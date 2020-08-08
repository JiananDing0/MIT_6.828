
obj/user/spawnfaultio.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
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
  800037:	83 ec 18             	sub    $0x18,%esp
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  80003a:	a1 04 40 80 00       	mov    0x804004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 20 25 80 00 	movl   $0x802520,(%esp)
  80004d:	e8 aa 01 00 00       	call   8001fc <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 3e 25 80 	movl   $0x80253e,0x4(%esp)
  800061:	00 
  800062:	c7 04 24 3e 25 80 00 	movl   $0x80253e,(%esp)
  800069:	e8 72 1b 00 00       	call   801be0 <spawnl>
  80006e:	85 c0                	test   %eax,%eax
  800070:	79 20                	jns    800092 <umain+0x5e>
		panic("spawn(faultio) failed: %e", r);
  800072:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800076:	c7 44 24 08 46 25 80 	movl   $0x802546,0x8(%esp)
  80007d:	00 
  80007e:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  800085:	00 
  800086:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  80008d:	e8 72 00 00 00       	call   800104 <_panic>
}
  800092:	c9                   	leave  
  800093:	c3                   	ret    

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	56                   	push   %esi
  800098:	53                   	push   %ebx
  800099:	83 ec 10             	sub    $0x10,%esp
  80009c:	8b 75 08             	mov    0x8(%ebp),%esi
  80009f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000a2:	e8 d4 0a 00 00       	call   800b7b <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8000a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ac:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8000b3:	c1 e0 07             	shl    $0x7,%eax
  8000b6:	29 d0                	sub    %edx,%eax
  8000b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000bd:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c2:	85 f6                	test   %esi,%esi
  8000c4:	7e 07                	jle    8000cd <libmain+0x39>
		binaryname = argv[0];
  8000c6:	8b 03                	mov    (%ebx),%eax
  8000c8:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d1:	89 34 24             	mov    %esi,(%esp)
  8000d4:	e8 5b ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000d9:	e8 0a 00 00 00       	call   8000e8 <exit>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    
  8000e5:	00 00                	add    %al,(%eax)
	...

008000e8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e8:	55                   	push   %ebp
  8000e9:	89 e5                	mov    %esp,%ebp
  8000eb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ee:	e8 18 0f 00 00       	call   80100b <close_all>
	sys_env_destroy(0);
  8000f3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000fa:	e8 2a 0a 00 00       	call   800b29 <sys_env_destroy>
}
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    
  800101:	00 00                	add    %al,(%eax)
	...

00800104 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	56                   	push   %esi
  800108:	53                   	push   %ebx
  800109:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80010c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80010f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  800115:	e8 61 0a 00 00       	call   800b7b <sys_getenvid>
  80011a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80011d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800121:	8b 55 08             	mov    0x8(%ebp),%edx
  800124:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800128:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80012c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800130:	c7 04 24 80 25 80 00 	movl   $0x802580,(%esp)
  800137:	e8 c0 00 00 00       	call   8001fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80013c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800140:	8b 45 10             	mov    0x10(%ebp),%eax
  800143:	89 04 24             	mov    %eax,(%esp)
  800146:	e8 50 00 00 00       	call   80019b <vcprintf>
	cprintf("\n");
  80014b:	c7 04 24 60 2a 80 00 	movl   $0x802a60,(%esp)
  800152:	e8 a5 00 00 00       	call   8001fc <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800157:	cc                   	int3   
  800158:	eb fd                	jmp    800157 <_panic+0x53>
	...

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
  800271:	e8 4e 20 00 00       	call   8022c4 <__udivdi3>
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
  8002c4:	e8 1b 21 00 00       	call   8023e4 <__umoddi3>
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	0f be 80 a3 25 80 00 	movsbl 0x8025a3(%eax),%eax
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
  8003e8:	ff 24 95 e0 26 80 00 	jmp    *0x8026e0(,%edx,4)
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
  800471:	83 f8 0f             	cmp    $0xf,%eax
  800474:	7f 0b                	jg     800481 <vprintfmt+0x123>
  800476:	8b 04 85 40 28 80 00 	mov    0x802840(,%eax,4),%eax
  80047d:	85 c0                	test   %eax,%eax
  80047f:	75 23                	jne    8004a4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800481:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800485:	c7 44 24 08 bb 25 80 	movl   $0x8025bb,0x8(%esp)
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
  8004a8:	c7 44 24 08 9a 29 80 	movl   $0x80299a,0x8(%esp)
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
  8004de:	be b4 25 80 00       	mov    $0x8025b4,%esi
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
  800b57:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800b5e:	00 
  800b5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800b66:	00 
  800b67:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800b6e:	e8 91 f5 ff ff       	call   800104 <_panic>

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
  800ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800be9:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800bf0:	00 
  800bf1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800bf8:	00 
  800bf9:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800c00:	e8 ff f4 ff ff       	call   800104 <_panic>

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
  800c3c:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800c43:	00 
  800c44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c4b:	00 
  800c4c:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800c53:	e8 ac f4 ff ff       	call   800104 <_panic>

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
  800c8f:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800c96:	00 
  800c97:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c9e:	00 
  800c9f:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800ca6:	e8 59 f4 ff ff       	call   800104 <_panic>

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
  800ce2:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800ce9:	00 
  800cea:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf1:	00 
  800cf2:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800cf9:	e8 06 f4 ff ff       	call   800104 <_panic>

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

00800d06 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800d27:	7e 28                	jle    800d51 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d2d:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d34:	00 
  800d35:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800d3c:	00 
  800d3d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d44:	00 
  800d45:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800d4c:	e8 b3 f3 ff ff       	call   800104 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d51:	83 c4 2c             	add    $0x2c,%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	89 df                	mov    %ebx,%edi
  800d74:	89 de                	mov    %ebx,%esi
  800d76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 28                	jle    800da4 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d80:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800d87:	00 
  800d88:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800d8f:	00 
  800d90:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d97:	00 
  800d98:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800d9f:	e8 60 f3 ff ff       	call   800104 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800da4:	83 c4 2c             	add    $0x2c,%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	be 00 00 00 00       	mov    $0x0,%esi
  800db7:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc8:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dca:	5b                   	pop    %ebx
  800dcb:	5e                   	pop    %esi
  800dcc:	5f                   	pop    %edi
  800dcd:	5d                   	pop    %ebp
  800dce:	c3                   	ret    

00800dcf <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddd:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	89 cb                	mov    %ecx,%ebx
  800de7:	89 cf                	mov    %ecx,%edi
  800de9:	89 ce                	mov    %ecx,%esi
  800deb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ded:	85 c0                	test   %eax,%eax
  800def:	7e 28                	jle    800e19 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df5:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800dfc:	00 
  800dfd:	c7 44 24 08 9f 28 80 	movl   $0x80289f,0x8(%esp)
  800e04:	00 
  800e05:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e0c:	00 
  800e0d:	c7 04 24 bc 28 80 00 	movl   $0x8028bc,(%esp)
  800e14:	e8 eb f2 ff ff       	call   800104 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e19:	83 c4 2c             	add    $0x2c,%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    
  800e21:	00 00                	add    %al,(%eax)
	...

00800e24 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	05 00 00 00 30       	add    $0x30000000,%eax
  800e2f:	c1 e8 0c             	shr    $0xc,%eax
}
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3d:	89 04 24             	mov    %eax,(%esp)
  800e40:	e8 df ff ff ff       	call   800e24 <fd2num>
  800e45:	05 20 00 0d 00       	add    $0xd0020,%eax
  800e4a:	c1 e0 0c             	shl    $0xc,%eax
}
  800e4d:	c9                   	leave  
  800e4e:	c3                   	ret    

00800e4f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	53                   	push   %ebx
  800e53:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e56:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  800e5b:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e5d:	89 c2                	mov    %eax,%edx
  800e5f:	c1 ea 16             	shr    $0x16,%edx
  800e62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e69:	f6 c2 01             	test   $0x1,%dl
  800e6c:	74 11                	je     800e7f <fd_alloc+0x30>
  800e6e:	89 c2                	mov    %eax,%edx
  800e70:	c1 ea 0c             	shr    $0xc,%edx
  800e73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e7a:	f6 c2 01             	test   $0x1,%dl
  800e7d:	75 09                	jne    800e88 <fd_alloc+0x39>
			*fd_store = fd;
  800e7f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  800e81:	b8 00 00 00 00       	mov    $0x0,%eax
  800e86:	eb 17                	jmp    800e9f <fd_alloc+0x50>
  800e88:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e8d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e92:	75 c7                	jne    800e5b <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e94:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  800e9a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e9f:	5b                   	pop    %ebx
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ea8:	83 f8 1f             	cmp    $0x1f,%eax
  800eab:	77 36                	ja     800ee3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800ead:	05 00 00 0d 00       	add    $0xd0000,%eax
  800eb2:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eb5:	89 c2                	mov    %eax,%edx
  800eb7:	c1 ea 16             	shr    $0x16,%edx
  800eba:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec1:	f6 c2 01             	test   $0x1,%dl
  800ec4:	74 24                	je     800eea <fd_lookup+0x48>
  800ec6:	89 c2                	mov    %eax,%edx
  800ec8:	c1 ea 0c             	shr    $0xc,%edx
  800ecb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed2:	f6 c2 01             	test   $0x1,%dl
  800ed5:	74 1a                	je     800ef1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800ed7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eda:	89 02                	mov    %eax,(%edx)
	return 0;
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	eb 13                	jmp    800ef6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ee8:	eb 0c                	jmp    800ef6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eef:	eb 05                	jmp    800ef6 <fd_lookup+0x54>
  800ef1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	53                   	push   %ebx
  800efc:	83 ec 14             	sub    $0x14,%esp
  800eff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  800f05:	ba 00 00 00 00       	mov    $0x0,%edx
  800f0a:	eb 0e                	jmp    800f1a <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  800f0c:	39 08                	cmp    %ecx,(%eax)
  800f0e:	75 09                	jne    800f19 <dev_lookup+0x21>
			*dev = devtab[i];
  800f10:	89 03                	mov    %eax,(%ebx)
			return 0;
  800f12:	b8 00 00 00 00       	mov    $0x0,%eax
  800f17:	eb 33                	jmp    800f4c <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f19:	42                   	inc    %edx
  800f1a:	8b 04 95 48 29 80 00 	mov    0x802948(,%edx,4),%eax
  800f21:	85 c0                	test   %eax,%eax
  800f23:	75 e7                	jne    800f0c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f25:	a1 04 40 80 00       	mov    0x804004,%eax
  800f2a:	8b 40 48             	mov    0x48(%eax),%eax
  800f2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f35:	c7 04 24 cc 28 80 00 	movl   $0x8028cc,(%esp)
  800f3c:	e8 bb f2 ff ff       	call   8001fc <cprintf>
	*dev = 0;
  800f41:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  800f47:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4c:	83 c4 14             	add    $0x14,%esp
  800f4f:	5b                   	pop    %ebx
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	56                   	push   %esi
  800f56:	53                   	push   %ebx
  800f57:	83 ec 30             	sub    $0x30,%esp
  800f5a:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5d:	8a 45 0c             	mov    0xc(%ebp),%al
  800f60:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f63:	89 34 24             	mov    %esi,(%esp)
  800f66:	e8 b9 fe ff ff       	call   800e24 <fd2num>
  800f6b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800f6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f72:	89 04 24             	mov    %eax,(%esp)
  800f75:	e8 28 ff ff ff       	call   800ea2 <fd_lookup>
  800f7a:	89 c3                	mov    %eax,%ebx
  800f7c:	85 c0                	test   %eax,%eax
  800f7e:	78 05                	js     800f85 <fd_close+0x33>
	    || fd != fd2)
  800f80:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f83:	74 0d                	je     800f92 <fd_close+0x40>
		return (must_exist ? r : 0);
  800f85:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  800f89:	75 46                	jne    800fd1 <fd_close+0x7f>
  800f8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f90:	eb 3f                	jmp    800fd1 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f92:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f99:	8b 06                	mov    (%esi),%eax
  800f9b:	89 04 24             	mov    %eax,(%esp)
  800f9e:	e8 55 ff ff ff       	call   800ef8 <dev_lookup>
  800fa3:	89 c3                	mov    %eax,%ebx
  800fa5:	85 c0                	test   %eax,%eax
  800fa7:	78 18                	js     800fc1 <fd_close+0x6f>
		if (dev->dev_close)
  800fa9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fac:	8b 40 10             	mov    0x10(%eax),%eax
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	74 09                	je     800fbc <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800fb3:	89 34 24             	mov    %esi,(%esp)
  800fb6:	ff d0                	call   *%eax
  800fb8:	89 c3                	mov    %eax,%ebx
  800fba:	eb 05                	jmp    800fc1 <fd_close+0x6f>
		else
			r = 0;
  800fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fc1:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fcc:	e8 8f fc ff ff       	call   800c60 <sys_page_unmap>
	return r;
}
  800fd1:	89 d8                	mov    %ebx,%eax
  800fd3:	83 c4 30             	add    $0x30,%esp
  800fd6:	5b                   	pop    %ebx
  800fd7:	5e                   	pop    %esi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    

00800fda <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fe0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fe7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fea:	89 04 24             	mov    %eax,(%esp)
  800fed:	e8 b0 fe ff ff       	call   800ea2 <fd_lookup>
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 13                	js     801009 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  800ff6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800ffd:	00 
  800ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801001:	89 04 24             	mov    %eax,(%esp)
  801004:	e8 49 ff ff ff       	call   800f52 <fd_close>
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <close_all>:

void
close_all(void)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	53                   	push   %ebx
  80100f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801012:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801017:	89 1c 24             	mov    %ebx,(%esp)
  80101a:	e8 bb ff ff ff       	call   800fda <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80101f:	43                   	inc    %ebx
  801020:	83 fb 20             	cmp    $0x20,%ebx
  801023:	75 f2                	jne    801017 <close_all+0xc>
		close(i);
}
  801025:	83 c4 14             	add    $0x14,%esp
  801028:	5b                   	pop    %ebx
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    

0080102b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	57                   	push   %edi
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
  801031:	83 ec 4c             	sub    $0x4c,%esp
  801034:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801037:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80103a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80103e:	8b 45 08             	mov    0x8(%ebp),%eax
  801041:	89 04 24             	mov    %eax,(%esp)
  801044:	e8 59 fe ff ff       	call   800ea2 <fd_lookup>
  801049:	89 c3                	mov    %eax,%ebx
  80104b:	85 c0                	test   %eax,%eax
  80104d:	0f 88 e1 00 00 00    	js     801134 <dup+0x109>
		return r;
	close(newfdnum);
  801053:	89 3c 24             	mov    %edi,(%esp)
  801056:	e8 7f ff ff ff       	call   800fda <close>

	newfd = INDEX2FD(newfdnum);
  80105b:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801061:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801064:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801067:	89 04 24             	mov    %eax,(%esp)
  80106a:	e8 c5 fd ff ff       	call   800e34 <fd2data>
  80106f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801071:	89 34 24             	mov    %esi,(%esp)
  801074:	e8 bb fd ff ff       	call   800e34 <fd2data>
  801079:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80107c:	89 d8                	mov    %ebx,%eax
  80107e:	c1 e8 16             	shr    $0x16,%eax
  801081:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801088:	a8 01                	test   $0x1,%al
  80108a:	74 46                	je     8010d2 <dup+0xa7>
  80108c:	89 d8                	mov    %ebx,%eax
  80108e:	c1 e8 0c             	shr    $0xc,%eax
  801091:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801098:	f6 c2 01             	test   $0x1,%dl
  80109b:	74 35                	je     8010d2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80109d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8010b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010bb:	00 
  8010bc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8010c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c7:	e8 41 fb ff ff       	call   800c0d <sys_page_map>
  8010cc:	89 c3                	mov    %eax,%ebx
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	78 3b                	js     80110d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010d2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d5:	89 c2                	mov    %eax,%edx
  8010d7:	c1 ea 0c             	shr    $0xc,%edx
  8010da:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e1:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8010e7:	89 54 24 10          	mov    %edx,0x10(%esp)
  8010eb:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8010ef:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010f6:	00 
  8010f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801102:	e8 06 fb ff ff       	call   800c0d <sys_page_map>
  801107:	89 c3                	mov    %eax,%ebx
  801109:	85 c0                	test   %eax,%eax
  80110b:	79 25                	jns    801132 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80110d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801111:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801118:	e8 43 fb ff ff       	call   800c60 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80111d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801120:	89 44 24 04          	mov    %eax,0x4(%esp)
  801124:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80112b:	e8 30 fb ff ff       	call   800c60 <sys_page_unmap>
	return r;
  801130:	eb 02                	jmp    801134 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801132:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801134:	89 d8                	mov    %ebx,%eax
  801136:	83 c4 4c             	add    $0x4c,%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	53                   	push   %ebx
  801142:	83 ec 24             	sub    $0x24,%esp
  801145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801148:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114f:	89 1c 24             	mov    %ebx,(%esp)
  801152:	e8 4b fd ff ff       	call   800ea2 <fd_lookup>
  801157:	85 c0                	test   %eax,%eax
  801159:	78 6d                	js     8011c8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80115e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	8b 00                	mov    (%eax),%eax
  801167:	89 04 24             	mov    %eax,(%esp)
  80116a:	e8 89 fd ff ff       	call   800ef8 <dev_lookup>
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 55                	js     8011c8 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801173:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801176:	8b 50 08             	mov    0x8(%eax),%edx
  801179:	83 e2 03             	and    $0x3,%edx
  80117c:	83 fa 01             	cmp    $0x1,%edx
  80117f:	75 23                	jne    8011a4 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801181:	a1 04 40 80 00       	mov    0x804004,%eax
  801186:	8b 40 48             	mov    0x48(%eax),%eax
  801189:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80118d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801191:	c7 04 24 0d 29 80 00 	movl   $0x80290d,(%esp)
  801198:	e8 5f f0 ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  80119d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011a2:	eb 24                	jmp    8011c8 <read+0x8a>
	}
	if (!dev->dev_read)
  8011a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a7:	8b 52 08             	mov    0x8(%edx),%edx
  8011aa:	85 d2                	test   %edx,%edx
  8011ac:	74 15                	je     8011c3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8011b1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8011bc:	89 04 24             	mov    %eax,(%esp)
  8011bf:	ff d2                	call   *%edx
  8011c1:	eb 05                	jmp    8011c8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8011c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8011c8:	83 c4 24             	add    $0x24,%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	83 ec 1c             	sub    $0x1c,%esp
  8011d7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011da:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011dd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011e2:	eb 23                	jmp    801207 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011e4:	89 f0                	mov    %esi,%eax
  8011e6:	29 d8                	sub    %ebx,%eax
  8011e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ef:	01 d8                	add    %ebx,%eax
  8011f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f5:	89 3c 24             	mov    %edi,(%esp)
  8011f8:	e8 41 ff ff ff       	call   80113e <read>
		if (m < 0)
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	78 10                	js     801211 <readn+0x43>
			return m;
		if (m == 0)
  801201:	85 c0                	test   %eax,%eax
  801203:	74 0a                	je     80120f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801205:	01 c3                	add    %eax,%ebx
  801207:	39 f3                	cmp    %esi,%ebx
  801209:	72 d9                	jb     8011e4 <readn+0x16>
  80120b:	89 d8                	mov    %ebx,%eax
  80120d:	eb 02                	jmp    801211 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80120f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801211:	83 c4 1c             	add    $0x1c,%esp
  801214:	5b                   	pop    %ebx
  801215:	5e                   	pop    %esi
  801216:	5f                   	pop    %edi
  801217:	5d                   	pop    %ebp
  801218:	c3                   	ret    

00801219 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801219:	55                   	push   %ebp
  80121a:	89 e5                	mov    %esp,%ebp
  80121c:	53                   	push   %ebx
  80121d:	83 ec 24             	sub    $0x24,%esp
  801220:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801223:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801226:	89 44 24 04          	mov    %eax,0x4(%esp)
  80122a:	89 1c 24             	mov    %ebx,(%esp)
  80122d:	e8 70 fc ff ff       	call   800ea2 <fd_lookup>
  801232:	85 c0                	test   %eax,%eax
  801234:	78 68                	js     80129e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80123d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801240:	8b 00                	mov    (%eax),%eax
  801242:	89 04 24             	mov    %eax,(%esp)
  801245:	e8 ae fc ff ff       	call   800ef8 <dev_lookup>
  80124a:	85 c0                	test   %eax,%eax
  80124c:	78 50                	js     80129e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80124e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801251:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801255:	75 23                	jne    80127a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801257:	a1 04 40 80 00       	mov    0x804004,%eax
  80125c:	8b 40 48             	mov    0x48(%eax),%eax
  80125f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801263:	89 44 24 04          	mov    %eax,0x4(%esp)
  801267:	c7 04 24 29 29 80 00 	movl   $0x802929,(%esp)
  80126e:	e8 89 ef ff ff       	call   8001fc <cprintf>
		return -E_INVAL;
  801273:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801278:	eb 24                	jmp    80129e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80127a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127d:	8b 52 0c             	mov    0xc(%edx),%edx
  801280:	85 d2                	test   %edx,%edx
  801282:	74 15                	je     801299 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801284:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801287:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801292:	89 04 24             	mov    %eax,(%esp)
  801295:	ff d2                	call   *%edx
  801297:	eb 05                	jmp    80129e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801299:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80129e:	83 c4 24             	add    $0x24,%esp
  8012a1:	5b                   	pop    %ebx
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    

008012a4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012a4:	55                   	push   %ebp
  8012a5:	89 e5                	mov    %esp,%ebp
  8012a7:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012aa:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b4:	89 04 24             	mov    %eax,(%esp)
  8012b7:	e8 e6 fb ff ff       	call   800ea2 <fd_lookup>
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	78 0e                	js     8012ce <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8012c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8012c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ce:	c9                   	leave  
  8012cf:	c3                   	ret    

008012d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 24             	sub    $0x24,%esp
  8012d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e1:	89 1c 24             	mov    %ebx,(%esp)
  8012e4:	e8 b9 fb ff ff       	call   800ea2 <fd_lookup>
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 61                	js     80134e <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f7:	8b 00                	mov    (%eax),%eax
  8012f9:	89 04 24             	mov    %eax,(%esp)
  8012fc:	e8 f7 fb ff ff       	call   800ef8 <dev_lookup>
  801301:	85 c0                	test   %eax,%eax
  801303:	78 49                	js     80134e <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80130c:	75 23                	jne    801331 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80130e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801313:	8b 40 48             	mov    0x48(%eax),%eax
  801316:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80131a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131e:	c7 04 24 ec 28 80 00 	movl   $0x8028ec,(%esp)
  801325:	e8 d2 ee ff ff       	call   8001fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80132a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80132f:	eb 1d                	jmp    80134e <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801331:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801334:	8b 52 18             	mov    0x18(%edx),%edx
  801337:	85 d2                	test   %edx,%edx
  801339:	74 0e                	je     801349 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80133b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80133e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801342:	89 04 24             	mov    %eax,(%esp)
  801345:	ff d2                	call   *%edx
  801347:	eb 05                	jmp    80134e <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801349:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  80134e:	83 c4 24             	add    $0x24,%esp
  801351:	5b                   	pop    %ebx
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    

00801354 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
  801357:	53                   	push   %ebx
  801358:	83 ec 24             	sub    $0x24,%esp
  80135b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801361:	89 44 24 04          	mov    %eax,0x4(%esp)
  801365:	8b 45 08             	mov    0x8(%ebp),%eax
  801368:	89 04 24             	mov    %eax,(%esp)
  80136b:	e8 32 fb ff ff       	call   800ea2 <fd_lookup>
  801370:	85 c0                	test   %eax,%eax
  801372:	78 52                	js     8013c6 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801374:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80137b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137e:	8b 00                	mov    (%eax),%eax
  801380:	89 04 24             	mov    %eax,(%esp)
  801383:	e8 70 fb ff ff       	call   800ef8 <dev_lookup>
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 3a                	js     8013c6 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  80138c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801393:	74 2c                	je     8013c1 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801395:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801398:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80139f:	00 00 00 
	stat->st_isdir = 0;
  8013a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013a9:	00 00 00 
	stat->st_dev = dev;
  8013ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013b6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013b9:	89 14 24             	mov    %edx,(%esp)
  8013bc:	ff 50 14             	call   *0x14(%eax)
  8013bf:	eb 05                	jmp    8013c6 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8013c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8013c6:	83 c4 24             	add    $0x24,%esp
  8013c9:	5b                   	pop    %ebx
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	56                   	push   %esi
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013d4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8013db:	00 
  8013dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013df:	89 04 24             	mov    %eax,(%esp)
  8013e2:	e8 fe 01 00 00       	call   8015e5 <open>
  8013e7:	89 c3                	mov    %eax,%ebx
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	78 1b                	js     801408 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8013ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f4:	89 1c 24             	mov    %ebx,(%esp)
  8013f7:	e8 58 ff ff ff       	call   801354 <fstat>
  8013fc:	89 c6                	mov    %eax,%esi
	close(fd);
  8013fe:	89 1c 24             	mov    %ebx,(%esp)
  801401:	e8 d4 fb ff ff       	call   800fda <close>
	return r;
  801406:	89 f3                	mov    %esi,%ebx
}
  801408:	89 d8                	mov    %ebx,%eax
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	5b                   	pop    %ebx
  80140e:	5e                   	pop    %esi
  80140f:	5d                   	pop    %ebp
  801410:	c3                   	ret    
  801411:	00 00                	add    %al,(%eax)
	...

00801414 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	56                   	push   %esi
  801418:	53                   	push   %ebx
  801419:	83 ec 10             	sub    $0x10,%esp
  80141c:	89 c3                	mov    %eax,%ebx
  80141e:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801420:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801427:	75 11                	jne    80143a <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801429:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801430:	e8 04 0e 00 00       	call   802239 <ipc_find_env>
  801435:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80143a:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801441:	00 
  801442:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801449:	00 
  80144a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80144e:	a1 00 40 80 00       	mov    0x804000,%eax
  801453:	89 04 24             	mov    %eax,(%esp)
  801456:	e8 74 0d 00 00       	call   8021cf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80145b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801462:	00 
  801463:	89 74 24 04          	mov    %esi,0x4(%esp)
  801467:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80146e:	e8 f5 0c 00 00       	call   802168 <ipc_recv>
}
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    

0080147a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80147a:	55                   	push   %ebp
  80147b:	89 e5                	mov    %esp,%ebp
  80147d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801480:	8b 45 08             	mov    0x8(%ebp),%eax
  801483:	8b 40 0c             	mov    0xc(%eax),%eax
  801486:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80148b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801493:	ba 00 00 00 00       	mov    $0x0,%edx
  801498:	b8 02 00 00 00       	mov    $0x2,%eax
  80149d:	e8 72 ff ff ff       	call   801414 <fsipc>
}
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ad:	8b 40 0c             	mov    0xc(%eax),%eax
  8014b0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ba:	b8 06 00 00 00       	mov    $0x6,%eax
  8014bf:	e8 50 ff ff ff       	call   801414 <fsipc>
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	53                   	push   %ebx
  8014ca:	83 ec 14             	sub    $0x14,%esp
  8014cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8014db:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e0:	b8 05 00 00 00       	mov    $0x5,%eax
  8014e5:	e8 2a ff ff ff       	call   801414 <fsipc>
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 2b                	js     801519 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8014ee:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8014f5:	00 
  8014f6:	89 1c 24             	mov    %ebx,(%esp)
  8014f9:	e8 c9 f2 ff ff       	call   8007c7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014fe:	a1 80 50 80 00       	mov    0x805080,%eax
  801503:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801509:	a1 84 50 80 00       	mov    0x805084,%eax
  80150e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801514:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801519:	83 c4 14             	add    $0x14,%esp
  80151c:	5b                   	pop    %ebx
  80151d:	5d                   	pop    %ebp
  80151e:	c3                   	ret    

0080151f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80151f:	55                   	push   %ebp
  801520:	89 e5                	mov    %esp,%ebp
  801522:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801525:	c7 44 24 08 58 29 80 	movl   $0x802958,0x8(%esp)
  80152c:	00 
  80152d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801534:	00 
  801535:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  80153c:	e8 c3 eb ff ff       	call   800104 <_panic>

00801541 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801541:	55                   	push   %ebp
  801542:	89 e5                	mov    %esp,%ebp
  801544:	56                   	push   %esi
  801545:	53                   	push   %ebx
  801546:	83 ec 10             	sub    $0x10,%esp
  801549:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80154c:	8b 45 08             	mov    0x8(%ebp),%eax
  80154f:	8b 40 0c             	mov    0xc(%eax),%eax
  801552:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801557:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80155d:	ba 00 00 00 00       	mov    $0x0,%edx
  801562:	b8 03 00 00 00       	mov    $0x3,%eax
  801567:	e8 a8 fe ff ff       	call   801414 <fsipc>
  80156c:	89 c3                	mov    %eax,%ebx
  80156e:	85 c0                	test   %eax,%eax
  801570:	78 6a                	js     8015dc <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801572:	39 c6                	cmp    %eax,%esi
  801574:	73 24                	jae    80159a <devfile_read+0x59>
  801576:	c7 44 24 0c 81 29 80 	movl   $0x802981,0xc(%esp)
  80157d:	00 
  80157e:	c7 44 24 08 88 29 80 	movl   $0x802988,0x8(%esp)
  801585:	00 
  801586:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  80158d:	00 
  80158e:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  801595:	e8 6a eb ff ff       	call   800104 <_panic>
	assert(r <= PGSIZE);
  80159a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80159f:	7e 24                	jle    8015c5 <devfile_read+0x84>
  8015a1:	c7 44 24 0c 9d 29 80 	movl   $0x80299d,0xc(%esp)
  8015a8:	00 
  8015a9:	c7 44 24 08 88 29 80 	movl   $0x802988,0x8(%esp)
  8015b0:	00 
  8015b1:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  8015b8:	00 
  8015b9:	c7 04 24 76 29 80 00 	movl   $0x802976,(%esp)
  8015c0:	e8 3f eb ff ff       	call   800104 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015c9:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8015d0:	00 
  8015d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d4:	89 04 24             	mov    %eax,(%esp)
  8015d7:	e8 64 f3 ff ff       	call   800940 <memmove>
	return r;
}
  8015dc:	89 d8                	mov    %ebx,%eax
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 20             	sub    $0x20,%esp
  8015ed:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015f0:	89 34 24             	mov    %esi,(%esp)
  8015f3:	e8 9c f1 ff ff       	call   800794 <strlen>
  8015f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015fd:	7f 60                	jg     80165f <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801602:	89 04 24             	mov    %eax,(%esp)
  801605:	e8 45 f8 ff ff       	call   800e4f <fd_alloc>
  80160a:	89 c3                	mov    %eax,%ebx
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 54                	js     801664 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801610:	89 74 24 04          	mov    %esi,0x4(%esp)
  801614:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80161b:	e8 a7 f1 ff ff       	call   8007c7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801620:	8b 45 0c             	mov    0xc(%ebp),%eax
  801623:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801628:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80162b:	b8 01 00 00 00       	mov    $0x1,%eax
  801630:	e8 df fd ff ff       	call   801414 <fsipc>
  801635:	89 c3                	mov    %eax,%ebx
  801637:	85 c0                	test   %eax,%eax
  801639:	79 15                	jns    801650 <open+0x6b>
		fd_close(fd, 0);
  80163b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801642:	00 
  801643:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801646:	89 04 24             	mov    %eax,(%esp)
  801649:	e8 04 f9 ff ff       	call   800f52 <fd_close>
		return r;
  80164e:	eb 14                	jmp    801664 <open+0x7f>
	}

	return fd2num(fd);
  801650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801653:	89 04 24             	mov    %eax,(%esp)
  801656:	e8 c9 f7 ff ff       	call   800e24 <fd2num>
  80165b:	89 c3                	mov    %eax,%ebx
  80165d:	eb 05                	jmp    801664 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80165f:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801664:	89 d8                	mov    %ebx,%eax
  801666:	83 c4 20             	add    $0x20,%esp
  801669:	5b                   	pop    %ebx
  80166a:	5e                   	pop    %esi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801673:	ba 00 00 00 00       	mov    $0x0,%edx
  801678:	b8 08 00 00 00       	mov    $0x8,%eax
  80167d:	e8 92 fd ff ff       	call   801414 <fsipc>
}
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	57                   	push   %edi
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
  80168a:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801690:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801697:	00 
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	89 04 24             	mov    %eax,(%esp)
  80169e:	e8 42 ff ff ff       	call   8015e5 <open>
  8016a3:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	0f 88 05 05 00 00    	js     801bb6 <spawn+0x532>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8016b1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
  8016b8:	00 
  8016b9:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8016bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8016c9:	89 04 24             	mov    %eax,(%esp)
  8016cc:	e8 fd fa ff ff       	call   8011ce <readn>
  8016d1:	3d 00 02 00 00       	cmp    $0x200,%eax
  8016d6:	75 0c                	jne    8016e4 <spawn+0x60>
	    || elf->e_magic != ELF_MAGIC) {
  8016d8:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8016df:	45 4c 46 
  8016e2:	74 3b                	je     80171f <spawn+0x9b>
		close(fd);
  8016e4:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8016ea:	89 04 24             	mov    %eax,(%esp)
  8016ed:	e8 e8 f8 ff ff       	call   800fda <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8016f2:	c7 44 24 08 7f 45 4c 	movl   $0x464c457f,0x8(%esp)
  8016f9:	46 
  8016fa:	8b 85 e8 fd ff ff    	mov    -0x218(%ebp),%eax
  801700:	89 44 24 04          	mov    %eax,0x4(%esp)
  801704:	c7 04 24 a9 29 80 00 	movl   $0x8029a9,(%esp)
  80170b:	e8 ec ea ff ff       	call   8001fc <cprintf>
		return -E_NOT_EXEC;
  801710:	c7 85 84 fd ff ff f2 	movl   $0xfffffff2,-0x27c(%ebp)
  801717:	ff ff ff 
  80171a:	e9 a3 04 00 00       	jmp    801bc2 <spawn+0x53e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80171f:	ba 07 00 00 00       	mov    $0x7,%edx
  801724:	89 d0                	mov    %edx,%eax
  801726:	cd 30                	int    $0x30
  801728:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80172e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801734:	85 c0                	test   %eax,%eax
  801736:	0f 88 86 04 00 00    	js     801bc2 <spawn+0x53e>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80173c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801741:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801748:	c1 e0 07             	shl    $0x7,%eax
  80174b:	29 d0                	sub    %edx,%eax
  80174d:	8d b0 00 00 c0 ee    	lea    -0x11400000(%eax),%esi
  801753:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801759:	b9 11 00 00 00       	mov    $0x11,%ecx
  80175e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801760:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801766:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80176c:	be 00 00 00 00       	mov    $0x0,%esi
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801771:	bb 00 00 00 00       	mov    $0x0,%ebx
  801776:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801779:	eb 0d                	jmp    801788 <spawn+0x104>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 11 f0 ff ff       	call   800794 <strlen>
  801783:	8d 5c 18 01          	lea    0x1(%eax,%ebx,1),%ebx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801787:	46                   	inc    %esi
  801788:	89 f2                	mov    %esi,%edx
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  80178a:	8d 0c b5 00 00 00 00 	lea    0x0(,%esi,4),%ecx
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801791:	8b 04 b7             	mov    (%edi,%esi,4),%eax
  801794:	85 c0                	test   %eax,%eax
  801796:	75 e3                	jne    80177b <spawn+0xf7>
  801798:	89 b5 80 fd ff ff    	mov    %esi,-0x280(%ebp)
  80179e:	89 8d 7c fd ff ff    	mov    %ecx,-0x284(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8017a4:	bf 00 10 40 00       	mov    $0x401000,%edi
  8017a9:	29 df                	sub    %ebx,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8017ab:	89 f8                	mov    %edi,%eax
  8017ad:	83 e0 fc             	and    $0xfffffffc,%eax
  8017b0:	f7 d2                	not    %edx
  8017b2:	8d 14 90             	lea    (%eax,%edx,4),%edx
  8017b5:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8017bb:	89 d0                	mov    %edx,%eax
  8017bd:	83 e8 08             	sub    $0x8,%eax
  8017c0:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8017c5:	0f 86 08 04 00 00    	jbe    801bd3 <spawn+0x54f>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8017cb:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8017d2:	00 
  8017d3:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8017da:	00 
  8017db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017e2:	e8 d2 f3 ff ff       	call   800bb9 <sys_page_alloc>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	0f 88 e9 03 00 00    	js     801bd8 <spawn+0x554>
  8017ef:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f4:	89 b5 90 fd ff ff    	mov    %esi,-0x270(%ebp)
  8017fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8017fd:	eb 2e                	jmp    80182d <spawn+0x1a9>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8017ff:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801805:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80180b:	89 04 9a             	mov    %eax,(%edx,%ebx,4)
		strcpy(string_store, argv[i]);
  80180e:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801811:	89 44 24 04          	mov    %eax,0x4(%esp)
  801815:	89 3c 24             	mov    %edi,(%esp)
  801818:	e8 aa ef ff ff       	call   8007c7 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80181d:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  801820:	89 04 24             	mov    %eax,(%esp)
  801823:	e8 6c ef ff ff       	call   800794 <strlen>
  801828:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80182c:	43                   	inc    %ebx
  80182d:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801833:	7c ca                	jl     8017ff <spawn+0x17b>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801835:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  80183b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801841:	c7 04 02 00 00 00 00 	movl   $0x0,(%edx,%eax,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801848:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  80184e:	74 24                	je     801874 <spawn+0x1f0>
  801850:	c7 44 24 0c 20 2a 80 	movl   $0x802a20,0xc(%esp)
  801857:	00 
  801858:	c7 44 24 08 88 29 80 	movl   $0x802988,0x8(%esp)
  80185f:	00 
  801860:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  801867:	00 
  801868:	c7 04 24 c3 29 80 00 	movl   $0x8029c3,(%esp)
  80186f:	e8 90 e8 ff ff       	call   800104 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801874:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80187a:	2d 00 30 80 11       	sub    $0x11803000,%eax
  80187f:	8b 95 94 fd ff ff    	mov    -0x26c(%ebp),%edx
  801885:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801888:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80188e:	89 42 f8             	mov    %eax,-0x8(%edx)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801891:	89 d0                	mov    %edx,%eax
  801893:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801898:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  80189e:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  8018a5:	00 
  8018a6:	c7 44 24 0c 00 d0 bf 	movl   $0xeebfd000,0xc(%esp)
  8018ad:	ee 
  8018ae:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8018b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018b8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018bf:	00 
  8018c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018c7:	e8 41 f3 ff ff       	call   800c0d <sys_page_map>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	85 c0                	test   %eax,%eax
  8018d0:	78 1a                	js     8018ec <spawn+0x268>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018d2:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018d9:	00 
  8018da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018e1:	e8 7a f3 ff ff       	call   800c60 <sys_page_unmap>
  8018e6:	89 c3                	mov    %eax,%ebx
  8018e8:	85 c0                	test   %eax,%eax
  8018ea:	79 1f                	jns    80190b <spawn+0x287>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  8018ec:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8018f3:	00 
  8018f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018fb:	e8 60 f3 ff ff       	call   800c60 <sys_page_unmap>
	return r;
  801900:	89 9d 84 fd ff ff    	mov    %ebx,-0x27c(%ebp)
  801906:	e9 b7 02 00 00       	jmp    801bc2 <spawn+0x53e>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80190b:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  801911:	03 95 04 fe ff ff    	add    -0x1fc(%ebp),%edx
  801917:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80191d:	c7 85 7c fd ff ff 00 	movl   $0x0,-0x284(%ebp)
  801924:	00 00 00 
  801927:	e9 bb 01 00 00       	jmp    801ae7 <spawn+0x463>
		if (ph->p_type != ELF_PROG_LOAD)
  80192c:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801932:	83 38 01             	cmpl   $0x1,(%eax)
  801935:	0f 85 9f 01 00 00    	jne    801ada <spawn+0x456>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80193b:	89 c2                	mov    %eax,%edx
  80193d:	8b 40 18             	mov    0x18(%eax),%eax
  801940:	83 e0 02             	and    $0x2,%eax
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
		if (ph->p_type != ELF_PROG_LOAD)
			continue;
		perm = PTE_P | PTE_U;
  801943:	83 f8 01             	cmp    $0x1,%eax
  801946:	19 c0                	sbb    %eax,%eax
  801948:	83 e0 fe             	and    $0xfffffffe,%eax
  80194b:	83 c0 07             	add    $0x7,%eax
  80194e:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801954:	8b 52 04             	mov    0x4(%edx),%edx
  801957:	89 95 78 fd ff ff    	mov    %edx,-0x288(%ebp)
  80195d:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801963:	8b 40 10             	mov    0x10(%eax),%eax
  801966:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80196c:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801972:	8b 52 14             	mov    0x14(%edx),%edx
  801975:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
  80197b:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801981:	8b 78 08             	mov    0x8(%eax),%edi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801984:	89 f8                	mov    %edi,%eax
  801986:	25 ff 0f 00 00       	and    $0xfff,%eax
  80198b:	74 16                	je     8019a3 <spawn+0x31f>
		va -= i;
  80198d:	29 c7                	sub    %eax,%edi
		memsz += i;
  80198f:	01 c2                	add    %eax,%edx
  801991:	89 95 8c fd ff ff    	mov    %edx,-0x274(%ebp)
		filesz += i;
  801997:	01 85 94 fd ff ff    	add    %eax,-0x26c(%ebp)
		fileoffset -= i;
  80199d:	29 85 78 fd ff ff    	sub    %eax,-0x288(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019a8:	e9 1f 01 00 00       	jmp    801acc <spawn+0x448>
		if (i >= filesz) {
  8019ad:	39 9d 94 fd ff ff    	cmp    %ebx,-0x26c(%ebp)
  8019b3:	77 2b                	ja     8019e0 <spawn+0x35c>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8019b5:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  8019bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8019bf:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019c3:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  8019c9:	89 04 24             	mov    %eax,(%esp)
  8019cc:	e8 e8 f1 ff ff       	call   800bb9 <sys_page_alloc>
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	0f 89 e7 00 00 00    	jns    801ac0 <spawn+0x43c>
  8019d9:	89 c6                	mov    %eax,%esi
  8019db:	e9 b2 01 00 00       	jmp    801b92 <spawn+0x50e>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019e0:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8019e7:	00 
  8019e8:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8019ef:	00 
  8019f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8019f7:	e8 bd f1 ff ff       	call   800bb9 <sys_page_alloc>
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	0f 88 84 01 00 00    	js     801b88 <spawn+0x504>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801a04:	8b 85 78 fd ff ff    	mov    -0x288(%ebp),%eax
  801a0a:	01 f0                	add    %esi,%eax
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801a0c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a10:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a16:	89 04 24             	mov    %eax,(%esp)
  801a19:	e8 86 f8 ff ff       	call   8012a4 <seek>
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	0f 88 66 01 00 00    	js     801b8c <spawn+0x508>
// prog: the pathname of the program to run.
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
  801a26:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a2c:	29 f0                	sub    %esi,%eax
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801a2e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a33:	76 05                	jbe    801a3a <spawn+0x3b6>
  801a35:	b8 00 10 00 00       	mov    $0x1000,%eax
  801a3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a3e:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a45:	00 
  801a46:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a4c:	89 04 24             	mov    %eax,(%esp)
  801a4f:	e8 7a f7 ff ff       	call   8011ce <readn>
  801a54:	85 c0                	test   %eax,%eax
  801a56:	0f 88 34 01 00 00    	js     801b90 <spawn+0x50c>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801a5c:	8b 95 90 fd ff ff    	mov    -0x270(%ebp),%edx
  801a62:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a66:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801a6a:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801a70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a74:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801a7b:	00 
  801a7c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a83:	e8 85 f1 ff ff       	call   800c0d <sys_page_map>
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	79 20                	jns    801aac <spawn+0x428>
				panic("spawn: sys_page_map data: %e", r);
  801a8c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a90:	c7 44 24 08 cf 29 80 	movl   $0x8029cf,0x8(%esp)
  801a97:	00 
  801a98:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
  801a9f:	00 
  801aa0:	c7 04 24 c3 29 80 00 	movl   $0x8029c3,(%esp)
  801aa7:	e8 58 e6 ff ff       	call   800104 <_panic>
			sys_page_unmap(0, UTEMP);
  801aac:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  801ab3:	00 
  801ab4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abb:	e8 a0 f1 ff ff       	call   800c60 <sys_page_unmap>
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801ac0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ac6:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801acc:	89 de                	mov    %ebx,%esi
  801ace:	39 9d 8c fd ff ff    	cmp    %ebx,-0x274(%ebp)
  801ad4:	0f 87 d3 fe ff ff    	ja     8019ad <spawn+0x329>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ada:	ff 85 7c fd ff ff    	incl   -0x284(%ebp)
  801ae0:	83 85 80 fd ff ff 20 	addl   $0x20,-0x280(%ebp)
  801ae7:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801aee:	39 85 7c fd ff ff    	cmp    %eax,-0x284(%ebp)
  801af4:	0f 8c 32 fe ff ff    	jl     80192c <spawn+0x2a8>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801afa:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b00:	89 04 24             	mov    %eax,(%esp)
  801b03:	e8 d2 f4 ff ff       	call   800fda <close>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801b08:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b0f:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b12:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b22:	89 04 24             	mov    %eax,(%esp)
  801b25:	e8 dc f1 ff ff       	call   800d06 <sys_env_set_trapframe>
  801b2a:	85 c0                	test   %eax,%eax
  801b2c:	79 20                	jns    801b4e <spawn+0x4ca>
		panic("sys_env_set_trapframe: %e", r);
  801b2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b32:	c7 44 24 08 ec 29 80 	movl   $0x8029ec,0x8(%esp)
  801b39:	00 
  801b3a:	c7 44 24 04 86 00 00 	movl   $0x86,0x4(%esp)
  801b41:	00 
  801b42:	c7 04 24 c3 29 80 00 	movl   $0x8029c3,(%esp)
  801b49:	e8 b6 e5 ff ff       	call   800104 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801b4e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801b55:	00 
  801b56:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	e8 4f f1 ff ff       	call   800cb3 <sys_env_set_status>
  801b64:	85 c0                	test   %eax,%eax
  801b66:	79 5a                	jns    801bc2 <spawn+0x53e>
		panic("sys_env_set_status: %e", r);
  801b68:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b6c:	c7 44 24 08 06 2a 80 	movl   $0x802a06,0x8(%esp)
  801b73:	00 
  801b74:	c7 44 24 04 89 00 00 	movl   $0x89,0x4(%esp)
  801b7b:	00 
  801b7c:	c7 04 24 c3 29 80 00 	movl   $0x8029c3,(%esp)
  801b83:	e8 7c e5 ff ff       	call   800104 <_panic>
  801b88:	89 c6                	mov    %eax,%esi
  801b8a:	eb 06                	jmp    801b92 <spawn+0x50e>
  801b8c:	89 c6                	mov    %eax,%esi
  801b8e:	eb 02                	jmp    801b92 <spawn+0x50e>
  801b90:	89 c6                	mov    %eax,%esi

	return child;

error:
	sys_env_destroy(child);
  801b92:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801b98:	89 04 24             	mov    %eax,(%esp)
  801b9b:	e8 89 ef ff ff       	call   800b29 <sys_env_destroy>
	close(fd);
  801ba0:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801ba6:	89 04 24             	mov    %eax,(%esp)
  801ba9:	e8 2c f4 ff ff       	call   800fda <close>
	return r;
  801bae:	89 b5 84 fd ff ff    	mov    %esi,-0x27c(%ebp)
  801bb4:	eb 0c                	jmp    801bc2 <spawn+0x53e>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801bb6:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801bbc:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801bc2:	8b 85 84 fd ff ff    	mov    -0x27c(%ebp),%eax
  801bc8:	81 c4 ac 02 00 00    	add    $0x2ac,%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5f                   	pop    %edi
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801bd3:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	return child;

error:
	sys_env_destroy(child);
	close(fd);
	return r;
  801bd8:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
  801bde:	eb e2                	jmp    801bc2 <spawn+0x53e>

00801be0 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801be0:	55                   	push   %ebp
  801be1:	89 e5                	mov    %esp,%ebp
  801be3:	57                   	push   %edi
  801be4:	56                   	push   %esi
  801be5:	53                   	push   %ebx
  801be6:	83 ec 1c             	sub    $0x1c,%esp
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
  801be9:	8d 45 10             	lea    0x10(%ebp),%eax
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801bec:	b9 00 00 00 00       	mov    $0x0,%ecx
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bf1:	eb 03                	jmp    801bf6 <spawnl+0x16>
		argc++;
  801bf3:	41                   	inc    %ecx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801bf4:	89 d0                	mov    %edx,%eax
  801bf6:	8d 50 04             	lea    0x4(%eax),%edx
  801bf9:	83 38 00             	cmpl   $0x0,(%eax)
  801bfc:	75 f5                	jne    801bf3 <spawnl+0x13>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801bfe:	8d 04 8d 26 00 00 00 	lea    0x26(,%ecx,4),%eax
  801c05:	83 e0 f0             	and    $0xfffffff0,%eax
  801c08:	29 c4                	sub    %eax,%esp
  801c0a:	8d 7c 24 17          	lea    0x17(%esp),%edi
  801c0e:	83 e7 f0             	and    $0xfffffff0,%edi
  801c11:	89 fe                	mov    %edi,%esi
	argv[0] = arg0;
  801c13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c16:	89 07                	mov    %eax,(%edi)
	argv[argc+1] = NULL;
  801c18:	c7 44 8f 04 00 00 00 	movl   $0x0,0x4(%edi,%ecx,4)
  801c1f:	00 

	va_start(vl, arg0);
  801c20:	8d 55 10             	lea    0x10(%ebp),%edx
	unsigned i;
	for(i=0;i<argc;i++)
  801c23:	b8 00 00 00 00       	mov    $0x0,%eax
  801c28:	eb 09                	jmp    801c33 <spawnl+0x53>
		argv[i+1] = va_arg(vl, const char *);
  801c2a:	40                   	inc    %eax
  801c2b:	8b 1a                	mov    (%edx),%ebx
  801c2d:	89 1c 86             	mov    %ebx,(%esi,%eax,4)
  801c30:	8d 52 04             	lea    0x4(%edx),%edx
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801c33:	39 c8                	cmp    %ecx,%eax
  801c35:	75 f3                	jne    801c2a <spawnl+0x4a>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801c37:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3e:	89 04 24             	mov    %eax,(%esp)
  801c41:	e8 3e fa ff ff       	call   801684 <spawn>
}
  801c46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c49:	5b                   	pop    %ebx
  801c4a:	5e                   	pop    %esi
  801c4b:	5f                   	pop    %edi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    
	...

00801c50 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	83 ec 10             	sub    $0x10,%esp
  801c58:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5e:	89 04 24             	mov    %eax,(%esp)
  801c61:	e8 ce f1 ff ff       	call   800e34 <fd2data>
  801c66:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801c68:	c7 44 24 04 48 2a 80 	movl   $0x802a48,0x4(%esp)
  801c6f:	00 
  801c70:	89 34 24             	mov    %esi,(%esp)
  801c73:	e8 4f eb ff ff       	call   8007c7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c78:	8b 43 04             	mov    0x4(%ebx),%eax
  801c7b:	2b 03                	sub    (%ebx),%eax
  801c7d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801c83:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801c8a:	00 00 00 
	stat->st_dev = &devpipe;
  801c8d:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  801c94:	30 80 00 
	return 0;
}
  801c97:	b8 00 00 00 00       	mov    $0x0,%eax
  801c9c:	83 c4 10             	add    $0x10,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5d                   	pop    %ebp
  801ca2:	c3                   	ret    

00801ca3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	53                   	push   %ebx
  801ca7:	83 ec 14             	sub    $0x14,%esp
  801caa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cb1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb8:	e8 a3 ef ff ff       	call   800c60 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cbd:	89 1c 24             	mov    %ebx,(%esp)
  801cc0:	e8 6f f1 ff ff       	call   800e34 <fd2data>
  801cc5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cd0:	e8 8b ef ff ff       	call   800c60 <sys_page_unmap>
}
  801cd5:	83 c4 14             	add    $0x14,%esp
  801cd8:	5b                   	pop    %ebx
  801cd9:	5d                   	pop    %ebp
  801cda:	c3                   	ret    

00801cdb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	57                   	push   %edi
  801cdf:	56                   	push   %esi
  801ce0:	53                   	push   %ebx
  801ce1:	83 ec 2c             	sub    $0x2c,%esp
  801ce4:	89 c7                	mov    %eax,%edi
  801ce6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ce9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cee:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cf1:	89 3c 24             	mov    %edi,(%esp)
  801cf4:	e8 87 05 00 00       	call   802280 <pageref>
  801cf9:	89 c6                	mov    %eax,%esi
  801cfb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801cfe:	89 04 24             	mov    %eax,(%esp)
  801d01:	e8 7a 05 00 00       	call   802280 <pageref>
  801d06:	39 c6                	cmp    %eax,%esi
  801d08:	0f 94 c0             	sete   %al
  801d0b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d0e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d14:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d17:	39 cb                	cmp    %ecx,%ebx
  801d19:	75 08                	jne    801d23 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d1b:	83 c4 2c             	add    $0x2c,%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5f                   	pop    %edi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d23:	83 f8 01             	cmp    $0x1,%eax
  801d26:	75 c1                	jne    801ce9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d28:	8b 42 58             	mov    0x58(%edx),%eax
  801d2b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d32:	00 
  801d33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d3b:	c7 04 24 4f 2a 80 00 	movl   $0x802a4f,(%esp)
  801d42:	e8 b5 e4 ff ff       	call   8001fc <cprintf>
  801d47:	eb a0                	jmp    801ce9 <_pipeisclosed+0xe>

00801d49 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d49:	55                   	push   %ebp
  801d4a:	89 e5                	mov    %esp,%ebp
  801d4c:	57                   	push   %edi
  801d4d:	56                   	push   %esi
  801d4e:	53                   	push   %ebx
  801d4f:	83 ec 1c             	sub    $0x1c,%esp
  801d52:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d55:	89 34 24             	mov    %esi,(%esp)
  801d58:	e8 d7 f0 ff ff       	call   800e34 <fd2data>
  801d5d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d5f:	bf 00 00 00 00       	mov    $0x0,%edi
  801d64:	eb 3c                	jmp    801da2 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801d66:	89 da                	mov    %ebx,%edx
  801d68:	89 f0                	mov    %esi,%eax
  801d6a:	e8 6c ff ff ff       	call   801cdb <_pipeisclosed>
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	75 38                	jne    801dab <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801d73:	e8 22 ee ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d78:	8b 43 04             	mov    0x4(%ebx),%eax
  801d7b:	8b 13                	mov    (%ebx),%edx
  801d7d:	83 c2 20             	add    $0x20,%edx
  801d80:	39 d0                	cmp    %edx,%eax
  801d82:	73 e2                	jae    801d66 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d87:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801d8a:	89 c2                	mov    %eax,%edx
  801d8c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801d92:	79 05                	jns    801d99 <devpipe_write+0x50>
  801d94:	4a                   	dec    %edx
  801d95:	83 ca e0             	or     $0xffffffe0,%edx
  801d98:	42                   	inc    %edx
  801d99:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d9d:	40                   	inc    %eax
  801d9e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da1:	47                   	inc    %edi
  801da2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801da5:	75 d1                	jne    801d78 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801da7:	89 f8                	mov    %edi,%eax
  801da9:	eb 05                	jmp    801db0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801dab:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801db0:	83 c4 1c             	add    $0x1c,%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5f                   	pop    %edi
  801db6:	5d                   	pop    %ebp
  801db7:	c3                   	ret    

00801db8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	57                   	push   %edi
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
  801dbe:	83 ec 1c             	sub    $0x1c,%esp
  801dc1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801dc4:	89 3c 24             	mov    %edi,(%esp)
  801dc7:	e8 68 f0 ff ff       	call   800e34 <fd2data>
  801dcc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dce:	be 00 00 00 00       	mov    $0x0,%esi
  801dd3:	eb 3a                	jmp    801e0f <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801dd5:	85 f6                	test   %esi,%esi
  801dd7:	74 04                	je     801ddd <devpipe_read+0x25>
				return i;
  801dd9:	89 f0                	mov    %esi,%eax
  801ddb:	eb 40                	jmp    801e1d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ddd:	89 da                	mov    %ebx,%edx
  801ddf:	89 f8                	mov    %edi,%eax
  801de1:	e8 f5 fe ff ff       	call   801cdb <_pipeisclosed>
  801de6:	85 c0                	test   %eax,%eax
  801de8:	75 2e                	jne    801e18 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801dea:	e8 ab ed ff ff       	call   800b9a <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801def:	8b 03                	mov    (%ebx),%eax
  801df1:	3b 43 04             	cmp    0x4(%ebx),%eax
  801df4:	74 df                	je     801dd5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801df6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801dfb:	79 05                	jns    801e02 <devpipe_read+0x4a>
  801dfd:	48                   	dec    %eax
  801dfe:	83 c8 e0             	or     $0xffffffe0,%eax
  801e01:	40                   	inc    %eax
  801e02:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e06:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e09:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e0c:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e0e:	46                   	inc    %esi
  801e0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e12:	75 db                	jne    801def <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e14:	89 f0                	mov    %esi,%eax
  801e16:	eb 05                	jmp    801e1d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e18:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e1d:	83 c4 1c             	add    $0x1c,%esp
  801e20:	5b                   	pop    %ebx
  801e21:	5e                   	pop    %esi
  801e22:	5f                   	pop    %edi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	57                   	push   %edi
  801e29:	56                   	push   %esi
  801e2a:	53                   	push   %ebx
  801e2b:	83 ec 3c             	sub    $0x3c,%esp
  801e2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e31:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e34:	89 04 24             	mov    %eax,(%esp)
  801e37:	e8 13 f0 ff ff       	call   800e4f <fd_alloc>
  801e3c:	89 c3                	mov    %eax,%ebx
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	0f 88 45 01 00 00    	js     801f8b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e46:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e4d:	00 
  801e4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e51:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e55:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e5c:	e8 58 ed ff ff       	call   800bb9 <sys_page_alloc>
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	85 c0                	test   %eax,%eax
  801e65:	0f 88 20 01 00 00    	js     801f8b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e6b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801e6e:	89 04 24             	mov    %eax,(%esp)
  801e71:	e8 d9 ef ff ff       	call   800e4f <fd_alloc>
  801e76:	89 c3                	mov    %eax,%ebx
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	0f 88 f8 00 00 00    	js     801f78 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e80:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e87:	00 
  801e88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e8b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e96:	e8 1e ed ff ff       	call   800bb9 <sys_page_alloc>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	0f 88 d3 00 00 00    	js     801f78 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801ea5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ea8:	89 04 24             	mov    %eax,(%esp)
  801eab:	e8 84 ef ff ff       	call   800e34 <fd2data>
  801eb0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801eb9:	00 
  801eba:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ebe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ec5:	e8 ef ec ff ff       	call   800bb9 <sys_page_alloc>
  801eca:	89 c3                	mov    %eax,%ebx
  801ecc:	85 c0                	test   %eax,%eax
  801ece:	0f 88 91 00 00 00    	js     801f65 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ed7:	89 04 24             	mov    %eax,(%esp)
  801eda:	e8 55 ef ff ff       	call   800e34 <fd2data>
  801edf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ee6:	00 
  801ee7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801eeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ef2:	00 
  801ef3:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ef7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801efe:	e8 0a ed ff ff       	call   800c0d <sys_page_map>
  801f03:	89 c3                	mov    %eax,%ebx
  801f05:	85 c0                	test   %eax,%eax
  801f07:	78 4c                	js     801f55 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f09:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f12:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f17:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f1e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801f24:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f27:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f29:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f36:	89 04 24             	mov    %eax,(%esp)
  801f39:	e8 e6 ee ff ff       	call   800e24 <fd2num>
  801f3e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f40:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f43:	89 04 24             	mov    %eax,(%esp)
  801f46:	e8 d9 ee ff ff       	call   800e24 <fd2num>
  801f4b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f53:	eb 36                	jmp    801f8b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f55:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f60:	e8 fb ec ff ff       	call   800c60 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801f65:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f6c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f73:	e8 e8 ec ff ff       	call   800c60 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801f78:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f7f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f86:	e8 d5 ec ff ff       	call   800c60 <sys_page_unmap>
    err:
	return r;
}
  801f8b:	89 d8                	mov    %ebx,%eax
  801f8d:	83 c4 3c             	add    $0x3c,%esp
  801f90:	5b                   	pop    %ebx
  801f91:	5e                   	pop    %esi
  801f92:	5f                   	pop    %edi
  801f93:	5d                   	pop    %ebp
  801f94:	c3                   	ret    

00801f95 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa5:	89 04 24             	mov    %eax,(%esp)
  801fa8:	e8 f5 ee ff ff       	call   800ea2 <fd_lookup>
  801fad:	85 c0                	test   %eax,%eax
  801faf:	78 15                	js     801fc6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801fb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fb4:	89 04 24             	mov    %eax,(%esp)
  801fb7:	e8 78 ee ff ff       	call   800e34 <fd2data>
	return _pipeisclosed(fd, p);
  801fbc:	89 c2                	mov    %eax,%edx
  801fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc1:	e8 15 fd ff ff       	call   801cdb <_pipeisclosed>
}
  801fc6:	c9                   	leave  
  801fc7:	c3                   	ret    

00801fc8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801fcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd0:	5d                   	pop    %ebp
  801fd1:	c3                   	ret    

00801fd2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fd2:	55                   	push   %ebp
  801fd3:	89 e5                	mov    %esp,%ebp
  801fd5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801fd8:	c7 44 24 04 67 2a 80 	movl   $0x802a67,0x4(%esp)
  801fdf:	00 
  801fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe3:	89 04 24             	mov    %eax,(%esp)
  801fe6:	e8 dc e7 ff ff       	call   8007c7 <strcpy>
	return 0;
}
  801feb:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff0:	c9                   	leave  
  801ff1:	c3                   	ret    

00801ff2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ff2:	55                   	push   %ebp
  801ff3:	89 e5                	mov    %esp,%ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ffe:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802003:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802009:	eb 30                	jmp    80203b <devcons_write+0x49>
		m = n - tot;
  80200b:	8b 75 10             	mov    0x10(%ebp),%esi
  80200e:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802010:	83 fe 7f             	cmp    $0x7f,%esi
  802013:	76 05                	jbe    80201a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  802015:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80201a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80201e:	03 45 0c             	add    0xc(%ebp),%eax
  802021:	89 44 24 04          	mov    %eax,0x4(%esp)
  802025:	89 3c 24             	mov    %edi,(%esp)
  802028:	e8 13 e9 ff ff       	call   800940 <memmove>
		sys_cputs(buf, m);
  80202d:	89 74 24 04          	mov    %esi,0x4(%esp)
  802031:	89 3c 24             	mov    %edi,(%esp)
  802034:	e8 b3 ea ff ff       	call   800aec <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802039:	01 f3                	add    %esi,%ebx
  80203b:	89 d8                	mov    %ebx,%eax
  80203d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802040:	72 c9                	jb     80200b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802042:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802048:	5b                   	pop    %ebx
  802049:	5e                   	pop    %esi
  80204a:	5f                   	pop    %edi
  80204b:	5d                   	pop    %ebp
  80204c:	c3                   	ret    

0080204d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  802053:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802057:	75 07                	jne    802060 <devcons_read+0x13>
  802059:	eb 25                	jmp    802080 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80205b:	e8 3a eb ff ff       	call   800b9a <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802060:	e8 a5 ea ff ff       	call   800b0a <sys_cgetc>
  802065:	85 c0                	test   %eax,%eax
  802067:	74 f2                	je     80205b <devcons_read+0xe>
  802069:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80206b:	85 c0                	test   %eax,%eax
  80206d:	78 1d                	js     80208c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80206f:	83 f8 04             	cmp    $0x4,%eax
  802072:	74 13                	je     802087 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  802074:	8b 45 0c             	mov    0xc(%ebp),%eax
  802077:	88 10                	mov    %dl,(%eax)
	return 1;
  802079:	b8 01 00 00 00       	mov    $0x1,%eax
  80207e:	eb 0c                	jmp    80208c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  802080:	b8 00 00 00 00       	mov    $0x0,%eax
  802085:	eb 05                	jmp    80208c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802087:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80208c:	c9                   	leave  
  80208d:	c3                   	ret    

0080208e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  802094:	8b 45 08             	mov    0x8(%ebp),%eax
  802097:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80209a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020a1:	00 
  8020a2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a5:	89 04 24             	mov    %eax,(%esp)
  8020a8:	e8 3f ea ff ff       	call   800aec <sys_cputs>
}
  8020ad:	c9                   	leave  
  8020ae:	c3                   	ret    

008020af <getchar>:

int
getchar(void)
{
  8020af:	55                   	push   %ebp
  8020b0:	89 e5                	mov    %esp,%ebp
  8020b2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020b5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8020bc:	00 
  8020bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020cb:	e8 6e f0 ff ff       	call   80113e <read>
	if (r < 0)
  8020d0:	85 c0                	test   %eax,%eax
  8020d2:	78 0f                	js     8020e3 <getchar+0x34>
		return r;
	if (r < 1)
  8020d4:	85 c0                	test   %eax,%eax
  8020d6:	7e 06                	jle    8020de <getchar+0x2f>
		return -E_EOF;
	return c;
  8020d8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8020dc:	eb 05                	jmp    8020e3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8020de:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8020f5:	89 04 24             	mov    %eax,(%esp)
  8020f8:	e8 a5 ed ff ff       	call   800ea2 <fd_lookup>
  8020fd:	85 c0                	test   %eax,%eax
  8020ff:	78 11                	js     802112 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802101:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802104:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80210a:	39 10                	cmp    %edx,(%eax)
  80210c:	0f 94 c0             	sete   %al
  80210f:	0f b6 c0             	movzbl %al,%eax
}
  802112:	c9                   	leave  
  802113:	c3                   	ret    

00802114 <opencons>:

int
opencons(void)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80211a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211d:	89 04 24             	mov    %eax,(%esp)
  802120:	e8 2a ed ff ff       	call   800e4f <fd_alloc>
  802125:	85 c0                	test   %eax,%eax
  802127:	78 3c                	js     802165 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802129:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802130:	00 
  802131:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802134:	89 44 24 04          	mov    %eax,0x4(%esp)
  802138:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80213f:	e8 75 ea ff ff       	call   800bb9 <sys_page_alloc>
  802144:	85 c0                	test   %eax,%eax
  802146:	78 1d                	js     802165 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802148:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80214e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802151:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802153:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802156:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80215d:	89 04 24             	mov    %eax,(%esp)
  802160:	e8 bf ec ff ff       	call   800e24 <fd2num>
}
  802165:	c9                   	leave  
  802166:	c3                   	ret    
	...

00802168 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	56                   	push   %esi
  80216c:	53                   	push   %ebx
  80216d:	83 ec 10             	sub    $0x10,%esp
  802170:	8b 75 08             	mov    0x8(%ebp),%esi
  802173:	8b 45 0c             	mov    0xc(%ebp),%eax
  802176:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  802179:	85 c0                	test   %eax,%eax
  80217b:	75 05                	jne    802182 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  80217d:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  802182:	89 04 24             	mov    %eax,(%esp)
  802185:	e8 45 ec ff ff       	call   800dcf <sys_ipc_recv>
	if (!err) {
  80218a:	85 c0                	test   %eax,%eax
  80218c:	75 26                	jne    8021b4 <ipc_recv+0x4c>
		if (from_env_store) {
  80218e:	85 f6                	test   %esi,%esi
  802190:	74 0a                	je     80219c <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  802192:	a1 04 40 80 00       	mov    0x804004,%eax
  802197:	8b 40 74             	mov    0x74(%eax),%eax
  80219a:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  80219c:	85 db                	test   %ebx,%ebx
  80219e:	74 0a                	je     8021aa <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8021a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8021a5:	8b 40 78             	mov    0x78(%eax),%eax
  8021a8:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8021aa:	a1 04 40 80 00       	mov    0x804004,%eax
  8021af:	8b 40 70             	mov    0x70(%eax),%eax
  8021b2:	eb 14                	jmp    8021c8 <ipc_recv+0x60>
	}
	if (from_env_store) {
  8021b4:	85 f6                	test   %esi,%esi
  8021b6:	74 06                	je     8021be <ipc_recv+0x56>
		*from_env_store = 0;
  8021b8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8021be:	85 db                	test   %ebx,%ebx
  8021c0:	74 06                	je     8021c8 <ipc_recv+0x60>
		*perm_store = 0;
  8021c2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8021c8:	83 c4 10             	add    $0x10,%esp
  8021cb:	5b                   	pop    %ebx
  8021cc:	5e                   	pop    %esi
  8021cd:	5d                   	pop    %ebp
  8021ce:	c3                   	ret    

008021cf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	57                   	push   %edi
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	83 ec 1c             	sub    $0x1c,%esp
  8021d8:	8b 75 10             	mov    0x10(%ebp),%esi
  8021db:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  8021de:	85 f6                	test   %esi,%esi
  8021e0:	75 05                	jne    8021e7 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  8021e2:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  8021e7:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8021eb:	89 74 24 08          	mov    %esi,0x8(%esp)
  8021ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f9:	89 04 24             	mov    %eax,(%esp)
  8021fc:	e8 ab eb ff ff       	call   800dac <sys_ipc_try_send>
  802201:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802203:	e8 92 e9 ff ff       	call   800b9a <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802208:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80220b:	74 da                	je     8021e7 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  80220d:	85 db                	test   %ebx,%ebx
  80220f:	74 20                	je     802231 <ipc_send+0x62>
		panic("send fail: %e", err);
  802211:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802215:	c7 44 24 08 73 2a 80 	movl   $0x802a73,0x8(%esp)
  80221c:	00 
  80221d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802224:	00 
  802225:	c7 04 24 81 2a 80 00 	movl   $0x802a81,(%esp)
  80222c:	e8 d3 de ff ff       	call   800104 <_panic>
	}
	return;
}
  802231:	83 c4 1c             	add    $0x1c,%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5f                   	pop    %edi
  802237:	5d                   	pop    %ebp
  802238:	c3                   	ret    

00802239 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802239:	55                   	push   %ebp
  80223a:	89 e5                	mov    %esp,%ebp
  80223c:	53                   	push   %ebx
  80223d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802240:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802245:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  80224c:	89 c2                	mov    %eax,%edx
  80224e:	c1 e2 07             	shl    $0x7,%edx
  802251:	29 ca                	sub    %ecx,%edx
  802253:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802259:	8b 52 50             	mov    0x50(%edx),%edx
  80225c:	39 da                	cmp    %ebx,%edx
  80225e:	75 0f                	jne    80226f <ipc_find_env+0x36>
			return envs[i].env_id;
  802260:	c1 e0 07             	shl    $0x7,%eax
  802263:	29 c8                	sub    %ecx,%eax
  802265:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80226a:	8b 40 40             	mov    0x40(%eax),%eax
  80226d:	eb 0c                	jmp    80227b <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80226f:	40                   	inc    %eax
  802270:	3d 00 04 00 00       	cmp    $0x400,%eax
  802275:	75 ce                	jne    802245 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802277:	66 b8 00 00          	mov    $0x0,%ax
}
  80227b:	5b                   	pop    %ebx
  80227c:	5d                   	pop    %ebp
  80227d:	c3                   	ret    
	...

00802280 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802280:	55                   	push   %ebp
  802281:	89 e5                	mov    %esp,%ebp
  802283:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802286:	89 c2                	mov    %eax,%edx
  802288:	c1 ea 16             	shr    $0x16,%edx
  80228b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802292:	f6 c2 01             	test   $0x1,%dl
  802295:	74 1e                	je     8022b5 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802297:	c1 e8 0c             	shr    $0xc,%eax
  80229a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022a1:	a8 01                	test   $0x1,%al
  8022a3:	74 17                	je     8022bc <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022a5:	c1 e8 0c             	shr    $0xc,%eax
  8022a8:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022af:	ef 
  8022b0:	0f b7 c0             	movzwl %ax,%eax
  8022b3:	eb 0c                	jmp    8022c1 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ba:	eb 05                	jmp    8022c1 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  8022bc:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
	...

008022c4 <__udivdi3>:
  8022c4:	55                   	push   %ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	83 ec 10             	sub    $0x10,%esp
  8022ca:	8b 74 24 20          	mov    0x20(%esp),%esi
  8022ce:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8022d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d6:	8b 7c 24 24          	mov    0x24(%esp),%edi
  8022da:	89 cd                	mov    %ecx,%ebp
  8022dc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  8022e0:	85 c0                	test   %eax,%eax
  8022e2:	75 2c                	jne    802310 <__udivdi3+0x4c>
  8022e4:	39 f9                	cmp    %edi,%ecx
  8022e6:	77 68                	ja     802350 <__udivdi3+0x8c>
  8022e8:	85 c9                	test   %ecx,%ecx
  8022ea:	75 0b                	jne    8022f7 <__udivdi3+0x33>
  8022ec:	b8 01 00 00 00       	mov    $0x1,%eax
  8022f1:	31 d2                	xor    %edx,%edx
  8022f3:	f7 f1                	div    %ecx
  8022f5:	89 c1                	mov    %eax,%ecx
  8022f7:	31 d2                	xor    %edx,%edx
  8022f9:	89 f8                	mov    %edi,%eax
  8022fb:	f7 f1                	div    %ecx
  8022fd:	89 c7                	mov    %eax,%edi
  8022ff:	89 f0                	mov    %esi,%eax
  802301:	f7 f1                	div    %ecx
  802303:	89 c6                	mov    %eax,%esi
  802305:	89 f0                	mov    %esi,%eax
  802307:	89 fa                	mov    %edi,%edx
  802309:	83 c4 10             	add    $0x10,%esp
  80230c:	5e                   	pop    %esi
  80230d:	5f                   	pop    %edi
  80230e:	5d                   	pop    %ebp
  80230f:	c3                   	ret    
  802310:	39 f8                	cmp    %edi,%eax
  802312:	77 2c                	ja     802340 <__udivdi3+0x7c>
  802314:	0f bd f0             	bsr    %eax,%esi
  802317:	83 f6 1f             	xor    $0x1f,%esi
  80231a:	75 4c                	jne    802368 <__udivdi3+0xa4>
  80231c:	39 f8                	cmp    %edi,%eax
  80231e:	bf 00 00 00 00       	mov    $0x0,%edi
  802323:	72 0a                	jb     80232f <__udivdi3+0x6b>
  802325:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802329:	0f 87 ad 00 00 00    	ja     8023dc <__udivdi3+0x118>
  80232f:	be 01 00 00 00       	mov    $0x1,%esi
  802334:	89 f0                	mov    %esi,%eax
  802336:	89 fa                	mov    %edi,%edx
  802338:	83 c4 10             	add    $0x10,%esp
  80233b:	5e                   	pop    %esi
  80233c:	5f                   	pop    %edi
  80233d:	5d                   	pop    %ebp
  80233e:	c3                   	ret    
  80233f:	90                   	nop
  802340:	31 ff                	xor    %edi,%edi
  802342:	31 f6                	xor    %esi,%esi
  802344:	89 f0                	mov    %esi,%eax
  802346:	89 fa                	mov    %edi,%edx
  802348:	83 c4 10             	add    $0x10,%esp
  80234b:	5e                   	pop    %esi
  80234c:	5f                   	pop    %edi
  80234d:	5d                   	pop    %ebp
  80234e:	c3                   	ret    
  80234f:	90                   	nop
  802350:	89 fa                	mov    %edi,%edx
  802352:	89 f0                	mov    %esi,%eax
  802354:	f7 f1                	div    %ecx
  802356:	89 c6                	mov    %eax,%esi
  802358:	31 ff                	xor    %edi,%edi
  80235a:	89 f0                	mov    %esi,%eax
  80235c:	89 fa                	mov    %edi,%edx
  80235e:	83 c4 10             	add    $0x10,%esp
  802361:	5e                   	pop    %esi
  802362:	5f                   	pop    %edi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    
  802365:	8d 76 00             	lea    0x0(%esi),%esi
  802368:	89 f1                	mov    %esi,%ecx
  80236a:	d3 e0                	shl    %cl,%eax
  80236c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802370:	b8 20 00 00 00       	mov    $0x20,%eax
  802375:	29 f0                	sub    %esi,%eax
  802377:	89 ea                	mov    %ebp,%edx
  802379:	88 c1                	mov    %al,%cl
  80237b:	d3 ea                	shr    %cl,%edx
  80237d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  802381:	09 ca                	or     %ecx,%edx
  802383:	89 54 24 08          	mov    %edx,0x8(%esp)
  802387:	89 f1                	mov    %esi,%ecx
  802389:	d3 e5                	shl    %cl,%ebp
  80238b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80238f:	89 fd                	mov    %edi,%ebp
  802391:	88 c1                	mov    %al,%cl
  802393:	d3 ed                	shr    %cl,%ebp
  802395:	89 fa                	mov    %edi,%edx
  802397:	89 f1                	mov    %esi,%ecx
  802399:	d3 e2                	shl    %cl,%edx
  80239b:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80239f:	88 c1                	mov    %al,%cl
  8023a1:	d3 ef                	shr    %cl,%edi
  8023a3:	09 d7                	or     %edx,%edi
  8023a5:	89 f8                	mov    %edi,%eax
  8023a7:	89 ea                	mov    %ebp,%edx
  8023a9:	f7 74 24 08          	divl   0x8(%esp)
  8023ad:	89 d1                	mov    %edx,%ecx
  8023af:	89 c7                	mov    %eax,%edi
  8023b1:	f7 64 24 0c          	mull   0xc(%esp)
  8023b5:	39 d1                	cmp    %edx,%ecx
  8023b7:	72 17                	jb     8023d0 <__udivdi3+0x10c>
  8023b9:	74 09                	je     8023c4 <__udivdi3+0x100>
  8023bb:	89 fe                	mov    %edi,%esi
  8023bd:	31 ff                	xor    %edi,%edi
  8023bf:	e9 41 ff ff ff       	jmp    802305 <__udivdi3+0x41>
  8023c4:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c8:	89 f1                	mov    %esi,%ecx
  8023ca:	d3 e2                	shl    %cl,%edx
  8023cc:	39 c2                	cmp    %eax,%edx
  8023ce:	73 eb                	jae    8023bb <__udivdi3+0xf7>
  8023d0:	8d 77 ff             	lea    -0x1(%edi),%esi
  8023d3:	31 ff                	xor    %edi,%edi
  8023d5:	e9 2b ff ff ff       	jmp    802305 <__udivdi3+0x41>
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	31 f6                	xor    %esi,%esi
  8023de:	e9 22 ff ff ff       	jmp    802305 <__udivdi3+0x41>
	...

008023e4 <__umoddi3>:
  8023e4:	55                   	push   %ebp
  8023e5:	57                   	push   %edi
  8023e6:	56                   	push   %esi
  8023e7:	83 ec 20             	sub    $0x20,%esp
  8023ea:	8b 44 24 30          	mov    0x30(%esp),%eax
  8023ee:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  8023f2:	89 44 24 14          	mov    %eax,0x14(%esp)
  8023f6:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023fa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8023fe:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  802402:	89 c7                	mov    %eax,%edi
  802404:	89 f2                	mov    %esi,%edx
  802406:	85 ed                	test   %ebp,%ebp
  802408:	75 16                	jne    802420 <__umoddi3+0x3c>
  80240a:	39 f1                	cmp    %esi,%ecx
  80240c:	0f 86 a6 00 00 00    	jbe    8024b8 <__umoddi3+0xd4>
  802412:	f7 f1                	div    %ecx
  802414:	89 d0                	mov    %edx,%eax
  802416:	31 d2                	xor    %edx,%edx
  802418:	83 c4 20             	add    $0x20,%esp
  80241b:	5e                   	pop    %esi
  80241c:	5f                   	pop    %edi
  80241d:	5d                   	pop    %ebp
  80241e:	c3                   	ret    
  80241f:	90                   	nop
  802420:	39 f5                	cmp    %esi,%ebp
  802422:	0f 87 ac 00 00 00    	ja     8024d4 <__umoddi3+0xf0>
  802428:	0f bd c5             	bsr    %ebp,%eax
  80242b:	83 f0 1f             	xor    $0x1f,%eax
  80242e:	89 44 24 10          	mov    %eax,0x10(%esp)
  802432:	0f 84 a8 00 00 00    	je     8024e0 <__umoddi3+0xfc>
  802438:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80243c:	d3 e5                	shl    %cl,%ebp
  80243e:	bf 20 00 00 00       	mov    $0x20,%edi
  802443:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802447:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80244b:	89 f9                	mov    %edi,%ecx
  80244d:	d3 e8                	shr    %cl,%eax
  80244f:	09 e8                	or     %ebp,%eax
  802451:	89 44 24 18          	mov    %eax,0x18(%esp)
  802455:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802459:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80245d:	d3 e0                	shl    %cl,%eax
  80245f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802463:	89 f2                	mov    %esi,%edx
  802465:	d3 e2                	shl    %cl,%edx
  802467:	8b 44 24 14          	mov    0x14(%esp),%eax
  80246b:	d3 e0                	shl    %cl,%eax
  80246d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802471:	8b 44 24 14          	mov    0x14(%esp),%eax
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e8                	shr    %cl,%eax
  802479:	09 d0                	or     %edx,%eax
  80247b:	d3 ee                	shr    %cl,%esi
  80247d:	89 f2                	mov    %esi,%edx
  80247f:	f7 74 24 18          	divl   0x18(%esp)
  802483:	89 d6                	mov    %edx,%esi
  802485:	f7 64 24 0c          	mull   0xc(%esp)
  802489:	89 c5                	mov    %eax,%ebp
  80248b:	89 d1                	mov    %edx,%ecx
  80248d:	39 d6                	cmp    %edx,%esi
  80248f:	72 67                	jb     8024f8 <__umoddi3+0x114>
  802491:	74 75                	je     802508 <__umoddi3+0x124>
  802493:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  802497:	29 e8                	sub    %ebp,%eax
  802499:	19 ce                	sbb    %ecx,%esi
  80249b:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80249f:	d3 e8                	shr    %cl,%eax
  8024a1:	89 f2                	mov    %esi,%edx
  8024a3:	89 f9                	mov    %edi,%ecx
  8024a5:	d3 e2                	shl    %cl,%edx
  8024a7:	09 d0                	or     %edx,%eax
  8024a9:	89 f2                	mov    %esi,%edx
  8024ab:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024af:	d3 ea                	shr    %cl,%edx
  8024b1:	83 c4 20             	add    $0x20,%esp
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    
  8024b8:	85 c9                	test   %ecx,%ecx
  8024ba:	75 0b                	jne    8024c7 <__umoddi3+0xe3>
  8024bc:	b8 01 00 00 00       	mov    $0x1,%eax
  8024c1:	31 d2                	xor    %edx,%edx
  8024c3:	f7 f1                	div    %ecx
  8024c5:	89 c1                	mov    %eax,%ecx
  8024c7:	89 f0                	mov    %esi,%eax
  8024c9:	31 d2                	xor    %edx,%edx
  8024cb:	f7 f1                	div    %ecx
  8024cd:	89 f8                	mov    %edi,%eax
  8024cf:	e9 3e ff ff ff       	jmp    802412 <__umoddi3+0x2e>
  8024d4:	89 f2                	mov    %esi,%edx
  8024d6:	83 c4 20             	add    $0x20,%esp
  8024d9:	5e                   	pop    %esi
  8024da:	5f                   	pop    %edi
  8024db:	5d                   	pop    %ebp
  8024dc:	c3                   	ret    
  8024dd:	8d 76 00             	lea    0x0(%esi),%esi
  8024e0:	39 f5                	cmp    %esi,%ebp
  8024e2:	72 04                	jb     8024e8 <__umoddi3+0x104>
  8024e4:	39 f9                	cmp    %edi,%ecx
  8024e6:	77 06                	ja     8024ee <__umoddi3+0x10a>
  8024e8:	89 f2                	mov    %esi,%edx
  8024ea:	29 cf                	sub    %ecx,%edi
  8024ec:	19 ea                	sbb    %ebp,%edx
  8024ee:	89 f8                	mov    %edi,%eax
  8024f0:	83 c4 20             	add    $0x20,%esp
  8024f3:	5e                   	pop    %esi
  8024f4:	5f                   	pop    %edi
  8024f5:	5d                   	pop    %ebp
  8024f6:	c3                   	ret    
  8024f7:	90                   	nop
  8024f8:	89 d1                	mov    %edx,%ecx
  8024fa:	89 c5                	mov    %eax,%ebp
  8024fc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  802500:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802504:	eb 8d                	jmp    802493 <__umoddi3+0xaf>
  802506:	66 90                	xchg   %ax,%ax
  802508:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  80250c:	72 ea                	jb     8024f8 <__umoddi3+0x114>
  80250e:	89 f1                	mov    %esi,%ecx
  802510:	eb 81                	jmp    802493 <__umoddi3+0xaf>
