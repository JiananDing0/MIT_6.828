
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
  800047:	56                   	push   %esi
  800048:	53                   	push   %ebx
  800049:	83 ec 10             	sub    $0x10,%esp
  80004c:	8b 75 08             	mov    0x8(%ebp),%esi
  80004f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800052:	e8 dc 00 00 00       	call   800133 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80005f:	c1 e0 05             	shl    $0x5,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 10 80 00       	mov    %eax,0x801004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 f6                	test   %esi,%esi
  80006e:	7e 07                	jle    800077 <libmain+0x33>
		binaryname = argv[0];
  800070:	8b 03                	mov    (%ebx),%eax
  800072:	a3 00 10 80 00       	mov    %eax,0x801000

	// call user main routine
	umain(argc, argv);
  800077:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007b:	89 34 24             	mov    %esi,(%esp)
  80007e:	e8 b1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800083:	e8 08 00 00 00       	call   800090 <exit>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	5b                   	pop    %ebx
  80008c:	5e                   	pop    %esi
  80008d:	5d                   	pop    %ebp
  80008e:	c3                   	ret    
	...

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800096:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009d:	e8 3f 00 00 00       	call   8000e1 <sys_env_destroy>
}
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 cb                	mov    %ecx,%ebx
  8000f9:	89 cf                	mov    %ecx,%edi
  8000fb:	89 ce                	mov    %ecx,%esi
  8000fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000ff:	85 c0                	test   %eax,%eax
  800101:	7e 28                	jle    80012b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800103:	89 44 24 10          	mov    %eax,0x10(%esp)
  800107:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80010e:	00 
  80010f:	c7 44 24 08 76 0d 80 	movl   $0x800d76,0x8(%esp)
  800116:	00 
  800117:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80011e:	00 
  80011f:	c7 04 24 93 0d 80 00 	movl   $0x800d93,(%esp)
  800126:	e8 29 00 00 00       	call   800154 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012b:	83 c4 2c             	add    $0x2c,%esp
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 02 00 00 00       	mov    $0x2,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    
	...

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	56                   	push   %esi
  800158:	53                   	push   %ebx
  800159:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800165:	e8 c9 ff ff ff       	call   800133 <sys_getenvid>
  80016a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80016d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800171:	8b 55 08             	mov    0x8(%ebp),%edx
  800174:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800178:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80017c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800180:	c7 04 24 a4 0d 80 00 	movl   $0x800da4,(%esp)
  800187:	e8 c0 00 00 00       	call   80024c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800190:	8b 45 10             	mov    0x10(%ebp),%eax
  800193:	89 04 24             	mov    %eax,(%esp)
  800196:	e8 50 00 00 00       	call   8001eb <vcprintf>
	cprintf("\n");
  80019b:	c7 04 24 c8 0d 80 00 	movl   $0x800dc8,(%esp)
  8001a2:	e8 a5 00 00 00       	call   80024c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a7:	cc                   	int3   
  8001a8:	eb fd                	jmp    8001a7 <_panic+0x53>
	...

008001ac <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ac:	55                   	push   %ebp
  8001ad:	89 e5                	mov    %esp,%ebp
  8001af:	53                   	push   %ebx
  8001b0:	83 ec 14             	sub    $0x14,%esp
  8001b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b6:	8b 03                	mov    (%ebx),%eax
  8001b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001bf:	40                   	inc    %eax
  8001c0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c7:	75 19                	jne    8001e2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001c9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d0:	00 
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	89 04 24             	mov    %eax,(%esp)
  8001d7:	e8 c8 fe ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8001dc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e2:	ff 43 04             	incl   0x4(%ebx)
}
  8001e5:	83 c4 14             	add    $0x14,%esp
  8001e8:	5b                   	pop    %ebx
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fb:	00 00 00 
	b.cnt = 0;
  8001fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800205:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800208:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020f:	8b 45 08             	mov    0x8(%ebp),%eax
  800212:	89 44 24 08          	mov    %eax,0x8(%esp)
  800216:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800220:	c7 04 24 ac 01 80 00 	movl   $0x8001ac,(%esp)
  800227:	e8 82 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800232:	89 44 24 04          	mov    %eax,0x4(%esp)
  800236:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023c:	89 04 24             	mov    %eax,(%esp)
  80023f:	e8 60 fe ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  800244:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    

0080024c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800252:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800255:	89 44 24 04          	mov    %eax,0x4(%esp)
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 87 ff ff ff       	call   8001eb <vcprintf>
	va_end(ap);

	return cnt;
}
  800264:	c9                   	leave  
  800265:	c3                   	ret    
	...

00800268 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 3c             	sub    $0x3c,%esp
  800271:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800274:	89 d7                	mov    %edx,%edi
  800276:	8b 45 08             	mov    0x8(%ebp),%eax
  800279:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80027c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80027f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800282:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800285:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800288:	85 c0                	test   %eax,%eax
  80028a:	75 08                	jne    800294 <printnum+0x2c>
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800292:	77 57                	ja     8002eb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800294:	89 74 24 10          	mov    %esi,0x10(%esp)
  800298:	4b                   	dec    %ebx
  800299:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80029d:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002a4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002a8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002ac:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002b3:	00 
  8002b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002b7:	89 04 24             	mov    %eax,(%esp)
  8002ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002c1:	e8 56 08 00 00       	call   800b1c <__udivdi3>
  8002c6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ca:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002ce:	89 04 24             	mov    %eax,(%esp)
  8002d1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002d5:	89 fa                	mov    %edi,%edx
  8002d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002da:	e8 89 ff ff ff       	call   800268 <printnum>
  8002df:	eb 0f                	jmp    8002f0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002e5:	89 34 24             	mov    %esi,(%esp)
  8002e8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002eb:	4b                   	dec    %ebx
  8002ec:	85 db                	test   %ebx,%ebx
  8002ee:	7f f1                	jg     8002e1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f4:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800306:	00 
  800307:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80030a:	89 04 24             	mov    %eax,(%esp)
  80030d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800310:	89 44 24 04          	mov    %eax,0x4(%esp)
  800314:	e8 23 09 00 00       	call   800c3c <__umoddi3>
  800319:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80031d:	0f be 80 ca 0d 80 00 	movsbl 0x800dca(%eax),%eax
  800324:	89 04 24             	mov    %eax,(%esp)
  800327:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80032a:	83 c4 3c             	add    $0x3c,%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800335:	83 fa 01             	cmp    $0x1,%edx
  800338:	7e 0e                	jle    800348 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80033f:	89 08                	mov    %ecx,(%eax)
  800341:	8b 02                	mov    (%edx),%eax
  800343:	8b 52 04             	mov    0x4(%edx),%edx
  800346:	eb 22                	jmp    80036a <getuint+0x38>
	else if (lflag)
  800348:	85 d2                	test   %edx,%edx
  80034a:	74 10                	je     80035c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80034c:	8b 10                	mov    (%eax),%edx
  80034e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800351:	89 08                	mov    %ecx,(%eax)
  800353:	8b 02                	mov    (%edx),%eax
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	eb 0e                	jmp    80036a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80036a:	5d                   	pop    %ebp
  80036b:	c3                   	ret    

0080036c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800372:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800375:	8b 10                	mov    (%eax),%edx
  800377:	3b 50 04             	cmp    0x4(%eax),%edx
  80037a:	73 08                	jae    800384 <sprintputch+0x18>
		*b->buf++ = ch;
  80037c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037f:	88 0a                	mov    %cl,(%edx)
  800381:	42                   	inc    %edx
  800382:	89 10                	mov    %edx,(%eax)
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80038c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80038f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800393:	8b 45 10             	mov    0x10(%ebp),%eax
  800396:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80039d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	e8 02 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 4c             	sub    $0x4c,%esp
  8003b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ba:	8b 75 10             	mov    0x10(%ebp),%esi
  8003bd:	eb 12                	jmp    8003d1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003bf:	85 c0                	test   %eax,%eax
  8003c1:	0f 84 6b 03 00 00    	je     800732 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003cb:	89 04 24             	mov    %eax,(%esp)
  8003ce:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d1:	0f b6 06             	movzbl (%esi),%eax
  8003d4:	46                   	inc    %esi
  8003d5:	83 f8 25             	cmp    $0x25,%eax
  8003d8:	75 e5                	jne    8003bf <vprintfmt+0x11>
  8003da:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003de:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003e5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ea:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	eb 26                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003fb:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003ff:	eb 1d                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800404:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800408:	eb 14                	jmp    80041e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80040d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800414:	eb 08                	jmp    80041e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800416:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800419:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041e:	0f b6 06             	movzbl (%esi),%eax
  800421:	8d 56 01             	lea    0x1(%esi),%edx
  800424:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800427:	8a 16                	mov    (%esi),%dl
  800429:	83 ea 23             	sub    $0x23,%edx
  80042c:	80 fa 55             	cmp    $0x55,%dl
  80042f:	0f 87 e1 02 00 00    	ja     800716 <vprintfmt+0x368>
  800435:	0f b6 d2             	movzbl %dl,%edx
  800438:	ff 24 95 58 0e 80 00 	jmp    *0x800e58(,%edx,4)
  80043f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800442:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800447:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80044a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80044e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800451:	8d 50 d0             	lea    -0x30(%eax),%edx
  800454:	83 fa 09             	cmp    $0x9,%edx
  800457:	77 2a                	ja     800483 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800459:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80045a:	eb eb                	jmp    800447 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80045c:	8b 45 14             	mov    0x14(%ebp),%eax
  80045f:	8d 50 04             	lea    0x4(%eax),%edx
  800462:	89 55 14             	mov    %edx,0x14(%ebp)
  800465:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800467:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80046a:	eb 17                	jmp    800483 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80046c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800470:	78 98                	js     80040a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800472:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800475:	eb a7                	jmp    80041e <vprintfmt+0x70>
  800477:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80047a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800481:	eb 9b                	jmp    80041e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800483:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800487:	79 95                	jns    80041e <vprintfmt+0x70>
  800489:	eb 8b                	jmp    800416 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80048b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80048f:	eb 8d                	jmp    80041e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80049e:	8b 00                	mov    (%eax),%eax
  8004a0:	89 04 24             	mov    %eax,(%esp)
  8004a3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004a9:	e9 23 ff ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 50 04             	lea    0x4(%eax),%edx
  8004b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	79 02                	jns    8004bf <vprintfmt+0x111>
  8004bd:	f7 d8                	neg    %eax
  8004bf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c1:	83 f8 06             	cmp    $0x6,%eax
  8004c4:	7f 0b                	jg     8004d1 <vprintfmt+0x123>
  8004c6:	8b 04 85 b0 0f 80 00 	mov    0x800fb0(,%eax,4),%eax
  8004cd:	85 c0                	test   %eax,%eax
  8004cf:	75 23                	jne    8004f4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004d1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004d5:	c7 44 24 08 e2 0d 80 	movl   $0x800de2,0x8(%esp)
  8004dc:	00 
  8004dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e4:	89 04 24             	mov    %eax,(%esp)
  8004e7:	e8 9a fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ec:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ef:	e9 dd fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	c7 44 24 08 eb 0d 80 	movl   $0x800deb,0x8(%esp)
  8004ff:	00 
  800500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800504:	8b 55 08             	mov    0x8(%ebp),%edx
  800507:	89 14 24             	mov    %edx,(%esp)
  80050a:	e8 77 fe ff ff       	call   800386 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800512:	e9 ba fe ff ff       	jmp    8003d1 <vprintfmt+0x23>
  800517:	89 f9                	mov    %edi,%ecx
  800519:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 30                	mov    (%eax),%esi
  80052a:	85 f6                	test   %esi,%esi
  80052c:	75 05                	jne    800533 <vprintfmt+0x185>
				p = "(null)";
  80052e:	be db 0d 80 00       	mov    $0x800ddb,%esi
			if (width > 0 && padc != '-')
  800533:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800537:	0f 8e 84 00 00 00    	jle    8005c1 <vprintfmt+0x213>
  80053d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800541:	74 7e                	je     8005c1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800543:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800547:	89 34 24             	mov    %esi,(%esp)
  80054a:	e8 8b 02 00 00       	call   8007da <strnlen>
  80054f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800552:	29 c2                	sub    %eax,%edx
  800554:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800557:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80055b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80055e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800561:	89 de                	mov    %ebx,%esi
  800563:	89 d3                	mov    %edx,%ebx
  800565:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800567:	eb 0b                	jmp    800574 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800569:	89 74 24 04          	mov    %esi,0x4(%esp)
  80056d:	89 3c 24             	mov    %edi,(%esp)
  800570:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800573:	4b                   	dec    %ebx
  800574:	85 db                	test   %ebx,%ebx
  800576:	7f f1                	jg     800569 <vprintfmt+0x1bb>
  800578:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80057b:	89 f3                	mov    %esi,%ebx
  80057d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800580:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800583:	85 c0                	test   %eax,%eax
  800585:	79 05                	jns    80058c <vprintfmt+0x1de>
  800587:	b8 00 00 00 00       	mov    $0x0,%eax
  80058c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058f:	29 c2                	sub    %eax,%edx
  800591:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800594:	eb 2b                	jmp    8005c1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80059a:	74 18                	je     8005b4 <vprintfmt+0x206>
  80059c:	8d 50 e0             	lea    -0x20(%eax),%edx
  80059f:	83 fa 5e             	cmp    $0x5e,%edx
  8005a2:	76 10                	jbe    8005b4 <vprintfmt+0x206>
					putch('?', putdat);
  8005a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005a8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005af:	ff 55 08             	call   *0x8(%ebp)
  8005b2:	eb 0a                	jmp    8005be <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	89 04 24             	mov    %eax,(%esp)
  8005bb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005be:	ff 4d e4             	decl   -0x1c(%ebp)
  8005c1:	0f be 06             	movsbl (%esi),%eax
  8005c4:	46                   	inc    %esi
  8005c5:	85 c0                	test   %eax,%eax
  8005c7:	74 21                	je     8005ea <vprintfmt+0x23c>
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	78 c9                	js     800596 <vprintfmt+0x1e8>
  8005cd:	4f                   	dec    %edi
  8005ce:	79 c6                	jns    800596 <vprintfmt+0x1e8>
  8005d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d3:	89 de                	mov    %ebx,%esi
  8005d5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d8:	eb 18                	jmp    8005f2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005da:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005de:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e7:	4b                   	dec    %ebx
  8005e8:	eb 08                	jmp    8005f2 <vprintfmt+0x244>
  8005ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005ed:	89 de                	mov    %ebx,%esi
  8005ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005f2:	85 db                	test   %ebx,%ebx
  8005f4:	7f e4                	jg     8005da <vprintfmt+0x22c>
  8005f6:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005f9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005fe:	e9 ce fd ff ff       	jmp    8003d1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7e 10                	jle    800618 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8d 50 08             	lea    0x8(%eax),%edx
  80060e:	89 55 14             	mov    %edx,0x14(%ebp)
  800611:	8b 30                	mov    (%eax),%esi
  800613:	8b 78 04             	mov    0x4(%eax),%edi
  800616:	eb 26                	jmp    80063e <vprintfmt+0x290>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 12                	je     80062e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 30                	mov    (%eax),%esi
  800627:	89 f7                	mov    %esi,%edi
  800629:	c1 ff 1f             	sar    $0x1f,%edi
  80062c:	eb 10                	jmp    80063e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80062e:	8b 45 14             	mov    0x14(%ebp),%eax
  800631:	8d 50 04             	lea    0x4(%eax),%edx
  800634:	89 55 14             	mov    %edx,0x14(%ebp)
  800637:	8b 30                	mov    (%eax),%esi
  800639:	89 f7                	mov    %esi,%edi
  80063b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80063e:	85 ff                	test   %edi,%edi
  800640:	78 0a                	js     80064c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800642:	b8 0a 00 00 00       	mov    $0xa,%eax
  800647:	e9 8c 00 00 00       	jmp    8006d8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80064c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800650:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800657:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80065a:	f7 de                	neg    %esi
  80065c:	83 d7 00             	adc    $0x0,%edi
  80065f:	f7 df                	neg    %edi
			}
			base = 10;
  800661:	b8 0a 00 00 00       	mov    $0xa,%eax
  800666:	eb 70                	jmp    8006d8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800668:	89 ca                	mov    %ecx,%edx
  80066a:	8d 45 14             	lea    0x14(%ebp),%eax
  80066d:	e8 c0 fc ff ff       	call   800332 <getuint>
  800672:	89 c6                	mov    %eax,%esi
  800674:	89 d7                	mov    %edx,%edi
			base = 10;
  800676:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80067b:	eb 5b                	jmp    8006d8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80067d:	89 ca                	mov    %ecx,%edx
  80067f:	8d 45 14             	lea    0x14(%ebp),%eax
  800682:	e8 ab fc ff ff       	call   800332 <getuint>
  800687:	89 c6                	mov    %eax,%esi
  800689:	89 d7                	mov    %edx,%edi
			base = 8;
  80068b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800690:	eb 46                	jmp    8006d8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800696:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80069d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b1:	8d 50 04             	lea    0x4(%eax),%edx
  8006b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006b7:	8b 30                	mov    (%eax),%esi
  8006b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006c3:	eb 13                	jmp    8006d8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c5:	89 ca                	mov    %ecx,%edx
  8006c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ca:	e8 63 fc ff ff       	call   800332 <getuint>
  8006cf:	89 c6                	mov    %eax,%esi
  8006d1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006eb:	89 34 24             	mov    %esi,(%esp)
  8006ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006f2:	89 da                	mov    %ebx,%edx
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	e8 6c fb ff ff       	call   800268 <printnum>
			break;
  8006fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006ff:	e9 cd fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800704:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800708:	89 04 24             	mov    %eax,(%esp)
  80070b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800711:	e9 bb fc ff ff       	jmp    8003d1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800716:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800721:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800724:	eb 01                	jmp    800727 <vprintfmt+0x379>
  800726:	4e                   	dec    %esi
  800727:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80072b:	75 f9                	jne    800726 <vprintfmt+0x378>
  80072d:	e9 9f fc ff ff       	jmp    8003d1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800732:	83 c4 4c             	add    $0x4c,%esp
  800735:	5b                   	pop    %ebx
  800736:	5e                   	pop    %esi
  800737:	5f                   	pop    %edi
  800738:	5d                   	pop    %ebp
  800739:	c3                   	ret    

0080073a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	83 ec 28             	sub    $0x28,%esp
  800740:	8b 45 08             	mov    0x8(%ebp),%eax
  800743:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800746:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800749:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80074d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800750:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800757:	85 c0                	test   %eax,%eax
  800759:	74 30                	je     80078b <vsnprintf+0x51>
  80075b:	85 d2                	test   %edx,%edx
  80075d:	7e 33                	jle    800792 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800766:	8b 45 10             	mov    0x10(%ebp),%eax
  800769:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800770:	89 44 24 04          	mov    %eax,0x4(%esp)
  800774:	c7 04 24 6c 03 80 00 	movl   $0x80036c,(%esp)
  80077b:	e8 2e fc ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800780:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800783:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800786:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800789:	eb 0c                	jmp    800797 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80078b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800790:	eb 05                	jmp    800797 <vsnprintf+0x5d>
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b7:	89 04 24             	mov    %eax,(%esp)
  8007ba:	e8 7b ff ff ff       	call   80073a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007bf:	c9                   	leave  
  8007c0:	c3                   	ret    
  8007c1:	00 00                	add    %al,(%eax)
	...

008007c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cf:	eb 01                	jmp    8007d2 <strlen+0xe>
		n++;
  8007d1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d6:	75 f9                	jne    8007d1 <strlen+0xd>
		n++;
	return n;
}
  8007d8:	5d                   	pop    %ebp
  8007d9:	c3                   	ret    

008007da <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007da:	55                   	push   %ebp
  8007db:	89 e5                	mov    %esp,%ebp
  8007dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007e0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e8:	eb 01                	jmp    8007eb <strnlen+0x11>
		n++;
  8007ea:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007eb:	39 d0                	cmp    %edx,%eax
  8007ed:	74 06                	je     8007f5 <strnlen+0x1b>
  8007ef:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007f3:	75 f5                	jne    8007ea <strnlen+0x10>
		n++;
	return n;
}
  8007f5:	5d                   	pop    %ebp
  8007f6:	c3                   	ret    

008007f7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	53                   	push   %ebx
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800801:	ba 00 00 00 00       	mov    $0x0,%edx
  800806:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800809:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80080c:	42                   	inc    %edx
  80080d:	84 c9                	test   %cl,%cl
  80080f:	75 f5                	jne    800806 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800811:	5b                   	pop    %ebx
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	53                   	push   %ebx
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80081e:	89 1c 24             	mov    %ebx,(%esp)
  800821:	e8 9e ff ff ff       	call   8007c4 <strlen>
	strcpy(dst + len, src);
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	89 54 24 04          	mov    %edx,0x4(%esp)
  80082d:	01 d8                	add    %ebx,%eax
  80082f:	89 04 24             	mov    %eax,(%esp)
  800832:	e8 c0 ff ff ff       	call   8007f7 <strcpy>
	return dst;
}
  800837:	89 d8                	mov    %ebx,%eax
  800839:	83 c4 08             	add    $0x8,%esp
  80083c:	5b                   	pop    %ebx
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	56                   	push   %esi
  800843:	53                   	push   %ebx
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80084d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800852:	eb 0c                	jmp    800860 <strncpy+0x21>
		*dst++ = *src;
  800854:	8a 1a                	mov    (%edx),%bl
  800856:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800859:	80 3a 01             	cmpb   $0x1,(%edx)
  80085c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085f:	41                   	inc    %ecx
  800860:	39 f1                	cmp    %esi,%ecx
  800862:	75 f0                	jne    800854 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    

00800868 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800868:	55                   	push   %ebp
  800869:	89 e5                	mov    %esp,%ebp
  80086b:	56                   	push   %esi
  80086c:	53                   	push   %ebx
  80086d:	8b 75 08             	mov    0x8(%ebp),%esi
  800870:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800873:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800876:	85 d2                	test   %edx,%edx
  800878:	75 0a                	jne    800884 <strlcpy+0x1c>
  80087a:	89 f0                	mov    %esi,%eax
  80087c:	eb 1a                	jmp    800898 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80087e:	88 18                	mov    %bl,(%eax)
  800880:	40                   	inc    %eax
  800881:	41                   	inc    %ecx
  800882:	eb 02                	jmp    800886 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800884:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800886:	4a                   	dec    %edx
  800887:	74 0a                	je     800893 <strlcpy+0x2b>
  800889:	8a 19                	mov    (%ecx),%bl
  80088b:	84 db                	test   %bl,%bl
  80088d:	75 ef                	jne    80087e <strlcpy+0x16>
  80088f:	89 c2                	mov    %eax,%edx
  800891:	eb 02                	jmp    800895 <strlcpy+0x2d>
  800893:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800895:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800898:	29 f0                	sub    %esi,%eax
}
  80089a:	5b                   	pop    %ebx
  80089b:	5e                   	pop    %esi
  80089c:	5d                   	pop    %ebp
  80089d:	c3                   	ret    

0080089e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80089e:	55                   	push   %ebp
  80089f:	89 e5                	mov    %esp,%ebp
  8008a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008a4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008a7:	eb 02                	jmp    8008ab <strcmp+0xd>
		p++, q++;
  8008a9:	41                   	inc    %ecx
  8008aa:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ab:	8a 01                	mov    (%ecx),%al
  8008ad:	84 c0                	test   %al,%al
  8008af:	74 04                	je     8008b5 <strcmp+0x17>
  8008b1:	3a 02                	cmp    (%edx),%al
  8008b3:	74 f4                	je     8008a9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b5:	0f b6 c0             	movzbl %al,%eax
  8008b8:	0f b6 12             	movzbl (%edx),%edx
  8008bb:	29 d0                	sub    %edx,%eax
}
  8008bd:	5d                   	pop    %ebp
  8008be:	c3                   	ret    

008008bf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008bf:	55                   	push   %ebp
  8008c0:	89 e5                	mov    %esp,%ebp
  8008c2:	53                   	push   %ebx
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008c9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008cc:	eb 03                	jmp    8008d1 <strncmp+0x12>
		n--, p++, q++;
  8008ce:	4a                   	dec    %edx
  8008cf:	40                   	inc    %eax
  8008d0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008d1:	85 d2                	test   %edx,%edx
  8008d3:	74 14                	je     8008e9 <strncmp+0x2a>
  8008d5:	8a 18                	mov    (%eax),%bl
  8008d7:	84 db                	test   %bl,%bl
  8008d9:	74 04                	je     8008df <strncmp+0x20>
  8008db:	3a 19                	cmp    (%ecx),%bl
  8008dd:	74 ef                	je     8008ce <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008df:	0f b6 00             	movzbl (%eax),%eax
  8008e2:	0f b6 11             	movzbl (%ecx),%edx
  8008e5:	29 d0                	sub    %edx,%eax
  8008e7:	eb 05                	jmp    8008ee <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008e9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ee:	5b                   	pop    %ebx
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fa:	eb 05                	jmp    800901 <strchr+0x10>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	74 0c                	je     80090c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800900:	40                   	inc    %eax
  800901:	8a 10                	mov    (%eax),%dl
  800903:	84 d2                	test   %dl,%dl
  800905:	75 f5                	jne    8008fc <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800907:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 45 08             	mov    0x8(%ebp),%eax
  800914:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800917:	eb 05                	jmp    80091e <strfind+0x10>
		if (*s == c)
  800919:	38 ca                	cmp    %cl,%dl
  80091b:	74 07                	je     800924 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80091d:	40                   	inc    %eax
  80091e:	8a 10                	mov    (%eax),%dl
  800920:	84 d2                	test   %dl,%dl
  800922:	75 f5                	jne    800919 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	53                   	push   %ebx
  80092c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800932:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 30                	je     800969 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800939:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80093f:	75 25                	jne    800966 <memset+0x40>
  800941:	f6 c1 03             	test   $0x3,%cl
  800944:	75 20                	jne    800966 <memset+0x40>
		c &= 0xFF;
  800946:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800949:	89 d3                	mov    %edx,%ebx
  80094b:	c1 e3 08             	shl    $0x8,%ebx
  80094e:	89 d6                	mov    %edx,%esi
  800950:	c1 e6 18             	shl    $0x18,%esi
  800953:	89 d0                	mov    %edx,%eax
  800955:	c1 e0 10             	shl    $0x10,%eax
  800958:	09 f0                	or     %esi,%eax
  80095a:	09 d0                	or     %edx,%eax
  80095c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80095e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800961:	fc                   	cld    
  800962:	f3 ab                	rep stos %eax,%es:(%edi)
  800964:	eb 03                	jmp    800969 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800966:	fc                   	cld    
  800967:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800969:	89 f8                	mov    %edi,%eax
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5f                   	pop    %edi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    

00800970 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	57                   	push   %edi
  800974:	56                   	push   %esi
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 75 0c             	mov    0xc(%ebp),%esi
  80097b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80097e:	39 c6                	cmp    %eax,%esi
  800980:	73 34                	jae    8009b6 <memmove+0x46>
  800982:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800985:	39 d0                	cmp    %edx,%eax
  800987:	73 2d                	jae    8009b6 <memmove+0x46>
		s += n;
		d += n;
  800989:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	f6 c2 03             	test   $0x3,%dl
  80098f:	75 1b                	jne    8009ac <memmove+0x3c>
  800991:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800997:	75 13                	jne    8009ac <memmove+0x3c>
  800999:	f6 c1 03             	test   $0x3,%cl
  80099c:	75 0e                	jne    8009ac <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80099e:	83 ef 04             	sub    $0x4,%edi
  8009a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009a7:	fd                   	std    
  8009a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009aa:	eb 07                	jmp    8009b3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ac:	4f                   	dec    %edi
  8009ad:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009b0:	fd                   	std    
  8009b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b3:	fc                   	cld    
  8009b4:	eb 20                	jmp    8009d6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009bc:	75 13                	jne    8009d1 <memmove+0x61>
  8009be:	a8 03                	test   $0x3,%al
  8009c0:	75 0f                	jne    8009d1 <memmove+0x61>
  8009c2:	f6 c1 03             	test   $0x3,%cl
  8009c5:	75 0a                	jne    8009d1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ca:	89 c7                	mov    %eax,%edi
  8009cc:	fc                   	cld    
  8009cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cf:	eb 05                	jmp    8009d6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009d1:	89 c7                	mov    %eax,%edi
  8009d3:	fc                   	cld    
  8009d4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d6:	5e                   	pop    %esi
  8009d7:	5f                   	pop    %edi
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	89 04 24             	mov    %eax,(%esp)
  8009f4:	e8 77 ff ff ff       	call   800970 <memmove>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	57                   	push   %edi
  8009ff:	56                   	push   %esi
  800a00:	53                   	push   %ebx
  800a01:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a04:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0f:	eb 16                	jmp    800a27 <memcmp+0x2c>
		if (*s1 != *s2)
  800a11:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a14:	42                   	inc    %edx
  800a15:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a19:	38 c8                	cmp    %cl,%al
  800a1b:	74 0a                	je     800a27 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a1d:	0f b6 c0             	movzbl %al,%eax
  800a20:	0f b6 c9             	movzbl %cl,%ecx
  800a23:	29 c8                	sub    %ecx,%eax
  800a25:	eb 09                	jmp    800a30 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a27:	39 da                	cmp    %ebx,%edx
  800a29:	75 e6                	jne    800a11 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a30:	5b                   	pop    %ebx
  800a31:	5e                   	pop    %esi
  800a32:	5f                   	pop    %edi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a3e:	89 c2                	mov    %eax,%edx
  800a40:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a43:	eb 05                	jmp    800a4a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a45:	38 08                	cmp    %cl,(%eax)
  800a47:	74 05                	je     800a4e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a49:	40                   	inc    %eax
  800a4a:	39 d0                	cmp    %edx,%eax
  800a4c:	72 f7                	jb     800a45 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	57                   	push   %edi
  800a54:	56                   	push   %esi
  800a55:	53                   	push   %ebx
  800a56:	8b 55 08             	mov    0x8(%ebp),%edx
  800a59:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5c:	eb 01                	jmp    800a5f <strtol+0xf>
		s++;
  800a5e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a5f:	8a 02                	mov    (%edx),%al
  800a61:	3c 20                	cmp    $0x20,%al
  800a63:	74 f9                	je     800a5e <strtol+0xe>
  800a65:	3c 09                	cmp    $0x9,%al
  800a67:	74 f5                	je     800a5e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a69:	3c 2b                	cmp    $0x2b,%al
  800a6b:	75 08                	jne    800a75 <strtol+0x25>
		s++;
  800a6d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a6e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a73:	eb 13                	jmp    800a88 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a75:	3c 2d                	cmp    $0x2d,%al
  800a77:	75 0a                	jne    800a83 <strtol+0x33>
		s++, neg = 1;
  800a79:	8d 52 01             	lea    0x1(%edx),%edx
  800a7c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a81:	eb 05                	jmp    800a88 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	74 05                	je     800a91 <strtol+0x41>
  800a8c:	83 fb 10             	cmp    $0x10,%ebx
  800a8f:	75 28                	jne    800ab9 <strtol+0x69>
  800a91:	8a 02                	mov    (%edx),%al
  800a93:	3c 30                	cmp    $0x30,%al
  800a95:	75 10                	jne    800aa7 <strtol+0x57>
  800a97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9b:	75 0a                	jne    800aa7 <strtol+0x57>
		s += 2, base = 16;
  800a9d:	83 c2 02             	add    $0x2,%edx
  800aa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa5:	eb 12                	jmp    800ab9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800aa7:	85 db                	test   %ebx,%ebx
  800aa9:	75 0e                	jne    800ab9 <strtol+0x69>
  800aab:	3c 30                	cmp    $0x30,%al
  800aad:	75 05                	jne    800ab4 <strtol+0x64>
		s++, base = 8;
  800aaf:	42                   	inc    %edx
  800ab0:	b3 08                	mov    $0x8,%bl
  800ab2:	eb 05                	jmp    800ab9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ab4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  800abe:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ac0:	8a 0a                	mov    (%edx),%cl
  800ac2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ac5:	80 fb 09             	cmp    $0x9,%bl
  800ac8:	77 08                	ja     800ad2 <strtol+0x82>
			dig = *s - '0';
  800aca:	0f be c9             	movsbl %cl,%ecx
  800acd:	83 e9 30             	sub    $0x30,%ecx
  800ad0:	eb 1e                	jmp    800af0 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ad2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ad5:	80 fb 19             	cmp    $0x19,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800ada:	0f be c9             	movsbl %cl,%ecx
  800add:	83 e9 57             	sub    $0x57,%ecx
  800ae0:	eb 0e                	jmp    800af0 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ae2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 12                	ja     800afc <strtol+0xac>
			dig = *s - 'A' + 10;
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800af0:	39 f1                	cmp    %esi,%ecx
  800af2:	7d 0c                	jge    800b00 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800af4:	42                   	inc    %edx
  800af5:	0f af c6             	imul   %esi,%eax
  800af8:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800afa:	eb c4                	jmp    800ac0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800afc:	89 c1                	mov    %eax,%ecx
  800afe:	eb 02                	jmp    800b02 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b00:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b06:	74 05                	je     800b0d <strtol+0xbd>
		*endptr = (char *) s;
  800b08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b0d:	85 ff                	test   %edi,%edi
  800b0f:	74 04                	je     800b15 <strtol+0xc5>
  800b11:	89 c8                	mov    %ecx,%eax
  800b13:	f7 d8                	neg    %eax
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    
	...

00800b1c <__udivdi3>:
  800b1c:	55                   	push   %ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	83 ec 10             	sub    $0x10,%esp
  800b22:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b26:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b2a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b2e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b32:	89 cd                	mov    %ecx,%ebp
  800b34:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b38:	85 c0                	test   %eax,%eax
  800b3a:	75 2c                	jne    800b68 <__udivdi3+0x4c>
  800b3c:	39 f9                	cmp    %edi,%ecx
  800b3e:	77 68                	ja     800ba8 <__udivdi3+0x8c>
  800b40:	85 c9                	test   %ecx,%ecx
  800b42:	75 0b                	jne    800b4f <__udivdi3+0x33>
  800b44:	b8 01 00 00 00       	mov    $0x1,%eax
  800b49:	31 d2                	xor    %edx,%edx
  800b4b:	f7 f1                	div    %ecx
  800b4d:	89 c1                	mov    %eax,%ecx
  800b4f:	31 d2                	xor    %edx,%edx
  800b51:	89 f8                	mov    %edi,%eax
  800b53:	f7 f1                	div    %ecx
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	89 f0                	mov    %esi,%eax
  800b59:	f7 f1                	div    %ecx
  800b5b:	89 c6                	mov    %eax,%esi
  800b5d:	89 f0                	mov    %esi,%eax
  800b5f:	89 fa                	mov    %edi,%edx
  800b61:	83 c4 10             	add    $0x10,%esp
  800b64:	5e                   	pop    %esi
  800b65:	5f                   	pop    %edi
  800b66:	5d                   	pop    %ebp
  800b67:	c3                   	ret    
  800b68:	39 f8                	cmp    %edi,%eax
  800b6a:	77 2c                	ja     800b98 <__udivdi3+0x7c>
  800b6c:	0f bd f0             	bsr    %eax,%esi
  800b6f:	83 f6 1f             	xor    $0x1f,%esi
  800b72:	75 4c                	jne    800bc0 <__udivdi3+0xa4>
  800b74:	39 f8                	cmp    %edi,%eax
  800b76:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7b:	72 0a                	jb     800b87 <__udivdi3+0x6b>
  800b7d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b81:	0f 87 ad 00 00 00    	ja     800c34 <__udivdi3+0x118>
  800b87:	be 01 00 00 00       	mov    $0x1,%esi
  800b8c:	89 f0                	mov    %esi,%eax
  800b8e:	89 fa                	mov    %edi,%edx
  800b90:	83 c4 10             	add    $0x10,%esp
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    
  800b97:	90                   	nop
  800b98:	31 ff                	xor    %edi,%edi
  800b9a:	31 f6                	xor    %esi,%esi
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	89 fa                	mov    %edi,%edx
  800ba0:	83 c4 10             	add    $0x10,%esp
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    
  800ba7:	90                   	nop
  800ba8:	89 fa                	mov    %edi,%edx
  800baa:	89 f0                	mov    %esi,%eax
  800bac:	f7 f1                	div    %ecx
  800bae:	89 c6                	mov    %eax,%esi
  800bb0:	31 ff                	xor    %edi,%edi
  800bb2:	89 f0                	mov    %esi,%eax
  800bb4:	89 fa                	mov    %edi,%edx
  800bb6:	83 c4 10             	add    $0x10,%esp
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    
  800bbd:	8d 76 00             	lea    0x0(%esi),%esi
  800bc0:	89 f1                	mov    %esi,%ecx
  800bc2:	d3 e0                	shl    %cl,%eax
  800bc4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bc8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bcd:	29 f0                	sub    %esi,%eax
  800bcf:	89 ea                	mov    %ebp,%edx
  800bd1:	88 c1                	mov    %al,%cl
  800bd3:	d3 ea                	shr    %cl,%edx
  800bd5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bd9:	09 ca                	or     %ecx,%edx
  800bdb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bdf:	89 f1                	mov    %esi,%ecx
  800be1:	d3 e5                	shl    %cl,%ebp
  800be3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800be7:	89 fd                	mov    %edi,%ebp
  800be9:	88 c1                	mov    %al,%cl
  800beb:	d3 ed                	shr    %cl,%ebp
  800bed:	89 fa                	mov    %edi,%edx
  800bef:	89 f1                	mov    %esi,%ecx
  800bf1:	d3 e2                	shl    %cl,%edx
  800bf3:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bf7:	88 c1                	mov    %al,%cl
  800bf9:	d3 ef                	shr    %cl,%edi
  800bfb:	09 d7                	or     %edx,%edi
  800bfd:	89 f8                	mov    %edi,%eax
  800bff:	89 ea                	mov    %ebp,%edx
  800c01:	f7 74 24 08          	divl   0x8(%esp)
  800c05:	89 d1                	mov    %edx,%ecx
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	f7 64 24 0c          	mull   0xc(%esp)
  800c0d:	39 d1                	cmp    %edx,%ecx
  800c0f:	72 17                	jb     800c28 <__udivdi3+0x10c>
  800c11:	74 09                	je     800c1c <__udivdi3+0x100>
  800c13:	89 fe                	mov    %edi,%esi
  800c15:	31 ff                	xor    %edi,%edi
  800c17:	e9 41 ff ff ff       	jmp    800b5d <__udivdi3+0x41>
  800c1c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c20:	89 f1                	mov    %esi,%ecx
  800c22:	d3 e2                	shl    %cl,%edx
  800c24:	39 c2                	cmp    %eax,%edx
  800c26:	73 eb                	jae    800c13 <__udivdi3+0xf7>
  800c28:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c2b:	31 ff                	xor    %edi,%edi
  800c2d:	e9 2b ff ff ff       	jmp    800b5d <__udivdi3+0x41>
  800c32:	66 90                	xchg   %ax,%ax
  800c34:	31 f6                	xor    %esi,%esi
  800c36:	e9 22 ff ff ff       	jmp    800b5d <__udivdi3+0x41>
	...

00800c3c <__umoddi3>:
  800c3c:	55                   	push   %ebp
  800c3d:	57                   	push   %edi
  800c3e:	56                   	push   %esi
  800c3f:	83 ec 20             	sub    $0x20,%esp
  800c42:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c46:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c4a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c4e:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c52:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c56:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c5a:	89 c7                	mov    %eax,%edi
  800c5c:	89 f2                	mov    %esi,%edx
  800c5e:	85 ed                	test   %ebp,%ebp
  800c60:	75 16                	jne    800c78 <__umoddi3+0x3c>
  800c62:	39 f1                	cmp    %esi,%ecx
  800c64:	0f 86 a6 00 00 00    	jbe    800d10 <__umoddi3+0xd4>
  800c6a:	f7 f1                	div    %ecx
  800c6c:	89 d0                	mov    %edx,%eax
  800c6e:	31 d2                	xor    %edx,%edx
  800c70:	83 c4 20             	add    $0x20,%esp
  800c73:	5e                   	pop    %esi
  800c74:	5f                   	pop    %edi
  800c75:	5d                   	pop    %ebp
  800c76:	c3                   	ret    
  800c77:	90                   	nop
  800c78:	39 f5                	cmp    %esi,%ebp
  800c7a:	0f 87 ac 00 00 00    	ja     800d2c <__umoddi3+0xf0>
  800c80:	0f bd c5             	bsr    %ebp,%eax
  800c83:	83 f0 1f             	xor    $0x1f,%eax
  800c86:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8a:	0f 84 a8 00 00 00    	je     800d38 <__umoddi3+0xfc>
  800c90:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c94:	d3 e5                	shl    %cl,%ebp
  800c96:	bf 20 00 00 00       	mov    $0x20,%edi
  800c9b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800c9f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800ca3:	89 f9                	mov    %edi,%ecx
  800ca5:	d3 e8                	shr    %cl,%eax
  800ca7:	09 e8                	or     %ebp,%eax
  800ca9:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cad:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cb1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cb5:	d3 e0                	shl    %cl,%eax
  800cb7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cbb:	89 f2                	mov    %esi,%edx
  800cbd:	d3 e2                	shl    %cl,%edx
  800cbf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cc3:	d3 e0                	shl    %cl,%eax
  800cc5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cc9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ccd:	89 f9                	mov    %edi,%ecx
  800ccf:	d3 e8                	shr    %cl,%eax
  800cd1:	09 d0                	or     %edx,%eax
  800cd3:	d3 ee                	shr    %cl,%esi
  800cd5:	89 f2                	mov    %esi,%edx
  800cd7:	f7 74 24 18          	divl   0x18(%esp)
  800cdb:	89 d6                	mov    %edx,%esi
  800cdd:	f7 64 24 0c          	mull   0xc(%esp)
  800ce1:	89 c5                	mov    %eax,%ebp
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	39 d6                	cmp    %edx,%esi
  800ce7:	72 67                	jb     800d50 <__umoddi3+0x114>
  800ce9:	74 75                	je     800d60 <__umoddi3+0x124>
  800ceb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cef:	29 e8                	sub    %ebp,%eax
  800cf1:	19 ce                	sbb    %ecx,%esi
  800cf3:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cf7:	d3 e8                	shr    %cl,%eax
  800cf9:	89 f2                	mov    %esi,%edx
  800cfb:	89 f9                	mov    %edi,%ecx
  800cfd:	d3 e2                	shl    %cl,%edx
  800cff:	09 d0                	or     %edx,%eax
  800d01:	89 f2                	mov    %esi,%edx
  800d03:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d07:	d3 ea                	shr    %cl,%edx
  800d09:	83 c4 20             	add    $0x20,%esp
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
  800d10:	85 c9                	test   %ecx,%ecx
  800d12:	75 0b                	jne    800d1f <__umoddi3+0xe3>
  800d14:	b8 01 00 00 00       	mov    $0x1,%eax
  800d19:	31 d2                	xor    %edx,%edx
  800d1b:	f7 f1                	div    %ecx
  800d1d:	89 c1                	mov    %eax,%ecx
  800d1f:	89 f0                	mov    %esi,%eax
  800d21:	31 d2                	xor    %edx,%edx
  800d23:	f7 f1                	div    %ecx
  800d25:	89 f8                	mov    %edi,%eax
  800d27:	e9 3e ff ff ff       	jmp    800c6a <__umoddi3+0x2e>
  800d2c:	89 f2                	mov    %esi,%edx
  800d2e:	83 c4 20             	add    $0x20,%esp
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
  800d35:	8d 76 00             	lea    0x0(%esi),%esi
  800d38:	39 f5                	cmp    %esi,%ebp
  800d3a:	72 04                	jb     800d40 <__umoddi3+0x104>
  800d3c:	39 f9                	cmp    %edi,%ecx
  800d3e:	77 06                	ja     800d46 <__umoddi3+0x10a>
  800d40:	89 f2                	mov    %esi,%edx
  800d42:	29 cf                	sub    %ecx,%edi
  800d44:	19 ea                	sbb    %ebp,%edx
  800d46:	89 f8                	mov    %edi,%eax
  800d48:	83 c4 20             	add    $0x20,%esp
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    
  800d4f:	90                   	nop
  800d50:	89 d1                	mov    %edx,%ecx
  800d52:	89 c5                	mov    %eax,%ebp
  800d54:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d58:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d5c:	eb 8d                	jmp    800ceb <__umoddi3+0xaf>
  800d5e:	66 90                	xchg   %ax,%ax
  800d60:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d64:	72 ea                	jb     800d50 <__umoddi3+0x114>
  800d66:	89 f1                	mov    %esi,%ecx
  800d68:	eb 81                	jmp    800ceb <__umoddi3+0xaf>
