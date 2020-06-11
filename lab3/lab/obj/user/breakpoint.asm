
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 0b 00 00 00       	call   80003c <libmain>
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
	asm volatile("int $3");
  800037:	cc                   	int3   
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    
	...

0080003c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003c:	55                   	push   %ebp
  80003d:	89 e5                	mov    %esp,%ebp
  80003f:	83 ec 18             	sub    $0x18,%esp
  800042:	8b 45 08             	mov    0x8(%ebp),%eax
  800045:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800048:	c7 05 04 10 80 00 00 	movl   $0x0,0x801004
  80004f:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800052:	85 c0                	test   %eax,%eax
  800054:	7e 08                	jle    80005e <libmain+0x22>
		binaryname = argv[0];
  800056:	8b 0a                	mov    (%edx),%ecx
  800058:	89 0d 00 10 80 00    	mov    %ecx,0x801000

	// call user main routine
	umain(argc, argv);
  80005e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800062:	89 04 24             	mov    %eax,(%esp)
  800065:	e8 ca ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80006a:	e8 05 00 00 00       	call   800074 <exit>
}
  80006f:	c9                   	leave  
  800070:	c3                   	ret    
  800071:	00 00                	add    %al,(%eax)
	...

00800074 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800074:	55                   	push   %ebp
  800075:	89 e5                	mov    %esp,%ebp
  800077:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80007a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800081:	e8 3f 00 00 00       	call   8000c5 <sys_env_destroy>
}
  800086:	c9                   	leave  
  800087:	c3                   	ret    

00800088 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	57                   	push   %edi
  80008c:	56                   	push   %esi
  80008d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80008e:	b8 00 00 00 00       	mov    $0x0,%eax
  800093:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800096:	8b 55 08             	mov    0x8(%ebp),%edx
  800099:	89 c3                	mov    %eax,%ebx
  80009b:	89 c7                	mov    %eax,%edi
  80009d:	89 c6                	mov    %eax,%esi
  80009f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a1:	5b                   	pop    %ebx
  8000a2:	5e                   	pop    %esi
  8000a3:	5f                   	pop    %edi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000b6:	89 d1                	mov    %edx,%ecx
  8000b8:	89 d3                	mov    %edx,%ebx
  8000ba:	89 d7                	mov    %edx,%edi
  8000bc:	89 d6                	mov    %edx,%esi
  8000be:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
  8000cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	89 cb                	mov    %ecx,%ebx
  8000dd:	89 cf                	mov    %ecx,%edi
  8000df:	89 ce                	mov    %ecx,%esi
  8000e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	7e 28                	jle    80010f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000eb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8000f2:	00 
  8000f3:	c7 44 24 08 5a 0d 80 	movl   $0x800d5a,0x8(%esp)
  8000fa:	00 
  8000fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800102:	00 
  800103:	c7 04 24 77 0d 80 00 	movl   $0x800d77,(%esp)
  80010a:	e8 29 00 00 00       	call   800138 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	83 c4 2c             	add    $0x2c,%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    
	...

00800138 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  800140:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800143:	8b 1d 00 10 80 00    	mov    0x801000,%ebx
  800149:	e8 c9 ff ff ff       	call   800117 <sys_getenvid>
  80014e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800151:	89 54 24 10          	mov    %edx,0x10(%esp)
  800155:	8b 55 08             	mov    0x8(%ebp),%edx
  800158:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80015c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800160:	89 44 24 04          	mov    %eax,0x4(%esp)
  800164:	c7 04 24 88 0d 80 00 	movl   $0x800d88,(%esp)
  80016b:	e8 c0 00 00 00       	call   800230 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800170:	89 74 24 04          	mov    %esi,0x4(%esp)
  800174:	8b 45 10             	mov    0x10(%ebp),%eax
  800177:	89 04 24             	mov    %eax,(%esp)
  80017a:	e8 50 00 00 00       	call   8001cf <vcprintf>
	cprintf("\n");
  80017f:	c7 04 24 ac 0d 80 00 	movl   $0x800dac,(%esp)
  800186:	e8 a5 00 00 00       	call   800230 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80018b:	cc                   	int3   
  80018c:	eb fd                	jmp    80018b <_panic+0x53>
	...

00800190 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	53                   	push   %ebx
  800194:	83 ec 14             	sub    $0x14,%esp
  800197:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80019a:	8b 03                	mov    (%ebx),%eax
  80019c:	8b 55 08             	mov    0x8(%ebp),%edx
  80019f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001a3:	40                   	inc    %eax
  8001a4:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001ab:	75 19                	jne    8001c6 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  8001ad:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001b4:	00 
  8001b5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b8:	89 04 24             	mov    %eax,(%esp)
  8001bb:	e8 c8 fe ff ff       	call   800088 <sys_cputs>
		b->idx = 0;
  8001c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001c6:	ff 43 04             	incl   0x4(%ebx)
}
  8001c9:	83 c4 14             	add    $0x14,%esp
  8001cc:	5b                   	pop    %ebx
  8001cd:	5d                   	pop    %ebp
  8001ce:	c3                   	ret    

008001cf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001df:	00 00 00 
	b.cnt = 0;
  8001e2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001e9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800200:	89 44 24 04          	mov    %eax,0x4(%esp)
  800204:	c7 04 24 90 01 80 00 	movl   $0x800190,(%esp)
  80020b:	e8 82 01 00 00       	call   800392 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800210:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800216:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	e8 60 fe ff ff       	call   800088 <sys_cputs>

	return b.cnt;
}
  800228:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022e:	c9                   	leave  
  80022f:	c3                   	ret    

00800230 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800236:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800239:	89 44 24 04          	mov    %eax,0x4(%esp)
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	89 04 24             	mov    %eax,(%esp)
  800243:	e8 87 ff ff ff       	call   8001cf <vcprintf>
	va_end(ap);

	return cnt;
}
  800248:	c9                   	leave  
  800249:	c3                   	ret    
	...

0080024c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80024c:	55                   	push   %ebp
  80024d:	89 e5                	mov    %esp,%ebp
  80024f:	57                   	push   %edi
  800250:	56                   	push   %esi
  800251:	53                   	push   %ebx
  800252:	83 ec 3c             	sub    $0x3c,%esp
  800255:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800258:	89 d7                	mov    %edx,%edi
  80025a:	8b 45 08             	mov    0x8(%ebp),%eax
  80025d:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800260:	8b 45 0c             	mov    0xc(%ebp),%eax
  800263:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800266:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800269:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80026c:	85 c0                	test   %eax,%eax
  80026e:	75 08                	jne    800278 <printnum+0x2c>
  800270:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800273:	39 45 10             	cmp    %eax,0x10(%ebp)
  800276:	77 57                	ja     8002cf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800278:	89 74 24 10          	mov    %esi,0x10(%esp)
  80027c:	4b                   	dec    %ebx
  80027d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800281:	8b 45 10             	mov    0x10(%ebp),%eax
  800284:	89 44 24 08          	mov    %eax,0x8(%esp)
  800288:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80028c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800290:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800297:	00 
  800298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80029b:	89 04 24             	mov    %eax,(%esp)
  80029e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002a5:	e8 56 08 00 00       	call   800b00 <__udivdi3>
  8002aa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002ae:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002b2:	89 04 24             	mov    %eax,(%esp)
  8002b5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002b9:	89 fa                	mov    %edi,%edx
  8002bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002be:	e8 89 ff ff ff       	call   80024c <printnum>
  8002c3:	eb 0f                	jmp    8002d4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002c5:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002c9:	89 34 24             	mov    %esi,(%esp)
  8002cc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002cf:	4b                   	dec    %ebx
  8002d0:	85 db                	test   %ebx,%ebx
  8002d2:	7f f1                	jg     8002c5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002d4:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8002d8:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8002dc:	8b 45 10             	mov    0x10(%ebp),%eax
  8002df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ea:	00 
  8002eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ee:	89 04 24             	mov    %eax,(%esp)
  8002f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002f8:	e8 23 09 00 00       	call   800c20 <__umoddi3>
  8002fd:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800301:	0f be 80 ae 0d 80 00 	movsbl 0x800dae(%eax),%eax
  800308:	89 04 24             	mov    %eax,(%esp)
  80030b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80030e:	83 c4 3c             	add    $0x3c,%esp
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800319:	83 fa 01             	cmp    $0x1,%edx
  80031c:	7e 0e                	jle    80032c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80031e:	8b 10                	mov    (%eax),%edx
  800320:	8d 4a 08             	lea    0x8(%edx),%ecx
  800323:	89 08                	mov    %ecx,(%eax)
  800325:	8b 02                	mov    (%edx),%eax
  800327:	8b 52 04             	mov    0x4(%edx),%edx
  80032a:	eb 22                	jmp    80034e <getuint+0x38>
	else if (lflag)
  80032c:	85 d2                	test   %edx,%edx
  80032e:	74 10                	je     800340 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800330:	8b 10                	mov    (%eax),%edx
  800332:	8d 4a 04             	lea    0x4(%edx),%ecx
  800335:	89 08                	mov    %ecx,(%eax)
  800337:	8b 02                	mov    (%edx),%eax
  800339:	ba 00 00 00 00       	mov    $0x0,%edx
  80033e:	eb 0e                	jmp    80034e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800356:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  800359:	8b 10                	mov    (%eax),%edx
  80035b:	3b 50 04             	cmp    0x4(%eax),%edx
  80035e:	73 08                	jae    800368 <sprintputch+0x18>
		*b->buf++ = ch;
  800360:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800363:	88 0a                	mov    %cl,(%edx)
  800365:	42                   	inc    %edx
  800366:	89 10                	mov    %edx,(%eax)
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  800370:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800373:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800377:	8b 45 10             	mov    0x10(%ebp),%eax
  80037a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800381:	89 44 24 04          	mov    %eax,0x4(%esp)
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	e8 02 00 00 00       	call   800392 <vprintfmt>
	va_end(ap);
}
  800390:	c9                   	leave  
  800391:	c3                   	ret    

00800392 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800392:	55                   	push   %ebp
  800393:	89 e5                	mov    %esp,%ebp
  800395:	57                   	push   %edi
  800396:	56                   	push   %esi
  800397:	53                   	push   %ebx
  800398:	83 ec 4c             	sub    $0x4c,%esp
  80039b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80039e:	8b 75 10             	mov    0x10(%ebp),%esi
  8003a1:	eb 12                	jmp    8003b5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003a3:	85 c0                	test   %eax,%eax
  8003a5:	0f 84 6b 03 00 00    	je     800716 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
  8003ab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8003af:	89 04 24             	mov    %eax,(%esp)
  8003b2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003b5:	0f b6 06             	movzbl (%esi),%eax
  8003b8:	46                   	inc    %esi
  8003b9:	83 f8 25             	cmp    $0x25,%eax
  8003bc:	75 e5                	jne    8003a3 <vprintfmt+0x11>
  8003be:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  8003c2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  8003c9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  8003ce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003da:	eb 26                	jmp    800402 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  8003df:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  8003e3:	eb 1d                	jmp    800402 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003e8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  8003ec:	eb 14                	jmp    800402 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  8003f1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003f8:	eb 08                	jmp    800402 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  8003fa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8003fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800402:	0f b6 06             	movzbl (%esi),%eax
  800405:	8d 56 01             	lea    0x1(%esi),%edx
  800408:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80040b:	8a 16                	mov    (%esi),%dl
  80040d:	83 ea 23             	sub    $0x23,%edx
  800410:	80 fa 55             	cmp    $0x55,%dl
  800413:	0f 87 e1 02 00 00    	ja     8006fa <vprintfmt+0x368>
  800419:	0f b6 d2             	movzbl %dl,%edx
  80041c:	ff 24 95 3c 0e 80 00 	jmp    *0x800e3c(,%edx,4)
  800423:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800426:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80042b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  80042e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  800432:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  800435:	8d 50 d0             	lea    -0x30(%eax),%edx
  800438:	83 fa 09             	cmp    $0x9,%edx
  80043b:	77 2a                	ja     800467 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80043d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80043e:	eb eb                	jmp    80042b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 50 04             	lea    0x4(%eax),%edx
  800446:	89 55 14             	mov    %edx,0x14(%ebp)
  800449:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80044e:	eb 17                	jmp    800467 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  800450:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800454:	78 98                	js     8003ee <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800456:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800459:	eb a7                	jmp    800402 <vprintfmt+0x70>
  80045b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80045e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800465:	eb 9b                	jmp    800402 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  800467:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046b:	79 95                	jns    800402 <vprintfmt+0x70>
  80046d:	eb 8b                	jmp    8003fa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80046f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800473:	eb 8d                	jmp    800402 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800475:	8b 45 14             	mov    0x14(%ebp),%eax
  800478:	8d 50 04             	lea    0x4(%eax),%edx
  80047b:	89 55 14             	mov    %edx,0x14(%ebp)
  80047e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800482:	8b 00                	mov    (%eax),%eax
  800484:	89 04 24             	mov    %eax,(%esp)
  800487:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80048d:	e9 23 ff ff ff       	jmp    8003b5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 50 04             	lea    0x4(%eax),%edx
  800498:	89 55 14             	mov    %edx,0x14(%ebp)
  80049b:	8b 00                	mov    (%eax),%eax
  80049d:	85 c0                	test   %eax,%eax
  80049f:	79 02                	jns    8004a3 <vprintfmt+0x111>
  8004a1:	f7 d8                	neg    %eax
  8004a3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a5:	83 f8 06             	cmp    $0x6,%eax
  8004a8:	7f 0b                	jg     8004b5 <vprintfmt+0x123>
  8004aa:	8b 04 85 94 0f 80 00 	mov    0x800f94(,%eax,4),%eax
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	75 23                	jne    8004d8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  8004b5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b9:	c7 44 24 08 c6 0d 80 	movl   $0x800dc6,0x8(%esp)
  8004c0:	00 
  8004c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c8:	89 04 24             	mov    %eax,(%esp)
  8004cb:	e8 9a fe ff ff       	call   80036a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8004d3:	e9 dd fe ff ff       	jmp    8003b5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  8004d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004dc:	c7 44 24 08 cf 0d 80 	movl   $0x800dcf,0x8(%esp)
  8004e3:	00 
  8004e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8004e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8004eb:	89 14 24             	mov    %edx,(%esp)
  8004ee:	e8 77 fe ff ff       	call   80036a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8004f6:	e9 ba fe ff ff       	jmp    8003b5 <vprintfmt+0x23>
  8004fb:	89 f9                	mov    %edi,%ecx
  8004fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800500:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8d 50 04             	lea    0x4(%eax),%edx
  800509:	89 55 14             	mov    %edx,0x14(%ebp)
  80050c:	8b 30                	mov    (%eax),%esi
  80050e:	85 f6                	test   %esi,%esi
  800510:	75 05                	jne    800517 <vprintfmt+0x185>
				p = "(null)";
  800512:	be bf 0d 80 00       	mov    $0x800dbf,%esi
			if (width > 0 && padc != '-')
  800517:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051b:	0f 8e 84 00 00 00    	jle    8005a5 <vprintfmt+0x213>
  800521:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  800525:	74 7e                	je     8005a5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  800527:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80052b:	89 34 24             	mov    %esi,(%esp)
  80052e:	e8 8b 02 00 00       	call   8007be <strnlen>
  800533:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800536:	29 c2                	sub    %eax,%edx
  800538:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  80053b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  80053f:	89 75 d0             	mov    %esi,-0x30(%ebp)
  800542:	89 7d cc             	mov    %edi,-0x34(%ebp)
  800545:	89 de                	mov    %ebx,%esi
  800547:	89 d3                	mov    %edx,%ebx
  800549:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054b:	eb 0b                	jmp    800558 <vprintfmt+0x1c6>
					putch(padc, putdat);
  80054d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800551:	89 3c 24             	mov    %edi,(%esp)
  800554:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800557:	4b                   	dec    %ebx
  800558:	85 db                	test   %ebx,%ebx
  80055a:	7f f1                	jg     80054d <vprintfmt+0x1bb>
  80055c:	8b 7d cc             	mov    -0x34(%ebp),%edi
  80055f:	89 f3                	mov    %esi,%ebx
  800561:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  800564:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800567:	85 c0                	test   %eax,%eax
  800569:	79 05                	jns    800570 <vprintfmt+0x1de>
  80056b:	b8 00 00 00 00       	mov    $0x0,%eax
  800570:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800573:	29 c2                	sub    %eax,%edx
  800575:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800578:	eb 2b                	jmp    8005a5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80057e:	74 18                	je     800598 <vprintfmt+0x206>
  800580:	8d 50 e0             	lea    -0x20(%eax),%edx
  800583:	83 fa 5e             	cmp    $0x5e,%edx
  800586:	76 10                	jbe    800598 <vprintfmt+0x206>
					putch('?', putdat);
  800588:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80058c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800593:	ff 55 08             	call   *0x8(%ebp)
  800596:	eb 0a                	jmp    8005a2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800598:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a2:	ff 4d e4             	decl   -0x1c(%ebp)
  8005a5:	0f be 06             	movsbl (%esi),%eax
  8005a8:	46                   	inc    %esi
  8005a9:	85 c0                	test   %eax,%eax
  8005ab:	74 21                	je     8005ce <vprintfmt+0x23c>
  8005ad:	85 ff                	test   %edi,%edi
  8005af:	78 c9                	js     80057a <vprintfmt+0x1e8>
  8005b1:	4f                   	dec    %edi
  8005b2:	79 c6                	jns    80057a <vprintfmt+0x1e8>
  8005b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005b7:	89 de                	mov    %ebx,%esi
  8005b9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005bc:	eb 18                	jmp    8005d6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cb:	4b                   	dec    %ebx
  8005cc:	eb 08                	jmp    8005d6 <vprintfmt+0x244>
  8005ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8005d1:	89 de                	mov    %ebx,%esi
  8005d3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8005d6:	85 db                	test   %ebx,%ebx
  8005d8:	7f e4                	jg     8005be <vprintfmt+0x22c>
  8005da:	89 7d 08             	mov    %edi,0x8(%ebp)
  8005dd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e2:	e9 ce fd ff ff       	jmp    8003b5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005e7:	83 f9 01             	cmp    $0x1,%ecx
  8005ea:	7e 10                	jle    8005fc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 08             	lea    0x8(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 30                	mov    (%eax),%esi
  8005f7:	8b 78 04             	mov    0x4(%eax),%edi
  8005fa:	eb 26                	jmp    800622 <vprintfmt+0x290>
	else if (lflag)
  8005fc:	85 c9                	test   %ecx,%ecx
  8005fe:	74 12                	je     800612 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800600:	8b 45 14             	mov    0x14(%ebp),%eax
  800603:	8d 50 04             	lea    0x4(%eax),%edx
  800606:	89 55 14             	mov    %edx,0x14(%ebp)
  800609:	8b 30                	mov    (%eax),%esi
  80060b:	89 f7                	mov    %esi,%edi
  80060d:	c1 ff 1f             	sar    $0x1f,%edi
  800610:	eb 10                	jmp    800622 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 30                	mov    (%eax),%esi
  80061d:	89 f7                	mov    %esi,%edi
  80061f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800622:	85 ff                	test   %edi,%edi
  800624:	78 0a                	js     800630 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800626:	b8 0a 00 00 00       	mov    $0xa,%eax
  80062b:	e9 8c 00 00 00       	jmp    8006bc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  800630:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800634:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  80063e:	f7 de                	neg    %esi
  800640:	83 d7 00             	adc    $0x0,%edi
  800643:	f7 df                	neg    %edi
			}
			base = 10;
  800645:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064a:	eb 70                	jmp    8006bc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80064c:	89 ca                	mov    %ecx,%edx
  80064e:	8d 45 14             	lea    0x14(%ebp),%eax
  800651:	e8 c0 fc ff ff       	call   800316 <getuint>
  800656:	89 c6                	mov    %eax,%esi
  800658:	89 d7                	mov    %edx,%edi
			base = 10;
  80065a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80065f:	eb 5b                	jmp    8006bc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800661:	89 ca                	mov    %ecx,%edx
  800663:	8d 45 14             	lea    0x14(%ebp),%eax
  800666:	e8 ab fc ff ff       	call   800316 <getuint>
  80066b:	89 c6                	mov    %eax,%esi
  80066d:	89 d7                	mov    %edx,%edi
			base = 8;
  80066f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800674:	eb 46                	jmp    8006bc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
  800676:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80067a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800681:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800688:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80068f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 04             	lea    0x4(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80069b:	8b 30                	mov    (%eax),%esi
  80069d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006a7:	eb 13                	jmp    8006bc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a9:	89 ca                	mov    %ecx,%edx
  8006ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ae:	e8 63 fc ff ff       	call   800316 <getuint>
  8006b3:	89 c6                	mov    %eax,%esi
  8006b5:	89 d7                	mov    %edx,%edi
			base = 16;
  8006b7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  8006c0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006cf:	89 34 24             	mov    %esi,(%esp)
  8006d2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8006d6:	89 da                	mov    %ebx,%edx
  8006d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006db:	e8 6c fb ff ff       	call   80024c <printnum>
			break;
  8006e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8006e3:	e9 cd fc ff ff       	jmp    8003b5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006ec:	89 04 24             	mov    %eax,(%esp)
  8006ef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006f2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006f5:	e9 bb fc ff ff       	jmp    8003b5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006fa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006fe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800705:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  800708:	eb 01                	jmp    80070b <vprintfmt+0x379>
  80070a:	4e                   	dec    %esi
  80070b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  80070f:	75 f9                	jne    80070a <vprintfmt+0x378>
  800711:	e9 9f fc ff ff       	jmp    8003b5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  800716:	83 c4 4c             	add    $0x4c,%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	83 ec 28             	sub    $0x28,%esp
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80072a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800731:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800734:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80073b:	85 c0                	test   %eax,%eax
  80073d:	74 30                	je     80076f <vsnprintf+0x51>
  80073f:	85 d2                	test   %edx,%edx
  800741:	7e 33                	jle    800776 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800751:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800754:	89 44 24 04          	mov    %eax,0x4(%esp)
  800758:	c7 04 24 50 03 80 00 	movl   $0x800350,(%esp)
  80075f:	e8 2e fc ff ff       	call   800392 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800764:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800767:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	eb 0c                	jmp    80077b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80076f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800774:	eb 05                	jmp    80077b <vsnprintf+0x5d>
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80077b:	c9                   	leave  
  80077c:	c3                   	ret    

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
  800794:	89 44 24 04          	mov    %eax,0x4(%esp)
  800798:	8b 45 08             	mov    0x8(%ebp),%eax
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	e8 7b ff ff ff       	call   80071e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    
  8007a5:	00 00                	add    %al,(%eax)
	...

008007a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	eb 01                	jmp    8007b6 <strlen+0xe>
		n++;
  8007b5:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ba:	75 f9                	jne    8007b5 <strlen+0xd>
		n++;
	return n;
}
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  8007c4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cc:	eb 01                	jmp    8007cf <strnlen+0x11>
		n++;
  8007ce:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007cf:	39 d0                	cmp    %edx,%eax
  8007d1:	74 06                	je     8007d9 <strnlen+0x1b>
  8007d3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d7:	75 f5                	jne    8007ce <strnlen+0x10>
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8007ea:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  8007ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8007f0:	42                   	inc    %edx
  8007f1:	84 c9                	test   %cl,%cl
  8007f3:	75 f5                	jne    8007ea <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f5:	5b                   	pop    %ebx
  8007f6:	5d                   	pop    %ebp
  8007f7:	c3                   	ret    

008007f8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	53                   	push   %ebx
  8007fc:	83 ec 08             	sub    $0x8,%esp
  8007ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800802:	89 1c 24             	mov    %ebx,(%esp)
  800805:	e8 9e ff ff ff       	call   8007a8 <strlen>
	strcpy(dst + len, src);
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800811:	01 d8                	add    %ebx,%eax
  800813:	89 04 24             	mov    %eax,(%esp)
  800816:	e8 c0 ff ff ff       	call   8007db <strcpy>
	return dst;
}
  80081b:	89 d8                	mov    %ebx,%eax
  80081d:	83 c4 08             	add    $0x8,%esp
  800820:	5b                   	pop    %ebx
  800821:	5d                   	pop    %ebp
  800822:	c3                   	ret    

00800823 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800823:	55                   	push   %ebp
  800824:	89 e5                	mov    %esp,%ebp
  800826:	56                   	push   %esi
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	eb 0c                	jmp    800844 <strncpy+0x21>
		*dst++ = *src;
  800838:	8a 1a                	mov    (%edx),%bl
  80083a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083d:	80 3a 01             	cmpb   $0x1,(%edx)
  800840:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800843:	41                   	inc    %ecx
  800844:	39 f1                	cmp    %esi,%ecx
  800846:	75 f0                	jne    800838 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800848:	5b                   	pop    %ebx
  800849:	5e                   	pop    %esi
  80084a:	5d                   	pop    %ebp
  80084b:	c3                   	ret    

0080084c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084c:	55                   	push   %ebp
  80084d:	89 e5                	mov    %esp,%ebp
  80084f:	56                   	push   %esi
  800850:	53                   	push   %ebx
  800851:	8b 75 08             	mov    0x8(%ebp),%esi
  800854:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800857:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085a:	85 d2                	test   %edx,%edx
  80085c:	75 0a                	jne    800868 <strlcpy+0x1c>
  80085e:	89 f0                	mov    %esi,%eax
  800860:	eb 1a                	jmp    80087c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800862:	88 18                	mov    %bl,(%eax)
  800864:	40                   	inc    %eax
  800865:	41                   	inc    %ecx
  800866:	eb 02                	jmp    80086a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800868:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  80086a:	4a                   	dec    %edx
  80086b:	74 0a                	je     800877 <strlcpy+0x2b>
  80086d:	8a 19                	mov    (%ecx),%bl
  80086f:	84 db                	test   %bl,%bl
  800871:	75 ef                	jne    800862 <strlcpy+0x16>
  800873:	89 c2                	mov    %eax,%edx
  800875:	eb 02                	jmp    800879 <strlcpy+0x2d>
  800877:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800879:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  80087c:	29 f0                	sub    %esi,%eax
}
  80087e:	5b                   	pop    %ebx
  80087f:	5e                   	pop    %esi
  800880:	5d                   	pop    %ebp
  800881:	c3                   	ret    

00800882 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800888:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088b:	eb 02                	jmp    80088f <strcmp+0xd>
		p++, q++;
  80088d:	41                   	inc    %ecx
  80088e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80088f:	8a 01                	mov    (%ecx),%al
  800891:	84 c0                	test   %al,%al
  800893:	74 04                	je     800899 <strcmp+0x17>
  800895:	3a 02                	cmp    (%edx),%al
  800897:	74 f4                	je     80088d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800899:	0f b6 c0             	movzbl %al,%eax
  80089c:	0f b6 12             	movzbl (%edx),%edx
  80089f:	29 d0                	sub    %edx,%eax
}
  8008a1:	5d                   	pop    %ebp
  8008a2:	c3                   	ret    

008008a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	53                   	push   %ebx
  8008a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008ad:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  8008b0:	eb 03                	jmp    8008b5 <strncmp+0x12>
		n--, p++, q++;
  8008b2:	4a                   	dec    %edx
  8008b3:	40                   	inc    %eax
  8008b4:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8008b5:	85 d2                	test   %edx,%edx
  8008b7:	74 14                	je     8008cd <strncmp+0x2a>
  8008b9:	8a 18                	mov    (%eax),%bl
  8008bb:	84 db                	test   %bl,%bl
  8008bd:	74 04                	je     8008c3 <strncmp+0x20>
  8008bf:	3a 19                	cmp    (%ecx),%bl
  8008c1:	74 ef                	je     8008b2 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c3:	0f b6 00             	movzbl (%eax),%eax
  8008c6:	0f b6 11             	movzbl (%ecx),%edx
  8008c9:	29 d0                	sub    %edx,%eax
  8008cb:	eb 05                	jmp    8008d2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008de:	eb 05                	jmp    8008e5 <strchr+0x10>
		if (*s == c)
  8008e0:	38 ca                	cmp    %cl,%dl
  8008e2:	74 0c                	je     8008f0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008e4:	40                   	inc    %eax
  8008e5:	8a 10                	mov    (%eax),%dl
  8008e7:	84 d2                	test   %dl,%dl
  8008e9:	75 f5                	jne    8008e0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  8008fb:	eb 05                	jmp    800902 <strfind+0x10>
		if (*s == c)
  8008fd:	38 ca                	cmp    %cl,%dl
  8008ff:	74 07                	je     800908 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800901:	40                   	inc    %eax
  800902:	8a 10                	mov    (%eax),%dl
  800904:	84 d2                	test   %dl,%dl
  800906:	75 f5                	jne    8008fd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	57                   	push   %edi
  80090e:	56                   	push   %esi
  80090f:	53                   	push   %ebx
  800910:	8b 7d 08             	mov    0x8(%ebp),%edi
  800913:	8b 45 0c             	mov    0xc(%ebp),%eax
  800916:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800919:	85 c9                	test   %ecx,%ecx
  80091b:	74 30                	je     80094d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80091d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800923:	75 25                	jne    80094a <memset+0x40>
  800925:	f6 c1 03             	test   $0x3,%cl
  800928:	75 20                	jne    80094a <memset+0x40>
		c &= 0xFF;
  80092a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092d:	89 d3                	mov    %edx,%ebx
  80092f:	c1 e3 08             	shl    $0x8,%ebx
  800932:	89 d6                	mov    %edx,%esi
  800934:	c1 e6 18             	shl    $0x18,%esi
  800937:	89 d0                	mov    %edx,%eax
  800939:	c1 e0 10             	shl    $0x10,%eax
  80093c:	09 f0                	or     %esi,%eax
  80093e:	09 d0                	or     %edx,%eax
  800940:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800942:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800945:	fc                   	cld    
  800946:	f3 ab                	rep stos %eax,%es:(%edi)
  800948:	eb 03                	jmp    80094d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094a:	fc                   	cld    
  80094b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80094d:	89 f8                	mov    %edi,%eax
  80094f:	5b                   	pop    %ebx
  800950:	5e                   	pop    %esi
  800951:	5f                   	pop    %edi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	57                   	push   %edi
  800958:	56                   	push   %esi
  800959:	8b 45 08             	mov    0x8(%ebp),%eax
  80095c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800962:	39 c6                	cmp    %eax,%esi
  800964:	73 34                	jae    80099a <memmove+0x46>
  800966:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800969:	39 d0                	cmp    %edx,%eax
  80096b:	73 2d                	jae    80099a <memmove+0x46>
		s += n;
		d += n;
  80096d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800970:	f6 c2 03             	test   $0x3,%dl
  800973:	75 1b                	jne    800990 <memmove+0x3c>
  800975:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80097b:	75 13                	jne    800990 <memmove+0x3c>
  80097d:	f6 c1 03             	test   $0x3,%cl
  800980:	75 0e                	jne    800990 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800982:	83 ef 04             	sub    $0x4,%edi
  800985:	8d 72 fc             	lea    -0x4(%edx),%esi
  800988:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80098b:	fd                   	std    
  80098c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098e:	eb 07                	jmp    800997 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800990:	4f                   	dec    %edi
  800991:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800994:	fd                   	std    
  800995:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800997:	fc                   	cld    
  800998:	eb 20                	jmp    8009ba <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80099a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a0:	75 13                	jne    8009b5 <memmove+0x61>
  8009a2:	a8 03                	test   $0x3,%al
  8009a4:	75 0f                	jne    8009b5 <memmove+0x61>
  8009a6:	f6 c1 03             	test   $0x3,%cl
  8009a9:	75 0a                	jne    8009b5 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ab:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8009ae:	89 c7                	mov    %eax,%edi
  8009b0:	fc                   	cld    
  8009b1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b3:	eb 05                	jmp    8009ba <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009b5:	89 c7                	mov    %eax,%edi
  8009b7:	fc                   	cld    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ba:	5e                   	pop    %esi
  8009bb:	5f                   	pop    %edi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	89 04 24             	mov    %eax,(%esp)
  8009d8:	e8 77 ff ff ff       	call   800954 <memmove>
}
  8009dd:	c9                   	leave  
  8009de:	c3                   	ret    

008009df <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009df:	55                   	push   %ebp
  8009e0:	89 e5                	mov    %esp,%ebp
  8009e2:	57                   	push   %edi
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009eb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f3:	eb 16                	jmp    800a0b <memcmp+0x2c>
		if (*s1 != *s2)
  8009f5:	8a 04 17             	mov    (%edi,%edx,1),%al
  8009f8:	42                   	inc    %edx
  8009f9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  8009fd:	38 c8                	cmp    %cl,%al
  8009ff:	74 0a                	je     800a0b <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800a01:	0f b6 c0             	movzbl %al,%eax
  800a04:	0f b6 c9             	movzbl %cl,%ecx
  800a07:	29 c8                	sub    %ecx,%eax
  800a09:	eb 09                	jmp    800a14 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a0b:	39 da                	cmp    %ebx,%edx
  800a0d:	75 e6                	jne    8009f5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	5f                   	pop    %edi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a22:	89 c2                	mov    %eax,%edx
  800a24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a27:	eb 05                	jmp    800a2e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a29:	38 08                	cmp    %cl,(%eax)
  800a2b:	74 05                	je     800a32 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a2d:	40                   	inc    %eax
  800a2e:	39 d0                	cmp    %edx,%eax
  800a30:	72 f7                	jb     800a29 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a32:	5d                   	pop    %ebp
  800a33:	c3                   	ret    

00800a34 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	57                   	push   %edi
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a40:	eb 01                	jmp    800a43 <strtol+0xf>
		s++;
  800a42:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a43:	8a 02                	mov    (%edx),%al
  800a45:	3c 20                	cmp    $0x20,%al
  800a47:	74 f9                	je     800a42 <strtol+0xe>
  800a49:	3c 09                	cmp    $0x9,%al
  800a4b:	74 f5                	je     800a42 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a4d:	3c 2b                	cmp    $0x2b,%al
  800a4f:	75 08                	jne    800a59 <strtol+0x25>
		s++;
  800a51:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a52:	bf 00 00 00 00       	mov    $0x0,%edi
  800a57:	eb 13                	jmp    800a6c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a59:	3c 2d                	cmp    $0x2d,%al
  800a5b:	75 0a                	jne    800a67 <strtol+0x33>
		s++, neg = 1;
  800a5d:	8d 52 01             	lea    0x1(%edx),%edx
  800a60:	bf 01 00 00 00       	mov    $0x1,%edi
  800a65:	eb 05                	jmp    800a6c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	74 05                	je     800a75 <strtol+0x41>
  800a70:	83 fb 10             	cmp    $0x10,%ebx
  800a73:	75 28                	jne    800a9d <strtol+0x69>
  800a75:	8a 02                	mov    (%edx),%al
  800a77:	3c 30                	cmp    $0x30,%al
  800a79:	75 10                	jne    800a8b <strtol+0x57>
  800a7b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a7f:	75 0a                	jne    800a8b <strtol+0x57>
		s += 2, base = 16;
  800a81:	83 c2 02             	add    $0x2,%edx
  800a84:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a89:	eb 12                	jmp    800a9d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800a8b:	85 db                	test   %ebx,%ebx
  800a8d:	75 0e                	jne    800a9d <strtol+0x69>
  800a8f:	3c 30                	cmp    $0x30,%al
  800a91:	75 05                	jne    800a98 <strtol+0x64>
		s++, base = 8;
  800a93:	42                   	inc    %edx
  800a94:	b3 08                	mov    $0x8,%bl
  800a96:	eb 05                	jmp    800a9d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800a98:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800a9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa2:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800aa4:	8a 0a                	mov    (%edx),%cl
  800aa6:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800aa9:	80 fb 09             	cmp    $0x9,%bl
  800aac:	77 08                	ja     800ab6 <strtol+0x82>
			dig = *s - '0';
  800aae:	0f be c9             	movsbl %cl,%ecx
  800ab1:	83 e9 30             	sub    $0x30,%ecx
  800ab4:	eb 1e                	jmp    800ad4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800ab6:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800ab9:	80 fb 19             	cmp    $0x19,%bl
  800abc:	77 08                	ja     800ac6 <strtol+0x92>
			dig = *s - 'a' + 10;
  800abe:	0f be c9             	movsbl %cl,%ecx
  800ac1:	83 e9 57             	sub    $0x57,%ecx
  800ac4:	eb 0e                	jmp    800ad4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800ac6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800ac9:	80 fb 19             	cmp    $0x19,%bl
  800acc:	77 12                	ja     800ae0 <strtol+0xac>
			dig = *s - 'A' + 10;
  800ace:	0f be c9             	movsbl %cl,%ecx
  800ad1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ad4:	39 f1                	cmp    %esi,%ecx
  800ad6:	7d 0c                	jge    800ae4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800ad8:	42                   	inc    %edx
  800ad9:	0f af c6             	imul   %esi,%eax
  800adc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800ade:	eb c4                	jmp    800aa4 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800ae0:	89 c1                	mov    %eax,%ecx
  800ae2:	eb 02                	jmp    800ae6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ae4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800ae6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aea:	74 05                	je     800af1 <strtol+0xbd>
		*endptr = (char *) s;
  800aec:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800aef:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800af1:	85 ff                	test   %edi,%edi
  800af3:	74 04                	je     800af9 <strtol+0xc5>
  800af5:	89 c8                	mov    %ecx,%eax
  800af7:	f7 d8                	neg    %eax
}
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    
	...

00800b00 <__udivdi3>:
  800b00:	55                   	push   %ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	83 ec 10             	sub    $0x10,%esp
  800b06:	8b 74 24 20          	mov    0x20(%esp),%esi
  800b0a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  800b0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b12:	8b 7c 24 24          	mov    0x24(%esp),%edi
  800b16:	89 cd                	mov    %ecx,%ebp
  800b18:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  800b1c:	85 c0                	test   %eax,%eax
  800b1e:	75 2c                	jne    800b4c <__udivdi3+0x4c>
  800b20:	39 f9                	cmp    %edi,%ecx
  800b22:	77 68                	ja     800b8c <__udivdi3+0x8c>
  800b24:	85 c9                	test   %ecx,%ecx
  800b26:	75 0b                	jne    800b33 <__udivdi3+0x33>
  800b28:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2d:	31 d2                	xor    %edx,%edx
  800b2f:	f7 f1                	div    %ecx
  800b31:	89 c1                	mov    %eax,%ecx
  800b33:	31 d2                	xor    %edx,%edx
  800b35:	89 f8                	mov    %edi,%eax
  800b37:	f7 f1                	div    %ecx
  800b39:	89 c7                	mov    %eax,%edi
  800b3b:	89 f0                	mov    %esi,%eax
  800b3d:	f7 f1                	div    %ecx
  800b3f:	89 c6                	mov    %eax,%esi
  800b41:	89 f0                	mov    %esi,%eax
  800b43:	89 fa                	mov    %edi,%edx
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    
  800b4c:	39 f8                	cmp    %edi,%eax
  800b4e:	77 2c                	ja     800b7c <__udivdi3+0x7c>
  800b50:	0f bd f0             	bsr    %eax,%esi
  800b53:	83 f6 1f             	xor    $0x1f,%esi
  800b56:	75 4c                	jne    800ba4 <__udivdi3+0xa4>
  800b58:	39 f8                	cmp    %edi,%eax
  800b5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b5f:	72 0a                	jb     800b6b <__udivdi3+0x6b>
  800b61:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  800b65:	0f 87 ad 00 00 00    	ja     800c18 <__udivdi3+0x118>
  800b6b:	be 01 00 00 00       	mov    $0x1,%esi
  800b70:	89 f0                	mov    %esi,%eax
  800b72:	89 fa                	mov    %edi,%edx
  800b74:	83 c4 10             	add    $0x10,%esp
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    
  800b7b:	90                   	nop
  800b7c:	31 ff                	xor    %edi,%edi
  800b7e:	31 f6                	xor    %esi,%esi
  800b80:	89 f0                	mov    %esi,%eax
  800b82:	89 fa                	mov    %edi,%edx
  800b84:	83 c4 10             	add    $0x10,%esp
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    
  800b8b:	90                   	nop
  800b8c:	89 fa                	mov    %edi,%edx
  800b8e:	89 f0                	mov    %esi,%eax
  800b90:	f7 f1                	div    %ecx
  800b92:	89 c6                	mov    %eax,%esi
  800b94:	31 ff                	xor    %edi,%edi
  800b96:	89 f0                	mov    %esi,%eax
  800b98:	89 fa                	mov    %edi,%edx
  800b9a:	83 c4 10             	add    $0x10,%esp
  800b9d:	5e                   	pop    %esi
  800b9e:	5f                   	pop    %edi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    
  800ba1:	8d 76 00             	lea    0x0(%esi),%esi
  800ba4:	89 f1                	mov    %esi,%ecx
  800ba6:	d3 e0                	shl    %cl,%eax
  800ba8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bac:	b8 20 00 00 00       	mov    $0x20,%eax
  800bb1:	29 f0                	sub    %esi,%eax
  800bb3:	89 ea                	mov    %ebp,%edx
  800bb5:	88 c1                	mov    %al,%cl
  800bb7:	d3 ea                	shr    %cl,%edx
  800bb9:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  800bbd:	09 ca                	or     %ecx,%edx
  800bbf:	89 54 24 08          	mov    %edx,0x8(%esp)
  800bc3:	89 f1                	mov    %esi,%ecx
  800bc5:	d3 e5                	shl    %cl,%ebp
  800bc7:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  800bcb:	89 fd                	mov    %edi,%ebp
  800bcd:	88 c1                	mov    %al,%cl
  800bcf:	d3 ed                	shr    %cl,%ebp
  800bd1:	89 fa                	mov    %edi,%edx
  800bd3:	89 f1                	mov    %esi,%ecx
  800bd5:	d3 e2                	shl    %cl,%edx
  800bd7:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bdb:	88 c1                	mov    %al,%cl
  800bdd:	d3 ef                	shr    %cl,%edi
  800bdf:	09 d7                	or     %edx,%edi
  800be1:	89 f8                	mov    %edi,%eax
  800be3:	89 ea                	mov    %ebp,%edx
  800be5:	f7 74 24 08          	divl   0x8(%esp)
  800be9:	89 d1                	mov    %edx,%ecx
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	f7 64 24 0c          	mull   0xc(%esp)
  800bf1:	39 d1                	cmp    %edx,%ecx
  800bf3:	72 17                	jb     800c0c <__udivdi3+0x10c>
  800bf5:	74 09                	je     800c00 <__udivdi3+0x100>
  800bf7:	89 fe                	mov    %edi,%esi
  800bf9:	31 ff                	xor    %edi,%edi
  800bfb:	e9 41 ff ff ff       	jmp    800b41 <__udivdi3+0x41>
  800c00:	8b 54 24 04          	mov    0x4(%esp),%edx
  800c04:	89 f1                	mov    %esi,%ecx
  800c06:	d3 e2                	shl    %cl,%edx
  800c08:	39 c2                	cmp    %eax,%edx
  800c0a:	73 eb                	jae    800bf7 <__udivdi3+0xf7>
  800c0c:	8d 77 ff             	lea    -0x1(%edi),%esi
  800c0f:	31 ff                	xor    %edi,%edi
  800c11:	e9 2b ff ff ff       	jmp    800b41 <__udivdi3+0x41>
  800c16:	66 90                	xchg   %ax,%ax
  800c18:	31 f6                	xor    %esi,%esi
  800c1a:	e9 22 ff ff ff       	jmp    800b41 <__udivdi3+0x41>
	...

00800c20 <__umoddi3>:
  800c20:	55                   	push   %ebp
  800c21:	57                   	push   %edi
  800c22:	56                   	push   %esi
  800c23:	83 ec 20             	sub    $0x20,%esp
  800c26:	8b 44 24 30          	mov    0x30(%esp),%eax
  800c2a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  800c2e:	89 44 24 14          	mov    %eax,0x14(%esp)
  800c32:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c36:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800c3a:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  800c3e:	89 c7                	mov    %eax,%edi
  800c40:	89 f2                	mov    %esi,%edx
  800c42:	85 ed                	test   %ebp,%ebp
  800c44:	75 16                	jne    800c5c <__umoddi3+0x3c>
  800c46:	39 f1                	cmp    %esi,%ecx
  800c48:	0f 86 a6 00 00 00    	jbe    800cf4 <__umoddi3+0xd4>
  800c4e:	f7 f1                	div    %ecx
  800c50:	89 d0                	mov    %edx,%eax
  800c52:	31 d2                	xor    %edx,%edx
  800c54:	83 c4 20             	add    $0x20,%esp
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    
  800c5b:	90                   	nop
  800c5c:	39 f5                	cmp    %esi,%ebp
  800c5e:	0f 87 ac 00 00 00    	ja     800d10 <__umoddi3+0xf0>
  800c64:	0f bd c5             	bsr    %ebp,%eax
  800c67:	83 f0 1f             	xor    $0x1f,%eax
  800c6a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c6e:	0f 84 a8 00 00 00    	je     800d1c <__umoddi3+0xfc>
  800c74:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c78:	d3 e5                	shl    %cl,%ebp
  800c7a:	bf 20 00 00 00       	mov    $0x20,%edi
  800c7f:	2b 7c 24 10          	sub    0x10(%esp),%edi
  800c83:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c87:	89 f9                	mov    %edi,%ecx
  800c89:	d3 e8                	shr    %cl,%eax
  800c8b:	09 e8                	or     %ebp,%eax
  800c8d:	89 44 24 18          	mov    %eax,0x18(%esp)
  800c91:	8b 44 24 0c          	mov    0xc(%esp),%eax
  800c95:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800c99:	d3 e0                	shl    %cl,%eax
  800c9b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c9f:	89 f2                	mov    %esi,%edx
  800ca1:	d3 e2                	shl    %cl,%edx
  800ca3:	8b 44 24 14          	mov    0x14(%esp),%eax
  800ca7:	d3 e0                	shl    %cl,%eax
  800ca9:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  800cad:	8b 44 24 14          	mov    0x14(%esp),%eax
  800cb1:	89 f9                	mov    %edi,%ecx
  800cb3:	d3 e8                	shr    %cl,%eax
  800cb5:	09 d0                	or     %edx,%eax
  800cb7:	d3 ee                	shr    %cl,%esi
  800cb9:	89 f2                	mov    %esi,%edx
  800cbb:	f7 74 24 18          	divl   0x18(%esp)
  800cbf:	89 d6                	mov    %edx,%esi
  800cc1:	f7 64 24 0c          	mull   0xc(%esp)
  800cc5:	89 c5                	mov    %eax,%ebp
  800cc7:	89 d1                	mov    %edx,%ecx
  800cc9:	39 d6                	cmp    %edx,%esi
  800ccb:	72 67                	jb     800d34 <__umoddi3+0x114>
  800ccd:	74 75                	je     800d44 <__umoddi3+0x124>
  800ccf:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  800cd3:	29 e8                	sub    %ebp,%eax
  800cd5:	19 ce                	sbb    %ecx,%esi
  800cd7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800cdb:	d3 e8                	shr    %cl,%eax
  800cdd:	89 f2                	mov    %esi,%edx
  800cdf:	89 f9                	mov    %edi,%ecx
  800ce1:	d3 e2                	shl    %cl,%edx
  800ce3:	09 d0                	or     %edx,%eax
  800ce5:	89 f2                	mov    %esi,%edx
  800ce7:	8a 4c 24 10          	mov    0x10(%esp),%cl
  800ceb:	d3 ea                	shr    %cl,%edx
  800ced:	83 c4 20             	add    $0x20,%esp
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    
  800cf4:	85 c9                	test   %ecx,%ecx
  800cf6:	75 0b                	jne    800d03 <__umoddi3+0xe3>
  800cf8:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfd:	31 d2                	xor    %edx,%edx
  800cff:	f7 f1                	div    %ecx
  800d01:	89 c1                	mov    %eax,%ecx
  800d03:	89 f0                	mov    %esi,%eax
  800d05:	31 d2                	xor    %edx,%edx
  800d07:	f7 f1                	div    %ecx
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	e9 3e ff ff ff       	jmp    800c4e <__umoddi3+0x2e>
  800d10:	89 f2                	mov    %esi,%edx
  800d12:	83 c4 20             	add    $0x20,%esp
  800d15:	5e                   	pop    %esi
  800d16:	5f                   	pop    %edi
  800d17:	5d                   	pop    %ebp
  800d18:	c3                   	ret    
  800d19:	8d 76 00             	lea    0x0(%esi),%esi
  800d1c:	39 f5                	cmp    %esi,%ebp
  800d1e:	72 04                	jb     800d24 <__umoddi3+0x104>
  800d20:	39 f9                	cmp    %edi,%ecx
  800d22:	77 06                	ja     800d2a <__umoddi3+0x10a>
  800d24:	89 f2                	mov    %esi,%edx
  800d26:	29 cf                	sub    %ecx,%edi
  800d28:	19 ea                	sbb    %ebp,%edx
  800d2a:	89 f8                	mov    %edi,%eax
  800d2c:	83 c4 20             	add    $0x20,%esp
  800d2f:	5e                   	pop    %esi
  800d30:	5f                   	pop    %edi
  800d31:	5d                   	pop    %ebp
  800d32:	c3                   	ret    
  800d33:	90                   	nop
  800d34:	89 d1                	mov    %edx,%ecx
  800d36:	89 c5                	mov    %eax,%ebp
  800d38:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  800d3c:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  800d40:	eb 8d                	jmp    800ccf <__umoddi3+0xaf>
  800d42:	66 90                	xchg   %ax,%ax
  800d44:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  800d48:	72 ea                	jb     800d34 <__umoddi3+0x114>
  800d4a:	89 f1                	mov    %esi,%ecx
  800d4c:	eb 81                	jmp    800ccf <__umoddi3+0xaf>
