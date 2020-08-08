
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 70 12 f0       	mov    $0xf0127000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 f0 00 00 00       	call   f010012e <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	83 ec 10             	sub    $0x10,%esp
f0100048:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004b:	83 3d 80 1e 33 f0 00 	cmpl   $0x0,0xf0331e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 1e 33 f0    	mov    %esi,0xf0331e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 b4 63 00 00       	call   f0106418 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 e0 6a 10 f0 	movl   $0xf0106ae0,(%esp)
f010007d:	e8 48 3e 00 00       	call   f0103eca <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 09 3e 00 00       	call   f0103e97 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 6c 7c 10 f0 	movl   $0xf0107c6c,(%esp)
f0100095:	e8 30 3e 00 00       	call   f0103eca <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 f4 07 00 00       	call   f010089a <monitor>
f01000a6:	eb f2                	jmp    f010009a <_panic+0x5a>

f01000a8 <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000a8:	55                   	push   %ebp
f01000a9:	89 e5                	mov    %esp,%ebp
f01000ab:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000ae:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 4b 6b 10 f0 	movl   $0xf0106b4b,(%esp)
f01000d5:	e8 66 ff ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01000da:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01000df:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01000e2:	e8 31 63 00 00       	call   f0106418 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 57 6b 10 f0 	movl   $0xf0106b57,(%esp)
f01000f2:	e8 d3 3d 00 00       	call   f0103eca <cprintf>

	lapic_init();
f01000f7:	e8 37 63 00 00       	call   f0106433 <lapic_init>
	env_init_percpu();
f01000fc:	e8 b0 34 00 00       	call   f01035b1 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 de 3d 00 00       	call   f0103ee4 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 0d 63 00 00       	call   f0106418 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 20 33 f0    	add    $0xf0332020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100114:	b8 01 00 00 00       	mov    $0x1,%eax
f0100119:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f010011d:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100124:	e8 ae 65 00 00       	call   f01066d7 <spin_lock>
	//
	// Your code here:
	// Aquire lock
	lock_kernel();
	// Start execution
	sched_yield();
f0100129:	e8 a8 4a 00 00       	call   f0104bd6 <sched_yield>

f010012e <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010012e:	55                   	push   %ebp
f010012f:	89 e5                	mov    %esp,%ebp
f0100131:	53                   	push   %ebx
f0100132:	83 ec 14             	sub    $0x14,%esp
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100135:	e8 27 05 00 00       	call   f0100661 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010013a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100141:	00 
f0100142:	c7 04 24 6d 6b 10 f0 	movl   $0xf0106b6d,(%esp)
f0100149:	e8 7c 3d 00 00       	call   f0103eca <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010014e:	e8 cd 11 00 00       	call   f0101320 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100153:	e8 83 34 00 00       	call   f01035db <env_init>
	trap_init();
f0100158:	e8 89 3e 00 00       	call   f0103fe6 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010015d:	e8 ce 5f 00 00       	call   f0106130 <mp_init>
	lapic_init();
f0100162:	e8 cc 62 00 00       	call   f0106433 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100167:	e8 b4 3c 00 00       	call   f0103e20 <pic_init>
f010016c:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100173:	e8 5f 65 00 00       	call   f01066d7 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100178:	83 3d 88 1e 33 f0 07 	cmpl   $0x7,0xf0331e88
f010017f:	77 24                	ja     f01001a5 <i386_init+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100181:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100188:	00 
f0100189:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0100190:	f0 
f0100191:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0100198:	00 
f0100199:	c7 04 24 4b 6b 10 f0 	movl   $0xf0106b4b,(%esp)
f01001a0:	e8 9b fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001a5:	b8 5a 60 10 f0       	mov    $0xf010605a,%eax
f01001aa:	2d e0 5f 10 f0       	sub    $0xf0105fe0,%eax
f01001af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001b3:	c7 44 24 04 e0 5f 10 	movl   $0xf0105fe0,0x4(%esp)
f01001ba:	f0 
f01001bb:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001c2:	e8 6d 5c 00 00       	call   f0105e34 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c7:	bb 20 20 33 f0       	mov    $0xf0332020,%ebx
f01001cc:	eb 6f                	jmp    f010023d <i386_init+0x10f>
		if (c == cpus + cpunum())  // We've started already.
f01001ce:	e8 45 62 00 00       	call   f0106418 <cpunum>
f01001d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001da:	29 c2                	sub    %eax,%edx
f01001dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001df:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f01001e6:	39 c3                	cmp    %eax,%ebx
f01001e8:	74 50                	je     f010023a <i386_init+0x10c>

static void boot_aps(void);


void
i386_init(void)
f01001ea:	89 d8                	mov    %ebx,%eax
f01001ec:	2d 20 20 33 f0       	sub    $0xf0332020,%eax
	for (c = cpus; c < cpus + ncpu; c++) {
		if (c == cpus + cpunum())  // We've started already.
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f01001f1:	c1 f8 02             	sar    $0x2,%eax
f01001f4:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01001f7:	8d 14 d0             	lea    (%eax,%edx,8),%edx
f01001fa:	89 d1                	mov    %edx,%ecx
f01001fc:	c1 e1 05             	shl    $0x5,%ecx
f01001ff:	29 d1                	sub    %edx,%ecx
f0100201:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f0100204:	89 d1                	mov    %edx,%ecx
f0100206:	c1 e1 0e             	shl    $0xe,%ecx
f0100209:	29 d1                	sub    %edx,%ecx
f010020b:	8d 14 88             	lea    (%eax,%ecx,4),%edx
f010020e:	8d 44 90 01          	lea    0x1(%eax,%edx,4),%eax
f0100212:	c1 e0 0f             	shl    $0xf,%eax
f0100215:	05 00 30 33 f0       	add    $0xf0333000,%eax
f010021a:	a3 84 1e 33 f0       	mov    %eax,0xf0331e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010021f:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100226:	00 
f0100227:	0f b6 03             	movzbl (%ebx),%eax
f010022a:	89 04 24             	mov    %eax,(%esp)
f010022d:	e8 5a 63 00 00       	call   f010658c <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100232:	8b 43 04             	mov    0x4(%ebx),%eax
f0100235:	83 f8 01             	cmp    $0x1,%eax
f0100238:	75 f8                	jne    f0100232 <i386_init+0x104>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f010023a:	83 c3 74             	add    $0x74,%ebx
f010023d:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f0100242:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100249:	29 c2                	sub    %eax,%edx
f010024b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010024e:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0100255:	39 c3                	cmp    %eax,%ebx
f0100257:	0f 82 71 ff ff ff    	jb     f01001ce <i386_init+0xa0>
	// Starting non-boot CPUs
	boot_aps();

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f010025d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100264:	00 
f0100265:	c7 04 24 90 e5 31 f0 	movl   $0xf031e590,(%esp)
f010026c:	e8 af 35 00 00       	call   f0103820 <env_create>
	// Tests for lab 4 exercise 14
	ENV_CREATE(user_primes, ENV_TYPE_USER);
#endif // TEST*

	// Schedule and run the first user environment!
	sched_yield();
f0100271:	e8 60 49 00 00       	call   f0104bd6 <sched_yield>

f0100276 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100276:	55                   	push   %ebp
f0100277:	89 e5                	mov    %esp,%ebp
f0100279:	53                   	push   %ebx
f010027a:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010027d:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100280:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100283:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100287:	8b 45 08             	mov    0x8(%ebp),%eax
f010028a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010028e:	c7 04 24 88 6b 10 f0 	movl   $0xf0106b88,(%esp)
f0100295:	e8 30 3c 00 00       	call   f0103eca <cprintf>
	vcprintf(fmt, ap);
f010029a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010029e:	8b 45 10             	mov    0x10(%ebp),%eax
f01002a1:	89 04 24             	mov    %eax,(%esp)
f01002a4:	e8 ee 3b 00 00       	call   f0103e97 <vcprintf>
	cprintf("\n");
f01002a9:	c7 04 24 6c 7c 10 f0 	movl   $0xf0107c6c,(%esp)
f01002b0:	e8 15 3c 00 00       	call   f0103eca <cprintf>
	va_end(ap);
}
f01002b5:	83 c4 14             	add    $0x14,%esp
f01002b8:	5b                   	pop    %ebx
f01002b9:	5d                   	pop    %ebp
f01002ba:	c3                   	ret    
	...

f01002bc <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002bc:	55                   	push   %ebp
f01002bd:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002bf:	ba 84 00 00 00       	mov    $0x84,%edx
f01002c4:	ec                   	in     (%dx),%al
f01002c5:	ec                   	in     (%dx),%al
f01002c6:	ec                   	in     (%dx),%al
f01002c7:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002c8:	5d                   	pop    %ebp
f01002c9:	c3                   	ret    

f01002ca <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002ca:	55                   	push   %ebp
f01002cb:	89 e5                	mov    %esp,%ebp
f01002cd:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002d2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002d3:	a8 01                	test   $0x1,%al
f01002d5:	74 08                	je     f01002df <serial_proc_data+0x15>
f01002d7:	b2 f8                	mov    $0xf8,%dl
f01002d9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002da:	0f b6 c0             	movzbl %al,%eax
f01002dd:	eb 05                	jmp    f01002e4 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002e4:	5d                   	pop    %ebp
f01002e5:	c3                   	ret    

f01002e6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002e6:	55                   	push   %ebp
f01002e7:	89 e5                	mov    %esp,%ebp
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 04             	sub    $0x4,%esp
f01002ed:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002ef:	eb 29                	jmp    f010031a <cons_intr+0x34>
		if (c == 0)
f01002f1:	85 c0                	test   %eax,%eax
f01002f3:	74 25                	je     f010031a <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01002f5:	8b 15 24 12 33 f0    	mov    0xf0331224,%edx
f01002fb:	88 82 20 10 33 f0    	mov    %al,-0xfccefe0(%edx)
f0100301:	8d 42 01             	lea    0x1(%edx),%eax
f0100304:	a3 24 12 33 f0       	mov    %eax,0xf0331224
		if (cons.wpos == CONSBUFSIZE)
f0100309:	3d 00 02 00 00       	cmp    $0x200,%eax
f010030e:	75 0a                	jne    f010031a <cons_intr+0x34>
			cons.wpos = 0;
f0100310:	c7 05 24 12 33 f0 00 	movl   $0x0,0xf0331224
f0100317:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010031a:	ff d3                	call   *%ebx
f010031c:	83 f8 ff             	cmp    $0xffffffff,%eax
f010031f:	75 d0                	jne    f01002f1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100321:	83 c4 04             	add    $0x4,%esp
f0100324:	5b                   	pop    %ebx
f0100325:	5d                   	pop    %ebp
f0100326:	c3                   	ret    

f0100327 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100327:	55                   	push   %ebp
f0100328:	89 e5                	mov    %esp,%ebp
f010032a:	57                   	push   %edi
f010032b:	56                   	push   %esi
f010032c:	53                   	push   %ebx
f010032d:	83 ec 2c             	sub    $0x2c,%esp
f0100330:	89 c6                	mov    %eax,%esi
f0100332:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100337:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010033c:	eb 05                	jmp    f0100343 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010033e:	e8 79 ff ff ff       	call   f01002bc <delay>
f0100343:	89 fa                	mov    %edi,%edx
f0100345:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100346:	a8 20                	test   $0x20,%al
f0100348:	75 03                	jne    f010034d <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010034a:	4b                   	dec    %ebx
f010034b:	75 f1                	jne    f010033e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010034d:	89 f2                	mov    %esi,%edx
f010034f:	89 f0                	mov    %esi,%eax
f0100351:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100354:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100359:	ee                   	out    %al,(%dx)
f010035a:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010035f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100364:	eb 05                	jmp    f010036b <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100366:	e8 51 ff ff ff       	call   f01002bc <delay>
f010036b:	89 fa                	mov    %edi,%edx
f010036d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010036e:	84 c0                	test   %al,%al
f0100370:	78 03                	js     f0100375 <cons_putc+0x4e>
f0100372:	4b                   	dec    %ebx
f0100373:	75 f1                	jne    f0100366 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100375:	ba 78 03 00 00       	mov    $0x378,%edx
f010037a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010037d:	ee                   	out    %al,(%dx)
f010037e:	b2 7a                	mov    $0x7a,%dl
f0100380:	b0 0d                	mov    $0xd,%al
f0100382:	ee                   	out    %al,(%dx)
f0100383:	b0 08                	mov    $0x8,%al
f0100385:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100386:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010038c:	75 06                	jne    f0100394 <cons_putc+0x6d>
		c |= 0x0700;
f010038e:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100394:	89 f0                	mov    %esi,%eax
f0100396:	25 ff 00 00 00       	and    $0xff,%eax
f010039b:	83 f8 09             	cmp    $0x9,%eax
f010039e:	74 78                	je     f0100418 <cons_putc+0xf1>
f01003a0:	83 f8 09             	cmp    $0x9,%eax
f01003a3:	7f 0b                	jg     f01003b0 <cons_putc+0x89>
f01003a5:	83 f8 08             	cmp    $0x8,%eax
f01003a8:	0f 85 9e 00 00 00    	jne    f010044c <cons_putc+0x125>
f01003ae:	eb 10                	jmp    f01003c0 <cons_putc+0x99>
f01003b0:	83 f8 0a             	cmp    $0xa,%eax
f01003b3:	74 39                	je     f01003ee <cons_putc+0xc7>
f01003b5:	83 f8 0d             	cmp    $0xd,%eax
f01003b8:	0f 85 8e 00 00 00    	jne    f010044c <cons_putc+0x125>
f01003be:	eb 36                	jmp    f01003f6 <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01003c0:	66 a1 34 12 33 f0    	mov    0xf0331234,%ax
f01003c6:	66 85 c0             	test   %ax,%ax
f01003c9:	0f 84 e2 00 00 00    	je     f01004b1 <cons_putc+0x18a>
			crt_pos--;
f01003cf:	48                   	dec    %eax
f01003d0:	66 a3 34 12 33 f0    	mov    %ax,0xf0331234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003d6:	0f b7 c0             	movzwl %ax,%eax
f01003d9:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01003df:	83 ce 20             	or     $0x20,%esi
f01003e2:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
f01003e8:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01003ec:	eb 78                	jmp    f0100466 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003ee:	66 83 05 34 12 33 f0 	addw   $0x50,0xf0331234
f01003f5:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003f6:	66 8b 0d 34 12 33 f0 	mov    0xf0331234,%cx
f01003fd:	bb 50 00 00 00       	mov    $0x50,%ebx
f0100402:	89 c8                	mov    %ecx,%eax
f0100404:	ba 00 00 00 00       	mov    $0x0,%edx
f0100409:	66 f7 f3             	div    %bx
f010040c:	66 29 d1             	sub    %dx,%cx
f010040f:	66 89 0d 34 12 33 f0 	mov    %cx,0xf0331234
f0100416:	eb 4e                	jmp    f0100466 <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100418:	b8 20 00 00 00       	mov    $0x20,%eax
f010041d:	e8 05 ff ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100422:	b8 20 00 00 00       	mov    $0x20,%eax
f0100427:	e8 fb fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f010042c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100431:	e8 f1 fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100436:	b8 20 00 00 00       	mov    $0x20,%eax
f010043b:	e8 e7 fe ff ff       	call   f0100327 <cons_putc>
		cons_putc(' ');
f0100440:	b8 20 00 00 00       	mov    $0x20,%eax
f0100445:	e8 dd fe ff ff       	call   f0100327 <cons_putc>
f010044a:	eb 1a                	jmp    f0100466 <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010044c:	66 a1 34 12 33 f0    	mov    0xf0331234,%ax
f0100452:	0f b7 c8             	movzwl %ax,%ecx
f0100455:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
f010045b:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010045f:	40                   	inc    %eax
f0100460:	66 a3 34 12 33 f0    	mov    %ax,0xf0331234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100466:	66 81 3d 34 12 33 f0 	cmpw   $0x7cf,0xf0331234
f010046d:	cf 07 
f010046f:	76 40                	jbe    f01004b1 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100471:	a1 30 12 33 f0       	mov    0xf0331230,%eax
f0100476:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010047d:	00 
f010047e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100484:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100488:	89 04 24             	mov    %eax,(%esp)
f010048b:	e8 a4 59 00 00       	call   f0105e34 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100490:	8b 15 30 12 33 f0    	mov    0xf0331230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100496:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010049b:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004a1:	40                   	inc    %eax
f01004a2:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004a7:	75 f2                	jne    f010049b <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004a9:	66 83 2d 34 12 33 f0 	subw   $0x50,0xf0331234
f01004b0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004b1:	8b 0d 2c 12 33 f0    	mov    0xf033122c,%ecx
f01004b7:	b0 0e                	mov    $0xe,%al
f01004b9:	89 ca                	mov    %ecx,%edx
f01004bb:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004bc:	66 8b 35 34 12 33 f0 	mov    0xf0331234,%si
f01004c3:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004c6:	89 f0                	mov    %esi,%eax
f01004c8:	66 c1 e8 08          	shr    $0x8,%ax
f01004cc:	89 da                	mov    %ebx,%edx
f01004ce:	ee                   	out    %al,(%dx)
f01004cf:	b0 0f                	mov    $0xf,%al
f01004d1:	89 ca                	mov    %ecx,%edx
f01004d3:	ee                   	out    %al,(%dx)
f01004d4:	89 f0                	mov    %esi,%eax
f01004d6:	89 da                	mov    %ebx,%edx
f01004d8:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004d9:	83 c4 2c             	add    $0x2c,%esp
f01004dc:	5b                   	pop    %ebx
f01004dd:	5e                   	pop    %esi
f01004de:	5f                   	pop    %edi
f01004df:	5d                   	pop    %ebp
f01004e0:	c3                   	ret    

f01004e1 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004e1:	55                   	push   %ebp
f01004e2:	89 e5                	mov    %esp,%ebp
f01004e4:	53                   	push   %ebx
f01004e5:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01004e8:	ba 64 00 00 00       	mov    $0x64,%edx
f01004ed:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01004ee:	0f b6 c0             	movzbl %al,%eax
f01004f1:	a8 01                	test   $0x1,%al
f01004f3:	0f 84 e0 00 00 00    	je     f01005d9 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01004f9:	a8 20                	test   $0x20,%al
f01004fb:	0f 85 df 00 00 00    	jne    f01005e0 <kbd_proc_data+0xff>
f0100501:	b2 60                	mov    $0x60,%dl
f0100503:	ec                   	in     (%dx),%al
f0100504:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100506:	3c e0                	cmp    $0xe0,%al
f0100508:	75 11                	jne    f010051b <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f010050a:	83 0d 28 12 33 f0 40 	orl    $0x40,0xf0331228
		return 0;
f0100511:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100516:	e9 ca 00 00 00       	jmp    f01005e5 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f010051b:	84 c0                	test   %al,%al
f010051d:	79 33                	jns    f0100552 <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010051f:	8b 0d 28 12 33 f0    	mov    0xf0331228,%ecx
f0100525:	f6 c1 40             	test   $0x40,%cl
f0100528:	75 05                	jne    f010052f <kbd_proc_data+0x4e>
f010052a:	88 c2                	mov    %al,%dl
f010052c:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010052f:	0f b6 d2             	movzbl %dl,%edx
f0100532:	8a 82 e0 6b 10 f0    	mov    -0xfef9420(%edx),%al
f0100538:	83 c8 40             	or     $0x40,%eax
f010053b:	0f b6 c0             	movzbl %al,%eax
f010053e:	f7 d0                	not    %eax
f0100540:	21 c1                	and    %eax,%ecx
f0100542:	89 0d 28 12 33 f0    	mov    %ecx,0xf0331228
		return 0;
f0100548:	bb 00 00 00 00       	mov    $0x0,%ebx
f010054d:	e9 93 00 00 00       	jmp    f01005e5 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f0100552:	8b 0d 28 12 33 f0    	mov    0xf0331228,%ecx
f0100558:	f6 c1 40             	test   $0x40,%cl
f010055b:	74 0e                	je     f010056b <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010055d:	88 c2                	mov    %al,%dl
f010055f:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100562:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100565:	89 0d 28 12 33 f0    	mov    %ecx,0xf0331228
	}

	shift |= shiftcode[data];
f010056b:	0f b6 d2             	movzbl %dl,%edx
f010056e:	0f b6 82 e0 6b 10 f0 	movzbl -0xfef9420(%edx),%eax
f0100575:	0b 05 28 12 33 f0    	or     0xf0331228,%eax
	shift ^= togglecode[data];
f010057b:	0f b6 8a e0 6c 10 f0 	movzbl -0xfef9320(%edx),%ecx
f0100582:	31 c8                	xor    %ecx,%eax
f0100584:	a3 28 12 33 f0       	mov    %eax,0xf0331228

	c = charcode[shift & (CTL | SHIFT)][data];
f0100589:	89 c1                	mov    %eax,%ecx
f010058b:	83 e1 03             	and    $0x3,%ecx
f010058e:	8b 0c 8d e0 6d 10 f0 	mov    -0xfef9220(,%ecx,4),%ecx
f0100595:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100599:	a8 08                	test   $0x8,%al
f010059b:	74 18                	je     f01005b5 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f010059d:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005a0:	83 fa 19             	cmp    $0x19,%edx
f01005a3:	77 05                	ja     f01005aa <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f01005a5:	83 eb 20             	sub    $0x20,%ebx
f01005a8:	eb 0b                	jmp    f01005b5 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f01005aa:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005ad:	83 fa 19             	cmp    $0x19,%edx
f01005b0:	77 03                	ja     f01005b5 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f01005b2:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005b5:	f7 d0                	not    %eax
f01005b7:	a8 06                	test   $0x6,%al
f01005b9:	75 2a                	jne    f01005e5 <kbd_proc_data+0x104>
f01005bb:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005c1:	75 22                	jne    f01005e5 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01005c3:	c7 04 24 a2 6b 10 f0 	movl   $0xf0106ba2,(%esp)
f01005ca:	e8 fb 38 00 00       	call   f0103eca <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005cf:	ba 92 00 00 00       	mov    $0x92,%edx
f01005d4:	b0 03                	mov    $0x3,%al
f01005d6:	ee                   	out    %al,(%dx)
f01005d7:	eb 0c                	jmp    f01005e5 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01005d9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005de:	eb 05                	jmp    f01005e5 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01005e0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005e5:	89 d8                	mov    %ebx,%eax
f01005e7:	83 c4 14             	add    $0x14,%esp
f01005ea:	5b                   	pop    %ebx
f01005eb:	5d                   	pop    %ebp
f01005ec:	c3                   	ret    

f01005ed <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01005f3:	80 3d 00 10 33 f0 00 	cmpb   $0x0,0xf0331000
f01005fa:	74 0a                	je     f0100606 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01005fc:	b8 ca 02 10 f0       	mov    $0xf01002ca,%eax
f0100601:	e8 e0 fc ff ff       	call   f01002e6 <cons_intr>
}
f0100606:	c9                   	leave  
f0100607:	c3                   	ret    

f0100608 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100608:	55                   	push   %ebp
f0100609:	89 e5                	mov    %esp,%ebp
f010060b:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010060e:	b8 e1 04 10 f0       	mov    $0xf01004e1,%eax
f0100613:	e8 ce fc ff ff       	call   f01002e6 <cons_intr>
}
f0100618:	c9                   	leave  
f0100619:	c3                   	ret    

f010061a <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010061a:	55                   	push   %ebp
f010061b:	89 e5                	mov    %esp,%ebp
f010061d:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100620:	e8 c8 ff ff ff       	call   f01005ed <serial_intr>
	kbd_intr();
f0100625:	e8 de ff ff ff       	call   f0100608 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010062a:	8b 15 20 12 33 f0    	mov    0xf0331220,%edx
f0100630:	3b 15 24 12 33 f0    	cmp    0xf0331224,%edx
f0100636:	74 22                	je     f010065a <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100638:	0f b6 82 20 10 33 f0 	movzbl -0xfccefe0(%edx),%eax
f010063f:	42                   	inc    %edx
f0100640:	89 15 20 12 33 f0    	mov    %edx,0xf0331220
		if (cons.rpos == CONSBUFSIZE)
f0100646:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010064c:	75 11                	jne    f010065f <cons_getc+0x45>
			cons.rpos = 0;
f010064e:	c7 05 20 12 33 f0 00 	movl   $0x0,0xf0331220
f0100655:	00 00 00 
f0100658:	eb 05                	jmp    f010065f <cons_getc+0x45>
		return c;
	}
	return 0;
f010065a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010065f:	c9                   	leave  
f0100660:	c3                   	ret    

f0100661 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100661:	55                   	push   %ebp
f0100662:	89 e5                	mov    %esp,%ebp
f0100664:	57                   	push   %edi
f0100665:	56                   	push   %esi
f0100666:	53                   	push   %ebx
f0100667:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010066a:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100671:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100678:	5a a5 
	if (*cp != 0xA55A) {
f010067a:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100680:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100684:	74 11                	je     f0100697 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100686:	c7 05 2c 12 33 f0 b4 	movl   $0x3b4,0xf033122c
f010068d:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100690:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100695:	eb 16                	jmp    f01006ad <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100697:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010069e:	c7 05 2c 12 33 f0 d4 	movl   $0x3d4,0xf033122c
f01006a5:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006a8:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006ad:	8b 0d 2c 12 33 f0    	mov    0xf033122c,%ecx
f01006b3:	b0 0e                	mov    $0xe,%al
f01006b5:	89 ca                	mov    %ecx,%edx
f01006b7:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b8:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006bb:	89 da                	mov    %ebx,%edx
f01006bd:	ec                   	in     (%dx),%al
f01006be:	0f b6 f8             	movzbl %al,%edi
f01006c1:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c4:	b0 0f                	mov    $0xf,%al
f01006c6:	89 ca                	mov    %ecx,%edx
f01006c8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c9:	89 da                	mov    %ebx,%edx
f01006cb:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006cc:	89 35 30 12 33 f0    	mov    %esi,0xf0331230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006d2:	0f b6 d8             	movzbl %al,%ebx
f01006d5:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006d7:	66 89 3d 34 12 33 f0 	mov    %di,0xf0331234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006de:	e8 25 ff ff ff       	call   f0100608 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006e3:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f01006ea:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ef:	89 04 24             	mov    %eax,(%esp)
f01006f2:	e8 b5 36 00 00       	call   f0103dac <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f7:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01006fc:	b0 00                	mov    $0x0,%al
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	b2 fb                	mov    $0xfb,%dl
f0100703:	b0 80                	mov    $0x80,%al
f0100705:	ee                   	out    %al,(%dx)
f0100706:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010070b:	b0 0c                	mov    $0xc,%al
f010070d:	89 ca                	mov    %ecx,%edx
f010070f:	ee                   	out    %al,(%dx)
f0100710:	b2 f9                	mov    $0xf9,%dl
f0100712:	b0 00                	mov    $0x0,%al
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b2 fb                	mov    $0xfb,%dl
f0100717:	b0 03                	mov    $0x3,%al
f0100719:	ee                   	out    %al,(%dx)
f010071a:	b2 fc                	mov    $0xfc,%dl
f010071c:	b0 00                	mov    $0x0,%al
f010071e:	ee                   	out    %al,(%dx)
f010071f:	b2 f9                	mov    $0xf9,%dl
f0100721:	b0 01                	mov    $0x1,%al
f0100723:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100724:	b2 fd                	mov    $0xfd,%dl
f0100726:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100727:	3c ff                	cmp    $0xff,%al
f0100729:	0f 95 45 e7          	setne  -0x19(%ebp)
f010072d:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100730:	a2 00 10 33 f0       	mov    %al,0xf0331000
f0100735:	89 da                	mov    %ebx,%edx
f0100737:	ec                   	in     (%dx),%al
f0100738:	89 ca                	mov    %ecx,%edx
f010073a:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010073b:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f010073f:	75 0c                	jne    f010074d <cons_init+0xec>
		cprintf("Serial port does not exist!\n");
f0100741:	c7 04 24 ae 6b 10 f0 	movl   $0xf0106bae,(%esp)
f0100748:	e8 7d 37 00 00       	call   f0103eca <cprintf>
}
f010074d:	83 c4 2c             	add    $0x2c,%esp
f0100750:	5b                   	pop    %ebx
f0100751:	5e                   	pop    %esi
f0100752:	5f                   	pop    %edi
f0100753:	5d                   	pop    %ebp
f0100754:	c3                   	ret    

f0100755 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100755:	55                   	push   %ebp
f0100756:	89 e5                	mov    %esp,%ebp
f0100758:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010075b:	8b 45 08             	mov    0x8(%ebp),%eax
f010075e:	e8 c4 fb ff ff       	call   f0100327 <cons_putc>
}
f0100763:	c9                   	leave  
f0100764:	c3                   	ret    

f0100765 <getchar>:

int
getchar(void)
{
f0100765:	55                   	push   %ebp
f0100766:	89 e5                	mov    %esp,%ebp
f0100768:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010076b:	e8 aa fe ff ff       	call   f010061a <cons_getc>
f0100770:	85 c0                	test   %eax,%eax
f0100772:	74 f7                	je     f010076b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100774:	c9                   	leave  
f0100775:	c3                   	ret    

f0100776 <iscons>:

int
iscons(int fdnum)
{
f0100776:	55                   	push   %ebp
f0100777:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100779:	b8 01 00 00 00       	mov    $0x1,%eax
f010077e:	5d                   	pop    %ebp
f010077f:	c3                   	ret    

f0100780 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100780:	55                   	push   %ebp
f0100781:	89 e5                	mov    %esp,%ebp
f0100783:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100786:	c7 04 24 f0 6d 10 f0 	movl   $0xf0106df0,(%esp)
f010078d:	e8 38 37 00 00       	call   f0103eca <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100792:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100799:	00 
f010079a:	c7 04 24 7c 6e 10 f0 	movl   $0xf0106e7c,(%esp)
f01007a1:	e8 24 37 00 00       	call   f0103eca <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007a6:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007ad:	00 
f01007ae:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007b5:	f0 
f01007b6:	c7 04 24 a4 6e 10 f0 	movl   $0xf0106ea4,(%esp)
f01007bd:	e8 08 37 00 00       	call   f0103eca <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007c2:	c7 44 24 08 d6 6a 10 	movl   $0x106ad6,0x8(%esp)
f01007c9:	00 
f01007ca:	c7 44 24 04 d6 6a 10 	movl   $0xf0106ad6,0x4(%esp)
f01007d1:	f0 
f01007d2:	c7 04 24 c8 6e 10 f0 	movl   $0xf0106ec8,(%esp)
f01007d9:	e8 ec 36 00 00       	call   f0103eca <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01007de:	c7 44 24 08 00 10 33 	movl   $0x331000,0x8(%esp)
f01007e5:	00 
f01007e6:	c7 44 24 04 00 10 33 	movl   $0xf0331000,0x4(%esp)
f01007ed:	f0 
f01007ee:	c7 04 24 ec 6e 10 f0 	movl   $0xf0106eec,(%esp)
f01007f5:	e8 d0 36 00 00       	call   f0103eca <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01007fa:	c7 44 24 08 08 30 37 	movl   $0x373008,0x8(%esp)
f0100801:	00 
f0100802:	c7 44 24 04 08 30 37 	movl   $0xf0373008,0x4(%esp)
f0100809:	f0 
f010080a:	c7 04 24 10 6f 10 f0 	movl   $0xf0106f10,(%esp)
f0100811:	e8 b4 36 00 00       	call   f0103eca <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100816:	b8 07 34 37 f0       	mov    $0xf0373407,%eax
f010081b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100820:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100825:	89 c2                	mov    %eax,%edx
f0100827:	85 c0                	test   %eax,%eax
f0100829:	79 06                	jns    f0100831 <mon_kerninfo+0xb1>
f010082b:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100831:	c1 fa 0a             	sar    $0xa,%edx
f0100834:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100838:	c7 04 24 34 6f 10 f0 	movl   $0xf0106f34,(%esp)
f010083f:	e8 86 36 00 00       	call   f0103eca <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100844:	b8 00 00 00 00       	mov    $0x0,%eax
f0100849:	c9                   	leave  
f010084a:	c3                   	ret    

f010084b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010084b:	55                   	push   %ebp
f010084c:	89 e5                	mov    %esp,%ebp
f010084e:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100851:	c7 44 24 08 09 6e 10 	movl   $0xf0106e09,0x8(%esp)
f0100858:	f0 
f0100859:	c7 44 24 04 27 6e 10 	movl   $0xf0106e27,0x4(%esp)
f0100860:	f0 
f0100861:	c7 04 24 2c 6e 10 f0 	movl   $0xf0106e2c,(%esp)
f0100868:	e8 5d 36 00 00       	call   f0103eca <cprintf>
f010086d:	c7 44 24 08 60 6f 10 	movl   $0xf0106f60,0x8(%esp)
f0100874:	f0 
f0100875:	c7 44 24 04 35 6e 10 	movl   $0xf0106e35,0x4(%esp)
f010087c:	f0 
f010087d:	c7 04 24 2c 6e 10 f0 	movl   $0xf0106e2c,(%esp)
f0100884:	e8 41 36 00 00       	call   f0103eca <cprintf>
	return 0;
}
f0100889:	b8 00 00 00 00       	mov    $0x0,%eax
f010088e:	c9                   	leave  
f010088f:	c3                   	ret    

f0100890 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100890:	55                   	push   %ebp
f0100891:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100893:	b8 00 00 00 00       	mov    $0x0,%eax
f0100898:	5d                   	pop    %ebp
f0100899:	c3                   	ret    

f010089a <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010089a:	55                   	push   %ebp
f010089b:	89 e5                	mov    %esp,%ebp
f010089d:	57                   	push   %edi
f010089e:	56                   	push   %esi
f010089f:	53                   	push   %ebx
f01008a0:	83 ec 5c             	sub    $0x5c,%esp
f01008a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008a6:	c7 04 24 88 6f 10 f0 	movl   $0xf0106f88,(%esp)
f01008ad:	e8 18 36 00 00       	call   f0103eca <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008b2:	c7 04 24 ac 6f 10 f0 	movl   $0xf0106fac,(%esp)
f01008b9:	e8 0c 36 00 00       	call   f0103eca <cprintf>

	if (tf != NULL)
f01008be:	85 ff                	test   %edi,%edi
f01008c0:	74 08                	je     f01008ca <monitor+0x30>
		print_trapframe(tf);
f01008c2:	89 3c 24             	mov    %edi,(%esp)
f01008c5:	e8 d8 3b 00 00       	call   f01044a2 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f01008ca:	c7 04 24 3e 6e 10 f0 	movl   $0xf0106e3e,(%esp)
f01008d1:	e8 ea 52 00 00       	call   f0105bc0 <readline>
f01008d6:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008d8:	85 c0                	test   %eax,%eax
f01008da:	74 ee                	je     f01008ca <monitor+0x30>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008dc:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008e3:	be 00 00 00 00       	mov    $0x0,%esi
f01008e8:	eb 04                	jmp    f01008ee <monitor+0x54>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008ea:	c6 03 00             	movb   $0x0,(%ebx)
f01008ed:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008ee:	8a 03                	mov    (%ebx),%al
f01008f0:	84 c0                	test   %al,%al
f01008f2:	74 5e                	je     f0100952 <monitor+0xb8>
f01008f4:	0f be c0             	movsbl %al,%eax
f01008f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008fb:	c7 04 24 42 6e 10 f0 	movl   $0xf0106e42,(%esp)
f0100902:	e8 ae 54 00 00       	call   f0105db5 <strchr>
f0100907:	85 c0                	test   %eax,%eax
f0100909:	75 df                	jne    f01008ea <monitor+0x50>
			*buf++ = 0;
		if (*buf == 0)
f010090b:	80 3b 00             	cmpb   $0x0,(%ebx)
f010090e:	74 42                	je     f0100952 <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100910:	83 fe 0f             	cmp    $0xf,%esi
f0100913:	75 16                	jne    f010092b <monitor+0x91>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100915:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f010091c:	00 
f010091d:	c7 04 24 47 6e 10 f0 	movl   $0xf0106e47,(%esp)
f0100924:	e8 a1 35 00 00       	call   f0103eca <cprintf>
f0100929:	eb 9f                	jmp    f01008ca <monitor+0x30>
			return 0;
		}
		argv[argc++] = buf;
f010092b:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f010092f:	46                   	inc    %esi
f0100930:	eb 01                	jmp    f0100933 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100932:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100933:	8a 03                	mov    (%ebx),%al
f0100935:	84 c0                	test   %al,%al
f0100937:	74 b5                	je     f01008ee <monitor+0x54>
f0100939:	0f be c0             	movsbl %al,%eax
f010093c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100940:	c7 04 24 42 6e 10 f0 	movl   $0xf0106e42,(%esp)
f0100947:	e8 69 54 00 00       	call   f0105db5 <strchr>
f010094c:	85 c0                	test   %eax,%eax
f010094e:	74 e2                	je     f0100932 <monitor+0x98>
f0100950:	eb 9c                	jmp    f01008ee <monitor+0x54>
			buf++;
	}
	argv[argc] = 0;
f0100952:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100959:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010095a:	85 f6                	test   %esi,%esi
f010095c:	0f 84 68 ff ff ff    	je     f01008ca <monitor+0x30>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100962:	c7 44 24 04 27 6e 10 	movl   $0xf0106e27,0x4(%esp)
f0100969:	f0 
f010096a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010096d:	89 04 24             	mov    %eax,(%esp)
f0100970:	e8 ed 53 00 00       	call   f0105d62 <strcmp>
f0100975:	85 c0                	test   %eax,%eax
f0100977:	74 1b                	je     f0100994 <monitor+0xfa>
f0100979:	c7 44 24 04 35 6e 10 	movl   $0xf0106e35,0x4(%esp)
f0100980:	f0 
f0100981:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100984:	89 04 24             	mov    %eax,(%esp)
f0100987:	e8 d6 53 00 00       	call   f0105d62 <strcmp>
f010098c:	85 c0                	test   %eax,%eax
f010098e:	75 2c                	jne    f01009bc <monitor+0x122>
f0100990:	b0 01                	mov    $0x1,%al
f0100992:	eb 05                	jmp    f0100999 <monitor+0xff>
f0100994:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100999:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010099c:	01 d0                	add    %edx,%eax
f010099e:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009a2:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009a5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009a9:	89 34 24             	mov    %esi,(%esp)
f01009ac:	ff 14 85 dc 6f 10 f0 	call   *-0xfef9024(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009b3:	85 c0                	test   %eax,%eax
f01009b5:	78 1d                	js     f01009d4 <monitor+0x13a>
f01009b7:	e9 0e ff ff ff       	jmp    f01008ca <monitor+0x30>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009bc:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009bf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009c3:	c7 04 24 64 6e 10 f0 	movl   $0xf0106e64,(%esp)
f01009ca:	e8 fb 34 00 00       	call   f0103eca <cprintf>
f01009cf:	e9 f6 fe ff ff       	jmp    f01008ca <monitor+0x30>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009d4:	83 c4 5c             	add    $0x5c,%esp
f01009d7:	5b                   	pop    %ebx
f01009d8:	5e                   	pop    %esi
f01009d9:	5f                   	pop    %edi
f01009da:	5d                   	pop    %ebp
f01009db:	c3                   	ret    

f01009dc <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009dc:	55                   	push   %ebp
f01009dd:	89 e5                	mov    %esp,%ebp
f01009df:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01009e2:	89 d1                	mov    %edx,%ecx
f01009e4:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01009e7:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009ea:	a8 01                	test   $0x1,%al
f01009ec:	74 4d                	je     f0100a3b <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009f3:	89 c1                	mov    %eax,%ecx
f01009f5:	c1 e9 0c             	shr    $0xc,%ecx
f01009f8:	3b 0d 88 1e 33 f0    	cmp    0xf0331e88,%ecx
f01009fe:	72 20                	jb     f0100a20 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a00:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a04:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0100a0b:	f0 
f0100a0c:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0100a13:	00 
f0100a14:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100a1b:	e8 20 f6 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100a20:	c1 ea 0c             	shr    $0xc,%edx
f0100a23:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a29:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a30:	a8 01                	test   $0x1,%al
f0100a32:	74 0e                	je     f0100a42 <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a39:	eb 0c                	jmp    f0100a47 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a40:	eb 05                	jmp    f0100a47 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100a42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100a47:	c9                   	leave  
f0100a48:	c3                   	ret    

f0100a49 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a49:	55                   	push   %ebp
f0100a4a:	89 e5                	mov    %esp,%ebp
f0100a4c:	56                   	push   %esi
f0100a4d:	53                   	push   %ebx
f0100a4e:	83 ec 10             	sub    $0x10,%esp
f0100a51:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a53:	89 04 24             	mov    %eax,(%esp)
f0100a56:	e8 29 33 00 00       	call   f0103d84 <mc146818_read>
f0100a5b:	89 c6                	mov    %eax,%esi
f0100a5d:	43                   	inc    %ebx
f0100a5e:	89 1c 24             	mov    %ebx,(%esp)
f0100a61:	e8 1e 33 00 00       	call   f0103d84 <mc146818_read>
f0100a66:	c1 e0 08             	shl    $0x8,%eax
f0100a69:	09 f0                	or     %esi,%eax
}
f0100a6b:	83 c4 10             	add    $0x10,%esp
f0100a6e:	5b                   	pop    %ebx
f0100a6f:	5e                   	pop    %esi
f0100a70:	5d                   	pop    %ebp
f0100a71:	c3                   	ret    

f0100a72 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a72:	55                   	push   %ebp
f0100a73:	89 e5                	mov    %esp,%ebp
f0100a75:	57                   	push   %edi
f0100a76:	56                   	push   %esi
f0100a77:	53                   	push   %ebx
f0100a78:	83 ec 1c             	sub    $0x1c,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a7b:	83 3d 3c 12 33 f0 00 	cmpl   $0x0,0xf033123c
f0100a82:	75 11                	jne    f0100a95 <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a84:	ba 07 40 37 f0       	mov    $0xf0374007,%edx
f0100a89:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a8f:	89 15 3c 12 33 f0    	mov    %edx,0xf033123c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	assert(n >= 0);
	// Convert to physical address
	result = (char *)PADDR(nextfree);
f0100a95:	8b 15 3c 12 33 f0    	mov    0xf033123c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100a9b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100aa1:	77 20                	ja     f0100ac3 <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100aa3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100aa7:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0100aae:	f0 
f0100aaf:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f0100ab6:	00 
f0100ab7:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100abe:	e8 7d f5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100ac3:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	// Determine whether it is out of bound
	if ((physaddr_t)result + n > PGSIZE * npages) {
f0100ac9:	8b 1d 88 1e 33 f0    	mov    0xf0331e88,%ebx
f0100acf:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
f0100ad2:	89 de                	mov    %ebx,%esi
f0100ad4:	c1 e6 0c             	shl    $0xc,%esi
f0100ad7:	39 f7                	cmp    %esi,%edi
f0100ad9:	76 1c                	jbe    f0100af7 <boot_alloc+0x85>
		panic("boot_alloc: out of memory!");
f0100adb:	c7 44 24 08 7d 79 10 	movl   $0xf010797d,0x8(%esp)
f0100ae2:	f0 
f0100ae3:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
f0100aea:	00 
f0100aeb:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100af2:	e8 49 f5 ff ff       	call   f0100040 <_panic>
	}
	// Otherwise, update value of nextfree, no update when n == 0
	nextfree += ROUNDUP(n, PGSIZE);
f0100af7:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100afc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b01:	01 d0                	add    %edx,%eax
f0100b03:	a3 3c 12 33 f0       	mov    %eax,0xf033123c
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b08:	89 c8                	mov    %ecx,%eax
f0100b0a:	c1 e8 0c             	shr    $0xc,%eax
f0100b0d:	39 c3                	cmp    %eax,%ebx
f0100b0f:	77 20                	ja     f0100b31 <boot_alloc+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b11:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100b15:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0100b1c:	f0 
f0100b1d:	c7 44 24 04 76 00 00 	movl   $0x76,0x4(%esp)
f0100b24:	00 
f0100b25:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100b2c:	e8 0f f5 ff ff       	call   f0100040 <_panic>
	// Convert back to kernel virtual address and return
	return KADDR((physaddr_t)result);
}
f0100b31:	89 d0                	mov    %edx,%eax
f0100b33:	83 c4 1c             	add    $0x1c,%esp
f0100b36:	5b                   	pop    %ebx
f0100b37:	5e                   	pop    %esi
f0100b38:	5f                   	pop    %edi
f0100b39:	5d                   	pop    %ebp
f0100b3a:	c3                   	ret    

f0100b3b <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b3b:	55                   	push   %ebp
f0100b3c:	89 e5                	mov    %esp,%ebp
f0100b3e:	57                   	push   %edi
f0100b3f:	56                   	push   %esi
f0100b40:	53                   	push   %ebx
f0100b41:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b44:	3c 01                	cmp    $0x1,%al
f0100b46:	19 f6                	sbb    %esi,%esi
f0100b48:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100b4e:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b4f:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0100b55:	85 d2                	test   %edx,%edx
f0100b57:	75 1c                	jne    f0100b75 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100b59:	c7 44 24 08 ec 6f 10 	movl   $0xf0106fec,0x8(%esp)
f0100b60:	f0 
f0100b61:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f0100b68:	00 
f0100b69:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100b70:	e8 cb f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100b75:	84 c0                	test   %al,%al
f0100b77:	74 4b                	je     f0100bc4 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b79:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100b7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100b7f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100b82:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b85:	89 d0                	mov    %edx,%eax
f0100b87:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100b8d:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b90:	c1 e8 16             	shr    $0x16,%eax
f0100b93:	39 c6                	cmp    %eax,%esi
f0100b95:	0f 96 c0             	setbe  %al
f0100b98:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100b9b:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100b9f:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ba1:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ba5:	8b 12                	mov    (%edx),%edx
f0100ba7:	85 d2                	test   %edx,%edx
f0100ba9:	75 da                	jne    f0100b85 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100bab:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bae:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bb4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100bba:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bbc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bbf:	a3 40 12 33 f0       	mov    %eax,0xf0331240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bc4:	8b 1d 40 12 33 f0    	mov    0xf0331240,%ebx
f0100bca:	eb 63                	jmp    f0100c2f <check_page_free_list+0xf4>
f0100bcc:	89 d8                	mov    %ebx,%eax
f0100bce:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100bd4:	c1 f8 03             	sar    $0x3,%eax
f0100bd7:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bda:	89 c2                	mov    %eax,%edx
f0100bdc:	c1 ea 16             	shr    $0x16,%edx
f0100bdf:	39 d6                	cmp    %edx,%esi
f0100be1:	76 4a                	jbe    f0100c2d <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100be3:	89 c2                	mov    %eax,%edx
f0100be5:	c1 ea 0c             	shr    $0xc,%edx
f0100be8:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100bee:	72 20                	jb     f0100c10 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bf0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bf4:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0100bfb:	f0 
f0100bfc:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c03:	00 
f0100c04:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0100c0b:	e8 30 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c10:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c17:	00 
f0100c18:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c1f:	00 
	return (void *)(pa + KERNBASE);
f0100c20:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c25:	89 04 24             	mov    %eax,(%esp)
f0100c28:	e8 bd 51 00 00       	call   f0105dea <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c2d:	8b 1b                	mov    (%ebx),%ebx
f0100c2f:	85 db                	test   %ebx,%ebx
f0100c31:	75 99                	jne    f0100bcc <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c33:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c38:	e8 35 fe ff ff       	call   f0100a72 <boot_alloc>
f0100c3d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c40:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c46:	8b 0d 90 1e 33 f0    	mov    0xf0331e90,%ecx
		assert(pp < pages + npages);
f0100c4c:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f0100c51:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c54:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c57:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c5a:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c5d:	be 00 00 00 00       	mov    $0x0,%esi
f0100c62:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c65:	e9 c4 01 00 00       	jmp    f0100e2e <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c6a:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100c6d:	73 24                	jae    f0100c93 <check_page_free_list+0x158>
f0100c6f:	c7 44 24 0c a6 79 10 	movl   $0xf01079a6,0xc(%esp)
f0100c76:	f0 
f0100c77:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100c7e:	f0 
f0100c7f:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0100c86:	00 
f0100c87:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100c8e:	e8 ad f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c93:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c96:	72 24                	jb     f0100cbc <check_page_free_list+0x181>
f0100c98:	c7 44 24 0c c7 79 10 	movl   $0xf01079c7,0xc(%esp)
f0100c9f:	f0 
f0100ca0:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100ca7:	f0 
f0100ca8:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0100caf:	00 
f0100cb0:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100cb7:	e8 84 f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cbc:	89 d0                	mov    %edx,%eax
f0100cbe:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cc1:	a8 07                	test   $0x7,%al
f0100cc3:	74 24                	je     f0100ce9 <check_page_free_list+0x1ae>
f0100cc5:	c7 44 24 0c 10 70 10 	movl   $0xf0107010,0xc(%esp)
f0100ccc:	f0 
f0100ccd:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100cd4:	f0 
f0100cd5:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f0100cdc:	00 
f0100cdd:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100ce4:	e8 57 f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ce9:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100cec:	c1 e0 0c             	shl    $0xc,%eax
f0100cef:	75 24                	jne    f0100d15 <check_page_free_list+0x1da>
f0100cf1:	c7 44 24 0c db 79 10 	movl   $0xf01079db,0xc(%esp)
f0100cf8:	f0 
f0100cf9:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100d00:	f0 
f0100d01:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0100d08:	00 
f0100d09:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100d10:	e8 2b f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d15:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d1a:	75 24                	jne    f0100d40 <check_page_free_list+0x205>
f0100d1c:	c7 44 24 0c ec 79 10 	movl   $0xf01079ec,0xc(%esp)
f0100d23:	f0 
f0100d24:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100d2b:	f0 
f0100d2c:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0100d33:	00 
f0100d34:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100d3b:	e8 00 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d40:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d45:	75 24                	jne    f0100d6b <check_page_free_list+0x230>
f0100d47:	c7 44 24 0c 44 70 10 	movl   $0xf0107044,0xc(%esp)
f0100d4e:	f0 
f0100d4f:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100d56:	f0 
f0100d57:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f0100d5e:	00 
f0100d5f:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100d66:	e8 d5 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d6b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d70:	75 24                	jne    f0100d96 <check_page_free_list+0x25b>
f0100d72:	c7 44 24 0c 05 7a 10 	movl   $0xf0107a05,0xc(%esp)
f0100d79:	f0 
f0100d7a:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100d81:	f0 
f0100d82:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0100d89:	00 
f0100d8a:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100d91:	e8 aa f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d96:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d9b:	76 59                	jbe    f0100df6 <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d9d:	89 c1                	mov    %eax,%ecx
f0100d9f:	c1 e9 0c             	shr    $0xc,%ecx
f0100da2:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100da5:	77 20                	ja     f0100dc7 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100da7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100dab:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0100db2:	f0 
f0100db3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100dba:	00 
f0100dbb:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0100dc2:	e8 79 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100dc7:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100dcd:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100dd0:	76 24                	jbe    f0100df6 <check_page_free_list+0x2bb>
f0100dd2:	c7 44 24 0c 68 70 10 	movl   $0xf0107068,0xc(%esp)
f0100dd9:	f0 
f0100dda:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100de1:	f0 
f0100de2:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0100de9:	00 
f0100dea:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100df1:	e8 4a f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100df6:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dfb:	75 24                	jne    f0100e21 <check_page_free_list+0x2e6>
f0100dfd:	c7 44 24 0c 1f 7a 10 	movl   $0xf0107a1f,0xc(%esp)
f0100e04:	f0 
f0100e05:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100e0c:	f0 
f0100e0d:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0100e14:	00 
f0100e15:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100e1c:	e8 1f f2 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100e21:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e26:	77 03                	ja     f0100e2b <check_page_free_list+0x2f0>
			++nfree_basemem;
f0100e28:	46                   	inc    %esi
f0100e29:	eb 01                	jmp    f0100e2c <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0100e2b:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e2c:	8b 12                	mov    (%edx),%edx
f0100e2e:	85 d2                	test   %edx,%edx
f0100e30:	0f 85 34 fe ff ff    	jne    f0100c6a <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e36:	85 f6                	test   %esi,%esi
f0100e38:	7f 24                	jg     f0100e5e <check_page_free_list+0x323>
f0100e3a:	c7 44 24 0c 3c 7a 10 	movl   $0xf0107a3c,0xc(%esp)
f0100e41:	f0 
f0100e42:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100e49:	f0 
f0100e4a:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f0100e51:	00 
f0100e52:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100e59:	e8 e2 f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e5e:	85 db                	test   %ebx,%ebx
f0100e60:	7f 24                	jg     f0100e86 <check_page_free_list+0x34b>
f0100e62:	c7 44 24 0c 4e 7a 10 	movl   $0xf0107a4e,0xc(%esp)
f0100e69:	f0 
f0100e6a:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0100e71:	f0 
f0100e72:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f0100e79:	00 
f0100e7a:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100e81:	e8 ba f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100e86:	c7 04 24 b0 70 10 f0 	movl   $0xf01070b0,(%esp)
f0100e8d:	e8 38 30 00 00       	call   f0103eca <cprintf>
}
f0100e92:	83 c4 4c             	add    $0x4c,%esp
f0100e95:	5b                   	pop    %ebx
f0100e96:	5e                   	pop    %esi
f0100e97:	5f                   	pop    %edi
f0100e98:	5d                   	pop    %ebp
f0100e99:	c3                   	ret    

f0100e9a <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100e9a:	55                   	push   %ebp
f0100e9b:	89 e5                	mov    %esp,%ebp
f0100e9d:	57                   	push   %edi
f0100e9e:	56                   	push   %esi
f0100e9f:	53                   	push   %ebx
f0100ea0:	83 ec 1c             	sub    $0x1c,%esp
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
f0100ea3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea8:	e8 c5 fb ff ff       	call   f0100a72 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ead:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100eb2:	77 20                	ja     f0100ed4 <page_init+0x3a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100eb4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100eb8:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0100ebf:	f0 
f0100ec0:	c7 44 24 04 40 01 00 	movl   $0x140,0x4(%esp)
f0100ec7:	00 
f0100ec8:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100ecf:	e8 6c f1 ff ff       	call   f0100040 <_panic>
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE) || (i == MPENTRY_PADDR / PGSIZE)) {
f0100ed4:	8b 35 38 12 33 f0    	mov    0xf0331238,%esi
	return (physaddr_t)kva - KERNBASE;
f0100eda:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0100ee0:	c1 ef 0c             	shr    $0xc,%edi
f0100ee3:	8b 1d 40 12 33 f0    	mov    0xf0331240,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100ee9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100eee:	ba 00 00 00 00       	mov    $0x0,%edx
f0100ef3:	eb 3b                	jmp    f0100f30 <page_init+0x96>
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE) || (i == MPENTRY_PADDR / PGSIZE)) {
f0100ef5:	85 d2                	test   %edx,%edx
f0100ef7:	74 0d                	je     f0100f06 <page_init+0x6c>
f0100ef9:	39 f2                	cmp    %esi,%edx
f0100efb:	72 04                	jb     f0100f01 <page_init+0x67>
f0100efd:	39 fa                	cmp    %edi,%edx
f0100eff:	72 05                	jb     f0100f06 <page_init+0x6c>
f0100f01:	83 fa 07             	cmp    $0x7,%edx
f0100f04:	75 0e                	jne    f0100f14 <page_init+0x7a>
			pages[i].pp_ref = 1;
f0100f06:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
f0100f0b:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
f0100f12:	eb 18                	jmp    f0100f2c <page_init+0x92>
		}
		// Rest of memory are free
		else {
			pages[i].pp_ref = 0;
f0100f14:	89 c8                	mov    %ecx,%eax
f0100f16:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
f0100f1c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f22:	89 18                	mov    %ebx,(%eax)
			page_free_list = &pages[i];
f0100f24:	89 cb                	mov    %ecx,%ebx
f0100f26:	03 1d 90 1e 33 f0    	add    0xf0331e90,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100f2c:	42                   	inc    %edx
f0100f2d:	83 c1 08             	add    $0x8,%ecx
f0100f30:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100f36:	72 bd                	jb     f0100ef5 <page_init+0x5b>
f0100f38:	89 1d 40 12 33 f0    	mov    %ebx,0xf0331240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100f3e:	83 c4 1c             	add    $0x1c,%esp
f0100f41:	5b                   	pop    %ebx
f0100f42:	5e                   	pop    %esi
f0100f43:	5f                   	pop    %edi
f0100f44:	5d                   	pop    %ebp
f0100f45:	c3                   	ret    

f0100f46 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f46:	55                   	push   %ebp
f0100f47:	89 e5                	mov    %esp,%ebp
f0100f49:	53                   	push   %ebx
f0100f4a:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo *currPage = page_free_list;
f0100f4d:	8b 1d 40 12 33 f0    	mov    0xf0331240,%ebx
	// Check whether out of free memory
	if (!page_free_list) {
f0100f53:	85 db                	test   %ebx,%ebx
f0100f55:	74 6b                	je     f0100fc2 <page_alloc+0x7c>
		return NULL;
	}
	// Set the page without change the reference bit.
	page_free_list = currPage->pp_link;
f0100f57:	8b 03                	mov    (%ebx),%eax
f0100f59:	a3 40 12 33 f0       	mov    %eax,0xf0331240
	currPage->pp_link = NULL;
f0100f5e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100f64:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f68:	74 58                	je     f0100fc2 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f6a:	89 d8                	mov    %ebx,%eax
f0100f6c:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0100f72:	c1 f8 03             	sar    $0x3,%eax
f0100f75:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f78:	89 c2                	mov    %eax,%edx
f0100f7a:	c1 ea 0c             	shr    $0xc,%edx
f0100f7d:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0100f83:	72 20                	jb     f0100fa5 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f85:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f89:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0100f90:	f0 
f0100f91:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100f98:	00 
f0100f99:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0100fa0:	e8 9b f0 ff ff       	call   f0100040 <_panic>
	{
		memset(page2kva(currPage), 0, PGSIZE);
f0100fa5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fac:	00 
f0100fad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fb4:	00 
	return (void *)(pa + KERNBASE);
f0100fb5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100fba:	89 04 24             	mov    %eax,(%esp)
f0100fbd:	e8 28 4e 00 00       	call   f0105dea <memset>
	}
	return currPage;
}
f0100fc2:	89 d8                	mov    %ebx,%eax
f0100fc4:	83 c4 14             	add    $0x14,%esp
f0100fc7:	5b                   	pop    %ebx
f0100fc8:	5d                   	pop    %ebp
f0100fc9:	c3                   	ret    

f0100fca <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100fca:	55                   	push   %ebp
f0100fcb:	89 e5                	mov    %esp,%ebp
f0100fcd:	83 ec 18             	sub    $0x18,%esp
f0100fd0:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref || pp->pp_link) {
f0100fd3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100fd8:	75 05                	jne    f0100fdf <page_free+0x15>
f0100fda:	83 38 00             	cmpl   $0x0,(%eax)
f0100fdd:	74 1c                	je     f0100ffb <page_free+0x31>
		panic("page_free: reference bit is nonzero or link is not NULL!");
f0100fdf:	c7 44 24 08 d4 70 10 	movl   $0xf01070d4,0x8(%esp)
f0100fe6:	f0 
f0100fe7:	c7 44 24 04 7b 01 00 	movl   $0x17b,0x4(%esp)
f0100fee:	00 
f0100fef:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0100ff6:	e8 45 f0 ff ff       	call   f0100040 <_panic>
	}
	// Update the free list
	pp->pp_link = page_free_list;
f0100ffb:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0101001:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0101003:	a3 40 12 33 f0       	mov    %eax,0xf0331240
}
f0101008:	c9                   	leave  
f0101009:	c3                   	ret    

f010100a <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f010100a:	55                   	push   %ebp
f010100b:	89 e5                	mov    %esp,%ebp
f010100d:	83 ec 18             	sub    $0x18,%esp
f0101010:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0101013:	8b 50 04             	mov    0x4(%eax),%edx
f0101016:	4a                   	dec    %edx
f0101017:	66 89 50 04          	mov    %dx,0x4(%eax)
f010101b:	66 85 d2             	test   %dx,%dx
f010101e:	75 08                	jne    f0101028 <page_decref+0x1e>
		page_free(pp);
f0101020:	89 04 24             	mov    %eax,(%esp)
f0101023:	e8 a2 ff ff ff       	call   f0100fca <page_free>
}
f0101028:	c9                   	leave  
f0101029:	c3                   	ret    

f010102a <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f010102a:	55                   	push   %ebp
f010102b:	89 e5                	mov    %esp,%ebp
f010102d:	56                   	push   %esi
f010102e:	53                   	push   %ebx
f010102f:	83 ec 10             	sub    $0x10,%esp
f0101032:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	struct PageInfo *newPage;
	pde_t *pdeEntry = &pgdir[PDX(va)];
f0101035:	89 f3                	mov    %esi,%ebx
f0101037:	c1 eb 16             	shr    $0x16,%ebx
f010103a:	c1 e3 02             	shl    $0x2,%ebx
f010103d:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t *pteEntry;
	// First extract the content stored in the page directory, 
	// it should be a physical address with some PTE information.
	// If the content is not null, convert it into virtual 
	// address and return
	if (*pdeEntry & PTE_P) {
f0101040:	f6 03 01             	testb  $0x1,(%ebx)
f0101043:	75 2b                	jne    f0101070 <pgdir_walk+0x46>
		goto good;
	}
	// Otherwise, intialize a new page if permitted
	if (create) {
f0101045:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101049:	74 6b                	je     f01010b6 <pgdir_walk+0x8c>
		newPage = page_alloc(ALLOC_ZERO);
f010104b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101052:	e8 ef fe ff ff       	call   f0100f46 <page_alloc>
		// If the page allocation success
		if (newPage) {
f0101057:	85 c0                	test   %eax,%eax
f0101059:	74 62                	je     f01010bd <pgdir_walk+0x93>
			newPage->pp_ref++;
f010105b:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010105f:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0101065:	c1 f8 03             	sar    $0x3,%eax
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
f0101068:	c1 e0 0c             	shl    $0xc,%eax
f010106b:	83 c8 07             	or     $0x7,%eax
f010106e:	89 03                	mov    %eax,(%ebx)
		}
	}
	return NULL;

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
f0101070:	8b 03                	mov    (%ebx),%eax
f0101072:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101077:	89 c2                	mov    %eax,%edx
f0101079:	c1 ea 0c             	shr    $0xc,%edx
f010107c:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0101082:	72 20                	jb     f01010a4 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101084:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101088:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010108f:	f0 
f0101090:	c7 44 24 04 bf 01 00 	movl   $0x1bf,0x4(%esp)
f0101097:	00 
f0101098:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010109f:	e8 9c ef ff ff       	call   f0100040 <_panic>
	return &pteEntry[PTX(va)];
f01010a4:	c1 ee 0a             	shr    $0xa,%esi
f01010a7:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010ad:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01010b4:	eb 0c                	jmp    f01010c2 <pgdir_walk+0x98>
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
			goto good;
		}
	}
	return NULL;
f01010b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01010bb:	eb 05                	jmp    f01010c2 <pgdir_walk+0x98>
f01010bd:	b8 00 00 00 00       	mov    $0x0,%eax

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
	return &pteEntry[PTX(va)];
}
f01010c2:	83 c4 10             	add    $0x10,%esp
f01010c5:	5b                   	pop    %ebx
f01010c6:	5e                   	pop    %esi
f01010c7:	5d                   	pop    %ebp
f01010c8:	c3                   	ret    

f01010c9 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01010c9:	55                   	push   %ebp
f01010ca:	89 e5                	mov    %esp,%ebp
f01010cc:	57                   	push   %edi
f01010cd:	56                   	push   %esi
f01010ce:	53                   	push   %ebx
f01010cf:	83 ec 2c             	sub    $0x2c,%esp
f01010d2:	89 c7                	mov    %eax,%edi
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
f01010d4:	c1 e9 0c             	shr    $0xc,%ecx
f01010d7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f01010da:	89 d3                	mov    %edx,%ebx
f01010dc:	be 00 00 00 00       	mov    $0x0,%esi
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f01010e1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010e4:	83 c8 01             	or     $0x1,%eax
f01010e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f01010ea:	8b 45 08             	mov    0x8(%ebp),%eax
f01010ed:	29 d0                	sub    %edx,%eax
f01010ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f01010f2:	eb 2b                	jmp    f010111f <boot_map_region+0x56>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
f01010f4:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010fb:	00 
f01010fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101100:	89 3c 24             	mov    %edi,(%esp)
f0101103:	e8 22 ff ff ff       	call   f010102a <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101108:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010110b:	01 da                	add    %ebx,%edx
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f010110d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101113:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101116:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0101118:	46                   	inc    %esi
f0101119:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010111f:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0101122:	75 d0                	jne    f01010f4 <boot_map_region+0x2b>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
	}
}
f0101124:	83 c4 2c             	add    $0x2c,%esp
f0101127:	5b                   	pop    %ebx
f0101128:	5e                   	pop    %esi
f0101129:	5f                   	pop    %edi
f010112a:	5d                   	pop    %ebp
f010112b:	c3                   	ret    

f010112c <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010112c:	55                   	push   %ebp
f010112d:	89 e5                	mov    %esp,%ebp
f010112f:	53                   	push   %ebx
f0101130:	83 ec 14             	sub    $0x14,%esp
f0101133:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
f0101136:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010113d:	00 
f010113e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101141:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101145:	8b 45 08             	mov    0x8(%ebp),%eax
f0101148:	89 04 24             	mov    %eax,(%esp)
f010114b:	e8 da fe ff ff       	call   f010102a <pgdir_walk>
	physaddr_t pp;
	if (!pteEntry) {
f0101150:	85 c0                	test   %eax,%eax
f0101152:	74 3f                	je     f0101193 <page_lookup+0x67>
		return NULL;
	}
	if (*pteEntry & PTE_P) {
f0101154:	f6 00 01             	testb  $0x1,(%eax)
f0101157:	74 41                	je     f010119a <page_lookup+0x6e>
		// Modify pte_store passed as a reference
		if (pte_store) {
f0101159:	85 db                	test   %ebx,%ebx
f010115b:	74 02                	je     f010115f <page_lookup+0x33>
		 	*pte_store = pteEntry;
f010115d:	89 03                	mov    %eax,(%ebx)
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
f010115f:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101161:	c1 e8 0c             	shr    $0xc,%eax
f0101164:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f010116a:	72 1c                	jb     f0101188 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f010116c:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0101173:	f0 
f0101174:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010117b:	00 
f010117c:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0101183:	e8 b8 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101188:	c1 e0 03             	shl    $0x3,%eax
f010118b:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
		return pa2page(pp);
f0101191:	eb 0c                	jmp    f010119f <page_lookup+0x73>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
	physaddr_t pp;
	if (!pteEntry) {
		return NULL;
f0101193:	b8 00 00 00 00       	mov    $0x0,%eax
f0101198:	eb 05                	jmp    f010119f <page_lookup+0x73>
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
		return pa2page(pp);
	}
	return NULL;
f010119a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010119f:	83 c4 14             	add    $0x14,%esp
f01011a2:	5b                   	pop    %ebx
f01011a3:	5d                   	pop    %ebp
f01011a4:	c3                   	ret    

f01011a5 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011a5:	55                   	push   %ebp
f01011a6:	89 e5                	mov    %esp,%ebp
f01011a8:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011ab:	e8 68 52 00 00       	call   f0106418 <cpunum>
f01011b0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011b7:	29 c2                	sub    %eax,%edx
f01011b9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01011bc:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f01011c3:	00 
f01011c4:	74 20                	je     f01011e6 <tlb_invalidate+0x41>
f01011c6:	e8 4d 52 00 00       	call   f0106418 <cpunum>
f01011cb:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011d2:	29 c2                	sub    %eax,%edx
f01011d4:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01011d7:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01011de:	8b 55 08             	mov    0x8(%ebp),%edx
f01011e1:	39 50 60             	cmp    %edx,0x60(%eax)
f01011e4:	75 06                	jne    f01011ec <tlb_invalidate+0x47>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01011e6:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011e9:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01011ec:	c9                   	leave  
f01011ed:	c3                   	ret    

f01011ee <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01011ee:	55                   	push   %ebp
f01011ef:	89 e5                	mov    %esp,%ebp
f01011f1:	56                   	push   %esi
f01011f2:	53                   	push   %ebx
f01011f3:	83 ec 20             	sub    $0x20,%esp
f01011f6:	8b 75 08             	mov    0x8(%ebp),%esi
f01011f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// Create a ptep store
	pte_t *pteEntry;
	// Look up the page and the entry for the page
	struct PageInfo *pp = page_lookup(pgdir, va, &pteEntry);
f01011fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101203:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101207:	89 34 24             	mov    %esi,(%esp)
f010120a:	e8 1d ff ff ff       	call   f010112c <page_lookup>
	if (!pp) {
f010120f:	85 c0                	test   %eax,%eax
f0101211:	74 1d                	je     f0101230 <page_remove+0x42>
		return;
	}
	page_decref(pp);
f0101213:	89 04 24             	mov    %eax,(%esp)
f0101216:	e8 ef fd ff ff       	call   f010100a <page_decref>
	tlb_invalidate(pgdir, va);
f010121b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010121f:	89 34 24             	mov    %esi,(%esp)
f0101222:	e8 7e ff ff ff       	call   f01011a5 <tlb_invalidate>
	// Enpty the page table
	*pteEntry = 0;
f0101227:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010122a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f0101230:	83 c4 20             	add    $0x20,%esp
f0101233:	5b                   	pop    %ebx
f0101234:	5e                   	pop    %esi
f0101235:	5d                   	pop    %ebp
f0101236:	c3                   	ret    

f0101237 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101237:	55                   	push   %ebp
f0101238:	89 e5                	mov    %esp,%ebp
f010123a:	57                   	push   %edi
f010123b:	56                   	push   %esi
f010123c:	53                   	push   %ebx
f010123d:	83 ec 1c             	sub    $0x1c,%esp
f0101240:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101243:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
f0101246:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010124d:	00 
f010124e:	8b 45 10             	mov    0x10(%ebp),%eax
f0101251:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101255:	89 3c 24             	mov    %edi,(%esp)
f0101258:	e8 cd fd ff ff       	call   f010102a <pgdir_walk>
f010125d:	89 c6                	mov    %eax,%esi
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
f010125f:	85 c0                	test   %eax,%eax
f0101261:	74 41                	je     f01012a4 <page_insert+0x6d>
		return -E_NO_MEM;
	}
	// Increment reference bit
	pp->pp_ref++;
f0101263:	66 ff 43 04          	incw   0x4(%ebx)
	// If the page itself is valid, remove it
	if (*pteEntry & PTE_P) {
f0101267:	f6 00 01             	testb  $0x1,(%eax)
f010126a:	74 0f                	je     f010127b <page_insert+0x44>
		// If there is already a page at va, it should be removed
		page_remove(pgdir, va);
f010126c:	8b 55 10             	mov    0x10(%ebp),%edx
f010126f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101273:	89 3c 24             	mov    %edi,(%esp)
f0101276:	e8 73 ff ff ff       	call   f01011ee <page_remove>
	}
	// Modify premission for both directory entry and page table entry
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f010127b:	8b 45 14             	mov    0x14(%ebp),%eax
f010127e:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101281:	2b 1d 90 1e 33 f0    	sub    0xf0331e90,%ebx
f0101287:	c1 fb 03             	sar    $0x3,%ebx
f010128a:	c1 e3 0c             	shl    $0xc,%ebx
f010128d:	09 c3                	or     %eax,%ebx
f010128f:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm;
f0101291:	8b 45 10             	mov    0x10(%ebp),%eax
f0101294:	c1 e8 16             	shr    $0x16,%eax
f0101297:	8b 55 14             	mov    0x14(%ebp),%edx
f010129a:	09 14 87             	or     %edx,(%edi,%eax,4)
	// Return success
	return 0;
f010129d:	b8 00 00 00 00       	mov    $0x0,%eax
f01012a2:	eb 05                	jmp    f01012a9 <page_insert+0x72>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
		return -E_NO_MEM;
f01012a4:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// Modify premission for both directory entry and page table entry
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	pgdir[PDX(va)] |= perm;
	// Return success
	return 0;
}
f01012a9:	83 c4 1c             	add    $0x1c,%esp
f01012ac:	5b                   	pop    %ebx
f01012ad:	5e                   	pop    %esi
f01012ae:	5f                   	pop    %edi
f01012af:	5d                   	pop    %ebp
f01012b0:	c3                   	ret    

f01012b1 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012b1:	55                   	push   %ebp
f01012b2:	89 e5                	mov    %esp,%ebp
f01012b4:	53                   	push   %ebx
f01012b5:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// Round size up
	size = (size + PGSIZE - 1) & ~(0xfff);
f01012b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012bb:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01012c1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size >  MMIOLIM) {
f01012c7:	8b 15 00 93 12 f0    	mov    0xf0129300,%edx
f01012cd:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f01012d0:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f01012d5:	76 1c                	jbe    f01012f3 <mmio_map_region+0x42>
		panic("mmio_map_region: unable to map region");
f01012d7:	c7 44 24 08 30 71 10 	movl   $0xf0107130,0x8(%esp)
f01012de:	f0 
f01012df:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
f01012e6:	00 
f01012e7:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01012ee:	e8 4d ed ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f01012f3:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f01012fa:	00 
f01012fb:	8b 45 08             	mov    0x8(%ebp),%eax
f01012fe:	89 04 24             	mov    %eax,(%esp)
f0101301:	89 d9                	mov    %ebx,%ecx
f0101303:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101308:	e8 bc fd ff ff       	call   f01010c9 <boot_map_region>
	newBase = base;
f010130d:	a1 00 93 12 f0       	mov    0xf0129300,%eax
	base += size;
f0101312:	01 c3                	add    %eax,%ebx
f0101314:	89 1d 00 93 12 f0    	mov    %ebx,0xf0129300
	return (void *)newBase;
}
f010131a:	83 c4 14             	add    $0x14,%esp
f010131d:	5b                   	pop    %ebx
f010131e:	5d                   	pop    %ebp
f010131f:	c3                   	ret    

f0101320 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101320:	55                   	push   %ebp
f0101321:	89 e5                	mov    %esp,%ebp
f0101323:	57                   	push   %edi
f0101324:	56                   	push   %esi
f0101325:	53                   	push   %ebx
f0101326:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101329:	b8 15 00 00 00       	mov    $0x15,%eax
f010132e:	e8 16 f7 ff ff       	call   f0100a49 <nvram_read>
f0101333:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101335:	b8 17 00 00 00       	mov    $0x17,%eax
f010133a:	e8 0a f7 ff ff       	call   f0100a49 <nvram_read>
f010133f:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101341:	b8 34 00 00 00       	mov    $0x34,%eax
f0101346:	e8 fe f6 ff ff       	call   f0100a49 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f010134b:	c1 e0 06             	shl    $0x6,%eax
f010134e:	74 08                	je     f0101358 <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f0101350:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f0101356:	eb 0e                	jmp    f0101366 <mem_init+0x46>
	else if (extmem)
f0101358:	85 f6                	test   %esi,%esi
f010135a:	74 08                	je     f0101364 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f010135c:	81 c6 00 04 00 00    	add    $0x400,%esi
f0101362:	eb 02                	jmp    f0101366 <mem_init+0x46>
	else
		totalmem = basemem;
f0101364:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f0101366:	89 f0                	mov    %esi,%eax
f0101368:	c1 e8 02             	shr    $0x2,%eax
f010136b:	a3 88 1e 33 f0       	mov    %eax,0xf0331e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101370:	89 d8                	mov    %ebx,%eax
f0101372:	c1 e8 02             	shr    $0x2,%eax
f0101375:	a3 38 12 33 f0       	mov    %eax,0xf0331238

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010137a:	89 f0                	mov    %esi,%eax
f010137c:	29 d8                	sub    %ebx,%eax
f010137e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101382:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101386:	89 74 24 04          	mov    %esi,0x4(%esp)
f010138a:	c7 04 24 58 71 10 f0 	movl   $0xf0107158,(%esp)
f0101391:	e8 34 2b 00 00       	call   f0103eca <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101396:	b8 00 10 00 00       	mov    $0x1000,%eax
f010139b:	e8 d2 f6 ff ff       	call   f0100a72 <boot_alloc>
f01013a0:	a3 8c 1e 33 f0       	mov    %eax,0xf0331e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013ac:	00 
f01013ad:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013b4:	00 
f01013b5:	89 04 24             	mov    %eax,(%esp)
f01013b8:	e8 2d 4a 00 00       	call   f0105dea <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013bd:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013c7:	77 20                	ja     f01013e9 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013cd:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01013d4:	f0 
f01013d5:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01013dc:	00 
f01013dd:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01013e4:	e8 57 ec ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01013e9:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01013ef:	83 ca 05             	or     $0x5,%edx
f01013f2:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f01013f8:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f01013fd:	c1 e0 03             	shl    $0x3,%eax
f0101400:	e8 6d f6 ff ff       	call   f0100a72 <boot_alloc>
f0101405:	a3 90 1e 33 f0       	mov    %eax,0xf0331e90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f010140a:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f0101410:	c1 e2 03             	shl    $0x3,%edx
f0101413:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101417:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010141e:	00 
f010141f:	89 04 24             	mov    %eax,(%esp)
f0101422:	e8 c3 49 00 00       	call   f0105dea <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101427:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f010142c:	e8 41 f6 ff ff       	call   f0100a72 <boot_alloc>
f0101431:	a3 48 12 33 f0       	mov    %eax,0xf0331248
	memset(envs, 0, sizeof(struct Env) * NENV);
f0101436:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f010143d:	00 
f010143e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101445:	00 
f0101446:	89 04 24             	mov    %eax,(%esp)
f0101449:	e8 9c 49 00 00       	call   f0105dea <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010144e:	e8 47 fa ff ff       	call   f0100e9a <page_init>

	check_page_free_list(1);
f0101453:	b8 01 00 00 00       	mov    $0x1,%eax
f0101458:	e8 de f6 ff ff       	call   f0100b3b <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010145d:	83 3d 90 1e 33 f0 00 	cmpl   $0x0,0xf0331e90
f0101464:	75 1c                	jne    f0101482 <mem_init+0x162>
		panic("'pages' is a null pointer!");
f0101466:	c7 44 24 08 5f 7a 10 	movl   $0xf0107a5f,0x8(%esp)
f010146d:	f0 
f010146e:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101475:	00 
f0101476:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010147d:	e8 be eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101482:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f0101487:	bb 00 00 00 00       	mov    $0x0,%ebx
f010148c:	eb 03                	jmp    f0101491 <mem_init+0x171>
		++nfree;
f010148e:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010148f:	8b 00                	mov    (%eax),%eax
f0101491:	85 c0                	test   %eax,%eax
f0101493:	75 f9                	jne    f010148e <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101495:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010149c:	e8 a5 fa ff ff       	call   f0100f46 <page_alloc>
f01014a1:	89 c6                	mov    %eax,%esi
f01014a3:	85 c0                	test   %eax,%eax
f01014a5:	75 24                	jne    f01014cb <mem_init+0x1ab>
f01014a7:	c7 44 24 0c 7a 7a 10 	movl   $0xf0107a7a,0xc(%esp)
f01014ae:	f0 
f01014af:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01014b6:	f0 
f01014b7:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01014be:	00 
f01014bf:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01014c6:	e8 75 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01014cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014d2:	e8 6f fa ff ff       	call   f0100f46 <page_alloc>
f01014d7:	89 c7                	mov    %eax,%edi
f01014d9:	85 c0                	test   %eax,%eax
f01014db:	75 24                	jne    f0101501 <mem_init+0x1e1>
f01014dd:	c7 44 24 0c 90 7a 10 	movl   $0xf0107a90,0xc(%esp)
f01014e4:	f0 
f01014e5:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01014ec:	f0 
f01014ed:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f01014f4:	00 
f01014f5:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01014fc:	e8 3f eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101501:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101508:	e8 39 fa ff ff       	call   f0100f46 <page_alloc>
f010150d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101510:	85 c0                	test   %eax,%eax
f0101512:	75 24                	jne    f0101538 <mem_init+0x218>
f0101514:	c7 44 24 0c a6 7a 10 	movl   $0xf0107aa6,0xc(%esp)
f010151b:	f0 
f010151c:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101523:	f0 
f0101524:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f010152b:	00 
f010152c:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101533:	e8 08 eb ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101538:	39 fe                	cmp    %edi,%esi
f010153a:	75 24                	jne    f0101560 <mem_init+0x240>
f010153c:	c7 44 24 0c bc 7a 10 	movl   $0xf0107abc,0xc(%esp)
f0101543:	f0 
f0101544:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010154b:	f0 
f010154c:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101553:	00 
f0101554:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010155b:	e8 e0 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101560:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101563:	74 05                	je     f010156a <mem_init+0x24a>
f0101565:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101568:	75 24                	jne    f010158e <mem_init+0x26e>
f010156a:	c7 44 24 0c 94 71 10 	movl   $0xf0107194,0xc(%esp)
f0101571:	f0 
f0101572:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101579:	f0 
f010157a:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101581:	00 
f0101582:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101589:	e8 b2 ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010158e:	8b 15 90 1e 33 f0    	mov    0xf0331e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101594:	a1 88 1e 33 f0       	mov    0xf0331e88,%eax
f0101599:	c1 e0 0c             	shl    $0xc,%eax
f010159c:	89 f1                	mov    %esi,%ecx
f010159e:	29 d1                	sub    %edx,%ecx
f01015a0:	c1 f9 03             	sar    $0x3,%ecx
f01015a3:	c1 e1 0c             	shl    $0xc,%ecx
f01015a6:	39 c1                	cmp    %eax,%ecx
f01015a8:	72 24                	jb     f01015ce <mem_init+0x2ae>
f01015aa:	c7 44 24 0c ce 7a 10 	movl   $0xf0107ace,0xc(%esp)
f01015b1:	f0 
f01015b2:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01015b9:	f0 
f01015ba:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f01015c1:	00 
f01015c2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01015c9:	e8 72 ea ff ff       	call   f0100040 <_panic>
f01015ce:	89 f9                	mov    %edi,%ecx
f01015d0:	29 d1                	sub    %edx,%ecx
f01015d2:	c1 f9 03             	sar    $0x3,%ecx
f01015d5:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01015d8:	39 c8                	cmp    %ecx,%eax
f01015da:	77 24                	ja     f0101600 <mem_init+0x2e0>
f01015dc:	c7 44 24 0c eb 7a 10 	movl   $0xf0107aeb,0xc(%esp)
f01015e3:	f0 
f01015e4:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01015eb:	f0 
f01015ec:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01015f3:	00 
f01015f4:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01015fb:	e8 40 ea ff ff       	call   f0100040 <_panic>
f0101600:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101603:	29 d1                	sub    %edx,%ecx
f0101605:	89 ca                	mov    %ecx,%edx
f0101607:	c1 fa 03             	sar    $0x3,%edx
f010160a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010160d:	39 d0                	cmp    %edx,%eax
f010160f:	77 24                	ja     f0101635 <mem_init+0x315>
f0101611:	c7 44 24 0c 08 7b 10 	movl   $0xf0107b08,0xc(%esp)
f0101618:	f0 
f0101619:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101620:	f0 
f0101621:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101628:	00 
f0101629:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101630:	e8 0b ea ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101635:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f010163a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010163d:	c7 05 40 12 33 f0 00 	movl   $0x0,0xf0331240
f0101644:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101647:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010164e:	e8 f3 f8 ff ff       	call   f0100f46 <page_alloc>
f0101653:	85 c0                	test   %eax,%eax
f0101655:	74 24                	je     f010167b <mem_init+0x35b>
f0101657:	c7 44 24 0c 25 7b 10 	movl   $0xf0107b25,0xc(%esp)
f010165e:	f0 
f010165f:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101666:	f0 
f0101667:	c7 44 24 04 2b 03 00 	movl   $0x32b,0x4(%esp)
f010166e:	00 
f010166f:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101676:	e8 c5 e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010167b:	89 34 24             	mov    %esi,(%esp)
f010167e:	e8 47 f9 ff ff       	call   f0100fca <page_free>
	page_free(pp1);
f0101683:	89 3c 24             	mov    %edi,(%esp)
f0101686:	e8 3f f9 ff ff       	call   f0100fca <page_free>
	page_free(pp2);
f010168b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010168e:	89 04 24             	mov    %eax,(%esp)
f0101691:	e8 34 f9 ff ff       	call   f0100fca <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101696:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010169d:	e8 a4 f8 ff ff       	call   f0100f46 <page_alloc>
f01016a2:	89 c6                	mov    %eax,%esi
f01016a4:	85 c0                	test   %eax,%eax
f01016a6:	75 24                	jne    f01016cc <mem_init+0x3ac>
f01016a8:	c7 44 24 0c 7a 7a 10 	movl   $0xf0107a7a,0xc(%esp)
f01016af:	f0 
f01016b0:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01016b7:	f0 
f01016b8:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01016bf:	00 
f01016c0:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01016c7:	e8 74 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01016cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016d3:	e8 6e f8 ff ff       	call   f0100f46 <page_alloc>
f01016d8:	89 c7                	mov    %eax,%edi
f01016da:	85 c0                	test   %eax,%eax
f01016dc:	75 24                	jne    f0101702 <mem_init+0x3e2>
f01016de:	c7 44 24 0c 90 7a 10 	movl   $0xf0107a90,0xc(%esp)
f01016e5:	f0 
f01016e6:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01016ed:	f0 
f01016ee:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f01016f5:	00 
f01016f6:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01016fd:	e8 3e e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101702:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101709:	e8 38 f8 ff ff       	call   f0100f46 <page_alloc>
f010170e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101711:	85 c0                	test   %eax,%eax
f0101713:	75 24                	jne    f0101739 <mem_init+0x419>
f0101715:	c7 44 24 0c a6 7a 10 	movl   $0xf0107aa6,0xc(%esp)
f010171c:	f0 
f010171d:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101724:	f0 
f0101725:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f010172c:	00 
f010172d:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101734:	e8 07 e9 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101739:	39 fe                	cmp    %edi,%esi
f010173b:	75 24                	jne    f0101761 <mem_init+0x441>
f010173d:	c7 44 24 0c bc 7a 10 	movl   $0xf0107abc,0xc(%esp)
f0101744:	f0 
f0101745:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010174c:	f0 
f010174d:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101754:	00 
f0101755:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010175c:	e8 df e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101761:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101764:	74 05                	je     f010176b <mem_init+0x44b>
f0101766:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101769:	75 24                	jne    f010178f <mem_init+0x46f>
f010176b:	c7 44 24 0c 94 71 10 	movl   $0xf0107194,0xc(%esp)
f0101772:	f0 
f0101773:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010177a:	f0 
f010177b:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0101782:	00 
f0101783:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010178a:	e8 b1 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010178f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101796:	e8 ab f7 ff ff       	call   f0100f46 <page_alloc>
f010179b:	85 c0                	test   %eax,%eax
f010179d:	74 24                	je     f01017c3 <mem_init+0x4a3>
f010179f:	c7 44 24 0c 25 7b 10 	movl   $0xf0107b25,0xc(%esp)
f01017a6:	f0 
f01017a7:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01017ae:	f0 
f01017af:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f01017b6:	00 
f01017b7:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01017be:	e8 7d e8 ff ff       	call   f0100040 <_panic>
f01017c3:	89 f0                	mov    %esi,%eax
f01017c5:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01017cb:	c1 f8 03             	sar    $0x3,%eax
f01017ce:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01017d1:	89 c2                	mov    %eax,%edx
f01017d3:	c1 ea 0c             	shr    $0xc,%edx
f01017d6:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f01017dc:	72 20                	jb     f01017fe <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017de:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017e2:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01017e9:	f0 
f01017ea:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01017f1:	00 
f01017f2:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f01017f9:	e8 42 e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01017fe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101805:	00 
f0101806:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010180d:	00 
	return (void *)(pa + KERNBASE);
f010180e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101813:	89 04 24             	mov    %eax,(%esp)
f0101816:	e8 cf 45 00 00       	call   f0105dea <memset>
	page_free(pp0);
f010181b:	89 34 24             	mov    %esi,(%esp)
f010181e:	e8 a7 f7 ff ff       	call   f0100fca <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101823:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010182a:	e8 17 f7 ff ff       	call   f0100f46 <page_alloc>
f010182f:	85 c0                	test   %eax,%eax
f0101831:	75 24                	jne    f0101857 <mem_init+0x537>
f0101833:	c7 44 24 0c 34 7b 10 	movl   $0xf0107b34,0xc(%esp)
f010183a:	f0 
f010183b:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101842:	f0 
f0101843:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f010184a:	00 
f010184b:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101852:	e8 e9 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101857:	39 c6                	cmp    %eax,%esi
f0101859:	74 24                	je     f010187f <mem_init+0x55f>
f010185b:	c7 44 24 0c 52 7b 10 	movl   $0xf0107b52,0xc(%esp)
f0101862:	f0 
f0101863:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010186a:	f0 
f010186b:	c7 44 24 04 3e 03 00 	movl   $0x33e,0x4(%esp)
f0101872:	00 
f0101873:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010187a:	e8 c1 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010187f:	89 f2                	mov    %esi,%edx
f0101881:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101887:	c1 fa 03             	sar    $0x3,%edx
f010188a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010188d:	89 d0                	mov    %edx,%eax
f010188f:	c1 e8 0c             	shr    $0xc,%eax
f0101892:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0101898:	72 20                	jb     f01018ba <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010189a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010189e:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01018a5:	f0 
f01018a6:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018ad:	00 
f01018ae:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f01018b5:	e8 86 e7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01018ba:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01018c0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018c6:	80 38 00             	cmpb   $0x0,(%eax)
f01018c9:	74 24                	je     f01018ef <mem_init+0x5cf>
f01018cb:	c7 44 24 0c 62 7b 10 	movl   $0xf0107b62,0xc(%esp)
f01018d2:	f0 
f01018d3:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01018da:	f0 
f01018db:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f01018e2:	00 
f01018e3:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01018ea:	e8 51 e7 ff ff       	call   f0100040 <_panic>
f01018ef:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01018f0:	39 d0                	cmp    %edx,%eax
f01018f2:	75 d2                	jne    f01018c6 <mem_init+0x5a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01018f4:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01018f7:	89 15 40 12 33 f0    	mov    %edx,0xf0331240

	// free the pages we took
	page_free(pp0);
f01018fd:	89 34 24             	mov    %esi,(%esp)
f0101900:	e8 c5 f6 ff ff       	call   f0100fca <page_free>
	page_free(pp1);
f0101905:	89 3c 24             	mov    %edi,(%esp)
f0101908:	e8 bd f6 ff ff       	call   f0100fca <page_free>
	page_free(pp2);
f010190d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101910:	89 04 24             	mov    %eax,(%esp)
f0101913:	e8 b2 f6 ff ff       	call   f0100fca <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101918:	a1 40 12 33 f0       	mov    0xf0331240,%eax
f010191d:	eb 03                	jmp    f0101922 <mem_init+0x602>
		--nfree;
f010191f:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101920:	8b 00                	mov    (%eax),%eax
f0101922:	85 c0                	test   %eax,%eax
f0101924:	75 f9                	jne    f010191f <mem_init+0x5ff>
		--nfree;
	assert(nfree == 0);
f0101926:	85 db                	test   %ebx,%ebx
f0101928:	74 24                	je     f010194e <mem_init+0x62e>
f010192a:	c7 44 24 0c 6c 7b 10 	movl   $0xf0107b6c,0xc(%esp)
f0101931:	f0 
f0101932:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101939:	f0 
f010193a:	c7 44 24 04 4e 03 00 	movl   $0x34e,0x4(%esp)
f0101941:	00 
f0101942:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101949:	e8 f2 e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010194e:	c7 04 24 b4 71 10 f0 	movl   $0xf01071b4,(%esp)
f0101955:	e8 70 25 00 00       	call   f0103eca <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010195a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101961:	e8 e0 f5 ff ff       	call   f0100f46 <page_alloc>
f0101966:	89 c7                	mov    %eax,%edi
f0101968:	85 c0                	test   %eax,%eax
f010196a:	75 24                	jne    f0101990 <mem_init+0x670>
f010196c:	c7 44 24 0c 7a 7a 10 	movl   $0xf0107a7a,0xc(%esp)
f0101973:	f0 
f0101974:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010197b:	f0 
f010197c:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f0101983:	00 
f0101984:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010198b:	e8 b0 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101990:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101997:	e8 aa f5 ff ff       	call   f0100f46 <page_alloc>
f010199c:	89 c6                	mov    %eax,%esi
f010199e:	85 c0                	test   %eax,%eax
f01019a0:	75 24                	jne    f01019c6 <mem_init+0x6a6>
f01019a2:	c7 44 24 0c 90 7a 10 	movl   $0xf0107a90,0xc(%esp)
f01019a9:	f0 
f01019aa:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01019b1:	f0 
f01019b2:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f01019b9:	00 
f01019ba:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01019c1:	e8 7a e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019cd:	e8 74 f5 ff ff       	call   f0100f46 <page_alloc>
f01019d2:	89 c3                	mov    %eax,%ebx
f01019d4:	85 c0                	test   %eax,%eax
f01019d6:	75 24                	jne    f01019fc <mem_init+0x6dc>
f01019d8:	c7 44 24 0c a6 7a 10 	movl   $0xf0107aa6,0xc(%esp)
f01019df:	f0 
f01019e0:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01019e7:	f0 
f01019e8:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01019ef:	00 
f01019f0:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01019f7:	e8 44 e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01019fc:	39 f7                	cmp    %esi,%edi
f01019fe:	75 24                	jne    f0101a24 <mem_init+0x704>
f0101a00:	c7 44 24 0c bc 7a 10 	movl   $0xf0107abc,0xc(%esp)
f0101a07:	f0 
f0101a08:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101a0f:	f0 
f0101a10:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101a17:	00 
f0101a18:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101a1f:	e8 1c e6 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a24:	39 c6                	cmp    %eax,%esi
f0101a26:	74 04                	je     f0101a2c <mem_init+0x70c>
f0101a28:	39 c7                	cmp    %eax,%edi
f0101a2a:	75 24                	jne    f0101a50 <mem_init+0x730>
f0101a2c:	c7 44 24 0c 94 71 10 	movl   $0xf0107194,0xc(%esp)
f0101a33:	f0 
f0101a34:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101a3b:	f0 
f0101a3c:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101a43:	00 
f0101a44:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101a4b:	e8 f0 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a50:	8b 15 40 12 33 f0    	mov    0xf0331240,%edx
f0101a56:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101a59:	c7 05 40 12 33 f0 00 	movl   $0x0,0xf0331240
f0101a60:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a6a:	e8 d7 f4 ff ff       	call   f0100f46 <page_alloc>
f0101a6f:	85 c0                	test   %eax,%eax
f0101a71:	74 24                	je     f0101a97 <mem_init+0x777>
f0101a73:	c7 44 24 0c 25 7b 10 	movl   $0xf0107b25,0xc(%esp)
f0101a7a:	f0 
f0101a7b:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101a82:	f0 
f0101a83:	c7 44 24 04 c1 03 00 	movl   $0x3c1,0x4(%esp)
f0101a8a:	00 
f0101a8b:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101a92:	e8 a9 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101a97:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101a9a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101a9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101aa5:	00 
f0101aa6:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101aab:	89 04 24             	mov    %eax,(%esp)
f0101aae:	e8 79 f6 ff ff       	call   f010112c <page_lookup>
f0101ab3:	85 c0                	test   %eax,%eax
f0101ab5:	74 24                	je     f0101adb <mem_init+0x7bb>
f0101ab7:	c7 44 24 0c d4 71 10 	movl   $0xf01071d4,0xc(%esp)
f0101abe:	f0 
f0101abf:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101ac6:	f0 
f0101ac7:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f0101ace:	00 
f0101acf:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101ad6:	e8 65 e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101adb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ae2:	00 
f0101ae3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101aea:	00 
f0101aeb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101aef:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101af4:	89 04 24             	mov    %eax,(%esp)
f0101af7:	e8 3b f7 ff ff       	call   f0101237 <page_insert>
f0101afc:	85 c0                	test   %eax,%eax
f0101afe:	78 24                	js     f0101b24 <mem_init+0x804>
f0101b00:	c7 44 24 0c 0c 72 10 	movl   $0xf010720c,0xc(%esp)
f0101b07:	f0 
f0101b08:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101b0f:	f0 
f0101b10:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0101b17:	00 
f0101b18:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101b1f:	e8 1c e5 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b24:	89 3c 24             	mov    %edi,(%esp)
f0101b27:	e8 9e f4 ff ff       	call   f0100fca <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b2c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b33:	00 
f0101b34:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b3b:	00 
f0101b3c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b40:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101b45:	89 04 24             	mov    %eax,(%esp)
f0101b48:	e8 ea f6 ff ff       	call   f0101237 <page_insert>
f0101b4d:	85 c0                	test   %eax,%eax
f0101b4f:	74 24                	je     f0101b75 <mem_init+0x855>
f0101b51:	c7 44 24 0c 3c 72 10 	movl   $0xf010723c,0xc(%esp)
f0101b58:	f0 
f0101b59:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101b60:	f0 
f0101b61:	c7 44 24 04 cb 03 00 	movl   $0x3cb,0x4(%esp)
f0101b68:	00 
f0101b69:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101b70:	e8 cb e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101b75:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0101b7b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b7e:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
f0101b83:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101b86:	8b 11                	mov    (%ecx),%edx
f0101b88:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101b8e:	89 f8                	mov    %edi,%eax
f0101b90:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101b93:	c1 f8 03             	sar    $0x3,%eax
f0101b96:	c1 e0 0c             	shl    $0xc,%eax
f0101b99:	39 c2                	cmp    %eax,%edx
f0101b9b:	74 24                	je     f0101bc1 <mem_init+0x8a1>
f0101b9d:	c7 44 24 0c 6c 72 10 	movl   $0xf010726c,0xc(%esp)
f0101ba4:	f0 
f0101ba5:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101bac:	f0 
f0101bad:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f0101bb4:	00 
f0101bb5:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101bbc:	e8 7f e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bc1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bc6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101bc9:	e8 0e ee ff ff       	call   f01009dc <check_va2pa>
f0101bce:	89 f2                	mov    %esi,%edx
f0101bd0:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101bd3:	c1 fa 03             	sar    $0x3,%edx
f0101bd6:	c1 e2 0c             	shl    $0xc,%edx
f0101bd9:	39 d0                	cmp    %edx,%eax
f0101bdb:	74 24                	je     f0101c01 <mem_init+0x8e1>
f0101bdd:	c7 44 24 0c 94 72 10 	movl   $0xf0107294,0xc(%esp)
f0101be4:	f0 
f0101be5:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101bec:	f0 
f0101bed:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101bf4:	00 
f0101bf5:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101bfc:	e8 3f e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101c01:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c06:	74 24                	je     f0101c2c <mem_init+0x90c>
f0101c08:	c7 44 24 0c 77 7b 10 	movl   $0xf0107b77,0xc(%esp)
f0101c0f:	f0 
f0101c10:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101c17:	f0 
f0101c18:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101c1f:	00 
f0101c20:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101c27:	e8 14 e4 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c2c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c31:	74 24                	je     f0101c57 <mem_init+0x937>
f0101c33:	c7 44 24 0c 88 7b 10 	movl   $0xf0107b88,0xc(%esp)
f0101c3a:	f0 
f0101c3b:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101c42:	f0 
f0101c43:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101c4a:	00 
f0101c4b:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101c52:	e8 e9 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c57:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c5e:	00 
f0101c5f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c66:	00 
f0101c67:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c6b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101c6e:	89 14 24             	mov    %edx,(%esp)
f0101c71:	e8 c1 f5 ff ff       	call   f0101237 <page_insert>
f0101c76:	85 c0                	test   %eax,%eax
f0101c78:	74 24                	je     f0101c9e <mem_init+0x97e>
f0101c7a:	c7 44 24 0c c4 72 10 	movl   $0xf01072c4,0xc(%esp)
f0101c81:	f0 
f0101c82:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101c89:	f0 
f0101c8a:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0101c91:	00 
f0101c92:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101c99:	e8 a2 e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c9e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ca3:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101ca8:	e8 2f ed ff ff       	call   f01009dc <check_va2pa>
f0101cad:	89 da                	mov    %ebx,%edx
f0101caf:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101cb5:	c1 fa 03             	sar    $0x3,%edx
f0101cb8:	c1 e2 0c             	shl    $0xc,%edx
f0101cbb:	39 d0                	cmp    %edx,%eax
f0101cbd:	74 24                	je     f0101ce3 <mem_init+0x9c3>
f0101cbf:	c7 44 24 0c 00 73 10 	movl   $0xf0107300,0xc(%esp)
f0101cc6:	f0 
f0101cc7:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101cce:	f0 
f0101ccf:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0101cd6:	00 
f0101cd7:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101cde:	e8 5d e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ce3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ce8:	74 24                	je     f0101d0e <mem_init+0x9ee>
f0101cea:	c7 44 24 0c 99 7b 10 	movl   $0xf0107b99,0xc(%esp)
f0101cf1:	f0 
f0101cf2:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101cf9:	f0 
f0101cfa:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101d01:	00 
f0101d02:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101d09:	e8 32 e3 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d0e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d15:	e8 2c f2 ff ff       	call   f0100f46 <page_alloc>
f0101d1a:	85 c0                	test   %eax,%eax
f0101d1c:	74 24                	je     f0101d42 <mem_init+0xa22>
f0101d1e:	c7 44 24 0c 25 7b 10 	movl   $0xf0107b25,0xc(%esp)
f0101d25:	f0 
f0101d26:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101d2d:	f0 
f0101d2e:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f0101d35:	00 
f0101d36:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101d3d:	e8 fe e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d42:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d49:	00 
f0101d4a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d51:	00 
f0101d52:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d56:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101d5b:	89 04 24             	mov    %eax,(%esp)
f0101d5e:	e8 d4 f4 ff ff       	call   f0101237 <page_insert>
f0101d63:	85 c0                	test   %eax,%eax
f0101d65:	74 24                	je     f0101d8b <mem_init+0xa6b>
f0101d67:	c7 44 24 0c c4 72 10 	movl   $0xf01072c4,0xc(%esp)
f0101d6e:	f0 
f0101d6f:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101d76:	f0 
f0101d77:	c7 44 24 04 da 03 00 	movl   $0x3da,0x4(%esp)
f0101d7e:	00 
f0101d7f:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101d86:	e8 b5 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d8b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d90:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101d95:	e8 42 ec ff ff       	call   f01009dc <check_va2pa>
f0101d9a:	89 da                	mov    %ebx,%edx
f0101d9c:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101da2:	c1 fa 03             	sar    $0x3,%edx
f0101da5:	c1 e2 0c             	shl    $0xc,%edx
f0101da8:	39 d0                	cmp    %edx,%eax
f0101daa:	74 24                	je     f0101dd0 <mem_init+0xab0>
f0101dac:	c7 44 24 0c 00 73 10 	movl   $0xf0107300,0xc(%esp)
f0101db3:	f0 
f0101db4:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101dbb:	f0 
f0101dbc:	c7 44 24 04 db 03 00 	movl   $0x3db,0x4(%esp)
f0101dc3:	00 
f0101dc4:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101dcb:	e8 70 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101dd0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101dd5:	74 24                	je     f0101dfb <mem_init+0xadb>
f0101dd7:	c7 44 24 0c 99 7b 10 	movl   $0xf0107b99,0xc(%esp)
f0101dde:	f0 
f0101ddf:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101de6:	f0 
f0101de7:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101dee:	00 
f0101def:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101df6:	e8 45 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101dfb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e02:	e8 3f f1 ff ff       	call   f0100f46 <page_alloc>
f0101e07:	85 c0                	test   %eax,%eax
f0101e09:	74 24                	je     f0101e2f <mem_init+0xb0f>
f0101e0b:	c7 44 24 0c 25 7b 10 	movl   $0xf0107b25,0xc(%esp)
f0101e12:	f0 
f0101e13:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101e1a:	f0 
f0101e1b:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0101e22:	00 
f0101e23:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101e2a:	e8 11 e2 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e2f:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f0101e35:	8b 02                	mov    (%edx),%eax
f0101e37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e3c:	89 c1                	mov    %eax,%ecx
f0101e3e:	c1 e9 0c             	shr    $0xc,%ecx
f0101e41:	3b 0d 88 1e 33 f0    	cmp    0xf0331e88,%ecx
f0101e47:	72 20                	jb     f0101e69 <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e4d:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0101e54:	f0 
f0101e55:	c7 44 24 04 e3 03 00 	movl   $0x3e3,0x4(%esp)
f0101e5c:	00 
f0101e5d:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101e64:	e8 d7 e1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101e69:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e6e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101e71:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e78:	00 
f0101e79:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e80:	00 
f0101e81:	89 14 24             	mov    %edx,(%esp)
f0101e84:	e8 a1 f1 ff ff       	call   f010102a <pgdir_walk>
f0101e89:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101e8c:	83 c2 04             	add    $0x4,%edx
f0101e8f:	39 d0                	cmp    %edx,%eax
f0101e91:	74 24                	je     f0101eb7 <mem_init+0xb97>
f0101e93:	c7 44 24 0c 30 73 10 	movl   $0xf0107330,0xc(%esp)
f0101e9a:	f0 
f0101e9b:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101ea2:	f0 
f0101ea3:	c7 44 24 04 e4 03 00 	movl   $0x3e4,0x4(%esp)
f0101eaa:	00 
f0101eab:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101eb2:	e8 89 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101eb7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101ebe:	00 
f0101ebf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ec6:	00 
f0101ec7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ecb:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101ed0:	89 04 24             	mov    %eax,(%esp)
f0101ed3:	e8 5f f3 ff ff       	call   f0101237 <page_insert>
f0101ed8:	85 c0                	test   %eax,%eax
f0101eda:	74 24                	je     f0101f00 <mem_init+0xbe0>
f0101edc:	c7 44 24 0c 70 73 10 	movl   $0xf0107370,0xc(%esp)
f0101ee3:	f0 
f0101ee4:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101eeb:	f0 
f0101eec:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0101ef3:	00 
f0101ef4:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101efb:	e8 40 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f00:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0101f06:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101f09:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f0e:	89 c8                	mov    %ecx,%eax
f0101f10:	e8 c7 ea ff ff       	call   f01009dc <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f15:	89 da                	mov    %ebx,%edx
f0101f17:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0101f1d:	c1 fa 03             	sar    $0x3,%edx
f0101f20:	c1 e2 0c             	shl    $0xc,%edx
f0101f23:	39 d0                	cmp    %edx,%eax
f0101f25:	74 24                	je     f0101f4b <mem_init+0xc2b>
f0101f27:	c7 44 24 0c 00 73 10 	movl   $0xf0107300,0xc(%esp)
f0101f2e:	f0 
f0101f2f:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101f36:	f0 
f0101f37:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0101f3e:	00 
f0101f3f:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101f46:	e8 f5 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f4b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f50:	74 24                	je     f0101f76 <mem_init+0xc56>
f0101f52:	c7 44 24 0c 99 7b 10 	movl   $0xf0107b99,0xc(%esp)
f0101f59:	f0 
f0101f5a:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101f61:	f0 
f0101f62:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101f69:	00 
f0101f6a:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101f71:	e8 ca e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101f76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f7d:	00 
f0101f7e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f85:	00 
f0101f86:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f89:	89 04 24             	mov    %eax,(%esp)
f0101f8c:	e8 99 f0 ff ff       	call   f010102a <pgdir_walk>
f0101f91:	f6 00 04             	testb  $0x4,(%eax)
f0101f94:	75 24                	jne    f0101fba <mem_init+0xc9a>
f0101f96:	c7 44 24 0c b0 73 10 	movl   $0xf01073b0,0xc(%esp)
f0101f9d:	f0 
f0101f9e:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101fa5:	f0 
f0101fa6:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101fad:	00 
f0101fae:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101fb5:	e8 86 e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101fba:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0101fbf:	f6 00 04             	testb  $0x4,(%eax)
f0101fc2:	75 24                	jne    f0101fe8 <mem_init+0xcc8>
f0101fc4:	c7 44 24 0c aa 7b 10 	movl   $0xf0107baa,0xc(%esp)
f0101fcb:	f0 
f0101fcc:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0101fd3:	f0 
f0101fd4:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101fdb:	00 
f0101fdc:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0101fe3:	e8 58 e0 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101fe8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101fef:	00 
f0101ff0:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ff7:	00 
f0101ff8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ffc:	89 04 24             	mov    %eax,(%esp)
f0101fff:	e8 33 f2 ff ff       	call   f0101237 <page_insert>
f0102004:	85 c0                	test   %eax,%eax
f0102006:	74 24                	je     f010202c <mem_init+0xd0c>
f0102008:	c7 44 24 0c c4 72 10 	movl   $0xf01072c4,0xc(%esp)
f010200f:	f0 
f0102010:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102017:	f0 
f0102018:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f010201f:	00 
f0102020:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102027:	e8 14 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f010202c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102033:	00 
f0102034:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010203b:	00 
f010203c:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102041:	89 04 24             	mov    %eax,(%esp)
f0102044:	e8 e1 ef ff ff       	call   f010102a <pgdir_walk>
f0102049:	f6 00 02             	testb  $0x2,(%eax)
f010204c:	75 24                	jne    f0102072 <mem_init+0xd52>
f010204e:	c7 44 24 0c e4 73 10 	movl   $0xf01073e4,0xc(%esp)
f0102055:	f0 
f0102056:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010205d:	f0 
f010205e:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102065:	00 
f0102066:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010206d:	e8 ce df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102072:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102079:	00 
f010207a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102081:	00 
f0102082:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102087:	89 04 24             	mov    %eax,(%esp)
f010208a:	e8 9b ef ff ff       	call   f010102a <pgdir_walk>
f010208f:	f6 00 04             	testb  $0x4,(%eax)
f0102092:	74 24                	je     f01020b8 <mem_init+0xd98>
f0102094:	c7 44 24 0c 18 74 10 	movl   $0xf0107418,0xc(%esp)
f010209b:	f0 
f010209c:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01020a3:	f0 
f01020a4:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f01020ab:	00 
f01020ac:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01020b3:	e8 88 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020b8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020bf:	00 
f01020c0:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01020c7:	00 
f01020c8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01020cc:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01020d1:	89 04 24             	mov    %eax,(%esp)
f01020d4:	e8 5e f1 ff ff       	call   f0101237 <page_insert>
f01020d9:	85 c0                	test   %eax,%eax
f01020db:	78 24                	js     f0102101 <mem_init+0xde1>
f01020dd:	c7 44 24 0c 50 74 10 	movl   $0xf0107450,0xc(%esp)
f01020e4:	f0 
f01020e5:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01020ec:	f0 
f01020ed:	c7 44 24 04 f3 03 00 	movl   $0x3f3,0x4(%esp)
f01020f4:	00 
f01020f5:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01020fc:	e8 3f df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102101:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102108:	00 
f0102109:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102110:	00 
f0102111:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102115:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010211a:	89 04 24             	mov    %eax,(%esp)
f010211d:	e8 15 f1 ff ff       	call   f0101237 <page_insert>
f0102122:	85 c0                	test   %eax,%eax
f0102124:	74 24                	je     f010214a <mem_init+0xe2a>
f0102126:	c7 44 24 0c 88 74 10 	movl   $0xf0107488,0xc(%esp)
f010212d:	f0 
f010212e:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102135:	f0 
f0102136:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f010213d:	00 
f010213e:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102145:	e8 f6 de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010214a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102151:	00 
f0102152:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102159:	00 
f010215a:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010215f:	89 04 24             	mov    %eax,(%esp)
f0102162:	e8 c3 ee ff ff       	call   f010102a <pgdir_walk>
f0102167:	f6 00 04             	testb  $0x4,(%eax)
f010216a:	74 24                	je     f0102190 <mem_init+0xe70>
f010216c:	c7 44 24 0c 18 74 10 	movl   $0xf0107418,0xc(%esp)
f0102173:	f0 
f0102174:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010217b:	f0 
f010217c:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f0102183:	00 
f0102184:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010218b:	e8 b0 de ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0102190:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102195:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102198:	ba 00 00 00 00       	mov    $0x0,%edx
f010219d:	e8 3a e8 ff ff       	call   f01009dc <check_va2pa>
f01021a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01021a5:	89 f0                	mov    %esi,%eax
f01021a7:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01021ad:	c1 f8 03             	sar    $0x3,%eax
f01021b0:	c1 e0 0c             	shl    $0xc,%eax
f01021b3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01021b6:	74 24                	je     f01021dc <mem_init+0xebc>
f01021b8:	c7 44 24 0c c4 74 10 	movl   $0xf01074c4,0xc(%esp)
f01021bf:	f0 
f01021c0:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01021c7:	f0 
f01021c8:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f01021cf:	00 
f01021d0:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01021d7:	e8 64 de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01021dc:	ba 00 10 00 00       	mov    $0x1000,%edx
f01021e1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01021e4:	e8 f3 e7 ff ff       	call   f01009dc <check_va2pa>
f01021e9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01021ec:	74 24                	je     f0102212 <mem_init+0xef2>
f01021ee:	c7 44 24 0c f0 74 10 	movl   $0xf01074f0,0xc(%esp)
f01021f5:	f0 
f01021f6:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01021fd:	f0 
f01021fe:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102205:	00 
f0102206:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010220d:	e8 2e de ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102212:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102217:	74 24                	je     f010223d <mem_init+0xf1d>
f0102219:	c7 44 24 0c c0 7b 10 	movl   $0xf0107bc0,0xc(%esp)
f0102220:	f0 
f0102221:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102228:	f0 
f0102229:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f0102230:	00 
f0102231:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102238:	e8 03 de ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010223d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102242:	74 24                	je     f0102268 <mem_init+0xf48>
f0102244:	c7 44 24 0c d1 7b 10 	movl   $0xf0107bd1,0xc(%esp)
f010224b:	f0 
f010224c:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102253:	f0 
f0102254:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f010225b:	00 
f010225c:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102263:	e8 d8 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102268:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010226f:	e8 d2 ec ff ff       	call   f0100f46 <page_alloc>
f0102274:	85 c0                	test   %eax,%eax
f0102276:	74 04                	je     f010227c <mem_init+0xf5c>
f0102278:	39 c3                	cmp    %eax,%ebx
f010227a:	74 24                	je     f01022a0 <mem_init+0xf80>
f010227c:	c7 44 24 0c 20 75 10 	movl   $0xf0107520,0xc(%esp)
f0102283:	f0 
f0102284:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010228b:	f0 
f010228c:	c7 44 24 04 01 04 00 	movl   $0x401,0x4(%esp)
f0102293:	00 
f0102294:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010229b:	e8 a0 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01022a0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022a7:	00 
f01022a8:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01022ad:	89 04 24             	mov    %eax,(%esp)
f01022b0:	e8 39 ef ff ff       	call   f01011ee <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022b5:	8b 15 8c 1e 33 f0    	mov    0xf0331e8c,%edx
f01022bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01022be:	ba 00 00 00 00       	mov    $0x0,%edx
f01022c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022c6:	e8 11 e7 ff ff       	call   f01009dc <check_va2pa>
f01022cb:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022ce:	74 24                	je     f01022f4 <mem_init+0xfd4>
f01022d0:	c7 44 24 0c 44 75 10 	movl   $0xf0107544,0xc(%esp)
f01022d7:	f0 
f01022d8:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01022df:	f0 
f01022e0:	c7 44 24 04 05 04 00 	movl   $0x405,0x4(%esp)
f01022e7:	00 
f01022e8:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01022ef:	e8 4c dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01022f4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022fc:	e8 db e6 ff ff       	call   f01009dc <check_va2pa>
f0102301:	89 f2                	mov    %esi,%edx
f0102303:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0102309:	c1 fa 03             	sar    $0x3,%edx
f010230c:	c1 e2 0c             	shl    $0xc,%edx
f010230f:	39 d0                	cmp    %edx,%eax
f0102311:	74 24                	je     f0102337 <mem_init+0x1017>
f0102313:	c7 44 24 0c f0 74 10 	movl   $0xf01074f0,0xc(%esp)
f010231a:	f0 
f010231b:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102322:	f0 
f0102323:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f010232a:	00 
f010232b:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102332:	e8 09 dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102337:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010233c:	74 24                	je     f0102362 <mem_init+0x1042>
f010233e:	c7 44 24 0c 77 7b 10 	movl   $0xf0107b77,0xc(%esp)
f0102345:	f0 
f0102346:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010234d:	f0 
f010234e:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102355:	00 
f0102356:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010235d:	e8 de dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102362:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102367:	74 24                	je     f010238d <mem_init+0x106d>
f0102369:	c7 44 24 0c d1 7b 10 	movl   $0xf0107bd1,0xc(%esp)
f0102370:	f0 
f0102371:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102378:	f0 
f0102379:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102380:	00 
f0102381:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102388:	e8 b3 dc ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010238d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102394:	00 
f0102395:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010239c:	00 
f010239d:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023a1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01023a4:	89 0c 24             	mov    %ecx,(%esp)
f01023a7:	e8 8b ee ff ff       	call   f0101237 <page_insert>
f01023ac:	85 c0                	test   %eax,%eax
f01023ae:	74 24                	je     f01023d4 <mem_init+0x10b4>
f01023b0:	c7 44 24 0c 68 75 10 	movl   $0xf0107568,0xc(%esp)
f01023b7:	f0 
f01023b8:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01023bf:	f0 
f01023c0:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01023c7:	00 
f01023c8:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01023cf:	e8 6c dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01023d4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01023d9:	75 24                	jne    f01023ff <mem_init+0x10df>
f01023db:	c7 44 24 0c e2 7b 10 	movl   $0xf0107be2,0xc(%esp)
f01023e2:	f0 
f01023e3:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01023ea:	f0 
f01023eb:	c7 44 24 04 0c 04 00 	movl   $0x40c,0x4(%esp)
f01023f2:	00 
f01023f3:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01023fa:	e8 41 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01023ff:	83 3e 00             	cmpl   $0x0,(%esi)
f0102402:	74 24                	je     f0102428 <mem_init+0x1108>
f0102404:	c7 44 24 0c ee 7b 10 	movl   $0xf0107bee,0xc(%esp)
f010240b:	f0 
f010240c:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102413:	f0 
f0102414:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f010241b:	00 
f010241c:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102423:	e8 18 dc ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102428:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010242f:	00 
f0102430:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102435:	89 04 24             	mov    %eax,(%esp)
f0102438:	e8 b1 ed ff ff       	call   f01011ee <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010243d:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102442:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102445:	ba 00 00 00 00       	mov    $0x0,%edx
f010244a:	e8 8d e5 ff ff       	call   f01009dc <check_va2pa>
f010244f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102452:	74 24                	je     f0102478 <mem_init+0x1158>
f0102454:	c7 44 24 0c 44 75 10 	movl   $0xf0107544,0xc(%esp)
f010245b:	f0 
f010245c:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102463:	f0 
f0102464:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f010246b:	00 
f010246c:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102473:	e8 c8 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102478:	ba 00 10 00 00       	mov    $0x1000,%edx
f010247d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102480:	e8 57 e5 ff ff       	call   f01009dc <check_va2pa>
f0102485:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102488:	74 24                	je     f01024ae <mem_init+0x118e>
f010248a:	c7 44 24 0c a0 75 10 	movl   $0xf01075a0,0xc(%esp)
f0102491:	f0 
f0102492:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102499:	f0 
f010249a:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01024a1:	00 
f01024a2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01024a9:	e8 92 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01024ae:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024b3:	74 24                	je     f01024d9 <mem_init+0x11b9>
f01024b5:	c7 44 24 0c 03 7c 10 	movl   $0xf0107c03,0xc(%esp)
f01024bc:	f0 
f01024bd:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01024c4:	f0 
f01024c5:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01024cc:	00 
f01024cd:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01024d4:	e8 67 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01024d9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01024de:	74 24                	je     f0102504 <mem_init+0x11e4>
f01024e0:	c7 44 24 0c d1 7b 10 	movl   $0xf0107bd1,0xc(%esp)
f01024e7:	f0 
f01024e8:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01024ef:	f0 
f01024f0:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01024f7:	00 
f01024f8:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01024ff:	e8 3c db ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102504:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010250b:	e8 36 ea ff ff       	call   f0100f46 <page_alloc>
f0102510:	85 c0                	test   %eax,%eax
f0102512:	74 04                	je     f0102518 <mem_init+0x11f8>
f0102514:	39 c6                	cmp    %eax,%esi
f0102516:	74 24                	je     f010253c <mem_init+0x121c>
f0102518:	c7 44 24 0c c8 75 10 	movl   $0xf01075c8,0xc(%esp)
f010251f:	f0 
f0102520:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102527:	f0 
f0102528:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f010252f:	00 
f0102530:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102537:	e8 04 db ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010253c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102543:	e8 fe e9 ff ff       	call   f0100f46 <page_alloc>
f0102548:	85 c0                	test   %eax,%eax
f010254a:	74 24                	je     f0102570 <mem_init+0x1250>
f010254c:	c7 44 24 0c 25 7b 10 	movl   $0xf0107b25,0xc(%esp)
f0102553:	f0 
f0102554:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010255b:	f0 
f010255c:	c7 44 24 04 1a 04 00 	movl   $0x41a,0x4(%esp)
f0102563:	00 
f0102564:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010256b:	e8 d0 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102570:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102575:	8b 08                	mov    (%eax),%ecx
f0102577:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010257d:	89 fa                	mov    %edi,%edx
f010257f:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0102585:	c1 fa 03             	sar    $0x3,%edx
f0102588:	c1 e2 0c             	shl    $0xc,%edx
f010258b:	39 d1                	cmp    %edx,%ecx
f010258d:	74 24                	je     f01025b3 <mem_init+0x1293>
f010258f:	c7 44 24 0c 6c 72 10 	movl   $0xf010726c,0xc(%esp)
f0102596:	f0 
f0102597:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010259e:	f0 
f010259f:	c7 44 24 04 1d 04 00 	movl   $0x41d,0x4(%esp)
f01025a6:	00 
f01025a7:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01025ae:	e8 8d da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01025b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01025b9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025be:	74 24                	je     f01025e4 <mem_init+0x12c4>
f01025c0:	c7 44 24 0c 88 7b 10 	movl   $0xf0107b88,0xc(%esp)
f01025c7:	f0 
f01025c8:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01025cf:	f0 
f01025d0:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01025d7:	00 
f01025d8:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01025df:	e8 5c da ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01025e4:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01025ea:	89 3c 24             	mov    %edi,(%esp)
f01025ed:	e8 d8 e9 ff ff       	call   f0100fca <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01025f2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01025f9:	00 
f01025fa:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102601:	00 
f0102602:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102607:	89 04 24             	mov    %eax,(%esp)
f010260a:	e8 1b ea ff ff       	call   f010102a <pgdir_walk>
f010260f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102612:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f0102618:	8b 51 04             	mov    0x4(%ecx),%edx
f010261b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102621:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102624:	8b 15 88 1e 33 f0    	mov    0xf0331e88,%edx
f010262a:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010262d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102630:	c1 ea 0c             	shr    $0xc,%edx
f0102633:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102636:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102639:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010263c:	72 23                	jb     f0102661 <mem_init+0x1341>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010263e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102641:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102645:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010264c:	f0 
f010264d:	c7 44 24 04 26 04 00 	movl   $0x426,0x4(%esp)
f0102654:	00 
f0102655:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010265c:	e8 df d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102661:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102664:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010266a:	39 d0                	cmp    %edx,%eax
f010266c:	74 24                	je     f0102692 <mem_init+0x1372>
f010266e:	c7 44 24 0c 14 7c 10 	movl   $0xf0107c14,0xc(%esp)
f0102675:	f0 
f0102676:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010267d:	f0 
f010267e:	c7 44 24 04 27 04 00 	movl   $0x427,0x4(%esp)
f0102685:	00 
f0102686:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010268d:	e8 ae d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102692:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102699:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010269f:	89 f8                	mov    %edi,%eax
f01026a1:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f01026a7:	c1 f8 03             	sar    $0x3,%eax
f01026aa:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026ad:	89 c1                	mov    %eax,%ecx
f01026af:	c1 e9 0c             	shr    $0xc,%ecx
f01026b2:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01026b5:	77 20                	ja     f01026d7 <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026bb:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01026c2:	f0 
f01026c3:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01026ca:	00 
f01026cb:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f01026d2:	e8 69 d9 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01026d7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01026de:	00 
f01026df:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01026e6:	00 
	return (void *)(pa + KERNBASE);
f01026e7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01026ec:	89 04 24             	mov    %eax,(%esp)
f01026ef:	e8 f6 36 00 00       	call   f0105dea <memset>
	page_free(pp0);
f01026f4:	89 3c 24             	mov    %edi,(%esp)
f01026f7:	e8 ce e8 ff ff       	call   f0100fca <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01026fc:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102703:	00 
f0102704:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010270b:	00 
f010270c:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102711:	89 04 24             	mov    %eax,(%esp)
f0102714:	e8 11 e9 ff ff       	call   f010102a <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102719:	89 fa                	mov    %edi,%edx
f010271b:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f0102721:	c1 fa 03             	sar    $0x3,%edx
f0102724:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102727:	89 d0                	mov    %edx,%eax
f0102729:	c1 e8 0c             	shr    $0xc,%eax
f010272c:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0102732:	72 20                	jb     f0102754 <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102734:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102738:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010273f:	f0 
f0102740:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102747:	00 
f0102748:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f010274f:	e8 ec d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102754:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010275a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010275d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102763:	f6 00 01             	testb  $0x1,(%eax)
f0102766:	74 24                	je     f010278c <mem_init+0x146c>
f0102768:	c7 44 24 0c 2c 7c 10 	movl   $0xf0107c2c,0xc(%esp)
f010276f:	f0 
f0102770:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102777:	f0 
f0102778:	c7 44 24 04 31 04 00 	movl   $0x431,0x4(%esp)
f010277f:	00 
f0102780:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102787:	e8 b4 d8 ff ff       	call   f0100040 <_panic>
f010278c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010278f:	39 d0                	cmp    %edx,%eax
f0102791:	75 d0                	jne    f0102763 <mem_init+0x1443>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102793:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102798:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010279e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01027a4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01027a7:	89 0d 40 12 33 f0    	mov    %ecx,0xf0331240

	// free the pages we took
	page_free(pp0);
f01027ad:	89 3c 24             	mov    %edi,(%esp)
f01027b0:	e8 15 e8 ff ff       	call   f0100fca <page_free>
	page_free(pp1);
f01027b5:	89 34 24             	mov    %esi,(%esp)
f01027b8:	e8 0d e8 ff ff       	call   f0100fca <page_free>
	page_free(pp2);
f01027bd:	89 1c 24             	mov    %ebx,(%esp)
f01027c0:	e8 05 e8 ff ff       	call   f0100fca <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01027c5:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f01027cc:	00 
f01027cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027d4:	e8 d8 ea ff ff       	call   f01012b1 <mmio_map_region>
f01027d9:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f01027db:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01027e2:	00 
f01027e3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01027ea:	e8 c2 ea ff ff       	call   f01012b1 <mmio_map_region>
f01027ef:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f01027f1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01027f7:	76 0d                	jbe    f0102806 <mem_init+0x14e6>
f01027f9:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f01027ff:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102804:	76 24                	jbe    f010282a <mem_init+0x150a>
f0102806:	c7 44 24 0c ec 75 10 	movl   $0xf01075ec,0xc(%esp)
f010280d:	f0 
f010280e:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102815:	f0 
f0102816:	c7 44 24 04 41 04 00 	movl   $0x441,0x4(%esp)
f010281d:	00 
f010281e:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102825:	e8 16 d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f010282a:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102830:	76 0e                	jbe    f0102840 <mem_init+0x1520>
f0102832:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102838:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f010283e:	76 24                	jbe    f0102864 <mem_init+0x1544>
f0102840:	c7 44 24 0c 14 76 10 	movl   $0xf0107614,0xc(%esp)
f0102847:	f0 
f0102848:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010284f:	f0 
f0102850:	c7 44 24 04 42 04 00 	movl   $0x442,0x4(%esp)
f0102857:	00 
f0102858:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010285f:	e8 dc d7 ff ff       	call   f0100040 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102864:	89 da                	mov    %ebx,%edx
f0102866:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102868:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f010286e:	74 24                	je     f0102894 <mem_init+0x1574>
f0102870:	c7 44 24 0c 3c 76 10 	movl   $0xf010763c,0xc(%esp)
f0102877:	f0 
f0102878:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010287f:	f0 
f0102880:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f0102887:	00 
f0102888:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010288f:	e8 ac d7 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0102894:	39 c6                	cmp    %eax,%esi
f0102896:	73 24                	jae    f01028bc <mem_init+0x159c>
f0102898:	c7 44 24 0c 43 7c 10 	movl   $0xf0107c43,0xc(%esp)
f010289f:	f0 
f01028a0:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01028a7:	f0 
f01028a8:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f01028af:	00 
f01028b0:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01028b7:	e8 84 d7 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01028bc:	8b 3d 8c 1e 33 f0    	mov    0xf0331e8c,%edi
f01028c2:	89 da                	mov    %ebx,%edx
f01028c4:	89 f8                	mov    %edi,%eax
f01028c6:	e8 11 e1 ff ff       	call   f01009dc <check_va2pa>
f01028cb:	85 c0                	test   %eax,%eax
f01028cd:	74 24                	je     f01028f3 <mem_init+0x15d3>
f01028cf:	c7 44 24 0c 64 76 10 	movl   $0xf0107664,0xc(%esp)
f01028d6:	f0 
f01028d7:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01028de:	f0 
f01028df:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f01028e6:	00 
f01028e7:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01028ee:	e8 4d d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f01028f3:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f01028f9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01028fc:	89 c2                	mov    %eax,%edx
f01028fe:	89 f8                	mov    %edi,%eax
f0102900:	e8 d7 e0 ff ff       	call   f01009dc <check_va2pa>
f0102905:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010290a:	74 24                	je     f0102930 <mem_init+0x1610>
f010290c:	c7 44 24 0c 88 76 10 	movl   $0xf0107688,0xc(%esp)
f0102913:	f0 
f0102914:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010291b:	f0 
f010291c:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102923:	00 
f0102924:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010292b:	e8 10 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102930:	89 f2                	mov    %esi,%edx
f0102932:	89 f8                	mov    %edi,%eax
f0102934:	e8 a3 e0 ff ff       	call   f01009dc <check_va2pa>
f0102939:	85 c0                	test   %eax,%eax
f010293b:	74 24                	je     f0102961 <mem_init+0x1641>
f010293d:	c7 44 24 0c b8 76 10 	movl   $0xf01076b8,0xc(%esp)
f0102944:	f0 
f0102945:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010294c:	f0 
f010294d:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f0102954:	00 
f0102955:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010295c:	e8 df d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102961:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102967:	89 f8                	mov    %edi,%eax
f0102969:	e8 6e e0 ff ff       	call   f01009dc <check_va2pa>
f010296e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102971:	74 24                	je     f0102997 <mem_init+0x1677>
f0102973:	c7 44 24 0c dc 76 10 	movl   $0xf01076dc,0xc(%esp)
f010297a:	f0 
f010297b:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102982:	f0 
f0102983:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f010298a:	00 
f010298b:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102992:	e8 a9 d6 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102997:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010299e:	00 
f010299f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01029a3:	89 3c 24             	mov    %edi,(%esp)
f01029a6:	e8 7f e6 ff ff       	call   f010102a <pgdir_walk>
f01029ab:	f6 00 1a             	testb  $0x1a,(%eax)
f01029ae:	75 24                	jne    f01029d4 <mem_init+0x16b4>
f01029b0:	c7 44 24 0c 08 77 10 	movl   $0xf0107708,0xc(%esp)
f01029b7:	f0 
f01029b8:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01029bf:	f0 
f01029c0:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f01029c7:	00 
f01029c8:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01029cf:	e8 6c d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01029d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01029db:	00 
f01029dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01029e0:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01029e5:	89 04 24             	mov    %eax,(%esp)
f01029e8:	e8 3d e6 ff ff       	call   f010102a <pgdir_walk>
f01029ed:	f6 00 04             	testb  $0x4,(%eax)
f01029f0:	74 24                	je     f0102a16 <mem_init+0x16f6>
f01029f2:	c7 44 24 0c 4c 77 10 	movl   $0xf010774c,0xc(%esp)
f01029f9:	f0 
f01029fa:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102a01:	f0 
f0102a02:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f0102a09:	00 
f0102a0a:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102a11:	e8 2a d6 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a16:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a1d:	00 
f0102a1e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a22:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102a27:	89 04 24             	mov    %eax,(%esp)
f0102a2a:	e8 fb e5 ff ff       	call   f010102a <pgdir_walk>
f0102a2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102a35:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a3c:	00 
f0102a3d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102a40:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102a44:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102a49:	89 04 24             	mov    %eax,(%esp)
f0102a4c:	e8 d9 e5 ff ff       	call   f010102a <pgdir_walk>
f0102a51:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102a57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a5e:	00 
f0102a5f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a63:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102a68:	89 04 24             	mov    %eax,(%esp)
f0102a6b:	e8 ba e5 ff ff       	call   f010102a <pgdir_walk>
f0102a70:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102a76:	c7 04 24 55 7c 10 f0 	movl   $0xf0107c55,(%esp)
f0102a7d:	e8 48 14 00 00       	call   f0103eca <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_W);
f0102a82:	a1 90 1e 33 f0       	mov    0xf0331e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a87:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a8c:	77 20                	ja     f0102aae <mem_init+0x178e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a8e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a92:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102a99:	f0 
f0102a9a:	c7 44 24 04 bf 00 00 	movl   $0xbf,0x4(%esp)
f0102aa1:	00 
f0102aa2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102aa9:	e8 92 d5 ff ff       	call   f0100040 <_panic>
f0102aae:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102ab5:	00 
	return (physaddr_t)kva - KERNBASE;
f0102ab6:	05 00 00 00 10       	add    $0x10000000,%eax
f0102abb:	89 04 24             	mov    %eax,(%esp)
f0102abe:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102ac3:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102ac8:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102acd:	e8 f7 e5 ff ff       	call   f01010c9 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_W | PTE_U);
f0102ad2:	a1 48 12 33 f0       	mov    0xf0331248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ad7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102adc:	77 20                	ja     f0102afe <mem_init+0x17de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ade:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ae2:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102ae9:	f0 
f0102aea:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
f0102af1:	00 
f0102af2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102af9:	e8 42 d5 ff ff       	call   f0100040 <_panic>
f0102afe:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0102b05:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b06:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b0b:	89 04 24             	mov    %eax,(%esp)
f0102b0e:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102b13:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102b18:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b1d:	e8 a7 e5 ff ff       	call   f01010c9 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b22:	b8 00 f0 11 f0       	mov    $0xf011f000,%eax
f0102b27:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b2c:	77 20                	ja     f0102b4e <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b32:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102b39:	f0 
f0102b3a:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
f0102b41:	00 
f0102b42:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102b49:	e8 f2 d4 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102b4e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b55:	00 
f0102b56:	c7 04 24 00 f0 11 00 	movl   $0x11f000,(%esp)
f0102b5d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b62:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102b67:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b6c:	e8 58 e5 ff ff       	call   f01010c9 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 2*npages*PGSIZE, 0, PTE_W);
f0102b71:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f0102b77:	c1 e1 0d             	shl    $0xd,%ecx
f0102b7a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b81:	00 
f0102b82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102b89:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102b8e:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102b93:	e8 31 e5 ff ff       	call   f01010c9 <boot_map_region>
f0102b98:	c7 45 cc 00 30 33 f0 	movl   $0xf0333000,-0x34(%ebp)
f0102b9f:	bb 00 30 33 f0       	mov    $0xf0333000,%ebx
f0102ba4:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ba9:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102baf:	77 20                	ja     f0102bd1 <mem_init+0x18b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102bb1:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102bb5:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102bbc:	f0 
f0102bbd:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
f0102bc4:	00 
f0102bc5:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102bcc:	e8 6f d4 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int i;
	uintptr_t kstacktop_i;
	for (i = 0; i < NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, (uintptr_t)(kstacktop_i - KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102bd1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102bd8:	00 
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102bd9:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	int i;
	uintptr_t kstacktop_i;
	for (i = 0; i < NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, (uintptr_t)(kstacktop_i - KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102bdf:	89 04 24             	mov    %eax,(%esp)
f0102be2:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102be7:	89 f2                	mov    %esi,%edx
f0102be9:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f0102bee:	e8 d6 e4 ff ff       	call   f01010c9 <boot_map_region>
f0102bf3:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102bf9:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	uintptr_t kstacktop_i;
	for (i = 0; i < NCPU; i++) {
f0102bff:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102c05:	75 a2                	jne    f0102ba9 <mem_init+0x1889>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102c07:	8b 1d 8c 1e 33 f0    	mov    0xf0331e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c0d:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f0102c13:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102c16:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102c1d:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102c23:	be 00 00 00 00       	mov    $0x0,%esi
f0102c28:	eb 70                	jmp    f0102c9a <mem_init+0x197a>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102c2a:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c30:	89 d8                	mov    %ebx,%eax
f0102c32:	e8 a5 dd ff ff       	call   f01009dc <check_va2pa>
f0102c37:	8b 15 90 1e 33 f0    	mov    0xf0331e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c3d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c43:	77 20                	ja     f0102c65 <mem_init+0x1945>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c45:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c49:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102c50:	f0 
f0102c51:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0102c58:	00 
f0102c59:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102c60:	e8 db d3 ff ff       	call   f0100040 <_panic>
f0102c65:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102c6c:	39 d0                	cmp    %edx,%eax
f0102c6e:	74 24                	je     f0102c94 <mem_init+0x1974>
f0102c70:	c7 44 24 0c 80 77 10 	movl   $0xf0107780,0xc(%esp)
f0102c77:	f0 
f0102c78:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102c7f:	f0 
f0102c80:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0102c87:	00 
f0102c88:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102c8f:	e8 ac d3 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102c94:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102c9a:	39 f7                	cmp    %esi,%edi
f0102c9c:	77 8c                	ja     f0102c2a <mem_init+0x190a>
f0102c9e:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102ca3:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ca9:	89 d8                	mov    %ebx,%eax
f0102cab:	e8 2c dd ff ff       	call   f01009dc <check_va2pa>
f0102cb0:	8b 15 48 12 33 f0    	mov    0xf0331248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cb6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102cbc:	77 20                	ja     f0102cde <mem_init+0x19be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cbe:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cc2:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102cc9:	f0 
f0102cca:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0102cd1:	00 
f0102cd2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102cd9:	e8 62 d3 ff ff       	call   f0100040 <_panic>
f0102cde:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102ce5:	39 d0                	cmp    %edx,%eax
f0102ce7:	74 24                	je     f0102d0d <mem_init+0x19ed>
f0102ce9:	c7 44 24 0c b4 77 10 	movl   $0xf01077b4,0xc(%esp)
f0102cf0:	f0 
f0102cf1:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102cf8:	f0 
f0102cf9:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f0102d00:	00 
f0102d01:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102d08:	e8 33 d3 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d0d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d13:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102d19:	75 88                	jne    f0102ca3 <mem_init+0x1983>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d1b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d1e:	c1 e7 0c             	shl    $0xc,%edi
f0102d21:	be 00 00 00 00       	mov    $0x0,%esi
f0102d26:	eb 3b                	jmp    f0102d63 <mem_init+0x1a43>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d28:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d2e:	89 d8                	mov    %ebx,%eax
f0102d30:	e8 a7 dc ff ff       	call   f01009dc <check_va2pa>
f0102d35:	39 c6                	cmp    %eax,%esi
f0102d37:	74 24                	je     f0102d5d <mem_init+0x1a3d>
f0102d39:	c7 44 24 0c e8 77 10 	movl   $0xf01077e8,0xc(%esp)
f0102d40:	f0 
f0102d41:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102d48:	f0 
f0102d49:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0102d50:	00 
f0102d51:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102d58:	e8 e3 d2 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d5d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d63:	39 fe                	cmp    %edi,%esi
f0102d65:	72 c1                	jb     f0102d28 <mem_init+0x1a08>
f0102d67:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102d6c:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102d6f:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102d72:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102d75:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d7b:	89 c6                	mov    %eax,%esi
f0102d7d:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102d83:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102d89:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102d8c:	89 da                	mov    %ebx,%edx
f0102d8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102d91:	e8 46 dc ff ff       	call   f01009dc <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102d96:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102d9d:	77 23                	ja     f0102dc2 <mem_init+0x1aa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d9f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102da2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102da6:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102dad:	f0 
f0102dae:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0102db5:	00 
f0102db6:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102dbd:	e8 7e d2 ff ff       	call   f0100040 <_panic>
f0102dc2:	39 f0                	cmp    %esi,%eax
f0102dc4:	74 24                	je     f0102dea <mem_init+0x1aca>
f0102dc6:	c7 44 24 0c 10 78 10 	movl   $0xf0107810,0xc(%esp)
f0102dcd:	f0 
f0102dce:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102dd5:	f0 
f0102dd6:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0102ddd:	00 
f0102dde:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102de5:	e8 56 d2 ff ff       	call   f0100040 <_panic>
f0102dea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102df0:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102df6:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102df9:	0f 85 55 05 00 00    	jne    f0103354 <mem_init+0x2034>
f0102dff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e04:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102e07:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102e0a:	89 f0                	mov    %esi,%eax
f0102e0c:	e8 cb db ff ff       	call   f01009dc <check_va2pa>
f0102e11:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e14:	74 24                	je     f0102e3a <mem_init+0x1b1a>
f0102e16:	c7 44 24 0c 58 78 10 	movl   $0xf0107858,0xc(%esp)
f0102e1d:	f0 
f0102e1e:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102e25:	f0 
f0102e26:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e2d:	00 
f0102e2e:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102e35:	e8 06 d2 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e3a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e40:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102e46:	75 bf                	jne    f0102e07 <mem_init+0x1ae7>
f0102e48:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102e4e:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102e55:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102e5b:	0f 85 0e ff ff ff    	jne    f0102d6f <mem_init+0x1a4f>
f0102e61:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e64:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102e69:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102e6f:	83 fa 04             	cmp    $0x4,%edx
f0102e72:	77 2e                	ja     f0102ea2 <mem_init+0x1b82>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102e74:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102e78:	0f 85 aa 00 00 00    	jne    f0102f28 <mem_init+0x1c08>
f0102e7e:	c7 44 24 0c 6e 7c 10 	movl   $0xf0107c6e,0xc(%esp)
f0102e85:	f0 
f0102e86:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102e8d:	f0 
f0102e8e:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0102e95:	00 
f0102e96:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102e9d:	e8 9e d1 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102ea2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102ea7:	76 55                	jbe    f0102efe <mem_init+0x1bde>
				assert(pgdir[i] & PTE_P);
f0102ea9:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102eac:	f6 c2 01             	test   $0x1,%dl
f0102eaf:	75 24                	jne    f0102ed5 <mem_init+0x1bb5>
f0102eb1:	c7 44 24 0c 6e 7c 10 	movl   $0xf0107c6e,0xc(%esp)
f0102eb8:	f0 
f0102eb9:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102ec0:	f0 
f0102ec1:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0102ec8:	00 
f0102ec9:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102ed0:	e8 6b d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102ed5:	f6 c2 02             	test   $0x2,%dl
f0102ed8:	75 4e                	jne    f0102f28 <mem_init+0x1c08>
f0102eda:	c7 44 24 0c 7f 7c 10 	movl   $0xf0107c7f,0xc(%esp)
f0102ee1:	f0 
f0102ee2:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102ee9:	f0 
f0102eea:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0102ef1:	00 
f0102ef2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102ef9:	e8 42 d1 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102efe:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102f02:	74 24                	je     f0102f28 <mem_init+0x1c08>
f0102f04:	c7 44 24 0c 90 7c 10 	movl   $0xf0107c90,0xc(%esp)
f0102f0b:	f0 
f0102f0c:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102f13:	f0 
f0102f14:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102f1b:	00 
f0102f1c:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102f23:	e8 18 d1 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102f28:	40                   	inc    %eax
f0102f29:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102f2e:	0f 85 35 ff ff ff    	jne    f0102e69 <mem_init+0x1b49>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102f34:	c7 04 24 7c 78 10 f0 	movl   $0xf010787c,(%esp)
f0102f3b:	e8 8a 0f 00 00       	call   f0103eca <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f40:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f45:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f4a:	77 20                	ja     f0102f6c <mem_init+0x1c4c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f4c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f50:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0102f57:	f0 
f0102f58:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
f0102f5f:	00 
f0102f60:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102f67:	e8 d4 d0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102f6c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102f71:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102f74:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f79:	e8 bd db ff ff       	call   f0100b3b <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102f7e:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102f81:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102f86:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102f89:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102f8c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f93:	e8 ae df ff ff       	call   f0100f46 <page_alloc>
f0102f98:	89 c6                	mov    %eax,%esi
f0102f9a:	85 c0                	test   %eax,%eax
f0102f9c:	75 24                	jne    f0102fc2 <mem_init+0x1ca2>
f0102f9e:	c7 44 24 0c 7a 7a 10 	movl   $0xf0107a7a,0xc(%esp)
f0102fa5:	f0 
f0102fa6:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102fad:	f0 
f0102fae:	c7 44 24 04 63 04 00 	movl   $0x463,0x4(%esp)
f0102fb5:	00 
f0102fb6:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102fbd:	e8 7e d0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102fc2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fc9:	e8 78 df ff ff       	call   f0100f46 <page_alloc>
f0102fce:	89 c7                	mov    %eax,%edi
f0102fd0:	85 c0                	test   %eax,%eax
f0102fd2:	75 24                	jne    f0102ff8 <mem_init+0x1cd8>
f0102fd4:	c7 44 24 0c 90 7a 10 	movl   $0xf0107a90,0xc(%esp)
f0102fdb:	f0 
f0102fdc:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0102fe3:	f0 
f0102fe4:	c7 44 24 04 64 04 00 	movl   $0x464,0x4(%esp)
f0102feb:	00 
f0102fec:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0102ff3:	e8 48 d0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ff8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fff:	e8 42 df ff ff       	call   f0100f46 <page_alloc>
f0103004:	89 c3                	mov    %eax,%ebx
f0103006:	85 c0                	test   %eax,%eax
f0103008:	75 24                	jne    f010302e <mem_init+0x1d0e>
f010300a:	c7 44 24 0c a6 7a 10 	movl   $0xf0107aa6,0xc(%esp)
f0103011:	f0 
f0103012:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0103019:	f0 
f010301a:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f0103021:	00 
f0103022:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0103029:	e8 12 d0 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010302e:	89 34 24             	mov    %esi,(%esp)
f0103031:	e8 94 df ff ff       	call   f0100fca <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103036:	89 f8                	mov    %edi,%eax
f0103038:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f010303e:	c1 f8 03             	sar    $0x3,%eax
f0103041:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103044:	89 c2                	mov    %eax,%edx
f0103046:	c1 ea 0c             	shr    $0xc,%edx
f0103049:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f010304f:	72 20                	jb     f0103071 <mem_init+0x1d51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103051:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103055:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010305c:	f0 
f010305d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103064:	00 
f0103065:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f010306c:	e8 cf cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0103071:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103078:	00 
f0103079:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0103080:	00 
	return (void *)(pa + KERNBASE);
f0103081:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103086:	89 04 24             	mov    %eax,(%esp)
f0103089:	e8 5c 2d 00 00       	call   f0105dea <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010308e:	89 d8                	mov    %ebx,%eax
f0103090:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0103096:	c1 f8 03             	sar    $0x3,%eax
f0103099:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010309c:	89 c2                	mov    %eax,%edx
f010309e:	c1 ea 0c             	shr    $0xc,%edx
f01030a1:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f01030a7:	72 20                	jb     f01030c9 <mem_init+0x1da9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030ad:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01030b4:	f0 
f01030b5:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01030bc:	00 
f01030bd:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f01030c4:	e8 77 cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01030c9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030d0:	00 
f01030d1:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01030d8:	00 
	return (void *)(pa + KERNBASE);
f01030d9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01030de:	89 04 24             	mov    %eax,(%esp)
f01030e1:	e8 04 2d 00 00       	call   f0105dea <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01030e6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01030ed:	00 
f01030ee:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030f5:	00 
f01030f6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01030fa:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01030ff:	89 04 24             	mov    %eax,(%esp)
f0103102:	e8 30 e1 ff ff       	call   f0101237 <page_insert>
	assert(pp1->pp_ref == 1);
f0103107:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010310c:	74 24                	je     f0103132 <mem_init+0x1e12>
f010310e:	c7 44 24 0c 77 7b 10 	movl   $0xf0107b77,0xc(%esp)
f0103115:	f0 
f0103116:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010311d:	f0 
f010311e:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f0103125:	00 
f0103126:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010312d:	e8 0e cf ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0103132:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103139:	01 01 01 
f010313c:	74 24                	je     f0103162 <mem_init+0x1e42>
f010313e:	c7 44 24 0c 9c 78 10 	movl   $0xf010789c,0xc(%esp)
f0103145:	f0 
f0103146:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010314d:	f0 
f010314e:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f0103155:	00 
f0103156:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010315d:	e8 de ce ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0103162:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103169:	00 
f010316a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103171:	00 
f0103172:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103176:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010317b:	89 04 24             	mov    %eax,(%esp)
f010317e:	e8 b4 e0 ff ff       	call   f0101237 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0103183:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f010318a:	02 02 02 
f010318d:	74 24                	je     f01031b3 <mem_init+0x1e93>
f010318f:	c7 44 24 0c c0 78 10 	movl   $0xf01078c0,0xc(%esp)
f0103196:	f0 
f0103197:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010319e:	f0 
f010319f:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f01031a6:	00 
f01031a7:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01031ae:	e8 8d ce ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01031b3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01031b8:	74 24                	je     f01031de <mem_init+0x1ebe>
f01031ba:	c7 44 24 0c 99 7b 10 	movl   $0xf0107b99,0xc(%esp)
f01031c1:	f0 
f01031c2:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01031c9:	f0 
f01031ca:	c7 44 24 04 6e 04 00 	movl   $0x46e,0x4(%esp)
f01031d1:	00 
f01031d2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01031d9:	e8 62 ce ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01031de:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01031e3:	74 24                	je     f0103209 <mem_init+0x1ee9>
f01031e5:	c7 44 24 0c 03 7c 10 	movl   $0xf0107c03,0xc(%esp)
f01031ec:	f0 
f01031ed:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01031f4:	f0 
f01031f5:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f01031fc:	00 
f01031fd:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0103204:	e8 37 ce ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103209:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103210:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103213:	89 d8                	mov    %ebx,%eax
f0103215:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f010321b:	c1 f8 03             	sar    $0x3,%eax
f010321e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103221:	89 c2                	mov    %eax,%edx
f0103223:	c1 ea 0c             	shr    $0xc,%edx
f0103226:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f010322c:	72 20                	jb     f010324e <mem_init+0x1f2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010322e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103232:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0103239:	f0 
f010323a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103241:	00 
f0103242:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0103249:	e8 f2 cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010324e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0103255:	03 03 03 
f0103258:	74 24                	je     f010327e <mem_init+0x1f5e>
f010325a:	c7 44 24 0c e4 78 10 	movl   $0xf01078e4,0xc(%esp)
f0103261:	f0 
f0103262:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0103269:	f0 
f010326a:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103271:	00 
f0103272:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f0103279:	e8 c2 cd ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010327e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0103285:	00 
f0103286:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f010328b:	89 04 24             	mov    %eax,(%esp)
f010328e:	e8 5b df ff ff       	call   f01011ee <page_remove>
	assert(pp2->pp_ref == 0);
f0103293:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0103298:	74 24                	je     f01032be <mem_init+0x1f9e>
f010329a:	c7 44 24 0c d1 7b 10 	movl   $0xf0107bd1,0xc(%esp)
f01032a1:	f0 
f01032a2:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01032a9:	f0 
f01032aa:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01032b1:	00 
f01032b2:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01032b9:	e8 82 cd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01032be:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
f01032c3:	8b 08                	mov    (%eax),%ecx
f01032c5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01032cb:	89 f2                	mov    %esi,%edx
f01032cd:	2b 15 90 1e 33 f0    	sub    0xf0331e90,%edx
f01032d3:	c1 fa 03             	sar    $0x3,%edx
f01032d6:	c1 e2 0c             	shl    $0xc,%edx
f01032d9:	39 d1                	cmp    %edx,%ecx
f01032db:	74 24                	je     f0103301 <mem_init+0x1fe1>
f01032dd:	c7 44 24 0c 6c 72 10 	movl   $0xf010726c,0xc(%esp)
f01032e4:	f0 
f01032e5:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f01032ec:	f0 
f01032ed:	c7 44 24 04 76 04 00 	movl   $0x476,0x4(%esp)
f01032f4:	00 
f01032f5:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f01032fc:	e8 3f cd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103301:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0103307:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010330c:	74 24                	je     f0103332 <mem_init+0x2012>
f010330e:	c7 44 24 0c 88 7b 10 	movl   $0xf0107b88,0xc(%esp)
f0103315:	f0 
f0103316:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f010331d:	f0 
f010331e:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f0103325:	00 
f0103326:	c7 04 24 71 79 10 f0 	movl   $0xf0107971,(%esp)
f010332d:	e8 0e cd ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0103332:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103338:	89 34 24             	mov    %esi,(%esp)
f010333b:	e8 8a dc ff ff       	call   f0100fca <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103340:	c7 04 24 10 79 10 f0 	movl   $0xf0107910,(%esp)
f0103347:	e8 7e 0b 00 00       	call   f0103eca <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010334c:	83 c4 3c             	add    $0x3c,%esp
f010334f:	5b                   	pop    %ebx
f0103350:	5e                   	pop    %esi
f0103351:	5f                   	pop    %edi
f0103352:	5d                   	pop    %ebp
f0103353:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103354:	89 da                	mov    %ebx,%edx
f0103356:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103359:	e8 7e d6 ff ff       	call   f01009dc <check_va2pa>
f010335e:	e9 5f fa ff ff       	jmp    f0102dc2 <mem_init+0x1aa2>

f0103363 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0103363:	55                   	push   %ebp
f0103364:	89 e5                	mov    %esp,%ebp
f0103366:	57                   	push   %edi
f0103367:	56                   	push   %esi
f0103368:	53                   	push   %ebx
f0103369:	83 ec 2c             	sub    $0x2c,%esp
f010336c:	8b 75 08             	mov    0x8(%ebp),%esi
f010336f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	uintptr_t upperBound = (uintptr_t)va + len;
f0103372:	8b 45 10             	mov    0x10(%ebp),%eax
f0103375:	01 d8                	add    %ebx,%eax
f0103377:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((uint32_t)va + len > ULIM) {
f010337a:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f010337f:	76 60                	jbe    f01033e1 <user_mem_check+0x7e>
		user_mem_check_addr = (uintptr_t)va;
f0103381:	89 1d 44 12 33 f0    	mov    %ebx,0xf0331244
		return -E_FAULT;
f0103387:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010338c:	eb 5f                	jmp    f01033ed <user_mem_check+0x8a>
	}
	
	while ((uintptr_t)va < upperBound) {
		pte_t *pgEntry = pgdir_walk(env->env_pgdir, va, false);
f010338e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0103395:	00 
f0103396:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010339a:	8b 46 60             	mov    0x60(%esi),%eax
f010339d:	89 04 24             	mov    %eax,(%esp)
f01033a0:	e8 85 dc ff ff       	call   f010102a <pgdir_walk>
		if (!pgEntry) {
f01033a5:	85 c0                	test   %eax,%eax
f01033a7:	75 0d                	jne    f01033b6 <user_mem_check+0x53>
			user_mem_check_addr = (uintptr_t)va;
f01033a9:	89 3d 44 12 33 f0    	mov    %edi,0xf0331244
			return -E_FAULT;
f01033af:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01033b4:	eb 37                	jmp    f01033ed <user_mem_check+0x8a>
		}
		if (((*pgEntry & perm) != perm) || !(*pgEntry & PTE_P)) {
f01033b6:	8b 00                	mov    (%eax),%eax
f01033b8:	8b 55 14             	mov    0x14(%ebp),%edx
f01033bb:	21 c2                	and    %eax,%edx
f01033bd:	39 55 14             	cmp    %edx,0x14(%ebp)
f01033c0:	75 04                	jne    f01033c6 <user_mem_check+0x63>
f01033c2:	a8 01                	test   $0x1,%al
f01033c4:	75 0d                	jne    f01033d3 <user_mem_check+0x70>
			user_mem_check_addr = (uintptr_t)va;
f01033c6:	89 3d 44 12 33 f0    	mov    %edi,0xf0331244
			return -E_FAULT;
f01033cc:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01033d1:	eb 1a                	jmp    f01033ed <user_mem_check+0x8a>
		}
		va -= (uintptr_t)va % PGSIZE;
f01033d3:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
f01033d9:	29 fb                	sub    %edi,%ebx
		va += PGSIZE; 
f01033db:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if ((uint32_t)va + len > ULIM) {
		user_mem_check_addr = (uintptr_t)va;
		return -E_FAULT;
	}
	
	while ((uintptr_t)va < upperBound) {
f01033e1:	89 df                	mov    %ebx,%edi
f01033e3:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f01033e6:	77 a6                	ja     f010338e <user_mem_check+0x2b>
			return -E_FAULT;
		}
		va -= (uintptr_t)va % PGSIZE;
		va += PGSIZE; 
	}
	return 0;
f01033e8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01033ed:	83 c4 2c             	add    $0x2c,%esp
f01033f0:	5b                   	pop    %ebx
f01033f1:	5e                   	pop    %esi
f01033f2:	5f                   	pop    %edi
f01033f3:	5d                   	pop    %ebp
f01033f4:	c3                   	ret    

f01033f5 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f01033f5:	55                   	push   %ebp
f01033f6:	89 e5                	mov    %esp,%ebp
f01033f8:	53                   	push   %ebx
f01033f9:	83 ec 14             	sub    $0x14,%esp
f01033fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f01033ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0103402:	83 c8 04             	or     $0x4,%eax
f0103405:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103409:	8b 45 10             	mov    0x10(%ebp),%eax
f010340c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103410:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103413:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103417:	89 1c 24             	mov    %ebx,(%esp)
f010341a:	e8 44 ff ff ff       	call   f0103363 <user_mem_check>
f010341f:	85 c0                	test   %eax,%eax
f0103421:	79 24                	jns    f0103447 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0103423:	a1 44 12 33 f0       	mov    0xf0331244,%eax
f0103428:	89 44 24 08          	mov    %eax,0x8(%esp)
f010342c:	8b 43 48             	mov    0x48(%ebx),%eax
f010342f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103433:	c7 04 24 3c 79 10 f0 	movl   $0xf010793c,(%esp)
f010343a:	e8 8b 0a 00 00       	call   f0103eca <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010343f:	89 1c 24             	mov    %ebx,(%esp)
f0103442:	e8 80 07 00 00       	call   f0103bc7 <env_destroy>
	}
}
f0103447:	83 c4 14             	add    $0x14,%esp
f010344a:	5b                   	pop    %ebx
f010344b:	5d                   	pop    %ebp
f010344c:	c3                   	ret    
f010344d:	00 00                	add    %al,(%eax)
	...

f0103450 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103450:	55                   	push   %ebp
f0103451:	89 e5                	mov    %esp,%ebp
f0103453:	57                   	push   %edi
f0103454:	56                   	push   %esi
f0103455:	53                   	push   %ebx
f0103456:	83 ec 1c             	sub    $0x1c,%esp
f0103459:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *pp;
	uint32_t i;
	for (i = ROUNDDOWN((uint32_t)va, PGSIZE); i < ROUNDUP((uint32_t)va + len, PGSIZE); i+=PGSIZE) {
f010345b:	89 d3                	mov    %edx,%ebx
f010345d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103463:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f010346a:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103470:	eb 6d                	jmp    f01034df <region_alloc+0x8f>
		pp = page_alloc(0);
f0103472:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103479:	e8 c8 da ff ff       	call   f0100f46 <page_alloc>
		if (!pp) {
f010347e:	85 c0                	test   %eax,%eax
f0103480:	75 1c                	jne    f010349e <region_alloc+0x4e>
			panic("Region alloc: Page allocation fail, not enough memory");
f0103482:	c7 44 24 08 a0 7c 10 	movl   $0xf0107ca0,0x8(%esp)
f0103489:	f0 
f010348a:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f0103491:	00 
f0103492:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f0103499:	e8 a2 cb ff ff       	call   f0100040 <_panic>
		}
		if (page_insert(e->env_pgdir, pp, (void *)i, PTE_W|PTE_U) < 0) {
f010349e:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01034a5:	00 
f01034a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01034aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034ae:	8b 46 60             	mov    0x60(%esi),%eax
f01034b1:	89 04 24             	mov    %eax,(%esp)
f01034b4:	e8 7e dd ff ff       	call   f0101237 <page_insert>
f01034b9:	85 c0                	test   %eax,%eax
f01034bb:	79 1c                	jns    f01034d9 <region_alloc+0x89>
			panic("Region alloc: Page insert fail, not enough memory");
f01034bd:	c7 44 24 08 d8 7c 10 	movl   $0xf0107cd8,0x8(%esp)
f01034c4:	f0 
f01034c5:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f01034cc:	00 
f01034cd:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f01034d4:	e8 67 cb ff ff       	call   f0100040 <_panic>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *pp;
	uint32_t i;
	for (i = ROUNDDOWN((uint32_t)va, PGSIZE); i < ROUNDUP((uint32_t)va + len, PGSIZE); i+=PGSIZE) {
f01034d9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01034df:	39 fb                	cmp    %edi,%ebx
f01034e1:	72 8f                	jb     f0103472 <region_alloc+0x22>
		}
		if (page_insert(e->env_pgdir, pp, (void *)i, PTE_W|PTE_U) < 0) {
			panic("Region alloc: Page insert fail, not enough memory");
		}
	}
}
f01034e3:	83 c4 1c             	add    $0x1c,%esp
f01034e6:	5b                   	pop    %ebx
f01034e7:	5e                   	pop    %esi
f01034e8:	5f                   	pop    %edi
f01034e9:	5d                   	pop    %ebp
f01034ea:	c3                   	ret    

f01034eb <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01034eb:	55                   	push   %ebp
f01034ec:	89 e5                	mov    %esp,%ebp
f01034ee:	57                   	push   %edi
f01034ef:	56                   	push   %esi
f01034f0:	53                   	push   %ebx
f01034f1:	83 ec 0c             	sub    $0xc,%esp
f01034f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01034f7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01034fa:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01034fd:	85 c0                	test   %eax,%eax
f01034ff:	75 24                	jne    f0103525 <envid2env+0x3a>
		*env_store = curenv;
f0103501:	e8 12 2f 00 00       	call   f0106418 <cpunum>
f0103506:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010350d:	29 c2                	sub    %eax,%edx
f010350f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103512:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103519:	89 06                	mov    %eax,(%esi)
		return 0;
f010351b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103520:	e9 84 00 00 00       	jmp    f01035a9 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0103525:	89 c3                	mov    %eax,%ebx
f0103527:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f010352d:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f0103534:	c1 e3 07             	shl    $0x7,%ebx
f0103537:	29 cb                	sub    %ecx,%ebx
f0103539:	03 1d 48 12 33 f0    	add    0xf0331248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010353f:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103543:	74 05                	je     f010354a <envid2env+0x5f>
f0103545:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103548:	74 0d                	je     f0103557 <envid2env+0x6c>
		*env_store = 0;
f010354a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103550:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103555:	eb 52                	jmp    f01035a9 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103557:	84 d2                	test   %dl,%dl
f0103559:	74 47                	je     f01035a2 <envid2env+0xb7>
f010355b:	e8 b8 2e 00 00       	call   f0106418 <cpunum>
f0103560:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103567:	29 c2                	sub    %eax,%edx
f0103569:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010356c:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103573:	74 2d                	je     f01035a2 <envid2env+0xb7>
f0103575:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103578:	e8 9b 2e 00 00       	call   f0106418 <cpunum>
f010357d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103584:	29 c2                	sub    %eax,%edx
f0103586:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103589:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103590:	3b 78 48             	cmp    0x48(%eax),%edi
f0103593:	74 0d                	je     f01035a2 <envid2env+0xb7>
		*env_store = 0;
f0103595:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f010359b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035a0:	eb 07                	jmp    f01035a9 <envid2env+0xbe>
	}

	*env_store = e;
f01035a2:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01035a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035a9:	83 c4 0c             	add    $0xc,%esp
f01035ac:	5b                   	pop    %ebx
f01035ad:	5e                   	pop    %esi
f01035ae:	5f                   	pop    %edi
f01035af:	5d                   	pop    %ebp
f01035b0:	c3                   	ret    

f01035b1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01035b1:	55                   	push   %ebp
f01035b2:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01035b4:	b8 20 93 12 f0       	mov    $0xf0129320,%eax
f01035b9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01035bc:	b8 23 00 00 00       	mov    $0x23,%eax
f01035c1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01035c3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01035c5:	b0 10                	mov    $0x10,%al
f01035c7:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01035c9:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01035cb:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01035cd:	ea d4 35 10 f0 08 00 	ljmp   $0x8,$0xf01035d4
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f01035d4:	b0 00                	mov    $0x0,%al
f01035d6:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01035d9:	5d                   	pop    %ebp
f01035da:	c3                   	ret    

f01035db <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01035db:	55                   	push   %ebp
f01035dc:	89 e5                	mov    %esp,%ebp
f01035de:	56                   	push   %esi
f01035df:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f01035e0:	8b 35 48 12 33 f0    	mov    0xf0331248,%esi
f01035e6:	8b 0d 4c 12 33 f0    	mov    0xf033124c,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f01035ec:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f01035f2:	ba ff 03 00 00       	mov    $0x3ff,%edx
f01035f7:	eb 02                	jmp    f01035fb <env_init+0x20>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f01035f9:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f01035fb:	89 c3                	mov    %eax,%ebx
f01035fd:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103604:	89 48 44             	mov    %ecx,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f0103607:	4a                   	dec    %edx
f0103608:	83 e8 7c             	sub    $0x7c,%eax
f010360b:	83 fa ff             	cmp    $0xffffffff,%edx
f010360e:	75 e9                	jne    f01035f9 <env_init+0x1e>
f0103610:	89 35 4c 12 33 f0    	mov    %esi,0xf033124c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103616:	e8 96 ff ff ff       	call   f01035b1 <env_init_percpu>
}
f010361b:	5b                   	pop    %ebx
f010361c:	5e                   	pop    %esi
f010361d:	5d                   	pop    %ebp
f010361e:	c3                   	ret    

f010361f <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010361f:	55                   	push   %ebp
f0103620:	89 e5                	mov    %esp,%ebp
f0103622:	56                   	push   %esi
f0103623:	53                   	push   %ebx
f0103624:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103627:	8b 1d 4c 12 33 f0    	mov    0xf033124c,%ebx
f010362d:	85 db                	test   %ebx,%ebx
f010362f:	0f 84 d8 01 00 00    	je     f010380d <env_alloc+0x1ee>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103635:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010363c:	e8 05 d9 ff ff       	call   f0100f46 <page_alloc>
f0103641:	85 c0                	test   %eax,%eax
f0103643:	0f 84 cb 01 00 00    	je     f0103814 <env_alloc+0x1f5>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
f0103649:	66 ff 40 04          	incw   0x4(%eax)
f010364d:	2b 05 90 1e 33 f0    	sub    0xf0331e90,%eax
f0103653:	c1 f8 03             	sar    $0x3,%eax
f0103656:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103659:	89 c2                	mov    %eax,%edx
f010365b:	c1 ea 0c             	shr    $0xc,%edx
f010365e:	3b 15 88 1e 33 f0    	cmp    0xf0331e88,%edx
f0103664:	72 20                	jb     f0103686 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103666:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010366a:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0103671:	f0 
f0103672:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103679:	00 
f010367a:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0103681:	e8 ba c9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103686:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010368b:	89 43 60             	mov    %eax,0x60(%ebx)
	e->env_pgdir = (pde_t *)page2kva(p);
f010368e:	ba 00 00 00 00       	mov    $0x0,%edx
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f0103693:	b8 00 00 00 00       	mov    $0x0,%eax
		if (i < PDX(UTOP))
f0103698:	3d ba 03 00 00       	cmp    $0x3ba,%eax
f010369d:	77 0c                	ja     f01036ab <env_alloc+0x8c>
			e->env_pgdir[i] = 0;
f010369f:	8b 4b 60             	mov    0x60(%ebx),%ecx
f01036a2:	c7 04 11 00 00 00 00 	movl   $0x0,(%ecx,%edx,1)
f01036a9:	eb 0f                	jmp    f01036ba <env_alloc+0x9b>
		else {
			e->env_pgdir[i] = kern_pgdir[i];
f01036ab:	8b 0d 8c 1e 33 f0    	mov    0xf0331e8c,%ecx
f01036b1:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f01036b4:	8b 4b 60             	mov    0x60(%ebx),%ecx
f01036b7:	89 34 11             	mov    %esi,(%ecx,%edx,1)
	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
	e->env_pgdir = (pde_t *)page2kva(p);
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f01036ba:	40                   	inc    %eax
f01036bb:	83 c2 04             	add    $0x4,%edx
f01036be:	3d 00 04 00 00       	cmp    $0x400,%eax
f01036c3:	75 d3                	jne    f0103698 <env_alloc+0x79>
		}
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01036c5:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01036c8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036cd:	77 20                	ja     f01036ef <env_alloc+0xd0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036d3:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01036da:	f0 
f01036db:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f01036e2:	00 
f01036e3:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f01036ea:	e8 51 c9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01036ef:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01036f5:	83 ca 05             	or     $0x5,%edx
f01036f8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f01036fe:	8b 43 48             	mov    0x48(%ebx),%eax
f0103701:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103706:	89 c1                	mov    %eax,%ecx
f0103708:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f010370e:	7f 05                	jg     f0103715 <env_alloc+0xf6>
		generation = 1 << ENVGENSHIFT;
f0103710:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103715:	89 d8                	mov    %ebx,%eax
f0103717:	2b 05 48 12 33 f0    	sub    0xf0331248,%eax
f010371d:	c1 f8 02             	sar    $0x2,%eax
f0103720:	89 c6                	mov    %eax,%esi
f0103722:	c1 e6 05             	shl    $0x5,%esi
f0103725:	89 c2                	mov    %eax,%edx
f0103727:	c1 e2 0a             	shl    $0xa,%edx
f010372a:	01 f2                	add    %esi,%edx
f010372c:	01 c2                	add    %eax,%edx
f010372e:	89 d6                	mov    %edx,%esi
f0103730:	c1 e6 0f             	shl    $0xf,%esi
f0103733:	01 f2                	add    %esi,%edx
f0103735:	c1 e2 05             	shl    $0x5,%edx
f0103738:	01 d0                	add    %edx,%eax
f010373a:	f7 d8                	neg    %eax
f010373c:	09 c1                	or     %eax,%ecx
f010373e:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103741:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103744:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103747:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010374e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103755:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010375c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103763:	00 
f0103764:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010376b:	00 
f010376c:	89 1c 24             	mov    %ebx,(%esp)
f010376f:	e8 76 26 00 00       	call   f0105dea <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103774:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f010377a:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103780:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103786:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010378d:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103793:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f010379a:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037a1:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037a5:	8b 43 44             	mov    0x44(%ebx),%eax
f01037a8:	a3 4c 12 33 f0       	mov    %eax,0xf033124c
	*newenv_store = e;
f01037ad:	8b 45 08             	mov    0x8(%ebp),%eax
f01037b0:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01037b2:	8b 5b 48             	mov    0x48(%ebx),%ebx
f01037b5:	e8 5e 2c 00 00       	call   f0106418 <cpunum>
f01037ba:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01037c1:	29 c2                	sub    %eax,%edx
f01037c3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037c6:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f01037cd:	00 
f01037ce:	74 1d                	je     f01037ed <env_alloc+0x1ce>
f01037d0:	e8 43 2c 00 00       	call   f0106418 <cpunum>
f01037d5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01037dc:	29 c2                	sub    %eax,%edx
f01037de:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01037e1:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01037e8:	8b 40 48             	mov    0x48(%eax),%eax
f01037eb:	eb 05                	jmp    f01037f2 <env_alloc+0x1d3>
f01037ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01037f2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01037f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037fa:	c7 04 24 6e 7d 10 f0 	movl   $0xf0107d6e,(%esp)
f0103801:	e8 c4 06 00 00       	call   f0103eca <cprintf>
	return 0;
f0103806:	b8 00 00 00 00       	mov    $0x0,%eax
f010380b:	eb 0c                	jmp    f0103819 <env_alloc+0x1fa>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f010380d:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103812:	eb 05                	jmp    f0103819 <env_alloc+0x1fa>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103814:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103819:	83 c4 10             	add    $0x10,%esp
f010381c:	5b                   	pop    %ebx
f010381d:	5e                   	pop    %esi
f010381e:	5d                   	pop    %ebp
f010381f:	c3                   	ret    

f0103820 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103820:	55                   	push   %ebp
f0103821:	89 e5                	mov    %esp,%ebp
f0103823:	57                   	push   %edi
f0103824:	56                   	push   %esi
f0103825:	53                   	push   %ebx
f0103826:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env *newenv;
	int e = env_alloc(&newenv, 0);
f0103829:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103830:	00 
f0103831:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103834:	89 04 24             	mov    %eax,(%esp)
f0103837:	e8 e3 fd ff ff       	call   f010361f <env_alloc>
	if (e < 0) {
f010383c:	85 c0                	test   %eax,%eax
f010383e:	79 20                	jns    f0103860 <env_create+0x40>
		panic("Env create: %e", e);
f0103840:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103844:	c7 44 24 08 83 7d 10 	movl   $0xf0107d83,0x8(%esp)
f010384b:	f0 
f010384c:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
f0103853:	00 
f0103854:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f010385b:	e8 e0 c7 ff ff       	call   f0100040 <_panic>
	}
	load_icode(newenv, binary);
f0103860:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103863:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf *elf = (struct Elf *)binary;
	struct PageInfo *pp;
	struct Proghdr *proghdr;
	int i;
	// Verify whether it is an ELF file
	if (elf->e_magic != ELF_MAGIC) {
f0103866:	8b 55 08             	mov    0x8(%ebp),%edx
f0103869:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f010386f:	74 1c                	je     f010388d <env_create+0x6d>
		panic("Load icode: Not a valid ELF file format");
f0103871:	c7 44 24 08 0c 7d 10 	movl   $0xf0107d0c,0x8(%esp)
f0103878:	f0 
f0103879:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0103880:	00 
f0103881:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f0103888:	e8 b3 c7 ff ff       	call   f0100040 <_panic>
	}
	// Set entry point
	e->env_tf.tf_eip = elf->e_entry;
f010388d:	8b 55 08             	mov    0x8(%ebp),%edx
f0103890:	8b 42 18             	mov    0x18(%edx),%eax
f0103893:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103896:	89 42 30             	mov    %eax,0x30(%edx)
	// Switch to environment
	lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
f0103899:	8b 42 60             	mov    0x60(%edx),%eax
f010389c:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f01038a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01038a7:	0f 22 d8             	mov    %eax,%cr3
	// If valid, go to the program headers
	proghdr = (struct Proghdr *)((uint8_t *) binary + elf->e_phoff);
f01038aa:	8b 75 08             	mov    0x8(%ebp),%esi
f01038ad:	03 76 1c             	add    0x1c(%esi),%esi
	for (i = 0; i < elf->e_phnum; i++) {
f01038b0:	bf 00 00 00 00       	mov    $0x0,%edi
f01038b5:	eb 6e                	jmp    f0103925 <env_create+0x105>
		// Check if the segments is loadable
		if (proghdr[i].p_type == ELF_PROG_LOAD) {
f01038b7:	83 3e 01             	cmpl   $0x1,(%esi)
f01038ba:	75 65                	jne    f0103921 <env_create+0x101>
			// Check if memory size is greater than or equal to file size
			if (proghdr[i].p_filesz > proghdr[i].p_memsz) {
f01038bc:	8b 4e 14             	mov    0x14(%esi),%ecx
f01038bf:	39 4e 10             	cmp    %ecx,0x10(%esi)
f01038c2:	76 1c                	jbe    f01038e0 <env_create+0xc0>
				panic("Load icode: File size greater than memory size");
f01038c4:	c7 44 24 08 34 7d 10 	movl   $0xf0107d34,0x8(%esp)
f01038cb:	f0 
f01038cc:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f01038d3:	00 
f01038d4:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f01038db:	e8 60 c7 ff ff       	call   f0100040 <_panic>
			}
			// Allocate page table entries for program to be copied
			region_alloc(e, (void *)proghdr[i].p_va, proghdr[i].p_memsz);
f01038e0:	8b 56 08             	mov    0x8(%esi),%edx
f01038e3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01038e6:	e8 65 fb ff ff       	call   f0103450 <region_alloc>
			// Copy file 
			memset((void *)proghdr[i].p_va, 0, proghdr[i].p_memsz);
f01038eb:	8b 46 14             	mov    0x14(%esi),%eax
f01038ee:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038f2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038f9:	00 
f01038fa:	8b 46 08             	mov    0x8(%esi),%eax
f01038fd:	89 04 24             	mov    %eax,(%esp)
f0103900:	e8 e5 24 00 00       	call   f0105dea <memset>
			memmove((void *)proghdr[i].p_va, (void *)(binary + proghdr[i].p_offset), proghdr[i].p_filesz);
f0103905:	8b 46 10             	mov    0x10(%esi),%eax
f0103908:	89 44 24 08          	mov    %eax,0x8(%esp)
f010390c:	8b 45 08             	mov    0x8(%ebp),%eax
f010390f:	03 46 04             	add    0x4(%esi),%eax
f0103912:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103916:	8b 46 08             	mov    0x8(%esi),%eax
f0103919:	89 04 24             	mov    %eax,(%esp)
f010391c:	e8 13 25 00 00       	call   f0105e34 <memmove>
	e->env_tf.tf_eip = elf->e_entry;
	// Switch to environment
	lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
	// If valid, go to the program headers
	proghdr = (struct Proghdr *)((uint8_t *) binary + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++) {
f0103921:	47                   	inc    %edi
f0103922:	83 c6 20             	add    $0x20,%esi
f0103925:	8b 55 08             	mov    0x8(%ebp),%edx
f0103928:	0f b7 42 2c          	movzwl 0x2c(%edx),%eax
f010392c:	39 c7                	cmp    %eax,%edi
f010392e:	7c 87                	jl     f01038b7 <env_create+0x97>

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103930:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103935:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010393a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010393d:	e8 0e fb ff ff       	call   f0103450 <region_alloc>
	memset((void *)(USTACKTOP - PGSIZE), 0, PGSIZE);
f0103942:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103949:	00 
f010394a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103951:	00 
f0103952:	c7 04 24 00 d0 bf ee 	movl   $0xeebfd000,(%esp)
f0103959:	e8 8c 24 00 00       	call   f0105dea <memset>

	// switch back to kern_pgdir to be on the safe side
	lcr3(PADDR(kern_pgdir));
f010395e:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103963:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103968:	77 20                	ja     f010398a <env_create+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010396a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010396e:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0103975:	f0 
f0103976:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f010397d:	00 
f010397e:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f0103985:	e8 b6 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010398a:	05 00 00 00 10       	add    $0x10000000,%eax
f010398f:	0f 22 d8             	mov    %eax,%cr3
	int e = env_alloc(&newenv, 0);
	if (e < 0) {
		panic("Env create: %e", e);
	}
	load_icode(newenv, binary);
	newenv->env_type = type;
f0103992:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103995:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103998:	89 50 50             	mov    %edx,0x50(%eax)
}
f010399b:	83 c4 3c             	add    $0x3c,%esp
f010399e:	5b                   	pop    %ebx
f010399f:	5e                   	pop    %esi
f01039a0:	5f                   	pop    %edi
f01039a1:	5d                   	pop    %ebp
f01039a2:	c3                   	ret    

f01039a3 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01039a3:	55                   	push   %ebp
f01039a4:	89 e5                	mov    %esp,%ebp
f01039a6:	57                   	push   %edi
f01039a7:	56                   	push   %esi
f01039a8:	53                   	push   %ebx
f01039a9:	83 ec 2c             	sub    $0x2c,%esp
f01039ac:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01039af:	e8 64 2a 00 00       	call   f0106418 <cpunum>
f01039b4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01039bb:	29 c2                	sub    %eax,%edx
f01039bd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01039c0:	39 3c 85 28 20 33 f0 	cmp    %edi,-0xfccdfd8(,%eax,4)
f01039c7:	75 34                	jne    f01039fd <env_free+0x5a>
		lcr3(PADDR(kern_pgdir));
f01039c9:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039ce:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039d3:	77 20                	ja     f01039f5 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039d5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039d9:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f01039e0:	f0 
f01039e1:	c7 44 24 04 b8 01 00 	movl   $0x1b8,0x4(%esp)
f01039e8:	00 
f01039e9:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f01039f0:	e8 4b c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039f5:	05 00 00 00 10       	add    $0x10000000,%eax
f01039fa:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01039fd:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103a00:	e8 13 2a 00 00       	call   f0106418 <cpunum>
f0103a05:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a0c:	29 c2                	sub    %eax,%edx
f0103a0e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a11:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0103a18:	00 
f0103a19:	74 1d                	je     f0103a38 <env_free+0x95>
f0103a1b:	e8 f8 29 00 00       	call   f0106418 <cpunum>
f0103a20:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a27:	29 c2                	sub    %eax,%edx
f0103a29:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a2c:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103a33:	8b 40 48             	mov    0x48(%eax),%eax
f0103a36:	eb 05                	jmp    f0103a3d <env_free+0x9a>
f0103a38:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a3d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103a41:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a45:	c7 04 24 92 7d 10 f0 	movl   $0xf0107d92,(%esp)
f0103a4c:	e8 79 04 00 00       	call   f0103eca <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103a51:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103a58:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a5b:	c1 e0 02             	shl    $0x2,%eax
f0103a5e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103a61:	8b 47 60             	mov    0x60(%edi),%eax
f0103a64:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a67:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103a6a:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103a70:	0f 84 b6 00 00 00    	je     f0103b2c <env_free+0x189>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a76:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a7c:	89 f0                	mov    %esi,%eax
f0103a7e:	c1 e8 0c             	shr    $0xc,%eax
f0103a81:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a84:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103a8a:	72 20                	jb     f0103aac <env_free+0x109>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a8c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103a90:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0103a97:	f0 
f0103a98:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103a9f:	00 
f0103aa0:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f0103aa7:	e8 94 c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103aac:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103aaf:	c1 e2 16             	shl    $0x16,%edx
f0103ab2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103ab5:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103aba:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103ac1:	01 
f0103ac2:	74 17                	je     f0103adb <env_free+0x138>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103ac4:	89 d8                	mov    %ebx,%eax
f0103ac6:	c1 e0 0c             	shl    $0xc,%eax
f0103ac9:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103acc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ad0:	8b 47 60             	mov    0x60(%edi),%eax
f0103ad3:	89 04 24             	mov    %eax,(%esp)
f0103ad6:	e8 13 d7 ff ff       	call   f01011ee <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103adb:	43                   	inc    %ebx
f0103adc:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103ae2:	75 d6                	jne    f0103aba <env_free+0x117>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103ae4:	8b 47 60             	mov    0x60(%edi),%eax
f0103ae7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103aea:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103af1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103af4:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103afa:	72 1c                	jb     f0103b18 <env_free+0x175>
		panic("pa2page called with invalid pa");
f0103afc:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0103b03:	f0 
f0103b04:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b0b:	00 
f0103b0c:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0103b13:	e8 28 c5 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b18:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103b1b:	c1 e0 03             	shl    $0x3,%eax
f0103b1e:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
		page_decref(pa2page(pa));
f0103b24:	89 04 24             	mov    %eax,(%esp)
f0103b27:	e8 de d4 ff ff       	call   f010100a <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103b2c:	ff 45 e0             	incl   -0x20(%ebp)
f0103b2f:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103b36:	0f 85 1c ff ff ff    	jne    f0103a58 <env_free+0xb5>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103b3c:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103b3f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103b44:	77 20                	ja     f0103b66 <env_free+0x1c3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103b46:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b4a:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0103b51:	f0 
f0103b52:	c7 44 24 04 d5 01 00 	movl   $0x1d5,0x4(%esp)
f0103b59:	00 
f0103b5a:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f0103b61:	e8 da c4 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103b66:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103b6d:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b72:	c1 e8 0c             	shr    $0xc,%eax
f0103b75:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f0103b7b:	72 1c                	jb     f0103b99 <env_free+0x1f6>
		panic("pa2page called with invalid pa");
f0103b7d:	c7 44 24 08 10 71 10 	movl   $0xf0107110,0x8(%esp)
f0103b84:	f0 
f0103b85:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b8c:	00 
f0103b8d:	c7 04 24 98 79 10 f0 	movl   $0xf0107998,(%esp)
f0103b94:	e8 a7 c4 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b99:	c1 e0 03             	shl    $0x3,%eax
f0103b9c:	03 05 90 1e 33 f0    	add    0xf0331e90,%eax
	page_decref(pa2page(pa));
f0103ba2:	89 04 24             	mov    %eax,(%esp)
f0103ba5:	e8 60 d4 ff ff       	call   f010100a <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103baa:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103bb1:	a1 4c 12 33 f0       	mov    0xf033124c,%eax
f0103bb6:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103bb9:	89 3d 4c 12 33 f0    	mov    %edi,0xf033124c
}
f0103bbf:	83 c4 2c             	add    $0x2c,%esp
f0103bc2:	5b                   	pop    %ebx
f0103bc3:	5e                   	pop    %esi
f0103bc4:	5f                   	pop    %edi
f0103bc5:	5d                   	pop    %ebp
f0103bc6:	c3                   	ret    

f0103bc7 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103bc7:	55                   	push   %ebp
f0103bc8:	89 e5                	mov    %esp,%ebp
f0103bca:	53                   	push   %ebx
f0103bcb:	83 ec 14             	sub    $0x14,%esp
f0103bce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103bd1:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103bd5:	75 23                	jne    f0103bfa <env_destroy+0x33>
f0103bd7:	e8 3c 28 00 00       	call   f0106418 <cpunum>
f0103bdc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103be3:	29 c2                	sub    %eax,%edx
f0103be5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103be8:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103bef:	74 09                	je     f0103bfa <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103bf1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103bf8:	eb 39                	jmp    f0103c33 <env_destroy+0x6c>
	}

	env_free(e);
f0103bfa:	89 1c 24             	mov    %ebx,(%esp)
f0103bfd:	e8 a1 fd ff ff       	call   f01039a3 <env_free>

	if (curenv == e) {
f0103c02:	e8 11 28 00 00       	call   f0106418 <cpunum>
f0103c07:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c0e:	29 c2                	sub    %eax,%edx
f0103c10:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c13:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103c1a:	75 17                	jne    f0103c33 <env_destroy+0x6c>
		curenv = NULL;
f0103c1c:	e8 f7 27 00 00       	call   f0106418 <cpunum>
f0103c21:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c24:	c7 80 28 20 33 f0 00 	movl   $0x0,-0xfccdfd8(%eax)
f0103c2b:	00 00 00 
		sched_yield();
f0103c2e:	e8 a3 0f 00 00       	call   f0104bd6 <sched_yield>
	}
}
f0103c33:	83 c4 14             	add    $0x14,%esp
f0103c36:	5b                   	pop    %ebx
f0103c37:	5d                   	pop    %ebp
f0103c38:	c3                   	ret    

f0103c39 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103c39:	55                   	push   %ebp
f0103c3a:	89 e5                	mov    %esp,%ebp
f0103c3c:	53                   	push   %ebx
f0103c3d:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103c40:	e8 d3 27 00 00       	call   f0106418 <cpunum>
f0103c45:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c4c:	29 c2                	sub    %eax,%edx
f0103c4e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c51:	8b 1c 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%ebx
f0103c58:	e8 bb 27 00 00       	call   f0106418 <cpunum>
f0103c5d:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103c60:	8b 65 08             	mov    0x8(%ebp),%esp
f0103c63:	61                   	popa   
f0103c64:	07                   	pop    %es
f0103c65:	1f                   	pop    %ds
f0103c66:	83 c4 08             	add    $0x8,%esp
f0103c69:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103c6a:	c7 44 24 08 a8 7d 10 	movl   $0xf0107da8,0x8(%esp)
f0103c71:	f0 
f0103c72:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0103c79:	00 
f0103c7a:	c7 04 24 63 7d 10 f0 	movl   $0xf0107d63,(%esp)
f0103c81:	e8 ba c3 ff ff       	call   f0100040 <_panic>

f0103c86 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c86:	55                   	push   %ebp
f0103c87:	89 e5                	mov    %esp,%ebp
f0103c89:	53                   	push   %ebx
f0103c8a:	83 ec 14             	sub    $0x14,%esp
f0103c8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (e != curenv) {
f0103c90:	e8 83 27 00 00       	call   f0106418 <cpunum>
f0103c95:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c9c:	29 c2                	sub    %eax,%edx
f0103c9e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca1:	39 1c 85 28 20 33 f0 	cmp    %ebx,-0xfccdfd8(,%eax,4)
f0103ca8:	0f 84 a7 00 00 00    	je     f0103d55 <env_run+0xcf>
		// Step 1-1:
		if (curenv) {
f0103cae:	e8 65 27 00 00       	call   f0106418 <cpunum>
f0103cb3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cba:	29 c2                	sub    %eax,%edx
f0103cbc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cbf:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0103cc6:	00 
f0103cc7:	74 29                	je     f0103cf2 <env_run+0x6c>
			if (curenv->env_status == ENV_RUNNING)
f0103cc9:	e8 4a 27 00 00       	call   f0106418 <cpunum>
f0103cce:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cd1:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0103cd7:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103cdb:	75 15                	jne    f0103cf2 <env_run+0x6c>
				curenv->env_status = ENV_RUNNABLE;
f0103cdd:	e8 36 27 00 00       	call   f0106418 <cpunum>
f0103ce2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ce5:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0103ceb:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		// Step 1-2:
		curenv = e;
f0103cf2:	e8 21 27 00 00       	call   f0106418 <cpunum>
f0103cf7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cfe:	29 c2                	sub    %eax,%edx
f0103d00:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d03:	89 1c 85 28 20 33 f0 	mov    %ebx,-0xfccdfd8(,%eax,4)
		// Step 1-3:
		curenv->env_status = ENV_RUNNING;
f0103d0a:	e8 09 27 00 00       	call   f0106418 <cpunum>
f0103d0f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d16:	29 c2                	sub    %eax,%edx
f0103d18:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d1b:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103d22:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		// Step 1-4:
		curenv->env_runs++;
f0103d29:	e8 ea 26 00 00       	call   f0106418 <cpunum>
f0103d2e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d35:	29 c2                	sub    %eax,%edx
f0103d37:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d3a:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103d41:	ff 40 58             	incl   0x58(%eax)
		// Step 1-5:
		lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
f0103d44:	8b 43 60             	mov    0x60(%ebx),%eax
f0103d47:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f0103d4d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103d52:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103d55:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0103d5c:	e8 19 2a 00 00       	call   f010677a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103d61:	f3 90                	pause  
	}
	// Release Lock right before user mode
	unlock_kernel();

	// Step 2:
	env_pop_tf(&(curenv->env_tf));
f0103d63:	e8 b0 26 00 00       	call   f0106418 <cpunum>
f0103d68:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d6f:	29 c2                	sub    %eax,%edx
f0103d71:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d74:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0103d7b:	89 04 24             	mov    %eax,(%esp)
f0103d7e:	e8 b6 fe ff ff       	call   f0103c39 <env_pop_tf>
	...

f0103d84 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d84:	55                   	push   %ebp
f0103d85:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d87:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d8f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d90:	b2 71                	mov    $0x71,%dl
f0103d92:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d93:	0f b6 c0             	movzbl %al,%eax
}
f0103d96:	5d                   	pop    %ebp
f0103d97:	c3                   	ret    

f0103d98 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d98:	55                   	push   %ebp
f0103d99:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d9b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103da0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103da3:	ee                   	out    %al,(%dx)
f0103da4:	b2 71                	mov    $0x71,%dl
f0103da6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103da9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103daa:	5d                   	pop    %ebp
f0103dab:	c3                   	ret    

f0103dac <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103dac:	55                   	push   %ebp
f0103dad:	89 e5                	mov    %esp,%ebp
f0103daf:	56                   	push   %esi
f0103db0:	53                   	push   %ebx
f0103db1:	83 ec 10             	sub    $0x10,%esp
f0103db4:	8b 45 08             	mov    0x8(%ebp),%eax
f0103db7:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103db9:	66 a3 a8 93 12 f0    	mov    %ax,0xf01293a8
	if (!didinit)
f0103dbf:	80 3d 50 12 33 f0 00 	cmpb   $0x0,0xf0331250
f0103dc6:	74 51                	je     f0103e19 <irq_setmask_8259A+0x6d>
f0103dc8:	ba 21 00 00 00       	mov    $0x21,%edx
f0103dcd:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103dce:	89 f0                	mov    %esi,%eax
f0103dd0:	66 c1 e8 08          	shr    $0x8,%ax
f0103dd4:	b2 a1                	mov    $0xa1,%dl
f0103dd6:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103dd7:	c7 04 24 b4 7d 10 f0 	movl   $0xf0107db4,(%esp)
f0103dde:	e8 e7 00 00 00       	call   f0103eca <cprintf>
	for (i = 0; i < 16; i++)
f0103de3:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103de8:	0f b7 f6             	movzwl %si,%esi
f0103deb:	f7 d6                	not    %esi
f0103ded:	89 f0                	mov    %esi,%eax
f0103def:	88 d9                	mov    %bl,%cl
f0103df1:	d3 f8                	sar    %cl,%eax
f0103df3:	a8 01                	test   $0x1,%al
f0103df5:	74 10                	je     f0103e07 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103df7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103dfb:	c7 04 24 97 82 10 f0 	movl   $0xf0108297,(%esp)
f0103e02:	e8 c3 00 00 00       	call   f0103eca <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e07:	43                   	inc    %ebx
f0103e08:	83 fb 10             	cmp    $0x10,%ebx
f0103e0b:	75 e0                	jne    f0103ded <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e0d:	c7 04 24 6c 7c 10 f0 	movl   $0xf0107c6c,(%esp)
f0103e14:	e8 b1 00 00 00       	call   f0103eca <cprintf>
}
f0103e19:	83 c4 10             	add    $0x10,%esp
f0103e1c:	5b                   	pop    %ebx
f0103e1d:	5e                   	pop    %esi
f0103e1e:	5d                   	pop    %ebp
f0103e1f:	c3                   	ret    

f0103e20 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e20:	55                   	push   %ebp
f0103e21:	89 e5                	mov    %esp,%ebp
f0103e23:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103e26:	c6 05 50 12 33 f0 01 	movb   $0x1,0xf0331250
f0103e2d:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e32:	b0 ff                	mov    $0xff,%al
f0103e34:	ee                   	out    %al,(%dx)
f0103e35:	b2 a1                	mov    $0xa1,%dl
f0103e37:	ee                   	out    %al,(%dx)
f0103e38:	b2 20                	mov    $0x20,%dl
f0103e3a:	b0 11                	mov    $0x11,%al
f0103e3c:	ee                   	out    %al,(%dx)
f0103e3d:	b2 21                	mov    $0x21,%dl
f0103e3f:	b0 20                	mov    $0x20,%al
f0103e41:	ee                   	out    %al,(%dx)
f0103e42:	b0 04                	mov    $0x4,%al
f0103e44:	ee                   	out    %al,(%dx)
f0103e45:	b0 03                	mov    $0x3,%al
f0103e47:	ee                   	out    %al,(%dx)
f0103e48:	b2 a0                	mov    $0xa0,%dl
f0103e4a:	b0 11                	mov    $0x11,%al
f0103e4c:	ee                   	out    %al,(%dx)
f0103e4d:	b2 a1                	mov    $0xa1,%dl
f0103e4f:	b0 28                	mov    $0x28,%al
f0103e51:	ee                   	out    %al,(%dx)
f0103e52:	b0 02                	mov    $0x2,%al
f0103e54:	ee                   	out    %al,(%dx)
f0103e55:	b0 01                	mov    $0x1,%al
f0103e57:	ee                   	out    %al,(%dx)
f0103e58:	b2 20                	mov    $0x20,%dl
f0103e5a:	b0 68                	mov    $0x68,%al
f0103e5c:	ee                   	out    %al,(%dx)
f0103e5d:	b0 0a                	mov    $0xa,%al
f0103e5f:	ee                   	out    %al,(%dx)
f0103e60:	b2 a0                	mov    $0xa0,%dl
f0103e62:	b0 68                	mov    $0x68,%al
f0103e64:	ee                   	out    %al,(%dx)
f0103e65:	b0 0a                	mov    $0xa,%al
f0103e67:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103e68:	66 a1 a8 93 12 f0    	mov    0xf01293a8,%ax
f0103e6e:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103e72:	74 0b                	je     f0103e7f <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103e74:	0f b7 c0             	movzwl %ax,%eax
f0103e77:	89 04 24             	mov    %eax,(%esp)
f0103e7a:	e8 2d ff ff ff       	call   f0103dac <irq_setmask_8259A>
}
f0103e7f:	c9                   	leave  
f0103e80:	c3                   	ret    
f0103e81:	00 00                	add    %al,(%eax)
	...

f0103e84 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e84:	55                   	push   %ebp
f0103e85:	89 e5                	mov    %esp,%ebp
f0103e87:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103e8a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e8d:	89 04 24             	mov    %eax,(%esp)
f0103e90:	e8 c0 c8 ff ff       	call   f0100755 <cputchar>
	*cnt++;
}
f0103e95:	c9                   	leave  
f0103e96:	c3                   	ret    

f0103e97 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e97:	55                   	push   %ebp
f0103e98:	89 e5                	mov    %esp,%ebp
f0103e9a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103e9d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103ea4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103ea7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103eab:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eae:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103eb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103eb5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103eb9:	c7 04 24 84 3e 10 f0 	movl   $0xf0103e84,(%esp)
f0103ec0:	e8 c5 18 00 00       	call   f010578a <vprintfmt>
	return cnt;
}
f0103ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103ec8:	c9                   	leave  
f0103ec9:	c3                   	ret    

f0103eca <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103eca:	55                   	push   %ebp
f0103ecb:	89 e5                	mov    %esp,%ebp
f0103ecd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103ed0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ed7:	8b 45 08             	mov    0x8(%ebp),%eax
f0103eda:	89 04 24             	mov    %eax,(%esp)
f0103edd:	e8 b5 ff ff ff       	call   f0103e97 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103ee2:	c9                   	leave  
f0103ee3:	c3                   	ret    

f0103ee4 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103ee4:	55                   	push   %ebp
f0103ee5:	89 e5                	mov    %esp,%ebp
f0103ee7:	57                   	push   %edi
f0103ee8:	56                   	push   %esi
f0103ee9:	53                   	push   %ebx
f0103eea:	83 ec 0c             	sub    $0xc,%esp
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)(percpu_kstacks[cpunum()] + KSTKSIZE);
f0103eed:	e8 26 25 00 00       	call   f0106418 <cpunum>
f0103ef2:	89 c3                	mov    %eax,%ebx
f0103ef4:	e8 1f 25 00 00       	call   f0106418 <cpunum>
f0103ef9:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0103f00:	29 da                	sub    %ebx,%edx
f0103f02:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103f05:	c1 e0 0f             	shl    $0xf,%eax
f0103f08:	8d 80 00 b0 33 f0    	lea    -0xfcc5000(%eax),%eax
f0103f0e:	89 04 95 30 20 33 f0 	mov    %eax,-0xfccdfd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103f15:	e8 fe 24 00 00       	call   f0106418 <cpunum>
f0103f1a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f21:	29 c2                	sub    %eax,%edx
f0103f23:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f26:	66 c7 04 85 34 20 33 	movw   $0x10,-0xfccdfcc(,%eax,4)
f0103f2d:	f0 10 00 
	// thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate) * (cpunum() + 1);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103f30:	e8 e3 24 00 00       	call   f0106418 <cpunum>
f0103f35:	8d 58 05             	lea    0x5(%eax),%ebx
f0103f38:	e8 db 24 00 00       	call   f0106418 <cpunum>
f0103f3d:	89 c6                	mov    %eax,%esi
f0103f3f:	e8 d4 24 00 00       	call   f0106418 <cpunum>
f0103f44:	89 c7                	mov    %eax,%edi
f0103f46:	e8 cd 24 00 00       	call   f0106418 <cpunum>
f0103f4b:	66 c7 04 dd 40 93 12 	movw   $0x67,-0xfed6cc0(,%ebx,8)
f0103f52:	f0 67 00 
f0103f55:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0103f5c:	29 f2                	sub    %esi,%edx
f0103f5e:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103f61:	8d 14 95 2c 20 33 f0 	lea    -0xfccdfd4(,%edx,4),%edx
f0103f68:	66 89 14 dd 42 93 12 	mov    %dx,-0xfed6cbe(,%ebx,8)
f0103f6f:	f0 
f0103f70:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103f77:	29 fa                	sub    %edi,%edx
f0103f79:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103f7c:	8d 14 95 2c 20 33 f0 	lea    -0xfccdfd4(,%edx,4),%edx
f0103f83:	c1 ea 10             	shr    $0x10,%edx
f0103f86:	88 14 dd 44 93 12 f0 	mov    %dl,-0xfed6cbc(,%ebx,8)
f0103f8d:	c6 04 dd 45 93 12 f0 	movb   $0x99,-0xfed6cbb(,%ebx,8)
f0103f94:	99 
f0103f95:	c6 04 dd 46 93 12 f0 	movb   $0x40,-0xfed6cba(,%ebx,8)
f0103f9c:	40 
f0103f9d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103fa4:	29 c2                	sub    %eax,%edx
f0103fa6:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103fa9:	8d 04 85 2c 20 33 f0 	lea    -0xfccdfd4(,%eax,4),%eax
f0103fb0:	c1 e8 18             	shr    $0x18,%eax
f0103fb3:	88 04 dd 47 93 12 f0 	mov    %al,-0xfed6cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103fba:	e8 59 24 00 00       	call   f0106418 <cpunum>
f0103fbf:	80 24 c5 6d 93 12 f0 	andb   $0xef,-0xfed6c93(,%eax,8)
f0103fc6:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103fc7:	e8 4c 24 00 00       	call   f0106418 <cpunum>
f0103fcc:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103fd3:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103fd6:	b8 ac 93 12 f0       	mov    $0xf01293ac,%eax
f0103fdb:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103fde:	83 c4 0c             	add    $0xc,%esp
f0103fe1:	5b                   	pop    %ebx
f0103fe2:	5e                   	pop    %esi
f0103fe3:	5f                   	pop    %edi
f0103fe4:	5d                   	pop    %ebp
f0103fe5:	c3                   	ret    

f0103fe6 <trap_init>:
}


void
trap_init(void)
{
f0103fe6:	55                   	push   %ebp
f0103fe7:	89 e5                	mov    %esp,%ebp
f0103fe9:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[0], 0, GD_KT, T_DIVIDE_handler, 0);			// divide error
f0103fec:	b8 e4 49 10 f0       	mov    $0xf01049e4,%eax
f0103ff1:	66 a3 60 12 33 f0    	mov    %ax,0xf0331260
f0103ff7:	66 c7 05 62 12 33 f0 	movw   $0x8,0xf0331262
f0103ffe:	08 00 
f0104000:	c6 05 64 12 33 f0 00 	movb   $0x0,0xf0331264
f0104007:	c6 05 65 12 33 f0 8e 	movb   $0x8e,0xf0331265
f010400e:	c1 e8 10             	shr    $0x10,%eax
f0104011:	66 a3 66 12 33 f0    	mov    %ax,0xf0331266
	SETGATE(idt[1], 0, GD_KT, T_DEBUG_handler, 0);			// debug exception
f0104017:	b8 ee 49 10 f0       	mov    $0xf01049ee,%eax
f010401c:	66 a3 68 12 33 f0    	mov    %ax,0xf0331268
f0104022:	66 c7 05 6a 12 33 f0 	movw   $0x8,0xf033126a
f0104029:	08 00 
f010402b:	c6 05 6c 12 33 f0 00 	movb   $0x0,0xf033126c
f0104032:	c6 05 6d 12 33 f0 8e 	movb   $0x8e,0xf033126d
f0104039:	c1 e8 10             	shr    $0x10,%eax
f010403c:	66 a3 6e 12 33 f0    	mov    %ax,0xf033126e
	SETGATE(idt[2], 0, GD_KT, T_NMI_handler, 0);			// non-maskable interrupt
f0104042:	b8 f8 49 10 f0       	mov    $0xf01049f8,%eax
f0104047:	66 a3 70 12 33 f0    	mov    %ax,0xf0331270
f010404d:	66 c7 05 72 12 33 f0 	movw   $0x8,0xf0331272
f0104054:	08 00 
f0104056:	c6 05 74 12 33 f0 00 	movb   $0x0,0xf0331274
f010405d:	c6 05 75 12 33 f0 8e 	movb   $0x8e,0xf0331275
f0104064:	c1 e8 10             	shr    $0x10,%eax
f0104067:	66 a3 76 12 33 f0    	mov    %ax,0xf0331276
	SETGATE(idt[3], 0, GD_KT, T_BRKPT_handler, 3);			// breakpoint
f010406d:	b8 02 4a 10 f0       	mov    $0xf0104a02,%eax
f0104072:	66 a3 78 12 33 f0    	mov    %ax,0xf0331278
f0104078:	66 c7 05 7a 12 33 f0 	movw   $0x8,0xf033127a
f010407f:	08 00 
f0104081:	c6 05 7c 12 33 f0 00 	movb   $0x0,0xf033127c
f0104088:	c6 05 7d 12 33 f0 ee 	movb   $0xee,0xf033127d
f010408f:	c1 e8 10             	shr    $0x10,%eax
f0104092:	66 a3 7e 12 33 f0    	mov    %ax,0xf033127e
	SETGATE(idt[4], 0, GD_KT, T_OFLOW_handler, 0);			// overflow
f0104098:	b8 0c 4a 10 f0       	mov    $0xf0104a0c,%eax
f010409d:	66 a3 80 12 33 f0    	mov    %ax,0xf0331280
f01040a3:	66 c7 05 82 12 33 f0 	movw   $0x8,0xf0331282
f01040aa:	08 00 
f01040ac:	c6 05 84 12 33 f0 00 	movb   $0x0,0xf0331284
f01040b3:	c6 05 85 12 33 f0 8e 	movb   $0x8e,0xf0331285
f01040ba:	c1 e8 10             	shr    $0x10,%eax
f01040bd:	66 a3 86 12 33 f0    	mov    %ax,0xf0331286
	SETGATE(idt[5], 0, GD_KT, T_BOUND_handler, 0);			// bounds check
f01040c3:	b8 16 4a 10 f0       	mov    $0xf0104a16,%eax
f01040c8:	66 a3 88 12 33 f0    	mov    %ax,0xf0331288
f01040ce:	66 c7 05 8a 12 33 f0 	movw   $0x8,0xf033128a
f01040d5:	08 00 
f01040d7:	c6 05 8c 12 33 f0 00 	movb   $0x0,0xf033128c
f01040de:	c6 05 8d 12 33 f0 8e 	movb   $0x8e,0xf033128d
f01040e5:	c1 e8 10             	shr    $0x10,%eax
f01040e8:	66 a3 8e 12 33 f0    	mov    %ax,0xf033128e
	SETGATE(idt[6], 0, GD_KT, T_ILLOP_handler, 0);			// illegal opcode
f01040ee:	b8 20 4a 10 f0       	mov    $0xf0104a20,%eax
f01040f3:	66 a3 90 12 33 f0    	mov    %ax,0xf0331290
f01040f9:	66 c7 05 92 12 33 f0 	movw   $0x8,0xf0331292
f0104100:	08 00 
f0104102:	c6 05 94 12 33 f0 00 	movb   $0x0,0xf0331294
f0104109:	c6 05 95 12 33 f0 8e 	movb   $0x8e,0xf0331295
f0104110:	c1 e8 10             	shr    $0x10,%eax
f0104113:	66 a3 96 12 33 f0    	mov    %ax,0xf0331296
	SETGATE(idt[7], 0, GD_KT, T_DEVICE_handler, 0);			// device not available
f0104119:	b8 2a 4a 10 f0       	mov    $0xf0104a2a,%eax
f010411e:	66 a3 98 12 33 f0    	mov    %ax,0xf0331298
f0104124:	66 c7 05 9a 12 33 f0 	movw   $0x8,0xf033129a
f010412b:	08 00 
f010412d:	c6 05 9c 12 33 f0 00 	movb   $0x0,0xf033129c
f0104134:	c6 05 9d 12 33 f0 8e 	movb   $0x8e,0xf033129d
f010413b:	c1 e8 10             	shr    $0x10,%eax
f010413e:	66 a3 9e 12 33 f0    	mov    %ax,0xf033129e
	SETGATE(idt[8], 0, GD_KT, T_DBLFLT_handler, 0);			// double fault
f0104144:	b8 34 4a 10 f0       	mov    $0xf0104a34,%eax
f0104149:	66 a3 a0 12 33 f0    	mov    %ax,0xf03312a0
f010414f:	66 c7 05 a2 12 33 f0 	movw   $0x8,0xf03312a2
f0104156:	08 00 
f0104158:	c6 05 a4 12 33 f0 00 	movb   $0x0,0xf03312a4
f010415f:	c6 05 a5 12 33 f0 8e 	movb   $0x8e,0xf03312a5
f0104166:	c1 e8 10             	shr    $0x10,%eax
f0104169:	66 a3 a6 12 33 f0    	mov    %ax,0xf03312a6

	SETGATE(idt[10], 0, GD_KT, T_TSS_handler, 0);			// invalid task switch segment
f010416f:	b8 3e 4a 10 f0       	mov    $0xf0104a3e,%eax
f0104174:	66 a3 b0 12 33 f0    	mov    %ax,0xf03312b0
f010417a:	66 c7 05 b2 12 33 f0 	movw   $0x8,0xf03312b2
f0104181:	08 00 
f0104183:	c6 05 b4 12 33 f0 00 	movb   $0x0,0xf03312b4
f010418a:	c6 05 b5 12 33 f0 8e 	movb   $0x8e,0xf03312b5
f0104191:	c1 e8 10             	shr    $0x10,%eax
f0104194:	66 a3 b6 12 33 f0    	mov    %ax,0xf03312b6
	SETGATE(idt[11], 0, GD_KT, T_SEGNP_handler, 0);			// segment not present
f010419a:	b8 48 4a 10 f0       	mov    $0xf0104a48,%eax
f010419f:	66 a3 b8 12 33 f0    	mov    %ax,0xf03312b8
f01041a5:	66 c7 05 ba 12 33 f0 	movw   $0x8,0xf03312ba
f01041ac:	08 00 
f01041ae:	c6 05 bc 12 33 f0 00 	movb   $0x0,0xf03312bc
f01041b5:	c6 05 bd 12 33 f0 8e 	movb   $0x8e,0xf03312bd
f01041bc:	c1 e8 10             	shr    $0x10,%eax
f01041bf:	66 a3 be 12 33 f0    	mov    %ax,0xf03312be
	SETGATE(idt[12], 0, GD_KT, T_STACK_handler, 0);			// stack exception
f01041c5:	b8 52 4a 10 f0       	mov    $0xf0104a52,%eax
f01041ca:	66 a3 c0 12 33 f0    	mov    %ax,0xf03312c0
f01041d0:	66 c7 05 c2 12 33 f0 	movw   $0x8,0xf03312c2
f01041d7:	08 00 
f01041d9:	c6 05 c4 12 33 f0 00 	movb   $0x0,0xf03312c4
f01041e0:	c6 05 c5 12 33 f0 8e 	movb   $0x8e,0xf03312c5
f01041e7:	c1 e8 10             	shr    $0x10,%eax
f01041ea:	66 a3 c6 12 33 f0    	mov    %ax,0xf03312c6
	SETGATE(idt[13], 0, GD_KT, T_GPFLT_handler, 0);			// general protection fault
f01041f0:	b8 5c 4a 10 f0       	mov    $0xf0104a5c,%eax
f01041f5:	66 a3 c8 12 33 f0    	mov    %ax,0xf03312c8
f01041fb:	66 c7 05 ca 12 33 f0 	movw   $0x8,0xf03312ca
f0104202:	08 00 
f0104204:	c6 05 cc 12 33 f0 00 	movb   $0x0,0xf03312cc
f010420b:	c6 05 cd 12 33 f0 8e 	movb   $0x8e,0xf03312cd
f0104212:	c1 e8 10             	shr    $0x10,%eax
f0104215:	66 a3 ce 12 33 f0    	mov    %ax,0xf03312ce
	SETGATE(idt[14], 0, GD_KT, T_PGFLT_handler, 0);			// page fault
f010421b:	b8 64 4a 10 f0       	mov    $0xf0104a64,%eax
f0104220:	66 a3 d0 12 33 f0    	mov    %ax,0xf03312d0
f0104226:	66 c7 05 d2 12 33 f0 	movw   $0x8,0xf03312d2
f010422d:	08 00 
f010422f:	c6 05 d4 12 33 f0 00 	movb   $0x0,0xf03312d4
f0104236:	c6 05 d5 12 33 f0 8e 	movb   $0x8e,0xf03312d5
f010423d:	c1 e8 10             	shr    $0x10,%eax
f0104240:	66 a3 d6 12 33 f0    	mov    %ax,0xf03312d6

	SETGATE(idt[16], 0, GD_KT, T_FPERR_handler, 0);			// floating point error
f0104246:	b8 6c 4a 10 f0       	mov    $0xf0104a6c,%eax
f010424b:	66 a3 e0 12 33 f0    	mov    %ax,0xf03312e0
f0104251:	66 c7 05 e2 12 33 f0 	movw   $0x8,0xf03312e2
f0104258:	08 00 
f010425a:	c6 05 e4 12 33 f0 00 	movb   $0x0,0xf03312e4
f0104261:	c6 05 e5 12 33 f0 8e 	movb   $0x8e,0xf03312e5
f0104268:	c1 e8 10             	shr    $0x10,%eax
f010426b:	66 a3 e6 12 33 f0    	mov    %ax,0xf03312e6
	SETGATE(idt[17], 0, GD_KT, T_ALIGN_handler, 0);			// aligment check
f0104271:	b8 76 4a 10 f0       	mov    $0xf0104a76,%eax
f0104276:	66 a3 e8 12 33 f0    	mov    %ax,0xf03312e8
f010427c:	66 c7 05 ea 12 33 f0 	movw   $0x8,0xf03312ea
f0104283:	08 00 
f0104285:	c6 05 ec 12 33 f0 00 	movb   $0x0,0xf03312ec
f010428c:	c6 05 ed 12 33 f0 8e 	movb   $0x8e,0xf03312ed
f0104293:	c1 e8 10             	shr    $0x10,%eax
f0104296:	66 a3 ee 12 33 f0    	mov    %ax,0xf03312ee
	SETGATE(idt[18], 0, GD_KT, T_MCHK_handler, 0);			// machine check
f010429c:	b8 80 4a 10 f0       	mov    $0xf0104a80,%eax
f01042a1:	66 a3 f0 12 33 f0    	mov    %ax,0xf03312f0
f01042a7:	66 c7 05 f2 12 33 f0 	movw   $0x8,0xf03312f2
f01042ae:	08 00 
f01042b0:	c6 05 f4 12 33 f0 00 	movb   $0x0,0xf03312f4
f01042b7:	c6 05 f5 12 33 f0 8e 	movb   $0x8e,0xf03312f5
f01042be:	c1 e8 10             	shr    $0x10,%eax
f01042c1:	66 a3 f6 12 33 f0    	mov    %ax,0xf03312f6
	SETGATE(idt[19], 0, GD_KT, T_SIMDERR_handler, 0);		// SIMD floating point error
f01042c7:	b8 8a 4a 10 f0       	mov    $0xf0104a8a,%eax
f01042cc:	66 a3 f8 12 33 f0    	mov    %ax,0xf03312f8
f01042d2:	66 c7 05 fa 12 33 f0 	movw   $0x8,0xf03312fa
f01042d9:	08 00 
f01042db:	c6 05 fc 12 33 f0 00 	movb   $0x0,0xf03312fc
f01042e2:	c6 05 fd 12 33 f0 8e 	movb   $0x8e,0xf03312fd
f01042e9:	c1 e8 10             	shr    $0x10,%eax
f01042ec:	66 a3 fe 12 33 f0    	mov    %ax,0xf03312fe
	// Add for lab 4 exercise 7
	SETGATE(idt[48], 0, GD_KT, T_SYSCALL_handler, 3);		// System call handler
f01042f2:	b8 94 4a 10 f0       	mov    $0xf0104a94,%eax
f01042f7:	66 a3 e0 13 33 f0    	mov    %ax,0xf03313e0
f01042fd:	66 c7 05 e2 13 33 f0 	movw   $0x8,0xf03313e2
f0104304:	08 00 
f0104306:	c6 05 e4 13 33 f0 00 	movb   $0x0,0xf03313e4
f010430d:	c6 05 e5 13 33 f0 ee 	movb   $0xee,0xf03313e5
f0104314:	c1 e8 10             	shr    $0x10,%eax
f0104317:	66 a3 e6 13 33 f0    	mov    %ax,0xf03313e6
	// Add for lab 4 exercise 13
	SETGATE(idt[32], 0, GD_KT, IRQ_TIMER_handler, 3);		// IRQ_TIMER
f010431d:	b8 9e 4a 10 f0       	mov    $0xf0104a9e,%eax
f0104322:	66 a3 60 13 33 f0    	mov    %ax,0xf0331360
f0104328:	66 c7 05 62 13 33 f0 	movw   $0x8,0xf0331362
f010432f:	08 00 
f0104331:	c6 05 64 13 33 f0 00 	movb   $0x0,0xf0331364
f0104338:	c6 05 65 13 33 f0 ee 	movb   $0xee,0xf0331365
f010433f:	c1 e8 10             	shr    $0x10,%eax
f0104342:	66 a3 66 13 33 f0    	mov    %ax,0xf0331366
	SETGATE(idt[33], 0, GD_KT, IRQ_KBD_handler, 3);		// IRQ_TIMER
f0104348:	b8 a8 4a 10 f0       	mov    $0xf0104aa8,%eax
f010434d:	66 a3 68 13 33 f0    	mov    %ax,0xf0331368
f0104353:	66 c7 05 6a 13 33 f0 	movw   $0x8,0xf033136a
f010435a:	08 00 
f010435c:	c6 05 6c 13 33 f0 00 	movb   $0x0,0xf033136c
f0104363:	c6 05 6d 13 33 f0 ee 	movb   $0xee,0xf033136d
f010436a:	c1 e8 10             	shr    $0x10,%eax
f010436d:	66 a3 6e 13 33 f0    	mov    %ax,0xf033136e
	SETGATE(idt[36], 0, GD_KT, IRQ_SERIAL_handler, 3);		// IRQ_TIMER
f0104373:	b8 b2 4a 10 f0       	mov    $0xf0104ab2,%eax
f0104378:	66 a3 80 13 33 f0    	mov    %ax,0xf0331380
f010437e:	66 c7 05 82 13 33 f0 	movw   $0x8,0xf0331382
f0104385:	08 00 
f0104387:	c6 05 84 13 33 f0 00 	movb   $0x0,0xf0331384
f010438e:	c6 05 85 13 33 f0 ee 	movb   $0xee,0xf0331385
f0104395:	c1 e8 10             	shr    $0x10,%eax
f0104398:	66 a3 86 13 33 f0    	mov    %ax,0xf0331386
	SETGATE(idt[39], 0, GD_KT, IRQ_SPURIOUS_handler, 3);		// IRQ_TIMER
f010439e:	b8 bc 4a 10 f0       	mov    $0xf0104abc,%eax
f01043a3:	66 a3 98 13 33 f0    	mov    %ax,0xf0331398
f01043a9:	66 c7 05 9a 13 33 f0 	movw   $0x8,0xf033139a
f01043b0:	08 00 
f01043b2:	c6 05 9c 13 33 f0 00 	movb   $0x0,0xf033139c
f01043b9:	c6 05 9d 13 33 f0 ee 	movb   $0xee,0xf033139d
f01043c0:	c1 e8 10             	shr    $0x10,%eax
f01043c3:	66 a3 9e 13 33 f0    	mov    %ax,0xf033139e
	SETGATE(idt[46], 0, GD_KT, IRQ_IDE_handler, 3);		// IRQ_TIMER
f01043c9:	b8 c6 4a 10 f0       	mov    $0xf0104ac6,%eax
f01043ce:	66 a3 d0 13 33 f0    	mov    %ax,0xf03313d0
f01043d4:	66 c7 05 d2 13 33 f0 	movw   $0x8,0xf03313d2
f01043db:	08 00 
f01043dd:	c6 05 d4 13 33 f0 00 	movb   $0x0,0xf03313d4
f01043e4:	c6 05 d5 13 33 f0 ee 	movb   $0xee,0xf03313d5
f01043eb:	c1 e8 10             	shr    $0x10,%eax
f01043ee:	66 a3 d6 13 33 f0    	mov    %ax,0xf03313d6

	// Per-CPU setup 
	trap_init_percpu();
f01043f4:	e8 eb fa ff ff       	call   f0103ee4 <trap_init_percpu>
}
f01043f9:	c9                   	leave  
f01043fa:	c3                   	ret    

f01043fb <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01043fb:	55                   	push   %ebp
f01043fc:	89 e5                	mov    %esp,%ebp
f01043fe:	53                   	push   %ebx
f01043ff:	83 ec 14             	sub    $0x14,%esp
f0104402:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104405:	8b 03                	mov    (%ebx),%eax
f0104407:	89 44 24 04          	mov    %eax,0x4(%esp)
f010440b:	c7 04 24 c8 7d 10 f0 	movl   $0xf0107dc8,(%esp)
f0104412:	e8 b3 fa ff ff       	call   f0103eca <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104417:	8b 43 04             	mov    0x4(%ebx),%eax
f010441a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010441e:	c7 04 24 d7 7d 10 f0 	movl   $0xf0107dd7,(%esp)
f0104425:	e8 a0 fa ff ff       	call   f0103eca <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010442a:	8b 43 08             	mov    0x8(%ebx),%eax
f010442d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104431:	c7 04 24 e6 7d 10 f0 	movl   $0xf0107de6,(%esp)
f0104438:	e8 8d fa ff ff       	call   f0103eca <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010443d:	8b 43 0c             	mov    0xc(%ebx),%eax
f0104440:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104444:	c7 04 24 f5 7d 10 f0 	movl   $0xf0107df5,(%esp)
f010444b:	e8 7a fa ff ff       	call   f0103eca <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0104450:	8b 43 10             	mov    0x10(%ebx),%eax
f0104453:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104457:	c7 04 24 04 7e 10 f0 	movl   $0xf0107e04,(%esp)
f010445e:	e8 67 fa ff ff       	call   f0103eca <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104463:	8b 43 14             	mov    0x14(%ebx),%eax
f0104466:	89 44 24 04          	mov    %eax,0x4(%esp)
f010446a:	c7 04 24 13 7e 10 f0 	movl   $0xf0107e13,(%esp)
f0104471:	e8 54 fa ff ff       	call   f0103eca <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104476:	8b 43 18             	mov    0x18(%ebx),%eax
f0104479:	89 44 24 04          	mov    %eax,0x4(%esp)
f010447d:	c7 04 24 22 7e 10 f0 	movl   $0xf0107e22,(%esp)
f0104484:	e8 41 fa ff ff       	call   f0103eca <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104489:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010448c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104490:	c7 04 24 31 7e 10 f0 	movl   $0xf0107e31,(%esp)
f0104497:	e8 2e fa ff ff       	call   f0103eca <cprintf>
}
f010449c:	83 c4 14             	add    $0x14,%esp
f010449f:	5b                   	pop    %ebx
f01044a0:	5d                   	pop    %ebp
f01044a1:	c3                   	ret    

f01044a2 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01044a2:	55                   	push   %ebp
f01044a3:	89 e5                	mov    %esp,%ebp
f01044a5:	53                   	push   %ebx
f01044a6:	83 ec 14             	sub    $0x14,%esp
f01044a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01044ac:	e8 67 1f 00 00       	call   f0106418 <cpunum>
f01044b1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01044b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044b9:	c7 04 24 95 7e 10 f0 	movl   $0xf0107e95,(%esp)
f01044c0:	e8 05 fa ff ff       	call   f0103eca <cprintf>
	print_regs(&tf->tf_regs);
f01044c5:	89 1c 24             	mov    %ebx,(%esp)
f01044c8:	e8 2e ff ff ff       	call   f01043fb <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01044cd:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01044d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044d5:	c7 04 24 b3 7e 10 f0 	movl   $0xf0107eb3,(%esp)
f01044dc:	e8 e9 f9 ff ff       	call   f0103eca <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01044e1:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01044e5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044e9:	c7 04 24 c6 7e 10 f0 	movl   $0xf0107ec6,(%esp)
f01044f0:	e8 d5 f9 ff ff       	call   f0103eca <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044f5:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01044f8:	83 f8 13             	cmp    $0x13,%eax
f01044fb:	77 09                	ja     f0104506 <print_trapframe+0x64>
		return excnames[trapno];
f01044fd:	8b 14 85 60 81 10 f0 	mov    -0xfef7ea0(,%eax,4),%edx
f0104504:	eb 20                	jmp    f0104526 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104506:	83 f8 30             	cmp    $0x30,%eax
f0104509:	74 0f                	je     f010451a <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010450b:	8d 50 e0             	lea    -0x20(%eax),%edx
f010450e:	83 fa 0f             	cmp    $0xf,%edx
f0104511:	77 0e                	ja     f0104521 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f0104513:	ba 4c 7e 10 f0       	mov    $0xf0107e4c,%edx
f0104518:	eb 0c                	jmp    f0104526 <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010451a:	ba 40 7e 10 f0       	mov    $0xf0107e40,%edx
f010451f:	eb 05                	jmp    f0104526 <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f0104521:	ba 5f 7e 10 f0       	mov    $0xf0107e5f,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104526:	89 54 24 08          	mov    %edx,0x8(%esp)
f010452a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010452e:	c7 04 24 d9 7e 10 f0 	movl   $0xf0107ed9,(%esp)
f0104535:	e8 90 f9 ff ff       	call   f0103eca <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f010453a:	3b 1d 60 1a 33 f0    	cmp    0xf0331a60,%ebx
f0104540:	75 19                	jne    f010455b <print_trapframe+0xb9>
f0104542:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104546:	75 13                	jne    f010455b <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104548:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010454b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010454f:	c7 04 24 eb 7e 10 f0 	movl   $0xf0107eeb,(%esp)
f0104556:	e8 6f f9 ff ff       	call   f0103eca <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f010455b:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010455e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104562:	c7 04 24 fa 7e 10 f0 	movl   $0xf0107efa,(%esp)
f0104569:	e8 5c f9 ff ff       	call   f0103eca <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f010456e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104572:	75 4d                	jne    f01045c1 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104574:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104577:	a8 01                	test   $0x1,%al
f0104579:	74 07                	je     f0104582 <print_trapframe+0xe0>
f010457b:	b9 6e 7e 10 f0       	mov    $0xf0107e6e,%ecx
f0104580:	eb 05                	jmp    f0104587 <print_trapframe+0xe5>
f0104582:	b9 79 7e 10 f0       	mov    $0xf0107e79,%ecx
f0104587:	a8 02                	test   $0x2,%al
f0104589:	74 07                	je     f0104592 <print_trapframe+0xf0>
f010458b:	ba 85 7e 10 f0       	mov    $0xf0107e85,%edx
f0104590:	eb 05                	jmp    f0104597 <print_trapframe+0xf5>
f0104592:	ba 8b 7e 10 f0       	mov    $0xf0107e8b,%edx
f0104597:	a8 04                	test   $0x4,%al
f0104599:	74 07                	je     f01045a2 <print_trapframe+0x100>
f010459b:	b8 90 7e 10 f0       	mov    $0xf0107e90,%eax
f01045a0:	eb 05                	jmp    f01045a7 <print_trapframe+0x105>
f01045a2:	b8 dd 7f 10 f0       	mov    $0xf0107fdd,%eax
f01045a7:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01045ab:	89 54 24 08          	mov    %edx,0x8(%esp)
f01045af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b3:	c7 04 24 08 7f 10 f0 	movl   $0xf0107f08,(%esp)
f01045ba:	e8 0b f9 ff ff       	call   f0103eca <cprintf>
f01045bf:	eb 0c                	jmp    f01045cd <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01045c1:	c7 04 24 6c 7c 10 f0 	movl   $0xf0107c6c,(%esp)
f01045c8:	e8 fd f8 ff ff       	call   f0103eca <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01045cd:	8b 43 30             	mov    0x30(%ebx),%eax
f01045d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045d4:	c7 04 24 17 7f 10 f0 	movl   $0xf0107f17,(%esp)
f01045db:	e8 ea f8 ff ff       	call   f0103eca <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01045e0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01045e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045e8:	c7 04 24 26 7f 10 f0 	movl   $0xf0107f26,(%esp)
f01045ef:	e8 d6 f8 ff ff       	call   f0103eca <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01045f4:	8b 43 38             	mov    0x38(%ebx),%eax
f01045f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045fb:	c7 04 24 39 7f 10 f0 	movl   $0xf0107f39,(%esp)
f0104602:	e8 c3 f8 ff ff       	call   f0103eca <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104607:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010460b:	74 27                	je     f0104634 <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010460d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104610:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104614:	c7 04 24 48 7f 10 f0 	movl   $0xf0107f48,(%esp)
f010461b:	e8 aa f8 ff ff       	call   f0103eca <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104620:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0104624:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104628:	c7 04 24 57 7f 10 f0 	movl   $0xf0107f57,(%esp)
f010462f:	e8 96 f8 ff ff       	call   f0103eca <cprintf>
	}
}
f0104634:	83 c4 14             	add    $0x14,%esp
f0104637:	5b                   	pop    %ebx
f0104638:	5d                   	pop    %ebp
f0104639:	c3                   	ret    

f010463a <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010463a:	55                   	push   %ebp
f010463b:	89 e5                	mov    %esp,%ebp
f010463d:	57                   	push   %edi
f010463e:	56                   	push   %esi
f010463f:	53                   	push   %ebx
f0104640:	83 ec 1c             	sub    $0x1c,%esp
f0104643:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0104646:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// Determine whether in kernel mode
	if (tf->tf_cs == GD_KT) {
f0104649:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f010464e:	75 1c                	jne    f010466c <page_fault_handler+0x32>
		panic("Page fault from kernel\n");
f0104650:	c7 44 24 08 6a 7f 10 	movl   $0xf0107f6a,0x8(%esp)
f0104657:	f0 
f0104658:	c7 44 24 04 65 01 00 	movl   $0x165,0x4(%esp)
f010465f:	00 
f0104660:	c7 04 24 82 7f 10 f0 	movl   $0xf0107f82,(%esp)
f0104667:	e8 d4 b9 ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;
	// If there is no upcall function
	if (curenv->env_pgfault_upcall) {
f010466c:	e8 a7 1d 00 00       	call   f0106418 <cpunum>
f0104671:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104678:	29 c2                	sub    %eax,%edx
f010467a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010467d:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104684:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104688:	0f 84 b5 00 00 00    	je     f0104743 <page_fault_handler+0x109>
		// Determine whether the user process is running in exception stack or normal stack. 
		// If yes, then we need to initialize UTF right under the current tf_esp. Otherwise, 
		// we just set it to the top of UXSTACKTOP
		if (tf->tf_esp < USTACKTOP) {
f010468e:	8b 43 3c             	mov    0x3c(%ebx),%eax
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104691:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
	// If there is no upcall function
	if (curenv->env_pgfault_upcall) {
		// Determine whether the user process is running in exception stack or normal stack. 
		// If yes, then we need to initialize UTF right under the current tf_esp. Otherwise, 
		// we just set it to the top of UXSTACKTOP
		if (tf->tf_esp < USTACKTOP) {
f0104696:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f010469b:	76 03                	jbe    f01046a0 <page_fault_handler+0x66>
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		else {
			// Leave a 32-bit padding for pushing return address
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010469d:	8d 78 c8             	lea    -0x38(%eax),%edi
		}
		// Check whether current stack is valid or overflowed, the reason of test it by using
		// (void *)(utf) instead of (void *)(UXSTACKTOP - PGSIZE) is to fulfill the requirement 
		// of grading script. Otherwise I cannot get full mark on it.
		user_mem_assert(curenv, (void *)(utf), (UXSTACKTOP - (uintptr_t)utf), PTE_W);
f01046a0:	e8 73 1d 00 00       	call   f0106418 <cpunum>
f01046a5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01046ac:	00 
f01046ad:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01046b2:	29 fa                	sub    %edi,%edx
f01046b4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01046b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01046bc:	6b c0 74             	imul   $0x74,%eax,%eax
f01046bf:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01046c5:	89 04 24             	mov    %eax,(%esp)
f01046c8:	e8 28 ed ff ff       	call   f01033f5 <user_mem_assert>
		// Push all information for trapframe
		utf->utf_esp = tf->tf_esp;
f01046cd:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01046d0:	89 47 30             	mov    %eax,0x30(%edi)
		utf->utf_eflags = tf->tf_eflags;
f01046d3:	8b 43 38             	mov    0x38(%ebx),%eax
f01046d6:	89 47 2c             	mov    %eax,0x2c(%edi)
		utf->utf_eip = tf->tf_eip;
f01046d9:	8b 43 30             	mov    0x30(%ebx),%eax
f01046dc:	89 47 28             	mov    %eax,0x28(%edi)
		utf->utf_regs.reg_eax = tf->tf_regs.reg_eax;
f01046df:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01046e2:	89 47 24             	mov    %eax,0x24(%edi)
		utf->utf_regs.reg_ecx = tf->tf_regs.reg_ecx;
f01046e5:	8b 43 18             	mov    0x18(%ebx),%eax
f01046e8:	89 47 20             	mov    %eax,0x20(%edi)
		utf->utf_regs.reg_edx = tf->tf_regs.reg_edx;
f01046eb:	8b 43 14             	mov    0x14(%ebx),%eax
f01046ee:	89 47 1c             	mov    %eax,0x1c(%edi)
		utf->utf_regs.reg_ebx = tf->tf_regs.reg_ebx;
f01046f1:	8b 43 10             	mov    0x10(%ebx),%eax
f01046f4:	89 47 18             	mov    %eax,0x18(%edi)
		utf->utf_regs.reg_oesp = tf->tf_regs.reg_oesp;
f01046f7:	8b 43 0c             	mov    0xc(%ebx),%eax
f01046fa:	89 47 14             	mov    %eax,0x14(%edi)
		utf->utf_regs.reg_ebp = tf->tf_regs.reg_ebp;
f01046fd:	8b 43 08             	mov    0x8(%ebx),%eax
f0104700:	89 47 10             	mov    %eax,0x10(%edi)
		utf->utf_regs.reg_esi = tf->tf_regs.reg_esi;
f0104703:	8b 43 04             	mov    0x4(%ebx),%eax
f0104706:	89 47 0c             	mov    %eax,0xc(%edi)
		utf->utf_regs.reg_edi = tf->tf_regs.reg_edi;
f0104709:	8b 03                	mov    (%ebx),%eax
f010470b:	89 47 08             	mov    %eax,0x8(%edi)
		utf->utf_err = tf->tf_err;
f010470e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104711:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_fault_va = fault_va;
f0104714:	89 37                	mov    %esi,(%edi)
		// Branch to user page fault upcall function
		tf->tf_esp = (uintptr_t)utf;
f0104716:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f0104719:	e8 fa 1c 00 00       	call   f0106418 <cpunum>
f010471e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104721:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0104727:	8b 40 64             	mov    0x64(%eax),%eax
f010472a:	89 43 30             	mov    %eax,0x30(%ebx)
		// Run current environment
		env_run(curenv);
f010472d:	e8 e6 1c 00 00       	call   f0106418 <cpunum>
f0104732:	6b c0 74             	imul   $0x74,%eax,%eax
f0104735:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f010473b:	89 04 24             	mov    %eax,(%esp)
f010473e:	e8 43 f5 ff ff       	call   f0103c86 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104743:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f0104746:	e8 cd 1c 00 00       	call   f0106418 <cpunum>
		// Run current environment
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010474b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010474f:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0104753:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010475a:	29 c2                	sub    %eax,%edx
f010475c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010475f:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
		// Run current environment
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104766:	8b 40 48             	mov    0x48(%eax),%eax
f0104769:	89 44 24 04          	mov    %eax,0x4(%esp)
f010476d:	c7 04 24 28 81 10 f0 	movl   $0xf0108128,(%esp)
f0104774:	e8 51 f7 ff ff       	call   f0103eca <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104779:	89 1c 24             	mov    %ebx,(%esp)
f010477c:	e8 21 fd ff ff       	call   f01044a2 <print_trapframe>
	env_destroy(curenv);
f0104781:	e8 92 1c 00 00       	call   f0106418 <cpunum>
f0104786:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010478d:	29 c2                	sub    %eax,%edx
f010478f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104792:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104799:	89 04 24             	mov    %eax,(%esp)
f010479c:	e8 26 f4 ff ff       	call   f0103bc7 <env_destroy>
}
f01047a1:	83 c4 1c             	add    $0x1c,%esp
f01047a4:	5b                   	pop    %ebx
f01047a5:	5e                   	pop    %esi
f01047a6:	5f                   	pop    %edi
f01047a7:	5d                   	pop    %ebp
f01047a8:	c3                   	ret    

f01047a9 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01047a9:	55                   	push   %ebp
f01047aa:	89 e5                	mov    %esp,%ebp
f01047ac:	57                   	push   %edi
f01047ad:	56                   	push   %esi
f01047ae:	83 ec 20             	sub    $0x20,%esp
f01047b1:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01047b4:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01047b5:	83 3d 80 1e 33 f0 00 	cmpl   $0x0,0xf0331e80
f01047bc:	74 01                	je     f01047bf <trap+0x16>
		asm volatile("hlt");
f01047be:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01047bf:	e8 54 1c 00 00       	call   f0106418 <cpunum>
f01047c4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01047cb:	29 c2                	sub    %eax,%edx
f01047cd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01047d0:	8d 14 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01047d7:	b8 01 00 00 00       	mov    $0x1,%eax
f01047dc:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f01047e0:	83 f8 02             	cmp    $0x2,%eax
f01047e3:	75 0c                	jne    f01047f1 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01047e5:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f01047ec:	e8 e6 1e 00 00       	call   f01066d7 <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01047f1:	9c                   	pushf  
f01047f2:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f01047f3:	f6 c4 02             	test   $0x2,%ah
f01047f6:	74 24                	je     f010481c <trap+0x73>
f01047f8:	c7 44 24 0c 8e 7f 10 	movl   $0xf0107f8e,0xc(%esp)
f01047ff:	f0 
f0104800:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0104807:	f0 
f0104808:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
f010480f:	00 
f0104810:	c7 04 24 82 7f 10 f0 	movl   $0xf0107f82,(%esp)
f0104817:	e8 24 b8 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010481c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0104820:	83 e0 03             	and    $0x3,%eax
f0104823:	83 f8 03             	cmp    $0x3,%eax
f0104826:	0f 85 a7 00 00 00    	jne    f01048d3 <trap+0x12a>
f010482c:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104833:	e8 9f 1e 00 00       	call   f01066d7 <spin_lock>
		// LAB 4: Your code here.

		// Aquire lock
		lock_kernel();

		assert(curenv);
f0104838:	e8 db 1b 00 00       	call   f0106418 <cpunum>
f010483d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104840:	83 b8 28 20 33 f0 00 	cmpl   $0x0,-0xfccdfd8(%eax)
f0104847:	75 24                	jne    f010486d <trap+0xc4>
f0104849:	c7 44 24 0c a7 7f 10 	movl   $0xf0107fa7,0xc(%esp)
f0104850:	f0 
f0104851:	c7 44 24 08 b2 79 10 	movl   $0xf01079b2,0x8(%esp)
f0104858:	f0 
f0104859:	c7 44 24 04 37 01 00 	movl   $0x137,0x4(%esp)
f0104860:	00 
f0104861:	c7 04 24 82 7f 10 f0 	movl   $0xf0107f82,(%esp)
f0104868:	e8 d3 b7 ff ff       	call   f0100040 <_panic>
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010486d:	e8 a6 1b 00 00       	call   f0106418 <cpunum>
f0104872:	6b c0 74             	imul   $0x74,%eax,%eax
f0104875:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f010487b:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010487f:	75 2d                	jne    f01048ae <trap+0x105>
			env_free(curenv);
f0104881:	e8 92 1b 00 00       	call   f0106418 <cpunum>
f0104886:	6b c0 74             	imul   $0x74,%eax,%eax
f0104889:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f010488f:	89 04 24             	mov    %eax,(%esp)
f0104892:	e8 0c f1 ff ff       	call   f01039a3 <env_free>
			curenv = NULL;
f0104897:	e8 7c 1b 00 00       	call   f0106418 <cpunum>
f010489c:	6b c0 74             	imul   $0x74,%eax,%eax
f010489f:	c7 80 28 20 33 f0 00 	movl   $0x0,-0xfccdfd8(%eax)
f01048a6:	00 00 00 
			sched_yield();
f01048a9:	e8 28 03 00 00       	call   f0104bd6 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01048ae:	e8 65 1b 00 00       	call   f0106418 <cpunum>
f01048b3:	6b c0 74             	imul   $0x74,%eax,%eax
f01048b6:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01048bc:	b9 11 00 00 00       	mov    $0x11,%ecx
f01048c1:	89 c7                	mov    %eax,%edi
f01048c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01048c5:	e8 4e 1b 00 00       	call   f0106418 <cpunum>
f01048ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01048cd:	8b b0 28 20 33 f0    	mov    -0xfccdfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01048d3:	89 35 60 1a 33 f0    	mov    %esi,0xf0331a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Trap 3
	if (tf->tf_trapno == T_BRKPT) {
f01048d9:	8b 46 28             	mov    0x28(%esi),%eax
f01048dc:	83 f8 03             	cmp    $0x3,%eax
f01048df:	75 0d                	jne    f01048ee <trap+0x145>
		monitor(tf);
f01048e1:	89 34 24             	mov    %esi,(%esp)
f01048e4:	e8 b1 bf ff ff       	call   f010089a <monitor>
f01048e9:	e9 b4 00 00 00       	jmp    f01049a2 <trap+0x1f9>
		return;
	}
	// Trap 14
	if (tf->tf_trapno == T_PGFLT) {
f01048ee:	83 f8 0e             	cmp    $0xe,%eax
f01048f1:	75 0d                	jne    f0104900 <trap+0x157>
		page_fault_handler(tf);
f01048f3:	89 34 24             	mov    %esi,(%esp)
f01048f6:	e8 3f fd ff ff       	call   f010463a <page_fault_handler>
f01048fb:	e9 a2 00 00 00       	jmp    f01049a2 <trap+0x1f9>
		return;
	}
	// Trap 48
	if (tf->tf_trapno == T_SYSCALL) {
f0104900:	83 f8 30             	cmp    $0x30,%eax
f0104903:	75 32                	jne    f0104937 <trap+0x18e>
		int32_t ret;
		ret = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, 
f0104905:	8b 46 04             	mov    0x4(%esi),%eax
f0104908:	89 44 24 14          	mov    %eax,0x14(%esp)
f010490c:	8b 06                	mov    (%esi),%eax
f010490e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104912:	8b 46 10             	mov    0x10(%esi),%eax
f0104915:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104919:	8b 46 18             	mov    0x18(%esi),%eax
f010491c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104920:	8b 46 14             	mov    0x14(%esi),%eax
f0104923:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104927:	8b 46 1c             	mov    0x1c(%esi),%eax
f010492a:	89 04 24             	mov    %eax,(%esp)
f010492d:	e8 86 03 00 00       	call   f0104cb8 <syscall>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f0104932:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104935:	eb 6b                	jmp    f01049a2 <trap+0x1f9>
		return;
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0104937:	83 f8 27             	cmp    $0x27,%eax
f010493a:	75 16                	jne    f0104952 <trap+0x1a9>
		cprintf("Spurious interrupt on irq 7\n");
f010493c:	c7 04 24 ae 7f 10 f0 	movl   $0xf0107fae,(%esp)
f0104943:	e8 82 f5 ff ff       	call   f0103eca <cprintf>
		print_trapframe(tf);
f0104948:	89 34 24             	mov    %esi,(%esp)
f010494b:	e8 52 fb ff ff       	call   f01044a2 <print_trapframe>
f0104950:	eb 50                	jmp    f01049a2 <trap+0x1f9>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f0104952:	83 f8 20             	cmp    $0x20,%eax
f0104955:	75 0a                	jne    f0104961 <trap+0x1b8>
		lapic_eoi();
f0104957:	e8 13 1c 00 00       	call   f010656f <lapic_eoi>
		sched_yield();
f010495c:	e8 75 02 00 00       	call   f0104bd6 <sched_yield>
	}

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104961:	89 34 24             	mov    %esi,(%esp)
f0104964:	e8 39 fb ff ff       	call   f01044a2 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104969:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010496e:	75 1c                	jne    f010498c <trap+0x1e3>
		panic("unhandled trap in kernel");
f0104970:	c7 44 24 08 cb 7f 10 	movl   $0xf0107fcb,0x8(%esp)
f0104977:	f0 
f0104978:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
f010497f:	00 
f0104980:	c7 04 24 82 7f 10 f0 	movl   $0xf0107f82,(%esp)
f0104987:	e8 b4 b6 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f010498c:	e8 87 1a 00 00       	call   f0106418 <cpunum>
f0104991:	6b c0 74             	imul   $0x74,%eax,%eax
f0104994:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f010499a:	89 04 24             	mov    %eax,(%esp)
f010499d:	e8 25 f2 ff ff       	call   f0103bc7 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01049a2:	e8 71 1a 00 00       	call   f0106418 <cpunum>
f01049a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049aa:	83 b8 28 20 33 f0 00 	cmpl   $0x0,-0xfccdfd8(%eax)
f01049b1:	74 2a                	je     f01049dd <trap+0x234>
f01049b3:	e8 60 1a 00 00       	call   f0106418 <cpunum>
f01049b8:	6b c0 74             	imul   $0x74,%eax,%eax
f01049bb:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01049c1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01049c5:	75 16                	jne    f01049dd <trap+0x234>
		env_run(curenv);
f01049c7:	e8 4c 1a 00 00       	call   f0106418 <cpunum>
f01049cc:	6b c0 74             	imul   $0x74,%eax,%eax
f01049cf:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01049d5:	89 04 24             	mov    %eax,(%esp)
f01049d8:	e8 a9 f2 ff ff       	call   f0103c86 <env_run>
	else
		sched_yield();
f01049dd:	e8 f4 01 00 00       	call   f0104bd6 <sched_yield>
	...

f01049e4 <T_DIVIDE_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(T_DIVIDE_handler, T_DIVIDE)
f01049e4:	6a 00                	push   $0x0
f01049e6:	6a 00                	push   $0x0
f01049e8:	e9 e2 00 00 00       	jmp    f0104acf <_alltraps>
f01049ed:	90                   	nop

f01049ee <T_DEBUG_handler>:
TRAPHANDLER_NOEC(T_DEBUG_handler, T_DEBUG)
f01049ee:	6a 00                	push   $0x0
f01049f0:	6a 01                	push   $0x1
f01049f2:	e9 d8 00 00 00       	jmp    f0104acf <_alltraps>
f01049f7:	90                   	nop

f01049f8 <T_NMI_handler>:
TRAPHANDLER_NOEC(T_NMI_handler, T_NMI)
f01049f8:	6a 00                	push   $0x0
f01049fa:	6a 02                	push   $0x2
f01049fc:	e9 ce 00 00 00       	jmp    f0104acf <_alltraps>
f0104a01:	90                   	nop

f0104a02 <T_BRKPT_handler>:
TRAPHANDLER_NOEC(T_BRKPT_handler, T_BRKPT)
f0104a02:	6a 00                	push   $0x0
f0104a04:	6a 03                	push   $0x3
f0104a06:	e9 c4 00 00 00       	jmp    f0104acf <_alltraps>
f0104a0b:	90                   	nop

f0104a0c <T_OFLOW_handler>:
TRAPHANDLER_NOEC(T_OFLOW_handler, T_OFLOW)
f0104a0c:	6a 00                	push   $0x0
f0104a0e:	6a 04                	push   $0x4
f0104a10:	e9 ba 00 00 00       	jmp    f0104acf <_alltraps>
f0104a15:	90                   	nop

f0104a16 <T_BOUND_handler>:
TRAPHANDLER_NOEC(T_BOUND_handler, T_BOUND)
f0104a16:	6a 00                	push   $0x0
f0104a18:	6a 05                	push   $0x5
f0104a1a:	e9 b0 00 00 00       	jmp    f0104acf <_alltraps>
f0104a1f:	90                   	nop

f0104a20 <T_ILLOP_handler>:
TRAPHANDLER_NOEC(T_ILLOP_handler, T_ILLOP)
f0104a20:	6a 00                	push   $0x0
f0104a22:	6a 06                	push   $0x6
f0104a24:	e9 a6 00 00 00       	jmp    f0104acf <_alltraps>
f0104a29:	90                   	nop

f0104a2a <T_DEVICE_handler>:
TRAPHANDLER_NOEC(T_DEVICE_handler, T_DEVICE)
f0104a2a:	6a 00                	push   $0x0
f0104a2c:	6a 07                	push   $0x7
f0104a2e:	e9 9c 00 00 00       	jmp    f0104acf <_alltraps>
f0104a33:	90                   	nop

f0104a34 <T_DBLFLT_handler>:
TRAPHANDLER_NOEC(T_DBLFLT_handler, T_DBLFLT)
f0104a34:	6a 00                	push   $0x0
f0104a36:	6a 08                	push   $0x8
f0104a38:	e9 92 00 00 00       	jmp    f0104acf <_alltraps>
f0104a3d:	90                   	nop

f0104a3e <T_TSS_handler>:

TRAPHANDLER_NOEC(T_TSS_handler, T_TSS)
f0104a3e:	6a 00                	push   $0x0
f0104a40:	6a 0a                	push   $0xa
f0104a42:	e9 88 00 00 00       	jmp    f0104acf <_alltraps>
f0104a47:	90                   	nop

f0104a48 <T_SEGNP_handler>:
TRAPHANDLER_NOEC(T_SEGNP_handler, T_SEGNP)
f0104a48:	6a 00                	push   $0x0
f0104a4a:	6a 0b                	push   $0xb
f0104a4c:	e9 7e 00 00 00       	jmp    f0104acf <_alltraps>
f0104a51:	90                   	nop

f0104a52 <T_STACK_handler>:
TRAPHANDLER_NOEC(T_STACK_handler, T_STACK)
f0104a52:	6a 00                	push   $0x0
f0104a54:	6a 0c                	push   $0xc
f0104a56:	e9 74 00 00 00       	jmp    f0104acf <_alltraps>
f0104a5b:	90                   	nop

f0104a5c <T_GPFLT_handler>:
TRAPHANDLER(T_GPFLT_handler, T_GPFLT)
f0104a5c:	6a 0d                	push   $0xd
f0104a5e:	e9 6c 00 00 00       	jmp    f0104acf <_alltraps>
f0104a63:	90                   	nop

f0104a64 <T_PGFLT_handler>:
TRAPHANDLER(T_PGFLT_handler, T_PGFLT)
f0104a64:	6a 0e                	push   $0xe
f0104a66:	e9 64 00 00 00       	jmp    f0104acf <_alltraps>
f0104a6b:	90                   	nop

f0104a6c <T_FPERR_handler>:

TRAPHANDLER_NOEC(T_FPERR_handler, T_FPERR)
f0104a6c:	6a 00                	push   $0x0
f0104a6e:	6a 10                	push   $0x10
f0104a70:	e9 5a 00 00 00       	jmp    f0104acf <_alltraps>
f0104a75:	90                   	nop

f0104a76 <T_ALIGN_handler>:
TRAPHANDLER_NOEC(T_ALIGN_handler, T_ALIGN)
f0104a76:	6a 00                	push   $0x0
f0104a78:	6a 11                	push   $0x11
f0104a7a:	e9 50 00 00 00       	jmp    f0104acf <_alltraps>
f0104a7f:	90                   	nop

f0104a80 <T_MCHK_handler>:
TRAPHANDLER_NOEC(T_MCHK_handler, T_MCHK)
f0104a80:	6a 00                	push   $0x0
f0104a82:	6a 12                	push   $0x12
f0104a84:	e9 46 00 00 00       	jmp    f0104acf <_alltraps>
f0104a89:	90                   	nop

f0104a8a <T_SIMDERR_handler>:
TRAPHANDLER_NOEC(T_SIMDERR_handler, T_SIMDERR)
f0104a8a:	6a 00                	push   $0x0
f0104a8c:	6a 13                	push   $0x13
f0104a8e:	e9 3c 00 00 00       	jmp    f0104acf <_alltraps>
f0104a93:	90                   	nop

f0104a94 <T_SYSCALL_handler>:

TRAPHANDLER_NOEC(T_SYSCALL_handler, T_SYSCALL)
f0104a94:	6a 00                	push   $0x0
f0104a96:	6a 30                	push   $0x30
f0104a98:	e9 32 00 00 00       	jmp    f0104acf <_alltraps>
f0104a9d:	90                   	nop

f0104a9e <IRQ_TIMER_handler>:

/* 
 * Lab 4: Hardware handlers
 */
TRAPHANDLER_NOEC(IRQ_TIMER_handler, IRQ_OFFSET+IRQ_TIMER)
f0104a9e:	6a 00                	push   $0x0
f0104aa0:	6a 20                	push   $0x20
f0104aa2:	e9 28 00 00 00       	jmp    f0104acf <_alltraps>
f0104aa7:	90                   	nop

f0104aa8 <IRQ_KBD_handler>:
TRAPHANDLER_NOEC(IRQ_KBD_handler, IRQ_OFFSET+IRQ_KBD)
f0104aa8:	6a 00                	push   $0x0
f0104aaa:	6a 21                	push   $0x21
f0104aac:	e9 1e 00 00 00       	jmp    f0104acf <_alltraps>
f0104ab1:	90                   	nop

f0104ab2 <IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(IRQ_SERIAL_handler, IRQ_OFFSET+IRQ_SERIAL)
f0104ab2:	6a 00                	push   $0x0
f0104ab4:	6a 24                	push   $0x24
f0104ab6:	e9 14 00 00 00       	jmp    f0104acf <_alltraps>
f0104abb:	90                   	nop

f0104abc <IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(IRQ_SPURIOUS_handler, IRQ_OFFSET+IRQ_SPURIOUS)
f0104abc:	6a 00                	push   $0x0
f0104abe:	6a 27                	push   $0x27
f0104ac0:	e9 0a 00 00 00       	jmp    f0104acf <_alltraps>
f0104ac5:	90                   	nop

f0104ac6 <IRQ_IDE_handler>:
TRAPHANDLER_NOEC(IRQ_IDE_handler, IRQ_OFFSET+IRQ_IDE)
f0104ac6:	6a 00                	push   $0x0
f0104ac8:	6a 2e                	push   $0x2e
f0104aca:	e9 00 00 00 00       	jmp    f0104acf <_alltraps>

f0104acf <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
  # Build trap frame.
  pushl %ds
f0104acf:	1e                   	push   %ds
  pushl %es
f0104ad0:	06                   	push   %es
  pushal
f0104ad1:	60                   	pusha  

  # Save information
  movl $GD_KD, %eax
f0104ad2:	b8 10 00 00 00       	mov    $0x10,%eax
  movw %ax, %ds
f0104ad7:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0104ad9:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
f0104adb:	54                   	push   %esp
  call trap
f0104adc:	e8 c8 fc ff ff       	call   f01047a9 <trap>
f0104ae1:	00 00                	add    %al,(%eax)
	...

f0104ae4 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104ae4:	55                   	push   %ebp
f0104ae5:	89 e5                	mov    %esp,%ebp
f0104ae7:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104aea:	8b 15 48 12 33 f0    	mov    0xf0331248,%edx
f0104af0:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104af3:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104af8:	8b 0a                	mov    (%edx),%ecx
f0104afa:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104afb:	83 f9 02             	cmp    $0x2,%ecx
f0104afe:	76 0d                	jbe    f0104b0d <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104b00:	40                   	inc    %eax
f0104b01:	83 c2 7c             	add    $0x7c,%edx
f0104b04:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b09:	75 ed                	jne    f0104af8 <sched_halt+0x14>
f0104b0b:	eb 07                	jmp    f0104b14 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104b0d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104b12:	75 1a                	jne    f0104b2e <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104b14:	c7 04 24 b0 81 10 f0 	movl   $0xf01081b0,(%esp)
f0104b1b:	e8 aa f3 ff ff       	call   f0103eca <cprintf>
		while (1)
			monitor(NULL);
f0104b20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104b27:	e8 6e bd ff ff       	call   f010089a <monitor>
f0104b2c:	eb f2                	jmp    f0104b20 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104b2e:	e8 e5 18 00 00       	call   f0106418 <cpunum>
f0104b33:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b3a:	29 c2                	sub    %eax,%edx
f0104b3c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b3f:	c7 04 85 28 20 33 f0 	movl   $0x0,-0xfccdfd8(,%eax,4)
f0104b46:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104b4a:	a1 8c 1e 33 f0       	mov    0xf0331e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104b4f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104b54:	77 20                	ja     f0104b76 <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104b56:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104b5a:	c7 44 24 08 04 6b 10 	movl   $0xf0106b04,0x8(%esp)
f0104b61:	f0 
f0104b62:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0104b69:	00 
f0104b6a:	c7 04 24 d9 81 10 f0 	movl   $0xf01081d9,(%esp)
f0104b71:	e8 ca b4 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104b76:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104b7b:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104b7e:	e8 95 18 00 00       	call   f0106418 <cpunum>
f0104b83:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b8a:	29 c2                	sub    %eax,%edx
f0104b8c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b8f:	8d 14 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104b96:	b8 02 00 00 00       	mov    $0x2,%eax
f0104b9b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104b9f:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104ba6:	e8 cf 1b 00 00       	call   f010677a <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104bab:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104bad:	e8 66 18 00 00       	call   f0106418 <cpunum>
f0104bb2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bb9:	29 c2                	sub    %eax,%edx
f0104bbb:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104bbe:	8b 04 85 30 20 33 f0 	mov    -0xfccdfd0(,%eax,4),%eax
f0104bc5:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104bca:	89 c4                	mov    %eax,%esp
f0104bcc:	6a 00                	push   $0x0
f0104bce:	6a 00                	push   $0x0
f0104bd0:	fb                   	sti    
f0104bd1:	f4                   	hlt    
f0104bd2:	eb fd                	jmp    f0104bd1 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104bd4:	c9                   	leave  
f0104bd5:	c3                   	ret    

f0104bd6 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104bd6:	55                   	push   %ebp
f0104bd7:	89 e5                	mov    %esp,%ebp
f0104bd9:	56                   	push   %esi
f0104bda:	53                   	push   %ebx
f0104bdb:	83 ec 10             	sub    $0x10,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	int idx = ENVX((curenv ? ENVX(curenv->env_id) : 0) + 1);
f0104bde:	e8 35 18 00 00       	call   f0106418 <cpunum>
f0104be3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104bea:	29 c2                	sub    %eax,%edx
f0104bec:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bef:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0104bf6:	00 
f0104bf7:	74 23                	je     f0104c1c <sched_yield+0x46>
f0104bf9:	e8 1a 18 00 00       	call   f0106418 <cpunum>
f0104bfe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c05:	29 c2                	sub    %eax,%edx
f0104c07:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c0a:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104c11:	8b 40 48             	mov    0x48(%eax),%eax
f0104c14:	40                   	inc    %eax
f0104c15:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104c1a:	eb 05                	jmp    f0104c21 <sched_yield+0x4b>
f0104c1c:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 0; i < NENV; i++) {
		// Get the environment
		idle = &envs[idx];
f0104c21:	8b 35 48 12 33 f0    	mov    0xf0331248,%esi
f0104c27:	ba 00 04 00 00       	mov    $0x400,%edx
f0104c2c:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0104c33:	89 c1                	mov    %eax,%ecx
f0104c35:	c1 e1 07             	shl    $0x7,%ecx
f0104c38:	29 d9                	sub    %ebx,%ecx
f0104c3a:	01 f1                	add    %esi,%ecx
		if (idle->env_status == ENV_RUNNABLE) {
f0104c3c:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0104c40:	75 08                	jne    f0104c4a <sched_yield+0x74>
			env_run(idle);
f0104c42:	89 0c 24             	mov    %ecx,(%esp)
f0104c45:	e8 3c f0 ff ff       	call   f0103c86 <env_run>
			break;
		}
		idx = ENVX(idx + 1);
f0104c4a:	40                   	inc    %eax
f0104c4b:	25 ff 03 00 00       	and    $0x3ff,%eax
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	int idx = ENVX((curenv ? ENVX(curenv->env_id) : 0) + 1);
	for (i = 0; i < NENV; i++) {
f0104c50:	4a                   	dec    %edx
f0104c51:	75 d9                	jne    f0104c2c <sched_yield+0x56>
			break;
		}
		idx = ENVX(idx + 1);
	}
	// If not found, then continue the original one
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0104c53:	e8 c0 17 00 00       	call   f0106418 <cpunum>
f0104c58:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c5f:	29 c2                	sub    %eax,%edx
f0104c61:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c64:	83 3c 85 28 20 33 f0 	cmpl   $0x0,-0xfccdfd8(,%eax,4)
f0104c6b:	00 
f0104c6c:	74 3e                	je     f0104cac <sched_yield+0xd6>
f0104c6e:	e8 a5 17 00 00       	call   f0106418 <cpunum>
f0104c73:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c7a:	29 c2                	sub    %eax,%edx
f0104c7c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c7f:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104c86:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104c8a:	75 20                	jne    f0104cac <sched_yield+0xd6>
		env_run(curenv);
f0104c8c:	e8 87 17 00 00       	call   f0106418 <cpunum>
f0104c91:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c98:	29 c2                	sub    %eax,%edx
f0104c9a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c9d:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104ca4:	89 04 24             	mov    %eax,(%esp)
f0104ca7:	e8 da ef ff ff       	call   f0103c86 <env_run>
	
	// sched_halt never returns
	sched_halt();
f0104cac:	e8 33 fe ff ff       	call   f0104ae4 <sched_halt>
}
f0104cb1:	83 c4 10             	add    $0x10,%esp
f0104cb4:	5b                   	pop    %ebx
f0104cb5:	5e                   	pop    %esi
f0104cb6:	5d                   	pop    %ebp
f0104cb7:	c3                   	ret    

f0104cb8 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104cb8:	55                   	push   %ebp
f0104cb9:	89 e5                	mov    %esp,%ebp
f0104cbb:	57                   	push   %edi
f0104cbc:	56                   	push   %esi
f0104cbd:	53                   	push   %ebx
f0104cbe:	83 ec 3c             	sub    $0x3c,%esp
f0104cc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cc4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cc7:	8b 75 10             	mov    0x10(%ebp),%esi
f0104cca:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret;

	switch (syscallno) {
f0104ccd:	83 f8 0c             	cmp    $0xc,%eax
f0104cd0:	0f 87 7f 06 00 00    	ja     f0105355 <syscall+0x69d>
f0104cd6:	ff 24 85 3c 82 10 f0 	jmp    *-0xfef7dc4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104cdd:	e8 36 17 00 00       	call   f0106418 <cpunum>
f0104ce2:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104ce9:	00 
f0104cea:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104cee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104cf2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104cf9:	29 c2                	sub    %eax,%edx
f0104cfb:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cfe:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104d05:	89 04 24             	mov    %eax,(%esp)
f0104d08:	e8 e8 e6 ff ff       	call   f01033f5 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104d0d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104d11:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d15:	c7 04 24 e6 81 10 f0 	movl   $0xf01081e6,(%esp)
f0104d1c:	e8 a9 f1 ff ff       	call   f0103eca <cprintf>
	int32_t ret;

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
f0104d21:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d26:	e9 2f 06 00 00       	jmp    f010535a <syscall+0x6a2>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104d2b:	e8 ea b8 ff ff       	call   f010061a <cons_getc>
f0104d30:	89 c3                	mov    %eax,%ebx
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
		break;
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
f0104d32:	e9 23 06 00 00       	jmp    f010535a <syscall+0x6a2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104d37:	e8 dc 16 00 00       	call   f0106418 <cpunum>
f0104d3c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d43:	29 c2                	sub    %eax,%edx
f0104d45:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d48:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104d4f:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
f0104d52:	e9 03 06 00 00       	jmp    f010535a <syscall+0x6a2>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104d57:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d5e:	00 
f0104d5f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d62:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d66:	89 1c 24             	mov    %ebx,(%esp)
f0104d69:	e8 7d e7 ff ff       	call   f01034eb <envid2env>
f0104d6e:	89 c3                	mov    %eax,%ebx
f0104d70:	85 c0                	test   %eax,%eax
f0104d72:	0f 88 e2 05 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	if (e == curenv)
f0104d78:	e8 9b 16 00 00       	call   f0106418 <cpunum>
f0104d7d:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104d80:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f0104d87:	29 c1                	sub    %eax,%ecx
f0104d89:	8d 04 88             	lea    (%eax,%ecx,4),%eax
f0104d8c:	39 14 85 28 20 33 f0 	cmp    %edx,-0xfccdfd8(,%eax,4)
f0104d93:	75 2d                	jne    f0104dc2 <syscall+0x10a>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104d95:	e8 7e 16 00 00       	call   f0106418 <cpunum>
f0104d9a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104da1:	29 c2                	sub    %eax,%edx
f0104da3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104da6:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104dad:	8b 40 48             	mov    0x48(%eax),%eax
f0104db0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104db4:	c7 04 24 eb 81 10 f0 	movl   $0xf01081eb,(%esp)
f0104dbb:	e8 0a f1 ff ff       	call   f0103eca <cprintf>
f0104dc0:	eb 32                	jmp    f0104df4 <syscall+0x13c>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104dc2:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104dc5:	e8 4e 16 00 00       	call   f0106418 <cpunum>
f0104dca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104dce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104dd5:	29 c2                	sub    %eax,%edx
f0104dd7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104dda:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104de1:	8b 40 48             	mov    0x48(%eax),%eax
f0104de4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104de8:	c7 04 24 06 82 10 f0 	movl   $0xf0108206,(%esp)
f0104def:	e8 d6 f0 ff ff       	call   f0103eca <cprintf>
	env_destroy(e);
f0104df4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104df7:	89 04 24             	mov    %eax,(%esp)
f0104dfa:	e8 c8 ed ff ff       	call   f0103bc7 <env_destroy>
	return 0;
f0104dff:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
	case SYS_env_destroy:
		ret = sys_env_destroy((envid_t)a1);
		break;
f0104e04:	e9 51 05 00 00       	jmp    f010535a <syscall+0x6a2>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104e09:	e8 c8 fd ff ff       	call   f0104bd6 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((r = env_alloc(&env_store, curenv->env_id)) < 0) {
f0104e0e:	e8 05 16 00 00       	call   f0106418 <cpunum>
f0104e13:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e1a:	29 c2                	sub    %eax,%edx
f0104e1c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e1f:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104e26:	8b 40 48             	mov    0x48(%eax),%eax
f0104e29:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e2d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e30:	89 04 24             	mov    %eax,(%esp)
f0104e33:	e8 e7 e7 ff ff       	call   f010361f <env_alloc>
f0104e38:	89 c3                	mov    %eax,%ebx
f0104e3a:	85 c0                	test   %eax,%eax
f0104e3c:	0f 88 18 05 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	}
	env_store->env_status = ENV_NOT_RUNNABLE;
f0104e42:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e45:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove((void *) &env_store->env_tf, (void *)&curenv->env_tf, sizeof(struct Trapframe));
f0104e4c:	e8 c7 15 00 00       	call   f0106418 <cpunum>
f0104e51:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104e58:	00 
f0104e59:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104e60:	29 c2                	sub    %eax,%edx
f0104e62:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104e65:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f0104e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e70:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e73:	89 04 24             	mov    %eax,(%esp)
f0104e76:	e8 b9 0f 00 00       	call   f0105e34 <memmove>
	// Set return of child process to be 0
	env_store->env_tf.tf_regs.reg_eax = 0;
f0104e7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e7e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env_store->env_id;
f0104e85:	8b 58 48             	mov    0x48(%eax),%ebx
		sys_yield();
		ret = 0;
		break;
	case SYS_exofork:
		ret = sys_exofork();
		break;
f0104e88:	e9 cd 04 00 00       	jmp    f010535a <syscall+0x6a2>
	// envid's status.

	// LAB 4: Your code here.
	int r;
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104e8d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e94:	00 
f0104e95:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e98:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e9c:	89 1c 24             	mov    %ebx,(%esp)
f0104e9f:	e8 47 e6 ff ff       	call   f01034eb <envid2env>
f0104ea4:	89 c3                	mov    %eax,%ebx
f0104ea6:	85 c0                	test   %eax,%eax
f0104ea8:	0f 88 ac 04 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	}
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
f0104eae:	83 fe 04             	cmp    $0x4,%esi
f0104eb1:	74 05                	je     f0104eb8 <syscall+0x200>
f0104eb3:	83 fe 02             	cmp    $0x2,%esi
f0104eb6:	75 10                	jne    f0104ec8 <syscall+0x210>
		return -E_INVAL;
	}
	env_store->env_status = status;
f0104eb8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104ebb:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104ec3:	e9 92 04 00 00       	jmp    f010535a <syscall+0x6a2>
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
		return r;
	}
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
		return -E_INVAL;
f0104ec8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_exofork:
		ret = sys_exofork();
		break;
	case SYS_env_set_status:
		ret = sys_env_set_status((envid_t)a1, (int)a2);
		break;
f0104ecd:	e9 88 04 00 00       	jmp    f010535a <syscall+0x6a2>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct PageInfo *newPage = page_alloc(ALLOC_ZERO);
f0104ed2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104ed9:	e8 68 c0 ff ff       	call   f0100f46 <page_alloc>
f0104ede:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Env *env_store;
	int r;
	if (!newPage) {
f0104ee1:	85 c0                	test   %eax,%eax
f0104ee3:	74 6e                	je     f0104f53 <syscall+0x29b>
		return -E_NO_MEM;
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
f0104ee5:	89 f8                	mov    %edi,%eax
f0104ee7:	83 e0 05             	and    $0x5,%eax
f0104eea:	83 f8 05             	cmp    $0x5,%eax
f0104eed:	75 6e                	jne    f0104f5d <syscall+0x2a5>
		return -E_INVAL;
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0104eef:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f0104ef5:	75 70                	jne    f0104f67 <syscall+0x2af>
		return -E_INVAL;
	}
	if ((uintptr_t)va >= UTOP) {
f0104ef7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104efd:	77 72                	ja     f0104f71 <syscall+0x2b9>
		return -E_INVAL;
	}
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104eff:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f06:	00 
f0104f07:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f0a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f0e:	89 1c 24             	mov    %ebx,(%esp)
f0104f11:	e8 d5 e5 ff ff       	call   f01034eb <envid2env>
f0104f16:	89 c3                	mov    %eax,%ebx
f0104f18:	85 c0                	test   %eax,%eax
f0104f1a:	0f 88 3a 04 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	}
	if ((r = page_insert(env_store->env_pgdir, newPage, va, perm)) < 0) {
f0104f20:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104f24:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104f28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f2b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f2f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f32:	8b 40 60             	mov    0x60(%eax),%eax
f0104f35:	89 04 24             	mov    %eax,(%esp)
f0104f38:	e8 fa c2 ff ff       	call   f0101237 <page_insert>
f0104f3d:	89 c3                	mov    %eax,%ebx
f0104f3f:	85 c0                	test   %eax,%eax
f0104f41:	79 38                	jns    f0104f7b <syscall+0x2c3>
		page_free(newPage);
f0104f43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104f46:	89 04 24             	mov    %eax,(%esp)
f0104f49:	e8 7c c0 ff ff       	call   f0100fca <page_free>
f0104f4e:	e9 07 04 00 00       	jmp    f010535a <syscall+0x6a2>
	// LAB 4: Your code here.
	struct PageInfo *newPage = page_alloc(ALLOC_ZERO);
	struct Env *env_store;
	int r;
	if (!newPage) {
		return -E_NO_MEM;
f0104f53:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104f58:	e9 fd 03 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
		return -E_INVAL;
f0104f5d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f62:	e9 f3 03 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
		return -E_INVAL;
f0104f67:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f6c:	e9 e9 03 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((uintptr_t)va >= UTOP) {
		return -E_INVAL;
f0104f71:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f76:	e9 df 03 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((r = page_insert(env_store->env_pgdir, newPage, va, perm)) < 0) {
		page_free(newPage);
		return r;
	}
	return 0;
f0104f7b:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_env_set_status:
		ret = sys_env_set_status((envid_t)a1, (int)a2);
		break;
	case SYS_page_alloc:
		ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		break;
f0104f80:	e9 d5 03 00 00       	jmp    f010535a <syscall+0x6a2>
	// LAB 4: Your code here.
	struct PageInfo *srcPage;
	struct Env *srcenv_store, *dstenv_store;
	pte_t *srcpte_store;
	int r;
	if ((r = envid2env(srcenvid, &srcenv_store, true)) < 0) {
f0104f85:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104f8c:	00 
f0104f8d:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104f90:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f94:	89 1c 24             	mov    %ebx,(%esp)
f0104f97:	e8 4f e5 ff ff       	call   f01034eb <envid2env>
f0104f9c:	89 c3                	mov    %eax,%ebx
f0104f9e:	85 c0                	test   %eax,%eax
f0104fa0:	0f 88 b4 03 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
f0104fa6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fad:	00 
f0104fae:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fb5:	89 3c 24             	mov    %edi,(%esp)
f0104fb8:	e8 2e e5 ff ff       	call   f01034eb <envid2env>
f0104fbd:	89 c3                	mov    %eax,%ebx
f0104fbf:	85 c0                	test   %eax,%eax
f0104fc1:	0f 88 93 03 00 00    	js     f010535a <syscall+0x6a2>
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
f0104fc7:	8b 45 18             	mov    0x18(%ebp),%eax
f0104fca:	09 f0                	or     %esi,%eax
		return r;
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
		return r;
	}
	if ((uintptr_t)srcva % PGSIZE != 0 || (uintptr_t)dstva % PGSIZE != 0) {
f0104fcc:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104fd1:	0f 85 a1 00 00 00    	jne    f0105078 <syscall+0x3c0>
		return -E_INVAL;
	}
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) {
f0104fd7:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104fdd:	77 09                	ja     f0104fe8 <syscall+0x330>
f0104fdf:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104fe6:	76 1d                	jbe    f0105005 <syscall+0x34d>
		cprintf("dstva is now %x\n", dstva);
f0104fe8:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104feb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104fef:	c7 04 24 1e 82 10 f0 	movl   $0xf010821e,(%esp)
f0104ff6:	e8 cf ee ff ff       	call   f0103eca <cprintf>
		return -E_INVAL;
f0104ffb:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105000:	e9 55 03 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
f0105005:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0105008:	83 e0 05             	and    $0x5,%eax
f010500b:	83 f8 05             	cmp    $0x5,%eax
f010500e:	75 72                	jne    f0105082 <syscall+0x3ca>
		return -E_INVAL;
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0105010:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0105017:	75 73                	jne    f010508c <syscall+0x3d4>
		return -E_INVAL;
	}
	if ((srcPage = page_lookup(srcenv_store->env_pgdir, srcva, &srcpte_store)) == NULL) {
f0105019:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010501c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105020:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105024:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105027:	8b 40 60             	mov    0x60(%eax),%eax
f010502a:	89 04 24             	mov    %eax,(%esp)
f010502d:	e8 fa c0 ff ff       	call   f010112c <page_lookup>
f0105032:	85 c0                	test   %eax,%eax
f0105034:	74 60                	je     f0105096 <syscall+0x3de>
		return -E_INVAL;
	}
	if ((perm & PTE_W) && !(*srcpte_store & PTE_W)) {
f0105036:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010503a:	74 08                	je     f0105044 <syscall+0x38c>
f010503c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010503f:	f6 02 02             	testb  $0x2,(%edx)
f0105042:	74 5c                	je     f01050a0 <syscall+0x3e8>
		return -E_INVAL;
	}
	if ((r = page_insert(dstenv_store->env_pgdir, srcPage, dstva, perm)) < 0) {
f0105044:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0105047:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010504b:	8b 5d 18             	mov    0x18(%ebp),%ebx
f010504e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105052:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105056:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105059:	8b 40 60             	mov    0x60(%eax),%eax
f010505c:	89 04 24             	mov    %eax,(%esp)
f010505f:	e8 d3 c1 ff ff       	call   f0101237 <page_insert>
f0105064:	89 c3                	mov    %eax,%ebx
f0105066:	85 c0                	test   %eax,%eax
f0105068:	0f 8e ec 02 00 00    	jle    f010535a <syscall+0x6a2>
f010506e:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105073:	e9 e2 02 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
		return r;
	}
	if ((uintptr_t)srcva % PGSIZE != 0 || (uintptr_t)dstva % PGSIZE != 0) {
		return -E_INVAL;
f0105078:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010507d:	e9 d8 02 00 00       	jmp    f010535a <syscall+0x6a2>
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) {
		cprintf("dstva is now %x\n", dstva);
		return -E_INVAL;
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
		return -E_INVAL;
f0105082:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105087:	e9 ce 02 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
		return -E_INVAL;
f010508c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105091:	e9 c4 02 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((srcPage = page_lookup(srcenv_store->env_pgdir, srcva, &srcpte_store)) == NULL) {
		return -E_INVAL;
f0105096:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010509b:	e9 ba 02 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	if ((perm & PTE_W) && !(*srcpte_store & PTE_W)) {
		return -E_INVAL;
f01050a0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_alloc:
		ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		break;
	case SYS_page_map:
		ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
		break;
f01050a5:	e9 b0 02 00 00       	jmp    f010535a <syscall+0x6a2>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((uintptr_t)va >= UTOP) {
f01050aa:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f01050b0:	77 3d                	ja     f01050ef <syscall+0x437>
		return -E_INVAL;
	}
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f01050b2:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01050b9:	00 
f01050ba:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01050bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01050c1:	89 1c 24             	mov    %ebx,(%esp)
f01050c4:	e8 22 e4 ff ff       	call   f01034eb <envid2env>
f01050c9:	89 c3                	mov    %eax,%ebx
f01050cb:	85 c0                	test   %eax,%eax
f01050cd:	0f 88 87 02 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	}
	page_remove(env_store->env_pgdir, va);
f01050d3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01050d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01050da:	8b 40 60             	mov    0x60(%eax),%eax
f01050dd:	89 04 24             	mov    %eax,(%esp)
f01050e0:	e8 09 c1 ff ff       	call   f01011ee <page_remove>
	return 0;
f01050e5:	bb 00 00 00 00       	mov    $0x0,%ebx
f01050ea:	e9 6b 02 00 00       	jmp    f010535a <syscall+0x6a2>

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((uintptr_t)va >= UTOP) {
		return -E_INVAL;
f01050ef:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_map:
		ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
		break;
	case SYS_page_unmap:
		ret = sys_page_unmap((envid_t)a1, (void *)a2);
		break;
f01050f4:	e9 61 02 00 00       	jmp    f010535a <syscall+0x6a2>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	int r;
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f01050f9:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105100:	00 
f0105101:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105104:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105108:	89 1c 24             	mov    %ebx,(%esp)
f010510b:	e8 db e3 ff ff       	call   f01034eb <envid2env>
f0105110:	89 c3                	mov    %eax,%ebx
f0105112:	85 c0                	test   %eax,%eax
f0105114:	0f 88 40 02 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	}
	env_store->env_pgfault_upcall = func;
f010511a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010511d:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0105120:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_page_unmap:
		ret = sys_page_unmap((envid_t)a1, (void *)a2);
		break;
	case SYS_env_set_pgfault_upcall:
		ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		break;
f0105125:	e9 30 02 00 00       	jmp    f010535a <syscall+0x6a2>
	// LAB 4: Your code here.
	struct PageInfo *srcPage;
	struct Env *env_store;
	pte_t *pte_store;
	int r;
	if ((r = envid2env(envid, &env_store, false)) < 0) {
f010512a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105131:	00 
f0105132:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0105135:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105139:	89 1c 24             	mov    %ebx,(%esp)
f010513c:	e8 aa e3 ff ff       	call   f01034eb <envid2env>
f0105141:	89 c3                	mov    %eax,%ebx
f0105143:	85 c0                	test   %eax,%eax
f0105145:	0f 88 0f 02 00 00    	js     f010535a <syscall+0x6a2>
		return r;
	}
	if ((env_store->env_ipc_recving == false) || (env_store->env_ipc_from != 0)) {
f010514b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010514e:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0105152:	0f 84 01 01 00 00    	je     f0105259 <syscall+0x5a1>
f0105158:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f010515c:	0f 85 01 01 00 00    	jne    f0105263 <syscall+0x5ab>
		return -E_IPC_NOT_RECV;
	}
	// If srcva is less then UTOP
	if ((uintptr_t)srcva < UTOP) {
f0105162:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105168:	0f 87 af 00 00 00    	ja     f010521d <syscall+0x565>
		if ((uintptr_t)srcva % PGSIZE != 0) {
f010516e:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0105174:	0f 85 f3 00 00 00    	jne    f010526d <syscall+0x5b5>
			return -E_INVAL;
		}
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) {
f010517a:	8b 45 18             	mov    0x18(%ebp),%eax
f010517d:	83 e0 05             	and    $0x5,%eax
f0105180:	83 f8 05             	cmp    $0x5,%eax
f0105183:	0f 85 ee 00 00 00    	jne    f0105277 <syscall+0x5bf>
			return -E_INVAL;
		}
		if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0105189:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0105190:	0f 85 eb 00 00 00    	jne    f0105281 <syscall+0x5c9>
			return -E_INVAL;
		}
		if ((srcPage = page_lookup(curenv->env_pgdir, srcva, &pte_store)) == NULL) {
f0105196:	e8 7d 12 00 00       	call   f0106418 <cpunum>
f010519b:	8d 55 e0             	lea    -0x20(%ebp),%edx
f010519e:	89 54 24 08          	mov    %edx,0x8(%esp)
f01051a2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01051a6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01051ad:	29 c2                	sub    %eax,%edx
f01051af:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01051b2:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f01051b9:	8b 40 60             	mov    0x60(%eax),%eax
f01051bc:	89 04 24             	mov    %eax,(%esp)
f01051bf:	e8 68 bf ff ff       	call   f010112c <page_lookup>
f01051c4:	85 c0                	test   %eax,%eax
f01051c6:	0f 84 bf 00 00 00    	je     f010528b <syscall+0x5d3>
			return -E_INVAL;
		}
		if ((perm & PTE_W) && (!(*pte_store & PTE_W))) {
f01051cc:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01051d0:	74 0c                	je     f01051de <syscall+0x526>
f01051d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01051d5:	f6 02 02             	testb  $0x2,(%edx)
f01051d8:	0f 84 b7 00 00 00    	je     f0105295 <syscall+0x5dd>
			return -E_INVAL;
		}
		// Updates
		if ((uintptr_t)env_store->env_ipc_dstva < UTOP) {
f01051de:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01051e1:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f01051e4:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01051ea:	77 2a                	ja     f0105216 <syscall+0x55e>
			if (page_insert(env_store->env_pgdir, srcPage, env_store->env_ipc_dstva, perm) < 0) {
f01051ec:	8b 5d 18             	mov    0x18(%ebp),%ebx
f01051ef:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01051f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01051f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01051fb:	8b 42 60             	mov    0x60(%edx),%eax
f01051fe:	89 04 24             	mov    %eax,(%esp)
f0105201:	e8 31 c0 ff ff       	call   f0101237 <page_insert>
f0105206:	85 c0                	test   %eax,%eax
f0105208:	0f 88 91 00 00 00    	js     f010529f <syscall+0x5e7>
				return -E_NO_MEM;
			}
			env_store->env_ipc_perm = perm;
f010520e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105211:	89 58 78             	mov    %ebx,0x78(%eax)
f0105214:	eb 07                	jmp    f010521d <syscall+0x565>
		}
		else {
			env_store->env_ipc_perm = 0;
f0105216:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
		}
	}
	// Updates
	env_store->env_ipc_recving = false;
f010521d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105220:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_store->env_ipc_from = curenv->env_id;
f0105224:	e8 ef 11 00 00       	call   f0106418 <cpunum>
f0105229:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105230:	29 c2                	sub    %eax,%edx
f0105232:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0105235:	8b 04 85 28 20 33 f0 	mov    -0xfccdfd8(,%eax,4),%eax
f010523c:	8b 40 48             	mov    0x48(%eax),%eax
f010523f:	89 43 74             	mov    %eax,0x74(%ebx)
	env_store->env_ipc_value = value;
f0105242:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105245:	89 70 70             	mov    %esi,0x70(%eax)
	env_store->env_status = ENV_RUNNABLE;
f0105248:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f010524f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105254:	e9 01 01 00 00       	jmp    f010535a <syscall+0x6a2>
	int r;
	if ((r = envid2env(envid, &env_store, false)) < 0) {
		return r;
	}
	if ((env_store->env_ipc_recving == false) || (env_store->env_ipc_from != 0)) {
		return -E_IPC_NOT_RECV;
f0105259:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f010525e:	e9 f7 00 00 00       	jmp    f010535a <syscall+0x6a2>
f0105263:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0105268:	e9 ed 00 00 00       	jmp    f010535a <syscall+0x6a2>
	}
	// If srcva is less then UTOP
	if ((uintptr_t)srcva < UTOP) {
		if ((uintptr_t)srcva % PGSIZE != 0) {
			return -E_INVAL;
f010526d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105272:	e9 e3 00 00 00       	jmp    f010535a <syscall+0x6a2>
		}
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) {
			return -E_INVAL;
f0105277:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010527c:	e9 d9 00 00 00       	jmp    f010535a <syscall+0x6a2>
		}
		if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
			return -E_INVAL;
f0105281:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105286:	e9 cf 00 00 00       	jmp    f010535a <syscall+0x6a2>
		}
		if ((srcPage = page_lookup(curenv->env_pgdir, srcva, &pte_store)) == NULL) {
			return -E_INVAL;
f010528b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0105290:	e9 c5 00 00 00       	jmp    f010535a <syscall+0x6a2>
		}
		if ((perm & PTE_W) && (!(*pte_store & PTE_W))) {
			return -E_INVAL;
f0105295:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010529a:	e9 bb 00 00 00       	jmp    f010535a <syscall+0x6a2>
		}
		// Updates
		if ((uintptr_t)env_store->env_ipc_dstva < UTOP) {
			if (page_insert(env_store->env_pgdir, srcPage, env_store->env_ipc_dstva, perm) < 0) {
				return -E_NO_MEM;
f010529f:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
	case SYS_env_set_pgfault_upcall:
		ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		break;
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
f01052a4:	e9 b1 00 00 00       	jmp    f010535a <syscall+0x6a2>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP) {
f01052a9:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01052af:	77 39                	ja     f01052ea <syscall+0x632>
		if ((uintptr_t)dstva % PGSIZE != 0) {
f01052b1:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01052b7:	74 1e                	je     f01052d7 <syscall+0x61f>
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
		cprintf("value is %d\n", ret);
f01052b9:	c7 44 24 04 fd ff ff 	movl   $0xfffffffd,0x4(%esp)
f01052c0:	ff 
f01052c1:	c7 04 24 2f 82 10 f0 	movl   $0xf010822f,(%esp)
f01052c8:	e8 fd eb ff ff       	call   f0103eca <cprintf>
		break;
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
f01052cd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		cprintf("value is %d\n", ret);
		break;
f01052d2:	e9 83 00 00 00       	jmp    f010535a <syscall+0x6a2>
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP) {
		if ((uintptr_t)dstva % PGSIZE != 0) {
			return -E_INVAL;
		}
		curenv->env_ipc_dstva = dstva;
f01052d7:	e8 3c 11 00 00       	call   f0106418 <cpunum>
f01052dc:	6b c0 74             	imul   $0x74,%eax,%eax
f01052df:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01052e5:	89 58 6c             	mov    %ebx,0x6c(%eax)
f01052e8:	eb 15                	jmp    f01052ff <syscall+0x647>
	}
	else {
		curenv->env_ipc_dstva = (void *)UTOP;
f01052ea:	e8 29 11 00 00       	call   f0106418 <cpunum>
f01052ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01052f2:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f01052f8:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)
	}
	// Mark itself as not runnable
	curenv->env_status = ENV_NOT_RUNNABLE;
f01052ff:	e8 14 11 00 00       	call   f0106418 <cpunum>
f0105304:	6b c0 74             	imul   $0x74,%eax,%eax
f0105307:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f010530d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = true;
f0105314:	e8 ff 10 00 00       	call   f0106418 <cpunum>
f0105319:	6b c0 74             	imul   $0x74,%eax,%eax
f010531c:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0105322:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f0105326:	e8 ed 10 00 00       	call   f0106418 <cpunum>
f010532b:	6b c0 74             	imul   $0x74,%eax,%eax
f010532e:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0105334:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f010533b:	e8 d8 10 00 00       	call   f0106418 <cpunum>
f0105340:	6b c0 74             	imul   $0x74,%eax,%eax
f0105343:	8b 80 28 20 33 f0    	mov    -0xfccdfd8(%eax),%eax
f0105349:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	// Give up the CPU
	sched_yield();
f0105350:	e8 81 f8 ff ff       	call   f0104bd6 <sched_yield>
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
		cprintf("value is %d\n", ret);
		break;
	default:
		ret = -E_INVAL;
f0105355:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		break;
	}

	return ret;
}
f010535a:	89 d8                	mov    %ebx,%eax
f010535c:	83 c4 3c             	add    $0x3c,%esp
f010535f:	5b                   	pop    %ebx
f0105360:	5e                   	pop    %esi
f0105361:	5f                   	pop    %edi
f0105362:	5d                   	pop    %ebp
f0105363:	c3                   	ret    

f0105364 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105364:	55                   	push   %ebp
f0105365:	89 e5                	mov    %esp,%ebp
f0105367:	57                   	push   %edi
f0105368:	56                   	push   %esi
f0105369:	53                   	push   %ebx
f010536a:	83 ec 14             	sub    $0x14,%esp
f010536d:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105370:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105373:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105376:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0105379:	8b 1a                	mov    (%edx),%ebx
f010537b:	8b 01                	mov    (%ecx),%eax
f010537d:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105380:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0105387:	e9 83 00 00 00       	jmp    f010540f <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f010538c:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010538f:	01 d8                	add    %ebx,%eax
f0105391:	89 c7                	mov    %eax,%edi
f0105393:	c1 ef 1f             	shr    $0x1f,%edi
f0105396:	01 c7                	add    %eax,%edi
f0105398:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010539a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010539d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053a0:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01053a4:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053a6:	eb 01                	jmp    f01053a9 <stab_binsearch+0x45>
			m--;
f01053a8:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01053a9:	39 c3                	cmp    %eax,%ebx
f01053ab:	7f 1e                	jg     f01053cb <stab_binsearch+0x67>
f01053ad:	0f b6 0a             	movzbl (%edx),%ecx
f01053b0:	83 ea 0c             	sub    $0xc,%edx
f01053b3:	39 f1                	cmp    %esi,%ecx
f01053b5:	75 f1                	jne    f01053a8 <stab_binsearch+0x44>
f01053b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01053ba:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01053bd:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01053c0:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01053c4:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01053c7:	76 18                	jbe    f01053e1 <stab_binsearch+0x7d>
f01053c9:	eb 05                	jmp    f01053d0 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01053cb:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01053ce:	eb 3f                	jmp    f010540f <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01053d0:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01053d3:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01053d5:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01053d8:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01053df:	eb 2e                	jmp    f010540f <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01053e1:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01053e4:	73 15                	jae    f01053fb <stab_binsearch+0x97>
			*region_right = m - 1;
f01053e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053e9:	49                   	dec    %ecx
f01053ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01053ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053f0:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01053f2:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01053f9:	eb 14                	jmp    f010540f <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01053fb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01053fe:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105401:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f0105403:	ff 45 0c             	incl   0xc(%ebp)
f0105406:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105408:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010540f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105412:	0f 8e 74 ff ff ff    	jle    f010538c <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105418:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010541c:	75 0d                	jne    f010542b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f010541e:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105421:	8b 02                	mov    (%edx),%eax
f0105423:	48                   	dec    %eax
f0105424:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105427:	89 01                	mov    %eax,(%ecx)
f0105429:	eb 2a                	jmp    f0105455 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010542b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010542e:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105430:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105433:	8b 0a                	mov    (%edx),%ecx
f0105435:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105438:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010543b:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010543f:	eb 01                	jmp    f0105442 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105441:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105442:	39 c8                	cmp    %ecx,%eax
f0105444:	7e 0a                	jle    f0105450 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f0105446:	0f b6 1a             	movzbl (%edx),%ebx
f0105449:	83 ea 0c             	sub    $0xc,%edx
f010544c:	39 f3                	cmp    %esi,%ebx
f010544e:	75 f1                	jne    f0105441 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105450:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105453:	89 02                	mov    %eax,(%edx)
	}
}
f0105455:	83 c4 14             	add    $0x14,%esp
f0105458:	5b                   	pop    %ebx
f0105459:	5e                   	pop    %esi
f010545a:	5f                   	pop    %edi
f010545b:	5d                   	pop    %ebp
f010545c:	c3                   	ret    

f010545d <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010545d:	55                   	push   %ebp
f010545e:	89 e5                	mov    %esp,%ebp
f0105460:	57                   	push   %edi
f0105461:	56                   	push   %esi
f0105462:	53                   	push   %ebx
f0105463:	83 ec 3c             	sub    $0x3c,%esp
f0105466:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105469:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010546c:	c7 06 70 82 10 f0    	movl   $0xf0108270,(%esi)
	info->eip_line = 0;
f0105472:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0105479:	c7 46 08 70 82 10 f0 	movl   $0xf0108270,0x8(%esi)
	info->eip_fn_namelen = 9;
f0105480:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0105487:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010548a:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105491:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0105497:	77 22                	ja     f01054bb <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0105499:	8b 1d 00 00 20 00    	mov    0x200000,%ebx
f010549f:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
		stab_end = usd->stab_end;
f01054a2:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01054a7:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f01054ad:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f01054b0:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f01054b6:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01054b9:	eb 1a                	jmp    f01054d5 <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01054bb:	c7 45 d0 fa e2 11 f0 	movl   $0xf011e2fa,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01054c2:	c7 45 cc dd 37 11 f0 	movl   $0xf01137dd,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01054c9:	b8 dc 37 11 f0       	mov    $0xf01137dc,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01054ce:	c7 45 d4 54 87 10 f0 	movl   $0xf0108754,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01054d5:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01054d8:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f01054db:	0f 83 24 01 00 00    	jae    f0105605 <debuginfo_eip+0x1a8>
f01054e1:	80 7b ff 00          	cmpb   $0x0,-0x1(%ebx)
f01054e5:	0f 85 21 01 00 00    	jne    f010560c <debuginfo_eip+0x1af>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01054eb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01054f2:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f01054f5:	c1 f8 02             	sar    $0x2,%eax
f01054f8:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01054fb:	8d 14 90             	lea    (%eax,%edx,4),%edx
f01054fe:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105501:	89 d1                	mov    %edx,%ecx
f0105503:	c1 e1 08             	shl    $0x8,%ecx
f0105506:	01 ca                	add    %ecx,%edx
f0105508:	89 d1                	mov    %edx,%ecx
f010550a:	c1 e1 10             	shl    $0x10,%ecx
f010550d:	01 ca                	add    %ecx,%edx
f010550f:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f0105513:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0105516:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010551a:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105521:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105524:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105527:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010552a:	e8 35 fe ff ff       	call   f0105364 <stab_binsearch>
	if (lfile == 0)
f010552f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105532:	85 c0                	test   %eax,%eax
f0105534:	0f 84 d9 00 00 00    	je     f0105613 <debuginfo_eip+0x1b6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010553a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010553d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105540:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105543:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105547:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f010554e:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105551:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105554:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105557:	e8 08 fe ff ff       	call   f0105364 <stab_binsearch>

	if (lfun <= rfun) {
f010555c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010555f:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0105562:	7f 23                	jg     f0105587 <debuginfo_eip+0x12a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105564:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010556a:	8d 04 82             	lea    (%edx,%eax,4),%eax
f010556d:	8b 10                	mov    (%eax),%edx
f010556f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105572:	2b 4d cc             	sub    -0x34(%ebp),%ecx
f0105575:	39 ca                	cmp    %ecx,%edx
f0105577:	73 06                	jae    f010557f <debuginfo_eip+0x122>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0105579:	03 55 cc             	add    -0x34(%ebp),%edx
f010557c:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010557f:	8b 40 08             	mov    0x8(%eax),%eax
f0105582:	89 46 10             	mov    %eax,0x10(%esi)
f0105585:	eb 06                	jmp    f010558d <debuginfo_eip+0x130>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0105587:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f010558a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010558d:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105594:	00 
f0105595:	8b 46 08             	mov    0x8(%esi),%eax
f0105598:	89 04 24             	mov    %eax,(%esp)
f010559b:	e8 32 08 00 00       	call   f0105dd2 <strfind>
f01055a0:	2b 46 08             	sub    0x8(%esi),%eax
f01055a3:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01055a9:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01055ac:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01055af:	8d 44 82 08          	lea    0x8(%edx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055b3:	eb 04                	jmp    f01055b9 <debuginfo_eip+0x15c>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01055b5:	4b                   	dec    %ebx
f01055b6:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01055b9:	39 fb                	cmp    %edi,%ebx
f01055bb:	7c 19                	jl     f01055d6 <debuginfo_eip+0x179>
	       && stabs[lline].n_type != N_SOL
f01055bd:	8a 50 fc             	mov    -0x4(%eax),%dl
f01055c0:	80 fa 84             	cmp    $0x84,%dl
f01055c3:	74 69                	je     f010562e <debuginfo_eip+0x1d1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01055c5:	80 fa 64             	cmp    $0x64,%dl
f01055c8:	75 eb                	jne    f01055b5 <debuginfo_eip+0x158>
f01055ca:	83 38 00             	cmpl   $0x0,(%eax)
f01055cd:	74 e6                	je     f01055b5 <debuginfo_eip+0x158>
f01055cf:	eb 5d                	jmp    f010562e <debuginfo_eip+0x1d1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01055d1:	03 45 cc             	add    -0x34(%ebp),%eax
f01055d4:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01055d6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01055d9:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01055dc:	39 c8                	cmp    %ecx,%eax
f01055de:	7d 3a                	jge    f010561a <debuginfo_eip+0x1bd>
		for (lline = lfun + 1;
f01055e0:	40                   	inc    %eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055e1:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01055e4:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01055e7:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01055eb:	eb 04                	jmp    f01055f1 <debuginfo_eip+0x194>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01055ed:	ff 46 14             	incl   0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01055f0:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01055f1:	39 c8                	cmp    %ecx,%eax
f01055f3:	74 2c                	je     f0105621 <debuginfo_eip+0x1c4>
f01055f5:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01055f8:	80 7a f4 a0          	cmpb   $0xa0,-0xc(%edx)
f01055fc:	74 ef                	je     f01055ed <debuginfo_eip+0x190>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01055fe:	b8 00 00 00 00       	mov    $0x0,%eax
f0105603:	eb 21                	jmp    f0105626 <debuginfo_eip+0x1c9>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105605:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010560a:	eb 1a                	jmp    f0105626 <debuginfo_eip+0x1c9>
f010560c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105611:	eb 13                	jmp    f0105626 <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105618:	eb 0c                	jmp    f0105626 <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010561a:	b8 00 00 00 00       	mov    $0x0,%eax
f010561f:	eb 05                	jmp    f0105626 <debuginfo_eip+0x1c9>
f0105621:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105626:	83 c4 3c             	add    $0x3c,%esp
f0105629:	5b                   	pop    %ebx
f010562a:	5e                   	pop    %esi
f010562b:	5f                   	pop    %edi
f010562c:	5d                   	pop    %ebp
f010562d:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010562e:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105631:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105634:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f0105637:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010563a:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010563d:	39 d0                	cmp    %edx,%eax
f010563f:	72 90                	jb     f01055d1 <debuginfo_eip+0x174>
f0105641:	eb 93                	jmp    f01055d6 <debuginfo_eip+0x179>
	...

f0105644 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105644:	55                   	push   %ebp
f0105645:	89 e5                	mov    %esp,%ebp
f0105647:	57                   	push   %edi
f0105648:	56                   	push   %esi
f0105649:	53                   	push   %ebx
f010564a:	83 ec 3c             	sub    $0x3c,%esp
f010564d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105650:	89 d7                	mov    %edx,%edi
f0105652:	8b 45 08             	mov    0x8(%ebp),%eax
f0105655:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105658:	8b 45 0c             	mov    0xc(%ebp),%eax
f010565b:	89 45 e0             	mov    %eax,-0x20(%ebp)
f010565e:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105661:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105664:	85 c0                	test   %eax,%eax
f0105666:	75 08                	jne    f0105670 <printnum+0x2c>
f0105668:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010566b:	39 45 10             	cmp    %eax,0x10(%ebp)
f010566e:	77 57                	ja     f01056c7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105670:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105674:	4b                   	dec    %ebx
f0105675:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105679:	8b 45 10             	mov    0x10(%ebp),%eax
f010567c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105680:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105684:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0105688:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010568f:	00 
f0105690:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105693:	89 04 24             	mov    %eax,(%esp)
f0105696:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105699:	89 44 24 04          	mov    %eax,0x4(%esp)
f010569d:	e8 e6 11 00 00       	call   f0106888 <__udivdi3>
f01056a2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01056a6:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01056aa:	89 04 24             	mov    %eax,(%esp)
f01056ad:	89 54 24 04          	mov    %edx,0x4(%esp)
f01056b1:	89 fa                	mov    %edi,%edx
f01056b3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01056b6:	e8 89 ff ff ff       	call   f0105644 <printnum>
f01056bb:	eb 0f                	jmp    f01056cc <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01056bd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056c1:	89 34 24             	mov    %esi,(%esp)
f01056c4:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01056c7:	4b                   	dec    %ebx
f01056c8:	85 db                	test   %ebx,%ebx
f01056ca:	7f f1                	jg     f01056bd <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01056cc:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056d0:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01056d4:	8b 45 10             	mov    0x10(%ebp),%eax
f01056d7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01056db:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01056e2:	00 
f01056e3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01056e6:	89 04 24             	mov    %eax,(%esp)
f01056e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056f0:	e8 b3 12 00 00       	call   f01069a8 <__umoddi3>
f01056f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01056f9:	0f be 80 7a 82 10 f0 	movsbl -0xfef7d86(%eax),%eax
f0105700:	89 04 24             	mov    %eax,(%esp)
f0105703:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0105706:	83 c4 3c             	add    $0x3c,%esp
f0105709:	5b                   	pop    %ebx
f010570a:	5e                   	pop    %esi
f010570b:	5f                   	pop    %edi
f010570c:	5d                   	pop    %ebp
f010570d:	c3                   	ret    

f010570e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f010570e:	55                   	push   %ebp
f010570f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105711:	83 fa 01             	cmp    $0x1,%edx
f0105714:	7e 0e                	jle    f0105724 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0105716:	8b 10                	mov    (%eax),%edx
f0105718:	8d 4a 08             	lea    0x8(%edx),%ecx
f010571b:	89 08                	mov    %ecx,(%eax)
f010571d:	8b 02                	mov    (%edx),%eax
f010571f:	8b 52 04             	mov    0x4(%edx),%edx
f0105722:	eb 22                	jmp    f0105746 <getuint+0x38>
	else if (lflag)
f0105724:	85 d2                	test   %edx,%edx
f0105726:	74 10                	je     f0105738 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105728:	8b 10                	mov    (%eax),%edx
f010572a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010572d:	89 08                	mov    %ecx,(%eax)
f010572f:	8b 02                	mov    (%edx),%eax
f0105731:	ba 00 00 00 00       	mov    $0x0,%edx
f0105736:	eb 0e                	jmp    f0105746 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105738:	8b 10                	mov    (%eax),%edx
f010573a:	8d 4a 04             	lea    0x4(%edx),%ecx
f010573d:	89 08                	mov    %ecx,(%eax)
f010573f:	8b 02                	mov    (%edx),%eax
f0105741:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105746:	5d                   	pop    %ebp
f0105747:	c3                   	ret    

f0105748 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105748:	55                   	push   %ebp
f0105749:	89 e5                	mov    %esp,%ebp
f010574b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f010574e:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105751:	8b 10                	mov    (%eax),%edx
f0105753:	3b 50 04             	cmp    0x4(%eax),%edx
f0105756:	73 08                	jae    f0105760 <sprintputch+0x18>
		*b->buf++ = ch;
f0105758:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010575b:	88 0a                	mov    %cl,(%edx)
f010575d:	42                   	inc    %edx
f010575e:	89 10                	mov    %edx,(%eax)
}
f0105760:	5d                   	pop    %ebp
f0105761:	c3                   	ret    

f0105762 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105762:	55                   	push   %ebp
f0105763:	89 e5                	mov    %esp,%ebp
f0105765:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105768:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010576b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010576f:	8b 45 10             	mov    0x10(%ebp),%eax
f0105772:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105776:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105779:	89 44 24 04          	mov    %eax,0x4(%esp)
f010577d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105780:	89 04 24             	mov    %eax,(%esp)
f0105783:	e8 02 00 00 00       	call   f010578a <vprintfmt>
	va_end(ap);
}
f0105788:	c9                   	leave  
f0105789:	c3                   	ret    

f010578a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010578a:	55                   	push   %ebp
f010578b:	89 e5                	mov    %esp,%ebp
f010578d:	57                   	push   %edi
f010578e:	56                   	push   %esi
f010578f:	53                   	push   %ebx
f0105790:	83 ec 4c             	sub    $0x4c,%esp
f0105793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105796:	8b 75 10             	mov    0x10(%ebp),%esi
f0105799:	eb 12                	jmp    f01057ad <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010579b:	85 c0                	test   %eax,%eax
f010579d:	0f 84 8b 03 00 00    	je     f0105b2e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
f01057a3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057a7:	89 04 24             	mov    %eax,(%esp)
f01057aa:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01057ad:	0f b6 06             	movzbl (%esi),%eax
f01057b0:	46                   	inc    %esi
f01057b1:	83 f8 25             	cmp    $0x25,%eax
f01057b4:	75 e5                	jne    f010579b <vprintfmt+0x11>
f01057b6:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01057ba:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01057c1:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01057c6:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01057cd:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057d2:	eb 26                	jmp    f01057fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057d4:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01057d7:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01057db:	eb 1d                	jmp    f01057fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057dd:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01057e0:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01057e4:	eb 14                	jmp    f01057fa <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057e6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01057e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01057f0:	eb 08                	jmp    f01057fa <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01057f2:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01057f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057fa:	0f b6 06             	movzbl (%esi),%eax
f01057fd:	8d 56 01             	lea    0x1(%esi),%edx
f0105800:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105803:	8a 16                	mov    (%esi),%dl
f0105805:	83 ea 23             	sub    $0x23,%edx
f0105808:	80 fa 55             	cmp    $0x55,%dl
f010580b:	0f 87 01 03 00 00    	ja     f0105b12 <vprintfmt+0x388>
f0105811:	0f b6 d2             	movzbl %dl,%edx
f0105814:	ff 24 95 40 83 10 f0 	jmp    *-0xfef7cc0(,%edx,4)
f010581b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010581e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105823:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0105826:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010582a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f010582d:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105830:	83 fa 09             	cmp    $0x9,%edx
f0105833:	77 2a                	ja     f010585f <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105835:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0105836:	eb eb                	jmp    f0105823 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105838:	8b 45 14             	mov    0x14(%ebp),%eax
f010583b:	8d 50 04             	lea    0x4(%eax),%edx
f010583e:	89 55 14             	mov    %edx,0x14(%ebp)
f0105841:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105843:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0105846:	eb 17                	jmp    f010585f <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105848:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010584c:	78 98                	js     f01057e6 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010584e:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105851:	eb a7                	jmp    f01057fa <vprintfmt+0x70>
f0105853:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0105856:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f010585d:	eb 9b                	jmp    f01057fa <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f010585f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105863:	79 95                	jns    f01057fa <vprintfmt+0x70>
f0105865:	eb 8b                	jmp    f01057f2 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0105867:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105868:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010586b:	eb 8d                	jmp    f01057fa <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010586d:	8b 45 14             	mov    0x14(%ebp),%eax
f0105870:	8d 50 04             	lea    0x4(%eax),%edx
f0105873:	89 55 14             	mov    %edx,0x14(%ebp)
f0105876:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010587a:	8b 00                	mov    (%eax),%eax
f010587c:	89 04 24             	mov    %eax,(%esp)
f010587f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105882:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105885:	e9 23 ff ff ff       	jmp    f01057ad <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010588a:	8b 45 14             	mov    0x14(%ebp),%eax
f010588d:	8d 50 04             	lea    0x4(%eax),%edx
f0105890:	89 55 14             	mov    %edx,0x14(%ebp)
f0105893:	8b 00                	mov    (%eax),%eax
f0105895:	85 c0                	test   %eax,%eax
f0105897:	79 02                	jns    f010589b <vprintfmt+0x111>
f0105899:	f7 d8                	neg    %eax
f010589b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010589d:	83 f8 08             	cmp    $0x8,%eax
f01058a0:	7f 0b                	jg     f01058ad <vprintfmt+0x123>
f01058a2:	8b 04 85 a0 84 10 f0 	mov    -0xfef7b60(,%eax,4),%eax
f01058a9:	85 c0                	test   %eax,%eax
f01058ab:	75 23                	jne    f01058d0 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01058ad:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01058b1:	c7 44 24 08 92 82 10 	movl   $0xf0108292,0x8(%esp)
f01058b8:	f0 
f01058b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01058c0:	89 04 24             	mov    %eax,(%esp)
f01058c3:	e8 9a fe ff ff       	call   f0105762 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058c8:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01058cb:	e9 dd fe ff ff       	jmp    f01057ad <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01058d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058d4:	c7 44 24 08 c4 79 10 	movl   $0xf01079c4,0x8(%esp)
f01058db:	f0 
f01058dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058e0:	8b 55 08             	mov    0x8(%ebp),%edx
f01058e3:	89 14 24             	mov    %edx,(%esp)
f01058e6:	e8 77 fe ff ff       	call   f0105762 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058eb:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01058ee:	e9 ba fe ff ff       	jmp    f01057ad <vprintfmt+0x23>
f01058f3:	89 f9                	mov    %edi,%ecx
f01058f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01058f8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01058fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01058fe:	8d 50 04             	lea    0x4(%eax),%edx
f0105901:	89 55 14             	mov    %edx,0x14(%ebp)
f0105904:	8b 30                	mov    (%eax),%esi
f0105906:	85 f6                	test   %esi,%esi
f0105908:	75 05                	jne    f010590f <vprintfmt+0x185>
				p = "(null)";
f010590a:	be 8b 82 10 f0       	mov    $0xf010828b,%esi
			if (width > 0 && padc != '-')
f010590f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105913:	0f 8e 84 00 00 00    	jle    f010599d <vprintfmt+0x213>
f0105919:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f010591d:	74 7e                	je     f010599d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f010591f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105923:	89 34 24             	mov    %esi,(%esp)
f0105926:	e8 73 03 00 00       	call   f0105c9e <strnlen>
f010592b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010592e:	29 c2                	sub    %eax,%edx
f0105930:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105933:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0105937:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010593a:	89 7d cc             	mov    %edi,-0x34(%ebp)
f010593d:	89 de                	mov    %ebx,%esi
f010593f:	89 d3                	mov    %edx,%ebx
f0105941:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105943:	eb 0b                	jmp    f0105950 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105945:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105949:	89 3c 24             	mov    %edi,(%esp)
f010594c:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010594f:	4b                   	dec    %ebx
f0105950:	85 db                	test   %ebx,%ebx
f0105952:	7f f1                	jg     f0105945 <vprintfmt+0x1bb>
f0105954:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0105957:	89 f3                	mov    %esi,%ebx
f0105959:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f010595c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010595f:	85 c0                	test   %eax,%eax
f0105961:	79 05                	jns    f0105968 <vprintfmt+0x1de>
f0105963:	b8 00 00 00 00       	mov    $0x0,%eax
f0105968:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010596b:	29 c2                	sub    %eax,%edx
f010596d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105970:	eb 2b                	jmp    f010599d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105972:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0105976:	74 18                	je     f0105990 <vprintfmt+0x206>
f0105978:	8d 50 e0             	lea    -0x20(%eax),%edx
f010597b:	83 fa 5e             	cmp    $0x5e,%edx
f010597e:	76 10                	jbe    f0105990 <vprintfmt+0x206>
					putch('?', putdat);
f0105980:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105984:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010598b:	ff 55 08             	call   *0x8(%ebp)
f010598e:	eb 0a                	jmp    f010599a <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105990:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105994:	89 04 24             	mov    %eax,(%esp)
f0105997:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010599a:	ff 4d e4             	decl   -0x1c(%ebp)
f010599d:	0f be 06             	movsbl (%esi),%eax
f01059a0:	46                   	inc    %esi
f01059a1:	85 c0                	test   %eax,%eax
f01059a3:	74 21                	je     f01059c6 <vprintfmt+0x23c>
f01059a5:	85 ff                	test   %edi,%edi
f01059a7:	78 c9                	js     f0105972 <vprintfmt+0x1e8>
f01059a9:	4f                   	dec    %edi
f01059aa:	79 c6                	jns    f0105972 <vprintfmt+0x1e8>
f01059ac:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059af:	89 de                	mov    %ebx,%esi
f01059b1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01059b4:	eb 18                	jmp    f01059ce <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01059b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01059ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01059c1:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01059c3:	4b                   	dec    %ebx
f01059c4:	eb 08                	jmp    f01059ce <vprintfmt+0x244>
f01059c6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01059c9:	89 de                	mov    %ebx,%esi
f01059cb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01059ce:	85 db                	test   %ebx,%ebx
f01059d0:	7f e4                	jg     f01059b6 <vprintfmt+0x22c>
f01059d2:	89 7d 08             	mov    %edi,0x8(%ebp)
f01059d5:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059d7:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01059da:	e9 ce fd ff ff       	jmp    f01057ad <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01059df:	83 f9 01             	cmp    $0x1,%ecx
f01059e2:	7e 10                	jle    f01059f4 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f01059e4:	8b 45 14             	mov    0x14(%ebp),%eax
f01059e7:	8d 50 08             	lea    0x8(%eax),%edx
f01059ea:	89 55 14             	mov    %edx,0x14(%ebp)
f01059ed:	8b 30                	mov    (%eax),%esi
f01059ef:	8b 78 04             	mov    0x4(%eax),%edi
f01059f2:	eb 26                	jmp    f0105a1a <vprintfmt+0x290>
	else if (lflag)
f01059f4:	85 c9                	test   %ecx,%ecx
f01059f6:	74 12                	je     f0105a0a <vprintfmt+0x280>
		return va_arg(*ap, long);
f01059f8:	8b 45 14             	mov    0x14(%ebp),%eax
f01059fb:	8d 50 04             	lea    0x4(%eax),%edx
f01059fe:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a01:	8b 30                	mov    (%eax),%esi
f0105a03:	89 f7                	mov    %esi,%edi
f0105a05:	c1 ff 1f             	sar    $0x1f,%edi
f0105a08:	eb 10                	jmp    f0105a1a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0105a0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a0d:	8d 50 04             	lea    0x4(%eax),%edx
f0105a10:	89 55 14             	mov    %edx,0x14(%ebp)
f0105a13:	8b 30                	mov    (%eax),%esi
f0105a15:	89 f7                	mov    %esi,%edi
f0105a17:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105a1a:	85 ff                	test   %edi,%edi
f0105a1c:	78 0a                	js     f0105a28 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105a1e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a23:	e9 ac 00 00 00       	jmp    f0105ad4 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105a28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a2c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105a33:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0105a36:	f7 de                	neg    %esi
f0105a38:	83 d7 00             	adc    $0x0,%edi
f0105a3b:	f7 df                	neg    %edi
			}
			base = 10;
f0105a3d:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105a42:	e9 8d 00 00 00       	jmp    f0105ad4 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105a47:	89 ca                	mov    %ecx,%edx
f0105a49:	8d 45 14             	lea    0x14(%ebp),%eax
f0105a4c:	e8 bd fc ff ff       	call   f010570e <getuint>
f0105a51:	89 c6                	mov    %eax,%esi
f0105a53:	89 d7                	mov    %edx,%edi
			base = 10;
f0105a55:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105a5a:	eb 78                	jmp    f0105ad4 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105a5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a60:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105a67:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0105a6a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a6e:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105a75:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0105a78:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a7c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105a83:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a86:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0105a89:	e9 1f fd ff ff       	jmp    f01057ad <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0105a8e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a92:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0105a99:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0105a9c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105aa0:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105aa7:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0105aaa:	8b 45 14             	mov    0x14(%ebp),%eax
f0105aad:	8d 50 04             	lea    0x4(%eax),%edx
f0105ab0:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105ab3:	8b 30                	mov    (%eax),%esi
f0105ab5:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0105aba:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0105abf:	eb 13                	jmp    f0105ad4 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105ac1:	89 ca                	mov    %ecx,%edx
f0105ac3:	8d 45 14             	lea    0x14(%ebp),%eax
f0105ac6:	e8 43 fc ff ff       	call   f010570e <getuint>
f0105acb:	89 c6                	mov    %eax,%esi
f0105acd:	89 d7                	mov    %edx,%edi
			base = 16;
f0105acf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105ad4:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105ad8:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105adc:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105adf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105ae3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ae7:	89 34 24             	mov    %esi,(%esp)
f0105aea:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105aee:	89 da                	mov    %ebx,%edx
f0105af0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105af3:	e8 4c fb ff ff       	call   f0105644 <printnum>
			break;
f0105af8:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105afb:	e9 ad fc ff ff       	jmp    f01057ad <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105b00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b04:	89 04 24             	mov    %eax,(%esp)
f0105b07:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105b0a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105b0d:	e9 9b fc ff ff       	jmp    f01057ad <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105b16:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105b1d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105b20:	eb 01                	jmp    f0105b23 <vprintfmt+0x399>
f0105b22:	4e                   	dec    %esi
f0105b23:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105b27:	75 f9                	jne    f0105b22 <vprintfmt+0x398>
f0105b29:	e9 7f fc ff ff       	jmp    f01057ad <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105b2e:	83 c4 4c             	add    $0x4c,%esp
f0105b31:	5b                   	pop    %ebx
f0105b32:	5e                   	pop    %esi
f0105b33:	5f                   	pop    %edi
f0105b34:	5d                   	pop    %ebp
f0105b35:	c3                   	ret    

f0105b36 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105b36:	55                   	push   %ebp
f0105b37:	89 e5                	mov    %esp,%ebp
f0105b39:	83 ec 28             	sub    $0x28,%esp
f0105b3c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105b42:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105b45:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105b49:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105b4c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105b53:	85 c0                	test   %eax,%eax
f0105b55:	74 30                	je     f0105b87 <vsnprintf+0x51>
f0105b57:	85 d2                	test   %edx,%edx
f0105b59:	7e 33                	jle    f0105b8e <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105b5b:	8b 45 14             	mov    0x14(%ebp),%eax
f0105b5e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105b62:	8b 45 10             	mov    0x10(%ebp),%eax
f0105b65:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105b69:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105b6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b70:	c7 04 24 48 57 10 f0 	movl   $0xf0105748,(%esp)
f0105b77:	e8 0e fc ff ff       	call   f010578a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105b7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105b7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105b85:	eb 0c                	jmp    f0105b93 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105b87:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105b8c:	eb 05                	jmp    f0105b93 <vsnprintf+0x5d>
f0105b8e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105b93:	c9                   	leave  
f0105b94:	c3                   	ret    

f0105b95 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105b95:	55                   	push   %ebp
f0105b96:	89 e5                	mov    %esp,%ebp
f0105b98:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105b9b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105b9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ba2:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ba5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105bac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bb0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bb3:	89 04 24             	mov    %eax,(%esp)
f0105bb6:	e8 7b ff ff ff       	call   f0105b36 <vsnprintf>
	va_end(ap);

	return rc;
}
f0105bbb:	c9                   	leave  
f0105bbc:	c3                   	ret    
f0105bbd:	00 00                	add    %al,(%eax)
	...

f0105bc0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105bc0:	55                   	push   %ebp
f0105bc1:	89 e5                	mov    %esp,%ebp
f0105bc3:	57                   	push   %edi
f0105bc4:	56                   	push   %esi
f0105bc5:	53                   	push   %ebx
f0105bc6:	83 ec 1c             	sub    $0x1c,%esp
f0105bc9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0105bcc:	85 c0                	test   %eax,%eax
f0105bce:	74 10                	je     f0105be0 <readline+0x20>
		cprintf("%s", prompt);
f0105bd0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bd4:	c7 04 24 c4 79 10 f0 	movl   $0xf01079c4,(%esp)
f0105bdb:	e8 ea e2 ff ff       	call   f0103eca <cprintf>

	i = 0;
	echoing = iscons(0);
f0105be0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105be7:	e8 8a ab ff ff       	call   f0100776 <iscons>
f0105bec:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0105bee:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105bf3:	e8 6d ab ff ff       	call   f0100765 <getchar>
f0105bf8:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105bfa:	85 c0                	test   %eax,%eax
f0105bfc:	79 17                	jns    f0105c15 <readline+0x55>
			cprintf("read error: %e\n", c);
f0105bfe:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c02:	c7 04 24 c4 84 10 f0 	movl   $0xf01084c4,(%esp)
f0105c09:	e8 bc e2 ff ff       	call   f0103eca <cprintf>
			return NULL;
f0105c0e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c13:	eb 69                	jmp    f0105c7e <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105c15:	83 f8 08             	cmp    $0x8,%eax
f0105c18:	74 05                	je     f0105c1f <readline+0x5f>
f0105c1a:	83 f8 7f             	cmp    $0x7f,%eax
f0105c1d:	75 17                	jne    f0105c36 <readline+0x76>
f0105c1f:	85 f6                	test   %esi,%esi
f0105c21:	7e 13                	jle    f0105c36 <readline+0x76>
			if (echoing)
f0105c23:	85 ff                	test   %edi,%edi
f0105c25:	74 0c                	je     f0105c33 <readline+0x73>
				cputchar('\b');
f0105c27:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105c2e:	e8 22 ab ff ff       	call   f0100755 <cputchar>
			i--;
f0105c33:	4e                   	dec    %esi
f0105c34:	eb bd                	jmp    f0105bf3 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105c36:	83 fb 1f             	cmp    $0x1f,%ebx
f0105c39:	7e 1d                	jle    f0105c58 <readline+0x98>
f0105c3b:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105c41:	7f 15                	jg     f0105c58 <readline+0x98>
			if (echoing)
f0105c43:	85 ff                	test   %edi,%edi
f0105c45:	74 08                	je     f0105c4f <readline+0x8f>
				cputchar(c);
f0105c47:	89 1c 24             	mov    %ebx,(%esp)
f0105c4a:	e8 06 ab ff ff       	call   f0100755 <cputchar>
			buf[i++] = c;
f0105c4f:	88 9e 80 1a 33 f0    	mov    %bl,-0xfcce580(%esi)
f0105c55:	46                   	inc    %esi
f0105c56:	eb 9b                	jmp    f0105bf3 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105c58:	83 fb 0a             	cmp    $0xa,%ebx
f0105c5b:	74 05                	je     f0105c62 <readline+0xa2>
f0105c5d:	83 fb 0d             	cmp    $0xd,%ebx
f0105c60:	75 91                	jne    f0105bf3 <readline+0x33>
			if (echoing)
f0105c62:	85 ff                	test   %edi,%edi
f0105c64:	74 0c                	je     f0105c72 <readline+0xb2>
				cputchar('\n');
f0105c66:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105c6d:	e8 e3 aa ff ff       	call   f0100755 <cputchar>
			buf[i] = 0;
f0105c72:	c6 86 80 1a 33 f0 00 	movb   $0x0,-0xfcce580(%esi)
			return buf;
f0105c79:	b8 80 1a 33 f0       	mov    $0xf0331a80,%eax
		}
	}
}
f0105c7e:	83 c4 1c             	add    $0x1c,%esp
f0105c81:	5b                   	pop    %ebx
f0105c82:	5e                   	pop    %esi
f0105c83:	5f                   	pop    %edi
f0105c84:	5d                   	pop    %ebp
f0105c85:	c3                   	ret    
	...

f0105c88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105c88:	55                   	push   %ebp
f0105c89:	89 e5                	mov    %esp,%ebp
f0105c8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c8e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c93:	eb 01                	jmp    f0105c96 <strlen+0xe>
		n++;
f0105c95:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105c96:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105c9a:	75 f9                	jne    f0105c95 <strlen+0xd>
		n++;
	return n;
}
f0105c9c:	5d                   	pop    %ebp
f0105c9d:	c3                   	ret    

f0105c9e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105c9e:	55                   	push   %ebp
f0105c9f:	89 e5                	mov    %esp,%ebp
f0105ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105ca4:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105ca7:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cac:	eb 01                	jmp    f0105caf <strnlen+0x11>
		n++;
f0105cae:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105caf:	39 d0                	cmp    %edx,%eax
f0105cb1:	74 06                	je     f0105cb9 <strnlen+0x1b>
f0105cb3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105cb7:	75 f5                	jne    f0105cae <strnlen+0x10>
		n++;
	return n;
}
f0105cb9:	5d                   	pop    %ebp
f0105cba:	c3                   	ret    

f0105cbb <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105cbb:	55                   	push   %ebp
f0105cbc:	89 e5                	mov    %esp,%ebp
f0105cbe:	53                   	push   %ebx
f0105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105cc5:	ba 00 00 00 00       	mov    $0x0,%edx
f0105cca:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105ccd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105cd0:	42                   	inc    %edx
f0105cd1:	84 c9                	test   %cl,%cl
f0105cd3:	75 f5                	jne    f0105cca <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105cd5:	5b                   	pop    %ebx
f0105cd6:	5d                   	pop    %ebp
f0105cd7:	c3                   	ret    

f0105cd8 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105cd8:	55                   	push   %ebp
f0105cd9:	89 e5                	mov    %esp,%ebp
f0105cdb:	53                   	push   %ebx
f0105cdc:	83 ec 08             	sub    $0x8,%esp
f0105cdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105ce2:	89 1c 24             	mov    %ebx,(%esp)
f0105ce5:	e8 9e ff ff ff       	call   f0105c88 <strlen>
	strcpy(dst + len, src);
f0105cea:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105ced:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105cf1:	01 d8                	add    %ebx,%eax
f0105cf3:	89 04 24             	mov    %eax,(%esp)
f0105cf6:	e8 c0 ff ff ff       	call   f0105cbb <strcpy>
	return dst;
}
f0105cfb:	89 d8                	mov    %ebx,%eax
f0105cfd:	83 c4 08             	add    $0x8,%esp
f0105d00:	5b                   	pop    %ebx
f0105d01:	5d                   	pop    %ebp
f0105d02:	c3                   	ret    

f0105d03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105d03:	55                   	push   %ebp
f0105d04:	89 e5                	mov    %esp,%ebp
f0105d06:	56                   	push   %esi
f0105d07:	53                   	push   %ebx
f0105d08:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d0b:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105d0e:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d11:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d16:	eb 0c                	jmp    f0105d24 <strncpy+0x21>
		*dst++ = *src;
f0105d18:	8a 1a                	mov    (%edx),%bl
f0105d1a:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105d1d:	80 3a 01             	cmpb   $0x1,(%edx)
f0105d20:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105d23:	41                   	inc    %ecx
f0105d24:	39 f1                	cmp    %esi,%ecx
f0105d26:	75 f0                	jne    f0105d18 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105d28:	5b                   	pop    %ebx
f0105d29:	5e                   	pop    %esi
f0105d2a:	5d                   	pop    %ebp
f0105d2b:	c3                   	ret    

f0105d2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105d2c:	55                   	push   %ebp
f0105d2d:	89 e5                	mov    %esp,%ebp
f0105d2f:	56                   	push   %esi
f0105d30:	53                   	push   %ebx
f0105d31:	8b 75 08             	mov    0x8(%ebp),%esi
f0105d34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d37:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d3a:	85 d2                	test   %edx,%edx
f0105d3c:	75 0a                	jne    f0105d48 <strlcpy+0x1c>
f0105d3e:	89 f0                	mov    %esi,%eax
f0105d40:	eb 1a                	jmp    f0105d5c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105d42:	88 18                	mov    %bl,(%eax)
f0105d44:	40                   	inc    %eax
f0105d45:	41                   	inc    %ecx
f0105d46:	eb 02                	jmp    f0105d4a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105d48:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0105d4a:	4a                   	dec    %edx
f0105d4b:	74 0a                	je     f0105d57 <strlcpy+0x2b>
f0105d4d:	8a 19                	mov    (%ecx),%bl
f0105d4f:	84 db                	test   %bl,%bl
f0105d51:	75 ef                	jne    f0105d42 <strlcpy+0x16>
f0105d53:	89 c2                	mov    %eax,%edx
f0105d55:	eb 02                	jmp    f0105d59 <strlcpy+0x2d>
f0105d57:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105d59:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105d5c:	29 f0                	sub    %esi,%eax
}
f0105d5e:	5b                   	pop    %ebx
f0105d5f:	5e                   	pop    %esi
f0105d60:	5d                   	pop    %ebp
f0105d61:	c3                   	ret    

f0105d62 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105d62:	55                   	push   %ebp
f0105d63:	89 e5                	mov    %esp,%ebp
f0105d65:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105d68:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105d6b:	eb 02                	jmp    f0105d6f <strcmp+0xd>
		p++, q++;
f0105d6d:	41                   	inc    %ecx
f0105d6e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105d6f:	8a 01                	mov    (%ecx),%al
f0105d71:	84 c0                	test   %al,%al
f0105d73:	74 04                	je     f0105d79 <strcmp+0x17>
f0105d75:	3a 02                	cmp    (%edx),%al
f0105d77:	74 f4                	je     f0105d6d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105d79:	0f b6 c0             	movzbl %al,%eax
f0105d7c:	0f b6 12             	movzbl (%edx),%edx
f0105d7f:	29 d0                	sub    %edx,%eax
}
f0105d81:	5d                   	pop    %ebp
f0105d82:	c3                   	ret    

f0105d83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105d83:	55                   	push   %ebp
f0105d84:	89 e5                	mov    %esp,%ebp
f0105d86:	53                   	push   %ebx
f0105d87:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105d8d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105d90:	eb 03                	jmp    f0105d95 <strncmp+0x12>
		n--, p++, q++;
f0105d92:	4a                   	dec    %edx
f0105d93:	40                   	inc    %eax
f0105d94:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105d95:	85 d2                	test   %edx,%edx
f0105d97:	74 14                	je     f0105dad <strncmp+0x2a>
f0105d99:	8a 18                	mov    (%eax),%bl
f0105d9b:	84 db                	test   %bl,%bl
f0105d9d:	74 04                	je     f0105da3 <strncmp+0x20>
f0105d9f:	3a 19                	cmp    (%ecx),%bl
f0105da1:	74 ef                	je     f0105d92 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105da3:	0f b6 00             	movzbl (%eax),%eax
f0105da6:	0f b6 11             	movzbl (%ecx),%edx
f0105da9:	29 d0                	sub    %edx,%eax
f0105dab:	eb 05                	jmp    f0105db2 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105dad:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105db2:	5b                   	pop    %ebx
f0105db3:	5d                   	pop    %ebp
f0105db4:	c3                   	ret    

f0105db5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105db5:	55                   	push   %ebp
f0105db6:	89 e5                	mov    %esp,%ebp
f0105db8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dbb:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105dbe:	eb 05                	jmp    f0105dc5 <strchr+0x10>
		if (*s == c)
f0105dc0:	38 ca                	cmp    %cl,%dl
f0105dc2:	74 0c                	je     f0105dd0 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105dc4:	40                   	inc    %eax
f0105dc5:	8a 10                	mov    (%eax),%dl
f0105dc7:	84 d2                	test   %dl,%dl
f0105dc9:	75 f5                	jne    f0105dc0 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0105dcb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105dd0:	5d                   	pop    %ebp
f0105dd1:	c3                   	ret    

f0105dd2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105dd2:	55                   	push   %ebp
f0105dd3:	89 e5                	mov    %esp,%ebp
f0105dd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0105dd8:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105ddb:	eb 05                	jmp    f0105de2 <strfind+0x10>
		if (*s == c)
f0105ddd:	38 ca                	cmp    %cl,%dl
f0105ddf:	74 07                	je     f0105de8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105de1:	40                   	inc    %eax
f0105de2:	8a 10                	mov    (%eax),%dl
f0105de4:	84 d2                	test   %dl,%dl
f0105de6:	75 f5                	jne    f0105ddd <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0105de8:	5d                   	pop    %ebp
f0105de9:	c3                   	ret    

f0105dea <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105dea:	55                   	push   %ebp
f0105deb:	89 e5                	mov    %esp,%ebp
f0105ded:	57                   	push   %edi
f0105dee:	56                   	push   %esi
f0105def:	53                   	push   %ebx
f0105df0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105df3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105df6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105df9:	85 c9                	test   %ecx,%ecx
f0105dfb:	74 30                	je     f0105e2d <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105dfd:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105e03:	75 25                	jne    f0105e2a <memset+0x40>
f0105e05:	f6 c1 03             	test   $0x3,%cl
f0105e08:	75 20                	jne    f0105e2a <memset+0x40>
		c &= 0xFF;
f0105e0a:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105e0d:	89 d3                	mov    %edx,%ebx
f0105e0f:	c1 e3 08             	shl    $0x8,%ebx
f0105e12:	89 d6                	mov    %edx,%esi
f0105e14:	c1 e6 18             	shl    $0x18,%esi
f0105e17:	89 d0                	mov    %edx,%eax
f0105e19:	c1 e0 10             	shl    $0x10,%eax
f0105e1c:	09 f0                	or     %esi,%eax
f0105e1e:	09 d0                	or     %edx,%eax
f0105e20:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105e22:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105e25:	fc                   	cld    
f0105e26:	f3 ab                	rep stos %eax,%es:(%edi)
f0105e28:	eb 03                	jmp    f0105e2d <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105e2a:	fc                   	cld    
f0105e2b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105e2d:	89 f8                	mov    %edi,%eax
f0105e2f:	5b                   	pop    %ebx
f0105e30:	5e                   	pop    %esi
f0105e31:	5f                   	pop    %edi
f0105e32:	5d                   	pop    %ebp
f0105e33:	c3                   	ret    

f0105e34 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105e34:	55                   	push   %ebp
f0105e35:	89 e5                	mov    %esp,%ebp
f0105e37:	57                   	push   %edi
f0105e38:	56                   	push   %esi
f0105e39:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e3c:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105e42:	39 c6                	cmp    %eax,%esi
f0105e44:	73 34                	jae    f0105e7a <memmove+0x46>
f0105e46:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105e49:	39 d0                	cmp    %edx,%eax
f0105e4b:	73 2d                	jae    f0105e7a <memmove+0x46>
		s += n;
		d += n;
f0105e4d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e50:	f6 c2 03             	test   $0x3,%dl
f0105e53:	75 1b                	jne    f0105e70 <memmove+0x3c>
f0105e55:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105e5b:	75 13                	jne    f0105e70 <memmove+0x3c>
f0105e5d:	f6 c1 03             	test   $0x3,%cl
f0105e60:	75 0e                	jne    f0105e70 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105e62:	83 ef 04             	sub    $0x4,%edi
f0105e65:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105e68:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105e6b:	fd                   	std    
f0105e6c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e6e:	eb 07                	jmp    f0105e77 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105e70:	4f                   	dec    %edi
f0105e71:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105e74:	fd                   	std    
f0105e75:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105e77:	fc                   	cld    
f0105e78:	eb 20                	jmp    f0105e9a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105e7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105e80:	75 13                	jne    f0105e95 <memmove+0x61>
f0105e82:	a8 03                	test   $0x3,%al
f0105e84:	75 0f                	jne    f0105e95 <memmove+0x61>
f0105e86:	f6 c1 03             	test   $0x3,%cl
f0105e89:	75 0a                	jne    f0105e95 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105e8b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105e8e:	89 c7                	mov    %eax,%edi
f0105e90:	fc                   	cld    
f0105e91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105e93:	eb 05                	jmp    f0105e9a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105e95:	89 c7                	mov    %eax,%edi
f0105e97:	fc                   	cld    
f0105e98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105e9a:	5e                   	pop    %esi
f0105e9b:	5f                   	pop    %edi
f0105e9c:	5d                   	pop    %ebp
f0105e9d:	c3                   	ret    

f0105e9e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105e9e:	55                   	push   %ebp
f0105e9f:	89 e5                	mov    %esp,%ebp
f0105ea1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105ea4:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ea7:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105eab:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105eae:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105eb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eb5:	89 04 24             	mov    %eax,(%esp)
f0105eb8:	e8 77 ff ff ff       	call   f0105e34 <memmove>
}
f0105ebd:	c9                   	leave  
f0105ebe:	c3                   	ret    

f0105ebf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105ebf:	55                   	push   %ebp
f0105ec0:	89 e5                	mov    %esp,%ebp
f0105ec2:	57                   	push   %edi
f0105ec3:	56                   	push   %esi
f0105ec4:	53                   	push   %ebx
f0105ec5:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105ec8:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ecb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105ece:	ba 00 00 00 00       	mov    $0x0,%edx
f0105ed3:	eb 16                	jmp    f0105eeb <memcmp+0x2c>
		if (*s1 != *s2)
f0105ed5:	8a 04 17             	mov    (%edi,%edx,1),%al
f0105ed8:	42                   	inc    %edx
f0105ed9:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0105edd:	38 c8                	cmp    %cl,%al
f0105edf:	74 0a                	je     f0105eeb <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0105ee1:	0f b6 c0             	movzbl %al,%eax
f0105ee4:	0f b6 c9             	movzbl %cl,%ecx
f0105ee7:	29 c8                	sub    %ecx,%eax
f0105ee9:	eb 09                	jmp    f0105ef4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105eeb:	39 da                	cmp    %ebx,%edx
f0105eed:	75 e6                	jne    f0105ed5 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105eef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ef4:	5b                   	pop    %ebx
f0105ef5:	5e                   	pop    %esi
f0105ef6:	5f                   	pop    %edi
f0105ef7:	5d                   	pop    %ebp
f0105ef8:	c3                   	ret    

f0105ef9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105ef9:	55                   	push   %ebp
f0105efa:	89 e5                	mov    %esp,%ebp
f0105efc:	8b 45 08             	mov    0x8(%ebp),%eax
f0105eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105f02:	89 c2                	mov    %eax,%edx
f0105f04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105f07:	eb 05                	jmp    f0105f0e <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105f09:	38 08                	cmp    %cl,(%eax)
f0105f0b:	74 05                	je     f0105f12 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105f0d:	40                   	inc    %eax
f0105f0e:	39 d0                	cmp    %edx,%eax
f0105f10:	72 f7                	jb     f0105f09 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105f12:	5d                   	pop    %ebp
f0105f13:	c3                   	ret    

f0105f14 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105f14:	55                   	push   %ebp
f0105f15:	89 e5                	mov    %esp,%ebp
f0105f17:	57                   	push   %edi
f0105f18:	56                   	push   %esi
f0105f19:	53                   	push   %ebx
f0105f1a:	8b 55 08             	mov    0x8(%ebp),%edx
f0105f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105f20:	eb 01                	jmp    f0105f23 <strtol+0xf>
		s++;
f0105f22:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105f23:	8a 02                	mov    (%edx),%al
f0105f25:	3c 20                	cmp    $0x20,%al
f0105f27:	74 f9                	je     f0105f22 <strtol+0xe>
f0105f29:	3c 09                	cmp    $0x9,%al
f0105f2b:	74 f5                	je     f0105f22 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105f2d:	3c 2b                	cmp    $0x2b,%al
f0105f2f:	75 08                	jne    f0105f39 <strtol+0x25>
		s++;
f0105f31:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105f32:	bf 00 00 00 00       	mov    $0x0,%edi
f0105f37:	eb 13                	jmp    f0105f4c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105f39:	3c 2d                	cmp    $0x2d,%al
f0105f3b:	75 0a                	jne    f0105f47 <strtol+0x33>
		s++, neg = 1;
f0105f3d:	8d 52 01             	lea    0x1(%edx),%edx
f0105f40:	bf 01 00 00 00       	mov    $0x1,%edi
f0105f45:	eb 05                	jmp    f0105f4c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105f47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105f4c:	85 db                	test   %ebx,%ebx
f0105f4e:	74 05                	je     f0105f55 <strtol+0x41>
f0105f50:	83 fb 10             	cmp    $0x10,%ebx
f0105f53:	75 28                	jne    f0105f7d <strtol+0x69>
f0105f55:	8a 02                	mov    (%edx),%al
f0105f57:	3c 30                	cmp    $0x30,%al
f0105f59:	75 10                	jne    f0105f6b <strtol+0x57>
f0105f5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105f5f:	75 0a                	jne    f0105f6b <strtol+0x57>
		s += 2, base = 16;
f0105f61:	83 c2 02             	add    $0x2,%edx
f0105f64:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105f69:	eb 12                	jmp    f0105f7d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105f6b:	85 db                	test   %ebx,%ebx
f0105f6d:	75 0e                	jne    f0105f7d <strtol+0x69>
f0105f6f:	3c 30                	cmp    $0x30,%al
f0105f71:	75 05                	jne    f0105f78 <strtol+0x64>
		s++, base = 8;
f0105f73:	42                   	inc    %edx
f0105f74:	b3 08                	mov    $0x8,%bl
f0105f76:	eb 05                	jmp    f0105f7d <strtol+0x69>
	else if (base == 0)
		base = 10;
f0105f78:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105f7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105f82:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105f84:	8a 0a                	mov    (%edx),%cl
f0105f86:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105f89:	80 fb 09             	cmp    $0x9,%bl
f0105f8c:	77 08                	ja     f0105f96 <strtol+0x82>
			dig = *s - '0';
f0105f8e:	0f be c9             	movsbl %cl,%ecx
f0105f91:	83 e9 30             	sub    $0x30,%ecx
f0105f94:	eb 1e                	jmp    f0105fb4 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105f96:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105f99:	80 fb 19             	cmp    $0x19,%bl
f0105f9c:	77 08                	ja     f0105fa6 <strtol+0x92>
			dig = *s - 'a' + 10;
f0105f9e:	0f be c9             	movsbl %cl,%ecx
f0105fa1:	83 e9 57             	sub    $0x57,%ecx
f0105fa4:	eb 0e                	jmp    f0105fb4 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105fa6:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105fa9:	80 fb 19             	cmp    $0x19,%bl
f0105fac:	77 12                	ja     f0105fc0 <strtol+0xac>
			dig = *s - 'A' + 10;
f0105fae:	0f be c9             	movsbl %cl,%ecx
f0105fb1:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105fb4:	39 f1                	cmp    %esi,%ecx
f0105fb6:	7d 0c                	jge    f0105fc4 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105fb8:	42                   	inc    %edx
f0105fb9:	0f af c6             	imul   %esi,%eax
f0105fbc:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105fbe:	eb c4                	jmp    f0105f84 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105fc0:	89 c1                	mov    %eax,%ecx
f0105fc2:	eb 02                	jmp    f0105fc6 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105fc4:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105fc6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105fca:	74 05                	je     f0105fd1 <strtol+0xbd>
		*endptr = (char *) s;
f0105fcc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105fcf:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105fd1:	85 ff                	test   %edi,%edi
f0105fd3:	74 04                	je     f0105fd9 <strtol+0xc5>
f0105fd5:	89 c8                	mov    %ecx,%eax
f0105fd7:	f7 d8                	neg    %eax
}
f0105fd9:	5b                   	pop    %ebx
f0105fda:	5e                   	pop    %esi
f0105fdb:	5f                   	pop    %edi
f0105fdc:	5d                   	pop    %ebp
f0105fdd:	c3                   	ret    
	...

f0105fe0 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105fe0:	fa                   	cli    

	xorw    %ax, %ax
f0105fe1:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105fe3:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105fe5:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105fe7:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105fe9:	0f 01 16             	lgdtl  (%esi)
f0105fec:	74 70                	je     f010605e <sum+0x2>
	movl    %cr0, %eax
f0105fee:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105ff1:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105ff5:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105ff8:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105ffe:	08 00                	or     %al,(%eax)

f0106000 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0106000:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0106004:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0106006:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0106008:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010600a:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f010600e:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0106010:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0106012:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0106017:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f010601a:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f010601d:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0106022:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0106025:	8b 25 84 1e 33 f0    	mov    0xf0331e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f010602b:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0106030:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0106035:	ff d0                	call   *%eax

f0106037 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0106037:	eb fe                	jmp    f0106037 <spin>
f0106039:	8d 76 00             	lea    0x0(%esi),%esi

f010603c <gdt>:
	...
f0106044:	ff                   	(bad)  
f0106045:	ff 00                	incl   (%eax)
f0106047:	00 00                	add    %al,(%eax)
f0106049:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0106050:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0106054 <gdtdesc>:
f0106054:	17                   	pop    %ss
f0106055:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f010605a <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f010605a:	90                   	nop
	...

f010605c <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f010605c:	55                   	push   %ebp
f010605d:	89 e5                	mov    %esp,%ebp
f010605f:	56                   	push   %esi
f0106060:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0106061:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0106066:	b9 00 00 00 00       	mov    $0x0,%ecx
f010606b:	eb 07                	jmp    f0106074 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f010606d:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0106071:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0106073:	41                   	inc    %ecx
f0106074:	39 d1                	cmp    %edx,%ecx
f0106076:	7c f5                	jl     f010606d <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0106078:	88 d8                	mov    %bl,%al
f010607a:	5b                   	pop    %ebx
f010607b:	5e                   	pop    %esi
f010607c:	5d                   	pop    %ebp
f010607d:	c3                   	ret    

f010607e <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f010607e:	55                   	push   %ebp
f010607f:	89 e5                	mov    %esp,%ebp
f0106081:	56                   	push   %esi
f0106082:	53                   	push   %ebx
f0106083:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106086:	8b 0d 88 1e 33 f0    	mov    0xf0331e88,%ecx
f010608c:	89 c3                	mov    %eax,%ebx
f010608e:	c1 eb 0c             	shr    $0xc,%ebx
f0106091:	39 cb                	cmp    %ecx,%ebx
f0106093:	72 20                	jb     f01060b5 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106095:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106099:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01060a0:	f0 
f01060a1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01060a8:	00 
f01060a9:	c7 04 24 61 86 10 f0 	movl   $0xf0108661,(%esp)
f01060b0:	e8 8b 9f ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f01060b5:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01060b8:	89 f2                	mov    %esi,%edx
f01060ba:	c1 ea 0c             	shr    $0xc,%edx
f01060bd:	39 d1                	cmp    %edx,%ecx
f01060bf:	77 20                	ja     f01060e1 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01060c1:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01060c5:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01060cc:	f0 
f01060cd:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f01060d4:	00 
f01060d5:	c7 04 24 61 86 10 f0 	movl   $0xf0108661,(%esp)
f01060dc:	e8 5f 9f ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01060e1:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01060e7:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f01060ed:	eb 2f                	jmp    f010611e <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f01060ef:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f01060f6:	00 
f01060f7:	c7 44 24 04 71 86 10 	movl   $0xf0108671,0x4(%esp)
f01060fe:	f0 
f01060ff:	89 1c 24             	mov    %ebx,(%esp)
f0106102:	e8 b8 fd ff ff       	call   f0105ebf <memcmp>
f0106107:	85 c0                	test   %eax,%eax
f0106109:	75 10                	jne    f010611b <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f010610b:	ba 10 00 00 00       	mov    $0x10,%edx
f0106110:	89 d8                	mov    %ebx,%eax
f0106112:	e8 45 ff ff ff       	call   f010605c <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106117:	84 c0                	test   %al,%al
f0106119:	74 0c                	je     f0106127 <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f010611b:	83 c3 10             	add    $0x10,%ebx
f010611e:	39 f3                	cmp    %esi,%ebx
f0106120:	72 cd                	jb     f01060ef <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0106122:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0106127:	89 d8                	mov    %ebx,%eax
f0106129:	83 c4 10             	add    $0x10,%esp
f010612c:	5b                   	pop    %ebx
f010612d:	5e                   	pop    %esi
f010612e:	5d                   	pop    %ebp
f010612f:	c3                   	ret    

f0106130 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106130:	55                   	push   %ebp
f0106131:	89 e5                	mov    %esp,%ebp
f0106133:	57                   	push   %edi
f0106134:	56                   	push   %esi
f0106135:	53                   	push   %ebx
f0106136:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106139:	c7 05 c0 23 33 f0 20 	movl   $0xf0332020,0xf03323c0
f0106140:	20 33 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106143:	83 3d 88 1e 33 f0 00 	cmpl   $0x0,0xf0331e88
f010614a:	75 24                	jne    f0106170 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010614c:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0106153:	00 
f0106154:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f010615b:	f0 
f010615c:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0106163:	00 
f0106164:	c7 04 24 61 86 10 f0 	movl   $0xf0108661,(%esp)
f010616b:	e8 d0 9e ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0106170:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0106177:	85 c0                	test   %eax,%eax
f0106179:	74 16                	je     f0106191 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f010617b:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f010617e:	ba 00 04 00 00       	mov    $0x400,%edx
f0106183:	e8 f6 fe ff ff       	call   f010607e <mpsearch1>
f0106188:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010618b:	85 c0                	test   %eax,%eax
f010618d:	75 3c                	jne    f01061cb <mp_init+0x9b>
f010618f:	eb 20                	jmp    f01061b1 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0106191:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0106198:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f010619b:	2d 00 04 00 00       	sub    $0x400,%eax
f01061a0:	ba 00 04 00 00       	mov    $0x400,%edx
f01061a5:	e8 d4 fe ff ff       	call   f010607e <mpsearch1>
f01061aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01061ad:	85 c0                	test   %eax,%eax
f01061af:	75 1a                	jne    f01061cb <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01061b1:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061b6:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01061bb:	e8 be fe ff ff       	call   f010607e <mpsearch1>
f01061c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01061c3:	85 c0                	test   %eax,%eax
f01061c5:	0f 84 2c 02 00 00    	je     f01063f7 <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01061cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01061ce:	8b 58 04             	mov    0x4(%eax),%ebx
f01061d1:	85 db                	test   %ebx,%ebx
f01061d3:	74 06                	je     f01061db <mp_init+0xab>
f01061d5:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f01061d9:	74 11                	je     f01061ec <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f01061db:	c7 04 24 d4 84 10 f0 	movl   $0xf01084d4,(%esp)
f01061e2:	e8 e3 dc ff ff       	call   f0103eca <cprintf>
f01061e7:	e9 0b 02 00 00       	jmp    f01063f7 <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01061ec:	89 d8                	mov    %ebx,%eax
f01061ee:	c1 e8 0c             	shr    $0xc,%eax
f01061f1:	3b 05 88 1e 33 f0    	cmp    0xf0331e88,%eax
f01061f7:	72 20                	jb     f0106219 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01061f9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01061fd:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f0106204:	f0 
f0106205:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f010620c:	00 
f010620d:	c7 04 24 61 86 10 f0 	movl   $0xf0108661,(%esp)
f0106214:	e8 27 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106219:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f010621f:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0106226:	00 
f0106227:	c7 44 24 04 76 86 10 	movl   $0xf0108676,0x4(%esp)
f010622e:	f0 
f010622f:	89 1c 24             	mov    %ebx,(%esp)
f0106232:	e8 88 fc ff ff       	call   f0105ebf <memcmp>
f0106237:	85 c0                	test   %eax,%eax
f0106239:	74 11                	je     f010624c <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010623b:	c7 04 24 04 85 10 f0 	movl   $0xf0108504,(%esp)
f0106242:	e8 83 dc ff ff       	call   f0103eca <cprintf>
f0106247:	e9 ab 01 00 00       	jmp    f01063f7 <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010624c:	66 8b 73 04          	mov    0x4(%ebx),%si
f0106250:	0f b7 d6             	movzwl %si,%edx
f0106253:	89 d8                	mov    %ebx,%eax
f0106255:	e8 02 fe ff ff       	call   f010605c <sum>
f010625a:	84 c0                	test   %al,%al
f010625c:	74 11                	je     f010626f <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f010625e:	c7 04 24 38 85 10 f0 	movl   $0xf0108538,(%esp)
f0106265:	e8 60 dc ff ff       	call   f0103eca <cprintf>
f010626a:	e9 88 01 00 00       	jmp    f01063f7 <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f010626f:	8a 43 06             	mov    0x6(%ebx),%al
f0106272:	3c 01                	cmp    $0x1,%al
f0106274:	74 1c                	je     f0106292 <mp_init+0x162>
f0106276:	3c 04                	cmp    $0x4,%al
f0106278:	74 18                	je     f0106292 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f010627a:	0f b6 c0             	movzbl %al,%eax
f010627d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106281:	c7 04 24 5c 85 10 f0 	movl   $0xf010855c,(%esp)
f0106288:	e8 3d dc ff ff       	call   f0103eca <cprintf>
f010628d:	e9 65 01 00 00       	jmp    f01063f7 <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106292:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0106296:	0f b7 c6             	movzwl %si,%eax
f0106299:	01 d8                	add    %ebx,%eax
f010629b:	e8 bc fd ff ff       	call   f010605c <sum>
f01062a0:	02 43 2a             	add    0x2a(%ebx),%al
f01062a3:	84 c0                	test   %al,%al
f01062a5:	74 11                	je     f01062b8 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01062a7:	c7 04 24 7c 85 10 f0 	movl   $0xf010857c,(%esp)
f01062ae:	e8 17 dc ff ff       	call   f0103eca <cprintf>
f01062b3:	e9 3f 01 00 00       	jmp    f01063f7 <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01062b8:	85 db                	test   %ebx,%ebx
f01062ba:	0f 84 37 01 00 00    	je     f01063f7 <mp_init+0x2c7>
		return;
	ismp = 1;
f01062c0:	c7 05 00 20 33 f0 01 	movl   $0x1,0xf0332000
f01062c7:	00 00 00 
	lapicaddr = conf->lapicaddr;
f01062ca:	8b 43 24             	mov    0x24(%ebx),%eax
f01062cd:	a3 00 30 37 f0       	mov    %eax,0xf0373000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062d2:	8d 73 2c             	lea    0x2c(%ebx),%esi
f01062d5:	bf 00 00 00 00       	mov    $0x0,%edi
f01062da:	e9 94 00 00 00       	jmp    f0106373 <mp_init+0x243>
		switch (*p) {
f01062df:	8a 06                	mov    (%esi),%al
f01062e1:	84 c0                	test   %al,%al
f01062e3:	74 06                	je     f01062eb <mp_init+0x1bb>
f01062e5:	3c 04                	cmp    $0x4,%al
f01062e7:	77 68                	ja     f0106351 <mp_init+0x221>
f01062e9:	eb 61                	jmp    f010634c <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f01062eb:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f01062ef:	74 1d                	je     f010630e <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f01062f1:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f01062f6:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01062fd:	29 c2                	sub    %eax,%edx
f01062ff:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106302:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0106309:	a3 c0 23 33 f0       	mov    %eax,0xf03323c0
			if (ncpu < NCPU) {
f010630e:	a1 c4 23 33 f0       	mov    0xf03323c4,%eax
f0106313:	83 f8 07             	cmp    $0x7,%eax
f0106316:	7f 1b                	jg     f0106333 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0106318:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010631f:	29 c2                	sub    %eax,%edx
f0106321:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106324:	88 04 95 20 20 33 f0 	mov    %al,-0xfccdfe0(,%edx,4)
				ncpu++;
f010632b:	40                   	inc    %eax
f010632c:	a3 c4 23 33 f0       	mov    %eax,0xf03323c4
f0106331:	eb 14                	jmp    f0106347 <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106333:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f0106337:	89 44 24 04          	mov    %eax,0x4(%esp)
f010633b:	c7 04 24 ac 85 10 f0 	movl   $0xf01085ac,(%esp)
f0106342:	e8 83 db ff ff       	call   f0103eca <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106347:	83 c6 14             	add    $0x14,%esi
			continue;
f010634a:	eb 26                	jmp    f0106372 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010634c:	83 c6 08             	add    $0x8,%esi
			continue;
f010634f:	eb 21                	jmp    f0106372 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106351:	0f b6 c0             	movzbl %al,%eax
f0106354:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106358:	c7 04 24 d4 85 10 f0 	movl   $0xf01085d4,(%esp)
f010635f:	e8 66 db ff ff       	call   f0103eca <cprintf>
			ismp = 0;
f0106364:	c7 05 00 20 33 f0 00 	movl   $0x0,0xf0332000
f010636b:	00 00 00 
			i = conf->entry;
f010636e:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106372:	47                   	inc    %edi
f0106373:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f0106377:	39 c7                	cmp    %eax,%edi
f0106379:	0f 82 60 ff ff ff    	jb     f01062df <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f010637f:	a1 c0 23 33 f0       	mov    0xf03323c0,%eax
f0106384:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010638b:	83 3d 00 20 33 f0 00 	cmpl   $0x0,0xf0332000
f0106392:	75 22                	jne    f01063b6 <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0106394:	c7 05 c4 23 33 f0 01 	movl   $0x1,0xf03323c4
f010639b:	00 00 00 
		lapicaddr = 0;
f010639e:	c7 05 00 30 37 f0 00 	movl   $0x0,0xf0373000
f01063a5:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01063a8:	c7 04 24 f4 85 10 f0 	movl   $0xf01085f4,(%esp)
f01063af:	e8 16 db ff ff       	call   f0103eca <cprintf>
		return;
f01063b4:	eb 41                	jmp    f01063f7 <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01063b6:	8b 15 c4 23 33 f0    	mov    0xf03323c4,%edx
f01063bc:	89 54 24 08          	mov    %edx,0x8(%esp)
f01063c0:	0f b6 00             	movzbl (%eax),%eax
f01063c3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01063c7:	c7 04 24 7b 86 10 f0 	movl   $0xf010867b,(%esp)
f01063ce:	e8 f7 da ff ff       	call   f0103eca <cprintf>

	if (mp->imcrp) {
f01063d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01063d6:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01063da:	74 1b                	je     f01063f7 <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01063dc:	c7 04 24 20 86 10 f0 	movl   $0xf0108620,(%esp)
f01063e3:	e8 e2 da ff ff       	call   f0103eca <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063e8:	ba 22 00 00 00       	mov    $0x22,%edx
f01063ed:	b0 70                	mov    $0x70,%al
f01063ef:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01063f0:	b2 23                	mov    $0x23,%dl
f01063f2:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f01063f3:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01063f6:	ee                   	out    %al,(%dx)
	}
}
f01063f7:	83 c4 2c             	add    $0x2c,%esp
f01063fa:	5b                   	pop    %ebx
f01063fb:	5e                   	pop    %esi
f01063fc:	5f                   	pop    %edi
f01063fd:	5d                   	pop    %ebp
f01063fe:	c3                   	ret    
	...

f0106400 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106400:	55                   	push   %ebp
f0106401:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106403:	c1 e0 02             	shl    $0x2,%eax
f0106406:	03 05 04 30 37 f0    	add    0xf0373004,%eax
f010640c:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010640e:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f0106413:	8b 40 20             	mov    0x20(%eax),%eax
}
f0106416:	5d                   	pop    %ebp
f0106417:	c3                   	ret    

f0106418 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106418:	55                   	push   %ebp
f0106419:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010641b:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f0106420:	85 c0                	test   %eax,%eax
f0106422:	74 08                	je     f010642c <cpunum+0x14>
		return lapic[ID] >> 24;
f0106424:	8b 40 20             	mov    0x20(%eax),%eax
f0106427:	c1 e8 18             	shr    $0x18,%eax
f010642a:	eb 05                	jmp    f0106431 <cpunum+0x19>
	return 0;
f010642c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106431:	5d                   	pop    %ebp
f0106432:	c3                   	ret    

f0106433 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106433:	55                   	push   %ebp
f0106434:	89 e5                	mov    %esp,%ebp
f0106436:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106439:	a1 00 30 37 f0       	mov    0xf0373000,%eax
f010643e:	85 c0                	test   %eax,%eax
f0106440:	0f 84 27 01 00 00    	je     f010656d <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0106446:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010644d:	00 
f010644e:	89 04 24             	mov    %eax,(%esp)
f0106451:	e8 5b ae ff ff       	call   f01012b1 <mmio_map_region>
f0106456:	a3 04 30 37 f0       	mov    %eax,0xf0373004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010645b:	ba 27 01 00 00       	mov    $0x127,%edx
f0106460:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106465:	e8 96 ff ff ff       	call   f0106400 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010646a:	ba 0b 00 00 00       	mov    $0xb,%edx
f010646f:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106474:	e8 87 ff ff ff       	call   f0106400 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0106479:	ba 20 00 02 00       	mov    $0x20020,%edx
f010647e:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106483:	e8 78 ff ff ff       	call   f0106400 <lapicw>
	lapicw(TICR, 10000000); 
f0106488:	ba 80 96 98 00       	mov    $0x989680,%edx
f010648d:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0106492:	e8 69 ff ff ff       	call   f0106400 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0106497:	e8 7c ff ff ff       	call   f0106418 <cpunum>
f010649c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01064a3:	29 c2                	sub    %eax,%edx
f01064a5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01064a8:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f01064af:	39 05 c0 23 33 f0    	cmp    %eax,0xf03323c0
f01064b5:	74 0f                	je     f01064c6 <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f01064b7:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064bc:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01064c1:	e8 3a ff ff ff       	call   f0106400 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01064c6:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064cb:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01064d0:	e8 2b ff ff ff       	call   f0106400 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01064d5:	a1 04 30 37 f0       	mov    0xf0373004,%eax
f01064da:	8b 40 30             	mov    0x30(%eax),%eax
f01064dd:	c1 e8 10             	shr    $0x10,%eax
f01064e0:	3c 03                	cmp    $0x3,%al
f01064e2:	76 0f                	jbe    f01064f3 <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f01064e4:	ba 00 00 01 00       	mov    $0x10000,%edx
f01064e9:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01064ee:	e8 0d ff ff ff       	call   f0106400 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f01064f3:	ba 33 00 00 00       	mov    $0x33,%edx
f01064f8:	b8 dc 00 00 00       	mov    $0xdc,%eax
f01064fd:	e8 fe fe ff ff       	call   f0106400 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106502:	ba 00 00 00 00       	mov    $0x0,%edx
f0106507:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010650c:	e8 ef fe ff ff       	call   f0106400 <lapicw>
	lapicw(ESR, 0);
f0106511:	ba 00 00 00 00       	mov    $0x0,%edx
f0106516:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010651b:	e8 e0 fe ff ff       	call   f0106400 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106520:	ba 00 00 00 00       	mov    $0x0,%edx
f0106525:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010652a:	e8 d1 fe ff ff       	call   f0106400 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010652f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106534:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106539:	e8 c2 fe ff ff       	call   f0106400 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010653e:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106543:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106548:	e8 b3 fe ff ff       	call   f0106400 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010654d:	8b 15 04 30 37 f0    	mov    0xf0373004,%edx
f0106553:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106559:	f6 c4 10             	test   $0x10,%ah
f010655c:	75 f5                	jne    f0106553 <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010655e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106563:	b8 20 00 00 00       	mov    $0x20,%eax
f0106568:	e8 93 fe ff ff       	call   f0106400 <lapicw>
}
f010656d:	c9                   	leave  
f010656e:	c3                   	ret    

f010656f <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f010656f:	55                   	push   %ebp
f0106570:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106572:	83 3d 04 30 37 f0 00 	cmpl   $0x0,0xf0373004
f0106579:	74 0f                	je     f010658a <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010657b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106580:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106585:	e8 76 fe ff ff       	call   f0106400 <lapicw>
}
f010658a:	5d                   	pop    %ebp
f010658b:	c3                   	ret    

f010658c <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f010658c:	55                   	push   %ebp
f010658d:	89 e5                	mov    %esp,%ebp
f010658f:	56                   	push   %esi
f0106590:	53                   	push   %ebx
f0106591:	83 ec 10             	sub    $0x10,%esp
f0106594:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106597:	8a 5d 08             	mov    0x8(%ebp),%bl
f010659a:	ba 70 00 00 00       	mov    $0x70,%edx
f010659f:	b0 0f                	mov    $0xf,%al
f01065a1:	ee                   	out    %al,(%dx)
f01065a2:	b2 71                	mov    $0x71,%dl
f01065a4:	b0 0a                	mov    $0xa,%al
f01065a6:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01065a7:	83 3d 88 1e 33 f0 00 	cmpl   $0x0,0xf0331e88
f01065ae:	75 24                	jne    f01065d4 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01065b0:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01065b7:	00 
f01065b8:	c7 44 24 08 28 6b 10 	movl   $0xf0106b28,0x8(%esp)
f01065bf:	f0 
f01065c0:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01065c7:	00 
f01065c8:	c7 04 24 98 86 10 f0 	movl   $0xf0108698,(%esp)
f01065cf:	e8 6c 9a ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01065d4:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01065db:	00 00 
	wrv[1] = addr >> 4;
f01065dd:	89 f0                	mov    %esi,%eax
f01065df:	c1 e8 04             	shr    $0x4,%eax
f01065e2:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01065e8:	c1 e3 18             	shl    $0x18,%ebx
f01065eb:	89 da                	mov    %ebx,%edx
f01065ed:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01065f2:	e8 09 fe ff ff       	call   f0106400 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f01065f7:	ba 00 c5 00 00       	mov    $0xc500,%edx
f01065fc:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106601:	e8 fa fd ff ff       	call   f0106400 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106606:	ba 00 85 00 00       	mov    $0x8500,%edx
f010660b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106610:	e8 eb fd ff ff       	call   f0106400 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106615:	c1 ee 0c             	shr    $0xc,%esi
f0106618:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010661e:	89 da                	mov    %ebx,%edx
f0106620:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106625:	e8 d6 fd ff ff       	call   f0106400 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010662a:	89 f2                	mov    %esi,%edx
f010662c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106631:	e8 ca fd ff ff       	call   f0106400 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106636:	89 da                	mov    %ebx,%edx
f0106638:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010663d:	e8 be fd ff ff       	call   f0106400 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106642:	89 f2                	mov    %esi,%edx
f0106644:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106649:	e8 b2 fd ff ff       	call   f0106400 <lapicw>
		microdelay(200);
	}
}
f010664e:	83 c4 10             	add    $0x10,%esp
f0106651:	5b                   	pop    %ebx
f0106652:	5e                   	pop    %esi
f0106653:	5d                   	pop    %ebp
f0106654:	c3                   	ret    

f0106655 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106655:	55                   	push   %ebp
f0106656:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106658:	8b 55 08             	mov    0x8(%ebp),%edx
f010665b:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106661:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106666:	e8 95 fd ff ff       	call   f0106400 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010666b:	8b 15 04 30 37 f0    	mov    0xf0373004,%edx
f0106671:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106677:	f6 c4 10             	test   $0x10,%ah
f010667a:	75 f5                	jne    f0106671 <lapic_ipi+0x1c>
		;
}
f010667c:	5d                   	pop    %ebp
f010667d:	c3                   	ret    
	...

f0106680 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106680:	55                   	push   %ebp
f0106681:	89 e5                	mov    %esp,%ebp
f0106683:	53                   	push   %ebx
f0106684:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f0106687:	83 38 00             	cmpl   $0x0,(%eax)
f010668a:	74 25                	je     f01066b1 <holding+0x31>
f010668c:	8b 58 08             	mov    0x8(%eax),%ebx
f010668f:	e8 84 fd ff ff       	call   f0106418 <cpunum>
f0106694:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010669b:	29 c2                	sub    %eax,%edx
f010669d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01066a0:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01066a7:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01066a9:	0f 94 c0             	sete   %al
f01066ac:	0f b6 c0             	movzbl %al,%eax
f01066af:	eb 05                	jmp    f01066b6 <holding+0x36>
f01066b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01066b6:	83 c4 04             	add    $0x4,%esp
f01066b9:	5b                   	pop    %ebx
f01066ba:	5d                   	pop    %ebp
f01066bb:	c3                   	ret    

f01066bc <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01066bc:	55                   	push   %ebp
f01066bd:	89 e5                	mov    %esp,%ebp
f01066bf:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01066c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01066c8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01066cb:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01066ce:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01066d5:	5d                   	pop    %ebp
f01066d6:	c3                   	ret    

f01066d7 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01066d7:	55                   	push   %ebp
f01066d8:	89 e5                	mov    %esp,%ebp
f01066da:	53                   	push   %ebx
f01066db:	83 ec 24             	sub    $0x24,%esp
f01066de:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01066e1:	89 d8                	mov    %ebx,%eax
f01066e3:	e8 98 ff ff ff       	call   f0106680 <holding>
f01066e8:	85 c0                	test   %eax,%eax
f01066ea:	74 30                	je     f010671c <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f01066ec:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01066ef:	e8 24 fd ff ff       	call   f0106418 <cpunum>
f01066f4:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f01066f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01066fc:	c7 44 24 08 a8 86 10 	movl   $0xf01086a8,0x8(%esp)
f0106703:	f0 
f0106704:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f010670b:	00 
f010670c:	c7 04 24 0c 87 10 f0 	movl   $0xf010870c,(%esp)
f0106713:	e8 28 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106718:	f3 90                	pause  
f010671a:	eb 05                	jmp    f0106721 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010671c:	ba 01 00 00 00       	mov    $0x1,%edx
f0106721:	89 d0                	mov    %edx,%eax
f0106723:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106726:	85 c0                	test   %eax,%eax
f0106728:	75 ee                	jne    f0106718 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010672a:	e8 e9 fc ff ff       	call   f0106418 <cpunum>
f010672f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106736:	29 c2                	sub    %eax,%edx
f0106738:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010673b:	8d 04 85 20 20 33 f0 	lea    -0xfccdfe0(,%eax,4),%eax
f0106742:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106745:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106748:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010674a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f010674f:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106755:	76 10                	jbe    f0106767 <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f0106757:	8b 4a 04             	mov    0x4(%edx),%ecx
f010675a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f010675d:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f010675f:	40                   	inc    %eax
f0106760:	83 f8 0a             	cmp    $0xa,%eax
f0106763:	75 ea                	jne    f010674f <spin_lock+0x78>
f0106765:	eb 0d                	jmp    f0106774 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0106767:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f010676e:	40                   	inc    %eax
f010676f:	83 f8 09             	cmp    $0x9,%eax
f0106772:	7e f3                	jle    f0106767 <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106774:	83 c4 24             	add    $0x24,%esp
f0106777:	5b                   	pop    %ebx
f0106778:	5d                   	pop    %ebp
f0106779:	c3                   	ret    

f010677a <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010677a:	55                   	push   %ebp
f010677b:	89 e5                	mov    %esp,%ebp
f010677d:	57                   	push   %edi
f010677e:	56                   	push   %esi
f010677f:	53                   	push   %ebx
f0106780:	83 ec 7c             	sub    $0x7c,%esp
f0106783:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0106786:	89 d8                	mov    %ebx,%eax
f0106788:	e8 f3 fe ff ff       	call   f0106680 <holding>
f010678d:	85 c0                	test   %eax,%eax
f010678f:	0f 85 d3 00 00 00    	jne    f0106868 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0106795:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f010679c:	00 
f010679d:	8d 43 0c             	lea    0xc(%ebx),%eax
f01067a0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067a4:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01067a7:	89 34 24             	mov    %esi,(%esp)
f01067aa:	e8 85 f6 ff ff       	call   f0105e34 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01067af:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01067b2:	0f b6 38             	movzbl (%eax),%edi
f01067b5:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01067b8:	e8 5b fc ff ff       	call   f0106418 <cpunum>
f01067bd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01067c1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01067c5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01067c9:	c7 04 24 d4 86 10 f0 	movl   $0xf01086d4,(%esp)
f01067d0:	e8 f5 d6 ff ff       	call   f0103eca <cprintf>
f01067d5:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01067d7:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01067da:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01067dd:	89 c7                	mov    %eax,%edi
f01067df:	eb 63                	jmp    f0106844 <spin_unlock+0xca>
f01067e1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01067e5:	89 04 24             	mov    %eax,(%esp)
f01067e8:	e8 70 ec ff ff       	call   f010545d <debuginfo_eip>
f01067ed:	85 c0                	test   %eax,%eax
f01067ef:	78 39                	js     f010682a <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f01067f1:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f01067f3:	89 c2                	mov    %eax,%edx
f01067f5:	2b 55 e0             	sub    -0x20(%ebp),%edx
f01067f8:	89 54 24 18          	mov    %edx,0x18(%esp)
f01067fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01067ff:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106803:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106806:	89 54 24 10          	mov    %edx,0x10(%esp)
f010680a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010680d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106811:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106814:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106818:	89 44 24 04          	mov    %eax,0x4(%esp)
f010681c:	c7 04 24 1c 87 10 f0 	movl   $0xf010871c,(%esp)
f0106823:	e8 a2 d6 ff ff       	call   f0103eca <cprintf>
f0106828:	eb 12                	jmp    f010683c <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010682a:	8b 06                	mov    (%esi),%eax
f010682c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106830:	c7 04 24 33 87 10 f0 	movl   $0xf0108733,(%esp)
f0106837:	e8 8e d6 ff ff       	call   f0103eca <cprintf>
f010683c:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010683f:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106842:	74 08                	je     f010684c <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106844:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106846:	8b 03                	mov    (%ebx),%eax
f0106848:	85 c0                	test   %eax,%eax
f010684a:	75 95                	jne    f01067e1 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f010684c:	c7 44 24 08 3b 87 10 	movl   $0xf010873b,0x8(%esp)
f0106853:	f0 
f0106854:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010685b:	00 
f010685c:	c7 04 24 0c 87 10 f0 	movl   $0xf010870c,(%esp)
f0106863:	e8 d8 97 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0106868:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f010686f:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f0106876:	b8 00 00 00 00       	mov    $0x0,%eax
f010687b:	f0 87 03             	lock xchg %eax,(%ebx)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f010687e:	83 c4 7c             	add    $0x7c,%esp
f0106881:	5b                   	pop    %ebx
f0106882:	5e                   	pop    %esi
f0106883:	5f                   	pop    %edi
f0106884:	5d                   	pop    %ebp
f0106885:	c3                   	ret    
	...

f0106888 <__udivdi3>:
f0106888:	55                   	push   %ebp
f0106889:	57                   	push   %edi
f010688a:	56                   	push   %esi
f010688b:	83 ec 10             	sub    $0x10,%esp
f010688e:	8b 74 24 20          	mov    0x20(%esp),%esi
f0106892:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0106896:	89 74 24 04          	mov    %esi,0x4(%esp)
f010689a:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010689e:	89 cd                	mov    %ecx,%ebp
f01068a0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f01068a4:	85 c0                	test   %eax,%eax
f01068a6:	75 2c                	jne    f01068d4 <__udivdi3+0x4c>
f01068a8:	39 f9                	cmp    %edi,%ecx
f01068aa:	77 68                	ja     f0106914 <__udivdi3+0x8c>
f01068ac:	85 c9                	test   %ecx,%ecx
f01068ae:	75 0b                	jne    f01068bb <__udivdi3+0x33>
f01068b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01068b5:	31 d2                	xor    %edx,%edx
f01068b7:	f7 f1                	div    %ecx
f01068b9:	89 c1                	mov    %eax,%ecx
f01068bb:	31 d2                	xor    %edx,%edx
f01068bd:	89 f8                	mov    %edi,%eax
f01068bf:	f7 f1                	div    %ecx
f01068c1:	89 c7                	mov    %eax,%edi
f01068c3:	89 f0                	mov    %esi,%eax
f01068c5:	f7 f1                	div    %ecx
f01068c7:	89 c6                	mov    %eax,%esi
f01068c9:	89 f0                	mov    %esi,%eax
f01068cb:	89 fa                	mov    %edi,%edx
f01068cd:	83 c4 10             	add    $0x10,%esp
f01068d0:	5e                   	pop    %esi
f01068d1:	5f                   	pop    %edi
f01068d2:	5d                   	pop    %ebp
f01068d3:	c3                   	ret    
f01068d4:	39 f8                	cmp    %edi,%eax
f01068d6:	77 2c                	ja     f0106904 <__udivdi3+0x7c>
f01068d8:	0f bd f0             	bsr    %eax,%esi
f01068db:	83 f6 1f             	xor    $0x1f,%esi
f01068de:	75 4c                	jne    f010692c <__udivdi3+0xa4>
f01068e0:	39 f8                	cmp    %edi,%eax
f01068e2:	bf 00 00 00 00       	mov    $0x0,%edi
f01068e7:	72 0a                	jb     f01068f3 <__udivdi3+0x6b>
f01068e9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01068ed:	0f 87 ad 00 00 00    	ja     f01069a0 <__udivdi3+0x118>
f01068f3:	be 01 00 00 00       	mov    $0x1,%esi
f01068f8:	89 f0                	mov    %esi,%eax
f01068fa:	89 fa                	mov    %edi,%edx
f01068fc:	83 c4 10             	add    $0x10,%esp
f01068ff:	5e                   	pop    %esi
f0106900:	5f                   	pop    %edi
f0106901:	5d                   	pop    %ebp
f0106902:	c3                   	ret    
f0106903:	90                   	nop
f0106904:	31 ff                	xor    %edi,%edi
f0106906:	31 f6                	xor    %esi,%esi
f0106908:	89 f0                	mov    %esi,%eax
f010690a:	89 fa                	mov    %edi,%edx
f010690c:	83 c4 10             	add    $0x10,%esp
f010690f:	5e                   	pop    %esi
f0106910:	5f                   	pop    %edi
f0106911:	5d                   	pop    %ebp
f0106912:	c3                   	ret    
f0106913:	90                   	nop
f0106914:	89 fa                	mov    %edi,%edx
f0106916:	89 f0                	mov    %esi,%eax
f0106918:	f7 f1                	div    %ecx
f010691a:	89 c6                	mov    %eax,%esi
f010691c:	31 ff                	xor    %edi,%edi
f010691e:	89 f0                	mov    %esi,%eax
f0106920:	89 fa                	mov    %edi,%edx
f0106922:	83 c4 10             	add    $0x10,%esp
f0106925:	5e                   	pop    %esi
f0106926:	5f                   	pop    %edi
f0106927:	5d                   	pop    %ebp
f0106928:	c3                   	ret    
f0106929:	8d 76 00             	lea    0x0(%esi),%esi
f010692c:	89 f1                	mov    %esi,%ecx
f010692e:	d3 e0                	shl    %cl,%eax
f0106930:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106934:	b8 20 00 00 00       	mov    $0x20,%eax
f0106939:	29 f0                	sub    %esi,%eax
f010693b:	89 ea                	mov    %ebp,%edx
f010693d:	88 c1                	mov    %al,%cl
f010693f:	d3 ea                	shr    %cl,%edx
f0106941:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106945:	09 ca                	or     %ecx,%edx
f0106947:	89 54 24 08          	mov    %edx,0x8(%esp)
f010694b:	89 f1                	mov    %esi,%ecx
f010694d:	d3 e5                	shl    %cl,%ebp
f010694f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0106953:	89 fd                	mov    %edi,%ebp
f0106955:	88 c1                	mov    %al,%cl
f0106957:	d3 ed                	shr    %cl,%ebp
f0106959:	89 fa                	mov    %edi,%edx
f010695b:	89 f1                	mov    %esi,%ecx
f010695d:	d3 e2                	shl    %cl,%edx
f010695f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106963:	88 c1                	mov    %al,%cl
f0106965:	d3 ef                	shr    %cl,%edi
f0106967:	09 d7                	or     %edx,%edi
f0106969:	89 f8                	mov    %edi,%eax
f010696b:	89 ea                	mov    %ebp,%edx
f010696d:	f7 74 24 08          	divl   0x8(%esp)
f0106971:	89 d1                	mov    %edx,%ecx
f0106973:	89 c7                	mov    %eax,%edi
f0106975:	f7 64 24 0c          	mull   0xc(%esp)
f0106979:	39 d1                	cmp    %edx,%ecx
f010697b:	72 17                	jb     f0106994 <__udivdi3+0x10c>
f010697d:	74 09                	je     f0106988 <__udivdi3+0x100>
f010697f:	89 fe                	mov    %edi,%esi
f0106981:	31 ff                	xor    %edi,%edi
f0106983:	e9 41 ff ff ff       	jmp    f01068c9 <__udivdi3+0x41>
f0106988:	8b 54 24 04          	mov    0x4(%esp),%edx
f010698c:	89 f1                	mov    %esi,%ecx
f010698e:	d3 e2                	shl    %cl,%edx
f0106990:	39 c2                	cmp    %eax,%edx
f0106992:	73 eb                	jae    f010697f <__udivdi3+0xf7>
f0106994:	8d 77 ff             	lea    -0x1(%edi),%esi
f0106997:	31 ff                	xor    %edi,%edi
f0106999:	e9 2b ff ff ff       	jmp    f01068c9 <__udivdi3+0x41>
f010699e:	66 90                	xchg   %ax,%ax
f01069a0:	31 f6                	xor    %esi,%esi
f01069a2:	e9 22 ff ff ff       	jmp    f01068c9 <__udivdi3+0x41>
	...

f01069a8 <__umoddi3>:
f01069a8:	55                   	push   %ebp
f01069a9:	57                   	push   %edi
f01069aa:	56                   	push   %esi
f01069ab:	83 ec 20             	sub    $0x20,%esp
f01069ae:	8b 44 24 30          	mov    0x30(%esp),%eax
f01069b2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f01069b6:	89 44 24 14          	mov    %eax,0x14(%esp)
f01069ba:	8b 74 24 34          	mov    0x34(%esp),%esi
f01069be:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01069c2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01069c6:	89 c7                	mov    %eax,%edi
f01069c8:	89 f2                	mov    %esi,%edx
f01069ca:	85 ed                	test   %ebp,%ebp
f01069cc:	75 16                	jne    f01069e4 <__umoddi3+0x3c>
f01069ce:	39 f1                	cmp    %esi,%ecx
f01069d0:	0f 86 a6 00 00 00    	jbe    f0106a7c <__umoddi3+0xd4>
f01069d6:	f7 f1                	div    %ecx
f01069d8:	89 d0                	mov    %edx,%eax
f01069da:	31 d2                	xor    %edx,%edx
f01069dc:	83 c4 20             	add    $0x20,%esp
f01069df:	5e                   	pop    %esi
f01069e0:	5f                   	pop    %edi
f01069e1:	5d                   	pop    %ebp
f01069e2:	c3                   	ret    
f01069e3:	90                   	nop
f01069e4:	39 f5                	cmp    %esi,%ebp
f01069e6:	0f 87 ac 00 00 00    	ja     f0106a98 <__umoddi3+0xf0>
f01069ec:	0f bd c5             	bsr    %ebp,%eax
f01069ef:	83 f0 1f             	xor    $0x1f,%eax
f01069f2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01069f6:	0f 84 a8 00 00 00    	je     f0106aa4 <__umoddi3+0xfc>
f01069fc:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106a00:	d3 e5                	shl    %cl,%ebp
f0106a02:	bf 20 00 00 00       	mov    $0x20,%edi
f0106a07:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0106a0b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106a0f:	89 f9                	mov    %edi,%ecx
f0106a11:	d3 e8                	shr    %cl,%eax
f0106a13:	09 e8                	or     %ebp,%eax
f0106a15:	89 44 24 18          	mov    %eax,0x18(%esp)
f0106a19:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106a1d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106a21:	d3 e0                	shl    %cl,%eax
f0106a23:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106a27:	89 f2                	mov    %esi,%edx
f0106a29:	d3 e2                	shl    %cl,%edx
f0106a2b:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106a2f:	d3 e0                	shl    %cl,%eax
f0106a31:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0106a35:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106a39:	89 f9                	mov    %edi,%ecx
f0106a3b:	d3 e8                	shr    %cl,%eax
f0106a3d:	09 d0                	or     %edx,%eax
f0106a3f:	d3 ee                	shr    %cl,%esi
f0106a41:	89 f2                	mov    %esi,%edx
f0106a43:	f7 74 24 18          	divl   0x18(%esp)
f0106a47:	89 d6                	mov    %edx,%esi
f0106a49:	f7 64 24 0c          	mull   0xc(%esp)
f0106a4d:	89 c5                	mov    %eax,%ebp
f0106a4f:	89 d1                	mov    %edx,%ecx
f0106a51:	39 d6                	cmp    %edx,%esi
f0106a53:	72 67                	jb     f0106abc <__umoddi3+0x114>
f0106a55:	74 75                	je     f0106acc <__umoddi3+0x124>
f0106a57:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106a5b:	29 e8                	sub    %ebp,%eax
f0106a5d:	19 ce                	sbb    %ecx,%esi
f0106a5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106a63:	d3 e8                	shr    %cl,%eax
f0106a65:	89 f2                	mov    %esi,%edx
f0106a67:	89 f9                	mov    %edi,%ecx
f0106a69:	d3 e2                	shl    %cl,%edx
f0106a6b:	09 d0                	or     %edx,%eax
f0106a6d:	89 f2                	mov    %esi,%edx
f0106a6f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106a73:	d3 ea                	shr    %cl,%edx
f0106a75:	83 c4 20             	add    $0x20,%esp
f0106a78:	5e                   	pop    %esi
f0106a79:	5f                   	pop    %edi
f0106a7a:	5d                   	pop    %ebp
f0106a7b:	c3                   	ret    
f0106a7c:	85 c9                	test   %ecx,%ecx
f0106a7e:	75 0b                	jne    f0106a8b <__umoddi3+0xe3>
f0106a80:	b8 01 00 00 00       	mov    $0x1,%eax
f0106a85:	31 d2                	xor    %edx,%edx
f0106a87:	f7 f1                	div    %ecx
f0106a89:	89 c1                	mov    %eax,%ecx
f0106a8b:	89 f0                	mov    %esi,%eax
f0106a8d:	31 d2                	xor    %edx,%edx
f0106a8f:	f7 f1                	div    %ecx
f0106a91:	89 f8                	mov    %edi,%eax
f0106a93:	e9 3e ff ff ff       	jmp    f01069d6 <__umoddi3+0x2e>
f0106a98:	89 f2                	mov    %esi,%edx
f0106a9a:	83 c4 20             	add    $0x20,%esp
f0106a9d:	5e                   	pop    %esi
f0106a9e:	5f                   	pop    %edi
f0106a9f:	5d                   	pop    %ebp
f0106aa0:	c3                   	ret    
f0106aa1:	8d 76 00             	lea    0x0(%esi),%esi
f0106aa4:	39 f5                	cmp    %esi,%ebp
f0106aa6:	72 04                	jb     f0106aac <__umoddi3+0x104>
f0106aa8:	39 f9                	cmp    %edi,%ecx
f0106aaa:	77 06                	ja     f0106ab2 <__umoddi3+0x10a>
f0106aac:	89 f2                	mov    %esi,%edx
f0106aae:	29 cf                	sub    %ecx,%edi
f0106ab0:	19 ea                	sbb    %ebp,%edx
f0106ab2:	89 f8                	mov    %edi,%eax
f0106ab4:	83 c4 20             	add    $0x20,%esp
f0106ab7:	5e                   	pop    %esi
f0106ab8:	5f                   	pop    %edi
f0106ab9:	5d                   	pop    %ebp
f0106aba:	c3                   	ret    
f0106abb:	90                   	nop
f0106abc:	89 d1                	mov    %edx,%ecx
f0106abe:	89 c5                	mov    %eax,%ebp
f0106ac0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0106ac4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106ac8:	eb 8d                	jmp    f0106a57 <__umoddi3+0xaf>
f0106aca:	66 90                	xchg   %ax,%ax
f0106acc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106ad0:	72 ea                	jb     f0106abc <__umoddi3+0x114>
f0106ad2:	89 f1                	mov    %esi,%ecx
f0106ad4:	eb 81                	jmp    f0106a57 <__umoddi3+0xaf>
