
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 17 02 00 00       	call   800248 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800042:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800049:	00 
  80004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004e:	89 34 24             	mov    %esi,(%esp)
  800051:	e8 17 0d 00 00       	call   800d6d <sys_page_alloc>
  800056:	85 c0                	test   %eax,%eax
  800058:	79 20                	jns    80007a <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  80005a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005e:	c7 44 24 08 00 21 80 	movl   $0x802100,0x8(%esp)
  800065:	00 
  800066:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006d:	00 
  80006e:	c7 04 24 13 21 80 00 	movl   $0x802113,(%esp)
  800075:	e8 3e 02 00 00       	call   8002b8 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80007a:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800081:	00 
  800082:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800089:	00 
  80008a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800091:	00 
  800092:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800096:	89 34 24             	mov    %esi,(%esp)
  800099:	e8 23 0d 00 00       	call   800dc1 <sys_page_map>
  80009e:	85 c0                	test   %eax,%eax
  8000a0:	79 20                	jns    8000c2 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a6:	c7 44 24 08 23 21 80 	movl   $0x802123,0x8(%esp)
  8000ad:	00 
  8000ae:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b5:	00 
  8000b6:	c7 04 24 13 21 80 00 	movl   $0x802113,(%esp)
  8000bd:	e8 f6 01 00 00       	call   8002b8 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c9:	00 
  8000ca:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000ce:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d5:	e8 1a 0a 00 00       	call   800af4 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000da:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e1:	00 
  8000e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e9:	e8 26 0d 00 00       	call   800e14 <sys_page_unmap>
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	79 20                	jns    800112 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 34 21 80 	movl   $0x802134,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 13 21 80 00 	movl   $0x802113,(%esp)
  80010d:	e8 a6 01 00 00       	call   8002b8 <_panic>
}
  800112:	83 c4 20             	add    $0x20,%esp
  800115:	5b                   	pop    %ebx
  800116:	5e                   	pop    %esi
  800117:	5d                   	pop    %ebp
  800118:	c3                   	ret    

00800119 <dumbfork>:

envid_t
dumbfork(void)
{
  800119:	55                   	push   %ebp
  80011a:	89 e5                	mov    %esp,%ebp
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
  80011e:	83 ec 20             	sub    $0x20,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800121:	be 07 00 00 00       	mov    $0x7,%esi
  800126:	89 f0                	mov    %esi,%eax
  800128:	cd 30                	int    $0x30
  80012a:	89 c6                	mov    %eax,%esi
  80012c:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012e:	85 c0                	test   %eax,%eax
  800130:	79 20                	jns    800152 <dumbfork+0x39>
		panic("sys_exofork: %e", envid);
  800132:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800136:	c7 44 24 08 47 21 80 	movl   $0x802147,0x8(%esp)
  80013d:	00 
  80013e:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800145:	00 
  800146:	c7 04 24 13 21 80 00 	movl   $0x802113,(%esp)
  80014d:	e8 66 01 00 00       	call   8002b8 <_panic>
	if (envid == 0) {
  800152:	85 c0                	test   %eax,%eax
  800154:	75 22                	jne    800178 <dumbfork+0x5f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800156:	e8 d4 0b 00 00       	call   800d2f <sys_getenvid>
  80015b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800160:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800167:	c1 e0 07             	shl    $0x7,%eax
  80016a:	29 d0                	sub    %edx,%eax
  80016c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800171:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800176:	eb 6e                	jmp    8001e6 <dumbfork+0xcd>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800178:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  80017f:	eb 13                	jmp    800194 <dumbfork+0x7b>
		duppage(envid, addr);
  800181:	89 44 24 04          	mov    %eax,0x4(%esp)
  800185:	89 1c 24             	mov    %ebx,(%esp)
  800188:	e8 a7 fe ff ff       	call   800034 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80018d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800197:	3d 00 60 80 00       	cmp    $0x806000,%eax
  80019c:	72 e3                	jb     800181 <dumbfork+0x68>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80019e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001aa:	89 34 24             	mov    %esi,(%esp)
  8001ad:	e8 82 fe ff ff       	call   800034 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001b9:	00 
  8001ba:	89 34 24             	mov    %esi,(%esp)
  8001bd:	e8 a5 0c 00 00       	call   800e67 <sys_env_set_status>
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	79 20                	jns    8001e6 <dumbfork+0xcd>
		panic("sys_env_set_status: %e", r);
  8001c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001ca:	c7 44 24 08 57 21 80 	movl   $0x802157,0x8(%esp)
  8001d1:	00 
  8001d2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001d9:	00 
  8001da:	c7 04 24 13 21 80 00 	movl   $0x802113,(%esp)
  8001e1:	e8 d2 00 00 00       	call   8002b8 <_panic>

	return envid;
}
  8001e6:	89 f0                	mov    %esi,%eax
  8001e8:	83 c4 20             	add    $0x20,%esp
  8001eb:	5b                   	pop    %ebx
  8001ec:	5e                   	pop    %esi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	56                   	push   %esi
  8001f3:	53                   	push   %ebx
  8001f4:	83 ec 10             	sub    $0x10,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001f7:	e8 1d ff ff ff       	call   800119 <dumbfork>
  8001fc:	89 c3                	mov    %eax,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001fe:	be 00 00 00 00       	mov    $0x0,%esi
  800203:	eb 2a                	jmp    80022f <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800205:	85 db                	test   %ebx,%ebx
  800207:	74 07                	je     800210 <umain+0x21>
  800209:	b8 6e 21 80 00       	mov    $0x80216e,%eax
  80020e:	eb 05                	jmp    800215 <umain+0x26>
  800210:	b8 75 21 80 00       	mov    $0x802175,%eax
  800215:	89 44 24 08          	mov    %eax,0x8(%esp)
  800219:	89 74 24 04          	mov    %esi,0x4(%esp)
  80021d:	c7 04 24 7b 21 80 00 	movl   $0x80217b,(%esp)
  800224:	e8 87 01 00 00       	call   8003b0 <cprintf>
		sys_yield();
  800229:	e8 20 0b 00 00       	call   800d4e <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80022e:	46                   	inc    %esi
  80022f:	83 fb 01             	cmp    $0x1,%ebx
  800232:	19 c0                	sbb    %eax,%eax
  800234:	83 e0 0a             	and    $0xa,%eax
  800237:	83 c0 0a             	add    $0xa,%eax
  80023a:	39 c6                	cmp    %eax,%esi
  80023c:	7c c7                	jl     800205 <umain+0x16>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  80023e:	83 c4 10             	add    $0x10,%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5d                   	pop    %ebp
  800244:	c3                   	ret    
  800245:	00 00                	add    %al,(%eax)
	...

00800248 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	56                   	push   %esi
  80024c:	53                   	push   %ebx
  80024d:	83 ec 10             	sub    $0x10,%esp
  800250:	8b 75 08             	mov    0x8(%ebp),%esi
  800253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800256:	e8 d4 0a 00 00       	call   800d2f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80025b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800260:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  800267:	c1 e0 07             	shl    $0x7,%eax
  80026a:	29 d0                	sub    %edx,%eax
  80026c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800271:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800276:	85 f6                	test   %esi,%esi
  800278:	7e 07                	jle    800281 <libmain+0x39>
		binaryname = argv[0];
  80027a:	8b 03                	mov    (%ebx),%eax
  80027c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800281:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800285:	89 34 24             	mov    %esi,(%esp)
  800288:	e8 62 ff ff ff       	call   8001ef <umain>

	// exit gracefully
	exit();
  80028d:	e8 0a 00 00 00       	call   80029c <exit>
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5d                   	pop    %ebp
  800298:	c3                   	ret    
  800299:	00 00                	add    %al,(%eax)
	...

0080029c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8002a2:	e8 18 0f 00 00       	call   8011bf <close_all>
	sys_env_destroy(0);
  8002a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002ae:	e8 2a 0a 00 00       	call   800cdd <sys_env_destroy>
}
  8002b3:	c9                   	leave  
  8002b4:	c3                   	ret    
  8002b5:	00 00                	add    %al,(%eax)
	...

008002b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8002c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c3:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8002c9:	e8 61 0a 00 00       	call   800d2f <sys_getenvid>
  8002ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e4:	c7 04 24 98 21 80 00 	movl   $0x802198,(%esp)
  8002eb:	e8 c0 00 00 00       	call   8003b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f7:	89 04 24             	mov    %eax,(%esp)
  8002fa:	e8 50 00 00 00       	call   80034f <vcprintf>
	cprintf("\n");
  8002ff:	c7 04 24 8b 21 80 00 	movl   $0x80218b,(%esp)
  800306:	e8 a5 00 00 00       	call   8003b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030b:	cc                   	int3   
  80030c:	eb fd                	jmp    80030b <_panic+0x53>
	...

00800310 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800310:	55                   	push   %ebp
  800311:	89 e5                	mov    %esp,%ebp
  800313:	53                   	push   %ebx
  800314:	83 ec 14             	sub    $0x14,%esp
  800317:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031a:	8b 03                	mov    (%ebx),%eax
  80031c:	8b 55 08             	mov    0x8(%ebp),%edx
  80031f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800323:	40                   	inc    %eax
  800324:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800326:	3d ff 00 00 00       	cmp    $0xff,%eax
  80032b:	75 19                	jne    800346 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80032d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800334:	00 
  800335:	8d 43 08             	lea    0x8(%ebx),%eax
  800338:	89 04 24             	mov    %eax,(%esp)
  80033b:	e8 60 09 00 00       	call   800ca0 <sys_cputs>
		b->idx = 0;
  800340:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800346:	ff 43 04             	incl   0x4(%ebx)
}
  800349:	83 c4 14             	add    $0x14,%esp
  80034c:	5b                   	pop    %ebx
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800358:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80035f:	00 00 00 
	b.cnt = 0;
  800362:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800369:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80036c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80036f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800373:	8b 45 08             	mov    0x8(%ebp),%eax
  800376:	89 44 24 08          	mov    %eax,0x8(%esp)
  80037a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800380:	89 44 24 04          	mov    %eax,0x4(%esp)
  800384:	c7 04 24 10 03 80 00 	movl   $0x800310,(%esp)
  80038b:	e8 82 01 00 00       	call   800512 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800390:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800396:	89 44 24 04          	mov    %eax,0x4(%esp)
  80039a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003a0:	89 04 24             	mov    %eax,(%esp)
  8003a3:	e8 f8 08 00 00       	call   800ca0 <sys_cputs>

	return b.cnt;
}
  8003a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003ae:	c9                   	leave  
  8003af:	c3                   	ret    

008003b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	89 04 24             	mov    %eax,(%esp)
  8003c3:	e8 87 ff ff ff       	call   80034f <vcprintf>
	va_end(ap);

	return cnt;
}
  8003c8:	c9                   	leave  
  8003c9:	c3                   	ret    
	...

008003cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
  8003cf:	57                   	push   %edi
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	83 ec 3c             	sub    $0x3c,%esp
  8003d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003d8:	89 d7                	mov    %edx,%edi
  8003da:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8003e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	75 08                	jne    8003f8 <printnum+0x2c>
  8003f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8003f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8003f6:	77 57                	ja     80044f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8003fc:	4b                   	dec    %ebx
  8003fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800401:	8b 45 10             	mov    0x10(%ebp),%eax
  800404:	89 44 24 08          	mov    %eax,0x8(%esp)
  800408:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80040c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  800410:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800417:	00 
  800418:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80041b:	89 04 24             	mov    %eax,(%esp)
  80041e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800421:	89 44 24 04          	mov    %eax,0x4(%esp)
  800425:	e8 82 1a 00 00       	call   801eac <__udivdi3>
  80042a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80042e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800432:	89 04 24             	mov    %eax,(%esp)
  800435:	89 54 24 04          	mov    %edx,0x4(%esp)
  800439:	89 fa                	mov    %edi,%edx
  80043b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80043e:	e8 89 ff ff ff       	call   8003cc <printnum>
  800443:	eb 0f                	jmp    800454 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800445:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800449:	89 34 24             	mov    %esi,(%esp)
  80044c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80044f:	4b                   	dec    %ebx
  800450:	85 db                	test   %ebx,%ebx
  800452:	7f f1                	jg     800445 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800454:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800458:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80045c:	8b 45 10             	mov    0x10(%ebp),%eax
  80045f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800463:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80046a:	00 
  80046b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80046e:	89 04 24             	mov    %eax,(%esp)
  800471:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800474:	89 44 24 04          	mov    %eax,0x4(%esp)
  800478:	e8 4f 1b 00 00       	call   801fcc <__umoddi3>
  80047d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800481:	0f be 80 bb 21 80 00 	movsbl 0x8021bb(%eax),%eax
  800488:	89 04 24             	mov    %eax,(%esp)
  80048b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80048e:	83 c4 3c             	add    $0x3c,%esp
  800491:	5b                   	pop    %ebx
  800492:	5e                   	pop    %esi
  800493:	5f                   	pop    %edi
  800494:	5d                   	pop    %ebp
  800495:	c3                   	ret    

00800496 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800499:	83 fa 01             	cmp    $0x1,%edx
  80049c:	7e 0e                	jle    8004ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80049e:	8b 10                	mov    (%eax),%edx
  8004a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004a3:	89 08                	mov    %ecx,(%eax)
  8004a5:	8b 02                	mov    (%edx),%eax
  8004a7:	8b 52 04             	mov    0x4(%edx),%edx
  8004aa:	eb 22                	jmp    8004ce <getuint+0x38>
	else if (lflag)
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	74 10                	je     8004c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b0:	8b 10                	mov    (%eax),%edx
  8004b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004b5:	89 08                	mov    %ecx,(%eax)
  8004b7:	8b 02                	mov    (%edx),%eax
  8004b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004be:	eb 0e                	jmp    8004ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c0:	8b 10                	mov    (%eax),%edx
  8004c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 02                	mov    (%edx),%eax
  8004c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8004d9:	8b 10                	mov    (%eax),%edx
  8004db:	3b 50 04             	cmp    0x4(%eax),%edx
  8004de:	73 08                	jae    8004e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8004e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8004e3:	88 0a                	mov    %cl,(%edx)
  8004e5:	42                   	inc    %edx
  8004e6:	89 10                	mov    %edx,(%eax)
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8004fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	8b 45 08             	mov    0x8(%ebp),%eax
  800508:	89 04 24             	mov    %eax,(%esp)
  80050b:	e8 02 00 00 00       	call   800512 <vprintfmt>
	va_end(ap);
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	57                   	push   %edi
  800516:	56                   	push   %esi
  800517:	53                   	push   %ebx
  800518:	83 ec 4c             	sub    $0x4c,%esp
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051e:	8b 75 10             	mov    0x10(%ebp),%esi
  800521:	eb 12                	jmp    800535 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800523:	85 c0                	test   %eax,%eax
  800525:	0f 84 8b 03 00 00    	je     8008b6 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80052b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80052f:	89 04 24             	mov    %eax,(%esp)
  800532:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800535:	0f b6 06             	movzbl (%esi),%eax
  800538:	46                   	inc    %esi
  800539:	83 f8 25             	cmp    $0x25,%eax
  80053c:	75 e5                	jne    800523 <vprintfmt+0x11>
  80053e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  800542:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  800549:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80054e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800555:	b9 00 00 00 00       	mov    $0x0,%ecx
  80055a:	eb 26                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80055f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  800563:	eb 1d                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800565:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800568:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80056c:	eb 14                	jmp    800582 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  800571:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800578:	eb 08                	jmp    800582 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80057a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80057d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800582:	0f b6 06             	movzbl (%esi),%eax
  800585:	8d 56 01             	lea    0x1(%esi),%edx
  800588:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058b:	8a 16                	mov    (%esi),%dl
  80058d:	83 ea 23             	sub    $0x23,%edx
  800590:	80 fa 55             	cmp    $0x55,%dl
  800593:	0f 87 01 03 00 00    	ja     80089a <vprintfmt+0x388>
  800599:	0f b6 d2             	movzbl %dl,%edx
  80059c:	ff 24 95 00 23 80 00 	jmp    *0x802300(,%edx,4)
  8005a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8005ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8005b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8005b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8005b8:	83 fa 09             	cmp    $0x9,%edx
  8005bb:	77 2a                	ja     8005e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005be:	eb eb                	jmp    8005ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 50 04             	lea    0x4(%eax),%edx
  8005c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005ce:	eb 17                	jmp    8005e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8005d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005d4:	78 98                	js     80056e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005d9:	eb a7                	jmp    800582 <vprintfmt+0x70>
  8005db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8005e5:	eb 9b                	jmp    800582 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8005e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005eb:	79 95                	jns    800582 <vprintfmt+0x70>
  8005ed:	eb 8b                	jmp    80057a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005f3:	eb 8d                	jmp    800582 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8d 50 04             	lea    0x4(%eax),%edx
  8005fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	89 04 24             	mov    %eax,(%esp)
  800607:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060d:	e9 23 ff ff ff       	jmp    800535 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800612:	8b 45 14             	mov    0x14(%ebp),%eax
  800615:	8d 50 04             	lea    0x4(%eax),%edx
  800618:	89 55 14             	mov    %edx,0x14(%ebp)
  80061b:	8b 00                	mov    (%eax),%eax
  80061d:	85 c0                	test   %eax,%eax
  80061f:	79 02                	jns    800623 <vprintfmt+0x111>
  800621:	f7 d8                	neg    %eax
  800623:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800625:	83 f8 0f             	cmp    $0xf,%eax
  800628:	7f 0b                	jg     800635 <vprintfmt+0x123>
  80062a:	8b 04 85 60 24 80 00 	mov    0x802460(,%eax,4),%eax
  800631:	85 c0                	test   %eax,%eax
  800633:	75 23                	jne    800658 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  800635:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800639:	c7 44 24 08 d3 21 80 	movl   $0x8021d3,0x8(%esp)
  800640:	00 
  800641:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	e8 9a fe ff ff       	call   8004ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800650:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800653:	e9 dd fe ff ff       	jmp    800535 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  800658:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80065c:	c7 44 24 08 be 25 80 	movl   $0x8025be,0x8(%esp)
  800663:	00 
  800664:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800668:	8b 55 08             	mov    0x8(%ebp),%edx
  80066b:	89 14 24             	mov    %edx,(%esp)
  80066e:	e8 77 fe ff ff       	call   8004ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800676:	e9 ba fe ff ff       	jmp    800535 <vprintfmt+0x23>
  80067b:	89 f9                	mov    %edi,%ecx
  80067d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800680:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 30                	mov    (%eax),%esi
  80068e:	85 f6                	test   %esi,%esi
  800690:	75 05                	jne    800697 <vprintfmt+0x185>
				p = "(null)";
  800692:	be cc 21 80 00       	mov    $0x8021cc,%esi
			if (width > 0 && padc != '-')
  800697:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80069b:	0f 8e 84 00 00 00    	jle    800725 <vprintfmt+0x213>
  8006a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8006a5:	74 7e                	je     800725 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8006ab:	89 34 24             	mov    %esi,(%esp)
  8006ae:	e8 ab 02 00 00       	call   80095e <strnlen>
  8006b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8006b6:	29 c2                	sub    %eax,%edx
  8006b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8006bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8006bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8006c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8006c5:	89 de                	mov    %ebx,%esi
  8006c7:	89 d3                	mov    %edx,%ebx
  8006c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cb:	eb 0b                	jmp    8006d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8006cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d1:	89 3c 24             	mov    %edi,(%esp)
  8006d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d7:	4b                   	dec    %ebx
  8006d8:	85 db                	test   %ebx,%ebx
  8006da:	7f f1                	jg     8006cd <vprintfmt+0x1bb>
  8006dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8006df:	89 f3                	mov    %esi,%ebx
  8006e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8006e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006e7:	85 c0                	test   %eax,%eax
  8006e9:	79 05                	jns    8006f0 <vprintfmt+0x1de>
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8006f8:	eb 2b                	jmp    800725 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006fe:	74 18                	je     800718 <vprintfmt+0x206>
  800700:	8d 50 e0             	lea    -0x20(%eax),%edx
  800703:	83 fa 5e             	cmp    $0x5e,%edx
  800706:	76 10                	jbe    800718 <vprintfmt+0x206>
					putch('?', putdat);
  800708:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80070c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800713:	ff 55 08             	call   *0x8(%ebp)
  800716:	eb 0a                	jmp    800722 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  800718:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80071c:	89 04 24             	mov    %eax,(%esp)
  80071f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800722:	ff 4d e4             	decl   -0x1c(%ebp)
  800725:	0f be 06             	movsbl (%esi),%eax
  800728:	46                   	inc    %esi
  800729:	85 c0                	test   %eax,%eax
  80072b:	74 21                	je     80074e <vprintfmt+0x23c>
  80072d:	85 ff                	test   %edi,%edi
  80072f:	78 c9                	js     8006fa <vprintfmt+0x1e8>
  800731:	4f                   	dec    %edi
  800732:	79 c6                	jns    8006fa <vprintfmt+0x1e8>
  800734:	8b 7d 08             	mov    0x8(%ebp),%edi
  800737:	89 de                	mov    %ebx,%esi
  800739:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80073c:	eb 18                	jmp    800756 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800742:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800749:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80074b:	4b                   	dec    %ebx
  80074c:	eb 08                	jmp    800756 <vprintfmt+0x244>
  80074e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800751:	89 de                	mov    %ebx,%esi
  800753:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800756:	85 db                	test   %ebx,%ebx
  800758:	7f e4                	jg     80073e <vprintfmt+0x22c>
  80075a:	89 7d 08             	mov    %edi,0x8(%ebp)
  80075d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800762:	e9 ce fd ff ff       	jmp    800535 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800767:	83 f9 01             	cmp    $0x1,%ecx
  80076a:	7e 10                	jle    80077c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 50 08             	lea    0x8(%eax),%edx
  800772:	89 55 14             	mov    %edx,0x14(%ebp)
  800775:	8b 30                	mov    (%eax),%esi
  800777:	8b 78 04             	mov    0x4(%eax),%edi
  80077a:	eb 26                	jmp    8007a2 <vprintfmt+0x290>
	else if (lflag)
  80077c:	85 c9                	test   %ecx,%ecx
  80077e:	74 12                	je     800792 <vprintfmt+0x280>
		return va_arg(*ap, long);
  800780:	8b 45 14             	mov    0x14(%ebp),%eax
  800783:	8d 50 04             	lea    0x4(%eax),%edx
  800786:	89 55 14             	mov    %edx,0x14(%ebp)
  800789:	8b 30                	mov    (%eax),%esi
  80078b:	89 f7                	mov    %esi,%edi
  80078d:	c1 ff 1f             	sar    $0x1f,%edi
  800790:	eb 10                	jmp    8007a2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8d 50 04             	lea    0x4(%eax),%edx
  800798:	89 55 14             	mov    %edx,0x14(%ebp)
  80079b:	8b 30                	mov    (%eax),%esi
  80079d:	89 f7                	mov    %esi,%edi
  80079f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007a2:	85 ff                	test   %edi,%edi
  8007a4:	78 0a                	js     8007b0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ab:	e9 ac 00 00 00       	jmp    80085c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  8007b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007b4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8007bb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8007be:	f7 de                	neg    %esi
  8007c0:	83 d7 00             	adc    $0x0,%edi
  8007c3:	f7 df                	neg    %edi
			}
			base = 10;
  8007c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007ca:	e9 8d 00 00 00       	jmp    80085c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007cf:	89 ca                	mov    %ecx,%edx
  8007d1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007d4:	e8 bd fc ff ff       	call   800496 <getuint>
  8007d9:	89 c6                	mov    %eax,%esi
  8007db:	89 d7                	mov    %edx,%edi
			base = 10;
  8007dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8007e2:	eb 78                	jmp    80085c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8007e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007ef:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8007f2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007fd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  800800:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800804:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  80080b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80080e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800811:	e9 1f fd ff ff       	jmp    800535 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  800816:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80081a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800821:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  800824:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800828:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80082f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800832:	8b 45 14             	mov    0x14(%ebp),%eax
  800835:	8d 50 04             	lea    0x4(%eax),%edx
  800838:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80083b:	8b 30                	mov    (%eax),%esi
  80083d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800842:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800847:	eb 13                	jmp    80085c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800849:	89 ca                	mov    %ecx,%edx
  80084b:	8d 45 14             	lea    0x14(%ebp),%eax
  80084e:	e8 43 fc ff ff       	call   800496 <getuint>
  800853:	89 c6                	mov    %eax,%esi
  800855:	89 d7                	mov    %edx,%edi
			base = 16;
  800857:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80085c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  800860:	89 54 24 10          	mov    %edx,0x10(%esp)
  800864:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800867:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80086b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80086f:	89 34 24             	mov    %esi,(%esp)
  800872:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800876:	89 da                	mov    %ebx,%edx
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	e8 4c fb ff ff       	call   8003cc <printnum>
			break;
  800880:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800883:	e9 ad fc ff ff       	jmp    800535 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800888:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80088c:	89 04 24             	mov    %eax,(%esp)
  80088f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800892:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800895:	e9 9b fc ff ff       	jmp    800535 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80089a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80089e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8008a5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008a8:	eb 01                	jmp    8008ab <vprintfmt+0x399>
  8008aa:	4e                   	dec    %esi
  8008ab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  8008af:	75 f9                	jne    8008aa <vprintfmt+0x398>
  8008b1:	e9 7f fc ff ff       	jmp    800535 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  8008b6:	83 c4 4c             	add    $0x4c,%esp
  8008b9:	5b                   	pop    %ebx
  8008ba:	5e                   	pop    %esi
  8008bb:	5f                   	pop    %edi
  8008bc:	5d                   	pop    %ebp
  8008bd:	c3                   	ret    

008008be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 28             	sub    $0x28,%esp
  8008c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008cd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008d1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008d4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008db:	85 c0                	test   %eax,%eax
  8008dd:	74 30                	je     80090f <vsnprintf+0x51>
  8008df:	85 d2                	test   %edx,%edx
  8008e1:	7e 33                	jle    800916 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f8:	c7 04 24 d0 04 80 00 	movl   $0x8004d0,(%esp)
  8008ff:	e8 0e fc ff ff       	call   800512 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800904:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800907:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80090a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80090d:	eb 0c                	jmp    80091b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80090f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800914:	eb 05                	jmp    80091b <vsnprintf+0x5d>
  800916:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80091b:	c9                   	leave  
  80091c:	c3                   	ret    

0080091d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800923:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800926:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80092a:	8b 45 10             	mov    0x10(%ebp),%eax
  80092d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	89 44 24 04          	mov    %eax,0x4(%esp)
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	89 04 24             	mov    %eax,(%esp)
  80093e:	e8 7b ff ff ff       	call   8008be <vsnprintf>
	va_end(ap);

	return rc;
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    
  800945:	00 00                	add    %al,(%eax)
	...

00800948 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094e:	b8 00 00 00 00       	mov    $0x0,%eax
  800953:	eb 01                	jmp    800956 <strlen+0xe>
		n++;
  800955:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800956:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095a:	75 f9                	jne    800955 <strlen+0xd>
		n++;
	return n;
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  800964:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800967:	b8 00 00 00 00       	mov    $0x0,%eax
  80096c:	eb 01                	jmp    80096f <strnlen+0x11>
		n++;
  80096e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80096f:	39 d0                	cmp    %edx,%eax
  800971:	74 06                	je     800979 <strnlen+0x1b>
  800973:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800977:	75 f5                	jne    80096e <strnlen+0x10>
		n++;
	return n;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	8b 45 08             	mov    0x8(%ebp),%eax
  800982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  80098d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800990:	42                   	inc    %edx
  800991:	84 c9                	test   %cl,%cl
  800993:	75 f5                	jne    80098a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	53                   	push   %ebx
  80099c:	83 ec 08             	sub    $0x8,%esp
  80099f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a2:	89 1c 24             	mov    %ebx,(%esp)
  8009a5:	e8 9e ff ff ff       	call   800948 <strlen>
	strcpy(dst + len, src);
  8009aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8009b1:	01 d8                	add    %ebx,%eax
  8009b3:	89 04 24             	mov    %eax,(%esp)
  8009b6:	e8 c0 ff ff ff       	call   80097b <strcpy>
	return dst;
}
  8009bb:	89 d8                	mov    %ebx,%eax
  8009bd:	83 c4 08             	add    $0x8,%esp
  8009c0:	5b                   	pop    %ebx
  8009c1:	5d                   	pop    %ebp
  8009c2:	c3                   	ret    

008009c3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8009d6:	eb 0c                	jmp    8009e4 <strncpy+0x21>
		*dst++ = *src;
  8009d8:	8a 1a                	mov    (%edx),%bl
  8009da:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009dd:	80 3a 01             	cmpb   $0x1,(%edx)
  8009e0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e3:	41                   	inc    %ecx
  8009e4:	39 f1                	cmp    %esi,%ecx
  8009e6:	75 f0                	jne    8009d8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e8:	5b                   	pop    %ebx
  8009e9:	5e                   	pop    %esi
  8009ea:	5d                   	pop    %ebp
  8009eb:	c3                   	ret    

008009ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ec:	55                   	push   %ebp
  8009ed:	89 e5                	mov    %esp,%ebp
  8009ef:	56                   	push   %esi
  8009f0:	53                   	push   %ebx
  8009f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009fa:	85 d2                	test   %edx,%edx
  8009fc:	75 0a                	jne    800a08 <strlcpy+0x1c>
  8009fe:	89 f0                	mov    %esi,%eax
  800a00:	eb 1a                	jmp    800a1c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a02:	88 18                	mov    %bl,(%eax)
  800a04:	40                   	inc    %eax
  800a05:	41                   	inc    %ecx
  800a06:	eb 02                	jmp    800a0a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a08:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  800a0a:	4a                   	dec    %edx
  800a0b:	74 0a                	je     800a17 <strlcpy+0x2b>
  800a0d:	8a 19                	mov    (%ecx),%bl
  800a0f:	84 db                	test   %bl,%bl
  800a11:	75 ef                	jne    800a02 <strlcpy+0x16>
  800a13:	89 c2                	mov    %eax,%edx
  800a15:	eb 02                	jmp    800a19 <strlcpy+0x2d>
  800a17:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  800a19:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  800a1c:	29 f0                	sub    %esi,%eax
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a28:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a2b:	eb 02                	jmp    800a2f <strcmp+0xd>
		p++, q++;
  800a2d:	41                   	inc    %ecx
  800a2e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2f:	8a 01                	mov    (%ecx),%al
  800a31:	84 c0                	test   %al,%al
  800a33:	74 04                	je     800a39 <strcmp+0x17>
  800a35:	3a 02                	cmp    (%edx),%al
  800a37:	74 f4                	je     800a2d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a39:	0f b6 c0             	movzbl %al,%eax
  800a3c:	0f b6 12             	movzbl (%edx),%edx
  800a3f:	29 d0                	sub    %edx,%eax
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	53                   	push   %ebx
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  800a50:	eb 03                	jmp    800a55 <strncmp+0x12>
		n--, p++, q++;
  800a52:	4a                   	dec    %edx
  800a53:	40                   	inc    %eax
  800a54:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a55:	85 d2                	test   %edx,%edx
  800a57:	74 14                	je     800a6d <strncmp+0x2a>
  800a59:	8a 18                	mov    (%eax),%bl
  800a5b:	84 db                	test   %bl,%bl
  800a5d:	74 04                	je     800a63 <strncmp+0x20>
  800a5f:	3a 19                	cmp    (%ecx),%bl
  800a61:	74 ef                	je     800a52 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a63:	0f b6 00             	movzbl (%eax),%eax
  800a66:	0f b6 11             	movzbl (%ecx),%edx
  800a69:	29 d0                	sub    %edx,%eax
  800a6b:	eb 05                	jmp    800a72 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a6d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a72:	5b                   	pop    %ebx
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a7e:	eb 05                	jmp    800a85 <strchr+0x10>
		if (*s == c)
  800a80:	38 ca                	cmp    %cl,%dl
  800a82:	74 0c                	je     800a90 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a84:	40                   	inc    %eax
  800a85:	8a 10                	mov    (%eax),%dl
  800a87:	84 d2                	test   %dl,%dl
  800a89:	75 f5                	jne    800a80 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a90:	5d                   	pop    %ebp
  800a91:	c3                   	ret    

00800a92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  800a9b:	eb 05                	jmp    800aa2 <strfind+0x10>
		if (*s == c)
  800a9d:	38 ca                	cmp    %cl,%dl
  800a9f:	74 07                	je     800aa8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aa1:	40                   	inc    %eax
  800aa2:	8a 10                	mov    (%eax),%dl
  800aa4:	84 d2                	test   %dl,%dl
  800aa6:	75 f5                	jne    800a9d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
  800ab0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ab3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab9:	85 c9                	test   %ecx,%ecx
  800abb:	74 30                	je     800aed <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac3:	75 25                	jne    800aea <memset+0x40>
  800ac5:	f6 c1 03             	test   $0x3,%cl
  800ac8:	75 20                	jne    800aea <memset+0x40>
		c &= 0xFF;
  800aca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800acd:	89 d3                	mov    %edx,%ebx
  800acf:	c1 e3 08             	shl    $0x8,%ebx
  800ad2:	89 d6                	mov    %edx,%esi
  800ad4:	c1 e6 18             	shl    $0x18,%esi
  800ad7:	89 d0                	mov    %edx,%eax
  800ad9:	c1 e0 10             	shl    $0x10,%eax
  800adc:	09 f0                	or     %esi,%eax
  800ade:	09 d0                	or     %edx,%eax
  800ae0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ae5:	fc                   	cld    
  800ae6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ae8:	eb 03                	jmp    800aed <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aea:	fc                   	cld    
  800aeb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aed:	89 f8                	mov    %edi,%eax
  800aef:	5b                   	pop    %ebx
  800af0:	5e                   	pop    %esi
  800af1:	5f                   	pop    %edi
  800af2:	5d                   	pop    %ebp
  800af3:	c3                   	ret    

00800af4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b02:	39 c6                	cmp    %eax,%esi
  800b04:	73 34                	jae    800b3a <memmove+0x46>
  800b06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b09:	39 d0                	cmp    %edx,%eax
  800b0b:	73 2d                	jae    800b3a <memmove+0x46>
		s += n;
		d += n;
  800b0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b10:	f6 c2 03             	test   $0x3,%dl
  800b13:	75 1b                	jne    800b30 <memmove+0x3c>
  800b15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b1b:	75 13                	jne    800b30 <memmove+0x3c>
  800b1d:	f6 c1 03             	test   $0x3,%cl
  800b20:	75 0e                	jne    800b30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b22:	83 ef 04             	sub    $0x4,%edi
  800b25:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b28:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b2b:	fd                   	std    
  800b2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b2e:	eb 07                	jmp    800b37 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b30:	4f                   	dec    %edi
  800b31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b34:	fd                   	std    
  800b35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b37:	fc                   	cld    
  800b38:	eb 20                	jmp    800b5a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b40:	75 13                	jne    800b55 <memmove+0x61>
  800b42:	a8 03                	test   $0x3,%al
  800b44:	75 0f                	jne    800b55 <memmove+0x61>
  800b46:	f6 c1 03             	test   $0x3,%cl
  800b49:	75 0a                	jne    800b55 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b4b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b4e:	89 c7                	mov    %eax,%edi
  800b50:	fc                   	cld    
  800b51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b53:	eb 05                	jmp    800b5a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b55:	89 c7                	mov    %eax,%edi
  800b57:	fc                   	cld    
  800b58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b5a:	5e                   	pop    %esi
  800b5b:	5f                   	pop    %edi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b64:	8b 45 10             	mov    0x10(%ebp),%eax
  800b67:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	89 04 24             	mov    %eax,(%esp)
  800b78:	e8 77 ff ff ff       	call   800af4 <memmove>
}
  800b7d:	c9                   	leave  
  800b7e:	c3                   	ret    

00800b7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
  800b85:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	eb 16                	jmp    800bab <memcmp+0x2c>
		if (*s1 != *s2)
  800b95:	8a 04 17             	mov    (%edi,%edx,1),%al
  800b98:	42                   	inc    %edx
  800b99:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  800b9d:	38 c8                	cmp    %cl,%al
  800b9f:	74 0a                	je     800bab <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  800ba1:	0f b6 c0             	movzbl %al,%eax
  800ba4:	0f b6 c9             	movzbl %cl,%ecx
  800ba7:	29 c8                	sub    %ecx,%eax
  800ba9:	eb 09                	jmp    800bb4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bab:	39 da                	cmp    %ebx,%edx
  800bad:	75 e6                	jne    800b95 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bc2:	89 c2                	mov    %eax,%edx
  800bc4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc7:	eb 05                	jmp    800bce <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc9:	38 08                	cmp    %cl,(%eax)
  800bcb:	74 05                	je     800bd2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bcd:	40                   	inc    %eax
  800bce:	39 d0                	cmp    %edx,%eax
  800bd0:	72 f7                	jb     800bc9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	57                   	push   %edi
  800bd8:	56                   	push   %esi
  800bd9:	53                   	push   %ebx
  800bda:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be0:	eb 01                	jmp    800be3 <strtol+0xf>
		s++;
  800be2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be3:	8a 02                	mov    (%edx),%al
  800be5:	3c 20                	cmp    $0x20,%al
  800be7:	74 f9                	je     800be2 <strtol+0xe>
  800be9:	3c 09                	cmp    $0x9,%al
  800beb:	74 f5                	je     800be2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bed:	3c 2b                	cmp    $0x2b,%al
  800bef:	75 08                	jne    800bf9 <strtol+0x25>
		s++;
  800bf1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bf2:	bf 00 00 00 00       	mov    $0x0,%edi
  800bf7:	eb 13                	jmp    800c0c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bf9:	3c 2d                	cmp    $0x2d,%al
  800bfb:	75 0a                	jne    800c07 <strtol+0x33>
		s++, neg = 1;
  800bfd:	8d 52 01             	lea    0x1(%edx),%edx
  800c00:	bf 01 00 00 00       	mov    $0x1,%edi
  800c05:	eb 05                	jmp    800c0c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0c:	85 db                	test   %ebx,%ebx
  800c0e:	74 05                	je     800c15 <strtol+0x41>
  800c10:	83 fb 10             	cmp    $0x10,%ebx
  800c13:	75 28                	jne    800c3d <strtol+0x69>
  800c15:	8a 02                	mov    (%edx),%al
  800c17:	3c 30                	cmp    $0x30,%al
  800c19:	75 10                	jne    800c2b <strtol+0x57>
  800c1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c1f:	75 0a                	jne    800c2b <strtol+0x57>
		s += 2, base = 16;
  800c21:	83 c2 02             	add    $0x2,%edx
  800c24:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c29:	eb 12                	jmp    800c3d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  800c2b:	85 db                	test   %ebx,%ebx
  800c2d:	75 0e                	jne    800c3d <strtol+0x69>
  800c2f:	3c 30                	cmp    $0x30,%al
  800c31:	75 05                	jne    800c38 <strtol+0x64>
		s++, base = 8;
  800c33:	42                   	inc    %edx
  800c34:	b3 08                	mov    $0x8,%bl
  800c36:	eb 05                	jmp    800c3d <strtol+0x69>
	else if (base == 0)
		base = 10;
  800c38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c42:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c44:	8a 0a                	mov    (%edx),%cl
  800c46:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c49:	80 fb 09             	cmp    $0x9,%bl
  800c4c:	77 08                	ja     800c56 <strtol+0x82>
			dig = *s - '0';
  800c4e:	0f be c9             	movsbl %cl,%ecx
  800c51:	83 e9 30             	sub    $0x30,%ecx
  800c54:	eb 1e                	jmp    800c74 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  800c56:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  800c59:	80 fb 19             	cmp    $0x19,%bl
  800c5c:	77 08                	ja     800c66 <strtol+0x92>
			dig = *s - 'a' + 10;
  800c5e:	0f be c9             	movsbl %cl,%ecx
  800c61:	83 e9 57             	sub    $0x57,%ecx
  800c64:	eb 0e                	jmp    800c74 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  800c66:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  800c69:	80 fb 19             	cmp    $0x19,%bl
  800c6c:	77 12                	ja     800c80 <strtol+0xac>
			dig = *s - 'A' + 10;
  800c6e:	0f be c9             	movsbl %cl,%ecx
  800c71:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c74:	39 f1                	cmp    %esi,%ecx
  800c76:	7d 0c                	jge    800c84 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  800c78:	42                   	inc    %edx
  800c79:	0f af c6             	imul   %esi,%eax
  800c7c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  800c7e:	eb c4                	jmp    800c44 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  800c80:	89 c1                	mov    %eax,%ecx
  800c82:	eb 02                	jmp    800c86 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c84:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  800c86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c8a:	74 05                	je     800c91 <strtol+0xbd>
		*endptr = (char *) s;
  800c8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c8f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c91:	85 ff                	test   %edi,%edi
  800c93:	74 04                	je     800c99 <strtol+0xc5>
  800c95:	89 c8                	mov    %ecx,%eax
  800c97:	f7 d8                	neg    %eax
}
  800c99:	5b                   	pop    %ebx
  800c9a:	5e                   	pop    %esi
  800c9b:	5f                   	pop    %edi
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    
	...

00800ca0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ca0:	55                   	push   %ebp
  800ca1:	89 e5                	mov    %esp,%ebp
  800ca3:	57                   	push   %edi
  800ca4:	56                   	push   %esi
  800ca5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	89 c7                	mov    %eax,%edi
  800cb5:	89 c6                	mov    %eax,%esi
  800cb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_cgetc>:

int
sys_cgetc(void)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cce:	89 d1                	mov    %edx,%ecx
  800cd0:	89 d3                	mov    %edx,%ebx
  800cd2:	89 d7                	mov    %edx,%edi
  800cd4:	89 d6                	mov    %edx,%esi
  800cd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ceb:	b8 03 00 00 00       	mov    $0x3,%eax
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	89 cb                	mov    %ecx,%ebx
  800cf5:	89 cf                	mov    %ecx,%edi
  800cf7:	89 ce                	mov    %ecx,%esi
  800cf9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 28                	jle    800d27 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d03:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800d0a:	00 
  800d0b:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800d12:	00 
  800d13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d1a:	00 
  800d1b:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800d22:	e8 91 f5 ff ff       	call   8002b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d27:	83 c4 2c             	add    $0x2c,%esp
  800d2a:	5b                   	pop    %ebx
  800d2b:	5e                   	pop    %esi
  800d2c:	5f                   	pop    %edi
  800d2d:	5d                   	pop    %ebp
  800d2e:	c3                   	ret    

00800d2f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	57                   	push   %edi
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d35:	ba 00 00 00 00       	mov    $0x0,%edx
  800d3a:	b8 02 00 00 00       	mov    $0x2,%eax
  800d3f:	89 d1                	mov    %edx,%ecx
  800d41:	89 d3                	mov    %edx,%ebx
  800d43:	89 d7                	mov    %edx,%edi
  800d45:	89 d6                	mov    %edx,%esi
  800d47:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d49:	5b                   	pop    %ebx
  800d4a:	5e                   	pop    %esi
  800d4b:	5f                   	pop    %edi
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_yield>:

void
sys_yield(void)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	57                   	push   %edi
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	ba 00 00 00 00       	mov    $0x0,%edx
  800d59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5e:	89 d1                	mov    %edx,%ecx
  800d60:	89 d3                	mov    %edx,%ebx
  800d62:	89 d7                	mov    %edx,%edi
  800d64:	89 d6                	mov    %edx,%esi
  800d66:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d68:	5b                   	pop    %ebx
  800d69:	5e                   	pop    %esi
  800d6a:	5f                   	pop    %edi
  800d6b:	5d                   	pop    %ebp
  800d6c:	c3                   	ret    

00800d6d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	57                   	push   %edi
  800d71:	56                   	push   %esi
  800d72:	53                   	push   %ebx
  800d73:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d76:	be 00 00 00 00       	mov    $0x0,%esi
  800d7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800d80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 f7                	mov    %esi,%edi
  800d8b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	7e 28                	jle    800db9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800da4:	00 
  800da5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dac:	00 
  800dad:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800db4:	e8 ff f4 ff ff       	call   8002b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800db9:	83 c4 2c             	add    $0x2c,%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	b8 05 00 00 00       	mov    $0x5,%eax
  800dcf:	8b 75 18             	mov    0x18(%ebp),%esi
  800dd2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dd5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 28                	jle    800e0c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	89 44 24 10          	mov    %eax,0x10(%esp)
  800de8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800def:	00 
  800df0:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800df7:	00 
  800df8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dff:	00 
  800e00:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800e07:	e8 ac f4 ff ff       	call   8002b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e0c:	83 c4 2c             	add    $0x2c,%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5f                   	pop    %edi
  800e12:	5d                   	pop    %ebp
  800e13:	c3                   	ret    

00800e14 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	57                   	push   %edi
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e22:	b8 06 00 00 00       	mov    $0x6,%eax
  800e27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2d:	89 df                	mov    %ebx,%edi
  800e2f:	89 de                	mov    %ebx,%esi
  800e31:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e33:	85 c0                	test   %eax,%eax
  800e35:	7e 28                	jle    800e5f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e42:	00 
  800e43:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800e5a:	e8 59 f4 ff ff       	call   8002b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e5f:	83 c4 2c             	add    $0x2c,%esp
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e75:	b8 08 00 00 00       	mov    $0x8,%eax
  800e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	89 df                	mov    %ebx,%edi
  800e82:	89 de                	mov    %ebx,%esi
  800e84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7e 28                	jle    800eb2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e95:	00 
  800e96:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800e9d:	00 
  800e9e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea5:	00 
  800ea6:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800ead:	e8 06 f4 ff ff       	call   8002b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800eb2:	83 c4 2c             	add    $0x2c,%esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5f                   	pop    %edi
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	57                   	push   %edi
  800ebe:	56                   	push   %esi
  800ebf:	53                   	push   %ebx
  800ec0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec8:	b8 09 00 00 00       	mov    $0x9,%eax
  800ecd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed3:	89 df                	mov    %ebx,%edi
  800ed5:	89 de                	mov    %ebx,%esi
  800ed7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	7e 28                	jle    800f05 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ee1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800ee8:	00 
  800ee9:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800ef0:	00 
  800ef1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef8:	00 
  800ef9:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800f00:	e8 b3 f3 ff ff       	call   8002b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f05:	83 c4 2c             	add    $0x2c,%esp
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
  800f13:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	89 df                	mov    %ebx,%edi
  800f28:	89 de                	mov    %ebx,%esi
  800f2a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	7e 28                	jle    800f58 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f30:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f34:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  800f3b:	00 
  800f3c:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800f43:	00 
  800f44:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f4b:	00 
  800f4c:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800f53:	e8 60 f3 ff ff       	call   8002b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f58:	83 c4 2c             	add    $0x2c,%esp
  800f5b:	5b                   	pop    %ebx
  800f5c:	5e                   	pop    %esi
  800f5d:	5f                   	pop    %edi
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	57                   	push   %edi
  800f64:	56                   	push   %esi
  800f65:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f66:	be 00 00 00 00       	mov    $0x0,%esi
  800f6b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	57                   	push   %edi
  800f87:	56                   	push   %esi
  800f88:	53                   	push   %ebx
  800f89:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f91:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f96:	8b 55 08             	mov    0x8(%ebp),%edx
  800f99:	89 cb                	mov    %ecx,%ebx
  800f9b:	89 cf                	mov    %ecx,%edi
  800f9d:	89 ce                	mov    %ecx,%esi
  800f9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fa1:	85 c0                	test   %eax,%eax
  800fa3:	7e 28                	jle    800fcd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fa5:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 08 bf 24 80 	movl   $0x8024bf,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc0:	00 
  800fc1:	c7 04 24 dc 24 80 00 	movl   $0x8024dc,(%esp)
  800fc8:	e8 eb f2 ff ff       	call   8002b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fcd:	83 c4 2c             	add    $0x2c,%esp
  800fd0:	5b                   	pop    %ebx
  800fd1:	5e                   	pop    %esi
  800fd2:	5f                   	pop    %edi
  800fd3:	5d                   	pop    %ebp
  800fd4:	c3                   	ret    
  800fd5:	00 00                	add    %al,(%eax)
	...

00800fd8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fdb:	8b 45 08             	mov    0x8(%ebp),%eax
  800fde:	05 00 00 00 30       	add    $0x30000000,%eax
  800fe3:	c1 e8 0c             	shr    $0xc,%eax
}
  800fe6:	5d                   	pop    %ebp
  800fe7:	c3                   	ret    

00800fe8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800fe8:	55                   	push   %ebp
  800fe9:	89 e5                	mov    %esp,%ebp
  800feb:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800fee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff1:	89 04 24             	mov    %eax,(%esp)
  800ff4:	e8 df ff ff ff       	call   800fd8 <fd2num>
  800ff9:	05 20 00 0d 00       	add    $0xd0020,%eax
  800ffe:	c1 e0 0c             	shl    $0xc,%eax
}
  801001:	c9                   	leave  
  801002:	c3                   	ret    

00801003 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	53                   	push   %ebx
  801007:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80100a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  80100f:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801011:	89 c2                	mov    %eax,%edx
  801013:	c1 ea 16             	shr    $0x16,%edx
  801016:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80101d:	f6 c2 01             	test   $0x1,%dl
  801020:	74 11                	je     801033 <fd_alloc+0x30>
  801022:	89 c2                	mov    %eax,%edx
  801024:	c1 ea 0c             	shr    $0xc,%edx
  801027:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80102e:	f6 c2 01             	test   $0x1,%dl
  801031:	75 09                	jne    80103c <fd_alloc+0x39>
			*fd_store = fd;
  801033:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
  80103a:	eb 17                	jmp    801053 <fd_alloc+0x50>
  80103c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801041:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801046:	75 c7                	jne    80100f <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801048:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80104e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801053:	5b                   	pop    %ebx
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80105c:	83 f8 1f             	cmp    $0x1f,%eax
  80105f:	77 36                	ja     801097 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801061:	05 00 00 0d 00       	add    $0xd0000,%eax
  801066:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801069:	89 c2                	mov    %eax,%edx
  80106b:	c1 ea 16             	shr    $0x16,%edx
  80106e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801075:	f6 c2 01             	test   $0x1,%dl
  801078:	74 24                	je     80109e <fd_lookup+0x48>
  80107a:	89 c2                	mov    %eax,%edx
  80107c:	c1 ea 0c             	shr    $0xc,%edx
  80107f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801086:	f6 c2 01             	test   $0x1,%dl
  801089:	74 1a                	je     8010a5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80108b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108e:	89 02                	mov    %eax,(%edx)
	return 0;
  801090:	b8 00 00 00 00       	mov    $0x0,%eax
  801095:	eb 13                	jmp    8010aa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801097:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80109c:	eb 0c                	jmp    8010aa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80109e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010a3:	eb 05                	jmp    8010aa <fd_lookup+0x54>
  8010a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	53                   	push   %ebx
  8010b0:	83 ec 14             	sub    $0x14,%esp
  8010b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  8010b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010be:	eb 0e                	jmp    8010ce <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  8010c0:	39 08                	cmp    %ecx,(%eax)
  8010c2:	75 09                	jne    8010cd <dev_lookup+0x21>
			*dev = devtab[i];
  8010c4:	89 03                	mov    %eax,(%ebx)
			return 0;
  8010c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8010cb:	eb 33                	jmp    801100 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8010cd:	42                   	inc    %edx
  8010ce:	8b 04 95 6c 25 80 00 	mov    0x80256c(,%edx,4),%eax
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	75 e7                	jne    8010c0 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010d9:	a1 04 40 80 00       	mov    0x804004,%eax
  8010de:	8b 40 48             	mov    0x48(%eax),%eax
  8010e1:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e9:	c7 04 24 ec 24 80 00 	movl   $0x8024ec,(%esp)
  8010f0:	e8 bb f2 ff ff       	call   8003b0 <cprintf>
	*dev = 0;
  8010f5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8010fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801100:	83 c4 14             	add    $0x14,%esp
  801103:	5b                   	pop    %ebx
  801104:	5d                   	pop    %ebp
  801105:	c3                   	ret    

00801106 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801106:	55                   	push   %ebp
  801107:	89 e5                	mov    %esp,%ebp
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 30             	sub    $0x30,%esp
  80110e:	8b 75 08             	mov    0x8(%ebp),%esi
  801111:	8a 45 0c             	mov    0xc(%ebp),%al
  801114:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801117:	89 34 24             	mov    %esi,(%esp)
  80111a:	e8 b9 fe ff ff       	call   800fd8 <fd2num>
  80111f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801122:	89 54 24 04          	mov    %edx,0x4(%esp)
  801126:	89 04 24             	mov    %eax,(%esp)
  801129:	e8 28 ff ff ff       	call   801056 <fd_lookup>
  80112e:	89 c3                	mov    %eax,%ebx
  801130:	85 c0                	test   %eax,%eax
  801132:	78 05                	js     801139 <fd_close+0x33>
	    || fd != fd2)
  801134:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801137:	74 0d                	je     801146 <fd_close+0x40>
		return (must_exist ? r : 0);
  801139:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  80113d:	75 46                	jne    801185 <fd_close+0x7f>
  80113f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801144:	eb 3f                	jmp    801185 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801146:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801149:	89 44 24 04          	mov    %eax,0x4(%esp)
  80114d:	8b 06                	mov    (%esi),%eax
  80114f:	89 04 24             	mov    %eax,(%esp)
  801152:	e8 55 ff ff ff       	call   8010ac <dev_lookup>
  801157:	89 c3                	mov    %eax,%ebx
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 18                	js     801175 <fd_close+0x6f>
		if (dev->dev_close)
  80115d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801160:	8b 40 10             	mov    0x10(%eax),%eax
  801163:	85 c0                	test   %eax,%eax
  801165:	74 09                	je     801170 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801167:	89 34 24             	mov    %esi,(%esp)
  80116a:	ff d0                	call   *%eax
  80116c:	89 c3                	mov    %eax,%ebx
  80116e:	eb 05                	jmp    801175 <fd_close+0x6f>
		else
			r = 0;
  801170:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801175:	89 74 24 04          	mov    %esi,0x4(%esp)
  801179:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801180:	e8 8f fc ff ff       	call   800e14 <sys_page_unmap>
	return r;
}
  801185:	89 d8                	mov    %ebx,%eax
  801187:	83 c4 30             	add    $0x30,%esp
  80118a:	5b                   	pop    %ebx
  80118b:	5e                   	pop    %esi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    

0080118e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80118e:	55                   	push   %ebp
  80118f:	89 e5                	mov    %esp,%ebp
  801191:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801194:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801197:	89 44 24 04          	mov    %eax,0x4(%esp)
  80119b:	8b 45 08             	mov    0x8(%ebp),%eax
  80119e:	89 04 24             	mov    %eax,(%esp)
  8011a1:	e8 b0 fe ff ff       	call   801056 <fd_lookup>
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	78 13                	js     8011bd <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8011aa:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8011b1:	00 
  8011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b5:	89 04 24             	mov    %eax,(%esp)
  8011b8:	e8 49 ff ff ff       	call   801106 <fd_close>
}
  8011bd:	c9                   	leave  
  8011be:	c3                   	ret    

008011bf <close_all>:

void
close_all(void)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	53                   	push   %ebx
  8011c3:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011cb:	89 1c 24             	mov    %ebx,(%esp)
  8011ce:	e8 bb ff ff ff       	call   80118e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8011d3:	43                   	inc    %ebx
  8011d4:	83 fb 20             	cmp    $0x20,%ebx
  8011d7:	75 f2                	jne    8011cb <close_all+0xc>
		close(i);
}
  8011d9:	83 c4 14             	add    $0x14,%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	57                   	push   %edi
  8011e3:	56                   	push   %esi
  8011e4:	53                   	push   %ebx
  8011e5:	83 ec 4c             	sub    $0x4c,%esp
  8011e8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8011eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f5:	89 04 24             	mov    %eax,(%esp)
  8011f8:	e8 59 fe ff ff       	call   801056 <fd_lookup>
  8011fd:	89 c3                	mov    %eax,%ebx
  8011ff:	85 c0                	test   %eax,%eax
  801201:	0f 88 e1 00 00 00    	js     8012e8 <dup+0x109>
		return r;
	close(newfdnum);
  801207:	89 3c 24             	mov    %edi,(%esp)
  80120a:	e8 7f ff ff ff       	call   80118e <close>

	newfd = INDEX2FD(newfdnum);
  80120f:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801215:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801218:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80121b:	89 04 24             	mov    %eax,(%esp)
  80121e:	e8 c5 fd ff ff       	call   800fe8 <fd2data>
  801223:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801225:	89 34 24             	mov    %esi,(%esp)
  801228:	e8 bb fd ff ff       	call   800fe8 <fd2data>
  80122d:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801230:	89 d8                	mov    %ebx,%eax
  801232:	c1 e8 16             	shr    $0x16,%eax
  801235:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80123c:	a8 01                	test   $0x1,%al
  80123e:	74 46                	je     801286 <dup+0xa7>
  801240:	89 d8                	mov    %ebx,%eax
  801242:	c1 e8 0c             	shr    $0xc,%eax
  801245:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80124c:	f6 c2 01             	test   $0x1,%dl
  80124f:	74 35                	je     801286 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801251:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801258:	25 07 0e 00 00       	and    $0xe07,%eax
  80125d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801261:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801264:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801268:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80126f:	00 
  801270:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801274:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80127b:	e8 41 fb ff ff       	call   800dc1 <sys_page_map>
  801280:	89 c3                	mov    %eax,%ebx
  801282:	85 c0                	test   %eax,%eax
  801284:	78 3b                	js     8012c1 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801286:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801289:	89 c2                	mov    %eax,%edx
  80128b:	c1 ea 0c             	shr    $0xc,%edx
  80128e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801295:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80129b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80129f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8012a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012aa:	00 
  8012ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012b6:	e8 06 fb ff ff       	call   800dc1 <sys_page_map>
  8012bb:	89 c3                	mov    %eax,%ebx
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	79 25                	jns    8012e6 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012c1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8012c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012cc:	e8 43 fb ff ff       	call   800e14 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012d1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012df:	e8 30 fb ff ff       	call   800e14 <sys_page_unmap>
	return r;
  8012e4:	eb 02                	jmp    8012e8 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8012e6:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012e8:	89 d8                	mov    %ebx,%eax
  8012ea:	83 c4 4c             	add    $0x4c,%esp
  8012ed:	5b                   	pop    %ebx
  8012ee:	5e                   	pop    %esi
  8012ef:	5f                   	pop    %edi
  8012f0:	5d                   	pop    %ebp
  8012f1:	c3                   	ret    

008012f2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
  8012f5:	53                   	push   %ebx
  8012f6:	83 ec 24             	sub    $0x24,%esp
  8012f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  801303:	89 1c 24             	mov    %ebx,(%esp)
  801306:	e8 4b fd ff ff       	call   801056 <fd_lookup>
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 6d                	js     80137c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80130f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801312:	89 44 24 04          	mov    %eax,0x4(%esp)
  801316:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801319:	8b 00                	mov    (%eax),%eax
  80131b:	89 04 24             	mov    %eax,(%esp)
  80131e:	e8 89 fd ff ff       	call   8010ac <dev_lookup>
  801323:	85 c0                	test   %eax,%eax
  801325:	78 55                	js     80137c <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132a:	8b 50 08             	mov    0x8(%eax),%edx
  80132d:	83 e2 03             	and    $0x3,%edx
  801330:	83 fa 01             	cmp    $0x1,%edx
  801333:	75 23                	jne    801358 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801335:	a1 04 40 80 00       	mov    0x804004,%eax
  80133a:	8b 40 48             	mov    0x48(%eax),%eax
  80133d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801341:	89 44 24 04          	mov    %eax,0x4(%esp)
  801345:	c7 04 24 30 25 80 00 	movl   $0x802530,(%esp)
  80134c:	e8 5f f0 ff ff       	call   8003b0 <cprintf>
		return -E_INVAL;
  801351:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801356:	eb 24                	jmp    80137c <read+0x8a>
	}
	if (!dev->dev_read)
  801358:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80135b:	8b 52 08             	mov    0x8(%edx),%edx
  80135e:	85 d2                	test   %edx,%edx
  801360:	74 15                	je     801377 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801362:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801365:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801369:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80136c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801370:	89 04 24             	mov    %eax,(%esp)
  801373:	ff d2                	call   *%edx
  801375:	eb 05                	jmp    80137c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801377:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  80137c:	83 c4 24             	add    $0x24,%esp
  80137f:	5b                   	pop    %ebx
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	57                   	push   %edi
  801386:	56                   	push   %esi
  801387:	53                   	push   %ebx
  801388:	83 ec 1c             	sub    $0x1c,%esp
  80138b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801391:	bb 00 00 00 00       	mov    $0x0,%ebx
  801396:	eb 23                	jmp    8013bb <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801398:	89 f0                	mov    %esi,%eax
  80139a:	29 d8                	sub    %ebx,%eax
  80139c:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a3:	01 d8                	add    %ebx,%eax
  8013a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a9:	89 3c 24             	mov    %edi,(%esp)
  8013ac:	e8 41 ff ff ff       	call   8012f2 <read>
		if (m < 0)
  8013b1:	85 c0                	test   %eax,%eax
  8013b3:	78 10                	js     8013c5 <readn+0x43>
			return m;
		if (m == 0)
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	74 0a                	je     8013c3 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b9:	01 c3                	add    %eax,%ebx
  8013bb:	39 f3                	cmp    %esi,%ebx
  8013bd:	72 d9                	jb     801398 <readn+0x16>
  8013bf:	89 d8                	mov    %ebx,%eax
  8013c1:	eb 02                	jmp    8013c5 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  8013c3:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8013c5:	83 c4 1c             	add    $0x1c,%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 24             	sub    $0x24,%esp
  8013d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013de:	89 1c 24             	mov    %ebx,(%esp)
  8013e1:	e8 70 fc ff ff       	call   801056 <fd_lookup>
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 68                	js     801452 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f4:	8b 00                	mov    (%eax),%eax
  8013f6:	89 04 24             	mov    %eax,(%esp)
  8013f9:	e8 ae fc ff ff       	call   8010ac <dev_lookup>
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 50                	js     801452 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801402:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801405:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801409:	75 23                	jne    80142e <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80140b:	a1 04 40 80 00       	mov    0x804004,%eax
  801410:	8b 40 48             	mov    0x48(%eax),%eax
  801413:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801417:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141b:	c7 04 24 4c 25 80 00 	movl   $0x80254c,(%esp)
  801422:	e8 89 ef ff ff       	call   8003b0 <cprintf>
		return -E_INVAL;
  801427:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142c:	eb 24                	jmp    801452 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80142e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801431:	8b 52 0c             	mov    0xc(%edx),%edx
  801434:	85 d2                	test   %edx,%edx
  801436:	74 15                	je     80144d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801438:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80143b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80143f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801442:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801446:	89 04 24             	mov    %eax,(%esp)
  801449:	ff d2                	call   *%edx
  80144b:	eb 05                	jmp    801452 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80144d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  801452:	83 c4 24             	add    $0x24,%esp
  801455:	5b                   	pop    %ebx
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <seek>:

int
seek(int fdnum, off_t offset)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801461:	89 44 24 04          	mov    %eax,0x4(%esp)
  801465:	8b 45 08             	mov    0x8(%ebp),%eax
  801468:	89 04 24             	mov    %eax,(%esp)
  80146b:	e8 e6 fb ff ff       	call   801056 <fd_lookup>
  801470:	85 c0                	test   %eax,%eax
  801472:	78 0e                	js     801482 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801474:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801477:	8b 55 0c             	mov    0xc(%ebp),%edx
  80147a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80147d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801482:	c9                   	leave  
  801483:	c3                   	ret    

00801484 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	53                   	push   %ebx
  801488:	83 ec 24             	sub    $0x24,%esp
  80148b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80148e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801491:	89 44 24 04          	mov    %eax,0x4(%esp)
  801495:	89 1c 24             	mov    %ebx,(%esp)
  801498:	e8 b9 fb ff ff       	call   801056 <fd_lookup>
  80149d:	85 c0                	test   %eax,%eax
  80149f:	78 61                	js     801502 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ab:	8b 00                	mov    (%eax),%eax
  8014ad:	89 04 24             	mov    %eax,(%esp)
  8014b0:	e8 f7 fb ff ff       	call   8010ac <dev_lookup>
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 49                	js     801502 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014bc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c0:	75 23                	jne    8014e5 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014c2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014c7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d2:	c7 04 24 0c 25 80 00 	movl   $0x80250c,(%esp)
  8014d9:	e8 d2 ee ff ff       	call   8003b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e3:	eb 1d                	jmp    801502 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8014e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014e8:	8b 52 18             	mov    0x18(%edx),%edx
  8014eb:	85 d2                	test   %edx,%edx
  8014ed:	74 0e                	je     8014fd <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8014f6:	89 04 24             	mov    %eax,(%esp)
  8014f9:	ff d2                	call   *%edx
  8014fb:	eb 05                	jmp    801502 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8014fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  801502:	83 c4 24             	add    $0x24,%esp
  801505:	5b                   	pop    %ebx
  801506:	5d                   	pop    %ebp
  801507:	c3                   	ret    

00801508 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801508:	55                   	push   %ebp
  801509:	89 e5                	mov    %esp,%ebp
  80150b:	53                   	push   %ebx
  80150c:	83 ec 24             	sub    $0x24,%esp
  80150f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801512:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801515:	89 44 24 04          	mov    %eax,0x4(%esp)
  801519:	8b 45 08             	mov    0x8(%ebp),%eax
  80151c:	89 04 24             	mov    %eax,(%esp)
  80151f:	e8 32 fb ff ff       	call   801056 <fd_lookup>
  801524:	85 c0                	test   %eax,%eax
  801526:	78 52                	js     80157a <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801528:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80152f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801532:	8b 00                	mov    (%eax),%eax
  801534:	89 04 24             	mov    %eax,(%esp)
  801537:	e8 70 fb ff ff       	call   8010ac <dev_lookup>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 3a                	js     80157a <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  801540:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801543:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801547:	74 2c                	je     801575 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801549:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80154c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801553:	00 00 00 
	stat->st_isdir = 0;
  801556:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80155d:	00 00 00 
	stat->st_dev = dev;
  801560:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801566:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80156a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80156d:	89 14 24             	mov    %edx,(%esp)
  801570:	ff 50 14             	call   *0x14(%eax)
  801573:	eb 05                	jmp    80157a <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801575:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80157a:	83 c4 24             	add    $0x24,%esp
  80157d:	5b                   	pop    %ebx
  80157e:	5d                   	pop    %ebp
  80157f:	c3                   	ret    

00801580 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	56                   	push   %esi
  801584:	53                   	push   %ebx
  801585:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801588:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80158f:	00 
  801590:	8b 45 08             	mov    0x8(%ebp),%eax
  801593:	89 04 24             	mov    %eax,(%esp)
  801596:	e8 fe 01 00 00       	call   801799 <open>
  80159b:	89 c3                	mov    %eax,%ebx
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 1b                	js     8015bc <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  8015a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a8:	89 1c 24             	mov    %ebx,(%esp)
  8015ab:	e8 58 ff ff ff       	call   801508 <fstat>
  8015b0:	89 c6                	mov    %eax,%esi
	close(fd);
  8015b2:	89 1c 24             	mov    %ebx,(%esp)
  8015b5:	e8 d4 fb ff ff       	call   80118e <close>
	return r;
  8015ba:	89 f3                	mov    %esi,%ebx
}
  8015bc:	89 d8                	mov    %ebx,%eax
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	5b                   	pop    %ebx
  8015c2:	5e                   	pop    %esi
  8015c3:	5d                   	pop    %ebp
  8015c4:	c3                   	ret    
  8015c5:	00 00                	add    %al,(%eax)
	...

008015c8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015c8:	55                   	push   %ebp
  8015c9:	89 e5                	mov    %esp,%ebp
  8015cb:	56                   	push   %esi
  8015cc:	53                   	push   %ebx
  8015cd:	83 ec 10             	sub    $0x10,%esp
  8015d0:	89 c3                	mov    %eax,%ebx
  8015d2:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8015d4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015db:	75 11                	jne    8015ee <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015dd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8015e4:	e8 38 08 00 00       	call   801e21 <ipc_find_env>
  8015e9:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015ee:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8015f5:	00 
  8015f6:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8015fd:	00 
  8015fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801602:	a1 00 40 80 00       	mov    0x804000,%eax
  801607:	89 04 24             	mov    %eax,(%esp)
  80160a:	e8 a8 07 00 00       	call   801db7 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80160f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801616:	00 
  801617:	89 74 24 04          	mov    %esi,0x4(%esp)
  80161b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801622:	e8 29 07 00 00       	call   801d50 <ipc_recv>
}
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801634:	8b 45 08             	mov    0x8(%ebp),%eax
  801637:	8b 40 0c             	mov    0xc(%eax),%eax
  80163a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80163f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801642:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801647:	ba 00 00 00 00       	mov    $0x0,%edx
  80164c:	b8 02 00 00 00       	mov    $0x2,%eax
  801651:	e8 72 ff ff ff       	call   8015c8 <fsipc>
}
  801656:	c9                   	leave  
  801657:	c3                   	ret    

00801658 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80165e:	8b 45 08             	mov    0x8(%ebp),%eax
  801661:	8b 40 0c             	mov    0xc(%eax),%eax
  801664:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
  80166e:	b8 06 00 00 00       	mov    $0x6,%eax
  801673:	e8 50 ff ff ff       	call   8015c8 <fsipc>
}
  801678:	c9                   	leave  
  801679:	c3                   	ret    

0080167a <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	53                   	push   %ebx
  80167e:	83 ec 14             	sub    $0x14,%esp
  801681:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801684:	8b 45 08             	mov    0x8(%ebp),%eax
  801687:	8b 40 0c             	mov    0xc(%eax),%eax
  80168a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80168f:	ba 00 00 00 00       	mov    $0x0,%edx
  801694:	b8 05 00 00 00       	mov    $0x5,%eax
  801699:	e8 2a ff ff ff       	call   8015c8 <fsipc>
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 2b                	js     8016cd <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016a2:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8016a9:	00 
  8016aa:	89 1c 24             	mov    %ebx,(%esp)
  8016ad:	e8 c9 f2 ff ff       	call   80097b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016b2:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016bd:	a1 84 50 80 00       	mov    0x805084,%eax
  8016c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016cd:	83 c4 14             	add    $0x14,%esp
  8016d0:	5b                   	pop    %ebx
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  8016d9:	c7 44 24 08 7c 25 80 	movl   $0x80257c,0x8(%esp)
  8016e0:	00 
  8016e1:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8016e8:	00 
  8016e9:	c7 04 24 9a 25 80 00 	movl   $0x80259a,(%esp)
  8016f0:	e8 c3 eb ff ff       	call   8002b8 <_panic>

008016f5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	83 ec 10             	sub    $0x10,%esp
  8016fd:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801700:	8b 45 08             	mov    0x8(%ebp),%eax
  801703:	8b 40 0c             	mov    0xc(%eax),%eax
  801706:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80170b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
  801716:	b8 03 00 00 00       	mov    $0x3,%eax
  80171b:	e8 a8 fe ff ff       	call   8015c8 <fsipc>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	85 c0                	test   %eax,%eax
  801724:	78 6a                	js     801790 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  801726:	39 c6                	cmp    %eax,%esi
  801728:	73 24                	jae    80174e <devfile_read+0x59>
  80172a:	c7 44 24 0c a5 25 80 	movl   $0x8025a5,0xc(%esp)
  801731:	00 
  801732:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  801739:	00 
  80173a:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  801741:	00 
  801742:	c7 04 24 9a 25 80 00 	movl   $0x80259a,(%esp)
  801749:	e8 6a eb ff ff       	call   8002b8 <_panic>
	assert(r <= PGSIZE);
  80174e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801753:	7e 24                	jle    801779 <devfile_read+0x84>
  801755:	c7 44 24 0c c1 25 80 	movl   $0x8025c1,0xc(%esp)
  80175c:	00 
  80175d:	c7 44 24 08 ac 25 80 	movl   $0x8025ac,0x8(%esp)
  801764:	00 
  801765:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  80176c:	00 
  80176d:	c7 04 24 9a 25 80 00 	movl   $0x80259a,(%esp)
  801774:	e8 3f eb ff ff       	call   8002b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801779:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177d:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801784:	00 
  801785:	8b 45 0c             	mov    0xc(%ebp),%eax
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	e8 64 f3 ff ff       	call   800af4 <memmove>
	return r;
}
  801790:	89 d8                	mov    %ebx,%eax
  801792:	83 c4 10             	add    $0x10,%esp
  801795:	5b                   	pop    %ebx
  801796:	5e                   	pop    %esi
  801797:	5d                   	pop    %ebp
  801798:	c3                   	ret    

00801799 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 20             	sub    $0x20,%esp
  8017a1:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017a4:	89 34 24             	mov    %esi,(%esp)
  8017a7:	e8 9c f1 ff ff       	call   800948 <strlen>
  8017ac:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017b1:	7f 60                	jg     801813 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b6:	89 04 24             	mov    %eax,(%esp)
  8017b9:	e8 45 f8 ff ff       	call   801003 <fd_alloc>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	85 c0                	test   %eax,%eax
  8017c2:	78 54                	js     801818 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017c8:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017cf:	e8 a7 f1 ff ff       	call   80097b <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d7:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017df:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e4:	e8 df fd ff ff       	call   8015c8 <fsipc>
  8017e9:	89 c3                	mov    %eax,%ebx
  8017eb:	85 c0                	test   %eax,%eax
  8017ed:	79 15                	jns    801804 <open+0x6b>
		fd_close(fd, 0);
  8017ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8017f6:	00 
  8017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fa:	89 04 24             	mov    %eax,(%esp)
  8017fd:	e8 04 f9 ff ff       	call   801106 <fd_close>
		return r;
  801802:	eb 14                	jmp    801818 <open+0x7f>
	}

	return fd2num(fd);
  801804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801807:	89 04 24             	mov    %eax,(%esp)
  80180a:	e8 c9 f7 ff ff       	call   800fd8 <fd2num>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	eb 05                	jmp    801818 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801813:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801818:	89 d8                	mov    %ebx,%eax
  80181a:	83 c4 20             	add    $0x20,%esp
  80181d:	5b                   	pop    %ebx
  80181e:	5e                   	pop    %esi
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801821:	55                   	push   %ebp
  801822:	89 e5                	mov    %esp,%ebp
  801824:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801827:	ba 00 00 00 00       	mov    $0x0,%edx
  80182c:	b8 08 00 00 00       	mov    $0x8,%eax
  801831:	e8 92 fd ff ff       	call   8015c8 <fsipc>
}
  801836:	c9                   	leave  
  801837:	c3                   	ret    

00801838 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	56                   	push   %esi
  80183c:	53                   	push   %ebx
  80183d:	83 ec 10             	sub    $0x10,%esp
  801840:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	e8 9a f7 ff ff       	call   800fe8 <fd2data>
  80184e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  801850:	c7 44 24 04 cd 25 80 	movl   $0x8025cd,0x4(%esp)
  801857:	00 
  801858:	89 34 24             	mov    %esi,(%esp)
  80185b:	e8 1b f1 ff ff       	call   80097b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801860:	8b 43 04             	mov    0x4(%ebx),%eax
  801863:	2b 03                	sub    (%ebx),%eax
  801865:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  80186b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  801872:	00 00 00 
	stat->st_dev = &devpipe;
  801875:	c7 86 88 00 00 00 20 	movl   $0x803020,0x88(%esi)
  80187c:	30 80 00 
	return 0;
}
  80187f:	b8 00 00 00 00       	mov    $0x0,%eax
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	5b                   	pop    %ebx
  801888:	5e                   	pop    %esi
  801889:	5d                   	pop    %ebp
  80188a:	c3                   	ret    

0080188b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80188b:	55                   	push   %ebp
  80188c:	89 e5                	mov    %esp,%ebp
  80188e:	53                   	push   %ebx
  80188f:	83 ec 14             	sub    $0x14,%esp
  801892:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801895:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801899:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a0:	e8 6f f5 ff ff       	call   800e14 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018a5:	89 1c 24             	mov    %ebx,(%esp)
  8018a8:	e8 3b f7 ff ff       	call   800fe8 <fd2data>
  8018ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018b8:	e8 57 f5 ff ff       	call   800e14 <sys_page_unmap>
}
  8018bd:	83 c4 14             	add    $0x14,%esp
  8018c0:	5b                   	pop    %ebx
  8018c1:	5d                   	pop    %ebp
  8018c2:	c3                   	ret    

008018c3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018c3:	55                   	push   %ebp
  8018c4:	89 e5                	mov    %esp,%ebp
  8018c6:	57                   	push   %edi
  8018c7:	56                   	push   %esi
  8018c8:	53                   	push   %ebx
  8018c9:	83 ec 2c             	sub    $0x2c,%esp
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018d9:	89 3c 24             	mov    %edi,(%esp)
  8018dc:	e8 87 05 00 00       	call   801e68 <pageref>
  8018e1:	89 c6                	mov    %eax,%esi
  8018e3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8018e6:	89 04 24             	mov    %eax,(%esp)
  8018e9:	e8 7a 05 00 00       	call   801e68 <pageref>
  8018ee:	39 c6                	cmp    %eax,%esi
  8018f0:	0f 94 c0             	sete   %al
  8018f3:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018f6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018fc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018ff:	39 cb                	cmp    %ecx,%ebx
  801901:	75 08                	jne    80190b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  801903:	83 c4 2c             	add    $0x2c,%esp
  801906:	5b                   	pop    %ebx
  801907:	5e                   	pop    %esi
  801908:	5f                   	pop    %edi
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  80190b:	83 f8 01             	cmp    $0x1,%eax
  80190e:	75 c1                	jne    8018d1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801910:	8b 42 58             	mov    0x58(%edx),%eax
  801913:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  80191a:	00 
  80191b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80191f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801923:	c7 04 24 d4 25 80 00 	movl   $0x8025d4,(%esp)
  80192a:	e8 81 ea ff ff       	call   8003b0 <cprintf>
  80192f:	eb a0                	jmp    8018d1 <_pipeisclosed+0xe>

00801931 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	57                   	push   %edi
  801935:	56                   	push   %esi
  801936:	53                   	push   %ebx
  801937:	83 ec 1c             	sub    $0x1c,%esp
  80193a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80193d:	89 34 24             	mov    %esi,(%esp)
  801940:	e8 a3 f6 ff ff       	call   800fe8 <fd2data>
  801945:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801947:	bf 00 00 00 00       	mov    $0x0,%edi
  80194c:	eb 3c                	jmp    80198a <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80194e:	89 da                	mov    %ebx,%edx
  801950:	89 f0                	mov    %esi,%eax
  801952:	e8 6c ff ff ff       	call   8018c3 <_pipeisclosed>
  801957:	85 c0                	test   %eax,%eax
  801959:	75 38                	jne    801993 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80195b:	e8 ee f3 ff ff       	call   800d4e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801960:	8b 43 04             	mov    0x4(%ebx),%eax
  801963:	8b 13                	mov    (%ebx),%edx
  801965:	83 c2 20             	add    $0x20,%edx
  801968:	39 d0                	cmp    %edx,%eax
  80196a:	73 e2                	jae    80194e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80196c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80196f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  801972:	89 c2                	mov    %eax,%edx
  801974:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  80197a:	79 05                	jns    801981 <devpipe_write+0x50>
  80197c:	4a                   	dec    %edx
  80197d:	83 ca e0             	or     $0xffffffe0,%edx
  801980:	42                   	inc    %edx
  801981:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801985:	40                   	inc    %eax
  801986:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801989:	47                   	inc    %edi
  80198a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80198d:	75 d1                	jne    801960 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80198f:	89 f8                	mov    %edi,%eax
  801991:	eb 05                	jmp    801998 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801993:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801998:	83 c4 1c             	add    $0x1c,%esp
  80199b:	5b                   	pop    %ebx
  80199c:	5e                   	pop    %esi
  80199d:	5f                   	pop    %edi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	57                   	push   %edi
  8019a4:	56                   	push   %esi
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 1c             	sub    $0x1c,%esp
  8019a9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019ac:	89 3c 24             	mov    %edi,(%esp)
  8019af:	e8 34 f6 ff ff       	call   800fe8 <fd2data>
  8019b4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019b6:	be 00 00 00 00       	mov    $0x0,%esi
  8019bb:	eb 3a                	jmp    8019f7 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019bd:	85 f6                	test   %esi,%esi
  8019bf:	74 04                	je     8019c5 <devpipe_read+0x25>
				return i;
  8019c1:	89 f0                	mov    %esi,%eax
  8019c3:	eb 40                	jmp    801a05 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019c5:	89 da                	mov    %ebx,%edx
  8019c7:	89 f8                	mov    %edi,%eax
  8019c9:	e8 f5 fe ff ff       	call   8018c3 <_pipeisclosed>
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	75 2e                	jne    801a00 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019d2:	e8 77 f3 ff ff       	call   800d4e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019d7:	8b 03                	mov    (%ebx),%eax
  8019d9:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019dc:	74 df                	je     8019bd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019de:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8019e3:	79 05                	jns    8019ea <devpipe_read+0x4a>
  8019e5:	48                   	dec    %eax
  8019e6:	83 c8 e0             	or     $0xffffffe0,%eax
  8019e9:	40                   	inc    %eax
  8019ea:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8019ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019f1:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8019f4:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f6:	46                   	inc    %esi
  8019f7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019fa:	75 db                	jne    8019d7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019fc:	89 f0                	mov    %esi,%eax
  8019fe:	eb 05                	jmp    801a05 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a00:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a05:	83 c4 1c             	add    $0x1c,%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	57                   	push   %edi
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
  801a13:	83 ec 3c             	sub    $0x3c,%esp
  801a16:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a19:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a1c:	89 04 24             	mov    %eax,(%esp)
  801a1f:	e8 df f5 ff ff       	call   801003 <fd_alloc>
  801a24:	89 c3                	mov    %eax,%ebx
  801a26:	85 c0                	test   %eax,%eax
  801a28:	0f 88 45 01 00 00    	js     801b73 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a2e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a35:	00 
  801a36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a44:	e8 24 f3 ff ff       	call   800d6d <sys_page_alloc>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	0f 88 20 01 00 00    	js     801b73 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a53:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 a5 f5 ff ff       	call   801003 <fd_alloc>
  801a5e:	89 c3                	mov    %eax,%ebx
  801a60:	85 c0                	test   %eax,%eax
  801a62:	0f 88 f8 00 00 00    	js     801b60 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a68:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a6f:	00 
  801a70:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801a73:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a77:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a7e:	e8 ea f2 ff ff       	call   800d6d <sys_page_alloc>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	85 c0                	test   %eax,%eax
  801a87:	0f 88 d3 00 00 00    	js     801b60 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a8d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a90:	89 04 24             	mov    %eax,(%esp)
  801a93:	e8 50 f5 ff ff       	call   800fe8 <fd2data>
  801a98:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9a:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801aa1:	00 
  801aa2:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aad:	e8 bb f2 ff ff       	call   800d6d <sys_page_alloc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	0f 88 91 00 00 00    	js     801b4d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801abf:	89 04 24             	mov    %eax,(%esp)
  801ac2:	e8 21 f5 ff ff       	call   800fe8 <fd2data>
  801ac7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  801ace:	00 
  801acf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ad3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ada:	00 
  801adb:	89 74 24 04          	mov    %esi,0x4(%esp)
  801adf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ae6:	e8 d6 f2 ff ff       	call   800dc1 <sys_page_map>
  801aeb:	89 c3                	mov    %eax,%ebx
  801aed:	85 c0                	test   %eax,%eax
  801aef:	78 4c                	js     801b3d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801af1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801afa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801afc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b06:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b0f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b11:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b14:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	e8 b2 f4 ff ff       	call   800fd8 <fd2num>
  801b26:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  801b28:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b2b:	89 04 24             	mov    %eax,(%esp)
  801b2e:	e8 a5 f4 ff ff       	call   800fd8 <fd2num>
  801b33:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  801b36:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b3b:	eb 36                	jmp    801b73 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  801b3d:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b48:	e8 c7 f2 ff ff       	call   800e14 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  801b4d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b50:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b54:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b5b:	e8 b4 f2 ff ff       	call   800e14 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  801b60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b67:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b6e:	e8 a1 f2 ff ff       	call   800e14 <sys_page_unmap>
    err:
	return r;
}
  801b73:	89 d8                	mov    %ebx,%eax
  801b75:	83 c4 3c             	add    $0x3c,%esp
  801b78:	5b                   	pop    %ebx
  801b79:	5e                   	pop    %esi
  801b7a:	5f                   	pop    %edi
  801b7b:	5d                   	pop    %ebp
  801b7c:	c3                   	ret    

00801b7d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b86:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8d:	89 04 24             	mov    %eax,(%esp)
  801b90:	e8 c1 f4 ff ff       	call   801056 <fd_lookup>
  801b95:	85 c0                	test   %eax,%eax
  801b97:	78 15                	js     801bae <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9c:	89 04 24             	mov    %eax,(%esp)
  801b9f:	e8 44 f4 ff ff       	call   800fe8 <fd2data>
	return _pipeisclosed(fd, p);
  801ba4:	89 c2                	mov    %eax,%edx
  801ba6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba9:	e8 15 fd ff ff       	call   8018c3 <_pipeisclosed>
}
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    

00801bba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  801bc0:	c7 44 24 04 ec 25 80 	movl   $0x8025ec,0x4(%esp)
  801bc7:	00 
  801bc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcb:	89 04 24             	mov    %eax,(%esp)
  801bce:	e8 a8 ed ff ff       	call   80097b <strcpy>
	return 0;
}
  801bd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	57                   	push   %edi
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801beb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bf1:	eb 30                	jmp    801c23 <devcons_write+0x49>
		m = n - tot;
  801bf3:	8b 75 10             	mov    0x10(%ebp),%esi
  801bf6:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  801bf8:	83 fe 7f             	cmp    $0x7f,%esi
  801bfb:	76 05                	jbe    801c02 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  801bfd:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c02:	89 74 24 08          	mov    %esi,0x8(%esp)
  801c06:	03 45 0c             	add    0xc(%ebp),%eax
  801c09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c0d:	89 3c 24             	mov    %edi,(%esp)
  801c10:	e8 df ee ff ff       	call   800af4 <memmove>
		sys_cputs(buf, m);
  801c15:	89 74 24 04          	mov    %esi,0x4(%esp)
  801c19:	89 3c 24             	mov    %edi,(%esp)
  801c1c:	e8 7f f0 ff ff       	call   800ca0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c21:	01 f3                	add    %esi,%ebx
  801c23:	89 d8                	mov    %ebx,%eax
  801c25:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c28:	72 c9                	jb     801bf3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c2a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  801c30:	5b                   	pop    %ebx
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    

00801c35 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  801c3b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c3f:	75 07                	jne    801c48 <devcons_read+0x13>
  801c41:	eb 25                	jmp    801c68 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c43:	e8 06 f1 ff ff       	call   800d4e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c48:	e8 71 f0 ff ff       	call   800cbe <sys_cgetc>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	74 f2                	je     801c43 <devcons_read+0xe>
  801c51:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  801c53:	85 c0                	test   %eax,%eax
  801c55:	78 1d                	js     801c74 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c57:	83 f8 04             	cmp    $0x4,%eax
  801c5a:	74 13                	je     801c6f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  801c5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c5f:	88 10                	mov    %dl,(%eax)
	return 1;
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	eb 0c                	jmp    801c74 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6d:	eb 05                	jmp    801c74 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c6f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c74:	c9                   	leave  
  801c75:	c3                   	ret    

00801c76 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  801c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c82:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801c89:	00 
  801c8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c8d:	89 04 24             	mov    %eax,(%esp)
  801c90:	e8 0b f0 ff ff       	call   800ca0 <sys_cputs>
}
  801c95:	c9                   	leave  
  801c96:	c3                   	ret    

00801c97 <getchar>:

int
getchar(void)
{
  801c97:	55                   	push   %ebp
  801c98:	89 e5                	mov    %esp,%ebp
  801c9a:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c9d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  801ca4:	00 
  801ca5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cb3:	e8 3a f6 ff ff       	call   8012f2 <read>
	if (r < 0)
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	78 0f                	js     801ccb <getchar+0x34>
		return r;
	if (r < 1)
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	7e 06                	jle    801cc6 <getchar+0x2f>
		return -E_EOF;
	return c;
  801cc0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cc4:	eb 05                	jmp    801ccb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cc6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ccb:	c9                   	leave  
  801ccc:	c3                   	ret    

00801ccd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cda:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdd:	89 04 24             	mov    %eax,(%esp)
  801ce0:	e8 71 f3 ff ff       	call   801056 <fd_lookup>
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	78 11                	js     801cfa <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cf2:	39 10                	cmp    %edx,(%eax)
  801cf4:	0f 94 c0             	sete   %al
  801cf7:	0f b6 c0             	movzbl %al,%eax
}
  801cfa:	c9                   	leave  
  801cfb:	c3                   	ret    

00801cfc <opencons>:

int
opencons(void)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d05:	89 04 24             	mov    %eax,(%esp)
  801d08:	e8 f6 f2 ff ff       	call   801003 <fd_alloc>
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	78 3c                	js     801d4d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d11:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801d18:	00 
  801d19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d27:	e8 41 f0 ff ff       	call   800d6d <sys_page_alloc>
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	78 1d                	js     801d4d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d30:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d39:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d45:	89 04 24             	mov    %eax,(%esp)
  801d48:	e8 8b f2 ff ff       	call   800fd8 <fd2num>
}
  801d4d:	c9                   	leave  
  801d4e:	c3                   	ret    
	...

00801d50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	83 ec 10             	sub    $0x10,%esp
  801d58:	8b 75 08             	mov    0x8(%ebp),%esi
  801d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  801d61:	85 c0                	test   %eax,%eax
  801d63:	75 05                	jne    801d6a <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  801d65:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  801d6a:	89 04 24             	mov    %eax,(%esp)
  801d6d:	e8 11 f2 ff ff       	call   800f83 <sys_ipc_recv>
	if (!err) {
  801d72:	85 c0                	test   %eax,%eax
  801d74:	75 26                	jne    801d9c <ipc_recv+0x4c>
		if (from_env_store) {
  801d76:	85 f6                	test   %esi,%esi
  801d78:	74 0a                	je     801d84 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  801d7a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d7f:	8b 40 74             	mov    0x74(%eax),%eax
  801d82:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  801d84:	85 db                	test   %ebx,%ebx
  801d86:	74 0a                	je     801d92 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  801d88:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8d:	8b 40 78             	mov    0x78(%eax),%eax
  801d90:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  801d92:	a1 04 40 80 00       	mov    0x804004,%eax
  801d97:	8b 40 70             	mov    0x70(%eax),%eax
  801d9a:	eb 14                	jmp    801db0 <ipc_recv+0x60>
	}
	if (from_env_store) {
  801d9c:	85 f6                	test   %esi,%esi
  801d9e:	74 06                	je     801da6 <ipc_recv+0x56>
		*from_env_store = 0;
  801da0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  801da6:	85 db                	test   %ebx,%ebx
  801da8:	74 06                	je     801db0 <ipc_recv+0x60>
		*perm_store = 0;
  801daa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  801db0:	83 c4 10             	add    $0x10,%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5e                   	pop    %esi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801db7:	55                   	push   %ebp
  801db8:	89 e5                	mov    %esp,%ebp
  801dba:	57                   	push   %edi
  801dbb:	56                   	push   %esi
  801dbc:	53                   	push   %ebx
  801dbd:	83 ec 1c             	sub    $0x1c,%esp
  801dc0:	8b 75 10             	mov    0x10(%ebp),%esi
  801dc3:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  801dc6:	85 f6                	test   %esi,%esi
  801dc8:	75 05                	jne    801dcf <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  801dca:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  801dcf:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801dd3:	89 74 24 08          	mov    %esi,0x8(%esp)
  801dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dda:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dde:	8b 45 08             	mov    0x8(%ebp),%eax
  801de1:	89 04 24             	mov    %eax,(%esp)
  801de4:	e8 77 f1 ff ff       	call   800f60 <sys_ipc_try_send>
  801de9:	89 c3                	mov    %eax,%ebx
		sys_yield();
  801deb:	e8 5e ef ff ff       	call   800d4e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  801df0:	83 fb f9             	cmp    $0xfffffff9,%ebx
  801df3:	74 da                	je     801dcf <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  801df5:	85 db                	test   %ebx,%ebx
  801df7:	74 20                	je     801e19 <ipc_send+0x62>
		panic("send fail: %e", err);
  801df9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801dfd:	c7 44 24 08 f8 25 80 	movl   $0x8025f8,0x8(%esp)
  801e04:	00 
  801e05:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  801e0c:	00 
  801e0d:	c7 04 24 06 26 80 00 	movl   $0x802606,(%esp)
  801e14:	e8 9f e4 ff ff       	call   8002b8 <_panic>
	}
	return;
}
  801e19:	83 c4 1c             	add    $0x1c,%esp
  801e1c:	5b                   	pop    %ebx
  801e1d:	5e                   	pop    %esi
  801e1e:	5f                   	pop    %edi
  801e1f:	5d                   	pop    %ebp
  801e20:	c3                   	ret    

00801e21 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e21:	55                   	push   %ebp
  801e22:	89 e5                	mov    %esp,%ebp
  801e24:	53                   	push   %ebx
  801e25:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  801e28:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e2d:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  801e34:	89 c2                	mov    %eax,%edx
  801e36:	c1 e2 07             	shl    $0x7,%edx
  801e39:	29 ca                	sub    %ecx,%edx
  801e3b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e41:	8b 52 50             	mov    0x50(%edx),%edx
  801e44:	39 da                	cmp    %ebx,%edx
  801e46:	75 0f                	jne    801e57 <ipc_find_env+0x36>
			return envs[i].env_id;
  801e48:	c1 e0 07             	shl    $0x7,%eax
  801e4b:	29 c8                	sub    %ecx,%eax
  801e4d:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  801e52:	8b 40 40             	mov    0x40(%eax),%eax
  801e55:	eb 0c                	jmp    801e63 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801e57:	40                   	inc    %eax
  801e58:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e5d:	75 ce                	jne    801e2d <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801e5f:	66 b8 00 00          	mov    $0x0,%ax
}
  801e63:	5b                   	pop    %ebx
  801e64:	5d                   	pop    %ebp
  801e65:	c3                   	ret    
	...

00801e68 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	c1 ea 16             	shr    $0x16,%edx
  801e73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e7a:	f6 c2 01             	test   $0x1,%dl
  801e7d:	74 1e                	je     801e9d <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e7f:	c1 e8 0c             	shr    $0xc,%eax
  801e82:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e89:	a8 01                	test   $0x1,%al
  801e8b:	74 17                	je     801ea4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e8d:	c1 e8 0c             	shr    $0xc,%eax
  801e90:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  801e97:	ef 
  801e98:	0f b7 c0             	movzwl %ax,%eax
  801e9b:	eb 0c                	jmp    801ea9 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  801e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea2:	eb 05                	jmp    801ea9 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  801ea4:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    
	...

00801eac <__udivdi3>:
  801eac:	55                   	push   %ebp
  801ead:	57                   	push   %edi
  801eae:	56                   	push   %esi
  801eaf:	83 ec 10             	sub    $0x10,%esp
  801eb2:	8b 74 24 20          	mov    0x20(%esp),%esi
  801eb6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801eba:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ebe:	8b 7c 24 24          	mov    0x24(%esp),%edi
  801ec2:	89 cd                	mov    %ecx,%ebp
  801ec4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	75 2c                	jne    801ef8 <__udivdi3+0x4c>
  801ecc:	39 f9                	cmp    %edi,%ecx
  801ece:	77 68                	ja     801f38 <__udivdi3+0x8c>
  801ed0:	85 c9                	test   %ecx,%ecx
  801ed2:	75 0b                	jne    801edf <__udivdi3+0x33>
  801ed4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed9:	31 d2                	xor    %edx,%edx
  801edb:	f7 f1                	div    %ecx
  801edd:	89 c1                	mov    %eax,%ecx
  801edf:	31 d2                	xor    %edx,%edx
  801ee1:	89 f8                	mov    %edi,%eax
  801ee3:	f7 f1                	div    %ecx
  801ee5:	89 c7                	mov    %eax,%edi
  801ee7:	89 f0                	mov    %esi,%eax
  801ee9:	f7 f1                	div    %ecx
  801eeb:	89 c6                	mov    %eax,%esi
  801eed:	89 f0                	mov    %esi,%eax
  801eef:	89 fa                	mov    %edi,%edx
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	5e                   	pop    %esi
  801ef5:	5f                   	pop    %edi
  801ef6:	5d                   	pop    %ebp
  801ef7:	c3                   	ret    
  801ef8:	39 f8                	cmp    %edi,%eax
  801efa:	77 2c                	ja     801f28 <__udivdi3+0x7c>
  801efc:	0f bd f0             	bsr    %eax,%esi
  801eff:	83 f6 1f             	xor    $0x1f,%esi
  801f02:	75 4c                	jne    801f50 <__udivdi3+0xa4>
  801f04:	39 f8                	cmp    %edi,%eax
  801f06:	bf 00 00 00 00       	mov    $0x0,%edi
  801f0b:	72 0a                	jb     801f17 <__udivdi3+0x6b>
  801f0d:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f11:	0f 87 ad 00 00 00    	ja     801fc4 <__udivdi3+0x118>
  801f17:	be 01 00 00 00       	mov    $0x1,%esi
  801f1c:	89 f0                	mov    %esi,%eax
  801f1e:	89 fa                	mov    %edi,%edx
  801f20:	83 c4 10             	add    $0x10,%esp
  801f23:	5e                   	pop    %esi
  801f24:	5f                   	pop    %edi
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
  801f27:	90                   	nop
  801f28:	31 ff                	xor    %edi,%edi
  801f2a:	31 f6                	xor    %esi,%esi
  801f2c:	89 f0                	mov    %esi,%eax
  801f2e:	89 fa                	mov    %edi,%edx
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	5e                   	pop    %esi
  801f34:	5f                   	pop    %edi
  801f35:	5d                   	pop    %ebp
  801f36:	c3                   	ret    
  801f37:	90                   	nop
  801f38:	89 fa                	mov    %edi,%edx
  801f3a:	89 f0                	mov    %esi,%eax
  801f3c:	f7 f1                	div    %ecx
  801f3e:	89 c6                	mov    %eax,%esi
  801f40:	31 ff                	xor    %edi,%edi
  801f42:	89 f0                	mov    %esi,%eax
  801f44:	89 fa                	mov    %edi,%edx
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	5e                   	pop    %esi
  801f4a:	5f                   	pop    %edi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    
  801f4d:	8d 76 00             	lea    0x0(%esi),%esi
  801f50:	89 f1                	mov    %esi,%ecx
  801f52:	d3 e0                	shl    %cl,%eax
  801f54:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f58:	b8 20 00 00 00       	mov    $0x20,%eax
  801f5d:	29 f0                	sub    %esi,%eax
  801f5f:	89 ea                	mov    %ebp,%edx
  801f61:	88 c1                	mov    %al,%cl
  801f63:	d3 ea                	shr    %cl,%edx
  801f65:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  801f69:	09 ca                	or     %ecx,%edx
  801f6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801f6f:	89 f1                	mov    %esi,%ecx
  801f71:	d3 e5                	shl    %cl,%ebp
  801f73:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  801f77:	89 fd                	mov    %edi,%ebp
  801f79:	88 c1                	mov    %al,%cl
  801f7b:	d3 ed                	shr    %cl,%ebp
  801f7d:	89 fa                	mov    %edi,%edx
  801f7f:	89 f1                	mov    %esi,%ecx
  801f81:	d3 e2                	shl    %cl,%edx
  801f83:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801f87:	88 c1                	mov    %al,%cl
  801f89:	d3 ef                	shr    %cl,%edi
  801f8b:	09 d7                	or     %edx,%edi
  801f8d:	89 f8                	mov    %edi,%eax
  801f8f:	89 ea                	mov    %ebp,%edx
  801f91:	f7 74 24 08          	divl   0x8(%esp)
  801f95:	89 d1                	mov    %edx,%ecx
  801f97:	89 c7                	mov    %eax,%edi
  801f99:	f7 64 24 0c          	mull   0xc(%esp)
  801f9d:	39 d1                	cmp    %edx,%ecx
  801f9f:	72 17                	jb     801fb8 <__udivdi3+0x10c>
  801fa1:	74 09                	je     801fac <__udivdi3+0x100>
  801fa3:	89 fe                	mov    %edi,%esi
  801fa5:	31 ff                	xor    %edi,%edi
  801fa7:	e9 41 ff ff ff       	jmp    801eed <__udivdi3+0x41>
  801fac:	8b 54 24 04          	mov    0x4(%esp),%edx
  801fb0:	89 f1                	mov    %esi,%ecx
  801fb2:	d3 e2                	shl    %cl,%edx
  801fb4:	39 c2                	cmp    %eax,%edx
  801fb6:	73 eb                	jae    801fa3 <__udivdi3+0xf7>
  801fb8:	8d 77 ff             	lea    -0x1(%edi),%esi
  801fbb:	31 ff                	xor    %edi,%edi
  801fbd:	e9 2b ff ff ff       	jmp    801eed <__udivdi3+0x41>
  801fc2:	66 90                	xchg   %ax,%ax
  801fc4:	31 f6                	xor    %esi,%esi
  801fc6:	e9 22 ff ff ff       	jmp    801eed <__udivdi3+0x41>
	...

00801fcc <__umoddi3>:
  801fcc:	55                   	push   %ebp
  801fcd:	57                   	push   %edi
  801fce:	56                   	push   %esi
  801fcf:	83 ec 20             	sub    $0x20,%esp
  801fd2:	8b 44 24 30          	mov    0x30(%esp),%eax
  801fd6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  801fda:	89 44 24 14          	mov    %eax,0x14(%esp)
  801fde:	8b 74 24 34          	mov    0x34(%esp),%esi
  801fe2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801fe6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  801fea:	89 c7                	mov    %eax,%edi
  801fec:	89 f2                	mov    %esi,%edx
  801fee:	85 ed                	test   %ebp,%ebp
  801ff0:	75 16                	jne    802008 <__umoddi3+0x3c>
  801ff2:	39 f1                	cmp    %esi,%ecx
  801ff4:	0f 86 a6 00 00 00    	jbe    8020a0 <__umoddi3+0xd4>
  801ffa:	f7 f1                	div    %ecx
  801ffc:	89 d0                	mov    %edx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	83 c4 20             	add    $0x20,%esp
  802003:	5e                   	pop    %esi
  802004:	5f                   	pop    %edi
  802005:	5d                   	pop    %ebp
  802006:	c3                   	ret    
  802007:	90                   	nop
  802008:	39 f5                	cmp    %esi,%ebp
  80200a:	0f 87 ac 00 00 00    	ja     8020bc <__umoddi3+0xf0>
  802010:	0f bd c5             	bsr    %ebp,%eax
  802013:	83 f0 1f             	xor    $0x1f,%eax
  802016:	89 44 24 10          	mov    %eax,0x10(%esp)
  80201a:	0f 84 a8 00 00 00    	je     8020c8 <__umoddi3+0xfc>
  802020:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802024:	d3 e5                	shl    %cl,%ebp
  802026:	bf 20 00 00 00       	mov    $0x20,%edi
  80202b:	2b 7c 24 10          	sub    0x10(%esp),%edi
  80202f:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802033:	89 f9                	mov    %edi,%ecx
  802035:	d3 e8                	shr    %cl,%eax
  802037:	09 e8                	or     %ebp,%eax
  802039:	89 44 24 18          	mov    %eax,0x18(%esp)
  80203d:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802041:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802045:	d3 e0                	shl    %cl,%eax
  802047:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204b:	89 f2                	mov    %esi,%edx
  80204d:	d3 e2                	shl    %cl,%edx
  80204f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802053:	d3 e0                	shl    %cl,%eax
  802055:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  802059:	8b 44 24 14          	mov    0x14(%esp),%eax
  80205d:	89 f9                	mov    %edi,%ecx
  80205f:	d3 e8                	shr    %cl,%eax
  802061:	09 d0                	or     %edx,%eax
  802063:	d3 ee                	shr    %cl,%esi
  802065:	89 f2                	mov    %esi,%edx
  802067:	f7 74 24 18          	divl   0x18(%esp)
  80206b:	89 d6                	mov    %edx,%esi
  80206d:	f7 64 24 0c          	mull   0xc(%esp)
  802071:	89 c5                	mov    %eax,%ebp
  802073:	89 d1                	mov    %edx,%ecx
  802075:	39 d6                	cmp    %edx,%esi
  802077:	72 67                	jb     8020e0 <__umoddi3+0x114>
  802079:	74 75                	je     8020f0 <__umoddi3+0x124>
  80207b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80207f:	29 e8                	sub    %ebp,%eax
  802081:	19 ce                	sbb    %ecx,%esi
  802083:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802087:	d3 e8                	shr    %cl,%eax
  802089:	89 f2                	mov    %esi,%edx
  80208b:	89 f9                	mov    %edi,%ecx
  80208d:	d3 e2                	shl    %cl,%edx
  80208f:	09 d0                	or     %edx,%eax
  802091:	89 f2                	mov    %esi,%edx
  802093:	8a 4c 24 10          	mov    0x10(%esp),%cl
  802097:	d3 ea                	shr    %cl,%edx
  802099:	83 c4 20             	add    $0x20,%esp
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    
  8020a0:	85 c9                	test   %ecx,%ecx
  8020a2:	75 0b                	jne    8020af <__umoddi3+0xe3>
  8020a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8020a9:	31 d2                	xor    %edx,%edx
  8020ab:	f7 f1                	div    %ecx
  8020ad:	89 c1                	mov    %eax,%ecx
  8020af:	89 f0                	mov    %esi,%eax
  8020b1:	31 d2                	xor    %edx,%edx
  8020b3:	f7 f1                	div    %ecx
  8020b5:	89 f8                	mov    %edi,%eax
  8020b7:	e9 3e ff ff ff       	jmp    801ffa <__umoddi3+0x2e>
  8020bc:	89 f2                	mov    %esi,%edx
  8020be:	83 c4 20             	add    $0x20,%esp
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    
  8020c5:	8d 76 00             	lea    0x0(%esi),%esi
  8020c8:	39 f5                	cmp    %esi,%ebp
  8020ca:	72 04                	jb     8020d0 <__umoddi3+0x104>
  8020cc:	39 f9                	cmp    %edi,%ecx
  8020ce:	77 06                	ja     8020d6 <__umoddi3+0x10a>
  8020d0:	89 f2                	mov    %esi,%edx
  8020d2:	29 cf                	sub    %ecx,%edi
  8020d4:	19 ea                	sbb    %ebp,%edx
  8020d6:	89 f8                	mov    %edi,%eax
  8020d8:	83 c4 20             	add    $0x20,%esp
  8020db:	5e                   	pop    %esi
  8020dc:	5f                   	pop    %edi
  8020dd:	5d                   	pop    %ebp
  8020de:	c3                   	ret    
  8020df:	90                   	nop
  8020e0:	89 d1                	mov    %edx,%ecx
  8020e2:	89 c5                	mov    %eax,%ebp
  8020e4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8020e8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8020ec:	eb 8d                	jmp    80207b <__umoddi3+0xaf>
  8020ee:	66 90                	xchg   %ax,%ax
  8020f0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8020f4:	72 ea                	jb     8020e0 <__umoddi3+0x114>
  8020f6:	89 f1                	mov    %esi,%ecx
  8020f8:	eb 81                	jmp    80207b <__umoddi3+0xaf>
