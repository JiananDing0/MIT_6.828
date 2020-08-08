
obj/user/sendpage:     file format elf32-i386


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
  80002c:	e8 af 01 00 00       	call   8001e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 28             	sub    $0x28,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003a:	e8 8c 0f 00 00       	call   800fcb <fork>
  80003f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800042:	85 c0                	test   %eax,%eax
  800044:	0f 85 bb 00 00 00    	jne    800105 <umain+0xd1>
		// Child
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  80004a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800051:	00 
  800052:	c7 44 24 04 00 00 b0 	movl   $0xb00000,0x4(%esp)
  800059:	00 
  80005a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80005d:	89 04 24             	mov    %eax,(%esp)
  800060:	e8 5f 12 00 00       	call   8012c4 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  80007b:	e8 68 02 00 00       	call   8002e8 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 f3 07 00 00       	call   800880 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 20 80 00       	mov    0x802004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 d5 08 00 00       	call   80097b <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 74 17 80 00 	movl   $0x801774,(%esp)
  8000b1:	e8 32 02 00 00       	call   8002e8 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 bd 07 00 00       	call   800880 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 20 80 00       	mov    0x802000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 b9 09 00 00       	call   800a96 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 2b 12 00 00       	call   80132b <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 80 0b 00 00       	call   800ca5 <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 20 80 00       	mov    0x802004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 4e 07 00 00       	call   800880 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 20 80 00       	mov    0x802004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 4a 09 00 00       	call   800a96 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 bc 11 00 00       	call   80132b <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 3a 11 00 00       	call   8012c4 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 60 17 80 00 	movl   $0x801760,(%esp)
  8001a0:	e8 43 01 00 00       	call   8002e8 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 20 80 00       	mov    0x802000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 ce 06 00 00       	call   800880 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 20 80 00       	mov    0x802000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 b0 07 00 00       	call   80097b <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 94 17 80 00 	movl   $0x801794,(%esp)
  8001d6:	e8 0d 01 00 00       	call   8002e8 <cprintf>
	return;
}
  8001db:	c9                   	leave  
  8001dc:	c3                   	ret    
  8001dd:	00 00                	add    %al,(%eax)
	...

008001e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 10             	sub    $0x10,%esp
  8001e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8001eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8001ee:	e8 74 0a 00 00       	call   800c67 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 0c 20 80 00       	mov    %eax,0x80200c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 f6                	test   %esi,%esi
  800210:	7e 07                	jle    800219 <libmain+0x39>
		binaryname = argv[0];
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	a3 08 20 80 00       	mov    %eax,0x802008

	// call user main routine
	umain(argc, argv);
  800219:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021d:	89 34 24             	mov    %esi,(%esp)
  800220:	e8 0f fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800225:	e8 0a 00 00 00       	call   800234 <exit>
}
  80022a:	83 c4 10             	add    $0x10,%esp
  80022d:	5b                   	pop    %ebx
  80022e:	5e                   	pop    %esi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
  800231:	00 00                	add    %al,(%eax)
	...

00800234 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80023a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800241:	e8 cf 09 00 00       	call   800c15 <sys_env_destroy>
}
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	53                   	push   %ebx
  80024c:	83 ec 14             	sub    $0x14,%esp
  80024f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800252:	8b 03                	mov    (%ebx),%eax
  800254:	8b 55 08             	mov    0x8(%ebp),%edx
  800257:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80025b:	40                   	inc    %eax
  80025c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80025e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800263:	75 19                	jne    80027e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  800265:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80026c:	00 
  80026d:	8d 43 08             	lea    0x8(%ebx),%eax
  800270:	89 04 24             	mov    %eax,(%esp)
  800273:	e8 60 09 00 00       	call   800bd8 <sys_cputs>
		b->idx = 0;
  800278:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80027e:	ff 43 04             	incl   0x4(%ebx)
}
  800281:	83 c4 14             	add    $0x14,%esp
  800284:	5b                   	pop    %ebx
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800287:	55                   	push   %ebp
  800288:	89 e5                	mov    %esp,%ebp
  80028a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800290:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800297:	00 00 00 
	b.cnt = 0;
  80029a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bc:	c7 04 24 48 02 80 00 	movl   $0x800248,(%esp)
  8002c3:	e8 82 01 00 00       	call   80044a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002c8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	e8 f8 08 00 00       	call   800bd8 <sys_cputs>

	return b.cnt;
}
  8002e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002e6:	c9                   	leave  
  8002e7:	c3                   	ret    

008002e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002e8:	55                   	push   %ebp
  8002e9:	89 e5                	mov    %esp,%ebp
  8002eb:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f8:	89 04 24             	mov    %eax,(%esp)
  8002fb:	e8 87 ff ff ff       	call   800287 <vcprintf>
	va_end(ap);

	return cnt;
}
  800300:	c9                   	leave  
  800301:	c3                   	ret    
	...

00800304 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 3c             	sub    $0x3c,%esp
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	89 d7                	mov    %edx,%edi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800318:	8b 45 0c             	mov    0xc(%ebp),%eax
  80031b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80031e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800321:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800324:	85 c0                	test   %eax,%eax
  800326:	75 08                	jne    800330 <printnum+0x2c>
  800328:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80032b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80032e:	77 57                	ja     800387 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800330:	89 74 24 10          	mov    %esi,0x10(%esp)
  800334:	4b                   	dec    %ebx
  800335:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800339:	8b 45 10             	mov    0x10(%ebp),%eax
  80033c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800340:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800344:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800348:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034f:	00 
  800350:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800353:	89 04 24             	mov    %eax,(%esp)
  800356:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800359:	89 44 24 04          	mov    %eax,0x4(%esp)
  80035d:	e8 96 11 00 00       	call   8014f8 <__udivdi3>
  800362:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800366:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80036a:	89 04 24             	mov    %eax,(%esp)
  80036d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800371:	89 fa                	mov    %edi,%edx
  800373:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800376:	e8 89 ff ff ff       	call   800304 <printnum>
  80037b:	eb 0f                	jmp    80038c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80037d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800381:	89 34 24             	mov    %esi,(%esp)
  800384:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800387:	4b                   	dec    %ebx
  800388:	85 db                	test   %ebx,%ebx
  80038a:	7f f1                	jg     80037d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800390:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800394:	8b 45 10             	mov    0x10(%ebp),%eax
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003a2:	00 
  8003a3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003a6:	89 04 24             	mov    %eax,(%esp)
  8003a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b0:	e8 63 12 00 00       	call   801618 <__umoddi3>
  8003b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003b9:	0f be 80 0c 18 80 00 	movsbl 0x80180c(%eax),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003c6:	83 c4 3c             	add    $0x3c,%esp
  8003c9:	5b                   	pop    %ebx
  8003ca:	5e                   	pop    %esi
  8003cb:	5f                   	pop    %edi
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d1:	83 fa 01             	cmp    $0x1,%edx
  8003d4:	7e 0e                	jle    8003e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d6:	8b 10                	mov    (%eax),%edx
  8003d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003db:	89 08                	mov    %ecx,(%eax)
  8003dd:	8b 02                	mov    (%edx),%eax
  8003df:	8b 52 04             	mov    0x4(%edx),%edx
  8003e2:	eb 22                	jmp    800406 <getuint+0x38>
	else if (lflag)
  8003e4:	85 d2                	test   %edx,%edx
  8003e6:	74 10                	je     8003f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e8:	8b 10                	mov    (%eax),%edx
  8003ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003ed:	89 08                	mov    %ecx,(%eax)
  8003ef:	8b 02                	mov    (%edx),%eax
  8003f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f6:	eb 0e                	jmp    800406 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f8:	8b 10                	mov    (%eax),%edx
  8003fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003fd:	89 08                	mov    %ecx,(%eax)
  8003ff:	8b 02                	mov    (%edx),%eax
  800401:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800406:	5d                   	pop    %ebp
  800407:	c3                   	ret    

00800408 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800408:	55                   	push   %ebp
  800409:	89 e5                	mov    %esp,%ebp
  80040b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800411:	8b 10                	mov    (%eax),%edx
  800413:	3b 50 04             	cmp    0x4(%eax),%edx
  800416:	73 08                	jae    800420 <sprintputch+0x18>
		*b->buf++ = ch;
  800418:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041b:	88 0a                	mov    %cl,(%edx)
  80041d:	42                   	inc    %edx
  80041e:	89 10                	mov    %edx,(%eax)
}
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800428:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80042f:	8b 45 10             	mov    0x10(%ebp),%eax
  800432:	89 44 24 08          	mov    %eax,0x8(%esp)
  800436:	8b 45 0c             	mov    0xc(%ebp),%eax
  800439:	89 44 24 04          	mov    %eax,0x4(%esp)
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
  800440:	89 04 24             	mov    %eax,(%esp)
  800443:	e8 02 00 00 00       	call   80044a <vprintfmt>
	va_end(ap);
}
  800448:	c9                   	leave  
  800449:	c3                   	ret    

0080044a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 4c             	sub    $0x4c,%esp
  800453:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800456:	8b 75 10             	mov    0x10(%ebp),%esi
  800459:	eb 12                	jmp    80046d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80045b:	85 c0                	test   %eax,%eax
  80045d:	0f 84 8b 03 00 00    	je     8007ee <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  800463:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800467:	89 04 24             	mov    %eax,(%esp)
  80046a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80046d:	0f b6 06             	movzbl (%esi),%eax
  800470:	46                   	inc    %esi
  800471:	83 f8 25             	cmp    $0x25,%eax
  800474:	75 e5                	jne    80045b <vprintfmt+0x11>
  800476:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  80047a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800481:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  800486:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  80048d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800492:	eb 26                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  800497:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80049b:	eb 1d                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004a4:	eb 14                	jmp    8004ba <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b0:	eb 08                	jmp    8004ba <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004b2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004b5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	0f b6 06             	movzbl (%esi),%eax
  8004bd:	8d 56 01             	lea    0x1(%esi),%edx
  8004c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c3:	8a 16                	mov    (%esi),%dl
  8004c5:	83 ea 23             	sub    $0x23,%edx
  8004c8:	80 fa 55             	cmp    $0x55,%dl
  8004cb:	0f 87 01 03 00 00    	ja     8007d2 <vprintfmt+0x388>
  8004d1:	0f b6 d2             	movzbl %dl,%edx
  8004d4:	ff 24 95 e0 18 80 00 	jmp    *0x8018e0(,%edx,4)
  8004db:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004de:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004e3:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004e6:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004ea:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004ed:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f0:	83 fa 09             	cmp    $0x9,%edx
  8004f3:	77 2a                	ja     80051f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004f5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004f6:	eb eb                	jmp    8004e3 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8d 50 04             	lea    0x4(%eax),%edx
  8004fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800501:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800503:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800506:	eb 17                	jmp    80051f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800508:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050c:	78 98                	js     8004a6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800511:	eb a7                	jmp    8004ba <vprintfmt+0x70>
  800513:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800516:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80051d:	eb 9b                	jmp    8004ba <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80051f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800523:	79 95                	jns    8004ba <vprintfmt+0x70>
  800525:	eb 8b                	jmp    8004b2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800527:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80052b:	eb 8d                	jmp    8004ba <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052d:	8b 45 14             	mov    0x14(%ebp),%eax
  800530:	8d 50 04             	lea    0x4(%eax),%edx
  800533:	89 55 14             	mov    %edx,0x14(%ebp)
  800536:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 04 24             	mov    %eax,(%esp)
  80053f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800542:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800545:	e9 23 ff ff ff       	jmp    80046d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054a:	8b 45 14             	mov    0x14(%ebp),%eax
  80054d:	8d 50 04             	lea    0x4(%eax),%edx
  800550:	89 55 14             	mov    %edx,0x14(%ebp)
  800553:	8b 00                	mov    (%eax),%eax
  800555:	85 c0                	test   %eax,%eax
  800557:	79 02                	jns    80055b <vprintfmt+0x111>
  800559:	f7 d8                	neg    %eax
  80055b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055d:	83 f8 08             	cmp    $0x8,%eax
  800560:	7f 0b                	jg     80056d <vprintfmt+0x123>
  800562:	8b 04 85 40 1a 80 00 	mov    0x801a40(,%eax,4),%eax
  800569:	85 c0                	test   %eax,%eax
  80056b:	75 23                	jne    800590 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80056d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800571:	c7 44 24 08 24 18 80 	movl   $0x801824,0x8(%esp)
  800578:	00 
  800579:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80057d:	8b 45 08             	mov    0x8(%ebp),%eax
  800580:	89 04 24             	mov    %eax,(%esp)
  800583:	e8 9a fe ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800588:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80058b:	e9 dd fe ff ff       	jmp    80046d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800590:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800594:	c7 44 24 08 2d 18 80 	movl   $0x80182d,0x8(%esp)
  80059b:	00 
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8005a3:	89 14 24             	mov    %edx,(%esp)
  8005a6:	e8 77 fe ff ff       	call   800422 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ab:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ae:	e9 ba fe ff ff       	jmp    80046d <vprintfmt+0x23>
  8005b3:	89 f9                	mov    %edi,%ecx
  8005b5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 30                	mov    (%eax),%esi
  8005c6:	85 f6                	test   %esi,%esi
  8005c8:	75 05                	jne    8005cf <vprintfmt+0x185>
				p = "(null)";
  8005ca:	be 1d 18 80 00       	mov    $0x80181d,%esi
			if (width > 0 && padc != '-')
  8005cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005d3:	0f 8e 84 00 00 00    	jle    80065d <vprintfmt+0x213>
  8005d9:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005dd:	74 7e                	je     80065d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e3:	89 34 24             	mov    %esi,(%esp)
  8005e6:	e8 ab 02 00 00       	call   800896 <strnlen>
  8005eb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005ee:	29 c2                	sub    %eax,%edx
  8005f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005f3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005f7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8005fa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8005fd:	89 de                	mov    %ebx,%esi
  8005ff:	89 d3                	mov    %edx,%ebx
  800601:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800603:	eb 0b                	jmp    800610 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800605:	89 74 24 04          	mov    %esi,0x4(%esp)
  800609:	89 3c 24             	mov    %edi,(%esp)
  80060c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	4b                   	dec    %ebx
  800610:	85 db                	test   %ebx,%ebx
  800612:	7f f1                	jg     800605 <vprintfmt+0x1bb>
  800614:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800617:	89 f3                	mov    %esi,%ebx
  800619:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80061c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80061f:	85 c0                	test   %eax,%eax
  800621:	79 05                	jns    800628 <vprintfmt+0x1de>
  800623:	b8 00 00 00 00       	mov    $0x0,%eax
  800628:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80062b:	29 c2                	sub    %eax,%edx
  80062d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800630:	eb 2b                	jmp    80065d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800632:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800636:	74 18                	je     800650 <vprintfmt+0x206>
  800638:	8d 50 e0             	lea    -0x20(%eax),%edx
  80063b:	83 fa 5e             	cmp    $0x5e,%edx
  80063e:	76 10                	jbe    800650 <vprintfmt+0x206>
					putch('?', putdat);
  800640:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800644:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80064b:	ff 55 08             	call   *0x8(%ebp)
  80064e:	eb 0a                	jmp    80065a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800650:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800654:	89 04 24             	mov    %eax,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80065a:	ff 4d e4             	decl   -0x1c(%ebp)
  80065d:	0f be 06             	movsbl (%esi),%eax
  800660:	46                   	inc    %esi
  800661:	85 c0                	test   %eax,%eax
  800663:	74 21                	je     800686 <vprintfmt+0x23c>
  800665:	85 ff                	test   %edi,%edi
  800667:	78 c9                	js     800632 <vprintfmt+0x1e8>
  800669:	4f                   	dec    %edi
  80066a:	79 c6                	jns    800632 <vprintfmt+0x1e8>
  80066c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80066f:	89 de                	mov    %ebx,%esi
  800671:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800674:	eb 18                	jmp    80068e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800676:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800681:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800683:	4b                   	dec    %ebx
  800684:	eb 08                	jmp    80068e <vprintfmt+0x244>
  800686:	8b 7d 08             	mov    0x8(%ebp),%edi
  800689:	89 de                	mov    %ebx,%esi
  80068b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80068e:	85 db                	test   %ebx,%ebx
  800690:	7f e4                	jg     800676 <vprintfmt+0x22c>
  800692:	89 7d 08             	mov    %edi,0x8(%ebp)
  800695:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80069a:	e9 ce fd ff ff       	jmp    80046d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7e 10                	jle    8006b4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 08             	lea    0x8(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 30                	mov    (%eax),%esi
  8006af:	8b 78 04             	mov    0x4(%eax),%edi
  8006b2:	eb 26                	jmp    8006da <vprintfmt+0x290>
	else if (lflag)
  8006b4:	85 c9                	test   %ecx,%ecx
  8006b6:	74 12                	je     8006ca <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bb:	8d 50 04             	lea    0x4(%eax),%edx
  8006be:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c1:	8b 30                	mov    (%eax),%esi
  8006c3:	89 f7                	mov    %esi,%edi
  8006c5:	c1 ff 1f             	sar    $0x1f,%edi
  8006c8:	eb 10                	jmp    8006da <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 30                	mov    (%eax),%esi
  8006d5:	89 f7                	mov    %esi,%edi
  8006d7:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006da:	85 ff                	test   %edi,%edi
  8006dc:	78 0a                	js     8006e8 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e3:	e9 ac 00 00 00       	jmp    800794 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006f6:	f7 de                	neg    %esi
  8006f8:	83 d7 00             	adc    $0x0,%edi
  8006fb:	f7 df                	neg    %edi
			}
			base = 10;
  8006fd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800702:	e9 8d 00 00 00       	jmp    800794 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800707:	89 ca                	mov    %ecx,%edx
  800709:	8d 45 14             	lea    0x14(%ebp),%eax
  80070c:	e8 bd fc ff ff       	call   8003ce <getuint>
  800711:	89 c6                	mov    %eax,%esi
  800713:	89 d7                	mov    %edx,%edi
			base = 10;
  800715:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80071a:	eb 78                	jmp    800794 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80071c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800720:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800727:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  80072a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072e:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800735:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800738:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80073c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800743:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800746:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800749:	e9 1f fd ff ff       	jmp    80046d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  80074e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800752:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800759:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80075c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800760:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800767:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8d 50 04             	lea    0x4(%eax),%edx
  800770:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800773:	8b 30                	mov    (%eax),%esi
  800775:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80077a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80077f:	eb 13                	jmp    800794 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800781:	89 ca                	mov    %ecx,%edx
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
  800786:	e8 43 fc ff ff       	call   8003ce <getuint>
  80078b:	89 c6                	mov    %eax,%esi
  80078d:	89 d7                	mov    %edx,%edi
			base = 16;
  80078f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800794:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800798:	89 54 24 10          	mov    %edx,0x10(%esp)
  80079c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80079f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007a3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a7:	89 34 24             	mov    %esi,(%esp)
  8007aa:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007ae:	89 da                	mov    %ebx,%edx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	e8 4c fb ff ff       	call   800304 <printnum>
			break;
  8007b8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007bb:	e9 ad fc ff ff       	jmp    80046d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c4:	89 04 24             	mov    %eax,(%esp)
  8007c7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ca:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007cd:	e9 9b fc ff ff       	jmp    80046d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007d6:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007dd:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e0:	eb 01                	jmp    8007e3 <vprintfmt+0x399>
  8007e2:	4e                   	dec    %esi
  8007e3:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007e7:	75 f9                	jne    8007e2 <vprintfmt+0x398>
  8007e9:	e9 7f fc ff ff       	jmp    80046d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007ee:	83 c4 4c             	add    $0x4c,%esp
  8007f1:	5b                   	pop    %ebx
  8007f2:	5e                   	pop    %esi
  8007f3:	5f                   	pop    %edi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	83 ec 28             	sub    $0x28,%esp
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800802:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800805:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800809:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80080c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800813:	85 c0                	test   %eax,%eax
  800815:	74 30                	je     800847 <vsnprintf+0x51>
  800817:	85 d2                	test   %edx,%edx
  800819:	7e 33                	jle    80084e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081b:	8b 45 14             	mov    0x14(%ebp),%eax
  80081e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800822:	8b 45 10             	mov    0x10(%ebp),%eax
  800825:	89 44 24 08          	mov    %eax,0x8(%esp)
  800829:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800830:	c7 04 24 08 04 80 00 	movl   $0x800408,(%esp)
  800837:	e8 0e fc ff ff       	call   80044a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800845:	eb 0c                	jmp    800853 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800847:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084c:	eb 05                	jmp    800853 <vsnprintf+0x5d>
  80084e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800853:	c9                   	leave  
  800854:	c3                   	ret    

00800855 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80085b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80085e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800862:	8b 45 10             	mov    0x10(%ebp),%eax
  800865:	89 44 24 08          	mov    %eax,0x8(%esp)
  800869:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800870:	8b 45 08             	mov    0x8(%ebp),%eax
  800873:	89 04 24             	mov    %eax,(%esp)
  800876:	e8 7b ff ff ff       	call   8007f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087b:	c9                   	leave  
  80087c:	c3                   	ret    
  80087d:	00 00                	add    %al,(%eax)
	...

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	eb 01                	jmp    80088e <strlen+0xe>
		n++;
  80088d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800892:	75 f9                	jne    80088d <strlen+0xd>
		n++;
	return n;
}
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a4:	eb 01                	jmp    8008a7 <strnlen+0x11>
		n++;
  8008a6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	39 d0                	cmp    %edx,%eax
  8008a9:	74 06                	je     8008b1 <strnlen+0x1b>
  8008ab:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008af:	75 f5                	jne    8008a6 <strnlen+0x10>
		n++;
	return n;
}
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    

008008b3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b3:	55                   	push   %ebp
  8008b4:	89 e5                	mov    %esp,%ebp
  8008b6:	53                   	push   %ebx
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008c2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008c5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c8:	42                   	inc    %edx
  8008c9:	84 c9                	test   %cl,%cl
  8008cb:	75 f5                	jne    8008c2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008cd:	5b                   	pop    %ebx
  8008ce:	5d                   	pop    %ebp
  8008cf:	c3                   	ret    

008008d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d0:	55                   	push   %ebp
  8008d1:	89 e5                	mov    %esp,%ebp
  8008d3:	53                   	push   %ebx
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008da:	89 1c 24             	mov    %ebx,(%esp)
  8008dd:	e8 9e ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  8008e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e9:	01 d8                	add    %ebx,%eax
  8008eb:	89 04 24             	mov    %eax,(%esp)
  8008ee:	e8 c0 ff ff ff       	call   8008b3 <strcpy>
	return dst;
}
  8008f3:	89 d8                	mov    %ebx,%eax
  8008f5:	83 c4 08             	add    $0x8,%esp
  8008f8:	5b                   	pop    %ebx
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	8b 55 0c             	mov    0xc(%ebp),%edx
  800906:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090e:	eb 0c                	jmp    80091c <strncpy+0x21>
		*dst++ = *src;
  800910:	8a 1a                	mov    (%edx),%bl
  800912:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800915:	80 3a 01             	cmpb   $0x1,(%edx)
  800918:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091b:	41                   	inc    %ecx
  80091c:	39 f1                	cmp    %esi,%ecx
  80091e:	75 f0                	jne    800910 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800932:	85 d2                	test   %edx,%edx
  800934:	75 0a                	jne    800940 <strlcpy+0x1c>
  800936:	89 f0                	mov    %esi,%eax
  800938:	eb 1a                	jmp    800954 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80093a:	88 18                	mov    %bl,(%eax)
  80093c:	40                   	inc    %eax
  80093d:	41                   	inc    %ecx
  80093e:	eb 02                	jmp    800942 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800940:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800942:	4a                   	dec    %edx
  800943:	74 0a                	je     80094f <strlcpy+0x2b>
  800945:	8a 19                	mov    (%ecx),%bl
  800947:	84 db                	test   %bl,%bl
  800949:	75 ef                	jne    80093a <strlcpy+0x16>
  80094b:	89 c2                	mov    %eax,%edx
  80094d:	eb 02                	jmp    800951 <strlcpy+0x2d>
  80094f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800951:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800954:	29 f0                	sub    %esi,%eax
}
  800956:	5b                   	pop    %ebx
  800957:	5e                   	pop    %esi
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800960:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800963:	eb 02                	jmp    800967 <strcmp+0xd>
		p++, q++;
  800965:	41                   	inc    %ecx
  800966:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800967:	8a 01                	mov    (%ecx),%al
  800969:	84 c0                	test   %al,%al
  80096b:	74 04                	je     800971 <strcmp+0x17>
  80096d:	3a 02                	cmp    (%edx),%al
  80096f:	74 f4                	je     800965 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800971:	0f b6 c0             	movzbl %al,%eax
  800974:	0f b6 12             	movzbl (%edx),%edx
  800977:	29 d0                	sub    %edx,%eax
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800985:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800988:	eb 03                	jmp    80098d <strncmp+0x12>
		n--, p++, q++;
  80098a:	4a                   	dec    %edx
  80098b:	40                   	inc    %eax
  80098c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098d:	85 d2                	test   %edx,%edx
  80098f:	74 14                	je     8009a5 <strncmp+0x2a>
  800991:	8a 18                	mov    (%eax),%bl
  800993:	84 db                	test   %bl,%bl
  800995:	74 04                	je     80099b <strncmp+0x20>
  800997:	3a 19                	cmp    (%ecx),%bl
  800999:	74 ef                	je     80098a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80099b:	0f b6 00             	movzbl (%eax),%eax
  80099e:	0f b6 11             	movzbl (%ecx),%edx
  8009a1:	29 d0                	sub    %edx,%eax
  8009a3:	eb 05                	jmp    8009aa <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009aa:	5b                   	pop    %ebx
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009b6:	eb 05                	jmp    8009bd <strchr+0x10>
		if (*s == c)
  8009b8:	38 ca                	cmp    %cl,%dl
  8009ba:	74 0c                	je     8009c8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009bc:	40                   	inc    %eax
  8009bd:	8a 10                	mov    (%eax),%dl
  8009bf:	84 d2                	test   %dl,%dl
  8009c1:	75 f5                	jne    8009b8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009d3:	eb 05                	jmp    8009da <strfind+0x10>
		if (*s == c)
  8009d5:	38 ca                	cmp    %cl,%dl
  8009d7:	74 07                	je     8009e0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009d9:	40                   	inc    %eax
  8009da:	8a 10                	mov    (%eax),%dl
  8009dc:	84 d2                	test   %dl,%dl
  8009de:	75 f5                	jne    8009d5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e0:	5d                   	pop    %ebp
  8009e1:	c3                   	ret    

008009e2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	57                   	push   %edi
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f1:	85 c9                	test   %ecx,%ecx
  8009f3:	74 30                	je     800a25 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fb:	75 25                	jne    800a22 <memset+0x40>
  8009fd:	f6 c1 03             	test   $0x3,%cl
  800a00:	75 20                	jne    800a22 <memset+0x40>
		c &= 0xFF;
  800a02:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a05:	89 d3                	mov    %edx,%ebx
  800a07:	c1 e3 08             	shl    $0x8,%ebx
  800a0a:	89 d6                	mov    %edx,%esi
  800a0c:	c1 e6 18             	shl    $0x18,%esi
  800a0f:	89 d0                	mov    %edx,%eax
  800a11:	c1 e0 10             	shl    $0x10,%eax
  800a14:	09 f0                	or     %esi,%eax
  800a16:	09 d0                	or     %edx,%eax
  800a18:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a1a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a1d:	fc                   	cld    
  800a1e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a20:	eb 03                	jmp    800a25 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a22:	fc                   	cld    
  800a23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a25:	89 f8                	mov    %edi,%eax
  800a27:	5b                   	pop    %ebx
  800a28:	5e                   	pop    %esi
  800a29:	5f                   	pop    %edi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	57                   	push   %edi
  800a30:	56                   	push   %esi
  800a31:	8b 45 08             	mov    0x8(%ebp),%eax
  800a34:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a3a:	39 c6                	cmp    %eax,%esi
  800a3c:	73 34                	jae    800a72 <memmove+0x46>
  800a3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a41:	39 d0                	cmp    %edx,%eax
  800a43:	73 2d                	jae    800a72 <memmove+0x46>
		s += n;
		d += n;
  800a45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a48:	f6 c2 03             	test   $0x3,%dl
  800a4b:	75 1b                	jne    800a68 <memmove+0x3c>
  800a4d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a53:	75 13                	jne    800a68 <memmove+0x3c>
  800a55:	f6 c1 03             	test   $0x3,%cl
  800a58:	75 0e                	jne    800a68 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a5a:	83 ef 04             	sub    $0x4,%edi
  800a5d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a60:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a63:	fd                   	std    
  800a64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a66:	eb 07                	jmp    800a6f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a68:	4f                   	dec    %edi
  800a69:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a6c:	fd                   	std    
  800a6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a6f:	fc                   	cld    
  800a70:	eb 20                	jmp    800a92 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a72:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a78:	75 13                	jne    800a8d <memmove+0x61>
  800a7a:	a8 03                	test   $0x3,%al
  800a7c:	75 0f                	jne    800a8d <memmove+0x61>
  800a7e:	f6 c1 03             	test   $0x3,%cl
  800a81:	75 0a                	jne    800a8d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a83:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a86:	89 c7                	mov    %eax,%edi
  800a88:	fc                   	cld    
  800a89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a8b:	eb 05                	jmp    800a92 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a8d:	89 c7                	mov    %eax,%edi
  800a8f:	fc                   	cld    
  800a90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a92:	5e                   	pop    %esi
  800a93:	5f                   	pop    %edi
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	89 04 24             	mov    %eax,(%esp)
  800ab0:	e8 77 ff ff ff       	call   800a2c <memmove>
}
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    

00800ab7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ab7:	55                   	push   %ebp
  800ab8:	89 e5                	mov    %esp,%ebp
  800aba:	57                   	push   %edi
  800abb:	56                   	push   %esi
  800abc:	53                   	push   %ebx
  800abd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac6:	ba 00 00 00 00       	mov    $0x0,%edx
  800acb:	eb 16                	jmp    800ae3 <memcmp+0x2c>
		if (*s1 != *s2)
  800acd:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ad0:	42                   	inc    %edx
  800ad1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800ad5:	38 c8                	cmp    %cl,%al
  800ad7:	74 0a                	je     800ae3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ad9:	0f b6 c0             	movzbl %al,%eax
  800adc:	0f b6 c9             	movzbl %cl,%ecx
  800adf:	29 c8                	sub    %ecx,%eax
  800ae1:	eb 09                	jmp    800aec <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae3:	39 da                	cmp    %ebx,%edx
  800ae5:	75 e6                	jne    800acd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aec:	5b                   	pop    %ebx
  800aed:	5e                   	pop    %esi
  800aee:	5f                   	pop    %edi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800afa:	89 c2                	mov    %eax,%edx
  800afc:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aff:	eb 05                	jmp    800b06 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b01:	38 08                	cmp    %cl,(%eax)
  800b03:	74 05                	je     800b0a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b05:	40                   	inc    %eax
  800b06:	39 d0                	cmp    %edx,%eax
  800b08:	72 f7                	jb     800b01 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b0a:	5d                   	pop    %ebp
  800b0b:	c3                   	ret    

00800b0c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0c:	55                   	push   %ebp
  800b0d:	89 e5                	mov    %esp,%ebp
  800b0f:	57                   	push   %edi
  800b10:	56                   	push   %esi
  800b11:	53                   	push   %ebx
  800b12:	8b 55 08             	mov    0x8(%ebp),%edx
  800b15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b18:	eb 01                	jmp    800b1b <strtol+0xf>
		s++;
  800b1a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1b:	8a 02                	mov    (%edx),%al
  800b1d:	3c 20                	cmp    $0x20,%al
  800b1f:	74 f9                	je     800b1a <strtol+0xe>
  800b21:	3c 09                	cmp    $0x9,%al
  800b23:	74 f5                	je     800b1a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b25:	3c 2b                	cmp    $0x2b,%al
  800b27:	75 08                	jne    800b31 <strtol+0x25>
		s++;
  800b29:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b2a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b2f:	eb 13                	jmp    800b44 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b31:	3c 2d                	cmp    $0x2d,%al
  800b33:	75 0a                	jne    800b3f <strtol+0x33>
		s++, neg = 1;
  800b35:	8d 52 01             	lea    0x1(%edx),%edx
  800b38:	bf 01 00 00 00       	mov    $0x1,%edi
  800b3d:	eb 05                	jmp    800b44 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b44:	85 db                	test   %ebx,%ebx
  800b46:	74 05                	je     800b4d <strtol+0x41>
  800b48:	83 fb 10             	cmp    $0x10,%ebx
  800b4b:	75 28                	jne    800b75 <strtol+0x69>
  800b4d:	8a 02                	mov    (%edx),%al
  800b4f:	3c 30                	cmp    $0x30,%al
  800b51:	75 10                	jne    800b63 <strtol+0x57>
  800b53:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b57:	75 0a                	jne    800b63 <strtol+0x57>
		s += 2, base = 16;
  800b59:	83 c2 02             	add    $0x2,%edx
  800b5c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b61:	eb 12                	jmp    800b75 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	75 0e                	jne    800b75 <strtol+0x69>
  800b67:	3c 30                	cmp    $0x30,%al
  800b69:	75 05                	jne    800b70 <strtol+0x64>
		s++, base = 8;
  800b6b:	42                   	inc    %edx
  800b6c:	b3 08                	mov    $0x8,%bl
  800b6e:	eb 05                	jmp    800b75 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b70:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b75:	b8 00 00 00 00       	mov    $0x0,%eax
  800b7a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b7c:	8a 0a                	mov    (%edx),%cl
  800b7e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b81:	80 fb 09             	cmp    $0x9,%bl
  800b84:	77 08                	ja     800b8e <strtol+0x82>
			dig = *s - '0';
  800b86:	0f be c9             	movsbl %cl,%ecx
  800b89:	83 e9 30             	sub    $0x30,%ecx
  800b8c:	eb 1e                	jmp    800bac <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b8e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b91:	80 fb 19             	cmp    $0x19,%bl
  800b94:	77 08                	ja     800b9e <strtol+0x92>
			dig = *s - 'a' + 10;
  800b96:	0f be c9             	movsbl %cl,%ecx
  800b99:	83 e9 57             	sub    $0x57,%ecx
  800b9c:	eb 0e                	jmp    800bac <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800b9e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ba1:	80 fb 19             	cmp    $0x19,%bl
  800ba4:	77 12                	ja     800bb8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ba6:	0f be c9             	movsbl %cl,%ecx
  800ba9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bac:	39 f1                	cmp    %esi,%ecx
  800bae:	7d 0c                	jge    800bbc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bb0:	42                   	inc    %edx
  800bb1:	0f af c6             	imul   %esi,%eax
  800bb4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bb6:	eb c4                	jmp    800b7c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bb8:	89 c1                	mov    %eax,%ecx
  800bba:	eb 02                	jmp    800bbe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bbc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc2:	74 05                	je     800bc9 <strtol+0xbd>
		*endptr = (char *) s;
  800bc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bc7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bc9:	85 ff                	test   %edi,%edi
  800bcb:	74 04                	je     800bd1 <strtol+0xc5>
  800bcd:	89 c8                	mov    %ecx,%eax
  800bcf:	f7 d8                	neg    %eax
}
  800bd1:	5b                   	pop    %ebx
  800bd2:	5e                   	pop    %esi
  800bd3:	5f                   	pop    %edi
  800bd4:	5d                   	pop    %ebp
  800bd5:	c3                   	ret    
	...

00800bd8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	57                   	push   %edi
  800bdc:	56                   	push   %esi
  800bdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	8b 55 08             	mov    0x8(%ebp),%edx
  800be9:	89 c3                	mov    %eax,%ebx
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	89 c6                	mov    %eax,%esi
  800bef:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf1:	5b                   	pop    %ebx
  800bf2:	5e                   	pop    %esi
  800bf3:	5f                   	pop    %edi
  800bf4:	5d                   	pop    %ebp
  800bf5:	c3                   	ret    

00800bf6 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
  800c01:	b8 01 00 00 00       	mov    $0x1,%eax
  800c06:	89 d1                	mov    %edx,%ecx
  800c08:	89 d3                	mov    %edx,%ebx
  800c0a:	89 d7                	mov    %edx,%edi
  800c0c:	89 d6                	mov    %edx,%esi
  800c0e:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800c1e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c23:	b8 03 00 00 00       	mov    $0x3,%eax
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	89 cb                	mov    %ecx,%ebx
  800c2d:	89 cf                	mov    %ecx,%edi
  800c2f:	89 ce                	mov    %ecx,%esi
  800c31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7e 28                	jle    800c5f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c3b:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c42:	00 
  800c43:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c52:	00 
  800c53:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800c5a:	e8 7d 07 00 00       	call   8013dc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c5f:	83 c4 2c             	add    $0x2c,%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    

00800c67 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	57                   	push   %edi
  800c6b:	56                   	push   %esi
  800c6c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	b8 02 00 00 00       	mov    $0x2,%eax
  800c77:	89 d1                	mov    %edx,%ecx
  800c79:	89 d3                	mov    %edx,%ebx
  800c7b:	89 d7                	mov    %edx,%edi
  800c7d:	89 d6                	mov    %edx,%esi
  800c7f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c81:	5b                   	pop    %ebx
  800c82:	5e                   	pop    %esi
  800c83:	5f                   	pop    %edi
  800c84:	5d                   	pop    %ebp
  800c85:	c3                   	ret    

00800c86 <sys_yield>:

void
sys_yield(void)
{
  800c86:	55                   	push   %ebp
  800c87:	89 e5                	mov    %esp,%ebp
  800c89:	57                   	push   %edi
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	89 d3                	mov    %edx,%ebx
  800c9a:	89 d7                	mov    %edx,%edi
  800c9c:	89 d6                	mov    %edx,%esi
  800c9e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	be 00 00 00 00       	mov    $0x0,%esi
  800cb3:	b8 04 00 00 00       	mov    $0x4,%eax
  800cb8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc1:	89 f7                	mov    %esi,%edi
  800cc3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 28                	jle    800cf1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccd:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cd4:	00 
  800cd5:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800cdc:	00 
  800cdd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce4:	00 
  800ce5:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800cec:	e8 eb 06 00 00       	call   8013dc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf1:	83 c4 2c             	add    $0x2c,%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5f                   	pop    %edi
  800cf7:	5d                   	pop    %ebp
  800cf8:	c3                   	ret    

00800cf9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	b8 05 00 00 00       	mov    $0x5,%eax
  800d07:	8b 75 18             	mov    0x18(%ebp),%esi
  800d0a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d13:	8b 55 08             	mov    0x8(%ebp),%edx
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 28                	jle    800d44 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d20:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d27:	00 
  800d28:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800d2f:	00 
  800d30:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d37:	00 
  800d38:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800d3f:	e8 98 06 00 00       	call   8013dc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d44:	83 c4 2c             	add    $0x2c,%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
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
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 06 00 00 00       	mov    $0x6,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 28                	jle    800d97 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d73:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800d82:	00 
  800d83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8a:	00 
  800d8b:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800d92:	e8 45 06 00 00       	call   8013dc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d97:	83 c4 2c             	add    $0x2c,%esp
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dad:	b8 08 00 00 00       	mov    $0x8,%eax
  800db2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db5:	8b 55 08             	mov    0x8(%ebp),%edx
  800db8:	89 df                	mov    %ebx,%edi
  800dba:	89 de                	mov    %ebx,%esi
  800dbc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	7e 28                	jle    800dea <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc6:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dcd:	00 
  800dce:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ddd:	00 
  800dde:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800de5:	e8 f2 05 00 00       	call   8013dc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dea:	83 c4 2c             	add    $0x2c,%esp
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e00:	b8 09 00 00 00       	mov    $0x9,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	89 df                	mov    %ebx,%edi
  800e0d:	89 de                	mov    %ebx,%esi
  800e0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e11:	85 c0                	test   %eax,%eax
  800e13:	7e 28                	jle    800e3d <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e15:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e19:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e20:	00 
  800e21:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800e28:	00 
  800e29:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e30:	00 
  800e31:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800e38:	e8 9f 05 00 00       	call   8013dc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3d:	83 c4 2c             	add    $0x2c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	be 00 00 00 00       	mov    $0x0,%esi
  800e50:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e58:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e76:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 cb                	mov    %ecx,%ebx
  800e80:	89 cf                	mov    %ecx,%edi
  800e82:	89 ce                	mov    %ecx,%esi
  800e84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7e 28                	jle    800eb2 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8e:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800e95:	00 
  800e96:	c7 44 24 08 64 1a 80 	movl   $0x801a64,0x8(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea5:	00 
  800ea6:	c7 04 24 81 1a 80 00 	movl   $0x801a81,(%esp)
  800ead:	e8 2a 05 00 00       	call   8013dc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb2:	83 c4 2c             	add    $0x2c,%esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    
	...

00800ebc <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 24             	sub    $0x24,%esp
  800ec3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ec6:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800ec8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ecc:	75 20                	jne    800eee <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800ece:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ed2:	c7 44 24 08 90 1a 80 	movl   $0x801a90,0x8(%esp)
  800ed9:	00 
  800eda:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800ee1:	00 
  800ee2:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  800ee9:	e8 ee 04 00 00       	call   8013dc <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800eee:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800ef4:	89 d8                	mov    %ebx,%eax
  800ef6:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800ef9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f00:	f6 c4 08             	test   $0x8,%ah
  800f03:	75 1c                	jne    800f21 <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f05:	c7 44 24 08 c0 1a 80 	movl   $0x801ac0,0x8(%esp)
  800f0c:	00 
  800f0d:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800f14:	00 
  800f15:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  800f1c:	e8 bb 04 00 00       	call   8013dc <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800f21:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f28:	00 
  800f29:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f30:	00 
  800f31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f38:	e8 68 fd ff ff       	call   800ca5 <sys_page_alloc>
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	79 20                	jns    800f61 <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800f41:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800f45:	c7 44 24 08 1a 1b 80 	movl   $0x801b1a,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  800f5c:	e8 7b 04 00 00       	call   8013dc <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800f61:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800f68:	00 
  800f69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800f6d:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800f74:	e8 b3 fa ff ff       	call   800a2c <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800f79:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800f80:	00 
  800f81:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9c:	e8 58 fd ff ff       	call   800cf9 <sys_page_map>
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	79 20                	jns    800fc5 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  800fa5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fa9:	c7 44 24 08 2d 1b 80 	movl   $0x801b2d,0x8(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  800fb8:	00 
  800fb9:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  800fc0:	e8 17 04 00 00       	call   8013dc <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  800fc5:	83 c4 24             	add    $0x24,%esp
  800fc8:	5b                   	pop    %ebx
  800fc9:	5d                   	pop    %ebp
  800fca:	c3                   	ret    

00800fcb <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fcb:	55                   	push   %ebp
  800fcc:	89 e5                	mov    %esp,%ebp
  800fce:	57                   	push   %edi
  800fcf:	56                   	push   %esi
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  800fd4:	c7 04 24 bc 0e 80 00 	movl   $0x800ebc,(%esp)
  800fdb:	e8 54 04 00 00       	call   801434 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fe0:	ba 07 00 00 00       	mov    $0x7,%edx
  800fe5:	89 d0                	mov    %edx,%eax
  800fe7:	cd 30                	int    $0x30
  800fe9:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800fec:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  800fef:	85 c0                	test   %eax,%eax
  800ff1:	79 20                	jns    801013 <fork+0x48>
		panic("sys_exofork: %e", envid);
  800ff3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ff7:	c7 44 24 08 3e 1b 80 	movl   $0x801b3e,0x8(%esp)
  800ffe:	00 
  800fff:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801006:	00 
  801007:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  80100e:	e8 c9 03 00 00       	call   8013dc <_panic>
	}
	
	// Child process
	if (envid == 0) {
  801013:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801017:	75 25                	jne    80103e <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  801019:	e8 49 fc ff ff       	call   800c67 <sys_getenvid>
  80101e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801023:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80102a:	c1 e0 07             	shl    $0x7,%eax
  80102d:	29 d0                	sub    %edx,%eax
  80102f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801034:	a3 0c 20 80 00       	mov    %eax,0x80200c
		return 0;
  801039:	e9 58 02 00 00       	jmp    801296 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  80103e:	bf 00 00 00 00       	mov    $0x0,%edi
  801043:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  801048:	89 f0                	mov    %esi,%eax
  80104a:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  80104d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801054:	a8 01                	test   $0x1,%al
  801056:	0f 84 7a 01 00 00    	je     8011d6 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  80105c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  801063:	a8 01                	test   $0x1,%al
  801065:	0f 84 6b 01 00 00    	je     8011d6 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  80106b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801070:	8b 40 48             	mov    0x48(%eax),%eax
  801073:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  801076:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80107d:	f6 c4 04             	test   $0x4,%ah
  801080:	74 52                	je     8010d4 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801082:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801089:	25 07 0e 00 00       	and    $0xe07,%eax
  80108e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801092:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801096:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801099:	89 44 24 08          	mov    %eax,0x8(%esp)
  80109d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010a1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010a4:	89 04 24             	mov    %eax,(%esp)
  8010a7:	e8 4d fc ff ff       	call   800cf9 <sys_page_map>
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	0f 89 22 01 00 00    	jns    8011d6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8010b4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010b8:	c7 44 24 08 4e 1b 80 	movl   $0x801b4e,0x8(%esp)
  8010bf:	00 
  8010c0:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8010c7:	00 
  8010c8:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  8010cf:	e8 08 03 00 00       	call   8013dc <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  8010d4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010db:	f6 c4 08             	test   $0x8,%ah
  8010de:	75 0f                	jne    8010ef <fork+0x124>
  8010e0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e7:	a8 02                	test   $0x2,%al
  8010e9:	0f 84 99 00 00 00    	je     801188 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  8010ef:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f6:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  8010f9:	83 f8 01             	cmp    $0x1,%eax
  8010fc:	19 db                	sbb    %ebx,%ebx
  8010fe:	83 e3 fc             	and    $0xfffffffc,%ebx
  801101:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801107:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80110b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80110f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801112:	89 44 24 08          	mov    %eax,0x8(%esp)
  801116:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80111a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80111d:	89 04 24             	mov    %eax,(%esp)
  801120:	e8 d4 fb ff ff       	call   800cf9 <sys_page_map>
  801125:	85 c0                	test   %eax,%eax
  801127:	79 20                	jns    801149 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801129:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80112d:	c7 44 24 08 4e 1b 80 	movl   $0x801b4e,0x8(%esp)
  801134:	00 
  801135:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  80113c:	00 
  80113d:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  801144:	e8 93 02 00 00       	call   8013dc <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  801149:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  80114d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801151:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801154:	89 44 24 08          	mov    %eax,0x8(%esp)
  801158:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80115c:	89 04 24             	mov    %eax,(%esp)
  80115f:	e8 95 fb ff ff       	call   800cf9 <sys_page_map>
  801164:	85 c0                	test   %eax,%eax
  801166:	79 6e                	jns    8011d6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801168:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80116c:	c7 44 24 08 4e 1b 80 	movl   $0x801b4e,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  801183:	e8 54 02 00 00       	call   8013dc <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  801188:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80118f:	25 07 0e 00 00       	and    $0xe07,%eax
  801194:	89 44 24 10          	mov    %eax,0x10(%esp)
  801198:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80119c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80119f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011a3:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011aa:	89 04 24             	mov    %eax,(%esp)
  8011ad:	e8 47 fb ff ff       	call   800cf9 <sys_page_map>
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	79 20                	jns    8011d6 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ba:	c7 44 24 08 4e 1b 80 	movl   $0x801b4e,0x8(%esp)
  8011c1:	00 
  8011c2:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  8011c9:	00 
  8011ca:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  8011d1:	e8 06 02 00 00       	call   8013dc <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  8011d6:	46                   	inc    %esi
  8011d7:	81 c7 00 10 00 00    	add    $0x1000,%edi
  8011dd:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  8011e3:	0f 85 5f fe ff ff    	jne    801048 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  8011e9:	c7 44 24 04 d4 14 80 	movl   $0x8014d4,0x4(%esp)
  8011f0:	00 
  8011f1:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011f4:	89 04 24             	mov    %eax,(%esp)
  8011f7:	e8 f6 fb ff ff       	call   800df2 <sys_env_set_pgfault_upcall>
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	79 20                	jns    801220 <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  801200:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801204:	c7 44 24 08 f0 1a 80 	movl   $0x801af0,0x8(%esp)
  80120b:	00 
  80120c:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  801213:	00 
  801214:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  80121b:	e8 bc 01 00 00       	call   8013dc <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  801220:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801227:	00 
  801228:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80122f:	ee 
  801230:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801233:	89 04 24             	mov    %eax,(%esp)
  801236:	e8 6a fa ff ff       	call   800ca5 <sys_page_alloc>
  80123b:	85 c0                	test   %eax,%eax
  80123d:	79 20                	jns    80125f <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80123f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801243:	c7 44 24 08 1a 1b 80 	movl   $0x801b1a,0x8(%esp)
  80124a:	00 
  80124b:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  801252:	00 
  801253:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  80125a:	e8 7d 01 00 00       	call   8013dc <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  80125f:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  801266:	00 
  801267:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80126a:	89 04 24             	mov    %eax,(%esp)
  80126d:	e8 2d fb ff ff       	call   800d9f <sys_env_set_status>
  801272:	85 c0                	test   %eax,%eax
  801274:	79 20                	jns    801296 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  801276:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80127a:	c7 44 24 08 60 1b 80 	movl   $0x801b60,0x8(%esp)
  801281:	00 
  801282:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  801289:	00 
  80128a:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  801291:	e8 46 01 00 00       	call   8013dc <_panic>
	}
	
	return envid;
}
  801296:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801299:	83 c4 3c             	add    $0x3c,%esp
  80129c:	5b                   	pop    %ebx
  80129d:	5e                   	pop    %esi
  80129e:	5f                   	pop    %edi
  80129f:	5d                   	pop    %ebp
  8012a0:	c3                   	ret    

008012a1 <sfork>:

// Challenge!
int
sfork(void)
{
  8012a1:	55                   	push   %ebp
  8012a2:	89 e5                	mov    %esp,%ebp
  8012a4:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8012a7:	c7 44 24 08 77 1b 80 	movl   $0x801b77,0x8(%esp)
  8012ae:	00 
  8012af:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  8012b6:	00 
  8012b7:	c7 04 24 0f 1b 80 00 	movl   $0x801b0f,(%esp)
  8012be:	e8 19 01 00 00       	call   8013dc <_panic>
	...

008012c4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	56                   	push   %esi
  8012c8:	53                   	push   %ebx
  8012c9:	83 ec 10             	sub    $0x10,%esp
  8012cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	75 05                	jne    8012de <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8012d9:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8012de:	89 04 24             	mov    %eax,(%esp)
  8012e1:	e8 82 fb ff ff       	call   800e68 <sys_ipc_recv>
	if (!err) {
  8012e6:	85 c0                	test   %eax,%eax
  8012e8:	75 26                	jne    801310 <ipc_recv+0x4c>
		if (from_env_store) {
  8012ea:	85 f6                	test   %esi,%esi
  8012ec:	74 0a                	je     8012f8 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8012ee:	a1 0c 20 80 00       	mov    0x80200c,%eax
  8012f3:	8b 40 74             	mov    0x74(%eax),%eax
  8012f6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8012f8:	85 db                	test   %ebx,%ebx
  8012fa:	74 0a                	je     801306 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8012fc:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801301:	8b 40 78             	mov    0x78(%eax),%eax
  801304:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801306:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80130b:	8b 40 70             	mov    0x70(%eax),%eax
  80130e:	eb 14                	jmp    801324 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801310:	85 f6                	test   %esi,%esi
  801312:	74 06                	je     80131a <ipc_recv+0x56>
		*from_env_store = 0;
  801314:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  80131a:	85 db                	test   %ebx,%ebx
  80131c:	74 06                	je     801324 <ipc_recv+0x60>
		*perm_store = 0;
  80131e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	5b                   	pop    %ebx
  801328:	5e                   	pop    %esi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    

0080132b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	57                   	push   %edi
  80132f:	56                   	push   %esi
  801330:	53                   	push   %ebx
  801331:	83 ec 1c             	sub    $0x1c,%esp
  801334:	8b 75 10             	mov    0x10(%ebp),%esi
  801337:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  80133a:	85 f6                	test   %esi,%esi
  80133c:	75 05                	jne    801343 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  80133e:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801343:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801347:	89 74 24 08          	mov    %esi,0x8(%esp)
  80134b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801352:	8b 45 08             	mov    0x8(%ebp),%eax
  801355:	89 04 24             	mov    %eax,(%esp)
  801358:	e8 e8 fa ff ff       	call   800e45 <sys_ipc_try_send>
  80135d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  80135f:	e8 22 f9 ff ff       	call   800c86 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801364:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801367:	74 da                	je     801343 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801369:	85 db                	test   %ebx,%ebx
  80136b:	74 20                	je     80138d <ipc_send+0x62>
		panic("send fail: %e", err);
  80136d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801371:	c7 44 24 08 8d 1b 80 	movl   $0x801b8d,0x8(%esp)
  801378:	00 
  801379:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801380:	00 
  801381:	c7 04 24 9b 1b 80 00 	movl   $0x801b9b,(%esp)
  801388:	e8 4f 00 00 00       	call   8013dc <_panic>
	}
	return;
}
  80138d:	83 c4 1c             	add    $0x1c,%esp
  801390:	5b                   	pop    %ebx
  801391:	5e                   	pop    %esi
  801392:	5f                   	pop    %edi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	53                   	push   %ebx
  801399:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  80139c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013a1:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  8013a8:	89 c2                	mov    %eax,%edx
  8013aa:	c1 e2 07             	shl    $0x7,%edx
  8013ad:	29 ca                	sub    %ecx,%edx
  8013af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013b5:	8b 52 50             	mov    0x50(%edx),%edx
  8013b8:	39 da                	cmp    %ebx,%edx
  8013ba:	75 0f                	jne    8013cb <ipc_find_env+0x36>
			return envs[i].env_id;
  8013bc:	c1 e0 07             	shl    $0x7,%eax
  8013bf:	29 c8                	sub    %ecx,%eax
  8013c1:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  8013c6:	8b 40 40             	mov    0x40(%eax),%eax
  8013c9:	eb 0c                	jmp    8013d7 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013cb:	40                   	inc    %eax
  8013cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013d1:	75 ce                	jne    8013a1 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013d3:	66 b8 00 00          	mov    $0x0,%ax
}
  8013d7:	5b                   	pop    %ebx
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    
	...

008013dc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8013e4:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8013e7:	8b 1d 08 20 80 00    	mov    0x802008,%ebx
  8013ed:	e8 75 f8 ff ff       	call   800c67 <sys_getenvid>
  8013f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8013f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8013fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801400:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801404:	89 44 24 04          	mov    %eax,0x4(%esp)
  801408:	c7 04 24 a8 1b 80 00 	movl   $0x801ba8,(%esp)
  80140f:	e8 d4 ee ff ff       	call   8002e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801414:	89 74 24 04          	mov    %esi,0x4(%esp)
  801418:	8b 45 10             	mov    0x10(%ebp),%eax
  80141b:	89 04 24             	mov    %eax,(%esp)
  80141e:	e8 64 ee ff ff       	call   800287 <vcprintf>
	cprintf("\n");
  801423:	c7 04 24 5e 1b 80 00 	movl   $0x801b5e,(%esp)
  80142a:	e8 b9 ee ff ff       	call   8002e8 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80142f:	cc                   	int3   
  801430:	eb fd                	jmp    80142f <_panic+0x53>
	...

00801434 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80143a:	83 3d 10 20 80 00 00 	cmpl   $0x0,0x802010
  801441:	0f 85 80 00 00 00    	jne    8014c7 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  801447:	a1 0c 20 80 00       	mov    0x80200c,%eax
  80144c:	8b 40 48             	mov    0x48(%eax),%eax
  80144f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801456:	00 
  801457:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80145e:	ee 
  80145f:	89 04 24             	mov    %eax,(%esp)
  801462:	e8 3e f8 ff ff       	call   800ca5 <sys_page_alloc>
  801467:	85 c0                	test   %eax,%eax
  801469:	79 20                	jns    80148b <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80146b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80146f:	c7 44 24 08 cc 1b 80 	movl   $0x801bcc,0x8(%esp)
  801476:	00 
  801477:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80147e:	00 
  80147f:	c7 04 24 28 1c 80 00 	movl   $0x801c28,(%esp)
  801486:	e8 51 ff ff ff       	call   8013dc <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80148b:	a1 0c 20 80 00       	mov    0x80200c,%eax
  801490:	8b 40 48             	mov    0x48(%eax),%eax
  801493:	c7 44 24 04 d4 14 80 	movl   $0x8014d4,0x4(%esp)
  80149a:	00 
  80149b:	89 04 24             	mov    %eax,(%esp)
  80149e:	e8 4f f9 ff ff       	call   800df2 <sys_env_set_pgfault_upcall>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	79 20                	jns    8014c7 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  8014a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014ab:	c7 44 24 08 f8 1b 80 	movl   $0x801bf8,0x8(%esp)
  8014b2:	00 
  8014b3:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  8014ba:	00 
  8014bb:	c7 04 24 28 1c 80 00 	movl   $0x801c28,(%esp)
  8014c2:	e8 15 ff ff ff       	call   8013dc <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8014c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ca:	a3 10 20 80 00       	mov    %eax,0x802010
}
  8014cf:	c9                   	leave  
  8014d0:	c3                   	ret    
  8014d1:	00 00                	add    %al,(%eax)
	...

008014d4 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8014d4:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8014d5:	a1 10 20 80 00       	mov    0x802010,%eax
	call *%eax
  8014da:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8014dc:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8014df:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8014e3:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8014e5:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8014e8:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8014e9:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8014ec:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8014ee:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8014f1:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8014f2:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8014f5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8014f6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8014f7:	c3                   	ret    

008014f8 <__udivdi3>:
  8014f8:	55                   	push   %ebp
  8014f9:	57                   	push   %edi
  8014fa:	56                   	push   %esi
  8014fb:	83 ec 10             	sub    $0x10,%esp
  8014fe:	8b 74 24 20          	mov    0x20(%esp),%esi
  801502:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801506:	89 74 24 04          	mov    %esi,0x4(%esp)
  80150a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80150e:	89 cd                	mov    %ecx,%ebp
  801510:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801514:	85 c0                	test   %eax,%eax
  801516:	75 2c                	jne    801544 <__udivdi3+0x4c>
  801518:	39 f9                	cmp    %edi,%ecx
  80151a:	77 68                	ja     801584 <__udivdi3+0x8c>
  80151c:	85 c9                	test   %ecx,%ecx
  80151e:	75 0b                	jne    80152b <__udivdi3+0x33>
  801520:	b8 01 00 00 00       	mov    $0x1,%eax
  801525:	31 d2                	xor    %edx,%edx
  801527:	f7 f1                	div    %ecx
  801529:	89 c1                	mov    %eax,%ecx
  80152b:	31 d2                	xor    %edx,%edx
  80152d:	89 f8                	mov    %edi,%eax
  80152f:	f7 f1                	div    %ecx
  801531:	89 c7                	mov    %eax,%edi
  801533:	89 f0                	mov    %esi,%eax
  801535:	f7 f1                	div    %ecx
  801537:	89 c6                	mov    %eax,%esi
  801539:	89 f0                	mov    %esi,%eax
  80153b:	89 fa                	mov    %edi,%edx
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	5e                   	pop    %esi
  801541:	5f                   	pop    %edi
  801542:	5d                   	pop    %ebp
  801543:	c3                   	ret    
  801544:	39 f8                	cmp    %edi,%eax
  801546:	77 2c                	ja     801574 <__udivdi3+0x7c>
  801548:	0f bd f0             	bsr    %eax,%esi
  80154b:	83 f6 1f             	xor    $0x1f,%esi
  80154e:	75 4c                	jne    80159c <__udivdi3+0xa4>
  801550:	39 f8                	cmp    %edi,%eax
  801552:	bf 00 00 00 00       	mov    $0x0,%edi
  801557:	72 0a                	jb     801563 <__udivdi3+0x6b>
  801559:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  80155d:	0f 87 ad 00 00 00    	ja     801610 <__udivdi3+0x118>
  801563:	be 01 00 00 00       	mov    $0x1,%esi
  801568:	89 f0                	mov    %esi,%eax
  80156a:	89 fa                	mov    %edi,%edx
  80156c:	83 c4 10             	add    $0x10,%esp
  80156f:	5e                   	pop    %esi
  801570:	5f                   	pop    %edi
  801571:	5d                   	pop    %ebp
  801572:	c3                   	ret    
  801573:	90                   	nop
  801574:	31 ff                	xor    %edi,%edi
  801576:	31 f6                	xor    %esi,%esi
  801578:	89 f0                	mov    %esi,%eax
  80157a:	89 fa                	mov    %edi,%edx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	5e                   	pop    %esi
  801580:	5f                   	pop    %edi
  801581:	5d                   	pop    %ebp
  801582:	c3                   	ret    
  801583:	90                   	nop
  801584:	89 fa                	mov    %edi,%edx
  801586:	89 f0                	mov    %esi,%eax
  801588:	f7 f1                	div    %ecx
  80158a:	89 c6                	mov    %eax,%esi
  80158c:	31 ff                	xor    %edi,%edi
  80158e:	89 f0                	mov    %esi,%eax
  801590:	89 fa                	mov    %edi,%edx
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	5e                   	pop    %esi
  801596:	5f                   	pop    %edi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    
  801599:	8d 76 00             	lea    0x0(%esi),%esi
  80159c:	89 f1                	mov    %esi,%ecx
  80159e:	d3 e0                	shl    %cl,%eax
  8015a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015a4:	b8 20 00 00 00       	mov    $0x20,%eax
  8015a9:	29 f0                	sub    %esi,%eax
  8015ab:	89 ea                	mov    %ebp,%edx
  8015ad:	88 c1                	mov    %al,%cl
  8015af:	d3 ea                	shr    %cl,%edx
  8015b1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8015b5:	09 ca                	or     %ecx,%edx
  8015b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8015bb:	89 f1                	mov    %esi,%ecx
  8015bd:	d3 e5                	shl    %cl,%ebp
  8015bf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8015c3:	89 fd                	mov    %edi,%ebp
  8015c5:	88 c1                	mov    %al,%cl
  8015c7:	d3 ed                	shr    %cl,%ebp
  8015c9:	89 fa                	mov    %edi,%edx
  8015cb:	89 f1                	mov    %esi,%ecx
  8015cd:	d3 e2                	shl    %cl,%edx
  8015cf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8015d3:	88 c1                	mov    %al,%cl
  8015d5:	d3 ef                	shr    %cl,%edi
  8015d7:	09 d7                	or     %edx,%edi
  8015d9:	89 f8                	mov    %edi,%eax
  8015db:	89 ea                	mov    %ebp,%edx
  8015dd:	f7 74 24 08          	divl   0x8(%esp)
  8015e1:	89 d1                	mov    %edx,%ecx
  8015e3:	89 c7                	mov    %eax,%edi
  8015e5:	f7 64 24 0c          	mull   0xc(%esp)
  8015e9:	39 d1                	cmp    %edx,%ecx
  8015eb:	72 17                	jb     801604 <__udivdi3+0x10c>
  8015ed:	74 09                	je     8015f8 <__udivdi3+0x100>
  8015ef:	89 fe                	mov    %edi,%esi
  8015f1:	31 ff                	xor    %edi,%edi
  8015f3:	e9 41 ff ff ff       	jmp    801539 <__udivdi3+0x41>
  8015f8:	8b 54 24 04          	mov    0x4(%esp),%edx
  8015fc:	89 f1                	mov    %esi,%ecx
  8015fe:	d3 e2                	shl    %cl,%edx
  801600:	39 c2                	cmp    %eax,%edx
  801602:	73 eb                	jae    8015ef <__udivdi3+0xf7>
  801604:	8d 77 ff             	lea    -0x1(%edi),%esi
  801607:	31 ff                	xor    %edi,%edi
  801609:	e9 2b ff ff ff       	jmp    801539 <__udivdi3+0x41>
  80160e:	66 90                	xchg   %ax,%ax
  801610:	31 f6                	xor    %esi,%esi
  801612:	e9 22 ff ff ff       	jmp    801539 <__udivdi3+0x41>
	...

00801618 <__umoddi3>:
  801618:	55                   	push   %ebp
  801619:	57                   	push   %edi
  80161a:	56                   	push   %esi
  80161b:	83 ec 20             	sub    $0x20,%esp
  80161e:	8b 44 24 30          	mov    0x30(%esp),%eax
  801622:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801626:	89 44 24 14          	mov    %eax,0x14(%esp)
  80162a:	8b 74 24 34          	mov    0x34(%esp),%esi
  80162e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801632:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801636:	89 c7                	mov    %eax,%edi
  801638:	89 f2                	mov    %esi,%edx
  80163a:	85 ed                	test   %ebp,%ebp
  80163c:	75 16                	jne    801654 <__umoddi3+0x3c>
  80163e:	39 f1                	cmp    %esi,%ecx
  801640:	0f 86 a6 00 00 00    	jbe    8016ec <__umoddi3+0xd4>
  801646:	f7 f1                	div    %ecx
  801648:	89 d0                	mov    %edx,%eax
  80164a:	31 d2                	xor    %edx,%edx
  80164c:	83 c4 20             	add    $0x20,%esp
  80164f:	5e                   	pop    %esi
  801650:	5f                   	pop    %edi
  801651:	5d                   	pop    %ebp
  801652:	c3                   	ret    
  801653:	90                   	nop
  801654:	39 f5                	cmp    %esi,%ebp
  801656:	0f 87 ac 00 00 00    	ja     801708 <__umoddi3+0xf0>
  80165c:	0f bd c5             	bsr    %ebp,%eax
  80165f:	83 f0 1f             	xor    $0x1f,%eax
  801662:	89 44 24 10          	mov    %eax,0x10(%esp)
  801666:	0f 84 a8 00 00 00    	je     801714 <__umoddi3+0xfc>
  80166c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801670:	d3 e5                	shl    %cl,%ebp
  801672:	bf 20 00 00 00       	mov    $0x20,%edi
  801677:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80167b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80167f:	89 f9                	mov    %edi,%ecx
  801681:	d3 e8                	shr    %cl,%eax
  801683:	09 e8                	or     %ebp,%eax
  801685:	89 44 24 18          	mov    %eax,0x18(%esp)
  801689:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80168d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  801691:	d3 e0                	shl    %cl,%eax
  801693:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801697:	89 f2                	mov    %esi,%edx
  801699:	d3 e2                	shl    %cl,%edx
  80169b:	8b 44 24 14          	mov    0x14(%esp),%eax
  80169f:	d3 e0                	shl    %cl,%eax
  8016a1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8016a5:	8b 44 24 14          	mov    0x14(%esp),%eax
  8016a9:	89 f9                	mov    %edi,%ecx
  8016ab:	d3 e8                	shr    %cl,%eax
  8016ad:	09 d0                	or     %edx,%eax
  8016af:	d3 ee                	shr    %cl,%esi
  8016b1:	89 f2                	mov    %esi,%edx
  8016b3:	f7 74 24 18          	divl   0x18(%esp)
  8016b7:	89 d6                	mov    %edx,%esi
  8016b9:	f7 64 24 0c          	mull   0xc(%esp)
  8016bd:	89 c5                	mov    %eax,%ebp
  8016bf:	89 d1                	mov    %edx,%ecx
  8016c1:	39 d6                	cmp    %edx,%esi
  8016c3:	72 67                	jb     80172c <__umoddi3+0x114>
  8016c5:	74 75                	je     80173c <__umoddi3+0x124>
  8016c7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8016cb:	29 e8                	sub    %ebp,%eax
  8016cd:	19 ce                	sbb    %ecx,%esi
  8016cf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016d3:	d3 e8                	shr    %cl,%eax
  8016d5:	89 f2                	mov    %esi,%edx
  8016d7:	89 f9                	mov    %edi,%ecx
  8016d9:	d3 e2                	shl    %cl,%edx
  8016db:	09 d0                	or     %edx,%eax
  8016dd:	89 f2                	mov    %esi,%edx
  8016df:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8016e3:	d3 ea                	shr    %cl,%edx
  8016e5:	83 c4 20             	add    $0x20,%esp
  8016e8:	5e                   	pop    %esi
  8016e9:	5f                   	pop    %edi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    
  8016ec:	85 c9                	test   %ecx,%ecx
  8016ee:	75 0b                	jne    8016fb <__umoddi3+0xe3>
  8016f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016f5:	31 d2                	xor    %edx,%edx
  8016f7:	f7 f1                	div    %ecx
  8016f9:	89 c1                	mov    %eax,%ecx
  8016fb:	89 f0                	mov    %esi,%eax
  8016fd:	31 d2                	xor    %edx,%edx
  8016ff:	f7 f1                	div    %ecx
  801701:	89 f8                	mov    %edi,%eax
  801703:	e9 3e ff ff ff       	jmp    801646 <__umoddi3+0x2e>
  801708:	89 f2                	mov    %esi,%edx
  80170a:	83 c4 20             	add    $0x20,%esp
  80170d:	5e                   	pop    %esi
  80170e:	5f                   	pop    %edi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    
  801711:	8d 76 00             	lea    0x0(%esi),%esi
  801714:	39 f5                	cmp    %esi,%ebp
  801716:	72 04                	jb     80171c <__umoddi3+0x104>
  801718:	39 f9                	cmp    %edi,%ecx
  80171a:	77 06                	ja     801722 <__umoddi3+0x10a>
  80171c:	89 f2                	mov    %esi,%edx
  80171e:	29 cf                	sub    %ecx,%edi
  801720:	19 ea                	sbb    %ebp,%edx
  801722:	89 f8                	mov    %edi,%eax
  801724:	83 c4 20             	add    $0x20,%esp
  801727:	5e                   	pop    %esi
  801728:	5f                   	pop    %edi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    
  80172b:	90                   	nop
  80172c:	89 d1                	mov    %edx,%ecx
  80172e:	89 c5                	mov    %eax,%ebp
  801730:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  801734:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  801738:	eb 8d                	jmp    8016c7 <__umoddi3+0xaf>
  80173a:	66 90                	xchg   %ax,%ax
  80173c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  801740:	72 ea                	jb     80172c <__umoddi3+0x114>
  801742:	89 f1                	mov    %esi,%ecx
  801744:	eb 81                	jmp    8016c7 <__umoddi3+0xaf>
