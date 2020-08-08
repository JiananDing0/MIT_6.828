
obj/user/sendpage.debug:     file format elf32-i386


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
  80003a:	e8 e8 0f 00 00       	call   801027 <fork>
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
  800060:	e8 bb 12 00 00       	call   801320 <ipc_recv>
		cprintf("%x got message: %s\n", who, TEMP_ADDR_CHILD);
  800065:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  80006c:	00 
  80006d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800070:	89 44 24 04          	mov    %eax,0x4(%esp)
  800074:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  80007b:	e8 70 02 00 00       	call   8002f0 <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800080:	a1 04 30 80 00       	mov    0x803004,%eax
  800085:	89 04 24             	mov    %eax,(%esp)
  800088:	e8 fb 07 00 00       	call   800888 <strlen>
  80008d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800091:	a1 04 30 80 00       	mov    0x803004,%eax
  800096:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009a:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000a1:	e8 dd 08 00 00       	call   800983 <strncmp>
  8000a6:	85 c0                	test   %eax,%eax
  8000a8:	75 0c                	jne    8000b6 <umain+0x82>
			cprintf("child received correct message\n");
  8000aa:	c7 04 24 74 25 80 00 	movl   $0x802574,(%esp)
  8000b1:	e8 3a 02 00 00       	call   8002f0 <cprintf>

		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  8000b6:	a1 00 30 80 00       	mov    0x803000,%eax
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 c5 07 00 00       	call   800888 <strlen>
  8000c3:	40                   	inc    %eax
  8000c4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c8:	a1 00 30 80 00       	mov    0x803000,%eax
  8000cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000d1:	c7 04 24 00 00 b0 00 	movl   $0xb00000,(%esp)
  8000d8:	e8 c1 09 00 00       	call   800a9e <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  8000dd:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8000e4:	00 
  8000e5:	c7 44 24 08 00 00 b0 	movl   $0xb00000,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000f4:	00 
  8000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8000f8:	89 04 24             	mov    %eax,(%esp)
  8000fb:	e8 87 12 00 00       	call   801387 <ipc_send>
		return;
  800100:	e9 d6 00 00 00       	jmp    8001db <umain+0x1a7>
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  800105:	a1 04 40 80 00       	mov    0x804004,%eax
  80010a:	8b 40 48             	mov    0x48(%eax),%eax
  80010d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800114:	00 
  800115:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80011c:	00 
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 88 0b 00 00       	call   800cad <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800125:	a1 04 30 80 00       	mov    0x803004,%eax
  80012a:	89 04 24             	mov    %eax,(%esp)
  80012d:	e8 56 07 00 00       	call   800888 <strlen>
  800132:	40                   	inc    %eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	a1 04 30 80 00       	mov    0x803004,%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  800147:	e8 52 09 00 00       	call   800a9e <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80014c:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  800153:	00 
  800154:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  80015b:	00 
  80015c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800163:	00 
  800164:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800167:	89 04 24             	mov    %eax,(%esp)
  80016a:	e8 18 12 00 00       	call   801387 <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80016f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800176:	00 
  800177:	c7 44 24 04 00 00 a0 	movl   $0xa00000,0x4(%esp)
  80017e:	00 
  80017f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800182:	89 04 24             	mov    %eax,(%esp)
  800185:	e8 96 11 00 00       	call   801320 <ipc_recv>
	cprintf("%x got message: %s\n", who, TEMP_ADDR);
  80018a:	c7 44 24 08 00 00 a0 	movl   $0xa00000,0x8(%esp)
  800191:	00 
  800192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 60 25 80 00 	movl   $0x802560,(%esp)
  8001a0:	e8 4b 01 00 00       	call   8002f0 <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8001a5:	a1 00 30 80 00       	mov    0x803000,%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 d6 06 00 00       	call   800888 <strlen>
  8001b2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b6:	a1 00 30 80 00       	mov    0x803000,%eax
  8001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001bf:	c7 04 24 00 00 a0 00 	movl   $0xa00000,(%esp)
  8001c6:	e8 b8 07 00 00       	call   800983 <strncmp>
  8001cb:	85 c0                	test   %eax,%eax
  8001cd:	75 0c                	jne    8001db <umain+0x1a7>
		cprintf("parent received correct message\n");
  8001cf:	c7 04 24 94 25 80 00 	movl   $0x802594,(%esp)
  8001d6:	e8 15 01 00 00       	call   8002f0 <cprintf>
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
  8001ee:	e8 7c 0a 00 00       	call   800c6f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  8001f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8001ff:	c1 e0 07             	shl    $0x7,%eax
  800202:	29 d0                	sub    %edx,%eax
  800204:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800209:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80020e:	85 f6                	test   %esi,%esi
  800210:	7e 07                	jle    800219 <libmain+0x39>
		binaryname = argv[0];
  800212:	8b 03                	mov    (%ebx),%eax
  800214:	a3 08 30 80 00       	mov    %eax,0x803008

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
	close_all();
  80023a:	e8 e0 13 00 00       	call   80161f <close_all>
	sys_env_destroy(0);
  80023f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800246:	e8 d2 09 00 00       	call   800c1d <sys_env_destroy>
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    
  80024d:	00 00                	add    %al,(%eax)
	...

00800250 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	53                   	push   %ebx
  800254:	83 ec 14             	sub    $0x14,%esp
  800257:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80025a:	8b 03                	mov    (%ebx),%eax
  80025c:	8b 55 08             	mov    0x8(%ebp),%edx
  80025f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800263:	40                   	inc    %eax
  800264:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800266:	3d ff 00 00 00       	cmp    $0xff,%eax
  80026b:	75 19                	jne    800286 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80026d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800274:	00 
  800275:	8d 43 08             	lea    0x8(%ebx),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	e8 60 09 00 00       	call   800be0 <sys_cputs>
		b->idx = 0;
  800280:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800286:	ff 43 04             	incl   0x4(%ebx)
}
  800289:	83 c4 14             	add    $0x14,%esp
  80028c:	5b                   	pop    %ebx
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    

0080028f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800298:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80029f:	00 00 00 
	b.cnt = 0;
  8002a2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002a9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c4:	c7 04 24 50 02 80 00 	movl   $0x800250,(%esp)
  8002cb:	e8 82 01 00 00       	call   800452 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d0:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8002d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e0:	89 04 24             	mov    %eax,(%esp)
  8002e3:	e8 f8 08 00 00       	call   800be0 <sys_cputs>

	return b.cnt;
}
  8002e8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ee:	c9                   	leave  
  8002ef:	c3                   	ret    

008002f0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800300:	89 04 24             	mov    %eax,(%esp)
  800303:	e8 87 ff ff ff       	call   80028f <vcprintf>
	va_end(ap);

	return cnt;
}
  800308:	c9                   	leave  
  800309:	c3                   	ret    
	...

0080030c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	57                   	push   %edi
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
  800312:	83 ec 3c             	sub    $0x3c,%esp
  800315:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800318:	89 d7                	mov    %edx,%edi
  80031a:	8b 45 08             	mov    0x8(%ebp),%eax
  80031d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800320:	8b 45 0c             	mov    0xc(%ebp),%eax
  800323:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800326:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800329:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80032c:	85 c0                	test   %eax,%eax
  80032e:	75 08                	jne    800338 <printnum+0x2c>
  800330:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800333:	39 45 10             	cmp    %eax,0x10(%ebp)
  800336:	77 57                	ja     80038f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800338:	89 74 24 10          	mov    %esi,0x10(%esp)
  80033c:	4b                   	dec    %ebx
  80033d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800341:	8b 45 10             	mov    0x10(%ebp),%eax
  800344:	89 44 24 08          	mov    %eax,0x8(%esp)
  800348:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80034c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800350:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800357:	00 
  800358:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035b:	89 04 24             	mov    %eax,(%esp)
  80035e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800361:	89 44 24 04          	mov    %eax,0x4(%esp)
  800365:	e8 a6 1f 00 00       	call   802310 <__udivdi3>
  80036a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80036e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800372:	89 04 24             	mov    %eax,(%esp)
  800375:	89 54 24 04          	mov    %edx,0x4(%esp)
  800379:	89 fa                	mov    %edi,%edx
  80037b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80037e:	e8 89 ff ff ff       	call   80030c <printnum>
  800383:	eb 0f                	jmp    800394 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800385:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800389:	89 34 24             	mov    %esi,(%esp)
  80038c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80038f:	4b                   	dec    %ebx
  800390:	85 db                	test   %ebx,%ebx
  800392:	7f f1                	jg     800385 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800394:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800398:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80039c:	8b 45 10             	mov    0x10(%ebp),%eax
  80039f:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8003aa:	00 
  8003ab:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003ae:	89 04 24             	mov    %eax,(%esp)
  8003b1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b8:	e8 73 20 00 00       	call   802430 <__umoddi3>
  8003bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8003c1:	0f be 80 0c 26 80 00 	movsbl 0x80260c(%eax),%eax
  8003c8:	89 04 24             	mov    %eax,(%esp)
  8003cb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003ce:	83 c4 3c             	add    $0x3c,%esp
  8003d1:	5b                   	pop    %ebx
  8003d2:	5e                   	pop    %esi
  8003d3:	5f                   	pop    %edi
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003d9:	83 fa 01             	cmp    $0x1,%edx
  8003dc:	7e 0e                	jle    8003ec <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003de:	8b 10                	mov    (%eax),%edx
  8003e0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003e3:	89 08                	mov    %ecx,(%eax)
  8003e5:	8b 02                	mov    (%edx),%eax
  8003e7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ea:	eb 22                	jmp    80040e <getuint+0x38>
	else if (lflag)
  8003ec:	85 d2                	test   %edx,%edx
  8003ee:	74 10                	je     800400 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f5:	89 08                	mov    %ecx,(%eax)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003fe:	eb 0e                	jmp    80040e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800400:	8b 10                	mov    (%eax),%edx
  800402:	8d 4a 04             	lea    0x4(%edx),%ecx
  800405:	89 08                	mov    %ecx,(%eax)
  800407:	8b 02                	mov    (%edx),%eax
  800409:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800416:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800419:	8b 10                	mov    (%eax),%edx
  80041b:	3b 50 04             	cmp    0x4(%eax),%edx
  80041e:	73 08                	jae    800428 <sprintputch+0x18>
		*b->buf++ = ch;
  800420:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800423:	88 0a                	mov    %cl,(%edx)
  800425:	42                   	inc    %edx
  800426:	89 10                	mov    %edx,(%eax)
}
  800428:	5d                   	pop    %ebp
  800429:	c3                   	ret    

0080042a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80042a:	55                   	push   %ebp
  80042b:	89 e5                	mov    %esp,%ebp
  80042d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800430:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	8b 45 10             	mov    0x10(%ebp),%eax
  80043a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	89 44 24 04          	mov    %eax,0x4(%esp)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	89 04 24             	mov    %eax,(%esp)
  80044b:	e8 02 00 00 00       	call   800452 <vprintfmt>
	va_end(ap);
}
  800450:	c9                   	leave  
  800451:	c3                   	ret    

00800452 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	57                   	push   %edi
  800456:	56                   	push   %esi
  800457:	53                   	push   %ebx
  800458:	83 ec 4c             	sub    $0x4c,%esp
  80045b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80045e:	8b 75 10             	mov    0x10(%ebp),%esi
  800461:	eb 12                	jmp    800475 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800463:	85 c0                	test   %eax,%eax
  800465:	0f 84 8b 03 00 00    	je     8007f6 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80046b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800475:	0f b6 06             	movzbl (%esi),%eax
  800478:	46                   	inc    %esi
  800479:	83 f8 25             	cmp    $0x25,%eax
  80047c:	75 e5                	jne    800463 <vprintfmt+0x11>
  80047e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800482:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800489:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80048e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800495:	b9 00 00 00 00       	mov    $0x0,%ecx
  80049a:	eb 26                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80049f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8004a3:	eb 1d                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004a8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8004ac:	eb 14                	jmp    8004c2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8004b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004b8:	eb 08                	jmp    8004c2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8004ba:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8004bd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	0f b6 06             	movzbl (%esi),%eax
  8004c5:	8d 56 01             	lea    0x1(%esi),%edx
  8004c8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004cb:	8a 16                	mov    (%esi),%dl
  8004cd:	83 ea 23             	sub    $0x23,%edx
  8004d0:	80 fa 55             	cmp    $0x55,%dl
  8004d3:	0f 87 01 03 00 00    	ja     8007da <vprintfmt+0x388>
  8004d9:	0f b6 d2             	movzbl %dl,%edx
  8004dc:	ff 24 95 40 27 80 00 	jmp    *0x802740(,%edx,4)
  8004e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004e6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004eb:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8004ee:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8004f2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8004f5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8004f8:	83 fa 09             	cmp    $0x9,%edx
  8004fb:	77 2a                	ja     800527 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004fd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004fe:	eb eb                	jmp    8004eb <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80050e:	eb 17                	jmp    800527 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800510:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800514:	78 98                	js     8004ae <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800516:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800519:	eb a7                	jmp    8004c2 <vprintfmt+0x70>
  80051b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80051e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800525:	eb 9b                	jmp    8004c2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800527:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80052b:	79 95                	jns    8004c2 <vprintfmt+0x70>
  80052d:	eb 8b                	jmp    8004ba <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80052f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800533:	eb 8d                	jmp    8004c2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 50 04             	lea    0x4(%eax),%edx
  80053b:	89 55 14             	mov    %edx,0x14(%ebp)
  80053e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800542:	8b 00                	mov    (%eax),%eax
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80054d:	e9 23 ff ff ff       	jmp    800475 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800552:	8b 45 14             	mov    0x14(%ebp),%eax
  800555:	8d 50 04             	lea    0x4(%eax),%edx
  800558:	89 55 14             	mov    %edx,0x14(%ebp)
  80055b:	8b 00                	mov    (%eax),%eax
  80055d:	85 c0                	test   %eax,%eax
  80055f:	79 02                	jns    800563 <vprintfmt+0x111>
  800561:	f7 d8                	neg    %eax
  800563:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800565:	83 f8 0f             	cmp    $0xf,%eax
  800568:	7f 0b                	jg     800575 <vprintfmt+0x123>
  80056a:	8b 04 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%eax
  800571:	85 c0                	test   %eax,%eax
  800573:	75 23                	jne    800598 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800575:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800579:	c7 44 24 08 24 26 80 	movl   $0x802624,0x8(%esp)
  800580:	00 
  800581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800585:	8b 45 08             	mov    0x8(%ebp),%eax
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	e8 9a fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800590:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800593:	e9 dd fe ff ff       	jmp    800475 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800598:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80059c:	c7 44 24 08 12 2b 80 	movl   $0x802b12,0x8(%esp)
  8005a3:	00 
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8005ab:	89 14 24             	mov    %edx,(%esp)
  8005ae:	e8 77 fe ff ff       	call   80042a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b6:	e9 ba fe ff ff       	jmp    800475 <vprintfmt+0x23>
  8005bb:	89 f9                	mov    %edi,%ecx
  8005bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 30                	mov    (%eax),%esi
  8005ce:	85 f6                	test   %esi,%esi
  8005d0:	75 05                	jne    8005d7 <vprintfmt+0x185>
				p = "(null)";
  8005d2:	be 1d 26 80 00       	mov    $0x80261d,%esi
			if (width > 0 && padc != '-')
  8005d7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005db:	0f 8e 84 00 00 00    	jle    800665 <vprintfmt+0x213>
  8005e1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8005e5:	74 7e                	je     800665 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005eb:	89 34 24             	mov    %esi,(%esp)
  8005ee:	e8 ab 02 00 00       	call   80089e <strnlen>
  8005f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8005f6:	29 c2                	sub    %eax,%edx
  8005f8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8005fb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8005ff:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800602:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800605:	89 de                	mov    %ebx,%esi
  800607:	89 d3                	mov    %edx,%ebx
  800609:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060b:	eb 0b                	jmp    800618 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80060d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800611:	89 3c 24             	mov    %edi,(%esp)
  800614:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800617:	4b                   	dec    %ebx
  800618:	85 db                	test   %ebx,%ebx
  80061a:	7f f1                	jg     80060d <vprintfmt+0x1bb>
  80061c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80061f:	89 f3                	mov    %esi,%ebx
  800621:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800624:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800627:	85 c0                	test   %eax,%eax
  800629:	79 05                	jns    800630 <vprintfmt+0x1de>
  80062b:	b8 00 00 00 00       	mov    $0x0,%eax
  800630:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800633:	29 c2                	sub    %eax,%edx
  800635:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800638:	eb 2b                	jmp    800665 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80063e:	74 18                	je     800658 <vprintfmt+0x206>
  800640:	8d 50 e0             	lea    -0x20(%eax),%edx
  800643:	83 fa 5e             	cmp    $0x5e,%edx
  800646:	76 10                	jbe    800658 <vprintfmt+0x206>
					putch('?', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
  800656:	eb 0a                	jmp    800662 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800658:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80065c:	89 04 24             	mov    %eax,(%esp)
  80065f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800662:	ff 4d e4             	decl   -0x1c(%ebp)
  800665:	0f be 06             	movsbl (%esi),%eax
  800668:	46                   	inc    %esi
  800669:	85 c0                	test   %eax,%eax
  80066b:	74 21                	je     80068e <vprintfmt+0x23c>
  80066d:	85 ff                	test   %edi,%edi
  80066f:	78 c9                	js     80063a <vprintfmt+0x1e8>
  800671:	4f                   	dec    %edi
  800672:	79 c6                	jns    80063a <vprintfmt+0x1e8>
  800674:	8b 7d 08             	mov    0x8(%ebp),%edi
  800677:	89 de                	mov    %ebx,%esi
  800679:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80067c:	eb 18                	jmp    800696 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800689:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068b:	4b                   	dec    %ebx
  80068c:	eb 08                	jmp    800696 <vprintfmt+0x244>
  80068e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800691:	89 de                	mov    %ebx,%esi
  800693:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800696:	85 db                	test   %ebx,%ebx
  800698:	7f e4                	jg     80067e <vprintfmt+0x22c>
  80069a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80069d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006a2:	e9 ce fd ff ff       	jmp    800475 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	7e 10                	jle    8006bc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 08             	lea    0x8(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 30                	mov    (%eax),%esi
  8006b7:	8b 78 04             	mov    0x4(%eax),%edi
  8006ba:	eb 26                	jmp    8006e2 <vprintfmt+0x290>
	else if (lflag)
  8006bc:	85 c9                	test   %ecx,%ecx
  8006be:	74 12                	je     8006d2 <vprintfmt+0x280>
		return va_arg(*ap, long);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8d 50 04             	lea    0x4(%eax),%edx
  8006c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c9:	8b 30                	mov    (%eax),%esi
  8006cb:	89 f7                	mov    %esi,%edi
  8006cd:	c1 ff 1f             	sar    $0x1f,%edi
  8006d0:	eb 10                	jmp    8006e2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  8006d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d5:	8d 50 04             	lea    0x4(%eax),%edx
  8006d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006db:	8b 30                	mov    (%eax),%esi
  8006dd:	89 f7                	mov    %esi,%edi
  8006df:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e2:	85 ff                	test   %edi,%edi
  8006e4:	78 0a                	js     8006f0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006eb:	e9 ac 00 00 00       	jmp    80079c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8006fe:	f7 de                	neg    %esi
  800700:	83 d7 00             	adc    $0x0,%edi
  800703:	f7 df                	neg    %edi
			}
			base = 10;
  800705:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070a:	e9 8d 00 00 00       	jmp    80079c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80070f:	89 ca                	mov    %ecx,%edx
  800711:	8d 45 14             	lea    0x14(%ebp),%eax
  800714:	e8 bd fc ff ff       	call   8003d6 <getuint>
  800719:	89 c6                	mov    %eax,%esi
  80071b:	89 d7                	mov    %edx,%edi
			base = 10;
  80071d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800722:	eb 78                	jmp    80079c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800724:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800728:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80072f:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800732:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800736:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80073d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800740:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800744:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80074b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80074e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800751:	e9 1f fd ff ff       	jmp    800475 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800756:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80075a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800761:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800764:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800768:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80076f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8d 50 04             	lea    0x4(%eax),%edx
  800778:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077b:	8b 30                	mov    (%eax),%esi
  80077d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800787:	eb 13                	jmp    80079c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800789:	89 ca                	mov    %ecx,%edx
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	e8 43 fc ff ff       	call   8003d6 <getuint>
  800793:	89 c6                	mov    %eax,%esi
  800795:	89 d7                	mov    %edx,%edi
			base = 16;
  800797:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80079c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8007a0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007a4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007a7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007af:	89 34 24             	mov    %esi,(%esp)
  8007b2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8007b6:	89 da                	mov    %ebx,%edx
  8007b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bb:	e8 4c fb ff ff       	call   80030c <printnum>
			break;
  8007c0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8007c3:	e9 ad fc ff ff       	jmp    800475 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007cc:	89 04 24             	mov    %eax,(%esp)
  8007cf:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007d2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007d5:	e9 9b fc ff ff       	jmp    800475 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007de:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007e5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007e8:	eb 01                	jmp    8007eb <vprintfmt+0x399>
  8007ea:	4e                   	dec    %esi
  8007eb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8007ef:	75 f9                	jne    8007ea <vprintfmt+0x398>
  8007f1:	e9 7f fc ff ff       	jmp    800475 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8007f6:	83 c4 4c             	add    $0x4c,%esp
  8007f9:	5b                   	pop    %ebx
  8007fa:	5e                   	pop    %esi
  8007fb:	5f                   	pop    %edi
  8007fc:	5d                   	pop    %ebp
  8007fd:	c3                   	ret    

008007fe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 28             	sub    $0x28,%esp
  800804:	8b 45 08             	mov    0x8(%ebp),%eax
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80080a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800811:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800814:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80081b:	85 c0                	test   %eax,%eax
  80081d:	74 30                	je     80084f <vsnprintf+0x51>
  80081f:	85 d2                	test   %edx,%edx
  800821:	7e 33                	jle    800856 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082a:	8b 45 10             	mov    0x10(%ebp),%eax
  80082d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800831:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800834:	89 44 24 04          	mov    %eax,0x4(%esp)
  800838:	c7 04 24 10 04 80 00 	movl   $0x800410,(%esp)
  80083f:	e8 0e fc ff ff       	call   800452 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800844:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800847:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80084a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084d:	eb 0c                	jmp    80085b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80084f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800854:	eb 05                	jmp    80085b <vsnprintf+0x5d>
  800856:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800863:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800866:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086a:	8b 45 10             	mov    0x10(%ebp),%eax
  80086d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800871:	8b 45 0c             	mov    0xc(%ebp),%eax
  800874:	89 44 24 04          	mov    %eax,0x4(%esp)
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	89 04 24             	mov    %eax,(%esp)
  80087e:	e8 7b ff ff ff       	call   8007fe <vsnprintf>
	va_end(ap);

	return rc;
}
  800883:	c9                   	leave  
  800884:	c3                   	ret    
  800885:	00 00                	add    %al,(%eax)
	...

00800888 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
  800893:	eb 01                	jmp    800896 <strlen+0xe>
		n++;
  800895:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80089a:	75 f9                	jne    800895 <strlen+0xd>
		n++;
	return n;
}
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ac:	eb 01                	jmp    8008af <strnlen+0x11>
		n++;
  8008ae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008af:	39 d0                	cmp    %edx,%eax
  8008b1:	74 06                	je     8008b9 <strnlen+0x1b>
  8008b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008b7:	75 f5                	jne    8008ae <strnlen+0x10>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8008ca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8008cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008d0:	42                   	inc    %edx
  8008d1:	84 c9                	test   %cl,%cl
  8008d3:	75 f5                	jne    8008ca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d5:	5b                   	pop    %ebx
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 9e ff ff ff       	call   800888 <strlen>
	strcpy(dst + len, src);
  8008ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f1:	01 d8                	add    %ebx,%eax
  8008f3:	89 04 24             	mov    %eax,(%esp)
  8008f6:	e8 c0 ff ff ff       	call   8008bb <strcpy>
	return dst;
}
  8008fb:	89 d8                	mov    %ebx,%eax
  8008fd:	83 c4 08             	add    $0x8,%esp
  800900:	5b                   	pop    %ebx
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800911:	b9 00 00 00 00       	mov    $0x0,%ecx
  800916:	eb 0c                	jmp    800924 <strncpy+0x21>
		*dst++ = *src;
  800918:	8a 1a                	mov    (%edx),%bl
  80091a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80091d:	80 3a 01             	cmpb   $0x1,(%edx)
  800920:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800923:	41                   	inc    %ecx
  800924:	39 f1                	cmp    %esi,%ecx
  800926:	75 f0                	jne    800918 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800928:	5b                   	pop    %ebx
  800929:	5e                   	pop    %esi
  80092a:	5d                   	pop    %ebp
  80092b:	c3                   	ret    

0080092c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	56                   	push   %esi
  800930:	53                   	push   %ebx
  800931:	8b 75 08             	mov    0x8(%ebp),%esi
  800934:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800937:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80093a:	85 d2                	test   %edx,%edx
  80093c:	75 0a                	jne    800948 <strlcpy+0x1c>
  80093e:	89 f0                	mov    %esi,%eax
  800940:	eb 1a                	jmp    80095c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800942:	88 18                	mov    %bl,(%eax)
  800944:	40                   	inc    %eax
  800945:	41                   	inc    %ecx
  800946:	eb 02                	jmp    80094a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800948:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80094a:	4a                   	dec    %edx
  80094b:	74 0a                	je     800957 <strlcpy+0x2b>
  80094d:	8a 19                	mov    (%ecx),%bl
  80094f:	84 db                	test   %bl,%bl
  800951:	75 ef                	jne    800942 <strlcpy+0x16>
  800953:	89 c2                	mov    %eax,%edx
  800955:	eb 02                	jmp    800959 <strlcpy+0x2d>
  800957:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800959:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80095c:	29 f0                	sub    %esi,%eax
}
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800968:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096b:	eb 02                	jmp    80096f <strcmp+0xd>
		p++, q++;
  80096d:	41                   	inc    %ecx
  80096e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096f:	8a 01                	mov    (%ecx),%al
  800971:	84 c0                	test   %al,%al
  800973:	74 04                	je     800979 <strcmp+0x17>
  800975:	3a 02                	cmp    (%edx),%al
  800977:	74 f4                	je     80096d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800979:	0f b6 c0             	movzbl %al,%eax
  80097c:	0f b6 12             	movzbl (%edx),%edx
  80097f:	29 d0                	sub    %edx,%eax
}
  800981:	5d                   	pop    %ebp
  800982:	c3                   	ret    

00800983 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	53                   	push   %ebx
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800990:	eb 03                	jmp    800995 <strncmp+0x12>
		n--, p++, q++;
  800992:	4a                   	dec    %edx
  800993:	40                   	inc    %eax
  800994:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800995:	85 d2                	test   %edx,%edx
  800997:	74 14                	je     8009ad <strncmp+0x2a>
  800999:	8a 18                	mov    (%eax),%bl
  80099b:	84 db                	test   %bl,%bl
  80099d:	74 04                	je     8009a3 <strncmp+0x20>
  80099f:	3a 19                	cmp    (%ecx),%bl
  8009a1:	74 ef                	je     800992 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a3:	0f b6 00             	movzbl (%eax),%eax
  8009a6:	0f b6 11             	movzbl (%ecx),%edx
  8009a9:	29 d0                	sub    %edx,%eax
  8009ab:	eb 05                	jmp    8009b2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009ad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b2:	5b                   	pop    %ebx
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009be:	eb 05                	jmp    8009c5 <strchr+0x10>
		if (*s == c)
  8009c0:	38 ca                	cmp    %cl,%dl
  8009c2:	74 0c                	je     8009d0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009c4:	40                   	inc    %eax
  8009c5:	8a 10                	mov    (%eax),%dl
  8009c7:	84 d2                	test   %dl,%dl
  8009c9:	75 f5                	jne    8009c0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8009cb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d0:	5d                   	pop    %ebp
  8009d1:	c3                   	ret    

008009d2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009d2:	55                   	push   %ebp
  8009d3:	89 e5                	mov    %esp,%ebp
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8009db:	eb 05                	jmp    8009e2 <strfind+0x10>
		if (*s == c)
  8009dd:	38 ca                	cmp    %cl,%dl
  8009df:	74 07                	je     8009e8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009e1:	40                   	inc    %eax
  8009e2:	8a 10                	mov    (%eax),%dl
  8009e4:	84 d2                	test   %dl,%dl
  8009e6:	75 f5                	jne    8009dd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	57                   	push   %edi
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f9:	85 c9                	test   %ecx,%ecx
  8009fb:	74 30                	je     800a2d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a03:	75 25                	jne    800a2a <memset+0x40>
  800a05:	f6 c1 03             	test   $0x3,%cl
  800a08:	75 20                	jne    800a2a <memset+0x40>
		c &= 0xFF;
  800a0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a0d:	89 d3                	mov    %edx,%ebx
  800a0f:	c1 e3 08             	shl    $0x8,%ebx
  800a12:	89 d6                	mov    %edx,%esi
  800a14:	c1 e6 18             	shl    $0x18,%esi
  800a17:	89 d0                	mov    %edx,%eax
  800a19:	c1 e0 10             	shl    $0x10,%eax
  800a1c:	09 f0                	or     %esi,%eax
  800a1e:	09 d0                	or     %edx,%eax
  800a20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a25:	fc                   	cld    
  800a26:	f3 ab                	rep stos %eax,%es:(%edi)
  800a28:	eb 03                	jmp    800a2d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a2a:	fc                   	cld    
  800a2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	5b                   	pop    %ebx
  800a30:	5e                   	pop    %esi
  800a31:	5f                   	pop    %edi
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a42:	39 c6                	cmp    %eax,%esi
  800a44:	73 34                	jae    800a7a <memmove+0x46>
  800a46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a49:	39 d0                	cmp    %edx,%eax
  800a4b:	73 2d                	jae    800a7a <memmove+0x46>
		s += n;
		d += n;
  800a4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a50:	f6 c2 03             	test   $0x3,%dl
  800a53:	75 1b                	jne    800a70 <memmove+0x3c>
  800a55:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5b:	75 13                	jne    800a70 <memmove+0x3c>
  800a5d:	f6 c1 03             	test   $0x3,%cl
  800a60:	75 0e                	jne    800a70 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a62:	83 ef 04             	sub    $0x4,%edi
  800a65:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a68:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a6b:	fd                   	std    
  800a6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a6e:	eb 07                	jmp    800a77 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a70:	4f                   	dec    %edi
  800a71:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a74:	fd                   	std    
  800a75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a77:	fc                   	cld    
  800a78:	eb 20                	jmp    800a9a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a80:	75 13                	jne    800a95 <memmove+0x61>
  800a82:	a8 03                	test   $0x3,%al
  800a84:	75 0f                	jne    800a95 <memmove+0x61>
  800a86:	f6 c1 03             	test   $0x3,%cl
  800a89:	75 0a                	jne    800a95 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a8b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a8e:	89 c7                	mov    %eax,%edi
  800a90:	fc                   	cld    
  800a91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a93:	eb 05                	jmp    800a9a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a95:	89 c7                	mov    %eax,%edi
  800a97:	fc                   	cld    
  800a98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800aa4:	8b 45 10             	mov    0x10(%ebp),%eax
  800aa7:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	89 04 24             	mov    %eax,(%esp)
  800ab8:	e8 77 ff ff ff       	call   800a34 <memmove>
}
  800abd:	c9                   	leave  
  800abe:	c3                   	ret    

00800abf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	57                   	push   %edi
  800ac3:	56                   	push   %esi
  800ac4:	53                   	push   %ebx
  800ac5:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800acb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ace:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad3:	eb 16                	jmp    800aeb <memcmp+0x2c>
		if (*s1 != *s2)
  800ad5:	8a 04 17             	mov    (%edi,%edx,1),%al
  800ad8:	42                   	inc    %edx
  800ad9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800add:	38 c8                	cmp    %cl,%al
  800adf:	74 0a                	je     800aeb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ae1:	0f b6 c0             	movzbl %al,%eax
  800ae4:	0f b6 c9             	movzbl %cl,%ecx
  800ae7:	29 c8                	sub    %ecx,%eax
  800ae9:	eb 09                	jmp    800af4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aeb:	39 da                	cmp    %ebx,%edx
  800aed:	75 e6                	jne    800ad5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af4:	5b                   	pop    %ebx
  800af5:	5e                   	pop    %esi
  800af6:	5f                   	pop    %edi
  800af7:	5d                   	pop    %ebp
  800af8:	c3                   	ret    

00800af9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af9:	55                   	push   %ebp
  800afa:	89 e5                	mov    %esp,%ebp
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b02:	89 c2                	mov    %eax,%edx
  800b04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b07:	eb 05                	jmp    800b0e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b09:	38 08                	cmp    %cl,(%eax)
  800b0b:	74 05                	je     800b12 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0d:	40                   	inc    %eax
  800b0e:	39 d0                	cmp    %edx,%eax
  800b10:	72 f7                	jb     800b09 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	57                   	push   %edi
  800b18:	56                   	push   %esi
  800b19:	53                   	push   %ebx
  800b1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b20:	eb 01                	jmp    800b23 <strtol+0xf>
		s++;
  800b22:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b23:	8a 02                	mov    (%edx),%al
  800b25:	3c 20                	cmp    $0x20,%al
  800b27:	74 f9                	je     800b22 <strtol+0xe>
  800b29:	3c 09                	cmp    $0x9,%al
  800b2b:	74 f5                	je     800b22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b2d:	3c 2b                	cmp    $0x2b,%al
  800b2f:	75 08                	jne    800b39 <strtol+0x25>
		s++;
  800b31:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b32:	bf 00 00 00 00       	mov    $0x0,%edi
  800b37:	eb 13                	jmp    800b4c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b39:	3c 2d                	cmp    $0x2d,%al
  800b3b:	75 0a                	jne    800b47 <strtol+0x33>
		s++, neg = 1;
  800b3d:	8d 52 01             	lea    0x1(%edx),%edx
  800b40:	bf 01 00 00 00       	mov    $0x1,%edi
  800b45:	eb 05                	jmp    800b4c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b4c:	85 db                	test   %ebx,%ebx
  800b4e:	74 05                	je     800b55 <strtol+0x41>
  800b50:	83 fb 10             	cmp    $0x10,%ebx
  800b53:	75 28                	jne    800b7d <strtol+0x69>
  800b55:	8a 02                	mov    (%edx),%al
  800b57:	3c 30                	cmp    $0x30,%al
  800b59:	75 10                	jne    800b6b <strtol+0x57>
  800b5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b5f:	75 0a                	jne    800b6b <strtol+0x57>
		s += 2, base = 16;
  800b61:	83 c2 02             	add    $0x2,%edx
  800b64:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b69:	eb 12                	jmp    800b7d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800b6b:	85 db                	test   %ebx,%ebx
  800b6d:	75 0e                	jne    800b7d <strtol+0x69>
  800b6f:	3c 30                	cmp    $0x30,%al
  800b71:	75 05                	jne    800b78 <strtol+0x64>
		s++, base = 8;
  800b73:	42                   	inc    %edx
  800b74:	b3 08                	mov    $0x8,%bl
  800b76:	eb 05                	jmp    800b7d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800b78:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b7d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b82:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b84:	8a 0a                	mov    (%edx),%cl
  800b86:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800b89:	80 fb 09             	cmp    $0x9,%bl
  800b8c:	77 08                	ja     800b96 <strtol+0x82>
			dig = *s - '0';
  800b8e:	0f be c9             	movsbl %cl,%ecx
  800b91:	83 e9 30             	sub    $0x30,%ecx
  800b94:	eb 1e                	jmp    800bb4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800b96:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800b99:	80 fb 19             	cmp    $0x19,%bl
  800b9c:	77 08                	ja     800ba6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800b9e:	0f be c9             	movsbl %cl,%ecx
  800ba1:	83 e9 57             	sub    $0x57,%ecx
  800ba4:	eb 0e                	jmp    800bb4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ba6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ba9:	80 fb 19             	cmp    $0x19,%bl
  800bac:	77 12                	ja     800bc0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800bae:	0f be c9             	movsbl %cl,%ecx
  800bb1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bb4:	39 f1                	cmp    %esi,%ecx
  800bb6:	7d 0c                	jge    800bc4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800bb8:	42                   	inc    %edx
  800bb9:	0f af c6             	imul   %esi,%eax
  800bbc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800bbe:	eb c4                	jmp    800b84 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800bc0:	89 c1                	mov    %eax,%ecx
  800bc2:	eb 02                	jmp    800bc6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800bc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bca:	74 05                	je     800bd1 <strtol+0xbd>
		*endptr = (char *) s;
  800bcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bcf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bd1:	85 ff                	test   %edi,%edi
  800bd3:	74 04                	je     800bd9 <strtol+0xc5>
  800bd5:	89 c8                	mov    %ecx,%eax
  800bd7:	f7 d8                	neg    %eax
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
	...

00800be0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	57                   	push   %edi
  800be4:	56                   	push   %esi
  800be5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bee:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	89 c6                	mov    %eax,%esi
  800bf7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
  800c09:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 d3                	mov    %edx,%ebx
  800c12:	89 d7                	mov    %edx,%edi
  800c14:	89 d6                	mov    %edx,%esi
  800c16:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c18:	5b                   	pop    %ebx
  800c19:	5e                   	pop    %esi
  800c1a:	5f                   	pop    %edi
  800c1b:	5d                   	pop    %ebp
  800c1c:	c3                   	ret    

00800c1d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	57                   	push   %edi
  800c21:	56                   	push   %esi
  800c22:	53                   	push   %ebx
  800c23:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c26:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c2b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c30:	8b 55 08             	mov    0x8(%ebp),%edx
  800c33:	89 cb                	mov    %ecx,%ebx
  800c35:	89 cf                	mov    %ecx,%edi
  800c37:	89 ce                	mov    %ecx,%esi
  800c39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	7e 28                	jle    800c67 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c43:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800c4a:	00 
  800c4b:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800c52:	00 
  800c53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800c5a:	00 
  800c5b:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800c62:	e8 49 15 00 00       	call   8021b0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c67:	83 c4 2c             	add    $0x2c,%esp
  800c6a:	5b                   	pop    %ebx
  800c6b:	5e                   	pop    %esi
  800c6c:	5f                   	pop    %edi
  800c6d:	5d                   	pop    %ebp
  800c6e:	c3                   	ret    

00800c6f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	57                   	push   %edi
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c75:	ba 00 00 00 00       	mov    $0x0,%edx
  800c7a:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7f:	89 d1                	mov    %edx,%ecx
  800c81:	89 d3                	mov    %edx,%ebx
  800c83:	89 d7                	mov    %edx,%edi
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c89:	5b                   	pop    %ebx
  800c8a:	5e                   	pop    %esi
  800c8b:	5f                   	pop    %edi
  800c8c:	5d                   	pop    %ebp
  800c8d:	c3                   	ret    

00800c8e <sys_yield>:

void
sys_yield(void)
{
  800c8e:	55                   	push   %ebp
  800c8f:	89 e5                	mov    %esp,%ebp
  800c91:	57                   	push   %edi
  800c92:	56                   	push   %esi
  800c93:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c94:	ba 00 00 00 00       	mov    $0x0,%edx
  800c99:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c9e:	89 d1                	mov    %edx,%ecx
  800ca0:	89 d3                	mov    %edx,%ebx
  800ca2:	89 d7                	mov    %edx,%edi
  800ca4:	89 d6                	mov    %edx,%esi
  800ca6:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
  800cb3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb6:	be 00 00 00 00       	mov    $0x0,%esi
  800cbb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cc0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc9:	89 f7                	mov    %esi,%edi
  800ccb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ccd:	85 c0                	test   %eax,%eax
  800ccf:	7e 28                	jle    800cf9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800cdc:	00 
  800cdd:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800ce4:	00 
  800ce5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cec:	00 
  800ced:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800cf4:	e8 b7 14 00 00       	call   8021b0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf9:	83 c4 2c             	add    $0x2c,%esp
  800cfc:	5b                   	pop    %ebx
  800cfd:	5e                   	pop    %esi
  800cfe:	5f                   	pop    %edi
  800cff:	5d                   	pop    %ebp
  800d00:	c3                   	ret    

00800d01 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
  800d07:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d0f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d20:	85 c0                	test   %eax,%eax
  800d22:	7e 28                	jle    800d4c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d28:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800d2f:	00 
  800d30:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d37:	00 
  800d38:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3f:	00 
  800d40:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d47:	e8 64 14 00 00       	call   8021b0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d4c:	83 c4 2c             	add    $0x2c,%esp
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
  800d5a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d62:	b8 06 00 00 00       	mov    $0x6,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	89 df                	mov    %ebx,%edi
  800d6f:	89 de                	mov    %ebx,%esi
  800d71:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d73:	85 c0                	test   %eax,%eax
  800d75:	7e 28                	jle    800d9f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d77:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d7b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800d82:	00 
  800d83:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d92:	00 
  800d93:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800d9a:	e8 11 14 00 00       	call   8021b0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d9f:	83 c4 2c             	add    $0x2c,%esp
  800da2:	5b                   	pop    %ebx
  800da3:	5e                   	pop    %esi
  800da4:	5f                   	pop    %edi
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	57                   	push   %edi
  800dab:	56                   	push   %esi
  800dac:	53                   	push   %ebx
  800dad:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db5:	b8 08 00 00 00       	mov    $0x8,%eax
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc0:	89 df                	mov    %ebx,%edi
  800dc2:	89 de                	mov    %ebx,%esi
  800dc4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 28                	jle    800df2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dce:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dd5:	00 
  800dd6:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800ddd:	00 
  800dde:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de5:	00 
  800de6:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800ded:	e8 be 13 00 00       	call   8021b0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df2:	83 c4 2c             	add    $0x2c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    

00800dfa <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	57                   	push   %edi
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e08:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	8b 55 08             	mov    0x8(%ebp),%edx
  800e13:	89 df                	mov    %ebx,%edi
  800e15:	89 de                	mov    %ebx,%esi
  800e17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e19:	85 c0                	test   %eax,%eax
  800e1b:	7e 28                	jle    800e45 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e21:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e28:	00 
  800e29:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e30:	00 
  800e31:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e38:	00 
  800e39:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e40:	e8 6b 13 00 00       	call   8021b0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e45:	83 c4 2c             	add    $0x2c,%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5f                   	pop    %edi
  800e4b:	5d                   	pop    %ebp
  800e4c:	c3                   	ret    

00800e4d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	57                   	push   %edi
  800e51:	56                   	push   %esi
  800e52:	53                   	push   %ebx
  800e53:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e56:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e63:	8b 55 08             	mov    0x8(%ebp),%edx
  800e66:	89 df                	mov    %ebx,%edi
  800e68:	89 de                	mov    %ebx,%esi
  800e6a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	7e 28                	jle    800e98 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e70:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e74:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800e7b:	00 
  800e7c:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800e83:	00 
  800e84:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8b:	00 
  800e8c:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800e93:	e8 18 13 00 00       	call   8021b0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e98:	83 c4 2c             	add    $0x2c,%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5f                   	pop    %edi
  800e9e:	5d                   	pop    %ebp
  800e9f:	c3                   	ret    

00800ea0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	57                   	push   %edi
  800ea4:	56                   	push   %esi
  800ea5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea6:	be 00 00 00 00       	mov    $0x0,%esi
  800eab:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb0:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebc:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5f                   	pop    %edi
  800ec1:	5d                   	pop    %ebp
  800ec2:	c3                   	ret    

00800ec3 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec3:	55                   	push   %ebp
  800ec4:	89 e5                	mov    %esp,%ebp
  800ec6:	57                   	push   %edi
  800ec7:	56                   	push   %esi
  800ec8:	53                   	push   %ebx
  800ec9:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed9:	89 cb                	mov    %ecx,%ebx
  800edb:	89 cf                	mov    %ecx,%edi
  800edd:	89 ce                	mov    %ecx,%esi
  800edf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee1:	85 c0                	test   %eax,%eax
  800ee3:	7e 28                	jle    800f0d <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 08 ff 28 80 	movl   $0x8028ff,0x8(%esp)
  800ef8:	00 
  800ef9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f00:	00 
  800f01:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  800f08:	e8 a3 12 00 00       	call   8021b0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f0d:	83 c4 2c             	add    $0x2c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	00 00                	add    %al,(%eax)
	...

00800f18 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	53                   	push   %ebx
  800f1c:	83 ec 24             	sub    $0x24,%esp
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f22:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if ((err & FEC_WR) == 0)
  800f24:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f28:	75 20                	jne    800f4a <pgfault+0x32>
		panic("pgfault: faulting address [%08x] not a write\n", addr);
  800f2a:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f2e:	c7 44 24 08 2c 29 80 	movl   $0x80292c,0x8(%esp)
  800f35:	00 
  800f36:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  800f3d:	00 
  800f3e:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  800f45:	e8 66 12 00 00       	call   8021b0 <_panic>

	void *page_aligned_addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f4a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t page_num = (uint32_t) page_aligned_addr / PGSIZE;
  800f50:	89 d8                	mov    %ebx,%eax
  800f52:	c1 e8 0c             	shr    $0xc,%eax
	if (!(uvpt[page_num] & PTE_COW))
  800f55:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5c:	f6 c4 08             	test   $0x8,%ah
  800f5f:	75 1c                	jne    800f7d <pgfault+0x65>
		panic("pgfault: fault was not on a copy-on-write page\n");
  800f61:	c7 44 24 08 5c 29 80 	movl   $0x80295c,0x8(%esp)
  800f68:	00 
  800f69:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  800f70:	00 
  800f71:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  800f78:	e8 33 12 00 00       	call   8021b0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc(0, PFTEMP, PTE_P|PTE_U|PTE_W)) < 0) {
  800f7d:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f94:	e8 14 fd ff ff       	call   800cad <sys_page_alloc>
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	79 20                	jns    800fbd <pgfault+0xa5>
		panic("sys_page_alloc: %e", r);
  800f9d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800fa1:	c7 44 24 08 b6 29 80 	movl   $0x8029b6,0x8(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  800fb0:	00 
  800fb1:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  800fb8:	e8 f3 11 00 00       	call   8021b0 <_panic>
	}
	addr = (void *)ROUNDDOWN(addr, PGSIZE);
	memmove(PFTEMP, addr, PGSIZE);
  800fbd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800fc4:	00 
  800fc5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800fc9:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  800fd0:	e8 5f fa ff ff       	call   800a34 <memmove>
	if ((r = sys_page_map(0, PFTEMP, 0, addr, PTE_P|PTE_U|PTE_W)) < 0) {
  800fd5:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800fdc:	00 
  800fdd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fe1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ff8:	e8 04 fd ff ff       	call   800d01 <sys_page_map>
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	79 20                	jns    801021 <pgfault+0x109>
		panic("sys_page_map: %e", r);
  801001:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801005:	c7 44 24 08 c9 29 80 	movl   $0x8029c9,0x8(%esp)
  80100c:	00 
  80100d:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801014:	00 
  801015:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  80101c:	e8 8f 11 00 00       	call   8021b0 <_panic>
	}
	// if ((r = sys_page_unmap(0, PFTEMP)) < 0) {
	// 	panic("sys_page_unmap: %e", r);
	// }
}
  801021:	83 c4 24             	add    $0x24,%esp
  801024:	5b                   	pop    %ebx
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	57                   	push   %edi
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
  80102d:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 4: Your code here.
	int r;
	envid_t envid;

	// First, set up page fault handler
	set_pgfault_handler(pgfault);
  801030:	c7 04 24 18 0f 80 00 	movl   $0x800f18,(%esp)
  801037:	e8 cc 11 00 00       	call   802208 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80103c:	ba 07 00 00 00       	mov    $0x7,%edx
  801041:	89 d0                	mov    %edx,%eax
  801043:	cd 30                	int    $0x30
  801045:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801048:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	// Second, create child process
	envid = sys_exofork();
	// On Error
	if (envid < 0) {
  80104b:	85 c0                	test   %eax,%eax
  80104d:	79 20                	jns    80106f <fork+0x48>
		panic("sys_exofork: %e", envid);
  80104f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801053:	c7 44 24 08 da 29 80 	movl   $0x8029da,0x8(%esp)
  80105a:	00 
  80105b:	c7 44 24 04 84 00 00 	movl   $0x84,0x4(%esp)
  801062:	00 
  801063:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  80106a:	e8 41 11 00 00       	call   8021b0 <_panic>
	}
	
	// Child process
	if (envid == 0) {
  80106f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801073:	75 25                	jne    80109a <fork+0x73>
		thisenv = &envs[ENVX(sys_getenvid())];
  801075:	e8 f5 fb ff ff       	call   800c6f <sys_getenvid>
  80107a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80107f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801086:	c1 e0 07             	shl    $0x7,%eax
  801089:	29 d0                	sub    %edx,%eax
  80108b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801090:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801095:	e9 58 02 00 00       	jmp    8012f2 <fork+0x2cb>
	if (envid < 0) {
		panic("sys_exofork: %e", envid);
	}
	
	// Child process
	if (envid == 0) {
  80109a:	bf 00 00 00 00       	mov    $0x0,%edi
  80109f:	be 00 00 00 00       	mov    $0x0,%esi
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
  8010a4:	89 f0                	mov    %esi,%eax
  8010a6:	c1 e8 0a             	shr    $0xa,%eax
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010a9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010b0:	a8 01                	test   $0x1,%al
  8010b2:	0f 84 7a 01 00 00    	je     801232 <fork+0x20b>
			((uvpt[page_num] & PTE_P) == PTE_P)) {
  8010b8:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
		uint32_t pdx = ROUNDDOWN(page_num, NPDENTRIES) / NPDENTRIES;
		if ((uvpd[pdx] & PTE_P) == PTE_P &&
  8010bf:	a8 01                	test   $0x1,%al
  8010c1:	0f 84 6b 01 00 00    	je     801232 <fork+0x20b>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
	envid_t this_envid = thisenv->env_id;
  8010c7:	a1 04 40 80 00       	mov    0x804004,%eax
  8010cc:	8b 40 48             	mov    0x48(%eax),%eax
  8010cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	// LAB 4: Your code here.
	// Reference from batmanW1's github
	if (uvpt[pn] & PTE_SHARE) {
  8010d2:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d9:	f6 c4 04             	test   $0x4,%ah
  8010dc:	74 52                	je     801130 <fork+0x109>
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8010de:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8010ea:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ee:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010f2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010f5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8010fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801100:	89 04 24             	mov    %eax,(%esp)
  801103:	e8 f9 fb ff ff       	call   800d01 <sys_page_map>
  801108:	85 c0                	test   %eax,%eax
  80110a:	0f 89 22 01 00 00    	jns    801232 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801110:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801114:	c7 44 24 08 ea 29 80 	movl   $0x8029ea,0x8(%esp)
  80111b:	00 
  80111c:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  801123:	00 
  801124:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  80112b:	e8 80 10 00 00       	call   8021b0 <_panic>
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
  801130:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801137:	f6 c4 08             	test   $0x8,%ah
  80113a:	75 0f                	jne    80114b <fork+0x124>
  80113c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801143:	a8 02                	test   $0x2,%al
  801145:	0f 84 99 00 00 00    	je     8011e4 <fork+0x1bd>
		if (uvpt[pn] & PTE_U)
  80114b:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801152:	83 e0 04             	and    $0x4,%eax
//
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	uint32_t perm = PTE_P | PTE_COW;
  801155:	83 f8 01             	cmp    $0x1,%eax
  801158:	19 db                	sbb    %ebx,%ebx
  80115a:	83 e3 fc             	and    $0xfffffffc,%ebx
  80115d:	81 c3 05 08 00 00    	add    $0x805,%ebx
	} else if (uvpt[pn] & PTE_COW || uvpt[pn] & PTE_W) {
		if (uvpt[pn] & PTE_U)
			perm |= PTE_U;

		// Map page COW, U and P in child
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), perm)) < 0)
  801163:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801167:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80116b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80116e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801172:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801176:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801179:	89 04 24             	mov    %eax,(%esp)
  80117c:	e8 80 fb ff ff       	call   800d01 <sys_page_map>
  801181:	85 c0                	test   %eax,%eax
  801183:	79 20                	jns    8011a5 <fork+0x17e>
			panic("sys_page_map: %e\n", r);
  801185:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801189:	c7 44 24 08 ea 29 80 	movl   $0x8029ea,0x8(%esp)
  801190:	00 
  801191:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
  801198:	00 
  801199:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  8011a0:	e8 0b 10 00 00       	call   8021b0 <_panic>

		// Map page COW, U and P in parent
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), this_envid, (void *) (pn*PGSIZE), perm)) < 0)
  8011a5:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8011a9:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011b8:	89 04 24             	mov    %eax,(%esp)
  8011bb:	e8 41 fb ff ff       	call   800d01 <sys_page_map>
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	79 6e                	jns    801232 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  8011c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c8:	c7 44 24 08 ea 29 80 	movl   $0x8029ea,0x8(%esp)
  8011cf:	00 
  8011d0:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  8011d7:	00 
  8011d8:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  8011df:	e8 cc 0f 00 00       	call   8021b0 <_panic>

	} else { // map pages that are present but not writable or COW with their original permissions
		if ((r = sys_page_map(this_envid, (void *) (pn*PGSIZE), envid, (void *) (pn*PGSIZE), uvpt[pn] & PTE_SYSCALL)) < 0)
  8011e4:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011f4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8011f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011ff:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801203:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801206:	89 04 24             	mov    %eax,(%esp)
  801209:	e8 f3 fa ff ff       	call   800d01 <sys_page_map>
  80120e:	85 c0                	test   %eax,%eax
  801210:	79 20                	jns    801232 <fork+0x20b>
			panic("sys_page_map: %e\n", r);
  801212:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801216:	c7 44 24 08 ea 29 80 	movl   $0x8029ea,0x8(%esp)
  80121d:	00 
  80121e:	c7 44 24 04 60 00 00 	movl   $0x60,0x4(%esp)
  801225:	00 
  801226:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  80122d:	e8 7e 0f 00 00       	call   8021b0 <_panic>
	// Iterate over all pages until UTOP. Map all pages that are present
	// and let duppage worry about the permissions.
	// Note that we don't remap anything above UTOP because the kernel took
	// care of that for us in env_setup_vm().
	uint32_t page_num;
	for (page_num = 0; page_num < PGNUM(USTACKTOP); page_num++) {
  801232:	46                   	inc    %esi
  801233:	81 c7 00 10 00 00    	add    $0x1000,%edi
  801239:	81 fe fe eb 0e 00    	cmp    $0xeebfe,%esi
  80123f:	0f 85 5f fe ff ff    	jne    8010a4 <fork+0x7d>
				duppage(envid, page_num);
		}
	}
	
	// Set environment id for child process
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0) {
  801245:	c7 44 24 04 a8 22 80 	movl   $0x8022a8,0x4(%esp)
  80124c:	00 
  80124d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801250:	89 04 24             	mov    %eax,(%esp)
  801253:	e8 f5 fb ff ff       	call   800e4d <sys_env_set_pgfault_upcall>
  801258:	85 c0                	test   %eax,%eax
  80125a:	79 20                	jns    80127c <fork+0x255>
		panic("sys_env_set_pgfault_upcall: %e", r);
  80125c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801260:	c7 44 24 08 8c 29 80 	movl   $0x80298c,0x8(%esp)
  801267:	00 
  801268:	c7 44 24 04 9d 00 00 	movl   $0x9d,0x4(%esp)
  80126f:	00 
  801270:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  801277:	e8 34 0f 00 00       	call   8021b0 <_panic>
	}
	
	// Allocate a new page for child process for its user exception stack
	if ((r = sys_page_alloc(envid, (void *)(UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W)) < 0) {
  80127c:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801283:	00 
  801284:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80128b:	ee 
  80128c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80128f:	89 04 24             	mov    %eax,(%esp)
  801292:	e8 16 fa ff ff       	call   800cad <sys_page_alloc>
  801297:	85 c0                	test   %eax,%eax
  801299:	79 20                	jns    8012bb <fork+0x294>
		panic("sys_page_alloc: %e", r);
  80129b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80129f:	c7 44 24 08 b6 29 80 	movl   $0x8029b6,0x8(%esp)
  8012a6:	00 
  8012a7:	c7 44 24 04 a2 00 00 	movl   $0xa2,0x4(%esp)
  8012ae:	00 
  8012af:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  8012b6:	e8 f5 0e 00 00       	call   8021b0 <_panic>
	}
	
	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0) {
  8012bb:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012c2:	00 
  8012c3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c6:	89 04 24             	mov    %eax,(%esp)
  8012c9:	e8 d9 fa ff ff       	call   800da7 <sys_env_set_status>
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	79 20                	jns    8012f2 <fork+0x2cb>
		panic("sys_env_set_status: %e", r);
  8012d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012d6:	c7 44 24 08 fc 29 80 	movl   $0x8029fc,0x8(%esp)
  8012dd:	00 
  8012de:	c7 44 24 04 a7 00 00 	movl   $0xa7,0x4(%esp)
  8012e5:	00 
  8012e6:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  8012ed:	e8 be 0e 00 00       	call   8021b0 <_panic>
	}
	
	return envid;
}
  8012f2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012f5:	83 c4 3c             	add    $0x3c,%esp
  8012f8:	5b                   	pop    %ebx
  8012f9:	5e                   	pop    %esi
  8012fa:	5f                   	pop    %edi
  8012fb:	5d                   	pop    %ebp
  8012fc:	c3                   	ret    

008012fd <sfork>:

// Challenge!
int
sfork(void)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801303:	c7 44 24 08 13 2a 80 	movl   $0x802a13,0x8(%esp)
  80130a:	00 
  80130b:	c7 44 24 04 b1 00 00 	movl   $0xb1,0x4(%esp)
  801312:	00 
  801313:	c7 04 24 ab 29 80 00 	movl   $0x8029ab,(%esp)
  80131a:	e8 91 0e 00 00       	call   8021b0 <_panic>
	...

00801320 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	56                   	push   %esi
  801324:	53                   	push   %ebx
  801325:	83 ec 10             	sub    $0x10,%esp
  801328:	8b 75 08             	mov    0x8(%ebp),%esi
  80132b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801331:	85 c0                	test   %eax,%eax
  801333:	75 05                	jne    80133a <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801335:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  80133a:	89 04 24             	mov    %eax,(%esp)
  80133d:	e8 81 fb ff ff       	call   800ec3 <sys_ipc_recv>
	if (!err) {
  801342:	85 c0                	test   %eax,%eax
  801344:	75 26                	jne    80136c <ipc_recv+0x4c>
		if (from_env_store) {
  801346:	85 f6                	test   %esi,%esi
  801348:	74 0a                	je     801354 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  80134a:	a1 04 40 80 00       	mov    0x804004,%eax
  80134f:	8b 40 74             	mov    0x74(%eax),%eax
  801352:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801354:	85 db                	test   %ebx,%ebx
  801356:	74 0a                	je     801362 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801358:	a1 04 40 80 00       	mov    0x804004,%eax
  80135d:	8b 40 78             	mov    0x78(%eax),%eax
  801360:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801362:	a1 04 40 80 00       	mov    0x804004,%eax
  801367:	8b 40 70             	mov    0x70(%eax),%eax
  80136a:	eb 14                	jmp    801380 <ipc_recv+0x60>
	}
	if (from_env_store) {
  80136c:	85 f6                	test   %esi,%esi
  80136e:	74 06                	je     801376 <ipc_recv+0x56>
		*from_env_store = 0;
  801370:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801376:	85 db                	test   %ebx,%ebx
  801378:	74 06                	je     801380 <ipc_recv+0x60>
		*perm_store = 0;
  80137a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801380:	83 c4 10             	add    $0x10,%esp
  801383:	5b                   	pop    %ebx
  801384:	5e                   	pop    %esi
  801385:	5d                   	pop    %ebp
  801386:	c3                   	ret    

00801387 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	57                   	push   %edi
  80138b:	56                   	push   %esi
  80138c:	53                   	push   %ebx
  80138d:	83 ec 1c             	sub    $0x1c,%esp
  801390:	8b 75 10             	mov    0x10(%ebp),%esi
  801393:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801396:	85 f6                	test   %esi,%esi
  801398:	75 05                	jne    80139f <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  80139a:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80139f:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013a3:	89 74 24 08          	mov    %esi,0x8(%esp)
  8013a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b1:	89 04 24             	mov    %eax,(%esp)
  8013b4:	e8 e7 fa ff ff       	call   800ea0 <sys_ipc_try_send>
  8013b9:	89 c3                	mov    %eax,%ebx
		sys_yield();
  8013bb:	e8 ce f8 ff ff       	call   800c8e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  8013c0:	83 fb f9             	cmp    $0xfffffff9,%ebx
  8013c3:	74 da                	je     80139f <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  8013c5:	85 db                	test   %ebx,%ebx
  8013c7:	74 20                	je     8013e9 <ipc_send+0x62>
		panic("send fail: %e", err);
  8013c9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8013cd:	c7 44 24 08 29 2a 80 	movl   $0x802a29,0x8(%esp)
  8013d4:	00 
  8013d5:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  8013dc:	00 
  8013dd:	c7 04 24 37 2a 80 00 	movl   $0x802a37,(%esp)
  8013e4:	e8 c7 0d 00 00       	call   8021b0 <_panic>
	}
	return;
}
  8013e9:	83 c4 1c             	add    $0x1c,%esp
  8013ec:	5b                   	pop    %ebx
  8013ed:	5e                   	pop    %esi
  8013ee:	5f                   	pop    %edi
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	53                   	push   %ebx
  8013f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  8013f8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013fd:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801404:	89 c2                	mov    %eax,%edx
  801406:	c1 e2 07             	shl    $0x7,%edx
  801409:	29 ca                	sub    %ecx,%edx
  80140b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801411:	8b 52 50             	mov    0x50(%edx),%edx
  801414:	39 da                	cmp    %ebx,%edx
  801416:	75 0f                	jne    801427 <ipc_find_env+0x36>
			return envs[i].env_id;
  801418:	c1 e0 07             	shl    $0x7,%eax
  80141b:	29 c8                	sub    %ecx,%eax
  80141d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801422:	8b 40 40             	mov    0x40(%eax),%eax
  801425:	eb 0c                	jmp    801433 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801427:	40                   	inc    %eax
  801428:	3d 00 04 00 00       	cmp    $0x400,%eax
  80142d:	75 ce                	jne    8013fd <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80142f:	66 b8 00 00          	mov    $0x0,%ax
}
  801433:	5b                   	pop    %ebx
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    
	...

00801438 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	05 00 00 00 30       	add    $0x30000000,%eax
  801443:	c1 e8 0c             	shr    $0xc,%eax
}
  801446:	5d                   	pop    %ebp
  801447:	c3                   	ret    

00801448 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	89 04 24             	mov    %eax,(%esp)
  801454:	e8 df ff ff ff       	call   801438 <fd2num>
  801459:	05 20 00 0d 00       	add    $0xd0020,%eax
  80145e:	c1 e0 0c             	shl    $0xc,%eax
}
  801461:	c9                   	leave  
  801462:	c3                   	ret    

00801463 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	53                   	push   %ebx
  801467:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80146a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80146f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801471:	89 c2                	mov    %eax,%edx
  801473:	c1 ea 16             	shr    $0x16,%edx
  801476:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80147d:	f6 c2 01             	test   $0x1,%dl
  801480:	74 11                	je     801493 <fd_alloc+0x30>
  801482:	89 c2                	mov    %eax,%edx
  801484:	c1 ea 0c             	shr    $0xc,%edx
  801487:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80148e:	f6 c2 01             	test   $0x1,%dl
  801491:	75 09                	jne    80149c <fd_alloc+0x39>
			*fd_store = fd;
  801493:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
  80149a:	eb 17                	jmp    8014b3 <fd_alloc+0x50>
  80149c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014a1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014a6:	75 c7                	jne    80146f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  8014ae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8014b3:	5b                   	pop    %ebx
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014bc:	83 f8 1f             	cmp    $0x1f,%eax
  8014bf:	77 36                	ja     8014f7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014c1:	05 00 00 0d 00       	add    $0xd0000,%eax
  8014c6:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014c9:	89 c2                	mov    %eax,%edx
  8014cb:	c1 ea 16             	shr    $0x16,%edx
  8014ce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014d5:	f6 c2 01             	test   $0x1,%dl
  8014d8:	74 24                	je     8014fe <fd_lookup+0x48>
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	c1 ea 0c             	shr    $0xc,%edx
  8014df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 1a                	je     801505 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ee:	89 02                	mov    %eax,(%edx)
	return 0;
  8014f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8014f5:	eb 13                	jmp    80150a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014fc:	eb 0c                	jmp    80150a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801503:	eb 05                	jmp    80150a <fd_lookup+0x54>
  801505:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	53                   	push   %ebx
  801510:	83 ec 14             	sub    $0x14,%esp
  801513:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801516:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  801519:	ba 00 00 00 00       	mov    $0x0,%edx
  80151e:	eb 0e                	jmp    80152e <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  801520:	39 08                	cmp    %ecx,(%eax)
  801522:	75 09                	jne    80152d <dev_lookup+0x21>
			*dev = devtab[i];
  801524:	89 03                	mov    %eax,(%ebx)
			return 0;
  801526:	b8 00 00 00 00       	mov    $0x0,%eax
  80152b:	eb 33                	jmp    801560 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80152d:	42                   	inc    %edx
  80152e:	8b 04 95 c0 2a 80 00 	mov    0x802ac0(,%edx,4),%eax
  801535:	85 c0                	test   %eax,%eax
  801537:	75 e7                	jne    801520 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801539:	a1 04 40 80 00       	mov    0x804004,%eax
  80153e:	8b 40 48             	mov    0x48(%eax),%eax
  801541:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801545:	89 44 24 04          	mov    %eax,0x4(%esp)
  801549:	c7 04 24 44 2a 80 00 	movl   $0x802a44,(%esp)
  801550:	e8 9b ed ff ff       	call   8002f0 <cprintf>
	*dev = 0;
  801555:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  80155b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801560:	83 c4 14             	add    $0x14,%esp
  801563:	5b                   	pop    %ebx
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	56                   	push   %esi
  80156a:	53                   	push   %ebx
  80156b:	83 ec 30             	sub    $0x30,%esp
  80156e:	8b 75 08             	mov    0x8(%ebp),%esi
  801571:	8a 45 0c             	mov    0xc(%ebp),%al
  801574:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801577:	89 34 24             	mov    %esi,(%esp)
  80157a:	e8 b9 fe ff ff       	call   801438 <fd2num>
  80157f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801582:	89 54 24 04          	mov    %edx,0x4(%esp)
  801586:	89 04 24             	mov    %eax,(%esp)
  801589:	e8 28 ff ff ff       	call   8014b6 <fd_lookup>
  80158e:	89 c3                	mov    %eax,%ebx
  801590:	85 c0                	test   %eax,%eax
  801592:	78 05                	js     801599 <fd_close+0x33>
	    || fd != fd2)
  801594:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801597:	74 0d                	je     8015a6 <fd_close+0x40>
		return (must_exist ? r : 0);
  801599:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80159d:	75 46                	jne    8015e5 <fd_close+0x7f>
  80159f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015a4:	eb 3f                	jmp    8015e5 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ad:	8b 06                	mov    (%esi),%eax
  8015af:	89 04 24             	mov    %eax,(%esp)
  8015b2:	e8 55 ff ff ff       	call   80150c <dev_lookup>
  8015b7:	89 c3                	mov    %eax,%ebx
  8015b9:	85 c0                	test   %eax,%eax
  8015bb:	78 18                	js     8015d5 <fd_close+0x6f>
		if (dev->dev_close)
  8015bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015c0:	8b 40 10             	mov    0x10(%eax),%eax
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	74 09                	je     8015d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8015c7:	89 34 24             	mov    %esi,(%esp)
  8015ca:	ff d0                	call   *%eax
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	eb 05                	jmp    8015d5 <fd_close+0x6f>
		else
			r = 0;
  8015d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8015d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e0:	e8 6f f7 ff ff       	call   800d54 <sys_page_unmap>
	return r;
}
  8015e5:	89 d8                	mov    %ebx,%eax
  8015e7:	83 c4 30             	add    $0x30,%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	89 04 24             	mov    %eax,(%esp)
  801601:	e8 b0 fe ff ff       	call   8014b6 <fd_lookup>
  801606:	85 c0                	test   %eax,%eax
  801608:	78 13                	js     80161d <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  80160a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801611:	00 
  801612:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801615:	89 04 24             	mov    %eax,(%esp)
  801618:	e8 49 ff ff ff       	call   801566 <fd_close>
}
  80161d:	c9                   	leave  
  80161e:	c3                   	ret    

0080161f <close_all>:

void
close_all(void)
{
  80161f:	55                   	push   %ebp
  801620:	89 e5                	mov    %esp,%ebp
  801622:	53                   	push   %ebx
  801623:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801626:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80162b:	89 1c 24             	mov    %ebx,(%esp)
  80162e:	e8 bb ff ff ff       	call   8015ee <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801633:	43                   	inc    %ebx
  801634:	83 fb 20             	cmp    $0x20,%ebx
  801637:	75 f2                	jne    80162b <close_all+0xc>
		close(i);
}
  801639:	83 c4 14             	add    $0x14,%esp
  80163c:	5b                   	pop    %ebx
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	57                   	push   %edi
  801643:	56                   	push   %esi
  801644:	53                   	push   %ebx
  801645:	83 ec 4c             	sub    $0x4c,%esp
  801648:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80164b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80164e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801652:	8b 45 08             	mov    0x8(%ebp),%eax
  801655:	89 04 24             	mov    %eax,(%esp)
  801658:	e8 59 fe ff ff       	call   8014b6 <fd_lookup>
  80165d:	89 c3                	mov    %eax,%ebx
  80165f:	85 c0                	test   %eax,%eax
  801661:	0f 88 e1 00 00 00    	js     801748 <dup+0x109>
		return r;
	close(newfdnum);
  801667:	89 3c 24             	mov    %edi,(%esp)
  80166a:	e8 7f ff ff ff       	call   8015ee <close>

	newfd = INDEX2FD(newfdnum);
  80166f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801675:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801678:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167b:	89 04 24             	mov    %eax,(%esp)
  80167e:	e8 c5 fd ff ff       	call   801448 <fd2data>
  801683:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801685:	89 34 24             	mov    %esi,(%esp)
  801688:	e8 bb fd ff ff       	call   801448 <fd2data>
  80168d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801690:	89 d8                	mov    %ebx,%eax
  801692:	c1 e8 16             	shr    $0x16,%eax
  801695:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169c:	a8 01                	test   $0x1,%al
  80169e:	74 46                	je     8016e6 <dup+0xa7>
  8016a0:	89 d8                	mov    %ebx,%eax
  8016a2:	c1 e8 0c             	shr    $0xc,%eax
  8016a5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ac:	f6 c2 01             	test   $0x1,%dl
  8016af:	74 35                	je     8016e6 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8016bd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016cf:	00 
  8016d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016db:	e8 21 f6 ff ff       	call   800d01 <sys_page_map>
  8016e0:	89 c3                	mov    %eax,%ebx
  8016e2:	85 c0                	test   %eax,%eax
  8016e4:	78 3b                	js     801721 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	c1 ea 0c             	shr    $0xc,%edx
  8016ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016f5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8016ff:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801703:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170a:	00 
  80170b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80170f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801716:	e8 e6 f5 ff ff       	call   800d01 <sys_page_map>
  80171b:	89 c3                	mov    %eax,%ebx
  80171d:	85 c0                	test   %eax,%eax
  80171f:	79 25                	jns    801746 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801721:	89 74 24 04          	mov    %esi,0x4(%esp)
  801725:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80172c:	e8 23 f6 ff ff       	call   800d54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801731:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801734:	89 44 24 04          	mov    %eax,0x4(%esp)
  801738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80173f:	e8 10 f6 ff ff       	call   800d54 <sys_page_unmap>
	return r;
  801744:	eb 02                	jmp    801748 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  801746:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801748:	89 d8                	mov    %ebx,%eax
  80174a:	83 c4 4c             	add    $0x4c,%esp
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5f                   	pop    %edi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	53                   	push   %ebx
  801756:	83 ec 24             	sub    $0x24,%esp
  801759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80175c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	89 1c 24             	mov    %ebx,(%esp)
  801766:	e8 4b fd ff ff       	call   8014b6 <fd_lookup>
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 6d                	js     8017dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801772:	89 44 24 04          	mov    %eax,0x4(%esp)
  801776:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801779:	8b 00                	mov    (%eax),%eax
  80177b:	89 04 24             	mov    %eax,(%esp)
  80177e:	e8 89 fd ff ff       	call   80150c <dev_lookup>
  801783:	85 c0                	test   %eax,%eax
  801785:	78 55                	js     8017dc <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801787:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80178a:	8b 50 08             	mov    0x8(%eax),%edx
  80178d:	83 e2 03             	and    $0x3,%edx
  801790:	83 fa 01             	cmp    $0x1,%edx
  801793:	75 23                	jne    8017b8 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801795:	a1 04 40 80 00       	mov    0x804004,%eax
  80179a:	8b 40 48             	mov    0x48(%eax),%eax
  80179d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a5:	c7 04 24 85 2a 80 00 	movl   $0x802a85,(%esp)
  8017ac:	e8 3f eb ff ff       	call   8002f0 <cprintf>
		return -E_INVAL;
  8017b1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017b6:	eb 24                	jmp    8017dc <read+0x8a>
	}
	if (!dev->dev_read)
  8017b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bb:	8b 52 08             	mov    0x8(%edx),%edx
  8017be:	85 d2                	test   %edx,%edx
  8017c0:	74 15                	je     8017d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8017c5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8017c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8017d0:	89 04 24             	mov    %eax,(%esp)
  8017d3:	ff d2                	call   *%edx
  8017d5:	eb 05                	jmp    8017dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  8017dc:	83 c4 24             	add    $0x24,%esp
  8017df:	5b                   	pop    %ebx
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	57                   	push   %edi
  8017e6:	56                   	push   %esi
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 1c             	sub    $0x1c,%esp
  8017eb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017ee:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017f6:	eb 23                	jmp    80181b <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f8:	89 f0                	mov    %esi,%eax
  8017fa:	29 d8                	sub    %ebx,%eax
  8017fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  801800:	8b 45 0c             	mov    0xc(%ebp),%eax
  801803:	01 d8                	add    %ebx,%eax
  801805:	89 44 24 04          	mov    %eax,0x4(%esp)
  801809:	89 3c 24             	mov    %edi,(%esp)
  80180c:	e8 41 ff ff ff       	call   801752 <read>
		if (m < 0)
  801811:	85 c0                	test   %eax,%eax
  801813:	78 10                	js     801825 <readn+0x43>
			return m;
		if (m == 0)
  801815:	85 c0                	test   %eax,%eax
  801817:	74 0a                	je     801823 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801819:	01 c3                	add    %eax,%ebx
  80181b:	39 f3                	cmp    %esi,%ebx
  80181d:	72 d9                	jb     8017f8 <readn+0x16>
  80181f:	89 d8                	mov    %ebx,%eax
  801821:	eb 02                	jmp    801825 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  801823:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  801825:	83 c4 1c             	add    $0x1c,%esp
  801828:	5b                   	pop    %ebx
  801829:	5e                   	pop    %esi
  80182a:	5f                   	pop    %edi
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    

0080182d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	53                   	push   %ebx
  801831:	83 ec 24             	sub    $0x24,%esp
  801834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801837:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80183a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80183e:	89 1c 24             	mov    %ebx,(%esp)
  801841:	e8 70 fc ff ff       	call   8014b6 <fd_lookup>
  801846:	85 c0                	test   %eax,%eax
  801848:	78 68                	js     8018b2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80184a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801854:	8b 00                	mov    (%eax),%eax
  801856:	89 04 24             	mov    %eax,(%esp)
  801859:	e8 ae fc ff ff       	call   80150c <dev_lookup>
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 50                	js     8018b2 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801862:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801865:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801869:	75 23                	jne    80188e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80186b:	a1 04 40 80 00       	mov    0x804004,%eax
  801870:	8b 40 48             	mov    0x48(%eax),%eax
  801873:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80187b:	c7 04 24 a1 2a 80 00 	movl   $0x802aa1,(%esp)
  801882:	e8 69 ea ff ff       	call   8002f0 <cprintf>
		return -E_INVAL;
  801887:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80188c:	eb 24                	jmp    8018b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80188e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801891:	8b 52 0c             	mov    0xc(%edx),%edx
  801894:	85 d2                	test   %edx,%edx
  801896:	74 15                	je     8018ad <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801898:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80189b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80189f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018a2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	ff d2                	call   *%edx
  8018ab:	eb 05                	jmp    8018b2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  8018b2:	83 c4 24             	add    $0x24,%esp
  8018b5:	5b                   	pop    %ebx
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    

008018b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018b8:	55                   	push   %ebp
  8018b9:	89 e5                	mov    %esp,%ebp
  8018bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	89 04 24             	mov    %eax,(%esp)
  8018cb:	e8 e6 fb ff ff       	call   8014b6 <fd_lookup>
  8018d0:	85 c0                	test   %eax,%eax
  8018d2:	78 0e                	js     8018e2 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8018d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 24             	sub    $0x24,%esp
  8018eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018f5:	89 1c 24             	mov    %ebx,(%esp)
  8018f8:	e8 b9 fb ff ff       	call   8014b6 <fd_lookup>
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 61                	js     801962 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801904:	89 44 24 04          	mov    %eax,0x4(%esp)
  801908:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190b:	8b 00                	mov    (%eax),%eax
  80190d:	89 04 24             	mov    %eax,(%esp)
  801910:	e8 f7 fb ff ff       	call   80150c <dev_lookup>
  801915:	85 c0                	test   %eax,%eax
  801917:	78 49                	js     801962 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801919:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80191c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801920:	75 23                	jne    801945 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801922:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801927:	8b 40 48             	mov    0x48(%eax),%eax
  80192a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80192e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801932:	c7 04 24 64 2a 80 00 	movl   $0x802a64,(%esp)
  801939:	e8 b2 e9 ff ff       	call   8002f0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80193e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801943:	eb 1d                	jmp    801962 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  801945:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801948:	8b 52 18             	mov    0x18(%edx),%edx
  80194b:	85 d2                	test   %edx,%edx
  80194d:	74 0e                	je     80195d <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80194f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801952:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801956:	89 04 24             	mov    %eax,(%esp)
  801959:	ff d2                	call   *%edx
  80195b:	eb 05                	jmp    801962 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80195d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801962:	83 c4 24             	add    $0x24,%esp
  801965:	5b                   	pop    %ebx
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	83 ec 24             	sub    $0x24,%esp
  80196f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801972:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801975:	89 44 24 04          	mov    %eax,0x4(%esp)
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	89 04 24             	mov    %eax,(%esp)
  80197f:	e8 32 fb ff ff       	call   8014b6 <fd_lookup>
  801984:	85 c0                	test   %eax,%eax
  801986:	78 52                	js     8019da <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801988:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80198f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801992:	8b 00                	mov    (%eax),%eax
  801994:	89 04 24             	mov    %eax,(%esp)
  801997:	e8 70 fb ff ff       	call   80150c <dev_lookup>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 3a                	js     8019da <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019a7:	74 2c                	je     8019d5 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019b3:	00 00 00 
	stat->st_isdir = 0;
  8019b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019bd:	00 00 00 
	stat->st_dev = dev;
  8019c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019c6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8019ca:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019cd:	89 14 24             	mov    %edx,(%esp)
  8019d0:	ff 50 14             	call   *0x14(%eax)
  8019d3:	eb 05                	jmp    8019da <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019d5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019da:	83 c4 24             	add    $0x24,%esp
  8019dd:	5b                   	pop    %ebx
  8019de:	5d                   	pop    %ebp
  8019df:	c3                   	ret    

008019e0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019e0:	55                   	push   %ebp
  8019e1:	89 e5                	mov    %esp,%ebp
  8019e3:	56                   	push   %esi
  8019e4:	53                   	push   %ebx
  8019e5:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019e8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019ef:	00 
  8019f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f3:	89 04 24             	mov    %eax,(%esp)
  8019f6:	e8 fe 01 00 00       	call   801bf9 <open>
  8019fb:	89 c3                	mov    %eax,%ebx
  8019fd:	85 c0                	test   %eax,%eax
  8019ff:	78 1b                	js     801a1c <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  801a01:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a04:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a08:	89 1c 24             	mov    %ebx,(%esp)
  801a0b:	e8 58 ff ff ff       	call   801968 <fstat>
  801a10:	89 c6                	mov    %eax,%esi
	close(fd);
  801a12:	89 1c 24             	mov    %ebx,(%esp)
  801a15:	e8 d4 fb ff ff       	call   8015ee <close>
	return r;
  801a1a:	89 f3                	mov    %esi,%ebx
}
  801a1c:	89 d8                	mov    %ebx,%eax
  801a1e:	83 c4 10             	add    $0x10,%esp
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5d                   	pop    %ebp
  801a24:	c3                   	ret    
  801a25:	00 00                	add    %al,(%eax)
	...

00801a28 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	56                   	push   %esi
  801a2c:	53                   	push   %ebx
  801a2d:	83 ec 10             	sub    $0x10,%esp
  801a30:	89 c3                	mov    %eax,%ebx
  801a32:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801a34:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a3b:	75 11                	jne    801a4e <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a3d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  801a44:	e8 a8 f9 ff ff       	call   8013f1 <ipc_find_env>
  801a49:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a4e:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801a55:	00 
  801a56:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801a5d:	00 
  801a5e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a62:	a1 00 40 80 00       	mov    0x804000,%eax
  801a67:	89 04 24             	mov    %eax,(%esp)
  801a6a:	e8 18 f9 ff ff       	call   801387 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a76:	00 
  801a77:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a82:	e8 99 f8 ff ff       	call   801320 <ipc_recv>
}
  801a87:	83 c4 10             	add    $0x10,%esp
  801a8a:	5b                   	pop    %ebx
  801a8b:	5e                   	pop    %esi
  801a8c:	5d                   	pop    %ebp
  801a8d:	c3                   	ret    

00801a8e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a8e:	55                   	push   %ebp
  801a8f:	89 e5                	mov    %esp,%ebp
  801a91:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a94:	8b 45 08             	mov    0x8(%ebp),%eax
  801a97:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aa7:	ba 00 00 00 00       	mov    $0x0,%edx
  801aac:	b8 02 00 00 00       	mov    $0x2,%eax
  801ab1:	e8 72 ff ff ff       	call   801a28 <fsipc>
}
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ace:	b8 06 00 00 00       	mov    $0x6,%eax
  801ad3:	e8 50 ff ff ff       	call   801a28 <fsipc>
}
  801ad8:	c9                   	leave  
  801ad9:	c3                   	ret    

00801ada <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ada:	55                   	push   %ebp
  801adb:	89 e5                	mov    %esp,%ebp
  801add:	53                   	push   %ebx
  801ade:	83 ec 14             	sub    $0x14,%esp
  801ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae7:	8b 40 0c             	mov    0xc(%eax),%eax
  801aea:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aef:	ba 00 00 00 00       	mov    $0x0,%edx
  801af4:	b8 05 00 00 00       	mov    $0x5,%eax
  801af9:	e8 2a ff ff ff       	call   801a28 <fsipc>
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 2b                	js     801b2d <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b02:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801b09:	00 
  801b0a:	89 1c 24             	mov    %ebx,(%esp)
  801b0d:	e8 a9 ed ff ff       	call   8008bb <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b12:	a1 80 50 80 00       	mov    0x805080,%eax
  801b17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b1d:	a1 84 50 80 00       	mov    0x805084,%eax
  801b22:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b2d:	83 c4 14             	add    $0x14,%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5d                   	pop    %ebp
  801b32:	c3                   	ret    

00801b33 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  801b39:	c7 44 24 08 d0 2a 80 	movl   $0x802ad0,0x8(%esp)
  801b40:	00 
  801b41:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  801b48:	00 
  801b49:	c7 04 24 ee 2a 80 00 	movl   $0x802aee,(%esp)
  801b50:	e8 5b 06 00 00       	call   8021b0 <_panic>

00801b55 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	56                   	push   %esi
  801b59:	53                   	push   %ebx
  801b5a:	83 ec 10             	sub    $0x10,%esp
  801b5d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	8b 40 0c             	mov    0xc(%eax),%eax
  801b66:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b6b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
  801b76:	b8 03 00 00 00       	mov    $0x3,%eax
  801b7b:	e8 a8 fe ff ff       	call   801a28 <fsipc>
  801b80:	89 c3                	mov    %eax,%ebx
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 6a                	js     801bf0 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801b86:	39 c6                	cmp    %eax,%esi
  801b88:	73 24                	jae    801bae <devfile_read+0x59>
  801b8a:	c7 44 24 0c f9 2a 80 	movl   $0x802af9,0xc(%esp)
  801b91:	00 
  801b92:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801b99:	00 
  801b9a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801ba1:	00 
  801ba2:	c7 04 24 ee 2a 80 00 	movl   $0x802aee,(%esp)
  801ba9:	e8 02 06 00 00       	call   8021b0 <_panic>
	assert(r <= PGSIZE);
  801bae:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bb3:	7e 24                	jle    801bd9 <devfile_read+0x84>
  801bb5:	c7 44 24 0c 15 2b 80 	movl   $0x802b15,0xc(%esp)
  801bbc:	00 
  801bbd:	c7 44 24 08 00 2b 80 	movl   $0x802b00,0x8(%esp)
  801bc4:	00 
  801bc5:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  801bcc:	00 
  801bcd:	c7 04 24 ee 2a 80 00 	movl   $0x802aee,(%esp)
  801bd4:	e8 d7 05 00 00       	call   8021b0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bd9:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bdd:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801be4:	00 
  801be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be8:	89 04 24             	mov    %eax,(%esp)
  801beb:	e8 44 ee ff ff       	call   800a34 <memmove>
	return r;
}
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	83 c4 10             	add    $0x10,%esp
  801bf5:	5b                   	pop    %ebx
  801bf6:	5e                   	pop    %esi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    

00801bf9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bf9:	55                   	push   %ebp
  801bfa:	89 e5                	mov    %esp,%ebp
  801bfc:	56                   	push   %esi
  801bfd:	53                   	push   %ebx
  801bfe:	83 ec 20             	sub    $0x20,%esp
  801c01:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801c04:	89 34 24             	mov    %esi,(%esp)
  801c07:	e8 7c ec ff ff       	call   800888 <strlen>
  801c0c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c11:	7f 60                	jg     801c73 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c16:	89 04 24             	mov    %eax,(%esp)
  801c19:	e8 45 f8 ff ff       	call   801463 <fd_alloc>
  801c1e:	89 c3                	mov    %eax,%ebx
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 54                	js     801c78 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c28:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801c2f:	e8 87 ec ff ff       	call   8008bb <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c37:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c3f:	b8 01 00 00 00       	mov    $0x1,%eax
  801c44:	e8 df fd ff ff       	call   801a28 <fsipc>
  801c49:	89 c3                	mov    %eax,%ebx
  801c4b:	85 c0                	test   %eax,%eax
  801c4d:	79 15                	jns    801c64 <open+0x6b>
		fd_close(fd, 0);
  801c4f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c56:	00 
  801c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5a:	89 04 24             	mov    %eax,(%esp)
  801c5d:	e8 04 f9 ff ff       	call   801566 <fd_close>
		return r;
  801c62:	eb 14                	jmp    801c78 <open+0x7f>
	}

	return fd2num(fd);
  801c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c67:	89 04 24             	mov    %eax,(%esp)
  801c6a:	e8 c9 f7 ff ff       	call   801438 <fd2num>
  801c6f:	89 c3                	mov    %eax,%ebx
  801c71:	eb 05                	jmp    801c78 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c73:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c78:	89 d8                	mov    %ebx,%eax
  801c7a:	83 c4 20             	add    $0x20,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    

00801c81 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c81:	55                   	push   %ebp
  801c82:	89 e5                	mov    %esp,%ebp
  801c84:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c87:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8c:	b8 08 00 00 00       	mov    $0x8,%eax
  801c91:	e8 92 fd ff ff       	call   801a28 <fsipc>
}
  801c96:	c9                   	leave  
  801c97:	c3                   	ret    

00801c98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	56                   	push   %esi
  801c9c:	53                   	push   %ebx
  801c9d:	83 ec 10             	sub    $0x10,%esp
  801ca0:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	89 04 24             	mov    %eax,(%esp)
  801ca9:	e8 9a f7 ff ff       	call   801448 <fd2data>
  801cae:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801cb0:	c7 44 24 04 21 2b 80 	movl   $0x802b21,0x4(%esp)
  801cb7:	00 
  801cb8:	89 34 24             	mov    %esi,(%esp)
  801cbb:	e8 fb eb ff ff       	call   8008bb <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cc0:	8b 43 04             	mov    0x4(%ebx),%eax
  801cc3:	2b 03                	sub    (%ebx),%eax
  801cc5:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  801ccb:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801cd2:	00 00 00 
	stat->st_dev = &devpipe;
  801cd5:	c7 86 88 00 00 00 28 	movl   $0x803028,0x88(%esi)
  801cdc:	30 80 00 
	return 0;
}
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce4:	83 c4 10             	add    $0x10,%esp
  801ce7:	5b                   	pop    %ebx
  801ce8:	5e                   	pop    %esi
  801ce9:	5d                   	pop    %ebp
  801cea:	c3                   	ret    

00801ceb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	53                   	push   %ebx
  801cef:	83 ec 14             	sub    $0x14,%esp
  801cf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cf5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cf9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d00:	e8 4f f0 ff ff       	call   800d54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d05:	89 1c 24             	mov    %ebx,(%esp)
  801d08:	e8 3b f7 ff ff       	call   801448 <fd2data>
  801d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d18:	e8 37 f0 ff ff       	call   800d54 <sys_page_unmap>
}
  801d1d:	83 c4 14             	add    $0x14,%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	57                   	push   %edi
  801d27:	56                   	push   %esi
  801d28:	53                   	push   %ebx
  801d29:	83 ec 2c             	sub    $0x2c,%esp
  801d2c:	89 c7                	mov    %eax,%edi
  801d2e:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d31:	a1 04 40 80 00       	mov    0x804004,%eax
  801d36:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d39:	89 3c 24             	mov    %edi,(%esp)
  801d3c:	e8 8b 05 00 00       	call   8022cc <pageref>
  801d41:	89 c6                	mov    %eax,%esi
  801d43:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801d46:	89 04 24             	mov    %eax,(%esp)
  801d49:	e8 7e 05 00 00       	call   8022cc <pageref>
  801d4e:	39 c6                	cmp    %eax,%esi
  801d50:	0f 94 c0             	sete   %al
  801d53:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801d56:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d5c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d5f:	39 cb                	cmp    %ecx,%ebx
  801d61:	75 08                	jne    801d6b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801d63:	83 c4 2c             	add    $0x2c,%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5f                   	pop    %edi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  801d6b:	83 f8 01             	cmp    $0x1,%eax
  801d6e:	75 c1                	jne    801d31 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d70:	8b 42 58             	mov    0x58(%edx),%eax
  801d73:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  801d7a:	00 
  801d7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d7f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d83:	c7 04 24 28 2b 80 00 	movl   $0x802b28,(%esp)
  801d8a:	e8 61 e5 ff ff       	call   8002f0 <cprintf>
  801d8f:	eb a0                	jmp    801d31 <_pipeisclosed+0xe>

00801d91 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	57                   	push   %edi
  801d95:	56                   	push   %esi
  801d96:	53                   	push   %ebx
  801d97:	83 ec 1c             	sub    $0x1c,%esp
  801d9a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801d9d:	89 34 24             	mov    %esi,(%esp)
  801da0:	e8 a3 f6 ff ff       	call   801448 <fd2data>
  801da5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801da7:	bf 00 00 00 00       	mov    $0x0,%edi
  801dac:	eb 3c                	jmp    801dea <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801dae:	89 da                	mov    %ebx,%edx
  801db0:	89 f0                	mov    %esi,%eax
  801db2:	e8 6c ff ff ff       	call   801d23 <_pipeisclosed>
  801db7:	85 c0                	test   %eax,%eax
  801db9:	75 38                	jne    801df3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dbb:	e8 ce ee ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dc0:	8b 43 04             	mov    0x4(%ebx),%eax
  801dc3:	8b 13                	mov    (%ebx),%edx
  801dc5:	83 c2 20             	add    $0x20,%edx
  801dc8:	39 d0                	cmp    %edx,%eax
  801dca:	73 e2                	jae    801dae <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcf:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801dd2:	89 c2                	mov    %eax,%edx
  801dd4:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  801dda:	79 05                	jns    801de1 <devpipe_write+0x50>
  801ddc:	4a                   	dec    %edx
  801ddd:	83 ca e0             	or     $0xffffffe0,%edx
  801de0:	42                   	inc    %edx
  801de1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801de5:	40                   	inc    %eax
  801de6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de9:	47                   	inc    %edi
  801dea:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ded:	75 d1                	jne    801dc0 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801def:	89 f8                	mov    %edi,%eax
  801df1:	eb 05                	jmp    801df8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801df3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801df8:	83 c4 1c             	add    $0x1c,%esp
  801dfb:	5b                   	pop    %ebx
  801dfc:	5e                   	pop    %esi
  801dfd:	5f                   	pop    %edi
  801dfe:	5d                   	pop    %ebp
  801dff:	c3                   	ret    

00801e00 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	57                   	push   %edi
  801e04:	56                   	push   %esi
  801e05:	53                   	push   %ebx
  801e06:	83 ec 1c             	sub    $0x1c,%esp
  801e09:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e0c:	89 3c 24             	mov    %edi,(%esp)
  801e0f:	e8 34 f6 ff ff       	call   801448 <fd2data>
  801e14:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e16:	be 00 00 00 00       	mov    $0x0,%esi
  801e1b:	eb 3a                	jmp    801e57 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e1d:	85 f6                	test   %esi,%esi
  801e1f:	74 04                	je     801e25 <devpipe_read+0x25>
				return i;
  801e21:	89 f0                	mov    %esi,%eax
  801e23:	eb 40                	jmp    801e65 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e25:	89 da                	mov    %ebx,%edx
  801e27:	89 f8                	mov    %edi,%eax
  801e29:	e8 f5 fe ff ff       	call   801d23 <_pipeisclosed>
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	75 2e                	jne    801e60 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e32:	e8 57 ee ff ff       	call   800c8e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e37:	8b 03                	mov    (%ebx),%eax
  801e39:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e3c:	74 df                	je     801e1d <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e3e:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801e43:	79 05                	jns    801e4a <devpipe_read+0x4a>
  801e45:	48                   	dec    %eax
  801e46:	83 c8 e0             	or     $0xffffffe0,%eax
  801e49:	40                   	inc    %eax
  801e4a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  801e4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e51:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  801e54:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e56:	46                   	inc    %esi
  801e57:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5a:	75 db                	jne    801e37 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801e5c:	89 f0                	mov    %esi,%eax
  801e5e:	eb 05                	jmp    801e65 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e60:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801e65:	83 c4 1c             	add    $0x1c,%esp
  801e68:	5b                   	pop    %ebx
  801e69:	5e                   	pop    %esi
  801e6a:	5f                   	pop    %edi
  801e6b:	5d                   	pop    %ebp
  801e6c:	c3                   	ret    

00801e6d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801e6d:	55                   	push   %ebp
  801e6e:	89 e5                	mov    %esp,%ebp
  801e70:	57                   	push   %edi
  801e71:	56                   	push   %esi
  801e72:	53                   	push   %ebx
  801e73:	83 ec 3c             	sub    $0x3c,%esp
  801e76:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801e79:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801e7c:	89 04 24             	mov    %eax,(%esp)
  801e7f:	e8 df f5 ff ff       	call   801463 <fd_alloc>
  801e84:	89 c3                	mov    %eax,%ebx
  801e86:	85 c0                	test   %eax,%eax
  801e88:	0f 88 45 01 00 00    	js     801fd3 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e8e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801e95:	00 
  801e96:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ea4:	e8 04 ee ff ff       	call   800cad <sys_page_alloc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	85 c0                	test   %eax,%eax
  801ead:	0f 88 20 01 00 00    	js     801fd3 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801eb3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801eb6:	89 04 24             	mov    %eax,(%esp)
  801eb9:	e8 a5 f5 ff ff       	call   801463 <fd_alloc>
  801ebe:	89 c3                	mov    %eax,%ebx
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	0f 88 f8 00 00 00    	js     801fc0 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec8:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ecf:	00 
  801ed0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ede:	e8 ca ed ff ff       	call   800cad <sys_page_alloc>
  801ee3:	89 c3                	mov    %eax,%ebx
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	0f 88 d3 00 00 00    	js     801fc0 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801eed:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ef0:	89 04 24             	mov    %eax,(%esp)
  801ef3:	e8 50 f5 ff ff       	call   801448 <fd2data>
  801ef8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801efa:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801f01:	00 
  801f02:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f06:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f0d:	e8 9b ed ff ff       	call   800cad <sys_page_alloc>
  801f12:	89 c3                	mov    %eax,%ebx
  801f14:	85 c0                	test   %eax,%eax
  801f16:	0f 88 91 00 00 00    	js     801fad <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f1f:	89 04 24             	mov    %eax,(%esp)
  801f22:	e8 21 f5 ff ff       	call   801448 <fd2data>
  801f27:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801f2e:	00 
  801f2f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801f3a:	00 
  801f3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801f46:	e8 b6 ed ff ff       	call   800d01 <sys_page_map>
  801f4b:	89 c3                	mov    %eax,%ebx
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	78 4c                	js     801f9d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f51:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801f57:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f5a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f5c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f5f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801f66:	8b 15 28 30 80 00    	mov    0x803028,%edx
  801f6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f6f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801f71:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f74:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801f7b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801f7e:	89 04 24             	mov    %eax,(%esp)
  801f81:	e8 b2 f4 ff ff       	call   801438 <fd2num>
  801f86:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801f88:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801f8b:	89 04 24             	mov    %eax,(%esp)
  801f8e:	e8 a5 f4 ff ff       	call   801438 <fd2num>
  801f93:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801f96:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f9b:	eb 36                	jmp    801fd3 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801f9d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fa1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fa8:	e8 a7 ed ff ff       	call   800d54 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801fad:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fb4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fbb:	e8 94 ed ff ff       	call   800d54 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801fc0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801fc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fc7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801fce:	e8 81 ed ff ff       	call   800d54 <sys_page_unmap>
    err:
	return r;
}
  801fd3:	89 d8                	mov    %ebx,%eax
  801fd5:	83 c4 3c             	add    $0x3c,%esp
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fea:	8b 45 08             	mov    0x8(%ebp),%eax
  801fed:	89 04 24             	mov    %eax,(%esp)
  801ff0:	e8 c1 f4 ff ff       	call   8014b6 <fd_lookup>
  801ff5:	85 c0                	test   %eax,%eax
  801ff7:	78 15                	js     80200e <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffc:	89 04 24             	mov    %eax,(%esp)
  801fff:	e8 44 f4 ff ff       	call   801448 <fd2data>
	return _pipeisclosed(fd, p);
  802004:	89 c2                	mov    %eax,%edx
  802006:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802009:	e8 15 fd ff ff       	call   801d23 <_pipeisclosed>
}
  80200e:	c9                   	leave  
  80200f:	c3                   	ret    

00802010 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802010:	55                   	push   %ebp
  802011:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    

0080201a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  802020:	c7 44 24 04 40 2b 80 	movl   $0x802b40,0x4(%esp)
  802027:	00 
  802028:	8b 45 0c             	mov    0xc(%ebp),%eax
  80202b:	89 04 24             	mov    %eax,(%esp)
  80202e:	e8 88 e8 ff ff       	call   8008bb <strcpy>
	return 0;
}
  802033:	b8 00 00 00 00       	mov    $0x0,%eax
  802038:	c9                   	leave  
  802039:	c3                   	ret    

0080203a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80203a:	55                   	push   %ebp
  80203b:	89 e5                	mov    %esp,%ebp
  80203d:	57                   	push   %edi
  80203e:	56                   	push   %esi
  80203f:	53                   	push   %ebx
  802040:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802046:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80204b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802051:	eb 30                	jmp    802083 <devcons_write+0x49>
		m = n - tot;
  802053:	8b 75 10             	mov    0x10(%ebp),%esi
  802056:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  802058:	83 fe 7f             	cmp    $0x7f,%esi
  80205b:	76 05                	jbe    802062 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80205d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802062:	89 74 24 08          	mov    %esi,0x8(%esp)
  802066:	03 45 0c             	add    0xc(%ebp),%eax
  802069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206d:	89 3c 24             	mov    %edi,(%esp)
  802070:	e8 bf e9 ff ff       	call   800a34 <memmove>
		sys_cputs(buf, m);
  802075:	89 74 24 04          	mov    %esi,0x4(%esp)
  802079:	89 3c 24             	mov    %edi,(%esp)
  80207c:	e8 5f eb ff ff       	call   800be0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802081:	01 f3                	add    %esi,%ebx
  802083:	89 d8                	mov    %ebx,%eax
  802085:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802088:	72 c9                	jb     802053 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80208a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  802090:	5b                   	pop    %ebx
  802091:	5e                   	pop    %esi
  802092:	5f                   	pop    %edi
  802093:	5d                   	pop    %ebp
  802094:	c3                   	ret    

00802095 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80209b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80209f:	75 07                	jne    8020a8 <devcons_read+0x13>
  8020a1:	eb 25                	jmp    8020c8 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020a3:	e8 e6 eb ff ff       	call   800c8e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020a8:	e8 51 eb ff ff       	call   800bfe <sys_cgetc>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	74 f2                	je     8020a3 <devcons_read+0xe>
  8020b1:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  8020b3:	85 c0                	test   %eax,%eax
  8020b5:	78 1d                	js     8020d4 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020b7:	83 f8 04             	cmp    $0x4,%eax
  8020ba:	74 13                	je     8020cf <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  8020bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020bf:	88 10                	mov    %dl,(%eax)
	return 1;
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c6:	eb 0c                	jmp    8020d4 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  8020c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020cd:	eb 05                	jmp    8020d4 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020cf:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  8020dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020df:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8020e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8020e9:	00 
  8020ea:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ed:	89 04 24             	mov    %eax,(%esp)
  8020f0:	e8 eb ea ff ff       	call   800be0 <sys_cputs>
}
  8020f5:	c9                   	leave  
  8020f6:	c3                   	ret    

008020f7 <getchar>:

int
getchar(void)
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8020fd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  802104:	00 
  802105:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802108:	89 44 24 04          	mov    %eax,0x4(%esp)
  80210c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802113:	e8 3a f6 ff ff       	call   801752 <read>
	if (r < 0)
  802118:	85 c0                	test   %eax,%eax
  80211a:	78 0f                	js     80212b <getchar+0x34>
		return r;
	if (r < 1)
  80211c:	85 c0                	test   %eax,%eax
  80211e:	7e 06                	jle    802126 <getchar+0x2f>
		return -E_EOF;
	return c;
  802120:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802124:	eb 05                	jmp    80212b <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802126:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80212b:	c9                   	leave  
  80212c:	c3                   	ret    

0080212d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802133:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80213a:	8b 45 08             	mov    0x8(%ebp),%eax
  80213d:	89 04 24             	mov    %eax,(%esp)
  802140:	e8 71 f3 ff ff       	call   8014b6 <fd_lookup>
  802145:	85 c0                	test   %eax,%eax
  802147:	78 11                	js     80215a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214c:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802152:	39 10                	cmp    %edx,(%eax)
  802154:	0f 94 c0             	sete   %al
  802157:	0f b6 c0             	movzbl %al,%eax
}
  80215a:	c9                   	leave  
  80215b:	c3                   	ret    

0080215c <opencons>:

int
opencons(void)
{
  80215c:	55                   	push   %ebp
  80215d:	89 e5                	mov    %esp,%ebp
  80215f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802162:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802165:	89 04 24             	mov    %eax,(%esp)
  802168:	e8 f6 f2 ff ff       	call   801463 <fd_alloc>
  80216d:	85 c0                	test   %eax,%eax
  80216f:	78 3c                	js     8021ad <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802171:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802178:	00 
  802179:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802180:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802187:	e8 21 eb ff ff       	call   800cad <sys_page_alloc>
  80218c:	85 c0                	test   %eax,%eax
  80218e:	78 1d                	js     8021ad <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802190:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802196:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802199:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80219b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021a5:	89 04 24             	mov    %eax,(%esp)
  8021a8:	e8 8b f2 ff ff       	call   801438 <fd2num>
}
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    
	...

008021b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021b0:	55                   	push   %ebp
  8021b1:	89 e5                	mov    %esp,%ebp
  8021b3:	56                   	push   %esi
  8021b4:	53                   	push   %ebx
  8021b5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8021b8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021bb:	8b 1d 08 30 80 00    	mov    0x803008,%ebx
  8021c1:	e8 a9 ea ff ff       	call   800c6f <sys_getenvid>
  8021c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8021cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8021d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8021dc:	c7 04 24 4c 2b 80 00 	movl   $0x802b4c,(%esp)
  8021e3:	e8 08 e1 ff ff       	call   8002f0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ef:	89 04 24             	mov    %eax,(%esp)
  8021f2:	e8 98 e0 ff ff       	call   80028f <vcprintf>
	cprintf("\n");
  8021f7:	c7 04 24 39 2b 80 00 	movl   $0x802b39,(%esp)
  8021fe:	e8 ed e0 ff ff       	call   8002f0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802203:	cc                   	int3   
  802204:	eb fd                	jmp    802203 <_panic+0x53>
	...

00802208 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802208:	55                   	push   %ebp
  802209:	89 e5                	mov    %esp,%ebp
  80220b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  80220e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802215:	0f 85 80 00 00 00    	jne    80229b <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  80221b:	a1 04 40 80 00       	mov    0x804004,%eax
  802220:	8b 40 48             	mov    0x48(%eax),%eax
  802223:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80222a:	00 
  80222b:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802232:	ee 
  802233:	89 04 24             	mov    %eax,(%esp)
  802236:	e8 72 ea ff ff       	call   800cad <sys_page_alloc>
  80223b:	85 c0                	test   %eax,%eax
  80223d:	79 20                	jns    80225f <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80223f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802243:	c7 44 24 08 70 2b 80 	movl   $0x802b70,0x8(%esp)
  80224a:	00 
  80224b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802252:	00 
  802253:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  80225a:	e8 51 ff ff ff       	call   8021b0 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80225f:	a1 04 40 80 00       	mov    0x804004,%eax
  802264:	8b 40 48             	mov    0x48(%eax),%eax
  802267:	c7 44 24 04 a8 22 80 	movl   $0x8022a8,0x4(%esp)
  80226e:	00 
  80226f:	89 04 24             	mov    %eax,(%esp)
  802272:	e8 d6 eb ff ff       	call   800e4d <sys_env_set_pgfault_upcall>
  802277:	85 c0                	test   %eax,%eax
  802279:	79 20                	jns    80229b <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80227b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80227f:	c7 44 24 08 9c 2b 80 	movl   $0x802b9c,0x8(%esp)
  802286:	00 
  802287:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80228e:	00 
  80228f:	c7 04 24 cc 2b 80 00 	movl   $0x802bcc,(%esp)
  802296:	e8 15 ff ff ff       	call   8021b0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80229b:	8b 45 08             	mov    0x8(%ebp),%eax
  80229e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  8022a3:	c9                   	leave  
  8022a4:	c3                   	ret    
  8022a5:	00 00                	add    %al,(%eax)
	...

008022a8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022a8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022a9:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8022ae:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022b0:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  8022b3:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  8022b7:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  8022b9:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  8022bc:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  8022bd:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  8022c0:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  8022c2:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  8022c5:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  8022c6:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  8022c9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8022ca:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8022cb:	c3                   	ret    

008022cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022cc:	55                   	push   %ebp
  8022cd:	89 e5                	mov    %esp,%ebp
  8022cf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022d2:	89 c2                	mov    %eax,%edx
  8022d4:	c1 ea 16             	shr    $0x16,%edx
  8022d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8022de:	f6 c2 01             	test   $0x1,%dl
  8022e1:	74 1e                	je     802301 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  8022e3:	c1 e8 0c             	shr    $0xc,%eax
  8022e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022ed:	a8 01                	test   $0x1,%al
  8022ef:	74 17                	je     802308 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8022f1:	c1 e8 0c             	shr    $0xc,%eax
  8022f4:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  8022fb:	ef 
  8022fc:	0f b7 c0             	movzwl %ax,%eax
  8022ff:	eb 0c                	jmp    80230d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802301:	b8 00 00 00 00       	mov    $0x0,%eax
  802306:	eb 05                	jmp    80230d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802308:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80230d:	5d                   	pop    %ebp
  80230e:	c3                   	ret    
	...

00802310 <__udivdi3>:
  802310:	55                   	push   %ebp
  802311:	57                   	push   %edi
  802312:	56                   	push   %esi
  802313:	83 ec 10             	sub    $0x10,%esp
  802316:	8b 74 24 20          	mov    0x20(%esp),%esi
  80231a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80231e:	89 74 24 04          	mov    %esi,0x4(%esp)
  802322:	8b 7c 24 24          	mov    0x24(%esp),%edi
  802326:	89 cd                	mov    %ecx,%ebp
  802328:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80232c:	85 c0                	test   %eax,%eax
  80232e:	75 2c                	jne    80235c <__udivdi3+0x4c>
  802330:	39 f9                	cmp    %edi,%ecx
  802332:	77 68                	ja     80239c <__udivdi3+0x8c>
  802334:	85 c9                	test   %ecx,%ecx
  802336:	75 0b                	jne    802343 <__udivdi3+0x33>
  802338:	b8 01 00 00 00       	mov    $0x1,%eax
  80233d:	31 d2                	xor    %edx,%edx
  80233f:	f7 f1                	div    %ecx
  802341:	89 c1                	mov    %eax,%ecx
  802343:	31 d2                	xor    %edx,%edx
  802345:	89 f8                	mov    %edi,%eax
  802347:	f7 f1                	div    %ecx
  802349:	89 c7                	mov    %eax,%edi
  80234b:	89 f0                	mov    %esi,%eax
  80234d:	f7 f1                	div    %ecx
  80234f:	89 c6                	mov    %eax,%esi
  802351:	89 f0                	mov    %esi,%eax
  802353:	89 fa                	mov    %edi,%edx
  802355:	83 c4 10             	add    $0x10,%esp
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	39 f8                	cmp    %edi,%eax
  80235e:	77 2c                	ja     80238c <__udivdi3+0x7c>
  802360:	0f bd f0             	bsr    %eax,%esi
  802363:	83 f6 1f             	xor    $0x1f,%esi
  802366:	75 4c                	jne    8023b4 <__udivdi3+0xa4>
  802368:	39 f8                	cmp    %edi,%eax
  80236a:	bf 00 00 00 00       	mov    $0x0,%edi
  80236f:	72 0a                	jb     80237b <__udivdi3+0x6b>
  802371:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802375:	0f 87 ad 00 00 00    	ja     802428 <__udivdi3+0x118>
  80237b:	be 01 00 00 00       	mov    $0x1,%esi
  802380:	89 f0                	mov    %esi,%eax
  802382:	89 fa                	mov    %edi,%edx
  802384:	83 c4 10             	add    $0x10,%esp
  802387:	5e                   	pop    %esi
  802388:	5f                   	pop    %edi
  802389:	5d                   	pop    %ebp
  80238a:	c3                   	ret    
  80238b:	90                   	nop
  80238c:	31 ff                	xor    %edi,%edi
  80238e:	31 f6                	xor    %esi,%esi
  802390:	89 f0                	mov    %esi,%eax
  802392:	89 fa                	mov    %edi,%edx
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	5e                   	pop    %esi
  802398:	5f                   	pop    %edi
  802399:	5d                   	pop    %ebp
  80239a:	c3                   	ret    
  80239b:	90                   	nop
  80239c:	89 fa                	mov    %edi,%edx
  80239e:	89 f0                	mov    %esi,%eax
  8023a0:	f7 f1                	div    %ecx
  8023a2:	89 c6                	mov    %eax,%esi
  8023a4:	31 ff                	xor    %edi,%edi
  8023a6:	89 f0                	mov    %esi,%eax
  8023a8:	89 fa                	mov    %edi,%edx
  8023aa:	83 c4 10             	add    $0x10,%esp
  8023ad:	5e                   	pop    %esi
  8023ae:	5f                   	pop    %edi
  8023af:	5d                   	pop    %ebp
  8023b0:	c3                   	ret    
  8023b1:	8d 76 00             	lea    0x0(%esi),%esi
  8023b4:	89 f1                	mov    %esi,%ecx
  8023b6:	d3 e0                	shl    %cl,%eax
  8023b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bc:	b8 20 00 00 00       	mov    $0x20,%eax
  8023c1:	29 f0                	sub    %esi,%eax
  8023c3:	89 ea                	mov    %ebp,%edx
  8023c5:	88 c1                	mov    %al,%cl
  8023c7:	d3 ea                	shr    %cl,%edx
  8023c9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  8023cd:	09 ca                	or     %ecx,%edx
  8023cf:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023d3:	89 f1                	mov    %esi,%ecx
  8023d5:	d3 e5                	shl    %cl,%ebp
  8023d7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  8023db:	89 fd                	mov    %edi,%ebp
  8023dd:	88 c1                	mov    %al,%cl
  8023df:	d3 ed                	shr    %cl,%ebp
  8023e1:	89 fa                	mov    %edi,%edx
  8023e3:	89 f1                	mov    %esi,%ecx
  8023e5:	d3 e2                	shl    %cl,%edx
  8023e7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8023eb:	88 c1                	mov    %al,%cl
  8023ed:	d3 ef                	shr    %cl,%edi
  8023ef:	09 d7                	or     %edx,%edi
  8023f1:	89 f8                	mov    %edi,%eax
  8023f3:	89 ea                	mov    %ebp,%edx
  8023f5:	f7 74 24 08          	divl   0x8(%esp)
  8023f9:	89 d1                	mov    %edx,%ecx
  8023fb:	89 c7                	mov    %eax,%edi
  8023fd:	f7 64 24 0c          	mull   0xc(%esp)
  802401:	39 d1                	cmp    %edx,%ecx
  802403:	72 17                	jb     80241c <__udivdi3+0x10c>
  802405:	74 09                	je     802410 <__udivdi3+0x100>
  802407:	89 fe                	mov    %edi,%esi
  802409:	31 ff                	xor    %edi,%edi
  80240b:	e9 41 ff ff ff       	jmp    802351 <__udivdi3+0x41>
  802410:	8b 54 24 04          	mov    0x4(%esp),%edx
  802414:	89 f1                	mov    %esi,%ecx
  802416:	d3 e2                	shl    %cl,%edx
  802418:	39 c2                	cmp    %eax,%edx
  80241a:	73 eb                	jae    802407 <__udivdi3+0xf7>
  80241c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80241f:	31 ff                	xor    %edi,%edi
  802421:	e9 2b ff ff ff       	jmp    802351 <__udivdi3+0x41>
  802426:	66 90                	xchg   %ax,%ax
  802428:	31 f6                	xor    %esi,%esi
  80242a:	e9 22 ff ff ff       	jmp    802351 <__udivdi3+0x41>
	...

00802430 <__umoddi3>:
  802430:	55                   	push   %ebp
  802431:	57                   	push   %edi
  802432:	56                   	push   %esi
  802433:	83 ec 20             	sub    $0x20,%esp
  802436:	8b 44 24 30          	mov    0x30(%esp),%eax
  80243a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80243e:	89 44 24 14          	mov    %eax,0x14(%esp)
  802442:	8b 74 24 34          	mov    0x34(%esp),%esi
  802446:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80244a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  80244e:	89 c7                	mov    %eax,%edi
  802450:	89 f2                	mov    %esi,%edx
  802452:	85 ed                	test   %ebp,%ebp
  802454:	75 16                	jne    80246c <__umoddi3+0x3c>
  802456:	39 f1                	cmp    %esi,%ecx
  802458:	0f 86 a6 00 00 00    	jbe    802504 <__umoddi3+0xd4>
  80245e:	f7 f1                	div    %ecx
  802460:	89 d0                	mov    %edx,%eax
  802462:	31 d2                	xor    %edx,%edx
  802464:	83 c4 20             	add    $0x20,%esp
  802467:	5e                   	pop    %esi
  802468:	5f                   	pop    %edi
  802469:	5d                   	pop    %ebp
  80246a:	c3                   	ret    
  80246b:	90                   	nop
  80246c:	39 f5                	cmp    %esi,%ebp
  80246e:	0f 87 ac 00 00 00    	ja     802520 <__umoddi3+0xf0>
  802474:	0f bd c5             	bsr    %ebp,%eax
  802477:	83 f0 1f             	xor    $0x1f,%eax
  80247a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80247e:	0f 84 a8 00 00 00    	je     80252c <__umoddi3+0xfc>
  802484:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802488:	d3 e5                	shl    %cl,%ebp
  80248a:	bf 20 00 00 00       	mov    $0x20,%edi
  80248f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  802493:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802497:	89 f9                	mov    %edi,%ecx
  802499:	d3 e8                	shr    %cl,%eax
  80249b:	09 e8                	or     %ebp,%eax
  80249d:	89 44 24 18          	mov    %eax,0x18(%esp)
  8024a1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8024a5:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024a9:	d3 e0                	shl    %cl,%eax
  8024ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8024af:	89 f2                	mov    %esi,%edx
  8024b1:	d3 e2                	shl    %cl,%edx
  8024b3:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024b7:	d3 e0                	shl    %cl,%eax
  8024b9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  8024bd:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024c1:	89 f9                	mov    %edi,%ecx
  8024c3:	d3 e8                	shr    %cl,%eax
  8024c5:	09 d0                	or     %edx,%eax
  8024c7:	d3 ee                	shr    %cl,%esi
  8024c9:	89 f2                	mov    %esi,%edx
  8024cb:	f7 74 24 18          	divl   0x18(%esp)
  8024cf:	89 d6                	mov    %edx,%esi
  8024d1:	f7 64 24 0c          	mull   0xc(%esp)
  8024d5:	89 c5                	mov    %eax,%ebp
  8024d7:	89 d1                	mov    %edx,%ecx
  8024d9:	39 d6                	cmp    %edx,%esi
  8024db:	72 67                	jb     802544 <__umoddi3+0x114>
  8024dd:	74 75                	je     802554 <__umoddi3+0x124>
  8024df:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8024e3:	29 e8                	sub    %ebp,%eax
  8024e5:	19 ce                	sbb    %ecx,%esi
  8024e7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	89 f2                	mov    %esi,%edx
  8024ef:	89 f9                	mov    %edi,%ecx
  8024f1:	d3 e2                	shl    %cl,%edx
  8024f3:	09 d0                	or     %edx,%eax
  8024f5:	89 f2                	mov    %esi,%edx
  8024f7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8024fb:	d3 ea                	shr    %cl,%edx
  8024fd:	83 c4 20             	add    $0x20,%esp
  802500:	5e                   	pop    %esi
  802501:	5f                   	pop    %edi
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	85 c9                	test   %ecx,%ecx
  802506:	75 0b                	jne    802513 <__umoddi3+0xe3>
  802508:	b8 01 00 00 00       	mov    $0x1,%eax
  80250d:	31 d2                	xor    %edx,%edx
  80250f:	f7 f1                	div    %ecx
  802511:	89 c1                	mov    %eax,%ecx
  802513:	89 f0                	mov    %esi,%eax
  802515:	31 d2                	xor    %edx,%edx
  802517:	f7 f1                	div    %ecx
  802519:	89 f8                	mov    %edi,%eax
  80251b:	e9 3e ff ff ff       	jmp    80245e <__umoddi3+0x2e>
  802520:	89 f2                	mov    %esi,%edx
  802522:	83 c4 20             	add    $0x20,%esp
  802525:	5e                   	pop    %esi
  802526:	5f                   	pop    %edi
  802527:	5d                   	pop    %ebp
  802528:	c3                   	ret    
  802529:	8d 76 00             	lea    0x0(%esi),%esi
  80252c:	39 f5                	cmp    %esi,%ebp
  80252e:	72 04                	jb     802534 <__umoddi3+0x104>
  802530:	39 f9                	cmp    %edi,%ecx
  802532:	77 06                	ja     80253a <__umoddi3+0x10a>
  802534:	89 f2                	mov    %esi,%edx
  802536:	29 cf                	sub    %ecx,%edi
  802538:	19 ea                	sbb    %ebp,%edx
  80253a:	89 f8                	mov    %edi,%eax
  80253c:	83 c4 20             	add    $0x20,%esp
  80253f:	5e                   	pop    %esi
  802540:	5f                   	pop    %edi
  802541:	5d                   	pop    %ebp
  802542:	c3                   	ret    
  802543:	90                   	nop
  802544:	89 d1                	mov    %edx,%ecx
  802546:	89 c5                	mov    %eax,%ebp
  802548:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  80254c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  802550:	eb 8d                	jmp    8024df <__umoddi3+0xaf>
  802552:	66 90                	xchg   %ax,%ax
  802554:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  802558:	72 ea                	jb     802544 <__umoddi3+0x114>
  80255a:	89 f1                	mov    %esi,%ecx
  80255c:	eb 81                	jmp    8024df <__umoddi3+0xaf>
