
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0f 00 00 00       	call   800040 <libmain>
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
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	5d                   	pop    %ebp
  80003e:	c3                   	ret    
	...

00800040 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
  800046:	8b 45 08             	mov    0x8(%ebp),%eax
  800049:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004c:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  800053:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	7e 08                	jle    800062 <libmain+0x22>
		binaryname = argv[0];
  80005a:	8b 0a                	mov    (%edx),%ecx
  80005c:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  800062:	89 54 24 04          	mov    %edx,0x4(%esp)
  800066:	89 04 24             	mov    %eax,(%esp)
  800069:	e8 c6 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006e:	e8 05 00 00 00       	call   800078 <exit>
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    
  800075:	00 00                	add    %al,(%eax)
	...

00800078 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800078:	55                   	push   %ebp
  800079:	89 e5                	mov    %esp,%ebp
  80007b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800085:	e8 3f 00 00 00       	call   8000c9 <sys_env_destroy>
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	57                   	push   %edi
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800092:	b8 00 00 00 00       	mov    $0x0,%eax
  800097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009a:	8b 55 08             	mov    0x8(%ebp),%edx
  80009d:	89 c3                	mov    %eax,%ebx
  80009f:	89 c7                	mov    %eax,%edi
  8000a1:	89 c6                	mov    %eax,%esi
  8000a3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a5:	5b                   	pop    %ebx
  8000a6:	5e                   	pop    %esi
  8000a7:	5f                   	pop    %edi
  8000a8:	5d                   	pop    %ebp
  8000a9:	c3                   	ret    

008000aa <sys_cgetc>:

int
sys_cgetc(void)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ba:	89 d1                	mov    %edx,%ecx
  8000bc:	89 d3                	mov    %edx,%ebx
  8000be:	89 d7                	mov    %edx,%edi
  8000c0:	89 d6                	mov    %edx,%esi
  8000c2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c4:	5b                   	pop    %ebx
  8000c5:	5e                   	pop    %esi
  8000c6:	5f                   	pop    %edi
  8000c7:	5d                   	pop    %ebp
  8000c8:	c3                   	ret    

008000c9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	57                   	push   %edi
  8000cd:	56                   	push   %esi
  8000ce:	53                   	push   %ebx
  8000cf:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d7:	b8 03 00 00 00       	mov    $0x3,%eax
  8000dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000df:	89 cb                	mov    %ecx,%ebx
  8000e1:	89 cf                	mov    %ecx,%edi
  8000e3:	89 ce                	mov    %ecx,%esi
  8000e5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000e7:	85 c0                	test   %eax,%eax
  8000e9:	7e 28                	jle    800113 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ef:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000f6:	00 
  8000f7:	c7 44 24 08 5e 0d 80 	movl   $0x800d5e,0x8(%esp)
  8000fe:	00 
  8000ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800106:	00 
  800107:	c7 04 24 7b 0d 80 00 	movl   $0x800d7b,(%esp)
  80010e:	e8 29 00 00 00       	call   80013c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	83 c4 2c             	add    $0x2c,%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    

0080011b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800121:	ba 00 00 00 00       	mov    $0x0,%edx
  800126:	b8 02 00 00 00       	mov    $0x2,%eax
  80012b:	89 d1                	mov    %edx,%ecx
  80012d:	89 d3                	mov    %edx,%ebx
  80012f:	89 d7                	mov    %edx,%edi
  800131:	89 d6                	mov    %edx,%esi
  800133:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    
	...

0080013c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800144:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800147:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  80014d:	e8 c9 ff ff ff       	call   80011b <sys_getenvid>
  800152:	8b 55 0c             	mov    0xc(%ebp),%edx
  800155:	89 54 24 10          	mov    %edx,0x10(%esp)
  800159:	8b 55 08             	mov    0x8(%ebp),%edx
  80015c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800160:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800164:	89 44 24 04          	mov    %eax,0x4(%esp)
  800168:	c7 04 24 8c 0d 80 00 	movl   $0x800d8c,(%esp)
  80016f:	e8 c0 00 00 00       	call   800234 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800174:	89 74 24 04          	mov    %esi,0x4(%esp)
  800178:	8b 45 10             	mov    0x10(%ebp),%eax
  80017b:	89 04 24             	mov    %eax,(%esp)
  80017e:	e8 50 00 00 00       	call   8001d3 <vcprintf>
	cprintf("\n");
  800183:	c7 04 24 b0 0d 80 00 	movl   $0x800db0,(%esp)
  80018a:	e8 a5 00 00 00       	call   800234 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018f:	cc                   	int3   
  800190:	eb fd                	jmp    80018f <_panic+0x53>
	...

00800194 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	53                   	push   %ebx
  800198:	83 ec 14             	sub    $0x14,%esp
  80019b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019e:	8b 03                	mov    (%ebx),%eax
  8001a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a3:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001a7:	40                   	inc    %eax
  8001a8:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001aa:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001af:	75 19                	jne    8001ca <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001b1:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b8:	00 
  8001b9:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bc:	89 04 24             	mov    %eax,(%esp)
  8001bf:	e8 c8 fe ff ff       	call   80008c <sys_cputs>
		b->idx = 0;
  8001c4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001ca:	ff 43 04             	incl   0x4(%ebx)
}
  8001cd:	83 c4 14             	add    $0x14,%esp
  8001d0:	5b                   	pop    %ebx
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e3:	00 00 00 
	b.cnt = 0;
  8001e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800204:	89 44 24 04          	mov    %eax,0x4(%esp)
  800208:	c7 04 24 94 01 80 00 	movl   $0x800194,(%esp)
  80020f:	e8 82 01 00 00       	call   800396 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80021a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800224:	89 04 24             	mov    %eax,(%esp)
  800227:	e8 60 fe ff ff       	call   80008c <sys_cputs>

	return b.cnt;
}
  80022c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800232:	c9                   	leave  
  800233:	c3                   	ret    

00800234 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80023a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800241:	8b 45 08             	mov    0x8(%ebp),%eax
  800244:	89 04 24             	mov    %eax,(%esp)
  800247:	e8 87 ff ff ff       	call   8001d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    
	...

00800250 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 3c             	sub    $0x3c,%esp
  800259:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80025c:	89 d7                	mov    %edx,%edi
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800264:	8b 45 0c             	mov    0xc(%ebp),%eax
  800267:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80026a:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80026d:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800270:	85 c0                	test   %eax,%eax
  800272:	75 08                	jne    80027c <printnum+0x2c>
  800274:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800277:	39 45 10             	cmp    %eax,0x10(%ebp)
  80027a:	77 57                	ja     8002d3 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80027c:	89 74 24 10          	mov    %esi,0x10(%esp)
  800280:	4b                   	dec    %ebx
  800281:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800285:	8b 45 10             	mov    0x10(%ebp),%eax
  800288:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028c:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  800290:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800294:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029b:	00 
  80029c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029f:	89 04 24             	mov    %eax,(%esp)
  8002a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a9:	e8 56 08 00 00       	call   800b04 <__udivdi3>
  8002ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002b2:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b6:	89 04 24             	mov    %eax,(%esp)
  8002b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002bd:	89 fa                	mov    %edi,%edx
  8002bf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002c2:	e8 89 ff ff ff       	call   800250 <printnum>
  8002c7:	eb 0f                	jmp    8002d8 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c9:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002cd:	89 34 24             	mov    %esi,(%esp)
  8002d0:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d3:	4b                   	dec    %ebx
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7f f1                	jg     8002c9 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002dc:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ee:	00 
  8002ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002f2:	89 04 24             	mov    %eax,(%esp)
  8002f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002fc:	e8 23 09 00 00       	call   800c24 <__umoddi3>
  800301:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800305:	0f be 80 b2 0d 80 00 	movsbl 0x800db2(%eax),%eax
  80030c:	89 04 24             	mov    %eax,(%esp)
  80030f:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800312:	83 c4 3c             	add    $0x3c,%esp
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80031d:	83 fa 01             	cmp    $0x1,%edx
  800320:	7e 0e                	jle    800330 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800322:	8b 10                	mov    (%eax),%edx
  800324:	8d 4a 08             	lea    0x8(%edx),%ecx
  800327:	89 08                	mov    %ecx,(%eax)
  800329:	8b 02                	mov    (%edx),%eax
  80032b:	8b 52 04             	mov    0x4(%edx),%edx
  80032e:	eb 22                	jmp    800352 <getuint+0x38>
	else if (lflag)
  800330:	85 d2                	test   %edx,%edx
  800332:	74 10                	je     800344 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800334:	8b 10                	mov    (%eax),%edx
  800336:	8d 4a 04             	lea    0x4(%edx),%ecx
  800339:	89 08                	mov    %ecx,(%eax)
  80033b:	8b 02                	mov    (%edx),%eax
  80033d:	ba 00 00 00 00       	mov    $0x0,%edx
  800342:	eb 0e                	jmp    800352 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800344:	8b 10                	mov    (%eax),%edx
  800346:	8d 4a 04             	lea    0x4(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 02                	mov    (%edx),%eax
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80035a:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	3b 50 04             	cmp    0x4(%eax),%edx
  800362:	73 08                	jae    80036c <sprintputch+0x18>
		*b->buf++ = ch;
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 0a                	mov    %cl,(%edx)
  800369:	42                   	inc    %edx
  80036a:	89 10                	mov    %edx,(%eax)
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800374:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800377:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80037b:	8b 45 10             	mov    0x10(%ebp),%eax
  80037e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800382:	8b 45 0c             	mov    0xc(%ebp),%eax
  800385:	89 44 24 04          	mov    %eax,0x4(%esp)
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	89 04 24             	mov    %eax,(%esp)
  80038f:	e8 02 00 00 00       	call   800396 <vprintfmt>
	va_end(ap);
}
  800394:	c9                   	leave  
  800395:	c3                   	ret    

00800396 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	57                   	push   %edi
  80039a:	56                   	push   %esi
  80039b:	53                   	push   %ebx
  80039c:	83 ec 4c             	sub    $0x4c,%esp
  80039f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003a2:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a5:	eb 12                	jmp    8003b9 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a7:	85 c0                	test   %eax,%eax
  8003a9:	0f 84 6b 03 00 00    	je     80071a <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003af:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003b3:	89 04 24             	mov    %eax,(%esp)
  8003b6:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b9:	0f b6 06             	movzbl (%esi),%eax
  8003bc:	46                   	inc    %esi
  8003bd:	83 f8 25             	cmp    $0x25,%eax
  8003c0:	75 e5                	jne    8003a7 <vprintfmt+0x11>
  8003c2:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003c6:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003cd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003d2:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003de:	eb 26                	jmp    800406 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e0:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003e3:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003e7:	eb 1d                	jmp    800406 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ec:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003f0:	eb 14                	jmp    800406 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003fc:	eb 08                	jmp    800406 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003fe:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800401:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	0f b6 06             	movzbl (%esi),%eax
  800409:	8d 56 01             	lea    0x1(%esi),%edx
  80040c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80040f:	8a 16                	mov    (%esi),%dl
  800411:	83 ea 23             	sub    $0x23,%edx
  800414:	80 fa 55             	cmp    $0x55,%dl
  800417:	0f 87 e1 02 00 00    	ja     8006fe <vprintfmt+0x368>
  80041d:	0f b6 d2             	movzbl %dl,%edx
  800420:	ff 24 95 40 0e 80 00 	jmp    *0x800e40(,%edx,4)
  800427:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80042a:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042f:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800432:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800436:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800439:	8d 50 d0             	lea    -0x30(%eax),%edx
  80043c:	83 fa 09             	cmp    $0x9,%edx
  80043f:	77 2a                	ja     80046b <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800441:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800442:	eb eb                	jmp    80042f <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800444:	8b 45 14             	mov    0x14(%ebp),%eax
  800447:	8d 50 04             	lea    0x4(%eax),%edx
  80044a:	89 55 14             	mov    %edx,0x14(%ebp)
  80044d:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800452:	eb 17                	jmp    80046b <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800454:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800458:	78 98                	js     8003f2 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80045d:	eb a7                	jmp    800406 <vprintfmt+0x70>
  80045f:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800462:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800469:	eb 9b                	jmp    800406 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80046b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046f:	79 95                	jns    800406 <vprintfmt+0x70>
  800471:	eb 8b                	jmp    8003fe <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800473:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800477:	eb 8d                	jmp    800406 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 50 04             	lea    0x4(%eax),%edx
  80047f:	89 55 14             	mov    %edx,0x14(%ebp)
  800482:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800486:	8b 00                	mov    (%eax),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800491:	e9 23 ff ff ff       	jmp    8003b9 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800496:	8b 45 14             	mov    0x14(%ebp),%eax
  800499:	8d 50 04             	lea    0x4(%eax),%edx
  80049c:	89 55 14             	mov    %edx,0x14(%ebp)
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	85 c0                	test   %eax,%eax
  8004a3:	79 02                	jns    8004a7 <vprintfmt+0x111>
  8004a5:	f7 d8                	neg    %eax
  8004a7:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a9:	83 f8 06             	cmp    $0x6,%eax
  8004ac:	7f 0b                	jg     8004b9 <vprintfmt+0x123>
  8004ae:	8b 04 85 98 0f 80 00 	mov    0x800f98(,%eax,4),%eax
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	75 23                	jne    8004dc <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004b9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bd:	c7 44 24 08 ca 0d 80 	movl   $0x800dca,0x8(%esp)
  8004c4:	00 
  8004c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004cc:	89 04 24             	mov    %eax,(%esp)
  8004cf:	e8 9a fe ff ff       	call   80036e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d4:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d7:	e9 dd fe ff ff       	jmp    8003b9 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e0:	c7 44 24 08 d3 0d 80 	movl   $0x800dd3,0x8(%esp)
  8004e7:	00 
  8004e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8004ef:	89 14 24             	mov    %edx,(%esp)
  8004f2:	e8 77 fe ff ff       	call   80036e <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004fa:	e9 ba fe ff ff       	jmp    8003b9 <vprintfmt+0x23>
  8004ff:	89 f9                	mov    %edi,%ecx
  800501:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800504:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800507:	8b 45 14             	mov    0x14(%ebp),%eax
  80050a:	8d 50 04             	lea    0x4(%eax),%edx
  80050d:	89 55 14             	mov    %edx,0x14(%ebp)
  800510:	8b 30                	mov    (%eax),%esi
  800512:	85 f6                	test   %esi,%esi
  800514:	75 05                	jne    80051b <vprintfmt+0x185>
				p = "(null)";
  800516:	be c3 0d 80 00       	mov    $0x800dc3,%esi
			if (width > 0 && padc != '-')
  80051b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051f:	0f 8e 84 00 00 00    	jle    8005a9 <vprintfmt+0x213>
  800525:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800529:	74 7e                	je     8005a9 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80052b:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80052f:	89 34 24             	mov    %esi,(%esp)
  800532:	e8 8b 02 00 00       	call   8007c2 <strnlen>
  800537:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80053a:	29 c2                	sub    %eax,%edx
  80053c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80053f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800543:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800546:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800549:	89 de                	mov    %ebx,%esi
  80054b:	89 d3                	mov    %edx,%ebx
  80054d:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	eb 0b                	jmp    80055c <vprintfmt+0x1c6>
					putch(padc, putdat);
  800551:	89 74 24 04          	mov    %esi,0x4(%esp)
  800555:	89 3c 24             	mov    %edi,(%esp)
  800558:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055b:	4b                   	dec    %ebx
  80055c:	85 db                	test   %ebx,%ebx
  80055e:	7f f1                	jg     800551 <vprintfmt+0x1bb>
  800560:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800563:	89 f3                	mov    %esi,%ebx
  800565:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800568:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056b:	85 c0                	test   %eax,%eax
  80056d:	79 05                	jns    800574 <vprintfmt+0x1de>
  80056f:	b8 00 00 00 00       	mov    $0x0,%eax
  800574:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800577:	29 c2                	sub    %eax,%edx
  800579:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80057c:	eb 2b                	jmp    8005a9 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800582:	74 18                	je     80059c <vprintfmt+0x206>
  800584:	8d 50 e0             	lea    -0x20(%eax),%edx
  800587:	83 fa 5e             	cmp    $0x5e,%edx
  80058a:	76 10                	jbe    80059c <vprintfmt+0x206>
					putch('?', putdat);
  80058c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800590:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800597:	ff 55 08             	call   *0x8(%ebp)
  80059a:	eb 0a                	jmp    8005a6 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  80059c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a0:	89 04 24             	mov    %eax,(%esp)
  8005a3:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a6:	ff 4d e4             	decl   -0x1c(%ebp)
  8005a9:	0f be 06             	movsbl (%esi),%eax
  8005ac:	46                   	inc    %esi
  8005ad:	85 c0                	test   %eax,%eax
  8005af:	74 21                	je     8005d2 <vprintfmt+0x23c>
  8005b1:	85 ff                	test   %edi,%edi
  8005b3:	78 c9                	js     80057e <vprintfmt+0x1e8>
  8005b5:	4f                   	dec    %edi
  8005b6:	79 c6                	jns    80057e <vprintfmt+0x1e8>
  8005b8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005bb:	89 de                	mov    %ebx,%esi
  8005bd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005c0:	eb 18                	jmp    8005da <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c6:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005cd:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cf:	4b                   	dec    %ebx
  8005d0:	eb 08                	jmp    8005da <vprintfmt+0x244>
  8005d2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d5:	89 de                	mov    %ebx,%esi
  8005d7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005da:	85 db                	test   %ebx,%ebx
  8005dc:	7f e4                	jg     8005c2 <vprintfmt+0x22c>
  8005de:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005e1:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e6:	e9 ce fd ff ff       	jmp    8003b9 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005eb:	83 f9 01             	cmp    $0x1,%ecx
  8005ee:	7e 10                	jle    800600 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f3:	8d 50 08             	lea    0x8(%eax),%edx
  8005f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f9:	8b 30                	mov    (%eax),%esi
  8005fb:	8b 78 04             	mov    0x4(%eax),%edi
  8005fe:	eb 26                	jmp    800626 <vprintfmt+0x290>
	else if (lflag)
  800600:	85 c9                	test   %ecx,%ecx
  800602:	74 12                	je     800616 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 30                	mov    (%eax),%esi
  80060f:	89 f7                	mov    %esi,%edi
  800611:	c1 ff 1f             	sar    $0x1f,%edi
  800614:	eb 10                	jmp    800626 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800616:	8b 45 14             	mov    0x14(%ebp),%eax
  800619:	8d 50 04             	lea    0x4(%eax),%edx
  80061c:	89 55 14             	mov    %edx,0x14(%ebp)
  80061f:	8b 30                	mov    (%eax),%esi
  800621:	89 f7                	mov    %esi,%edi
  800623:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800626:	85 ff                	test   %edi,%edi
  800628:	78 0a                	js     800634 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80062a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062f:	e9 8c 00 00 00       	jmp    8006c0 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800634:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800638:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063f:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800642:	f7 de                	neg    %esi
  800644:	83 d7 00             	adc    $0x0,%edi
  800647:	f7 df                	neg    %edi
			}
			base = 10;
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064e:	eb 70                	jmp    8006c0 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800650:	89 ca                	mov    %ecx,%edx
  800652:	8d 45 14             	lea    0x14(%ebp),%eax
  800655:	e8 c0 fc ff ff       	call   80031a <getuint>
  80065a:	89 c6                	mov    %eax,%esi
  80065c:	89 d7                	mov    %edx,%edi
			base = 10;
  80065e:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800663:	eb 5b                	jmp    8006c0 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800665:	89 ca                	mov    %ecx,%edx
  800667:	8d 45 14             	lea    0x14(%ebp),%eax
  80066a:	e8 ab fc ff ff       	call   80031a <getuint>
  80066f:	89 c6                	mov    %eax,%esi
  800671:	89 d7                	mov    %edx,%edi
			base = 8;
  800673:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800678:	eb 46                	jmp    8006c0 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80067a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800685:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800688:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80068c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800693:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800696:	8b 45 14             	mov    0x14(%ebp),%eax
  800699:	8d 50 04             	lea    0x4(%eax),%edx
  80069c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069f:	8b 30                	mov    (%eax),%esi
  8006a1:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ab:	eb 13                	jmp    8006c0 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006ad:	89 ca                	mov    %ecx,%edx
  8006af:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b2:	e8 63 fc ff ff       	call   80031a <getuint>
  8006b7:	89 c6                	mov    %eax,%esi
  8006b9:	89 d7                	mov    %edx,%edi
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006c4:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006d3:	89 34 24             	mov    %esi,(%esp)
  8006d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006da:	89 da                	mov    %ebx,%edx
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	e8 6c fb ff ff       	call   800250 <printnum>
			break;
  8006e4:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e7:	e9 cd fc ff ff       	jmp    8003b9 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006ec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006f0:	89 04 24             	mov    %eax,(%esp)
  8006f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f9:	e9 bb fc ff ff       	jmp    8003b9 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800702:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800709:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  80070c:	eb 01                	jmp    80070f <vprintfmt+0x379>
  80070e:	4e                   	dec    %esi
  80070f:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800713:	75 f9                	jne    80070e <vprintfmt+0x378>
  800715:	e9 9f fc ff ff       	jmp    8003b9 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80071a:	83 c4 4c             	add    $0x4c,%esp
  80071d:	5b                   	pop    %ebx
  80071e:	5e                   	pop    %esi
  80071f:	5f                   	pop    %edi
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    

00800722 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	83 ec 28             	sub    $0x28,%esp
  800728:	8b 45 08             	mov    0x8(%ebp),%eax
  80072b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800731:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800735:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800738:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073f:	85 c0                	test   %eax,%eax
  800741:	74 30                	je     800773 <vsnprintf+0x51>
  800743:	85 d2                	test   %edx,%edx
  800745:	7e 33                	jle    80077a <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074e:	8b 45 10             	mov    0x10(%ebp),%eax
  800751:	89 44 24 08          	mov    %eax,0x8(%esp)
  800755:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075c:	c7 04 24 54 03 80 00 	movl   $0x800354,(%esp)
  800763:	e8 2e fc ff ff       	call   800396 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	eb 0c                	jmp    80077f <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800773:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800778:	eb 05                	jmp    80077f <vsnprintf+0x5d>
  80077a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077f:	c9                   	leave  
  800780:	c3                   	ret    

00800781 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800787:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80078a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078e:	8b 45 10             	mov    0x10(%ebp),%eax
  800791:	89 44 24 08          	mov    %eax,0x8(%esp)
  800795:	8b 45 0c             	mov    0xc(%ebp),%eax
  800798:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079c:	8b 45 08             	mov    0x8(%ebp),%eax
  80079f:	89 04 24             	mov    %eax,(%esp)
  8007a2:	e8 7b ff ff ff       	call   800722 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    
  8007a9:	00 00                	add    %al,(%eax)
	...

008007ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	eb 01                	jmp    8007ba <strlen+0xe>
		n++;
  8007b9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007be:	75 f9                	jne    8007b9 <strlen+0xd>
		n++;
	return n;
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007c8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d0:	eb 01                	jmp    8007d3 <strnlen+0x11>
		n++;
  8007d2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d3:	39 d0                	cmp    %edx,%eax
  8007d5:	74 06                	je     8007dd <strnlen+0x1b>
  8007d7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007db:	75 f5                	jne    8007d2 <strnlen+0x10>
		n++;
	return n;
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	53                   	push   %ebx
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ee:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007f1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f4:	42                   	inc    %edx
  8007f5:	84 c9                	test   %cl,%cl
  8007f7:	75 f5                	jne    8007ee <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f9:	5b                   	pop    %ebx
  8007fa:	5d                   	pop    %ebp
  8007fb:	c3                   	ret    

008007fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	53                   	push   %ebx
  800800:	83 ec 08             	sub    $0x8,%esp
  800803:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800806:	89 1c 24             	mov    %ebx,(%esp)
  800809:	e8 9e ff ff ff       	call   8007ac <strlen>
	strcpy(dst + len, src);
  80080e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800811:	89 54 24 04          	mov    %edx,0x4(%esp)
  800815:	01 d8                	add    %ebx,%eax
  800817:	89 04 24             	mov    %eax,(%esp)
  80081a:	e8 c0 ff ff ff       	call   8007df <strcpy>
	return dst;
}
  80081f:	89 d8                	mov    %ebx,%eax
  800821:	83 c4 08             	add    $0x8,%esp
  800824:	5b                   	pop    %ebx
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 45 08             	mov    0x8(%ebp),%eax
  80082f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800832:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800835:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083a:	eb 0c                	jmp    800848 <strncpy+0x21>
		*dst++ = *src;
  80083c:	8a 1a                	mov    (%edx),%bl
  80083e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800841:	80 3a 01             	cmpb   $0x1,(%edx)
  800844:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800847:	41                   	inc    %ecx
  800848:	39 f1                	cmp    %esi,%ecx
  80084a:	75 f0                	jne    80083c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80084c:	5b                   	pop    %ebx
  80084d:	5e                   	pop    %esi
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	56                   	push   %esi
  800854:	53                   	push   %ebx
  800855:	8b 75 08             	mov    0x8(%ebp),%esi
  800858:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80085b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085e:	85 d2                	test   %edx,%edx
  800860:	75 0a                	jne    80086c <strlcpy+0x1c>
  800862:	89 f0                	mov    %esi,%eax
  800864:	eb 1a                	jmp    800880 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800866:	88 18                	mov    %bl,(%eax)
  800868:	40                   	inc    %eax
  800869:	41                   	inc    %ecx
  80086a:	eb 02                	jmp    80086e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80086c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80086e:	4a                   	dec    %edx
  80086f:	74 0a                	je     80087b <strlcpy+0x2b>
  800871:	8a 19                	mov    (%ecx),%bl
  800873:	84 db                	test   %bl,%bl
  800875:	75 ef                	jne    800866 <strlcpy+0x16>
  800877:	89 c2                	mov    %eax,%edx
  800879:	eb 02                	jmp    80087d <strlcpy+0x2d>
  80087b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  80087d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800880:	29 f0                	sub    %esi,%eax
}
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088f:	eb 02                	jmp    800893 <strcmp+0xd>
		p++, q++;
  800891:	41                   	inc    %ecx
  800892:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800893:	8a 01                	mov    (%ecx),%al
  800895:	84 c0                	test   %al,%al
  800897:	74 04                	je     80089d <strcmp+0x17>
  800899:	3a 02                	cmp    (%edx),%al
  80089b:	74 f4                	je     800891 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089d:	0f b6 c0             	movzbl %al,%eax
  8008a0:	0f b6 12             	movzbl (%edx),%edx
  8008a3:	29 d0                	sub    %edx,%eax
}
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a7:	55                   	push   %ebp
  8008a8:	89 e5                	mov    %esp,%ebp
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008b4:	eb 03                	jmp    8008b9 <strncmp+0x12>
		n--, p++, q++;
  8008b6:	4a                   	dec    %edx
  8008b7:	40                   	inc    %eax
  8008b8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	74 14                	je     8008d1 <strncmp+0x2a>
  8008bd:	8a 18                	mov    (%eax),%bl
  8008bf:	84 db                	test   %bl,%bl
  8008c1:	74 04                	je     8008c7 <strncmp+0x20>
  8008c3:	3a 19                	cmp    (%ecx),%bl
  8008c5:	74 ef                	je     8008b6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c7:	0f b6 00             	movzbl (%eax),%eax
  8008ca:	0f b6 11             	movzbl (%ecx),%edx
  8008cd:	29 d0                	sub    %edx,%eax
  8008cf:	eb 05                	jmp    8008d6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008d1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d6:	5b                   	pop    %ebx
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d9:	55                   	push   %ebp
  8008da:	89 e5                	mov    %esp,%ebp
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008e2:	eb 05                	jmp    8008e9 <strchr+0x10>
		if (*s == c)
  8008e4:	38 ca                	cmp    %cl,%dl
  8008e6:	74 0c                	je     8008f4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e8:	40                   	inc    %eax
  8008e9:	8a 10                	mov    (%eax),%dl
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	75 f5                	jne    8008e4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008ff:	eb 05                	jmp    800906 <strfind+0x10>
		if (*s == c)
  800901:	38 ca                	cmp    %cl,%dl
  800903:	74 07                	je     80090c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800905:	40                   	inc    %eax
  800906:	8a 10                	mov    (%eax),%dl
  800908:	84 d2                	test   %dl,%dl
  80090a:	75 f5                	jne    800901 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	57                   	push   %edi
  800912:	56                   	push   %esi
  800913:	53                   	push   %ebx
  800914:	8b 7d 08             	mov    0x8(%ebp),%edi
  800917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80091d:	85 c9                	test   %ecx,%ecx
  80091f:	74 30                	je     800951 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800921:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800927:	75 25                	jne    80094e <memset+0x40>
  800929:	f6 c1 03             	test   $0x3,%cl
  80092c:	75 20                	jne    80094e <memset+0x40>
		c &= 0xFF;
  80092e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800931:	89 d3                	mov    %edx,%ebx
  800933:	c1 e3 08             	shl    $0x8,%ebx
  800936:	89 d6                	mov    %edx,%esi
  800938:	c1 e6 18             	shl    $0x18,%esi
  80093b:	89 d0                	mov    %edx,%eax
  80093d:	c1 e0 10             	shl    $0x10,%eax
  800940:	09 f0                	or     %esi,%eax
  800942:	09 d0                	or     %edx,%eax
  800944:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800946:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800949:	fc                   	cld    
  80094a:	f3 ab                	rep stos %eax,%es:(%edi)
  80094c:	eb 03                	jmp    800951 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094e:	fc                   	cld    
  80094f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800951:	89 f8                	mov    %edi,%eax
  800953:	5b                   	pop    %ebx
  800954:	5e                   	pop    %esi
  800955:	5f                   	pop    %edi
  800956:	5d                   	pop    %ebp
  800957:	c3                   	ret    

00800958 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	57                   	push   %edi
  80095c:	56                   	push   %esi
  80095d:	8b 45 08             	mov    0x8(%ebp),%eax
  800960:	8b 75 0c             	mov    0xc(%ebp),%esi
  800963:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800966:	39 c6                	cmp    %eax,%esi
  800968:	73 34                	jae    80099e <memmove+0x46>
  80096a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80096d:	39 d0                	cmp    %edx,%eax
  80096f:	73 2d                	jae    80099e <memmove+0x46>
		s += n;
		d += n;
  800971:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800974:	f6 c2 03             	test   $0x3,%dl
  800977:	75 1b                	jne    800994 <memmove+0x3c>
  800979:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097f:	75 13                	jne    800994 <memmove+0x3c>
  800981:	f6 c1 03             	test   $0x3,%cl
  800984:	75 0e                	jne    800994 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800986:	83 ef 04             	sub    $0x4,%edi
  800989:	8d 72 fc             	lea    -0x4(%edx),%esi
  80098c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098f:	fd                   	std    
  800990:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800992:	eb 07                	jmp    80099b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800994:	4f                   	dec    %edi
  800995:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800998:	fd                   	std    
  800999:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80099b:	fc                   	cld    
  80099c:	eb 20                	jmp    8009be <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a4:	75 13                	jne    8009b9 <memmove+0x61>
  8009a6:	a8 03                	test   $0x3,%al
  8009a8:	75 0f                	jne    8009b9 <memmove+0x61>
  8009aa:	f6 c1 03             	test   $0x3,%cl
  8009ad:	75 0a                	jne    8009b9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009af:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 05                	jmp    8009be <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	89 04 24             	mov    %eax,(%esp)
  8009dc:	e8 77 ff ff ff       	call   800958 <memmove>
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f7:	eb 16                	jmp    800a0f <memcmp+0x2c>
		if (*s1 != *s2)
  8009f9:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009fc:	42                   	inc    %edx
  8009fd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a01:	38 c8                	cmp    %cl,%al
  800a03:	74 0a                	je     800a0f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a05:	0f b6 c0             	movzbl %al,%eax
  800a08:	0f b6 c9             	movzbl %cl,%ecx
  800a0b:	29 c8                	sub    %ecx,%eax
  800a0d:	eb 09                	jmp    800a18 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0f:	39 da                	cmp    %ebx,%edx
  800a11:	75 e6                	jne    8009f9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5f                   	pop    %edi
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2b:	eb 05                	jmp    800a32 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2d:	38 08                	cmp    %cl,(%eax)
  800a2f:	74 05                	je     800a36 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a31:	40                   	inc    %eax
  800a32:	39 d0                	cmp    %edx,%eax
  800a34:	72 f7                	jb     800a2d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	57                   	push   %edi
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a41:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a44:	eb 01                	jmp    800a47 <strtol+0xf>
		s++;
  800a46:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a47:	8a 02                	mov    (%edx),%al
  800a49:	3c 20                	cmp    $0x20,%al
  800a4b:	74 f9                	je     800a46 <strtol+0xe>
  800a4d:	3c 09                	cmp    $0x9,%al
  800a4f:	74 f5                	je     800a46 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a51:	3c 2b                	cmp    $0x2b,%al
  800a53:	75 08                	jne    800a5d <strtol+0x25>
		s++;
  800a55:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a56:	bf 00 00 00 00       	mov    $0x0,%edi
  800a5b:	eb 13                	jmp    800a70 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a5d:	3c 2d                	cmp    $0x2d,%al
  800a5f:	75 0a                	jne    800a6b <strtol+0x33>
		s++, neg = 1;
  800a61:	8d 52 01             	lea    0x1(%edx),%edx
  800a64:	bf 01 00 00 00       	mov    $0x1,%edi
  800a69:	eb 05                	jmp    800a70 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	85 db                	test   %ebx,%ebx
  800a72:	74 05                	je     800a79 <strtol+0x41>
  800a74:	83 fb 10             	cmp    $0x10,%ebx
  800a77:	75 28                	jne    800aa1 <strtol+0x69>
  800a79:	8a 02                	mov    (%edx),%al
  800a7b:	3c 30                	cmp    $0x30,%al
  800a7d:	75 10                	jne    800a8f <strtol+0x57>
  800a7f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a83:	75 0a                	jne    800a8f <strtol+0x57>
		s += 2, base = 16;
  800a85:	83 c2 02             	add    $0x2,%edx
  800a88:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8d:	eb 12                	jmp    800aa1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a8f:	85 db                	test   %ebx,%ebx
  800a91:	75 0e                	jne    800aa1 <strtol+0x69>
  800a93:	3c 30                	cmp    $0x30,%al
  800a95:	75 05                	jne    800a9c <strtol+0x64>
		s++, base = 8;
  800a97:	42                   	inc    %edx
  800a98:	b3 08                	mov    $0x8,%bl
  800a9a:	eb 05                	jmp    800aa1 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a9c:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800aa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa8:	8a 0a                	mov    (%edx),%cl
  800aaa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aad:	80 fb 09             	cmp    $0x9,%bl
  800ab0:	77 08                	ja     800aba <strtol+0x82>
			dig = *s - '0';
  800ab2:	0f be c9             	movsbl %cl,%ecx
  800ab5:	83 e9 30             	sub    $0x30,%ecx
  800ab8:	eb 1e                	jmp    800ad8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800aba:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800abd:	80 fb 19             	cmp    $0x19,%bl
  800ac0:	77 08                	ja     800aca <strtol+0x92>
			dig = *s - 'a' + 10;
  800ac2:	0f be c9             	movsbl %cl,%ecx
  800ac5:	83 e9 57             	sub    $0x57,%ecx
  800ac8:	eb 0e                	jmp    800ad8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800aca:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 12                	ja     800ae4 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ad2:	0f be c9             	movsbl %cl,%ecx
  800ad5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad8:	39 f1                	cmp    %esi,%ecx
  800ada:	7d 0c                	jge    800ae8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800adc:	42                   	inc    %edx
  800add:	0f af c6             	imul   %esi,%eax
  800ae0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ae2:	eb c4                	jmp    800aa8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae4:	89 c1                	mov    %eax,%ecx
  800ae6:	eb 02                	jmp    800aea <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800aea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aee:	74 05                	je     800af5 <strtol+0xbd>
		*endptr = (char *) s;
  800af0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af5:	85 ff                	test   %edi,%edi
  800af7:	74 04                	je     800afd <strtol+0xc5>
  800af9:	89 c8                	mov    %ecx,%eax
  800afb:	f7 d8                	neg    %eax
}
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5f                   	pop    %edi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    
	...

00800b04 <__udivdi3>:
  800b04:	55                   	push   %ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	83 ec 10             	sub    $0x10,%esp
  800b0a:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b0e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b12:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b16:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b1a:	89 cd                	mov    %ecx,%ebp
  800b1c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b20:	85 c0                	test   %eax,%eax
  800b22:	75 2c                	jne    800b50 <__udivdi3+0x4c>
  800b24:	39 f9                	cmp    %edi,%ecx
  800b26:	77 68                	ja     800b90 <__udivdi3+0x8c>
  800b28:	85 c9                	test   %ecx,%ecx
  800b2a:	75 0b                	jne    800b37 <__udivdi3+0x33>
  800b2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b31:	31 d2                	xor    %edx,%edx
  800b33:	f7 f1                	div    %ecx
  800b35:	89 c1                	mov    %eax,%ecx
  800b37:	31 d2                	xor    %edx,%edx
  800b39:	89 f8                	mov    %edi,%eax
  800b3b:	f7 f1                	div    %ecx
  800b3d:	89 c7                	mov    %eax,%edi
  800b3f:	89 f0                	mov    %esi,%eax
  800b41:	f7 f1                	div    %ecx
  800b43:	89 c6                	mov    %eax,%esi
  800b45:	89 f0                	mov    %esi,%eax
  800b47:	89 fa                	mov    %edi,%edx
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	5e                   	pop    %esi
  800b4d:	5f                   	pop    %edi
  800b4e:	5d                   	pop    %ebp
  800b4f:	c3                   	ret    
  800b50:	39 f8                	cmp    %edi,%eax
  800b52:	77 2c                	ja     800b80 <__udivdi3+0x7c>
  800b54:	0f bd f0             	bsr    %eax,%esi
  800b57:	83 f6 1f             	xor    $0x1f,%esi
  800b5a:	75 4c                	jne    800ba8 <__udivdi3+0xa4>
  800b5c:	39 f8                	cmp    %edi,%eax
  800b5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b63:	72 0a                	jb     800b6f <__udivdi3+0x6b>
  800b65:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b69:	0f 87 ad 00 00 00    	ja     800c1c <__udivdi3+0x118>
  800b6f:	be 01 00 00 00       	mov    $0x1,%esi
  800b74:	89 f0                	mov    %esi,%eax
  800b76:	89 fa                	mov    %edi,%edx
  800b78:	83 c4 10             	add    $0x10,%esp
  800b7b:	5e                   	pop    %esi
  800b7c:	5f                   	pop    %edi
  800b7d:	5d                   	pop    %ebp
  800b7e:	c3                   	ret    
  800b7f:	90                   	nop
  800b80:	31 ff                	xor    %edi,%edi
  800b82:	31 f6                	xor    %esi,%esi
  800b84:	89 f0                	mov    %esi,%eax
  800b86:	89 fa                	mov    %edi,%edx
  800b88:	83 c4 10             	add    $0x10,%esp
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    
  800b8f:	90                   	nop
  800b90:	89 fa                	mov    %edi,%edx
  800b92:	89 f0                	mov    %esi,%eax
  800b94:	f7 f1                	div    %ecx
  800b96:	89 c6                	mov    %eax,%esi
  800b98:	31 ff                	xor    %edi,%edi
  800b9a:	89 f0                	mov    %esi,%eax
  800b9c:	89 fa                	mov    %edi,%edx
  800b9e:	83 c4 10             	add    $0x10,%esp
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    
  800ba5:	8d 76 00             	lea    0x0(%esi),%esi
  800ba8:	89 f1                	mov    %esi,%ecx
  800baa:	d3 e0                	shl    %cl,%eax
  800bac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bb0:	b8 20 00 00 00       	mov    $0x20,%eax
  800bb5:	29 f0                	sub    %esi,%eax
  800bb7:	89 ea                	mov    %ebp,%edx
  800bb9:	88 c1                	mov    %al,%cl
  800bbb:	d3 ea                	shr    %cl,%edx
  800bbd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bc1:	09 ca                	or     %ecx,%edx
  800bc3:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bc7:	89 f1                	mov    %esi,%ecx
  800bc9:	d3 e5                	shl    %cl,%ebp
  800bcb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800bcf:	89 fd                	mov    %edi,%ebp
  800bd1:	88 c1                	mov    %al,%cl
  800bd3:	d3 ed                	shr    %cl,%ebp
  800bd5:	89 fa                	mov    %edi,%edx
  800bd7:	89 f1                	mov    %esi,%ecx
  800bd9:	d3 e2                	shl    %cl,%edx
  800bdb:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bdf:	88 c1                	mov    %al,%cl
  800be1:	d3 ef                	shr    %cl,%edi
  800be3:	09 d7                	or     %edx,%edi
  800be5:	89 f8                	mov    %edi,%eax
  800be7:	89 ea                	mov    %ebp,%edx
  800be9:	f7 74 24 08          	divl   0x8(%esp)
  800bed:	89 d1                	mov    %edx,%ecx
  800bef:	89 c7                	mov    %eax,%edi
  800bf1:	f7 64 24 0c          	mull   0xc(%esp)
  800bf5:	39 d1                	cmp    %edx,%ecx
  800bf7:	72 17                	jb     800c10 <__udivdi3+0x10c>
  800bf9:	74 09                	je     800c04 <__udivdi3+0x100>
  800bfb:	89 fe                	mov    %edi,%esi
  800bfd:	31 ff                	xor    %edi,%edi
  800bff:	e9 41 ff ff ff       	jmp    800b45 <__udivdi3+0x41>
  800c04:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c08:	89 f1                	mov    %esi,%ecx
  800c0a:	d3 e2                	shl    %cl,%edx
  800c0c:	39 c2                	cmp    %eax,%edx
  800c0e:	73 eb                	jae    800bfb <__udivdi3+0xf7>
  800c10:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c13:	31 ff                	xor    %edi,%edi
  800c15:	e9 2b ff ff ff       	jmp    800b45 <__udivdi3+0x41>
  800c1a:	66 90                	xchg   %ax,%ax
  800c1c:	31 f6                	xor    %esi,%esi
  800c1e:	e9 22 ff ff ff       	jmp    800b45 <__udivdi3+0x41>
	...

00800c24 <__umoddi3>:
  800c24:	55                   	push   %ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	83 ec 20             	sub    $0x20,%esp
  800c2a:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c2e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c32:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c36:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c3a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c3e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c42:	89 c7                	mov    %eax,%edi
  800c44:	89 f2                	mov    %esi,%edx
  800c46:	85 ed                	test   %ebp,%ebp
  800c48:	75 16                	jne    800c60 <__umoddi3+0x3c>
  800c4a:	39 f1                	cmp    %esi,%ecx
  800c4c:	0f 86 a6 00 00 00    	jbe    800cf8 <__umoddi3+0xd4>
  800c52:	f7 f1                	div    %ecx
  800c54:	89 d0                	mov    %edx,%eax
  800c56:	31 d2                	xor    %edx,%edx
  800c58:	83 c4 20             	add    $0x20,%esp
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    
  800c5f:	90                   	nop
  800c60:	39 f5                	cmp    %esi,%ebp
  800c62:	0f 87 ac 00 00 00    	ja     800d14 <__umoddi3+0xf0>
  800c68:	0f bd c5             	bsr    %ebp,%eax
  800c6b:	83 f0 1f             	xor    $0x1f,%eax
  800c6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c72:	0f 84 a8 00 00 00    	je     800d20 <__umoddi3+0xfc>
  800c78:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c7c:	d3 e5                	shl    %cl,%ebp
  800c7e:	bf 20 00 00 00       	mov    $0x20,%edi
  800c83:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800c87:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c8b:	89 f9                	mov    %edi,%ecx
  800c8d:	d3 e8                	shr    %cl,%eax
  800c8f:	09 e8                	or     %ebp,%eax
  800c91:	89 44 24 18          	mov    %eax,0x18(%esp)
  800c95:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c99:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c9d:	d3 e0                	shl    %cl,%eax
  800c9f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ca3:	89 f2                	mov    %esi,%edx
  800ca5:	d3 e2                	shl    %cl,%edx
  800ca7:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cab:	d3 e0                	shl    %cl,%eax
  800cad:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cb1:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cb5:	89 f9                	mov    %edi,%ecx
  800cb7:	d3 e8                	shr    %cl,%eax
  800cb9:	09 d0                	or     %edx,%eax
  800cbb:	d3 ee                	shr    %cl,%esi
  800cbd:	89 f2                	mov    %esi,%edx
  800cbf:	f7 74 24 18          	divl   0x18(%esp)
  800cc3:	89 d6                	mov    %edx,%esi
  800cc5:	f7 64 24 0c          	mull   0xc(%esp)
  800cc9:	89 c5                	mov    %eax,%ebp
  800ccb:	89 d1                	mov    %edx,%ecx
  800ccd:	39 d6                	cmp    %edx,%esi
  800ccf:	72 67                	jb     800d38 <__umoddi3+0x114>
  800cd1:	74 75                	je     800d48 <__umoddi3+0x124>
  800cd3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cd7:	29 e8                	sub    %ebp,%eax
  800cd9:	19 ce                	sbb    %ecx,%esi
  800cdb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cdf:	d3 e8                	shr    %cl,%eax
  800ce1:	89 f2                	mov    %esi,%edx
  800ce3:	89 f9                	mov    %edi,%ecx
  800ce5:	d3 e2                	shl    %cl,%edx
  800ce7:	09 d0                	or     %edx,%eax
  800ce9:	89 f2                	mov    %esi,%edx
  800ceb:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cef:	d3 ea                	shr    %cl,%edx
  800cf1:	83 c4 20             	add    $0x20,%esp
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    
  800cf8:	85 c9                	test   %ecx,%ecx
  800cfa:	75 0b                	jne    800d07 <__umoddi3+0xe3>
  800cfc:	b8 01 00 00 00       	mov    $0x1,%eax
  800d01:	31 d2                	xor    %edx,%edx
  800d03:	f7 f1                	div    %ecx
  800d05:	89 c1                	mov    %eax,%ecx
  800d07:	89 f0                	mov    %esi,%eax
  800d09:	31 d2                	xor    %edx,%edx
  800d0b:	f7 f1                	div    %ecx
  800d0d:	89 f8                	mov    %edi,%eax
  800d0f:	e9 3e ff ff ff       	jmp    800c52 <__umoddi3+0x2e>
  800d14:	89 f2                	mov    %esi,%edx
  800d16:	83 c4 20             	add    $0x20,%esp
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
  800d1d:	8d 76 00             	lea    0x0(%esi),%esi
  800d20:	39 f5                	cmp    %esi,%ebp
  800d22:	72 04                	jb     800d28 <__umoddi3+0x104>
  800d24:	39 f9                	cmp    %edi,%ecx
  800d26:	77 06                	ja     800d2e <__umoddi3+0x10a>
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	29 cf                	sub    %ecx,%edi
  800d2c:	19 ea                	sbb    %ebp,%edx
  800d2e:	89 f8                	mov    %edi,%eax
  800d30:	83 c4 20             	add    $0x20,%esp
  800d33:	5e                   	pop    %esi
  800d34:	5f                   	pop    %edi
  800d35:	5d                   	pop    %ebp
  800d36:	c3                   	ret    
  800d37:	90                   	nop
  800d38:	89 d1                	mov    %edx,%ecx
  800d3a:	89 c5                	mov    %eax,%ebp
  800d3c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d40:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d44:	eb 8d                	jmp    800cd3 <__umoddi3+0xaf>
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d4c:	72 ea                	jb     800d38 <__umoddi3+0x114>
  800d4e:	89 f1                	mov    %esi,%ecx
  800d50:	eb 81                	jmp    800cd3 <__umoddi3+0xaf>
