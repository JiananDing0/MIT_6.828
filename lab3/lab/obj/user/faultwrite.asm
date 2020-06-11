
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 13 00 00 00       	call   800044 <libmain>
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
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    
	...

00800044 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800044:	55                   	push   %ebp
  800045:	89 e5                	mov    %esp,%ebp
  800047:	83 ec 18             	sub    $0x18,%esp
  80004a:	8b 45 08             	mov    0x8(%ebp),%eax
  80004d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800050:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800057:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005a:	85 c0                	test   %eax,%eax
  80005c:	7e 08                	jle    800066 <libmain+0x22>
		binaryname = argv[0];
  80005e:	8b 0a                	mov    (%edx),%ecx
  800060:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800066:	89 54 24 04          	mov    %edx,0x4(%esp)
  80006a:	89 04 24             	mov    %eax,(%esp)
  80006d:	e8 c2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800072:	e8 05 00 00 00       	call   80007c <exit>
}
  800077:	c9                   	leave  
  800078:	c3                   	ret    
  800079:	00 00                	add    %al,(%eax)
	...

0080007c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800082:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800089:	e8 3f 00 00 00       	call   8000cd <sys_env_destroy>
}
  80008e:	c9                   	leave  
  80008f:	c3                   	ret    

00800090 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	57                   	push   %edi
  800094:	56                   	push   %esi
  800095:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800096:	b8 00 00 00 00       	mov    $0x0,%eax
  80009b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009e:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a1:	89 c3                	mov    %eax,%ebx
  8000a3:	89 c7                	mov    %eax,%edi
  8000a5:	89 c6                	mov    %eax,%esi
  8000a7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a9:	5b                   	pop    %ebx
  8000aa:	5e                   	pop    %esi
  8000ab:	5f                   	pop    %edi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000be:	89 d1                	mov    %edx,%ecx
  8000c0:	89 d3                	mov    %edx,%ebx
  8000c2:	89 d7                	mov    %edx,%edi
  8000c4:	89 d6                	mov    %edx,%esi
  8000c6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c8:	5b                   	pop    %ebx
  8000c9:	5e                   	pop    %esi
  8000ca:	5f                   	pop    %edi
  8000cb:	5d                   	pop    %ebp
  8000cc:	c3                   	ret    

008000cd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	57                   	push   %edi
  8000d1:	56                   	push   %esi
  8000d2:	53                   	push   %ebx
  8000d3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000db:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	89 cb                	mov    %ecx,%ebx
  8000e5:	89 cf                	mov    %ecx,%edi
  8000e7:	89 ce                	mov    %ecx,%esi
  8000e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000eb:	85 c0                	test   %eax,%eax
  8000ed:	7e 28                	jle    800117 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ef:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000f3:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 08 62 0d 80 	movl   $0x800d62,0x8(%esp)
  800102:	00 
  800103:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80010a:	00 
  80010b:	c7 04 24 7f 0d 80 00 	movl   $0x800d7f,(%esp)
  800112:	e8 29 00 00 00       	call   800140 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800117:	83 c4 2c             	add    $0x2c,%esp
  80011a:	5b                   	pop    %ebx
  80011b:	5e                   	pop    %esi
  80011c:	5f                   	pop    %edi
  80011d:	5d                   	pop    %ebp
  80011e:	c3                   	ret    

0080011f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011f:	55                   	push   %ebp
  800120:	89 e5                	mov    %esp,%ebp
  800122:	57                   	push   %edi
  800123:	56                   	push   %esi
  800124:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800125:	ba 00 00 00 00       	mov    $0x0,%edx
  80012a:	b8 02 00 00 00       	mov    $0x2,%eax
  80012f:	89 d1                	mov    %edx,%ecx
  800131:	89 d3                	mov    %edx,%ebx
  800133:	89 d7                	mov    %edx,%edi
  800135:	89 d6                	mov    %edx,%esi
  800137:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800139:	5b                   	pop    %ebx
  80013a:	5e                   	pop    %esi
  80013b:	5f                   	pop    %edi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    
	...

00800140 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800140:	55                   	push   %ebp
  800141:	89 e5                	mov    %esp,%ebp
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
  800145:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800148:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014b:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800151:	e8 c9 ff ff ff       	call   80011f <sys_getenvid>
  800156:	8b 55 0c             	mov    0xc(%ebp),%edx
  800159:	89 54 24 10          	mov    %edx,0x10(%esp)
  80015d:	8b 55 08             	mov    0x8(%ebp),%edx
  800160:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800164:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016c:	c7 04 24 90 0d 80 00 	movl   $0x800d90,(%esp)
  800173:	e8 c0 00 00 00       	call   800238 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800178:	89 74 24 04          	mov    %esi,0x4(%esp)
  80017c:	8b 45 10             	mov    0x10(%ebp),%eax
  80017f:	89 04 24             	mov    %eax,(%esp)
  800182:	e8 50 00 00 00       	call   8001d7 <vcprintf>
	cprintf("\n");
  800187:	c7 04 24 b4 0d 80 00 	movl   $0x800db4,(%esp)
  80018e:	e8 a5 00 00 00       	call   800238 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800193:	cc                   	int3   
  800194:	eb fd                	jmp    800193 <_panic+0x53>
	...

00800198 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	53                   	push   %ebx
  80019c:	83 ec 14             	sub    $0x14,%esp
  80019f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a2:	8b 03                	mov    (%ebx),%eax
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ab:	40                   	inc    %eax
  8001ac:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001b3:	75 19                	jne    8001ce <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001b5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001bc:	00 
  8001bd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c0:	89 04 24             	mov    %eax,(%esp)
  8001c3:	e8 c8 fe ff ff       	call   800090 <sys_cputs>
		b->idx = 0;
  8001c8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ce:	ff 43 04             	incl   0x4(%ebx)
}
  8001d1:	83 c4 14             	add    $0x14,%esp
  8001d4:	5b                   	pop    %ebx
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e7:	00 00 00 
	b.cnt = 0;
  8001ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fe:	89 44 24 08          	mov    %eax,0x8(%esp)
  800202:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80020c:	c7 04 24 98 01 80 00 	movl   $0x800198,(%esp)
  800213:	e8 82 01 00 00       	call   80039a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800218:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800222:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 60 fe ff ff       	call   800090 <sys_cputs>

	return b.cnt;
}
  800230:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800236:	c9                   	leave  
  800237:	c3                   	ret    

00800238 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800241:	89 44 24 04          	mov    %eax,0x4(%esp)
  800245:	8b 45 08             	mov    0x8(%ebp),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 87 ff ff ff       	call   8001d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    
	...

00800254 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800254:	55                   	push   %ebp
  800255:	89 e5                	mov    %esp,%ebp
  800257:	57                   	push   %edi
  800258:	56                   	push   %esi
  800259:	53                   	push   %ebx
  80025a:	83 ec 3c             	sub    $0x3c,%esp
  80025d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800260:	89 d7                	mov    %edx,%edi
  800262:	8b 45 08             	mov    0x8(%ebp),%eax
  800265:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80026b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800271:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800274:	85 c0                	test   %eax,%eax
  800276:	75 08                	jne    800280 <printnum+0x2c>
  800278:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027e:	77 57                	ja     8002d7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800280:	89 74 24 10          	mov    %esi,0x10(%esp)
  800284:	4b                   	dec    %ebx
  800285:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800289:	8b 45 10             	mov    0x10(%ebp),%eax
  80028c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800290:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800294:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002ad:	e8 56 08 00 00       	call   800b08 <__udivdi3>
  8002b2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ba:	89 04 24             	mov    %eax,(%esp)
  8002bd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c1:	89 fa                	mov    %edi,%edx
  8002c3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c6:	e8 89 ff ff ff       	call   800254 <printnum>
  8002cb:	eb 0f                	jmp    8002dc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d1:	89 34 24             	mov    %esi,(%esp)
  8002d4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d7:	4b                   	dec    %ebx
  8002d8:	85 db                	test   %ebx,%ebx
  8002da:	7f f1                	jg     8002cd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002dc:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002eb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002f2:	00 
  8002f3:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800300:	e8 23 09 00 00       	call   800c28 <__umoddi3>
  800305:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800309:	0f be 80 b6 0d 80 00 	movsbl 0x800db6(%eax),%eax
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800316:	83 c4 3c             	add    $0x3c,%esp
  800319:	5b                   	pop    %ebx
  80031a:	5e                   	pop    %esi
  80031b:	5f                   	pop    %edi
  80031c:	5d                   	pop    %ebp
  80031d:	c3                   	ret    

0080031e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800321:	83 fa 01             	cmp    $0x1,%edx
  800324:	7e 0e                	jle    800334 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 08             	lea    0x8(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	8b 52 04             	mov    0x4(%edx),%edx
  800332:	eb 22                	jmp    800356 <getuint+0x38>
	else if (lflag)
  800334:	85 d2                	test   %edx,%edx
  800336:	74 10                	je     800348 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	ba 00 00 00 00       	mov    $0x0,%edx
  800346:	eb 0e                	jmp    800356 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800348:	8b 10                	mov    (%eax),%edx
  80034a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800361:	8b 10                	mov    (%eax),%edx
  800363:	3b 50 04             	cmp    0x4(%eax),%edx
  800366:	73 08                	jae    800370 <sprintputch+0x18>
		*b->buf++ = ch;
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 0a                	mov    %cl,(%edx)
  80036d:	42                   	inc    %edx
  80036e:	89 10                	mov    %edx,(%eax)
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800378:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80037b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80037f:	8b 45 10             	mov    0x10(%ebp),%eax
  800382:	89 44 24 08          	mov    %eax,0x8(%esp)
  800386:	8b 45 0c             	mov    0xc(%ebp),%eax
  800389:	89 44 24 04          	mov    %eax,0x4(%esp)
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	89 04 24             	mov    %eax,(%esp)
  800393:	e8 02 00 00 00       	call   80039a <vprintfmt>
	va_end(ap);
}
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	57                   	push   %edi
  80039e:	56                   	push   %esi
  80039f:	53                   	push   %ebx
  8003a0:	83 ec 4c             	sub    $0x4c,%esp
  8003a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a9:	eb 12                	jmp    8003bd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003ab:	85 c0                	test   %eax,%eax
  8003ad:	0f 84 6b 03 00 00    	je     80071e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b7:	89 04 24             	mov    %eax,(%esp)
  8003ba:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003bd:	0f b6 06             	movzbl (%esi),%eax
  8003c0:	46                   	inc    %esi
  8003c1:	83 f8 25             	cmp    $0x25,%eax
  8003c4:	75 e5                	jne    8003ab <vprintfmt+0x11>
  8003c6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ca:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003d1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003d6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003dd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003e2:	eb 26                	jmp    80040a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003eb:	eb 1d                	jmp    80040a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003f0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003f4:	eb 14                	jmp    80040a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800400:	eb 08                	jmp    80040a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800402:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800405:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	0f b6 06             	movzbl (%esi),%eax
  80040d:	8d 56 01             	lea    0x1(%esi),%edx
  800410:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800413:	8a 16                	mov    (%esi),%dl
  800415:	83 ea 23             	sub    $0x23,%edx
  800418:	80 fa 55             	cmp    $0x55,%dl
  80041b:	0f 87 e1 02 00 00    	ja     800702 <vprintfmt+0x368>
  800421:	0f b6 d2             	movzbl %dl,%edx
  800424:	ff 24 95 44 0e 80 00 	jmp    *0x800e44(,%edx,4)
  80042b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800433:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800436:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80043a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80043d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800440:	83 fa 09             	cmp    $0x9,%edx
  800443:	77 2a                	ja     80046f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800445:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800446:	eb eb                	jmp    800433 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800448:	8b 45 14             	mov    0x14(%ebp),%eax
  80044b:	8d 50 04             	lea    0x4(%eax),%edx
  80044e:	89 55 14             	mov    %edx,0x14(%ebp)
  800451:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800453:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800456:	eb 17                	jmp    80046f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800458:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80045c:	78 98                	js     8003f6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800461:	eb a7                	jmp    80040a <vprintfmt+0x70>
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800466:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80046d:	eb 9b                	jmp    80040a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80046f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800473:	79 95                	jns    80040a <vprintfmt+0x70>
  800475:	eb 8b                	jmp    800402 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800477:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80047b:	eb 8d                	jmp    80040a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 04 24             	mov    %eax,(%esp)
  80048f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800492:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800495:	e9 23 ff ff ff       	jmp    8003bd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049a:	8b 45 14             	mov    0x14(%ebp),%eax
  80049d:	8d 50 04             	lea    0x4(%eax),%edx
  8004a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004a3:	8b 00                	mov    (%eax),%eax
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	79 02                	jns    8004ab <vprintfmt+0x111>
  8004a9:	f7 d8                	neg    %eax
  8004ab:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ad:	83 f8 06             	cmp    $0x6,%eax
  8004b0:	7f 0b                	jg     8004bd <vprintfmt+0x123>
  8004b2:	8b 04 85 9c 0f 80 00 	mov    0x800f9c(,%eax,4),%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	75 23                	jne    8004e0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004bd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c1:	c7 44 24 08 ce 0d 80 	movl   $0x800dce,0x8(%esp)
  8004c8:	00 
  8004c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d0:	89 04 24             	mov    %eax,(%esp)
  8004d3:	e8 9a fe ff ff       	call   800372 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004db:	e9 dd fe ff ff       	jmp    8003bd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e4:	c7 44 24 08 d7 0d 80 	movl   $0x800dd7,0x8(%esp)
  8004eb:	00 
  8004ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8004f3:	89 14 24             	mov    %edx,(%esp)
  8004f6:	e8 77 fe ff ff       	call   800372 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fe:	e9 ba fe ff ff       	jmp    8003bd <vprintfmt+0x23>
  800503:	89 f9                	mov    %edi,%ecx
  800505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800508:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8d 50 04             	lea    0x4(%eax),%edx
  800511:	89 55 14             	mov    %edx,0x14(%ebp)
  800514:	8b 30                	mov    (%eax),%esi
  800516:	85 f6                	test   %esi,%esi
  800518:	75 05                	jne    80051f <vprintfmt+0x185>
				p = "(null)";
  80051a:	be c7 0d 80 00       	mov    $0x800dc7,%esi
			if (width > 0 && padc != '-')
  80051f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800523:	0f 8e 84 00 00 00    	jle    8005ad <vprintfmt+0x213>
  800529:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80052d:	74 7e                	je     8005ad <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800533:	89 34 24             	mov    %esi,(%esp)
  800536:	e8 8b 02 00 00       	call   8007c6 <strnlen>
  80053b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80053e:	29 c2                	sub    %eax,%edx
  800540:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800543:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800547:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80054a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80054d:	89 de                	mov    %ebx,%esi
  80054f:	89 d3                	mov    %edx,%ebx
  800551:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	eb 0b                	jmp    800560 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800555:	89 74 24 04          	mov    %esi,0x4(%esp)
  800559:	89 3c 24             	mov    %edi,(%esp)
  80055c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	4b                   	dec    %ebx
  800560:	85 db                	test   %ebx,%ebx
  800562:	7f f1                	jg     800555 <vprintfmt+0x1bb>
  800564:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800567:	89 f3                	mov    %esi,%ebx
  800569:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80056c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056f:	85 c0                	test   %eax,%eax
  800571:	79 05                	jns    800578 <vprintfmt+0x1de>
  800573:	b8 00 00 00 00       	mov    $0x0,%eax
  800578:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80057b:	29 c2                	sub    %eax,%edx
  80057d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800580:	eb 2b                	jmp    8005ad <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800582:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800586:	74 18                	je     8005a0 <vprintfmt+0x206>
  800588:	8d 50 e0             	lea    -0x20(%eax),%edx
  80058b:	83 fa 5e             	cmp    $0x5e,%edx
  80058e:	76 10                	jbe    8005a0 <vprintfmt+0x206>
					putch('?', putdat);
  800590:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800594:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80059b:	ff 55 08             	call   *0x8(%ebp)
  80059e:	eb 0a                	jmp    8005aa <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005aa:	ff 4d e4             	decl   -0x1c(%ebp)
  8005ad:	0f be 06             	movsbl (%esi),%eax
  8005b0:	46                   	inc    %esi
  8005b1:	85 c0                	test   %eax,%eax
  8005b3:	74 21                	je     8005d6 <vprintfmt+0x23c>
  8005b5:	85 ff                	test   %edi,%edi
  8005b7:	78 c9                	js     800582 <vprintfmt+0x1e8>
  8005b9:	4f                   	dec    %edi
  8005ba:	79 c6                	jns    800582 <vprintfmt+0x1e8>
  8005bc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005bf:	89 de                	mov    %ebx,%esi
  8005c1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c4:	eb 18                	jmp    8005de <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ca:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005d3:	4b                   	dec    %ebx
  8005d4:	eb 08                	jmp    8005de <vprintfmt+0x244>
  8005d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d9:	89 de                	mov    %ebx,%esi
  8005db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005de:	85 db                	test   %ebx,%ebx
  8005e0:	7f e4                	jg     8005c6 <vprintfmt+0x22c>
  8005e2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005ea:	e9 ce fd ff ff       	jmp    8003bd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ef:	83 f9 01             	cmp    $0x1,%ecx
  8005f2:	7e 10                	jle    800604 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 08             	lea    0x8(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	8b 30                	mov    (%eax),%esi
  8005ff:	8b 78 04             	mov    0x4(%eax),%edi
  800602:	eb 26                	jmp    80062a <vprintfmt+0x290>
	else if (lflag)
  800604:	85 c9                	test   %ecx,%ecx
  800606:	74 12                	je     80061a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 04             	lea    0x4(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
  800613:	89 f7                	mov    %esi,%edi
  800615:	c1 ff 1f             	sar    $0x1f,%edi
  800618:	eb 10                	jmp    80062a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
  800623:	8b 30                	mov    (%eax),%esi
  800625:	89 f7                	mov    %esi,%edi
  800627:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80062a:	85 ff                	test   %edi,%edi
  80062c:	78 0a                	js     800638 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800633:	e9 8c 00 00 00       	jmp    8006c4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800638:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80063c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800643:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800646:	f7 de                	neg    %esi
  800648:	83 d7 00             	adc    $0x0,%edi
  80064b:	f7 df                	neg    %edi
			}
			base = 10;
  80064d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800652:	eb 70                	jmp    8006c4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800654:	89 ca                	mov    %ecx,%edx
  800656:	8d 45 14             	lea    0x14(%ebp),%eax
  800659:	e8 c0 fc ff ff       	call   80031e <getuint>
  80065e:	89 c6                	mov    %eax,%esi
  800660:	89 d7                	mov    %edx,%edi
			base = 10;
  800662:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800667:	eb 5b                	jmp    8006c4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800669:	89 ca                	mov    %ecx,%edx
  80066b:	8d 45 14             	lea    0x14(%ebp),%eax
  80066e:	e8 ab fc ff ff       	call   80031e <getuint>
  800673:	89 c6                	mov    %eax,%esi
  800675:	89 d7                	mov    %edx,%edi
			base = 8;
  800677:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80067c:	eb 46                	jmp    8006c4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80067e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800682:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800689:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80068c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800690:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800697:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80069a:	8b 45 14             	mov    0x14(%ebp),%eax
  80069d:	8d 50 04             	lea    0x4(%eax),%edx
  8006a0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006a3:	8b 30                	mov    (%eax),%esi
  8006a5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006aa:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006af:	eb 13                	jmp    8006c4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b1:	89 ca                	mov    %ecx,%edx
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 63 fc ff ff       	call   80031e <getuint>
  8006bb:	89 c6                	mov    %eax,%esi
  8006bd:	89 d7                	mov    %edx,%edi
			base = 16;
  8006bf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006c8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006cc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d7:	89 34 24             	mov    %esi,(%esp)
  8006da:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006de:	89 da                	mov    %ebx,%edx
  8006e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e3:	e8 6c fb ff ff       	call   800254 <printnum>
			break;
  8006e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006eb:	e9 cd fc ff ff       	jmp    8003bd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006fd:	e9 bb fc ff ff       	jmp    8003bd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800702:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800706:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80070d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800710:	eb 01                	jmp    800713 <vprintfmt+0x379>
  800712:	4e                   	dec    %esi
  800713:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800717:	75 f9                	jne    800712 <vprintfmt+0x378>
  800719:	e9 9f fc ff ff       	jmp    8003bd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80071e:	83 c4 4c             	add    $0x4c,%esp
  800721:	5b                   	pop    %ebx
  800722:	5e                   	pop    %esi
  800723:	5f                   	pop    %edi
  800724:	5d                   	pop    %ebp
  800725:	c3                   	ret    

00800726 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800726:	55                   	push   %ebp
  800727:	89 e5                	mov    %esp,%ebp
  800729:	83 ec 28             	sub    $0x28,%esp
  80072c:	8b 45 08             	mov    0x8(%ebp),%eax
  80072f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800732:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800735:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800739:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80073c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800743:	85 c0                	test   %eax,%eax
  800745:	74 30                	je     800777 <vsnprintf+0x51>
  800747:	85 d2                	test   %edx,%edx
  800749:	7e 33                	jle    80077e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074b:	8b 45 14             	mov    0x14(%ebp),%eax
  80074e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800752:	8b 45 10             	mov    0x10(%ebp),%eax
  800755:	89 44 24 08          	mov    %eax,0x8(%esp)
  800759:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800760:	c7 04 24 58 03 80 00 	movl   $0x800358,(%esp)
  800767:	e8 2e fc ff ff       	call   80039a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800772:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800775:	eb 0c                	jmp    800783 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800777:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077c:	eb 05                	jmp    800783 <vsnprintf+0x5d>
  80077e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800783:	c9                   	leave  
  800784:	c3                   	ret    

00800785 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800792:	8b 45 10             	mov    0x10(%ebp),%eax
  800795:	89 44 24 08          	mov    %eax,0x8(%esp)
  800799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80079c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	e8 7b ff ff ff       	call   800726 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ab:	c9                   	leave  
  8007ac:	c3                   	ret    
  8007ad:	00 00                	add    %al,(%eax)
	...

008007b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	eb 01                	jmp    8007be <strlen+0xe>
		n++;
  8007bd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c2:	75 f9                	jne    8007bd <strlen+0xd>
		n++;
	return n;
}
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007cc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d4:	eb 01                	jmp    8007d7 <strnlen+0x11>
		n++;
  8007d6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d7:	39 d0                	cmp    %edx,%eax
  8007d9:	74 06                	je     8007e1 <strnlen+0x1b>
  8007db:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007df:	75 f5                	jne    8007d6 <strnlen+0x10>
		n++;
	return n;
}
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8007f2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007f5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f8:	42                   	inc    %edx
  8007f9:	84 c9                	test   %cl,%cl
  8007fb:	75 f5                	jne    8007f2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	53                   	push   %ebx
  800804:	83 ec 08             	sub    $0x8,%esp
  800807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080a:	89 1c 24             	mov    %ebx,(%esp)
  80080d:	e8 9e ff ff ff       	call   8007b0 <strlen>
	strcpy(dst + len, src);
  800812:	8b 55 0c             	mov    0xc(%ebp),%edx
  800815:	89 54 24 04          	mov    %edx,0x4(%esp)
  800819:	01 d8                	add    %ebx,%eax
  80081b:	89 04 24             	mov    %eax,(%esp)
  80081e:	e8 c0 ff ff ff       	call   8007e3 <strcpy>
	return dst;
}
  800823:	89 d8                	mov    %ebx,%eax
  800825:	83 c4 08             	add    $0x8,%esp
  800828:	5b                   	pop    %ebx
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 45 08             	mov    0x8(%ebp),%eax
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
  800836:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800839:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083e:	eb 0c                	jmp    80084c <strncpy+0x21>
		*dst++ = *src;
  800840:	8a 1a                	mov    (%edx),%bl
  800842:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800845:	80 3a 01             	cmpb   $0x1,(%edx)
  800848:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084b:	41                   	inc    %ecx
  80084c:	39 f1                	cmp    %esi,%ecx
  80084e:	75 f0                	jne    800840 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	56                   	push   %esi
  800858:	53                   	push   %ebx
  800859:	8b 75 08             	mov    0x8(%ebp),%esi
  80085c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800862:	85 d2                	test   %edx,%edx
  800864:	75 0a                	jne    800870 <strlcpy+0x1c>
  800866:	89 f0                	mov    %esi,%eax
  800868:	eb 1a                	jmp    800884 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80086a:	88 18                	mov    %bl,(%eax)
  80086c:	40                   	inc    %eax
  80086d:	41                   	inc    %ecx
  80086e:	eb 02                	jmp    800872 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800870:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800872:	4a                   	dec    %edx
  800873:	74 0a                	je     80087f <strlcpy+0x2b>
  800875:	8a 19                	mov    (%ecx),%bl
  800877:	84 db                	test   %bl,%bl
  800879:	75 ef                	jne    80086a <strlcpy+0x16>
  80087b:	89 c2                	mov    %eax,%edx
  80087d:	eb 02                	jmp    800881 <strlcpy+0x2d>
  80087f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800881:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800884:	29 f0                	sub    %esi,%eax
}
  800886:	5b                   	pop    %ebx
  800887:	5e                   	pop    %esi
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800893:	eb 02                	jmp    800897 <strcmp+0xd>
		p++, q++;
  800895:	41                   	inc    %ecx
  800896:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800897:	8a 01                	mov    (%ecx),%al
  800899:	84 c0                	test   %al,%al
  80089b:	74 04                	je     8008a1 <strcmp+0x17>
  80089d:	3a 02                	cmp    (%edx),%al
  80089f:	74 f4                	je     800895 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a1:	0f b6 c0             	movzbl %al,%eax
  8008a4:	0f b6 12             	movzbl (%edx),%edx
  8008a7:	29 d0                	sub    %edx,%eax
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008b8:	eb 03                	jmp    8008bd <strncmp+0x12>
		n--, p++, q++;
  8008ba:	4a                   	dec    %edx
  8008bb:	40                   	inc    %eax
  8008bc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008bd:	85 d2                	test   %edx,%edx
  8008bf:	74 14                	je     8008d5 <strncmp+0x2a>
  8008c1:	8a 18                	mov    (%eax),%bl
  8008c3:	84 db                	test   %bl,%bl
  8008c5:	74 04                	je     8008cb <strncmp+0x20>
  8008c7:	3a 19                	cmp    (%ecx),%bl
  8008c9:	74 ef                	je     8008ba <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cb:	0f b6 00             	movzbl (%eax),%eax
  8008ce:	0f b6 11             	movzbl (%ecx),%edx
  8008d1:	29 d0                	sub    %edx,%eax
  8008d3:	eb 05                	jmp    8008da <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008da:	5b                   	pop    %ebx
  8008db:	5d                   	pop    %ebp
  8008dc:	c3                   	ret    

008008dd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e6:	eb 05                	jmp    8008ed <strchr+0x10>
		if (*s == c)
  8008e8:	38 ca                	cmp    %cl,%dl
  8008ea:	74 0c                	je     8008f8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008ec:	40                   	inc    %eax
  8008ed:	8a 10                	mov    (%eax),%dl
  8008ef:	84 d2                	test   %dl,%dl
  8008f1:	75 f5                	jne    8008e8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800900:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800903:	eb 05                	jmp    80090a <strfind+0x10>
		if (*s == c)
  800905:	38 ca                	cmp    %cl,%dl
  800907:	74 07                	je     800910 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800909:	40                   	inc    %eax
  80090a:	8a 10                	mov    (%eax),%dl
  80090c:	84 d2                	test   %dl,%dl
  80090e:	75 f5                	jne    800905 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800921:	85 c9                	test   %ecx,%ecx
  800923:	74 30                	je     800955 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800925:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80092b:	75 25                	jne    800952 <memset+0x40>
  80092d:	f6 c1 03             	test   $0x3,%cl
  800930:	75 20                	jne    800952 <memset+0x40>
		c &= 0xFF;
  800932:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800935:	89 d3                	mov    %edx,%ebx
  800937:	c1 e3 08             	shl    $0x8,%ebx
  80093a:	89 d6                	mov    %edx,%esi
  80093c:	c1 e6 18             	shl    $0x18,%esi
  80093f:	89 d0                	mov    %edx,%eax
  800941:	c1 e0 10             	shl    $0x10,%eax
  800944:	09 f0                	or     %esi,%eax
  800946:	09 d0                	or     %edx,%eax
  800948:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80094d:	fc                   	cld    
  80094e:	f3 ab                	rep stos %eax,%es:(%edi)
  800950:	eb 03                	jmp    800955 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800952:	fc                   	cld    
  800953:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800955:	89 f8                	mov    %edi,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	57                   	push   %edi
  800960:	56                   	push   %esi
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 75 0c             	mov    0xc(%ebp),%esi
  800967:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096a:	39 c6                	cmp    %eax,%esi
  80096c:	73 34                	jae    8009a2 <memmove+0x46>
  80096e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800971:	39 d0                	cmp    %edx,%eax
  800973:	73 2d                	jae    8009a2 <memmove+0x46>
		s += n;
		d += n;
  800975:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800978:	f6 c2 03             	test   $0x3,%dl
  80097b:	75 1b                	jne    800998 <memmove+0x3c>
  80097d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800983:	75 13                	jne    800998 <memmove+0x3c>
  800985:	f6 c1 03             	test   $0x3,%cl
  800988:	75 0e                	jne    800998 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 07                	jmp    80099f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800998:	4f                   	dec    %edi
  800999:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80099c:	fd                   	std    
  80099d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099f:	fc                   	cld    
  8009a0:	eb 20                	jmp    8009c2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a8:	75 13                	jne    8009bd <memmove+0x61>
  8009aa:	a8 03                	test   $0x3,%al
  8009ac:	75 0f                	jne    8009bd <memmove+0x61>
  8009ae:	f6 c1 03             	test   $0x3,%cl
  8009b1:	75 0a                	jne    8009bd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b6:	89 c7                	mov    %eax,%edi
  8009b8:	fc                   	cld    
  8009b9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bb:	eb 05                	jmp    8009c2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c2:	5e                   	pop    %esi
  8009c3:	5f                   	pop    %edi
  8009c4:	5d                   	pop    %ebp
  8009c5:	c3                   	ret    

008009c6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	89 04 24             	mov    %eax,(%esp)
  8009e0:	e8 77 ff ff ff       	call   80095c <memmove>
}
  8009e5:	c9                   	leave  
  8009e6:	c3                   	ret    

008009e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	57                   	push   %edi
  8009eb:	56                   	push   %esi
  8009ec:	53                   	push   %ebx
  8009ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fb:	eb 16                	jmp    800a13 <memcmp+0x2c>
		if (*s1 != *s2)
  8009fd:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a00:	42                   	inc    %edx
  800a01:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a05:	38 c8                	cmp    %cl,%al
  800a07:	74 0a                	je     800a13 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c0             	movzbl %al,%eax
  800a0c:	0f b6 c9             	movzbl %cl,%ecx
  800a0f:	29 c8                	sub    %ecx,%eax
  800a11:	eb 09                	jmp    800a1c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	75 e6                	jne    8009fd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5b                   	pop    %ebx
  800a1d:	5e                   	pop    %esi
  800a1e:	5f                   	pop    %edi
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2a:	89 c2                	mov    %eax,%edx
  800a2c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2f:	eb 05                	jmp    800a36 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a31:	38 08                	cmp    %cl,(%eax)
  800a33:	74 05                	je     800a3a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a35:	40                   	inc    %eax
  800a36:	39 d0                	cmp    %edx,%eax
  800a38:	72 f7                	jb     800a31 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	57                   	push   %edi
  800a40:	56                   	push   %esi
  800a41:	53                   	push   %ebx
  800a42:	8b 55 08             	mov    0x8(%ebp),%edx
  800a45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a48:	eb 01                	jmp    800a4b <strtol+0xf>
		s++;
  800a4a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4b:	8a 02                	mov    (%edx),%al
  800a4d:	3c 20                	cmp    $0x20,%al
  800a4f:	74 f9                	je     800a4a <strtol+0xe>
  800a51:	3c 09                	cmp    $0x9,%al
  800a53:	74 f5                	je     800a4a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a55:	3c 2b                	cmp    $0x2b,%al
  800a57:	75 08                	jne    800a61 <strtol+0x25>
		s++;
  800a59:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5f:	eb 13                	jmp    800a74 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a61:	3c 2d                	cmp    $0x2d,%al
  800a63:	75 0a                	jne    800a6f <strtol+0x33>
		s++, neg = 1;
  800a65:	8d 52 01             	lea    0x1(%edx),%edx
  800a68:	bf 01 00 00 00       	mov    $0x1,%edi
  800a6d:	eb 05                	jmp    800a74 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	74 05                	je     800a7d <strtol+0x41>
  800a78:	83 fb 10             	cmp    $0x10,%ebx
  800a7b:	75 28                	jne    800aa5 <strtol+0x69>
  800a7d:	8a 02                	mov    (%edx),%al
  800a7f:	3c 30                	cmp    $0x30,%al
  800a81:	75 10                	jne    800a93 <strtol+0x57>
  800a83:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a87:	75 0a                	jne    800a93 <strtol+0x57>
		s += 2, base = 16;
  800a89:	83 c2 02             	add    $0x2,%edx
  800a8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a91:	eb 12                	jmp    800aa5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a93:	85 db                	test   %ebx,%ebx
  800a95:	75 0e                	jne    800aa5 <strtol+0x69>
  800a97:	3c 30                	cmp    $0x30,%al
  800a99:	75 05                	jne    800aa0 <strtol+0x64>
		s++, base = 8;
  800a9b:	42                   	inc    %edx
  800a9c:	b3 08                	mov    $0x8,%bl
  800a9e:	eb 05                	jmp    800aa5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800aa0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aaa:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aac:	8a 0a                	mov    (%edx),%cl
  800aae:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ab1:	80 fb 09             	cmp    $0x9,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x82>
			dig = *s - '0';
  800ab6:	0f be c9             	movsbl %cl,%ecx
  800ab9:	83 e9 30             	sub    $0x30,%ecx
  800abc:	eb 1e                	jmp    800adc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800abe:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ac1:	80 fb 19             	cmp    $0x19,%bl
  800ac4:	77 08                	ja     800ace <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac6:	0f be c9             	movsbl %cl,%ecx
  800ac9:	83 e9 57             	sub    $0x57,%ecx
  800acc:	eb 0e                	jmp    800adc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ace:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 12                	ja     800ae8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800adc:	39 f1                	cmp    %esi,%ecx
  800ade:	7d 0c                	jge    800aec <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ae0:	42                   	inc    %edx
  800ae1:	0f af c6             	imul   %esi,%eax
  800ae4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ae6:	eb c4                	jmp    800aac <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae8:	89 c1                	mov    %eax,%ecx
  800aea:	eb 02                	jmp    800aee <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aec:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800af2:	74 05                	je     800af9 <strtol+0xbd>
		*endptr = (char *) s;
  800af4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af9:	85 ff                	test   %edi,%edi
  800afb:	74 04                	je     800b01 <strtol+0xc5>
  800afd:	89 c8                	mov    %ecx,%eax
  800aff:	f7 d8                	neg    %eax
}
  800b01:	5b                   	pop    %ebx
  800b02:	5e                   	pop    %esi
  800b03:	5f                   	pop    %edi
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    
	...

00800b08 <__udivdi3>:
  800b08:	55                   	push   %ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	83 ec 10             	sub    $0x10,%esp
  800b0e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b12:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b1a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b1e:	89 cd                	mov    %ecx,%ebp
  800b20:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b24:	85 c0                	test   %eax,%eax
  800b26:	75 2c                	jne    800b54 <__udivdi3+0x4c>
  800b28:	39 f9                	cmp    %edi,%ecx
  800b2a:	77 68                	ja     800b94 <__udivdi3+0x8c>
  800b2c:	85 c9                	test   %ecx,%ecx
  800b2e:	75 0b                	jne    800b3b <__udivdi3+0x33>
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	31 d2                	xor    %edx,%edx
  800b37:	f7 f1                	div    %ecx
  800b39:	89 c1                	mov    %eax,%ecx
  800b3b:	31 d2                	xor    %edx,%edx
  800b3d:	89 f8                	mov    %edi,%eax
  800b3f:	f7 f1                	div    %ecx
  800b41:	89 c7                	mov    %eax,%edi
  800b43:	89 f0                	mov    %esi,%eax
  800b45:	f7 f1                	div    %ecx
  800b47:	89 c6                	mov    %eax,%esi
  800b49:	89 f0                	mov    %esi,%eax
  800b4b:	89 fa                	mov    %edi,%edx
  800b4d:	83 c4 10             	add    $0x10,%esp
  800b50:	5e                   	pop    %esi
  800b51:	5f                   	pop    %edi
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    
  800b54:	39 f8                	cmp    %edi,%eax
  800b56:	77 2c                	ja     800b84 <__udivdi3+0x7c>
  800b58:	0f bd f0             	bsr    %eax,%esi
  800b5b:	83 f6 1f             	xor    $0x1f,%esi
  800b5e:	75 4c                	jne    800bac <__udivdi3+0xa4>
  800b60:	39 f8                	cmp    %edi,%eax
  800b62:	bf 00 00 00 00       	mov    $0x0,%edi
  800b67:	72 0a                	jb     800b73 <__udivdi3+0x6b>
  800b69:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b6d:	0f 87 ad 00 00 00    	ja     800c20 <__udivdi3+0x118>
  800b73:	be 01 00 00 00       	mov    $0x1,%esi
  800b78:	89 f0                	mov    %esi,%eax
  800b7a:	89 fa                	mov    %edi,%edx
  800b7c:	83 c4 10             	add    $0x10,%esp
  800b7f:	5e                   	pop    %esi
  800b80:	5f                   	pop    %edi
  800b81:	5d                   	pop    %ebp
  800b82:	c3                   	ret    
  800b83:	90                   	nop
  800b84:	31 ff                	xor    %edi,%edi
  800b86:	31 f6                	xor    %esi,%esi
  800b88:	89 f0                	mov    %esi,%eax
  800b8a:	89 fa                	mov    %edi,%edx
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    
  800b93:	90                   	nop
  800b94:	89 fa                	mov    %edi,%edx
  800b96:	89 f0                	mov    %esi,%eax
  800b98:	f7 f1                	div    %ecx
  800b9a:	89 c6                	mov    %eax,%esi
  800b9c:	31 ff                	xor    %edi,%edi
  800b9e:	89 f0                	mov    %esi,%eax
  800ba0:	89 fa                	mov    %edi,%edx
  800ba2:	83 c4 10             	add    $0x10,%esp
  800ba5:	5e                   	pop    %esi
  800ba6:	5f                   	pop    %edi
  800ba7:	5d                   	pop    %ebp
  800ba8:	c3                   	ret    
  800ba9:	8d 76 00             	lea    0x0(%esi),%esi
  800bac:	89 f1                	mov    %esi,%ecx
  800bae:	d3 e0                	shl    %cl,%eax
  800bb0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb4:	b8 20 00 00 00       	mov    $0x20,%eax
  800bb9:	29 f0                	sub    %esi,%eax
  800bbb:	89 ea                	mov    %ebp,%edx
  800bbd:	88 c1                	mov    %al,%cl
  800bbf:	d3 ea                	shr    %cl,%edx
  800bc1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bc5:	09 ca                	or     %ecx,%edx
  800bc7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bcb:	89 f1                	mov    %esi,%ecx
  800bcd:	d3 e5                	shl    %cl,%ebp
  800bcf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800bd3:	89 fd                	mov    %edi,%ebp
  800bd5:	88 c1                	mov    %al,%cl
  800bd7:	d3 ed                	shr    %cl,%ebp
  800bd9:	89 fa                	mov    %edi,%edx
  800bdb:	89 f1                	mov    %esi,%ecx
  800bdd:	d3 e2                	shl    %cl,%edx
  800bdf:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800be3:	88 c1                	mov    %al,%cl
  800be5:	d3 ef                	shr    %cl,%edi
  800be7:	09 d7                	or     %edx,%edi
  800be9:	89 f8                	mov    %edi,%eax
  800beb:	89 ea                	mov    %ebp,%edx
  800bed:	f7 74 24 08          	divl   0x8(%esp)
  800bf1:	89 d1                	mov    %edx,%ecx
  800bf3:	89 c7                	mov    %eax,%edi
  800bf5:	f7 64 24 0c          	mull   0xc(%esp)
  800bf9:	39 d1                	cmp    %edx,%ecx
  800bfb:	72 17                	jb     800c14 <__udivdi3+0x10c>
  800bfd:	74 09                	je     800c08 <__udivdi3+0x100>
  800bff:	89 fe                	mov    %edi,%esi
  800c01:	31 ff                	xor    %edi,%edi
  800c03:	e9 41 ff ff ff       	jmp    800b49 <__udivdi3+0x41>
  800c08:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c0c:	89 f1                	mov    %esi,%ecx
  800c0e:	d3 e2                	shl    %cl,%edx
  800c10:	39 c2                	cmp    %eax,%edx
  800c12:	73 eb                	jae    800bff <__udivdi3+0xf7>
  800c14:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c17:	31 ff                	xor    %edi,%edi
  800c19:	e9 2b ff ff ff       	jmp    800b49 <__udivdi3+0x41>
  800c1e:	66 90                	xchg   %ax,%ax
  800c20:	31 f6                	xor    %esi,%esi
  800c22:	e9 22 ff ff ff       	jmp    800b49 <__udivdi3+0x41>
	...

00800c28 <__umoddi3>:
  800c28:	55                   	push   %ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	83 ec 20             	sub    $0x20,%esp
  800c2e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c32:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c36:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c3a:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c3e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c42:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c46:	89 c7                	mov    %eax,%edi
  800c48:	89 f2                	mov    %esi,%edx
  800c4a:	85 ed                	test   %ebp,%ebp
  800c4c:	75 16                	jne    800c64 <__umoddi3+0x3c>
  800c4e:	39 f1                	cmp    %esi,%ecx
  800c50:	0f 86 a6 00 00 00    	jbe    800cfc <__umoddi3+0xd4>
  800c56:	f7 f1                	div    %ecx
  800c58:	89 d0                	mov    %edx,%eax
  800c5a:	31 d2                	xor    %edx,%edx
  800c5c:	83 c4 20             	add    $0x20,%esp
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    
  800c63:	90                   	nop
  800c64:	39 f5                	cmp    %esi,%ebp
  800c66:	0f 87 ac 00 00 00    	ja     800d18 <__umoddi3+0xf0>
  800c6c:	0f bd c5             	bsr    %ebp,%eax
  800c6f:	83 f0 1f             	xor    $0x1f,%eax
  800c72:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c76:	0f 84 a8 00 00 00    	je     800d24 <__umoddi3+0xfc>
  800c7c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c80:	d3 e5                	shl    %cl,%ebp
  800c82:	bf 20 00 00 00       	mov    $0x20,%edi
  800c87:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800c8b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c8f:	89 f9                	mov    %edi,%ecx
  800c91:	d3 e8                	shr    %cl,%eax
  800c93:	09 e8                	or     %ebp,%eax
  800c95:	89 44 24 18          	mov    %eax,0x18(%esp)
  800c99:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c9d:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ca1:	d3 e0                	shl    %cl,%eax
  800ca3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ca7:	89 f2                	mov    %esi,%edx
  800ca9:	d3 e2                	shl    %cl,%edx
  800cab:	8b 44 24 14          	mov    0x14(%esp),%eax
  800caf:	d3 e0                	shl    %cl,%eax
  800cb1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cb5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cb9:	89 f9                	mov    %edi,%ecx
  800cbb:	d3 e8                	shr    %cl,%eax
  800cbd:	09 d0                	or     %edx,%eax
  800cbf:	d3 ee                	shr    %cl,%esi
  800cc1:	89 f2                	mov    %esi,%edx
  800cc3:	f7 74 24 18          	divl   0x18(%esp)
  800cc7:	89 d6                	mov    %edx,%esi
  800cc9:	f7 64 24 0c          	mull   0xc(%esp)
  800ccd:	89 c5                	mov    %eax,%ebp
  800ccf:	89 d1                	mov    %edx,%ecx
  800cd1:	39 d6                	cmp    %edx,%esi
  800cd3:	72 67                	jb     800d3c <__umoddi3+0x114>
  800cd5:	74 75                	je     800d4c <__umoddi3+0x124>
  800cd7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cdb:	29 e8                	sub    %ebp,%eax
  800cdd:	19 ce                	sbb    %ecx,%esi
  800cdf:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ce3:	d3 e8                	shr    %cl,%eax
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	89 f9                	mov    %edi,%ecx
  800ce9:	d3 e2                	shl    %cl,%edx
  800ceb:	09 d0                	or     %edx,%eax
  800ced:	89 f2                	mov    %esi,%edx
  800cef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cf3:	d3 ea                	shr    %cl,%edx
  800cf5:	83 c4 20             	add    $0x20,%esp
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
  800cfc:	85 c9                	test   %ecx,%ecx
  800cfe:	75 0b                	jne    800d0b <__umoddi3+0xe3>
  800d00:	b8 01 00 00 00       	mov    $0x1,%eax
  800d05:	31 d2                	xor    %edx,%edx
  800d07:	f7 f1                	div    %ecx
  800d09:	89 c1                	mov    %eax,%ecx
  800d0b:	89 f0                	mov    %esi,%eax
  800d0d:	31 d2                	xor    %edx,%edx
  800d0f:	f7 f1                	div    %ecx
  800d11:	89 f8                	mov    %edi,%eax
  800d13:	e9 3e ff ff ff       	jmp    800c56 <__umoddi3+0x2e>
  800d18:	89 f2                	mov    %esi,%edx
  800d1a:	83 c4 20             	add    $0x20,%esp
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    
  800d21:	8d 76 00             	lea    0x0(%esi),%esi
  800d24:	39 f5                	cmp    %esi,%ebp
  800d26:	72 04                	jb     800d2c <__umoddi3+0x104>
  800d28:	39 f9                	cmp    %edi,%ecx
  800d2a:	77 06                	ja     800d32 <__umoddi3+0x10a>
  800d2c:	89 f2                	mov    %esi,%edx
  800d2e:	29 cf                	sub    %ecx,%edi
  800d30:	19 ea                	sbb    %ebp,%edx
  800d32:	89 f8                	mov    %edi,%eax
  800d34:	83 c4 20             	add    $0x20,%esp
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    
  800d3b:	90                   	nop
  800d3c:	89 d1                	mov    %edx,%ecx
  800d3e:	89 c5                	mov    %eax,%ebp
  800d40:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d44:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d48:	eb 8d                	jmp    800cd7 <__umoddi3+0xaf>
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d50:	72 ea                	jb     800d3c <__umoddi3+0x114>
  800d52:	89 f1                	mov    %esi,%ecx
  800d54:	eb 81                	jmp    800cd7 <__umoddi3+0xaf>
