
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
  80004a:	e8 65 00 00 00       	call   8000b4 <sys_cputs>
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
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	83 ec 10             	sub    $0x10,%esp
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800062:	e8 dc 00 00 00       	call   800143 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  800067:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006c:	8d 04 40             	lea    (%eax,%eax,2),%eax
  80006f:	c1 e0 05             	shl    $0x5,%eax
  800072:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800077:	a3 08 10 80 00       	mov    %eax,0x801008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 f6                	test   %esi,%esi
  80007e:	7e 07                	jle    800087 <libmain+0x33>
		binaryname = argv[0];
  800080:	8b 03                	mov    (%ebx),%eax
  800082:	a3 04 10 80 00       	mov    %eax,0x801004

	// call user main routine
	umain(argc, argv);
  800087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008b:	89 34 24             	mov    %esi,(%esp)
  80008e:	e8 a1 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800093:	e8 08 00 00 00       	call   8000a0 <exit>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ad:	e8 3f 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 28                	jle    80013b <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	89 44 24 10          	mov    %eax,0x10(%esp)
  800117:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80011e:	00 
  80011f:	c7 44 24 08 94 0d 80 	movl   $0x800d94,0x8(%esp)
  800126:	00 
  800127:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80012e:	00 
  80012f:	c7 04 24 b1 0d 80 00 	movl   $0x800db1,(%esp)
  800136:	e8 29 00 00 00       	call   800164 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	83 c4 2c             	add    $0x2c,%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    
	...

00800164 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  80016c:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016f:	8b 1d 04 10 80 00    	mov    0x801004,%ebx
  800175:	e8 c9 ff ff ff       	call   800143 <sys_getenvid>
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800188:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80018c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800190:	c7 04 24 c0 0d 80 00 	movl   $0x800dc0,(%esp)
  800197:	e8 c0 00 00 00       	call   80025c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80019c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a3:	89 04 24             	mov    %eax,(%esp)
  8001a6:	e8 50 00 00 00       	call   8001fb <vcprintf>
	cprintf("\n");
  8001ab:	c7 04 24 88 0d 80 00 	movl   $0x800d88,(%esp)
  8001b2:	e8 a5 00 00 00       	call   80025c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b7:	cc                   	int3   
  8001b8:	eb fd                	jmp    8001b7 <_panic+0x53>
	...

008001bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	53                   	push   %ebx
  8001c0:	83 ec 14             	sub    $0x14,%esp
  8001c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001c6:	8b 03                	mov    (%ebx),%eax
  8001c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cb:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001cf:	40                   	inc    %eax
  8001d0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001d2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d7:	75 19                	jne    8001f2 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001d9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001e0:	00 
  8001e1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001e4:	89 04 24             	mov    %eax,(%esp)
  8001e7:	e8 c8 fe ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8001ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001f2:	ff 43 04             	incl   0x4(%ebx)
}
  8001f5:	83 c4 14             	add    $0x14,%esp
  8001f8:	5b                   	pop    %ebx
  8001f9:	5d                   	pop    %ebp
  8001fa:	c3                   	ret    

008001fb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800204:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80020b:	00 00 00 
	b.cnt = 0;
  80020e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800215:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800218:	8b 45 0c             	mov    0xc(%ebp),%eax
  80021b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80021f:	8b 45 08             	mov    0x8(%ebp),%eax
  800222:	89 44 24 08          	mov    %eax,0x8(%esp)
  800226:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80022c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800230:	c7 04 24 bc 01 80 00 	movl   $0x8001bc,(%esp)
  800237:	e8 82 01 00 00       	call   8003be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80023c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800242:	89 44 24 04          	mov    %eax,0x4(%esp)
  800246:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024c:	89 04 24             	mov    %eax,(%esp)
  80024f:	e8 60 fe ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  800254:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025a:	c9                   	leave  
  80025b:	c3                   	ret    

0080025c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80025c:	55                   	push   %ebp
  80025d:	89 e5                	mov    %esp,%ebp
  80025f:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800262:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800265:	89 44 24 04          	mov    %eax,0x4(%esp)
  800269:	8b 45 08             	mov    0x8(%ebp),%eax
  80026c:	89 04 24             	mov    %eax,(%esp)
  80026f:	e8 87 ff ff ff       	call   8001fb <vcprintf>
	va_end(ap);

	return cnt;
}
  800274:	c9                   	leave  
  800275:	c3                   	ret    
	...

00800278 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800278:	55                   	push   %ebp
  800279:	89 e5                	mov    %esp,%ebp
  80027b:	57                   	push   %edi
  80027c:	56                   	push   %esi
  80027d:	53                   	push   %ebx
  80027e:	83 ec 3c             	sub    $0x3c,%esp
  800281:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800284:	89 d7                	mov    %edx,%edi
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
  800289:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80028c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80028f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800292:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800295:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800298:	85 c0                	test   %eax,%eax
  80029a:	75 08                	jne    8002a4 <printnum+0x2c>
  80029c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002a2:	77 57                	ja     8002fb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a4:	89 74 24 10          	mov    %esi,0x10(%esp)
  8002a8:	4b                   	dec    %ebx
  8002a9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8002b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  8002b8:	8b 74 24 0c          	mov    0xc(%esp),%esi
  8002bc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002c3:	00 
  8002c4:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002c7:	89 04 24             	mov    %eax,(%esp)
  8002ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002d1:	e8 56 08 00 00       	call   800b2c <__udivdi3>
  8002d6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002da:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002de:	89 04 24             	mov    %eax,(%esp)
  8002e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002e5:	89 fa                	mov    %edi,%edx
  8002e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002ea:	e8 89 ff ff ff       	call   800278 <printnum>
  8002ef:	eb 0f                	jmp    800300 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f1:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002f5:	89 34 24             	mov    %esi,(%esp)
  8002f8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002fb:	4b                   	dec    %ebx
  8002fc:	85 db                	test   %ebx,%ebx
  8002fe:	7f f1                	jg     8002f1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800300:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800304:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800308:	8b 45 10             	mov    0x10(%ebp),%eax
  80030b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800316:	00 
  800317:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031a:	89 04 24             	mov    %eax,(%esp)
  80031d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800320:	89 44 24 04          	mov    %eax,0x4(%esp)
  800324:	e8 23 09 00 00       	call   800c4c <__umoddi3>
  800329:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80032d:	0f be 80 e4 0d 80 00 	movsbl 0x800de4(%eax),%eax
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80033a:	83 c4 3c             	add    $0x3c,%esp
  80033d:	5b                   	pop    %ebx
  80033e:	5e                   	pop    %esi
  80033f:	5f                   	pop    %edi
  800340:	5d                   	pop    %ebp
  800341:	c3                   	ret    

00800342 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800345:	83 fa 01             	cmp    $0x1,%edx
  800348:	7e 0e                	jle    800358 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80034a:	8b 10                	mov    (%eax),%edx
  80034c:	8d 4a 08             	lea    0x8(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 02                	mov    (%edx),%eax
  800353:	8b 52 04             	mov    0x4(%edx),%edx
  800356:	eb 22                	jmp    80037a <getuint+0x38>
	else if (lflag)
  800358:	85 d2                	test   %edx,%edx
  80035a:	74 10                	je     80036c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80035c:	8b 10                	mov    (%eax),%edx
  80035e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800361:	89 08                	mov    %ecx,(%eax)
  800363:	8b 02                	mov    (%edx),%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	eb 0e                	jmp    80037a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80036c:	8b 10                	mov    (%eax),%edx
  80036e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800371:	89 08                	mov    %ecx,(%eax)
  800373:	8b 02                	mov    (%edx),%eax
  800375:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80037c:	55                   	push   %ebp
  80037d:	89 e5                	mov    %esp,%ebp
  80037f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800382:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800385:	8b 10                	mov    (%eax),%edx
  800387:	3b 50 04             	cmp    0x4(%eax),%edx
  80038a:	73 08                	jae    800394 <sprintputch+0x18>
		*b->buf++ = ch;
  80038c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038f:	88 0a                	mov    %cl,(%edx)
  800391:	42                   	inc    %edx
  800392:	89 10                	mov    %edx,(%eax)
}
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
  800399:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  80039c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	89 04 24             	mov    %eax,(%esp)
  8003b7:	e8 02 00 00 00       	call   8003be <vprintfmt>
	va_end(ap);
}
  8003bc:	c9                   	leave  
  8003bd:	c3                   	ret    

008003be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003be:	55                   	push   %ebp
  8003bf:	89 e5                	mov    %esp,%ebp
  8003c1:	57                   	push   %edi
  8003c2:	56                   	push   %esi
  8003c3:	53                   	push   %ebx
  8003c4:	83 ec 4c             	sub    $0x4c,%esp
  8003c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003ca:	8b 75 10             	mov    0x10(%ebp),%esi
  8003cd:	eb 12                	jmp    8003e1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003cf:	85 c0                	test   %eax,%eax
  8003d1:	0f 84 6b 03 00 00    	je     800742 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003db:	89 04 24             	mov    %eax,(%esp)
  8003de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003e1:	0f b6 06             	movzbl (%esi),%eax
  8003e4:	46                   	inc    %esi
  8003e5:	83 f8 25             	cmp    $0x25,%eax
  8003e8:	75 e5                	jne    8003cf <vprintfmt+0x11>
  8003ea:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800401:	b9 00 00 00 00       	mov    $0x0,%ecx
  800406:	eb 26                	jmp    80042e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800408:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80040b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  80040f:	eb 1d                	jmp    80042e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800411:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800414:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  800418:	eb 14                	jmp    80042e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80041a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  80041d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800424:	eb 08                	jmp    80042e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  800426:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800429:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042e:	0f b6 06             	movzbl (%esi),%eax
  800431:	8d 56 01             	lea    0x1(%esi),%edx
  800434:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800437:	8a 16                	mov    (%esi),%dl
  800439:	83 ea 23             	sub    $0x23,%edx
  80043c:	80 fa 55             	cmp    $0x55,%dl
  80043f:	0f 87 e1 02 00 00    	ja     800726 <vprintfmt+0x368>
  800445:	0f b6 d2             	movzbl %dl,%edx
  800448:	ff 24 95 74 0e 80 00 	jmp    *0x800e74(,%edx,4)
  80044f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800452:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800457:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80045a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  80045e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800461:	8d 50 d0             	lea    -0x30(%eax),%edx
  800464:	83 fa 09             	cmp    $0x9,%edx
  800467:	77 2a                	ja     800493 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800469:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80046a:	eb eb                	jmp    800457 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8d 50 04             	lea    0x4(%eax),%edx
  800472:	89 55 14             	mov    %edx,0x14(%ebp)
  800475:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800477:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80047a:	eb 17                	jmp    800493 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  80047c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800480:	78 98                	js     80041a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800482:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800485:	eb a7                	jmp    80042e <vprintfmt+0x70>
  800487:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80048a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800491:	eb 9b                	jmp    80042e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800493:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800497:	79 95                	jns    80042e <vprintfmt+0x70>
  800499:	eb 8b                	jmp    800426 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80049b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80049f:	eb 8d                	jmp    80042e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8d 50 04             	lea    0x4(%eax),%edx
  8004a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	89 04 24             	mov    %eax,(%esp)
  8004b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004b9:	e9 23 ff ff ff       	jmp    8003e1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 50 04             	lea    0x4(%eax),%edx
  8004c4:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	79 02                	jns    8004cf <vprintfmt+0x111>
  8004cd:	f7 d8                	neg    %eax
  8004cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d1:	83 f8 06             	cmp    $0x6,%eax
  8004d4:	7f 0b                	jg     8004e1 <vprintfmt+0x123>
  8004d6:	8b 04 85 cc 0f 80 00 	mov    0x800fcc(,%eax,4),%eax
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	75 23                	jne    800504 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004e5:	c7 44 24 08 fc 0d 80 	movl   $0x800dfc,0x8(%esp)
  8004ec:	00 
  8004ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f4:	89 04 24             	mov    %eax,(%esp)
  8004f7:	e8 9a fe ff ff       	call   800396 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004ff:	e9 dd fe ff ff       	jmp    8003e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800504:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800508:	c7 44 24 08 05 0e 80 	movl   $0x800e05,0x8(%esp)
  80050f:	00 
  800510:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800514:	8b 55 08             	mov    0x8(%ebp),%edx
  800517:	89 14 24             	mov    %edx,(%esp)
  80051a:	e8 77 fe ff ff       	call   800396 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80051f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800522:	e9 ba fe ff ff       	jmp    8003e1 <vprintfmt+0x23>
  800527:	89 f9                	mov    %edi,%ecx
  800529:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80052c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 30                	mov    (%eax),%esi
  80053a:	85 f6                	test   %esi,%esi
  80053c:	75 05                	jne    800543 <vprintfmt+0x185>
				p = "(null)";
  80053e:	be f5 0d 80 00       	mov    $0x800df5,%esi
			if (width > 0 && padc != '-')
  800543:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800547:	0f 8e 84 00 00 00    	jle    8005d1 <vprintfmt+0x213>
  80054d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800551:	74 7e                	je     8005d1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800553:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800557:	89 34 24             	mov    %esi,(%esp)
  80055a:	e8 8b 02 00 00       	call   8007ea <strnlen>
  80055f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800562:	29 c2                	sub    %eax,%edx
  800564:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  800567:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80056b:	89 75 d0             	mov    %esi,-0x30(%ebp)
  80056e:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800571:	89 de                	mov    %ebx,%esi
  800573:	89 d3                	mov    %edx,%ebx
  800575:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	eb 0b                	jmp    800584 <vprintfmt+0x1c6>
					putch(padc, putdat);
  800579:	89 74 24 04          	mov    %esi,0x4(%esp)
  80057d:	89 3c 24             	mov    %edi,(%esp)
  800580:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	4b                   	dec    %ebx
  800584:	85 db                	test   %ebx,%ebx
  800586:	7f f1                	jg     800579 <vprintfmt+0x1bb>
  800588:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80058b:	89 f3                	mov    %esi,%ebx
  80058d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800590:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	79 05                	jns    80059c <vprintfmt+0x1de>
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059f:	29 c2                	sub    %eax,%edx
  8005a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a4:	eb 2b                	jmp    8005d1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005aa:	74 18                	je     8005c4 <vprintfmt+0x206>
  8005ac:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005af:	83 fa 5e             	cmp    $0x5e,%edx
  8005b2:	76 10                	jbe    8005c4 <vprintfmt+0x206>
					putch('?', putdat);
  8005b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005b8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bf:	ff 55 08             	call   *0x8(%ebp)
  8005c2:	eb 0a                	jmp    8005ce <vprintfmt+0x210>
				else
					putch(ch, putdat);
  8005c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005c8:	89 04 24             	mov    %eax,(%esp)
  8005cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ce:	ff 4d e4             	decl   -0x1c(%ebp)
  8005d1:	0f be 06             	movsbl (%esi),%eax
  8005d4:	46                   	inc    %esi
  8005d5:	85 c0                	test   %eax,%eax
  8005d7:	74 21                	je     8005fa <vprintfmt+0x23c>
  8005d9:	85 ff                	test   %edi,%edi
  8005db:	78 c9                	js     8005a6 <vprintfmt+0x1e8>
  8005dd:	4f                   	dec    %edi
  8005de:	79 c6                	jns    8005a6 <vprintfmt+0x1e8>
  8005e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005e3:	89 de                	mov    %ebx,%esi
  8005e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005e8:	eb 18                	jmp    800602 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ea:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005f7:	4b                   	dec    %ebx
  8005f8:	eb 08                	jmp    800602 <vprintfmt+0x244>
  8005fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005fd:	89 de                	mov    %ebx,%esi
  8005ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800602:	85 db                	test   %ebx,%ebx
  800604:	7f e4                	jg     8005ea <vprintfmt+0x22c>
  800606:	89 7d 08             	mov    %edi,0x8(%ebp)
  800609:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80060e:	e9 ce fd ff ff       	jmp    8003e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800613:	83 f9 01             	cmp    $0x1,%ecx
  800616:	7e 10                	jle    800628 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 50 08             	lea    0x8(%eax),%edx
  80061e:	89 55 14             	mov    %edx,0x14(%ebp)
  800621:	8b 30                	mov    (%eax),%esi
  800623:	8b 78 04             	mov    0x4(%eax),%edi
  800626:	eb 26                	jmp    80064e <vprintfmt+0x290>
	else if (lflag)
  800628:	85 c9                	test   %ecx,%ecx
  80062a:	74 12                	je     80063e <vprintfmt+0x280>
		return va_arg(*ap, long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 50 04             	lea    0x4(%eax),%edx
  800632:	89 55 14             	mov    %edx,0x14(%ebp)
  800635:	8b 30                	mov    (%eax),%esi
  800637:	89 f7                	mov    %esi,%edi
  800639:	c1 ff 1f             	sar    $0x1f,%edi
  80063c:	eb 10                	jmp    80064e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	8d 50 04             	lea    0x4(%eax),%edx
  800644:	89 55 14             	mov    %edx,0x14(%ebp)
  800647:	8b 30                	mov    (%eax),%esi
  800649:	89 f7                	mov    %esi,%edi
  80064b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80064e:	85 ff                	test   %edi,%edi
  800650:	78 0a                	js     80065c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800652:	b8 0a 00 00 00       	mov    $0xa,%eax
  800657:	e9 8c 00 00 00       	jmp    8006e8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  80065c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800660:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800667:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80066a:	f7 de                	neg    %esi
  80066c:	83 d7 00             	adc    $0x0,%edi
  80066f:	f7 df                	neg    %edi
			}
			base = 10;
  800671:	b8 0a 00 00 00       	mov    $0xa,%eax
  800676:	eb 70                	jmp    8006e8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800678:	89 ca                	mov    %ecx,%edx
  80067a:	8d 45 14             	lea    0x14(%ebp),%eax
  80067d:	e8 c0 fc ff ff       	call   800342 <getuint>
  800682:	89 c6                	mov    %eax,%esi
  800684:	89 d7                	mov    %edx,%edi
			base = 10;
  800686:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80068b:	eb 5b                	jmp    8006e8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80068d:	89 ca                	mov    %ecx,%edx
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 ab fc ff ff       	call   800342 <getuint>
  800697:	89 c6                	mov    %eax,%esi
  800699:	89 d7                	mov    %edx,%edi
			base = 8;
  80069b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006a0:	eb 46                	jmp    8006e8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  8006a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  8006b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8d 50 04             	lea    0x4(%eax),%edx
  8006c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8006c7:	8b 30                	mov    (%eax),%esi
  8006c9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006d3:	eb 13                	jmp    8006e8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d5:	89 ca                	mov    %ecx,%edx
  8006d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006da:	e8 63 fc ff ff       	call   800342 <getuint>
  8006df:	89 c6                	mov    %eax,%esi
  8006e1:	89 d7                	mov    %edx,%edi
			base = 16;
  8006e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fb:	89 34 24             	mov    %esi,(%esp)
  8006fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800702:	89 da                	mov    %ebx,%edx
  800704:	8b 45 08             	mov    0x8(%ebp),%eax
  800707:	e8 6c fb ff ff       	call   800278 <printnum>
			break;
  80070c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80070f:	e9 cd fc ff ff       	jmp    8003e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800714:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800718:	89 04 24             	mov    %eax,(%esp)
  80071b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800721:	e9 bb fc ff ff       	jmp    8003e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800726:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80072a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800731:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800734:	eb 01                	jmp    800737 <vprintfmt+0x379>
  800736:	4e                   	dec    %esi
  800737:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80073b:	75 f9                	jne    800736 <vprintfmt+0x378>
  80073d:	e9 9f fc ff ff       	jmp    8003e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800742:	83 c4 4c             	add    $0x4c,%esp
  800745:	5b                   	pop    %ebx
  800746:	5e                   	pop    %esi
  800747:	5f                   	pop    %edi
  800748:	5d                   	pop    %ebp
  800749:	c3                   	ret    

0080074a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074a:	55                   	push   %ebp
  80074b:	89 e5                	mov    %esp,%ebp
  80074d:	83 ec 28             	sub    $0x28,%esp
  800750:	8b 45 08             	mov    0x8(%ebp),%eax
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800756:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800759:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80075d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800760:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800767:	85 c0                	test   %eax,%eax
  800769:	74 30                	je     80079b <vsnprintf+0x51>
  80076b:	85 d2                	test   %edx,%edx
  80076d:	7e 33                	jle    8007a2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800776:	8b 45 10             	mov    0x10(%ebp),%eax
  800779:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800780:	89 44 24 04          	mov    %eax,0x4(%esp)
  800784:	c7 04 24 7c 03 80 00 	movl   $0x80037c,(%esp)
  80078b:	e8 2e fc ff ff       	call   8003be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800790:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800793:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800796:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800799:	eb 0c                	jmp    8007a7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80079b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a0:	eb 05                	jmp    8007a7 <vsnprintf+0x5d>
  8007a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007a7:	c9                   	leave  
  8007a8:	c3                   	ret    

008007a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a9:	55                   	push   %ebp
  8007aa:	89 e5                	mov    %esp,%ebp
  8007ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	89 04 24             	mov    %eax,(%esp)
  8007ca:	e8 7b ff ff ff       	call   80074a <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cf:	c9                   	leave  
  8007d0:	c3                   	ret    
  8007d1:	00 00                	add    %al,(%eax)
	...

008007d4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	eb 01                	jmp    8007e2 <strlen+0xe>
		n++;
  8007e1:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e6:	75 f9                	jne    8007e1 <strlen+0xd>
		n++;
	return n;
}
  8007e8:	5d                   	pop    %ebp
  8007e9:	c3                   	ret    

008007ea <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ea:	55                   	push   %ebp
  8007eb:	89 e5                	mov    %esp,%ebp
  8007ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007f0:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f8:	eb 01                	jmp    8007fb <strnlen+0x11>
		n++;
  8007fa:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007fb:	39 d0                	cmp    %edx,%eax
  8007fd:	74 06                	je     800805 <strnlen+0x1b>
  8007ff:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800803:	75 f5                	jne    8007fa <strnlen+0x10>
		n++;
	return n;
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800811:	ba 00 00 00 00       	mov    $0x0,%edx
  800816:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  800819:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  80081c:	42                   	inc    %edx
  80081d:	84 c9                	test   %cl,%cl
  80081f:	75 f5                	jne    800816 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800821:	5b                   	pop    %ebx
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80082e:	89 1c 24             	mov    %ebx,(%esp)
  800831:	e8 9e ff ff ff       	call   8007d4 <strlen>
	strcpy(dst + len, src);
  800836:	8b 55 0c             	mov    0xc(%ebp),%edx
  800839:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083d:	01 d8                	add    %ebx,%eax
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	e8 c0 ff ff ff       	call   800807 <strcpy>
	return dst;
}
  800847:	89 d8                	mov    %ebx,%eax
  800849:	83 c4 08             	add    $0x8,%esp
  80084c:	5b                   	pop    %ebx
  80084d:	5d                   	pop    %ebp
  80084e:	c3                   	ret    

0080084f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	56                   	push   %esi
  800853:	53                   	push   %ebx
  800854:	8b 45 08             	mov    0x8(%ebp),%eax
  800857:	8b 55 0c             	mov    0xc(%ebp),%edx
  80085a:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80085d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800862:	eb 0c                	jmp    800870 <strncpy+0x21>
		*dst++ = *src;
  800864:	8a 1a                	mov    (%edx),%bl
  800866:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800869:	80 3a 01             	cmpb   $0x1,(%edx)
  80086c:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80086f:	41                   	inc    %ecx
  800870:	39 f1                	cmp    %esi,%ecx
  800872:	75 f0                	jne    800864 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800874:	5b                   	pop    %ebx
  800875:	5e                   	pop    %esi
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	56                   	push   %esi
  80087c:	53                   	push   %ebx
  80087d:	8b 75 08             	mov    0x8(%ebp),%esi
  800880:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800883:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 d2                	test   %edx,%edx
  800888:	75 0a                	jne    800894 <strlcpy+0x1c>
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	eb 1a                	jmp    8008a8 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80088e:	88 18                	mov    %bl,(%eax)
  800890:	40                   	inc    %eax
  800891:	41                   	inc    %ecx
  800892:	eb 02                	jmp    800896 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800894:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800896:	4a                   	dec    %edx
  800897:	74 0a                	je     8008a3 <strlcpy+0x2b>
  800899:	8a 19                	mov    (%ecx),%bl
  80089b:	84 db                	test   %bl,%bl
  80089d:	75 ef                	jne    80088e <strlcpy+0x16>
  80089f:	89 c2                	mov    %eax,%edx
  8008a1:	eb 02                	jmp    8008a5 <strlcpy+0x2d>
  8008a3:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  8008a5:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  8008a8:	29 f0                	sub    %esi,%eax
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5e                   	pop    %esi
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008b7:	eb 02                	jmp    8008bb <strcmp+0xd>
		p++, q++;
  8008b9:	41                   	inc    %ecx
  8008ba:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008bb:	8a 01                	mov    (%ecx),%al
  8008bd:	84 c0                	test   %al,%al
  8008bf:	74 04                	je     8008c5 <strcmp+0x17>
  8008c1:	3a 02                	cmp    (%edx),%al
  8008c3:	74 f4                	je     8008b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c5:	0f b6 c0             	movzbl %al,%eax
  8008c8:	0f b6 12             	movzbl (%edx),%edx
  8008cb:	29 d0                	sub    %edx,%eax
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	53                   	push   %ebx
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d9:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008dc:	eb 03                	jmp    8008e1 <strncmp+0x12>
		n--, p++, q++;
  8008de:	4a                   	dec    %edx
  8008df:	40                   	inc    %eax
  8008e0:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008e1:	85 d2                	test   %edx,%edx
  8008e3:	74 14                	je     8008f9 <strncmp+0x2a>
  8008e5:	8a 18                	mov    (%eax),%bl
  8008e7:	84 db                	test   %bl,%bl
  8008e9:	74 04                	je     8008ef <strncmp+0x20>
  8008eb:	3a 19                	cmp    (%ecx),%bl
  8008ed:	74 ef                	je     8008de <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ef:	0f b6 00             	movzbl (%eax),%eax
  8008f2:	0f b6 11             	movzbl (%ecx),%edx
  8008f5:	29 d0                	sub    %edx,%eax
  8008f7:	eb 05                	jmp    8008fe <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008f9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008fe:	5b                   	pop    %ebx
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 08             	mov    0x8(%ebp),%eax
  800907:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  80090a:	eb 05                	jmp    800911 <strchr+0x10>
		if (*s == c)
  80090c:	38 ca                	cmp    %cl,%dl
  80090e:	74 0c                	je     80091c <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800910:	40                   	inc    %eax
  800911:	8a 10                	mov    (%eax),%dl
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f5                	jne    80090c <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800927:	eb 05                	jmp    80092e <strfind+0x10>
		if (*s == c)
  800929:	38 ca                	cmp    %cl,%dl
  80092b:	74 07                	je     800934 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80092d:	40                   	inc    %eax
  80092e:	8a 10                	mov    (%eax),%dl
  800930:	84 d2                	test   %dl,%dl
  800932:	75 f5                	jne    800929 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800942:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800945:	85 c9                	test   %ecx,%ecx
  800947:	74 30                	je     800979 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800949:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80094f:	75 25                	jne    800976 <memset+0x40>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 20                	jne    800976 <memset+0x40>
		c &= 0xFF;
  800956:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800959:	89 d3                	mov    %edx,%ebx
  80095b:	c1 e3 08             	shl    $0x8,%ebx
  80095e:	89 d6                	mov    %edx,%esi
  800960:	c1 e6 18             	shl    $0x18,%esi
  800963:	89 d0                	mov    %edx,%eax
  800965:	c1 e0 10             	shl    $0x10,%eax
  800968:	09 f0                	or     %esi,%eax
  80096a:	09 d0                	or     %edx,%eax
  80096c:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80096e:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800971:	fc                   	cld    
  800972:	f3 ab                	rep stos %eax,%es:(%edi)
  800974:	eb 03                	jmp    800979 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800976:	fc                   	cld    
  800977:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800979:	89 f8                	mov    %edi,%eax
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5f                   	pop    %edi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	57                   	push   %edi
  800984:	56                   	push   %esi
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 75 0c             	mov    0xc(%ebp),%esi
  80098b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80098e:	39 c6                	cmp    %eax,%esi
  800990:	73 34                	jae    8009c6 <memmove+0x46>
  800992:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800995:	39 d0                	cmp    %edx,%eax
  800997:	73 2d                	jae    8009c6 <memmove+0x46>
		s += n;
		d += n;
  800999:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099c:	f6 c2 03             	test   $0x3,%dl
  80099f:	75 1b                	jne    8009bc <memmove+0x3c>
  8009a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009a7:	75 13                	jne    8009bc <memmove+0x3c>
  8009a9:	f6 c1 03             	test   $0x3,%cl
  8009ac:	75 0e                	jne    8009bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009ae:	83 ef 04             	sub    $0x4,%edi
  8009b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009b4:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8009b7:	fd                   	std    
  8009b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ba:	eb 07                	jmp    8009c3 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009bc:	4f                   	dec    %edi
  8009bd:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8009c0:	fd                   	std    
  8009c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009c3:	fc                   	cld    
  8009c4:	eb 20                	jmp    8009e6 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009c6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009cc:	75 13                	jne    8009e1 <memmove+0x61>
  8009ce:	a8 03                	test   $0x3,%al
  8009d0:	75 0f                	jne    8009e1 <memmove+0x61>
  8009d2:	f6 c1 03             	test   $0x3,%cl
  8009d5:	75 0a                	jne    8009e1 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009d7:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009da:	89 c7                	mov    %eax,%edi
  8009dc:	fc                   	cld    
  8009dd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009df:	eb 05                	jmp    8009e6 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009e1:	89 c7                	mov    %eax,%edi
  8009e3:	fc                   	cld    
  8009e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009e6:	5e                   	pop    %esi
  8009e7:	5f                   	pop    %edi
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	89 04 24             	mov    %eax,(%esp)
  800a04:	e8 77 ff ff ff       	call   800980 <memmove>
}
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	57                   	push   %edi
  800a0f:	56                   	push   %esi
  800a10:	53                   	push   %ebx
  800a11:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a14:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a1a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1f:	eb 16                	jmp    800a37 <memcmp+0x2c>
		if (*s1 != *s2)
  800a21:	8a 04 17             	mov    (%edi,%edx,1),%al
  800a24:	42                   	inc    %edx
  800a25:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800a29:	38 c8                	cmp    %cl,%al
  800a2b:	74 0a                	je     800a37 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a2d:	0f b6 c0             	movzbl %al,%eax
  800a30:	0f b6 c9             	movzbl %cl,%ecx
  800a33:	29 c8                	sub    %ecx,%eax
  800a35:	eb 09                	jmp    800a40 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a37:	39 da                	cmp    %ebx,%edx
  800a39:	75 e6                	jne    800a21 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a40:	5b                   	pop    %ebx
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a4e:	89 c2                	mov    %eax,%edx
  800a50:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a53:	eb 05                	jmp    800a5a <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a55:	38 08                	cmp    %cl,(%eax)
  800a57:	74 05                	je     800a5e <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a59:	40                   	inc    %eax
  800a5a:	39 d0                	cmp    %edx,%eax
  800a5c:	72 f7                	jb     800a55 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	57                   	push   %edi
  800a64:	56                   	push   %esi
  800a65:	53                   	push   %ebx
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6c:	eb 01                	jmp    800a6f <strtol+0xf>
		s++;
  800a6e:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a6f:	8a 02                	mov    (%edx),%al
  800a71:	3c 20                	cmp    $0x20,%al
  800a73:	74 f9                	je     800a6e <strtol+0xe>
  800a75:	3c 09                	cmp    $0x9,%al
  800a77:	74 f5                	je     800a6e <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a79:	3c 2b                	cmp    $0x2b,%al
  800a7b:	75 08                	jne    800a85 <strtol+0x25>
		s++;
  800a7d:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a83:	eb 13                	jmp    800a98 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a85:	3c 2d                	cmp    $0x2d,%al
  800a87:	75 0a                	jne    800a93 <strtol+0x33>
		s++, neg = 1;
  800a89:	8d 52 01             	lea    0x1(%edx),%edx
  800a8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800a91:	eb 05                	jmp    800a98 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a98:	85 db                	test   %ebx,%ebx
  800a9a:	74 05                	je     800aa1 <strtol+0x41>
  800a9c:	83 fb 10             	cmp    $0x10,%ebx
  800a9f:	75 28                	jne    800ac9 <strtol+0x69>
  800aa1:	8a 02                	mov    (%edx),%al
  800aa3:	3c 30                	cmp    $0x30,%al
  800aa5:	75 10                	jne    800ab7 <strtol+0x57>
  800aa7:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aab:	75 0a                	jne    800ab7 <strtol+0x57>
		s += 2, base = 16;
  800aad:	83 c2 02             	add    $0x2,%edx
  800ab0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab5:	eb 12                	jmp    800ac9 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800ab7:	85 db                	test   %ebx,%ebx
  800ab9:	75 0e                	jne    800ac9 <strtol+0x69>
  800abb:	3c 30                	cmp    $0x30,%al
  800abd:	75 05                	jne    800ac4 <strtol+0x64>
		s++, base = 8;
  800abf:	42                   	inc    %edx
  800ac0:	b3 08                	mov    $0x8,%bl
  800ac2:	eb 05                	jmp    800ac9 <strtol+0x69>
	else if (base == 0)
		base = 10;
  800ac4:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ad0:	8a 0a                	mov    (%edx),%cl
  800ad2:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ad5:	80 fb 09             	cmp    $0x9,%bl
  800ad8:	77 08                	ja     800ae2 <strtol+0x82>
			dig = *s - '0';
  800ada:	0f be c9             	movsbl %cl,%ecx
  800add:	83 e9 30             	sub    $0x30,%ecx
  800ae0:	eb 1e                	jmp    800b00 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ae2:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ae5:	80 fb 19             	cmp    $0x19,%bl
  800ae8:	77 08                	ja     800af2 <strtol+0x92>
			dig = *s - 'a' + 10;
  800aea:	0f be c9             	movsbl %cl,%ecx
  800aed:	83 e9 57             	sub    $0x57,%ecx
  800af0:	eb 0e                	jmp    800b00 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800af2:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800af5:	80 fb 19             	cmp    $0x19,%bl
  800af8:	77 12                	ja     800b0c <strtol+0xac>
			dig = *s - 'A' + 10;
  800afa:	0f be c9             	movsbl %cl,%ecx
  800afd:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800b00:	39 f1                	cmp    %esi,%ecx
  800b02:	7d 0c                	jge    800b10 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800b04:	42                   	inc    %edx
  800b05:	0f af c6             	imul   %esi,%eax
  800b08:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800b0a:	eb c4                	jmp    800ad0 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800b0c:	89 c1                	mov    %eax,%ecx
  800b0e:	eb 02                	jmp    800b12 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b10:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800b12:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b16:	74 05                	je     800b1d <strtol+0xbd>
		*endptr = (char *) s;
  800b18:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1b:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800b1d:	85 ff                	test   %edi,%edi
  800b1f:	74 04                	je     800b25 <strtol+0xc5>
  800b21:	89 c8                	mov    %ecx,%eax
  800b23:	f7 d8                	neg    %eax
}
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5f                   	pop    %edi
  800b28:	5d                   	pop    %ebp
  800b29:	c3                   	ret    
	...

00800b2c <__udivdi3>:
  800b2c:	55                   	push   %ebp
  800b2d:	57                   	push   %edi
  800b2e:	56                   	push   %esi
  800b2f:	83 ec 10             	sub    $0x10,%esp
  800b32:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b36:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b3a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b3e:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b42:	89 cd                	mov    %ecx,%ebp
  800b44:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b48:	85 c0                	test   %eax,%eax
  800b4a:	75 2c                	jne    800b78 <__udivdi3+0x4c>
  800b4c:	39 f9                	cmp    %edi,%ecx
  800b4e:	77 68                	ja     800bb8 <__udivdi3+0x8c>
  800b50:	85 c9                	test   %ecx,%ecx
  800b52:	75 0b                	jne    800b5f <__udivdi3+0x33>
  800b54:	b8 01 00 00 00       	mov    $0x1,%eax
  800b59:	31 d2                	xor    %edx,%edx
  800b5b:	f7 f1                	div    %ecx
  800b5d:	89 c1                	mov    %eax,%ecx
  800b5f:	31 d2                	xor    %edx,%edx
  800b61:	89 f8                	mov    %edi,%eax
  800b63:	f7 f1                	div    %ecx
  800b65:	89 c7                	mov    %eax,%edi
  800b67:	89 f0                	mov    %esi,%eax
  800b69:	f7 f1                	div    %ecx
  800b6b:	89 c6                	mov    %eax,%esi
  800b6d:	89 f0                	mov    %esi,%eax
  800b6f:	89 fa                	mov    %edi,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	5e                   	pop    %esi
  800b75:	5f                   	pop    %edi
  800b76:	5d                   	pop    %ebp
  800b77:	c3                   	ret    
  800b78:	39 f8                	cmp    %edi,%eax
  800b7a:	77 2c                	ja     800ba8 <__udivdi3+0x7c>
  800b7c:	0f bd f0             	bsr    %eax,%esi
  800b7f:	83 f6 1f             	xor    $0x1f,%esi
  800b82:	75 4c                	jne    800bd0 <__udivdi3+0xa4>
  800b84:	39 f8                	cmp    %edi,%eax
  800b86:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8b:	72 0a                	jb     800b97 <__udivdi3+0x6b>
  800b8d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b91:	0f 87 ad 00 00 00    	ja     800c44 <__udivdi3+0x118>
  800b97:	be 01 00 00 00       	mov    $0x1,%esi
  800b9c:	89 f0                	mov    %esi,%eax
  800b9e:	89 fa                	mov    %edi,%edx
  800ba0:	83 c4 10             	add    $0x10,%esp
  800ba3:	5e                   	pop    %esi
  800ba4:	5f                   	pop    %edi
  800ba5:	5d                   	pop    %ebp
  800ba6:	c3                   	ret    
  800ba7:	90                   	nop
  800ba8:	31 ff                	xor    %edi,%edi
  800baa:	31 f6                	xor    %esi,%esi
  800bac:	89 f0                	mov    %esi,%eax
  800bae:	89 fa                	mov    %edi,%edx
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    
  800bb7:	90                   	nop
  800bb8:	89 fa                	mov    %edi,%edx
  800bba:	89 f0                	mov    %esi,%eax
  800bbc:	f7 f1                	div    %ecx
  800bbe:	89 c6                	mov    %eax,%esi
  800bc0:	31 ff                	xor    %edi,%edi
  800bc2:	89 f0                	mov    %esi,%eax
  800bc4:	89 fa                	mov    %edi,%edx
  800bc6:	83 c4 10             	add    $0x10,%esp
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	89 f1                	mov    %esi,%ecx
  800bd2:	d3 e0                	shl    %cl,%eax
  800bd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd8:	b8 20 00 00 00       	mov    $0x20,%eax
  800bdd:	29 f0                	sub    %esi,%eax
  800bdf:	89 ea                	mov    %ebp,%edx
  800be1:	88 c1                	mov    %al,%cl
  800be3:	d3 ea                	shr    %cl,%edx
  800be5:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800be9:	09 ca                	or     %ecx,%edx
  800beb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bef:	89 f1                	mov    %esi,%ecx
  800bf1:	d3 e5                	shl    %cl,%ebp
  800bf3:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800bf7:	89 fd                	mov    %edi,%ebp
  800bf9:	88 c1                	mov    %al,%cl
  800bfb:	d3 ed                	shr    %cl,%ebp
  800bfd:	89 fa                	mov    %edi,%edx
  800bff:	89 f1                	mov    %esi,%ecx
  800c01:	d3 e2                	shl    %cl,%edx
  800c03:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800c07:	88 c1                	mov    %al,%cl
  800c09:	d3 ef                	shr    %cl,%edi
  800c0b:	09 d7                	or     %edx,%edi
  800c0d:	89 f8                	mov    %edi,%eax
  800c0f:	89 ea                	mov    %ebp,%edx
  800c11:	f7 74 24 08          	divl   0x8(%esp)
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 c7                	mov    %eax,%edi
  800c19:	f7 64 24 0c          	mull   0xc(%esp)
  800c1d:	39 d1                	cmp    %edx,%ecx
  800c1f:	72 17                	jb     800c38 <__udivdi3+0x10c>
  800c21:	74 09                	je     800c2c <__udivdi3+0x100>
  800c23:	89 fe                	mov    %edi,%esi
  800c25:	31 ff                	xor    %edi,%edi
  800c27:	e9 41 ff ff ff       	jmp    800b6d <__udivdi3+0x41>
  800c2c:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c30:	89 f1                	mov    %esi,%ecx
  800c32:	d3 e2                	shl    %cl,%edx
  800c34:	39 c2                	cmp    %eax,%edx
  800c36:	73 eb                	jae    800c23 <__udivdi3+0xf7>
  800c38:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c3b:	31 ff                	xor    %edi,%edi
  800c3d:	e9 2b ff ff ff       	jmp    800b6d <__udivdi3+0x41>
  800c42:	66 90                	xchg   %ax,%ax
  800c44:	31 f6                	xor    %esi,%esi
  800c46:	e9 22 ff ff ff       	jmp    800b6d <__udivdi3+0x41>
	...

00800c4c <__umoddi3>:
  800c4c:	55                   	push   %ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	83 ec 20             	sub    $0x20,%esp
  800c52:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c56:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c5a:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c5e:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c66:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c6a:	89 c7                	mov    %eax,%edi
  800c6c:	89 f2                	mov    %esi,%edx
  800c6e:	85 ed                	test   %ebp,%ebp
  800c70:	75 16                	jne    800c88 <__umoddi3+0x3c>
  800c72:	39 f1                	cmp    %esi,%ecx
  800c74:	0f 86 a6 00 00 00    	jbe    800d20 <__umoddi3+0xd4>
  800c7a:	f7 f1                	div    %ecx
  800c7c:	89 d0                	mov    %edx,%eax
  800c7e:	31 d2                	xor    %edx,%edx
  800c80:	83 c4 20             	add    $0x20,%esp
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    
  800c87:	90                   	nop
  800c88:	39 f5                	cmp    %esi,%ebp
  800c8a:	0f 87 ac 00 00 00    	ja     800d3c <__umoddi3+0xf0>
  800c90:	0f bd c5             	bsr    %ebp,%eax
  800c93:	83 f0 1f             	xor    $0x1f,%eax
  800c96:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9a:	0f 84 a8 00 00 00    	je     800d48 <__umoddi3+0xfc>
  800ca0:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ca4:	d3 e5                	shl    %cl,%ebp
  800ca6:	bf 20 00 00 00       	mov    $0x20,%edi
  800cab:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800caf:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cb3:	89 f9                	mov    %edi,%ecx
  800cb5:	d3 e8                	shr    %cl,%eax
  800cb7:	09 e8                	or     %ebp,%eax
  800cb9:	89 44 24 18          	mov    %eax,0x18(%esp)
  800cbd:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800cc1:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cc5:	d3 e0                	shl    %cl,%eax
  800cc7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ccb:	89 f2                	mov    %esi,%edx
  800ccd:	d3 e2                	shl    %cl,%edx
  800ccf:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cd3:	d3 e0                	shl    %cl,%eax
  800cd5:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cd9:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cdd:	89 f9                	mov    %edi,%ecx
  800cdf:	d3 e8                	shr    %cl,%eax
  800ce1:	09 d0                	or     %edx,%eax
  800ce3:	d3 ee                	shr    %cl,%esi
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	f7 74 24 18          	divl   0x18(%esp)
  800ceb:	89 d6                	mov    %edx,%esi
  800ced:	f7 64 24 0c          	mull   0xc(%esp)
  800cf1:	89 c5                	mov    %eax,%ebp
  800cf3:	89 d1                	mov    %edx,%ecx
  800cf5:	39 d6                	cmp    %edx,%esi
  800cf7:	72 67                	jb     800d60 <__umoddi3+0x114>
  800cf9:	74 75                	je     800d70 <__umoddi3+0x124>
  800cfb:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cff:	29 e8                	sub    %ebp,%eax
  800d01:	19 ce                	sbb    %ecx,%esi
  800d03:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d07:	d3 e8                	shr    %cl,%eax
  800d09:	89 f2                	mov    %esi,%edx
  800d0b:	89 f9                	mov    %edi,%ecx
  800d0d:	d3 e2                	shl    %cl,%edx
  800d0f:	09 d0                	or     %edx,%eax
  800d11:	89 f2                	mov    %esi,%edx
  800d13:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800d17:	d3 ea                	shr    %cl,%edx
  800d19:	83 c4 20             	add    $0x20,%esp
  800d1c:	5e                   	pop    %esi
  800d1d:	5f                   	pop    %edi
  800d1e:	5d                   	pop    %ebp
  800d1f:	c3                   	ret    
  800d20:	85 c9                	test   %ecx,%ecx
  800d22:	75 0b                	jne    800d2f <__umoddi3+0xe3>
  800d24:	b8 01 00 00 00       	mov    $0x1,%eax
  800d29:	31 d2                	xor    %edx,%edx
  800d2b:	f7 f1                	div    %ecx
  800d2d:	89 c1                	mov    %eax,%ecx
  800d2f:	89 f0                	mov    %esi,%eax
  800d31:	31 d2                	xor    %edx,%edx
  800d33:	f7 f1                	div    %ecx
  800d35:	89 f8                	mov    %edi,%eax
  800d37:	e9 3e ff ff ff       	jmp    800c7a <__umoddi3+0x2e>
  800d3c:	89 f2                	mov    %esi,%edx
  800d3e:	83 c4 20             	add    $0x20,%esp
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	39 f5                	cmp    %esi,%ebp
  800d4a:	72 04                	jb     800d50 <__umoddi3+0x104>
  800d4c:	39 f9                	cmp    %edi,%ecx
  800d4e:	77 06                	ja     800d56 <__umoddi3+0x10a>
  800d50:	89 f2                	mov    %esi,%edx
  800d52:	29 cf                	sub    %ecx,%edi
  800d54:	19 ea                	sbb    %ebp,%edx
  800d56:	89 f8                	mov    %edi,%eax
  800d58:	83 c4 20             	add    $0x20,%esp
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    
  800d5f:	90                   	nop
  800d60:	89 d1                	mov    %edx,%ecx
  800d62:	89 c5                	mov    %eax,%ebp
  800d64:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d68:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d6c:	eb 8d                	jmp    800cfb <__umoddi3+0xaf>
  800d6e:	66 90                	xchg   %ax,%ax
  800d70:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d74:	72 ea                	jb     800d60 <__umoddi3+0x114>
  800d76:	89 f1                	mov    %esi,%ecx
  800d78:	eb 81                	jmp    800cfb <__umoddi3+0xaf>
