
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  80003a:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800041:	00 
  800042:	a1 00 10 80 00       	mov    0x801000,%eax
  800047:	89 04 24             	mov    %eax,(%esp)
  80004a:	e8 51 00 00 00       	call   8000a0 <sys_cputs>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	8b 45 08             	mov    0x8(%ebp),%eax
  80005d:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800060:	c7 05 08 10 80 00 00 	movl   $0x0,0x801008
  800067:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006a:	85 c0                	test   %eax,%eax
  80006c:	7e 08                	jle    800076 <libmain+0x22>
		binaryname = argv[0];
  80006e:	8b 0a                	mov    (%edx),%ecx
  800070:	89 0d 04 10 80 00    	mov    %ecx,0x801004

	// call user main routine
	umain(argc, argv);
  800076:	89 54 24 04          	mov    %edx,0x4(%esp)
  80007a:	89 04 24             	mov    %eax,(%esp)
  80007d:	e8 b2 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800082:	e8 05 00 00 00       	call   80008c <exit>
}
  800087:	c9                   	leave  
  800088:	c3                   	ret    
  800089:	00 00                	add    %al,(%eax)
	...

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 3f 00 00 00       	call   8000dd <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f3:	89 cb                	mov    %ecx,%ebx
  8000f5:	89 cf                	mov    %ecx,%edi
  8000f7:	89 ce                	mov    %ecx,%esi
  8000f9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	7e 28                	jle    800127 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800103:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010a:	00 
  80010b:	c7 44 24 08 80 0d 80 	movl   $0x800d80,0x8(%esp)
  800112:	00 
  800113:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011a:	00 
  80011b:	c7 04 24 9d 0d 80 00 	movl   $0x800d9d,(%esp)
  800122:	e8 29 00 00 00       	call   800150 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	83 c4 2c             	add    $0x2c,%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    
	...

00800150 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	56                   	push   %esi
  800154:	53                   	push   %ebx
  800155:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800158:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015b:	8b 1d 04 10 80 00    	mov    0x801004,%ebx
  800161:	e8 c9 ff ff ff       	call   80012f <sys_getenvid>
  800166:	8b 55 0c             	mov    0xc(%ebp),%edx
  800169:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016d:	8b 55 08             	mov    0x8(%ebp),%edx
  800170:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800174:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800178:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017c:	c7 04 24 ac 0d 80 00 	movl   $0x800dac,(%esp)
  800183:	e8 c0 00 00 00       	call   800248 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800188:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018c:	8b 45 10             	mov    0x10(%ebp),%eax
  80018f:	89 04 24             	mov    %eax,(%esp)
  800192:	e8 50 00 00 00       	call   8001e7 <vcprintf>
	cprintf("\n");
  800197:	c7 04 24 74 0d 80 00 	movl   $0x800d74,(%esp)
  80019e:	e8 a5 00 00 00       	call   800248 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a3:	cc                   	int3   
  8001a4:	eb fd                	jmp    8001a3 <_panic+0x53>
	...

008001a8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 14             	sub    $0x14,%esp
  8001af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b2:	8b 03                	mov    (%ebx),%eax
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bb:	40                   	inc    %eax
  8001bc:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c3:	75 19                	jne    8001de <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cc:	00 
  8001cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d0:	89 04 24             	mov    %eax,(%esp)
  8001d3:	e8 c8 fe ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8001d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001de:	ff 43 04             	incl   0x4(%ebx)
}
  8001e1:	83 c4 14             	add    $0x14,%esp
  8001e4:	5b                   	pop    %ebx
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f7:	00 00 00 
	b.cnt = 0;
  8001fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800201:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800204:	8b 45 0c             	mov    0xc(%ebp),%eax
  800207:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020b:	8b 45 08             	mov    0x8(%ebp),%eax
  80020e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800212:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800218:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021c:	c7 04 24 a8 01 80 00 	movl   $0x8001a8,(%esp)
  800223:	e8 82 01 00 00       	call   8003aa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800228:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80022e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800232:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800238:	89 04 24             	mov    %eax,(%esp)
  80023b:	e8 60 fe ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800240:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800246:	c9                   	leave  
  800247:	c3                   	ret    

00800248 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80024e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800251:	89 44 24 04          	mov    %eax,0x4(%esp)
  800255:	8b 45 08             	mov    0x8(%ebp),%eax
  800258:	89 04 24             	mov    %eax,(%esp)
  80025b:	e8 87 ff ff ff       	call   8001e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    
	...

00800264 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 3c             	sub    $0x3c,%esp
  80026d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800270:	89 d7                	mov    %edx,%edi
  800272:	8b 45 08             	mov    0x8(%ebp),%eax
  800275:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800278:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80027e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800281:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800284:	85 c0                	test   %eax,%eax
  800286:	75 08                	jne    800290 <printnum+0x2c>
  800288:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028b:	39 45 10             	cmp    %eax,0x10(%ebp)
  80028e:	77 57                	ja     8002e7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800290:	89 74 24 10          	mov    %esi,0x10(%esp)
  800294:	4b                   	dec    %ebx
  800295:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800299:	8b 45 10             	mov    0x10(%ebp),%eax
  80029c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002af:	00 
  8002b0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b3:	89 04 24             	mov    %eax,(%esp)
  8002b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002bd:	e8 56 08 00 00       	call   800b18 <__udivdi3>
  8002c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c6:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ca:	89 04 24             	mov    %eax,(%esp)
  8002cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d1:	89 fa                	mov    %edi,%edx
  8002d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002d6:	e8 89 ff ff ff       	call   800264 <printnum>
  8002db:	eb 0f                	jmp    8002ec <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002dd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e1:	89 34 24             	mov    %esi,(%esp)
  8002e4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e7:	4b                   	dec    %ebx
  8002e8:	85 db                	test   %ebx,%ebx
  8002ea:	7f f1                	jg     8002dd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ec:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f0:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800302:	00 
  800303:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800306:	89 04 24             	mov    %eax,(%esp)
  800309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800310:	e8 23 09 00 00       	call   800c38 <__umoddi3>
  800315:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800319:	0f be 80 d0 0d 80 00 	movsbl 0x800dd0(%eax),%eax
  800320:	89 04 24             	mov    %eax,(%esp)
  800323:	ff 55 e4             	call   *-0x1c(%ebp)
}
  800326:	83 c4 3c             	add    $0x3c,%esp
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    

0080032e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800331:	83 fa 01             	cmp    $0x1,%edx
  800334:	7e 0e                	jle    800344 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800336:	8b 10                	mov    (%eax),%edx
  800338:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033b:	89 08                	mov    %ecx,(%eax)
  80033d:	8b 02                	mov    (%edx),%eax
  80033f:	8b 52 04             	mov    0x4(%edx),%edx
  800342:	eb 22                	jmp    800366 <getuint+0x38>
	else if (lflag)
  800344:	85 d2                	test   %edx,%edx
  800346:	74 10                	je     800358 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800348:	8b 10                	mov    (%eax),%edx
  80034a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80034d:	89 08                	mov    %ecx,(%eax)
  80034f:	8b 02                	mov    (%edx),%eax
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	eb 0e                	jmp    800366 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800358:	8b 10                	mov    (%eax),%edx
  80035a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035d:	89 08                	mov    %ecx,(%eax)
  80035f:	8b 02                	mov    (%edx),%eax
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800366:	5d                   	pop    %ebp
  800367:	c3                   	ret    

00800368 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800368:	55                   	push   %ebp
  800369:	89 e5                	mov    %esp,%ebp
  80036b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80036e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800371:	8b 10                	mov    (%eax),%edx
  800373:	3b 50 04             	cmp    0x4(%eax),%edx
  800376:	73 08                	jae    800380 <sprintputch+0x18>
		*b->buf++ = ch;
  800378:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037b:	88 0a                	mov    %cl,(%edx)
  80037d:	42                   	inc    %edx
  80037e:	89 10                	mov    %edx,(%eax)
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800388:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80038f:	8b 45 10             	mov    0x10(%ebp),%eax
  800392:	89 44 24 08          	mov    %eax,0x8(%esp)
  800396:	8b 45 0c             	mov    0xc(%ebp),%eax
  800399:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 02 00 00 00       	call   8003aa <vprintfmt>
	va_end(ap);
}
  8003a8:	c9                   	leave  
  8003a9:	c3                   	ret    

008003aa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
  8003ad:	57                   	push   %edi
  8003ae:	56                   	push   %esi
  8003af:	53                   	push   %ebx
  8003b0:	83 ec 4c             	sub    $0x4c,%esp
  8003b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003b6:	8b 75 10             	mov    0x10(%ebp),%esi
  8003b9:	eb 12                	jmp    8003cd <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003bb:	85 c0                	test   %eax,%eax
  8003bd:	0f 84 6b 03 00 00    	je     80072e <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003c3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003c7:	89 04 24             	mov    %eax,(%esp)
  8003ca:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003cd:	0f b6 06             	movzbl (%esi),%eax
  8003d0:	46                   	inc    %esi
  8003d1:	83 f8 25             	cmp    $0x25,%eax
  8003d4:	75 e5                	jne    8003bb <vprintfmt+0x11>
  8003d6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003da:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003e6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f2:	eb 26                	jmp    80041a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003f7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003fb:	eb 1d                	jmp    80041a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800400:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800404:	eb 14                	jmp    80041a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800409:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800410:	eb 08                	jmp    80041a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800412:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800415:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	0f b6 06             	movzbl (%esi),%eax
  80041d:	8d 56 01             	lea    0x1(%esi),%edx
  800420:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800423:	8a 16                	mov    (%esi),%dl
  800425:	83 ea 23             	sub    $0x23,%edx
  800428:	80 fa 55             	cmp    $0x55,%dl
  80042b:	0f 87 e1 02 00 00    	ja     800712 <vprintfmt+0x368>
  800431:	0f b6 d2             	movzbl %dl,%edx
  800434:	ff 24 95 60 0e 80 00 	jmp    *0x800e60(,%edx,4)
  80043b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80043e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800443:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  800446:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80044a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  80044d:	8d 50 d0             	lea    -0x30(%eax),%edx
  800450:	83 fa 09             	cmp    $0x9,%edx
  800453:	77 2a                	ja     80047f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800455:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800456:	eb eb                	jmp    800443 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800458:	8b 45 14             	mov    0x14(%ebp),%eax
  80045b:	8d 50 04             	lea    0x4(%eax),%edx
  80045e:	89 55 14             	mov    %edx,0x14(%ebp)
  800461:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800466:	eb 17                	jmp    80047f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800468:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046c:	78 98                	js     800406 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046e:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800471:	eb a7                	jmp    80041a <vprintfmt+0x70>
  800473:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800476:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  80047d:	eb 9b                	jmp    80041a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  80047f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800483:	79 95                	jns    80041a <vprintfmt+0x70>
  800485:	eb 8b                	jmp    800412 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800487:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048b:	eb 8d                	jmp    80041a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80048d:	8b 45 14             	mov    0x14(%ebp),%eax
  800490:	8d 50 04             	lea    0x4(%eax),%edx
  800493:	89 55 14             	mov    %edx,0x14(%ebp)
  800496:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	89 04 24             	mov    %eax,(%esp)
  80049f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a5:	e9 23 ff ff ff       	jmp    8003cd <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ad:	8d 50 04             	lea    0x4(%eax),%edx
  8004b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b3:	8b 00                	mov    (%eax),%eax
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	79 02                	jns    8004bb <vprintfmt+0x111>
  8004b9:	f7 d8                	neg    %eax
  8004bb:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004bd:	83 f8 06             	cmp    $0x6,%eax
  8004c0:	7f 0b                	jg     8004cd <vprintfmt+0x123>
  8004c2:	8b 04 85 b8 0f 80 00 	mov    0x800fb8(,%eax,4),%eax
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	75 23                	jne    8004f0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d1:	c7 44 24 08 e8 0d 80 	movl   $0x800de8,0x8(%esp)
  8004d8:	00 
  8004d9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e0:	89 04 24             	mov    %eax,(%esp)
  8004e3:	e8 9a fe ff ff       	call   800382 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004e8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004eb:	e9 dd fe ff ff       	jmp    8003cd <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f4:	c7 44 24 08 f1 0d 80 	movl   $0x800df1,0x8(%esp)
  8004fb:	00 
  8004fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800500:	8b 55 08             	mov    0x8(%ebp),%edx
  800503:	89 14 24             	mov    %edx,(%esp)
  800506:	e8 77 fe ff ff       	call   800382 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80050e:	e9 ba fe ff ff       	jmp    8003cd <vprintfmt+0x23>
  800513:	89 f9                	mov    %edi,%ecx
  800515:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800518:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 45 14             	mov    0x14(%ebp),%eax
  80051e:	8d 50 04             	lea    0x4(%eax),%edx
  800521:	89 55 14             	mov    %edx,0x14(%ebp)
  800524:	8b 30                	mov    (%eax),%esi
  800526:	85 f6                	test   %esi,%esi
  800528:	75 05                	jne    80052f <vprintfmt+0x185>
				p = "(null)";
  80052a:	be e1 0d 80 00       	mov    $0x800de1,%esi
			if (width > 0 && padc != '-')
  80052f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800533:	0f 8e 84 00 00 00    	jle    8005bd <vprintfmt+0x213>
  800539:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80053d:	74 7e                	je     8005bd <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80053f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800543:	89 34 24             	mov    %esi,(%esp)
  800546:	e8 8b 02 00 00       	call   8007d6 <strnlen>
  80054b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80054e:	29 c2                	sub    %eax,%edx
  800550:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800553:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  800557:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80055a:	89 7d cc             	mov    %edi,-0x34(%ebp)
  80055d:	89 de                	mov    %ebx,%esi
  80055f:	89 d3                	mov    %edx,%ebx
  800561:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800563:	eb 0b                	jmp    800570 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800565:	89 74 24 04          	mov    %esi,0x4(%esp)
  800569:	89 3c 24             	mov    %edi,(%esp)
  80056c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80056f:	4b                   	dec    %ebx
  800570:	85 db                	test   %ebx,%ebx
  800572:	7f f1                	jg     800565 <vprintfmt+0x1bb>
  800574:	8b 7d cc             	mov    -0x34(%ebp),%edi
  800577:	89 f3                	mov    %esi,%ebx
  800579:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  80057c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80057f:	85 c0                	test   %eax,%eax
  800581:	79 05                	jns    800588 <vprintfmt+0x1de>
  800583:	b8 00 00 00 00       	mov    $0x0,%eax
  800588:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058b:	29 c2                	sub    %eax,%edx
  80058d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800590:	eb 2b                	jmp    8005bd <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800592:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800596:	74 18                	je     8005b0 <vprintfmt+0x206>
  800598:	8d 50 e0             	lea    -0x20(%eax),%edx
  80059b:	83 fa 5e             	cmp    $0x5e,%edx
  80059e:	76 10                	jbe    8005b0 <vprintfmt+0x206>
					putch('?', putdat);
  8005a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005ab:	ff 55 08             	call   *0x8(%ebp)
  8005ae:	eb 0a                	jmp    8005ba <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b4:	89 04 24             	mov    %eax,(%esp)
  8005b7:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ba:	ff 4d e4             	decl   -0x1c(%ebp)
  8005bd:	0f be 06             	movsbl (%esi),%eax
  8005c0:	46                   	inc    %esi
  8005c1:	85 c0                	test   %eax,%eax
  8005c3:	74 21                	je     8005e6 <vprintfmt+0x23c>
  8005c5:	85 ff                	test   %edi,%edi
  8005c7:	78 c9                	js     800592 <vprintfmt+0x1e8>
  8005c9:	4f                   	dec    %edi
  8005ca:	79 c6                	jns    800592 <vprintfmt+0x1e8>
  8005cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005cf:	89 de                	mov    %ebx,%esi
  8005d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d4:	eb 18                	jmp    8005ee <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005da:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e3:	4b                   	dec    %ebx
  8005e4:	eb 08                	jmp    8005ee <vprintfmt+0x244>
  8005e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e9:	89 de                	mov    %ebx,%esi
  8005eb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005ee:	85 db                	test   %ebx,%ebx
  8005f0:	7f e4                	jg     8005d6 <vprintfmt+0x22c>
  8005f2:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fa:	e9 ce fd ff ff       	jmp    8003cd <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ff:	83 f9 01             	cmp    $0x1,%ecx
  800602:	7e 10                	jle    800614 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 08             	lea    0x8(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 30                	mov    (%eax),%esi
  80060f:	8b 78 04             	mov    0x4(%eax),%edi
  800612:	eb 26                	jmp    80063a <vprintfmt+0x290>
	else if (lflag)
  800614:	85 c9                	test   %ecx,%ecx
  800616:	74 12                	je     80062a <vprintfmt+0x280>
		return va_arg(*ap, long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 04             	lea    0x4(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 30                	mov    (%eax),%esi
  800623:	89 f7                	mov    %esi,%edi
  800625:	c1 ff 1f             	sar    $0x1f,%edi
  800628:	eb 10                	jmp    80063a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80062a:	8b 45 14             	mov    0x14(%ebp),%eax
  80062d:	8d 50 04             	lea    0x4(%eax),%edx
  800630:	89 55 14             	mov    %edx,0x14(%ebp)
  800633:	8b 30                	mov    (%eax),%esi
  800635:	89 f7                	mov    %esi,%edi
  800637:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063a:	85 ff                	test   %edi,%edi
  80063c:	78 0a                	js     800648 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80063e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800643:	e9 8c 00 00 00       	jmp    8006d4 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800648:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80064c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800653:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  800656:	f7 de                	neg    %esi
  800658:	83 d7 00             	adc    $0x0,%edi
  80065b:	f7 df                	neg    %edi
			}
			base = 10;
  80065d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800662:	eb 70                	jmp    8006d4 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800664:	89 ca                	mov    %ecx,%edx
  800666:	8d 45 14             	lea    0x14(%ebp),%eax
  800669:	e8 c0 fc ff ff       	call   80032e <getuint>
  80066e:	89 c6                	mov    %eax,%esi
  800670:	89 d7                	mov    %edx,%edi
			base = 10;
  800672:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800677:	eb 5b                	jmp    8006d4 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 ab fc ff ff       	call   80032e <getuint>
  800683:	89 c6                	mov    %eax,%esi
  800685:	89 d7                	mov    %edx,%edi
			base = 8;
  800687:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80068c:	eb 46                	jmp    8006d4 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  80068e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800692:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800699:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80069c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006a7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 50 04             	lea    0x4(%eax),%edx
  8006b0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b3:	8b 30                	mov    (%eax),%esi
  8006b5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006bf:	eb 13                	jmp    8006d4 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c1:	89 ca                	mov    %ecx,%edx
  8006c3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006c6:	e8 63 fc ff ff       	call   80032e <getuint>
  8006cb:	89 c6                	mov    %eax,%esi
  8006cd:	89 d7                	mov    %edx,%edi
			base = 16;
  8006cf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006d8:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006dc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006df:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006e7:	89 34 24             	mov    %esi,(%esp)
  8006ea:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006ee:	89 da                	mov    %ebx,%edx
  8006f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f3:	e8 6c fb ff ff       	call   800264 <printnum>
			break;
  8006f8:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006fb:	e9 cd fc ff ff       	jmp    8003cd <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800700:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80070d:	e9 bb fc ff ff       	jmp    8003cd <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800712:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800716:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80071d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800720:	eb 01                	jmp    800723 <vprintfmt+0x379>
  800722:	4e                   	dec    %esi
  800723:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  800727:	75 f9                	jne    800722 <vprintfmt+0x378>
  800729:	e9 9f fc ff ff       	jmp    8003cd <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80072e:	83 c4 4c             	add    $0x4c,%esp
  800731:	5b                   	pop    %ebx
  800732:	5e                   	pop    %esi
  800733:	5f                   	pop    %edi
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	83 ec 28             	sub    $0x28,%esp
  80073c:	8b 45 08             	mov    0x8(%ebp),%eax
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800742:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800745:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800749:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80074c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800753:	85 c0                	test   %eax,%eax
  800755:	74 30                	je     800787 <vsnprintf+0x51>
  800757:	85 d2                	test   %edx,%edx
  800759:	7e 33                	jle    80078e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800762:	8b 45 10             	mov    0x10(%ebp),%eax
  800765:	89 44 24 08          	mov    %eax,0x8(%esp)
  800769:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800770:	c7 04 24 68 03 80 00 	movl   $0x800368,(%esp)
  800777:	e8 2e fc ff ff       	call   8003aa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800785:	eb 0c                	jmp    800793 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078c:	eb 05                	jmp    800793 <vsnprintf+0x5d>
  80078e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800793:	c9                   	leave  
  800794:	c3                   	ret    

00800795 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	89 04 24             	mov    %eax,(%esp)
  8007b6:	e8 7b ff ff ff       	call   800736 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bb:	c9                   	leave  
  8007bc:	c3                   	ret    
  8007bd:	00 00                	add    %al,(%eax)
	...

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 01                	jmp    8007ce <strlen+0xe>
		n++;
  8007cd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d2:	75 f9                	jne    8007cd <strlen+0xd>
		n++;
	return n;
}
  8007d4:	5d                   	pop    %ebp
  8007d5:	c3                   	ret    

008007d6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007dc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	eb 01                	jmp    8007e7 <strnlen+0x11>
		n++;
  8007e6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e7:	39 d0                	cmp    %edx,%eax
  8007e9:	74 06                	je     8007f1 <strnlen+0x1b>
  8007eb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ef:	75 f5                	jne    8007e6 <strnlen+0x10>
		n++;
	return n;
}
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    

008007f3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	53                   	push   %ebx
  8007f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007fd:	ba 00 00 00 00       	mov    $0x0,%edx
  800802:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800805:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800808:	42                   	inc    %edx
  800809:	84 c9                	test   %cl,%cl
  80080b:	75 f5                	jne    800802 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80080d:	5b                   	pop    %ebx
  80080e:	5d                   	pop    %ebp
  80080f:	c3                   	ret    

00800810 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081a:	89 1c 24             	mov    %ebx,(%esp)
  80081d:	e8 9e ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	89 54 24 04          	mov    %edx,0x4(%esp)
  800829:	01 d8                	add    %ebx,%eax
  80082b:	89 04 24             	mov    %eax,(%esp)
  80082e:	e8 c0 ff ff ff       	call   8007f3 <strcpy>
	return dst;
}
  800833:	89 d8                	mov    %ebx,%eax
  800835:	83 c4 08             	add    $0x8,%esp
  800838:	5b                   	pop    %ebx
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	56                   	push   %esi
  80083f:	53                   	push   %ebx
  800840:	8b 45 08             	mov    0x8(%ebp),%eax
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
  800846:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800849:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084e:	eb 0c                	jmp    80085c <strncpy+0x21>
		*dst++ = *src;
  800850:	8a 1a                	mov    (%edx),%bl
  800852:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800855:	80 3a 01             	cmpb   $0x1,(%edx)
  800858:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085b:	41                   	inc    %ecx
  80085c:	39 f1                	cmp    %esi,%ecx
  80085e:	75 f0                	jne    800850 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800860:	5b                   	pop    %ebx
  800861:	5e                   	pop    %esi
  800862:	5d                   	pop    %ebp
  800863:	c3                   	ret    

00800864 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800864:	55                   	push   %ebp
  800865:	89 e5                	mov    %esp,%ebp
  800867:	56                   	push   %esi
  800868:	53                   	push   %ebx
  800869:	8b 75 08             	mov    0x8(%ebp),%esi
  80086c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80086f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800872:	85 d2                	test   %edx,%edx
  800874:	75 0a                	jne    800880 <strlcpy+0x1c>
  800876:	89 f0                	mov    %esi,%eax
  800878:	eb 1a                	jmp    800894 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087a:	88 18                	mov    %bl,(%eax)
  80087c:	40                   	inc    %eax
  80087d:	41                   	inc    %ecx
  80087e:	eb 02                	jmp    800882 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800880:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800882:	4a                   	dec    %edx
  800883:	74 0a                	je     80088f <strlcpy+0x2b>
  800885:	8a 19                	mov    (%ecx),%bl
  800887:	84 db                	test   %bl,%bl
  800889:	75 ef                	jne    80087a <strlcpy+0x16>
  80088b:	89 c2                	mov    %eax,%edx
  80088d:	eb 02                	jmp    800891 <strlcpy+0x2d>
  80088f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800891:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800894:	29 f0                	sub    %esi,%eax
}
  800896:	5b                   	pop    %ebx
  800897:	5e                   	pop    %esi
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a3:	eb 02                	jmp    8008a7 <strcmp+0xd>
		p++, q++;
  8008a5:	41                   	inc    %ecx
  8008a6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008a7:	8a 01                	mov    (%ecx),%al
  8008a9:	84 c0                	test   %al,%al
  8008ab:	74 04                	je     8008b1 <strcmp+0x17>
  8008ad:	3a 02                	cmp    (%edx),%al
  8008af:	74 f4                	je     8008a5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b1:	0f b6 c0             	movzbl %al,%eax
  8008b4:	0f b6 12             	movzbl (%edx),%edx
  8008b7:	29 d0                	sub    %edx,%eax
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008c8:	eb 03                	jmp    8008cd <strncmp+0x12>
		n--, p++, q++;
  8008ca:	4a                   	dec    %edx
  8008cb:	40                   	inc    %eax
  8008cc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008cd:	85 d2                	test   %edx,%edx
  8008cf:	74 14                	je     8008e5 <strncmp+0x2a>
  8008d1:	8a 18                	mov    (%eax),%bl
  8008d3:	84 db                	test   %bl,%bl
  8008d5:	74 04                	je     8008db <strncmp+0x20>
  8008d7:	3a 19                	cmp    (%ecx),%bl
  8008d9:	74 ef                	je     8008ca <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008db:	0f b6 00             	movzbl (%eax),%eax
  8008de:	0f b6 11             	movzbl (%ecx),%edx
  8008e1:	29 d0                	sub    %edx,%eax
  8008e3:	eb 05                	jmp    8008ea <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ea:	5b                   	pop    %ebx
  8008eb:	5d                   	pop    %ebp
  8008ec:	c3                   	ret    

008008ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008f6:	eb 05                	jmp    8008fd <strchr+0x10>
		if (*s == c)
  8008f8:	38 ca                	cmp    %cl,%dl
  8008fa:	74 0c                	je     800908 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008fc:	40                   	inc    %eax
  8008fd:	8a 10                	mov    (%eax),%dl
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f5                	jne    8008f8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800903:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	8b 45 08             	mov    0x8(%ebp),%eax
  800910:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800913:	eb 05                	jmp    80091a <strfind+0x10>
		if (*s == c)
  800915:	38 ca                	cmp    %cl,%dl
  800917:	74 07                	je     800920 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800919:	40                   	inc    %eax
  80091a:	8a 10                	mov    (%eax),%dl
  80091c:	84 d2                	test   %dl,%dl
  80091e:	75 f5                	jne    800915 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 30                	je     800965 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800935:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093b:	75 25                	jne    800962 <memset+0x40>
  80093d:	f6 c1 03             	test   $0x3,%cl
  800940:	75 20                	jne    800962 <memset+0x40>
		c &= 0xFF;
  800942:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800945:	89 d3                	mov    %edx,%ebx
  800947:	c1 e3 08             	shl    $0x8,%ebx
  80094a:	89 d6                	mov    %edx,%esi
  80094c:	c1 e6 18             	shl    $0x18,%esi
  80094f:	89 d0                	mov    %edx,%eax
  800951:	c1 e0 10             	shl    $0x10,%eax
  800954:	09 f0                	or     %esi,%eax
  800956:	09 d0                	or     %edx,%eax
  800958:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80095d:	fc                   	cld    
  80095e:	f3 ab                	rep stos %eax,%es:(%edi)
  800960:	eb 03                	jmp    800965 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800962:	fc                   	cld    
  800963:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800965:	89 f8                	mov    %edi,%eax
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5f                   	pop    %edi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	57                   	push   %edi
  800970:	56                   	push   %esi
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 75 0c             	mov    0xc(%ebp),%esi
  800977:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097a:	39 c6                	cmp    %eax,%esi
  80097c:	73 34                	jae    8009b2 <memmove+0x46>
  80097e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800981:	39 d0                	cmp    %edx,%eax
  800983:	73 2d                	jae    8009b2 <memmove+0x46>
		s += n;
		d += n;
  800985:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800988:	f6 c2 03             	test   $0x3,%dl
  80098b:	75 1b                	jne    8009a8 <memmove+0x3c>
  80098d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800993:	75 13                	jne    8009a8 <memmove+0x3c>
  800995:	f6 c1 03             	test   $0x3,%cl
  800998:	75 0e                	jne    8009a8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099a:	83 ef 04             	sub    $0x4,%edi
  80099d:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a3:	fd                   	std    
  8009a4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a6:	eb 07                	jmp    8009af <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a8:	4f                   	dec    %edi
  8009a9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009ac:	fd                   	std    
  8009ad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009af:	fc                   	cld    
  8009b0:	eb 20                	jmp    8009d2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009b8:	75 13                	jne    8009cd <memmove+0x61>
  8009ba:	a8 03                	test   $0x3,%al
  8009bc:	75 0f                	jne    8009cd <memmove+0x61>
  8009be:	f6 c1 03             	test   $0x3,%cl
  8009c1:	75 0a                	jne    8009cd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009c6:	89 c7                	mov    %eax,%edi
  8009c8:	fc                   	cld    
  8009c9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cb:	eb 05                	jmp    8009d2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009cd:	89 c7                	mov    %eax,%edi
  8009cf:	fc                   	cld    
  8009d0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d2:	5e                   	pop    %esi
  8009d3:	5f                   	pop    %edi
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	89 04 24             	mov    %eax,(%esp)
  8009f0:	e8 77 ff ff ff       	call   80096c <memmove>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	57                   	push   %edi
  8009fb:	56                   	push   %esi
  8009fc:	53                   	push   %ebx
  8009fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a00:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a06:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0b:	eb 16                	jmp    800a23 <memcmp+0x2c>
		if (*s1 != *s2)
  800a0d:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a10:	42                   	inc    %edx
  800a11:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a15:	38 c8                	cmp    %cl,%al
  800a17:	74 0a                	je     800a23 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a19:	0f b6 c0             	movzbl %al,%eax
  800a1c:	0f b6 c9             	movzbl %cl,%ecx
  800a1f:	29 c8                	sub    %ecx,%eax
  800a21:	eb 09                	jmp    800a2c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a23:	39 da                	cmp    %ebx,%edx
  800a25:	75 e6                	jne    800a0d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	5b                   	pop    %ebx
  800a2d:	5e                   	pop    %esi
  800a2e:	5f                   	pop    %edi
  800a2f:	5d                   	pop    %ebp
  800a30:	c3                   	ret    

00800a31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3a:	89 c2                	mov    %eax,%edx
  800a3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a3f:	eb 05                	jmp    800a46 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a41:	38 08                	cmp    %cl,(%eax)
  800a43:	74 05                	je     800a4a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a45:	40                   	inc    %eax
  800a46:	39 d0                	cmp    %edx,%eax
  800a48:	72 f7                	jb     800a41 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4a:	5d                   	pop    %ebp
  800a4b:	c3                   	ret    

00800a4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a4c:	55                   	push   %ebp
  800a4d:	89 e5                	mov    %esp,%ebp
  800a4f:	57                   	push   %edi
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 55 08             	mov    0x8(%ebp),%edx
  800a55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a58:	eb 01                	jmp    800a5b <strtol+0xf>
		s++;
  800a5a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5b:	8a 02                	mov    (%edx),%al
  800a5d:	3c 20                	cmp    $0x20,%al
  800a5f:	74 f9                	je     800a5a <strtol+0xe>
  800a61:	3c 09                	cmp    $0x9,%al
  800a63:	74 f5                	je     800a5a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a65:	3c 2b                	cmp    $0x2b,%al
  800a67:	75 08                	jne    800a71 <strtol+0x25>
		s++;
  800a69:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6f:	eb 13                	jmp    800a84 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a71:	3c 2d                	cmp    $0x2d,%al
  800a73:	75 0a                	jne    800a7f <strtol+0x33>
		s++, neg = 1;
  800a75:	8d 52 01             	lea    0x1(%edx),%edx
  800a78:	bf 01 00 00 00       	mov    $0x1,%edi
  800a7d:	eb 05                	jmp    800a84 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a84:	85 db                	test   %ebx,%ebx
  800a86:	74 05                	je     800a8d <strtol+0x41>
  800a88:	83 fb 10             	cmp    $0x10,%ebx
  800a8b:	75 28                	jne    800ab5 <strtol+0x69>
  800a8d:	8a 02                	mov    (%edx),%al
  800a8f:	3c 30                	cmp    $0x30,%al
  800a91:	75 10                	jne    800aa3 <strtol+0x57>
  800a93:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a97:	75 0a                	jne    800aa3 <strtol+0x57>
		s += 2, base = 16;
  800a99:	83 c2 02             	add    $0x2,%edx
  800a9c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa1:	eb 12                	jmp    800ab5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa3:	85 db                	test   %ebx,%ebx
  800aa5:	75 0e                	jne    800ab5 <strtol+0x69>
  800aa7:	3c 30                	cmp    $0x30,%al
  800aa9:	75 05                	jne    800ab0 <strtol+0x64>
		s++, base = 8;
  800aab:	42                   	inc    %edx
  800aac:	b3 08                	mov    $0x8,%bl
  800aae:	eb 05                	jmp    800ab5 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab0:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab5:	b8 00 00 00 00       	mov    $0x0,%eax
  800aba:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800abc:	8a 0a                	mov    (%edx),%cl
  800abe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac1:	80 fb 09             	cmp    $0x9,%bl
  800ac4:	77 08                	ja     800ace <strtol+0x82>
			dig = *s - '0';
  800ac6:	0f be c9             	movsbl %cl,%ecx
  800ac9:	83 e9 30             	sub    $0x30,%ecx
  800acc:	eb 1e                	jmp    800aec <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ace:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad1:	80 fb 19             	cmp    $0x19,%bl
  800ad4:	77 08                	ja     800ade <strtol+0x92>
			dig = *s - 'a' + 10;
  800ad6:	0f be c9             	movsbl %cl,%ecx
  800ad9:	83 e9 57             	sub    $0x57,%ecx
  800adc:	eb 0e                	jmp    800aec <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ade:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae1:	80 fb 19             	cmp    $0x19,%bl
  800ae4:	77 12                	ja     800af8 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ae6:	0f be c9             	movsbl %cl,%ecx
  800ae9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800aec:	39 f1                	cmp    %esi,%ecx
  800aee:	7d 0c                	jge    800afc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af0:	42                   	inc    %edx
  800af1:	0f af c6             	imul   %esi,%eax
  800af4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800af6:	eb c4                	jmp    800abc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800af8:	89 c1                	mov    %eax,%ecx
  800afa:	eb 02                	jmp    800afe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800afc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800afe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b02:	74 05                	je     800b09 <strtol+0xbd>
		*endptr = (char *) s;
  800b04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b07:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b09:	85 ff                	test   %edi,%edi
  800b0b:	74 04                	je     800b11 <strtol+0xc5>
  800b0d:	89 c8                	mov    %ecx,%eax
  800b0f:	f7 d8                	neg    %eax
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5f                   	pop    %edi
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    
	...

00800b18 <__udivdi3>:
  800b18:	55                   	push   %ebp
  800b19:	57                   	push   %edi
  800b1a:	56                   	push   %esi
  800b1b:	83 ec 10             	sub    $0x10,%esp
  800b1e:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b22:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b2a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b2e:	89 cd                	mov    %ecx,%ebp
  800b30:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b34:	85 c0                	test   %eax,%eax
  800b36:	75 2c                	jne    800b64 <__udivdi3+0x4c>
  800b38:	39 f9                	cmp    %edi,%ecx
  800b3a:	77 68                	ja     800ba4 <__udivdi3+0x8c>
  800b3c:	85 c9                	test   %ecx,%ecx
  800b3e:	75 0b                	jne    800b4b <__udivdi3+0x33>
  800b40:	b8 01 00 00 00       	mov    $0x1,%eax
  800b45:	31 d2                	xor    %edx,%edx
  800b47:	f7 f1                	div    %ecx
  800b49:	89 c1                	mov    %eax,%ecx
  800b4b:	31 d2                	xor    %edx,%edx
  800b4d:	89 f8                	mov    %edi,%eax
  800b4f:	f7 f1                	div    %ecx
  800b51:	89 c7                	mov    %eax,%edi
  800b53:	89 f0                	mov    %esi,%eax
  800b55:	f7 f1                	div    %ecx
  800b57:	89 c6                	mov    %eax,%esi
  800b59:	89 f0                	mov    %esi,%eax
  800b5b:	89 fa                	mov    %edi,%edx
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	5e                   	pop    %esi
  800b61:	5f                   	pop    %edi
  800b62:	5d                   	pop    %ebp
  800b63:	c3                   	ret    
  800b64:	39 f8                	cmp    %edi,%eax
  800b66:	77 2c                	ja     800b94 <__udivdi3+0x7c>
  800b68:	0f bd f0             	bsr    %eax,%esi
  800b6b:	83 f6 1f             	xor    $0x1f,%esi
  800b6e:	75 4c                	jne    800bbc <__udivdi3+0xa4>
  800b70:	39 f8                	cmp    %edi,%eax
  800b72:	bf 00 00 00 00       	mov    $0x0,%edi
  800b77:	72 0a                	jb     800b83 <__udivdi3+0x6b>
  800b79:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b7d:	0f 87 ad 00 00 00    	ja     800c30 <__udivdi3+0x118>
  800b83:	be 01 00 00 00       	mov    $0x1,%esi
  800b88:	89 f0                	mov    %esi,%eax
  800b8a:	89 fa                	mov    %edi,%edx
  800b8c:	83 c4 10             	add    $0x10,%esp
  800b8f:	5e                   	pop    %esi
  800b90:	5f                   	pop    %edi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    
  800b93:	90                   	nop
  800b94:	31 ff                	xor    %edi,%edi
  800b96:	31 f6                	xor    %esi,%esi
  800b98:	89 f0                	mov    %esi,%eax
  800b9a:	89 fa                	mov    %edi,%edx
  800b9c:	83 c4 10             	add    $0x10,%esp
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    
  800ba3:	90                   	nop
  800ba4:	89 fa                	mov    %edi,%edx
  800ba6:	89 f0                	mov    %esi,%eax
  800ba8:	f7 f1                	div    %ecx
  800baa:	89 c6                	mov    %eax,%esi
  800bac:	31 ff                	xor    %edi,%edi
  800bae:	89 f0                	mov    %esi,%eax
  800bb0:	89 fa                	mov    %edi,%edx
  800bb2:	83 c4 10             	add    $0x10,%esp
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    
  800bb9:	8d 76 00             	lea    0x0(%esi),%esi
  800bbc:	89 f1                	mov    %esi,%ecx
  800bbe:	d3 e0                	shl    %cl,%eax
  800bc0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bc4:	b8 20 00 00 00       	mov    $0x20,%eax
  800bc9:	29 f0                	sub    %esi,%eax
  800bcb:	89 ea                	mov    %ebp,%edx
  800bcd:	88 c1                	mov    %al,%cl
  800bcf:	d3 ea                	shr    %cl,%edx
  800bd1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bd5:	09 ca                	or     %ecx,%edx
  800bd7:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bdb:	89 f1                	mov    %esi,%ecx
  800bdd:	d3 e5                	shl    %cl,%ebp
  800bdf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800be3:	89 fd                	mov    %edi,%ebp
  800be5:	88 c1                	mov    %al,%cl
  800be7:	d3 ed                	shr    %cl,%ebp
  800be9:	89 fa                	mov    %edi,%edx
  800beb:	89 f1                	mov    %esi,%ecx
  800bed:	d3 e2                	shl    %cl,%edx
  800bef:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bf3:	88 c1                	mov    %al,%cl
  800bf5:	d3 ef                	shr    %cl,%edi
  800bf7:	09 d7                	or     %edx,%edi
  800bf9:	89 f8                	mov    %edi,%eax
  800bfb:	89 ea                	mov    %ebp,%edx
  800bfd:	f7 74 24 08          	divl   0x8(%esp)
  800c01:	89 d1                	mov    %edx,%ecx
  800c03:	89 c7                	mov    %eax,%edi
  800c05:	f7 64 24 0c          	mull   0xc(%esp)
  800c09:	39 d1                	cmp    %edx,%ecx
  800c0b:	72 17                	jb     800c24 <__udivdi3+0x10c>
  800c0d:	74 09                	je     800c18 <__udivdi3+0x100>
  800c0f:	89 fe                	mov    %edi,%esi
  800c11:	31 ff                	xor    %edi,%edi
  800c13:	e9 41 ff ff ff       	jmp    800b59 <__udivdi3+0x41>
  800c18:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c1c:	89 f1                	mov    %esi,%ecx
  800c1e:	d3 e2                	shl    %cl,%edx
  800c20:	39 c2                	cmp    %eax,%edx
  800c22:	73 eb                	jae    800c0f <__udivdi3+0xf7>
  800c24:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c27:	31 ff                	xor    %edi,%edi
  800c29:	e9 2b ff ff ff       	jmp    800b59 <__udivdi3+0x41>
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	31 f6                	xor    %esi,%esi
  800c32:	e9 22 ff ff ff       	jmp    800b59 <__udivdi3+0x41>
	...

00800c38 <__umoddi3>:
  800c38:	55                   	push   %ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	83 ec 20             	sub    $0x20,%esp
  800c3e:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c42:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c46:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c4a:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c4e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c52:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c56:	89 c7                	mov    %eax,%edi
  800c58:	89 f2                	mov    %esi,%edx
  800c5a:	85 ed                	test   %ebp,%ebp
  800c5c:	75 16                	jne    800c74 <__umoddi3+0x3c>
  800c5e:	39 f1                	cmp    %esi,%ecx
  800c60:	0f 86 a6 00 00 00    	jbe    800d0c <__umoddi3+0xd4>
  800c66:	f7 f1                	div    %ecx
  800c68:	89 d0                	mov    %edx,%eax
  800c6a:	31 d2                	xor    %edx,%edx
  800c6c:	83 c4 20             	add    $0x20,%esp
  800c6f:	5e                   	pop    %esi
  800c70:	5f                   	pop    %edi
  800c71:	5d                   	pop    %ebp
  800c72:	c3                   	ret    
  800c73:	90                   	nop
  800c74:	39 f5                	cmp    %esi,%ebp
  800c76:	0f 87 ac 00 00 00    	ja     800d28 <__umoddi3+0xf0>
  800c7c:	0f bd c5             	bsr    %ebp,%eax
  800c7f:	83 f0 1f             	xor    $0x1f,%eax
  800c82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c86:	0f 84 a8 00 00 00    	je     800d34 <__umoddi3+0xfc>
  800c8c:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c90:	d3 e5                	shl    %cl,%ebp
  800c92:	bf 20 00 00 00       	mov    $0x20,%edi
  800c97:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800c9b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c9f:	89 f9                	mov    %edi,%ecx
  800ca1:	d3 e8                	shr    %cl,%eax
  800ca3:	09 e8                	or     %ebp,%eax
  800ca5:	89 44 24 18          	mov    %eax,0x18(%esp)
  800ca9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cad:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cb1:	d3 e0                	shl    %cl,%eax
  800cb3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cb7:	89 f2                	mov    %esi,%edx
  800cb9:	d3 e2                	shl    %cl,%edx
  800cbb:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cbf:	d3 e0                	shl    %cl,%eax
  800cc1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cc5:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cc9:	89 f9                	mov    %edi,%ecx
  800ccb:	d3 e8                	shr    %cl,%eax
  800ccd:	09 d0                	or     %edx,%eax
  800ccf:	d3 ee                	shr    %cl,%esi
  800cd1:	89 f2                	mov    %esi,%edx
  800cd3:	f7 74 24 18          	divl   0x18(%esp)
  800cd7:	89 d6                	mov    %edx,%esi
  800cd9:	f7 64 24 0c          	mull   0xc(%esp)
  800cdd:	89 c5                	mov    %eax,%ebp
  800cdf:	89 d1                	mov    %edx,%ecx
  800ce1:	39 d6                	cmp    %edx,%esi
  800ce3:	72 67                	jb     800d4c <__umoddi3+0x114>
  800ce5:	74 75                	je     800d5c <__umoddi3+0x124>
  800ce7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800ceb:	29 e8                	sub    %ebp,%eax
  800ced:	19 ce                	sbb    %ecx,%esi
  800cef:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cf3:	d3 e8                	shr    %cl,%eax
  800cf5:	89 f2                	mov    %esi,%edx
  800cf7:	89 f9                	mov    %edi,%ecx
  800cf9:	d3 e2                	shl    %cl,%edx
  800cfb:	09 d0                	or     %edx,%eax
  800cfd:	89 f2                	mov    %esi,%edx
  800cff:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d03:	d3 ea                	shr    %cl,%edx
  800d05:	83 c4 20             	add    $0x20,%esp
  800d08:	5e                   	pop    %esi
  800d09:	5f                   	pop    %edi
  800d0a:	5d                   	pop    %ebp
  800d0b:	c3                   	ret    
  800d0c:	85 c9                	test   %ecx,%ecx
  800d0e:	75 0b                	jne    800d1b <__umoddi3+0xe3>
  800d10:	b8 01 00 00 00       	mov    $0x1,%eax
  800d15:	31 d2                	xor    %edx,%edx
  800d17:	f7 f1                	div    %ecx
  800d19:	89 c1                	mov    %eax,%ecx
  800d1b:	89 f0                	mov    %esi,%eax
  800d1d:	31 d2                	xor    %edx,%edx
  800d1f:	f7 f1                	div    %ecx
  800d21:	89 f8                	mov    %edi,%eax
  800d23:	e9 3e ff ff ff       	jmp    800c66 <__umoddi3+0x2e>
  800d28:	89 f2                	mov    %esi,%edx
  800d2a:	83 c4 20             	add    $0x20,%esp
  800d2d:	5e                   	pop    %esi
  800d2e:	5f                   	pop    %edi
  800d2f:	5d                   	pop    %ebp
  800d30:	c3                   	ret    
  800d31:	8d 76 00             	lea    0x0(%esi),%esi
  800d34:	39 f5                	cmp    %esi,%ebp
  800d36:	72 04                	jb     800d3c <__umoddi3+0x104>
  800d38:	39 f9                	cmp    %edi,%ecx
  800d3a:	77 06                	ja     800d42 <__umoddi3+0x10a>
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	29 cf                	sub    %ecx,%edi
  800d40:	19 ea                	sbb    %ebp,%edx
  800d42:	89 f8                	mov    %edi,%eax
  800d44:	83 c4 20             	add    $0x20,%esp
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    
  800d4b:	90                   	nop
  800d4c:	89 d1                	mov    %edx,%ecx
  800d4e:	89 c5                	mov    %eax,%ebp
  800d50:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d54:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d58:	eb 8d                	jmp    800ce7 <__umoddi3+0xaf>
  800d5a:	66 90                	xchg   %ax,%ax
  800d5c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d60:	72 ea                	jb     800d4c <__umoddi3+0x114>
  800d62:	89 f1                	mov    %esi,%ecx
  800d64:	eb 81                	jmp    800ce7 <__umoddi3+0xaf>
