
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 0a 0b 00 00       	call   800b4b <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 04 20 80 00 7c 	cmpl   $0xeec0007c,0x802004
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 36 0d 00 00       	call   800da0 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 60 11 80 00 	movl   $0x801160,(%esp)
  80007c:	e8 4b 01 00 00       	call   8001cc <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 71 11 80 00 	movl   $0x801171,(%esp)
  800097:	e8 30 01 00 00       	call   8001cc <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  8000a1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000a8:	00 
  8000a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b0:	00 
  8000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b8:	00 
  8000b9:	89 04 24             	mov    %eax,(%esp)
  8000bc:	e8 46 0d 00 00       	call   800e07 <ipc_send>
  8000c1:	eb d9                	jmp    80009c <umain+0x68>
	...

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	56                   	push   %esi
  8000c8:	53                   	push   %ebx
  8000c9:	83 ec 10             	sub    $0x10,%esp
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000d2:	e8 74 0a 00 00       	call   800b4b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000e3:	c1 e0 07             	shl    $0x7,%eax
  8000e6:	29 d0                	sub    %edx,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 f6                	test   %esi,%esi
  8000f4:	7e 07                	jle    8000fd <libmain+0x39>
		binaryname = argv[0];
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800101:	89 34 24             	mov    %esi,(%esp)
  800104:	e8 2b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800109:	e8 0a 00 00 00       	call   800118 <exit>
}
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	5b                   	pop    %ebx
  800112:	5e                   	pop    %esi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
  800115:	00 00                	add    %al,(%eax)
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800125:	e8 cf 09 00 00       	call   800af9 <sys_env_destroy>
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	53                   	push   %ebx
  800130:	83 ec 14             	sub    $0x14,%esp
  800133:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800136:	8b 03                	mov    (%ebx),%eax
  800138:	8b 55 08             	mov    0x8(%ebp),%edx
  80013b:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80013f:	40                   	inc    %eax
  800140:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800142:	3d ff 00 00 00       	cmp    $0xff,%eax
  800147:	75 19                	jne    800162 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800149:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800150:	00 
  800151:	8d 43 08             	lea    0x8(%ebx),%eax
  800154:	89 04 24             	mov    %eax,(%esp)
  800157:	e8 60 09 00 00       	call   800abc <sys_cputs>
		b->idx = 0;
  80015c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800162:	ff 43 04             	incl   0x4(%ebx)
}
  800165:	83 c4 14             	add    $0x14,%esp
  800168:	5b                   	pop    %ebx
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800174:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80017b:	00 00 00 
	b.cnt = 0;
  80017e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800185:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800188:	8b 45 0c             	mov    0xc(%ebp),%eax
  80018b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80018f:	8b 45 08             	mov    0x8(%ebp),%eax
  800192:	89 44 24 08          	mov    %eax,0x8(%esp)
  800196:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a0:	c7 04 24 2c 01 80 00 	movl   $0x80012c,(%esp)
  8001a7:	e8 82 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ac:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bc:	89 04 24             	mov    %eax,(%esp)
  8001bf:	e8 f8 08 00 00       	call   800abc <sys_cputs>

	return b.cnt;
}
  8001c4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001ca:	c9                   	leave  
  8001cb:	c3                   	ret    

008001cc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cc:	55                   	push   %ebp
  8001cd:	89 e5                	mov    %esp,%ebp
  8001cf:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001dc:	89 04 24             	mov    %eax,(%esp)
  8001df:	e8 87 ff ff ff       	call   80016b <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    
	...

008001e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 3c             	sub    $0x3c,%esp
  8001f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001f4:	89 d7                	mov    %edx,%edi
  8001f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800202:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800205:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800208:	85 c0                	test   %eax,%eax
  80020a:	75 08                	jne    800214 <printnum+0x2c>
  80020c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80020f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800212:	77 57                	ja     80026b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	89 74 24 10          	mov    %esi,0x10(%esp)
  800218:	4b                   	dec    %ebx
  800219:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80021d:	8b 45 10             	mov    0x10(%ebp),%eax
  800220:	89 44 24 08          	mov    %eax,0x8(%esp)
  800224:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800228:	8b 74 24 0c          	mov    0xc(%esp),%esi
  80022c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800233:	00 
  800234:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800237:	89 04 24             	mov    %eax,(%esp)
  80023a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	e8 ca 0c 00 00       	call   800f10 <__udivdi3>
  800246:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80024a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80024e:	89 04 24             	mov    %eax,(%esp)
  800251:	89 54 24 04          	mov    %edx,0x4(%esp)
  800255:	89 fa                	mov    %edi,%edx
  800257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025a:	e8 89 ff ff ff       	call   8001e8 <printnum>
  80025f:	eb 0f                	jmp    800270 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800261:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800265:	89 34 24             	mov    %esi,(%esp)
  800268:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026b:	4b                   	dec    %ebx
  80026c:	85 db                	test   %ebx,%ebx
  80026e:	7f f1                	jg     800261 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800270:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800274:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800278:	8b 45 10             	mov    0x10(%ebp),%eax
  80027b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800286:	00 
  800287:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028a:	89 04 24             	mov    %eax,(%esp)
  80028d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800290:	89 44 24 04          	mov    %eax,0x4(%esp)
  800294:	e8 97 0d 00 00       	call   801030 <__umoddi3>
  800299:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80029d:	0f be 80 92 11 80 00 	movsbl 0x801192(%eax),%eax
  8002a4:	89 04 24             	mov    %eax,(%esp)
  8002a7:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002aa:	83 c4 3c             	add    $0x3c,%esp
  8002ad:	5b                   	pop    %ebx
  8002ae:	5e                   	pop    %esi
  8002af:	5f                   	pop    %edi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b5:	83 fa 01             	cmp    $0x1,%edx
  8002b8:	7e 0e                	jle    8002c8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002bf:	89 08                	mov    %ecx,(%eax)
  8002c1:	8b 02                	mov    (%edx),%eax
  8002c3:	8b 52 04             	mov    0x4(%edx),%edx
  8002c6:	eb 22                	jmp    8002ea <getuint+0x38>
	else if (lflag)
  8002c8:	85 d2                	test   %edx,%edx
  8002ca:	74 10                	je     8002dc <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002cc:	8b 10                	mov    (%eax),%edx
  8002ce:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d1:	89 08                	mov    %ecx,(%eax)
  8002d3:	8b 02                	mov    (%edx),%eax
  8002d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8002da:	eb 0e                	jmp    8002ea <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002dc:	8b 10                	mov    (%eax),%edx
  8002de:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e1:	89 08                	mov    %ecx,(%eax)
  8002e3:	8b 02                	mov    (%edx),%eax
  8002e5:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ea:	5d                   	pop    %ebp
  8002eb:	c3                   	ret    

008002ec <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ec:	55                   	push   %ebp
  8002ed:	89 e5                	mov    %esp,%ebp
  8002ef:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f2:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8002f5:	8b 10                	mov    (%eax),%edx
  8002f7:	3b 50 04             	cmp    0x4(%eax),%edx
  8002fa:	73 08                	jae    800304 <sprintputch+0x18>
		*b->buf++ = ch;
  8002fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ff:	88 0a                	mov    %cl,(%edx)
  800301:	42                   	inc    %edx
  800302:	89 10                	mov    %edx,(%eax)
}
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80030c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80030f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800313:	8b 45 10             	mov    0x10(%ebp),%eax
  800316:	89 44 24 08          	mov    %eax,0x8(%esp)
  80031a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800321:	8b 45 08             	mov    0x8(%ebp),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	e8 02 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 4c             	sub    $0x4c,%esp
  800337:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033a:	8b 75 10             	mov    0x10(%ebp),%esi
  80033d:	eb 12                	jmp    800351 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80033f:	85 c0                	test   %eax,%eax
  800341:	0f 84 8b 03 00 00    	je     8006d2 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800347:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80034b:	89 04 24             	mov    %eax,(%esp)
  80034e:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800351:	0f b6 06             	movzbl (%esi),%eax
  800354:	46                   	inc    %esi
  800355:	83 f8 25             	cmp    $0x25,%eax
  800358:	75 e5                	jne    80033f <vprintfmt+0x11>
  80035a:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80035e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800365:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80036a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800371:	b9 00 00 00 00       	mov    $0x0,%ecx
  800376:	eb 26                	jmp    80039e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80037b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80037f:	eb 1d                	jmp    80039e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800381:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800384:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800388:	eb 14                	jmp    80039e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80038a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80038d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800394:	eb 08                	jmp    80039e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800396:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800399:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039e:	0f b6 06             	movzbl (%esi),%eax
  8003a1:	8d 56 01             	lea    0x1(%esi),%edx
  8003a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003a7:	8a 16                	mov    (%esi),%dl
  8003a9:	83 ea 23             	sub    $0x23,%edx
  8003ac:	80 fa 55             	cmp    $0x55,%dl
  8003af:	0f 87 01 03 00 00    	ja     8006b6 <vprintfmt+0x388>
  8003b5:	0f b6 d2             	movzbl %dl,%edx
  8003b8:	ff 24 95 60 12 80 00 	jmp    *0x801260(,%edx,4)
  8003bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003c2:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c7:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8003ca:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8003ce:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8003d1:	8d 50 d0             	lea    -0x30(%eax),%edx
  8003d4:	83 fa 09             	cmp    $0x9,%edx
  8003d7:	77 2a                	ja     800403 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003d9:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003da:	eb eb                	jmp    8003c7 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8003df:	8d 50 04             	lea    0x4(%eax),%edx
  8003e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e5:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003ea:	eb 17                	jmp    800403 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8003ec:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003f0:	78 98                	js     80038a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8003f5:	eb a7                	jmp    80039e <vprintfmt+0x70>
  8003f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8003fa:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800401:	eb 9b                	jmp    80039e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800403:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800407:	79 95                	jns    80039e <vprintfmt+0x70>
  800409:	eb 8b                	jmp    800396 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80040b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80040f:	eb 8d                	jmp    80039e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800411:	8b 45 14             	mov    0x14(%ebp),%eax
  800414:	8d 50 04             	lea    0x4(%eax),%edx
  800417:	89 55 14             	mov    %edx,0x14(%ebp)
  80041a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80041e:	8b 00                	mov    (%eax),%eax
  800420:	89 04 24             	mov    %eax,(%esp)
  800423:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800426:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800429:	e9 23 ff ff ff       	jmp    800351 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80042e:	8b 45 14             	mov    0x14(%ebp),%eax
  800431:	8d 50 04             	lea    0x4(%eax),%edx
  800434:	89 55 14             	mov    %edx,0x14(%ebp)
  800437:	8b 00                	mov    (%eax),%eax
  800439:	85 c0                	test   %eax,%eax
  80043b:	79 02                	jns    80043f <vprintfmt+0x111>
  80043d:	f7 d8                	neg    %eax
  80043f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800441:	83 f8 08             	cmp    $0x8,%eax
  800444:	7f 0b                	jg     800451 <vprintfmt+0x123>
  800446:	8b 04 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%eax
  80044d:	85 c0                	test   %eax,%eax
  80044f:	75 23                	jne    800474 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800451:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800455:	c7 44 24 08 aa 11 80 	movl   $0x8011aa,0x8(%esp)
  80045c:	00 
  80045d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800461:	8b 45 08             	mov    0x8(%ebp),%eax
  800464:	89 04 24             	mov    %eax,(%esp)
  800467:	e8 9a fe ff ff       	call   800306 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80046f:	e9 dd fe ff ff       	jmp    800351 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800474:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800478:	c7 44 24 08 b3 11 80 	movl   $0x8011b3,0x8(%esp)
  80047f:	00 
  800480:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800484:	8b 55 08             	mov    0x8(%ebp),%edx
  800487:	89 14 24             	mov    %edx,(%esp)
  80048a:	e8 77 fe ff ff       	call   800306 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800492:	e9 ba fe ff ff       	jmp    800351 <vprintfmt+0x23>
  800497:	89 f9                	mov    %edi,%ecx
  800499:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80049c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80049f:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a2:	8d 50 04             	lea    0x4(%eax),%edx
  8004a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a8:	8b 30                	mov    (%eax),%esi
  8004aa:	85 f6                	test   %esi,%esi
  8004ac:	75 05                	jne    8004b3 <vprintfmt+0x185>
				p = "(null)";
  8004ae:	be a3 11 80 00       	mov    $0x8011a3,%esi
			if (width > 0 && padc != '-')
  8004b3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004b7:	0f 8e 84 00 00 00    	jle    800541 <vprintfmt+0x213>
  8004bd:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8004c1:	74 7e                	je     800541 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c7:	89 34 24             	mov    %esi,(%esp)
  8004ca:	e8 ab 02 00 00       	call   80077a <strnlen>
  8004cf:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8004d2:	29 c2                	sub    %eax,%edx
  8004d4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8004d7:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8004db:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8004de:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8004e1:	89 de                	mov    %ebx,%esi
  8004e3:	89 d3                	mov    %edx,%ebx
  8004e5:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e7:	eb 0b                	jmp    8004f4 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8004e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ed:	89 3c 24             	mov    %edi,(%esp)
  8004f0:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f3:	4b                   	dec    %ebx
  8004f4:	85 db                	test   %ebx,%ebx
  8004f6:	7f f1                	jg     8004e9 <vprintfmt+0x1bb>
  8004f8:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8004fb:	89 f3                	mov    %esi,%ebx
  8004fd:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800500:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800503:	85 c0                	test   %eax,%eax
  800505:	79 05                	jns    80050c <vprintfmt+0x1de>
  800507:	b8 00 00 00 00       	mov    $0x0,%eax
  80050c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050f:	29 c2                	sub    %eax,%edx
  800511:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800514:	eb 2b                	jmp    800541 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800516:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80051a:	74 18                	je     800534 <vprintfmt+0x206>
  80051c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80051f:	83 fa 5e             	cmp    $0x5e,%edx
  800522:	76 10                	jbe    800534 <vprintfmt+0x206>
					putch('?', putdat);
  800524:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800528:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80052f:	ff 55 08             	call   *0x8(%ebp)
  800532:	eb 0a                	jmp    80053e <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800534:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800538:	89 04 24             	mov    %eax,(%esp)
  80053b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80053e:	ff 4d e4             	decl   -0x1c(%ebp)
  800541:	0f be 06             	movsbl (%esi),%eax
  800544:	46                   	inc    %esi
  800545:	85 c0                	test   %eax,%eax
  800547:	74 21                	je     80056a <vprintfmt+0x23c>
  800549:	85 ff                	test   %edi,%edi
  80054b:	78 c9                	js     800516 <vprintfmt+0x1e8>
  80054d:	4f                   	dec    %edi
  80054e:	79 c6                	jns    800516 <vprintfmt+0x1e8>
  800550:	8b 7d 08             	mov    0x8(%ebp),%edi
  800553:	89 de                	mov    %ebx,%esi
  800555:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800558:	eb 18                	jmp    800572 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80055a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80055e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800565:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800567:	4b                   	dec    %ebx
  800568:	eb 08                	jmp    800572 <vprintfmt+0x244>
  80056a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80056d:	89 de                	mov    %ebx,%esi
  80056f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800572:	85 db                	test   %ebx,%ebx
  800574:	7f e4                	jg     80055a <vprintfmt+0x22c>
  800576:	89 7d 08             	mov    %edi,0x8(%ebp)
  800579:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80057e:	e9 ce fd ff ff       	jmp    800351 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800583:	83 f9 01             	cmp    $0x1,%ecx
  800586:	7e 10                	jle    800598 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 50 08             	lea    0x8(%eax),%edx
  80058e:	89 55 14             	mov    %edx,0x14(%ebp)
  800591:	8b 30                	mov    (%eax),%esi
  800593:	8b 78 04             	mov    0x4(%eax),%edi
  800596:	eb 26                	jmp    8005be <vprintfmt+0x290>
	else if (lflag)
  800598:	85 c9                	test   %ecx,%ecx
  80059a:	74 12                	je     8005ae <vprintfmt+0x280>
		return va_arg(*ap, long);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8d 50 04             	lea    0x4(%eax),%edx
  8005a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005a5:	8b 30                	mov    (%eax),%esi
  8005a7:	89 f7                	mov    %esi,%edi
  8005a9:	c1 ff 1f             	sar    $0x1f,%edi
  8005ac:	eb 10                	jmp    8005be <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8d 50 04             	lea    0x4(%eax),%edx
  8005b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b7:	8b 30                	mov    (%eax),%esi
  8005b9:	89 f7                	mov    %esi,%edi
  8005bb:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005be:	85 ff                	test   %edi,%edi
  8005c0:	78 0a                	js     8005cc <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005c2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c7:	e9 ac 00 00 00       	jmp    800678 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8005cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005d0:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005d7:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8005da:	f7 de                	neg    %esi
  8005dc:	83 d7 00             	adc    $0x0,%edi
  8005df:	f7 df                	neg    %edi
			}
			base = 10;
  8005e1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e6:	e9 8d 00 00 00       	jmp    800678 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8005eb:	89 ca                	mov    %ecx,%edx
  8005ed:	8d 45 14             	lea    0x14(%ebp),%eax
  8005f0:	e8 bd fc ff ff       	call   8002b2 <getuint>
  8005f5:	89 c6                	mov    %eax,%esi
  8005f7:	89 d7                	mov    %edx,%edi
			base = 10;
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8005fe:	eb 78                	jmp    800678 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800600:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800604:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80060b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80060e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800612:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800619:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80061c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800620:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800627:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80062d:	e9 1f fd ff ff       	jmp    800351 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800632:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800636:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80063d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80064e:	8b 45 14             	mov    0x14(%ebp),%eax
  800651:	8d 50 04             	lea    0x4(%eax),%edx
  800654:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800657:	8b 30                	mov    (%eax),%esi
  800659:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80065e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800663:	eb 13                	jmp    800678 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800665:	89 ca                	mov    %ecx,%edx
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 43 fc ff ff       	call   8002b2 <getuint>
  80066f:	89 c6                	mov    %eax,%esi
  800671:	89 d7                	mov    %edx,%edi
			base = 16;
  800673:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800678:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  80067c:	89 54 24 10          	mov    %edx,0x10(%esp)
  800680:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800683:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800687:	89 44 24 08          	mov    %eax,0x8(%esp)
  80068b:	89 34 24             	mov    %esi,(%esp)
  80068e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800692:	89 da                	mov    %ebx,%edx
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	e8 4c fb ff ff       	call   8001e8 <printnum>
			break;
  80069c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80069f:	e9 ad fc ff ff       	jmp    800351 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a8:	89 04 24             	mov    %eax,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006b1:	e9 9b fc ff ff       	jmp    800351 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ba:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006c1:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006c4:	eb 01                	jmp    8006c7 <vprintfmt+0x399>
  8006c6:	4e                   	dec    %esi
  8006c7:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8006cb:	75 f9                	jne    8006c6 <vprintfmt+0x398>
  8006cd:	e9 7f fc ff ff       	jmp    800351 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8006d2:	83 c4 4c             	add    $0x4c,%esp
  8006d5:	5b                   	pop    %ebx
  8006d6:	5e                   	pop    %esi
  8006d7:	5f                   	pop    %edi
  8006d8:	5d                   	pop    %ebp
  8006d9:	c3                   	ret    

008006da <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 28             	sub    $0x28,%esp
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006ed:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	74 30                	je     80072b <vsnprintf+0x51>
  8006fb:	85 d2                	test   %edx,%edx
  8006fd:	7e 33                	jle    800732 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800706:	8b 45 10             	mov    0x10(%ebp),%eax
  800709:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800710:	89 44 24 04          	mov    %eax,0x4(%esp)
  800714:	c7 04 24 ec 02 80 00 	movl   $0x8002ec,(%esp)
  80071b:	e8 0e fc ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800720:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800723:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800729:	eb 0c                	jmp    800737 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80072b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800730:	eb 05                	jmp    800737 <vsnprintf+0x5d>
  800732:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800737:	c9                   	leave  
  800738:	c3                   	ret    

00800739 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80073f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800742:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800746:	8b 45 10             	mov    0x10(%ebp),%eax
  800749:	89 44 24 08          	mov    %eax,0x8(%esp)
  80074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800750:	89 44 24 04          	mov    %eax,0x4(%esp)
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	89 04 24             	mov    %eax,(%esp)
  80075a:	e8 7b ff ff ff       	call   8006da <vsnprintf>
	va_end(ap);

	return rc;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    
  800761:	00 00                	add    %al,(%eax)
	...

00800764 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax
  80076f:	eb 01                	jmp    800772 <strlen+0xe>
		n++;
  800771:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800772:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800776:	75 f9                	jne    800771 <strlen+0xd>
		n++;
	return n;
}
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800780:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800783:	b8 00 00 00 00       	mov    $0x0,%eax
  800788:	eb 01                	jmp    80078b <strnlen+0x11>
		n++;
  80078a:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078b:	39 d0                	cmp    %edx,%eax
  80078d:	74 06                	je     800795 <strnlen+0x1b>
  80078f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800793:	75 f5                	jne    80078a <strnlen+0x10>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 45 08             	mov    0x8(%ebp),%eax
  80079e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a6:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007a9:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007ac:	42                   	inc    %edx
  8007ad:	84 c9                	test   %cl,%cl
  8007af:	75 f5                	jne    8007a6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007b1:	5b                   	pop    %ebx
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	53                   	push   %ebx
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007be:	89 1c 24             	mov    %ebx,(%esp)
  8007c1:	e8 9e ff ff ff       	call   800764 <strlen>
	strcpy(dst + len, src);
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007cd:	01 d8                	add    %ebx,%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 c0 ff ff ff       	call   800797 <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	5b                   	pop    %ebx
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	56                   	push   %esi
  8007e3:	53                   	push   %ebx
  8007e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ea:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	eb 0c                	jmp    800800 <strncpy+0x21>
		*dst++ = *src;
  8007f4:	8a 1a                	mov    (%edx),%bl
  8007f6:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007f9:	80 3a 01             	cmpb   $0x1,(%edx)
  8007fc:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ff:	41                   	inc    %ecx
  800800:	39 f1                	cmp    %esi,%ecx
  800802:	75 f0                	jne    8007f4 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800804:	5b                   	pop    %ebx
  800805:	5e                   	pop    %esi
  800806:	5d                   	pop    %ebp
  800807:	c3                   	ret    

00800808 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	56                   	push   %esi
  80080c:	53                   	push   %ebx
  80080d:	8b 75 08             	mov    0x8(%ebp),%esi
  800810:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800813:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800816:	85 d2                	test   %edx,%edx
  800818:	75 0a                	jne    800824 <strlcpy+0x1c>
  80081a:	89 f0                	mov    %esi,%eax
  80081c:	eb 1a                	jmp    800838 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80081e:	88 18                	mov    %bl,(%eax)
  800820:	40                   	inc    %eax
  800821:	41                   	inc    %ecx
  800822:	eb 02                	jmp    800826 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800824:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800826:	4a                   	dec    %edx
  800827:	74 0a                	je     800833 <strlcpy+0x2b>
  800829:	8a 19                	mov    (%ecx),%bl
  80082b:	84 db                	test   %bl,%bl
  80082d:	75 ef                	jne    80081e <strlcpy+0x16>
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 02                	jmp    800835 <strlcpy+0x2d>
  800833:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800835:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800838:	29 f0                	sub    %esi,%eax
}
  80083a:	5b                   	pop    %ebx
  80083b:	5e                   	pop    %esi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800844:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800847:	eb 02                	jmp    80084b <strcmp+0xd>
		p++, q++;
  800849:	41                   	inc    %ecx
  80084a:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80084b:	8a 01                	mov    (%ecx),%al
  80084d:	84 c0                	test   %al,%al
  80084f:	74 04                	je     800855 <strcmp+0x17>
  800851:	3a 02                	cmp    (%edx),%al
  800853:	74 f4                	je     800849 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800855:	0f b6 c0             	movzbl %al,%eax
  800858:	0f b6 12             	movzbl (%edx),%edx
  80085b:	29 d0                	sub    %edx,%eax
}
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	53                   	push   %ebx
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800869:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  80086c:	eb 03                	jmp    800871 <strncmp+0x12>
		n--, p++, q++;
  80086e:	4a                   	dec    %edx
  80086f:	40                   	inc    %eax
  800870:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800871:	85 d2                	test   %edx,%edx
  800873:	74 14                	je     800889 <strncmp+0x2a>
  800875:	8a 18                	mov    (%eax),%bl
  800877:	84 db                	test   %bl,%bl
  800879:	74 04                	je     80087f <strncmp+0x20>
  80087b:	3a 19                	cmp    (%ecx),%bl
  80087d:	74 ef                	je     80086e <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 00             	movzbl (%eax),%eax
  800882:	0f b6 11             	movzbl (%ecx),%edx
  800885:	29 d0                	sub    %edx,%eax
  800887:	eb 05                	jmp    80088e <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800889:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80088e:	5b                   	pop    %ebx
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80089a:	eb 05                	jmp    8008a1 <strchr+0x10>
		if (*s == c)
  80089c:	38 ca                	cmp    %cl,%dl
  80089e:	74 0c                	je     8008ac <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008a0:	40                   	inc    %eax
  8008a1:	8a 10                	mov    (%eax),%dl
  8008a3:	84 d2                	test   %dl,%dl
  8008a5:	75 f5                	jne    80089c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008b7:	eb 05                	jmp    8008be <strfind+0x10>
		if (*s == c)
  8008b9:	38 ca                	cmp    %cl,%dl
  8008bb:	74 07                	je     8008c4 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8008bd:	40                   	inc    %eax
  8008be:	8a 10                	mov    (%eax),%dl
  8008c0:	84 d2                	test   %dl,%dl
  8008c2:	75 f5                	jne    8008b9 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	57                   	push   %edi
  8008ca:	56                   	push   %esi
  8008cb:	53                   	push   %ebx
  8008cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d5:	85 c9                	test   %ecx,%ecx
  8008d7:	74 30                	je     800909 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008d9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008df:	75 25                	jne    800906 <memset+0x40>
  8008e1:	f6 c1 03             	test   $0x3,%cl
  8008e4:	75 20                	jne    800906 <memset+0x40>
		c &= 0xFF;
  8008e6:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e9:	89 d3                	mov    %edx,%ebx
  8008eb:	c1 e3 08             	shl    $0x8,%ebx
  8008ee:	89 d6                	mov    %edx,%esi
  8008f0:	c1 e6 18             	shl    $0x18,%esi
  8008f3:	89 d0                	mov    %edx,%eax
  8008f5:	c1 e0 10             	shl    $0x10,%eax
  8008f8:	09 f0                	or     %esi,%eax
  8008fa:	09 d0                	or     %edx,%eax
  8008fc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008fe:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800901:	fc                   	cld    
  800902:	f3 ab                	rep stos %eax,%es:(%edi)
  800904:	eb 03                	jmp    800909 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800906:	fc                   	cld    
  800907:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800909:	89 f8                	mov    %edi,%eax
  80090b:	5b                   	pop    %ebx
  80090c:	5e                   	pop    %esi
  80090d:	5f                   	pop    %edi
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	57                   	push   %edi
  800914:	56                   	push   %esi
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 75 0c             	mov    0xc(%ebp),%esi
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80091e:	39 c6                	cmp    %eax,%esi
  800920:	73 34                	jae    800956 <memmove+0x46>
  800922:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800925:	39 d0                	cmp    %edx,%eax
  800927:	73 2d                	jae    800956 <memmove+0x46>
		s += n;
		d += n;
  800929:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092c:	f6 c2 03             	test   $0x3,%dl
  80092f:	75 1b                	jne    80094c <memmove+0x3c>
  800931:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800937:	75 13                	jne    80094c <memmove+0x3c>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 0e                	jne    80094c <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80093e:	83 ef 04             	sub    $0x4,%edi
  800941:	8d 72 fc             	lea    -0x4(%edx),%esi
  800944:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800947:	fd                   	std    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 07                	jmp    800953 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094c:	4f                   	dec    %edi
  80094d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800950:	fd                   	std    
  800951:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800953:	fc                   	cld    
  800954:	eb 20                	jmp    800976 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800956:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095c:	75 13                	jne    800971 <memmove+0x61>
  80095e:	a8 03                	test   $0x3,%al
  800960:	75 0f                	jne    800971 <memmove+0x61>
  800962:	f6 c1 03             	test   $0x3,%cl
  800965:	75 0a                	jne    800971 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800967:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80096a:	89 c7                	mov    %eax,%edi
  80096c:	fc                   	cld    
  80096d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096f:	eb 05                	jmp    800976 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800971:	89 c7                	mov    %eax,%edi
  800973:	fc                   	cld    
  800974:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800980:	8b 45 10             	mov    0x10(%ebp),%eax
  800983:	89 44 24 08          	mov    %eax,0x8(%esp)
  800987:	8b 45 0c             	mov    0xc(%ebp),%eax
  80098a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	89 04 24             	mov    %eax,(%esp)
  800994:	e8 77 ff ff ff       	call   800910 <memmove>
}
  800999:	c9                   	leave  
  80099a:	c3                   	ret    

0080099b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	57                   	push   %edi
  80099f:	56                   	push   %esi
  8009a0:	53                   	push   %ebx
  8009a1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	eb 16                	jmp    8009c7 <memcmp+0x2c>
		if (*s1 != *s2)
  8009b1:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009b4:	42                   	inc    %edx
  8009b5:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009b9:	38 c8                	cmp    %cl,%al
  8009bb:	74 0a                	je     8009c7 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  8009bd:	0f b6 c0             	movzbl %al,%eax
  8009c0:	0f b6 c9             	movzbl %cl,%ecx
  8009c3:	29 c8                	sub    %ecx,%eax
  8009c5:	eb 09                	jmp    8009d0 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c7:	39 da                	cmp    %ebx,%edx
  8009c9:	75 e6                	jne    8009b1 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5f                   	pop    %edi
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009de:	89 c2                	mov    %eax,%edx
  8009e0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e3:	eb 05                	jmp    8009ea <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e5:	38 08                	cmp    %cl,(%eax)
  8009e7:	74 05                	je     8009ee <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009e9:	40                   	inc    %eax
  8009ea:	39 d0                	cmp    %edx,%eax
  8009ec:	72 f7                	jb     8009e5 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	57                   	push   %edi
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009fc:	eb 01                	jmp    8009ff <strtol+0xf>
		s++;
  8009fe:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ff:	8a 02                	mov    (%edx),%al
  800a01:	3c 20                	cmp    $0x20,%al
  800a03:	74 f9                	je     8009fe <strtol+0xe>
  800a05:	3c 09                	cmp    $0x9,%al
  800a07:	74 f5                	je     8009fe <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a09:	3c 2b                	cmp    $0x2b,%al
  800a0b:	75 08                	jne    800a15 <strtol+0x25>
		s++;
  800a0d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a13:	eb 13                	jmp    800a28 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a15:	3c 2d                	cmp    $0x2d,%al
  800a17:	75 0a                	jne    800a23 <strtol+0x33>
		s++, neg = 1;
  800a19:	8d 52 01             	lea    0x1(%edx),%edx
  800a1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a21:	eb 05                	jmp    800a28 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a23:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a28:	85 db                	test   %ebx,%ebx
  800a2a:	74 05                	je     800a31 <strtol+0x41>
  800a2c:	83 fb 10             	cmp    $0x10,%ebx
  800a2f:	75 28                	jne    800a59 <strtol+0x69>
  800a31:	8a 02                	mov    (%edx),%al
  800a33:	3c 30                	cmp    $0x30,%al
  800a35:	75 10                	jne    800a47 <strtol+0x57>
  800a37:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a3b:	75 0a                	jne    800a47 <strtol+0x57>
		s += 2, base = 16;
  800a3d:	83 c2 02             	add    $0x2,%edx
  800a40:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a45:	eb 12                	jmp    800a59 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a47:	85 db                	test   %ebx,%ebx
  800a49:	75 0e                	jne    800a59 <strtol+0x69>
  800a4b:	3c 30                	cmp    $0x30,%al
  800a4d:	75 05                	jne    800a54 <strtol+0x64>
		s++, base = 8;
  800a4f:	42                   	inc    %edx
  800a50:	b3 08                	mov    $0x8,%bl
  800a52:	eb 05                	jmp    800a59 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a54:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5e:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a60:	8a 0a                	mov    (%edx),%cl
  800a62:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800a65:	80 fb 09             	cmp    $0x9,%bl
  800a68:	77 08                	ja     800a72 <strtol+0x82>
			dig = *s - '0';
  800a6a:	0f be c9             	movsbl %cl,%ecx
  800a6d:	83 e9 30             	sub    $0x30,%ecx
  800a70:	eb 1e                	jmp    800a90 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800a72:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800a75:	80 fb 19             	cmp    $0x19,%bl
  800a78:	77 08                	ja     800a82 <strtol+0x92>
			dig = *s - 'a' + 10;
  800a7a:	0f be c9             	movsbl %cl,%ecx
  800a7d:	83 e9 57             	sub    $0x57,%ecx
  800a80:	eb 0e                	jmp    800a90 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800a82:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 12                	ja     800a9c <strtol+0xac>
			dig = *s - 'A' + 10;
  800a8a:	0f be c9             	movsbl %cl,%ecx
  800a8d:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800a90:	39 f1                	cmp    %esi,%ecx
  800a92:	7d 0c                	jge    800aa0 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800a94:	42                   	inc    %edx
  800a95:	0f af c6             	imul   %esi,%eax
  800a98:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800a9a:	eb c4                	jmp    800a60 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800a9c:	89 c1                	mov    %eax,%ecx
  800a9e:	eb 02                	jmp    800aa2 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aa0:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aa2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa6:	74 05                	je     800aad <strtol+0xbd>
		*endptr = (char *) s;
  800aa8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aab:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800aad:	85 ff                	test   %edi,%edi
  800aaf:	74 04                	je     800ab5 <strtol+0xc5>
  800ab1:	89 c8                	mov    %ecx,%eax
  800ab3:	f7 d8                	neg    %eax
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    
	...

00800abc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aca:	8b 55 08             	mov    0x8(%ebp),%edx
  800acd:	89 c3                	mov    %eax,%ebx
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	89 c6                	mov    %eax,%esi
  800ad3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5f                   	pop    %edi
  800ad8:	5d                   	pop    %ebp
  800ad9:	c3                   	ret    

00800ada <sys_cgetc>:

int
sys_cgetc(void)
{
  800ada:	55                   	push   %ebp
  800adb:	89 e5                	mov    %esp,%ebp
  800add:	57                   	push   %edi
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aea:	89 d1                	mov    %edx,%ecx
  800aec:	89 d3                	mov    %edx,%ebx
  800aee:	89 d7                	mov    %edx,%edi
  800af0:	89 d6                	mov    %edx,%esi
  800af2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	57                   	push   %edi
  800afd:	56                   	push   %esi
  800afe:	53                   	push   %ebx
  800aff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b07:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0f:	89 cb                	mov    %ecx,%ebx
  800b11:	89 cf                	mov    %ecx,%edi
  800b13:	89 ce                	mov    %ecx,%esi
  800b15:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	7e 28                	jle    800b43 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800b1f:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800b26:	00 
  800b27:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800b2e:	00 
  800b2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b36:	00 
  800b37:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800b3e:	e8 75 03 00 00       	call   800eb8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b43:	83 c4 2c             	add    $0x2c,%esp
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	ba 00 00 00 00       	mov    $0x0,%edx
  800b56:	b8 02 00 00 00       	mov    $0x2,%eax
  800b5b:	89 d1                	mov    %edx,%ecx
  800b5d:	89 d3                	mov    %edx,%ebx
  800b5f:	89 d7                	mov    %edx,%edi
  800b61:	89 d6                	mov    %edx,%esi
  800b63:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b65:	5b                   	pop    %ebx
  800b66:	5e                   	pop    %esi
  800b67:	5f                   	pop    %edi
  800b68:	5d                   	pop    %ebp
  800b69:	c3                   	ret    

00800b6a <sys_yield>:

void
sys_yield(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7a:	89 d1                	mov    %edx,%ecx
  800b7c:	89 d3                	mov    %edx,%ebx
  800b7e:	89 d7                	mov    %edx,%edi
  800b80:	89 d6                	mov    %edx,%esi
  800b82:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5f                   	pop    %edi
  800b87:	5d                   	pop    %ebp
  800b88:	c3                   	ret    

00800b89 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	57                   	push   %edi
  800b8d:	56                   	push   %esi
  800b8e:	53                   	push   %ebx
  800b8f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b92:	be 00 00 00 00       	mov    $0x0,%esi
  800b97:	b8 04 00 00 00       	mov    $0x4,%eax
  800b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba5:	89 f7                	mov    %esi,%edi
  800ba7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	7e 28                	jle    800bd5 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800bb1:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800bb8:	00 
  800bb9:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800bc0:	00 
  800bc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bc8:	00 
  800bc9:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800bd0:	e8 e3 02 00 00       	call   800eb8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd5:	83 c4 2c             	add    $0x2c,%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 05 00 00 00       	mov    $0x5,%eax
  800beb:	8b 75 18             	mov    0x18(%ebp),%esi
  800bee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 28                	jle    800c28 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c04:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800c0b:	00 
  800c0c:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800c13:	00 
  800c14:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c1b:	00 
  800c1c:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800c23:	e8 90 02 00 00       	call   800eb8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c28:	83 c4 2c             	add    $0x2c,%esp
  800c2b:	5b                   	pop    %ebx
  800c2c:	5e                   	pop    %esi
  800c2d:	5f                   	pop    %edi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c46:	8b 55 08             	mov    0x8(%ebp),%edx
  800c49:	89 df                	mov    %ebx,%edi
  800c4b:	89 de                	mov    %ebx,%esi
  800c4d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4f:	85 c0                	test   %eax,%eax
  800c51:	7e 28                	jle    800c7b <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c53:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c57:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800c5e:	00 
  800c5f:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800c66:	00 
  800c67:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c6e:	00 
  800c6f:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800c76:	e8 3d 02 00 00       	call   800eb8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7b:	83 c4 2c             	add    $0x2c,%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 08 00 00 00       	mov    $0x8,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 28                	jle    800cce <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	89 44 24 10          	mov    %eax,0x10(%esp)
  800caa:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800cb1:	00 
  800cb2:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800cb9:	00 
  800cba:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cc1:	00 
  800cc2:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800cc9:	e8 ea 01 00 00       	call   800eb8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cce:	83 c4 2c             	add    $0x2c,%esp
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5f                   	pop    %edi
  800cd4:	5d                   	pop    %ebp
  800cd5:	c3                   	ret    

00800cd6 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cd6:	55                   	push   %ebp
  800cd7:	89 e5                	mov    %esp,%ebp
  800cd9:	57                   	push   %edi
  800cda:	56                   	push   %esi
  800cdb:	53                   	push   %ebx
  800cdc:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cec:	8b 55 08             	mov    0x8(%ebp),%edx
  800cef:	89 df                	mov    %ebx,%edi
  800cf1:	89 de                	mov    %ebx,%esi
  800cf3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 28                	jle    800d21 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfd:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d04:	00 
  800d05:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800d0c:	00 
  800d0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d14:	00 
  800d15:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800d1c:	e8 97 01 00 00       	call   800eb8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d21:	83 c4 2c             	add    $0x2c,%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2f:	be 00 00 00 00       	mov    $0x0,%esi
  800d34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d42:	8b 55 08             	mov    0x8(%ebp),%edx
  800d45:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
  800d52:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d5a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d62:	89 cb                	mov    %ecx,%ebx
  800d64:	89 cf                	mov    %ecx,%edi
  800d66:	89 ce                	mov    %ecx,%esi
  800d68:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7e 28                	jle    800d96 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d72:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d79:	00 
  800d7a:	c7 44 24 08 e4 13 80 	movl   $0x8013e4,0x8(%esp)
  800d81:	00 
  800d82:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d89:	00 
  800d8a:	c7 04 24 01 14 80 00 	movl   $0x801401,(%esp)
  800d91:	e8 22 01 00 00       	call   800eb8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d96:	83 c4 2c             	add    $0x2c,%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
	...

00800da0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	83 ec 10             	sub    $0x10,%esp
  800da8:	8b 75 08             	mov    0x8(%ebp),%esi
  800dab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dae:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  800db1:	85 c0                	test   %eax,%eax
  800db3:	75 05                	jne    800dba <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  800db5:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  800dba:	89 04 24             	mov    %eax,(%esp)
  800dbd:	e8 8a ff ff ff       	call   800d4c <sys_ipc_recv>
	if (!err) {
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	75 26                	jne    800dec <ipc_recv+0x4c>
		if (from_env_store) {
  800dc6:	85 f6                	test   %esi,%esi
  800dc8:	74 0a                	je     800dd4 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  800dca:	a1 04 20 80 00       	mov    0x802004,%eax
  800dcf:	8b 40 74             	mov    0x74(%eax),%eax
  800dd2:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  800dd4:	85 db                	test   %ebx,%ebx
  800dd6:	74 0a                	je     800de2 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  800dd8:	a1 04 20 80 00       	mov    0x802004,%eax
  800ddd:	8b 40 78             	mov    0x78(%eax),%eax
  800de0:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  800de2:	a1 04 20 80 00       	mov    0x802004,%eax
  800de7:	8b 40 70             	mov    0x70(%eax),%eax
  800dea:	eb 14                	jmp    800e00 <ipc_recv+0x60>
	}
	if (from_env_store) {
  800dec:	85 f6                	test   %esi,%esi
  800dee:	74 06                	je     800df6 <ipc_recv+0x56>
		*from_env_store = 0;
  800df0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  800df6:	85 db                	test   %ebx,%ebx
  800df8:	74 06                	je     800e00 <ipc_recv+0x60>
		*perm_store = 0;
  800dfa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  800e00:	83 c4 10             	add    $0x10,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e07:	55                   	push   %ebp
  800e08:	89 e5                	mov    %esp,%ebp
  800e0a:	57                   	push   %edi
  800e0b:	56                   	push   %esi
  800e0c:	53                   	push   %ebx
  800e0d:	83 ec 1c             	sub    $0x1c,%esp
  800e10:	8b 75 10             	mov    0x10(%ebp),%esi
  800e13:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  800e16:	85 f6                	test   %esi,%esi
  800e18:	75 05                	jne    800e1f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  800e1a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  800e1f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800e23:	89 74 24 08          	mov    %esi,0x8(%esp)
  800e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e31:	89 04 24             	mov    %eax,(%esp)
  800e34:	e8 f0 fe ff ff       	call   800d29 <sys_ipc_try_send>
  800e39:	89 c3                	mov    %eax,%ebx
		sys_yield();
  800e3b:	e8 2a fd ff ff       	call   800b6a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  800e40:	83 fb f9             	cmp    $0xfffffff9,%ebx
  800e43:	74 da                	je     800e1f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  800e45:	85 db                	test   %ebx,%ebx
  800e47:	74 20                	je     800e69 <ipc_send+0x62>
		panic("send fail: %e", err);
  800e49:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e4d:	c7 44 24 08 0f 14 80 	movl   $0x80140f,0x8(%esp)
  800e54:	00 
  800e55:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  800e5c:	00 
  800e5d:	c7 04 24 1d 14 80 00 	movl   $0x80141d,(%esp)
  800e64:	e8 4f 00 00 00       	call   800eb8 <_panic>
	}
	return;
}
  800e69:	83 c4 1c             	add    $0x1c,%esp
  800e6c:	5b                   	pop    %ebx
  800e6d:	5e                   	pop    %esi
  800e6e:	5f                   	pop    %edi
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	53                   	push   %ebx
  800e75:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e7d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  800e84:	89 c2                	mov    %eax,%edx
  800e86:	c1 e2 07             	shl    $0x7,%edx
  800e89:	29 ca                	sub    %ecx,%edx
  800e8b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e91:	8b 52 50             	mov    0x50(%edx),%edx
  800e94:	39 da                	cmp    %ebx,%edx
  800e96:	75 0f                	jne    800ea7 <ipc_find_env+0x36>
			return envs[i].env_id;
  800e98:	c1 e0 07             	shl    $0x7,%eax
  800e9b:	29 c8                	sub    %ecx,%eax
  800e9d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  800ea2:	8b 40 40             	mov    0x40(%eax),%eax
  800ea5:	eb 0c                	jmp    800eb3 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  800ea7:	40                   	inc    %eax
  800ea8:	3d 00 04 00 00       	cmp    $0x400,%eax
  800ead:	75 ce                	jne    800e7d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  800eaf:	66 b8 00 00          	mov    $0x0,%ax
}
  800eb3:	5b                   	pop    %ebx
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    
	...

00800eb8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	56                   	push   %esi
  800ebc:	53                   	push   %ebx
  800ebd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800ec0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ec3:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ec9:	e8 7d fc ff ff       	call   800b4b <sys_getenvid>
  800ece:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ed1:	89 54 24 10          	mov    %edx,0x10(%esp)
  800ed5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800edc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800ee0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee4:	c7 04 24 28 14 80 00 	movl   $0x801428,(%esp)
  800eeb:	e8 dc f2 ff ff       	call   8001cc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ef0:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ef4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef7:	89 04 24             	mov    %eax,(%esp)
  800efa:	e8 6c f2 ff ff       	call   80016b <vcprintf>
	cprintf("\n");
  800eff:	c7 04 24 6f 11 80 00 	movl   $0x80116f,(%esp)
  800f06:	e8 c1 f2 ff ff       	call   8001cc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f0b:	cc                   	int3   
  800f0c:	eb fd                	jmp    800f0b <_panic+0x53>
	...

00800f10 <__udivdi3>:
  800f10:	55                   	push   %ebp
  800f11:	57                   	push   %edi
  800f12:	56                   	push   %esi
  800f13:	83 ec 10             	sub    $0x10,%esp
  800f16:	8b 74 24 20          	mov    0x20(%esp),%esi
  800f1a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800f1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f22:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800f26:	89 cd                	mov    %ecx,%ebp
  800f28:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	75 2c                	jne    800f5c <__udivdi3+0x4c>
  800f30:	39 f9                	cmp    %edi,%ecx
  800f32:	77 68                	ja     800f9c <__udivdi3+0x8c>
  800f34:	85 c9                	test   %ecx,%ecx
  800f36:	75 0b                	jne    800f43 <__udivdi3+0x33>
  800f38:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3d:	31 d2                	xor    %edx,%edx
  800f3f:	f7 f1                	div    %ecx
  800f41:	89 c1                	mov    %eax,%ecx
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	89 f8                	mov    %edi,%eax
  800f47:	f7 f1                	div    %ecx
  800f49:	89 c7                	mov    %eax,%edi
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	f7 f1                	div    %ecx
  800f4f:	89 c6                	mov    %eax,%esi
  800f51:	89 f0                	mov    %esi,%eax
  800f53:	89 fa                	mov    %edi,%edx
  800f55:	83 c4 10             	add    $0x10,%esp
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    
  800f5c:	39 f8                	cmp    %edi,%eax
  800f5e:	77 2c                	ja     800f8c <__udivdi3+0x7c>
  800f60:	0f bd f0             	bsr    %eax,%esi
  800f63:	83 f6 1f             	xor    $0x1f,%esi
  800f66:	75 4c                	jne    800fb4 <__udivdi3+0xa4>
  800f68:	39 f8                	cmp    %edi,%eax
  800f6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6f:	72 0a                	jb     800f7b <__udivdi3+0x6b>
  800f71:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800f75:	0f 87 ad 00 00 00    	ja     801028 <__udivdi3+0x118>
  800f7b:	be 01 00 00 00       	mov    $0x1,%esi
  800f80:	89 f0                	mov    %esi,%eax
  800f82:	89 fa                	mov    %edi,%edx
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	5e                   	pop    %esi
  800f88:	5f                   	pop    %edi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    
  800f8b:	90                   	nop
  800f8c:	31 ff                	xor    %edi,%edi
  800f8e:	31 f6                	xor    %esi,%esi
  800f90:	89 f0                	mov    %esi,%eax
  800f92:	89 fa                	mov    %edi,%edx
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	5e                   	pop    %esi
  800f98:	5f                   	pop    %edi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    
  800f9b:	90                   	nop
  800f9c:	89 fa                	mov    %edi,%edx
  800f9e:	89 f0                	mov    %esi,%eax
  800fa0:	f7 f1                	div    %ecx
  800fa2:	89 c6                	mov    %eax,%esi
  800fa4:	31 ff                	xor    %edi,%edi
  800fa6:	89 f0                	mov    %esi,%eax
  800fa8:	89 fa                	mov    %edi,%edx
  800faa:	83 c4 10             	add    $0x10,%esp
  800fad:	5e                   	pop    %esi
  800fae:	5f                   	pop    %edi
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    
  800fb1:	8d 76 00             	lea    0x0(%esi),%esi
  800fb4:	89 f1                	mov    %esi,%ecx
  800fb6:	d3 e0                	shl    %cl,%eax
  800fb8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fbc:	b8 20 00 00 00       	mov    $0x20,%eax
  800fc1:	29 f0                	sub    %esi,%eax
  800fc3:	89 ea                	mov    %ebp,%edx
  800fc5:	88 c1                	mov    %al,%cl
  800fc7:	d3 ea                	shr    %cl,%edx
  800fc9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800fcd:	09 ca                	or     %ecx,%edx
  800fcf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fd3:	89 f1                	mov    %esi,%ecx
  800fd5:	d3 e5                	shl    %cl,%ebp
  800fd7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800fdb:	89 fd                	mov    %edi,%ebp
  800fdd:	88 c1                	mov    %al,%cl
  800fdf:	d3 ed                	shr    %cl,%ebp
  800fe1:	89 fa                	mov    %edi,%edx
  800fe3:	89 f1                	mov    %esi,%ecx
  800fe5:	d3 e2                	shl    %cl,%edx
  800fe7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800feb:	88 c1                	mov    %al,%cl
  800fed:	d3 ef                	shr    %cl,%edi
  800fef:	09 d7                	or     %edx,%edi
  800ff1:	89 f8                	mov    %edi,%eax
  800ff3:	89 ea                	mov    %ebp,%edx
  800ff5:	f7 74 24 08          	divl   0x8(%esp)
  800ff9:	89 d1                	mov    %edx,%ecx
  800ffb:	89 c7                	mov    %eax,%edi
  800ffd:	f7 64 24 0c          	mull   0xc(%esp)
  801001:	39 d1                	cmp    %edx,%ecx
  801003:	72 17                	jb     80101c <__udivdi3+0x10c>
  801005:	74 09                	je     801010 <__udivdi3+0x100>
  801007:	89 fe                	mov    %edi,%esi
  801009:	31 ff                	xor    %edi,%edi
  80100b:	e9 41 ff ff ff       	jmp    800f51 <__udivdi3+0x41>
  801010:	8b 54 24 04          	mov    0x4(%esp),%edx
  801014:	89 f1                	mov    %esi,%ecx
  801016:	d3 e2                	shl    %cl,%edx
  801018:	39 c2                	cmp    %eax,%edx
  80101a:	73 eb                	jae    801007 <__udivdi3+0xf7>
  80101c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80101f:	31 ff                	xor    %edi,%edi
  801021:	e9 2b ff ff ff       	jmp    800f51 <__udivdi3+0x41>
  801026:	66 90                	xchg   %ax,%ax
  801028:	31 f6                	xor    %esi,%esi
  80102a:	e9 22 ff ff ff       	jmp    800f51 <__udivdi3+0x41>
	...

00801030 <__umoddi3>:
  801030:	55                   	push   %ebp
  801031:	57                   	push   %edi
  801032:	56                   	push   %esi
  801033:	83 ec 20             	sub    $0x20,%esp
  801036:	8b 44 24 30          	mov    0x30(%esp),%eax
  80103a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80103e:	89 44 24 14          	mov    %eax,0x14(%esp)
  801042:	8b 74 24 34          	mov    0x34(%esp),%esi
  801046:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80104a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80104e:	89 c7                	mov    %eax,%edi
  801050:	89 f2                	mov    %esi,%edx
  801052:	85 ed                	test   %ebp,%ebp
  801054:	75 16                	jne    80106c <__umoddi3+0x3c>
  801056:	39 f1                	cmp    %esi,%ecx
  801058:	0f 86 a6 00 00 00    	jbe    801104 <__umoddi3+0xd4>
  80105e:	f7 f1                	div    %ecx
  801060:	89 d0                	mov    %edx,%eax
  801062:	31 d2                	xor    %edx,%edx
  801064:	83 c4 20             	add    $0x20,%esp
  801067:	5e                   	pop    %esi
  801068:	5f                   	pop    %edi
  801069:	5d                   	pop    %ebp
  80106a:	c3                   	ret    
  80106b:	90                   	nop
  80106c:	39 f5                	cmp    %esi,%ebp
  80106e:	0f 87 ac 00 00 00    	ja     801120 <__umoddi3+0xf0>
  801074:	0f bd c5             	bsr    %ebp,%eax
  801077:	83 f0 1f             	xor    $0x1f,%eax
  80107a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80107e:	0f 84 a8 00 00 00    	je     80112c <__umoddi3+0xfc>
  801084:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801088:	d3 e5                	shl    %cl,%ebp
  80108a:	bf 20 00 00 00       	mov    $0x20,%edi
  80108f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  801093:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801097:	89 f9                	mov    %edi,%ecx
  801099:	d3 e8                	shr    %cl,%eax
  80109b:	09 e8                	or     %ebp,%eax
  80109d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8010a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8010a5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010a9:	d3 e0                	shl    %cl,%eax
  8010ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010af:	89 f2                	mov    %esi,%edx
  8010b1:	d3 e2                	shl    %cl,%edx
  8010b3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010b7:	d3 e0                	shl    %cl,%eax
  8010b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8010bd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8010c1:	89 f9                	mov    %edi,%ecx
  8010c3:	d3 e8                	shr    %cl,%eax
  8010c5:	09 d0                	or     %edx,%eax
  8010c7:	d3 ee                	shr    %cl,%esi
  8010c9:	89 f2                	mov    %esi,%edx
  8010cb:	f7 74 24 18          	divl   0x18(%esp)
  8010cf:	89 d6                	mov    %edx,%esi
  8010d1:	f7 64 24 0c          	mull   0xc(%esp)
  8010d5:	89 c5                	mov    %eax,%ebp
  8010d7:	89 d1                	mov    %edx,%ecx
  8010d9:	39 d6                	cmp    %edx,%esi
  8010db:	72 67                	jb     801144 <__umoddi3+0x114>
  8010dd:	74 75                	je     801154 <__umoddi3+0x124>
  8010df:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8010e3:	29 e8                	sub    %ebp,%eax
  8010e5:	19 ce                	sbb    %ecx,%esi
  8010e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010eb:	d3 e8                	shr    %cl,%eax
  8010ed:	89 f2                	mov    %esi,%edx
  8010ef:	89 f9                	mov    %edi,%ecx
  8010f1:	d3 e2                	shl    %cl,%edx
  8010f3:	09 d0                	or     %edx,%eax
  8010f5:	89 f2                	mov    %esi,%edx
  8010f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8010fb:	d3 ea                	shr    %cl,%edx
  8010fd:	83 c4 20             	add    $0x20,%esp
  801100:	5e                   	pop    %esi
  801101:	5f                   	pop    %edi
  801102:	5d                   	pop    %ebp
  801103:	c3                   	ret    
  801104:	85 c9                	test   %ecx,%ecx
  801106:	75 0b                	jne    801113 <__umoddi3+0xe3>
  801108:	b8 01 00 00 00       	mov    $0x1,%eax
  80110d:	31 d2                	xor    %edx,%edx
  80110f:	f7 f1                	div    %ecx
  801111:	89 c1                	mov    %eax,%ecx
  801113:	89 f0                	mov    %esi,%eax
  801115:	31 d2                	xor    %edx,%edx
  801117:	f7 f1                	div    %ecx
  801119:	89 f8                	mov    %edi,%eax
  80111b:	e9 3e ff ff ff       	jmp    80105e <__umoddi3+0x2e>
  801120:	89 f2                	mov    %esi,%edx
  801122:	83 c4 20             	add    $0x20,%esp
  801125:	5e                   	pop    %esi
  801126:	5f                   	pop    %edi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    
  801129:	8d 76 00             	lea    0x0(%esi),%esi
  80112c:	39 f5                	cmp    %esi,%ebp
  80112e:	72 04                	jb     801134 <__umoddi3+0x104>
  801130:	39 f9                	cmp    %edi,%ecx
  801132:	77 06                	ja     80113a <__umoddi3+0x10a>
  801134:	89 f2                	mov    %esi,%edx
  801136:	29 cf                	sub    %ecx,%edi
  801138:	19 ea                	sbb    %ebp,%edx
  80113a:	89 f8                	mov    %edi,%eax
  80113c:	83 c4 20             	add    $0x20,%esp
  80113f:	5e                   	pop    %esi
  801140:	5f                   	pop    %edi
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    
  801143:	90                   	nop
  801144:	89 d1                	mov    %edx,%ecx
  801146:	89 c5                	mov    %eax,%ebp
  801148:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80114c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801150:	eb 8d                	jmp    8010df <__umoddi3+0xaf>
  801152:	66 90                	xchg   %ax,%ax
  801154:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801158:	72 ea                	jb     801144 <__umoddi3+0x114>
  80115a:	89 f1                	mov    %esi,%ecx
  80115c:	eb 81                	jmp    8010df <__umoddi3+0xaf>
