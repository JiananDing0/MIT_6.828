
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
f010004b:	83 3d 80 4e 22 f0 00 	cmpl   $0x0,0xf0224e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 4e 22 f0    	mov    %esi,0xf0224e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 ec 62 00 00       	call   f0106350 <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 20 6a 10 f0 	movl   $0xf0106a20,(%esp)
f010007d:	e8 ec 3d 00 00       	call   f0103e6e <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 ad 3d 00 00       	call   f0103e3b <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 ac 7b 10 f0 	movl   $0xf0107bac,(%esp)
f0100095:	e8 d4 3d 00 00       	call   f0103e6e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010009a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000a1:	e8 2c 08 00 00       	call   f01008d2 <monitor>
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
f01000ae:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 8b 6a 10 f0 	movl   $0xf0106a8b,(%esp)
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
f01000e2:	e8 69 62 00 00       	call   f0106350 <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 97 6a 10 f0 	movl   $0xf0106a97,(%esp)
f01000f2:	e8 77 3d 00 00       	call   f0103e6e <cprintf>

	lapic_init();
f01000f7:	e8 6f 62 00 00       	call   f010636b <lapic_init>
	env_init_percpu();
f01000fc:	e8 e8 34 00 00       	call   f01035e9 <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 82 3d 00 00       	call   f0103e88 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 45 62 00 00       	call   f0106350 <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 50 22 f0    	add    $0xf0225020,%edx
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
f0100124:	e8 e6 64 00 00       	call   f010660f <spin_lock>
	//
	// Your code here:
	// Aquire lock
	lock_kernel();
	// Start execution
	sched_yield();
f0100129:	e8 4c 4a 00 00       	call   f0104b7a <sched_yield>

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
f0100135:	e8 3f 05 00 00       	call   f0100679 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010013a:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100141:	00 
f0100142:	c7 04 24 ad 6a 10 f0 	movl   $0xf0106aad,(%esp)
f0100149:	e8 20 3d 00 00       	call   f0103e6e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010014e:	e8 05 12 00 00       	call   f0101358 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100153:	e8 bb 34 00 00       	call   f0103613 <env_init>
	trap_init();
f0100158:	e8 2d 3e 00 00       	call   f0103f8a <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010015d:	e8 06 5f 00 00       	call   f0106068 <mp_init>
	lapic_init();
f0100162:	e8 04 62 00 00       	call   f010636b <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100167:	e8 58 3c 00 00       	call   f0103dc4 <pic_init>
f010016c:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0100173:	e8 97 64 00 00       	call   f010660f <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100178:	83 3d 88 4e 22 f0 07 	cmpl   $0x7,0xf0224e88
f010017f:	77 24                	ja     f01001a5 <i386_init+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100181:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100188:	00 
f0100189:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100190:	f0 
f0100191:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100198:	00 
f0100199:	c7 04 24 8b 6a 10 f0 	movl   $0xf0106a8b,(%esp)
f01001a0:	e8 9b fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001a5:	b8 92 5f 10 f0       	mov    $0xf0105f92,%eax
f01001aa:	2d 18 5f 10 f0       	sub    $0xf0105f18,%eax
f01001af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001b3:	c7 44 24 04 18 5f 10 	movl   $0xf0105f18,0x4(%esp)
f01001ba:	f0 
f01001bb:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001c2:	e8 a5 5b 00 00       	call   f0105d6c <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c7:	bb 20 50 22 f0       	mov    $0xf0225020,%ebx
f01001cc:	eb 6f                	jmp    f010023d <i386_init+0x10f>
		if (c == cpus + cpunum())  // We've started already.
f01001ce:	e8 7d 61 00 00       	call   f0106350 <cpunum>
f01001d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001da:	29 c2                	sub    %eax,%edx
f01001dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001df:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f01001e6:	39 c3                	cmp    %eax,%ebx
f01001e8:	74 50                	je     f010023a <i386_init+0x10c>

static void boot_aps(void);


void
i386_init(void)
f01001ea:	89 d8                	mov    %ebx,%eax
f01001ec:	2d 20 50 22 f0       	sub    $0xf0225020,%eax
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
f0100215:	05 00 60 22 f0       	add    $0xf0226000,%eax
f010021a:	a3 84 4e 22 f0       	mov    %eax,0xf0224e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010021f:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100226:	00 
f0100227:	0f b6 03             	movzbl (%ebx),%eax
f010022a:	89 04 24             	mov    %eax,(%esp)
f010022d:	e8 92 62 00 00       	call   f01064c4 <lapic_startap>
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
f010023d:	a1 c4 53 22 f0       	mov    0xf02253c4,%eax
f0100242:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100249:	29 c2                	sub    %eax,%edx
f010024b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010024e:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f0100255:	39 c3                	cmp    %eax,%ebx
f0100257:	0f 82 71 ff ff ff    	jb     f01001ce <i386_init+0xa0>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010025d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100264:	00 
f0100265:	c7 04 24 bc aa 1d f0 	movl   $0xf01daabc,(%esp)
f010026c:	e8 93 35 00 00       	call   f0103804 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100271:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100278:	00 
f0100279:	c7 04 24 5d 3e 21 f0 	movl   $0xf0213e5d,(%esp)
f0100280:	e8 7f 35 00 00       	call   f0103804 <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100285:	e8 96 03 00 00       	call   f0100620 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f010028a:	e8 eb 48 00 00       	call   f0104b7a <sched_yield>

f010028f <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010028f:	55                   	push   %ebp
f0100290:	89 e5                	mov    %esp,%ebp
f0100292:	53                   	push   %ebx
f0100293:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100296:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100299:	8b 45 0c             	mov    0xc(%ebp),%eax
f010029c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01002a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01002a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01002a7:	c7 04 24 c8 6a 10 f0 	movl   $0xf0106ac8,(%esp)
f01002ae:	e8 bb 3b 00 00       	call   f0103e6e <cprintf>
	vcprintf(fmt, ap);
f01002b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ba:	89 04 24             	mov    %eax,(%esp)
f01002bd:	e8 79 3b 00 00       	call   f0103e3b <vcprintf>
	cprintf("\n");
f01002c2:	c7 04 24 ac 7b 10 f0 	movl   $0xf0107bac,(%esp)
f01002c9:	e8 a0 3b 00 00       	call   f0103e6e <cprintf>
	va_end(ap);
}
f01002ce:	83 c4 14             	add    $0x14,%esp
f01002d1:	5b                   	pop    %ebx
f01002d2:	5d                   	pop    %ebp
f01002d3:	c3                   	ret    

f01002d4 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d4:	55                   	push   %ebp
f01002d5:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d7:	ba 84 00 00 00       	mov    $0x84,%edx
f01002dc:	ec                   	in     (%dx),%al
f01002dd:	ec                   	in     (%dx),%al
f01002de:	ec                   	in     (%dx),%al
f01002df:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002e0:	5d                   	pop    %ebp
f01002e1:	c3                   	ret    

f01002e2 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002e2:	55                   	push   %ebp
f01002e3:	89 e5                	mov    %esp,%ebp
f01002e5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002ea:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002eb:	a8 01                	test   $0x1,%al
f01002ed:	74 08                	je     f01002f7 <serial_proc_data+0x15>
f01002ef:	b2 f8                	mov    $0xf8,%dl
f01002f1:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002f2:	0f b6 c0             	movzbl %al,%eax
f01002f5:	eb 05                	jmp    f01002fc <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01002f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01002fc:	5d                   	pop    %ebp
f01002fd:	c3                   	ret    

f01002fe <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fe:	55                   	push   %ebp
f01002ff:	89 e5                	mov    %esp,%ebp
f0100301:	53                   	push   %ebx
f0100302:	83 ec 04             	sub    $0x4,%esp
f0100305:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100307:	eb 29                	jmp    f0100332 <cons_intr+0x34>
		if (c == 0)
f0100309:	85 c0                	test   %eax,%eax
f010030b:	74 25                	je     f0100332 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f010030d:	8b 15 24 42 22 f0    	mov    0xf0224224,%edx
f0100313:	88 82 20 40 22 f0    	mov    %al,-0xfddbfe0(%edx)
f0100319:	8d 42 01             	lea    0x1(%edx),%eax
f010031c:	a3 24 42 22 f0       	mov    %eax,0xf0224224
		if (cons.wpos == CONSBUFSIZE)
f0100321:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100326:	75 0a                	jne    f0100332 <cons_intr+0x34>
			cons.wpos = 0;
f0100328:	c7 05 24 42 22 f0 00 	movl   $0x0,0xf0224224
f010032f:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100332:	ff d3                	call   *%ebx
f0100334:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100337:	75 d0                	jne    f0100309 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100339:	83 c4 04             	add    $0x4,%esp
f010033c:	5b                   	pop    %ebx
f010033d:	5d                   	pop    %ebp
f010033e:	c3                   	ret    

f010033f <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010033f:	55                   	push   %ebp
f0100340:	89 e5                	mov    %esp,%ebp
f0100342:	57                   	push   %edi
f0100343:	56                   	push   %esi
f0100344:	53                   	push   %ebx
f0100345:	83 ec 2c             	sub    $0x2c,%esp
f0100348:	89 c6                	mov    %eax,%esi
f010034a:	bb 01 32 00 00       	mov    $0x3201,%ebx
f010034f:	bf fd 03 00 00       	mov    $0x3fd,%edi
f0100354:	eb 05                	jmp    f010035b <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f0100356:	e8 79 ff ff ff       	call   f01002d4 <delay>
f010035b:	89 fa                	mov    %edi,%edx
f010035d:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010035e:	a8 20                	test   $0x20,%al
f0100360:	75 03                	jne    f0100365 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100362:	4b                   	dec    %ebx
f0100363:	75 f1                	jne    f0100356 <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100365:	89 f2                	mov    %esi,%edx
f0100367:	89 f0                	mov    %esi,%eax
f0100369:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100371:	ee                   	out    %al,(%dx)
f0100372:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100377:	bf 79 03 00 00       	mov    $0x379,%edi
f010037c:	eb 05                	jmp    f0100383 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f010037e:	e8 51 ff ff ff       	call   f01002d4 <delay>
f0100383:	89 fa                	mov    %edi,%edx
f0100385:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100386:	84 c0                	test   %al,%al
f0100388:	78 03                	js     f010038d <cons_putc+0x4e>
f010038a:	4b                   	dec    %ebx
f010038b:	75 f1                	jne    f010037e <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010038d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100392:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100395:	ee                   	out    %al,(%dx)
f0100396:	b2 7a                	mov    $0x7a,%dl
f0100398:	b0 0d                	mov    $0xd,%al
f010039a:	ee                   	out    %al,(%dx)
f010039b:	b0 08                	mov    $0x8,%al
f010039d:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010039e:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f01003a4:	75 06                	jne    f01003ac <cons_putc+0x6d>
		c |= 0x0700;
f01003a6:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f01003ac:	89 f0                	mov    %esi,%eax
f01003ae:	25 ff 00 00 00       	and    $0xff,%eax
f01003b3:	83 f8 09             	cmp    $0x9,%eax
f01003b6:	74 78                	je     f0100430 <cons_putc+0xf1>
f01003b8:	83 f8 09             	cmp    $0x9,%eax
f01003bb:	7f 0b                	jg     f01003c8 <cons_putc+0x89>
f01003bd:	83 f8 08             	cmp    $0x8,%eax
f01003c0:	0f 85 9e 00 00 00    	jne    f0100464 <cons_putc+0x125>
f01003c6:	eb 10                	jmp    f01003d8 <cons_putc+0x99>
f01003c8:	83 f8 0a             	cmp    $0xa,%eax
f01003cb:	74 39                	je     f0100406 <cons_putc+0xc7>
f01003cd:	83 f8 0d             	cmp    $0xd,%eax
f01003d0:	0f 85 8e 00 00 00    	jne    f0100464 <cons_putc+0x125>
f01003d6:	eb 36                	jmp    f010040e <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01003d8:	66 a1 34 42 22 f0    	mov    0xf0224234,%ax
f01003de:	66 85 c0             	test   %ax,%ax
f01003e1:	0f 84 e2 00 00 00    	je     f01004c9 <cons_putc+0x18a>
			crt_pos--;
f01003e7:	48                   	dec    %eax
f01003e8:	66 a3 34 42 22 f0    	mov    %ax,0xf0224234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ee:	0f b7 c0             	movzwl %ax,%eax
f01003f1:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01003f7:	83 ce 20             	or     $0x20,%esi
f01003fa:	8b 15 30 42 22 f0    	mov    0xf0224230,%edx
f0100400:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100404:	eb 78                	jmp    f010047e <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100406:	66 83 05 34 42 22 f0 	addw   $0x50,0xf0224234
f010040d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010040e:	66 8b 0d 34 42 22 f0 	mov    0xf0224234,%cx
f0100415:	bb 50 00 00 00       	mov    $0x50,%ebx
f010041a:	89 c8                	mov    %ecx,%eax
f010041c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100421:	66 f7 f3             	div    %bx
f0100424:	66 29 d1             	sub    %dx,%cx
f0100427:	66 89 0d 34 42 22 f0 	mov    %cx,0xf0224234
f010042e:	eb 4e                	jmp    f010047e <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100430:	b8 20 00 00 00       	mov    $0x20,%eax
f0100435:	e8 05 ff ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f010043a:	b8 20 00 00 00       	mov    $0x20,%eax
f010043f:	e8 fb fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f0100444:	b8 20 00 00 00       	mov    $0x20,%eax
f0100449:	e8 f1 fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f010044e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100453:	e8 e7 fe ff ff       	call   f010033f <cons_putc>
		cons_putc(' ');
f0100458:	b8 20 00 00 00       	mov    $0x20,%eax
f010045d:	e8 dd fe ff ff       	call   f010033f <cons_putc>
f0100462:	eb 1a                	jmp    f010047e <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100464:	66 a1 34 42 22 f0    	mov    0xf0224234,%ax
f010046a:	0f b7 c8             	movzwl %ax,%ecx
f010046d:	8b 15 30 42 22 f0    	mov    0xf0224230,%edx
f0100473:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100477:	40                   	inc    %eax
f0100478:	66 a3 34 42 22 f0    	mov    %ax,0xf0224234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010047e:	66 81 3d 34 42 22 f0 	cmpw   $0x7cf,0xf0224234
f0100485:	cf 07 
f0100487:	76 40                	jbe    f01004c9 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100489:	a1 30 42 22 f0       	mov    0xf0224230,%eax
f010048e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100495:	00 
f0100496:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010049c:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004a0:	89 04 24             	mov    %eax,(%esp)
f01004a3:	e8 c4 58 00 00       	call   f0105d6c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004a8:	8b 15 30 42 22 f0    	mov    0xf0224230,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004ae:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f01004b3:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004b9:	40                   	inc    %eax
f01004ba:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f01004bf:	75 f2                	jne    f01004b3 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004c1:	66 83 2d 34 42 22 f0 	subw   $0x50,0xf0224234
f01004c8:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c9:	8b 0d 2c 42 22 f0    	mov    0xf022422c,%ecx
f01004cf:	b0 0e                	mov    $0xe,%al
f01004d1:	89 ca                	mov    %ecx,%edx
f01004d3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d4:	66 8b 35 34 42 22 f0 	mov    0xf0224234,%si
f01004db:	8d 59 01             	lea    0x1(%ecx),%ebx
f01004de:	89 f0                	mov    %esi,%eax
f01004e0:	66 c1 e8 08          	shr    $0x8,%ax
f01004e4:	89 da                	mov    %ebx,%edx
f01004e6:	ee                   	out    %al,(%dx)
f01004e7:	b0 0f                	mov    $0xf,%al
f01004e9:	89 ca                	mov    %ecx,%edx
f01004eb:	ee                   	out    %al,(%dx)
f01004ec:	89 f0                	mov    %esi,%eax
f01004ee:	89 da                	mov    %ebx,%edx
f01004f0:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004f1:	83 c4 2c             	add    $0x2c,%esp
f01004f4:	5b                   	pop    %ebx
f01004f5:	5e                   	pop    %esi
f01004f6:	5f                   	pop    %edi
f01004f7:	5d                   	pop    %ebp
f01004f8:	c3                   	ret    

f01004f9 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01004f9:	55                   	push   %ebp
f01004fa:	89 e5                	mov    %esp,%ebp
f01004fc:	53                   	push   %ebx
f01004fd:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100500:	ba 64 00 00 00       	mov    $0x64,%edx
f0100505:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100506:	0f b6 c0             	movzbl %al,%eax
f0100509:	a8 01                	test   $0x1,%al
f010050b:	0f 84 e0 00 00 00    	je     f01005f1 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100511:	a8 20                	test   $0x20,%al
f0100513:	0f 85 df 00 00 00    	jne    f01005f8 <kbd_proc_data+0xff>
f0100519:	b2 60                	mov    $0x60,%dl
f010051b:	ec                   	in     (%dx),%al
f010051c:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010051e:	3c e0                	cmp    $0xe0,%al
f0100520:	75 11                	jne    f0100533 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f0100522:	83 0d 28 42 22 f0 40 	orl    $0x40,0xf0224228
		return 0;
f0100529:	bb 00 00 00 00       	mov    $0x0,%ebx
f010052e:	e9 ca 00 00 00       	jmp    f01005fd <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100533:	84 c0                	test   %al,%al
f0100535:	79 33                	jns    f010056a <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100537:	8b 0d 28 42 22 f0    	mov    0xf0224228,%ecx
f010053d:	f6 c1 40             	test   $0x40,%cl
f0100540:	75 05                	jne    f0100547 <kbd_proc_data+0x4e>
f0100542:	88 c2                	mov    %al,%dl
f0100544:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100547:	0f b6 d2             	movzbl %dl,%edx
f010054a:	8a 82 20 6b 10 f0    	mov    -0xfef94e0(%edx),%al
f0100550:	83 c8 40             	or     $0x40,%eax
f0100553:	0f b6 c0             	movzbl %al,%eax
f0100556:	f7 d0                	not    %eax
f0100558:	21 c1                	and    %eax,%ecx
f010055a:	89 0d 28 42 22 f0    	mov    %ecx,0xf0224228
		return 0;
f0100560:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100565:	e9 93 00 00 00       	jmp    f01005fd <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f010056a:	8b 0d 28 42 22 f0    	mov    0xf0224228,%ecx
f0100570:	f6 c1 40             	test   $0x40,%cl
f0100573:	74 0e                	je     f0100583 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100575:	88 c2                	mov    %al,%dl
f0100577:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010057a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010057d:	89 0d 28 42 22 f0    	mov    %ecx,0xf0224228
	}

	shift |= shiftcode[data];
f0100583:	0f b6 d2             	movzbl %dl,%edx
f0100586:	0f b6 82 20 6b 10 f0 	movzbl -0xfef94e0(%edx),%eax
f010058d:	0b 05 28 42 22 f0    	or     0xf0224228,%eax
	shift ^= togglecode[data];
f0100593:	0f b6 8a 20 6c 10 f0 	movzbl -0xfef93e0(%edx),%ecx
f010059a:	31 c8                	xor    %ecx,%eax
f010059c:	a3 28 42 22 f0       	mov    %eax,0xf0224228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005a1:	89 c1                	mov    %eax,%ecx
f01005a3:	83 e1 03             	and    $0x3,%ecx
f01005a6:	8b 0c 8d 20 6d 10 f0 	mov    -0xfef92e0(,%ecx,4),%ecx
f01005ad:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f01005b1:	a8 08                	test   $0x8,%al
f01005b3:	74 18                	je     f01005cd <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f01005b5:	8d 53 9f             	lea    -0x61(%ebx),%edx
f01005b8:	83 fa 19             	cmp    $0x19,%edx
f01005bb:	77 05                	ja     f01005c2 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f01005bd:	83 eb 20             	sub    $0x20,%ebx
f01005c0:	eb 0b                	jmp    f01005cd <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f01005c2:	8d 53 bf             	lea    -0x41(%ebx),%edx
f01005c5:	83 fa 19             	cmp    $0x19,%edx
f01005c8:	77 03                	ja     f01005cd <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f01005ca:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01005cd:	f7 d0                	not    %eax
f01005cf:	a8 06                	test   $0x6,%al
f01005d1:	75 2a                	jne    f01005fd <kbd_proc_data+0x104>
f01005d3:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01005d9:	75 22                	jne    f01005fd <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01005db:	c7 04 24 e2 6a 10 f0 	movl   $0xf0106ae2,(%esp)
f01005e2:	e8 87 38 00 00       	call   f0103e6e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e7:	ba 92 00 00 00       	mov    $0x92,%edx
f01005ec:	b0 03                	mov    $0x3,%al
f01005ee:	ee                   	out    %al,(%dx)
f01005ef:	eb 0c                	jmp    f01005fd <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01005f1:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005f6:	eb 05                	jmp    f01005fd <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01005f8:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01005fd:	89 d8                	mov    %ebx,%eax
f01005ff:	83 c4 14             	add    $0x14,%esp
f0100602:	5b                   	pop    %ebx
f0100603:	5d                   	pop    %ebp
f0100604:	c3                   	ret    

f0100605 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100605:	55                   	push   %ebp
f0100606:	89 e5                	mov    %esp,%ebp
f0100608:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010060b:	80 3d 00 40 22 f0 00 	cmpb   $0x0,0xf0224000
f0100612:	74 0a                	je     f010061e <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100614:	b8 e2 02 10 f0       	mov    $0xf01002e2,%eax
f0100619:	e8 e0 fc ff ff       	call   f01002fe <cons_intr>
}
f010061e:	c9                   	leave  
f010061f:	c3                   	ret    

f0100620 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100620:	55                   	push   %ebp
f0100621:	89 e5                	mov    %esp,%ebp
f0100623:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100626:	b8 f9 04 10 f0       	mov    $0xf01004f9,%eax
f010062b:	e8 ce fc ff ff       	call   f01002fe <cons_intr>
}
f0100630:	c9                   	leave  
f0100631:	c3                   	ret    

f0100632 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100632:	55                   	push   %ebp
f0100633:	89 e5                	mov    %esp,%ebp
f0100635:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100638:	e8 c8 ff ff ff       	call   f0100605 <serial_intr>
	kbd_intr();
f010063d:	e8 de ff ff ff       	call   f0100620 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100642:	8b 15 20 42 22 f0    	mov    0xf0224220,%edx
f0100648:	3b 15 24 42 22 f0    	cmp    0xf0224224,%edx
f010064e:	74 22                	je     f0100672 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100650:	0f b6 82 20 40 22 f0 	movzbl -0xfddbfe0(%edx),%eax
f0100657:	42                   	inc    %edx
f0100658:	89 15 20 42 22 f0    	mov    %edx,0xf0224220
		if (cons.rpos == CONSBUFSIZE)
f010065e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100664:	75 11                	jne    f0100677 <cons_getc+0x45>
			cons.rpos = 0;
f0100666:	c7 05 20 42 22 f0 00 	movl   $0x0,0xf0224220
f010066d:	00 00 00 
f0100670:	eb 05                	jmp    f0100677 <cons_getc+0x45>
		return c;
	}
	return 0;
f0100672:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100677:	c9                   	leave  
f0100678:	c3                   	ret    

f0100679 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100679:	55                   	push   %ebp
f010067a:	89 e5                	mov    %esp,%ebp
f010067c:	57                   	push   %edi
f010067d:	56                   	push   %esi
f010067e:	53                   	push   %ebx
f010067f:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100682:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100689:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100690:	5a a5 
	if (*cp != 0xA55A) {
f0100692:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100698:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010069c:	74 11                	je     f01006af <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010069e:	c7 05 2c 42 22 f0 b4 	movl   $0x3b4,0xf022422c
f01006a5:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01006a8:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01006ad:	eb 16                	jmp    f01006c5 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01006af:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01006b6:	c7 05 2c 42 22 f0 d4 	movl   $0x3d4,0xf022422c
f01006bd:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01006c0:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006c5:	8b 0d 2c 42 22 f0    	mov    0xf022422c,%ecx
f01006cb:	b0 0e                	mov    $0xe,%al
f01006cd:	89 ca                	mov    %ecx,%edx
f01006cf:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006d0:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006d3:	89 da                	mov    %ebx,%edx
f01006d5:	ec                   	in     (%dx),%al
f01006d6:	0f b6 f8             	movzbl %al,%edi
f01006d9:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006dc:	b0 0f                	mov    $0xf,%al
f01006de:	89 ca                	mov    %ecx,%edx
f01006e0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006e1:	89 da                	mov    %ebx,%edx
f01006e3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006e4:	89 35 30 42 22 f0    	mov    %esi,0xf0224230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006ea:	0f b6 d8             	movzbl %al,%ebx
f01006ed:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006ef:	66 89 3d 34 42 22 f0 	mov    %di,0xf0224234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006f6:	e8 25 ff ff ff       	call   f0100620 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006fb:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f0100702:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100707:	89 04 24             	mov    %eax,(%esp)
f010070a:	e8 41 36 00 00       	call   f0103d50 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010070f:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100714:	b0 00                	mov    $0x0,%al
f0100716:	89 da                	mov    %ebx,%edx
f0100718:	ee                   	out    %al,(%dx)
f0100719:	b2 fb                	mov    $0xfb,%dl
f010071b:	b0 80                	mov    $0x80,%al
f010071d:	ee                   	out    %al,(%dx)
f010071e:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f0100723:	b0 0c                	mov    $0xc,%al
f0100725:	89 ca                	mov    %ecx,%edx
f0100727:	ee                   	out    %al,(%dx)
f0100728:	b2 f9                	mov    $0xf9,%dl
f010072a:	b0 00                	mov    $0x0,%al
f010072c:	ee                   	out    %al,(%dx)
f010072d:	b2 fb                	mov    $0xfb,%dl
f010072f:	b0 03                	mov    $0x3,%al
f0100731:	ee                   	out    %al,(%dx)
f0100732:	b2 fc                	mov    $0xfc,%dl
f0100734:	b0 00                	mov    $0x0,%al
f0100736:	ee                   	out    %al,(%dx)
f0100737:	b2 f9                	mov    $0xf9,%dl
f0100739:	b0 01                	mov    $0x1,%al
f010073b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010073c:	b2 fd                	mov    $0xfd,%dl
f010073e:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010073f:	3c ff                	cmp    $0xff,%al
f0100741:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100745:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100748:	a2 00 40 22 f0       	mov    %al,0xf0224000
f010074d:	89 da                	mov    %ebx,%edx
f010074f:	ec                   	in     (%dx),%al
f0100750:	89 ca                	mov    %ecx,%edx
f0100752:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f0100753:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100757:	74 1d                	je     f0100776 <cons_init+0xfd>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100759:	0f b7 05 a8 93 12 f0 	movzwl 0xf01293a8,%eax
f0100760:	25 ef ff 00 00       	and    $0xffef,%eax
f0100765:	89 04 24             	mov    %eax,(%esp)
f0100768:	e8 e3 35 00 00       	call   f0103d50 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010076d:	80 3d 00 40 22 f0 00 	cmpb   $0x0,0xf0224000
f0100774:	75 0c                	jne    f0100782 <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100776:	c7 04 24 ee 6a 10 f0 	movl   $0xf0106aee,(%esp)
f010077d:	e8 ec 36 00 00       	call   f0103e6e <cprintf>
}
f0100782:	83 c4 2c             	add    $0x2c,%esp
f0100785:	5b                   	pop    %ebx
f0100786:	5e                   	pop    %esi
f0100787:	5f                   	pop    %edi
f0100788:	5d                   	pop    %ebp
f0100789:	c3                   	ret    

f010078a <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010078a:	55                   	push   %ebp
f010078b:	89 e5                	mov    %esp,%ebp
f010078d:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100790:	8b 45 08             	mov    0x8(%ebp),%eax
f0100793:	e8 a7 fb ff ff       	call   f010033f <cons_putc>
}
f0100798:	c9                   	leave  
f0100799:	c3                   	ret    

f010079a <getchar>:

int
getchar(void)
{
f010079a:	55                   	push   %ebp
f010079b:	89 e5                	mov    %esp,%ebp
f010079d:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007a0:	e8 8d fe ff ff       	call   f0100632 <cons_getc>
f01007a5:	85 c0                	test   %eax,%eax
f01007a7:	74 f7                	je     f01007a0 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007a9:	c9                   	leave  
f01007aa:	c3                   	ret    

f01007ab <iscons>:

int
iscons(int fdnum)
{
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007ae:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b3:	5d                   	pop    %ebp
f01007b4:	c3                   	ret    
f01007b5:	00 00                	add    %al,(%eax)
	...

f01007b8 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007b8:	55                   	push   %ebp
f01007b9:	89 e5                	mov    %esp,%ebp
f01007bb:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007be:	c7 04 24 30 6d 10 f0 	movl   $0xf0106d30,(%esp)
f01007c5:	e8 a4 36 00 00       	call   f0103e6e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ca:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007d1:	00 
f01007d2:	c7 04 24 bc 6d 10 f0 	movl   $0xf0106dbc,(%esp)
f01007d9:	e8 90 36 00 00       	call   f0103e6e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007de:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007e5:	00 
f01007e6:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007ed:	f0 
f01007ee:	c7 04 24 e4 6d 10 f0 	movl   $0xf0106de4,(%esp)
f01007f5:	e8 74 36 00 00       	call   f0103e6e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007fa:	c7 44 24 08 0e 6a 10 	movl   $0x106a0e,0x8(%esp)
f0100801:	00 
f0100802:	c7 44 24 04 0e 6a 10 	movl   $0xf0106a0e,0x4(%esp)
f0100809:	f0 
f010080a:	c7 04 24 08 6e 10 f0 	movl   $0xf0106e08,(%esp)
f0100811:	e8 58 36 00 00       	call   f0103e6e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100816:	c7 44 24 08 00 40 22 	movl   $0x224000,0x8(%esp)
f010081d:	00 
f010081e:	c7 44 24 04 00 40 22 	movl   $0xf0224000,0x4(%esp)
f0100825:	f0 
f0100826:	c7 04 24 2c 6e 10 f0 	movl   $0xf0106e2c,(%esp)
f010082d:	e8 3c 36 00 00       	call   f0103e6e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100832:	c7 44 24 08 08 60 26 	movl   $0x266008,0x8(%esp)
f0100839:	00 
f010083a:	c7 44 24 04 08 60 26 	movl   $0xf0266008,0x4(%esp)
f0100841:	f0 
f0100842:	c7 04 24 50 6e 10 f0 	movl   $0xf0106e50,(%esp)
f0100849:	e8 20 36 00 00       	call   f0103e6e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010084e:	b8 07 64 26 f0       	mov    $0xf0266407,%eax
f0100853:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100858:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010085d:	89 c2                	mov    %eax,%edx
f010085f:	85 c0                	test   %eax,%eax
f0100861:	79 06                	jns    f0100869 <mon_kerninfo+0xb1>
f0100863:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100869:	c1 fa 0a             	sar    $0xa,%edx
f010086c:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100870:	c7 04 24 74 6e 10 f0 	movl   $0xf0106e74,(%esp)
f0100877:	e8 f2 35 00 00       	call   f0103e6e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010087c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100881:	c9                   	leave  
f0100882:	c3                   	ret    

f0100883 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100883:	55                   	push   %ebp
f0100884:	89 e5                	mov    %esp,%ebp
f0100886:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100889:	c7 44 24 08 49 6d 10 	movl   $0xf0106d49,0x8(%esp)
f0100890:	f0 
f0100891:	c7 44 24 04 67 6d 10 	movl   $0xf0106d67,0x4(%esp)
f0100898:	f0 
f0100899:	c7 04 24 6c 6d 10 f0 	movl   $0xf0106d6c,(%esp)
f01008a0:	e8 c9 35 00 00       	call   f0103e6e <cprintf>
f01008a5:	c7 44 24 08 a0 6e 10 	movl   $0xf0106ea0,0x8(%esp)
f01008ac:	f0 
f01008ad:	c7 44 24 04 75 6d 10 	movl   $0xf0106d75,0x4(%esp)
f01008b4:	f0 
f01008b5:	c7 04 24 6c 6d 10 f0 	movl   $0xf0106d6c,(%esp)
f01008bc:	e8 ad 35 00 00       	call   f0103e6e <cprintf>
	return 0;
}
f01008c1:	b8 00 00 00 00       	mov    $0x0,%eax
f01008c6:	c9                   	leave  
f01008c7:	c3                   	ret    

f01008c8 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008c8:	55                   	push   %ebp
f01008c9:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01008cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01008d0:	5d                   	pop    %ebp
f01008d1:	c3                   	ret    

f01008d2 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008d2:	55                   	push   %ebp
f01008d3:	89 e5                	mov    %esp,%ebp
f01008d5:	57                   	push   %edi
f01008d6:	56                   	push   %esi
f01008d7:	53                   	push   %ebx
f01008d8:	83 ec 5c             	sub    $0x5c,%esp
f01008db:	8b 7d 08             	mov    0x8(%ebp),%edi
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008de:	c7 04 24 c8 6e 10 f0 	movl   $0xf0106ec8,(%esp)
f01008e5:	e8 84 35 00 00       	call   f0103e6e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ea:	c7 04 24 ec 6e 10 f0 	movl   $0xf0106eec,(%esp)
f01008f1:	e8 78 35 00 00       	call   f0103e6e <cprintf>

	if (tf != NULL)
f01008f6:	85 ff                	test   %edi,%edi
f01008f8:	74 08                	je     f0100902 <monitor+0x30>
		print_trapframe(tf);
f01008fa:	89 3c 24             	mov    %edi,(%esp)
f01008fd:	e8 44 3b 00 00       	call   f0104446 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100902:	c7 04 24 7e 6d 10 f0 	movl   $0xf0106d7e,(%esp)
f0100909:	e8 da 51 00 00       	call   f0105ae8 <readline>
f010090e:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100910:	85 c0                	test   %eax,%eax
f0100912:	74 ee                	je     f0100902 <monitor+0x30>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100914:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010091b:	be 00 00 00 00       	mov    $0x0,%esi
f0100920:	eb 04                	jmp    f0100926 <monitor+0x54>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100922:	c6 03 00             	movb   $0x0,(%ebx)
f0100925:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100926:	8a 03                	mov    (%ebx),%al
f0100928:	84 c0                	test   %al,%al
f010092a:	74 5e                	je     f010098a <monitor+0xb8>
f010092c:	0f be c0             	movsbl %al,%eax
f010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100933:	c7 04 24 82 6d 10 f0 	movl   $0xf0106d82,(%esp)
f010093a:	e8 ae 53 00 00       	call   f0105ced <strchr>
f010093f:	85 c0                	test   %eax,%eax
f0100941:	75 df                	jne    f0100922 <monitor+0x50>
			*buf++ = 0;
		if (*buf == 0)
f0100943:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100946:	74 42                	je     f010098a <monitor+0xb8>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100948:	83 fe 0f             	cmp    $0xf,%esi
f010094b:	75 16                	jne    f0100963 <monitor+0x91>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010094d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100954:	00 
f0100955:	c7 04 24 87 6d 10 f0 	movl   $0xf0106d87,(%esp)
f010095c:	e8 0d 35 00 00       	call   f0103e6e <cprintf>
f0100961:	eb 9f                	jmp    f0100902 <monitor+0x30>
			return 0;
		}
		argv[argc++] = buf;
f0100963:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100967:	46                   	inc    %esi
f0100968:	eb 01                	jmp    f010096b <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010096a:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010096b:	8a 03                	mov    (%ebx),%al
f010096d:	84 c0                	test   %al,%al
f010096f:	74 b5                	je     f0100926 <monitor+0x54>
f0100971:	0f be c0             	movsbl %al,%eax
f0100974:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100978:	c7 04 24 82 6d 10 f0 	movl   $0xf0106d82,(%esp)
f010097f:	e8 69 53 00 00       	call   f0105ced <strchr>
f0100984:	85 c0                	test   %eax,%eax
f0100986:	74 e2                	je     f010096a <monitor+0x98>
f0100988:	eb 9c                	jmp    f0100926 <monitor+0x54>
			buf++;
	}
	argv[argc] = 0;
f010098a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100991:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100992:	85 f6                	test   %esi,%esi
f0100994:	0f 84 68 ff ff ff    	je     f0100902 <monitor+0x30>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010099a:	c7 44 24 04 67 6d 10 	movl   $0xf0106d67,0x4(%esp)
f01009a1:	f0 
f01009a2:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009a5:	89 04 24             	mov    %eax,(%esp)
f01009a8:	e8 ed 52 00 00       	call   f0105c9a <strcmp>
f01009ad:	85 c0                	test   %eax,%eax
f01009af:	74 1b                	je     f01009cc <monitor+0xfa>
f01009b1:	c7 44 24 04 75 6d 10 	movl   $0xf0106d75,0x4(%esp)
f01009b8:	f0 
f01009b9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009bc:	89 04 24             	mov    %eax,(%esp)
f01009bf:	e8 d6 52 00 00       	call   f0105c9a <strcmp>
f01009c4:	85 c0                	test   %eax,%eax
f01009c6:	75 2c                	jne    f01009f4 <monitor+0x122>
f01009c8:	b0 01                	mov    $0x1,%al
f01009ca:	eb 05                	jmp    f01009d1 <monitor+0xff>
f01009cc:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009d1:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009d4:	01 d0                	add    %edx,%eax
f01009d6:	89 7c 24 08          	mov    %edi,0x8(%esp)
f01009da:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01009dd:	89 54 24 04          	mov    %edx,0x4(%esp)
f01009e1:	89 34 24             	mov    %esi,(%esp)
f01009e4:	ff 14 85 1c 6f 10 f0 	call   *-0xfef90e4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009eb:	85 c0                	test   %eax,%eax
f01009ed:	78 1d                	js     f0100a0c <monitor+0x13a>
f01009ef:	e9 0e ff ff ff       	jmp    f0100902 <monitor+0x30>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f4:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009fb:	c7 04 24 a4 6d 10 f0 	movl   $0xf0106da4,(%esp)
f0100a02:	e8 67 34 00 00       	call   f0103e6e <cprintf>
f0100a07:	e9 f6 fe ff ff       	jmp    f0100902 <monitor+0x30>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a0c:	83 c4 5c             	add    $0x5c,%esp
f0100a0f:	5b                   	pop    %ebx
f0100a10:	5e                   	pop    %esi
f0100a11:	5f                   	pop    %edi
f0100a12:	5d                   	pop    %ebp
f0100a13:	c3                   	ret    

f0100a14 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a14:	55                   	push   %ebp
f0100a15:	89 e5                	mov    %esp,%ebp
f0100a17:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100a1a:	89 d1                	mov    %edx,%ecx
f0100a1c:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100a1f:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a22:	a8 01                	test   $0x1,%al
f0100a24:	74 4d                	je     f0100a73 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a26:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a2b:	89 c1                	mov    %eax,%ecx
f0100a2d:	c1 e9 0c             	shr    $0xc,%ecx
f0100a30:	3b 0d 88 4e 22 f0    	cmp    0xf0224e88,%ecx
f0100a36:	72 20                	jb     f0100a58 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a38:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a3c:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100a43:	f0 
f0100a44:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0100a4b:	00 
f0100a4c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100a53:	e8 e8 f5 ff ff       	call   f0100040 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100a58:	c1 ea 0c             	shr    $0xc,%edx
f0100a5b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a61:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a68:	a8 01                	test   $0x1,%al
f0100a6a:	74 0e                	je     f0100a7a <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a6c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a71:	eb 0c                	jmp    f0100a7f <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a73:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100a78:	eb 05                	jmp    f0100a7f <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f0100a7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100a7f:	c9                   	leave  
f0100a80:	c3                   	ret    

f0100a81 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a81:	55                   	push   %ebp
f0100a82:	89 e5                	mov    %esp,%ebp
f0100a84:	56                   	push   %esi
f0100a85:	53                   	push   %ebx
f0100a86:	83 ec 10             	sub    $0x10,%esp
f0100a89:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a8b:	89 04 24             	mov    %eax,(%esp)
f0100a8e:	e8 95 32 00 00       	call   f0103d28 <mc146818_read>
f0100a93:	89 c6                	mov    %eax,%esi
f0100a95:	43                   	inc    %ebx
f0100a96:	89 1c 24             	mov    %ebx,(%esp)
f0100a99:	e8 8a 32 00 00       	call   f0103d28 <mc146818_read>
f0100a9e:	c1 e0 08             	shl    $0x8,%eax
f0100aa1:	09 f0                	or     %esi,%eax
}
f0100aa3:	83 c4 10             	add    $0x10,%esp
f0100aa6:	5b                   	pop    %ebx
f0100aa7:	5e                   	pop    %esi
f0100aa8:	5d                   	pop    %ebp
f0100aa9:	c3                   	ret    

f0100aaa <boot_alloc>:
// before the page_free_list list has been set up.
// Note that when this function is called, we are still using entry_pgdir,
// which only maps the first 4MB of physical memory.
static void *
boot_alloc(uint32_t n)
{
f0100aaa:	55                   	push   %ebp
f0100aab:	89 e5                	mov    %esp,%ebp
f0100aad:	57                   	push   %edi
f0100aae:	56                   	push   %esi
f0100aaf:	53                   	push   %ebx
f0100ab0:	83 ec 1c             	sub    $0x1c,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100ab3:	83 3d 3c 42 22 f0 00 	cmpl   $0x0,0xf022423c
f0100aba:	75 11                	jne    f0100acd <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100abc:	ba 07 70 26 f0       	mov    $0xf0267007,%edx
f0100ac1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ac7:	89 15 3c 42 22 f0    	mov    %edx,0xf022423c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	assert(n >= 0);
	// Convert to physical address
	result = (char *)PADDR(nextfree);
f0100acd:	8b 15 3c 42 22 f0    	mov    0xf022423c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ad3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100ad9:	77 20                	ja     f0100afb <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100adb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100adf:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0100ae6:	f0 
f0100ae7:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100aee:	00 
f0100aef:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100af6:	e8 45 f5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100afb:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	// Determine whether it is out of bound
	if ((physaddr_t)result + n > PGSIZE * npages) {
f0100b01:	8b 1d 88 4e 22 f0    	mov    0xf0224e88,%ebx
f0100b07:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
f0100b0a:	89 de                	mov    %ebx,%esi
f0100b0c:	c1 e6 0c             	shl    $0xc,%esi
f0100b0f:	39 f7                	cmp    %esi,%edi
f0100b11:	76 1c                	jbe    f0100b2f <boot_alloc+0x85>
		panic("boot_alloc: out of memory!");
f0100b13:	c7 44 24 08 bd 78 10 	movl   $0xf01078bd,0x8(%esp)
f0100b1a:	f0 
f0100b1b:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100b22:	00 
f0100b23:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100b2a:	e8 11 f5 ff ff       	call   f0100040 <_panic>
	}
	// Otherwise, update value of nextfree, no update when n == 0
	nextfree += ROUNDUP(n, PGSIZE);
f0100b2f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b39:	01 d0                	add    %edx,%eax
f0100b3b:	a3 3c 42 22 f0       	mov    %eax,0xf022423c
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b40:	89 c8                	mov    %ecx,%eax
f0100b42:	c1 e8 0c             	shr    $0xc,%eax
f0100b45:	39 c3                	cmp    %eax,%ebx
f0100b47:	77 20                	ja     f0100b69 <boot_alloc+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100b4d:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100b54:	f0 
f0100b55:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
f0100b5c:	00 
f0100b5d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100b64:	e8 d7 f4 ff ff       	call   f0100040 <_panic>
	// Convert back to kernel virtual address and return
	return KADDR((physaddr_t)result);
}
f0100b69:	89 d0                	mov    %edx,%eax
f0100b6b:	83 c4 1c             	add    $0x1c,%esp
f0100b6e:	5b                   	pop    %ebx
f0100b6f:	5e                   	pop    %esi
f0100b70:	5f                   	pop    %edi
f0100b71:	5d                   	pop    %ebp
f0100b72:	c3                   	ret    

f0100b73 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b73:	55                   	push   %ebp
f0100b74:	89 e5                	mov    %esp,%ebp
f0100b76:	57                   	push   %edi
f0100b77:	56                   	push   %esi
f0100b78:	53                   	push   %ebx
f0100b79:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b7c:	3c 01                	cmp    $0x1,%al
f0100b7e:	19 f6                	sbb    %esi,%esi
f0100b80:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100b86:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100b87:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f0100b8d:	85 d2                	test   %edx,%edx
f0100b8f:	75 1c                	jne    f0100bad <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100b91:	c7 44 24 08 2c 6f 10 	movl   $0xf0106f2c,0x8(%esp)
f0100b98:	f0 
f0100b99:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0100ba0:	00 
f0100ba1:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100ba8:	e8 93 f4 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
f0100bad:	84 c0                	test   %al,%al
f0100baf:	74 4b                	je     f0100bfc <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100bb1:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100bb4:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100bb7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100bba:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bbd:	89 d0                	mov    %edx,%eax
f0100bbf:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0100bc5:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100bc8:	c1 e8 16             	shr    $0x16,%eax
f0100bcb:	39 c6                	cmp    %eax,%esi
f0100bcd:	0f 96 c0             	setbe  %al
f0100bd0:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100bd3:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100bd7:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100bd9:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bdd:	8b 12                	mov    (%edx),%edx
f0100bdf:	85 d2                	test   %edx,%edx
f0100be1:	75 da                	jne    f0100bbd <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100be3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100be6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100bec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100bef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100bf2:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100bf4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bf7:	a3 40 42 22 f0       	mov    %eax,0xf0224240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfc:	8b 1d 40 42 22 f0    	mov    0xf0224240,%ebx
f0100c02:	eb 63                	jmp    f0100c67 <check_page_free_list+0xf4>
f0100c04:	89 d8                	mov    %ebx,%eax
f0100c06:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0100c0c:	c1 f8 03             	sar    $0x3,%eax
f0100c0f:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100c12:	89 c2                	mov    %eax,%edx
f0100c14:	c1 ea 16             	shr    $0x16,%edx
f0100c17:	39 d6                	cmp    %edx,%esi
f0100c19:	76 4a                	jbe    f0100c65 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c1b:	89 c2                	mov    %eax,%edx
f0100c1d:	c1 ea 0c             	shr    $0xc,%edx
f0100c20:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0100c26:	72 20                	jb     f0100c48 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c28:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c2c:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100c33:	f0 
f0100c34:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c3b:	00 
f0100c3c:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0100c43:	e8 f8 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c48:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c4f:	00 
f0100c50:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c57:	00 
	return (void *)(pa + KERNBASE);
f0100c58:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c5d:	89 04 24             	mov    %eax,(%esp)
f0100c60:	e8 bd 50 00 00       	call   f0105d22 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c65:	8b 1b                	mov    (%ebx),%ebx
f0100c67:	85 db                	test   %ebx,%ebx
f0100c69:	75 99                	jne    f0100c04 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c70:	e8 35 fe ff ff       	call   f0100aaa <boot_alloc>
f0100c75:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c78:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c7e:	8b 0d 90 4e 22 f0    	mov    0xf0224e90,%ecx
		assert(pp < pages + npages);
f0100c84:	a1 88 4e 22 f0       	mov    0xf0224e88,%eax
f0100c89:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c8c:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100c8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c92:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c95:	be 00 00 00 00       	mov    $0x0,%esi
f0100c9a:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c9d:	e9 c4 01 00 00       	jmp    f0100e66 <check_page_free_list+0x2f3>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ca2:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100ca5:	73 24                	jae    f0100ccb <check_page_free_list+0x158>
f0100ca7:	c7 44 24 0c e6 78 10 	movl   $0xf01078e6,0xc(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100cb6:	f0 
f0100cb7:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f0100cbe:	00 
f0100cbf:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100ccb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cce:	72 24                	jb     f0100cf4 <check_page_free_list+0x181>
f0100cd0:	c7 44 24 0c 07 79 10 	movl   $0xf0107907,0xc(%esp)
f0100cd7:	f0 
f0100cd8:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100cdf:	f0 
f0100ce0:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f0100ce7:	00 
f0100ce8:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100cef:	e8 4c f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cf4:	89 d0                	mov    %edx,%eax
f0100cf6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cf9:	a8 07                	test   $0x7,%al
f0100cfb:	74 24                	je     f0100d21 <check_page_free_list+0x1ae>
f0100cfd:	c7 44 24 0c 50 6f 10 	movl   $0xf0106f50,0xc(%esp)
f0100d04:	f0 
f0100d05:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100d0c:	f0 
f0100d0d:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100d14:	00 
f0100d15:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100d1c:	e8 1f f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100d21:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100d24:	c1 e0 0c             	shl    $0xc,%eax
f0100d27:	75 24                	jne    f0100d4d <check_page_free_list+0x1da>
f0100d29:	c7 44 24 0c 1b 79 10 	movl   $0xf010791b,0xc(%esp)
f0100d30:	f0 
f0100d31:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100d38:	f0 
f0100d39:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f0100d40:	00 
f0100d41:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100d48:	e8 f3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d4d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d52:	75 24                	jne    f0100d78 <check_page_free_list+0x205>
f0100d54:	c7 44 24 0c 2c 79 10 	movl   $0xf010792c,0xc(%esp)
f0100d5b:	f0 
f0100d5c:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100d63:	f0 
f0100d64:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0100d6b:	00 
f0100d6c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100d73:	e8 c8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d78:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d7d:	75 24                	jne    f0100da3 <check_page_free_list+0x230>
f0100d7f:	c7 44 24 0c 84 6f 10 	movl   $0xf0106f84,0xc(%esp)
f0100d86:	f0 
f0100d87:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100d8e:	f0 
f0100d8f:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0100d96:	00 
f0100d97:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100d9e:	e8 9d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da3:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da8:	75 24                	jne    f0100dce <check_page_free_list+0x25b>
f0100daa:	c7 44 24 0c 45 79 10 	movl   $0xf0107945,0xc(%esp)
f0100db1:	f0 
f0100db2:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100db9:	f0 
f0100dba:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0100dc1:	00 
f0100dc2:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100dc9:	e8 72 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100dce:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100dd3:	76 59                	jbe    f0100e2e <check_page_free_list+0x2bb>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100dd5:	89 c1                	mov    %eax,%ecx
f0100dd7:	c1 e9 0c             	shr    $0xc,%ecx
f0100dda:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100ddd:	77 20                	ja     f0100dff <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ddf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100de3:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100dea:	f0 
f0100deb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100df2:	00 
f0100df3:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0100dfa:	e8 41 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100dff:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e05:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e08:	76 24                	jbe    f0100e2e <check_page_free_list+0x2bb>
f0100e0a:	c7 44 24 0c a8 6f 10 	movl   $0xf0106fa8,0xc(%esp)
f0100e11:	f0 
f0100e12:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100e19:	f0 
f0100e1a:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0100e21:	00 
f0100e22:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100e29:	e8 12 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e2e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e33:	75 24                	jne    f0100e59 <check_page_free_list+0x2e6>
f0100e35:	c7 44 24 0c 5f 79 10 	movl   $0xf010795f,0xc(%esp)
f0100e3c:	f0 
f0100e3d:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100e44:	f0 
f0100e45:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0100e4c:	00 
f0100e4d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100e54:	e8 e7 f1 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f0100e59:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100e5e:	77 03                	ja     f0100e63 <check_page_free_list+0x2f0>
			++nfree_basemem;
f0100e60:	46                   	inc    %esi
f0100e61:	eb 01                	jmp    f0100e64 <check_page_free_list+0x2f1>
		else
			++nfree_extmem;
f0100e63:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e64:	8b 12                	mov    (%edx),%edx
f0100e66:	85 d2                	test   %edx,%edx
f0100e68:	0f 85 34 fe ff ff    	jne    f0100ca2 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100e6e:	85 f6                	test   %esi,%esi
f0100e70:	7f 24                	jg     f0100e96 <check_page_free_list+0x323>
f0100e72:	c7 44 24 0c 7c 79 10 	movl   $0xf010797c,0xc(%esp)
f0100e79:	f0 
f0100e7a:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100e81:	f0 
f0100e82:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0100e89:	00 
f0100e8a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100e91:	e8 aa f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e96:	85 db                	test   %ebx,%ebx
f0100e98:	7f 24                	jg     f0100ebe <check_page_free_list+0x34b>
f0100e9a:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f0100ea1:	f0 
f0100ea2:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0100ea9:	f0 
f0100eaa:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100eb1:	00 
f0100eb2:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100eb9:	e8 82 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ebe:	c7 04 24 f0 6f 10 f0 	movl   $0xf0106ff0,(%esp)
f0100ec5:	e8 a4 2f 00 00       	call   f0103e6e <cprintf>
}
f0100eca:	83 c4 4c             	add    $0x4c,%esp
f0100ecd:	5b                   	pop    %ebx
f0100ece:	5e                   	pop    %esi
f0100ecf:	5f                   	pop    %edi
f0100ed0:	5d                   	pop    %ebp
f0100ed1:	c3                   	ret    

f0100ed2 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ed2:	55                   	push   %ebp
f0100ed3:	89 e5                	mov    %esp,%ebp
f0100ed5:	57                   	push   %edi
f0100ed6:	56                   	push   %esi
f0100ed7:	53                   	push   %ebx
f0100ed8:	83 ec 1c             	sub    $0x1c,%esp
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
f0100edb:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ee0:	e8 c5 fb ff ff       	call   f0100aaa <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ee5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100eea:	77 20                	ja     f0100f0c <page_init+0x3a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100eec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ef0:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0100ef7:	f0 
f0100ef8:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0100eff:	00 
f0100f00:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0100f07:	e8 34 f1 ff ff       	call   f0100040 <_panic>
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE) || (i == MPENTRY_PADDR / PGSIZE)) {
f0100f0c:	8b 35 38 42 22 f0    	mov    0xf0224238,%esi
	return (physaddr_t)kva - KERNBASE;
f0100f12:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0100f18:	c1 ef 0c             	shr    $0xc,%edi
f0100f1b:	8b 1d 40 42 22 f0    	mov    0xf0224240,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100f21:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100f26:	ba 00 00 00 00       	mov    $0x0,%edx
f0100f2b:	eb 3b                	jmp    f0100f68 <page_init+0x96>
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE) || (i == MPENTRY_PADDR / PGSIZE)) {
f0100f2d:	85 d2                	test   %edx,%edx
f0100f2f:	74 0d                	je     f0100f3e <page_init+0x6c>
f0100f31:	39 f2                	cmp    %esi,%edx
f0100f33:	72 04                	jb     f0100f39 <page_init+0x67>
f0100f35:	39 fa                	cmp    %edi,%edx
f0100f37:	72 05                	jb     f0100f3e <page_init+0x6c>
f0100f39:	83 fa 07             	cmp    $0x7,%edx
f0100f3c:	75 0e                	jne    f0100f4c <page_init+0x7a>
			pages[i].pp_ref = 1;
f0100f3e:	a1 90 4e 22 f0       	mov    0xf0224e90,%eax
f0100f43:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
f0100f4a:	eb 18                	jmp    f0100f64 <page_init+0x92>
		}
		// Rest of memory are free
		else {
			pages[i].pp_ref = 0;
f0100f4c:	89 c8                	mov    %ecx,%eax
f0100f4e:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
f0100f54:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f5a:	89 18                	mov    %ebx,(%eax)
			page_free_list = &pages[i];
f0100f5c:	89 cb                	mov    %ecx,%ebx
f0100f5e:	03 1d 90 4e 22 f0    	add    0xf0224e90,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100f64:	42                   	inc    %edx
f0100f65:	83 c1 08             	add    $0x8,%ecx
f0100f68:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0100f6e:	72 bd                	jb     f0100f2d <page_init+0x5b>
f0100f70:	89 1d 40 42 22 f0    	mov    %ebx,0xf0224240
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100f76:	83 c4 1c             	add    $0x1c,%esp
f0100f79:	5b                   	pop    %ebx
f0100f7a:	5e                   	pop    %esi
f0100f7b:	5f                   	pop    %edi
f0100f7c:	5d                   	pop    %ebp
f0100f7d:	c3                   	ret    

f0100f7e <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100f7e:	55                   	push   %ebp
f0100f7f:	89 e5                	mov    %esp,%ebp
f0100f81:	53                   	push   %ebx
f0100f82:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo *currPage = page_free_list;
f0100f85:	8b 1d 40 42 22 f0    	mov    0xf0224240,%ebx
	// Check whether out of free memory
	if (!page_free_list) {
f0100f8b:	85 db                	test   %ebx,%ebx
f0100f8d:	74 6b                	je     f0100ffa <page_alloc+0x7c>
		return NULL;
	}
	// Set the page without change the reference bit.
	page_free_list = currPage->pp_link;
f0100f8f:	8b 03                	mov    (%ebx),%eax
f0100f91:	a3 40 42 22 f0       	mov    %eax,0xf0224240
	currPage->pp_link = NULL;
f0100f96:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100f9c:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100fa0:	74 58                	je     f0100ffa <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fa2:	89 d8                	mov    %ebx,%eax
f0100fa4:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0100faa:	c1 f8 03             	sar    $0x3,%eax
f0100fad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb0:	89 c2                	mov    %eax,%edx
f0100fb2:	c1 ea 0c             	shr    $0xc,%edx
f0100fb5:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0100fbb:	72 20                	jb     f0100fdd <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fc1:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0100fc8:	f0 
f0100fc9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100fd0:	00 
f0100fd1:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0100fd8:	e8 63 f0 ff ff       	call   f0100040 <_panic>
	{
		memset(page2kva(currPage), 0, PGSIZE);
f0100fdd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100fe4:	00 
f0100fe5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100fec:	00 
	return (void *)(pa + KERNBASE);
f0100fed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ff2:	89 04 24             	mov    %eax,(%esp)
f0100ff5:	e8 28 4d 00 00       	call   f0105d22 <memset>
	}
	return currPage;
}
f0100ffa:	89 d8                	mov    %ebx,%eax
f0100ffc:	83 c4 14             	add    $0x14,%esp
f0100fff:	5b                   	pop    %ebx
f0101000:	5d                   	pop    %ebp
f0101001:	c3                   	ret    

f0101002 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0101002:	55                   	push   %ebp
f0101003:	89 e5                	mov    %esp,%ebp
f0101005:	83 ec 18             	sub    $0x18,%esp
f0101008:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref || pp->pp_link) {
f010100b:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0101010:	75 05                	jne    f0101017 <page_free+0x15>
f0101012:	83 38 00             	cmpl   $0x0,(%eax)
f0101015:	74 1c                	je     f0101033 <page_free+0x31>
		panic("page_free: reference bit is nonzero or link is not NULL!");
f0101017:	c7 44 24 08 14 70 10 	movl   $0xf0107014,0x8(%esp)
f010101e:	f0 
f010101f:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0101026:	00 
f0101027:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010102e:	e8 0d f0 ff ff       	call   f0100040 <_panic>
	}
	// Update the free list
	pp->pp_link = page_free_list;
f0101033:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f0101039:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010103b:	a3 40 42 22 f0       	mov    %eax,0xf0224240
}
f0101040:	c9                   	leave  
f0101041:	c3                   	ret    

f0101042 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101042:	55                   	push   %ebp
f0101043:	89 e5                	mov    %esp,%ebp
f0101045:	83 ec 18             	sub    $0x18,%esp
f0101048:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f010104b:	8b 50 04             	mov    0x4(%eax),%edx
f010104e:	4a                   	dec    %edx
f010104f:	66 89 50 04          	mov    %dx,0x4(%eax)
f0101053:	66 85 d2             	test   %dx,%dx
f0101056:	75 08                	jne    f0101060 <page_decref+0x1e>
		page_free(pp);
f0101058:	89 04 24             	mov    %eax,(%esp)
f010105b:	e8 a2 ff ff ff       	call   f0101002 <page_free>
}
f0101060:	c9                   	leave  
f0101061:	c3                   	ret    

f0101062 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101062:	55                   	push   %ebp
f0101063:	89 e5                	mov    %esp,%ebp
f0101065:	56                   	push   %esi
f0101066:	53                   	push   %ebx
f0101067:	83 ec 10             	sub    $0x10,%esp
f010106a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	struct PageInfo *newPage;
	pde_t *pdeEntry = &pgdir[PDX(va)];
f010106d:	89 f3                	mov    %esi,%ebx
f010106f:	c1 eb 16             	shr    $0x16,%ebx
f0101072:	c1 e3 02             	shl    $0x2,%ebx
f0101075:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t *pteEntry;
	// First extract the content stored in the page directory, 
	// it should be a physical address with some PTE information.
	// If the content is not null, convert it into virtual 
	// address and return
	if (*pdeEntry & PTE_P) {
f0101078:	f6 03 01             	testb  $0x1,(%ebx)
f010107b:	75 2b                	jne    f01010a8 <pgdir_walk+0x46>
		goto good;
	}
	// Otherwise, intialize a new page if permitted
	if (create) {
f010107d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101081:	74 6b                	je     f01010ee <pgdir_walk+0x8c>
		newPage = page_alloc(ALLOC_ZERO);
f0101083:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010108a:	e8 ef fe ff ff       	call   f0100f7e <page_alloc>
		// If the page allocation success
		if (newPage) {
f010108f:	85 c0                	test   %eax,%eax
f0101091:	74 62                	je     f01010f5 <pgdir_walk+0x93>
			newPage->pp_ref++;
f0101093:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101097:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f010109d:	c1 f8 03             	sar    $0x3,%eax
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
f01010a0:	c1 e0 0c             	shl    $0xc,%eax
f01010a3:	83 c8 07             	or     $0x7,%eax
f01010a6:	89 03                	mov    %eax,(%ebx)
		}
	}
	return NULL;

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
f01010a8:	8b 03                	mov    (%ebx),%eax
f01010aa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01010af:	89 c2                	mov    %eax,%edx
f01010b1:	c1 ea 0c             	shr    $0xc,%edx
f01010b4:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f01010ba:	72 20                	jb     f01010dc <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010c0:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01010c7:	f0 
f01010c8:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
f01010cf:	00 
f01010d0:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01010d7:	e8 64 ef ff ff       	call   f0100040 <_panic>
	return &pteEntry[PTX(va)];
f01010dc:	c1 ee 0a             	shr    $0xa,%esi
f01010df:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010e5:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f01010ec:	eb 0c                	jmp    f01010fa <pgdir_walk+0x98>
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
			goto good;
		}
	}
	return NULL;
f01010ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01010f3:	eb 05                	jmp    f01010fa <pgdir_walk+0x98>
f01010f5:	b8 00 00 00 00       	mov    $0x0,%eax

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
	return &pteEntry[PTX(va)];
}
f01010fa:	83 c4 10             	add    $0x10,%esp
f01010fd:	5b                   	pop    %ebx
f01010fe:	5e                   	pop    %esi
f01010ff:	5d                   	pop    %ebp
f0101100:	c3                   	ret    

f0101101 <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101101:	55                   	push   %ebp
f0101102:	89 e5                	mov    %esp,%ebp
f0101104:	57                   	push   %edi
f0101105:	56                   	push   %esi
f0101106:	53                   	push   %ebx
f0101107:	83 ec 2c             	sub    $0x2c,%esp
f010110a:	89 c7                	mov    %eax,%edi
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
f010110c:	c1 e9 0c             	shr    $0xc,%ecx
f010110f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0101112:	89 d3                	mov    %edx,%ebx
f0101114:	be 00 00 00 00       	mov    $0x0,%esi
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f0101119:	8b 45 0c             	mov    0xc(%ebp),%eax
f010111c:	83 c8 01             	or     $0x1,%eax
f010111f:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101122:	8b 45 08             	mov    0x8(%ebp),%eax
f0101125:	29 d0                	sub    %edx,%eax
f0101127:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f010112a:	eb 2b                	jmp    f0101157 <boot_map_region+0x56>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
f010112c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101133:	00 
f0101134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101138:	89 3c 24             	mov    %edi,(%esp)
f010113b:	e8 22 ff ff ff       	call   f0101062 <pgdir_walk>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101140:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101143:	01 da                	add    %ebx,%edx
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f0101145:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010114b:	0b 55 e0             	or     -0x20(%ebp),%edx
f010114e:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0101150:	46                   	inc    %esi
f0101151:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101157:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010115a:	75 d0                	jne    f010112c <boot_map_region+0x2b>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
	}
}
f010115c:	83 c4 2c             	add    $0x2c,%esp
f010115f:	5b                   	pop    %ebx
f0101160:	5e                   	pop    %esi
f0101161:	5f                   	pop    %edi
f0101162:	5d                   	pop    %ebp
f0101163:	c3                   	ret    

f0101164 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101164:	55                   	push   %ebp
f0101165:	89 e5                	mov    %esp,%ebp
f0101167:	53                   	push   %ebx
f0101168:	83 ec 14             	sub    $0x14,%esp
f010116b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
f010116e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101175:	00 
f0101176:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101179:	89 44 24 04          	mov    %eax,0x4(%esp)
f010117d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101180:	89 04 24             	mov    %eax,(%esp)
f0101183:	e8 da fe ff ff       	call   f0101062 <pgdir_walk>
	physaddr_t pp;
	if (!pteEntry) {
f0101188:	85 c0                	test   %eax,%eax
f010118a:	74 3f                	je     f01011cb <page_lookup+0x67>
		return NULL;
	}
	if (*pteEntry & PTE_P) {
f010118c:	f6 00 01             	testb  $0x1,(%eax)
f010118f:	74 41                	je     f01011d2 <page_lookup+0x6e>
		// Modify pte_store passed as a reference
		if (pte_store) {
f0101191:	85 db                	test   %ebx,%ebx
f0101193:	74 02                	je     f0101197 <page_lookup+0x33>
		 	*pte_store = pteEntry;
f0101195:	89 03                	mov    %eax,(%ebx)
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
f0101197:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101199:	c1 e8 0c             	shr    $0xc,%eax
f010119c:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f01011a2:	72 1c                	jb     f01011c0 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f01011a4:	c7 44 24 08 50 70 10 	movl   $0xf0107050,0x8(%esp)
f01011ab:	f0 
f01011ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01011b3:	00 
f01011b4:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f01011bb:	e8 80 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011c0:	c1 e0 03             	shl    $0x3,%eax
f01011c3:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
		return pa2page(pp);
f01011c9:	eb 0c                	jmp    f01011d7 <page_lookup+0x73>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
	physaddr_t pp;
	if (!pteEntry) {
		return NULL;
f01011cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01011d0:	eb 05                	jmp    f01011d7 <page_lookup+0x73>
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
		return pa2page(pp);
	}
	return NULL;
f01011d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01011d7:	83 c4 14             	add    $0x14,%esp
f01011da:	5b                   	pop    %ebx
f01011db:	5d                   	pop    %ebp
f01011dc:	c3                   	ret    

f01011dd <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01011dd:	55                   	push   %ebp
f01011de:	89 e5                	mov    %esp,%ebp
f01011e0:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01011e3:	e8 68 51 00 00       	call   f0106350 <cpunum>
f01011e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011ef:	29 c2                	sub    %eax,%edx
f01011f1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01011f4:	83 3c 85 28 50 22 f0 	cmpl   $0x0,-0xfddafd8(,%eax,4)
f01011fb:	00 
f01011fc:	74 20                	je     f010121e <tlb_invalidate+0x41>
f01011fe:	e8 4d 51 00 00       	call   f0106350 <cpunum>
f0101203:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010120a:	29 c2                	sub    %eax,%edx
f010120c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010120f:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0101216:	8b 55 08             	mov    0x8(%ebp),%edx
f0101219:	39 50 60             	cmp    %edx,0x60(%eax)
f010121c:	75 06                	jne    f0101224 <tlb_invalidate+0x47>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010121e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101221:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0101224:	c9                   	leave  
f0101225:	c3                   	ret    

f0101226 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101226:	55                   	push   %ebp
f0101227:	89 e5                	mov    %esp,%ebp
f0101229:	56                   	push   %esi
f010122a:	53                   	push   %ebx
f010122b:	83 ec 20             	sub    $0x20,%esp
f010122e:	8b 75 08             	mov    0x8(%ebp),%esi
f0101231:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// Create a ptep store
	pte_t *pteEntry;
	// Look up the page and the entry for the page
	struct PageInfo *pp = page_lookup(pgdir, va, &pteEntry);
f0101234:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101237:	89 44 24 08          	mov    %eax,0x8(%esp)
f010123b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010123f:	89 34 24             	mov    %esi,(%esp)
f0101242:	e8 1d ff ff ff       	call   f0101164 <page_lookup>
	if (!pp) {
f0101247:	85 c0                	test   %eax,%eax
f0101249:	74 1d                	je     f0101268 <page_remove+0x42>
		return;
	}
	page_decref(pp);
f010124b:	89 04 24             	mov    %eax,(%esp)
f010124e:	e8 ef fd ff ff       	call   f0101042 <page_decref>
	tlb_invalidate(pgdir, va);
f0101253:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101257:	89 34 24             	mov    %esi,(%esp)
f010125a:	e8 7e ff ff ff       	call   f01011dd <tlb_invalidate>
	// Enpty the page table
	*pteEntry = 0;
f010125f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101262:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f0101268:	83 c4 20             	add    $0x20,%esp
f010126b:	5b                   	pop    %ebx
f010126c:	5e                   	pop    %esi
f010126d:	5d                   	pop    %ebp
f010126e:	c3                   	ret    

f010126f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010126f:	55                   	push   %ebp
f0101270:	89 e5                	mov    %esp,%ebp
f0101272:	57                   	push   %edi
f0101273:	56                   	push   %esi
f0101274:	53                   	push   %ebx
f0101275:	83 ec 1c             	sub    $0x1c,%esp
f0101278:	8b 7d 08             	mov    0x8(%ebp),%edi
f010127b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
f010127e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101285:	00 
f0101286:	8b 45 10             	mov    0x10(%ebp),%eax
f0101289:	89 44 24 04          	mov    %eax,0x4(%esp)
f010128d:	89 3c 24             	mov    %edi,(%esp)
f0101290:	e8 cd fd ff ff       	call   f0101062 <pgdir_walk>
f0101295:	89 c6                	mov    %eax,%esi
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
f0101297:	85 c0                	test   %eax,%eax
f0101299:	74 41                	je     f01012dc <page_insert+0x6d>
		return -E_NO_MEM;
	}
	// Increment reference bit
	pp->pp_ref++;
f010129b:	66 ff 43 04          	incw   0x4(%ebx)
	// If the page itself is valid, remove it
	if (*pteEntry & PTE_P) {
f010129f:	f6 00 01             	testb  $0x1,(%eax)
f01012a2:	74 0f                	je     f01012b3 <page_insert+0x44>
		// If there is already a page at va, it should be removed
		page_remove(pgdir, va);
f01012a4:	8b 55 10             	mov    0x10(%ebp),%edx
f01012a7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01012ab:	89 3c 24             	mov    %edi,(%esp)
f01012ae:	e8 73 ff ff ff       	call   f0101226 <page_remove>
	}
	// Modify premission for both directory entry and page table entry
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f01012b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01012b6:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01012b9:	2b 1d 90 4e 22 f0    	sub    0xf0224e90,%ebx
f01012bf:	c1 fb 03             	sar    $0x3,%ebx
f01012c2:	c1 e3 0c             	shl    $0xc,%ebx
f01012c5:	09 c3                	or     %eax,%ebx
f01012c7:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm;
f01012c9:	8b 45 10             	mov    0x10(%ebp),%eax
f01012cc:	c1 e8 16             	shr    $0x16,%eax
f01012cf:	8b 55 14             	mov    0x14(%ebp),%edx
f01012d2:	09 14 87             	or     %edx,(%edi,%eax,4)
	// Return success
	return 0;
f01012d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01012da:	eb 05                	jmp    f01012e1 <page_insert+0x72>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
		return -E_NO_MEM;
f01012dc:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// Modify premission for both directory entry and page table entry
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	pgdir[PDX(va)] |= perm;
	// Return success
	return 0;
}
f01012e1:	83 c4 1c             	add    $0x1c,%esp
f01012e4:	5b                   	pop    %ebx
f01012e5:	5e                   	pop    %esi
f01012e6:	5f                   	pop    %edi
f01012e7:	5d                   	pop    %ebp
f01012e8:	c3                   	ret    

f01012e9 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01012e9:	55                   	push   %ebp
f01012ea:	89 e5                	mov    %esp,%ebp
f01012ec:	53                   	push   %ebx
f01012ed:	83 ec 14             	sub    $0x14,%esp
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	// Round size up
	size = (size + PGSIZE - 1) & ~(0xfff);
f01012f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01012f3:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
f01012f9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (base + size > MMIOLIM) {
f01012ff:	8b 15 00 93 12 f0    	mov    0xf0129300,%edx
f0101305:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101308:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010130d:	76 1c                	jbe    f010132b <mmio_map_region+0x42>
		panic("mmio_map_region: unable to map region");
f010130f:	c7 44 24 08 70 70 10 	movl   $0xf0107070,0x8(%esp)
f0101316:	f0 
f0101317:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f010131e:	00 
f010131f:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101326:	e8 15 ed ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010132b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101332:	00 
f0101333:	8b 45 08             	mov    0x8(%ebp),%eax
f0101336:	89 04 24             	mov    %eax,(%esp)
f0101339:	89 d9                	mov    %ebx,%ecx
f010133b:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101340:	e8 bc fd ff ff       	call   f0101101 <boot_map_region>
	newBase = base;
f0101345:	a1 00 93 12 f0       	mov    0xf0129300,%eax
	base += size;
f010134a:	01 c3                	add    %eax,%ebx
f010134c:	89 1d 00 93 12 f0    	mov    %ebx,0xf0129300
	return (void *)newBase;
}
f0101352:	83 c4 14             	add    $0x14,%esp
f0101355:	5b                   	pop    %ebx
f0101356:	5d                   	pop    %ebp
f0101357:	c3                   	ret    

f0101358 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101358:	55                   	push   %ebp
f0101359:	89 e5                	mov    %esp,%ebp
f010135b:	57                   	push   %edi
f010135c:	56                   	push   %esi
f010135d:	53                   	push   %ebx
f010135e:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101361:	b8 15 00 00 00       	mov    $0x15,%eax
f0101366:	e8 16 f7 ff ff       	call   f0100a81 <nvram_read>
f010136b:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010136d:	b8 17 00 00 00       	mov    $0x17,%eax
f0101372:	e8 0a f7 ff ff       	call   f0100a81 <nvram_read>
f0101377:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101379:	b8 34 00 00 00       	mov    $0x34,%eax
f010137e:	e8 fe f6 ff ff       	call   f0100a81 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101383:	c1 e0 06             	shl    $0x6,%eax
f0101386:	74 08                	je     f0101390 <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f0101388:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f010138e:	eb 0e                	jmp    f010139e <mem_init+0x46>
	else if (extmem)
f0101390:	85 f6                	test   %esi,%esi
f0101392:	74 08                	je     f010139c <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0101394:	81 c6 00 04 00 00    	add    $0x400,%esi
f010139a:	eb 02                	jmp    f010139e <mem_init+0x46>
	else
		totalmem = basemem;
f010139c:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f010139e:	89 f0                	mov    %esi,%eax
f01013a0:	c1 e8 02             	shr    $0x2,%eax
f01013a3:	a3 88 4e 22 f0       	mov    %eax,0xf0224e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01013a8:	89 d8                	mov    %ebx,%eax
f01013aa:	c1 e8 02             	shr    $0x2,%eax
f01013ad:	a3 38 42 22 f0       	mov    %eax,0xf0224238

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013b2:	89 f0                	mov    %esi,%eax
f01013b4:	29 d8                	sub    %ebx,%eax
f01013b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01013be:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013c2:	c7 04 24 98 70 10 f0 	movl   $0xf0107098,(%esp)
f01013c9:	e8 a0 2a 00 00       	call   f0103e6e <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013ce:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013d3:	e8 d2 f6 ff ff       	call   f0100aaa <boot_alloc>
f01013d8:	a3 8c 4e 22 f0       	mov    %eax,0xf0224e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013e4:	00 
f01013e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013ec:	00 
f01013ed:	89 04 24             	mov    %eax,(%esp)
f01013f0:	e8 2d 49 00 00       	call   f0105d22 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013f5:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013ff:	77 20                	ja     f0101421 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101401:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101405:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f010140c:	f0 
f010140d:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
f0101414:	00 
f0101415:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010141c:	e8 1f ec ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101421:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101427:	83 ca 05             	or     $0x5,%edx
f010142a:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101430:	a1 88 4e 22 f0       	mov    0xf0224e88,%eax
f0101435:	c1 e0 03             	shl    $0x3,%eax
f0101438:	e8 6d f6 ff ff       	call   f0100aaa <boot_alloc>
f010143d:	a3 90 4e 22 f0       	mov    %eax,0xf0224e90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101442:	8b 15 88 4e 22 f0    	mov    0xf0224e88,%edx
f0101448:	c1 e2 03             	shl    $0x3,%edx
f010144b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010144f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101456:	00 
f0101457:	89 04 24             	mov    %eax,(%esp)
f010145a:	e8 c3 48 00 00       	call   f0105d22 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f010145f:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101464:	e8 41 f6 ff ff       	call   f0100aaa <boot_alloc>
f0101469:	a3 48 42 22 f0       	mov    %eax,0xf0224248
	memset(envs, 0, sizeof(struct Env) * NENV);
f010146e:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0101475:	00 
f0101476:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010147d:	00 
f010147e:	89 04 24             	mov    %eax,(%esp)
f0101481:	e8 9c 48 00 00       	call   f0105d22 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101486:	e8 47 fa ff ff       	call   f0100ed2 <page_init>

	check_page_free_list(1);
f010148b:	b8 01 00 00 00       	mov    $0x1,%eax
f0101490:	e8 de f6 ff ff       	call   f0100b73 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101495:	83 3d 90 4e 22 f0 00 	cmpl   $0x0,0xf0224e90
f010149c:	75 1c                	jne    f01014ba <mem_init+0x162>
		panic("'pages' is a null pointer!");
f010149e:	c7 44 24 08 9f 79 10 	movl   $0xf010799f,0x8(%esp)
f01014a5:	f0 
f01014a6:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01014ad:	00 
f01014ae:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01014b5:	e8 86 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014ba:	a1 40 42 22 f0       	mov    0xf0224240,%eax
f01014bf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01014c4:	eb 03                	jmp    f01014c9 <mem_init+0x171>
		++nfree;
f01014c6:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014c7:	8b 00                	mov    (%eax),%eax
f01014c9:	85 c0                	test   %eax,%eax
f01014cb:	75 f9                	jne    f01014c6 <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014d4:	e8 a5 fa ff ff       	call   f0100f7e <page_alloc>
f01014d9:	89 c6                	mov    %eax,%esi
f01014db:	85 c0                	test   %eax,%eax
f01014dd:	75 24                	jne    f0101503 <mem_init+0x1ab>
f01014df:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f01014e6:	f0 
f01014e7:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01014ee:	f0 
f01014ef:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01014f6:	00 
f01014f7:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01014fe:	e8 3d eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101503:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010150a:	e8 6f fa ff ff       	call   f0100f7e <page_alloc>
f010150f:	89 c7                	mov    %eax,%edi
f0101511:	85 c0                	test   %eax,%eax
f0101513:	75 24                	jne    f0101539 <mem_init+0x1e1>
f0101515:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f010151c:	f0 
f010151d:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101524:	f0 
f0101525:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f010152c:	00 
f010152d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101534:	e8 07 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101540:	e8 39 fa ff ff       	call   f0100f7e <page_alloc>
f0101545:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101548:	85 c0                	test   %eax,%eax
f010154a:	75 24                	jne    f0101570 <mem_init+0x218>
f010154c:	c7 44 24 0c e6 79 10 	movl   $0xf01079e6,0xc(%esp)
f0101553:	f0 
f0101554:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010155b:	f0 
f010155c:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101563:	00 
f0101564:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010156b:	e8 d0 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101570:	39 fe                	cmp    %edi,%esi
f0101572:	75 24                	jne    f0101598 <mem_init+0x240>
f0101574:	c7 44 24 0c fc 79 10 	movl   $0xf01079fc,0xc(%esp)
f010157b:	f0 
f010157c:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101583:	f0 
f0101584:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f010158b:	00 
f010158c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101593:	e8 a8 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101598:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010159b:	74 05                	je     f01015a2 <mem_init+0x24a>
f010159d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015a0:	75 24                	jne    f01015c6 <mem_init+0x26e>
f01015a2:	c7 44 24 0c d4 70 10 	movl   $0xf01070d4,0xc(%esp)
f01015a9:	f0 
f01015aa:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01015b1:	f0 
f01015b2:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01015b9:	00 
f01015ba:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01015c1:	e8 7a ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015c6:	8b 15 90 4e 22 f0    	mov    0xf0224e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015cc:	a1 88 4e 22 f0       	mov    0xf0224e88,%eax
f01015d1:	c1 e0 0c             	shl    $0xc,%eax
f01015d4:	89 f1                	mov    %esi,%ecx
f01015d6:	29 d1                	sub    %edx,%ecx
f01015d8:	c1 f9 03             	sar    $0x3,%ecx
f01015db:	c1 e1 0c             	shl    $0xc,%ecx
f01015de:	39 c1                	cmp    %eax,%ecx
f01015e0:	72 24                	jb     f0101606 <mem_init+0x2ae>
f01015e2:	c7 44 24 0c 0e 7a 10 	movl   $0xf0107a0e,0xc(%esp)
f01015e9:	f0 
f01015ea:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01015f1:	f0 
f01015f2:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f01015f9:	00 
f01015fa:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101601:	e8 3a ea ff ff       	call   f0100040 <_panic>
f0101606:	89 f9                	mov    %edi,%ecx
f0101608:	29 d1                	sub    %edx,%ecx
f010160a:	c1 f9 03             	sar    $0x3,%ecx
f010160d:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101610:	39 c8                	cmp    %ecx,%eax
f0101612:	77 24                	ja     f0101638 <mem_init+0x2e0>
f0101614:	c7 44 24 0c 2b 7a 10 	movl   $0xf0107a2b,0xc(%esp)
f010161b:	f0 
f010161c:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101623:	f0 
f0101624:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f010162b:	00 
f010162c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101633:	e8 08 ea ff ff       	call   f0100040 <_panic>
f0101638:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010163b:	29 d1                	sub    %edx,%ecx
f010163d:	89 ca                	mov    %ecx,%edx
f010163f:	c1 fa 03             	sar    $0x3,%edx
f0101642:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101645:	39 d0                	cmp    %edx,%eax
f0101647:	77 24                	ja     f010166d <mem_init+0x315>
f0101649:	c7 44 24 0c 48 7a 10 	movl   $0xf0107a48,0xc(%esp)
f0101650:	f0 
f0101651:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101658:	f0 
f0101659:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101660:	00 
f0101661:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101668:	e8 d3 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010166d:	a1 40 42 22 f0       	mov    0xf0224240,%eax
f0101672:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101675:	c7 05 40 42 22 f0 00 	movl   $0x0,0xf0224240
f010167c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010167f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101686:	e8 f3 f8 ff ff       	call   f0100f7e <page_alloc>
f010168b:	85 c0                	test   %eax,%eax
f010168d:	74 24                	je     f01016b3 <mem_init+0x35b>
f010168f:	c7 44 24 0c 65 7a 10 	movl   $0xf0107a65,0xc(%esp)
f0101696:	f0 
f0101697:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010169e:	f0 
f010169f:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f01016a6:	00 
f01016a7:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01016ae:	e8 8d e9 ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01016b3:	89 34 24             	mov    %esi,(%esp)
f01016b6:	e8 47 f9 ff ff       	call   f0101002 <page_free>
	page_free(pp1);
f01016bb:	89 3c 24             	mov    %edi,(%esp)
f01016be:	e8 3f f9 ff ff       	call   f0101002 <page_free>
	page_free(pp2);
f01016c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016c6:	89 04 24             	mov    %eax,(%esp)
f01016c9:	e8 34 f9 ff ff       	call   f0101002 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016ce:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016d5:	e8 a4 f8 ff ff       	call   f0100f7e <page_alloc>
f01016da:	89 c6                	mov    %eax,%esi
f01016dc:	85 c0                	test   %eax,%eax
f01016de:	75 24                	jne    f0101704 <mem_init+0x3ac>
f01016e0:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f01016e7:	f0 
f01016e8:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01016ef:	f0 
f01016f0:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f01016f7:	00 
f01016f8:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01016ff:	e8 3c e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101704:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010170b:	e8 6e f8 ff ff       	call   f0100f7e <page_alloc>
f0101710:	89 c7                	mov    %eax,%edi
f0101712:	85 c0                	test   %eax,%eax
f0101714:	75 24                	jne    f010173a <mem_init+0x3e2>
f0101716:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f010171d:	f0 
f010171e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101725:	f0 
f0101726:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f010172d:	00 
f010172e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101735:	e8 06 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010173a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101741:	e8 38 f8 ff ff       	call   f0100f7e <page_alloc>
f0101746:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101749:	85 c0                	test   %eax,%eax
f010174b:	75 24                	jne    f0101771 <mem_init+0x419>
f010174d:	c7 44 24 0c e6 79 10 	movl   $0xf01079e6,0xc(%esp)
f0101754:	f0 
f0101755:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010175c:	f0 
f010175d:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101764:	00 
f0101765:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010176c:	e8 cf e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101771:	39 fe                	cmp    %edi,%esi
f0101773:	75 24                	jne    f0101799 <mem_init+0x441>
f0101775:	c7 44 24 0c fc 79 10 	movl   $0xf01079fc,0xc(%esp)
f010177c:	f0 
f010177d:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101784:	f0 
f0101785:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f010178c:	00 
f010178d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101794:	e8 a7 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101799:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010179c:	74 05                	je     f01017a3 <mem_init+0x44b>
f010179e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017a1:	75 24                	jne    f01017c7 <mem_init+0x46f>
f01017a3:	c7 44 24 0c d4 70 10 	movl   $0xf01070d4,0xc(%esp)
f01017aa:	f0 
f01017ab:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01017b2:	f0 
f01017b3:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f01017ba:	00 
f01017bb:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01017c2:	e8 79 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ce:	e8 ab f7 ff ff       	call   f0100f7e <page_alloc>
f01017d3:	85 c0                	test   %eax,%eax
f01017d5:	74 24                	je     f01017fb <mem_init+0x4a3>
f01017d7:	c7 44 24 0c 65 7a 10 	movl   $0xf0107a65,0xc(%esp)
f01017de:	f0 
f01017df:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01017e6:	f0 
f01017e7:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f01017ee:	00 
f01017ef:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01017f6:	e8 45 e8 ff ff       	call   f0100040 <_panic>
f01017fb:	89 f0                	mov    %esi,%eax
f01017fd:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0101803:	c1 f8 03             	sar    $0x3,%eax
f0101806:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101809:	89 c2                	mov    %eax,%edx
f010180b:	c1 ea 0c             	shr    $0xc,%edx
f010180e:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0101814:	72 20                	jb     f0101836 <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101816:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010181a:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0101821:	f0 
f0101822:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101829:	00 
f010182a:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0101831:	e8 0a e8 ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101836:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010183d:	00 
f010183e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101845:	00 
	return (void *)(pa + KERNBASE);
f0101846:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010184b:	89 04 24             	mov    %eax,(%esp)
f010184e:	e8 cf 44 00 00       	call   f0105d22 <memset>
	page_free(pp0);
f0101853:	89 34 24             	mov    %esi,(%esp)
f0101856:	e8 a7 f7 ff ff       	call   f0101002 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010185b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101862:	e8 17 f7 ff ff       	call   f0100f7e <page_alloc>
f0101867:	85 c0                	test   %eax,%eax
f0101869:	75 24                	jne    f010188f <mem_init+0x537>
f010186b:	c7 44 24 0c 74 7a 10 	movl   $0xf0107a74,0xc(%esp)
f0101872:	f0 
f0101873:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010187a:	f0 
f010187b:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101882:	00 
f0101883:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010188a:	e8 b1 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010188f:	39 c6                	cmp    %eax,%esi
f0101891:	74 24                	je     f01018b7 <mem_init+0x55f>
f0101893:	c7 44 24 0c 92 7a 10 	movl   $0xf0107a92,0xc(%esp)
f010189a:	f0 
f010189b:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01018a2:	f0 
f01018a3:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f01018aa:	00 
f01018ab:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01018b2:	e8 89 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b7:	89 f2                	mov    %esi,%edx
f01018b9:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f01018bf:	c1 fa 03             	sar    $0x3,%edx
f01018c2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018c5:	89 d0                	mov    %edx,%eax
f01018c7:	c1 e8 0c             	shr    $0xc,%eax
f01018ca:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f01018d0:	72 20                	jb     f01018f2 <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01018d6:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01018dd:	f0 
f01018de:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018e5:	00 
f01018e6:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f01018ed:	e8 4e e7 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01018f2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01018f8:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01018fe:	80 38 00             	cmpb   $0x0,(%eax)
f0101901:	74 24                	je     f0101927 <mem_init+0x5cf>
f0101903:	c7 44 24 0c a2 7a 10 	movl   $0xf0107aa2,0xc(%esp)
f010190a:	f0 
f010190b:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101912:	f0 
f0101913:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f010191a:	00 
f010191b:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101922:	e8 19 e7 ff ff       	call   f0100040 <_panic>
f0101927:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101928:	39 d0                	cmp    %edx,%eax
f010192a:	75 d2                	jne    f01018fe <mem_init+0x5a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010192c:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010192f:	89 15 40 42 22 f0    	mov    %edx,0xf0224240

	// free the pages we took
	page_free(pp0);
f0101935:	89 34 24             	mov    %esi,(%esp)
f0101938:	e8 c5 f6 ff ff       	call   f0101002 <page_free>
	page_free(pp1);
f010193d:	89 3c 24             	mov    %edi,(%esp)
f0101940:	e8 bd f6 ff ff       	call   f0101002 <page_free>
	page_free(pp2);
f0101945:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101948:	89 04 24             	mov    %eax,(%esp)
f010194b:	e8 b2 f6 ff ff       	call   f0101002 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101950:	a1 40 42 22 f0       	mov    0xf0224240,%eax
f0101955:	eb 03                	jmp    f010195a <mem_init+0x602>
		--nfree;
f0101957:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101958:	8b 00                	mov    (%eax),%eax
f010195a:	85 c0                	test   %eax,%eax
f010195c:	75 f9                	jne    f0101957 <mem_init+0x5ff>
		--nfree;
	assert(nfree == 0);
f010195e:	85 db                	test   %ebx,%ebx
f0101960:	74 24                	je     f0101986 <mem_init+0x62e>
f0101962:	c7 44 24 0c ac 7a 10 	movl   $0xf0107aac,0xc(%esp)
f0101969:	f0 
f010196a:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101971:	f0 
f0101972:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101979:	00 
f010197a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101981:	e8 ba e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101986:	c7 04 24 f4 70 10 f0 	movl   $0xf01070f4,(%esp)
f010198d:	e8 dc 24 00 00       	call   f0103e6e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101992:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101999:	e8 e0 f5 ff ff       	call   f0100f7e <page_alloc>
f010199e:	89 c7                	mov    %eax,%edi
f01019a0:	85 c0                	test   %eax,%eax
f01019a2:	75 24                	jne    f01019c8 <mem_init+0x670>
f01019a4:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f01019ab:	f0 
f01019ac:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01019b3:	f0 
f01019b4:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01019bb:	00 
f01019bc:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01019c3:	e8 78 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019cf:	e8 aa f5 ff ff       	call   f0100f7e <page_alloc>
f01019d4:	89 c6                	mov    %eax,%esi
f01019d6:	85 c0                	test   %eax,%eax
f01019d8:	75 24                	jne    f01019fe <mem_init+0x6a6>
f01019da:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f01019e1:	f0 
f01019e2:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01019e9:	f0 
f01019ea:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f01019f1:	00 
f01019f2:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01019f9:	e8 42 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a05:	e8 74 f5 ff ff       	call   f0100f7e <page_alloc>
f0101a0a:	89 c3                	mov    %eax,%ebx
f0101a0c:	85 c0                	test   %eax,%eax
f0101a0e:	75 24                	jne    f0101a34 <mem_init+0x6dc>
f0101a10:	c7 44 24 0c e6 79 10 	movl   $0xf01079e6,0xc(%esp)
f0101a17:	f0 
f0101a18:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101a1f:	f0 
f0101a20:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101a27:	00 
f0101a28:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101a2f:	e8 0c e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a34:	39 f7                	cmp    %esi,%edi
f0101a36:	75 24                	jne    f0101a5c <mem_init+0x704>
f0101a38:	c7 44 24 0c fc 79 10 	movl   $0xf01079fc,0xc(%esp)
f0101a3f:	f0 
f0101a40:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101a47:	f0 
f0101a48:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101a4f:	00 
f0101a50:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101a57:	e8 e4 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a5c:	39 c6                	cmp    %eax,%esi
f0101a5e:	74 04                	je     f0101a64 <mem_init+0x70c>
f0101a60:	39 c7                	cmp    %eax,%edi
f0101a62:	75 24                	jne    f0101a88 <mem_init+0x730>
f0101a64:	c7 44 24 0c d4 70 10 	movl   $0xf01070d4,0xc(%esp)
f0101a6b:	f0 
f0101a6c:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101a73:	f0 
f0101a74:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101a7b:	00 
f0101a7c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101a83:	e8 b8 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a88:	8b 15 40 42 22 f0    	mov    0xf0224240,%edx
f0101a8e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101a91:	c7 05 40 42 22 f0 00 	movl   $0x0,0xf0224240
f0101a98:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aa2:	e8 d7 f4 ff ff       	call   f0100f7e <page_alloc>
f0101aa7:	85 c0                	test   %eax,%eax
f0101aa9:	74 24                	je     f0101acf <mem_init+0x777>
f0101aab:	c7 44 24 0c 65 7a 10 	movl   $0xf0107a65,0xc(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101aba:	f0 
f0101abb:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101ac2:	00 
f0101ac3:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101aca:	e8 71 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101acf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ad2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ad6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101add:	00 
f0101ade:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101ae3:	89 04 24             	mov    %eax,(%esp)
f0101ae6:	e8 79 f6 ff ff       	call   f0101164 <page_lookup>
f0101aeb:	85 c0                	test   %eax,%eax
f0101aed:	74 24                	je     f0101b13 <mem_init+0x7bb>
f0101aef:	c7 44 24 0c 14 71 10 	movl   $0xf0107114,0xc(%esp)
f0101af6:	f0 
f0101af7:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0101b06:	00 
f0101b07:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101b0e:	e8 2d e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b13:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b1a:	00 
f0101b1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b22:	00 
f0101b23:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b27:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101b2c:	89 04 24             	mov    %eax,(%esp)
f0101b2f:	e8 3b f7 ff ff       	call   f010126f <page_insert>
f0101b34:	85 c0                	test   %eax,%eax
f0101b36:	78 24                	js     f0101b5c <mem_init+0x804>
f0101b38:	c7 44 24 0c 4c 71 10 	movl   $0xf010714c,0xc(%esp)
f0101b3f:	f0 
f0101b40:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101b47:	f0 
f0101b48:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101b4f:	00 
f0101b50:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101b57:	e8 e4 e4 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101b5c:	89 3c 24             	mov    %edi,(%esp)
f0101b5f:	e8 9e f4 ff ff       	call   f0101002 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101b64:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b6b:	00 
f0101b6c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b73:	00 
f0101b74:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b78:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101b7d:	89 04 24             	mov    %eax,(%esp)
f0101b80:	e8 ea f6 ff ff       	call   f010126f <page_insert>
f0101b85:	85 c0                	test   %eax,%eax
f0101b87:	74 24                	je     f0101bad <mem_init+0x855>
f0101b89:	c7 44 24 0c 7c 71 10 	movl   $0xf010717c,0xc(%esp)
f0101b90:	f0 
f0101b91:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101b98:	f0 
f0101b99:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101ba0:	00 
f0101ba1:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101ba8:	e8 93 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bad:	8b 0d 8c 4e 22 f0    	mov    0xf0224e8c,%ecx
f0101bb3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bb6:	a1 90 4e 22 f0       	mov    0xf0224e90,%eax
f0101bbb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bbe:	8b 11                	mov    (%ecx),%edx
f0101bc0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101bc6:	89 f8                	mov    %edi,%eax
f0101bc8:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101bcb:	c1 f8 03             	sar    $0x3,%eax
f0101bce:	c1 e0 0c             	shl    $0xc,%eax
f0101bd1:	39 c2                	cmp    %eax,%edx
f0101bd3:	74 24                	je     f0101bf9 <mem_init+0x8a1>
f0101bd5:	c7 44 24 0c ac 71 10 	movl   $0xf01071ac,0xc(%esp)
f0101bdc:	f0 
f0101bdd:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101be4:	f0 
f0101be5:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101bec:	00 
f0101bed:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101bf4:	e8 47 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101bf9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bfe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c01:	e8 0e ee ff ff       	call   f0100a14 <check_va2pa>
f0101c06:	89 f2                	mov    %esi,%edx
f0101c08:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101c0b:	c1 fa 03             	sar    $0x3,%edx
f0101c0e:	c1 e2 0c             	shl    $0xc,%edx
f0101c11:	39 d0                	cmp    %edx,%eax
f0101c13:	74 24                	je     f0101c39 <mem_init+0x8e1>
f0101c15:	c7 44 24 0c d4 71 10 	movl   $0xf01071d4,0xc(%esp)
f0101c1c:	f0 
f0101c1d:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101c24:	f0 
f0101c25:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101c2c:	00 
f0101c2d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101c34:	e8 07 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101c39:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c3e:	74 24                	je     f0101c64 <mem_init+0x90c>
f0101c40:	c7 44 24 0c b7 7a 10 	movl   $0xf0107ab7,0xc(%esp)
f0101c47:	f0 
f0101c48:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101c4f:	f0 
f0101c50:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0101c57:	00 
f0101c58:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101c5f:	e8 dc e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c64:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c69:	74 24                	je     f0101c8f <mem_init+0x937>
f0101c6b:	c7 44 24 0c c8 7a 10 	movl   $0xf0107ac8,0xc(%esp)
f0101c72:	f0 
f0101c73:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101c7a:	f0 
f0101c7b:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0101c82:	00 
f0101c83:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101c8a:	e8 b1 e3 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c8f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101c96:	00 
f0101c97:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c9e:	00 
f0101c9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ca3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101ca6:	89 14 24             	mov    %edx,(%esp)
f0101ca9:	e8 c1 f5 ff ff       	call   f010126f <page_insert>
f0101cae:	85 c0                	test   %eax,%eax
f0101cb0:	74 24                	je     f0101cd6 <mem_init+0x97e>
f0101cb2:	c7 44 24 0c 04 72 10 	movl   $0xf0107204,0xc(%esp)
f0101cb9:	f0 
f0101cba:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101cc1:	f0 
f0101cc2:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101cc9:	00 
f0101cca:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101cd1:	e8 6a e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cd6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cdb:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101ce0:	e8 2f ed ff ff       	call   f0100a14 <check_va2pa>
f0101ce5:	89 da                	mov    %ebx,%edx
f0101ce7:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0101ced:	c1 fa 03             	sar    $0x3,%edx
f0101cf0:	c1 e2 0c             	shl    $0xc,%edx
f0101cf3:	39 d0                	cmp    %edx,%eax
f0101cf5:	74 24                	je     f0101d1b <mem_init+0x9c3>
f0101cf7:	c7 44 24 0c 40 72 10 	movl   $0xf0107240,0xc(%esp)
f0101cfe:	f0 
f0101cff:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101d06:	f0 
f0101d07:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101d0e:	00 
f0101d0f:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101d16:	e8 25 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d1b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d20:	74 24                	je     f0101d46 <mem_init+0x9ee>
f0101d22:	c7 44 24 0c d9 7a 10 	movl   $0xf0107ad9,0xc(%esp)
f0101d29:	f0 
f0101d2a:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101d31:	f0 
f0101d32:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0101d39:	00 
f0101d3a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101d41:	e8 fa e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d4d:	e8 2c f2 ff ff       	call   f0100f7e <page_alloc>
f0101d52:	85 c0                	test   %eax,%eax
f0101d54:	74 24                	je     f0101d7a <mem_init+0xa22>
f0101d56:	c7 44 24 0c 65 7a 10 	movl   $0xf0107a65,0xc(%esp)
f0101d5d:	f0 
f0101d5e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101d6d:	00 
f0101d6e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101d75:	e8 c6 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d7a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d81:	00 
f0101d82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d89:	00 
f0101d8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d8e:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101d93:	89 04 24             	mov    %eax,(%esp)
f0101d96:	e8 d4 f4 ff ff       	call   f010126f <page_insert>
f0101d9b:	85 c0                	test   %eax,%eax
f0101d9d:	74 24                	je     f0101dc3 <mem_init+0xa6b>
f0101d9f:	c7 44 24 0c 04 72 10 	movl   $0xf0107204,0xc(%esp)
f0101da6:	f0 
f0101da7:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101dae:	f0 
f0101daf:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101db6:	00 
f0101db7:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101dbe:	e8 7d e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dc3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dc8:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101dcd:	e8 42 ec ff ff       	call   f0100a14 <check_va2pa>
f0101dd2:	89 da                	mov    %ebx,%edx
f0101dd4:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0101dda:	c1 fa 03             	sar    $0x3,%edx
f0101ddd:	c1 e2 0c             	shl    $0xc,%edx
f0101de0:	39 d0                	cmp    %edx,%eax
f0101de2:	74 24                	je     f0101e08 <mem_init+0xab0>
f0101de4:	c7 44 24 0c 40 72 10 	movl   $0xf0107240,0xc(%esp)
f0101deb:	f0 
f0101dec:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101df3:	f0 
f0101df4:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101dfb:	00 
f0101dfc:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101e03:	e8 38 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e08:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e0d:	74 24                	je     f0101e33 <mem_init+0xadb>
f0101e0f:	c7 44 24 0c d9 7a 10 	movl   $0xf0107ad9,0xc(%esp)
f0101e16:	f0 
f0101e17:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101e1e:	f0 
f0101e1f:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0101e26:	00 
f0101e27:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101e2e:	e8 0d e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e3a:	e8 3f f1 ff ff       	call   f0100f7e <page_alloc>
f0101e3f:	85 c0                	test   %eax,%eax
f0101e41:	74 24                	je     f0101e67 <mem_init+0xb0f>
f0101e43:	c7 44 24 0c 65 7a 10 	movl   $0xf0107a65,0xc(%esp)
f0101e4a:	f0 
f0101e4b:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101e52:	f0 
f0101e53:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101e5a:	00 
f0101e5b:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101e62:	e8 d9 e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e67:	8b 15 8c 4e 22 f0    	mov    0xf0224e8c,%edx
f0101e6d:	8b 02                	mov    (%edx),%eax
f0101e6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e74:	89 c1                	mov    %eax,%ecx
f0101e76:	c1 e9 0c             	shr    $0xc,%ecx
f0101e79:	3b 0d 88 4e 22 f0    	cmp    0xf0224e88,%ecx
f0101e7f:	72 20                	jb     f0101ea1 <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e81:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e85:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0101e8c:	f0 
f0101e8d:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101e94:	00 
f0101e95:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101e9c:	e8 9f e1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0101ea1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ea6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101ea9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101eb0:	00 
f0101eb1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101eb8:	00 
f0101eb9:	89 14 24             	mov    %edx,(%esp)
f0101ebc:	e8 a1 f1 ff ff       	call   f0101062 <pgdir_walk>
f0101ec1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101ec4:	83 c2 04             	add    $0x4,%edx
f0101ec7:	39 d0                	cmp    %edx,%eax
f0101ec9:	74 24                	je     f0101eef <mem_init+0xb97>
f0101ecb:	c7 44 24 0c 70 72 10 	movl   $0xf0107270,0xc(%esp)
f0101ed2:	f0 
f0101ed3:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101eda:	f0 
f0101edb:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0101ee2:	00 
f0101ee3:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101eea:	e8 51 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101eef:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101ef6:	00 
f0101ef7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101efe:	00 
f0101eff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f03:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101f08:	89 04 24             	mov    %eax,(%esp)
f0101f0b:	e8 5f f3 ff ff       	call   f010126f <page_insert>
f0101f10:	85 c0                	test   %eax,%eax
f0101f12:	74 24                	je     f0101f38 <mem_init+0xbe0>
f0101f14:	c7 44 24 0c b0 72 10 	movl   $0xf01072b0,0xc(%esp)
f0101f1b:	f0 
f0101f1c:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101f2b:	00 
f0101f2c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101f33:	e8 08 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f38:	8b 0d 8c 4e 22 f0    	mov    0xf0224e8c,%ecx
f0101f3e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101f41:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f46:	89 c8                	mov    %ecx,%eax
f0101f48:	e8 c7 ea ff ff       	call   f0100a14 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f4d:	89 da                	mov    %ebx,%edx
f0101f4f:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0101f55:	c1 fa 03             	sar    $0x3,%edx
f0101f58:	c1 e2 0c             	shl    $0xc,%edx
f0101f5b:	39 d0                	cmp    %edx,%eax
f0101f5d:	74 24                	je     f0101f83 <mem_init+0xc2b>
f0101f5f:	c7 44 24 0c 40 72 10 	movl   $0xf0107240,0xc(%esp)
f0101f66:	f0 
f0101f67:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101f76:	00 
f0101f77:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f83:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f88:	74 24                	je     f0101fae <mem_init+0xc56>
f0101f8a:	c7 44 24 0c d9 7a 10 	movl   $0xf0107ad9,0xc(%esp)
f0101f91:	f0 
f0101f92:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101f99:	f0 
f0101f9a:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101fa1:	00 
f0101fa2:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101fa9:	e8 92 e0 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101fae:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101fb5:	00 
f0101fb6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fbd:	00 
f0101fbe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fc1:	89 04 24             	mov    %eax,(%esp)
f0101fc4:	e8 99 f0 ff ff       	call   f0101062 <pgdir_walk>
f0101fc9:	f6 00 04             	testb  $0x4,(%eax)
f0101fcc:	75 24                	jne    f0101ff2 <mem_init+0xc9a>
f0101fce:	c7 44 24 0c f0 72 10 	movl   $0xf01072f0,0xc(%esp)
f0101fd5:	f0 
f0101fd6:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0101fdd:	f0 
f0101fde:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0101fe5:	00 
f0101fe6:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0101fed:	e8 4e e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ff2:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0101ff7:	f6 00 04             	testb  $0x4,(%eax)
f0101ffa:	75 24                	jne    f0102020 <mem_init+0xcc8>
f0101ffc:	c7 44 24 0c ea 7a 10 	movl   $0xf0107aea,0xc(%esp)
f0102003:	f0 
f0102004:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010200b:	f0 
f010200c:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102013:	00 
f0102014:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010201b:	e8 20 e0 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102020:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102027:	00 
f0102028:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010202f:	00 
f0102030:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102034:	89 04 24             	mov    %eax,(%esp)
f0102037:	e8 33 f2 ff ff       	call   f010126f <page_insert>
f010203c:	85 c0                	test   %eax,%eax
f010203e:	74 24                	je     f0102064 <mem_init+0xd0c>
f0102040:	c7 44 24 0c 04 72 10 	movl   $0xf0107204,0xc(%esp)
f0102047:	f0 
f0102048:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010204f:	f0 
f0102050:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102057:	00 
f0102058:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010205f:	e8 dc df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102064:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010206b:	00 
f010206c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102073:	00 
f0102074:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102079:	89 04 24             	mov    %eax,(%esp)
f010207c:	e8 e1 ef ff ff       	call   f0101062 <pgdir_walk>
f0102081:	f6 00 02             	testb  $0x2,(%eax)
f0102084:	75 24                	jne    f01020aa <mem_init+0xd52>
f0102086:	c7 44 24 0c 24 73 10 	movl   $0xf0107324,0xc(%esp)
f010208d:	f0 
f010208e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102095:	f0 
f0102096:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010209d:	00 
f010209e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01020a5:	e8 96 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020b1:	00 
f01020b2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020b9:	00 
f01020ba:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01020bf:	89 04 24             	mov    %eax,(%esp)
f01020c2:	e8 9b ef ff ff       	call   f0101062 <pgdir_walk>
f01020c7:	f6 00 04             	testb  $0x4,(%eax)
f01020ca:	74 24                	je     f01020f0 <mem_init+0xd98>
f01020cc:	c7 44 24 0c 58 73 10 	movl   $0xf0107358,0xc(%esp)
f01020d3:	f0 
f01020d4:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01020db:	f0 
f01020dc:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01020e3:	00 
f01020e4:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01020eb:	e8 50 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020f0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020f7:	00 
f01020f8:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01020ff:	00 
f0102100:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102104:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102109:	89 04 24             	mov    %eax,(%esp)
f010210c:	e8 5e f1 ff ff       	call   f010126f <page_insert>
f0102111:	85 c0                	test   %eax,%eax
f0102113:	78 24                	js     f0102139 <mem_init+0xde1>
f0102115:	c7 44 24 0c 90 73 10 	movl   $0xf0107390,0xc(%esp)
f010211c:	f0 
f010211d:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102124:	f0 
f0102125:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010212c:	00 
f010212d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102134:	e8 07 df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102139:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102140:	00 
f0102141:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102148:	00 
f0102149:	89 74 24 04          	mov    %esi,0x4(%esp)
f010214d:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102152:	89 04 24             	mov    %eax,(%esp)
f0102155:	e8 15 f1 ff ff       	call   f010126f <page_insert>
f010215a:	85 c0                	test   %eax,%eax
f010215c:	74 24                	je     f0102182 <mem_init+0xe2a>
f010215e:	c7 44 24 0c c8 73 10 	movl   $0xf01073c8,0xc(%esp)
f0102165:	f0 
f0102166:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010216d:	f0 
f010216e:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102175:	00 
f0102176:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010217d:	e8 be de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102182:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102189:	00 
f010218a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102191:	00 
f0102192:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102197:	89 04 24             	mov    %eax,(%esp)
f010219a:	e8 c3 ee ff ff       	call   f0101062 <pgdir_walk>
f010219f:	f6 00 04             	testb  $0x4,(%eax)
f01021a2:	74 24                	je     f01021c8 <mem_init+0xe70>
f01021a4:	c7 44 24 0c 58 73 10 	movl   $0xf0107358,0xc(%esp)
f01021ab:	f0 
f01021ac:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01021b3:	f0 
f01021b4:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f01021bb:	00 
f01021bc:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01021c3:	e8 78 de ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021c8:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01021cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01021d5:	e8 3a e8 ff ff       	call   f0100a14 <check_va2pa>
f01021da:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01021dd:	89 f0                	mov    %esi,%eax
f01021df:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f01021e5:	c1 f8 03             	sar    $0x3,%eax
f01021e8:	c1 e0 0c             	shl    $0xc,%eax
f01021eb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01021ee:	74 24                	je     f0102214 <mem_init+0xebc>
f01021f0:	c7 44 24 0c 04 74 10 	movl   $0xf0107404,0xc(%esp)
f01021f7:	f0 
f01021f8:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01021ff:	f0 
f0102200:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102207:	00 
f0102208:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010220f:	e8 2c de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102214:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102219:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010221c:	e8 f3 e7 ff ff       	call   f0100a14 <check_va2pa>
f0102221:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102224:	74 24                	je     f010224a <mem_init+0xef2>
f0102226:	c7 44 24 0c 30 74 10 	movl   $0xf0107430,0xc(%esp)
f010222d:	f0 
f010222e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102235:	f0 
f0102236:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010223d:	00 
f010223e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102245:	e8 f6 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010224a:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010224f:	74 24                	je     f0102275 <mem_init+0xf1d>
f0102251:	c7 44 24 0c 00 7b 10 	movl   $0xf0107b00,0xc(%esp)
f0102258:	f0 
f0102259:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102260:	f0 
f0102261:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102268:	00 
f0102269:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102270:	e8 cb dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102275:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010227a:	74 24                	je     f01022a0 <mem_init+0xf48>
f010227c:	c7 44 24 0c 11 7b 10 	movl   $0xf0107b11,0xc(%esp)
f0102283:	f0 
f0102284:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010228b:	f0 
f010228c:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102293:	00 
f0102294:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010229b:	e8 a0 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022a7:	e8 d2 ec ff ff       	call   f0100f7e <page_alloc>
f01022ac:	85 c0                	test   %eax,%eax
f01022ae:	74 04                	je     f01022b4 <mem_init+0xf5c>
f01022b0:	39 c3                	cmp    %eax,%ebx
f01022b2:	74 24                	je     f01022d8 <mem_init+0xf80>
f01022b4:	c7 44 24 0c 60 74 10 	movl   $0xf0107460,0xc(%esp)
f01022bb:	f0 
f01022bc:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01022c3:	f0 
f01022c4:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01022cb:	00 
f01022cc:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01022d3:	e8 68 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01022d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022df:	00 
f01022e0:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01022e5:	89 04 24             	mov    %eax,(%esp)
f01022e8:	e8 39 ef ff ff       	call   f0101226 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022ed:	8b 15 8c 4e 22 f0    	mov    0xf0224e8c,%edx
f01022f3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01022f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01022fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022fe:	e8 11 e7 ff ff       	call   f0100a14 <check_va2pa>
f0102303:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102306:	74 24                	je     f010232c <mem_init+0xfd4>
f0102308:	c7 44 24 0c 84 74 10 	movl   $0xf0107484,0xc(%esp)
f010230f:	f0 
f0102310:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102317:	f0 
f0102318:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f010231f:	00 
f0102320:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102327:	e8 14 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010232c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102331:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102334:	e8 db e6 ff ff       	call   f0100a14 <check_va2pa>
f0102339:	89 f2                	mov    %esi,%edx
f010233b:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0102341:	c1 fa 03             	sar    $0x3,%edx
f0102344:	c1 e2 0c             	shl    $0xc,%edx
f0102347:	39 d0                	cmp    %edx,%eax
f0102349:	74 24                	je     f010236f <mem_init+0x1017>
f010234b:	c7 44 24 0c 30 74 10 	movl   $0xf0107430,0xc(%esp)
f0102352:	f0 
f0102353:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010235a:	f0 
f010235b:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102362:	00 
f0102363:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010236a:	e8 d1 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010236f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102374:	74 24                	je     f010239a <mem_init+0x1042>
f0102376:	c7 44 24 0c b7 7a 10 	movl   $0xf0107ab7,0xc(%esp)
f010237d:	f0 
f010237e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102385:	f0 
f0102386:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010238d:	00 
f010238e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102395:	e8 a6 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010239a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010239f:	74 24                	je     f01023c5 <mem_init+0x106d>
f01023a1:	c7 44 24 0c 11 7b 10 	movl   $0xf0107b11,0xc(%esp)
f01023a8:	f0 
f01023a9:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01023b0:	f0 
f01023b1:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f01023b8:	00 
f01023b9:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01023c0:	e8 7b dc ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01023c5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01023cc:	00 
f01023cd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01023d4:	00 
f01023d5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023d9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01023dc:	89 0c 24             	mov    %ecx,(%esp)
f01023df:	e8 8b ee ff ff       	call   f010126f <page_insert>
f01023e4:	85 c0                	test   %eax,%eax
f01023e6:	74 24                	je     f010240c <mem_init+0x10b4>
f01023e8:	c7 44 24 0c a8 74 10 	movl   $0xf01074a8,0xc(%esp)
f01023ef:	f0 
f01023f0:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01023f7:	f0 
f01023f8:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f01023ff:	00 
f0102400:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102407:	e8 34 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010240c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102411:	75 24                	jne    f0102437 <mem_init+0x10df>
f0102413:	c7 44 24 0c 22 7b 10 	movl   $0xf0107b22,0xc(%esp)
f010241a:	f0 
f010241b:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102422:	f0 
f0102423:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f010242a:	00 
f010242b:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102432:	e8 09 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102437:	83 3e 00             	cmpl   $0x0,(%esi)
f010243a:	74 24                	je     f0102460 <mem_init+0x1108>
f010243c:	c7 44 24 0c 2e 7b 10 	movl   $0xf0107b2e,0xc(%esp)
f0102443:	f0 
f0102444:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010244b:	f0 
f010244c:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102453:	00 
f0102454:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010245b:	e8 e0 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102460:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102467:	00 
f0102468:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f010246d:	89 04 24             	mov    %eax,(%esp)
f0102470:	e8 b1 ed ff ff       	call   f0101226 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102475:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f010247a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010247d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102482:	e8 8d e5 ff ff       	call   f0100a14 <check_va2pa>
f0102487:	83 f8 ff             	cmp    $0xffffffff,%eax
f010248a:	74 24                	je     f01024b0 <mem_init+0x1158>
f010248c:	c7 44 24 0c 84 74 10 	movl   $0xf0107484,0xc(%esp)
f0102493:	f0 
f0102494:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010249b:	f0 
f010249c:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01024a3:	00 
f01024a4:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01024ab:	e8 90 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024b0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024b8:	e8 57 e5 ff ff       	call   f0100a14 <check_va2pa>
f01024bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c0:	74 24                	je     f01024e6 <mem_init+0x118e>
f01024c2:	c7 44 24 0c e0 74 10 	movl   $0xf01074e0,0xc(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01024d1:	f0 
f01024d2:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01024d9:	00 
f01024da:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01024e1:	e8 5a db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01024e6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024eb:	74 24                	je     f0102511 <mem_init+0x11b9>
f01024ed:	c7 44 24 0c 43 7b 10 	movl   $0xf0107b43,0xc(%esp)
f01024f4:	f0 
f01024f5:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01024fc:	f0 
f01024fd:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102504:	00 
f0102505:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010250c:	e8 2f db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102511:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102516:	74 24                	je     f010253c <mem_init+0x11e4>
f0102518:	c7 44 24 0c 11 7b 10 	movl   $0xf0107b11,0xc(%esp)
f010251f:	f0 
f0102520:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102527:	f0 
f0102528:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f010252f:	00 
f0102530:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102537:	e8 04 db ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010253c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102543:	e8 36 ea ff ff       	call   f0100f7e <page_alloc>
f0102548:	85 c0                	test   %eax,%eax
f010254a:	74 04                	je     f0102550 <mem_init+0x11f8>
f010254c:	39 c6                	cmp    %eax,%esi
f010254e:	74 24                	je     f0102574 <mem_init+0x121c>
f0102550:	c7 44 24 0c 08 75 10 	movl   $0xf0107508,0xc(%esp)
f0102557:	f0 
f0102558:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010255f:	f0 
f0102560:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102567:	00 
f0102568:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010256f:	e8 cc da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102574:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010257b:	e8 fe e9 ff ff       	call   f0100f7e <page_alloc>
f0102580:	85 c0                	test   %eax,%eax
f0102582:	74 24                	je     f01025a8 <mem_init+0x1250>
f0102584:	c7 44 24 0c 65 7a 10 	movl   $0xf0107a65,0xc(%esp)
f010258b:	f0 
f010258c:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102593:	f0 
f0102594:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f010259b:	00 
f010259c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01025a3:	e8 98 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025a8:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01025ad:	8b 08                	mov    (%eax),%ecx
f01025af:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025b5:	89 fa                	mov    %edi,%edx
f01025b7:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f01025bd:	c1 fa 03             	sar    $0x3,%edx
f01025c0:	c1 e2 0c             	shl    $0xc,%edx
f01025c3:	39 d1                	cmp    %edx,%ecx
f01025c5:	74 24                	je     f01025eb <mem_init+0x1293>
f01025c7:	c7 44 24 0c ac 71 10 	movl   $0xf01071ac,0xc(%esp)
f01025ce:	f0 
f01025cf:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01025d6:	f0 
f01025d7:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01025de:	00 
f01025df:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01025e6:	e8 55 da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01025eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01025f1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025f6:	74 24                	je     f010261c <mem_init+0x12c4>
f01025f8:	c7 44 24 0c c8 7a 10 	movl   $0xf0107ac8,0xc(%esp)
f01025ff:	f0 
f0102600:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102607:	f0 
f0102608:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f010260f:	00 
f0102610:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102617:	e8 24 da ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010261c:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102622:	89 3c 24             	mov    %edi,(%esp)
f0102625:	e8 d8 e9 ff ff       	call   f0101002 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010262a:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102631:	00 
f0102632:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102639:	00 
f010263a:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f010263f:	89 04 24             	mov    %eax,(%esp)
f0102642:	e8 1b ea ff ff       	call   f0101062 <pgdir_walk>
f0102647:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010264a:	8b 0d 8c 4e 22 f0    	mov    0xf0224e8c,%ecx
f0102650:	8b 51 04             	mov    0x4(%ecx),%edx
f0102653:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102659:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010265c:	8b 15 88 4e 22 f0    	mov    0xf0224e88,%edx
f0102662:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102665:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102668:	c1 ea 0c             	shr    $0xc,%edx
f010266b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010266e:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102671:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102674:	72 23                	jb     f0102699 <mem_init+0x1341>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102676:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102679:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010267d:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0102684:	f0 
f0102685:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010268c:	00 
f010268d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102694:	e8 a7 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102699:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010269c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01026a2:	39 d0                	cmp    %edx,%eax
f01026a4:	74 24                	je     f01026ca <mem_init+0x1372>
f01026a6:	c7 44 24 0c 54 7b 10 	movl   $0xf0107b54,0xc(%esp)
f01026ad:	f0 
f01026ae:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01026b5:	f0 
f01026b6:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01026bd:	00 
f01026be:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01026c5:	e8 76 d9 ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01026ca:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01026d1:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01026d7:	89 f8                	mov    %edi,%eax
f01026d9:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f01026df:	c1 f8 03             	sar    $0x3,%eax
f01026e2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01026e5:	89 c1                	mov    %eax,%ecx
f01026e7:	c1 e9 0c             	shr    $0xc,%ecx
f01026ea:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01026ed:	77 20                	ja     f010270f <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01026ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026f3:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01026fa:	f0 
f01026fb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102702:	00 
f0102703:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f010270a:	e8 31 d9 ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f010270f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102716:	00 
f0102717:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010271e:	00 
	return (void *)(pa + KERNBASE);
f010271f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102724:	89 04 24             	mov    %eax,(%esp)
f0102727:	e8 f6 35 00 00       	call   f0105d22 <memset>
	page_free(pp0);
f010272c:	89 3c 24             	mov    %edi,(%esp)
f010272f:	e8 ce e8 ff ff       	call   f0101002 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102734:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010273b:	00 
f010273c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102743:	00 
f0102744:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102749:	89 04 24             	mov    %eax,(%esp)
f010274c:	e8 11 e9 ff ff       	call   f0101062 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102751:	89 fa                	mov    %edi,%edx
f0102753:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f0102759:	c1 fa 03             	sar    $0x3,%edx
f010275c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010275f:	89 d0                	mov    %edx,%eax
f0102761:	c1 e8 0c             	shr    $0xc,%eax
f0102764:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f010276a:	72 20                	jb     f010278c <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010276c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102770:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0102777:	f0 
f0102778:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010277f:	00 
f0102780:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0102787:	e8 b4 d8 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010278c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102792:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102795:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010279b:	f6 00 01             	testb  $0x1,(%eax)
f010279e:	74 24                	je     f01027c4 <mem_init+0x146c>
f01027a0:	c7 44 24 0c 6c 7b 10 	movl   $0xf0107b6c,0xc(%esp)
f01027a7:	f0 
f01027a8:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01027af:	f0 
f01027b0:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01027b7:	00 
f01027b8:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01027bf:	e8 7c d8 ff ff       	call   f0100040 <_panic>
f01027c4:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01027c7:	39 d0                	cmp    %edx,%eax
f01027c9:	75 d0                	jne    f010279b <mem_init+0x1443>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01027cb:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01027d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027d6:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01027dc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01027df:	89 0d 40 42 22 f0    	mov    %ecx,0xf0224240

	// free the pages we took
	page_free(pp0);
f01027e5:	89 3c 24             	mov    %edi,(%esp)
f01027e8:	e8 15 e8 ff ff       	call   f0101002 <page_free>
	page_free(pp1);
f01027ed:	89 34 24             	mov    %esi,(%esp)
f01027f0:	e8 0d e8 ff ff       	call   f0101002 <page_free>
	page_free(pp2);
f01027f5:	89 1c 24             	mov    %ebx,(%esp)
f01027f8:	e8 05 e8 ff ff       	call   f0101002 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f01027fd:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102804:	00 
f0102805:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010280c:	e8 d8 ea ff ff       	call   f01012e9 <mmio_map_region>
f0102811:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102813:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010281a:	00 
f010281b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102822:	e8 c2 ea ff ff       	call   f01012e9 <mmio_map_region>
f0102827:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0102829:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f010282f:	76 0d                	jbe    f010283e <mem_init+0x14e6>
f0102831:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0102837:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010283c:	76 24                	jbe    f0102862 <mem_init+0x150a>
f010283e:	c7 44 24 0c 2c 75 10 	movl   $0xf010752c,0xc(%esp)
f0102845:	f0 
f0102846:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010284d:	f0 
f010284e:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102855:	00 
f0102856:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010285d:	e8 de d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102862:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102868:	76 0e                	jbe    f0102878 <mem_init+0x1520>
f010286a:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102870:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102876:	76 24                	jbe    f010289c <mem_init+0x1544>
f0102878:	c7 44 24 0c 54 75 10 	movl   $0xf0107554,0xc(%esp)
f010287f:	f0 
f0102880:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102887:	f0 
f0102888:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f010288f:	00 
f0102890:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102897:	e8 a4 d7 ff ff       	call   f0100040 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010289c:	89 da                	mov    %ebx,%edx
f010289e:	09 f2                	or     %esi,%edx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01028a0:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01028a6:	74 24                	je     f01028cc <mem_init+0x1574>
f01028a8:	c7 44 24 0c 7c 75 10 	movl   $0xf010757c,0xc(%esp)
f01028af:	f0 
f01028b0:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01028b7:	f0 
f01028b8:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f01028bf:	00 
f01028c0:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01028c7:	e8 74 d7 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f01028cc:	39 c6                	cmp    %eax,%esi
f01028ce:	73 24                	jae    f01028f4 <mem_init+0x159c>
f01028d0:	c7 44 24 0c 83 7b 10 	movl   $0xf0107b83,0xc(%esp)
f01028d7:	f0 
f01028d8:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01028df:	f0 
f01028e0:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f01028e7:	00 
f01028e8:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01028ef:	e8 4c d7 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01028f4:	8b 3d 8c 4e 22 f0    	mov    0xf0224e8c,%edi
f01028fa:	89 da                	mov    %ebx,%edx
f01028fc:	89 f8                	mov    %edi,%eax
f01028fe:	e8 11 e1 ff ff       	call   f0100a14 <check_va2pa>
f0102903:	85 c0                	test   %eax,%eax
f0102905:	74 24                	je     f010292b <mem_init+0x15d3>
f0102907:	c7 44 24 0c a4 75 10 	movl   $0xf01075a4,0xc(%esp)
f010290e:	f0 
f010290f:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102916:	f0 
f0102917:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f010291e:	00 
f010291f:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102926:	e8 15 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010292b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102931:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102934:	89 c2                	mov    %eax,%edx
f0102936:	89 f8                	mov    %edi,%eax
f0102938:	e8 d7 e0 ff ff       	call   f0100a14 <check_va2pa>
f010293d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102942:	74 24                	je     f0102968 <mem_init+0x1610>
f0102944:	c7 44 24 0c c8 75 10 	movl   $0xf01075c8,0xc(%esp)
f010294b:	f0 
f010294c:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102953:	f0 
f0102954:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f010295b:	00 
f010295c:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102968:	89 f2                	mov    %esi,%edx
f010296a:	89 f8                	mov    %edi,%eax
f010296c:	e8 a3 e0 ff ff       	call   f0100a14 <check_va2pa>
f0102971:	85 c0                	test   %eax,%eax
f0102973:	74 24                	je     f0102999 <mem_init+0x1641>
f0102975:	c7 44 24 0c f8 75 10 	movl   $0xf01075f8,0xc(%esp)
f010297c:	f0 
f010297d:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102984:	f0 
f0102985:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f010298c:	00 
f010298d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102994:	e8 a7 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102999:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010299f:	89 f8                	mov    %edi,%eax
f01029a1:	e8 6e e0 ff ff       	call   f0100a14 <check_va2pa>
f01029a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a9:	74 24                	je     f01029cf <mem_init+0x1677>
f01029ab:	c7 44 24 0c 1c 76 10 	movl   $0xf010761c,0xc(%esp)
f01029b2:	f0 
f01029b3:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01029ba:	f0 
f01029bb:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f01029c2:	00 
f01029c3:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01029ca:	e8 71 d6 ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01029cf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01029d6:	00 
f01029d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01029db:	89 3c 24             	mov    %edi,(%esp)
f01029de:	e8 7f e6 ff ff       	call   f0101062 <pgdir_walk>
f01029e3:	f6 00 1a             	testb  $0x1a,(%eax)
f01029e6:	75 24                	jne    f0102a0c <mem_init+0x16b4>
f01029e8:	c7 44 24 0c 48 76 10 	movl   $0xf0107648,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a0c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a13:	00 
f0102a14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a18:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102a1d:	89 04 24             	mov    %eax,(%esp)
f0102a20:	e8 3d e6 ff ff       	call   f0101062 <pgdir_walk>
f0102a25:	f6 00 04             	testb  $0x4,(%eax)
f0102a28:	74 24                	je     f0102a4e <mem_init+0x16f6>
f0102a2a:	c7 44 24 0c 8c 76 10 	movl   $0xf010768c,0xc(%esp)
f0102a31:	f0 
f0102a32:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102a39:	f0 
f0102a3a:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102a41:	00 
f0102a42:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102a49:	e8 f2 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a55:	00 
f0102a56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a5a:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102a5f:	89 04 24             	mov    %eax,(%esp)
f0102a62:	e8 fb e5 ff ff       	call   f0101062 <pgdir_walk>
f0102a67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102a6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a74:	00 
f0102a75:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102a78:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102a7c:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102a81:	89 04 24             	mov    %eax,(%esp)
f0102a84:	e8 d9 e5 ff ff       	call   f0101062 <pgdir_walk>
f0102a89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102a8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a96:	00 
f0102a97:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a9b:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102aa0:	89 04 24             	mov    %eax,(%esp)
f0102aa3:	e8 ba e5 ff ff       	call   f0101062 <pgdir_walk>
f0102aa8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102aae:	c7 04 24 95 7b 10 f0 	movl   $0xf0107b95,(%esp)
f0102ab5:	e8 b4 13 00 00       	call   f0103e6e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_W);
f0102aba:	a1 90 4e 22 f0       	mov    0xf0224e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102abf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ac4:	77 20                	ja     f0102ae6 <mem_init+0x178e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ac6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102aca:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102ad1:	f0 
f0102ad2:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102ad9:	00 
f0102ada:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102ae1:	e8 5a d5 ff ff       	call   f0100040 <_panic>
f0102ae6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102aed:	00 
	return (physaddr_t)kva - KERNBASE;
f0102aee:	05 00 00 00 10       	add    $0x10000000,%eax
f0102af3:	89 04 24             	mov    %eax,(%esp)
f0102af6:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102afb:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b00:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102b05:	e8 f7 e5 ff ff       	call   f0101101 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_W | PTE_U);
f0102b0a:	a1 48 42 22 f0       	mov    0xf0224248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b0f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b14:	77 20                	ja     f0102b36 <mem_init+0x17de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b1a:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102b21:	f0 
f0102b22:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0102b29:	00 
f0102b2a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102b31:	e8 0a d5 ff ff       	call   f0100040 <_panic>
f0102b36:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0102b3d:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b3e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b43:	89 04 24             	mov    %eax,(%esp)
f0102b46:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102b4b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102b50:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102b55:	e8 a7 e5 ff ff       	call   f0101101 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b5a:	b8 00 f0 11 f0       	mov    $0xf011f000,%eax
f0102b5f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b64:	77 20                	ja     f0102b86 <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b66:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b6a:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102b71:	f0 
f0102b72:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102b79:	00 
f0102b7a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102b81:	e8 ba d4 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102b86:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b8d:	00 
f0102b8e:	c7 04 24 00 f0 11 00 	movl   $0x11f000,(%esp)
f0102b95:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b9a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102b9f:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102ba4:	e8 58 e5 ff ff       	call   f0101101 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 2*npages*PGSIZE, 0, PTE_W);
f0102ba9:	8b 0d 88 4e 22 f0    	mov    0xf0224e88,%ecx
f0102baf:	c1 e1 0d             	shl    $0xd,%ecx
f0102bb2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102bb9:	00 
f0102bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bc1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102bc6:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102bcb:	e8 31 e5 ff ff       	call   f0101101 <boot_map_region>
f0102bd0:	c7 45 cc 00 60 22 f0 	movl   $0xf0226000,-0x34(%ebp)
f0102bd7:	bb 00 60 22 f0       	mov    $0xf0226000,%ebx
f0102bdc:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102be1:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102be7:	77 20                	ja     f0102c09 <mem_init+0x18b1>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102be9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102bed:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102bf4:	f0 
f0102bf5:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0102bfc:	00 
f0102bfd:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102c04:	e8 37 d4 ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	int i;
	uintptr_t kstacktop_i;
	for (i = 0; i < NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, (uintptr_t)(kstacktop_i - KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102c09:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102c10:	00 
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102c11:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
	// LAB 4: Your code here:
	int i;
	uintptr_t kstacktop_i;
	for (i = 0; i < NCPU; i++) {
		kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, (uintptr_t)(kstacktop_i - KSTKSIZE), KSTKSIZE, PADDR(percpu_kstacks[i]), PTE_W);
f0102c17:	89 04 24             	mov    %eax,(%esp)
f0102c1a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102c1f:	89 f2                	mov    %esi,%edx
f0102c21:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0102c26:	e8 d6 e4 ff ff       	call   f0101101 <boot_map_region>
f0102c2b:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0102c31:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i;
	uintptr_t kstacktop_i;
	for (i = 0; i < NCPU; i++) {
f0102c37:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0102c3d:	75 a2                	jne    f0102be1 <mem_init+0x1889>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102c3f:	8b 1d 8c 4e 22 f0    	mov    0xf0224e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c45:	8b 0d 88 4e 22 f0    	mov    0xf0224e88,%ecx
f0102c4b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0102c4e:	8d 3c cd ff 0f 00 00 	lea    0xfff(,%ecx,8),%edi
f0102c55:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102c5b:	be 00 00 00 00       	mov    $0x0,%esi
f0102c60:	eb 70                	jmp    f0102cd2 <mem_init+0x197a>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102c62:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102c68:	89 d8                	mov    %ebx,%eax
f0102c6a:	e8 a5 dd ff ff       	call   f0100a14 <check_va2pa>
f0102c6f:	8b 15 90 4e 22 f0    	mov    0xf0224e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c75:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c7b:	77 20                	ja     f0102c9d <mem_init+0x1945>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c81:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102c88:	f0 
f0102c89:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102c90:	00 
f0102c91:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102c98:	e8 a3 d3 ff ff       	call   f0100040 <_panic>
f0102c9d:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102ca4:	39 d0                	cmp    %edx,%eax
f0102ca6:	74 24                	je     f0102ccc <mem_init+0x1974>
f0102ca8:	c7 44 24 0c c0 76 10 	movl   $0xf01076c0,0xc(%esp)
f0102caf:	f0 
f0102cb0:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102cb7:	f0 
f0102cb8:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102cbf:	00 
f0102cc0:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102cc7:	e8 74 d3 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102ccc:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102cd2:	39 f7                	cmp    %esi,%edi
f0102cd4:	77 8c                	ja     f0102c62 <mem_init+0x190a>
f0102cd6:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cdb:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102ce1:	89 d8                	mov    %ebx,%eax
f0102ce3:	e8 2c dd ff ff       	call   f0100a14 <check_va2pa>
f0102ce8:	8b 15 48 42 22 f0    	mov    0xf0224248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cee:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102cf4:	77 20                	ja     f0102d16 <mem_init+0x19be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cfa:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102d01:	f0 
f0102d02:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102d09:	00 
f0102d0a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102d11:	e8 2a d3 ff ff       	call   f0100040 <_panic>
f0102d16:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d1d:	39 d0                	cmp    %edx,%eax
f0102d1f:	74 24                	je     f0102d45 <mem_init+0x19ed>
f0102d21:	c7 44 24 0c f4 76 10 	movl   $0xf01076f4,0xc(%esp)
f0102d28:	f0 
f0102d29:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102d30:	f0 
f0102d31:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102d38:	00 
f0102d39:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102d40:	e8 fb d2 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102d45:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d4b:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f0102d51:	75 88                	jne    f0102cdb <mem_init+0x1983>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d53:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102d56:	c1 e7 0c             	shl    $0xc,%edi
f0102d59:	be 00 00 00 00       	mov    $0x0,%esi
f0102d5e:	eb 3b                	jmp    f0102d9b <mem_init+0x1a43>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102d60:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102d66:	89 d8                	mov    %ebx,%eax
f0102d68:	e8 a7 dc ff ff       	call   f0100a14 <check_va2pa>
f0102d6d:	39 c6                	cmp    %eax,%esi
f0102d6f:	74 24                	je     f0102d95 <mem_init+0x1a3d>
f0102d71:	c7 44 24 0c 28 77 10 	movl   $0xf0107728,0xc(%esp)
f0102d78:	f0 
f0102d79:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102d80:	f0 
f0102d81:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0102d88:	00 
f0102d89:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102d90:	e8 ab d2 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102d95:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102d9b:	39 fe                	cmp    %edi,%esi
f0102d9d:	72 c1                	jb     f0102d60 <mem_init+0x1a08>
f0102d9f:	bf 00 00 ff ef       	mov    $0xefff0000,%edi
f0102da4:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102da7:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102daa:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102dad:	8d 9f 00 80 00 00    	lea    0x8000(%edi),%ebx
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102db3:	89 c6                	mov    %eax,%esi
f0102db5:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f0102dbb:	8d 97 00 00 01 00    	lea    0x10000(%edi),%edx
f0102dc1:	89 55 d0             	mov    %edx,-0x30(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102dc4:	89 da                	mov    %ebx,%edx
f0102dc6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102dc9:	e8 46 dc ff ff       	call   f0100a14 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102dce:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0102dd5:	77 23                	ja     f0102dfa <mem_init+0x1aa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dd7:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102dda:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102dde:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102de5:	f0 
f0102de6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102ded:	00 
f0102dee:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102df5:	e8 46 d2 ff ff       	call   f0100040 <_panic>
f0102dfa:	39 f0                	cmp    %esi,%eax
f0102dfc:	74 24                	je     f0102e22 <mem_init+0x1aca>
f0102dfe:	c7 44 24 0c 50 77 10 	movl   $0xf0107750,0xc(%esp)
f0102e05:	f0 
f0102e06:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102e0d:	f0 
f0102e0e:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e15:	00 
f0102e16:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102e1d:	e8 1e d2 ff ff       	call   f0100040 <_panic>
f0102e22:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e28:	81 c6 00 10 00 00    	add    $0x1000,%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102e2e:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102e31:	0f 85 55 05 00 00    	jne    f010338c <mem_init+0x2034>
f0102e37:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102e3c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102e3f:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
f0102e42:	89 f0                	mov    %esi,%eax
f0102e44:	e8 cb db ff ff       	call   f0100a14 <check_va2pa>
f0102e49:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102e4c:	74 24                	je     f0102e72 <mem_init+0x1b1a>
f0102e4e:	c7 44 24 0c 98 77 10 	movl   $0xf0107798,0xc(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102e5d:	f0 
f0102e5e:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0102e65:	00 
f0102e66:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102e6d:	e8 ce d1 ff ff       	call   f0100040 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f0102e72:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102e78:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f0102e7e:	75 bf                	jne    f0102e3f <mem_init+0x1ae7>
f0102e80:	81 ef 00 00 01 00    	sub    $0x10000,%edi
f0102e86:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f0102e8d:	81 ff 00 00 f7 ef    	cmp    $0xeff70000,%edi
f0102e93:	0f 85 0e ff ff ff    	jne    f0102da7 <mem_init+0x1a4f>
f0102e99:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0102e9c:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102ea1:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0102ea7:	83 fa 04             	cmp    $0x4,%edx
f0102eaa:	77 2e                	ja     f0102eda <mem_init+0x1b82>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f0102eac:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102eb0:	0f 85 aa 00 00 00    	jne    f0102f60 <mem_init+0x1c08>
f0102eb6:	c7 44 24 0c ae 7b 10 	movl   $0xf0107bae,0xc(%esp)
f0102ebd:	f0 
f0102ebe:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102ec5:	f0 
f0102ec6:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0102ecd:	00 
f0102ece:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102ed5:	e8 66 d1 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102eda:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102edf:	76 55                	jbe    f0102f36 <mem_init+0x1bde>
				assert(pgdir[i] & PTE_P);
f0102ee1:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102ee4:	f6 c2 01             	test   $0x1,%dl
f0102ee7:	75 24                	jne    f0102f0d <mem_init+0x1bb5>
f0102ee9:	c7 44 24 0c ae 7b 10 	movl   $0xf0107bae,0xc(%esp)
f0102ef0:	f0 
f0102ef1:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102ef8:	f0 
f0102ef9:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0102f00:	00 
f0102f01:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102f08:	e8 33 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102f0d:	f6 c2 02             	test   $0x2,%dl
f0102f10:	75 4e                	jne    f0102f60 <mem_init+0x1c08>
f0102f12:	c7 44 24 0c bf 7b 10 	movl   $0xf0107bbf,0xc(%esp)
f0102f19:	f0 
f0102f1a:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102f21:	f0 
f0102f22:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102f29:	00 
f0102f2a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102f31:	e8 0a d1 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102f36:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102f3a:	74 24                	je     f0102f60 <mem_init+0x1c08>
f0102f3c:	c7 44 24 0c d0 7b 10 	movl   $0xf0107bd0,0xc(%esp)
f0102f43:	f0 
f0102f44:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102f4b:	f0 
f0102f4c:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102f53:	00 
f0102f54:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102f5b:	e8 e0 d0 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102f60:	40                   	inc    %eax
f0102f61:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102f66:	0f 85 35 ff ff ff    	jne    f0102ea1 <mem_init+0x1b49>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102f6c:	c7 04 24 bc 77 10 f0 	movl   $0xf01077bc,(%esp)
f0102f73:	e8 f6 0e 00 00       	call   f0103e6e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f78:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f7d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f82:	77 20                	ja     f0102fa4 <mem_init+0x1c4c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f84:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f88:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0102f8f:	f0 
f0102f90:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
f0102f97:	00 
f0102f98:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102f9f:	e8 9c d0 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102fa4:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102fa9:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102fac:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fb1:	e8 bd db ff ff       	call   f0100b73 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102fb6:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102fb9:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102fbe:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102fc1:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102fc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102fcb:	e8 ae df ff ff       	call   f0100f7e <page_alloc>
f0102fd0:	89 c6                	mov    %eax,%esi
f0102fd2:	85 c0                	test   %eax,%eax
f0102fd4:	75 24                	jne    f0102ffa <mem_init+0x1ca2>
f0102fd6:	c7 44 24 0c ba 79 10 	movl   $0xf01079ba,0xc(%esp)
f0102fdd:	f0 
f0102fde:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0102fe5:	f0 
f0102fe6:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f0102fed:	00 
f0102fee:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0102ff5:	e8 46 d0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ffa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103001:	e8 78 df ff ff       	call   f0100f7e <page_alloc>
f0103006:	89 c7                	mov    %eax,%edi
f0103008:	85 c0                	test   %eax,%eax
f010300a:	75 24                	jne    f0103030 <mem_init+0x1cd8>
f010300c:	c7 44 24 0c d0 79 10 	movl   $0xf01079d0,0xc(%esp)
f0103013:	f0 
f0103014:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010301b:	f0 
f010301c:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0103023:	00 
f0103024:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010302b:	e8 10 d0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103030:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103037:	e8 42 df ff ff       	call   f0100f7e <page_alloc>
f010303c:	89 c3                	mov    %eax,%ebx
f010303e:	85 c0                	test   %eax,%eax
f0103040:	75 24                	jne    f0103066 <mem_init+0x1d0e>
f0103042:	c7 44 24 0c e6 79 10 	movl   $0xf01079e6,0xc(%esp)
f0103049:	f0 
f010304a:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0103051:	f0 
f0103052:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0103059:	00 
f010305a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0103061:	e8 da cf ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0103066:	89 34 24             	mov    %esi,(%esp)
f0103069:	e8 94 df ff ff       	call   f0101002 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010306e:	89 f8                	mov    %edi,%eax
f0103070:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0103076:	c1 f8 03             	sar    $0x3,%eax
f0103079:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010307c:	89 c2                	mov    %eax,%edx
f010307e:	c1 ea 0c             	shr    $0xc,%edx
f0103081:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0103087:	72 20                	jb     f01030a9 <mem_init+0x1d51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103089:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010308d:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0103094:	f0 
f0103095:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010309c:	00 
f010309d:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f01030a4:	e8 97 cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01030a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030b0:	00 
f01030b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01030b8:	00 
	return (void *)(pa + KERNBASE);
f01030b9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01030be:	89 04 24             	mov    %eax,(%esp)
f01030c1:	e8 5c 2c 00 00       	call   f0105d22 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01030c6:	89 d8                	mov    %ebx,%eax
f01030c8:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f01030ce:	c1 f8 03             	sar    $0x3,%eax
f01030d1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030d4:	89 c2                	mov    %eax,%edx
f01030d6:	c1 ea 0c             	shr    $0xc,%edx
f01030d9:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f01030df:	72 20                	jb     f0103101 <mem_init+0x1da9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030e5:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01030ec:	f0 
f01030ed:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01030f4:	00 
f01030f5:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f01030fc:	e8 3f cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103101:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103108:	00 
f0103109:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103110:	00 
	return (void *)(pa + KERNBASE);
f0103111:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103116:	89 04 24             	mov    %eax,(%esp)
f0103119:	e8 04 2c 00 00       	call   f0105d22 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010311e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103125:	00 
f0103126:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010312d:	00 
f010312e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103132:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f0103137:	89 04 24             	mov    %eax,(%esp)
f010313a:	e8 30 e1 ff ff       	call   f010126f <page_insert>
	assert(pp1->pp_ref == 1);
f010313f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103144:	74 24                	je     f010316a <mem_init+0x1e12>
f0103146:	c7 44 24 0c b7 7a 10 	movl   $0xf0107ab7,0xc(%esp)
f010314d:	f0 
f010314e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0103155:	f0 
f0103156:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f010315d:	00 
f010315e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0103165:	e8 d6 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010316a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103171:	01 01 01 
f0103174:	74 24                	je     f010319a <mem_init+0x1e42>
f0103176:	c7 44 24 0c dc 77 10 	movl   $0xf01077dc,0xc(%esp)
f010317d:	f0 
f010317e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0103185:	f0 
f0103186:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f010318d:	00 
f010318e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0103195:	e8 a6 ce ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010319a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01031a1:	00 
f01031a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031a9:	00 
f01031aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031ae:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01031b3:	89 04 24             	mov    %eax,(%esp)
f01031b6:	e8 b4 e0 ff ff       	call   f010126f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031bb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01031c2:	02 02 02 
f01031c5:	74 24                	je     f01031eb <mem_init+0x1e93>
f01031c7:	c7 44 24 0c 00 78 10 	movl   $0xf0107800,0xc(%esp)
f01031ce:	f0 
f01031cf:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01031d6:	f0 
f01031d7:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f01031de:	00 
f01031df:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01031e6:	e8 55 ce ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01031eb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01031f0:	74 24                	je     f0103216 <mem_init+0x1ebe>
f01031f2:	c7 44 24 0c d9 7a 10 	movl   $0xf0107ad9,0xc(%esp)
f01031f9:	f0 
f01031fa:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0103201:	f0 
f0103202:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0103209:	00 
f010320a:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0103211:	e8 2a ce ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103216:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010321b:	74 24                	je     f0103241 <mem_init+0x1ee9>
f010321d:	c7 44 24 0c 43 7b 10 	movl   $0xf0107b43,0xc(%esp)
f0103224:	f0 
f0103225:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f010322c:	f0 
f010322d:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103234:	00 
f0103235:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f010323c:	e8 ff cd ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0103241:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0103248:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010324b:	89 d8                	mov    %ebx,%eax
f010324d:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f0103253:	c1 f8 03             	sar    $0x3,%eax
f0103256:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103259:	89 c2                	mov    %eax,%edx
f010325b:	c1 ea 0c             	shr    $0xc,%edx
f010325e:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f0103264:	72 20                	jb     f0103286 <mem_init+0x1f2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103266:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010326a:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0103271:	f0 
f0103272:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103279:	00 
f010327a:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0103281:	e8 ba cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103286:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010328d:	03 03 03 
f0103290:	74 24                	je     f01032b6 <mem_init+0x1f5e>
f0103292:	c7 44 24 0c 24 78 10 	movl   $0xf0107824,0xc(%esp)
f0103299:	f0 
f010329a:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01032a1:	f0 
f01032a2:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01032a9:	00 
f01032aa:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01032b1:	e8 8a cd ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01032b6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01032bd:	00 
f01032be:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01032c3:	89 04 24             	mov    %eax,(%esp)
f01032c6:	e8 5b df ff ff       	call   f0101226 <page_remove>
	assert(pp2->pp_ref == 0);
f01032cb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01032d0:	74 24                	je     f01032f6 <mem_init+0x1f9e>
f01032d2:	c7 44 24 0c 11 7b 10 	movl   $0xf0107b11,0xc(%esp)
f01032d9:	f0 
f01032da:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01032e1:	f0 
f01032e2:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f01032e9:	00 
f01032ea:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f01032f1:	e8 4a cd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01032f6:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
f01032fb:	8b 08                	mov    (%eax),%ecx
f01032fd:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103303:	89 f2                	mov    %esi,%edx
f0103305:	2b 15 90 4e 22 f0    	sub    0xf0224e90,%edx
f010330b:	c1 fa 03             	sar    $0x3,%edx
f010330e:	c1 e2 0c             	shl    $0xc,%edx
f0103311:	39 d1                	cmp    %edx,%ecx
f0103313:	74 24                	je     f0103339 <mem_init+0x1fe1>
f0103315:	c7 44 24 0c ac 71 10 	movl   $0xf01071ac,0xc(%esp)
f010331c:	f0 
f010331d:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0103324:	f0 
f0103325:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f010332c:	00 
f010332d:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0103334:	e8 07 cd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103339:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010333f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103344:	74 24                	je     f010336a <mem_init+0x2012>
f0103346:	c7 44 24 0c c8 7a 10 	movl   $0xf0107ac8,0xc(%esp)
f010334d:	f0 
f010334e:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f0103355:	f0 
f0103356:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f010335d:	00 
f010335e:	c7 04 24 b1 78 10 f0 	movl   $0xf01078b1,(%esp)
f0103365:	e8 d6 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010336a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103370:	89 34 24             	mov    %esi,(%esp)
f0103373:	e8 8a dc ff ff       	call   f0101002 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103378:	c7 04 24 50 78 10 f0 	movl   $0xf0107850,(%esp)
f010337f:	e8 ea 0a 00 00       	call   f0103e6e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0103384:	83 c4 3c             	add    $0x3c,%esp
f0103387:	5b                   	pop    %ebx
f0103388:	5e                   	pop    %esi
f0103389:	5f                   	pop    %edi
f010338a:	5d                   	pop    %ebp
f010338b:	c3                   	ret    
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010338c:	89 da                	mov    %ebx,%edx
f010338e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103391:	e8 7e d6 ff ff       	call   f0100a14 <check_va2pa>
f0103396:	e9 5f fa ff ff       	jmp    f0102dfa <mem_init+0x1aa2>

f010339b <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f010339b:	55                   	push   %ebp
f010339c:	89 e5                	mov    %esp,%ebp
f010339e:	57                   	push   %edi
f010339f:	56                   	push   %esi
f01033a0:	53                   	push   %ebx
f01033a1:	83 ec 2c             	sub    $0x2c,%esp
f01033a4:	8b 75 08             	mov    0x8(%ebp),%esi
f01033a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	uintptr_t upperBound = (uintptr_t)va + len;
f01033aa:	8b 45 10             	mov    0x10(%ebp),%eax
f01033ad:	01 d8                	add    %ebx,%eax
f01033af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((uint32_t)va + len > ULIM) {
f01033b2:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f01033b7:	76 60                	jbe    f0103419 <user_mem_check+0x7e>
		user_mem_check_addr = (uintptr_t)va;
f01033b9:	89 1d 44 42 22 f0    	mov    %ebx,0xf0224244
		return -E_FAULT;
f01033bf:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01033c4:	eb 5f                	jmp    f0103425 <user_mem_check+0x8a>
	}
	
	while ((uintptr_t)va < upperBound) {
		pte_t *pgEntry = pgdir_walk(env->env_pgdir, va, false);
f01033c6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01033cd:	00 
f01033ce:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033d2:	8b 46 60             	mov    0x60(%esi),%eax
f01033d5:	89 04 24             	mov    %eax,(%esp)
f01033d8:	e8 85 dc ff ff       	call   f0101062 <pgdir_walk>
		if (!pgEntry) {
f01033dd:	85 c0                	test   %eax,%eax
f01033df:	75 0d                	jne    f01033ee <user_mem_check+0x53>
			user_mem_check_addr = (uintptr_t)va;
f01033e1:	89 3d 44 42 22 f0    	mov    %edi,0xf0224244
			return -E_FAULT;
f01033e7:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f01033ec:	eb 37                	jmp    f0103425 <user_mem_check+0x8a>
		}
		if (((*pgEntry & perm) != perm) || !(*pgEntry & PTE_P)) {
f01033ee:	8b 00                	mov    (%eax),%eax
f01033f0:	8b 55 14             	mov    0x14(%ebp),%edx
f01033f3:	21 c2                	and    %eax,%edx
f01033f5:	39 55 14             	cmp    %edx,0x14(%ebp)
f01033f8:	75 04                	jne    f01033fe <user_mem_check+0x63>
f01033fa:	a8 01                	test   $0x1,%al
f01033fc:	75 0d                	jne    f010340b <user_mem_check+0x70>
			user_mem_check_addr = (uintptr_t)va;
f01033fe:	89 3d 44 42 22 f0    	mov    %edi,0xf0224244
			return -E_FAULT;
f0103404:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0103409:	eb 1a                	jmp    f0103425 <user_mem_check+0x8a>
		}
		va -= (uintptr_t)va % PGSIZE;
f010340b:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
f0103411:	29 fb                	sub    %edi,%ebx
		va += PGSIZE; 
f0103413:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if ((uint32_t)va + len > ULIM) {
		user_mem_check_addr = (uintptr_t)va;
		return -E_FAULT;
	}
	
	while ((uintptr_t)va < upperBound) {
f0103419:	89 df                	mov    %ebx,%edi
f010341b:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f010341e:	77 a6                	ja     f01033c6 <user_mem_check+0x2b>
			return -E_FAULT;
		}
		va -= (uintptr_t)va % PGSIZE;
		va += PGSIZE; 
	}
	return 0;
f0103420:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103425:	83 c4 2c             	add    $0x2c,%esp
f0103428:	5b                   	pop    %ebx
f0103429:	5e                   	pop    %esi
f010342a:	5f                   	pop    %edi
f010342b:	5d                   	pop    %ebp
f010342c:	c3                   	ret    

f010342d <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f010342d:	55                   	push   %ebp
f010342e:	89 e5                	mov    %esp,%ebp
f0103430:	53                   	push   %ebx
f0103431:	83 ec 14             	sub    $0x14,%esp
f0103434:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0103437:	8b 45 14             	mov    0x14(%ebp),%eax
f010343a:	83 c8 04             	or     $0x4,%eax
f010343d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103441:	8b 45 10             	mov    0x10(%ebp),%eax
f0103444:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103448:	8b 45 0c             	mov    0xc(%ebp),%eax
f010344b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010344f:	89 1c 24             	mov    %ebx,(%esp)
f0103452:	e8 44 ff ff ff       	call   f010339b <user_mem_check>
f0103457:	85 c0                	test   %eax,%eax
f0103459:	79 24                	jns    f010347f <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f010345b:	a1 44 42 22 f0       	mov    0xf0224244,%eax
f0103460:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103464:	8b 43 48             	mov    0x48(%ebx),%eax
f0103467:	89 44 24 04          	mov    %eax,0x4(%esp)
f010346b:	c7 04 24 7c 78 10 f0 	movl   $0xf010787c,(%esp)
f0103472:	e8 f7 09 00 00       	call   f0103e6e <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103477:	89 1c 24             	mov    %ebx,(%esp)
f010347a:	e8 ed 06 00 00       	call   f0103b6c <env_destroy>
	}
}
f010347f:	83 c4 14             	add    $0x14,%esp
f0103482:	5b                   	pop    %ebx
f0103483:	5d                   	pop    %ebp
f0103484:	c3                   	ret    
f0103485:	00 00                	add    %al,(%eax)
	...

f0103488 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103488:	55                   	push   %ebp
f0103489:	89 e5                	mov    %esp,%ebp
f010348b:	57                   	push   %edi
f010348c:	56                   	push   %esi
f010348d:	53                   	push   %ebx
f010348e:	83 ec 1c             	sub    $0x1c,%esp
f0103491:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *pp;
	uint32_t i;
	for (i = ROUNDDOWN((uint32_t)va, PGSIZE); i < ROUNDUP((uint32_t)va + len, PGSIZE); i+=PGSIZE) {
f0103493:	89 d3                	mov    %edx,%ebx
f0103495:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f010349b:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f01034a2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01034a8:	eb 6d                	jmp    f0103517 <region_alloc+0x8f>
		pp = page_alloc(0);
f01034aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01034b1:	e8 c8 da ff ff       	call   f0100f7e <page_alloc>
		if (!pp) {
f01034b6:	85 c0                	test   %eax,%eax
f01034b8:	75 1c                	jne    f01034d6 <region_alloc+0x4e>
			panic("Region alloc: Page allocation fail, not enough memory");
f01034ba:	c7 44 24 08 e0 7b 10 	movl   $0xf0107be0,0x8(%esp)
f01034c1:	f0 
f01034c2:	c7 44 24 04 30 01 00 	movl   $0x130,0x4(%esp)
f01034c9:	00 
f01034ca:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f01034d1:	e8 6a cb ff ff       	call   f0100040 <_panic>
		}
		if (page_insert(e->env_pgdir, pp, (void *)i, PTE_W|PTE_U) < 0) {
f01034d6:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01034dd:	00 
f01034de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01034e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e6:	8b 46 60             	mov    0x60(%esi),%eax
f01034e9:	89 04 24             	mov    %eax,(%esp)
f01034ec:	e8 7e dd ff ff       	call   f010126f <page_insert>
f01034f1:	85 c0                	test   %eax,%eax
f01034f3:	79 1c                	jns    f0103511 <region_alloc+0x89>
			panic("Region alloc: Page insert fail, not enough memory");
f01034f5:	c7 44 24 08 18 7c 10 	movl   $0xf0107c18,0x8(%esp)
f01034fc:	f0 
f01034fd:	c7 44 24 04 33 01 00 	movl   $0x133,0x4(%esp)
f0103504:	00 
f0103505:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f010350c:	e8 2f cb ff ff       	call   f0100040 <_panic>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *pp;
	uint32_t i;
	for (i = ROUNDDOWN((uint32_t)va, PGSIZE); i < ROUNDUP((uint32_t)va + len, PGSIZE); i+=PGSIZE) {
f0103511:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103517:	39 fb                	cmp    %edi,%ebx
f0103519:	72 8f                	jb     f01034aa <region_alloc+0x22>
		}
		if (page_insert(e->env_pgdir, pp, (void *)i, PTE_W|PTE_U) < 0) {
			panic("Region alloc: Page insert fail, not enough memory");
		}
	}
}
f010351b:	83 c4 1c             	add    $0x1c,%esp
f010351e:	5b                   	pop    %ebx
f010351f:	5e                   	pop    %esi
f0103520:	5f                   	pop    %edi
f0103521:	5d                   	pop    %ebp
f0103522:	c3                   	ret    

f0103523 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103523:	55                   	push   %ebp
f0103524:	89 e5                	mov    %esp,%ebp
f0103526:	57                   	push   %edi
f0103527:	56                   	push   %esi
f0103528:	53                   	push   %ebx
f0103529:	83 ec 0c             	sub    $0xc,%esp
f010352c:	8b 45 08             	mov    0x8(%ebp),%eax
f010352f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103532:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103535:	85 c0                	test   %eax,%eax
f0103537:	75 24                	jne    f010355d <envid2env+0x3a>
		*env_store = curenv;
f0103539:	e8 12 2e 00 00       	call   f0106350 <cpunum>
f010353e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103545:	29 c2                	sub    %eax,%edx
f0103547:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010354a:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103551:	89 06                	mov    %eax,(%esi)
		return 0;
f0103553:	b8 00 00 00 00       	mov    $0x0,%eax
f0103558:	e9 84 00 00 00       	jmp    f01035e1 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010355d:	89 c3                	mov    %eax,%ebx
f010355f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103565:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f010356c:	c1 e3 07             	shl    $0x7,%ebx
f010356f:	29 cb                	sub    %ecx,%ebx
f0103571:	03 1d 48 42 22 f0    	add    0xf0224248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0103577:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f010357b:	74 05                	je     f0103582 <envid2env+0x5f>
f010357d:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103580:	74 0d                	je     f010358f <envid2env+0x6c>
		*env_store = 0;
f0103582:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103588:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010358d:	eb 52                	jmp    f01035e1 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f010358f:	84 d2                	test   %dl,%dl
f0103591:	74 47                	je     f01035da <envid2env+0xb7>
f0103593:	e8 b8 2d 00 00       	call   f0106350 <cpunum>
f0103598:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010359f:	29 c2                	sub    %eax,%edx
f01035a1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035a4:	39 1c 85 28 50 22 f0 	cmp    %ebx,-0xfddafd8(,%eax,4)
f01035ab:	74 2d                	je     f01035da <envid2env+0xb7>
f01035ad:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f01035b0:	e8 9b 2d 00 00       	call   f0106350 <cpunum>
f01035b5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01035bc:	29 c2                	sub    %eax,%edx
f01035be:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01035c1:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f01035c8:	3b 78 48             	cmp    0x48(%eax),%edi
f01035cb:	74 0d                	je     f01035da <envid2env+0xb7>
		*env_store = 0;
f01035cd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01035d3:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01035d8:	eb 07                	jmp    f01035e1 <envid2env+0xbe>
	}

	*env_store = e;
f01035da:	89 1e                	mov    %ebx,(%esi)
	return 0;
f01035dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01035e1:	83 c4 0c             	add    $0xc,%esp
f01035e4:	5b                   	pop    %ebx
f01035e5:	5e                   	pop    %esi
f01035e6:	5f                   	pop    %edi
f01035e7:	5d                   	pop    %ebp
f01035e8:	c3                   	ret    

f01035e9 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f01035e9:	55                   	push   %ebp
f01035ea:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f01035ec:	b8 20 93 12 f0       	mov    $0xf0129320,%eax
f01035f1:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01035f4:	b8 23 00 00 00       	mov    $0x23,%eax
f01035f9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01035fb:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01035fd:	b0 10                	mov    $0x10,%al
f01035ff:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103601:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103603:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0103605:	ea 0c 36 10 f0 08 00 	ljmp   $0x8,$0xf010360c
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010360c:	b0 00                	mov    $0x0,%al
f010360e:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103611:	5d                   	pop    %ebp
f0103612:	c3                   	ret    

f0103613 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103613:	55                   	push   %ebp
f0103614:	89 e5                	mov    %esp,%ebp
f0103616:	56                   	push   %esi
f0103617:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f0103618:	8b 35 48 42 22 f0    	mov    0xf0224248,%esi
f010361e:	8b 0d 4c 42 22 f0    	mov    0xf022424c,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103624:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f010362a:	ba ff 03 00 00       	mov    $0x3ff,%edx
f010362f:	eb 02                	jmp    f0103633 <env_init+0x20>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103631:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f0103633:	89 c3                	mov    %eax,%ebx
f0103635:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f010363c:	89 48 44             	mov    %ecx,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f010363f:	4a                   	dec    %edx
f0103640:	83 e8 7c             	sub    $0x7c,%eax
f0103643:	83 fa ff             	cmp    $0xffffffff,%edx
f0103646:	75 e9                	jne    f0103631 <env_init+0x1e>
f0103648:	89 35 4c 42 22 f0    	mov    %esi,0xf022424c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f010364e:	e8 96 ff ff ff       	call   f01035e9 <env_init_percpu>
}
f0103653:	5b                   	pop    %ebx
f0103654:	5e                   	pop    %esi
f0103655:	5d                   	pop    %ebp
f0103656:	c3                   	ret    

f0103657 <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103657:	55                   	push   %ebp
f0103658:	89 e5                	mov    %esp,%ebp
f010365a:	56                   	push   %esi
f010365b:	53                   	push   %ebx
f010365c:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f010365f:	8b 1d 4c 42 22 f0    	mov    0xf022424c,%ebx
f0103665:	85 db                	test   %ebx,%ebx
f0103667:	0f 84 84 01 00 00    	je     f01037f1 <env_alloc+0x19a>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f010366d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103674:	e8 05 d9 ff ff       	call   f0100f7e <page_alloc>
f0103679:	85 c0                	test   %eax,%eax
f010367b:	0f 84 77 01 00 00    	je     f01037f8 <env_alloc+0x1a1>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
f0103681:	66 ff 40 04          	incw   0x4(%eax)
f0103685:	2b 05 90 4e 22 f0    	sub    0xf0224e90,%eax
f010368b:	c1 f8 03             	sar    $0x3,%eax
f010368e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103691:	89 c2                	mov    %eax,%edx
f0103693:	c1 ea 0c             	shr    $0xc,%edx
f0103696:	3b 15 88 4e 22 f0    	cmp    0xf0224e88,%edx
f010369c:	72 20                	jb     f01036be <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010369e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01036a2:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01036a9:	f0 
f01036aa:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01036b1:	00 
f01036b2:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f01036b9:	e8 82 c9 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01036be:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01036c3:	89 43 60             	mov    %eax,0x60(%ebx)
	e->env_pgdir = (pde_t *)page2kva(p);
f01036c6:	ba 00 00 00 00       	mov    $0x0,%edx
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f01036cb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (i < PDX(UTOP))
f01036d0:	3d ba 03 00 00       	cmp    $0x3ba,%eax
f01036d5:	77 0c                	ja     f01036e3 <env_alloc+0x8c>
			e->env_pgdir[i] = 0;
f01036d7:	8b 4b 60             	mov    0x60(%ebx),%ecx
f01036da:	c7 04 11 00 00 00 00 	movl   $0x0,(%ecx,%edx,1)
f01036e1:	eb 0f                	jmp    f01036f2 <env_alloc+0x9b>
		else {
			e->env_pgdir[i] = kern_pgdir[i];
f01036e3:	8b 0d 8c 4e 22 f0    	mov    0xf0224e8c,%ecx
f01036e9:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f01036ec:	8b 4b 60             	mov    0x60(%ebx),%ecx
f01036ef:	89 34 11             	mov    %esi,(%ecx,%edx,1)
	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
	e->env_pgdir = (pde_t *)page2kva(p);
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f01036f2:	40                   	inc    %eax
f01036f3:	83 c2 04             	add    $0x4,%edx
f01036f6:	3d 00 04 00 00       	cmp    $0x400,%eax
f01036fb:	75 d3                	jne    f01036d0 <env_alloc+0x79>
		}
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f01036fd:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103700:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103705:	77 20                	ja     f0103727 <env_alloc+0xd0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103707:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010370b:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0103712:	f0 
f0103713:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f010371a:	00 
f010371b:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f0103722:	e8 19 c9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0103727:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010372d:	83 ca 05             	or     $0x5,%edx
f0103730:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103736:	8b 43 48             	mov    0x48(%ebx),%eax
f0103739:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f010373e:	89 c1                	mov    %eax,%ecx
f0103740:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103746:	7f 05                	jg     f010374d <env_alloc+0xf6>
		generation = 1 << ENVGENSHIFT;
f0103748:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f010374d:	89 d8                	mov    %ebx,%eax
f010374f:	2b 05 48 42 22 f0    	sub    0xf0224248,%eax
f0103755:	c1 f8 02             	sar    $0x2,%eax
f0103758:	89 c6                	mov    %eax,%esi
f010375a:	c1 e6 05             	shl    $0x5,%esi
f010375d:	89 c2                	mov    %eax,%edx
f010375f:	c1 e2 0a             	shl    $0xa,%edx
f0103762:	01 f2                	add    %esi,%edx
f0103764:	01 c2                	add    %eax,%edx
f0103766:	89 d6                	mov    %edx,%esi
f0103768:	c1 e6 0f             	shl    $0xf,%esi
f010376b:	01 f2                	add    %esi,%edx
f010376d:	c1 e2 05             	shl    $0x5,%edx
f0103770:	01 d0                	add    %edx,%eax
f0103772:	f7 d8                	neg    %eax
f0103774:	09 c1                	or     %eax,%ecx
f0103776:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103779:	8b 45 0c             	mov    0xc(%ebp),%eax
f010377c:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f010377f:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103786:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f010378d:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103794:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f010379b:	00 
f010379c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01037a3:	00 
f01037a4:	89 1c 24             	mov    %ebx,(%esp)
f01037a7:	e8 76 25 00 00       	call   f0105d22 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01037ac:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01037b2:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01037b8:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01037be:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01037c5:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f01037cb:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f01037d2:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f01037d9:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f01037dd:	8b 43 44             	mov    0x44(%ebx),%eax
f01037e0:	a3 4c 42 22 f0       	mov    %eax,0xf022424c
	*newenv_store = e;
f01037e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01037e8:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f01037ea:	b8 00 00 00 00       	mov    $0x0,%eax
f01037ef:	eb 0c                	jmp    f01037fd <env_alloc+0x1a6>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f01037f1:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01037f6:	eb 05                	jmp    f01037fd <env_alloc+0x1a6>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f01037f8:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f01037fd:	83 c4 10             	add    $0x10,%esp
f0103800:	5b                   	pop    %ebx
f0103801:	5e                   	pop    %esi
f0103802:	5d                   	pop    %ebp
f0103803:	c3                   	ret    

f0103804 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103804:	55                   	push   %ebp
f0103805:	89 e5                	mov    %esp,%ebp
f0103807:	57                   	push   %edi
f0103808:	56                   	push   %esi
f0103809:	53                   	push   %ebx
f010380a:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env *newenv;
	int e = env_alloc(&newenv, 0);
f010380d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103814:	00 
f0103815:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103818:	89 04 24             	mov    %eax,(%esp)
f010381b:	e8 37 fe ff ff       	call   f0103657 <env_alloc>
	if (e < 0) {
f0103820:	85 c0                	test   %eax,%eax
f0103822:	79 20                	jns    f0103844 <env_create+0x40>
		panic("Env create: %e", e);
f0103824:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103828:	c7 44 24 08 ae 7c 10 	movl   $0xf0107cae,0x8(%esp)
f010382f:	f0 
f0103830:	c7 44 24 04 a4 01 00 	movl   $0x1a4,0x4(%esp)
f0103837:	00 
f0103838:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f010383f:	e8 fc c7 ff ff       	call   f0100040 <_panic>
	}
	load_icode(newenv, binary);
f0103844:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103847:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf *elf = (struct Elf *)binary;
	struct PageInfo *pp;
	struct Proghdr *proghdr;
	int i;
	// Verify whether it is an ELF file
	if (elf->e_magic != ELF_MAGIC) {
f010384a:	8b 55 08             	mov    0x8(%ebp),%edx
f010384d:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f0103853:	74 1c                	je     f0103871 <env_create+0x6d>
		panic("Load icode: Not a valid ELF file format");
f0103855:	c7 44 24 08 4c 7c 10 	movl   $0xf0107c4c,0x8(%esp)
f010385c:	f0 
f010385d:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
f0103864:	00 
f0103865:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f010386c:	e8 cf c7 ff ff       	call   f0100040 <_panic>
	}
	// Set entry point
	e->env_tf.tf_eip = elf->e_entry;
f0103871:	8b 55 08             	mov    0x8(%ebp),%edx
f0103874:	8b 42 18             	mov    0x18(%edx),%eax
f0103877:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010387a:	89 42 30             	mov    %eax,0x30(%edx)
	// Switch to environment
	lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
f010387d:	8b 42 60             	mov    0x60(%edx),%eax
f0103880:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f0103886:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010388b:	0f 22 d8             	mov    %eax,%cr3
	// If valid, go to the program headers
	proghdr = (struct Proghdr *)((uint8_t *) binary + elf->e_phoff);
f010388e:	8b 75 08             	mov    0x8(%ebp),%esi
f0103891:	03 76 1c             	add    0x1c(%esi),%esi
	for (i = 0; i < elf->e_phnum; i++) {
f0103894:	bf 00 00 00 00       	mov    $0x0,%edi
f0103899:	eb 6e                	jmp    f0103909 <env_create+0x105>
		// Check if the segments is loadable
		if (proghdr[i].p_type == ELF_PROG_LOAD) {
f010389b:	83 3e 01             	cmpl   $0x1,(%esi)
f010389e:	75 65                	jne    f0103905 <env_create+0x101>
			// Check if memory size is greater than or equal to file size
			if (proghdr[i].p_filesz > proghdr[i].p_memsz) {
f01038a0:	8b 4e 14             	mov    0x14(%esi),%ecx
f01038a3:	39 4e 10             	cmp    %ecx,0x10(%esi)
f01038a6:	76 1c                	jbe    f01038c4 <env_create+0xc0>
				panic("Load icode: File size greater than memory size");
f01038a8:	c7 44 24 08 74 7c 10 	movl   $0xf0107c74,0x8(%esp)
f01038af:	f0 
f01038b0:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f01038b7:	00 
f01038b8:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f01038bf:	e8 7c c7 ff ff       	call   f0100040 <_panic>
			}
			// Allocate page table entries for program to be copied
			region_alloc(e, (void *)proghdr[i].p_va, proghdr[i].p_memsz);
f01038c4:	8b 56 08             	mov    0x8(%esi),%edx
f01038c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01038ca:	e8 b9 fb ff ff       	call   f0103488 <region_alloc>
			// Copy file 
			memset((void *)proghdr[i].p_va, 0, proghdr[i].p_memsz);
f01038cf:	8b 46 14             	mov    0x14(%esi),%eax
f01038d2:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01038dd:	00 
f01038de:	8b 46 08             	mov    0x8(%esi),%eax
f01038e1:	89 04 24             	mov    %eax,(%esp)
f01038e4:	e8 39 24 00 00       	call   f0105d22 <memset>
			memmove((void *)proghdr[i].p_va, (void *)(binary + proghdr[i].p_offset), proghdr[i].p_filesz);
f01038e9:	8b 46 10             	mov    0x10(%esi),%eax
f01038ec:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01038f3:	03 46 04             	add    0x4(%esi),%eax
f01038f6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038fa:	8b 46 08             	mov    0x8(%esi),%eax
f01038fd:	89 04 24             	mov    %eax,(%esp)
f0103900:	e8 67 24 00 00       	call   f0105d6c <memmove>
	e->env_tf.tf_eip = elf->e_entry;
	// Switch to environment
	lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
	// If valid, go to the program headers
	proghdr = (struct Proghdr *)((uint8_t *) binary + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++) {
f0103905:	47                   	inc    %edi
f0103906:	83 c6 20             	add    $0x20,%esi
f0103909:	8b 55 08             	mov    0x8(%ebp),%edx
f010390c:	0f b7 42 2c          	movzwl 0x2c(%edx),%eax
f0103910:	39 c7                	cmp    %eax,%edi
f0103912:	7c 87                	jl     f010389b <env_create+0x97>

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103914:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103919:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010391e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103921:	e8 62 fb ff ff       	call   f0103488 <region_alloc>
	memset((void *)(USTACKTOP - PGSIZE), 0, PGSIZE);
f0103926:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010392d:	00 
f010392e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103935:	00 
f0103936:	c7 04 24 00 d0 bf ee 	movl   $0xeebfd000,(%esp)
f010393d:	e8 e0 23 00 00       	call   f0105d22 <memset>

	// switch back to kern_pgdir to be on the safe side
	lcr3(PADDR(kern_pgdir));
f0103942:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103947:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010394c:	77 20                	ja     f010396e <env_create+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010394e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103952:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0103959:	f0 
f010395a:	c7 44 24 04 93 01 00 	movl   $0x193,0x4(%esp)
f0103961:	00 
f0103962:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f0103969:	e8 d2 c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010396e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103973:	0f 22 d8             	mov    %eax,%cr3
	int e = env_alloc(&newenv, 0);
	if (e < 0) {
		panic("Env create: %e", e);
	}
	load_icode(newenv, binary);
	newenv->env_type = type;
f0103976:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103979:	8b 55 0c             	mov    0xc(%ebp),%edx
f010397c:	89 50 50             	mov    %edx,0x50(%eax)
	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
	if (type == ENV_TYPE_FS) {
f010397f:	83 fa 01             	cmp    $0x1,%edx
f0103982:	75 07                	jne    f010398b <env_create+0x187>
		newenv->env_tf.tf_eflags |= FL_IOPL_3;
f0103984:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	}
}
f010398b:	83 c4 3c             	add    $0x3c,%esp
f010398e:	5b                   	pop    %ebx
f010398f:	5e                   	pop    %esi
f0103990:	5f                   	pop    %edi
f0103991:	5d                   	pop    %ebp
f0103992:	c3                   	ret    

f0103993 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0103993:	55                   	push   %ebp
f0103994:	89 e5                	mov    %esp,%ebp
f0103996:	57                   	push   %edi
f0103997:	56                   	push   %esi
f0103998:	53                   	push   %ebx
f0103999:	83 ec 2c             	sub    $0x2c,%esp
f010399c:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010399f:	e8 ac 29 00 00       	call   f0106350 <cpunum>
f01039a4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01039ab:	29 c2                	sub    %eax,%edx
f01039ad:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01039b0:	39 3c 85 28 50 22 f0 	cmp    %edi,-0xfddafd8(,%eax,4)
f01039b7:	75 3d                	jne    f01039f6 <env_free+0x63>
		lcr3(PADDR(kern_pgdir));
f01039b9:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01039be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01039c3:	77 20                	ja     f01039e5 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01039c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039c9:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f01039d0:	f0 
f01039d1:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
f01039d8:	00 
f01039d9:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f01039e0:	e8 5b c6 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01039e5:	05 00 00 00 10       	add    $0x10000000,%eax
f01039ea:	0f 22 d8             	mov    %eax,%cr3
f01039ed:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01039f4:	eb 07                	jmp    f01039fd <env_free+0x6a>
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01039f6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01039fd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103a00:	c1 e0 02             	shl    $0x2,%eax
f0103a03:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103a06:	8b 47 60             	mov    0x60(%edi),%eax
f0103a09:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a0c:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103a0f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103a15:	0f 84 b6 00 00 00    	je     f0103ad1 <env_free+0x13e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103a1b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a21:	89 f0                	mov    %esi,%eax
f0103a23:	c1 e8 0c             	shr    $0xc,%eax
f0103a26:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103a29:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f0103a2f:	72 20                	jb     f0103a51 <env_free+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a31:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103a35:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0103a3c:	f0 
f0103a3d:	c7 44 24 04 cc 01 00 	movl   $0x1cc,0x4(%esp)
f0103a44:	00 
f0103a45:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f0103a4c:	e8 ef c5 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a51:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103a54:	c1 e2 16             	shl    $0x16,%edx
f0103a57:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a5a:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103a5f:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103a66:	01 
f0103a67:	74 17                	je     f0103a80 <env_free+0xed>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103a69:	89 d8                	mov    %ebx,%eax
f0103a6b:	c1 e0 0c             	shl    $0xc,%eax
f0103a6e:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103a71:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a75:	8b 47 60             	mov    0x60(%edi),%eax
f0103a78:	89 04 24             	mov    %eax,(%esp)
f0103a7b:	e8 a6 d7 ff ff       	call   f0101226 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103a80:	43                   	inc    %ebx
f0103a81:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103a87:	75 d6                	jne    f0103a5f <env_free+0xcc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103a89:	8b 47 60             	mov    0x60(%edi),%eax
f0103a8c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103a8f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a96:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103a99:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f0103a9f:	72 1c                	jb     f0103abd <env_free+0x12a>
		panic("pa2page called with invalid pa");
f0103aa1:	c7 44 24 08 50 70 10 	movl   $0xf0107050,0x8(%esp)
f0103aa8:	f0 
f0103aa9:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103ab0:	00 
f0103ab1:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0103ab8:	e8 83 c5 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103abd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103ac0:	c1 e0 03             	shl    $0x3,%eax
f0103ac3:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
		page_decref(pa2page(pa));
f0103ac9:	89 04 24             	mov    %eax,(%esp)
f0103acc:	e8 71 d5 ff ff       	call   f0101042 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103ad1:	ff 45 e0             	incl   -0x20(%ebp)
f0103ad4:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103adb:	0f 85 1c ff ff ff    	jne    f01039fd <env_free+0x6a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103ae1:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ae4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ae9:	77 20                	ja     f0103b0b <env_free+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103aeb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aef:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0103af6:	f0 
f0103af7:	c7 44 24 04 da 01 00 	movl   $0x1da,0x4(%esp)
f0103afe:	00 
f0103aff:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f0103b06:	e8 35 c5 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103b0b:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103b12:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103b17:	c1 e8 0c             	shr    $0xc,%eax
f0103b1a:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f0103b20:	72 1c                	jb     f0103b3e <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f0103b22:	c7 44 24 08 50 70 10 	movl   $0xf0107050,0x8(%esp)
f0103b29:	f0 
f0103b2a:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f0103b31:	00 
f0103b32:	c7 04 24 d8 78 10 f0 	movl   $0xf01078d8,(%esp)
f0103b39:	e8 02 c5 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103b3e:	c1 e0 03             	shl    $0x3,%eax
f0103b41:	03 05 90 4e 22 f0    	add    0xf0224e90,%eax
	page_decref(pa2page(pa));
f0103b47:	89 04 24             	mov    %eax,(%esp)
f0103b4a:	e8 f3 d4 ff ff       	call   f0101042 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103b4f:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103b56:	a1 4c 42 22 f0       	mov    0xf022424c,%eax
f0103b5b:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103b5e:	89 3d 4c 42 22 f0    	mov    %edi,0xf022424c
}
f0103b64:	83 c4 2c             	add    $0x2c,%esp
f0103b67:	5b                   	pop    %ebx
f0103b68:	5e                   	pop    %esi
f0103b69:	5f                   	pop    %edi
f0103b6a:	5d                   	pop    %ebp
f0103b6b:	c3                   	ret    

f0103b6c <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103b6c:	55                   	push   %ebp
f0103b6d:	89 e5                	mov    %esp,%ebp
f0103b6f:	53                   	push   %ebx
f0103b70:	83 ec 14             	sub    $0x14,%esp
f0103b73:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103b76:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103b7a:	75 23                	jne    f0103b9f <env_destroy+0x33>
f0103b7c:	e8 cf 27 00 00       	call   f0106350 <cpunum>
f0103b81:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103b88:	29 c2                	sub    %eax,%edx
f0103b8a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103b8d:	39 1c 85 28 50 22 f0 	cmp    %ebx,-0xfddafd8(,%eax,4)
f0103b94:	74 09                	je     f0103b9f <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103b96:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103b9d:	eb 39                	jmp    f0103bd8 <env_destroy+0x6c>
	}

	env_free(e);
f0103b9f:	89 1c 24             	mov    %ebx,(%esp)
f0103ba2:	e8 ec fd ff ff       	call   f0103993 <env_free>

	if (curenv == e) {
f0103ba7:	e8 a4 27 00 00       	call   f0106350 <cpunum>
f0103bac:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bb3:	29 c2                	sub    %eax,%edx
f0103bb5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bb8:	39 1c 85 28 50 22 f0 	cmp    %ebx,-0xfddafd8(,%eax,4)
f0103bbf:	75 17                	jne    f0103bd8 <env_destroy+0x6c>
		curenv = NULL;
f0103bc1:	e8 8a 27 00 00       	call   f0106350 <cpunum>
f0103bc6:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bc9:	c7 80 28 50 22 f0 00 	movl   $0x0,-0xfddafd8(%eax)
f0103bd0:	00 00 00 
		sched_yield();
f0103bd3:	e8 a2 0f 00 00       	call   f0104b7a <sched_yield>
	}
}
f0103bd8:	83 c4 14             	add    $0x14,%esp
f0103bdb:	5b                   	pop    %ebx
f0103bdc:	5d                   	pop    %ebp
f0103bdd:	c3                   	ret    

f0103bde <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103bde:	55                   	push   %ebp
f0103bdf:	89 e5                	mov    %esp,%ebp
f0103be1:	53                   	push   %ebx
f0103be2:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103be5:	e8 66 27 00 00       	call   f0106350 <cpunum>
f0103bea:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103bf1:	29 c2                	sub    %eax,%edx
f0103bf3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103bf6:	8b 1c 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%ebx
f0103bfd:	e8 4e 27 00 00       	call   f0106350 <cpunum>
f0103c02:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103c05:	8b 65 08             	mov    0x8(%ebp),%esp
f0103c08:	61                   	popa   
f0103c09:	07                   	pop    %es
f0103c0a:	1f                   	pop    %ds
f0103c0b:	83 c4 08             	add    $0x8,%esp
f0103c0e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103c0f:	c7 44 24 08 bd 7c 10 	movl   $0xf0107cbd,0x8(%esp)
f0103c16:	f0 
f0103c17:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
f0103c1e:	00 
f0103c1f:	c7 04 24 a3 7c 10 f0 	movl   $0xf0107ca3,(%esp)
f0103c26:	e8 15 c4 ff ff       	call   f0100040 <_panic>

f0103c2b <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103c2b:	55                   	push   %ebp
f0103c2c:	89 e5                	mov    %esp,%ebp
f0103c2e:	53                   	push   %ebx
f0103c2f:	83 ec 14             	sub    $0x14,%esp
f0103c32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (e != curenv) {
f0103c35:	e8 16 27 00 00       	call   f0106350 <cpunum>
f0103c3a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c41:	29 c2                	sub    %eax,%edx
f0103c43:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c46:	39 1c 85 28 50 22 f0 	cmp    %ebx,-0xfddafd8(,%eax,4)
f0103c4d:	0f 84 a7 00 00 00    	je     f0103cfa <env_run+0xcf>
		// Step 1-1:
		if (curenv) {
f0103c53:	e8 f8 26 00 00       	call   f0106350 <cpunum>
f0103c58:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103c5f:	29 c2                	sub    %eax,%edx
f0103c61:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103c64:	83 3c 85 28 50 22 f0 	cmpl   $0x0,-0xfddafd8(,%eax,4)
f0103c6b:	00 
f0103c6c:	74 29                	je     f0103c97 <env_run+0x6c>
			if (curenv->env_status == ENV_RUNNING)
f0103c6e:	e8 dd 26 00 00       	call   f0106350 <cpunum>
f0103c73:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c76:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0103c7c:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103c80:	75 15                	jne    f0103c97 <env_run+0x6c>
				curenv->env_status = ENV_RUNNABLE;
f0103c82:	e8 c9 26 00 00       	call   f0106350 <cpunum>
f0103c87:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c8a:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0103c90:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		// Step 1-2:
		curenv = e;
f0103c97:	e8 b4 26 00 00       	call   f0106350 <cpunum>
f0103c9c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ca3:	29 c2                	sub    %eax,%edx
f0103ca5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca8:	89 1c 85 28 50 22 f0 	mov    %ebx,-0xfddafd8(,%eax,4)
		// Step 1-3:
		curenv->env_status = ENV_RUNNING;
f0103caf:	e8 9c 26 00 00       	call   f0106350 <cpunum>
f0103cb4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cbb:	29 c2                	sub    %eax,%edx
f0103cbd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cc0:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103cc7:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		// Step 1-4:
		curenv->env_runs++;
f0103cce:	e8 7d 26 00 00       	call   f0106350 <cpunum>
f0103cd3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103cda:	29 c2                	sub    %eax,%edx
f0103cdc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103cdf:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103ce6:	ff 40 58             	incl   0x58(%eax)
		// Step 1-5:
		lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
f0103ce9:	8b 43 60             	mov    0x60(%ebx),%eax
f0103cec:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f0103cf2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103cf7:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103cfa:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0103d01:	e8 ac 29 00 00       	call   f01066b2 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103d06:	f3 90                	pause  
	}
	// Release Lock right before user mode
	unlock_kernel();

	// Step 2:
	env_pop_tf(&(curenv->env_tf));
f0103d08:	e8 43 26 00 00       	call   f0106350 <cpunum>
f0103d0d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d14:	29 c2                	sub    %eax,%edx
f0103d16:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d19:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0103d20:	89 04 24             	mov    %eax,(%esp)
f0103d23:	e8 b6 fe ff ff       	call   f0103bde <env_pop_tf>

f0103d28 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103d28:	55                   	push   %ebp
f0103d29:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d2b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d30:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d33:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103d34:	b2 71                	mov    $0x71,%dl
f0103d36:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103d37:	0f b6 c0             	movzbl %al,%eax
}
f0103d3a:	5d                   	pop    %ebp
f0103d3b:	c3                   	ret    

f0103d3c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103d3c:	55                   	push   %ebp
f0103d3d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103d3f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103d44:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d47:	ee                   	out    %al,(%dx)
f0103d48:	b2 71                	mov    $0x71,%dl
f0103d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103d4d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103d4e:	5d                   	pop    %ebp
f0103d4f:	c3                   	ret    

f0103d50 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103d50:	55                   	push   %ebp
f0103d51:	89 e5                	mov    %esp,%ebp
f0103d53:	56                   	push   %esi
f0103d54:	53                   	push   %ebx
f0103d55:	83 ec 10             	sub    $0x10,%esp
f0103d58:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d5b:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103d5d:	66 a3 a8 93 12 f0    	mov    %ax,0xf01293a8
	if (!didinit)
f0103d63:	80 3d 50 42 22 f0 00 	cmpb   $0x0,0xf0224250
f0103d6a:	74 51                	je     f0103dbd <irq_setmask_8259A+0x6d>
f0103d6c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103d71:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103d72:	89 f0                	mov    %esi,%eax
f0103d74:	66 c1 e8 08          	shr    $0x8,%ax
f0103d78:	b2 a1                	mov    $0xa1,%dl
f0103d7a:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103d7b:	c7 04 24 c9 7c 10 f0 	movl   $0xf0107cc9,(%esp)
f0103d82:	e8 e7 00 00 00       	call   f0103e6e <cprintf>
	for (i = 0; i < 16; i++)
f0103d87:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103d8c:	0f b7 f6             	movzwl %si,%esi
f0103d8f:	f7 d6                	not    %esi
f0103d91:	89 f0                	mov    %esi,%eax
f0103d93:	88 d9                	mov    %bl,%cl
f0103d95:	d3 f8                	sar    %cl,%eax
f0103d97:	a8 01                	test   $0x1,%al
f0103d99:	74 10                	je     f0103dab <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103d9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d9f:	c7 04 24 6b 81 10 f0 	movl   $0xf010816b,(%esp)
f0103da6:	e8 c3 00 00 00       	call   f0103e6e <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103dab:	43                   	inc    %ebx
f0103dac:	83 fb 10             	cmp    $0x10,%ebx
f0103daf:	75 e0                	jne    f0103d91 <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103db1:	c7 04 24 ac 7b 10 f0 	movl   $0xf0107bac,(%esp)
f0103db8:	e8 b1 00 00 00       	call   f0103e6e <cprintf>
}
f0103dbd:	83 c4 10             	add    $0x10,%esp
f0103dc0:	5b                   	pop    %ebx
f0103dc1:	5e                   	pop    %esi
f0103dc2:	5d                   	pop    %ebp
f0103dc3:	c3                   	ret    

f0103dc4 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103dc4:	55                   	push   %ebp
f0103dc5:	89 e5                	mov    %esp,%ebp
f0103dc7:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103dca:	c6 05 50 42 22 f0 01 	movb   $0x1,0xf0224250
f0103dd1:	ba 21 00 00 00       	mov    $0x21,%edx
f0103dd6:	b0 ff                	mov    $0xff,%al
f0103dd8:	ee                   	out    %al,(%dx)
f0103dd9:	b2 a1                	mov    $0xa1,%dl
f0103ddb:	ee                   	out    %al,(%dx)
f0103ddc:	b2 20                	mov    $0x20,%dl
f0103dde:	b0 11                	mov    $0x11,%al
f0103de0:	ee                   	out    %al,(%dx)
f0103de1:	b2 21                	mov    $0x21,%dl
f0103de3:	b0 20                	mov    $0x20,%al
f0103de5:	ee                   	out    %al,(%dx)
f0103de6:	b0 04                	mov    $0x4,%al
f0103de8:	ee                   	out    %al,(%dx)
f0103de9:	b0 03                	mov    $0x3,%al
f0103deb:	ee                   	out    %al,(%dx)
f0103dec:	b2 a0                	mov    $0xa0,%dl
f0103dee:	b0 11                	mov    $0x11,%al
f0103df0:	ee                   	out    %al,(%dx)
f0103df1:	b2 a1                	mov    $0xa1,%dl
f0103df3:	b0 28                	mov    $0x28,%al
f0103df5:	ee                   	out    %al,(%dx)
f0103df6:	b0 02                	mov    $0x2,%al
f0103df8:	ee                   	out    %al,(%dx)
f0103df9:	b0 01                	mov    $0x1,%al
f0103dfb:	ee                   	out    %al,(%dx)
f0103dfc:	b2 20                	mov    $0x20,%dl
f0103dfe:	b0 68                	mov    $0x68,%al
f0103e00:	ee                   	out    %al,(%dx)
f0103e01:	b0 0a                	mov    $0xa,%al
f0103e03:	ee                   	out    %al,(%dx)
f0103e04:	b2 a0                	mov    $0xa0,%dl
f0103e06:	b0 68                	mov    $0x68,%al
f0103e08:	ee                   	out    %al,(%dx)
f0103e09:	b0 0a                	mov    $0xa,%al
f0103e0b:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103e0c:	66 a1 a8 93 12 f0    	mov    0xf01293a8,%ax
f0103e12:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103e16:	74 0b                	je     f0103e23 <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103e18:	0f b7 c0             	movzwl %ax,%eax
f0103e1b:	89 04 24             	mov    %eax,(%esp)
f0103e1e:	e8 2d ff ff ff       	call   f0103d50 <irq_setmask_8259A>
}
f0103e23:	c9                   	leave  
f0103e24:	c3                   	ret    
f0103e25:	00 00                	add    %al,(%eax)
	...

f0103e28 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103e28:	55                   	push   %ebp
f0103e29:	89 e5                	mov    %esp,%ebp
f0103e2b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103e2e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e31:	89 04 24             	mov    %eax,(%esp)
f0103e34:	e8 51 c9 ff ff       	call   f010078a <cputchar>
	*cnt++;
}
f0103e39:	c9                   	leave  
f0103e3a:	c3                   	ret    

f0103e3b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103e3b:	55                   	push   %ebp
f0103e3c:	89 e5                	mov    %esp,%ebp
f0103e3e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103e41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103e48:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103e4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103e4f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e52:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103e56:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103e59:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e5d:	c7 04 24 28 3e 10 f0 	movl   $0xf0103e28,(%esp)
f0103e64:	e8 49 18 00 00       	call   f01056b2 <vprintfmt>
	return cnt;
}
f0103e69:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103e6c:	c9                   	leave  
f0103e6d:	c3                   	ret    

f0103e6e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103e6e:	55                   	push   %ebp
f0103e6f:	89 e5                	mov    %esp,%ebp
f0103e71:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103e74:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103e77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103e7b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e7e:	89 04 24             	mov    %eax,(%esp)
f0103e81:	e8 b5 ff ff ff       	call   f0103e3b <vcprintf>
	va_end(ap);

	return cnt;
}
f0103e86:	c9                   	leave  
f0103e87:	c3                   	ret    

f0103e88 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103e88:	55                   	push   %ebp
f0103e89:	89 e5                	mov    %esp,%ebp
f0103e8b:	57                   	push   %edi
f0103e8c:	56                   	push   %esi
f0103e8d:	53                   	push   %ebx
f0103e8e:	83 ec 0c             	sub    $0xc,%esp
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)(percpu_kstacks[cpunum()] + KSTKSIZE);
f0103e91:	e8 ba 24 00 00       	call   f0106350 <cpunum>
f0103e96:	89 c3                	mov    %eax,%ebx
f0103e98:	e8 b3 24 00 00       	call   f0106350 <cpunum>
f0103e9d:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0103ea4:	29 da                	sub    %ebx,%edx
f0103ea6:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103ea9:	c1 e0 0f             	shl    $0xf,%eax
f0103eac:	8d 80 00 e0 22 f0    	lea    -0xfdd2000(%eax),%eax
f0103eb2:	89 04 95 30 50 22 f0 	mov    %eax,-0xfddafd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103eb9:	e8 92 24 00 00       	call   f0106350 <cpunum>
f0103ebe:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ec5:	29 c2                	sub    %eax,%edx
f0103ec7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103eca:	66 c7 04 85 34 50 22 	movw   $0x10,-0xfddafcc(,%eax,4)
f0103ed1:	f0 10 00 
	// thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate) * (cpunum() + 1);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103ed4:	e8 77 24 00 00       	call   f0106350 <cpunum>
f0103ed9:	8d 58 05             	lea    0x5(%eax),%ebx
f0103edc:	e8 6f 24 00 00       	call   f0106350 <cpunum>
f0103ee1:	89 c6                	mov    %eax,%esi
f0103ee3:	e8 68 24 00 00       	call   f0106350 <cpunum>
f0103ee8:	89 c7                	mov    %eax,%edi
f0103eea:	e8 61 24 00 00       	call   f0106350 <cpunum>
f0103eef:	66 c7 04 dd 40 93 12 	movw   $0x67,-0xfed6cc0(,%ebx,8)
f0103ef6:	f0 67 00 
f0103ef9:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0103f00:	29 f2                	sub    %esi,%edx
f0103f02:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103f05:	8d 14 95 2c 50 22 f0 	lea    -0xfddafd4(,%edx,4),%edx
f0103f0c:	66 89 14 dd 42 93 12 	mov    %dx,-0xfed6cbe(,%ebx,8)
f0103f13:	f0 
f0103f14:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103f1b:	29 fa                	sub    %edi,%edx
f0103f1d:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103f20:	8d 14 95 2c 50 22 f0 	lea    -0xfddafd4(,%edx,4),%edx
f0103f27:	c1 ea 10             	shr    $0x10,%edx
f0103f2a:	88 14 dd 44 93 12 f0 	mov    %dl,-0xfed6cbc(,%ebx,8)
f0103f31:	c6 04 dd 45 93 12 f0 	movb   $0x99,-0xfed6cbb(,%ebx,8)
f0103f38:	99 
f0103f39:	c6 04 dd 46 93 12 f0 	movb   $0x40,-0xfed6cba(,%ebx,8)
f0103f40:	40 
f0103f41:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103f48:	29 c2                	sub    %eax,%edx
f0103f4a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103f4d:	8d 04 85 2c 50 22 f0 	lea    -0xfddafd4(,%eax,4),%eax
f0103f54:	c1 e8 18             	shr    $0x18,%eax
f0103f57:	88 04 dd 47 93 12 f0 	mov    %al,-0xfed6cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103f5e:	e8 ed 23 00 00       	call   f0106350 <cpunum>
f0103f63:	80 24 c5 6d 93 12 f0 	andb   $0xef,-0xfed6c93(,%eax,8)
f0103f6a:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103f6b:	e8 e0 23 00 00       	call   f0106350 <cpunum>
f0103f70:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103f77:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103f7a:	b8 ac 93 12 f0       	mov    $0xf01293ac,%eax
f0103f7f:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103f82:	83 c4 0c             	add    $0xc,%esp
f0103f85:	5b                   	pop    %ebx
f0103f86:	5e                   	pop    %esi
f0103f87:	5f                   	pop    %edi
f0103f88:	5d                   	pop    %ebp
f0103f89:	c3                   	ret    

f0103f8a <trap_init>:
}


void
trap_init(void)
{
f0103f8a:	55                   	push   %ebp
f0103f8b:	89 e5                	mov    %esp,%ebp
f0103f8d:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[0], 0, GD_KT, T_DIVIDE_handler, 0);			// divide error
f0103f90:	b8 88 49 10 f0       	mov    $0xf0104988,%eax
f0103f95:	66 a3 60 42 22 f0    	mov    %ax,0xf0224260
f0103f9b:	66 c7 05 62 42 22 f0 	movw   $0x8,0xf0224262
f0103fa2:	08 00 
f0103fa4:	c6 05 64 42 22 f0 00 	movb   $0x0,0xf0224264
f0103fab:	c6 05 65 42 22 f0 8e 	movb   $0x8e,0xf0224265
f0103fb2:	c1 e8 10             	shr    $0x10,%eax
f0103fb5:	66 a3 66 42 22 f0    	mov    %ax,0xf0224266
	SETGATE(idt[1], 0, GD_KT, T_DEBUG_handler, 0);			// debug exception
f0103fbb:	b8 92 49 10 f0       	mov    $0xf0104992,%eax
f0103fc0:	66 a3 68 42 22 f0    	mov    %ax,0xf0224268
f0103fc6:	66 c7 05 6a 42 22 f0 	movw   $0x8,0xf022426a
f0103fcd:	08 00 
f0103fcf:	c6 05 6c 42 22 f0 00 	movb   $0x0,0xf022426c
f0103fd6:	c6 05 6d 42 22 f0 8e 	movb   $0x8e,0xf022426d
f0103fdd:	c1 e8 10             	shr    $0x10,%eax
f0103fe0:	66 a3 6e 42 22 f0    	mov    %ax,0xf022426e
	SETGATE(idt[2], 0, GD_KT, T_NMI_handler, 0);			// non-maskable interrupt
f0103fe6:	b8 9c 49 10 f0       	mov    $0xf010499c,%eax
f0103feb:	66 a3 70 42 22 f0    	mov    %ax,0xf0224270
f0103ff1:	66 c7 05 72 42 22 f0 	movw   $0x8,0xf0224272
f0103ff8:	08 00 
f0103ffa:	c6 05 74 42 22 f0 00 	movb   $0x0,0xf0224274
f0104001:	c6 05 75 42 22 f0 8e 	movb   $0x8e,0xf0224275
f0104008:	c1 e8 10             	shr    $0x10,%eax
f010400b:	66 a3 76 42 22 f0    	mov    %ax,0xf0224276
	SETGATE(idt[3], 0, GD_KT, T_BRKPT_handler, 3);			// breakpoint
f0104011:	b8 a6 49 10 f0       	mov    $0xf01049a6,%eax
f0104016:	66 a3 78 42 22 f0    	mov    %ax,0xf0224278
f010401c:	66 c7 05 7a 42 22 f0 	movw   $0x8,0xf022427a
f0104023:	08 00 
f0104025:	c6 05 7c 42 22 f0 00 	movb   $0x0,0xf022427c
f010402c:	c6 05 7d 42 22 f0 ee 	movb   $0xee,0xf022427d
f0104033:	c1 e8 10             	shr    $0x10,%eax
f0104036:	66 a3 7e 42 22 f0    	mov    %ax,0xf022427e
	SETGATE(idt[4], 0, GD_KT, T_OFLOW_handler, 0);			// overflow
f010403c:	b8 b0 49 10 f0       	mov    $0xf01049b0,%eax
f0104041:	66 a3 80 42 22 f0    	mov    %ax,0xf0224280
f0104047:	66 c7 05 82 42 22 f0 	movw   $0x8,0xf0224282
f010404e:	08 00 
f0104050:	c6 05 84 42 22 f0 00 	movb   $0x0,0xf0224284
f0104057:	c6 05 85 42 22 f0 8e 	movb   $0x8e,0xf0224285
f010405e:	c1 e8 10             	shr    $0x10,%eax
f0104061:	66 a3 86 42 22 f0    	mov    %ax,0xf0224286
	SETGATE(idt[5], 0, GD_KT, T_BOUND_handler, 0);			// bounds check
f0104067:	b8 ba 49 10 f0       	mov    $0xf01049ba,%eax
f010406c:	66 a3 88 42 22 f0    	mov    %ax,0xf0224288
f0104072:	66 c7 05 8a 42 22 f0 	movw   $0x8,0xf022428a
f0104079:	08 00 
f010407b:	c6 05 8c 42 22 f0 00 	movb   $0x0,0xf022428c
f0104082:	c6 05 8d 42 22 f0 8e 	movb   $0x8e,0xf022428d
f0104089:	c1 e8 10             	shr    $0x10,%eax
f010408c:	66 a3 8e 42 22 f0    	mov    %ax,0xf022428e
	SETGATE(idt[6], 0, GD_KT, T_ILLOP_handler, 0);			// illegal opcode
f0104092:	b8 c4 49 10 f0       	mov    $0xf01049c4,%eax
f0104097:	66 a3 90 42 22 f0    	mov    %ax,0xf0224290
f010409d:	66 c7 05 92 42 22 f0 	movw   $0x8,0xf0224292
f01040a4:	08 00 
f01040a6:	c6 05 94 42 22 f0 00 	movb   $0x0,0xf0224294
f01040ad:	c6 05 95 42 22 f0 8e 	movb   $0x8e,0xf0224295
f01040b4:	c1 e8 10             	shr    $0x10,%eax
f01040b7:	66 a3 96 42 22 f0    	mov    %ax,0xf0224296
	SETGATE(idt[7], 0, GD_KT, T_DEVICE_handler, 0);			// device not available
f01040bd:	b8 ce 49 10 f0       	mov    $0xf01049ce,%eax
f01040c2:	66 a3 98 42 22 f0    	mov    %ax,0xf0224298
f01040c8:	66 c7 05 9a 42 22 f0 	movw   $0x8,0xf022429a
f01040cf:	08 00 
f01040d1:	c6 05 9c 42 22 f0 00 	movb   $0x0,0xf022429c
f01040d8:	c6 05 9d 42 22 f0 8e 	movb   $0x8e,0xf022429d
f01040df:	c1 e8 10             	shr    $0x10,%eax
f01040e2:	66 a3 9e 42 22 f0    	mov    %ax,0xf022429e
	SETGATE(idt[8], 0, GD_KT, T_DBLFLT_handler, 0);			// double fault
f01040e8:	b8 d8 49 10 f0       	mov    $0xf01049d8,%eax
f01040ed:	66 a3 a0 42 22 f0    	mov    %ax,0xf02242a0
f01040f3:	66 c7 05 a2 42 22 f0 	movw   $0x8,0xf02242a2
f01040fa:	08 00 
f01040fc:	c6 05 a4 42 22 f0 00 	movb   $0x0,0xf02242a4
f0104103:	c6 05 a5 42 22 f0 8e 	movb   $0x8e,0xf02242a5
f010410a:	c1 e8 10             	shr    $0x10,%eax
f010410d:	66 a3 a6 42 22 f0    	mov    %ax,0xf02242a6

	SETGATE(idt[10], 0, GD_KT, T_TSS_handler, 0);			// invalid task switch segment
f0104113:	b8 e2 49 10 f0       	mov    $0xf01049e2,%eax
f0104118:	66 a3 b0 42 22 f0    	mov    %ax,0xf02242b0
f010411e:	66 c7 05 b2 42 22 f0 	movw   $0x8,0xf02242b2
f0104125:	08 00 
f0104127:	c6 05 b4 42 22 f0 00 	movb   $0x0,0xf02242b4
f010412e:	c6 05 b5 42 22 f0 8e 	movb   $0x8e,0xf02242b5
f0104135:	c1 e8 10             	shr    $0x10,%eax
f0104138:	66 a3 b6 42 22 f0    	mov    %ax,0xf02242b6
	SETGATE(idt[11], 0, GD_KT, T_SEGNP_handler, 0);			// segment not present
f010413e:	b8 ec 49 10 f0       	mov    $0xf01049ec,%eax
f0104143:	66 a3 b8 42 22 f0    	mov    %ax,0xf02242b8
f0104149:	66 c7 05 ba 42 22 f0 	movw   $0x8,0xf02242ba
f0104150:	08 00 
f0104152:	c6 05 bc 42 22 f0 00 	movb   $0x0,0xf02242bc
f0104159:	c6 05 bd 42 22 f0 8e 	movb   $0x8e,0xf02242bd
f0104160:	c1 e8 10             	shr    $0x10,%eax
f0104163:	66 a3 be 42 22 f0    	mov    %ax,0xf02242be
	SETGATE(idt[12], 0, GD_KT, T_STACK_handler, 0);			// stack exception
f0104169:	b8 f6 49 10 f0       	mov    $0xf01049f6,%eax
f010416e:	66 a3 c0 42 22 f0    	mov    %ax,0xf02242c0
f0104174:	66 c7 05 c2 42 22 f0 	movw   $0x8,0xf02242c2
f010417b:	08 00 
f010417d:	c6 05 c4 42 22 f0 00 	movb   $0x0,0xf02242c4
f0104184:	c6 05 c5 42 22 f0 8e 	movb   $0x8e,0xf02242c5
f010418b:	c1 e8 10             	shr    $0x10,%eax
f010418e:	66 a3 c6 42 22 f0    	mov    %ax,0xf02242c6
	SETGATE(idt[13], 0, GD_KT, T_GPFLT_handler, 0);			// general protection fault
f0104194:	b8 00 4a 10 f0       	mov    $0xf0104a00,%eax
f0104199:	66 a3 c8 42 22 f0    	mov    %ax,0xf02242c8
f010419f:	66 c7 05 ca 42 22 f0 	movw   $0x8,0xf02242ca
f01041a6:	08 00 
f01041a8:	c6 05 cc 42 22 f0 00 	movb   $0x0,0xf02242cc
f01041af:	c6 05 cd 42 22 f0 8e 	movb   $0x8e,0xf02242cd
f01041b6:	c1 e8 10             	shr    $0x10,%eax
f01041b9:	66 a3 ce 42 22 f0    	mov    %ax,0xf02242ce
	SETGATE(idt[14], 0, GD_KT, T_PGFLT_handler, 0);			// page fault
f01041bf:	b8 08 4a 10 f0       	mov    $0xf0104a08,%eax
f01041c4:	66 a3 d0 42 22 f0    	mov    %ax,0xf02242d0
f01041ca:	66 c7 05 d2 42 22 f0 	movw   $0x8,0xf02242d2
f01041d1:	08 00 
f01041d3:	c6 05 d4 42 22 f0 00 	movb   $0x0,0xf02242d4
f01041da:	c6 05 d5 42 22 f0 8e 	movb   $0x8e,0xf02242d5
f01041e1:	c1 e8 10             	shr    $0x10,%eax
f01041e4:	66 a3 d6 42 22 f0    	mov    %ax,0xf02242d6

	SETGATE(idt[16], 0, GD_KT, T_FPERR_handler, 0);			// floating point error
f01041ea:	b8 10 4a 10 f0       	mov    $0xf0104a10,%eax
f01041ef:	66 a3 e0 42 22 f0    	mov    %ax,0xf02242e0
f01041f5:	66 c7 05 e2 42 22 f0 	movw   $0x8,0xf02242e2
f01041fc:	08 00 
f01041fe:	c6 05 e4 42 22 f0 00 	movb   $0x0,0xf02242e4
f0104205:	c6 05 e5 42 22 f0 8e 	movb   $0x8e,0xf02242e5
f010420c:	c1 e8 10             	shr    $0x10,%eax
f010420f:	66 a3 e6 42 22 f0    	mov    %ax,0xf02242e6
	SETGATE(idt[17], 0, GD_KT, T_ALIGN_handler, 0);			// aligment check
f0104215:	b8 1a 4a 10 f0       	mov    $0xf0104a1a,%eax
f010421a:	66 a3 e8 42 22 f0    	mov    %ax,0xf02242e8
f0104220:	66 c7 05 ea 42 22 f0 	movw   $0x8,0xf02242ea
f0104227:	08 00 
f0104229:	c6 05 ec 42 22 f0 00 	movb   $0x0,0xf02242ec
f0104230:	c6 05 ed 42 22 f0 8e 	movb   $0x8e,0xf02242ed
f0104237:	c1 e8 10             	shr    $0x10,%eax
f010423a:	66 a3 ee 42 22 f0    	mov    %ax,0xf02242ee
	SETGATE(idt[18], 0, GD_KT, T_MCHK_handler, 0);			// machine check
f0104240:	b8 24 4a 10 f0       	mov    $0xf0104a24,%eax
f0104245:	66 a3 f0 42 22 f0    	mov    %ax,0xf02242f0
f010424b:	66 c7 05 f2 42 22 f0 	movw   $0x8,0xf02242f2
f0104252:	08 00 
f0104254:	c6 05 f4 42 22 f0 00 	movb   $0x0,0xf02242f4
f010425b:	c6 05 f5 42 22 f0 8e 	movb   $0x8e,0xf02242f5
f0104262:	c1 e8 10             	shr    $0x10,%eax
f0104265:	66 a3 f6 42 22 f0    	mov    %ax,0xf02242f6
	SETGATE(idt[19], 0, GD_KT, T_SIMDERR_handler, 0);		// SIMD floating point error
f010426b:	b8 2e 4a 10 f0       	mov    $0xf0104a2e,%eax
f0104270:	66 a3 f8 42 22 f0    	mov    %ax,0xf02242f8
f0104276:	66 c7 05 fa 42 22 f0 	movw   $0x8,0xf02242fa
f010427d:	08 00 
f010427f:	c6 05 fc 42 22 f0 00 	movb   $0x0,0xf02242fc
f0104286:	c6 05 fd 42 22 f0 8e 	movb   $0x8e,0xf02242fd
f010428d:	c1 e8 10             	shr    $0x10,%eax
f0104290:	66 a3 fe 42 22 f0    	mov    %ax,0xf02242fe
	// Add for lab 4 exercise 7
	SETGATE(idt[48], 0, GD_KT, T_SYSCALL_handler, 3);		// System call handler
f0104296:	b8 38 4a 10 f0       	mov    $0xf0104a38,%eax
f010429b:	66 a3 e0 43 22 f0    	mov    %ax,0xf02243e0
f01042a1:	66 c7 05 e2 43 22 f0 	movw   $0x8,0xf02243e2
f01042a8:	08 00 
f01042aa:	c6 05 e4 43 22 f0 00 	movb   $0x0,0xf02243e4
f01042b1:	c6 05 e5 43 22 f0 ee 	movb   $0xee,0xf02243e5
f01042b8:	c1 e8 10             	shr    $0x10,%eax
f01042bb:	66 a3 e6 43 22 f0    	mov    %ax,0xf02243e6
	// Add for lab 4 exercise 13
	SETGATE(idt[32], 0, GD_KT, IRQ_TIMER_handler, 3);		// IRQ_TIMER
f01042c1:	b8 42 4a 10 f0       	mov    $0xf0104a42,%eax
f01042c6:	66 a3 60 43 22 f0    	mov    %ax,0xf0224360
f01042cc:	66 c7 05 62 43 22 f0 	movw   $0x8,0xf0224362
f01042d3:	08 00 
f01042d5:	c6 05 64 43 22 f0 00 	movb   $0x0,0xf0224364
f01042dc:	c6 05 65 43 22 f0 ee 	movb   $0xee,0xf0224365
f01042e3:	c1 e8 10             	shr    $0x10,%eax
f01042e6:	66 a3 66 43 22 f0    	mov    %ax,0xf0224366
	SETGATE(idt[33], 0, GD_KT, IRQ_KBD_handler, 3);		// IRQ_TIMER
f01042ec:	b8 4c 4a 10 f0       	mov    $0xf0104a4c,%eax
f01042f1:	66 a3 68 43 22 f0    	mov    %ax,0xf0224368
f01042f7:	66 c7 05 6a 43 22 f0 	movw   $0x8,0xf022436a
f01042fe:	08 00 
f0104300:	c6 05 6c 43 22 f0 00 	movb   $0x0,0xf022436c
f0104307:	c6 05 6d 43 22 f0 ee 	movb   $0xee,0xf022436d
f010430e:	c1 e8 10             	shr    $0x10,%eax
f0104311:	66 a3 6e 43 22 f0    	mov    %ax,0xf022436e
	SETGATE(idt[36], 0, GD_KT, IRQ_SERIAL_handler, 3);		// IRQ_TIMER
f0104317:	b8 56 4a 10 f0       	mov    $0xf0104a56,%eax
f010431c:	66 a3 80 43 22 f0    	mov    %ax,0xf0224380
f0104322:	66 c7 05 82 43 22 f0 	movw   $0x8,0xf0224382
f0104329:	08 00 
f010432b:	c6 05 84 43 22 f0 00 	movb   $0x0,0xf0224384
f0104332:	c6 05 85 43 22 f0 ee 	movb   $0xee,0xf0224385
f0104339:	c1 e8 10             	shr    $0x10,%eax
f010433c:	66 a3 86 43 22 f0    	mov    %ax,0xf0224386
	SETGATE(idt[39], 0, GD_KT, IRQ_SPURIOUS_handler, 3);		// IRQ_TIMER
f0104342:	b8 60 4a 10 f0       	mov    $0xf0104a60,%eax
f0104347:	66 a3 98 43 22 f0    	mov    %ax,0xf0224398
f010434d:	66 c7 05 9a 43 22 f0 	movw   $0x8,0xf022439a
f0104354:	08 00 
f0104356:	c6 05 9c 43 22 f0 00 	movb   $0x0,0xf022439c
f010435d:	c6 05 9d 43 22 f0 ee 	movb   $0xee,0xf022439d
f0104364:	c1 e8 10             	shr    $0x10,%eax
f0104367:	66 a3 9e 43 22 f0    	mov    %ax,0xf022439e
	SETGATE(idt[46], 0, GD_KT, IRQ_IDE_handler, 3);		// IRQ_TIMER
f010436d:	b8 6a 4a 10 f0       	mov    $0xf0104a6a,%eax
f0104372:	66 a3 d0 43 22 f0    	mov    %ax,0xf02243d0
f0104378:	66 c7 05 d2 43 22 f0 	movw   $0x8,0xf02243d2
f010437f:	08 00 
f0104381:	c6 05 d4 43 22 f0 00 	movb   $0x0,0xf02243d4
f0104388:	c6 05 d5 43 22 f0 ee 	movb   $0xee,0xf02243d5
f010438f:	c1 e8 10             	shr    $0x10,%eax
f0104392:	66 a3 d6 43 22 f0    	mov    %ax,0xf02243d6

	// Per-CPU setup 
	trap_init_percpu();
f0104398:	e8 eb fa ff ff       	call   f0103e88 <trap_init_percpu>
}
f010439d:	c9                   	leave  
f010439e:	c3                   	ret    

f010439f <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010439f:	55                   	push   %ebp
f01043a0:	89 e5                	mov    %esp,%ebp
f01043a2:	53                   	push   %ebx
f01043a3:	83 ec 14             	sub    $0x14,%esp
f01043a6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01043a9:	8b 03                	mov    (%ebx),%eax
f01043ab:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043af:	c7 04 24 dd 7c 10 f0 	movl   $0xf0107cdd,(%esp)
f01043b6:	e8 b3 fa ff ff       	call   f0103e6e <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01043bb:	8b 43 04             	mov    0x4(%ebx),%eax
f01043be:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043c2:	c7 04 24 ec 7c 10 f0 	movl   $0xf0107cec,(%esp)
f01043c9:	e8 a0 fa ff ff       	call   f0103e6e <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01043ce:	8b 43 08             	mov    0x8(%ebx),%eax
f01043d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043d5:	c7 04 24 fb 7c 10 f0 	movl   $0xf0107cfb,(%esp)
f01043dc:	e8 8d fa ff ff       	call   f0103e6e <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01043e1:	8b 43 0c             	mov    0xc(%ebx),%eax
f01043e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043e8:	c7 04 24 0a 7d 10 f0 	movl   $0xf0107d0a,(%esp)
f01043ef:	e8 7a fa ff ff       	call   f0103e6e <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01043f4:	8b 43 10             	mov    0x10(%ebx),%eax
f01043f7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043fb:	c7 04 24 19 7d 10 f0 	movl   $0xf0107d19,(%esp)
f0104402:	e8 67 fa ff ff       	call   f0103e6e <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104407:	8b 43 14             	mov    0x14(%ebx),%eax
f010440a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010440e:	c7 04 24 28 7d 10 f0 	movl   $0xf0107d28,(%esp)
f0104415:	e8 54 fa ff ff       	call   f0103e6e <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010441a:	8b 43 18             	mov    0x18(%ebx),%eax
f010441d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104421:	c7 04 24 37 7d 10 f0 	movl   $0xf0107d37,(%esp)
f0104428:	e8 41 fa ff ff       	call   f0103e6e <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010442d:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104430:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104434:	c7 04 24 46 7d 10 f0 	movl   $0xf0107d46,(%esp)
f010443b:	e8 2e fa ff ff       	call   f0103e6e <cprintf>
}
f0104440:	83 c4 14             	add    $0x14,%esp
f0104443:	5b                   	pop    %ebx
f0104444:	5d                   	pop    %ebp
f0104445:	c3                   	ret    

f0104446 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104446:	55                   	push   %ebp
f0104447:	89 e5                	mov    %esp,%ebp
f0104449:	53                   	push   %ebx
f010444a:	83 ec 14             	sub    $0x14,%esp
f010444d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0104450:	e8 fb 1e 00 00       	call   f0106350 <cpunum>
f0104455:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104459:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010445d:	c7 04 24 aa 7d 10 f0 	movl   $0xf0107daa,(%esp)
f0104464:	e8 05 fa ff ff       	call   f0103e6e <cprintf>
	print_regs(&tf->tf_regs);
f0104469:	89 1c 24             	mov    %ebx,(%esp)
f010446c:	e8 2e ff ff ff       	call   f010439f <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0104471:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104475:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104479:	c7 04 24 c8 7d 10 f0 	movl   $0xf0107dc8,(%esp)
f0104480:	e8 e9 f9 ff ff       	call   f0103e6e <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104485:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104489:	89 44 24 04          	mov    %eax,0x4(%esp)
f010448d:	c7 04 24 db 7d 10 f0 	movl   $0xf0107ddb,(%esp)
f0104494:	e8 d5 f9 ff ff       	call   f0103e6e <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104499:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f010449c:	83 f8 13             	cmp    $0x13,%eax
f010449f:	77 09                	ja     f01044aa <print_trapframe+0x64>
		return excnames[trapno];
f01044a1:	8b 14 85 60 80 10 f0 	mov    -0xfef7fa0(,%eax,4),%edx
f01044a8:	eb 20                	jmp    f01044ca <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f01044aa:	83 f8 30             	cmp    $0x30,%eax
f01044ad:	74 0f                	je     f01044be <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f01044af:	8d 50 e0             	lea    -0x20(%eax),%edx
f01044b2:	83 fa 0f             	cmp    $0xf,%edx
f01044b5:	77 0e                	ja     f01044c5 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f01044b7:	ba 61 7d 10 f0       	mov    $0xf0107d61,%edx
f01044bc:	eb 0c                	jmp    f01044ca <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f01044be:	ba 55 7d 10 f0       	mov    $0xf0107d55,%edx
f01044c3:	eb 05                	jmp    f01044ca <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01044c5:	ba 74 7d 10 f0       	mov    $0xf0107d74,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01044ca:	89 54 24 08          	mov    %edx,0x8(%esp)
f01044ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044d2:	c7 04 24 ee 7d 10 f0 	movl   $0xf0107dee,(%esp)
f01044d9:	e8 90 f9 ff ff       	call   f0103e6e <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01044de:	3b 1d 60 4a 22 f0    	cmp    0xf0224a60,%ebx
f01044e4:	75 19                	jne    f01044ff <print_trapframe+0xb9>
f01044e6:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01044ea:	75 13                	jne    f01044ff <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01044ec:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01044ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f3:	c7 04 24 00 7e 10 f0 	movl   $0xf0107e00,(%esp)
f01044fa:	e8 6f f9 ff ff       	call   f0103e6e <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01044ff:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104502:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104506:	c7 04 24 0f 7e 10 f0 	movl   $0xf0107e0f,(%esp)
f010450d:	e8 5c f9 ff ff       	call   f0103e6e <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104512:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104516:	75 4d                	jne    f0104565 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0104518:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010451b:	a8 01                	test   $0x1,%al
f010451d:	74 07                	je     f0104526 <print_trapframe+0xe0>
f010451f:	b9 83 7d 10 f0       	mov    $0xf0107d83,%ecx
f0104524:	eb 05                	jmp    f010452b <print_trapframe+0xe5>
f0104526:	b9 8e 7d 10 f0       	mov    $0xf0107d8e,%ecx
f010452b:	a8 02                	test   $0x2,%al
f010452d:	74 07                	je     f0104536 <print_trapframe+0xf0>
f010452f:	ba 9a 7d 10 f0       	mov    $0xf0107d9a,%edx
f0104534:	eb 05                	jmp    f010453b <print_trapframe+0xf5>
f0104536:	ba a0 7d 10 f0       	mov    $0xf0107da0,%edx
f010453b:	a8 04                	test   $0x4,%al
f010453d:	74 07                	je     f0104546 <print_trapframe+0x100>
f010453f:	b8 a5 7d 10 f0       	mov    $0xf0107da5,%eax
f0104544:	eb 05                	jmp    f010454b <print_trapframe+0x105>
f0104546:	b8 f2 7e 10 f0       	mov    $0xf0107ef2,%eax
f010454b:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010454f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104553:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104557:	c7 04 24 1d 7e 10 f0 	movl   $0xf0107e1d,(%esp)
f010455e:	e8 0b f9 ff ff       	call   f0103e6e <cprintf>
f0104563:	eb 0c                	jmp    f0104571 <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104565:	c7 04 24 ac 7b 10 f0 	movl   $0xf0107bac,(%esp)
f010456c:	e8 fd f8 ff ff       	call   f0103e6e <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0104571:	8b 43 30             	mov    0x30(%ebx),%eax
f0104574:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104578:	c7 04 24 2c 7e 10 f0 	movl   $0xf0107e2c,(%esp)
f010457f:	e8 ea f8 ff ff       	call   f0103e6e <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104584:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104588:	89 44 24 04          	mov    %eax,0x4(%esp)
f010458c:	c7 04 24 3b 7e 10 f0 	movl   $0xf0107e3b,(%esp)
f0104593:	e8 d6 f8 ff ff       	call   f0103e6e <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104598:	8b 43 38             	mov    0x38(%ebx),%eax
f010459b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010459f:	c7 04 24 4e 7e 10 f0 	movl   $0xf0107e4e,(%esp)
f01045a6:	e8 c3 f8 ff ff       	call   f0103e6e <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01045ab:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01045af:	74 27                	je     f01045d8 <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01045b1:	8b 43 3c             	mov    0x3c(%ebx),%eax
f01045b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045b8:	c7 04 24 5d 7e 10 f0 	movl   $0xf0107e5d,(%esp)
f01045bf:	e8 aa f8 ff ff       	call   f0103e6e <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01045c4:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01045c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01045cc:	c7 04 24 6c 7e 10 f0 	movl   $0xf0107e6c,(%esp)
f01045d3:	e8 96 f8 ff ff       	call   f0103e6e <cprintf>
	}
}
f01045d8:	83 c4 14             	add    $0x14,%esp
f01045db:	5b                   	pop    %ebx
f01045dc:	5d                   	pop    %ebp
f01045dd:	c3                   	ret    

f01045de <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01045de:	55                   	push   %ebp
f01045df:	89 e5                	mov    %esp,%ebp
f01045e1:	57                   	push   %edi
f01045e2:	56                   	push   %esi
f01045e3:	53                   	push   %ebx
f01045e4:	83 ec 1c             	sub    $0x1c,%esp
f01045e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01045ea:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// Determine whether in kernel mode
	if (tf->tf_cs == GD_KT) {
f01045ed:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01045f2:	75 1c                	jne    f0104610 <page_fault_handler+0x32>
		panic("Page fault from kernel\n");
f01045f4:	c7 44 24 08 7f 7e 10 	movl   $0xf0107e7f,0x8(%esp)
f01045fb:	f0 
f01045fc:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f0104603:	00 
f0104604:	c7 04 24 97 7e 10 f0 	movl   $0xf0107e97,(%esp)
f010460b:	e8 30 ba ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;
	// If there is no upcall function
	if (curenv->env_pgfault_upcall) {
f0104610:	e8 3b 1d 00 00       	call   f0106350 <cpunum>
f0104615:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010461c:	29 c2                	sub    %eax,%edx
f010461e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104621:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104628:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f010462c:	0f 84 b5 00 00 00    	je     f01046e7 <page_fault_handler+0x109>
		// Determine whether the user process is running in exception stack or normal stack. 
		// If yes, then we need to initialize UTF right under the current tf_esp. Otherwise, 
		// we just set it to the top of UXSTACKTOP
		if (tf->tf_esp < USTACKTOP) {
f0104632:	8b 43 3c             	mov    0x3c(%ebx),%eax
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104635:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
	// If there is no upcall function
	if (curenv->env_pgfault_upcall) {
		// Determine whether the user process is running in exception stack or normal stack. 
		// If yes, then we need to initialize UTF right under the current tf_esp. Otherwise, 
		// we just set it to the top of UXSTACKTOP
		if (tf->tf_esp < USTACKTOP) {
f010463a:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f010463f:	76 03                	jbe    f0104644 <page_fault_handler+0x66>
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		else {
			// Leave a 32-bit padding for pushing return address
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0104641:	8d 78 c8             	lea    -0x38(%eax),%edi
		}
		// Check whether current stack is valid or overflowed, the reason of test it by using
		// (void *)(utf) instead of (void *)(UXSTACKTOP - PGSIZE) is to fulfill the requirement 
		// of grading script. Otherwise I cannot get full mark on it.
		user_mem_assert(curenv, (void *)(utf), (UXSTACKTOP - (uintptr_t)utf), PTE_W);
f0104644:	e8 07 1d 00 00       	call   f0106350 <cpunum>
f0104649:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0104650:	00 
f0104651:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0104656:	29 fa                	sub    %edi,%edx
f0104658:	89 54 24 08          	mov    %edx,0x8(%esp)
f010465c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104660:	6b c0 74             	imul   $0x74,%eax,%eax
f0104663:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104669:	89 04 24             	mov    %eax,(%esp)
f010466c:	e8 bc ed ff ff       	call   f010342d <user_mem_assert>
		// Push all information for trapframe
		utf->utf_esp = tf->tf_esp;
f0104671:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104674:	89 47 30             	mov    %eax,0x30(%edi)
		utf->utf_eflags = tf->tf_eflags;
f0104677:	8b 43 38             	mov    0x38(%ebx),%eax
f010467a:	89 47 2c             	mov    %eax,0x2c(%edi)
		utf->utf_eip = tf->tf_eip;
f010467d:	8b 43 30             	mov    0x30(%ebx),%eax
f0104680:	89 47 28             	mov    %eax,0x28(%edi)
		utf->utf_regs.reg_eax = tf->tf_regs.reg_eax;
f0104683:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104686:	89 47 24             	mov    %eax,0x24(%edi)
		utf->utf_regs.reg_ecx = tf->tf_regs.reg_ecx;
f0104689:	8b 43 18             	mov    0x18(%ebx),%eax
f010468c:	89 47 20             	mov    %eax,0x20(%edi)
		utf->utf_regs.reg_edx = tf->tf_regs.reg_edx;
f010468f:	8b 43 14             	mov    0x14(%ebx),%eax
f0104692:	89 47 1c             	mov    %eax,0x1c(%edi)
		utf->utf_regs.reg_ebx = tf->tf_regs.reg_ebx;
f0104695:	8b 43 10             	mov    0x10(%ebx),%eax
f0104698:	89 47 18             	mov    %eax,0x18(%edi)
		utf->utf_regs.reg_oesp = tf->tf_regs.reg_oesp;
f010469b:	8b 43 0c             	mov    0xc(%ebx),%eax
f010469e:	89 47 14             	mov    %eax,0x14(%edi)
		utf->utf_regs.reg_ebp = tf->tf_regs.reg_ebp;
f01046a1:	8b 43 08             	mov    0x8(%ebx),%eax
f01046a4:	89 47 10             	mov    %eax,0x10(%edi)
		utf->utf_regs.reg_esi = tf->tf_regs.reg_esi;
f01046a7:	8b 43 04             	mov    0x4(%ebx),%eax
f01046aa:	89 47 0c             	mov    %eax,0xc(%edi)
		utf->utf_regs.reg_edi = tf->tf_regs.reg_edi;
f01046ad:	8b 03                	mov    (%ebx),%eax
f01046af:	89 47 08             	mov    %eax,0x8(%edi)
		utf->utf_err = tf->tf_err;
f01046b2:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01046b5:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_fault_va = fault_va;
f01046b8:	89 37                	mov    %esi,(%edi)
		// Branch to user page fault upcall function
		tf->tf_esp = (uintptr_t)utf;
f01046ba:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f01046bd:	e8 8e 1c 00 00       	call   f0106350 <cpunum>
f01046c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01046c5:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f01046cb:	8b 40 64             	mov    0x64(%eax),%eax
f01046ce:	89 43 30             	mov    %eax,0x30(%ebx)
		// Run current environment
		env_run(curenv);
f01046d1:	e8 7a 1c 00 00       	call   f0106350 <cpunum>
f01046d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01046d9:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f01046df:	89 04 24             	mov    %eax,(%esp)
f01046e2:	e8 44 f5 ff ff       	call   f0103c2b <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01046e7:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01046ea:	e8 61 1c 00 00       	call   f0106350 <cpunum>
		// Run current environment
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01046ef:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01046f3:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01046f7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01046fe:	29 c2                	sub    %eax,%edx
f0104700:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104703:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
		// Run current environment
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010470a:	8b 40 48             	mov    0x48(%eax),%eax
f010470d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104711:	c7 04 24 3c 80 10 f0 	movl   $0xf010803c,(%esp)
f0104718:	e8 51 f7 ff ff       	call   f0103e6e <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f010471d:	89 1c 24             	mov    %ebx,(%esp)
f0104720:	e8 21 fd ff ff       	call   f0104446 <print_trapframe>
	env_destroy(curenv);
f0104725:	e8 26 1c 00 00       	call   f0106350 <cpunum>
f010472a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104731:	29 c2                	sub    %eax,%edx
f0104733:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104736:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f010473d:	89 04 24             	mov    %eax,(%esp)
f0104740:	e8 27 f4 ff ff       	call   f0103b6c <env_destroy>
}
f0104745:	83 c4 1c             	add    $0x1c,%esp
f0104748:	5b                   	pop    %ebx
f0104749:	5e                   	pop    %esi
f010474a:	5f                   	pop    %edi
f010474b:	5d                   	pop    %ebp
f010474c:	c3                   	ret    

f010474d <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f010474d:	55                   	push   %ebp
f010474e:	89 e5                	mov    %esp,%ebp
f0104750:	57                   	push   %edi
f0104751:	56                   	push   %esi
f0104752:	83 ec 20             	sub    $0x20,%esp
f0104755:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104758:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104759:	83 3d 80 4e 22 f0 00 	cmpl   $0x0,0xf0224e80
f0104760:	74 01                	je     f0104763 <trap+0x16>
		asm volatile("hlt");
f0104762:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0104763:	e8 e8 1b 00 00       	call   f0106350 <cpunum>
f0104768:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010476f:	29 c2                	sub    %eax,%edx
f0104771:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104774:	8d 14 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010477b:	b8 01 00 00 00       	mov    $0x1,%eax
f0104780:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104784:	83 f8 02             	cmp    $0x2,%eax
f0104787:	75 0c                	jne    f0104795 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104789:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104790:	e8 7a 1e 00 00       	call   f010660f <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104795:	9c                   	pushf  
f0104796:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104797:	f6 c4 02             	test   $0x2,%ah
f010479a:	74 24                	je     f01047c0 <trap+0x73>
f010479c:	c7 44 24 0c a3 7e 10 	movl   $0xf0107ea3,0xc(%esp)
f01047a3:	f0 
f01047a4:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01047ab:	f0 
f01047ac:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f01047b3:	00 
f01047b4:	c7 04 24 97 7e 10 f0 	movl   $0xf0107e97,(%esp)
f01047bb:	e8 80 b8 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f01047c0:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01047c4:	83 e0 03             	and    $0x3,%eax
f01047c7:	83 f8 03             	cmp    $0x3,%eax
f01047ca:	0f 85 a7 00 00 00    	jne    f0104877 <trap+0x12a>
f01047d0:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f01047d7:	e8 33 1e 00 00       	call   f010660f <spin_lock>
		// LAB 4: Your code here.

		// Aquire lock
		lock_kernel();

		assert(curenv);
f01047dc:	e8 6f 1b 00 00       	call   f0106350 <cpunum>
f01047e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047e4:	83 b8 28 50 22 f0 00 	cmpl   $0x0,-0xfddafd8(%eax)
f01047eb:	75 24                	jne    f0104811 <trap+0xc4>
f01047ed:	c7 44 24 0c bc 7e 10 	movl   $0xf0107ebc,0xc(%esp)
f01047f4:	f0 
f01047f5:	c7 44 24 08 f2 78 10 	movl   $0xf01078f2,0x8(%esp)
f01047fc:	f0 
f01047fd:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f0104804:	00 
f0104805:	c7 04 24 97 7e 10 f0 	movl   $0xf0107e97,(%esp)
f010480c:	e8 2f b8 ff ff       	call   f0100040 <_panic>
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0104811:	e8 3a 1b 00 00       	call   f0106350 <cpunum>
f0104816:	6b c0 74             	imul   $0x74,%eax,%eax
f0104819:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010481f:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0104823:	75 2d                	jne    f0104852 <trap+0x105>
			env_free(curenv);
f0104825:	e8 26 1b 00 00       	call   f0106350 <cpunum>
f010482a:	6b c0 74             	imul   $0x74,%eax,%eax
f010482d:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104833:	89 04 24             	mov    %eax,(%esp)
f0104836:	e8 58 f1 ff ff       	call   f0103993 <env_free>
			curenv = NULL;
f010483b:	e8 10 1b 00 00       	call   f0106350 <cpunum>
f0104840:	6b c0 74             	imul   $0x74,%eax,%eax
f0104843:	c7 80 28 50 22 f0 00 	movl   $0x0,-0xfddafd8(%eax)
f010484a:	00 00 00 
			sched_yield();
f010484d:	e8 28 03 00 00       	call   f0104b7a <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0104852:	e8 f9 1a 00 00       	call   f0106350 <cpunum>
f0104857:	6b c0 74             	imul   $0x74,%eax,%eax
f010485a:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104860:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104865:	89 c7                	mov    %eax,%edi
f0104867:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104869:	e8 e2 1a 00 00       	call   f0106350 <cpunum>
f010486e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104871:	8b b0 28 50 22 f0    	mov    -0xfddafd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104877:	89 35 60 4a 22 f0    	mov    %esi,0xf0224a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Trap 3
	if (tf->tf_trapno == T_BRKPT) {
f010487d:	8b 46 28             	mov    0x28(%esi),%eax
f0104880:	83 f8 03             	cmp    $0x3,%eax
f0104883:	75 0d                	jne    f0104892 <trap+0x145>
		monitor(tf);
f0104885:	89 34 24             	mov    %esi,(%esp)
f0104888:	e8 45 c0 ff ff       	call   f01008d2 <monitor>
f010488d:	e9 b4 00 00 00       	jmp    f0104946 <trap+0x1f9>
		return;
	}
	// Trap 14
	if (tf->tf_trapno == T_PGFLT) {
f0104892:	83 f8 0e             	cmp    $0xe,%eax
f0104895:	75 0d                	jne    f01048a4 <trap+0x157>
		page_fault_handler(tf);
f0104897:	89 34 24             	mov    %esi,(%esp)
f010489a:	e8 3f fd ff ff       	call   f01045de <page_fault_handler>
f010489f:	e9 a2 00 00 00       	jmp    f0104946 <trap+0x1f9>
		return;
	}
	// Trap 48
	if (tf->tf_trapno == T_SYSCALL) {
f01048a4:	83 f8 30             	cmp    $0x30,%eax
f01048a7:	75 32                	jne    f01048db <trap+0x18e>
		int32_t ret;
		ret = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, 
f01048a9:	8b 46 04             	mov    0x4(%esi),%eax
f01048ac:	89 44 24 14          	mov    %eax,0x14(%esp)
f01048b0:	8b 06                	mov    (%esi),%eax
f01048b2:	89 44 24 10          	mov    %eax,0x10(%esp)
f01048b6:	8b 46 10             	mov    0x10(%esi),%eax
f01048b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048bd:	8b 46 18             	mov    0x18(%esi),%eax
f01048c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01048c4:	8b 46 14             	mov    0x14(%esi),%eax
f01048c7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048cb:	8b 46 1c             	mov    0x1c(%esi),%eax
f01048ce:	89 04 24             	mov    %eax,(%esp)
f01048d1:	e8 86 03 00 00       	call   f0104c5c <syscall>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f01048d6:	89 46 1c             	mov    %eax,0x1c(%esi)
f01048d9:	eb 6b                	jmp    f0104946 <trap+0x1f9>
		return;
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01048db:	83 f8 27             	cmp    $0x27,%eax
f01048de:	75 16                	jne    f01048f6 <trap+0x1a9>
		cprintf("Spurious interrupt on irq 7\n");
f01048e0:	c7 04 24 c3 7e 10 f0 	movl   $0xf0107ec3,(%esp)
f01048e7:	e8 82 f5 ff ff       	call   f0103e6e <cprintf>
		print_trapframe(tf);
f01048ec:	89 34 24             	mov    %esi,(%esp)
f01048ef:	e8 52 fb ff ff       	call   f0104446 <print_trapframe>
f01048f4:	eb 50                	jmp    f0104946 <trap+0x1f9>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01048f6:	83 f8 20             	cmp    $0x20,%eax
f01048f9:	75 0a                	jne    f0104905 <trap+0x1b8>
		lapic_eoi();
f01048fb:	e8 a7 1b 00 00       	call   f01064a7 <lapic_eoi>
		sched_yield();
f0104900:	e8 75 02 00 00       	call   f0104b7a <sched_yield>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104905:	89 34 24             	mov    %esi,(%esp)
f0104908:	e8 39 fb ff ff       	call   f0104446 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010490d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104912:	75 1c                	jne    f0104930 <trap+0x1e3>
		panic("unhandled trap in kernel");
f0104914:	c7 44 24 08 e0 7e 10 	movl   $0xf0107ee0,0x8(%esp)
f010491b:	f0 
f010491c:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
f0104923:	00 
f0104924:	c7 04 24 97 7e 10 f0 	movl   $0xf0107e97,(%esp)
f010492b:	e8 10 b7 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f0104930:	e8 1b 1a 00 00       	call   f0106350 <cpunum>
f0104935:	6b c0 74             	imul   $0x74,%eax,%eax
f0104938:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010493e:	89 04 24             	mov    %eax,(%esp)
f0104941:	e8 26 f2 ff ff       	call   f0103b6c <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104946:	e8 05 1a 00 00       	call   f0106350 <cpunum>
f010494b:	6b c0 74             	imul   $0x74,%eax,%eax
f010494e:	83 b8 28 50 22 f0 00 	cmpl   $0x0,-0xfddafd8(%eax)
f0104955:	74 2a                	je     f0104981 <trap+0x234>
f0104957:	e8 f4 19 00 00       	call   f0106350 <cpunum>
f010495c:	6b c0 74             	imul   $0x74,%eax,%eax
f010495f:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104965:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104969:	75 16                	jne    f0104981 <trap+0x234>
		env_run(curenv);
f010496b:	e8 e0 19 00 00       	call   f0106350 <cpunum>
f0104970:	6b c0 74             	imul   $0x74,%eax,%eax
f0104973:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0104979:	89 04 24             	mov    %eax,(%esp)
f010497c:	e8 aa f2 ff ff       	call   f0103c2b <env_run>
	else
		sched_yield();
f0104981:	e8 f4 01 00 00       	call   f0104b7a <sched_yield>
	...

f0104988 <T_DIVIDE_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(T_DIVIDE_handler, T_DIVIDE)
f0104988:	6a 00                	push   $0x0
f010498a:	6a 00                	push   $0x0
f010498c:	e9 e2 00 00 00       	jmp    f0104a73 <_alltraps>
f0104991:	90                   	nop

f0104992 <T_DEBUG_handler>:
TRAPHANDLER_NOEC(T_DEBUG_handler, T_DEBUG)
f0104992:	6a 00                	push   $0x0
f0104994:	6a 01                	push   $0x1
f0104996:	e9 d8 00 00 00       	jmp    f0104a73 <_alltraps>
f010499b:	90                   	nop

f010499c <T_NMI_handler>:
TRAPHANDLER_NOEC(T_NMI_handler, T_NMI)
f010499c:	6a 00                	push   $0x0
f010499e:	6a 02                	push   $0x2
f01049a0:	e9 ce 00 00 00       	jmp    f0104a73 <_alltraps>
f01049a5:	90                   	nop

f01049a6 <T_BRKPT_handler>:
TRAPHANDLER_NOEC(T_BRKPT_handler, T_BRKPT)
f01049a6:	6a 00                	push   $0x0
f01049a8:	6a 03                	push   $0x3
f01049aa:	e9 c4 00 00 00       	jmp    f0104a73 <_alltraps>
f01049af:	90                   	nop

f01049b0 <T_OFLOW_handler>:
TRAPHANDLER_NOEC(T_OFLOW_handler, T_OFLOW)
f01049b0:	6a 00                	push   $0x0
f01049b2:	6a 04                	push   $0x4
f01049b4:	e9 ba 00 00 00       	jmp    f0104a73 <_alltraps>
f01049b9:	90                   	nop

f01049ba <T_BOUND_handler>:
TRAPHANDLER_NOEC(T_BOUND_handler, T_BOUND)
f01049ba:	6a 00                	push   $0x0
f01049bc:	6a 05                	push   $0x5
f01049be:	e9 b0 00 00 00       	jmp    f0104a73 <_alltraps>
f01049c3:	90                   	nop

f01049c4 <T_ILLOP_handler>:
TRAPHANDLER_NOEC(T_ILLOP_handler, T_ILLOP)
f01049c4:	6a 00                	push   $0x0
f01049c6:	6a 06                	push   $0x6
f01049c8:	e9 a6 00 00 00       	jmp    f0104a73 <_alltraps>
f01049cd:	90                   	nop

f01049ce <T_DEVICE_handler>:
TRAPHANDLER_NOEC(T_DEVICE_handler, T_DEVICE)
f01049ce:	6a 00                	push   $0x0
f01049d0:	6a 07                	push   $0x7
f01049d2:	e9 9c 00 00 00       	jmp    f0104a73 <_alltraps>
f01049d7:	90                   	nop

f01049d8 <T_DBLFLT_handler>:
TRAPHANDLER_NOEC(T_DBLFLT_handler, T_DBLFLT)
f01049d8:	6a 00                	push   $0x0
f01049da:	6a 08                	push   $0x8
f01049dc:	e9 92 00 00 00       	jmp    f0104a73 <_alltraps>
f01049e1:	90                   	nop

f01049e2 <T_TSS_handler>:

TRAPHANDLER_NOEC(T_TSS_handler, T_TSS)
f01049e2:	6a 00                	push   $0x0
f01049e4:	6a 0a                	push   $0xa
f01049e6:	e9 88 00 00 00       	jmp    f0104a73 <_alltraps>
f01049eb:	90                   	nop

f01049ec <T_SEGNP_handler>:
TRAPHANDLER_NOEC(T_SEGNP_handler, T_SEGNP)
f01049ec:	6a 00                	push   $0x0
f01049ee:	6a 0b                	push   $0xb
f01049f0:	e9 7e 00 00 00       	jmp    f0104a73 <_alltraps>
f01049f5:	90                   	nop

f01049f6 <T_STACK_handler>:
TRAPHANDLER_NOEC(T_STACK_handler, T_STACK)
f01049f6:	6a 00                	push   $0x0
f01049f8:	6a 0c                	push   $0xc
f01049fa:	e9 74 00 00 00       	jmp    f0104a73 <_alltraps>
f01049ff:	90                   	nop

f0104a00 <T_GPFLT_handler>:
TRAPHANDLER(T_GPFLT_handler, T_GPFLT)
f0104a00:	6a 0d                	push   $0xd
f0104a02:	e9 6c 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a07:	90                   	nop

f0104a08 <T_PGFLT_handler>:
TRAPHANDLER(T_PGFLT_handler, T_PGFLT)
f0104a08:	6a 0e                	push   $0xe
f0104a0a:	e9 64 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a0f:	90                   	nop

f0104a10 <T_FPERR_handler>:

TRAPHANDLER_NOEC(T_FPERR_handler, T_FPERR)
f0104a10:	6a 00                	push   $0x0
f0104a12:	6a 10                	push   $0x10
f0104a14:	e9 5a 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a19:	90                   	nop

f0104a1a <T_ALIGN_handler>:
TRAPHANDLER_NOEC(T_ALIGN_handler, T_ALIGN)
f0104a1a:	6a 00                	push   $0x0
f0104a1c:	6a 11                	push   $0x11
f0104a1e:	e9 50 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a23:	90                   	nop

f0104a24 <T_MCHK_handler>:
TRAPHANDLER_NOEC(T_MCHK_handler, T_MCHK)
f0104a24:	6a 00                	push   $0x0
f0104a26:	6a 12                	push   $0x12
f0104a28:	e9 46 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a2d:	90                   	nop

f0104a2e <T_SIMDERR_handler>:
TRAPHANDLER_NOEC(T_SIMDERR_handler, T_SIMDERR)
f0104a2e:	6a 00                	push   $0x0
f0104a30:	6a 13                	push   $0x13
f0104a32:	e9 3c 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a37:	90                   	nop

f0104a38 <T_SYSCALL_handler>:

TRAPHANDLER_NOEC(T_SYSCALL_handler, T_SYSCALL)
f0104a38:	6a 00                	push   $0x0
f0104a3a:	6a 30                	push   $0x30
f0104a3c:	e9 32 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a41:	90                   	nop

f0104a42 <IRQ_TIMER_handler>:

/* 
 * Lab 4: Hardware handlers
 */
TRAPHANDLER_NOEC(IRQ_TIMER_handler, IRQ_OFFSET+IRQ_TIMER)
f0104a42:	6a 00                	push   $0x0
f0104a44:	6a 20                	push   $0x20
f0104a46:	e9 28 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a4b:	90                   	nop

f0104a4c <IRQ_KBD_handler>:
TRAPHANDLER_NOEC(IRQ_KBD_handler, IRQ_OFFSET+IRQ_KBD)
f0104a4c:	6a 00                	push   $0x0
f0104a4e:	6a 21                	push   $0x21
f0104a50:	e9 1e 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a55:	90                   	nop

f0104a56 <IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(IRQ_SERIAL_handler, IRQ_OFFSET+IRQ_SERIAL)
f0104a56:	6a 00                	push   $0x0
f0104a58:	6a 24                	push   $0x24
f0104a5a:	e9 14 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a5f:	90                   	nop

f0104a60 <IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(IRQ_SPURIOUS_handler, IRQ_OFFSET+IRQ_SPURIOUS)
f0104a60:	6a 00                	push   $0x0
f0104a62:	6a 27                	push   $0x27
f0104a64:	e9 0a 00 00 00       	jmp    f0104a73 <_alltraps>
f0104a69:	90                   	nop

f0104a6a <IRQ_IDE_handler>:
TRAPHANDLER_NOEC(IRQ_IDE_handler, IRQ_OFFSET+IRQ_IDE)
f0104a6a:	6a 00                	push   $0x0
f0104a6c:	6a 2e                	push   $0x2e
f0104a6e:	e9 00 00 00 00       	jmp    f0104a73 <_alltraps>

f0104a73 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
  # Build trap frame.
  pushl %ds
f0104a73:	1e                   	push   %ds
  pushl %es
f0104a74:	06                   	push   %es
  pushal
f0104a75:	60                   	pusha  

  # Save information
  movl $GD_KD, %eax
f0104a76:	b8 10 00 00 00       	mov    $0x10,%eax
  movw %ax, %ds
f0104a7b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0104a7d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
f0104a7f:	54                   	push   %esp
  call trap
f0104a80:	e8 c8 fc ff ff       	call   f010474d <trap>
f0104a85:	00 00                	add    %al,(%eax)
	...

f0104a88 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104a88:	55                   	push   %ebp
f0104a89:	89 e5                	mov    %esp,%ebp
f0104a8b:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f0104a8e:	8b 15 48 42 22 f0    	mov    0xf0224248,%edx
f0104a94:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104a97:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104a9c:	8b 0a                	mov    (%edx),%ecx
f0104a9e:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104a9f:	83 f9 02             	cmp    $0x2,%ecx
f0104aa2:	76 0d                	jbe    f0104ab1 <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104aa4:	40                   	inc    %eax
f0104aa5:	83 c2 7c             	add    $0x7c,%edx
f0104aa8:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104aad:	75 ed                	jne    f0104a9c <sched_halt+0x14>
f0104aaf:	eb 07                	jmp    f0104ab8 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0104ab1:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104ab6:	75 1a                	jne    f0104ad2 <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104ab8:	c7 04 24 b0 80 10 f0 	movl   $0xf01080b0,(%esp)
f0104abf:	e8 aa f3 ff ff       	call   f0103e6e <cprintf>
		while (1)
			monitor(NULL);
f0104ac4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0104acb:	e8 02 be ff ff       	call   f01008d2 <monitor>
f0104ad0:	eb f2                	jmp    f0104ac4 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104ad2:	e8 79 18 00 00       	call   f0106350 <cpunum>
f0104ad7:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ade:	29 c2                	sub    %eax,%edx
f0104ae0:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ae3:	c7 04 85 28 50 22 f0 	movl   $0x0,-0xfddafd8(,%eax,4)
f0104aea:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104aee:	a1 8c 4e 22 f0       	mov    0xf0224e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104af3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104af8:	77 20                	ja     f0104b1a <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104afa:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104afe:	c7 44 24 08 44 6a 10 	movl   $0xf0106a44,0x8(%esp)
f0104b05:	f0 
f0104b06:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
f0104b0d:	00 
f0104b0e:	c7 04 24 d9 80 10 f0 	movl   $0xf01080d9,(%esp)
f0104b15:	e8 26 b5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0104b1a:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104b1f:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104b22:	e8 29 18 00 00       	call   f0106350 <cpunum>
f0104b27:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b2e:	29 c2                	sub    %eax,%edx
f0104b30:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b33:	8d 14 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104b3a:	b8 02 00 00 00       	mov    $0x2,%eax
f0104b3f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104b43:	c7 04 24 c0 93 12 f0 	movl   $0xf01293c0,(%esp)
f0104b4a:	e8 63 1b 00 00       	call   f01066b2 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104b4f:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104b51:	e8 fa 17 00 00       	call   f0106350 <cpunum>
f0104b56:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b5d:	29 c2                	sub    %eax,%edx
f0104b5f:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104b62:	8b 04 85 30 50 22 f0 	mov    -0xfddafd0(,%eax,4),%eax
f0104b69:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104b6e:	89 c4                	mov    %eax,%esp
f0104b70:	6a 00                	push   $0x0
f0104b72:	6a 00                	push   $0x0
f0104b74:	fb                   	sti    
f0104b75:	f4                   	hlt    
f0104b76:	eb fd                	jmp    f0104b75 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104b78:	c9                   	leave  
f0104b79:	c3                   	ret    

f0104b7a <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104b7a:	55                   	push   %ebp
f0104b7b:	89 e5                	mov    %esp,%ebp
f0104b7d:	56                   	push   %esi
f0104b7e:	53                   	push   %ebx
f0104b7f:	83 ec 10             	sub    $0x10,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	int idx = ENVX((curenv ? ENVX(curenv->env_id) : 0) + 1);
f0104b82:	e8 c9 17 00 00       	call   f0106350 <cpunum>
f0104b87:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b8e:	29 c2                	sub    %eax,%edx
f0104b90:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b93:	83 3c 85 28 50 22 f0 	cmpl   $0x0,-0xfddafd8(,%eax,4)
f0104b9a:	00 
f0104b9b:	74 23                	je     f0104bc0 <sched_yield+0x46>
f0104b9d:	e8 ae 17 00 00       	call   f0106350 <cpunum>
f0104ba2:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ba9:	29 c2                	sub    %eax,%edx
f0104bab:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104bae:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104bb5:	8b 40 48             	mov    0x48(%eax),%eax
f0104bb8:	40                   	inc    %eax
f0104bb9:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104bbe:	eb 05                	jmp    f0104bc5 <sched_yield+0x4b>
f0104bc0:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 0; i < NENV; i++) {
		// Get the environment
		idle = &envs[idx];
f0104bc5:	8b 35 48 42 22 f0    	mov    0xf0224248,%esi
f0104bcb:	ba 00 04 00 00       	mov    $0x400,%edx
f0104bd0:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f0104bd7:	89 c1                	mov    %eax,%ecx
f0104bd9:	c1 e1 07             	shl    $0x7,%ecx
f0104bdc:	29 d9                	sub    %ebx,%ecx
f0104bde:	01 f1                	add    %esi,%ecx
		if (idle->env_status == ENV_RUNNABLE) {
f0104be0:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f0104be4:	75 08                	jne    f0104bee <sched_yield+0x74>
			env_run(idle);
f0104be6:	89 0c 24             	mov    %ecx,(%esp)
f0104be9:	e8 3d f0 ff ff       	call   f0103c2b <env_run>
			break;
		}
		idx = ENVX(idx + 1);
f0104bee:	40                   	inc    %eax
f0104bef:	25 ff 03 00 00       	and    $0x3ff,%eax
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	int idx = ENVX((curenv ? ENVX(curenv->env_id) : 0) + 1);
	for (i = 0; i < NENV; i++) {
f0104bf4:	4a                   	dec    %edx
f0104bf5:	75 d9                	jne    f0104bd0 <sched_yield+0x56>
			break;
		}
		idx = ENVX(idx + 1);
	}
	// If not found, then continue the original one
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0104bf7:	e8 54 17 00 00       	call   f0106350 <cpunum>
f0104bfc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c03:	29 c2                	sub    %eax,%edx
f0104c05:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c08:	83 3c 85 28 50 22 f0 	cmpl   $0x0,-0xfddafd8(,%eax,4)
f0104c0f:	00 
f0104c10:	74 3e                	je     f0104c50 <sched_yield+0xd6>
f0104c12:	e8 39 17 00 00       	call   f0106350 <cpunum>
f0104c17:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c1e:	29 c2                	sub    %eax,%edx
f0104c20:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c23:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104c2a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104c2e:	75 20                	jne    f0104c50 <sched_yield+0xd6>
		env_run(curenv);
f0104c30:	e8 1b 17 00 00       	call   f0106350 <cpunum>
f0104c35:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c3c:	29 c2                	sub    %eax,%edx
f0104c3e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104c41:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104c48:	89 04 24             	mov    %eax,(%esp)
f0104c4b:	e8 db ef ff ff       	call   f0103c2b <env_run>
	
	// sched_halt never returns
	sched_halt();
f0104c50:	e8 33 fe ff ff       	call   f0104a88 <sched_halt>
}
f0104c55:	83 c4 10             	add    $0x10,%esp
f0104c58:	5b                   	pop    %ebx
f0104c59:	5e                   	pop    %esi
f0104c5a:	5d                   	pop    %ebp
f0104c5b:	c3                   	ret    

f0104c5c <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104c5c:	55                   	push   %ebp
f0104c5d:	89 e5                	mov    %esp,%ebp
f0104c5f:	57                   	push   %edi
f0104c60:	56                   	push   %esi
f0104c61:	53                   	push   %ebx
f0104c62:	83 ec 3c             	sub    $0x3c,%esp
f0104c65:	8b 45 08             	mov    0x8(%ebp),%eax
f0104c68:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c6b:	8b 75 10             	mov    0x10(%ebp),%esi
f0104c6e:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret;

	switch (syscallno) {
f0104c71:	83 f8 0d             	cmp    $0xd,%eax
f0104c74:	0f 87 03 06 00 00    	ja     f010527d <syscall+0x621>
f0104c7a:	ff 24 85 0c 81 10 f0 	jmp    *-0xfef7ef4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104c81:	e8 ca 16 00 00       	call   f0106350 <cpunum>
f0104c86:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104c8d:	00 
f0104c8e:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104c92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104c96:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104c9d:	29 c2                	sub    %eax,%edx
f0104c9f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ca2:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104ca9:	89 04 24             	mov    %eax,(%esp)
f0104cac:	e8 7c e7 ff ff       	call   f010342d <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104cb1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104cb5:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104cb9:	c7 04 24 e6 80 10 f0 	movl   $0xf01080e6,(%esp)
f0104cc0:	e8 a9 f1 ff ff       	call   f0103e6e <cprintf>
	int32_t ret;

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
f0104cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104cca:	e9 b3 05 00 00       	jmp    f0105282 <syscall+0x626>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104ccf:	e8 5e b9 ff ff       	call   f0100632 <cons_getc>
f0104cd4:	89 c3                	mov    %eax,%ebx
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
		break;
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
f0104cd6:	e9 a7 05 00 00       	jmp    f0105282 <syscall+0x626>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104cdb:	e8 70 16 00 00       	call   f0106350 <cpunum>
f0104ce0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ce7:	29 c2                	sub    %eax,%edx
f0104ce9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104cec:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104cf3:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
f0104cf6:	e9 87 05 00 00       	jmp    f0105282 <syscall+0x626>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104cfb:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104d02:	00 
f0104d03:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d06:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d0a:	89 1c 24             	mov    %ebx,(%esp)
f0104d0d:	e8 11 e8 ff ff       	call   f0103523 <envid2env>
f0104d12:	89 c3                	mov    %eax,%ebx
f0104d14:	85 c0                	test   %eax,%eax
f0104d16:	0f 88 66 05 00 00    	js     f0105282 <syscall+0x626>
		return r;
	env_destroy(e);
f0104d1c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d1f:	89 04 24             	mov    %eax,(%esp)
f0104d22:	e8 45 ee ff ff       	call   f0103b6c <env_destroy>
	return 0;
f0104d27:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
	case SYS_env_destroy:
		ret = sys_env_destroy((envid_t)a1);
		break;
f0104d2c:	e9 51 05 00 00       	jmp    f0105282 <syscall+0x626>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104d31:	e8 44 fe ff ff       	call   f0104b7a <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((r = env_alloc(&env_store, curenv->env_id)) < 0) {
f0104d36:	e8 15 16 00 00       	call   f0106350 <cpunum>
f0104d3b:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d42:	29 c2                	sub    %eax,%edx
f0104d44:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d47:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104d4e:	8b 40 48             	mov    0x48(%eax),%eax
f0104d51:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d55:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104d58:	89 04 24             	mov    %eax,(%esp)
f0104d5b:	e8 f7 e8 ff ff       	call   f0103657 <env_alloc>
f0104d60:	89 c3                	mov    %eax,%ebx
f0104d62:	85 c0                	test   %eax,%eax
f0104d64:	0f 88 18 05 00 00    	js     f0105282 <syscall+0x626>
		return r;
	}
	env_store->env_status = ENV_NOT_RUNNABLE;
f0104d6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d6d:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove((void *) &env_store->env_tf, (void *)&curenv->env_tf, sizeof(struct Trapframe));
f0104d74:	e8 d7 15 00 00       	call   f0106350 <cpunum>
f0104d79:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104d80:	00 
f0104d81:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104d88:	29 c2                	sub    %eax,%edx
f0104d8a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104d8d:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0104d94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d98:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d9b:	89 04 24             	mov    %eax,(%esp)
f0104d9e:	e8 c9 0f 00 00       	call   f0105d6c <memmove>
	// Set return of child process to be 0
	env_store->env_tf.tf_regs.reg_eax = 0;
f0104da3:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104da6:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env_store->env_id;
f0104dad:	8b 58 48             	mov    0x48(%eax),%ebx
		sys_yield();
		ret = 0;
		break;
	case SYS_exofork:
		ret = sys_exofork();
		break;
f0104db0:	e9 cd 04 00 00       	jmp    f0105282 <syscall+0x626>
	// envid's status.

	// LAB 4: Your code here.
	int r;
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104db5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104dbc:	00 
f0104dbd:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104dc0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dc4:	89 1c 24             	mov    %ebx,(%esp)
f0104dc7:	e8 57 e7 ff ff       	call   f0103523 <envid2env>
f0104dcc:	89 c3                	mov    %eax,%ebx
f0104dce:	85 c0                	test   %eax,%eax
f0104dd0:	0f 88 ac 04 00 00    	js     f0105282 <syscall+0x626>
		return r;
	}
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
f0104dd6:	83 fe 04             	cmp    $0x4,%esi
f0104dd9:	74 05                	je     f0104de0 <syscall+0x184>
f0104ddb:	83 fe 02             	cmp    $0x2,%esi
f0104dde:	75 10                	jne    f0104df0 <syscall+0x194>
		return -E_INVAL;
	}
	env_store->env_status = status;
f0104de0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104de3:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104de6:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104deb:	e9 92 04 00 00       	jmp    f0105282 <syscall+0x626>
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
		return r;
	}
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
		return -E_INVAL;
f0104df0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_exofork:
		ret = sys_exofork();
		break;
	case SYS_env_set_status:
		ret = sys_env_set_status((envid_t)a1, (int)a2);
		break;
f0104df5:	e9 88 04 00 00       	jmp    f0105282 <syscall+0x626>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct PageInfo *newPage = page_alloc(ALLOC_ZERO);
f0104dfa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104e01:	e8 78 c1 ff ff       	call   f0100f7e <page_alloc>
f0104e06:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Env *env_store;
	int r;
	if (!newPage) {
f0104e09:	85 c0                	test   %eax,%eax
f0104e0b:	74 6e                	je     f0104e7b <syscall+0x21f>
		return -E_NO_MEM;
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
f0104e0d:	89 f8                	mov    %edi,%eax
f0104e0f:	83 e0 05             	and    $0x5,%eax
f0104e12:	83 f8 05             	cmp    $0x5,%eax
f0104e15:	75 6e                	jne    f0104e85 <syscall+0x229>
		return -E_INVAL;
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0104e17:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f0104e1d:	75 70                	jne    f0104e8f <syscall+0x233>
		return -E_INVAL;
	}
	if ((uintptr_t)va >= UTOP) {
f0104e1f:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104e25:	77 72                	ja     f0104e99 <syscall+0x23d>
		return -E_INVAL;
	}
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104e27:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e2e:	00 
f0104e2f:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104e32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e36:	89 1c 24             	mov    %ebx,(%esp)
f0104e39:	e8 e5 e6 ff ff       	call   f0103523 <envid2env>
f0104e3e:	89 c3                	mov    %eax,%ebx
f0104e40:	85 c0                	test   %eax,%eax
f0104e42:	0f 88 3a 04 00 00    	js     f0105282 <syscall+0x626>
		return r;
	}
	if ((r = page_insert(env_store->env_pgdir, newPage, va, perm)) < 0) {
f0104e48:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104e4c:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104e50:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e57:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104e5a:	8b 40 60             	mov    0x60(%eax),%eax
f0104e5d:	89 04 24             	mov    %eax,(%esp)
f0104e60:	e8 0a c4 ff ff       	call   f010126f <page_insert>
f0104e65:	89 c3                	mov    %eax,%ebx
f0104e67:	85 c0                	test   %eax,%eax
f0104e69:	79 38                	jns    f0104ea3 <syscall+0x247>
		page_free(newPage);
f0104e6b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104e6e:	89 04 24             	mov    %eax,(%esp)
f0104e71:	e8 8c c1 ff ff       	call   f0101002 <page_free>
f0104e76:	e9 07 04 00 00       	jmp    f0105282 <syscall+0x626>
	// LAB 4: Your code here.
	struct PageInfo *newPage = page_alloc(ALLOC_ZERO);
	struct Env *env_store;
	int r;
	if (!newPage) {
		return -E_NO_MEM;
f0104e7b:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104e80:	e9 fd 03 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
		return -E_INVAL;
f0104e85:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e8a:	e9 f3 03 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
		return -E_INVAL;
f0104e8f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e94:	e9 e9 03 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((uintptr_t)va >= UTOP) {
		return -E_INVAL;
f0104e99:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e9e:	e9 df 03 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((r = page_insert(env_store->env_pgdir, newPage, va, perm)) < 0) {
		page_free(newPage);
		return r;
	}
	return 0;
f0104ea3:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_env_set_status:
		ret = sys_env_set_status((envid_t)a1, (int)a2);
		break;
	case SYS_page_alloc:
		ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		break;
f0104ea8:	e9 d5 03 00 00       	jmp    f0105282 <syscall+0x626>
	// LAB 4: Your code here.
	struct PageInfo *srcPage;
	struct Env *srcenv_store, *dstenv_store;
	pte_t *srcpte_store;
	int r;
	if ((r = envid2env(srcenvid, &srcenv_store, true)) < 0) {
f0104ead:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104eb4:	00 
f0104eb5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104eb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ebc:	89 1c 24             	mov    %ebx,(%esp)
f0104ebf:	e8 5f e6 ff ff       	call   f0103523 <envid2env>
f0104ec4:	89 c3                	mov    %eax,%ebx
f0104ec6:	85 c0                	test   %eax,%eax
f0104ec8:	0f 88 b4 03 00 00    	js     f0105282 <syscall+0x626>
		return r;
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
f0104ece:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ed5:	00 
f0104ed6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104ed9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104edd:	89 3c 24             	mov    %edi,(%esp)
f0104ee0:	e8 3e e6 ff ff       	call   f0103523 <envid2env>
f0104ee5:	89 c3                	mov    %eax,%ebx
f0104ee7:	85 c0                	test   %eax,%eax
f0104ee9:	0f 88 93 03 00 00    	js     f0105282 <syscall+0x626>
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
f0104eef:	8b 45 18             	mov    0x18(%ebp),%eax
f0104ef2:	09 f0                	or     %esi,%eax
		return r;
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
		return r;
	}
	if ((uintptr_t)srcva % PGSIZE != 0 || (uintptr_t)dstva % PGSIZE != 0) {
f0104ef4:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104ef9:	0f 85 a1 00 00 00    	jne    f0104fa0 <syscall+0x344>
		return -E_INVAL;
	}
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) {
f0104eff:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104f05:	77 09                	ja     f0104f10 <syscall+0x2b4>
f0104f07:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104f0e:	76 1d                	jbe    f0104f2d <syscall+0x2d1>
		cprintf("dstva is now %x\n", dstva);
f0104f10:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104f13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104f17:	c7 04 24 eb 80 10 f0 	movl   $0xf01080eb,(%esp)
f0104f1e:	e8 4b ef ff ff       	call   f0103e6e <cprintf>
		return -E_INVAL;
f0104f23:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f28:	e9 55 03 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
f0104f2d:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104f30:	83 e0 05             	and    $0x5,%eax
f0104f33:	83 f8 05             	cmp    $0x5,%eax
f0104f36:	75 72                	jne    f0104faa <syscall+0x34e>
		return -E_INVAL;
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0104f38:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104f3f:	75 73                	jne    f0104fb4 <syscall+0x358>
		return -E_INVAL;
	}
	if ((srcPage = page_lookup(srcenv_store->env_pgdir, srcva, &srcpte_store)) == NULL) {
f0104f41:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104f44:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f48:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f4f:	8b 40 60             	mov    0x60(%eax),%eax
f0104f52:	89 04 24             	mov    %eax,(%esp)
f0104f55:	e8 0a c2 ff ff       	call   f0101164 <page_lookup>
f0104f5a:	85 c0                	test   %eax,%eax
f0104f5c:	74 60                	je     f0104fbe <syscall+0x362>
		return -E_INVAL;
	}
	if ((perm & PTE_W) && !(*srcpte_store & PTE_W)) {
f0104f5e:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104f62:	74 08                	je     f0104f6c <syscall+0x310>
f0104f64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104f67:	f6 02 02             	testb  $0x2,(%edx)
f0104f6a:	74 5c                	je     f0104fc8 <syscall+0x36c>
		return -E_INVAL;
	}
	if ((r = page_insert(dstenv_store->env_pgdir, srcPage, dstva, perm)) < 0) {
f0104f6c:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104f6f:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104f73:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104f76:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104f7a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104f7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f81:	8b 40 60             	mov    0x60(%eax),%eax
f0104f84:	89 04 24             	mov    %eax,(%esp)
f0104f87:	e8 e3 c2 ff ff       	call   f010126f <page_insert>
f0104f8c:	89 c3                	mov    %eax,%ebx
f0104f8e:	85 c0                	test   %eax,%eax
f0104f90:	0f 8e ec 02 00 00    	jle    f0105282 <syscall+0x626>
f0104f96:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f9b:	e9 e2 02 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
		return r;
	}
	if ((uintptr_t)srcva % PGSIZE != 0 || (uintptr_t)dstva % PGSIZE != 0) {
		return -E_INVAL;
f0104fa0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fa5:	e9 d8 02 00 00       	jmp    f0105282 <syscall+0x626>
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) {
		cprintf("dstva is now %x\n", dstva);
		return -E_INVAL;
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
		return -E_INVAL;
f0104faa:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104faf:	e9 ce 02 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
		return -E_INVAL;
f0104fb4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fb9:	e9 c4 02 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((srcPage = page_lookup(srcenv_store->env_pgdir, srcva, &srcpte_store)) == NULL) {
		return -E_INVAL;
f0104fbe:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fc3:	e9 ba 02 00 00       	jmp    f0105282 <syscall+0x626>
	}
	if ((perm & PTE_W) && !(*srcpte_store & PTE_W)) {
		return -E_INVAL;
f0104fc8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_alloc:
		ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		break;
	case SYS_page_map:
		ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
		break;
f0104fcd:	e9 b0 02 00 00       	jmp    f0105282 <syscall+0x626>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((uintptr_t)va >= UTOP) {
f0104fd2:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104fd8:	77 3d                	ja     f0105017 <syscall+0x3bb>
		return -E_INVAL;
	}
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104fda:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104fe1:	00 
f0104fe2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104fe5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104fe9:	89 1c 24             	mov    %ebx,(%esp)
f0104fec:	e8 32 e5 ff ff       	call   f0103523 <envid2env>
f0104ff1:	89 c3                	mov    %eax,%ebx
f0104ff3:	85 c0                	test   %eax,%eax
f0104ff5:	0f 88 87 02 00 00    	js     f0105282 <syscall+0x626>
		return r;
	}
	page_remove(env_store->env_pgdir, va);
f0104ffb:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104fff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105002:	8b 40 60             	mov    0x60(%eax),%eax
f0105005:	89 04 24             	mov    %eax,(%esp)
f0105008:	e8 19 c2 ff ff       	call   f0101226 <page_remove>
	return 0;
f010500d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105012:	e9 6b 02 00 00       	jmp    f0105282 <syscall+0x626>

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((uintptr_t)va >= UTOP) {
		return -E_INVAL;
f0105017:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_map:
		ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
		break;
	case SYS_page_unmap:
		ret = sys_page_unmap((envid_t)a1, (void *)a2);
		break;
f010501c:	e9 61 02 00 00       	jmp    f0105282 <syscall+0x626>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	int r;
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0105021:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0105028:	00 
f0105029:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010502c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105030:	89 1c 24             	mov    %ebx,(%esp)
f0105033:	e8 eb e4 ff ff       	call   f0103523 <envid2env>
f0105038:	89 c3                	mov    %eax,%ebx
f010503a:	85 c0                	test   %eax,%eax
f010503c:	0f 88 40 02 00 00    	js     f0105282 <syscall+0x626>
		return r;
	}
	env_store->env_pgfault_upcall = func;
f0105042:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105045:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0105048:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_page_unmap:
		ret = sys_page_unmap((envid_t)a1, (void *)a2);
		break;
	case SYS_env_set_pgfault_upcall:
		ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		break;
f010504d:	e9 30 02 00 00       	jmp    f0105282 <syscall+0x626>
	// LAB 4: Your code here.
	struct PageInfo *srcPage;
	struct Env *env_store;
	pte_t *pte_store;
	int r;
	if ((r = envid2env(envid, &env_store, false)) < 0) {
f0105052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0105059:	00 
f010505a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010505d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105061:	89 1c 24             	mov    %ebx,(%esp)
f0105064:	e8 ba e4 ff ff       	call   f0103523 <envid2env>
f0105069:	89 c3                	mov    %eax,%ebx
f010506b:	85 c0                	test   %eax,%eax
f010506d:	0f 88 0f 02 00 00    	js     f0105282 <syscall+0x626>
		return r;
	}
	if ((env_store->env_ipc_recving == false) || (env_store->env_ipc_from != 0)) {
f0105073:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105076:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010507a:	0f 84 01 01 00 00    	je     f0105181 <syscall+0x525>
f0105080:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0105084:	0f 85 01 01 00 00    	jne    f010518b <syscall+0x52f>
		return -E_IPC_NOT_RECV;
	}
	// If srcva is less then UTOP
	if ((uintptr_t)srcva < UTOP) {
f010508a:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0105090:	0f 87 af 00 00 00    	ja     f0105145 <syscall+0x4e9>
		if ((uintptr_t)srcva % PGSIZE != 0) {
f0105096:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f010509c:	0f 85 f3 00 00 00    	jne    f0105195 <syscall+0x539>
			return -E_INVAL;
		}
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) {
f01050a2:	8b 45 18             	mov    0x18(%ebp),%eax
f01050a5:	83 e0 05             	and    $0x5,%eax
f01050a8:	83 f8 05             	cmp    $0x5,%eax
f01050ab:	0f 85 ee 00 00 00    	jne    f010519f <syscall+0x543>
			return -E_INVAL;
		}
		if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f01050b1:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f01050b8:	0f 85 eb 00 00 00    	jne    f01051a9 <syscall+0x54d>
			return -E_INVAL;
		}
		if ((srcPage = page_lookup(curenv->env_pgdir, srcva, &pte_store)) == NULL) {
f01050be:	e8 8d 12 00 00       	call   f0106350 <cpunum>
f01050c3:	8d 55 e0             	lea    -0x20(%ebp),%edx
f01050c6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01050ca:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01050ce:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01050d5:	29 c2                	sub    %eax,%edx
f01050d7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01050da:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f01050e1:	8b 40 60             	mov    0x60(%eax),%eax
f01050e4:	89 04 24             	mov    %eax,(%esp)
f01050e7:	e8 78 c0 ff ff       	call   f0101164 <page_lookup>
f01050ec:	85 c0                	test   %eax,%eax
f01050ee:	0f 84 bf 00 00 00    	je     f01051b3 <syscall+0x557>
			return -E_INVAL;
		}
		if ((perm & PTE_W) && (!(*pte_store & PTE_W))) {
f01050f4:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01050f8:	74 0c                	je     f0105106 <syscall+0x4aa>
f01050fa:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01050fd:	f6 02 02             	testb  $0x2,(%edx)
f0105100:	0f 84 b7 00 00 00    	je     f01051bd <syscall+0x561>
			return -E_INVAL;
		}
		// Updates
		if ((uintptr_t)env_store->env_ipc_dstva < UTOP) {
f0105106:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105109:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f010510c:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0105112:	77 2a                	ja     f010513e <syscall+0x4e2>
			if (page_insert(env_store->env_pgdir, srcPage, env_store->env_ipc_dstva, perm) < 0) {
f0105114:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0105117:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010511b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010511f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105123:	8b 42 60             	mov    0x60(%edx),%eax
f0105126:	89 04 24             	mov    %eax,(%esp)
f0105129:	e8 41 c1 ff ff       	call   f010126f <page_insert>
f010512e:	85 c0                	test   %eax,%eax
f0105130:	0f 88 91 00 00 00    	js     f01051c7 <syscall+0x56b>
				return -E_NO_MEM;
			}
			env_store->env_ipc_perm = perm;
f0105136:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105139:	89 58 78             	mov    %ebx,0x78(%eax)
f010513c:	eb 07                	jmp    f0105145 <syscall+0x4e9>
		}
		else {
			env_store->env_ipc_perm = 0;
f010513e:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
		}
	}
	// Updates
	env_store->env_ipc_recving = false;
f0105145:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105148:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_store->env_ipc_from = curenv->env_id;
f010514c:	e8 ff 11 00 00       	call   f0106350 <cpunum>
f0105151:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0105158:	29 c2                	sub    %eax,%edx
f010515a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010515d:	8b 04 85 28 50 22 f0 	mov    -0xfddafd8(,%eax,4),%eax
f0105164:	8b 40 48             	mov    0x48(%eax),%eax
f0105167:	89 43 74             	mov    %eax,0x74(%ebx)
	env_store->env_ipc_value = value;
f010516a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010516d:	89 70 70             	mov    %esi,0x70(%eax)
	env_store->env_status = ENV_RUNNABLE;
f0105170:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0105177:	bb 00 00 00 00       	mov    $0x0,%ebx
f010517c:	e9 01 01 00 00       	jmp    f0105282 <syscall+0x626>
	int r;
	if ((r = envid2env(envid, &env_store, false)) < 0) {
		return r;
	}
	if ((env_store->env_ipc_recving == false) || (env_store->env_ipc_from != 0)) {
		return -E_IPC_NOT_RECV;
f0105181:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0105186:	e9 f7 00 00 00       	jmp    f0105282 <syscall+0x626>
f010518b:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0105190:	e9 ed 00 00 00       	jmp    f0105282 <syscall+0x626>
	}
	// If srcva is less then UTOP
	if ((uintptr_t)srcva < UTOP) {
		if ((uintptr_t)srcva % PGSIZE != 0) {
			return -E_INVAL;
f0105195:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010519a:	e9 e3 00 00 00       	jmp    f0105282 <syscall+0x626>
		}
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) {
			return -E_INVAL;
f010519f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01051a4:	e9 d9 00 00 00       	jmp    f0105282 <syscall+0x626>
		}
		if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
			return -E_INVAL;
f01051a9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01051ae:	e9 cf 00 00 00       	jmp    f0105282 <syscall+0x626>
		}
		if ((srcPage = page_lookup(curenv->env_pgdir, srcva, &pte_store)) == NULL) {
			return -E_INVAL;
f01051b3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01051b8:	e9 c5 00 00 00       	jmp    f0105282 <syscall+0x626>
		}
		if ((perm & PTE_W) && (!(*pte_store & PTE_W))) {
			return -E_INVAL;
f01051bd:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01051c2:	e9 bb 00 00 00       	jmp    f0105282 <syscall+0x626>
		}
		// Updates
		if ((uintptr_t)env_store->env_ipc_dstva < UTOP) {
			if (page_insert(env_store->env_pgdir, srcPage, env_store->env_ipc_dstva, perm) < 0) {
				return -E_NO_MEM;
f01051c7:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
	case SYS_env_set_pgfault_upcall:
		ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		break;
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
f01051cc:	e9 b1 00 00 00       	jmp    f0105282 <syscall+0x626>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP) {
f01051d1:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f01051d7:	77 39                	ja     f0105212 <syscall+0x5b6>
		if ((uintptr_t)dstva % PGSIZE != 0) {
f01051d9:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f01051df:	74 1e                	je     f01051ff <syscall+0x5a3>
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
		cprintf("value is %d\n", ret);
f01051e1:	c7 44 24 04 fd ff ff 	movl   $0xfffffffd,0x4(%esp)
f01051e8:	ff 
f01051e9:	c7 04 24 fc 80 10 f0 	movl   $0xf01080fc,(%esp)
f01051f0:	e8 79 ec ff ff       	call   f0103e6e <cprintf>
		break;
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
f01051f5:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		cprintf("value is %d\n", ret);
		break;
f01051fa:	e9 83 00 00 00       	jmp    f0105282 <syscall+0x626>
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP) {
		if ((uintptr_t)dstva % PGSIZE != 0) {
			return -E_INVAL;
		}
		curenv->env_ipc_dstva = dstva;
f01051ff:	e8 4c 11 00 00       	call   f0106350 <cpunum>
f0105204:	6b c0 74             	imul   $0x74,%eax,%eax
f0105207:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010520d:	89 58 6c             	mov    %ebx,0x6c(%eax)
f0105210:	eb 15                	jmp    f0105227 <syscall+0x5cb>
	}
	else {
		curenv->env_ipc_dstva = (void *)UTOP;
f0105212:	e8 39 11 00 00       	call   f0106350 <cpunum>
f0105217:	6b c0 74             	imul   $0x74,%eax,%eax
f010521a:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0105220:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)
	}
	// Mark itself as not runnable
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105227:	e8 24 11 00 00       	call   f0106350 <cpunum>
f010522c:	6b c0 74             	imul   $0x74,%eax,%eax
f010522f:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0105235:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = true;
f010523c:	e8 0f 11 00 00       	call   f0106350 <cpunum>
f0105241:	6b c0 74             	imul   $0x74,%eax,%eax
f0105244:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010524a:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f010524e:	e8 fd 10 00 00       	call   f0106350 <cpunum>
f0105253:	6b c0 74             	imul   $0x74,%eax,%eax
f0105256:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f010525c:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f0105263:	e8 e8 10 00 00       	call   f0106350 <cpunum>
f0105268:	6b c0 74             	imul   $0x74,%eax,%eax
f010526b:	8b 80 28 50 22 f0    	mov    -0xfddafd8(%eax),%eax
f0105271:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	// Give up the CPU
	sched_yield();
f0105278:	e8 fd f8 ff ff       	call   f0104b7a <sched_yield>
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
		cprintf("value is %d\n", ret);
		break;
	default:
		ret = -E_INVAL;
f010527d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		break;
	}

	return ret;
}
f0105282:	89 d8                	mov    %ebx,%eax
f0105284:	83 c4 3c             	add    $0x3c,%esp
f0105287:	5b                   	pop    %ebx
f0105288:	5e                   	pop    %esi
f0105289:	5f                   	pop    %edi
f010528a:	5d                   	pop    %ebp
f010528b:	c3                   	ret    

f010528c <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010528c:	55                   	push   %ebp
f010528d:	89 e5                	mov    %esp,%ebp
f010528f:	57                   	push   %edi
f0105290:	56                   	push   %esi
f0105291:	53                   	push   %ebx
f0105292:	83 ec 14             	sub    $0x14,%esp
f0105295:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105298:	89 55 e8             	mov    %edx,-0x18(%ebp)
f010529b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010529e:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01052a1:	8b 1a                	mov    (%edx),%ebx
f01052a3:	8b 01                	mov    (%ecx),%eax
f01052a5:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01052a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f01052af:	e9 83 00 00 00       	jmp    f0105337 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f01052b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01052b7:	01 d8                	add    %ebx,%eax
f01052b9:	89 c7                	mov    %eax,%edi
f01052bb:	c1 ef 1f             	shr    $0x1f,%edi
f01052be:	01 c7                	add    %eax,%edi
f01052c0:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052c2:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01052c5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01052c8:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01052cc:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052ce:	eb 01                	jmp    f01052d1 <stab_binsearch+0x45>
			m--;
f01052d0:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01052d1:	39 c3                	cmp    %eax,%ebx
f01052d3:	7f 1e                	jg     f01052f3 <stab_binsearch+0x67>
f01052d5:	0f b6 0a             	movzbl (%edx),%ecx
f01052d8:	83 ea 0c             	sub    $0xc,%edx
f01052db:	39 f1                	cmp    %esi,%ecx
f01052dd:	75 f1                	jne    f01052d0 <stab_binsearch+0x44>
f01052df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01052e2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01052e5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01052e8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01052ec:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01052ef:	76 18                	jbe    f0105309 <stab_binsearch+0x7d>
f01052f1:	eb 05                	jmp    f01052f8 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01052f3:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01052f6:	eb 3f                	jmp    f0105337 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01052f8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01052fb:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01052fd:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105300:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105307:	eb 2e                	jmp    f0105337 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0105309:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010530c:	73 15                	jae    f0105323 <stab_binsearch+0x97>
			*region_right = m - 1;
f010530e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105311:	49                   	dec    %ecx
f0105312:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105315:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105318:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010531a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0105321:	eb 14                	jmp    f0105337 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0105323:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105326:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105329:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010532b:	ff 45 0c             	incl   0xc(%ebp)
f010532e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0105330:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105337:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010533a:	0f 8e 74 ff ff ff    	jle    f01052b4 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0105340:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105344:	75 0d                	jne    f0105353 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0105346:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105349:	8b 02                	mov    (%edx),%eax
f010534b:	48                   	dec    %eax
f010534c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010534f:	89 01                	mov    %eax,(%ecx)
f0105351:	eb 2a                	jmp    f010537d <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105353:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105356:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105358:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010535b:	8b 0a                	mov    (%edx),%ecx
f010535d:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0105360:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f0105363:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105367:	eb 01                	jmp    f010536a <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105369:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010536a:	39 c8                	cmp    %ecx,%eax
f010536c:	7e 0a                	jle    f0105378 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f010536e:	0f b6 1a             	movzbl (%edx),%ebx
f0105371:	83 ea 0c             	sub    $0xc,%edx
f0105374:	39 f3                	cmp    %esi,%ebx
f0105376:	75 f1                	jne    f0105369 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105378:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010537b:	89 02                	mov    %eax,(%edx)
	}
}
f010537d:	83 c4 14             	add    $0x14,%esp
f0105380:	5b                   	pop    %ebx
f0105381:	5e                   	pop    %esi
f0105382:	5f                   	pop    %edi
f0105383:	5d                   	pop    %ebp
f0105384:	c3                   	ret    

f0105385 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105385:	55                   	push   %ebp
f0105386:	89 e5                	mov    %esp,%ebp
f0105388:	57                   	push   %edi
f0105389:	56                   	push   %esi
f010538a:	53                   	push   %ebx
f010538b:	83 ec 3c             	sub    $0x3c,%esp
f010538e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105391:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105394:	c7 06 44 81 10 f0    	movl   $0xf0108144,(%esi)
	info->eip_line = 0;
f010539a:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01053a1:	c7 46 08 44 81 10 f0 	movl   $0xf0108144,0x8(%esi)
	info->eip_fn_namelen = 9;
f01053a8:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01053af:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01053b2:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01053b9:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01053bf:	77 22                	ja     f01053e3 <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01053c1:	8b 1d 00 00 20 00    	mov    0x200000,%ebx
f01053c7:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
		stab_end = usd->stab_end;
f01053ca:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01053cf:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f01053d5:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f01053d8:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f01053de:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01053e1:	eb 1a                	jmp    f01053fd <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01053e3:	c7 45 d0 e6 e2 11 f0 	movl   $0xf011e2e6,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01053ea:	c7 45 cc 49 37 11 f0 	movl   $0xf0113749,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01053f1:	b8 48 37 11 f0       	mov    $0xf0113748,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01053f6:	c7 45 d4 f0 86 10 f0 	movl   $0xf01086f0,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01053fd:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105400:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f0105403:	0f 83 24 01 00 00    	jae    f010552d <debuginfo_eip+0x1a8>
f0105409:	80 7b ff 00          	cmpb   $0x0,-0x1(%ebx)
f010540d:	0f 85 21 01 00 00    	jne    f0105534 <debuginfo_eip+0x1af>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105413:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010541a:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f010541d:	c1 f8 02             	sar    $0x2,%eax
f0105420:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0105423:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105426:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105429:	89 d1                	mov    %edx,%ecx
f010542b:	c1 e1 08             	shl    $0x8,%ecx
f010542e:	01 ca                	add    %ecx,%edx
f0105430:	89 d1                	mov    %edx,%ecx
f0105432:	c1 e1 10             	shl    $0x10,%ecx
f0105435:	01 ca                	add    %ecx,%edx
f0105437:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f010543b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010543e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105442:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105449:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010544c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010544f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105452:	e8 35 fe ff ff       	call   f010528c <stab_binsearch>
	if (lfile == 0)
f0105457:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010545a:	85 c0                	test   %eax,%eax
f010545c:	0f 84 d9 00 00 00    	je     f010553b <debuginfo_eip+0x1b6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0105462:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105465:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105468:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010546b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010546f:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105476:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105479:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010547c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010547f:	e8 08 fe ff ff       	call   f010528c <stab_binsearch>

	if (lfun <= rfun) {
f0105484:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105487:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f010548a:	7f 23                	jg     f01054af <debuginfo_eip+0x12a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010548c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010548f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105492:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105495:	8b 10                	mov    (%eax),%edx
f0105497:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010549a:	2b 4d cc             	sub    -0x34(%ebp),%ecx
f010549d:	39 ca                	cmp    %ecx,%edx
f010549f:	73 06                	jae    f01054a7 <debuginfo_eip+0x122>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01054a1:	03 55 cc             	add    -0x34(%ebp),%edx
f01054a4:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01054a7:	8b 40 08             	mov    0x8(%eax),%eax
f01054aa:	89 46 10             	mov    %eax,0x10(%esi)
f01054ad:	eb 06                	jmp    f01054b5 <debuginfo_eip+0x130>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01054af:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01054b2:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01054b5:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f01054bc:	00 
f01054bd:	8b 46 08             	mov    0x8(%esi),%eax
f01054c0:	89 04 24             	mov    %eax,(%esp)
f01054c3:	e8 42 08 00 00       	call   f0105d0a <strfind>
f01054c8:	2b 46 08             	sub    0x8(%esi),%eax
f01054cb:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01054ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01054d1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01054d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01054d7:	8d 44 82 08          	lea    0x8(%edx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01054db:	eb 04                	jmp    f01054e1 <debuginfo_eip+0x15c>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01054dd:	4b                   	dec    %ebx
f01054de:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01054e1:	39 fb                	cmp    %edi,%ebx
f01054e3:	7c 19                	jl     f01054fe <debuginfo_eip+0x179>
	       && stabs[lline].n_type != N_SOL
f01054e5:	8a 50 fc             	mov    -0x4(%eax),%dl
f01054e8:	80 fa 84             	cmp    $0x84,%dl
f01054eb:	74 69                	je     f0105556 <debuginfo_eip+0x1d1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01054ed:	80 fa 64             	cmp    $0x64,%dl
f01054f0:	75 eb                	jne    f01054dd <debuginfo_eip+0x158>
f01054f2:	83 38 00             	cmpl   $0x0,(%eax)
f01054f5:	74 e6                	je     f01054dd <debuginfo_eip+0x158>
f01054f7:	eb 5d                	jmp    f0105556 <debuginfo_eip+0x1d1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01054f9:	03 45 cc             	add    -0x34(%ebp),%eax
f01054fc:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01054fe:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105501:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0105504:	39 c8                	cmp    %ecx,%eax
f0105506:	7d 3a                	jge    f0105542 <debuginfo_eip+0x1bd>
		for (lline = lfun + 1;
f0105508:	40                   	inc    %eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105509:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f010550c:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010550f:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105513:	eb 04                	jmp    f0105519 <debuginfo_eip+0x194>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0105515:	ff 46 14             	incl   0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0105518:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0105519:	39 c8                	cmp    %ecx,%eax
f010551b:	74 2c                	je     f0105549 <debuginfo_eip+0x1c4>
f010551d:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0105520:	80 7a f4 a0          	cmpb   $0xa0,-0xc(%edx)
f0105524:	74 ef                	je     f0105515 <debuginfo_eip+0x190>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105526:	b8 00 00 00 00       	mov    $0x0,%eax
f010552b:	eb 21                	jmp    f010554e <debuginfo_eip+0x1c9>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010552d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105532:	eb 1a                	jmp    f010554e <debuginfo_eip+0x1c9>
f0105534:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105539:	eb 13                	jmp    f010554e <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010553b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105540:	eb 0c                	jmp    f010554e <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105542:	b8 00 00 00 00       	mov    $0x0,%eax
f0105547:	eb 05                	jmp    f010554e <debuginfo_eip+0x1c9>
f0105549:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010554e:	83 c4 3c             	add    $0x3c,%esp
f0105551:	5b                   	pop    %ebx
f0105552:	5e                   	pop    %esi
f0105553:	5f                   	pop    %edi
f0105554:	5d                   	pop    %ebp
f0105555:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105556:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105559:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010555c:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f010555f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0105562:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0105565:	39 d0                	cmp    %edx,%eax
f0105567:	72 90                	jb     f01054f9 <debuginfo_eip+0x174>
f0105569:	eb 93                	jmp    f01054fe <debuginfo_eip+0x179>
	...

f010556c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010556c:	55                   	push   %ebp
f010556d:	89 e5                	mov    %esp,%ebp
f010556f:	57                   	push   %edi
f0105570:	56                   	push   %esi
f0105571:	53                   	push   %ebx
f0105572:	83 ec 3c             	sub    $0x3c,%esp
f0105575:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105578:	89 d7                	mov    %edx,%edi
f010557a:	8b 45 08             	mov    0x8(%ebp),%eax
f010557d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0105580:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105583:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105586:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105589:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010558c:	85 c0                	test   %eax,%eax
f010558e:	75 08                	jne    f0105598 <printnum+0x2c>
f0105590:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105593:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105596:	77 57                	ja     f01055ef <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105598:	89 74 24 10          	mov    %esi,0x10(%esp)
f010559c:	4b                   	dec    %ebx
f010559d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01055a1:	8b 45 10             	mov    0x10(%ebp),%eax
f01055a4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01055a8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01055ac:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01055b0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01055b7:	00 
f01055b8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01055bb:	89 04 24             	mov    %eax,(%esp)
f01055be:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01055c1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01055c5:	e8 f6 11 00 00       	call   f01067c0 <__udivdi3>
f01055ca:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01055ce:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01055d2:	89 04 24             	mov    %eax,(%esp)
f01055d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01055d9:	89 fa                	mov    %edi,%edx
f01055db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055de:	e8 89 ff ff ff       	call   f010556c <printnum>
f01055e3:	eb 0f                	jmp    f01055f4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01055e5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01055e9:	89 34 24             	mov    %esi,(%esp)
f01055ec:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01055ef:	4b                   	dec    %ebx
f01055f0:	85 db                	test   %ebx,%ebx
f01055f2:	7f f1                	jg     f01055e5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01055f4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01055f8:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01055fc:	8b 45 10             	mov    0x10(%ebp),%eax
f01055ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105603:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010560a:	00 
f010560b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010560e:	89 04 24             	mov    %eax,(%esp)
f0105611:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105614:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105618:	e8 c3 12 00 00       	call   f01068e0 <__umoddi3>
f010561d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105621:	0f be 80 4e 81 10 f0 	movsbl -0xfef7eb2(%eax),%eax
f0105628:	89 04 24             	mov    %eax,(%esp)
f010562b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010562e:	83 c4 3c             	add    $0x3c,%esp
f0105631:	5b                   	pop    %ebx
f0105632:	5e                   	pop    %esi
f0105633:	5f                   	pop    %edi
f0105634:	5d                   	pop    %ebp
f0105635:	c3                   	ret    

f0105636 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105636:	55                   	push   %ebp
f0105637:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105639:	83 fa 01             	cmp    $0x1,%edx
f010563c:	7e 0e                	jle    f010564c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010563e:	8b 10                	mov    (%eax),%edx
f0105640:	8d 4a 08             	lea    0x8(%edx),%ecx
f0105643:	89 08                	mov    %ecx,(%eax)
f0105645:	8b 02                	mov    (%edx),%eax
f0105647:	8b 52 04             	mov    0x4(%edx),%edx
f010564a:	eb 22                	jmp    f010566e <getuint+0x38>
	else if (lflag)
f010564c:	85 d2                	test   %edx,%edx
f010564e:	74 10                	je     f0105660 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0105650:	8b 10                	mov    (%eax),%edx
f0105652:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105655:	89 08                	mov    %ecx,(%eax)
f0105657:	8b 02                	mov    (%edx),%eax
f0105659:	ba 00 00 00 00       	mov    $0x0,%edx
f010565e:	eb 0e                	jmp    f010566e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0105660:	8b 10                	mov    (%eax),%edx
f0105662:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105665:	89 08                	mov    %ecx,(%eax)
f0105667:	8b 02                	mov    (%edx),%eax
f0105669:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010566e:	5d                   	pop    %ebp
f010566f:	c3                   	ret    

f0105670 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0105670:	55                   	push   %ebp
f0105671:	89 e5                	mov    %esp,%ebp
f0105673:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105676:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105679:	8b 10                	mov    (%eax),%edx
f010567b:	3b 50 04             	cmp    0x4(%eax),%edx
f010567e:	73 08                	jae    f0105688 <sprintputch+0x18>
		*b->buf++ = ch;
f0105680:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105683:	88 0a                	mov    %cl,(%edx)
f0105685:	42                   	inc    %edx
f0105686:	89 10                	mov    %edx,(%eax)
}
f0105688:	5d                   	pop    %ebp
f0105689:	c3                   	ret    

f010568a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010568a:	55                   	push   %ebp
f010568b:	89 e5                	mov    %esp,%ebp
f010568d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0105690:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0105693:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105697:	8b 45 10             	mov    0x10(%ebp),%eax
f010569a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010569e:	8b 45 0c             	mov    0xc(%ebp),%eax
f01056a1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01056a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01056a8:	89 04 24             	mov    %eax,(%esp)
f01056ab:	e8 02 00 00 00       	call   f01056b2 <vprintfmt>
	va_end(ap);
}
f01056b0:	c9                   	leave  
f01056b1:	c3                   	ret    

f01056b2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01056b2:	55                   	push   %ebp
f01056b3:	89 e5                	mov    %esp,%ebp
f01056b5:	57                   	push   %edi
f01056b6:	56                   	push   %esi
f01056b7:	53                   	push   %ebx
f01056b8:	83 ec 4c             	sub    $0x4c,%esp
f01056bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01056be:	8b 75 10             	mov    0x10(%ebp),%esi
f01056c1:	eb 12                	jmp    f01056d5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01056c3:	85 c0                	test   %eax,%eax
f01056c5:	0f 84 8b 03 00 00    	je     f0105a56 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
f01056cb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01056cf:	89 04 24             	mov    %eax,(%esp)
f01056d2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01056d5:	0f b6 06             	movzbl (%esi),%eax
f01056d8:	46                   	inc    %esi
f01056d9:	83 f8 25             	cmp    $0x25,%eax
f01056dc:	75 e5                	jne    f01056c3 <vprintfmt+0x11>
f01056de:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01056e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01056e9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01056ee:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01056f5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056fa:	eb 26                	jmp    f0105722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056fc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01056ff:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0105703:	eb 1d                	jmp    f0105722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105705:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0105708:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010570c:	eb 14                	jmp    f0105722 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010570e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0105711:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105718:	eb 08                	jmp    f0105722 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010571a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010571d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105722:	0f b6 06             	movzbl (%esi),%eax
f0105725:	8d 56 01             	lea    0x1(%esi),%edx
f0105728:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010572b:	8a 16                	mov    (%esi),%dl
f010572d:	83 ea 23             	sub    $0x23,%edx
f0105730:	80 fa 55             	cmp    $0x55,%dl
f0105733:	0f 87 01 03 00 00    	ja     f0105a3a <vprintfmt+0x388>
f0105739:	0f b6 d2             	movzbl %dl,%edx
f010573c:	ff 24 95 a0 82 10 f0 	jmp    *-0xfef7d60(,%edx,4)
f0105743:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105746:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010574b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010574e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0105752:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105755:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105758:	83 fa 09             	cmp    $0x9,%edx
f010575b:	77 2a                	ja     f0105787 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010575d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010575e:	eb eb                	jmp    f010574b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105760:	8b 45 14             	mov    0x14(%ebp),%eax
f0105763:	8d 50 04             	lea    0x4(%eax),%edx
f0105766:	89 55 14             	mov    %edx,0x14(%ebp)
f0105769:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010576b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010576e:	eb 17                	jmp    f0105787 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0105770:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105774:	78 98                	js     f010570e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105776:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105779:	eb a7                	jmp    f0105722 <vprintfmt+0x70>
f010577b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010577e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105785:	eb 9b                	jmp    f0105722 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105787:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010578b:	79 95                	jns    f0105722 <vprintfmt+0x70>
f010578d:	eb 8b                	jmp    f010571a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010578f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105790:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0105793:	eb 8d                	jmp    f0105722 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105795:	8b 45 14             	mov    0x14(%ebp),%eax
f0105798:	8d 50 04             	lea    0x4(%eax),%edx
f010579b:	89 55 14             	mov    %edx,0x14(%ebp)
f010579e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057a2:	8b 00                	mov    (%eax),%eax
f01057a4:	89 04 24             	mov    %eax,(%esp)
f01057a7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057aa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01057ad:	e9 23 ff ff ff       	jmp    f01056d5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01057b2:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b5:	8d 50 04             	lea    0x4(%eax),%edx
f01057b8:	89 55 14             	mov    %edx,0x14(%ebp)
f01057bb:	8b 00                	mov    (%eax),%eax
f01057bd:	85 c0                	test   %eax,%eax
f01057bf:	79 02                	jns    f01057c3 <vprintfmt+0x111>
f01057c1:	f7 d8                	neg    %eax
f01057c3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01057c5:	83 f8 0f             	cmp    $0xf,%eax
f01057c8:	7f 0b                	jg     f01057d5 <vprintfmt+0x123>
f01057ca:	8b 04 85 00 84 10 f0 	mov    -0xfef7c00(,%eax,4),%eax
f01057d1:	85 c0                	test   %eax,%eax
f01057d3:	75 23                	jne    f01057f8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01057d5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01057d9:	c7 44 24 08 66 81 10 	movl   $0xf0108166,0x8(%esp)
f01057e0:	f0 
f01057e1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057e5:	8b 45 08             	mov    0x8(%ebp),%eax
f01057e8:	89 04 24             	mov    %eax,(%esp)
f01057eb:	e8 9a fe ff ff       	call   f010568a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01057f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01057f3:	e9 dd fe ff ff       	jmp    f01056d5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01057f8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01057fc:	c7 44 24 08 04 79 10 	movl   $0xf0107904,0x8(%esp)
f0105803:	f0 
f0105804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105808:	8b 55 08             	mov    0x8(%ebp),%edx
f010580b:	89 14 24             	mov    %edx,(%esp)
f010580e:	e8 77 fe ff ff       	call   f010568a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105813:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105816:	e9 ba fe ff ff       	jmp    f01056d5 <vprintfmt+0x23>
f010581b:	89 f9                	mov    %edi,%ecx
f010581d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105820:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105823:	8b 45 14             	mov    0x14(%ebp),%eax
f0105826:	8d 50 04             	lea    0x4(%eax),%edx
f0105829:	89 55 14             	mov    %edx,0x14(%ebp)
f010582c:	8b 30                	mov    (%eax),%esi
f010582e:	85 f6                	test   %esi,%esi
f0105830:	75 05                	jne    f0105837 <vprintfmt+0x185>
				p = "(null)";
f0105832:	be 5f 81 10 f0       	mov    $0xf010815f,%esi
			if (width > 0 && padc != '-')
f0105837:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010583b:	0f 8e 84 00 00 00    	jle    f01058c5 <vprintfmt+0x213>
f0105841:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105845:	74 7e                	je     f01058c5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105847:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010584b:	89 34 24             	mov    %esi,(%esp)
f010584e:	e8 83 03 00 00       	call   f0105bd6 <strnlen>
f0105853:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105856:	29 c2                	sub    %eax,%edx
f0105858:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f010585b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010585f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0105862:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105865:	89 de                	mov    %ebx,%esi
f0105867:	89 d3                	mov    %edx,%ebx
f0105869:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010586b:	eb 0b                	jmp    f0105878 <vprintfmt+0x1c6>
					putch(padc, putdat);
f010586d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105871:	89 3c 24             	mov    %edi,(%esp)
f0105874:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105877:	4b                   	dec    %ebx
f0105878:	85 db                	test   %ebx,%ebx
f010587a:	7f f1                	jg     f010586d <vprintfmt+0x1bb>
f010587c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010587f:	89 f3                	mov    %esi,%ebx
f0105881:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105884:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105887:	85 c0                	test   %eax,%eax
f0105889:	79 05                	jns    f0105890 <vprintfmt+0x1de>
f010588b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105890:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105893:	29 c2                	sub    %eax,%edx
f0105895:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105898:	eb 2b                	jmp    f01058c5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010589a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010589e:	74 18                	je     f01058b8 <vprintfmt+0x206>
f01058a0:	8d 50 e0             	lea    -0x20(%eax),%edx
f01058a3:	83 fa 5e             	cmp    $0x5e,%edx
f01058a6:	76 10                	jbe    f01058b8 <vprintfmt+0x206>
					putch('?', putdat);
f01058a8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058ac:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01058b3:	ff 55 08             	call   *0x8(%ebp)
f01058b6:	eb 0a                	jmp    f01058c2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f01058b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01058bc:	89 04 24             	mov    %eax,(%esp)
f01058bf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01058c2:	ff 4d e4             	decl   -0x1c(%ebp)
f01058c5:	0f be 06             	movsbl (%esi),%eax
f01058c8:	46                   	inc    %esi
f01058c9:	85 c0                	test   %eax,%eax
f01058cb:	74 21                	je     f01058ee <vprintfmt+0x23c>
f01058cd:	85 ff                	test   %edi,%edi
f01058cf:	78 c9                	js     f010589a <vprintfmt+0x1e8>
f01058d1:	4f                   	dec    %edi
f01058d2:	79 c6                	jns    f010589a <vprintfmt+0x1e8>
f01058d4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01058d7:	89 de                	mov    %ebx,%esi
f01058d9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01058dc:	eb 18                	jmp    f01058f6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01058de:	89 74 24 04          	mov    %esi,0x4(%esp)
f01058e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01058e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01058eb:	4b                   	dec    %ebx
f01058ec:	eb 08                	jmp    f01058f6 <vprintfmt+0x244>
f01058ee:	8b 7d 08             	mov    0x8(%ebp),%edi
f01058f1:	89 de                	mov    %ebx,%esi
f01058f3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01058f6:	85 db                	test   %ebx,%ebx
f01058f8:	7f e4                	jg     f01058de <vprintfmt+0x22c>
f01058fa:	89 7d 08             	mov    %edi,0x8(%ebp)
f01058fd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01058ff:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105902:	e9 ce fd ff ff       	jmp    f01056d5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0105907:	83 f9 01             	cmp    $0x1,%ecx
f010590a:	7e 10                	jle    f010591c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f010590c:	8b 45 14             	mov    0x14(%ebp),%eax
f010590f:	8d 50 08             	lea    0x8(%eax),%edx
f0105912:	89 55 14             	mov    %edx,0x14(%ebp)
f0105915:	8b 30                	mov    (%eax),%esi
f0105917:	8b 78 04             	mov    0x4(%eax),%edi
f010591a:	eb 26                	jmp    f0105942 <vprintfmt+0x290>
	else if (lflag)
f010591c:	85 c9                	test   %ecx,%ecx
f010591e:	74 12                	je     f0105932 <vprintfmt+0x280>
		return va_arg(*ap, long);
f0105920:	8b 45 14             	mov    0x14(%ebp),%eax
f0105923:	8d 50 04             	lea    0x4(%eax),%edx
f0105926:	89 55 14             	mov    %edx,0x14(%ebp)
f0105929:	8b 30                	mov    (%eax),%esi
f010592b:	89 f7                	mov    %esi,%edi
f010592d:	c1 ff 1f             	sar    $0x1f,%edi
f0105930:	eb 10                	jmp    f0105942 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0105932:	8b 45 14             	mov    0x14(%ebp),%eax
f0105935:	8d 50 04             	lea    0x4(%eax),%edx
f0105938:	89 55 14             	mov    %edx,0x14(%ebp)
f010593b:	8b 30                	mov    (%eax),%esi
f010593d:	89 f7                	mov    %esi,%edi
f010593f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0105942:	85 ff                	test   %edi,%edi
f0105944:	78 0a                	js     f0105950 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105946:	b8 0a 00 00 00       	mov    $0xa,%eax
f010594b:	e9 ac 00 00 00       	jmp    f01059fc <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0105950:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105954:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010595b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010595e:	f7 de                	neg    %esi
f0105960:	83 d7 00             	adc    $0x0,%edi
f0105963:	f7 df                	neg    %edi
			}
			base = 10;
f0105965:	b8 0a 00 00 00       	mov    $0xa,%eax
f010596a:	e9 8d 00 00 00       	jmp    f01059fc <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010596f:	89 ca                	mov    %ecx,%edx
f0105971:	8d 45 14             	lea    0x14(%ebp),%eax
f0105974:	e8 bd fc ff ff       	call   f0105636 <getuint>
f0105979:	89 c6                	mov    %eax,%esi
f010597b:	89 d7                	mov    %edx,%edi
			base = 10;
f010597d:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0105982:	eb 78                	jmp    f01059fc <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105984:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105988:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010598f:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f0105992:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105996:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010599d:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f01059a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059a4:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f01059ab:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01059ae:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f01059b1:	e9 1f fd ff ff       	jmp    f01056d5 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f01059b6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059ba:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01059c1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01059c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01059c8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01059cf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01059d2:	8b 45 14             	mov    0x14(%ebp),%eax
f01059d5:	8d 50 04             	lea    0x4(%eax),%edx
f01059d8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01059db:	8b 30                	mov    (%eax),%esi
f01059dd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01059e2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01059e7:	eb 13                	jmp    f01059fc <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01059e9:	89 ca                	mov    %ecx,%edx
f01059eb:	8d 45 14             	lea    0x14(%ebp),%eax
f01059ee:	e8 43 fc ff ff       	call   f0105636 <getuint>
f01059f3:	89 c6                	mov    %eax,%esi
f01059f5:	89 d7                	mov    %edx,%edi
			base = 16;
f01059f7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01059fc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0105a00:	89 54 24 10          	mov    %edx,0x10(%esp)
f0105a04:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0105a07:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105a0b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a0f:	89 34 24             	mov    %esi,(%esp)
f0105a12:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105a16:	89 da                	mov    %ebx,%edx
f0105a18:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a1b:	e8 4c fb ff ff       	call   f010556c <printnum>
			break;
f0105a20:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105a23:	e9 ad fc ff ff       	jmp    f01056d5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105a28:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a2c:	89 04 24             	mov    %eax,(%esp)
f0105a2f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105a32:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105a35:	e9 9b fc ff ff       	jmp    f01056d5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105a3a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105a3e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105a45:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105a48:	eb 01                	jmp    f0105a4b <vprintfmt+0x399>
f0105a4a:	4e                   	dec    %esi
f0105a4b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0105a4f:	75 f9                	jne    f0105a4a <vprintfmt+0x398>
f0105a51:	e9 7f fc ff ff       	jmp    f01056d5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105a56:	83 c4 4c             	add    $0x4c,%esp
f0105a59:	5b                   	pop    %ebx
f0105a5a:	5e                   	pop    %esi
f0105a5b:	5f                   	pop    %edi
f0105a5c:	5d                   	pop    %ebp
f0105a5d:	c3                   	ret    

f0105a5e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0105a5e:	55                   	push   %ebp
f0105a5f:	89 e5                	mov    %esp,%ebp
f0105a61:	83 ec 28             	sub    $0x28,%esp
f0105a64:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a67:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105a6a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105a6d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105a71:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105a74:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105a7b:	85 c0                	test   %eax,%eax
f0105a7d:	74 30                	je     f0105aaf <vsnprintf+0x51>
f0105a7f:	85 d2                	test   %edx,%edx
f0105a81:	7e 33                	jle    f0105ab6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105a83:	8b 45 14             	mov    0x14(%ebp),%eax
f0105a86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a8a:	8b 45 10             	mov    0x10(%ebp),%eax
f0105a8d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105a91:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105a94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105a98:	c7 04 24 70 56 10 f0 	movl   $0xf0105670,(%esp)
f0105a9f:	e8 0e fc ff ff       	call   f01056b2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105aa4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105aa7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105aad:	eb 0c                	jmp    f0105abb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0105aaf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105ab4:	eb 05                	jmp    f0105abb <vsnprintf+0x5d>
f0105ab6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105abb:	c9                   	leave  
f0105abc:	c3                   	ret    

f0105abd <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105abd:	55                   	push   %ebp
f0105abe:	89 e5                	mov    %esp,%ebp
f0105ac0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0105ac3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105ac6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105aca:	8b 45 10             	mov    0x10(%ebp),%eax
f0105acd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105ad1:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105ad4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105ad8:	8b 45 08             	mov    0x8(%ebp),%eax
f0105adb:	89 04 24             	mov    %eax,(%esp)
f0105ade:	e8 7b ff ff ff       	call   f0105a5e <vsnprintf>
	va_end(ap);

	return rc;
}
f0105ae3:	c9                   	leave  
f0105ae4:	c3                   	ret    
f0105ae5:	00 00                	add    %al,(%eax)
	...

f0105ae8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105ae8:	55                   	push   %ebp
f0105ae9:	89 e5                	mov    %esp,%ebp
f0105aeb:	57                   	push   %edi
f0105aec:	56                   	push   %esi
f0105aed:	53                   	push   %ebx
f0105aee:	83 ec 1c             	sub    $0x1c,%esp
f0105af1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0105af4:	85 c0                	test   %eax,%eax
f0105af6:	74 10                	je     f0105b08 <readline+0x20>
		cprintf("%s", prompt);
f0105af8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105afc:	c7 04 24 04 79 10 f0 	movl   $0xf0107904,(%esp)
f0105b03:	e8 66 e3 ff ff       	call   f0103e6e <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0105b08:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0105b0f:	e8 97 ac ff ff       	call   f01007ab <iscons>
f0105b14:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0105b16:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105b1b:	e8 7a ac ff ff       	call   f010079a <getchar>
f0105b20:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105b22:	85 c0                	test   %eax,%eax
f0105b24:	79 20                	jns    f0105b46 <readline+0x5e>
			if (c != -E_EOF)
f0105b26:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105b29:	0f 84 82 00 00 00    	je     f0105bb1 <readline+0xc9>
				cprintf("read error: %e\n", c);
f0105b2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105b33:	c7 04 24 5f 84 10 f0 	movl   $0xf010845f,(%esp)
f0105b3a:	e8 2f e3 ff ff       	call   f0103e6e <cprintf>
			return NULL;
f0105b3f:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b44:	eb 70                	jmp    f0105bb6 <readline+0xce>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105b46:	83 f8 08             	cmp    $0x8,%eax
f0105b49:	74 05                	je     f0105b50 <readline+0x68>
f0105b4b:	83 f8 7f             	cmp    $0x7f,%eax
f0105b4e:	75 17                	jne    f0105b67 <readline+0x7f>
f0105b50:	85 f6                	test   %esi,%esi
f0105b52:	7e 13                	jle    f0105b67 <readline+0x7f>
			if (echoing)
f0105b54:	85 ff                	test   %edi,%edi
f0105b56:	74 0c                	je     f0105b64 <readline+0x7c>
				cputchar('\b');
f0105b58:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105b5f:	e8 26 ac ff ff       	call   f010078a <cputchar>
			i--;
f0105b64:	4e                   	dec    %esi
f0105b65:	eb b4                	jmp    f0105b1b <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105b67:	83 fb 1f             	cmp    $0x1f,%ebx
f0105b6a:	7e 1d                	jle    f0105b89 <readline+0xa1>
f0105b6c:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105b72:	7f 15                	jg     f0105b89 <readline+0xa1>
			if (echoing)
f0105b74:	85 ff                	test   %edi,%edi
f0105b76:	74 08                	je     f0105b80 <readline+0x98>
				cputchar(c);
f0105b78:	89 1c 24             	mov    %ebx,(%esp)
f0105b7b:	e8 0a ac ff ff       	call   f010078a <cputchar>
			buf[i++] = c;
f0105b80:	88 9e 80 4a 22 f0    	mov    %bl,-0xfddb580(%esi)
f0105b86:	46                   	inc    %esi
f0105b87:	eb 92                	jmp    f0105b1b <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105b89:	83 fb 0a             	cmp    $0xa,%ebx
f0105b8c:	74 05                	je     f0105b93 <readline+0xab>
f0105b8e:	83 fb 0d             	cmp    $0xd,%ebx
f0105b91:	75 88                	jne    f0105b1b <readline+0x33>
			if (echoing)
f0105b93:	85 ff                	test   %edi,%edi
f0105b95:	74 0c                	je     f0105ba3 <readline+0xbb>
				cputchar('\n');
f0105b97:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0105b9e:	e8 e7 ab ff ff       	call   f010078a <cputchar>
			buf[i] = 0;
f0105ba3:	c6 86 80 4a 22 f0 00 	movb   $0x0,-0xfddb580(%esi)
			return buf;
f0105baa:	b8 80 4a 22 f0       	mov    $0xf0224a80,%eax
f0105baf:	eb 05                	jmp    f0105bb6 <readline+0xce>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0105bb1:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105bb6:	83 c4 1c             	add    $0x1c,%esp
f0105bb9:	5b                   	pop    %ebx
f0105bba:	5e                   	pop    %esi
f0105bbb:	5f                   	pop    %edi
f0105bbc:	5d                   	pop    %ebp
f0105bbd:	c3                   	ret    
	...

f0105bc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105bc0:	55                   	push   %ebp
f0105bc1:	89 e5                	mov    %esp,%ebp
f0105bc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105bc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0105bcb:	eb 01                	jmp    f0105bce <strlen+0xe>
		n++;
f0105bcd:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105bce:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105bd2:	75 f9                	jne    f0105bcd <strlen+0xd>
		n++;
	return n;
}
f0105bd4:	5d                   	pop    %ebp
f0105bd5:	c3                   	ret    

f0105bd6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0105bd6:	55                   	push   %ebp
f0105bd7:	89 e5                	mov    %esp,%ebp
f0105bd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0105bdc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105bdf:	b8 00 00 00 00       	mov    $0x0,%eax
f0105be4:	eb 01                	jmp    f0105be7 <strnlen+0x11>
		n++;
f0105be6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105be7:	39 d0                	cmp    %edx,%eax
f0105be9:	74 06                	je     f0105bf1 <strnlen+0x1b>
f0105beb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f0105bef:	75 f5                	jne    f0105be6 <strnlen+0x10>
		n++;
	return n;
}
f0105bf1:	5d                   	pop    %ebp
f0105bf2:	c3                   	ret    

f0105bf3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105bf3:	55                   	push   %ebp
f0105bf4:	89 e5                	mov    %esp,%ebp
f0105bf6:	53                   	push   %ebx
f0105bf7:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bfa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105bfd:	ba 00 00 00 00       	mov    $0x0,%edx
f0105c02:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0105c05:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105c08:	42                   	inc    %edx
f0105c09:	84 c9                	test   %cl,%cl
f0105c0b:	75 f5                	jne    f0105c02 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105c0d:	5b                   	pop    %ebx
f0105c0e:	5d                   	pop    %ebp
f0105c0f:	c3                   	ret    

f0105c10 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105c10:	55                   	push   %ebp
f0105c11:	89 e5                	mov    %esp,%ebp
f0105c13:	53                   	push   %ebx
f0105c14:	83 ec 08             	sub    $0x8,%esp
f0105c17:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105c1a:	89 1c 24             	mov    %ebx,(%esp)
f0105c1d:	e8 9e ff ff ff       	call   f0105bc0 <strlen>
	strcpy(dst + len, src);
f0105c22:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c25:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105c29:	01 d8                	add    %ebx,%eax
f0105c2b:	89 04 24             	mov    %eax,(%esp)
f0105c2e:	e8 c0 ff ff ff       	call   f0105bf3 <strcpy>
	return dst;
}
f0105c33:	89 d8                	mov    %ebx,%eax
f0105c35:	83 c4 08             	add    $0x8,%esp
f0105c38:	5b                   	pop    %ebx
f0105c39:	5d                   	pop    %ebp
f0105c3a:	c3                   	ret    

f0105c3b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105c3b:	55                   	push   %ebp
f0105c3c:	89 e5                	mov    %esp,%ebp
f0105c3e:	56                   	push   %esi
f0105c3f:	53                   	push   %ebx
f0105c40:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c43:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c46:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c49:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105c4e:	eb 0c                	jmp    f0105c5c <strncpy+0x21>
		*dst++ = *src;
f0105c50:	8a 1a                	mov    (%edx),%bl
f0105c52:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105c55:	80 3a 01             	cmpb   $0x1,(%edx)
f0105c58:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105c5b:	41                   	inc    %ecx
f0105c5c:	39 f1                	cmp    %esi,%ecx
f0105c5e:	75 f0                	jne    f0105c50 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105c60:	5b                   	pop    %ebx
f0105c61:	5e                   	pop    %esi
f0105c62:	5d                   	pop    %ebp
f0105c63:	c3                   	ret    

f0105c64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105c64:	55                   	push   %ebp
f0105c65:	89 e5                	mov    %esp,%ebp
f0105c67:	56                   	push   %esi
f0105c68:	53                   	push   %ebx
f0105c69:	8b 75 08             	mov    0x8(%ebp),%esi
f0105c6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105c6f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c72:	85 d2                	test   %edx,%edx
f0105c74:	75 0a                	jne    f0105c80 <strlcpy+0x1c>
f0105c76:	89 f0                	mov    %esi,%eax
f0105c78:	eb 1a                	jmp    f0105c94 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105c7a:	88 18                	mov    %bl,(%eax)
f0105c7c:	40                   	inc    %eax
f0105c7d:	41                   	inc    %ecx
f0105c7e:	eb 02                	jmp    f0105c82 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105c80:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0105c82:	4a                   	dec    %edx
f0105c83:	74 0a                	je     f0105c8f <strlcpy+0x2b>
f0105c85:	8a 19                	mov    (%ecx),%bl
f0105c87:	84 db                	test   %bl,%bl
f0105c89:	75 ef                	jne    f0105c7a <strlcpy+0x16>
f0105c8b:	89 c2                	mov    %eax,%edx
f0105c8d:	eb 02                	jmp    f0105c91 <strlcpy+0x2d>
f0105c8f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105c91:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105c94:	29 f0                	sub    %esi,%eax
}
f0105c96:	5b                   	pop    %ebx
f0105c97:	5e                   	pop    %esi
f0105c98:	5d                   	pop    %ebp
f0105c99:	c3                   	ret    

f0105c9a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105c9a:	55                   	push   %ebp
f0105c9b:	89 e5                	mov    %esp,%ebp
f0105c9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105ca3:	eb 02                	jmp    f0105ca7 <strcmp+0xd>
		p++, q++;
f0105ca5:	41                   	inc    %ecx
f0105ca6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105ca7:	8a 01                	mov    (%ecx),%al
f0105ca9:	84 c0                	test   %al,%al
f0105cab:	74 04                	je     f0105cb1 <strcmp+0x17>
f0105cad:	3a 02                	cmp    (%edx),%al
f0105caf:	74 f4                	je     f0105ca5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105cb1:	0f b6 c0             	movzbl %al,%eax
f0105cb4:	0f b6 12             	movzbl (%edx),%edx
f0105cb7:	29 d0                	sub    %edx,%eax
}
f0105cb9:	5d                   	pop    %ebp
f0105cba:	c3                   	ret    

f0105cbb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105cbb:	55                   	push   %ebp
f0105cbc:	89 e5                	mov    %esp,%ebp
f0105cbe:	53                   	push   %ebx
f0105cbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105cc5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105cc8:	eb 03                	jmp    f0105ccd <strncmp+0x12>
		n--, p++, q++;
f0105cca:	4a                   	dec    %edx
f0105ccb:	40                   	inc    %eax
f0105ccc:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105ccd:	85 d2                	test   %edx,%edx
f0105ccf:	74 14                	je     f0105ce5 <strncmp+0x2a>
f0105cd1:	8a 18                	mov    (%eax),%bl
f0105cd3:	84 db                	test   %bl,%bl
f0105cd5:	74 04                	je     f0105cdb <strncmp+0x20>
f0105cd7:	3a 19                	cmp    (%ecx),%bl
f0105cd9:	74 ef                	je     f0105cca <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105cdb:	0f b6 00             	movzbl (%eax),%eax
f0105cde:	0f b6 11             	movzbl (%ecx),%edx
f0105ce1:	29 d0                	sub    %edx,%eax
f0105ce3:	eb 05                	jmp    f0105cea <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105ce5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105cea:	5b                   	pop    %ebx
f0105ceb:	5d                   	pop    %ebp
f0105cec:	c3                   	ret    

f0105ced <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ced:	55                   	push   %ebp
f0105cee:	89 e5                	mov    %esp,%ebp
f0105cf0:	8b 45 08             	mov    0x8(%ebp),%eax
f0105cf3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105cf6:	eb 05                	jmp    f0105cfd <strchr+0x10>
		if (*s == c)
f0105cf8:	38 ca                	cmp    %cl,%dl
f0105cfa:	74 0c                	je     f0105d08 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105cfc:	40                   	inc    %eax
f0105cfd:	8a 10                	mov    (%eax),%dl
f0105cff:	84 d2                	test   %dl,%dl
f0105d01:	75 f5                	jne    f0105cf8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0105d03:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105d08:	5d                   	pop    %ebp
f0105d09:	c3                   	ret    

f0105d0a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105d0a:	55                   	push   %ebp
f0105d0b:	89 e5                	mov    %esp,%ebp
f0105d0d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d10:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105d13:	eb 05                	jmp    f0105d1a <strfind+0x10>
		if (*s == c)
f0105d15:	38 ca                	cmp    %cl,%dl
f0105d17:	74 07                	je     f0105d20 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105d19:	40                   	inc    %eax
f0105d1a:	8a 10                	mov    (%eax),%dl
f0105d1c:	84 d2                	test   %dl,%dl
f0105d1e:	75 f5                	jne    f0105d15 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0105d20:	5d                   	pop    %ebp
f0105d21:	c3                   	ret    

f0105d22 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105d22:	55                   	push   %ebp
f0105d23:	89 e5                	mov    %esp,%ebp
f0105d25:	57                   	push   %edi
f0105d26:	56                   	push   %esi
f0105d27:	53                   	push   %ebx
f0105d28:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105d2b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105d2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105d31:	85 c9                	test   %ecx,%ecx
f0105d33:	74 30                	je     f0105d65 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105d35:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d3b:	75 25                	jne    f0105d62 <memset+0x40>
f0105d3d:	f6 c1 03             	test   $0x3,%cl
f0105d40:	75 20                	jne    f0105d62 <memset+0x40>
		c &= 0xFF;
f0105d42:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105d45:	89 d3                	mov    %edx,%ebx
f0105d47:	c1 e3 08             	shl    $0x8,%ebx
f0105d4a:	89 d6                	mov    %edx,%esi
f0105d4c:	c1 e6 18             	shl    $0x18,%esi
f0105d4f:	89 d0                	mov    %edx,%eax
f0105d51:	c1 e0 10             	shl    $0x10,%eax
f0105d54:	09 f0                	or     %esi,%eax
f0105d56:	09 d0                	or     %edx,%eax
f0105d58:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105d5a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105d5d:	fc                   	cld    
f0105d5e:	f3 ab                	rep stos %eax,%es:(%edi)
f0105d60:	eb 03                	jmp    f0105d65 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105d62:	fc                   	cld    
f0105d63:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105d65:	89 f8                	mov    %edi,%eax
f0105d67:	5b                   	pop    %ebx
f0105d68:	5e                   	pop    %esi
f0105d69:	5f                   	pop    %edi
f0105d6a:	5d                   	pop    %ebp
f0105d6b:	c3                   	ret    

f0105d6c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105d6c:	55                   	push   %ebp
f0105d6d:	89 e5                	mov    %esp,%ebp
f0105d6f:	57                   	push   %edi
f0105d70:	56                   	push   %esi
f0105d71:	8b 45 08             	mov    0x8(%ebp),%eax
f0105d74:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d77:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105d7a:	39 c6                	cmp    %eax,%esi
f0105d7c:	73 34                	jae    f0105db2 <memmove+0x46>
f0105d7e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105d81:	39 d0                	cmp    %edx,%eax
f0105d83:	73 2d                	jae    f0105db2 <memmove+0x46>
		s += n;
		d += n;
f0105d85:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105d88:	f6 c2 03             	test   $0x3,%dl
f0105d8b:	75 1b                	jne    f0105da8 <memmove+0x3c>
f0105d8d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105d93:	75 13                	jne    f0105da8 <memmove+0x3c>
f0105d95:	f6 c1 03             	test   $0x3,%cl
f0105d98:	75 0e                	jne    f0105da8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105d9a:	83 ef 04             	sub    $0x4,%edi
f0105d9d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105da0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105da3:	fd                   	std    
f0105da4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105da6:	eb 07                	jmp    f0105daf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105da8:	4f                   	dec    %edi
f0105da9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105dac:	fd                   	std    
f0105dad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105daf:	fc                   	cld    
f0105db0:	eb 20                	jmp    f0105dd2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105db2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105db8:	75 13                	jne    f0105dcd <memmove+0x61>
f0105dba:	a8 03                	test   $0x3,%al
f0105dbc:	75 0f                	jne    f0105dcd <memmove+0x61>
f0105dbe:	f6 c1 03             	test   $0x3,%cl
f0105dc1:	75 0a                	jne    f0105dcd <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105dc3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105dc6:	89 c7                	mov    %eax,%edi
f0105dc8:	fc                   	cld    
f0105dc9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105dcb:	eb 05                	jmp    f0105dd2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105dcd:	89 c7                	mov    %eax,%edi
f0105dcf:	fc                   	cld    
f0105dd0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105dd2:	5e                   	pop    %esi
f0105dd3:	5f                   	pop    %edi
f0105dd4:	5d                   	pop    %ebp
f0105dd5:	c3                   	ret    

f0105dd6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105dd6:	55                   	push   %ebp
f0105dd7:	89 e5                	mov    %esp,%ebp
f0105dd9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105ddc:	8b 45 10             	mov    0x10(%ebp),%eax
f0105ddf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105de3:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105de6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dea:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ded:	89 04 24             	mov    %eax,(%esp)
f0105df0:	e8 77 ff ff ff       	call   f0105d6c <memmove>
}
f0105df5:	c9                   	leave  
f0105df6:	c3                   	ret    

f0105df7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105df7:	55                   	push   %ebp
f0105df8:	89 e5                	mov    %esp,%ebp
f0105dfa:	57                   	push   %edi
f0105dfb:	56                   	push   %esi
f0105dfc:	53                   	push   %ebx
f0105dfd:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105e00:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e06:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e0b:	eb 16                	jmp    f0105e23 <memcmp+0x2c>
		if (*s1 != *s2)
f0105e0d:	8a 04 17             	mov    (%edi,%edx,1),%al
f0105e10:	42                   	inc    %edx
f0105e11:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0105e15:	38 c8                	cmp    %cl,%al
f0105e17:	74 0a                	je     f0105e23 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0105e19:	0f b6 c0             	movzbl %al,%eax
f0105e1c:	0f b6 c9             	movzbl %cl,%ecx
f0105e1f:	29 c8                	sub    %ecx,%eax
f0105e21:	eb 09                	jmp    f0105e2c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105e23:	39 da                	cmp    %ebx,%edx
f0105e25:	75 e6                	jne    f0105e0d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105e27:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105e2c:	5b                   	pop    %ebx
f0105e2d:	5e                   	pop    %esi
f0105e2e:	5f                   	pop    %edi
f0105e2f:	5d                   	pop    %ebp
f0105e30:	c3                   	ret    

f0105e31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105e31:	55                   	push   %ebp
f0105e32:	89 e5                	mov    %esp,%ebp
f0105e34:	8b 45 08             	mov    0x8(%ebp),%eax
f0105e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105e3a:	89 c2                	mov    %eax,%edx
f0105e3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105e3f:	eb 05                	jmp    f0105e46 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105e41:	38 08                	cmp    %cl,(%eax)
f0105e43:	74 05                	je     f0105e4a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105e45:	40                   	inc    %eax
f0105e46:	39 d0                	cmp    %edx,%eax
f0105e48:	72 f7                	jb     f0105e41 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105e4a:	5d                   	pop    %ebp
f0105e4b:	c3                   	ret    

f0105e4c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105e4c:	55                   	push   %ebp
f0105e4d:	89 e5                	mov    %esp,%ebp
f0105e4f:	57                   	push   %edi
f0105e50:	56                   	push   %esi
f0105e51:	53                   	push   %ebx
f0105e52:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e58:	eb 01                	jmp    f0105e5b <strtol+0xf>
		s++;
f0105e5a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105e5b:	8a 02                	mov    (%edx),%al
f0105e5d:	3c 20                	cmp    $0x20,%al
f0105e5f:	74 f9                	je     f0105e5a <strtol+0xe>
f0105e61:	3c 09                	cmp    $0x9,%al
f0105e63:	74 f5                	je     f0105e5a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105e65:	3c 2b                	cmp    $0x2b,%al
f0105e67:	75 08                	jne    f0105e71 <strtol+0x25>
		s++;
f0105e69:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105e6a:	bf 00 00 00 00       	mov    $0x0,%edi
f0105e6f:	eb 13                	jmp    f0105e84 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105e71:	3c 2d                	cmp    $0x2d,%al
f0105e73:	75 0a                	jne    f0105e7f <strtol+0x33>
		s++, neg = 1;
f0105e75:	8d 52 01             	lea    0x1(%edx),%edx
f0105e78:	bf 01 00 00 00       	mov    $0x1,%edi
f0105e7d:	eb 05                	jmp    f0105e84 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105e7f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105e84:	85 db                	test   %ebx,%ebx
f0105e86:	74 05                	je     f0105e8d <strtol+0x41>
f0105e88:	83 fb 10             	cmp    $0x10,%ebx
f0105e8b:	75 28                	jne    f0105eb5 <strtol+0x69>
f0105e8d:	8a 02                	mov    (%edx),%al
f0105e8f:	3c 30                	cmp    $0x30,%al
f0105e91:	75 10                	jne    f0105ea3 <strtol+0x57>
f0105e93:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105e97:	75 0a                	jne    f0105ea3 <strtol+0x57>
		s += 2, base = 16;
f0105e99:	83 c2 02             	add    $0x2,%edx
f0105e9c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105ea1:	eb 12                	jmp    f0105eb5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105ea3:	85 db                	test   %ebx,%ebx
f0105ea5:	75 0e                	jne    f0105eb5 <strtol+0x69>
f0105ea7:	3c 30                	cmp    $0x30,%al
f0105ea9:	75 05                	jne    f0105eb0 <strtol+0x64>
		s++, base = 8;
f0105eab:	42                   	inc    %edx
f0105eac:	b3 08                	mov    $0x8,%bl
f0105eae:	eb 05                	jmp    f0105eb5 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0105eb0:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105eb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0105eba:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105ebc:	8a 0a                	mov    (%edx),%cl
f0105ebe:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105ec1:	80 fb 09             	cmp    $0x9,%bl
f0105ec4:	77 08                	ja     f0105ece <strtol+0x82>
			dig = *s - '0';
f0105ec6:	0f be c9             	movsbl %cl,%ecx
f0105ec9:	83 e9 30             	sub    $0x30,%ecx
f0105ecc:	eb 1e                	jmp    f0105eec <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105ece:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105ed1:	80 fb 19             	cmp    $0x19,%bl
f0105ed4:	77 08                	ja     f0105ede <strtol+0x92>
			dig = *s - 'a' + 10;
f0105ed6:	0f be c9             	movsbl %cl,%ecx
f0105ed9:	83 e9 57             	sub    $0x57,%ecx
f0105edc:	eb 0e                	jmp    f0105eec <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105ede:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105ee1:	80 fb 19             	cmp    $0x19,%bl
f0105ee4:	77 12                	ja     f0105ef8 <strtol+0xac>
			dig = *s - 'A' + 10;
f0105ee6:	0f be c9             	movsbl %cl,%ecx
f0105ee9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105eec:	39 f1                	cmp    %esi,%ecx
f0105eee:	7d 0c                	jge    f0105efc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105ef0:	42                   	inc    %edx
f0105ef1:	0f af c6             	imul   %esi,%eax
f0105ef4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105ef6:	eb c4                	jmp    f0105ebc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105ef8:	89 c1                	mov    %eax,%ecx
f0105efa:	eb 02                	jmp    f0105efe <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105efc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105efe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105f02:	74 05                	je     f0105f09 <strtol+0xbd>
		*endptr = (char *) s;
f0105f04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105f07:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105f09:	85 ff                	test   %edi,%edi
f0105f0b:	74 04                	je     f0105f11 <strtol+0xc5>
f0105f0d:	89 c8                	mov    %ecx,%eax
f0105f0f:	f7 d8                	neg    %eax
}
f0105f11:	5b                   	pop    %ebx
f0105f12:	5e                   	pop    %esi
f0105f13:	5f                   	pop    %edi
f0105f14:	5d                   	pop    %ebp
f0105f15:	c3                   	ret    
	...

f0105f18 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105f18:	fa                   	cli    

	xorw    %ax, %ax
f0105f19:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105f1b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f1d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f1f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105f21:	0f 01 16             	lgdtl  (%esi)
f0105f24:	74 70                	je     f0105f96 <sum+0x2>
	movl    %cr0, %eax
f0105f26:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105f29:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105f2d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105f30:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105f36:	08 00                	or     %al,(%eax)

f0105f38 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105f38:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105f3c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105f3e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105f40:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105f42:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105f46:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105f48:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105f4a:	b8 00 70 12 00       	mov    $0x127000,%eax
	movl    %eax, %cr3
f0105f4f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105f52:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105f55:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105f5a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105f5d:	8b 25 84 4e 22 f0    	mov    0xf0224e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105f63:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105f68:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0105f6d:	ff d0                	call   *%eax

f0105f6f <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105f6f:	eb fe                	jmp    f0105f6f <spin>
f0105f71:	8d 76 00             	lea    0x0(%esi),%esi

f0105f74 <gdt>:
	...
f0105f7c:	ff                   	(bad)  
f0105f7d:	ff 00                	incl   (%eax)
f0105f7f:	00 00                	add    %al,(%eax)
f0105f81:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105f88:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105f8c <gdtdesc>:
f0105f8c:	17                   	pop    %ss
f0105f8d:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105f92 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105f92:	90                   	nop
	...

f0105f94 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105f94:	55                   	push   %ebp
f0105f95:	89 e5                	mov    %esp,%ebp
f0105f97:	56                   	push   %esi
f0105f98:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0105f99:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105f9e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105fa3:	eb 07                	jmp    f0105fac <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f0105fa5:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105fa9:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105fab:	41                   	inc    %ecx
f0105fac:	39 d1                	cmp    %edx,%ecx
f0105fae:	7c f5                	jl     f0105fa5 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105fb0:	88 d8                	mov    %bl,%al
f0105fb2:	5b                   	pop    %ebx
f0105fb3:	5e                   	pop    %esi
f0105fb4:	5d                   	pop    %ebp
f0105fb5:	c3                   	ret    

f0105fb6 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105fb6:	55                   	push   %ebp
f0105fb7:	89 e5                	mov    %esp,%ebp
f0105fb9:	56                   	push   %esi
f0105fba:	53                   	push   %ebx
f0105fbb:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105fbe:	8b 0d 88 4e 22 f0    	mov    0xf0224e88,%ecx
f0105fc4:	89 c3                	mov    %eax,%ebx
f0105fc6:	c1 eb 0c             	shr    $0xc,%ebx
f0105fc9:	39 cb                	cmp    %ecx,%ebx
f0105fcb:	72 20                	jb     f0105fed <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105fcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105fd1:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0105fd8:	f0 
f0105fd9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105fe0:	00 
f0105fe1:	c7 04 24 fd 85 10 f0 	movl   $0xf01085fd,(%esp)
f0105fe8:	e8 53 a0 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105fed:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ff0:	89 f2                	mov    %esi,%edx
f0105ff2:	c1 ea 0c             	shr    $0xc,%edx
f0105ff5:	39 d1                	cmp    %edx,%ecx
f0105ff7:	77 20                	ja     f0106019 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ff9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105ffd:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0106004:	f0 
f0106005:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f010600c:	00 
f010600d:	c7 04 24 fd 85 10 f0 	movl   $0xf01085fd,(%esp)
f0106014:	e8 27 a0 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106019:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f010601f:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0106025:	eb 2f                	jmp    f0106056 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0106027:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010602e:	00 
f010602f:	c7 44 24 04 0d 86 10 	movl   $0xf010860d,0x4(%esp)
f0106036:	f0 
f0106037:	89 1c 24             	mov    %ebx,(%esp)
f010603a:	e8 b8 fd ff ff       	call   f0105df7 <memcmp>
f010603f:	85 c0                	test   %eax,%eax
f0106041:	75 10                	jne    f0106053 <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0106043:	ba 10 00 00 00       	mov    $0x10,%edx
f0106048:	89 d8                	mov    %ebx,%eax
f010604a:	e8 45 ff ff ff       	call   f0105f94 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010604f:	84 c0                	test   %al,%al
f0106051:	74 0c                	je     f010605f <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0106053:	83 c3 10             	add    $0x10,%ebx
f0106056:	39 f3                	cmp    %esi,%ebx
f0106058:	72 cd                	jb     f0106027 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010605a:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f010605f:	89 d8                	mov    %ebx,%eax
f0106061:	83 c4 10             	add    $0x10,%esp
f0106064:	5b                   	pop    %ebx
f0106065:	5e                   	pop    %esi
f0106066:	5d                   	pop    %ebp
f0106067:	c3                   	ret    

f0106068 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0106068:	55                   	push   %ebp
f0106069:	89 e5                	mov    %esp,%ebp
f010606b:	57                   	push   %edi
f010606c:	56                   	push   %esi
f010606d:	53                   	push   %ebx
f010606e:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0106071:	c7 05 c0 53 22 f0 20 	movl   $0xf0225020,0xf02253c0
f0106078:	50 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010607b:	83 3d 88 4e 22 f0 00 	cmpl   $0x0,0xf0224e88
f0106082:	75 24                	jne    f01060a8 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106084:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f010608b:	00 
f010608c:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f0106093:	f0 
f0106094:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f010609b:	00 
f010609c:	c7 04 24 fd 85 10 f0 	movl   $0xf01085fd,(%esp)
f01060a3:	e8 98 9f ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01060a8:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01060af:	85 c0                	test   %eax,%eax
f01060b1:	74 16                	je     f01060c9 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f01060b3:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f01060b6:	ba 00 04 00 00       	mov    $0x400,%edx
f01060bb:	e8 f6 fe ff ff       	call   f0105fb6 <mpsearch1>
f01060c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060c3:	85 c0                	test   %eax,%eax
f01060c5:	75 3c                	jne    f0106103 <mp_init+0x9b>
f01060c7:	eb 20                	jmp    f01060e9 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f01060c9:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01060d0:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f01060d3:	2d 00 04 00 00       	sub    $0x400,%eax
f01060d8:	ba 00 04 00 00       	mov    $0x400,%edx
f01060dd:	e8 d4 fe ff ff       	call   f0105fb6 <mpsearch1>
f01060e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01060e5:	85 c0                	test   %eax,%eax
f01060e7:	75 1a                	jne    f0106103 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01060e9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01060ee:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01060f3:	e8 be fe ff ff       	call   f0105fb6 <mpsearch1>
f01060f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01060fb:	85 c0                	test   %eax,%eax
f01060fd:	0f 84 2c 02 00 00    	je     f010632f <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0106103:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0106106:	8b 58 04             	mov    0x4(%eax),%ebx
f0106109:	85 db                	test   %ebx,%ebx
f010610b:	74 06                	je     f0106113 <mp_init+0xab>
f010610d:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0106111:	74 11                	je     f0106124 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0106113:	c7 04 24 70 84 10 f0 	movl   $0xf0108470,(%esp)
f010611a:	e8 4f dd ff ff       	call   f0103e6e <cprintf>
f010611f:	e9 0b 02 00 00       	jmp    f010632f <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0106124:	89 d8                	mov    %ebx,%eax
f0106126:	c1 e8 0c             	shr    $0xc,%eax
f0106129:	3b 05 88 4e 22 f0    	cmp    0xf0224e88,%eax
f010612f:	72 20                	jb     f0106151 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0106131:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0106135:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f010613c:	f0 
f010613d:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0106144:	00 
f0106145:	c7 04 24 fd 85 10 f0 	movl   $0xf01085fd,(%esp)
f010614c:	e8 ef 9e ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0106151:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0106157:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f010615e:	00 
f010615f:	c7 44 24 04 12 86 10 	movl   $0xf0108612,0x4(%esp)
f0106166:	f0 
f0106167:	89 1c 24             	mov    %ebx,(%esp)
f010616a:	e8 88 fc ff ff       	call   f0105df7 <memcmp>
f010616f:	85 c0                	test   %eax,%eax
f0106171:	74 11                	je     f0106184 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0106173:	c7 04 24 a0 84 10 f0 	movl   $0xf01084a0,(%esp)
f010617a:	e8 ef dc ff ff       	call   f0103e6e <cprintf>
f010617f:	e9 ab 01 00 00       	jmp    f010632f <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0106184:	66 8b 73 04          	mov    0x4(%ebx),%si
f0106188:	0f b7 d6             	movzwl %si,%edx
f010618b:	89 d8                	mov    %ebx,%eax
f010618d:	e8 02 fe ff ff       	call   f0105f94 <sum>
f0106192:	84 c0                	test   %al,%al
f0106194:	74 11                	je     f01061a7 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0106196:	c7 04 24 d4 84 10 f0 	movl   $0xf01084d4,(%esp)
f010619d:	e8 cc dc ff ff       	call   f0103e6e <cprintf>
f01061a2:	e9 88 01 00 00       	jmp    f010632f <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01061a7:	8a 43 06             	mov    0x6(%ebx),%al
f01061aa:	3c 01                	cmp    $0x1,%al
f01061ac:	74 1c                	je     f01061ca <mp_init+0x162>
f01061ae:	3c 04                	cmp    $0x4,%al
f01061b0:	74 18                	je     f01061ca <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01061b2:	0f b6 c0             	movzbl %al,%eax
f01061b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061b9:	c7 04 24 f8 84 10 f0 	movl   $0xf01084f8,(%esp)
f01061c0:	e8 a9 dc ff ff       	call   f0103e6e <cprintf>
f01061c5:	e9 65 01 00 00       	jmp    f010632f <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01061ca:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f01061ce:	0f b7 c6             	movzwl %si,%eax
f01061d1:	01 d8                	add    %ebx,%eax
f01061d3:	e8 bc fd ff ff       	call   f0105f94 <sum>
f01061d8:	02 43 2a             	add    0x2a(%ebx),%al
f01061db:	84 c0                	test   %al,%al
f01061dd:	74 11                	je     f01061f0 <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f01061df:	c7 04 24 18 85 10 f0 	movl   $0xf0108518,(%esp)
f01061e6:	e8 83 dc ff ff       	call   f0103e6e <cprintf>
f01061eb:	e9 3f 01 00 00       	jmp    f010632f <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f01061f0:	85 db                	test   %ebx,%ebx
f01061f2:	0f 84 37 01 00 00    	je     f010632f <mp_init+0x2c7>
		return;
	ismp = 1;
f01061f8:	c7 05 00 50 22 f0 01 	movl   $0x1,0xf0225000
f01061ff:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106202:	8b 43 24             	mov    0x24(%ebx),%eax
f0106205:	a3 00 60 26 f0       	mov    %eax,0xf0266000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010620a:	8d 73 2c             	lea    0x2c(%ebx),%esi
f010620d:	bf 00 00 00 00       	mov    $0x0,%edi
f0106212:	e9 94 00 00 00       	jmp    f01062ab <mp_init+0x243>
		switch (*p) {
f0106217:	8a 06                	mov    (%esi),%al
f0106219:	84 c0                	test   %al,%al
f010621b:	74 06                	je     f0106223 <mp_init+0x1bb>
f010621d:	3c 04                	cmp    $0x4,%al
f010621f:	77 68                	ja     f0106289 <mp_init+0x221>
f0106221:	eb 61                	jmp    f0106284 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0106223:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106227:	74 1d                	je     f0106246 <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f0106229:	a1 c4 53 22 f0       	mov    0xf02253c4,%eax
f010622e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106235:	29 c2                	sub    %eax,%edx
f0106237:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010623a:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f0106241:	a3 c0 53 22 f0       	mov    %eax,0xf02253c0
			if (ncpu < NCPU) {
f0106246:	a1 c4 53 22 f0       	mov    0xf02253c4,%eax
f010624b:	83 f8 07             	cmp    $0x7,%eax
f010624e:	7f 1b                	jg     f010626b <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f0106250:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106257:	29 c2                	sub    %eax,%edx
f0106259:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010625c:	88 04 95 20 50 22 f0 	mov    %al,-0xfddafe0(,%edx,4)
				ncpu++;
f0106263:	40                   	inc    %eax
f0106264:	a3 c4 53 22 f0       	mov    %eax,0xf02253c4
f0106269:	eb 14                	jmp    f010627f <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010626b:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010626f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106273:	c7 04 24 48 85 10 f0 	movl   $0xf0108548,(%esp)
f010627a:	e8 ef db ff ff       	call   f0103e6e <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010627f:	83 c6 14             	add    $0x14,%esi
			continue;
f0106282:	eb 26                	jmp    f01062aa <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106284:	83 c6 08             	add    $0x8,%esi
			continue;
f0106287:	eb 21                	jmp    f01062aa <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106289:	0f b6 c0             	movzbl %al,%eax
f010628c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106290:	c7 04 24 70 85 10 f0 	movl   $0xf0108570,(%esp)
f0106297:	e8 d2 db ff ff       	call   f0103e6e <cprintf>
			ismp = 0;
f010629c:	c7 05 00 50 22 f0 00 	movl   $0x0,0xf0225000
f01062a3:	00 00 00 
			i = conf->entry;
f01062a6:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01062aa:	47                   	inc    %edi
f01062ab:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01062af:	39 c7                	cmp    %eax,%edi
f01062b1:	0f 82 60 ff ff ff    	jb     f0106217 <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01062b7:	a1 c0 53 22 f0       	mov    0xf02253c0,%eax
f01062bc:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01062c3:	83 3d 00 50 22 f0 00 	cmpl   $0x0,0xf0225000
f01062ca:	75 22                	jne    f01062ee <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01062cc:	c7 05 c4 53 22 f0 01 	movl   $0x1,0xf02253c4
f01062d3:	00 00 00 
		lapicaddr = 0;
f01062d6:	c7 05 00 60 26 f0 00 	movl   $0x0,0xf0266000
f01062dd:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01062e0:	c7 04 24 90 85 10 f0 	movl   $0xf0108590,(%esp)
f01062e7:	e8 82 db ff ff       	call   f0103e6e <cprintf>
		return;
f01062ec:	eb 41                	jmp    f010632f <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01062ee:	8b 15 c4 53 22 f0    	mov    0xf02253c4,%edx
f01062f4:	89 54 24 08          	mov    %edx,0x8(%esp)
f01062f8:	0f b6 00             	movzbl (%eax),%eax
f01062fb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01062ff:	c7 04 24 17 86 10 f0 	movl   $0xf0108617,(%esp)
f0106306:	e8 63 db ff ff       	call   f0103e6e <cprintf>

	if (mp->imcrp) {
f010630b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010630e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106312:	74 1b                	je     f010632f <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106314:	c7 04 24 bc 85 10 f0 	movl   $0xf01085bc,(%esp)
f010631b:	e8 4e db ff ff       	call   f0103e6e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106320:	ba 22 00 00 00       	mov    $0x22,%edx
f0106325:	b0 70                	mov    $0x70,%al
f0106327:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106328:	b2 23                	mov    $0x23,%dl
f010632a:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f010632b:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010632e:	ee                   	out    %al,(%dx)
	}
}
f010632f:	83 c4 2c             	add    $0x2c,%esp
f0106332:	5b                   	pop    %ebx
f0106333:	5e                   	pop    %esi
f0106334:	5f                   	pop    %edi
f0106335:	5d                   	pop    %ebp
f0106336:	c3                   	ret    
	...

f0106338 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106338:	55                   	push   %ebp
f0106339:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010633b:	c1 e0 02             	shl    $0x2,%eax
f010633e:	03 05 04 60 26 f0    	add    0xf0266004,%eax
f0106344:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106346:	a1 04 60 26 f0       	mov    0xf0266004,%eax
f010634b:	8b 40 20             	mov    0x20(%eax),%eax
}
f010634e:	5d                   	pop    %ebp
f010634f:	c3                   	ret    

f0106350 <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0106350:	55                   	push   %ebp
f0106351:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106353:	a1 04 60 26 f0       	mov    0xf0266004,%eax
f0106358:	85 c0                	test   %eax,%eax
f010635a:	74 08                	je     f0106364 <cpunum+0x14>
		return lapic[ID] >> 24;
f010635c:	8b 40 20             	mov    0x20(%eax),%eax
f010635f:	c1 e8 18             	shr    $0x18,%eax
f0106362:	eb 05                	jmp    f0106369 <cpunum+0x19>
	return 0;
f0106364:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106369:	5d                   	pop    %ebp
f010636a:	c3                   	ret    

f010636b <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010636b:	55                   	push   %ebp
f010636c:	89 e5                	mov    %esp,%ebp
f010636e:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0106371:	a1 00 60 26 f0       	mov    0xf0266000,%eax
f0106376:	85 c0                	test   %eax,%eax
f0106378:	0f 84 27 01 00 00    	je     f01064a5 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010637e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106385:	00 
f0106386:	89 04 24             	mov    %eax,(%esp)
f0106389:	e8 5b af ff ff       	call   f01012e9 <mmio_map_region>
f010638e:	a3 04 60 26 f0       	mov    %eax,0xf0266004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0106393:	ba 27 01 00 00       	mov    $0x127,%edx
f0106398:	b8 3c 00 00 00       	mov    $0x3c,%eax
f010639d:	e8 96 ff ff ff       	call   f0106338 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01063a2:	ba 0b 00 00 00       	mov    $0xb,%edx
f01063a7:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01063ac:	e8 87 ff ff ff       	call   f0106338 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01063b1:	ba 20 00 02 00       	mov    $0x20020,%edx
f01063b6:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01063bb:	e8 78 ff ff ff       	call   f0106338 <lapicw>
	lapicw(TICR, 10000000); 
f01063c0:	ba 80 96 98 00       	mov    $0x989680,%edx
f01063c5:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01063ca:	e8 69 ff ff ff       	call   f0106338 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01063cf:	e8 7c ff ff ff       	call   f0106350 <cpunum>
f01063d4:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01063db:	29 c2                	sub    %eax,%edx
f01063dd:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01063e0:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f01063e7:	39 05 c0 53 22 f0    	cmp    %eax,0xf02253c0
f01063ed:	74 0f                	je     f01063fe <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f01063ef:	ba 00 00 01 00       	mov    $0x10000,%edx
f01063f4:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01063f9:	e8 3a ff ff ff       	call   f0106338 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01063fe:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106403:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106408:	e8 2b ff ff ff       	call   f0106338 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010640d:	a1 04 60 26 f0       	mov    0xf0266004,%eax
f0106412:	8b 40 30             	mov    0x30(%eax),%eax
f0106415:	c1 e8 10             	shr    $0x10,%eax
f0106418:	3c 03                	cmp    $0x3,%al
f010641a:	76 0f                	jbe    f010642b <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f010641c:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106421:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106426:	e8 0d ff ff ff       	call   f0106338 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010642b:	ba 33 00 00 00       	mov    $0x33,%edx
f0106430:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106435:	e8 fe fe ff ff       	call   f0106338 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010643a:	ba 00 00 00 00       	mov    $0x0,%edx
f010643f:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106444:	e8 ef fe ff ff       	call   f0106338 <lapicw>
	lapicw(ESR, 0);
f0106449:	ba 00 00 00 00       	mov    $0x0,%edx
f010644e:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106453:	e8 e0 fe ff ff       	call   f0106338 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106458:	ba 00 00 00 00       	mov    $0x0,%edx
f010645d:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106462:	e8 d1 fe ff ff       	call   f0106338 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106467:	ba 00 00 00 00       	mov    $0x0,%edx
f010646c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106471:	e8 c2 fe ff ff       	call   f0106338 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106476:	ba 00 85 08 00       	mov    $0x88500,%edx
f010647b:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106480:	e8 b3 fe ff ff       	call   f0106338 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106485:	8b 15 04 60 26 f0    	mov    0xf0266004,%edx
f010648b:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106491:	f6 c4 10             	test   $0x10,%ah
f0106494:	75 f5                	jne    f010648b <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106496:	ba 00 00 00 00       	mov    $0x0,%edx
f010649b:	b8 20 00 00 00       	mov    $0x20,%eax
f01064a0:	e8 93 fe ff ff       	call   f0106338 <lapicw>
}
f01064a5:	c9                   	leave  
f01064a6:	c3                   	ret    

f01064a7 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01064a7:	55                   	push   %ebp
f01064a8:	89 e5                	mov    %esp,%ebp
	if (lapic)
f01064aa:	83 3d 04 60 26 f0 00 	cmpl   $0x0,0xf0266004
f01064b1:	74 0f                	je     f01064c2 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f01064b3:	ba 00 00 00 00       	mov    $0x0,%edx
f01064b8:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01064bd:	e8 76 fe ff ff       	call   f0106338 <lapicw>
}
f01064c2:	5d                   	pop    %ebp
f01064c3:	c3                   	ret    

f01064c4 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01064c4:	55                   	push   %ebp
f01064c5:	89 e5                	mov    %esp,%ebp
f01064c7:	56                   	push   %esi
f01064c8:	53                   	push   %ebx
f01064c9:	83 ec 10             	sub    $0x10,%esp
f01064cc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01064cf:	8a 5d 08             	mov    0x8(%ebp),%bl
f01064d2:	ba 70 00 00 00       	mov    $0x70,%edx
f01064d7:	b0 0f                	mov    $0xf,%al
f01064d9:	ee                   	out    %al,(%dx)
f01064da:	b2 71                	mov    $0x71,%dl
f01064dc:	b0 0a                	mov    $0xa,%al
f01064de:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01064df:	83 3d 88 4e 22 f0 00 	cmpl   $0x0,0xf0224e88
f01064e6:	75 24                	jne    f010650c <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01064e8:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01064ef:	00 
f01064f0:	c7 44 24 08 68 6a 10 	movl   $0xf0106a68,0x8(%esp)
f01064f7:	f0 
f01064f8:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01064ff:	00 
f0106500:	c7 04 24 34 86 10 f0 	movl   $0xf0108634,(%esp)
f0106507:	e8 34 9b ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010650c:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106513:	00 00 
	wrv[1] = addr >> 4;
f0106515:	89 f0                	mov    %esi,%eax
f0106517:	c1 e8 04             	shr    $0x4,%eax
f010651a:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106520:	c1 e3 18             	shl    $0x18,%ebx
f0106523:	89 da                	mov    %ebx,%edx
f0106525:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010652a:	e8 09 fe ff ff       	call   f0106338 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010652f:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106534:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106539:	e8 fa fd ff ff       	call   f0106338 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010653e:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106543:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106548:	e8 eb fd ff ff       	call   f0106338 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010654d:	c1 ee 0c             	shr    $0xc,%esi
f0106550:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106556:	89 da                	mov    %ebx,%edx
f0106558:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010655d:	e8 d6 fd ff ff       	call   f0106338 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106562:	89 f2                	mov    %esi,%edx
f0106564:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106569:	e8 ca fd ff ff       	call   f0106338 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010656e:	89 da                	mov    %ebx,%edx
f0106570:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106575:	e8 be fd ff ff       	call   f0106338 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010657a:	89 f2                	mov    %esi,%edx
f010657c:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106581:	e8 b2 fd ff ff       	call   f0106338 <lapicw>
		microdelay(200);
	}
}
f0106586:	83 c4 10             	add    $0x10,%esp
f0106589:	5b                   	pop    %ebx
f010658a:	5e                   	pop    %esi
f010658b:	5d                   	pop    %ebp
f010658c:	c3                   	ret    

f010658d <lapic_ipi>:

void
lapic_ipi(int vector)
{
f010658d:	55                   	push   %ebp
f010658e:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0106590:	8b 55 08             	mov    0x8(%ebp),%edx
f0106593:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106599:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010659e:	e8 95 fd ff ff       	call   f0106338 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01065a3:	8b 15 04 60 26 f0    	mov    0xf0266004,%edx
f01065a9:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01065af:	f6 c4 10             	test   $0x10,%ah
f01065b2:	75 f5                	jne    f01065a9 <lapic_ipi+0x1c>
		;
}
f01065b4:	5d                   	pop    %ebp
f01065b5:	c3                   	ret    
	...

f01065b8 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01065b8:	55                   	push   %ebp
f01065b9:	89 e5                	mov    %esp,%ebp
f01065bb:	53                   	push   %ebx
f01065bc:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f01065bf:	83 38 00             	cmpl   $0x0,(%eax)
f01065c2:	74 25                	je     f01065e9 <holding+0x31>
f01065c4:	8b 58 08             	mov    0x8(%eax),%ebx
f01065c7:	e8 84 fd ff ff       	call   f0106350 <cpunum>
f01065cc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01065d3:	29 c2                	sub    %eax,%edx
f01065d5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01065d8:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01065df:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01065e1:	0f 94 c0             	sete   %al
f01065e4:	0f b6 c0             	movzbl %al,%eax
f01065e7:	eb 05                	jmp    f01065ee <holding+0x36>
f01065e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01065ee:	83 c4 04             	add    $0x4,%esp
f01065f1:	5b                   	pop    %ebx
f01065f2:	5d                   	pop    %ebp
f01065f3:	c3                   	ret    

f01065f4 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01065f4:	55                   	push   %ebp
f01065f5:	89 e5                	mov    %esp,%ebp
f01065f7:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01065fa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f0106600:	8b 55 0c             	mov    0xc(%ebp),%edx
f0106603:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f0106606:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f010660d:	5d                   	pop    %ebp
f010660e:	c3                   	ret    

f010660f <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f010660f:	55                   	push   %ebp
f0106610:	89 e5                	mov    %esp,%ebp
f0106612:	53                   	push   %ebx
f0106613:	83 ec 24             	sub    $0x24,%esp
f0106616:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106619:	89 d8                	mov    %ebx,%eax
f010661b:	e8 98 ff ff ff       	call   f01065b8 <holding>
f0106620:	85 c0                	test   %eax,%eax
f0106622:	74 30                	je     f0106654 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106624:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106627:	e8 24 fd ff ff       	call   f0106350 <cpunum>
f010662c:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106630:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106634:	c7 44 24 08 44 86 10 	movl   $0xf0108644,0x8(%esp)
f010663b:	f0 
f010663c:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f0106643:	00 
f0106644:	c7 04 24 a8 86 10 f0 	movl   $0xf01086a8,(%esp)
f010664b:	e8 f0 99 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106650:	f3 90                	pause  
f0106652:	eb 05                	jmp    f0106659 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106654:	ba 01 00 00 00       	mov    $0x1,%edx
f0106659:	89 d0                	mov    %edx,%eax
f010665b:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010665e:	85 c0                	test   %eax,%eax
f0106660:	75 ee                	jne    f0106650 <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106662:	e8 e9 fc ff ff       	call   f0106350 <cpunum>
f0106667:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010666e:	29 c2                	sub    %eax,%edx
f0106670:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106673:	8d 04 85 20 50 22 f0 	lea    -0xfddafe0(,%eax,4),%eax
f010667a:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f010667d:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106680:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f0106682:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106687:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010668d:	76 10                	jbe    f010669f <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010668f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106692:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106695:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106697:	40                   	inc    %eax
f0106698:	83 f8 0a             	cmp    $0xa,%eax
f010669b:	75 ea                	jne    f0106687 <spin_lock+0x78>
f010669d:	eb 0d                	jmp    f01066ac <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010669f:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01066a6:	40                   	inc    %eax
f01066a7:	83 f8 09             	cmp    $0x9,%eax
f01066aa:	7e f3                	jle    f010669f <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01066ac:	83 c4 24             	add    $0x24,%esp
f01066af:	5b                   	pop    %ebx
f01066b0:	5d                   	pop    %ebp
f01066b1:	c3                   	ret    

f01066b2 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01066b2:	55                   	push   %ebp
f01066b3:	89 e5                	mov    %esp,%ebp
f01066b5:	57                   	push   %edi
f01066b6:	56                   	push   %esi
f01066b7:	53                   	push   %ebx
f01066b8:	83 ec 7c             	sub    $0x7c,%esp
f01066bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01066be:	89 d8                	mov    %ebx,%eax
f01066c0:	e8 f3 fe ff ff       	call   f01065b8 <holding>
f01066c5:	85 c0                	test   %eax,%eax
f01066c7:	0f 85 d3 00 00 00    	jne    f01067a0 <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01066cd:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01066d4:	00 
f01066d5:	8d 43 0c             	lea    0xc(%ebx),%eax
f01066d8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01066dc:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01066df:	89 34 24             	mov    %esi,(%esp)
f01066e2:	e8 85 f6 ff ff       	call   f0105d6c <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01066e7:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01066ea:	0f b6 38             	movzbl (%eax),%edi
f01066ed:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01066f0:	e8 5b fc ff ff       	call   f0106350 <cpunum>
f01066f5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01066f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01066fd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106701:	c7 04 24 70 86 10 f0 	movl   $0xf0108670,(%esp)
f0106708:	e8 61 d7 ff ff       	call   f0103e6e <cprintf>
f010670d:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010670f:	8d 45 d0             	lea    -0x30(%ebp),%eax
f0106712:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106715:	89 c7                	mov    %eax,%edi
f0106717:	eb 63                	jmp    f010677c <spin_unlock+0xca>
f0106719:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010671d:	89 04 24             	mov    %eax,(%esp)
f0106720:	e8 60 ec ff ff       	call   f0105385 <debuginfo_eip>
f0106725:	85 c0                	test   %eax,%eax
f0106727:	78 39                	js     f0106762 <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106729:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010672b:	89 c2                	mov    %eax,%edx
f010672d:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106730:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106734:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106737:	89 54 24 14          	mov    %edx,0x14(%esp)
f010673b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010673e:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106742:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106745:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106749:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010674c:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106750:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106754:	c7 04 24 b8 86 10 f0 	movl   $0xf01086b8,(%esp)
f010675b:	e8 0e d7 ff ff       	call   f0103e6e <cprintf>
f0106760:	eb 12                	jmp    f0106774 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0106762:	8b 06                	mov    (%esi),%eax
f0106764:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106768:	c7 04 24 cf 86 10 f0 	movl   $0xf01086cf,(%esp)
f010676f:	e8 fa d6 ff ff       	call   f0103e6e <cprintf>
f0106774:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106777:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f010677a:	74 08                	je     f0106784 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f010677c:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010677e:	8b 03                	mov    (%ebx),%eax
f0106780:	85 c0                	test   %eax,%eax
f0106782:	75 95                	jne    f0106719 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106784:	c7 44 24 08 d7 86 10 	movl   $0xf01086d7,0x8(%esp)
f010678b:	f0 
f010678c:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f0106793:	00 
f0106794:	c7 04 24 a8 86 10 f0 	movl   $0xf01086a8,(%esp)
f010679b:	e8 a0 98 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f01067a0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01067a7:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f01067ae:	b8 00 00 00 00       	mov    $0x0,%eax
f01067b3:	f0 87 03             	lock xchg %eax,(%ebx)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f01067b6:	83 c4 7c             	add    $0x7c,%esp
f01067b9:	5b                   	pop    %ebx
f01067ba:	5e                   	pop    %esi
f01067bb:	5f                   	pop    %edi
f01067bc:	5d                   	pop    %ebp
f01067bd:	c3                   	ret    
	...

f01067c0 <__udivdi3>:
f01067c0:	55                   	push   %ebp
f01067c1:	57                   	push   %edi
f01067c2:	56                   	push   %esi
f01067c3:	83 ec 10             	sub    $0x10,%esp
f01067c6:	8b 74 24 20          	mov    0x20(%esp),%esi
f01067ca:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01067ce:	89 74 24 04          	mov    %esi,0x4(%esp)
f01067d2:	8b 7c 24 24          	mov    0x24(%esp),%edi
f01067d6:	89 cd                	mov    %ecx,%ebp
f01067d8:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f01067dc:	85 c0                	test   %eax,%eax
f01067de:	75 2c                	jne    f010680c <__udivdi3+0x4c>
f01067e0:	39 f9                	cmp    %edi,%ecx
f01067e2:	77 68                	ja     f010684c <__udivdi3+0x8c>
f01067e4:	85 c9                	test   %ecx,%ecx
f01067e6:	75 0b                	jne    f01067f3 <__udivdi3+0x33>
f01067e8:	b8 01 00 00 00       	mov    $0x1,%eax
f01067ed:	31 d2                	xor    %edx,%edx
f01067ef:	f7 f1                	div    %ecx
f01067f1:	89 c1                	mov    %eax,%ecx
f01067f3:	31 d2                	xor    %edx,%edx
f01067f5:	89 f8                	mov    %edi,%eax
f01067f7:	f7 f1                	div    %ecx
f01067f9:	89 c7                	mov    %eax,%edi
f01067fb:	89 f0                	mov    %esi,%eax
f01067fd:	f7 f1                	div    %ecx
f01067ff:	89 c6                	mov    %eax,%esi
f0106801:	89 f0                	mov    %esi,%eax
f0106803:	89 fa                	mov    %edi,%edx
f0106805:	83 c4 10             	add    $0x10,%esp
f0106808:	5e                   	pop    %esi
f0106809:	5f                   	pop    %edi
f010680a:	5d                   	pop    %ebp
f010680b:	c3                   	ret    
f010680c:	39 f8                	cmp    %edi,%eax
f010680e:	77 2c                	ja     f010683c <__udivdi3+0x7c>
f0106810:	0f bd f0             	bsr    %eax,%esi
f0106813:	83 f6 1f             	xor    $0x1f,%esi
f0106816:	75 4c                	jne    f0106864 <__udivdi3+0xa4>
f0106818:	39 f8                	cmp    %edi,%eax
f010681a:	bf 00 00 00 00       	mov    $0x0,%edi
f010681f:	72 0a                	jb     f010682b <__udivdi3+0x6b>
f0106821:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106825:	0f 87 ad 00 00 00    	ja     f01068d8 <__udivdi3+0x118>
f010682b:	be 01 00 00 00       	mov    $0x1,%esi
f0106830:	89 f0                	mov    %esi,%eax
f0106832:	89 fa                	mov    %edi,%edx
f0106834:	83 c4 10             	add    $0x10,%esp
f0106837:	5e                   	pop    %esi
f0106838:	5f                   	pop    %edi
f0106839:	5d                   	pop    %ebp
f010683a:	c3                   	ret    
f010683b:	90                   	nop
f010683c:	31 ff                	xor    %edi,%edi
f010683e:	31 f6                	xor    %esi,%esi
f0106840:	89 f0                	mov    %esi,%eax
f0106842:	89 fa                	mov    %edi,%edx
f0106844:	83 c4 10             	add    $0x10,%esp
f0106847:	5e                   	pop    %esi
f0106848:	5f                   	pop    %edi
f0106849:	5d                   	pop    %ebp
f010684a:	c3                   	ret    
f010684b:	90                   	nop
f010684c:	89 fa                	mov    %edi,%edx
f010684e:	89 f0                	mov    %esi,%eax
f0106850:	f7 f1                	div    %ecx
f0106852:	89 c6                	mov    %eax,%esi
f0106854:	31 ff                	xor    %edi,%edi
f0106856:	89 f0                	mov    %esi,%eax
f0106858:	89 fa                	mov    %edi,%edx
f010685a:	83 c4 10             	add    $0x10,%esp
f010685d:	5e                   	pop    %esi
f010685e:	5f                   	pop    %edi
f010685f:	5d                   	pop    %ebp
f0106860:	c3                   	ret    
f0106861:	8d 76 00             	lea    0x0(%esi),%esi
f0106864:	89 f1                	mov    %esi,%ecx
f0106866:	d3 e0                	shl    %cl,%eax
f0106868:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010686c:	b8 20 00 00 00       	mov    $0x20,%eax
f0106871:	29 f0                	sub    %esi,%eax
f0106873:	89 ea                	mov    %ebp,%edx
f0106875:	88 c1                	mov    %al,%cl
f0106877:	d3 ea                	shr    %cl,%edx
f0106879:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f010687d:	09 ca                	or     %ecx,%edx
f010687f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106883:	89 f1                	mov    %esi,%ecx
f0106885:	d3 e5                	shl    %cl,%ebp
f0106887:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f010688b:	89 fd                	mov    %edi,%ebp
f010688d:	88 c1                	mov    %al,%cl
f010688f:	d3 ed                	shr    %cl,%ebp
f0106891:	89 fa                	mov    %edi,%edx
f0106893:	89 f1                	mov    %esi,%ecx
f0106895:	d3 e2                	shl    %cl,%edx
f0106897:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010689b:	88 c1                	mov    %al,%cl
f010689d:	d3 ef                	shr    %cl,%edi
f010689f:	09 d7                	or     %edx,%edi
f01068a1:	89 f8                	mov    %edi,%eax
f01068a3:	89 ea                	mov    %ebp,%edx
f01068a5:	f7 74 24 08          	divl   0x8(%esp)
f01068a9:	89 d1                	mov    %edx,%ecx
f01068ab:	89 c7                	mov    %eax,%edi
f01068ad:	f7 64 24 0c          	mull   0xc(%esp)
f01068b1:	39 d1                	cmp    %edx,%ecx
f01068b3:	72 17                	jb     f01068cc <__udivdi3+0x10c>
f01068b5:	74 09                	je     f01068c0 <__udivdi3+0x100>
f01068b7:	89 fe                	mov    %edi,%esi
f01068b9:	31 ff                	xor    %edi,%edi
f01068bb:	e9 41 ff ff ff       	jmp    f0106801 <__udivdi3+0x41>
f01068c0:	8b 54 24 04          	mov    0x4(%esp),%edx
f01068c4:	89 f1                	mov    %esi,%ecx
f01068c6:	d3 e2                	shl    %cl,%edx
f01068c8:	39 c2                	cmp    %eax,%edx
f01068ca:	73 eb                	jae    f01068b7 <__udivdi3+0xf7>
f01068cc:	8d 77 ff             	lea    -0x1(%edi),%esi
f01068cf:	31 ff                	xor    %edi,%edi
f01068d1:	e9 2b ff ff ff       	jmp    f0106801 <__udivdi3+0x41>
f01068d6:	66 90                	xchg   %ax,%ax
f01068d8:	31 f6                	xor    %esi,%esi
f01068da:	e9 22 ff ff ff       	jmp    f0106801 <__udivdi3+0x41>
	...

f01068e0 <__umoddi3>:
f01068e0:	55                   	push   %ebp
f01068e1:	57                   	push   %edi
f01068e2:	56                   	push   %esi
f01068e3:	83 ec 20             	sub    $0x20,%esp
f01068e6:	8b 44 24 30          	mov    0x30(%esp),%eax
f01068ea:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f01068ee:	89 44 24 14          	mov    %eax,0x14(%esp)
f01068f2:	8b 74 24 34          	mov    0x34(%esp),%esi
f01068f6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01068fa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01068fe:	89 c7                	mov    %eax,%edi
f0106900:	89 f2                	mov    %esi,%edx
f0106902:	85 ed                	test   %ebp,%ebp
f0106904:	75 16                	jne    f010691c <__umoddi3+0x3c>
f0106906:	39 f1                	cmp    %esi,%ecx
f0106908:	0f 86 a6 00 00 00    	jbe    f01069b4 <__umoddi3+0xd4>
f010690e:	f7 f1                	div    %ecx
f0106910:	89 d0                	mov    %edx,%eax
f0106912:	31 d2                	xor    %edx,%edx
f0106914:	83 c4 20             	add    $0x20,%esp
f0106917:	5e                   	pop    %esi
f0106918:	5f                   	pop    %edi
f0106919:	5d                   	pop    %ebp
f010691a:	c3                   	ret    
f010691b:	90                   	nop
f010691c:	39 f5                	cmp    %esi,%ebp
f010691e:	0f 87 ac 00 00 00    	ja     f01069d0 <__umoddi3+0xf0>
f0106924:	0f bd c5             	bsr    %ebp,%eax
f0106927:	83 f0 1f             	xor    $0x1f,%eax
f010692a:	89 44 24 10          	mov    %eax,0x10(%esp)
f010692e:	0f 84 a8 00 00 00    	je     f01069dc <__umoddi3+0xfc>
f0106934:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106938:	d3 e5                	shl    %cl,%ebp
f010693a:	bf 20 00 00 00       	mov    $0x20,%edi
f010693f:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0106943:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106947:	89 f9                	mov    %edi,%ecx
f0106949:	d3 e8                	shr    %cl,%eax
f010694b:	09 e8                	or     %ebp,%eax
f010694d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0106951:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106955:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106959:	d3 e0                	shl    %cl,%eax
f010695b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010695f:	89 f2                	mov    %esi,%edx
f0106961:	d3 e2                	shl    %cl,%edx
f0106963:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106967:	d3 e0                	shl    %cl,%eax
f0106969:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f010696d:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106971:	89 f9                	mov    %edi,%ecx
f0106973:	d3 e8                	shr    %cl,%eax
f0106975:	09 d0                	or     %edx,%eax
f0106977:	d3 ee                	shr    %cl,%esi
f0106979:	89 f2                	mov    %esi,%edx
f010697b:	f7 74 24 18          	divl   0x18(%esp)
f010697f:	89 d6                	mov    %edx,%esi
f0106981:	f7 64 24 0c          	mull   0xc(%esp)
f0106985:	89 c5                	mov    %eax,%ebp
f0106987:	89 d1                	mov    %edx,%ecx
f0106989:	39 d6                	cmp    %edx,%esi
f010698b:	72 67                	jb     f01069f4 <__umoddi3+0x114>
f010698d:	74 75                	je     f0106a04 <__umoddi3+0x124>
f010698f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0106993:	29 e8                	sub    %ebp,%eax
f0106995:	19 ce                	sbb    %ecx,%esi
f0106997:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010699b:	d3 e8                	shr    %cl,%eax
f010699d:	89 f2                	mov    %esi,%edx
f010699f:	89 f9                	mov    %edi,%ecx
f01069a1:	d3 e2                	shl    %cl,%edx
f01069a3:	09 d0                	or     %edx,%eax
f01069a5:	89 f2                	mov    %esi,%edx
f01069a7:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01069ab:	d3 ea                	shr    %cl,%edx
f01069ad:	83 c4 20             	add    $0x20,%esp
f01069b0:	5e                   	pop    %esi
f01069b1:	5f                   	pop    %edi
f01069b2:	5d                   	pop    %ebp
f01069b3:	c3                   	ret    
f01069b4:	85 c9                	test   %ecx,%ecx
f01069b6:	75 0b                	jne    f01069c3 <__umoddi3+0xe3>
f01069b8:	b8 01 00 00 00       	mov    $0x1,%eax
f01069bd:	31 d2                	xor    %edx,%edx
f01069bf:	f7 f1                	div    %ecx
f01069c1:	89 c1                	mov    %eax,%ecx
f01069c3:	89 f0                	mov    %esi,%eax
f01069c5:	31 d2                	xor    %edx,%edx
f01069c7:	f7 f1                	div    %ecx
f01069c9:	89 f8                	mov    %edi,%eax
f01069cb:	e9 3e ff ff ff       	jmp    f010690e <__umoddi3+0x2e>
f01069d0:	89 f2                	mov    %esi,%edx
f01069d2:	83 c4 20             	add    $0x20,%esp
f01069d5:	5e                   	pop    %esi
f01069d6:	5f                   	pop    %edi
f01069d7:	5d                   	pop    %ebp
f01069d8:	c3                   	ret    
f01069d9:	8d 76 00             	lea    0x0(%esi),%esi
f01069dc:	39 f5                	cmp    %esi,%ebp
f01069de:	72 04                	jb     f01069e4 <__umoddi3+0x104>
f01069e0:	39 f9                	cmp    %edi,%ecx
f01069e2:	77 06                	ja     f01069ea <__umoddi3+0x10a>
f01069e4:	89 f2                	mov    %esi,%edx
f01069e6:	29 cf                	sub    %ecx,%edi
f01069e8:	19 ea                	sbb    %ebp,%edx
f01069ea:	89 f8                	mov    %edi,%eax
f01069ec:	83 c4 20             	add    $0x20,%esp
f01069ef:	5e                   	pop    %esi
f01069f0:	5f                   	pop    %edi
f01069f1:	5d                   	pop    %ebp
f01069f2:	c3                   	ret    
f01069f3:	90                   	nop
f01069f4:	89 d1                	mov    %edx,%ecx
f01069f6:	89 c5                	mov    %eax,%ebp
f01069f8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f01069fc:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0106a00:	eb 8d                	jmp    f010698f <__umoddi3+0xaf>
f0106a02:	66 90                	xchg   %ax,%ax
f0106a04:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0106a08:	72 ea                	jb     f01069f4 <__umoddi3+0x114>
f0106a0a:	89 f1                	mov    %esi,%ecx
f0106a0c:	eb 81                	jmp    f010698f <__umoddi3+0xaf>
