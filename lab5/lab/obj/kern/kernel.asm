
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
f0100015:	b8 00 60 12 00       	mov    $0x126000,%eax
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
f0100034:	bc 00 60 12 f0       	mov    $0xf0126000,%esp

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
f010004b:	83 3d 80 2e 22 f0 00 	cmpl   $0x0,0xf0222e80
f0100052:	75 46                	jne    f010009a <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100054:	89 35 80 2e 22 f0    	mov    %esi,0xf0222e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010005a:	fa                   	cli    
f010005b:	fc                   	cld    

	va_start(ap, fmt);
f010005c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005f:	e8 c8 60 00 00       	call   f010612c <cpunum>
f0100064:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100067:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010006b:	8b 55 08             	mov    0x8(%ebp),%edx
f010006e:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100072:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100076:	c7 04 24 00 68 10 f0 	movl   $0xf0106800,(%esp)
f010007d:	e8 c8 3b 00 00       	call   f0103c4a <cprintf>
	vcprintf(fmt, ap);
f0100082:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100086:	89 34 24             	mov    %esi,(%esp)
f0100089:	e8 89 3b 00 00       	call   f0103c17 <vcprintf>
	cprintf("\n");
f010008e:	c7 04 24 8c 79 10 f0 	movl   $0xf010798c,(%esp)
f0100095:	e8 b0 3b 00 00       	call   f0103c4a <cprintf>
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
f01000ae:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000b3:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000b8:	77 20                	ja     f01000da <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ba:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01000be:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f01000c5:	f0 
f01000c6:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01000cd:	00 
f01000ce:	c7 04 24 6b 68 10 f0 	movl   $0xf010686b,(%esp)
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
f01000e2:	e8 45 60 00 00       	call   f010612c <cpunum>
f01000e7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000eb:	c7 04 24 77 68 10 f0 	movl   $0xf0106877,(%esp)
f01000f2:	e8 53 3b 00 00       	call   f0103c4a <cprintf>

	lapic_init();
f01000f7:	e8 4b 60 00 00       	call   f0106147 <lapic_init>
	env_init_percpu();
f01000fc:	e8 4d 34 00 00       	call   f010354e <env_init_percpu>
	trap_init_percpu();
f0100101:	e8 5e 3b 00 00       	call   f0103c64 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100106:	e8 21 60 00 00       	call   f010612c <cpunum>
f010010b:	6b d0 74             	imul   $0x74,%eax,%edx
f010010e:	81 c2 20 30 22 f0    	add    $0xf0223020,%edx
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
f010011d:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f0100124:	e8 c2 62 00 00       	call   f01063eb <spin_lock>
	//
	// Your code here:
	// Aquire lock
	lock_kernel();
	// Start execution
	sched_yield();
f0100129:	e8 28 48 00 00       	call   f0104956 <sched_yield>

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
f0100142:	c7 04 24 8d 68 10 f0 	movl   $0xf010688d,(%esp)
f0100149:	e8 fc 3a 00 00       	call   f0103c4a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f010014e:	e8 05 12 00 00       	call   f0101358 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100153:	e8 20 34 00 00       	call   f0103578 <env_init>
	trap_init();
f0100158:	e8 09 3c 00 00       	call   f0103d66 <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f010015d:	e8 e2 5c 00 00       	call   f0105e44 <mp_init>
	lapic_init();
f0100162:	e8 e0 5f 00 00       	call   f0106147 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f0100167:	e8 34 3a 00 00       	call   f0103ba0 <pic_init>
f010016c:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f0100173:	e8 73 62 00 00       	call   f01063eb <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100178:	83 3d 88 2e 22 f0 07 	cmpl   $0x7,0xf0222e88
f010017f:	77 24                	ja     f01001a5 <i386_init+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100181:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f0100188:	00 
f0100189:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0100190:	f0 
f0100191:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
f0100198:	00 
f0100199:	c7 04 24 6b 68 10 f0 	movl   $0xf010686b,(%esp)
f01001a0:	e8 9b fe ff ff       	call   f0100040 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01001a5:	b8 6e 5d 10 f0       	mov    $0xf0105d6e,%eax
f01001aa:	2d f4 5c 10 f0       	sub    $0xf0105cf4,%eax
f01001af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01001b3:	c7 44 24 04 f4 5c 10 	movl   $0xf0105cf4,0x4(%esp)
f01001ba:	f0 
f01001bb:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f01001c2:	e8 81 59 00 00       	call   f0105b48 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f01001c7:	bb 20 30 22 f0       	mov    $0xf0223020,%ebx
f01001cc:	eb 6f                	jmp    f010023d <i386_init+0x10f>
		if (c == cpus + cpunum())  // We've started already.
f01001ce:	e8 59 5f 00 00       	call   f010612c <cpunum>
f01001d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01001da:	29 c2                	sub    %eax,%edx
f01001dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01001df:	8d 04 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%eax
f01001e6:	39 c3                	cmp    %eax,%ebx
f01001e8:	74 50                	je     f010023a <i386_init+0x10c>

static void boot_aps(void);


void
i386_init(void)
f01001ea:	89 d8                	mov    %ebx,%eax
f01001ec:	2d 20 30 22 f0       	sub    $0xf0223020,%eax
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
f0100215:	05 00 40 22 f0       	add    $0xf0224000,%eax
f010021a:	a3 84 2e 22 f0       	mov    %eax,0xf0222e84
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010021f:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100226:	00 
f0100227:	0f b6 03             	movzbl (%ebx),%eax
f010022a:	89 04 24             	mov    %eax,(%esp)
f010022d:	e8 6e 60 00 00       	call   f01062a0 <lapic_startap>
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
f010023d:	a1 c4 33 22 f0       	mov    0xf02233c4,%eax
f0100242:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0100249:	29 c2                	sub    %eax,%edx
f010024b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010024e:	8d 04 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%eax
f0100255:	39 c3                	cmp    %eax,%ebx
f0100257:	0f 82 71 ff ff ff    	jb     f01001ce <i386_init+0xa0>

	// Starting non-boot CPUs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010025d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0100264:	00 
f0100265:	c7 04 24 bc 9a 1d f0 	movl   $0xf01d9abc,(%esp)
f010026c:	e8 f8 34 00 00       	call   f0103769 <env_create>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100271:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100278:	00 
f0100279:	c7 04 24 6e ae 1c f0 	movl   $0xf01cae6e,(%esp)
f0100280:	e8 e4 34 00 00       	call   f0103769 <env_create>
	// Touch all you want.
	ENV_CREATE(user_icode, ENV_TYPE_USER);
#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f0100285:	e8 96 03 00 00       	call   f0100620 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f010028a:	e8 c7 46 00 00       	call   f0104956 <sched_yield>

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
f01002a7:	c7 04 24 a8 68 10 f0 	movl   $0xf01068a8,(%esp)
f01002ae:	e8 97 39 00 00       	call   f0103c4a <cprintf>
	vcprintf(fmt, ap);
f01002b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01002b7:	8b 45 10             	mov    0x10(%ebp),%eax
f01002ba:	89 04 24             	mov    %eax,(%esp)
f01002bd:	e8 55 39 00 00       	call   f0103c17 <vcprintf>
	cprintf("\n");
f01002c2:	c7 04 24 8c 79 10 f0 	movl   $0xf010798c,(%esp)
f01002c9:	e8 7c 39 00 00       	call   f0103c4a <cprintf>
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
f010030d:	8b 15 24 22 22 f0    	mov    0xf0222224,%edx
f0100313:	88 82 20 20 22 f0    	mov    %al,-0xfdddfe0(%edx)
f0100319:	8d 42 01             	lea    0x1(%edx),%eax
f010031c:	a3 24 22 22 f0       	mov    %eax,0xf0222224
		if (cons.wpos == CONSBUFSIZE)
f0100321:	3d 00 02 00 00       	cmp    $0x200,%eax
f0100326:	75 0a                	jne    f0100332 <cons_intr+0x34>
			cons.wpos = 0;
f0100328:	c7 05 24 22 22 f0 00 	movl   $0x0,0xf0222224
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
f01003d8:	66 a1 34 22 22 f0    	mov    0xf0222234,%ax
f01003de:	66 85 c0             	test   %ax,%ax
f01003e1:	0f 84 e2 00 00 00    	je     f01004c9 <cons_putc+0x18a>
			crt_pos--;
f01003e7:	48                   	dec    %eax
f01003e8:	66 a3 34 22 22 f0    	mov    %ax,0xf0222234
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ee:	0f b7 c0             	movzwl %ax,%eax
f01003f1:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01003f7:	83 ce 20             	or     $0x20,%esi
f01003fa:	8b 15 30 22 22 f0    	mov    0xf0222230,%edx
f0100400:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100404:	eb 78                	jmp    f010047e <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100406:	66 83 05 34 22 22 f0 	addw   $0x50,0xf0222234
f010040d:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010040e:	66 8b 0d 34 22 22 f0 	mov    0xf0222234,%cx
f0100415:	bb 50 00 00 00       	mov    $0x50,%ebx
f010041a:	89 c8                	mov    %ecx,%eax
f010041c:	ba 00 00 00 00       	mov    $0x0,%edx
f0100421:	66 f7 f3             	div    %bx
f0100424:	66 29 d1             	sub    %dx,%cx
f0100427:	66 89 0d 34 22 22 f0 	mov    %cx,0xf0222234
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
f0100464:	66 a1 34 22 22 f0    	mov    0xf0222234,%ax
f010046a:	0f b7 c8             	movzwl %ax,%ecx
f010046d:	8b 15 30 22 22 f0    	mov    0xf0222230,%edx
f0100473:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f0100477:	40                   	inc    %eax
f0100478:	66 a3 34 22 22 f0    	mov    %ax,0xf0222234
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010047e:	66 81 3d 34 22 22 f0 	cmpw   $0x7cf,0xf0222234
f0100485:	cf 07 
f0100487:	76 40                	jbe    f01004c9 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100489:	a1 30 22 22 f0       	mov    0xf0222230,%eax
f010048e:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100495:	00 
f0100496:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010049c:	89 54 24 04          	mov    %edx,0x4(%esp)
f01004a0:	89 04 24             	mov    %eax,(%esp)
f01004a3:	e8 a0 56 00 00       	call   f0105b48 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004a8:	8b 15 30 22 22 f0    	mov    0xf0222230,%edx
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
f01004c1:	66 83 2d 34 22 22 f0 	subw   $0x50,0xf0222234
f01004c8:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004c9:	8b 0d 2c 22 22 f0    	mov    0xf022222c,%ecx
f01004cf:	b0 0e                	mov    $0xe,%al
f01004d1:	89 ca                	mov    %ecx,%edx
f01004d3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004d4:	66 8b 35 34 22 22 f0 	mov    0xf0222234,%si
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
f0100522:	83 0d 28 22 22 f0 40 	orl    $0x40,0xf0222228
		return 0;
f0100529:	bb 00 00 00 00       	mov    $0x0,%ebx
f010052e:	e9 ca 00 00 00       	jmp    f01005fd <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100533:	84 c0                	test   %al,%al
f0100535:	79 33                	jns    f010056a <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100537:	8b 0d 28 22 22 f0    	mov    0xf0222228,%ecx
f010053d:	f6 c1 40             	test   $0x40,%cl
f0100540:	75 05                	jne    f0100547 <kbd_proc_data+0x4e>
f0100542:	88 c2                	mov    %al,%dl
f0100544:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100547:	0f b6 d2             	movzbl %dl,%edx
f010054a:	8a 82 00 69 10 f0    	mov    -0xfef9700(%edx),%al
f0100550:	83 c8 40             	or     $0x40,%eax
f0100553:	0f b6 c0             	movzbl %al,%eax
f0100556:	f7 d0                	not    %eax
f0100558:	21 c1                	and    %eax,%ecx
f010055a:	89 0d 28 22 22 f0    	mov    %ecx,0xf0222228
		return 0;
f0100560:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100565:	e9 93 00 00 00       	jmp    f01005fd <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f010056a:	8b 0d 28 22 22 f0    	mov    0xf0222228,%ecx
f0100570:	f6 c1 40             	test   $0x40,%cl
f0100573:	74 0e                	je     f0100583 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100575:	88 c2                	mov    %al,%dl
f0100577:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f010057a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010057d:	89 0d 28 22 22 f0    	mov    %ecx,0xf0222228
	}

	shift |= shiftcode[data];
f0100583:	0f b6 d2             	movzbl %dl,%edx
f0100586:	0f b6 82 00 69 10 f0 	movzbl -0xfef9700(%edx),%eax
f010058d:	0b 05 28 22 22 f0    	or     0xf0222228,%eax
	shift ^= togglecode[data];
f0100593:	0f b6 8a 00 6a 10 f0 	movzbl -0xfef9600(%edx),%ecx
f010059a:	31 c8                	xor    %ecx,%eax
f010059c:	a3 28 22 22 f0       	mov    %eax,0xf0222228

	c = charcode[shift & (CTL | SHIFT)][data];
f01005a1:	89 c1                	mov    %eax,%ecx
f01005a3:	83 e1 03             	and    $0x3,%ecx
f01005a6:	8b 0c 8d 00 6b 10 f0 	mov    -0xfef9500(,%ecx,4),%ecx
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
f01005db:	c7 04 24 c2 68 10 f0 	movl   $0xf01068c2,(%esp)
f01005e2:	e8 63 36 00 00       	call   f0103c4a <cprintf>
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
f010060b:	80 3d 00 20 22 f0 00 	cmpb   $0x0,0xf0222000
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
f0100642:	8b 15 20 22 22 f0    	mov    0xf0222220,%edx
f0100648:	3b 15 24 22 22 f0    	cmp    0xf0222224,%edx
f010064e:	74 22                	je     f0100672 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100650:	0f b6 82 20 20 22 f0 	movzbl -0xfdddfe0(%edx),%eax
f0100657:	42                   	inc    %edx
f0100658:	89 15 20 22 22 f0    	mov    %edx,0xf0222220
		if (cons.rpos == CONSBUFSIZE)
f010065e:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100664:	75 11                	jne    f0100677 <cons_getc+0x45>
			cons.rpos = 0;
f0100666:	c7 05 20 22 22 f0 00 	movl   $0x0,0xf0222220
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
f010069e:	c7 05 2c 22 22 f0 b4 	movl   $0x3b4,0xf022222c
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
f01006b6:	c7 05 2c 22 22 f0 d4 	movl   $0x3d4,0xf022222c
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
f01006c5:	8b 0d 2c 22 22 f0    	mov    0xf022222c,%ecx
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
f01006e4:	89 35 30 22 22 f0    	mov    %esi,0xf0222230

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01006ea:	0f b6 d8             	movzbl %al,%ebx
f01006ed:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01006ef:	66 89 3d 34 22 22 f0 	mov    %di,0xf0222234

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006f6:	e8 25 ff ff ff       	call   f0100620 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006fb:	0f b7 05 a8 83 12 f0 	movzwl 0xf01283a8,%eax
f0100702:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100707:	89 04 24             	mov    %eax,(%esp)
f010070a:	e8 1d 34 00 00       	call   f0103b2c <irq_setmask_8259A>
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
f0100748:	a2 00 20 22 f0       	mov    %al,0xf0222000
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
f0100759:	0f b7 05 a8 83 12 f0 	movzwl 0xf01283a8,%eax
f0100760:	25 ef ff 00 00       	and    $0xffef,%eax
f0100765:	89 04 24             	mov    %eax,(%esp)
f0100768:	e8 bf 33 00 00       	call   f0103b2c <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010076d:	80 3d 00 20 22 f0 00 	cmpb   $0x0,0xf0222000
f0100774:	75 0c                	jne    f0100782 <cons_init+0x109>
		cprintf("Serial port does not exist!\n");
f0100776:	c7 04 24 ce 68 10 f0 	movl   $0xf01068ce,(%esp)
f010077d:	e8 c8 34 00 00       	call   f0103c4a <cprintf>
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
f01007be:	c7 04 24 10 6b 10 f0 	movl   $0xf0106b10,(%esp)
f01007c5:	e8 80 34 00 00       	call   f0103c4a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007ca:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01007d1:	00 
f01007d2:	c7 04 24 9c 6b 10 f0 	movl   $0xf0106b9c,(%esp)
f01007d9:	e8 6c 34 00 00       	call   f0103c4a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007de:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f01007e5:	00 
f01007e6:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f01007ed:	f0 
f01007ee:	c7 04 24 c4 6b 10 f0 	movl   $0xf0106bc4,(%esp)
f01007f5:	e8 50 34 00 00       	call   f0103c4a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01007fa:	c7 44 24 08 ea 67 10 	movl   $0x1067ea,0x8(%esp)
f0100801:	00 
f0100802:	c7 44 24 04 ea 67 10 	movl   $0xf01067ea,0x4(%esp)
f0100809:	f0 
f010080a:	c7 04 24 e8 6b 10 f0 	movl   $0xf0106be8,(%esp)
f0100811:	e8 34 34 00 00       	call   f0103c4a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100816:	c7 44 24 08 00 20 22 	movl   $0x222000,0x8(%esp)
f010081d:	00 
f010081e:	c7 44 24 04 00 20 22 	movl   $0xf0222000,0x4(%esp)
f0100825:	f0 
f0100826:	c7 04 24 0c 6c 10 f0 	movl   $0xf0106c0c,(%esp)
f010082d:	e8 18 34 00 00       	call   f0103c4a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100832:	c7 44 24 08 08 40 26 	movl   $0x264008,0x8(%esp)
f0100839:	00 
f010083a:	c7 44 24 04 08 40 26 	movl   $0xf0264008,0x4(%esp)
f0100841:	f0 
f0100842:	c7 04 24 30 6c 10 f0 	movl   $0xf0106c30,(%esp)
f0100849:	e8 fc 33 00 00       	call   f0103c4a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010084e:	b8 07 44 26 f0       	mov    $0xf0264407,%eax
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
f0100870:	c7 04 24 54 6c 10 f0 	movl   $0xf0106c54,(%esp)
f0100877:	e8 ce 33 00 00       	call   f0103c4a <cprintf>
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
f0100889:	c7 44 24 08 29 6b 10 	movl   $0xf0106b29,0x8(%esp)
f0100890:	f0 
f0100891:	c7 44 24 04 47 6b 10 	movl   $0xf0106b47,0x4(%esp)
f0100898:	f0 
f0100899:	c7 04 24 4c 6b 10 f0 	movl   $0xf0106b4c,(%esp)
f01008a0:	e8 a5 33 00 00       	call   f0103c4a <cprintf>
f01008a5:	c7 44 24 08 80 6c 10 	movl   $0xf0106c80,0x8(%esp)
f01008ac:	f0 
f01008ad:	c7 44 24 04 55 6b 10 	movl   $0xf0106b55,0x4(%esp)
f01008b4:	f0 
f01008b5:	c7 04 24 4c 6b 10 f0 	movl   $0xf0106b4c,(%esp)
f01008bc:	e8 89 33 00 00       	call   f0103c4a <cprintf>
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
f01008de:	c7 04 24 a8 6c 10 f0 	movl   $0xf0106ca8,(%esp)
f01008e5:	e8 60 33 00 00       	call   f0103c4a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008ea:	c7 04 24 cc 6c 10 f0 	movl   $0xf0106ccc,(%esp)
f01008f1:	e8 54 33 00 00       	call   f0103c4a <cprintf>

	if (tf != NULL)
f01008f6:	85 ff                	test   %edi,%edi
f01008f8:	74 08                	je     f0100902 <monitor+0x30>
		print_trapframe(tf);
f01008fa:	89 3c 24             	mov    %edi,(%esp)
f01008fd:	e8 20 39 00 00       	call   f0104222 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100902:	c7 04 24 5e 6b 10 f0 	movl   $0xf0106b5e,(%esp)
f0100909:	e8 b6 4f 00 00       	call   f01058c4 <readline>
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
f0100933:	c7 04 24 62 6b 10 f0 	movl   $0xf0106b62,(%esp)
f010093a:	e8 8a 51 00 00       	call   f0105ac9 <strchr>
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
f0100955:	c7 04 24 67 6b 10 f0 	movl   $0xf0106b67,(%esp)
f010095c:	e8 e9 32 00 00       	call   f0103c4a <cprintf>
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
f0100978:	c7 04 24 62 6b 10 f0 	movl   $0xf0106b62,(%esp)
f010097f:	e8 45 51 00 00       	call   f0105ac9 <strchr>
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
f010099a:	c7 44 24 04 47 6b 10 	movl   $0xf0106b47,0x4(%esp)
f01009a1:	f0 
f01009a2:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009a5:	89 04 24             	mov    %eax,(%esp)
f01009a8:	e8 c9 50 00 00       	call   f0105a76 <strcmp>
f01009ad:	85 c0                	test   %eax,%eax
f01009af:	74 1b                	je     f01009cc <monitor+0xfa>
f01009b1:	c7 44 24 04 55 6b 10 	movl   $0xf0106b55,0x4(%esp)
f01009b8:	f0 
f01009b9:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01009bc:	89 04 24             	mov    %eax,(%esp)
f01009bf:	e8 b2 50 00 00       	call   f0105a76 <strcmp>
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
f01009e4:	ff 14 85 fc 6c 10 f0 	call   *-0xfef9304(,%eax,4)
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
f01009fb:	c7 04 24 84 6b 10 f0 	movl   $0xf0106b84,(%esp)
f0100a02:	e8 43 32 00 00       	call   f0103c4a <cprintf>
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
f0100a30:	3b 0d 88 2e 22 f0    	cmp    0xf0222e88,%ecx
f0100a36:	72 20                	jb     f0100a58 <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a38:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100a3c:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0100a43:	f0 
f0100a44:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0100a4b:	00 
f0100a4c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0100a8e:	e8 71 30 00 00       	call   f0103b04 <mc146818_read>
f0100a93:	89 c6                	mov    %eax,%esi
f0100a95:	43                   	inc    %ebx
f0100a96:	89 1c 24             	mov    %ebx,(%esp)
f0100a99:	e8 66 30 00 00       	call   f0103b04 <mc146818_read>
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
f0100ab3:	83 3d 3c 22 22 f0 00 	cmpl   $0x0,0xf022223c
f0100aba:	75 11                	jne    f0100acd <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100abc:	ba 07 50 26 f0       	mov    $0xf0265007,%edx
f0100ac1:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100ac7:	89 15 3c 22 22 f0    	mov    %edx,0xf022223c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	assert(n >= 0);
	// Convert to physical address
	result = (char *)PADDR(nextfree);
f0100acd:	8b 15 3c 22 22 f0    	mov    0xf022223c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ad3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0100ad9:	77 20                	ja     f0100afb <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100adb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100adf:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0100ae6:	f0 
f0100ae7:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
f0100aee:	00 
f0100aef:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100af6:	e8 45 f5 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100afb:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	// Determine whether it is out of bound
	if ((physaddr_t)result + n > PGSIZE * npages) {
f0100b01:	8b 1d 88 2e 22 f0    	mov    0xf0222e88,%ebx
f0100b07:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
f0100b0a:	89 de                	mov    %ebx,%esi
f0100b0c:	c1 e6 0c             	shl    $0xc,%esi
f0100b0f:	39 f7                	cmp    %esi,%edi
f0100b11:	76 1c                	jbe    f0100b2f <boot_alloc+0x85>
		panic("boot_alloc: out of memory!");
f0100b13:	c7 44 24 08 9d 76 10 	movl   $0xf010769d,0x8(%esp)
f0100b1a:	f0 
f0100b1b:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100b22:	00 
f0100b23:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100b2a:	e8 11 f5 ff ff       	call   f0100040 <_panic>
	}
	// Otherwise, update value of nextfree, no update when n == 0
	nextfree += ROUNDUP(n, PGSIZE);
f0100b2f:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100b34:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b39:	01 d0                	add    %edx,%eax
f0100b3b:	a3 3c 22 22 f0       	mov    %eax,0xf022223c
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
f0100b4d:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0100b54:	f0 
f0100b55:	c7 44 24 04 78 00 00 	movl   $0x78,0x4(%esp)
f0100b5c:	00 
f0100b5d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0100b87:	8b 15 40 22 22 f0    	mov    0xf0222240,%edx
f0100b8d:	85 d2                	test   %edx,%edx
f0100b8f:	75 1c                	jne    f0100bad <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100b91:	c7 44 24 08 0c 6d 10 	movl   $0xf0106d0c,0x8(%esp)
f0100b98:	f0 
f0100b99:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0100ba0:	00 
f0100ba1:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0100bbf:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
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
f0100bf7:	a3 40 22 22 f0       	mov    %eax,0xf0222240
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bfc:	8b 1d 40 22 22 f0    	mov    0xf0222240,%ebx
f0100c02:	eb 63                	jmp    f0100c67 <check_page_free_list+0xf4>
f0100c04:	89 d8                	mov    %ebx,%eax
f0100c06:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
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
f0100c20:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f0100c26:	72 20                	jb     f0100c48 <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c28:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100c2c:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0100c33:	f0 
f0100c34:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100c3b:	00 
f0100c3c:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f0100c43:	e8 f8 f3 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100c48:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100c4f:	00 
f0100c50:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100c57:	00 
	return (void *)(pa + KERNBASE);
f0100c58:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c5d:	89 04 24             	mov    %eax,(%esp)
f0100c60:	e8 99 4e 00 00       	call   f0105afe <memset>
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
f0100c78:	8b 15 40 22 22 f0    	mov    0xf0222240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c7e:	8b 0d 90 2e 22 f0    	mov    0xf0222e90,%ecx
		assert(pp < pages + npages);
f0100c84:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
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
f0100ca7:	c7 44 24 0c c6 76 10 	movl   $0xf01076c6,0xc(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100cb6:	f0 
f0100cb7:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f0100cbe:	00 
f0100cbf:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100ccb:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100cce:	72 24                	jb     f0100cf4 <check_page_free_list+0x181>
f0100cd0:	c7 44 24 0c e7 76 10 	movl   $0xf01076e7,0xc(%esp)
f0100cd7:	f0 
f0100cd8:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100cdf:	f0 
f0100ce0:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f0100ce7:	00 
f0100ce8:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100cef:	e8 4c f3 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100cf4:	89 d0                	mov    %edx,%eax
f0100cf6:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100cf9:	a8 07                	test   $0x7,%al
f0100cfb:	74 24                	je     f0100d21 <check_page_free_list+0x1ae>
f0100cfd:	c7 44 24 0c 30 6d 10 	movl   $0xf0106d30,0xc(%esp)
f0100d04:	f0 
f0100d05:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100d0c:	f0 
f0100d0d:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100d14:	00 
f0100d15:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0100d29:	c7 44 24 0c fb 76 10 	movl   $0xf01076fb,0xc(%esp)
f0100d30:	f0 
f0100d31:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100d38:	f0 
f0100d39:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f0100d40:	00 
f0100d41:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100d48:	e8 f3 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d4d:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d52:	75 24                	jne    f0100d78 <check_page_free_list+0x205>
f0100d54:	c7 44 24 0c 0c 77 10 	movl   $0xf010770c,0xc(%esp)
f0100d5b:	f0 
f0100d5c:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100d63:	f0 
f0100d64:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0100d6b:	00 
f0100d6c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100d73:	e8 c8 f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d78:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d7d:	75 24                	jne    f0100da3 <check_page_free_list+0x230>
f0100d7f:	c7 44 24 0c 64 6d 10 	movl   $0xf0106d64,0xc(%esp)
f0100d86:	f0 
f0100d87:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100d8e:	f0 
f0100d8f:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f0100d96:	00 
f0100d97:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100d9e:	e8 9d f2 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100da3:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100da8:	75 24                	jne    f0100dce <check_page_free_list+0x25b>
f0100daa:	c7 44 24 0c 25 77 10 	movl   $0xf0107725,0xc(%esp)
f0100db1:	f0 
f0100db2:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100db9:	f0 
f0100dba:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0100dc1:	00 
f0100dc2:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0100de3:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0100dea:	f0 
f0100deb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100df2:	00 
f0100df3:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f0100dfa:	e8 41 f2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0100dff:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100e05:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
f0100e08:	76 24                	jbe    f0100e2e <check_page_free_list+0x2bb>
f0100e0a:	c7 44 24 0c 88 6d 10 	movl   $0xf0106d88,0xc(%esp)
f0100e11:	f0 
f0100e12:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100e19:	f0 
f0100e1a:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0100e21:	00 
f0100e22:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100e29:	e8 12 f2 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100e2e:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100e33:	75 24                	jne    f0100e59 <check_page_free_list+0x2e6>
f0100e35:	c7 44 24 0c 3f 77 10 	movl   $0xf010773f,0xc(%esp)
f0100e3c:	f0 
f0100e3d:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100e44:	f0 
f0100e45:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0100e4c:	00 
f0100e4d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0100e72:	c7 44 24 0c 5c 77 10 	movl   $0xf010775c,0xc(%esp)
f0100e79:	f0 
f0100e7a:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100e81:	f0 
f0100e82:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0100e89:	00 
f0100e8a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100e91:	e8 aa f1 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100e96:	85 db                	test   %ebx,%ebx
f0100e98:	7f 24                	jg     f0100ebe <check_page_free_list+0x34b>
f0100e9a:	c7 44 24 0c 6e 77 10 	movl   $0xf010776e,0xc(%esp)
f0100ea1:	f0 
f0100ea2:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0100ea9:	f0 
f0100eaa:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f0100eb1:	00 
f0100eb2:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100eb9:	e8 82 f1 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100ebe:	c7 04 24 d0 6d 10 f0 	movl   $0xf0106dd0,(%esp)
f0100ec5:	e8 80 2d 00 00       	call   f0103c4a <cprintf>
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
f0100ef0:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0100ef7:	f0 
f0100ef8:	c7 44 24 04 42 01 00 	movl   $0x142,0x4(%esp)
f0100eff:	00 
f0100f00:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0100f07:	e8 34 f1 ff ff       	call   f0100040 <_panic>
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE) || (i == MPENTRY_PADDR / PGSIZE)) {
f0100f0c:	8b 35 38 22 22 f0    	mov    0xf0222238,%esi
	return (physaddr_t)kva - KERNBASE;
f0100f12:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0100f18:	c1 ef 0c             	shr    $0xc,%edi
f0100f1b:	8b 1d 40 22 22 f0    	mov    0xf0222240,%ebx
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
f0100f3e:	a1 90 2e 22 f0       	mov    0xf0222e90,%eax
f0100f43:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
f0100f4a:	eb 18                	jmp    f0100f64 <page_init+0x92>
		}
		// Rest of memory are free
		else {
			pages[i].pp_ref = 0;
f0100f4c:	89 c8                	mov    %ecx,%eax
f0100f4e:	03 05 90 2e 22 f0    	add    0xf0222e90,%eax
f0100f54:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100f5a:	89 18                	mov    %ebx,(%eax)
			page_free_list = &pages[i];
f0100f5c:	89 cb                	mov    %ecx,%ebx
f0100f5e:	03 1d 90 2e 22 f0    	add    0xf0222e90,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100f64:	42                   	inc    %edx
f0100f65:	83 c1 08             	add    $0x8,%ecx
f0100f68:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f0100f6e:	72 bd                	jb     f0100f2d <page_init+0x5b>
f0100f70:	89 1d 40 22 22 f0    	mov    %ebx,0xf0222240
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
f0100f85:	8b 1d 40 22 22 f0    	mov    0xf0222240,%ebx
	// Check whether out of free memory
	if (!page_free_list) {
f0100f8b:	85 db                	test   %ebx,%ebx
f0100f8d:	74 6b                	je     f0100ffa <page_alloc+0x7c>
		return NULL;
	}
	// Set the page without change the reference bit.
	page_free_list = currPage->pp_link;
f0100f8f:	8b 03                	mov    (%ebx),%eax
f0100f91:	a3 40 22 22 f0       	mov    %eax,0xf0222240
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
f0100fa4:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0100faa:	c1 f8 03             	sar    $0x3,%eax
f0100fad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fb0:	89 c2                	mov    %eax,%edx
f0100fb2:	c1 ea 0c             	shr    $0xc,%edx
f0100fb5:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f0100fbb:	72 20                	jb     f0100fdd <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fbd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fc1:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0100fc8:	f0 
f0100fc9:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100fd0:	00 
f0100fd1:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
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
f0100ff5:	e8 04 4b 00 00       	call   f0105afe <memset>
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
f0101017:	c7 44 24 08 f4 6d 10 	movl   $0xf0106df4,0x8(%esp)
f010101e:	f0 
f010101f:	c7 44 24 04 7d 01 00 	movl   $0x17d,0x4(%esp)
f0101026:	00 
f0101027:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010102e:	e8 0d f0 ff ff       	call   f0100040 <_panic>
	}
	// Update the free list
	pp->pp_link = page_free_list;
f0101033:	8b 15 40 22 22 f0    	mov    0xf0222240,%edx
f0101039:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f010103b:	a3 40 22 22 f0       	mov    %eax,0xf0222240
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
f0101097:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
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
f01010b4:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f01010ba:	72 20                	jb     f01010dc <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01010bc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01010c0:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f01010c7:	f0 
f01010c8:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
f01010cf:	00 
f01010d0:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f010119c:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f01011a2:	72 1c                	jb     f01011c0 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f01011a4:	c7 44 24 08 30 6e 10 	movl   $0xf0106e30,0x8(%esp)
f01011ab:	f0 
f01011ac:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01011b3:	00 
f01011b4:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f01011bb:	e8 80 ee ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01011c0:	c1 e0 03             	shl    $0x3,%eax
f01011c3:	03 05 90 2e 22 f0    	add    0xf0222e90,%eax
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
f01011e3:	e8 44 4f 00 00       	call   f010612c <cpunum>
f01011e8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01011ef:	29 c2                	sub    %eax,%edx
f01011f1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01011f4:	83 3c 85 28 30 22 f0 	cmpl   $0x0,-0xfddcfd8(,%eax,4)
f01011fb:	00 
f01011fc:	74 20                	je     f010121e <tlb_invalidate+0x41>
f01011fe:	e8 29 4f 00 00       	call   f010612c <cpunum>
f0101203:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010120a:	29 c2                	sub    %eax,%edx
f010120c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010120f:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
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
f01012b9:	2b 1d 90 2e 22 f0    	sub    0xf0222e90,%ebx
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
	if (base + size >  MMIOLIM) {
f01012ff:	8b 15 00 83 12 f0    	mov    0xf0128300,%edx
f0101305:	8d 04 13             	lea    (%ebx,%edx,1),%eax
f0101308:	3d 00 00 c0 ef       	cmp    $0xefc00000,%eax
f010130d:	76 1c                	jbe    f010132b <mmio_map_region+0x42>
		panic("mmio_map_region: unable to map region");
f010130f:	c7 44 24 08 50 6e 10 	movl   $0xf0106e50,0x8(%esp)
f0101316:	f0 
f0101317:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f010131e:	00 
f010131f:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101326:	e8 15 ed ff ff       	call   f0100040 <_panic>
	}
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD|PTE_PWT|PTE_W);
f010132b:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
f0101332:	00 
f0101333:	8b 45 08             	mov    0x8(%ebp),%eax
f0101336:	89 04 24             	mov    %eax,(%esp)
f0101339:	89 d9                	mov    %ebx,%ecx
f010133b:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101340:	e8 bc fd ff ff       	call   f0101101 <boot_map_region>
	newBase = base;
f0101345:	a1 00 83 12 f0       	mov    0xf0128300,%eax
	base += size;
f010134a:	01 c3                	add    %eax,%ebx
f010134c:	89 1d 00 83 12 f0    	mov    %ebx,0xf0128300
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
f01013a3:	a3 88 2e 22 f0       	mov    %eax,0xf0222e88
	npages_basemem = basemem / (PGSIZE / 1024);
f01013a8:	89 d8                	mov    %ebx,%eax
f01013aa:	c1 e8 02             	shr    $0x2,%eax
f01013ad:	a3 38 22 22 f0       	mov    %eax,0xf0222238

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01013b2:	89 f0                	mov    %esi,%eax
f01013b4:	29 d8                	sub    %ebx,%eax
f01013b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013ba:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01013be:	89 74 24 04          	mov    %esi,0x4(%esp)
f01013c2:	c7 04 24 78 6e 10 f0 	movl   $0xf0106e78,(%esp)
f01013c9:	e8 7c 28 00 00       	call   f0103c4a <cprintf>
	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01013ce:	b8 00 10 00 00       	mov    $0x1000,%eax
f01013d3:	e8 d2 f6 ff ff       	call   f0100aaa <boot_alloc>
f01013d8:	a3 8c 2e 22 f0       	mov    %eax,0xf0222e8c
	memset(kern_pgdir, 0, PGSIZE);
f01013dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013e4:	00 
f01013e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01013ec:	00 
f01013ed:	89 04 24             	mov    %eax,(%esp)
f01013f0:	e8 09 47 00 00       	call   f0105afe <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01013f5:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01013fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01013ff:	77 20                	ja     f0101421 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101401:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101405:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f010140c:	f0 
f010140d:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
f0101414:	00 
f0101415:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0101430:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f0101435:	c1 e0 03             	shl    $0x3,%eax
f0101438:	e8 6d f6 ff ff       	call   f0100aaa <boot_alloc>
f010143d:	a3 90 2e 22 f0       	mov    %eax,0xf0222e90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101442:	8b 15 88 2e 22 f0    	mov    0xf0222e88,%edx
f0101448:	c1 e2 03             	shl    $0x3,%edx
f010144b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010144f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101456:	00 
f0101457:	89 04 24             	mov    %eax,(%esp)
f010145a:	e8 9f 46 00 00       	call   f0105afe <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f010145f:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101464:	e8 41 f6 ff ff       	call   f0100aaa <boot_alloc>
f0101469:	a3 48 22 22 f0       	mov    %eax,0xf0222248
	memset(envs, 0, sizeof(struct Env) * NENV);
f010146e:	c7 44 24 08 00 f0 01 	movl   $0x1f000,0x8(%esp)
f0101475:	00 
f0101476:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010147d:	00 
f010147e:	89 04 24             	mov    %eax,(%esp)
f0101481:	e8 78 46 00 00       	call   f0105afe <memset>
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
f0101495:	83 3d 90 2e 22 f0 00 	cmpl   $0x0,0xf0222e90
f010149c:	75 1c                	jne    f01014ba <mem_init+0x162>
		panic("'pages' is a null pointer!");
f010149e:	c7 44 24 08 7f 77 10 	movl   $0xf010777f,0x8(%esp)
f01014a5:	f0 
f01014a6:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01014ad:	00 
f01014ae:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01014b5:	e8 86 eb ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01014ba:	a1 40 22 22 f0       	mov    0xf0222240,%eax
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
f01014df:	c7 44 24 0c 9a 77 10 	movl   $0xf010779a,0xc(%esp)
f01014e6:	f0 
f01014e7:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01014ee:	f0 
f01014ef:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f01014f6:	00 
f01014f7:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01014fe:	e8 3d eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101503:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010150a:	e8 6f fa ff ff       	call   f0100f7e <page_alloc>
f010150f:	89 c7                	mov    %eax,%edi
f0101511:	85 c0                	test   %eax,%eax
f0101513:	75 24                	jne    f0101539 <mem_init+0x1e1>
f0101515:	c7 44 24 0c b0 77 10 	movl   $0xf01077b0,0xc(%esp)
f010151c:	f0 
f010151d:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101524:	f0 
f0101525:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f010152c:	00 
f010152d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101534:	e8 07 eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101540:	e8 39 fa ff ff       	call   f0100f7e <page_alloc>
f0101545:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101548:	85 c0                	test   %eax,%eax
f010154a:	75 24                	jne    f0101570 <mem_init+0x218>
f010154c:	c7 44 24 0c c6 77 10 	movl   $0xf01077c6,0xc(%esp)
f0101553:	f0 
f0101554:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010155b:	f0 
f010155c:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101563:	00 
f0101564:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010156b:	e8 d0 ea ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101570:	39 fe                	cmp    %edi,%esi
f0101572:	75 24                	jne    f0101598 <mem_init+0x240>
f0101574:	c7 44 24 0c dc 77 10 	movl   $0xf01077dc,0xc(%esp)
f010157b:	f0 
f010157c:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101583:	f0 
f0101584:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f010158b:	00 
f010158c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101593:	e8 a8 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101598:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010159b:	74 05                	je     f01015a2 <mem_init+0x24a>
f010159d:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015a0:	75 24                	jne    f01015c6 <mem_init+0x26e>
f01015a2:	c7 44 24 0c b4 6e 10 	movl   $0xf0106eb4,0xc(%esp)
f01015a9:	f0 
f01015aa:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01015b1:	f0 
f01015b2:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01015b9:	00 
f01015ba:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01015c1:	e8 7a ea ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01015c6:	8b 15 90 2e 22 f0    	mov    0xf0222e90,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01015cc:	a1 88 2e 22 f0       	mov    0xf0222e88,%eax
f01015d1:	c1 e0 0c             	shl    $0xc,%eax
f01015d4:	89 f1                	mov    %esi,%ecx
f01015d6:	29 d1                	sub    %edx,%ecx
f01015d8:	c1 f9 03             	sar    $0x3,%ecx
f01015db:	c1 e1 0c             	shl    $0xc,%ecx
f01015de:	39 c1                	cmp    %eax,%ecx
f01015e0:	72 24                	jb     f0101606 <mem_init+0x2ae>
f01015e2:	c7 44 24 0c ee 77 10 	movl   $0xf01077ee,0xc(%esp)
f01015e9:	f0 
f01015ea:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01015f1:	f0 
f01015f2:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f01015f9:	00 
f01015fa:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101601:	e8 3a ea ff ff       	call   f0100040 <_panic>
f0101606:	89 f9                	mov    %edi,%ecx
f0101608:	29 d1                	sub    %edx,%ecx
f010160a:	c1 f9 03             	sar    $0x3,%ecx
f010160d:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101610:	39 c8                	cmp    %ecx,%eax
f0101612:	77 24                	ja     f0101638 <mem_init+0x2e0>
f0101614:	c7 44 24 0c 0b 78 10 	movl   $0xf010780b,0xc(%esp)
f010161b:	f0 
f010161c:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101623:	f0 
f0101624:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f010162b:	00 
f010162c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101633:	e8 08 ea ff ff       	call   f0100040 <_panic>
f0101638:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010163b:	29 d1                	sub    %edx,%ecx
f010163d:	89 ca                	mov    %ecx,%edx
f010163f:	c1 fa 03             	sar    $0x3,%edx
f0101642:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101645:	39 d0                	cmp    %edx,%eax
f0101647:	77 24                	ja     f010166d <mem_init+0x315>
f0101649:	c7 44 24 0c 28 78 10 	movl   $0xf0107828,0xc(%esp)
f0101650:	f0 
f0101651:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101658:	f0 
f0101659:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101660:	00 
f0101661:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101668:	e8 d3 e9 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010166d:	a1 40 22 22 f0       	mov    0xf0222240,%eax
f0101672:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101675:	c7 05 40 22 22 f0 00 	movl   $0x0,0xf0222240
f010167c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010167f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101686:	e8 f3 f8 ff ff       	call   f0100f7e <page_alloc>
f010168b:	85 c0                	test   %eax,%eax
f010168d:	74 24                	je     f01016b3 <mem_init+0x35b>
f010168f:	c7 44 24 0c 45 78 10 	movl   $0xf0107845,0xc(%esp)
f0101696:	f0 
f0101697:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010169e:	f0 
f010169f:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f01016a6:	00 
f01016a7:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f01016e0:	c7 44 24 0c 9a 77 10 	movl   $0xf010779a,0xc(%esp)
f01016e7:	f0 
f01016e8:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01016ef:	f0 
f01016f0:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f01016f7:	00 
f01016f8:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01016ff:	e8 3c e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101704:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010170b:	e8 6e f8 ff ff       	call   f0100f7e <page_alloc>
f0101710:	89 c7                	mov    %eax,%edi
f0101712:	85 c0                	test   %eax,%eax
f0101714:	75 24                	jne    f010173a <mem_init+0x3e2>
f0101716:	c7 44 24 0c b0 77 10 	movl   $0xf01077b0,0xc(%esp)
f010171d:	f0 
f010171e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101725:	f0 
f0101726:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f010172d:	00 
f010172e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101735:	e8 06 e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010173a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101741:	e8 38 f8 ff ff       	call   f0100f7e <page_alloc>
f0101746:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101749:	85 c0                	test   %eax,%eax
f010174b:	75 24                	jne    f0101771 <mem_init+0x419>
f010174d:	c7 44 24 0c c6 77 10 	movl   $0xf01077c6,0xc(%esp)
f0101754:	f0 
f0101755:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010175c:	f0 
f010175d:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101764:	00 
f0101765:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010176c:	e8 cf e8 ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101771:	39 fe                	cmp    %edi,%esi
f0101773:	75 24                	jne    f0101799 <mem_init+0x441>
f0101775:	c7 44 24 0c dc 77 10 	movl   $0xf01077dc,0xc(%esp)
f010177c:	f0 
f010177d:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101784:	f0 
f0101785:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f010178c:	00 
f010178d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101794:	e8 a7 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101799:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f010179c:	74 05                	je     f01017a3 <mem_init+0x44b>
f010179e:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01017a1:	75 24                	jne    f01017c7 <mem_init+0x46f>
f01017a3:	c7 44 24 0c b4 6e 10 	movl   $0xf0106eb4,0xc(%esp)
f01017aa:	f0 
f01017ab:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01017b2:	f0 
f01017b3:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f01017ba:	00 
f01017bb:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01017c2:	e8 79 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017c7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ce:	e8 ab f7 ff ff       	call   f0100f7e <page_alloc>
f01017d3:	85 c0                	test   %eax,%eax
f01017d5:	74 24                	je     f01017fb <mem_init+0x4a3>
f01017d7:	c7 44 24 0c 45 78 10 	movl   $0xf0107845,0xc(%esp)
f01017de:	f0 
f01017df:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01017e6:	f0 
f01017e7:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f01017ee:	00 
f01017ef:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01017f6:	e8 45 e8 ff ff       	call   f0100040 <_panic>
f01017fb:	89 f0                	mov    %esi,%eax
f01017fd:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0101803:	c1 f8 03             	sar    $0x3,%eax
f0101806:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101809:	89 c2                	mov    %eax,%edx
f010180b:	c1 ea 0c             	shr    $0xc,%edx
f010180e:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f0101814:	72 20                	jb     f0101836 <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101816:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010181a:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0101821:	f0 
f0101822:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101829:	00 
f010182a:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
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
f010184e:	e8 ab 42 00 00       	call   f0105afe <memset>
	page_free(pp0);
f0101853:	89 34 24             	mov    %esi,(%esp)
f0101856:	e8 a7 f7 ff ff       	call   f0101002 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010185b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101862:	e8 17 f7 ff ff       	call   f0100f7e <page_alloc>
f0101867:	85 c0                	test   %eax,%eax
f0101869:	75 24                	jne    f010188f <mem_init+0x537>
f010186b:	c7 44 24 0c 54 78 10 	movl   $0xf0107854,0xc(%esp)
f0101872:	f0 
f0101873:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010187a:	f0 
f010187b:	c7 44 24 04 3f 03 00 	movl   $0x33f,0x4(%esp)
f0101882:	00 
f0101883:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010188a:	e8 b1 e7 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010188f:	39 c6                	cmp    %eax,%esi
f0101891:	74 24                	je     f01018b7 <mem_init+0x55f>
f0101893:	c7 44 24 0c 72 78 10 	movl   $0xf0107872,0xc(%esp)
f010189a:	f0 
f010189b:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01018a2:	f0 
f01018a3:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f01018aa:	00 
f01018ab:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01018b2:	e8 89 e7 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b7:	89 f2                	mov    %esi,%edx
f01018b9:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f01018bf:	c1 fa 03             	sar    $0x3,%edx
f01018c2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018c5:	89 d0                	mov    %edx,%eax
f01018c7:	c1 e8 0c             	shr    $0xc,%eax
f01018ca:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f01018d0:	72 20                	jb     f01018f2 <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01018d6:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f01018dd:	f0 
f01018de:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018e5:	00 
f01018e6:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
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
f0101903:	c7 44 24 0c 82 78 10 	movl   $0xf0107882,0xc(%esp)
f010190a:	f0 
f010190b:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101912:	f0 
f0101913:	c7 44 24 04 43 03 00 	movl   $0x343,0x4(%esp)
f010191a:	00 
f010191b:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f010192f:	89 15 40 22 22 f0    	mov    %edx,0xf0222240

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
f0101950:	a1 40 22 22 f0       	mov    0xf0222240,%eax
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
f0101962:	c7 44 24 0c 8c 78 10 	movl   $0xf010788c,0xc(%esp)
f0101969:	f0 
f010196a:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101971:	f0 
f0101972:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0101979:	00 
f010197a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101981:	e8 ba e6 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101986:	c7 04 24 d4 6e 10 f0 	movl   $0xf0106ed4,(%esp)
f010198d:	e8 b8 22 00 00       	call   f0103c4a <cprintf>
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
f01019a4:	c7 44 24 0c 9a 77 10 	movl   $0xf010779a,0xc(%esp)
f01019ab:	f0 
f01019ac:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01019b3:	f0 
f01019b4:	c7 44 24 04 b6 03 00 	movl   $0x3b6,0x4(%esp)
f01019bb:	00 
f01019bc:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01019c3:	e8 78 e6 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01019c8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019cf:	e8 aa f5 ff ff       	call   f0100f7e <page_alloc>
f01019d4:	89 c6                	mov    %eax,%esi
f01019d6:	85 c0                	test   %eax,%eax
f01019d8:	75 24                	jne    f01019fe <mem_init+0x6a6>
f01019da:	c7 44 24 0c b0 77 10 	movl   $0xf01077b0,0xc(%esp)
f01019e1:	f0 
f01019e2:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01019e9:	f0 
f01019ea:	c7 44 24 04 b7 03 00 	movl   $0x3b7,0x4(%esp)
f01019f1:	00 
f01019f2:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01019f9:	e8 42 e6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01019fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101a05:	e8 74 f5 ff ff       	call   f0100f7e <page_alloc>
f0101a0a:	89 c3                	mov    %eax,%ebx
f0101a0c:	85 c0                	test   %eax,%eax
f0101a0e:	75 24                	jne    f0101a34 <mem_init+0x6dc>
f0101a10:	c7 44 24 0c c6 77 10 	movl   $0xf01077c6,0xc(%esp)
f0101a17:	f0 
f0101a18:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101a1f:	f0 
f0101a20:	c7 44 24 04 b8 03 00 	movl   $0x3b8,0x4(%esp)
f0101a27:	00 
f0101a28:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101a2f:	e8 0c e6 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101a34:	39 f7                	cmp    %esi,%edi
f0101a36:	75 24                	jne    f0101a5c <mem_init+0x704>
f0101a38:	c7 44 24 0c dc 77 10 	movl   $0xf01077dc,0xc(%esp)
f0101a3f:	f0 
f0101a40:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101a47:	f0 
f0101a48:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0101a4f:	00 
f0101a50:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101a57:	e8 e4 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101a5c:	39 c6                	cmp    %eax,%esi
f0101a5e:	74 04                	je     f0101a64 <mem_init+0x70c>
f0101a60:	39 c7                	cmp    %eax,%edi
f0101a62:	75 24                	jne    f0101a88 <mem_init+0x730>
f0101a64:	c7 44 24 0c b4 6e 10 	movl   $0xf0106eb4,0xc(%esp)
f0101a6b:	f0 
f0101a6c:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101a73:	f0 
f0101a74:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0101a7b:	00 
f0101a7c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101a83:	e8 b8 e5 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101a88:	8b 15 40 22 22 f0    	mov    0xf0222240,%edx
f0101a8e:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101a91:	c7 05 40 22 22 f0 00 	movl   $0x0,0xf0222240
f0101a98:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101a9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aa2:	e8 d7 f4 ff ff       	call   f0100f7e <page_alloc>
f0101aa7:	85 c0                	test   %eax,%eax
f0101aa9:	74 24                	je     f0101acf <mem_init+0x777>
f0101aab:	c7 44 24 0c 45 78 10 	movl   $0xf0107845,0xc(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101aba:	f0 
f0101abb:	c7 44 24 04 c3 03 00 	movl   $0x3c3,0x4(%esp)
f0101ac2:	00 
f0101ac3:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101aca:	e8 71 e5 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101acf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101ad2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ad6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101add:	00 
f0101ade:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101ae3:	89 04 24             	mov    %eax,(%esp)
f0101ae6:	e8 79 f6 ff ff       	call   f0101164 <page_lookup>
f0101aeb:	85 c0                	test   %eax,%eax
f0101aed:	74 24                	je     f0101b13 <mem_init+0x7bb>
f0101aef:	c7 44 24 0c f4 6e 10 	movl   $0xf0106ef4,0xc(%esp)
f0101af6:	f0 
f0101af7:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101afe:	f0 
f0101aff:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f0101b06:	00 
f0101b07:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101b0e:	e8 2d e5 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101b13:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b1a:	00 
f0101b1b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101b22:	00 
f0101b23:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101b27:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101b2c:	89 04 24             	mov    %eax,(%esp)
f0101b2f:	e8 3b f7 ff ff       	call   f010126f <page_insert>
f0101b34:	85 c0                	test   %eax,%eax
f0101b36:	78 24                	js     f0101b5c <mem_init+0x804>
f0101b38:	c7 44 24 0c 2c 6f 10 	movl   $0xf0106f2c,0xc(%esp)
f0101b3f:	f0 
f0101b40:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101b47:	f0 
f0101b48:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f0101b4f:	00 
f0101b50:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0101b78:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101b7d:	89 04 24             	mov    %eax,(%esp)
f0101b80:	e8 ea f6 ff ff       	call   f010126f <page_insert>
f0101b85:	85 c0                	test   %eax,%eax
f0101b87:	74 24                	je     f0101bad <mem_init+0x855>
f0101b89:	c7 44 24 0c 5c 6f 10 	movl   $0xf0106f5c,0xc(%esp)
f0101b90:	f0 
f0101b91:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101b98:	f0 
f0101b99:	c7 44 24 04 cd 03 00 	movl   $0x3cd,0x4(%esp)
f0101ba0:	00 
f0101ba1:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101ba8:	e8 93 e4 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101bad:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0101bb3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101bb6:	a1 90 2e 22 f0       	mov    0xf0222e90,%eax
f0101bbb:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bbe:	8b 11                	mov    (%ecx),%edx
f0101bc0:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101bc6:	89 f8                	mov    %edi,%eax
f0101bc8:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101bcb:	c1 f8 03             	sar    $0x3,%eax
f0101bce:	c1 e0 0c             	shl    $0xc,%eax
f0101bd1:	39 c2                	cmp    %eax,%edx
f0101bd3:	74 24                	je     f0101bf9 <mem_init+0x8a1>
f0101bd5:	c7 44 24 0c 8c 6f 10 	movl   $0xf0106f8c,0xc(%esp)
f0101bdc:	f0 
f0101bdd:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101be4:	f0 
f0101be5:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f0101bec:	00 
f0101bed:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0101c15:	c7 44 24 0c b4 6f 10 	movl   $0xf0106fb4,0xc(%esp)
f0101c1c:	f0 
f0101c1d:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101c24:	f0 
f0101c25:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f0101c2c:	00 
f0101c2d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101c34:	e8 07 e4 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101c39:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101c3e:	74 24                	je     f0101c64 <mem_init+0x90c>
f0101c40:	c7 44 24 0c 97 78 10 	movl   $0xf0107897,0xc(%esp)
f0101c47:	f0 
f0101c48:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101c4f:	f0 
f0101c50:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f0101c57:	00 
f0101c58:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101c5f:	e8 dc e3 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101c64:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c69:	74 24                	je     f0101c8f <mem_init+0x937>
f0101c6b:	c7 44 24 0c a8 78 10 	movl   $0xf01078a8,0xc(%esp)
f0101c72:	f0 
f0101c73:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101c7a:	f0 
f0101c7b:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f0101c82:	00 
f0101c83:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0101cb2:	c7 44 24 0c e4 6f 10 	movl   $0xf0106fe4,0xc(%esp)
f0101cb9:	f0 
f0101cba:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101cc1:	f0 
f0101cc2:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f0101cc9:	00 
f0101cca:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101cd1:	e8 6a e3 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cd6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101cdb:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101ce0:	e8 2f ed ff ff       	call   f0100a14 <check_va2pa>
f0101ce5:	89 da                	mov    %ebx,%edx
f0101ce7:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f0101ced:	c1 fa 03             	sar    $0x3,%edx
f0101cf0:	c1 e2 0c             	shl    $0xc,%edx
f0101cf3:	39 d0                	cmp    %edx,%eax
f0101cf5:	74 24                	je     f0101d1b <mem_init+0x9c3>
f0101cf7:	c7 44 24 0c 20 70 10 	movl   $0xf0107020,0xc(%esp)
f0101cfe:	f0 
f0101cff:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101d06:	f0 
f0101d07:	c7 44 24 04 d5 03 00 	movl   $0x3d5,0x4(%esp)
f0101d0e:	00 
f0101d0f:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101d16:	e8 25 e3 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101d1b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d20:	74 24                	je     f0101d46 <mem_init+0x9ee>
f0101d22:	c7 44 24 0c b9 78 10 	movl   $0xf01078b9,0xc(%esp)
f0101d29:	f0 
f0101d2a:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101d31:	f0 
f0101d32:	c7 44 24 04 d6 03 00 	movl   $0x3d6,0x4(%esp)
f0101d39:	00 
f0101d3a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101d41:	e8 fa e2 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101d46:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d4d:	e8 2c f2 ff ff       	call   f0100f7e <page_alloc>
f0101d52:	85 c0                	test   %eax,%eax
f0101d54:	74 24                	je     f0101d7a <mem_init+0xa22>
f0101d56:	c7 44 24 0c 45 78 10 	movl   $0xf0107845,0xc(%esp)
f0101d5d:	f0 
f0101d5e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101d65:	f0 
f0101d66:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0101d6d:	00 
f0101d6e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101d75:	e8 c6 e2 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d7a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d81:	00 
f0101d82:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d89:	00 
f0101d8a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d8e:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101d93:	89 04 24             	mov    %eax,(%esp)
f0101d96:	e8 d4 f4 ff ff       	call   f010126f <page_insert>
f0101d9b:	85 c0                	test   %eax,%eax
f0101d9d:	74 24                	je     f0101dc3 <mem_init+0xa6b>
f0101d9f:	c7 44 24 0c e4 6f 10 	movl   $0xf0106fe4,0xc(%esp)
f0101da6:	f0 
f0101da7:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101dae:	f0 
f0101daf:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f0101db6:	00 
f0101db7:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101dbe:	e8 7d e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101dc3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dc8:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101dcd:	e8 42 ec ff ff       	call   f0100a14 <check_va2pa>
f0101dd2:	89 da                	mov    %ebx,%edx
f0101dd4:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f0101dda:	c1 fa 03             	sar    $0x3,%edx
f0101ddd:	c1 e2 0c             	shl    $0xc,%edx
f0101de0:	39 d0                	cmp    %edx,%eax
f0101de2:	74 24                	je     f0101e08 <mem_init+0xab0>
f0101de4:	c7 44 24 0c 20 70 10 	movl   $0xf0107020,0xc(%esp)
f0101deb:	f0 
f0101dec:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101df3:	f0 
f0101df4:	c7 44 24 04 dd 03 00 	movl   $0x3dd,0x4(%esp)
f0101dfb:	00 
f0101dfc:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101e03:	e8 38 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101e08:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101e0d:	74 24                	je     f0101e33 <mem_init+0xadb>
f0101e0f:	c7 44 24 0c b9 78 10 	movl   $0xf01078b9,0xc(%esp)
f0101e16:	f0 
f0101e17:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101e1e:	f0 
f0101e1f:	c7 44 24 04 de 03 00 	movl   $0x3de,0x4(%esp)
f0101e26:	00 
f0101e27:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101e2e:	e8 0d e2 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101e33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101e3a:	e8 3f f1 ff ff       	call   f0100f7e <page_alloc>
f0101e3f:	85 c0                	test   %eax,%eax
f0101e41:	74 24                	je     f0101e67 <mem_init+0xb0f>
f0101e43:	c7 44 24 0c 45 78 10 	movl   $0xf0107845,0xc(%esp)
f0101e4a:	f0 
f0101e4b:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101e52:	f0 
f0101e53:	c7 44 24 04 e2 03 00 	movl   $0x3e2,0x4(%esp)
f0101e5a:	00 
f0101e5b:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101e62:	e8 d9 e1 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101e67:	8b 15 8c 2e 22 f0    	mov    0xf0222e8c,%edx
f0101e6d:	8b 02                	mov    (%edx),%eax
f0101e6f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101e74:	89 c1                	mov    %eax,%ecx
f0101e76:	c1 e9 0c             	shr    $0xc,%ecx
f0101e79:	3b 0d 88 2e 22 f0    	cmp    0xf0222e88,%ecx
f0101e7f:	72 20                	jb     f0101ea1 <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101e81:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101e85:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0101e8c:	f0 
f0101e8d:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f0101e94:	00 
f0101e95:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0101ecb:	c7 44 24 0c 50 70 10 	movl   $0xf0107050,0xc(%esp)
f0101ed2:	f0 
f0101ed3:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101eda:	f0 
f0101edb:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0101ee2:	00 
f0101ee3:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101eea:	e8 51 e1 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101eef:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101ef6:	00 
f0101ef7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101efe:	00 
f0101eff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101f03:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101f08:	89 04 24             	mov    %eax,(%esp)
f0101f0b:	e8 5f f3 ff ff       	call   f010126f <page_insert>
f0101f10:	85 c0                	test   %eax,%eax
f0101f12:	74 24                	je     f0101f38 <mem_init+0xbe0>
f0101f14:	c7 44 24 0c 90 70 10 	movl   $0xf0107090,0xc(%esp)
f0101f1b:	f0 
f0101f1c:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101f23:	f0 
f0101f24:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0101f2b:	00 
f0101f2c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101f33:	e8 08 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101f38:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
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
f0101f4f:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f0101f55:	c1 fa 03             	sar    $0x3,%edx
f0101f58:	c1 e2 0c             	shl    $0xc,%edx
f0101f5b:	39 d0                	cmp    %edx,%eax
f0101f5d:	74 24                	je     f0101f83 <mem_init+0xc2b>
f0101f5f:	c7 44 24 0c 20 70 10 	movl   $0xf0107020,0xc(%esp)
f0101f66:	f0 
f0101f67:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101f6e:	f0 
f0101f6f:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0101f76:	00 
f0101f77:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101f83:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101f88:	74 24                	je     f0101fae <mem_init+0xc56>
f0101f8a:	c7 44 24 0c b9 78 10 	movl   $0xf01078b9,0xc(%esp)
f0101f91:	f0 
f0101f92:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101f99:	f0 
f0101f9a:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0101fa1:	00 
f0101fa2:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0101fce:	c7 44 24 0c d0 70 10 	movl   $0xf01070d0,0xc(%esp)
f0101fd5:	f0 
f0101fd6:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0101fdd:	f0 
f0101fde:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0101fe5:	00 
f0101fe6:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0101fed:	e8 4e e0 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ff2:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0101ff7:	f6 00 04             	testb  $0x4,(%eax)
f0101ffa:	75 24                	jne    f0102020 <mem_init+0xcc8>
f0101ffc:	c7 44 24 0c ca 78 10 	movl   $0xf01078ca,0xc(%esp)
f0102003:	f0 
f0102004:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010200b:	f0 
f010200c:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102013:	00 
f0102014:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102040:	c7 44 24 0c e4 6f 10 	movl   $0xf0106fe4,0xc(%esp)
f0102047:	f0 
f0102048:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010204f:	f0 
f0102050:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102057:	00 
f0102058:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010205f:	e8 dc df ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102064:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010206b:	00 
f010206c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102073:	00 
f0102074:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102079:	89 04 24             	mov    %eax,(%esp)
f010207c:	e8 e1 ef ff ff       	call   f0101062 <pgdir_walk>
f0102081:	f6 00 02             	testb  $0x2,(%eax)
f0102084:	75 24                	jne    f01020aa <mem_init+0xd52>
f0102086:	c7 44 24 0c 04 71 10 	movl   $0xf0107104,0xc(%esp)
f010208d:	f0 
f010208e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102095:	f0 
f0102096:	c7 44 24 04 f1 03 00 	movl   $0x3f1,0x4(%esp)
f010209d:	00 
f010209e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01020a5:	e8 96 df ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f01020aa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01020b1:	00 
f01020b2:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01020b9:	00 
f01020ba:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01020bf:	89 04 24             	mov    %eax,(%esp)
f01020c2:	e8 9b ef ff ff       	call   f0101062 <pgdir_walk>
f01020c7:	f6 00 04             	testb  $0x4,(%eax)
f01020ca:	74 24                	je     f01020f0 <mem_init+0xd98>
f01020cc:	c7 44 24 0c 38 71 10 	movl   $0xf0107138,0xc(%esp)
f01020d3:	f0 
f01020d4:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01020db:	f0 
f01020dc:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f01020e3:	00 
f01020e4:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01020eb:	e8 50 df ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01020f0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01020f7:	00 
f01020f8:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01020ff:	00 
f0102100:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102104:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102109:	89 04 24             	mov    %eax,(%esp)
f010210c:	e8 5e f1 ff ff       	call   f010126f <page_insert>
f0102111:	85 c0                	test   %eax,%eax
f0102113:	78 24                	js     f0102139 <mem_init+0xde1>
f0102115:	c7 44 24 0c 70 71 10 	movl   $0xf0107170,0xc(%esp)
f010211c:	f0 
f010211d:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102124:	f0 
f0102125:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f010212c:	00 
f010212d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102134:	e8 07 df ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0102139:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102140:	00 
f0102141:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102148:	00 
f0102149:	89 74 24 04          	mov    %esi,0x4(%esp)
f010214d:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102152:	89 04 24             	mov    %eax,(%esp)
f0102155:	e8 15 f1 ff ff       	call   f010126f <page_insert>
f010215a:	85 c0                	test   %eax,%eax
f010215c:	74 24                	je     f0102182 <mem_init+0xe2a>
f010215e:	c7 44 24 0c a8 71 10 	movl   $0xf01071a8,0xc(%esp)
f0102165:	f0 
f0102166:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010216d:	f0 
f010216e:	c7 44 24 04 f8 03 00 	movl   $0x3f8,0x4(%esp)
f0102175:	00 
f0102176:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010217d:	e8 be de ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102182:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102189:	00 
f010218a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102191:	00 
f0102192:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102197:	89 04 24             	mov    %eax,(%esp)
f010219a:	e8 c3 ee ff ff       	call   f0101062 <pgdir_walk>
f010219f:	f6 00 04             	testb  $0x4,(%eax)
f01021a2:	74 24                	je     f01021c8 <mem_init+0xe70>
f01021a4:	c7 44 24 0c 38 71 10 	movl   $0xf0107138,0xc(%esp)
f01021ab:	f0 
f01021ac:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01021b3:	f0 
f01021b4:	c7 44 24 04 f9 03 00 	movl   $0x3f9,0x4(%esp)
f01021bb:	00 
f01021bc:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01021c3:	e8 78 de ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01021c8:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01021cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01021d5:	e8 3a e8 ff ff       	call   f0100a14 <check_va2pa>
f01021da:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01021dd:	89 f0                	mov    %esi,%eax
f01021df:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f01021e5:	c1 f8 03             	sar    $0x3,%eax
f01021e8:	c1 e0 0c             	shl    $0xc,%eax
f01021eb:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f01021ee:	74 24                	je     f0102214 <mem_init+0xebc>
f01021f0:	c7 44 24 0c e4 71 10 	movl   $0xf01071e4,0xc(%esp)
f01021f7:	f0 
f01021f8:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01021ff:	f0 
f0102200:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102207:	00 
f0102208:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010220f:	e8 2c de ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102214:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102219:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010221c:	e8 f3 e7 ff ff       	call   f0100a14 <check_va2pa>
f0102221:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102224:	74 24                	je     f010224a <mem_init+0xef2>
f0102226:	c7 44 24 0c 10 72 10 	movl   $0xf0107210,0xc(%esp)
f010222d:	f0 
f010222e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102235:	f0 
f0102236:	c7 44 24 04 fd 03 00 	movl   $0x3fd,0x4(%esp)
f010223d:	00 
f010223e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102245:	e8 f6 dd ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010224a:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010224f:	74 24                	je     f0102275 <mem_init+0xf1d>
f0102251:	c7 44 24 0c e0 78 10 	movl   $0xf01078e0,0xc(%esp)
f0102258:	f0 
f0102259:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102260:	f0 
f0102261:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102268:	00 
f0102269:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102270:	e8 cb dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102275:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010227a:	74 24                	je     f01022a0 <mem_init+0xf48>
f010227c:	c7 44 24 0c f1 78 10 	movl   $0xf01078f1,0xc(%esp)
f0102283:	f0 
f0102284:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010228b:	f0 
f010228c:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102293:	00 
f0102294:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010229b:	e8 a0 dd ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01022a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022a7:	e8 d2 ec ff ff       	call   f0100f7e <page_alloc>
f01022ac:	85 c0                	test   %eax,%eax
f01022ae:	74 04                	je     f01022b4 <mem_init+0xf5c>
f01022b0:	39 c3                	cmp    %eax,%ebx
f01022b2:	74 24                	je     f01022d8 <mem_init+0xf80>
f01022b4:	c7 44 24 0c 40 72 10 	movl   $0xf0107240,0xc(%esp)
f01022bb:	f0 
f01022bc:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01022c3:	f0 
f01022c4:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01022cb:	00 
f01022cc:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01022d3:	e8 68 dd ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01022d8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01022df:	00 
f01022e0:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01022e5:	89 04 24             	mov    %eax,(%esp)
f01022e8:	e8 39 ef ff ff       	call   f0101226 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01022ed:	8b 15 8c 2e 22 f0    	mov    0xf0222e8c,%edx
f01022f3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01022f6:	ba 00 00 00 00       	mov    $0x0,%edx
f01022fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022fe:	e8 11 e7 ff ff       	call   f0100a14 <check_va2pa>
f0102303:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102306:	74 24                	je     f010232c <mem_init+0xfd4>
f0102308:	c7 44 24 0c 64 72 10 	movl   $0xf0107264,0xc(%esp)
f010230f:	f0 
f0102310:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102317:	f0 
f0102318:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f010231f:	00 
f0102320:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102327:	e8 14 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f010232c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102331:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102334:	e8 db e6 ff ff       	call   f0100a14 <check_va2pa>
f0102339:	89 f2                	mov    %esi,%edx
f010233b:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f0102341:	c1 fa 03             	sar    $0x3,%edx
f0102344:	c1 e2 0c             	shl    $0xc,%edx
f0102347:	39 d0                	cmp    %edx,%eax
f0102349:	74 24                	je     f010236f <mem_init+0x1017>
f010234b:	c7 44 24 0c 10 72 10 	movl   $0xf0107210,0xc(%esp)
f0102352:	f0 
f0102353:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010235a:	f0 
f010235b:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f0102362:	00 
f0102363:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010236a:	e8 d1 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010236f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102374:	74 24                	je     f010239a <mem_init+0x1042>
f0102376:	c7 44 24 0c 97 78 10 	movl   $0xf0107897,0xc(%esp)
f010237d:	f0 
f010237e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102385:	f0 
f0102386:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f010238d:	00 
f010238e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102395:	e8 a6 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f010239a:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010239f:	74 24                	je     f01023c5 <mem_init+0x106d>
f01023a1:	c7 44 24 0c f1 78 10 	movl   $0xf01078f1,0xc(%esp)
f01023a8:	f0 
f01023a9:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01023b0:	f0 
f01023b1:	c7 44 24 04 0a 04 00 	movl   $0x40a,0x4(%esp)
f01023b8:	00 
f01023b9:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f01023e8:	c7 44 24 0c 88 72 10 	movl   $0xf0107288,0xc(%esp)
f01023ef:	f0 
f01023f0:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01023f7:	f0 
f01023f8:	c7 44 24 04 0d 04 00 	movl   $0x40d,0x4(%esp)
f01023ff:	00 
f0102400:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102407:	e8 34 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f010240c:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102411:	75 24                	jne    f0102437 <mem_init+0x10df>
f0102413:	c7 44 24 0c 02 79 10 	movl   $0xf0107902,0xc(%esp)
f010241a:	f0 
f010241b:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102422:	f0 
f0102423:	c7 44 24 04 0e 04 00 	movl   $0x40e,0x4(%esp)
f010242a:	00 
f010242b:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102432:	e8 09 dc ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0102437:	83 3e 00             	cmpl   $0x0,(%esi)
f010243a:	74 24                	je     f0102460 <mem_init+0x1108>
f010243c:	c7 44 24 0c 0e 79 10 	movl   $0xf010790e,0xc(%esp)
f0102443:	f0 
f0102444:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010244b:	f0 
f010244c:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102453:	00 
f0102454:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010245b:	e8 e0 db ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102460:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102467:	00 
f0102468:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f010246d:	89 04 24             	mov    %eax,(%esp)
f0102470:	e8 b1 ed ff ff       	call   f0101226 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102475:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f010247a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010247d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102482:	e8 8d e5 ff ff       	call   f0100a14 <check_va2pa>
f0102487:	83 f8 ff             	cmp    $0xffffffff,%eax
f010248a:	74 24                	je     f01024b0 <mem_init+0x1158>
f010248c:	c7 44 24 0c 64 72 10 	movl   $0xf0107264,0xc(%esp)
f0102493:	f0 
f0102494:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010249b:	f0 
f010249c:	c7 44 24 04 13 04 00 	movl   $0x413,0x4(%esp)
f01024a3:	00 
f01024a4:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01024ab:	e8 90 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01024b0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01024b5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01024b8:	e8 57 e5 ff ff       	call   f0100a14 <check_va2pa>
f01024bd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01024c0:	74 24                	je     f01024e6 <mem_init+0x118e>
f01024c2:	c7 44 24 0c c0 72 10 	movl   $0xf01072c0,0xc(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01024d1:	f0 
f01024d2:	c7 44 24 04 14 04 00 	movl   $0x414,0x4(%esp)
f01024d9:	00 
f01024da:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01024e1:	e8 5a db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f01024e6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01024eb:	74 24                	je     f0102511 <mem_init+0x11b9>
f01024ed:	c7 44 24 0c 23 79 10 	movl   $0xf0107923,0xc(%esp)
f01024f4:	f0 
f01024f5:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01024fc:	f0 
f01024fd:	c7 44 24 04 15 04 00 	movl   $0x415,0x4(%esp)
f0102504:	00 
f0102505:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010250c:	e8 2f db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102511:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102516:	74 24                	je     f010253c <mem_init+0x11e4>
f0102518:	c7 44 24 0c f1 78 10 	movl   $0xf01078f1,0xc(%esp)
f010251f:	f0 
f0102520:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102527:	f0 
f0102528:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f010252f:	00 
f0102530:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102537:	e8 04 db ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010253c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102543:	e8 36 ea ff ff       	call   f0100f7e <page_alloc>
f0102548:	85 c0                	test   %eax,%eax
f010254a:	74 04                	je     f0102550 <mem_init+0x11f8>
f010254c:	39 c6                	cmp    %eax,%esi
f010254e:	74 24                	je     f0102574 <mem_init+0x121c>
f0102550:	c7 44 24 0c e8 72 10 	movl   $0xf01072e8,0xc(%esp)
f0102557:	f0 
f0102558:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010255f:	f0 
f0102560:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102567:	00 
f0102568:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010256f:	e8 cc da ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102574:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010257b:	e8 fe e9 ff ff       	call   f0100f7e <page_alloc>
f0102580:	85 c0                	test   %eax,%eax
f0102582:	74 24                	je     f01025a8 <mem_init+0x1250>
f0102584:	c7 44 24 0c 45 78 10 	movl   $0xf0107845,0xc(%esp)
f010258b:	f0 
f010258c:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102593:	f0 
f0102594:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f010259b:	00 
f010259c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01025a3:	e8 98 da ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025a8:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01025ad:	8b 08                	mov    (%eax),%ecx
f01025af:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01025b5:	89 fa                	mov    %edi,%edx
f01025b7:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f01025bd:	c1 fa 03             	sar    $0x3,%edx
f01025c0:	c1 e2 0c             	shl    $0xc,%edx
f01025c3:	39 d1                	cmp    %edx,%ecx
f01025c5:	74 24                	je     f01025eb <mem_init+0x1293>
f01025c7:	c7 44 24 0c 8c 6f 10 	movl   $0xf0106f8c,0xc(%esp)
f01025ce:	f0 
f01025cf:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01025d6:	f0 
f01025d7:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f01025de:	00 
f01025df:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01025e6:	e8 55 da ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01025eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01025f1:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01025f6:	74 24                	je     f010261c <mem_init+0x12c4>
f01025f8:	c7 44 24 0c a8 78 10 	movl   $0xf01078a8,0xc(%esp)
f01025ff:	f0 
f0102600:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102607:	f0 
f0102608:	c7 44 24 04 21 04 00 	movl   $0x421,0x4(%esp)
f010260f:	00 
f0102610:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f010263a:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f010263f:	89 04 24             	mov    %eax,(%esp)
f0102642:	e8 1b ea ff ff       	call   f0101062 <pgdir_walk>
f0102647:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010264a:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f0102650:	8b 51 04             	mov    0x4(%ecx),%edx
f0102653:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102659:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010265c:	8b 15 88 2e 22 f0    	mov    0xf0222e88,%edx
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
f010267d:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0102684:	f0 
f0102685:	c7 44 24 04 28 04 00 	movl   $0x428,0x4(%esp)
f010268c:	00 
f010268d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102694:	e8 a7 d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102699:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010269c:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01026a2:	39 d0                	cmp    %edx,%eax
f01026a4:	74 24                	je     f01026ca <mem_init+0x1372>
f01026a6:	c7 44 24 0c 34 79 10 	movl   $0xf0107934,0xc(%esp)
f01026ad:	f0 
f01026ae:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01026b5:	f0 
f01026b6:	c7 44 24 04 29 04 00 	movl   $0x429,0x4(%esp)
f01026bd:	00 
f01026be:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f01026d9:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
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
f01026f3:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f01026fa:	f0 
f01026fb:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102702:	00 
f0102703:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
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
f0102727:	e8 d2 33 00 00       	call   f0105afe <memset>
	page_free(pp0);
f010272c:	89 3c 24             	mov    %edi,(%esp)
f010272f:	e8 ce e8 ff ff       	call   f0101002 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102734:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010273b:	00 
f010273c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102743:	00 
f0102744:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102749:	89 04 24             	mov    %eax,(%esp)
f010274c:	e8 11 e9 ff ff       	call   f0101062 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102751:	89 fa                	mov    %edi,%edx
f0102753:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f0102759:	c1 fa 03             	sar    $0x3,%edx
f010275c:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010275f:	89 d0                	mov    %edx,%eax
f0102761:	c1 e8 0c             	shr    $0xc,%eax
f0102764:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f010276a:	72 20                	jb     f010278c <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010276c:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102770:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0102777:	f0 
f0102778:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010277f:	00 
f0102780:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
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
f01027a0:	c7 44 24 0c 4c 79 10 	movl   $0xf010794c,0xc(%esp)
f01027a7:	f0 
f01027a8:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01027af:	f0 
f01027b0:	c7 44 24 04 33 04 00 	movl   $0x433,0x4(%esp)
f01027b7:	00 
f01027b8:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f01027cb:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01027d0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01027d6:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01027dc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01027df:	89 0d 40 22 22 f0    	mov    %ecx,0xf0222240

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
f010283e:	c7 44 24 0c 0c 73 10 	movl   $0xf010730c,0xc(%esp)
f0102845:	f0 
f0102846:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010284d:	f0 
f010284e:	c7 44 24 04 43 04 00 	movl   $0x443,0x4(%esp)
f0102855:	00 
f0102856:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010285d:	e8 de d7 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102862:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102868:	76 0e                	jbe    f0102878 <mem_init+0x1520>
f010286a:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0102870:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0102876:	76 24                	jbe    f010289c <mem_init+0x1544>
f0102878:	c7 44 24 0c 34 73 10 	movl   $0xf0107334,0xc(%esp)
f010287f:	f0 
f0102880:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102887:	f0 
f0102888:	c7 44 24 04 44 04 00 	movl   $0x444,0x4(%esp)
f010288f:	00 
f0102890:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f01028a8:	c7 44 24 0c 5c 73 10 	movl   $0xf010735c,0xc(%esp)
f01028af:	f0 
f01028b0:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01028b7:	f0 
f01028b8:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f01028bf:	00 
f01028c0:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01028c7:	e8 74 d7 ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f01028cc:	39 c6                	cmp    %eax,%esi
f01028ce:	73 24                	jae    f01028f4 <mem_init+0x159c>
f01028d0:	c7 44 24 0c 63 79 10 	movl   $0xf0107963,0xc(%esp)
f01028d7:	f0 
f01028d8:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01028df:	f0 
f01028e0:	c7 44 24 04 48 04 00 	movl   $0x448,0x4(%esp)
f01028e7:	00 
f01028e8:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01028ef:	e8 4c d7 ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f01028f4:	8b 3d 8c 2e 22 f0    	mov    0xf0222e8c,%edi
f01028fa:	89 da                	mov    %ebx,%edx
f01028fc:	89 f8                	mov    %edi,%eax
f01028fe:	e8 11 e1 ff ff       	call   f0100a14 <check_va2pa>
f0102903:	85 c0                	test   %eax,%eax
f0102905:	74 24                	je     f010292b <mem_init+0x15d3>
f0102907:	c7 44 24 0c 84 73 10 	movl   $0xf0107384,0xc(%esp)
f010290e:	f0 
f010290f:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102916:	f0 
f0102917:	c7 44 24 04 4a 04 00 	movl   $0x44a,0x4(%esp)
f010291e:	00 
f010291f:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102926:	e8 15 d7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010292b:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102931:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102934:	89 c2                	mov    %eax,%edx
f0102936:	89 f8                	mov    %edi,%eax
f0102938:	e8 d7 e0 ff ff       	call   f0100a14 <check_va2pa>
f010293d:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102942:	74 24                	je     f0102968 <mem_init+0x1610>
f0102944:	c7 44 24 0c a8 73 10 	movl   $0xf01073a8,0xc(%esp)
f010294b:	f0 
f010294c:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102953:	f0 
f0102954:	c7 44 24 04 4b 04 00 	movl   $0x44b,0x4(%esp)
f010295b:	00 
f010295c:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102963:	e8 d8 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102968:	89 f2                	mov    %esi,%edx
f010296a:	89 f8                	mov    %edi,%eax
f010296c:	e8 a3 e0 ff ff       	call   f0100a14 <check_va2pa>
f0102971:	85 c0                	test   %eax,%eax
f0102973:	74 24                	je     f0102999 <mem_init+0x1641>
f0102975:	c7 44 24 0c d8 73 10 	movl   $0xf01073d8,0xc(%esp)
f010297c:	f0 
f010297d:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102984:	f0 
f0102985:	c7 44 24 04 4c 04 00 	movl   $0x44c,0x4(%esp)
f010298c:	00 
f010298d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102994:	e8 a7 d6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102999:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f010299f:	89 f8                	mov    %edi,%eax
f01029a1:	e8 6e e0 ff ff       	call   f0100a14 <check_va2pa>
f01029a6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029a9:	74 24                	je     f01029cf <mem_init+0x1677>
f01029ab:	c7 44 24 0c fc 73 10 	movl   $0xf01073fc,0xc(%esp)
f01029b2:	f0 
f01029b3:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01029ba:	f0 
f01029bb:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f01029c2:	00 
f01029c3:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f01029e8:	c7 44 24 0c 28 74 10 	movl   $0xf0107428,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102a07:	e8 34 d6 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102a0c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a13:	00 
f0102a14:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a18:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102a1d:	89 04 24             	mov    %eax,(%esp)
f0102a20:	e8 3d e6 ff ff       	call   f0101062 <pgdir_walk>
f0102a25:	f6 00 04             	testb  $0x4,(%eax)
f0102a28:	74 24                	je     f0102a4e <mem_init+0x16f6>
f0102a2a:	c7 44 24 0c 6c 74 10 	movl   $0xf010746c,0xc(%esp)
f0102a31:	f0 
f0102a32:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102a39:	f0 
f0102a3a:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102a41:	00 
f0102a42:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102a49:	e8 f2 d5 ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102a4e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a55:	00 
f0102a56:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a5a:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102a5f:	89 04 24             	mov    %eax,(%esp)
f0102a62:	e8 fb e5 ff ff       	call   f0101062 <pgdir_walk>
f0102a67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102a6d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a74:	00 
f0102a75:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102a78:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102a7c:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102a81:	89 04 24             	mov    %eax,(%esp)
f0102a84:	e8 d9 e5 ff ff       	call   f0101062 <pgdir_walk>
f0102a89:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102a8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102a96:	00 
f0102a97:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102a9b:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102aa0:	89 04 24             	mov    %eax,(%esp)
f0102aa3:	e8 ba e5 ff ff       	call   f0101062 <pgdir_walk>
f0102aa8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102aae:	c7 04 24 75 79 10 f0 	movl   $0xf0107975,(%esp)
f0102ab5:	e8 90 11 00 00       	call   f0103c4a <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_W);
f0102aba:	a1 90 2e 22 f0       	mov    0xf0222e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102abf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ac4:	77 20                	ja     f0102ae6 <mem_init+0x178e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ac6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102aca:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102ad1:	f0 
f0102ad2:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f0102ad9:	00 
f0102ada:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102ae1:	e8 5a d5 ff ff       	call   f0100040 <_panic>
f0102ae6:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102aed:	00 
	return (physaddr_t)kva - KERNBASE;
f0102aee:	05 00 00 00 10       	add    $0x10000000,%eax
f0102af3:	89 04 24             	mov    %eax,(%esp)
f0102af6:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102afb:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102b00:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102b05:	e8 f7 e5 ff ff       	call   f0101101 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_W | PTE_U);
f0102b0a:	a1 48 22 22 f0       	mov    0xf0222248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b0f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b14:	77 20                	ja     f0102b36 <mem_init+0x17de>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b16:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b1a:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102b21:	f0 
f0102b22:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
f0102b29:	00 
f0102b2a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102b31:	e8 0a d5 ff ff       	call   f0100040 <_panic>
f0102b36:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f0102b3d:	00 
	return (physaddr_t)kva - KERNBASE;
f0102b3e:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b43:	89 04 24             	mov    %eax,(%esp)
f0102b46:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0102b4b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102b50:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102b55:	e8 a7 e5 ff ff       	call   f0101101 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b5a:	b8 00 e0 11 f0       	mov    $0xf011e000,%eax
f0102b5f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b64:	77 20                	ja     f0102b86 <mem_init+0x182e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b66:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b6a:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102b71:	f0 
f0102b72:	c7 44 24 04 d7 00 00 	movl   $0xd7,0x4(%esp)
f0102b79:	00 
f0102b7a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102b81:	e8 ba d4 ff ff       	call   f0100040 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102b86:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b8d:	00 
f0102b8e:	c7 04 24 00 e0 11 00 	movl   $0x11e000,(%esp)
f0102b95:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102b9a:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102b9f:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102ba4:	e8 58 e5 ff ff       	call   f0101101 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 2*npages*PGSIZE, 0, PTE_W);
f0102ba9:	8b 0d 88 2e 22 f0    	mov    0xf0222e88,%ecx
f0102baf:	c1 e1 0d             	shl    $0xd,%ecx
f0102bb2:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102bb9:	00 
f0102bba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102bc1:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102bc6:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0102bcb:	e8 31 e5 ff ff       	call   f0101101 <boot_map_region>
f0102bd0:	c7 45 cc 00 40 22 f0 	movl   $0xf0224000,-0x34(%ebp)
f0102bd7:	bb 00 40 22 f0       	mov    $0xf0224000,%ebx
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
f0102bed:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102bf4:	f0 
f0102bf5:	c7 44 24 04 19 01 00 	movl   $0x119,0x4(%esp)
f0102bfc:	00 
f0102bfd:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102c21:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
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
f0102c3f:	8b 1d 8c 2e 22 f0    	mov    0xf0222e8c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102c45:	8b 0d 88 2e 22 f0    	mov    0xf0222e88,%ecx
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
f0102c6f:	8b 15 90 2e 22 f0    	mov    0xf0222e90,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c75:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102c7b:	77 20                	ja     f0102c9d <mem_init+0x1945>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102c7d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102c81:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102c88:	f0 
f0102c89:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102c90:	00 
f0102c91:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102c98:	e8 a3 d3 ff ff       	call   f0100040 <_panic>
f0102c9d:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102ca4:	39 d0                	cmp    %edx,%eax
f0102ca6:	74 24                	je     f0102ccc <mem_init+0x1974>
f0102ca8:	c7 44 24 0c a0 74 10 	movl   $0xf01074a0,0xc(%esp)
f0102caf:	f0 
f0102cb0:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102cb7:	f0 
f0102cb8:	c7 44 24 04 68 03 00 	movl   $0x368,0x4(%esp)
f0102cbf:	00 
f0102cc0:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102ce8:	8b 15 48 22 22 f0    	mov    0xf0222248,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cee:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102cf4:	77 20                	ja     f0102d16 <mem_init+0x19be>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cf6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cfa:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102d01:	f0 
f0102d02:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102d09:	00 
f0102d0a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102d11:	e8 2a d3 ff ff       	call   f0100040 <_panic>
f0102d16:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102d1d:	39 d0                	cmp    %edx,%eax
f0102d1f:	74 24                	je     f0102d45 <mem_init+0x19ed>
f0102d21:	c7 44 24 0c d4 74 10 	movl   $0xf01074d4,0xc(%esp)
f0102d28:	f0 
f0102d29:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102d30:	f0 
f0102d31:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0102d38:	00 
f0102d39:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102d71:	c7 44 24 0c 08 75 10 	movl   $0xf0107508,0xc(%esp)
f0102d78:	f0 
f0102d79:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102d80:	f0 
f0102d81:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0102d88:	00 
f0102d89:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102dde:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102de5:	f0 
f0102de6:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102ded:	00 
f0102dee:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102df5:	e8 46 d2 ff ff       	call   f0100040 <_panic>
f0102dfa:	39 f0                	cmp    %esi,%eax
f0102dfc:	74 24                	je     f0102e22 <mem_init+0x1aca>
f0102dfe:	c7 44 24 0c 30 75 10 	movl   $0xf0107530,0xc(%esp)
f0102e05:	f0 
f0102e06:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102e0d:	f0 
f0102e0e:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102e15:	00 
f0102e16:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102e4e:	c7 44 24 0c 78 75 10 	movl   $0xf0107578,0xc(%esp)
f0102e55:	f0 
f0102e56:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102e5d:	f0 
f0102e5e:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0102e65:	00 
f0102e66:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102eb6:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f0102ebd:	f0 
f0102ebe:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102ec5:	f0 
f0102ec6:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0102ecd:	00 
f0102ece:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102ee9:	c7 44 24 0c 8e 79 10 	movl   $0xf010798e,0xc(%esp)
f0102ef0:	f0 
f0102ef1:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102ef8:	f0 
f0102ef9:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0102f00:	00 
f0102f01:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102f08:	e8 33 d1 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102f0d:	f6 c2 02             	test   $0x2,%dl
f0102f10:	75 4e                	jne    f0102f60 <mem_init+0x1c08>
f0102f12:	c7 44 24 0c 9f 79 10 	movl   $0xf010799f,0xc(%esp)
f0102f19:	f0 
f0102f1a:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102f21:	f0 
f0102f22:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0102f29:	00 
f0102f2a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102f31:	e8 0a d1 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102f36:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102f3a:	74 24                	je     f0102f60 <mem_init+0x1c08>
f0102f3c:	c7 44 24 0c b0 79 10 	movl   $0xf01079b0,0xc(%esp)
f0102f43:	f0 
f0102f44:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102f4b:	f0 
f0102f4c:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0102f53:	00 
f0102f54:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102f6c:	c7 04 24 9c 75 10 f0 	movl   $0xf010759c,(%esp)
f0102f73:	e8 d2 0c 00 00       	call   f0103c4a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102f78:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102f7d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102f82:	77 20                	ja     f0102fa4 <mem_init+0x1c4c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102f84:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102f88:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0102f8f:	f0 
f0102f90:	c7 44 24 04 f0 00 00 	movl   $0xf0,0x4(%esp)
f0102f97:	00 
f0102f98:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0102fd6:	c7 44 24 0c 9a 77 10 	movl   $0xf010779a,0xc(%esp)
f0102fdd:	f0 
f0102fde:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0102fe5:	f0 
f0102fe6:	c7 44 24 04 65 04 00 	movl   $0x465,0x4(%esp)
f0102fed:	00 
f0102fee:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0102ff5:	e8 46 d0 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102ffa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103001:	e8 78 df ff ff       	call   f0100f7e <page_alloc>
f0103006:	89 c7                	mov    %eax,%edi
f0103008:	85 c0                	test   %eax,%eax
f010300a:	75 24                	jne    f0103030 <mem_init+0x1cd8>
f010300c:	c7 44 24 0c b0 77 10 	movl   $0xf01077b0,0xc(%esp)
f0103013:	f0 
f0103014:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010301b:	f0 
f010301c:	c7 44 24 04 66 04 00 	movl   $0x466,0x4(%esp)
f0103023:	00 
f0103024:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f010302b:	e8 10 d0 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0103030:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103037:	e8 42 df ff ff       	call   f0100f7e <page_alloc>
f010303c:	89 c3                	mov    %eax,%ebx
f010303e:	85 c0                	test   %eax,%eax
f0103040:	75 24                	jne    f0103066 <mem_init+0x1d0e>
f0103042:	c7 44 24 0c c6 77 10 	movl   $0xf01077c6,0xc(%esp)
f0103049:	f0 
f010304a:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0103051:	f0 
f0103052:	c7 44 24 04 67 04 00 	movl   $0x467,0x4(%esp)
f0103059:	00 
f010305a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f0103070:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0103076:	c1 f8 03             	sar    $0x3,%eax
f0103079:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010307c:	89 c2                	mov    %eax,%edx
f010307e:	c1 ea 0c             	shr    $0xc,%edx
f0103081:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f0103087:	72 20                	jb     f01030a9 <mem_init+0x1d51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103089:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010308d:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0103094:	f0 
f0103095:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f010309c:	00 
f010309d:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f01030a4:	e8 97 cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01030a9:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01030b0:	00 
f01030b1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01030b8:	00 
	return (void *)(pa + KERNBASE);
f01030b9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01030be:	89 04 24             	mov    %eax,(%esp)
f01030c1:	e8 38 2a 00 00       	call   f0105afe <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01030c6:	89 d8                	mov    %ebx,%eax
f01030c8:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f01030ce:	c1 f8 03             	sar    $0x3,%eax
f01030d1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030d4:	89 c2                	mov    %eax,%edx
f01030d6:	c1 ea 0c             	shr    $0xc,%edx
f01030d9:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f01030df:	72 20                	jb     f0103101 <mem_init+0x1da9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030e5:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f01030ec:	f0 
f01030ed:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01030f4:	00 
f01030f5:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f01030fc:	e8 3f cf ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0103101:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0103108:	00 
f0103109:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103110:	00 
	return (void *)(pa + KERNBASE);
f0103111:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103116:	89 04 24             	mov    %eax,(%esp)
f0103119:	e8 e0 29 00 00       	call   f0105afe <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010311e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0103125:	00 
f0103126:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010312d:	00 
f010312e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103132:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f0103137:	89 04 24             	mov    %eax,(%esp)
f010313a:	e8 30 e1 ff ff       	call   f010126f <page_insert>
	assert(pp1->pp_ref == 1);
f010313f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0103144:	74 24                	je     f010316a <mem_init+0x1e12>
f0103146:	c7 44 24 0c 97 78 10 	movl   $0xf0107897,0xc(%esp)
f010314d:	f0 
f010314e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0103155:	f0 
f0103156:	c7 44 24 04 6c 04 00 	movl   $0x46c,0x4(%esp)
f010315d:	00 
f010315e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0103165:	e8 d6 ce ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f010316a:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0103171:	01 01 01 
f0103174:	74 24                	je     f010319a <mem_init+0x1e42>
f0103176:	c7 44 24 0c bc 75 10 	movl   $0xf01075bc,0xc(%esp)
f010317d:	f0 
f010317e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0103185:	f0 
f0103186:	c7 44 24 04 6d 04 00 	movl   $0x46d,0x4(%esp)
f010318d:	00 
f010318e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0103195:	e8 a6 ce ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f010319a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01031a1:	00 
f01031a2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01031a9:	00 
f01031aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031ae:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01031b3:	89 04 24             	mov    %eax,(%esp)
f01031b6:	e8 b4 e0 ff ff       	call   f010126f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01031bb:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01031c2:	02 02 02 
f01031c5:	74 24                	je     f01031eb <mem_init+0x1e93>
f01031c7:	c7 44 24 0c e0 75 10 	movl   $0xf01075e0,0xc(%esp)
f01031ce:	f0 
f01031cf:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01031d6:	f0 
f01031d7:	c7 44 24 04 6f 04 00 	movl   $0x46f,0x4(%esp)
f01031de:	00 
f01031df:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01031e6:	e8 55 ce ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01031eb:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01031f0:	74 24                	je     f0103216 <mem_init+0x1ebe>
f01031f2:	c7 44 24 0c b9 78 10 	movl   $0xf01078b9,0xc(%esp)
f01031f9:	f0 
f01031fa:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0103201:	f0 
f0103202:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f0103209:	00 
f010320a:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0103211:	e8 2a ce ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0103216:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f010321b:	74 24                	je     f0103241 <mem_init+0x1ee9>
f010321d:	c7 44 24 0c 23 79 10 	movl   $0xf0107923,0xc(%esp)
f0103224:	f0 
f0103225:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f010322c:	f0 
f010322d:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f0103234:	00 
f0103235:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
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
f010324d:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f0103253:	c1 f8 03             	sar    $0x3,%eax
f0103256:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103259:	89 c2                	mov    %eax,%edx
f010325b:	c1 ea 0c             	shr    $0xc,%edx
f010325e:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f0103264:	72 20                	jb     f0103286 <mem_init+0x1f2e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103266:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010326a:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0103271:	f0 
f0103272:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103279:	00 
f010327a:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f0103281:	e8 ba cd ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0103286:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f010328d:	03 03 03 
f0103290:	74 24                	je     f01032b6 <mem_init+0x1f5e>
f0103292:	c7 44 24 0c 04 76 10 	movl   $0xf0107604,0xc(%esp)
f0103299:	f0 
f010329a:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01032a1:	f0 
f01032a2:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f01032a9:	00 
f01032aa:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01032b1:	e8 8a cd ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01032b6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01032bd:	00 
f01032be:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01032c3:	89 04 24             	mov    %eax,(%esp)
f01032c6:	e8 5b df ff ff       	call   f0101226 <page_remove>
	assert(pp2->pp_ref == 0);
f01032cb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01032d0:	74 24                	je     f01032f6 <mem_init+0x1f9e>
f01032d2:	c7 44 24 0c f1 78 10 	movl   $0xf01078f1,0xc(%esp)
f01032d9:	f0 
f01032da:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01032e1:	f0 
f01032e2:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f01032e9:	00 
f01032ea:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f01032f1:	e8 4a cd ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01032f6:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
f01032fb:	8b 08                	mov    (%eax),%ecx
f01032fd:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103303:	89 f2                	mov    %esi,%edx
f0103305:	2b 15 90 2e 22 f0    	sub    0xf0222e90,%edx
f010330b:	c1 fa 03             	sar    $0x3,%edx
f010330e:	c1 e2 0c             	shl    $0xc,%edx
f0103311:	39 d1                	cmp    %edx,%ecx
f0103313:	74 24                	je     f0103339 <mem_init+0x1fe1>
f0103315:	c7 44 24 0c 8c 6f 10 	movl   $0xf0106f8c,0xc(%esp)
f010331c:	f0 
f010331d:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0103324:	f0 
f0103325:	c7 44 24 04 78 04 00 	movl   $0x478,0x4(%esp)
f010332c:	00 
f010332d:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0103334:	e8 07 cd ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0103339:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010333f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0103344:	74 24                	je     f010336a <mem_init+0x2012>
f0103346:	c7 44 24 0c a8 78 10 	movl   $0xf01078a8,0xc(%esp)
f010334d:	f0 
f010334e:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0103355:	f0 
f0103356:	c7 44 24 04 7a 04 00 	movl   $0x47a,0x4(%esp)
f010335d:	00 
f010335e:	c7 04 24 91 76 10 f0 	movl   $0xf0107691,(%esp)
f0103365:	e8 d6 cc ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f010336a:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0103370:	89 34 24             	mov    %esi,(%esp)
f0103373:	e8 8a dc ff ff       	call   f0101002 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0103378:	c7 04 24 30 76 10 f0 	movl   $0xf0107630,(%esp)
f010337f:	e8 c6 08 00 00       	call   f0103c4a <cprintf>
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
f01033b9:	89 1d 44 22 22 f0    	mov    %ebx,0xf0222244
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
f01033e1:	89 3d 44 22 22 f0    	mov    %edi,0xf0222244
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
f01033fe:	89 3d 44 22 22 f0    	mov    %edi,0xf0222244
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
f010345b:	a1 44 22 22 f0       	mov    0xf0222244,%eax
f0103460:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103464:	8b 43 48             	mov    0x48(%ebx),%eax
f0103467:	89 44 24 04          	mov    %eax,0x4(%esp)
f010346b:	c7 04 24 5c 76 10 f0 	movl   $0xf010765c,(%esp)
f0103472:	e8 d3 07 00 00       	call   f0103c4a <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0103477:	89 1c 24             	mov    %ebx,(%esp)
f010347a:	e8 c8 04 00 00       	call   f0103947 <env_destroy>
	}
}
f010347f:	83 c4 14             	add    $0x14,%esp
f0103482:	5b                   	pop    %ebx
f0103483:	5d                   	pop    %ebp
f0103484:	c3                   	ret    
f0103485:	00 00                	add    %al,(%eax)
	...

f0103488 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103488:	55                   	push   %ebp
f0103489:	89 e5                	mov    %esp,%ebp
f010348b:	57                   	push   %edi
f010348c:	56                   	push   %esi
f010348d:	53                   	push   %ebx
f010348e:	83 ec 0c             	sub    $0xc,%esp
f0103491:	8b 45 08             	mov    0x8(%ebp),%eax
f0103494:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103497:	8a 55 10             	mov    0x10(%ebp),%dl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f010349a:	85 c0                	test   %eax,%eax
f010349c:	75 24                	jne    f01034c2 <envid2env+0x3a>
		*env_store = curenv;
f010349e:	e8 89 2c 00 00       	call   f010612c <cpunum>
f01034a3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01034aa:	29 c2                	sub    %eax,%edx
f01034ac:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01034af:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f01034b6:	89 06                	mov    %eax,(%esi)
		return 0;
f01034b8:	b8 00 00 00 00       	mov    $0x0,%eax
f01034bd:	e9 84 00 00 00       	jmp    f0103546 <envid2env+0xbe>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f01034c2:	89 c3                	mov    %eax,%ebx
f01034c4:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f01034ca:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
f01034d1:	c1 e3 07             	shl    $0x7,%ebx
f01034d4:	29 cb                	sub    %ecx,%ebx
f01034d6:	03 1d 48 22 22 f0    	add    0xf0222248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f01034dc:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f01034e0:	74 05                	je     f01034e7 <envid2env+0x5f>
f01034e2:	39 43 48             	cmp    %eax,0x48(%ebx)
f01034e5:	74 0d                	je     f01034f4 <envid2env+0x6c>
		*env_store = 0;
f01034e7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f01034ed:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01034f2:	eb 52                	jmp    f0103546 <envid2env+0xbe>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f01034f4:	84 d2                	test   %dl,%dl
f01034f6:	74 47                	je     f010353f <envid2env+0xb7>
f01034f8:	e8 2f 2c 00 00       	call   f010612c <cpunum>
f01034fd:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103504:	29 c2                	sub    %eax,%edx
f0103506:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103509:	39 1c 85 28 30 22 f0 	cmp    %ebx,-0xfddcfd8(,%eax,4)
f0103510:	74 2d                	je     f010353f <envid2env+0xb7>
f0103512:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f0103515:	e8 12 2c 00 00       	call   f010612c <cpunum>
f010351a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103521:	29 c2                	sub    %eax,%edx
f0103523:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103526:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f010352d:	3b 78 48             	cmp    0x48(%eax),%edi
f0103530:	74 0d                	je     f010353f <envid2env+0xb7>
		*env_store = 0;
f0103532:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		return -E_BAD_ENV;
f0103538:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010353d:	eb 07                	jmp    f0103546 <envid2env+0xbe>
	}

	*env_store = e;
f010353f:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0103541:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103546:	83 c4 0c             	add    $0xc,%esp
f0103549:	5b                   	pop    %ebx
f010354a:	5e                   	pop    %esi
f010354b:	5f                   	pop    %edi
f010354c:	5d                   	pop    %ebp
f010354d:	c3                   	ret    

f010354e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010354e:	55                   	push   %ebp
f010354f:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103551:	b8 20 83 12 f0       	mov    $0xf0128320,%eax
f0103556:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103559:	b8 23 00 00 00       	mov    $0x23,%eax
f010355e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103560:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103562:	b0 10                	mov    $0x10,%al
f0103564:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103566:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103568:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010356a:	ea 71 35 10 f0 08 00 	ljmp   $0x8,$0xf0103571
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103571:	b0 00                	mov    $0x0,%al
f0103573:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103576:	5d                   	pop    %ebp
f0103577:	c3                   	ret    

f0103578 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103578:	55                   	push   %ebp
f0103579:	89 e5                	mov    %esp,%ebp
f010357b:	56                   	push   %esi
f010357c:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f010357d:	8b 35 48 22 22 f0    	mov    0xf0222248,%esi
f0103583:	8b 0d 4c 22 22 f0    	mov    0xf022224c,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103589:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f010358f:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0103594:	eb 02                	jmp    f0103598 <env_init+0x20>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103596:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f0103598:	89 c3                	mov    %eax,%ebx
f010359a:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01035a1:	89 48 44             	mov    %ecx,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f01035a4:	4a                   	dec    %edx
f01035a5:	83 e8 7c             	sub    $0x7c,%eax
f01035a8:	83 fa ff             	cmp    $0xffffffff,%edx
f01035ab:	75 e9                	jne    f0103596 <env_init+0x1e>
f01035ad:	89 35 4c 22 22 f0    	mov    %esi,0xf022224c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01035b3:	e8 96 ff ff ff       	call   f010354e <env_init_percpu>
}
f01035b8:	5b                   	pop    %ebx
f01035b9:	5e                   	pop    %esi
f01035ba:	5d                   	pop    %ebp
f01035bb:	c3                   	ret    

f01035bc <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01035bc:	55                   	push   %ebp
f01035bd:	89 e5                	mov    %esp,%ebp
f01035bf:	56                   	push   %esi
f01035c0:	53                   	push   %ebx
f01035c1:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01035c4:	8b 1d 4c 22 22 f0    	mov    0xf022224c,%ebx
f01035ca:	85 db                	test   %ebx,%ebx
f01035cc:	0f 84 84 01 00 00    	je     f0103756 <env_alloc+0x19a>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01035d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01035d9:	e8 a0 d9 ff ff       	call   f0100f7e <page_alloc>
f01035de:	85 c0                	test   %eax,%eax
f01035e0:	0f 84 77 01 00 00    	je     f010375d <env_alloc+0x1a1>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
f01035e6:	66 ff 40 04          	incw   0x4(%eax)
f01035ea:	2b 05 90 2e 22 f0    	sub    0xf0222e90,%eax
f01035f0:	c1 f8 03             	sar    $0x3,%eax
f01035f3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01035f6:	89 c2                	mov    %eax,%edx
f01035f8:	c1 ea 0c             	shr    $0xc,%edx
f01035fb:	3b 15 88 2e 22 f0    	cmp    0xf0222e88,%edx
f0103601:	72 20                	jb     f0103623 <env_alloc+0x67>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103603:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103607:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f010360e:	f0 
f010360f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103616:	00 
f0103617:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f010361e:	e8 1d ca ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0103623:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103628:	89 43 60             	mov    %eax,0x60(%ebx)
	e->env_pgdir = (pde_t *)page2kva(p);
f010362b:	ba 00 00 00 00       	mov    $0x0,%edx
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f0103630:	b8 00 00 00 00       	mov    $0x0,%eax
		if (i < PDX(UTOP))
f0103635:	3d ba 03 00 00       	cmp    $0x3ba,%eax
f010363a:	77 0c                	ja     f0103648 <env_alloc+0x8c>
			e->env_pgdir[i] = 0;
f010363c:	8b 4b 60             	mov    0x60(%ebx),%ecx
f010363f:	c7 04 11 00 00 00 00 	movl   $0x0,(%ecx,%edx,1)
f0103646:	eb 0f                	jmp    f0103657 <env_alloc+0x9b>
		else {
			e->env_pgdir[i] = kern_pgdir[i];
f0103648:	8b 0d 8c 2e 22 f0    	mov    0xf0222e8c,%ecx
f010364e:	8b 34 11             	mov    (%ecx,%edx,1),%esi
f0103651:	8b 4b 60             	mov    0x60(%ebx),%ecx
f0103654:	89 34 11             	mov    %esi,(%ecx,%edx,1)
	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
	e->env_pgdir = (pde_t *)page2kva(p);
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f0103657:	40                   	inc    %eax
f0103658:	83 c2 04             	add    $0x4,%edx
f010365b:	3d 00 04 00 00       	cmp    $0x400,%eax
f0103660:	75 d3                	jne    f0103635 <env_alloc+0x79>
		}
	}

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103662:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103665:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010366a:	77 20                	ja     f010368c <env_alloc+0xd0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010366c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103670:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f0103677:	f0 
f0103678:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
f010367f:	00 
f0103680:	c7 04 24 be 79 10 f0 	movl   $0xf01079be,(%esp)
f0103687:	e8 b4 c9 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010368c:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0103692:	83 ca 05             	or     $0x5,%edx
f0103695:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010369b:	8b 43 48             	mov    0x48(%ebx),%eax
f010369e:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f01036a3:	89 c1                	mov    %eax,%ecx
f01036a5:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f01036ab:	7f 05                	jg     f01036b2 <env_alloc+0xf6>
		generation = 1 << ENVGENSHIFT;
f01036ad:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f01036b2:	89 d8                	mov    %ebx,%eax
f01036b4:	2b 05 48 22 22 f0    	sub    0xf0222248,%eax
f01036ba:	c1 f8 02             	sar    $0x2,%eax
f01036bd:	89 c6                	mov    %eax,%esi
f01036bf:	c1 e6 05             	shl    $0x5,%esi
f01036c2:	89 c2                	mov    %eax,%edx
f01036c4:	c1 e2 0a             	shl    $0xa,%edx
f01036c7:	01 f2                	add    %esi,%edx
f01036c9:	01 c2                	add    %eax,%edx
f01036cb:	89 d6                	mov    %edx,%esi
f01036cd:	c1 e6 0f             	shl    $0xf,%esi
f01036d0:	01 f2                	add    %esi,%edx
f01036d2:	c1 e2 05             	shl    $0x5,%edx
f01036d5:	01 d0                	add    %edx,%eax
f01036d7:	f7 d8                	neg    %eax
f01036d9:	09 c1                	or     %eax,%ecx
f01036db:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01036de:	8b 45 0c             	mov    0xc(%ebp),%eax
f01036e1:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01036e4:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01036eb:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01036f2:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01036f9:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103700:	00 
f0103701:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103708:	00 
f0103709:	89 1c 24             	mov    %ebx,(%esp)
f010370c:	e8 ed 23 00 00       	call   f0105afe <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103711:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103717:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f010371d:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103723:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f010372a:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0103730:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103737:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f010373e:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103742:	8b 43 44             	mov    0x44(%ebx),%eax
f0103745:	a3 4c 22 22 f0       	mov    %eax,0xf022224c
	*newenv_store = e;
f010374a:	8b 45 08             	mov    0x8(%ebp),%eax
f010374d:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f010374f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103754:	eb 0c                	jmp    f0103762 <env_alloc+0x1a6>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103756:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f010375b:	eb 05                	jmp    f0103762 <env_alloc+0x1a6>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f010375d:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0103762:	83 c4 10             	add    $0x10,%esp
f0103765:	5b                   	pop    %ebx
f0103766:	5e                   	pop    %esi
f0103767:	5d                   	pop    %ebp
f0103768:	c3                   	ret    

f0103769 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103769:	55                   	push   %ebp
f010376a:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.
}
f010376c:	5d                   	pop    %ebp
f010376d:	c3                   	ret    

f010376e <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f010376e:	55                   	push   %ebp
f010376f:	89 e5                	mov    %esp,%ebp
f0103771:	57                   	push   %edi
f0103772:	56                   	push   %esi
f0103773:	53                   	push   %ebx
f0103774:	83 ec 2c             	sub    $0x2c,%esp
f0103777:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f010377a:	e8 ad 29 00 00       	call   f010612c <cpunum>
f010377f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103786:	29 c2                	sub    %eax,%edx
f0103788:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010378b:	39 3c 85 28 30 22 f0 	cmp    %edi,-0xfddcfd8(,%eax,4)
f0103792:	75 3d                	jne    f01037d1 <env_free+0x63>
		lcr3(PADDR(kern_pgdir));
f0103794:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103799:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010379e:	77 20                	ja     f01037c0 <env_free+0x52>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037a0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037a4:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f01037ab:	f0 
f01037ac:	c7 44 24 04 b4 01 00 	movl   $0x1b4,0x4(%esp)
f01037b3:	00 
f01037b4:	c7 04 24 be 79 10 f0 	movl   $0xf01079be,(%esp)
f01037bb:	e8 80 c8 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01037c0:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01037c5:	0f 22 d8             	mov    %eax,%cr3
f01037c8:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01037cf:	eb 07                	jmp    f01037d8 <env_free+0x6a>
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01037d1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01037d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01037db:	c1 e0 02             	shl    $0x2,%eax
f01037de:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01037e1:	8b 47 60             	mov    0x60(%edi),%eax
f01037e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01037e7:	8b 34 10             	mov    (%eax,%edx,1),%esi
f01037ea:	f7 c6 01 00 00 00    	test   $0x1,%esi
f01037f0:	0f 84 b6 00 00 00    	je     f01038ac <env_free+0x13e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f01037f6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01037fc:	89 f0                	mov    %esi,%eax
f01037fe:	c1 e8 0c             	shr    $0xc,%eax
f0103801:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103804:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f010380a:	72 20                	jb     f010382c <env_free+0xbe>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010380c:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103810:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0103817:	f0 
f0103818:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f010381f:	00 
f0103820:	c7 04 24 be 79 10 f0 	movl   $0xf01079be,(%esp)
f0103827:	e8 14 c8 ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010382c:	8b 55 e0             	mov    -0x20(%ebp),%edx
f010382f:	c1 e2 16             	shl    $0x16,%edx
f0103832:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103835:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f010383a:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103841:	01 
f0103842:	74 17                	je     f010385b <env_free+0xed>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103844:	89 d8                	mov    %ebx,%eax
f0103846:	c1 e0 0c             	shl    $0xc,%eax
f0103849:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010384c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103850:	8b 47 60             	mov    0x60(%edi),%eax
f0103853:	89 04 24             	mov    %eax,(%esp)
f0103856:	e8 cb d9 ff ff       	call   f0101226 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010385b:	43                   	inc    %ebx
f010385c:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0103862:	75 d6                	jne    f010383a <env_free+0xcc>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0103864:	8b 47 60             	mov    0x60(%edi),%eax
f0103867:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010386a:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103871:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103874:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f010387a:	72 1c                	jb     f0103898 <env_free+0x12a>
		panic("pa2page called with invalid pa");
f010387c:	c7 44 24 08 30 6e 10 	movl   $0xf0106e30,0x8(%esp)
f0103883:	f0 
f0103884:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010388b:	00 
f010388c:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f0103893:	e8 a8 c7 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103898:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010389b:	c1 e0 03             	shl    $0x3,%eax
f010389e:	03 05 90 2e 22 f0    	add    0xf0222e90,%eax
		page_decref(pa2page(pa));
f01038a4:	89 04 24             	mov    %eax,(%esp)
f01038a7:	e8 96 d7 ff ff       	call   f0101042 <page_decref>
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01038ac:	ff 45 e0             	incl   -0x20(%ebp)
f01038af:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01038b6:	0f 85 1c ff ff ff    	jne    f01037d8 <env_free+0x6a>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f01038bc:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01038bf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01038c4:	77 20                	ja     f01038e6 <env_free+0x178>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01038c6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01038ca:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f01038d1:	f0 
f01038d2:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
f01038d9:	00 
f01038da:	c7 04 24 be 79 10 f0 	movl   $0xf01079be,(%esp)
f01038e1:	e8 5a c7 ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f01038e6:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f01038ed:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01038f2:	c1 e8 0c             	shr    $0xc,%eax
f01038f5:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f01038fb:	72 1c                	jb     f0103919 <env_free+0x1ab>
		panic("pa2page called with invalid pa");
f01038fd:	c7 44 24 08 30 6e 10 	movl   $0xf0106e30,0x8(%esp)
f0103904:	f0 
f0103905:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010390c:	00 
f010390d:	c7 04 24 b8 76 10 f0 	movl   $0xf01076b8,(%esp)
f0103914:	e8 27 c7 ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0103919:	c1 e0 03             	shl    $0x3,%eax
f010391c:	03 05 90 2e 22 f0    	add    0xf0222e90,%eax
	page_decref(pa2page(pa));
f0103922:	89 04 24             	mov    %eax,(%esp)
f0103925:	e8 18 d7 ff ff       	call   f0101042 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010392a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103931:	a1 4c 22 22 f0       	mov    0xf022224c,%eax
f0103936:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103939:	89 3d 4c 22 22 f0    	mov    %edi,0xf022224c
}
f010393f:	83 c4 2c             	add    $0x2c,%esp
f0103942:	5b                   	pop    %ebx
f0103943:	5e                   	pop    %esi
f0103944:	5f                   	pop    %edi
f0103945:	5d                   	pop    %ebp
f0103946:	c3                   	ret    

f0103947 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103947:	55                   	push   %ebp
f0103948:	89 e5                	mov    %esp,%ebp
f010394a:	53                   	push   %ebx
f010394b:	83 ec 14             	sub    $0x14,%esp
f010394e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f0103951:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103955:	75 23                	jne    f010397a <env_destroy+0x33>
f0103957:	e8 d0 27 00 00       	call   f010612c <cpunum>
f010395c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103963:	29 c2                	sub    %eax,%edx
f0103965:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103968:	39 1c 85 28 30 22 f0 	cmp    %ebx,-0xfddcfd8(,%eax,4)
f010396f:	74 09                	je     f010397a <env_destroy+0x33>
		e->env_status = ENV_DYING;
f0103971:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103978:	eb 39                	jmp    f01039b3 <env_destroy+0x6c>
	}

	env_free(e);
f010397a:	89 1c 24             	mov    %ebx,(%esp)
f010397d:	e8 ec fd ff ff       	call   f010376e <env_free>

	if (curenv == e) {
f0103982:	e8 a5 27 00 00       	call   f010612c <cpunum>
f0103987:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010398e:	29 c2                	sub    %eax,%edx
f0103990:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103993:	39 1c 85 28 30 22 f0 	cmp    %ebx,-0xfddcfd8(,%eax,4)
f010399a:	75 17                	jne    f01039b3 <env_destroy+0x6c>
		curenv = NULL;
f010399c:	e8 8b 27 00 00       	call   f010612c <cpunum>
f01039a1:	6b c0 74             	imul   $0x74,%eax,%eax
f01039a4:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f01039ab:	00 00 00 
		sched_yield();
f01039ae:	e8 a3 0f 00 00       	call   f0104956 <sched_yield>
	}
}
f01039b3:	83 c4 14             	add    $0x14,%esp
f01039b6:	5b                   	pop    %ebx
f01039b7:	5d                   	pop    %ebp
f01039b8:	c3                   	ret    

f01039b9 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01039b9:	55                   	push   %ebp
f01039ba:	89 e5                	mov    %esp,%ebp
f01039bc:	53                   	push   %ebx
f01039bd:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01039c0:	e8 67 27 00 00       	call   f010612c <cpunum>
f01039c5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01039cc:	29 c2                	sub    %eax,%edx
f01039ce:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01039d1:	8b 1c 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%ebx
f01039d8:	e8 4f 27 00 00       	call   f010612c <cpunum>
f01039dd:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f01039e0:	8b 65 08             	mov    0x8(%ebp),%esp
f01039e3:	61                   	popa   
f01039e4:	07                   	pop    %es
f01039e5:	1f                   	pop    %ds
f01039e6:	83 c4 08             	add    $0x8,%esp
f01039e9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01039ea:	c7 44 24 08 c9 79 10 	movl   $0xf01079c9,0x8(%esp)
f01039f1:	f0 
f01039f2:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
f01039f9:	00 
f01039fa:	c7 04 24 be 79 10 f0 	movl   $0xf01079be,(%esp)
f0103a01:	e8 3a c6 ff ff       	call   f0100040 <_panic>

f0103a06 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103a06:	55                   	push   %ebp
f0103a07:	89 e5                	mov    %esp,%ebp
f0103a09:	53                   	push   %ebx
f0103a0a:	83 ec 14             	sub    $0x14,%esp
f0103a0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (e != curenv) {
f0103a10:	e8 17 27 00 00       	call   f010612c <cpunum>
f0103a15:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a1c:	29 c2                	sub    %eax,%edx
f0103a1e:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a21:	39 1c 85 28 30 22 f0 	cmp    %ebx,-0xfddcfd8(,%eax,4)
f0103a28:	0f 84 a7 00 00 00    	je     f0103ad5 <env_run+0xcf>
		// Step 1-1:
		if (curenv) {
f0103a2e:	e8 f9 26 00 00       	call   f010612c <cpunum>
f0103a33:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a3a:	29 c2                	sub    %eax,%edx
f0103a3c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a3f:	83 3c 85 28 30 22 f0 	cmpl   $0x0,-0xfddcfd8(,%eax,4)
f0103a46:	00 
f0103a47:	74 29                	je     f0103a72 <env_run+0x6c>
			if (curenv->env_status == ENV_RUNNING)
f0103a49:	e8 de 26 00 00       	call   f010612c <cpunum>
f0103a4e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a51:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103a57:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103a5b:	75 15                	jne    f0103a72 <env_run+0x6c>
				curenv->env_status = ENV_RUNNABLE;
f0103a5d:	e8 ca 26 00 00       	call   f010612c <cpunum>
f0103a62:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a65:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0103a6b:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
		// Step 1-2:
		curenv = e;
f0103a72:	e8 b5 26 00 00       	call   f010612c <cpunum>
f0103a77:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a7e:	29 c2                	sub    %eax,%edx
f0103a80:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a83:	89 1c 85 28 30 22 f0 	mov    %ebx,-0xfddcfd8(,%eax,4)
		// Step 1-3:
		curenv->env_status = ENV_RUNNING;
f0103a8a:	e8 9d 26 00 00       	call   f010612c <cpunum>
f0103a8f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103a96:	29 c2                	sub    %eax,%edx
f0103a98:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103a9b:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0103aa2:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		// Step 1-4:
		curenv->env_runs++;
f0103aa9:	e8 7e 26 00 00       	call   f010612c <cpunum>
f0103aae:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ab5:	29 c2                	sub    %eax,%edx
f0103ab7:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103aba:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0103ac1:	ff 40 58             	incl   0x58(%eax)
		// Step 1-5:
		lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
f0103ac4:	8b 43 60             	mov    0x60(%ebx),%eax
f0103ac7:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f0103acd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103ad2:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0103ad5:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f0103adc:	e8 ad 29 00 00       	call   f010648e <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0103ae1:	f3 90                	pause  
	}
	// Release Lock right before user mode
	unlock_kernel();

	// Step 2:
	env_pop_tf(&(curenv->env_tf));
f0103ae3:	e8 44 26 00 00       	call   f010612c <cpunum>
f0103ae8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103aef:	29 c2                	sub    %eax,%edx
f0103af1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103af4:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0103afb:	89 04 24             	mov    %eax,(%esp)
f0103afe:	e8 b6 fe ff ff       	call   f01039b9 <env_pop_tf>
	...

f0103b04 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103b04:	55                   	push   %ebp
f0103b05:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b07:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b0f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103b10:	b2 71                	mov    $0x71,%dl
f0103b12:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103b13:	0f b6 c0             	movzbl %al,%eax
}
f0103b16:	5d                   	pop    %ebp
f0103b17:	c3                   	ret    

f0103b18 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103b18:	55                   	push   %ebp
f0103b19:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103b1b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103b20:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b23:	ee                   	out    %al,(%dx)
f0103b24:	b2 71                	mov    $0x71,%dl
f0103b26:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b29:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103b2a:	5d                   	pop    %ebp
f0103b2b:	c3                   	ret    

f0103b2c <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103b2c:	55                   	push   %ebp
f0103b2d:	89 e5                	mov    %esp,%ebp
f0103b2f:	56                   	push   %esi
f0103b30:	53                   	push   %ebx
f0103b31:	83 ec 10             	sub    $0x10,%esp
f0103b34:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b37:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103b39:	66 a3 a8 83 12 f0    	mov    %ax,0xf01283a8
	if (!didinit)
f0103b3f:	80 3d 50 22 22 f0 00 	cmpb   $0x0,0xf0222250
f0103b46:	74 51                	je     f0103b99 <irq_setmask_8259A+0x6d>
f0103b48:	ba 21 00 00 00       	mov    $0x21,%edx
f0103b4d:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
f0103b4e:	89 f0                	mov    %esi,%eax
f0103b50:	66 c1 e8 08          	shr    $0x8,%ax
f0103b54:	b2 a1                	mov    $0xa1,%dl
f0103b56:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103b57:	c7 04 24 d5 79 10 f0 	movl   $0xf01079d5,(%esp)
f0103b5e:	e8 e7 00 00 00       	call   f0103c4a <cprintf>
	for (i = 0; i < 16; i++)
f0103b63:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103b68:	0f b7 f6             	movzwl %si,%esi
f0103b6b:	f7 d6                	not    %esi
f0103b6d:	89 f0                	mov    %esi,%eax
f0103b6f:	88 d9                	mov    %bl,%cl
f0103b71:	d3 f8                	sar    %cl,%eax
f0103b73:	a8 01                	test   $0x1,%al
f0103b75:	74 10                	je     f0103b87 <irq_setmask_8259A+0x5b>
			cprintf(" %d", i);
f0103b77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b7b:	c7 04 24 8b 7e 10 f0 	movl   $0xf0107e8b,(%esp)
f0103b82:	e8 c3 00 00 00       	call   f0103c4a <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103b87:	43                   	inc    %ebx
f0103b88:	83 fb 10             	cmp    $0x10,%ebx
f0103b8b:	75 e0                	jne    f0103b6d <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103b8d:	c7 04 24 8c 79 10 f0 	movl   $0xf010798c,(%esp)
f0103b94:	e8 b1 00 00 00       	call   f0103c4a <cprintf>
}
f0103b99:	83 c4 10             	add    $0x10,%esp
f0103b9c:	5b                   	pop    %ebx
f0103b9d:	5e                   	pop    %esi
f0103b9e:	5d                   	pop    %ebp
f0103b9f:	c3                   	ret    

f0103ba0 <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103ba0:	55                   	push   %ebp
f0103ba1:	89 e5                	mov    %esp,%ebp
f0103ba3:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103ba6:	c6 05 50 22 22 f0 01 	movb   $0x1,0xf0222250
f0103bad:	ba 21 00 00 00       	mov    $0x21,%edx
f0103bb2:	b0 ff                	mov    $0xff,%al
f0103bb4:	ee                   	out    %al,(%dx)
f0103bb5:	b2 a1                	mov    $0xa1,%dl
f0103bb7:	ee                   	out    %al,(%dx)
f0103bb8:	b2 20                	mov    $0x20,%dl
f0103bba:	b0 11                	mov    $0x11,%al
f0103bbc:	ee                   	out    %al,(%dx)
f0103bbd:	b2 21                	mov    $0x21,%dl
f0103bbf:	b0 20                	mov    $0x20,%al
f0103bc1:	ee                   	out    %al,(%dx)
f0103bc2:	b0 04                	mov    $0x4,%al
f0103bc4:	ee                   	out    %al,(%dx)
f0103bc5:	b0 03                	mov    $0x3,%al
f0103bc7:	ee                   	out    %al,(%dx)
f0103bc8:	b2 a0                	mov    $0xa0,%dl
f0103bca:	b0 11                	mov    $0x11,%al
f0103bcc:	ee                   	out    %al,(%dx)
f0103bcd:	b2 a1                	mov    $0xa1,%dl
f0103bcf:	b0 28                	mov    $0x28,%al
f0103bd1:	ee                   	out    %al,(%dx)
f0103bd2:	b0 02                	mov    $0x2,%al
f0103bd4:	ee                   	out    %al,(%dx)
f0103bd5:	b0 01                	mov    $0x1,%al
f0103bd7:	ee                   	out    %al,(%dx)
f0103bd8:	b2 20                	mov    $0x20,%dl
f0103bda:	b0 68                	mov    $0x68,%al
f0103bdc:	ee                   	out    %al,(%dx)
f0103bdd:	b0 0a                	mov    $0xa,%al
f0103bdf:	ee                   	out    %al,(%dx)
f0103be0:	b2 a0                	mov    $0xa0,%dl
f0103be2:	b0 68                	mov    $0x68,%al
f0103be4:	ee                   	out    %al,(%dx)
f0103be5:	b0 0a                	mov    $0xa,%al
f0103be7:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103be8:	66 a1 a8 83 12 f0    	mov    0xf01283a8,%ax
f0103bee:	66 83 f8 ff          	cmp    $0xffffffff,%ax
f0103bf2:	74 0b                	je     f0103bff <pic_init+0x5f>
		irq_setmask_8259A(irq_mask_8259A);
f0103bf4:	0f b7 c0             	movzwl %ax,%eax
f0103bf7:	89 04 24             	mov    %eax,(%esp)
f0103bfa:	e8 2d ff ff ff       	call   f0103b2c <irq_setmask_8259A>
}
f0103bff:	c9                   	leave  
f0103c00:	c3                   	ret    
f0103c01:	00 00                	add    %al,(%eax)
	...

f0103c04 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103c04:	55                   	push   %ebp
f0103c05:	89 e5                	mov    %esp,%ebp
f0103c07:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103c0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c0d:	89 04 24             	mov    %eax,(%esp)
f0103c10:	e8 75 cb ff ff       	call   f010078a <cputchar>
	*cnt++;
}
f0103c15:	c9                   	leave  
f0103c16:	c3                   	ret    

f0103c17 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103c17:	55                   	push   %ebp
f0103c18:	89 e5                	mov    %esp,%ebp
f0103c1a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103c1d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103c24:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103c27:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103c2b:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c2e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103c32:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103c35:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c39:	c7 04 24 04 3c 10 f0 	movl   $0xf0103c04,(%esp)
f0103c40:	e8 49 18 00 00       	call   f010548e <vprintfmt>
	return cnt;
}
f0103c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103c48:	c9                   	leave  
f0103c49:	c3                   	ret    

f0103c4a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103c4a:	55                   	push   %ebp
f0103c4b:	89 e5                	mov    %esp,%ebp
f0103c4d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0103c50:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0103c53:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c57:	8b 45 08             	mov    0x8(%ebp),%eax
f0103c5a:	89 04 24             	mov    %eax,(%esp)
f0103c5d:	e8 b5 ff ff ff       	call   f0103c17 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103c62:	c9                   	leave  
f0103c63:	c3                   	ret    

f0103c64 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103c64:	55                   	push   %ebp
f0103c65:	89 e5                	mov    %esp,%ebp
f0103c67:	57                   	push   %edi
f0103c68:	56                   	push   %esi
f0103c69:	53                   	push   %ebx
f0103c6a:	83 ec 0c             	sub    $0xc,%esp
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = (uintptr_t)(percpu_kstacks[cpunum()] + KSTKSIZE);
f0103c6d:	e8 ba 24 00 00       	call   f010612c <cpunum>
f0103c72:	89 c3                	mov    %eax,%ebx
f0103c74:	e8 b3 24 00 00       	call   f010612c <cpunum>
f0103c79:	8d 14 dd 00 00 00 00 	lea    0x0(,%ebx,8),%edx
f0103c80:	29 da                	sub    %ebx,%edx
f0103c82:	8d 14 93             	lea    (%ebx,%edx,4),%edx
f0103c85:	c1 e0 0f             	shl    $0xf,%eax
f0103c88:	8d 80 00 c0 22 f0    	lea    -0xfdd4000(%eax),%eax
f0103c8e:	89 04 95 30 30 22 f0 	mov    %eax,-0xfddcfd0(,%edx,4)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f0103c95:	e8 92 24 00 00       	call   f010612c <cpunum>
f0103c9a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103ca1:	29 c2                	sub    %eax,%edx
f0103ca3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103ca6:	66 c7 04 85 34 30 22 	movw   $0x10,-0xfddcfcc(,%eax,4)
f0103cad:	f0 10 00 
	// thiscpu->cpu_ts.ts_iomb = sizeof(struct Taskstate) * (cpunum() + 1);

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cpunum()] = SEG16(STS_T32A, (uint32_t) (&(thiscpu->cpu_ts)),
f0103cb0:	e8 77 24 00 00       	call   f010612c <cpunum>
f0103cb5:	8d 58 05             	lea    0x5(%eax),%ebx
f0103cb8:	e8 6f 24 00 00       	call   f010612c <cpunum>
f0103cbd:	89 c6                	mov    %eax,%esi
f0103cbf:	e8 68 24 00 00       	call   f010612c <cpunum>
f0103cc4:	89 c7                	mov    %eax,%edi
f0103cc6:	e8 61 24 00 00       	call   f010612c <cpunum>
f0103ccb:	66 c7 04 dd 40 83 12 	movw   $0x67,-0xfed7cc0(,%ebx,8)
f0103cd2:	f0 67 00 
f0103cd5:	8d 14 f5 00 00 00 00 	lea    0x0(,%esi,8),%edx
f0103cdc:	29 f2                	sub    %esi,%edx
f0103cde:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0103ce1:	8d 14 95 2c 30 22 f0 	lea    -0xfddcfd4(,%edx,4),%edx
f0103ce8:	66 89 14 dd 42 83 12 	mov    %dx,-0xfed7cbe(,%ebx,8)
f0103cef:	f0 
f0103cf0:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f0103cf7:	29 fa                	sub    %edi,%edx
f0103cf9:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0103cfc:	8d 14 95 2c 30 22 f0 	lea    -0xfddcfd4(,%edx,4),%edx
f0103d03:	c1 ea 10             	shr    $0x10,%edx
f0103d06:	88 14 dd 44 83 12 f0 	mov    %dl,-0xfed7cbc(,%ebx,8)
f0103d0d:	c6 04 dd 45 83 12 f0 	movb   $0x99,-0xfed7cbb(,%ebx,8)
f0103d14:	99 
f0103d15:	c6 04 dd 46 83 12 f0 	movb   $0x40,-0xfed7cba(,%ebx,8)
f0103d1c:	40 
f0103d1d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0103d24:	29 c2                	sub    %eax,%edx
f0103d26:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0103d29:	8d 04 85 2c 30 22 f0 	lea    -0xfddcfd4(,%eax,4),%eax
f0103d30:	c1 e8 18             	shr    $0x18,%eax
f0103d33:	88 04 dd 47 83 12 f0 	mov    %al,-0xfed7cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + cpunum()].sd_s = 0;
f0103d3a:	e8 ed 23 00 00       	call   f010612c <cpunum>
f0103d3f:	80 24 c5 6d 83 12 f0 	andb   $0xef,-0xfed7c93(,%eax,8)
f0103d46:	ef 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + (cpunum() << 3));
f0103d47:	e8 e0 23 00 00       	call   f010612c <cpunum>
f0103d4c:	8d 04 c5 28 00 00 00 	lea    0x28(,%eax,8),%eax
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103d53:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0103d56:	b8 ac 83 12 f0       	mov    $0xf01283ac,%eax
f0103d5b:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103d5e:	83 c4 0c             	add    $0xc,%esp
f0103d61:	5b                   	pop    %ebx
f0103d62:	5e                   	pop    %esi
f0103d63:	5f                   	pop    %edi
f0103d64:	5d                   	pop    %ebp
f0103d65:	c3                   	ret    

f0103d66 <trap_init>:
}


void
trap_init(void)
{
f0103d66:	55                   	push   %ebp
f0103d67:	89 e5                	mov    %esp,%ebp
f0103d69:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[0], 0, GD_KT, T_DIVIDE_handler, 0);			// divide error
f0103d6c:	b8 64 47 10 f0       	mov    $0xf0104764,%eax
f0103d71:	66 a3 60 22 22 f0    	mov    %ax,0xf0222260
f0103d77:	66 c7 05 62 22 22 f0 	movw   $0x8,0xf0222262
f0103d7e:	08 00 
f0103d80:	c6 05 64 22 22 f0 00 	movb   $0x0,0xf0222264
f0103d87:	c6 05 65 22 22 f0 8e 	movb   $0x8e,0xf0222265
f0103d8e:	c1 e8 10             	shr    $0x10,%eax
f0103d91:	66 a3 66 22 22 f0    	mov    %ax,0xf0222266
	SETGATE(idt[1], 0, GD_KT, T_DEBUG_handler, 0);			// debug exception
f0103d97:	b8 6e 47 10 f0       	mov    $0xf010476e,%eax
f0103d9c:	66 a3 68 22 22 f0    	mov    %ax,0xf0222268
f0103da2:	66 c7 05 6a 22 22 f0 	movw   $0x8,0xf022226a
f0103da9:	08 00 
f0103dab:	c6 05 6c 22 22 f0 00 	movb   $0x0,0xf022226c
f0103db2:	c6 05 6d 22 22 f0 8e 	movb   $0x8e,0xf022226d
f0103db9:	c1 e8 10             	shr    $0x10,%eax
f0103dbc:	66 a3 6e 22 22 f0    	mov    %ax,0xf022226e
	SETGATE(idt[2], 0, GD_KT, T_NMI_handler, 0);			// non-maskable interrupt
f0103dc2:	b8 78 47 10 f0       	mov    $0xf0104778,%eax
f0103dc7:	66 a3 70 22 22 f0    	mov    %ax,0xf0222270
f0103dcd:	66 c7 05 72 22 22 f0 	movw   $0x8,0xf0222272
f0103dd4:	08 00 
f0103dd6:	c6 05 74 22 22 f0 00 	movb   $0x0,0xf0222274
f0103ddd:	c6 05 75 22 22 f0 8e 	movb   $0x8e,0xf0222275
f0103de4:	c1 e8 10             	shr    $0x10,%eax
f0103de7:	66 a3 76 22 22 f0    	mov    %ax,0xf0222276
	SETGATE(idt[3], 0, GD_KT, T_BRKPT_handler, 3);			// breakpoint
f0103ded:	b8 82 47 10 f0       	mov    $0xf0104782,%eax
f0103df2:	66 a3 78 22 22 f0    	mov    %ax,0xf0222278
f0103df8:	66 c7 05 7a 22 22 f0 	movw   $0x8,0xf022227a
f0103dff:	08 00 
f0103e01:	c6 05 7c 22 22 f0 00 	movb   $0x0,0xf022227c
f0103e08:	c6 05 7d 22 22 f0 ee 	movb   $0xee,0xf022227d
f0103e0f:	c1 e8 10             	shr    $0x10,%eax
f0103e12:	66 a3 7e 22 22 f0    	mov    %ax,0xf022227e
	SETGATE(idt[4], 0, GD_KT, T_OFLOW_handler, 0);			// overflow
f0103e18:	b8 8c 47 10 f0       	mov    $0xf010478c,%eax
f0103e1d:	66 a3 80 22 22 f0    	mov    %ax,0xf0222280
f0103e23:	66 c7 05 82 22 22 f0 	movw   $0x8,0xf0222282
f0103e2a:	08 00 
f0103e2c:	c6 05 84 22 22 f0 00 	movb   $0x0,0xf0222284
f0103e33:	c6 05 85 22 22 f0 8e 	movb   $0x8e,0xf0222285
f0103e3a:	c1 e8 10             	shr    $0x10,%eax
f0103e3d:	66 a3 86 22 22 f0    	mov    %ax,0xf0222286
	SETGATE(idt[5], 0, GD_KT, T_BOUND_handler, 0);			// bounds check
f0103e43:	b8 96 47 10 f0       	mov    $0xf0104796,%eax
f0103e48:	66 a3 88 22 22 f0    	mov    %ax,0xf0222288
f0103e4e:	66 c7 05 8a 22 22 f0 	movw   $0x8,0xf022228a
f0103e55:	08 00 
f0103e57:	c6 05 8c 22 22 f0 00 	movb   $0x0,0xf022228c
f0103e5e:	c6 05 8d 22 22 f0 8e 	movb   $0x8e,0xf022228d
f0103e65:	c1 e8 10             	shr    $0x10,%eax
f0103e68:	66 a3 8e 22 22 f0    	mov    %ax,0xf022228e
	SETGATE(idt[6], 0, GD_KT, T_ILLOP_handler, 0);			// illegal opcode
f0103e6e:	b8 a0 47 10 f0       	mov    $0xf01047a0,%eax
f0103e73:	66 a3 90 22 22 f0    	mov    %ax,0xf0222290
f0103e79:	66 c7 05 92 22 22 f0 	movw   $0x8,0xf0222292
f0103e80:	08 00 
f0103e82:	c6 05 94 22 22 f0 00 	movb   $0x0,0xf0222294
f0103e89:	c6 05 95 22 22 f0 8e 	movb   $0x8e,0xf0222295
f0103e90:	c1 e8 10             	shr    $0x10,%eax
f0103e93:	66 a3 96 22 22 f0    	mov    %ax,0xf0222296
	SETGATE(idt[7], 0, GD_KT, T_DEVICE_handler, 0);			// device not available
f0103e99:	b8 aa 47 10 f0       	mov    $0xf01047aa,%eax
f0103e9e:	66 a3 98 22 22 f0    	mov    %ax,0xf0222298
f0103ea4:	66 c7 05 9a 22 22 f0 	movw   $0x8,0xf022229a
f0103eab:	08 00 
f0103ead:	c6 05 9c 22 22 f0 00 	movb   $0x0,0xf022229c
f0103eb4:	c6 05 9d 22 22 f0 8e 	movb   $0x8e,0xf022229d
f0103ebb:	c1 e8 10             	shr    $0x10,%eax
f0103ebe:	66 a3 9e 22 22 f0    	mov    %ax,0xf022229e
	SETGATE(idt[8], 0, GD_KT, T_DBLFLT_handler, 0);			// double fault
f0103ec4:	b8 b4 47 10 f0       	mov    $0xf01047b4,%eax
f0103ec9:	66 a3 a0 22 22 f0    	mov    %ax,0xf02222a0
f0103ecf:	66 c7 05 a2 22 22 f0 	movw   $0x8,0xf02222a2
f0103ed6:	08 00 
f0103ed8:	c6 05 a4 22 22 f0 00 	movb   $0x0,0xf02222a4
f0103edf:	c6 05 a5 22 22 f0 8e 	movb   $0x8e,0xf02222a5
f0103ee6:	c1 e8 10             	shr    $0x10,%eax
f0103ee9:	66 a3 a6 22 22 f0    	mov    %ax,0xf02222a6

	SETGATE(idt[10], 0, GD_KT, T_TSS_handler, 0);			// invalid task switch segment
f0103eef:	b8 be 47 10 f0       	mov    $0xf01047be,%eax
f0103ef4:	66 a3 b0 22 22 f0    	mov    %ax,0xf02222b0
f0103efa:	66 c7 05 b2 22 22 f0 	movw   $0x8,0xf02222b2
f0103f01:	08 00 
f0103f03:	c6 05 b4 22 22 f0 00 	movb   $0x0,0xf02222b4
f0103f0a:	c6 05 b5 22 22 f0 8e 	movb   $0x8e,0xf02222b5
f0103f11:	c1 e8 10             	shr    $0x10,%eax
f0103f14:	66 a3 b6 22 22 f0    	mov    %ax,0xf02222b6
	SETGATE(idt[11], 0, GD_KT, T_SEGNP_handler, 0);			// segment not present
f0103f1a:	b8 c8 47 10 f0       	mov    $0xf01047c8,%eax
f0103f1f:	66 a3 b8 22 22 f0    	mov    %ax,0xf02222b8
f0103f25:	66 c7 05 ba 22 22 f0 	movw   $0x8,0xf02222ba
f0103f2c:	08 00 
f0103f2e:	c6 05 bc 22 22 f0 00 	movb   $0x0,0xf02222bc
f0103f35:	c6 05 bd 22 22 f0 8e 	movb   $0x8e,0xf02222bd
f0103f3c:	c1 e8 10             	shr    $0x10,%eax
f0103f3f:	66 a3 be 22 22 f0    	mov    %ax,0xf02222be
	SETGATE(idt[12], 0, GD_KT, T_STACK_handler, 0);			// stack exception
f0103f45:	b8 d2 47 10 f0       	mov    $0xf01047d2,%eax
f0103f4a:	66 a3 c0 22 22 f0    	mov    %ax,0xf02222c0
f0103f50:	66 c7 05 c2 22 22 f0 	movw   $0x8,0xf02222c2
f0103f57:	08 00 
f0103f59:	c6 05 c4 22 22 f0 00 	movb   $0x0,0xf02222c4
f0103f60:	c6 05 c5 22 22 f0 8e 	movb   $0x8e,0xf02222c5
f0103f67:	c1 e8 10             	shr    $0x10,%eax
f0103f6a:	66 a3 c6 22 22 f0    	mov    %ax,0xf02222c6
	SETGATE(idt[13], 0, GD_KT, T_GPFLT_handler, 0);			// general protection fault
f0103f70:	b8 dc 47 10 f0       	mov    $0xf01047dc,%eax
f0103f75:	66 a3 c8 22 22 f0    	mov    %ax,0xf02222c8
f0103f7b:	66 c7 05 ca 22 22 f0 	movw   $0x8,0xf02222ca
f0103f82:	08 00 
f0103f84:	c6 05 cc 22 22 f0 00 	movb   $0x0,0xf02222cc
f0103f8b:	c6 05 cd 22 22 f0 8e 	movb   $0x8e,0xf02222cd
f0103f92:	c1 e8 10             	shr    $0x10,%eax
f0103f95:	66 a3 ce 22 22 f0    	mov    %ax,0xf02222ce
	SETGATE(idt[14], 0, GD_KT, T_PGFLT_handler, 0);			// page fault
f0103f9b:	b8 e4 47 10 f0       	mov    $0xf01047e4,%eax
f0103fa0:	66 a3 d0 22 22 f0    	mov    %ax,0xf02222d0
f0103fa6:	66 c7 05 d2 22 22 f0 	movw   $0x8,0xf02222d2
f0103fad:	08 00 
f0103faf:	c6 05 d4 22 22 f0 00 	movb   $0x0,0xf02222d4
f0103fb6:	c6 05 d5 22 22 f0 8e 	movb   $0x8e,0xf02222d5
f0103fbd:	c1 e8 10             	shr    $0x10,%eax
f0103fc0:	66 a3 d6 22 22 f0    	mov    %ax,0xf02222d6

	SETGATE(idt[16], 0, GD_KT, T_FPERR_handler, 0);			// floating point error
f0103fc6:	b8 ec 47 10 f0       	mov    $0xf01047ec,%eax
f0103fcb:	66 a3 e0 22 22 f0    	mov    %ax,0xf02222e0
f0103fd1:	66 c7 05 e2 22 22 f0 	movw   $0x8,0xf02222e2
f0103fd8:	08 00 
f0103fda:	c6 05 e4 22 22 f0 00 	movb   $0x0,0xf02222e4
f0103fe1:	c6 05 e5 22 22 f0 8e 	movb   $0x8e,0xf02222e5
f0103fe8:	c1 e8 10             	shr    $0x10,%eax
f0103feb:	66 a3 e6 22 22 f0    	mov    %ax,0xf02222e6
	SETGATE(idt[17], 0, GD_KT, T_ALIGN_handler, 0);			// aligment check
f0103ff1:	b8 f6 47 10 f0       	mov    $0xf01047f6,%eax
f0103ff6:	66 a3 e8 22 22 f0    	mov    %ax,0xf02222e8
f0103ffc:	66 c7 05 ea 22 22 f0 	movw   $0x8,0xf02222ea
f0104003:	08 00 
f0104005:	c6 05 ec 22 22 f0 00 	movb   $0x0,0xf02222ec
f010400c:	c6 05 ed 22 22 f0 8e 	movb   $0x8e,0xf02222ed
f0104013:	c1 e8 10             	shr    $0x10,%eax
f0104016:	66 a3 ee 22 22 f0    	mov    %ax,0xf02222ee
	SETGATE(idt[18], 0, GD_KT, T_MCHK_handler, 0);			// machine check
f010401c:	b8 00 48 10 f0       	mov    $0xf0104800,%eax
f0104021:	66 a3 f0 22 22 f0    	mov    %ax,0xf02222f0
f0104027:	66 c7 05 f2 22 22 f0 	movw   $0x8,0xf02222f2
f010402e:	08 00 
f0104030:	c6 05 f4 22 22 f0 00 	movb   $0x0,0xf02222f4
f0104037:	c6 05 f5 22 22 f0 8e 	movb   $0x8e,0xf02222f5
f010403e:	c1 e8 10             	shr    $0x10,%eax
f0104041:	66 a3 f6 22 22 f0    	mov    %ax,0xf02222f6
	SETGATE(idt[19], 0, GD_KT, T_SIMDERR_handler, 0);		// SIMD floating point error
f0104047:	b8 0a 48 10 f0       	mov    $0xf010480a,%eax
f010404c:	66 a3 f8 22 22 f0    	mov    %ax,0xf02222f8
f0104052:	66 c7 05 fa 22 22 f0 	movw   $0x8,0xf02222fa
f0104059:	08 00 
f010405b:	c6 05 fc 22 22 f0 00 	movb   $0x0,0xf02222fc
f0104062:	c6 05 fd 22 22 f0 8e 	movb   $0x8e,0xf02222fd
f0104069:	c1 e8 10             	shr    $0x10,%eax
f010406c:	66 a3 fe 22 22 f0    	mov    %ax,0xf02222fe
	// Add for lab 4 exercise 7
	SETGATE(idt[48], 0, GD_KT, T_SYSCALL_handler, 3);		// System call handler
f0104072:	b8 14 48 10 f0       	mov    $0xf0104814,%eax
f0104077:	66 a3 e0 23 22 f0    	mov    %ax,0xf02223e0
f010407d:	66 c7 05 e2 23 22 f0 	movw   $0x8,0xf02223e2
f0104084:	08 00 
f0104086:	c6 05 e4 23 22 f0 00 	movb   $0x0,0xf02223e4
f010408d:	c6 05 e5 23 22 f0 ee 	movb   $0xee,0xf02223e5
f0104094:	c1 e8 10             	shr    $0x10,%eax
f0104097:	66 a3 e6 23 22 f0    	mov    %ax,0xf02223e6
	// Add for lab 4 exercise 13
	SETGATE(idt[32], 0, GD_KT, IRQ_TIMER_handler, 3);		// IRQ_TIMER
f010409d:	b8 1e 48 10 f0       	mov    $0xf010481e,%eax
f01040a2:	66 a3 60 23 22 f0    	mov    %ax,0xf0222360
f01040a8:	66 c7 05 62 23 22 f0 	movw   $0x8,0xf0222362
f01040af:	08 00 
f01040b1:	c6 05 64 23 22 f0 00 	movb   $0x0,0xf0222364
f01040b8:	c6 05 65 23 22 f0 ee 	movb   $0xee,0xf0222365
f01040bf:	c1 e8 10             	shr    $0x10,%eax
f01040c2:	66 a3 66 23 22 f0    	mov    %ax,0xf0222366
	SETGATE(idt[33], 0, GD_KT, IRQ_KBD_handler, 3);		// IRQ_TIMER
f01040c8:	b8 28 48 10 f0       	mov    $0xf0104828,%eax
f01040cd:	66 a3 68 23 22 f0    	mov    %ax,0xf0222368
f01040d3:	66 c7 05 6a 23 22 f0 	movw   $0x8,0xf022236a
f01040da:	08 00 
f01040dc:	c6 05 6c 23 22 f0 00 	movb   $0x0,0xf022236c
f01040e3:	c6 05 6d 23 22 f0 ee 	movb   $0xee,0xf022236d
f01040ea:	c1 e8 10             	shr    $0x10,%eax
f01040ed:	66 a3 6e 23 22 f0    	mov    %ax,0xf022236e
	SETGATE(idt[36], 0, GD_KT, IRQ_SERIAL_handler, 3);		// IRQ_TIMER
f01040f3:	b8 32 48 10 f0       	mov    $0xf0104832,%eax
f01040f8:	66 a3 80 23 22 f0    	mov    %ax,0xf0222380
f01040fe:	66 c7 05 82 23 22 f0 	movw   $0x8,0xf0222382
f0104105:	08 00 
f0104107:	c6 05 84 23 22 f0 00 	movb   $0x0,0xf0222384
f010410e:	c6 05 85 23 22 f0 ee 	movb   $0xee,0xf0222385
f0104115:	c1 e8 10             	shr    $0x10,%eax
f0104118:	66 a3 86 23 22 f0    	mov    %ax,0xf0222386
	SETGATE(idt[39], 0, GD_KT, IRQ_SPURIOUS_handler, 3);		// IRQ_TIMER
f010411e:	b8 3c 48 10 f0       	mov    $0xf010483c,%eax
f0104123:	66 a3 98 23 22 f0    	mov    %ax,0xf0222398
f0104129:	66 c7 05 9a 23 22 f0 	movw   $0x8,0xf022239a
f0104130:	08 00 
f0104132:	c6 05 9c 23 22 f0 00 	movb   $0x0,0xf022239c
f0104139:	c6 05 9d 23 22 f0 ee 	movb   $0xee,0xf022239d
f0104140:	c1 e8 10             	shr    $0x10,%eax
f0104143:	66 a3 9e 23 22 f0    	mov    %ax,0xf022239e
	SETGATE(idt[46], 0, GD_KT, IRQ_IDE_handler, 3);		// IRQ_TIMER
f0104149:	b8 46 48 10 f0       	mov    $0xf0104846,%eax
f010414e:	66 a3 d0 23 22 f0    	mov    %ax,0xf02223d0
f0104154:	66 c7 05 d2 23 22 f0 	movw   $0x8,0xf02223d2
f010415b:	08 00 
f010415d:	c6 05 d4 23 22 f0 00 	movb   $0x0,0xf02223d4
f0104164:	c6 05 d5 23 22 f0 ee 	movb   $0xee,0xf02223d5
f010416b:	c1 e8 10             	shr    $0x10,%eax
f010416e:	66 a3 d6 23 22 f0    	mov    %ax,0xf02223d6

	// Per-CPU setup 
	trap_init_percpu();
f0104174:	e8 eb fa ff ff       	call   f0103c64 <trap_init_percpu>
}
f0104179:	c9                   	leave  
f010417a:	c3                   	ret    

f010417b <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f010417b:	55                   	push   %ebp
f010417c:	89 e5                	mov    %esp,%ebp
f010417e:	53                   	push   %ebx
f010417f:	83 ec 14             	sub    $0x14,%esp
f0104182:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104185:	8b 03                	mov    (%ebx),%eax
f0104187:	89 44 24 04          	mov    %eax,0x4(%esp)
f010418b:	c7 04 24 e9 79 10 f0 	movl   $0xf01079e9,(%esp)
f0104192:	e8 b3 fa ff ff       	call   f0103c4a <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104197:	8b 43 04             	mov    0x4(%ebx),%eax
f010419a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010419e:	c7 04 24 f8 79 10 f0 	movl   $0xf01079f8,(%esp)
f01041a5:	e8 a0 fa ff ff       	call   f0103c4a <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01041aa:	8b 43 08             	mov    0x8(%ebx),%eax
f01041ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041b1:	c7 04 24 07 7a 10 f0 	movl   $0xf0107a07,(%esp)
f01041b8:	e8 8d fa ff ff       	call   f0103c4a <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01041bd:	8b 43 0c             	mov    0xc(%ebx),%eax
f01041c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041c4:	c7 04 24 16 7a 10 f0 	movl   $0xf0107a16,(%esp)
f01041cb:	e8 7a fa ff ff       	call   f0103c4a <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01041d0:	8b 43 10             	mov    0x10(%ebx),%eax
f01041d3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041d7:	c7 04 24 25 7a 10 f0 	movl   $0xf0107a25,(%esp)
f01041de:	e8 67 fa ff ff       	call   f0103c4a <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01041e3:	8b 43 14             	mov    0x14(%ebx),%eax
f01041e6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041ea:	c7 04 24 34 7a 10 f0 	movl   $0xf0107a34,(%esp)
f01041f1:	e8 54 fa ff ff       	call   f0103c4a <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01041f6:	8b 43 18             	mov    0x18(%ebx),%eax
f01041f9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01041fd:	c7 04 24 43 7a 10 f0 	movl   $0xf0107a43,(%esp)
f0104204:	e8 41 fa ff ff       	call   f0103c4a <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104209:	8b 43 1c             	mov    0x1c(%ebx),%eax
f010420c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104210:	c7 04 24 52 7a 10 f0 	movl   $0xf0107a52,(%esp)
f0104217:	e8 2e fa ff ff       	call   f0103c4a <cprintf>
}
f010421c:	83 c4 14             	add    $0x14,%esp
f010421f:	5b                   	pop    %ebx
f0104220:	5d                   	pop    %ebp
f0104221:	c3                   	ret    

f0104222 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0104222:	55                   	push   %ebp
f0104223:	89 e5                	mov    %esp,%ebp
f0104225:	53                   	push   %ebx
f0104226:	83 ec 14             	sub    $0x14,%esp
f0104229:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f010422c:	e8 fb 1e 00 00       	call   f010612c <cpunum>
f0104231:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104235:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104239:	c7 04 24 b6 7a 10 f0 	movl   $0xf0107ab6,(%esp)
f0104240:	e8 05 fa ff ff       	call   f0103c4a <cprintf>
	print_regs(&tf->tf_regs);
f0104245:	89 1c 24             	mov    %ebx,(%esp)
f0104248:	e8 2e ff ff ff       	call   f010417b <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f010424d:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0104251:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104255:	c7 04 24 d4 7a 10 f0 	movl   $0xf0107ad4,(%esp)
f010425c:	e8 e9 f9 ff ff       	call   f0103c4a <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0104261:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0104265:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104269:	c7 04 24 e7 7a 10 f0 	movl   $0xf0107ae7,(%esp)
f0104270:	e8 d5 f9 ff ff       	call   f0103c4a <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104275:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0104278:	83 f8 13             	cmp    $0x13,%eax
f010427b:	77 09                	ja     f0104286 <print_trapframe+0x64>
		return excnames[trapno];
f010427d:	8b 14 85 80 7d 10 f0 	mov    -0xfef8280(,%eax,4),%edx
f0104284:	eb 20                	jmp    f01042a6 <print_trapframe+0x84>
	if (trapno == T_SYSCALL)
f0104286:	83 f8 30             	cmp    $0x30,%eax
f0104289:	74 0f                	je     f010429a <print_trapframe+0x78>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010428b:	8d 50 e0             	lea    -0x20(%eax),%edx
f010428e:	83 fa 0f             	cmp    $0xf,%edx
f0104291:	77 0e                	ja     f01042a1 <print_trapframe+0x7f>
		return "Hardware Interrupt";
f0104293:	ba 6d 7a 10 f0       	mov    $0xf0107a6d,%edx
f0104298:	eb 0c                	jmp    f01042a6 <print_trapframe+0x84>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f010429a:	ba 61 7a 10 f0       	mov    $0xf0107a61,%edx
f010429f:	eb 05                	jmp    f01042a6 <print_trapframe+0x84>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
		return "Hardware Interrupt";
	return "(unknown trap)";
f01042a1:	ba 80 7a 10 f0       	mov    $0xf0107a80,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01042a6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01042aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042ae:	c7 04 24 fa 7a 10 f0 	movl   $0xf0107afa,(%esp)
f01042b5:	e8 90 f9 ff ff       	call   f0103c4a <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01042ba:	3b 1d 60 2a 22 f0    	cmp    0xf0222a60,%ebx
f01042c0:	75 19                	jne    f01042db <print_trapframe+0xb9>
f01042c2:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01042c6:	75 13                	jne    f01042db <print_trapframe+0xb9>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f01042c8:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f01042cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042cf:	c7 04 24 0c 7b 10 f0 	movl   $0xf0107b0c,(%esp)
f01042d6:	e8 6f f9 ff ff       	call   f0103c4a <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f01042db:	8b 43 2c             	mov    0x2c(%ebx),%eax
f01042de:	89 44 24 04          	mov    %eax,0x4(%esp)
f01042e2:	c7 04 24 1b 7b 10 f0 	movl   $0xf0107b1b,(%esp)
f01042e9:	e8 5c f9 ff ff       	call   f0103c4a <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01042ee:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01042f2:	75 4d                	jne    f0104341 <print_trapframe+0x11f>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01042f4:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01042f7:	a8 01                	test   $0x1,%al
f01042f9:	74 07                	je     f0104302 <print_trapframe+0xe0>
f01042fb:	b9 8f 7a 10 f0       	mov    $0xf0107a8f,%ecx
f0104300:	eb 05                	jmp    f0104307 <print_trapframe+0xe5>
f0104302:	b9 9a 7a 10 f0       	mov    $0xf0107a9a,%ecx
f0104307:	a8 02                	test   $0x2,%al
f0104309:	74 07                	je     f0104312 <print_trapframe+0xf0>
f010430b:	ba a6 7a 10 f0       	mov    $0xf0107aa6,%edx
f0104310:	eb 05                	jmp    f0104317 <print_trapframe+0xf5>
f0104312:	ba ac 7a 10 f0       	mov    $0xf0107aac,%edx
f0104317:	a8 04                	test   $0x4,%al
f0104319:	74 07                	je     f0104322 <print_trapframe+0x100>
f010431b:	b8 b1 7a 10 f0       	mov    $0xf0107ab1,%eax
f0104320:	eb 05                	jmp    f0104327 <print_trapframe+0x105>
f0104322:	b8 fe 7b 10 f0       	mov    $0xf0107bfe,%eax
f0104327:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010432b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010432f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104333:	c7 04 24 29 7b 10 f0 	movl   $0xf0107b29,(%esp)
f010433a:	e8 0b f9 ff ff       	call   f0103c4a <cprintf>
f010433f:	eb 0c                	jmp    f010434d <print_trapframe+0x12b>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0104341:	c7 04 24 8c 79 10 f0 	movl   $0xf010798c,(%esp)
f0104348:	e8 fd f8 ff ff       	call   f0103c4a <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010434d:	8b 43 30             	mov    0x30(%ebx),%eax
f0104350:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104354:	c7 04 24 38 7b 10 f0 	movl   $0xf0107b38,(%esp)
f010435b:	e8 ea f8 ff ff       	call   f0103c4a <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0104360:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0104364:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104368:	c7 04 24 47 7b 10 f0 	movl   $0xf0107b47,(%esp)
f010436f:	e8 d6 f8 ff ff       	call   f0103c4a <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0104374:	8b 43 38             	mov    0x38(%ebx),%eax
f0104377:	89 44 24 04          	mov    %eax,0x4(%esp)
f010437b:	c7 04 24 5a 7b 10 f0 	movl   $0xf0107b5a,(%esp)
f0104382:	e8 c3 f8 ff ff       	call   f0103c4a <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0104387:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010438b:	74 27                	je     f01043b4 <print_trapframe+0x192>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010438d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104390:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104394:	c7 04 24 69 7b 10 f0 	movl   $0xf0107b69,(%esp)
f010439b:	e8 aa f8 ff ff       	call   f0103c4a <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01043a0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01043a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043a8:	c7 04 24 78 7b 10 f0 	movl   $0xf0107b78,(%esp)
f01043af:	e8 96 f8 ff ff       	call   f0103c4a <cprintf>
	}
}
f01043b4:	83 c4 14             	add    $0x14,%esp
f01043b7:	5b                   	pop    %ebx
f01043b8:	5d                   	pop    %ebp
f01043b9:	c3                   	ret    

f01043ba <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01043ba:	55                   	push   %ebp
f01043bb:	89 e5                	mov    %esp,%ebp
f01043bd:	57                   	push   %edi
f01043be:	56                   	push   %esi
f01043bf:	53                   	push   %ebx
f01043c0:	83 ec 1c             	sub    $0x1c,%esp
f01043c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01043c6:	0f 20 d6             	mov    %cr2,%esi

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	// Determine whether in kernel mode
	if (tf->tf_cs == GD_KT) {
f01043c9:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f01043ce:	75 1c                	jne    f01043ec <page_fault_handler+0x32>
		panic("Page fault from kernel\n");
f01043d0:	c7 44 24 08 8b 7b 10 	movl   $0xf0107b8b,0x8(%esp)
f01043d7:	f0 
f01043d8:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f01043df:	00 
f01043e0:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f01043e7:	e8 54 bc ff ff       	call   f0100040 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	struct UTrapframe *utf;
	// If there is no upcall function
	if (curenv->env_pgfault_upcall) {
f01043ec:	e8 3b 1d 00 00       	call   f010612c <cpunum>
f01043f1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01043f8:	29 c2                	sub    %eax,%edx
f01043fa:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01043fd:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104404:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104408:	0f 84 b5 00 00 00    	je     f01044c3 <page_fault_handler+0x109>
		// Determine whether the user process is running in exception stack or normal stack. 
		// If yes, then we need to initialize UTF right under the current tf_esp. Otherwise, 
		// we just set it to the top of UXSTACKTOP
		if (tf->tf_esp < USTACKTOP) {
f010440e:	8b 43 3c             	mov    0x3c(%ebx),%eax
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
f0104411:	bf cc ff bf ee       	mov    $0xeebfffcc,%edi
	// If there is no upcall function
	if (curenv->env_pgfault_upcall) {
		// Determine whether the user process is running in exception stack or normal stack. 
		// If yes, then we need to initialize UTF right under the current tf_esp. Otherwise, 
		// we just set it to the top of UXSTACKTOP
		if (tf->tf_esp < USTACKTOP) {
f0104416:	3d ff df bf ee       	cmp    $0xeebfdfff,%eax
f010441b:	76 03                	jbe    f0104420 <page_fault_handler+0x66>
			utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
		}
		else {
			// Leave a 32-bit padding for pushing return address
			utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f010441d:	8d 78 c8             	lea    -0x38(%eax),%edi
		}
		// Check whether current stack is valid or overflowed, the reason of test it by using
		// (void *)(utf) instead of (void *)(UXSTACKTOP - PGSIZE) is to fulfill the requirement 
		// of grading script. Otherwise I cannot get full mark on it.
		user_mem_assert(curenv, (void *)(utf), (UXSTACKTOP - (uintptr_t)utf), PTE_W);
f0104420:	e8 07 1d 00 00       	call   f010612c <cpunum>
f0104425:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010442c:	00 
f010442d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0104432:	29 fa                	sub    %edi,%edx
f0104434:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104438:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010443c:	6b c0 74             	imul   $0x74,%eax,%eax
f010443f:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104445:	89 04 24             	mov    %eax,(%esp)
f0104448:	e8 e0 ef ff ff       	call   f010342d <user_mem_assert>
		// Push all information for trapframe
		utf->utf_esp = tf->tf_esp;
f010444d:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104450:	89 47 30             	mov    %eax,0x30(%edi)
		utf->utf_eflags = tf->tf_eflags;
f0104453:	8b 43 38             	mov    0x38(%ebx),%eax
f0104456:	89 47 2c             	mov    %eax,0x2c(%edi)
		utf->utf_eip = tf->tf_eip;
f0104459:	8b 43 30             	mov    0x30(%ebx),%eax
f010445c:	89 47 28             	mov    %eax,0x28(%edi)
		utf->utf_regs.reg_eax = tf->tf_regs.reg_eax;
f010445f:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104462:	89 47 24             	mov    %eax,0x24(%edi)
		utf->utf_regs.reg_ecx = tf->tf_regs.reg_ecx;
f0104465:	8b 43 18             	mov    0x18(%ebx),%eax
f0104468:	89 47 20             	mov    %eax,0x20(%edi)
		utf->utf_regs.reg_edx = tf->tf_regs.reg_edx;
f010446b:	8b 43 14             	mov    0x14(%ebx),%eax
f010446e:	89 47 1c             	mov    %eax,0x1c(%edi)
		utf->utf_regs.reg_ebx = tf->tf_regs.reg_ebx;
f0104471:	8b 43 10             	mov    0x10(%ebx),%eax
f0104474:	89 47 18             	mov    %eax,0x18(%edi)
		utf->utf_regs.reg_oesp = tf->tf_regs.reg_oesp;
f0104477:	8b 43 0c             	mov    0xc(%ebx),%eax
f010447a:	89 47 14             	mov    %eax,0x14(%edi)
		utf->utf_regs.reg_ebp = tf->tf_regs.reg_ebp;
f010447d:	8b 43 08             	mov    0x8(%ebx),%eax
f0104480:	89 47 10             	mov    %eax,0x10(%edi)
		utf->utf_regs.reg_esi = tf->tf_regs.reg_esi;
f0104483:	8b 43 04             	mov    0x4(%ebx),%eax
f0104486:	89 47 0c             	mov    %eax,0xc(%edi)
		utf->utf_regs.reg_edi = tf->tf_regs.reg_edi;
f0104489:	8b 03                	mov    (%ebx),%eax
f010448b:	89 47 08             	mov    %eax,0x8(%edi)
		utf->utf_err = tf->tf_err;
f010448e:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104491:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_fault_va = fault_va;
f0104494:	89 37                	mov    %esi,(%edi)
		// Branch to user page fault upcall function
		tf->tf_esp = (uintptr_t)utf;
f0104496:	89 7b 3c             	mov    %edi,0x3c(%ebx)
		tf->tf_eip = (uintptr_t)(curenv->env_pgfault_upcall);
f0104499:	e8 8e 1c 00 00       	call   f010612c <cpunum>
f010449e:	6b c0 74             	imul   $0x74,%eax,%eax
f01044a1:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01044a7:	8b 40 64             	mov    0x64(%eax),%eax
f01044aa:	89 43 30             	mov    %eax,0x30(%ebx)
		// Run current environment
		env_run(curenv);
f01044ad:	e8 7a 1c 00 00       	call   f010612c <cpunum>
f01044b2:	6b c0 74             	imul   $0x74,%eax,%eax
f01044b5:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01044bb:	89 04 24             	mov    %eax,(%esp)
f01044be:	e8 43 f5 ff ff       	call   f0103a06 <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01044c3:	8b 7b 30             	mov    0x30(%ebx),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f01044c6:	e8 61 1c 00 00       	call   f010612c <cpunum>
		// Run current environment
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01044cb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01044cf:	89 74 24 08          	mov    %esi,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f01044d3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01044da:	29 c2                	sub    %eax,%edx
f01044dc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01044df:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
		// Run current environment
		env_run(curenv);
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f01044e6:	8b 40 48             	mov    0x48(%eax),%eax
f01044e9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ed:	c7 04 24 48 7d 10 f0 	movl   $0xf0107d48,(%esp)
f01044f4:	e8 51 f7 ff ff       	call   f0103c4a <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01044f9:	89 1c 24             	mov    %ebx,(%esp)
f01044fc:	e8 21 fd ff ff       	call   f0104222 <print_trapframe>
	env_destroy(curenv);
f0104501:	e8 26 1c 00 00       	call   f010612c <cpunum>
f0104506:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010450d:	29 c2                	sub    %eax,%edx
f010450f:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104512:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104519:	89 04 24             	mov    %eax,(%esp)
f010451c:	e8 26 f4 ff ff       	call   f0103947 <env_destroy>
}
f0104521:	83 c4 1c             	add    $0x1c,%esp
f0104524:	5b                   	pop    %ebx
f0104525:	5e                   	pop    %esi
f0104526:	5f                   	pop    %edi
f0104527:	5d                   	pop    %ebp
f0104528:	c3                   	ret    

f0104529 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0104529:	55                   	push   %ebp
f010452a:	89 e5                	mov    %esp,%ebp
f010452c:	57                   	push   %edi
f010452d:	56                   	push   %esi
f010452e:	83 ec 20             	sub    $0x20,%esp
f0104531:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0104534:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0104535:	83 3d 80 2e 22 f0 00 	cmpl   $0x0,0xf0222e80
f010453c:	74 01                	je     f010453f <trap+0x16>
		asm volatile("hlt");
f010453e:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f010453f:	e8 e8 1b 00 00       	call   f010612c <cpunum>
f0104544:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010454b:	29 c2                	sub    %eax,%edx
f010454d:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104550:	8d 14 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104557:	b8 01 00 00 00       	mov    $0x1,%eax
f010455c:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0104560:	83 f8 02             	cmp    $0x2,%eax
f0104563:	75 0c                	jne    f0104571 <trap+0x48>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0104565:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f010456c:	e8 7a 1e 00 00       	call   f01063eb <spin_lock>

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0104571:	9c                   	pushf  
f0104572:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104573:	f6 c4 02             	test   $0x2,%ah
f0104576:	74 24                	je     f010459c <trap+0x73>
f0104578:	c7 44 24 0c af 7b 10 	movl   $0xf0107baf,0xc(%esp)
f010457f:	f0 
f0104580:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f0104587:	f0 
f0104588:	c7 44 24 04 2f 01 00 	movl   $0x12f,0x4(%esp)
f010458f:	00 
f0104590:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0104597:	e8 a4 ba ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010459c:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01045a0:	83 e0 03             	and    $0x3,%eax
f01045a3:	83 f8 03             	cmp    $0x3,%eax
f01045a6:	0f 85 a7 00 00 00    	jne    f0104653 <trap+0x12a>
f01045ac:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f01045b3:	e8 33 1e 00 00       	call   f01063eb <spin_lock>
		// LAB 4: Your code here.

		// Aquire lock
		lock_kernel();

		assert(curenv);
f01045b8:	e8 6f 1b 00 00       	call   f010612c <cpunum>
f01045bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01045c0:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f01045c7:	75 24                	jne    f01045ed <trap+0xc4>
f01045c9:	c7 44 24 0c c8 7b 10 	movl   $0xf0107bc8,0xc(%esp)
f01045d0:	f0 
f01045d1:	c7 44 24 08 d2 76 10 	movl   $0xf01076d2,0x8(%esp)
f01045d8:	f0 
f01045d9:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f01045e0:	00 
f01045e1:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f01045e8:	e8 53 ba ff ff       	call   f0100040 <_panic>
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f01045ed:	e8 3a 1b 00 00       	call   f010612c <cpunum>
f01045f2:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f5:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f01045fb:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01045ff:	75 2d                	jne    f010462e <trap+0x105>
			env_free(curenv);
f0104601:	e8 26 1b 00 00       	call   f010612c <cpunum>
f0104606:	6b c0 74             	imul   $0x74,%eax,%eax
f0104609:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010460f:	89 04 24             	mov    %eax,(%esp)
f0104612:	e8 57 f1 ff ff       	call   f010376e <env_free>
			curenv = NULL;
f0104617:	e8 10 1b 00 00       	call   f010612c <cpunum>
f010461c:	6b c0 74             	imul   $0x74,%eax,%eax
f010461f:	c7 80 28 30 22 f0 00 	movl   $0x0,-0xfddcfd8(%eax)
f0104626:	00 00 00 
			sched_yield();
f0104629:	e8 28 03 00 00       	call   f0104956 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f010462e:	e8 f9 1a 00 00       	call   f010612c <cpunum>
f0104633:	6b c0 74             	imul   $0x74,%eax,%eax
f0104636:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010463c:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104641:	89 c7                	mov    %eax,%edi
f0104643:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0104645:	e8 e2 1a 00 00       	call   f010612c <cpunum>
f010464a:	6b c0 74             	imul   $0x74,%eax,%eax
f010464d:	8b b0 28 30 22 f0    	mov    -0xfddcfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0104653:	89 35 60 2a 22 f0    	mov    %esi,0xf0222a60
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Trap 3
	if (tf->tf_trapno == T_BRKPT) {
f0104659:	8b 46 28             	mov    0x28(%esi),%eax
f010465c:	83 f8 03             	cmp    $0x3,%eax
f010465f:	75 0d                	jne    f010466e <trap+0x145>
		monitor(tf);
f0104661:	89 34 24             	mov    %esi,(%esp)
f0104664:	e8 69 c2 ff ff       	call   f01008d2 <monitor>
f0104669:	e9 b4 00 00 00       	jmp    f0104722 <trap+0x1f9>
		return;
	}
	// Trap 14
	if (tf->tf_trapno == T_PGFLT) {
f010466e:	83 f8 0e             	cmp    $0xe,%eax
f0104671:	75 0d                	jne    f0104680 <trap+0x157>
		page_fault_handler(tf);
f0104673:	89 34 24             	mov    %esi,(%esp)
f0104676:	e8 3f fd ff ff       	call   f01043ba <page_fault_handler>
f010467b:	e9 a2 00 00 00       	jmp    f0104722 <trap+0x1f9>
		return;
	}
	// Trap 48
	if (tf->tf_trapno == T_SYSCALL) {
f0104680:	83 f8 30             	cmp    $0x30,%eax
f0104683:	75 32                	jne    f01046b7 <trap+0x18e>
		int32_t ret;
		ret = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, 
f0104685:	8b 46 04             	mov    0x4(%esi),%eax
f0104688:	89 44 24 14          	mov    %eax,0x14(%esp)
f010468c:	8b 06                	mov    (%esi),%eax
f010468e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104692:	8b 46 10             	mov    0x10(%esi),%eax
f0104695:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104699:	8b 46 18             	mov    0x18(%esi),%eax
f010469c:	89 44 24 08          	mov    %eax,0x8(%esp)
f01046a0:	8b 46 14             	mov    0x14(%esi),%eax
f01046a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01046a7:	8b 46 1c             	mov    0x1c(%esi),%eax
f01046aa:	89 04 24             	mov    %eax,(%esp)
f01046ad:	e8 86 03 00 00       	call   f0104a38 <syscall>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f01046b2:	89 46 1c             	mov    %eax,0x1c(%esi)
f01046b5:	eb 6b                	jmp    f0104722 <trap+0x1f9>
		return;
	}
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01046b7:	83 f8 27             	cmp    $0x27,%eax
f01046ba:	75 16                	jne    f01046d2 <trap+0x1a9>
		cprintf("Spurious interrupt on irq 7\n");
f01046bc:	c7 04 24 cf 7b 10 f0 	movl   $0xf0107bcf,(%esp)
f01046c3:	e8 82 f5 ff ff       	call   f0103c4a <cprintf>
		print_trapframe(tf);
f01046c8:	89 34 24             	mov    %esi,(%esp)
f01046cb:	e8 52 fb ff ff       	call   f0104222 <print_trapframe>
f01046d0:	eb 50                	jmp    f0104722 <trap+0x1f9>
	}

	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER) {
f01046d2:	83 f8 20             	cmp    $0x20,%eax
f01046d5:	75 0a                	jne    f01046e1 <trap+0x1b8>
		lapic_eoi();
f01046d7:	e8 a7 1b 00 00       	call   f0106283 <lapic_eoi>
		sched_yield();
f01046dc:	e8 75 02 00 00       	call   f0104956 <sched_yield>

	// Handle keyboard and serial interrupts.
	// LAB 5: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f01046e1:	89 34 24             	mov    %esi,(%esp)
f01046e4:	e8 39 fb ff ff       	call   f0104222 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f01046e9:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f01046ee:	75 1c                	jne    f010470c <trap+0x1e3>
		panic("unhandled trap in kernel");
f01046f0:	c7 44 24 08 ec 7b 10 	movl   $0xf0107bec,0x8(%esp)
f01046f7:	f0 
f01046f8:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
f01046ff:	00 
f0104700:	c7 04 24 a3 7b 10 f0 	movl   $0xf0107ba3,(%esp)
f0104707:	e8 34 b9 ff ff       	call   f0100040 <_panic>
	else {
		env_destroy(curenv);
f010470c:	e8 1b 1a 00 00       	call   f010612c <cpunum>
f0104711:	6b c0 74             	imul   $0x74,%eax,%eax
f0104714:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010471a:	89 04 24             	mov    %eax,(%esp)
f010471d:	e8 25 f2 ff ff       	call   f0103947 <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104722:	e8 05 1a 00 00       	call   f010612c <cpunum>
f0104727:	6b c0 74             	imul   $0x74,%eax,%eax
f010472a:	83 b8 28 30 22 f0 00 	cmpl   $0x0,-0xfddcfd8(%eax)
f0104731:	74 2a                	je     f010475d <trap+0x234>
f0104733:	e8 f4 19 00 00       	call   f010612c <cpunum>
f0104738:	6b c0 74             	imul   $0x74,%eax,%eax
f010473b:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104741:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104745:	75 16                	jne    f010475d <trap+0x234>
		env_run(curenv);
f0104747:	e8 e0 19 00 00       	call   f010612c <cpunum>
f010474c:	6b c0 74             	imul   $0x74,%eax,%eax
f010474f:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104755:	89 04 24             	mov    %eax,(%esp)
f0104758:	e8 a9 f2 ff ff       	call   f0103a06 <env_run>
	else
		sched_yield();
f010475d:	e8 f4 01 00 00       	call   f0104956 <sched_yield>
	...

f0104764 <T_DIVIDE_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(T_DIVIDE_handler, T_DIVIDE)
f0104764:	6a 00                	push   $0x0
f0104766:	6a 00                	push   $0x0
f0104768:	e9 e2 00 00 00       	jmp    f010484f <_alltraps>
f010476d:	90                   	nop

f010476e <T_DEBUG_handler>:
TRAPHANDLER_NOEC(T_DEBUG_handler, T_DEBUG)
f010476e:	6a 00                	push   $0x0
f0104770:	6a 01                	push   $0x1
f0104772:	e9 d8 00 00 00       	jmp    f010484f <_alltraps>
f0104777:	90                   	nop

f0104778 <T_NMI_handler>:
TRAPHANDLER_NOEC(T_NMI_handler, T_NMI)
f0104778:	6a 00                	push   $0x0
f010477a:	6a 02                	push   $0x2
f010477c:	e9 ce 00 00 00       	jmp    f010484f <_alltraps>
f0104781:	90                   	nop

f0104782 <T_BRKPT_handler>:
TRAPHANDLER_NOEC(T_BRKPT_handler, T_BRKPT)
f0104782:	6a 00                	push   $0x0
f0104784:	6a 03                	push   $0x3
f0104786:	e9 c4 00 00 00       	jmp    f010484f <_alltraps>
f010478b:	90                   	nop

f010478c <T_OFLOW_handler>:
TRAPHANDLER_NOEC(T_OFLOW_handler, T_OFLOW)
f010478c:	6a 00                	push   $0x0
f010478e:	6a 04                	push   $0x4
f0104790:	e9 ba 00 00 00       	jmp    f010484f <_alltraps>
f0104795:	90                   	nop

f0104796 <T_BOUND_handler>:
TRAPHANDLER_NOEC(T_BOUND_handler, T_BOUND)
f0104796:	6a 00                	push   $0x0
f0104798:	6a 05                	push   $0x5
f010479a:	e9 b0 00 00 00       	jmp    f010484f <_alltraps>
f010479f:	90                   	nop

f01047a0 <T_ILLOP_handler>:
TRAPHANDLER_NOEC(T_ILLOP_handler, T_ILLOP)
f01047a0:	6a 00                	push   $0x0
f01047a2:	6a 06                	push   $0x6
f01047a4:	e9 a6 00 00 00       	jmp    f010484f <_alltraps>
f01047a9:	90                   	nop

f01047aa <T_DEVICE_handler>:
TRAPHANDLER_NOEC(T_DEVICE_handler, T_DEVICE)
f01047aa:	6a 00                	push   $0x0
f01047ac:	6a 07                	push   $0x7
f01047ae:	e9 9c 00 00 00       	jmp    f010484f <_alltraps>
f01047b3:	90                   	nop

f01047b4 <T_DBLFLT_handler>:
TRAPHANDLER_NOEC(T_DBLFLT_handler, T_DBLFLT)
f01047b4:	6a 00                	push   $0x0
f01047b6:	6a 08                	push   $0x8
f01047b8:	e9 92 00 00 00       	jmp    f010484f <_alltraps>
f01047bd:	90                   	nop

f01047be <T_TSS_handler>:

TRAPHANDLER_NOEC(T_TSS_handler, T_TSS)
f01047be:	6a 00                	push   $0x0
f01047c0:	6a 0a                	push   $0xa
f01047c2:	e9 88 00 00 00       	jmp    f010484f <_alltraps>
f01047c7:	90                   	nop

f01047c8 <T_SEGNP_handler>:
TRAPHANDLER_NOEC(T_SEGNP_handler, T_SEGNP)
f01047c8:	6a 00                	push   $0x0
f01047ca:	6a 0b                	push   $0xb
f01047cc:	e9 7e 00 00 00       	jmp    f010484f <_alltraps>
f01047d1:	90                   	nop

f01047d2 <T_STACK_handler>:
TRAPHANDLER_NOEC(T_STACK_handler, T_STACK)
f01047d2:	6a 00                	push   $0x0
f01047d4:	6a 0c                	push   $0xc
f01047d6:	e9 74 00 00 00       	jmp    f010484f <_alltraps>
f01047db:	90                   	nop

f01047dc <T_GPFLT_handler>:
TRAPHANDLER(T_GPFLT_handler, T_GPFLT)
f01047dc:	6a 0d                	push   $0xd
f01047de:	e9 6c 00 00 00       	jmp    f010484f <_alltraps>
f01047e3:	90                   	nop

f01047e4 <T_PGFLT_handler>:
TRAPHANDLER(T_PGFLT_handler, T_PGFLT)
f01047e4:	6a 0e                	push   $0xe
f01047e6:	e9 64 00 00 00       	jmp    f010484f <_alltraps>
f01047eb:	90                   	nop

f01047ec <T_FPERR_handler>:

TRAPHANDLER_NOEC(T_FPERR_handler, T_FPERR)
f01047ec:	6a 00                	push   $0x0
f01047ee:	6a 10                	push   $0x10
f01047f0:	e9 5a 00 00 00       	jmp    f010484f <_alltraps>
f01047f5:	90                   	nop

f01047f6 <T_ALIGN_handler>:
TRAPHANDLER_NOEC(T_ALIGN_handler, T_ALIGN)
f01047f6:	6a 00                	push   $0x0
f01047f8:	6a 11                	push   $0x11
f01047fa:	e9 50 00 00 00       	jmp    f010484f <_alltraps>
f01047ff:	90                   	nop

f0104800 <T_MCHK_handler>:
TRAPHANDLER_NOEC(T_MCHK_handler, T_MCHK)
f0104800:	6a 00                	push   $0x0
f0104802:	6a 12                	push   $0x12
f0104804:	e9 46 00 00 00       	jmp    f010484f <_alltraps>
f0104809:	90                   	nop

f010480a <T_SIMDERR_handler>:
TRAPHANDLER_NOEC(T_SIMDERR_handler, T_SIMDERR)
f010480a:	6a 00                	push   $0x0
f010480c:	6a 13                	push   $0x13
f010480e:	e9 3c 00 00 00       	jmp    f010484f <_alltraps>
f0104813:	90                   	nop

f0104814 <T_SYSCALL_handler>:

TRAPHANDLER_NOEC(T_SYSCALL_handler, T_SYSCALL)
f0104814:	6a 00                	push   $0x0
f0104816:	6a 30                	push   $0x30
f0104818:	e9 32 00 00 00       	jmp    f010484f <_alltraps>
f010481d:	90                   	nop

f010481e <IRQ_TIMER_handler>:

/* 
 * Lab 4: Hardware handlers
 */
TRAPHANDLER_NOEC(IRQ_TIMER_handler, IRQ_OFFSET+IRQ_TIMER)
f010481e:	6a 00                	push   $0x0
f0104820:	6a 20                	push   $0x20
f0104822:	e9 28 00 00 00       	jmp    f010484f <_alltraps>
f0104827:	90                   	nop

f0104828 <IRQ_KBD_handler>:
TRAPHANDLER_NOEC(IRQ_KBD_handler, IRQ_OFFSET+IRQ_KBD)
f0104828:	6a 00                	push   $0x0
f010482a:	6a 21                	push   $0x21
f010482c:	e9 1e 00 00 00       	jmp    f010484f <_alltraps>
f0104831:	90                   	nop

f0104832 <IRQ_SERIAL_handler>:
TRAPHANDLER_NOEC(IRQ_SERIAL_handler, IRQ_OFFSET+IRQ_SERIAL)
f0104832:	6a 00                	push   $0x0
f0104834:	6a 24                	push   $0x24
f0104836:	e9 14 00 00 00       	jmp    f010484f <_alltraps>
f010483b:	90                   	nop

f010483c <IRQ_SPURIOUS_handler>:
TRAPHANDLER_NOEC(IRQ_SPURIOUS_handler, IRQ_OFFSET+IRQ_SPURIOUS)
f010483c:	6a 00                	push   $0x0
f010483e:	6a 27                	push   $0x27
f0104840:	e9 0a 00 00 00       	jmp    f010484f <_alltraps>
f0104845:	90                   	nop

f0104846 <IRQ_IDE_handler>:
TRAPHANDLER_NOEC(IRQ_IDE_handler, IRQ_OFFSET+IRQ_IDE)
f0104846:	6a 00                	push   $0x0
f0104848:	6a 2e                	push   $0x2e
f010484a:	e9 00 00 00 00       	jmp    f010484f <_alltraps>

f010484f <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
  # Build trap frame.
  pushl %ds
f010484f:	1e                   	push   %ds
  pushl %es
f0104850:	06                   	push   %es
  pushal
f0104851:	60                   	pusha  

  # Save information
  movl $GD_KD, %eax
f0104852:	b8 10 00 00 00       	mov    $0x10,%eax
  movw %ax, %ds
f0104857:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0104859:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
f010485b:	54                   	push   %esp
  call trap
f010485c:	e8 c8 fc ff ff       	call   f0104529 <trap>
f0104861:	00 00                	add    %al,(%eax)
	...

f0104864 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104864:	55                   	push   %ebp
f0104865:	89 e5                	mov    %esp,%ebp
f0104867:	83 ec 18             	sub    $0x18,%esp

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
f010486a:	8b 15 48 22 22 f0    	mov    0xf0222248,%edx
f0104870:	83 c2 54             	add    $0x54,%edx
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104873:	b8 00 00 00 00       	mov    $0x0,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f0104878:	8b 0a                	mov    (%edx),%ecx
f010487a:	49                   	dec    %ecx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f010487b:	83 f9 02             	cmp    $0x2,%ecx
f010487e:	76 0d                	jbe    f010488d <sched_halt+0x29>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0104880:	40                   	inc    %eax
f0104881:	83 c2 7c             	add    $0x7c,%edx
f0104884:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104889:	75 ed                	jne    f0104878 <sched_halt+0x14>
f010488b:	eb 07                	jmp    f0104894 <sched_halt+0x30>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f010488d:	3d 00 04 00 00       	cmp    $0x400,%eax
f0104892:	75 1a                	jne    f01048ae <sched_halt+0x4a>
		cprintf("No runnable environments in the system!\n");
f0104894:	c7 04 24 d0 7d 10 f0 	movl   $0xf0107dd0,(%esp)
f010489b:	e8 aa f3 ff ff       	call   f0103c4a <cprintf>
		while (1)
			monitor(NULL);
f01048a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048a7:	e8 26 c0 ff ff       	call   f01008d2 <monitor>
f01048ac:	eb f2                	jmp    f01048a0 <sched_halt+0x3c>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01048ae:	e8 79 18 00 00       	call   f010612c <cpunum>
f01048b3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01048ba:	29 c2                	sub    %eax,%edx
f01048bc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01048bf:	c7 04 85 28 30 22 f0 	movl   $0x0,-0xfddcfd8(,%eax,4)
f01048c6:	00 00 00 00 
	lcr3(PADDR(kern_pgdir));
f01048ca:	a1 8c 2e 22 f0       	mov    0xf0222e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01048cf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01048d4:	77 20                	ja     f01048f6 <sched_halt+0x92>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01048d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048da:	c7 44 24 08 24 68 10 	movl   $0xf0106824,0x8(%esp)
f01048e1:	f0 
f01048e2:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
f01048e9:	00 
f01048ea:	c7 04 24 f9 7d 10 f0 	movl   $0xf0107df9,(%esp)
f01048f1:	e8 4a b7 ff ff       	call   f0100040 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01048f6:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01048fb:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f01048fe:	e8 29 18 00 00       	call   f010612c <cpunum>
f0104903:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010490a:	29 c2                	sub    %eax,%edx
f010490c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010490f:	8d 14 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104916:	b8 02 00 00 00       	mov    $0x2,%eax
f010491b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010491f:	c7 04 24 c0 83 12 f0 	movl   $0xf01283c0,(%esp)
f0104926:	e8 63 1b 00 00       	call   f010648e <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010492b:	f3 90                	pause  
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010492d:	e8 fa 17 00 00       	call   f010612c <cpunum>
f0104932:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104939:	29 c2                	sub    %eax,%edx
f010493b:	8d 04 90             	lea    (%eax,%edx,4),%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010493e:	8b 04 85 30 30 22 f0 	mov    -0xfddcfd0(,%eax,4),%eax
f0104945:	bd 00 00 00 00       	mov    $0x0,%ebp
f010494a:	89 c4                	mov    %eax,%esp
f010494c:	6a 00                	push   $0x0
f010494e:	6a 00                	push   $0x0
f0104950:	fb                   	sti    
f0104951:	f4                   	hlt    
f0104952:	eb fd                	jmp    f0104951 <sched_halt+0xed>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104954:	c9                   	leave  
f0104955:	c3                   	ret    

f0104956 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104956:	55                   	push   %ebp
f0104957:	89 e5                	mov    %esp,%ebp
f0104959:	56                   	push   %esi
f010495a:	53                   	push   %ebx
f010495b:	83 ec 10             	sub    $0x10,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	int idx = ENVX((curenv ? ENVX(curenv->env_id) : 0) + 1);
f010495e:	e8 c9 17 00 00       	call   f010612c <cpunum>
f0104963:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010496a:	29 c2                	sub    %eax,%edx
f010496c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010496f:	83 3c 85 28 30 22 f0 	cmpl   $0x0,-0xfddcfd8(,%eax,4)
f0104976:	00 
f0104977:	74 23                	je     f010499c <sched_yield+0x46>
f0104979:	e8 ae 17 00 00       	call   f010612c <cpunum>
f010497e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104985:	29 c2                	sub    %eax,%edx
f0104987:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010498a:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104991:	8b 40 48             	mov    0x48(%eax),%eax
f0104994:	40                   	inc    %eax
f0104995:	25 ff 03 00 00       	and    $0x3ff,%eax
f010499a:	eb 05                	jmp    f01049a1 <sched_yield+0x4b>
f010499c:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 0; i < NENV; i++) {
		// Get the environment
		idle = &envs[idx];
f01049a1:	8b 35 48 22 22 f0    	mov    0xf0222248,%esi
f01049a7:	ba 00 04 00 00       	mov    $0x400,%edx
f01049ac:	8d 1c 85 00 00 00 00 	lea    0x0(,%eax,4),%ebx
f01049b3:	89 c1                	mov    %eax,%ecx
f01049b5:	c1 e1 07             	shl    $0x7,%ecx
f01049b8:	29 d9                	sub    %ebx,%ecx
f01049ba:	01 f1                	add    %esi,%ecx
		if (idle->env_status == ENV_RUNNABLE) {
f01049bc:	83 79 54 02          	cmpl   $0x2,0x54(%ecx)
f01049c0:	75 08                	jne    f01049ca <sched_yield+0x74>
			env_run(idle);
f01049c2:	89 0c 24             	mov    %ecx,(%esp)
f01049c5:	e8 3c f0 ff ff       	call   f0103a06 <env_run>
			break;
		}
		idx = ENVX(idx + 1);
f01049ca:	40                   	inc    %eax
f01049cb:	25 ff 03 00 00       	and    $0x3ff,%eax
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i;
	int idx = ENVX((curenv ? ENVX(curenv->env_id) : 0) + 1);
	for (i = 0; i < NENV; i++) {
f01049d0:	4a                   	dec    %edx
f01049d1:	75 d9                	jne    f01049ac <sched_yield+0x56>
			break;
		}
		idx = ENVX(idx + 1);
	}
	// If not found, then continue the original one
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f01049d3:	e8 54 17 00 00       	call   f010612c <cpunum>
f01049d8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01049df:	29 c2                	sub    %eax,%edx
f01049e1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049e4:	83 3c 85 28 30 22 f0 	cmpl   $0x0,-0xfddcfd8(,%eax,4)
f01049eb:	00 
f01049ec:	74 3e                	je     f0104a2c <sched_yield+0xd6>
f01049ee:	e8 39 17 00 00       	call   f010612c <cpunum>
f01049f3:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01049fa:	29 c2                	sub    %eax,%edx
f01049fc:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01049ff:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104a06:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a0a:	75 20                	jne    f0104a2c <sched_yield+0xd6>
		env_run(curenv);
f0104a0c:	e8 1b 17 00 00       	call   f010612c <cpunum>
f0104a11:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a18:	29 c2                	sub    %eax,%edx
f0104a1a:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a1d:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104a24:	89 04 24             	mov    %eax,(%esp)
f0104a27:	e8 da ef ff ff       	call   f0103a06 <env_run>
	
	// sched_halt never returns
	sched_halt();
f0104a2c:	e8 33 fe ff ff       	call   f0104864 <sched_halt>
}
f0104a31:	83 c4 10             	add    $0x10,%esp
f0104a34:	5b                   	pop    %ebx
f0104a35:	5e                   	pop    %esi
f0104a36:	5d                   	pop    %ebp
f0104a37:	c3                   	ret    

f0104a38 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a38:	55                   	push   %ebp
f0104a39:	89 e5                	mov    %esp,%ebp
f0104a3b:	57                   	push   %edi
f0104a3c:	56                   	push   %esi
f0104a3d:	53                   	push   %ebx
f0104a3e:	83 ec 3c             	sub    $0x3c,%esp
f0104a41:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a44:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a47:	8b 75 10             	mov    0x10(%ebp),%esi
f0104a4a:	8b 7d 14             	mov    0x14(%ebp),%edi
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 3: Your code here.
	int32_t ret;

	switch (syscallno) {
f0104a4d:	83 f8 0d             	cmp    $0xd,%eax
f0104a50:	0f 87 03 06 00 00    	ja     f0105059 <syscall+0x621>
f0104a56:	ff 24 85 2c 7e 10 f0 	jmp    *-0xfef81d4(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0104a5d:	e8 ca 16 00 00       	call   f010612c <cpunum>
f0104a62:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104a69:	00 
f0104a6a:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104a6e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104a72:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104a79:	29 c2                	sub    %eax,%edx
f0104a7b:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104a7e:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104a85:	89 04 24             	mov    %eax,(%esp)
f0104a88:	e8 a0 e9 ff ff       	call   f010342d <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104a8d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104a91:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104a95:	c7 04 24 06 7e 10 f0 	movl   $0xf0107e06,(%esp)
f0104a9c:	e8 a9 f1 ff ff       	call   f0103c4a <cprintf>
	int32_t ret;

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
f0104aa1:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104aa6:	e9 b3 05 00 00       	jmp    f010505e <syscall+0x626>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104aab:	e8 82 bb ff ff       	call   f0100632 <cons_getc>
f0104ab0:	89 c3                	mov    %eax,%ebx
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
		break;
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
f0104ab2:	e9 a7 05 00 00       	jmp    f010505e <syscall+0x626>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104ab7:	e8 70 16 00 00       	call   f010612c <cpunum>
f0104abc:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104ac3:	29 c2                	sub    %eax,%edx
f0104ac5:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104ac8:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104acf:	8b 58 48             	mov    0x48(%eax),%ebx
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
f0104ad2:	e9 87 05 00 00       	jmp    f010505e <syscall+0x626>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104ad7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104ade:	00 
f0104adf:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104ae2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ae6:	89 1c 24             	mov    %ebx,(%esp)
f0104ae9:	e8 9a e9 ff ff       	call   f0103488 <envid2env>
f0104aee:	89 c3                	mov    %eax,%ebx
f0104af0:	85 c0                	test   %eax,%eax
f0104af2:	0f 88 66 05 00 00    	js     f010505e <syscall+0x626>
		return r;
	env_destroy(e);
f0104af8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104afb:	89 04 24             	mov    %eax,(%esp)
f0104afe:	e8 44 ee ff ff       	call   f0103947 <env_destroy>
	return 0;
f0104b03:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
	case SYS_env_destroy:
		ret = sys_env_destroy((envid_t)a1);
		break;
f0104b08:	e9 51 05 00 00       	jmp    f010505e <syscall+0x626>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104b0d:	e8 44 fe ff ff       	call   f0104956 <sched_yield>
	// will appear to return 0.

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((r = env_alloc(&env_store, curenv->env_id)) < 0) {
f0104b12:	e8 15 16 00 00       	call   f010612c <cpunum>
f0104b17:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b1e:	29 c2                	sub    %eax,%edx
f0104b20:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b23:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104b2a:	8b 40 48             	mov    0x48(%eax),%eax
f0104b2d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b31:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104b34:	89 04 24             	mov    %eax,(%esp)
f0104b37:	e8 80 ea ff ff       	call   f01035bc <env_alloc>
f0104b3c:	89 c3                	mov    %eax,%ebx
f0104b3e:	85 c0                	test   %eax,%eax
f0104b40:	0f 88 18 05 00 00    	js     f010505e <syscall+0x626>
		return r;
	}
	env_store->env_status = ENV_NOT_RUNNABLE;
f0104b46:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b49:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	memmove((void *) &env_store->env_tf, (void *)&curenv->env_tf, sizeof(struct Trapframe));
f0104b50:	e8 d7 15 00 00       	call   f010612c <cpunum>
f0104b55:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0104b5c:	00 
f0104b5d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104b64:	29 c2                	sub    %eax,%edx
f0104b66:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104b69:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104b70:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b74:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b77:	89 04 24             	mov    %eax,(%esp)
f0104b7a:	e8 c9 0f 00 00       	call   f0105b48 <memmove>
	// Set return of child process to be 0
	env_store->env_tf.tf_regs.reg_eax = 0;
f0104b7f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104b82:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return env_store->env_id;
f0104b89:	8b 58 48             	mov    0x48(%eax),%ebx
		sys_yield();
		ret = 0;
		break;
	case SYS_exofork:
		ret = sys_exofork();
		break;
f0104b8c:	e9 cd 04 00 00       	jmp    f010505e <syscall+0x626>
	// envid's status.

	// LAB 4: Your code here.
	int r;
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104b91:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104b98:	00 
f0104b99:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104b9c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104ba0:	89 1c 24             	mov    %ebx,(%esp)
f0104ba3:	e8 e0 e8 ff ff       	call   f0103488 <envid2env>
f0104ba8:	89 c3                	mov    %eax,%ebx
f0104baa:	85 c0                	test   %eax,%eax
f0104bac:	0f 88 ac 04 00 00    	js     f010505e <syscall+0x626>
		return r;
	}
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
f0104bb2:	83 fe 04             	cmp    $0x4,%esi
f0104bb5:	74 05                	je     f0104bbc <syscall+0x184>
f0104bb7:	83 fe 02             	cmp    $0x2,%esi
f0104bba:	75 10                	jne    f0104bcc <syscall+0x194>
		return -E_INVAL;
	}
	env_store->env_status = status;
f0104bbc:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104bbf:	89 70 54             	mov    %esi,0x54(%eax)
	return 0;
f0104bc2:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104bc7:	e9 92 04 00 00       	jmp    f010505e <syscall+0x626>
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
		return r;
	}
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) {
		return -E_INVAL;
f0104bcc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_exofork:
		ret = sys_exofork();
		break;
	case SYS_env_set_status:
		ret = sys_env_set_status((envid_t)a1, (int)a2);
		break;
f0104bd1:	e9 88 04 00 00       	jmp    f010505e <syscall+0x626>
	//   parameters for correctness.
	//   If page_insert() fails, remember to free the page you
	//   allocated!

	// LAB 4: Your code here.
	struct PageInfo *newPage = page_alloc(ALLOC_ZERO);
f0104bd6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0104bdd:	e8 9c c3 ff ff       	call   f0100f7e <page_alloc>
f0104be2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Env *env_store;
	int r;
	if (!newPage) {
f0104be5:	85 c0                	test   %eax,%eax
f0104be7:	74 6e                	je     f0104c57 <syscall+0x21f>
		return -E_NO_MEM;
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
f0104be9:	89 f8                	mov    %edi,%eax
f0104beb:	83 e0 05             	and    $0x5,%eax
f0104bee:	83 f8 05             	cmp    $0x5,%eax
f0104bf1:	75 6e                	jne    f0104c61 <syscall+0x229>
		return -E_INVAL;
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0104bf3:	f7 c7 f8 f1 ff ff    	test   $0xfffff1f8,%edi
f0104bf9:	75 70                	jne    f0104c6b <syscall+0x233>
		return -E_INVAL;
	}
	if ((uintptr_t)va >= UTOP) {
f0104bfb:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104c01:	77 72                	ja     f0104c75 <syscall+0x23d>
		return -E_INVAL;
	}
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104c03:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104c0a:	00 
f0104c0b:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104c0e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c12:	89 1c 24             	mov    %ebx,(%esp)
f0104c15:	e8 6e e8 ff ff       	call   f0103488 <envid2env>
f0104c1a:	89 c3                	mov    %eax,%ebx
f0104c1c:	85 c0                	test   %eax,%eax
f0104c1e:	0f 88 3a 04 00 00    	js     f010505e <syscall+0x626>
		return r;
	}
	if ((r = page_insert(env_store->env_pgdir, newPage, va, perm)) < 0) {
f0104c24:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104c28:	89 74 24 08          	mov    %esi,0x8(%esp)
f0104c2c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104c2f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c33:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104c36:	8b 40 60             	mov    0x60(%eax),%eax
f0104c39:	89 04 24             	mov    %eax,(%esp)
f0104c3c:	e8 2e c6 ff ff       	call   f010126f <page_insert>
f0104c41:	89 c3                	mov    %eax,%ebx
f0104c43:	85 c0                	test   %eax,%eax
f0104c45:	79 38                	jns    f0104c7f <syscall+0x247>
		page_free(newPage);
f0104c47:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104c4a:	89 04 24             	mov    %eax,(%esp)
f0104c4d:	e8 b0 c3 ff ff       	call   f0101002 <page_free>
f0104c52:	e9 07 04 00 00       	jmp    f010505e <syscall+0x626>
	// LAB 4: Your code here.
	struct PageInfo *newPage = page_alloc(ALLOC_ZERO);
	struct Env *env_store;
	int r;
	if (!newPage) {
		return -E_NO_MEM;
f0104c57:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f0104c5c:	e9 fd 03 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
		return -E_INVAL;
f0104c61:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c66:	e9 f3 03 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
		return -E_INVAL;
f0104c6b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c70:	e9 e9 03 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((uintptr_t)va >= UTOP) {
		return -E_INVAL;
f0104c75:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104c7a:	e9 df 03 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((r = page_insert(env_store->env_pgdir, newPage, va, perm)) < 0) {
		page_free(newPage);
		return r;
	}
	return 0;
f0104c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_env_set_status:
		ret = sys_env_set_status((envid_t)a1, (int)a2);
		break;
	case SYS_page_alloc:
		ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		break;
f0104c84:	e9 d5 03 00 00       	jmp    f010505e <syscall+0x626>
	// LAB 4: Your code here.
	struct PageInfo *srcPage;
	struct Env *srcenv_store, *dstenv_store;
	pte_t *srcpte_store;
	int r;
	if ((r = envid2env(srcenvid, &srcenv_store, true)) < 0) {
f0104c89:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104c90:	00 
f0104c91:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104c94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104c98:	89 1c 24             	mov    %ebx,(%esp)
f0104c9b:	e8 e8 e7 ff ff       	call   f0103488 <envid2env>
f0104ca0:	89 c3                	mov    %eax,%ebx
f0104ca2:	85 c0                	test   %eax,%eax
f0104ca4:	0f 88 b4 03 00 00    	js     f010505e <syscall+0x626>
		return r;
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
f0104caa:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104cb1:	00 
f0104cb2:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cb5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104cb9:	89 3c 24             	mov    %edi,(%esp)
f0104cbc:	e8 c7 e7 ff ff       	call   f0103488 <envid2env>
f0104cc1:	89 c3                	mov    %eax,%ebx
f0104cc3:	85 c0                	test   %eax,%eax
f0104cc5:	0f 88 93 03 00 00    	js     f010505e <syscall+0x626>
	return 0;
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
f0104ccb:	8b 45 18             	mov    0x18(%ebp),%eax
f0104cce:	09 f0                	or     %esi,%eax
		return r;
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
		return r;
	}
	if ((uintptr_t)srcva % PGSIZE != 0 || (uintptr_t)dstva % PGSIZE != 0) {
f0104cd0:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0104cd5:	0f 85 a1 00 00 00    	jne    f0104d7c <syscall+0x344>
		return -E_INVAL;
	}
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) {
f0104cdb:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104ce1:	77 09                	ja     f0104cec <syscall+0x2b4>
f0104ce3:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104cea:	76 1d                	jbe    f0104d09 <syscall+0x2d1>
		cprintf("dstva is now %x\n", dstva);
f0104cec:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104cef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104cf3:	c7 04 24 0b 7e 10 f0 	movl   $0xf0107e0b,(%esp)
f0104cfa:	e8 4b ef ff ff       	call   f0103c4a <cprintf>
		return -E_INVAL;
f0104cff:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d04:	e9 55 03 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
f0104d09:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104d0c:	83 e0 05             	and    $0x5,%eax
f0104d0f:	83 f8 05             	cmp    $0x5,%eax
f0104d12:	75 72                	jne    f0104d86 <syscall+0x34e>
		return -E_INVAL;
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0104d14:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104d1b:	75 73                	jne    f0104d90 <syscall+0x358>
		return -E_INVAL;
	}
	if ((srcPage = page_lookup(srcenv_store->env_pgdir, srcva, &srcpte_store)) == NULL) {
f0104d1d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d20:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104d24:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d28:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d2b:	8b 40 60             	mov    0x60(%eax),%eax
f0104d2e:	89 04 24             	mov    %eax,(%esp)
f0104d31:	e8 2e c4 ff ff       	call   f0101164 <page_lookup>
f0104d36:	85 c0                	test   %eax,%eax
f0104d38:	74 60                	je     f0104d9a <syscall+0x362>
		return -E_INVAL;
	}
	if ((perm & PTE_W) && !(*srcpte_store & PTE_W)) {
f0104d3a:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d3e:	74 08                	je     f0104d48 <syscall+0x310>
f0104d40:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d43:	f6 02 02             	testb  $0x2,(%edx)
f0104d46:	74 5c                	je     f0104da4 <syscall+0x36c>
		return -E_INVAL;
	}
	if ((r = page_insert(dstenv_store->env_pgdir, srcPage, dstva, perm)) < 0) {
f0104d48:	8b 5d 1c             	mov    0x1c(%ebp),%ebx
f0104d4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104d4f:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104d52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104d56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104d5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d5d:	8b 40 60             	mov    0x60(%eax),%eax
f0104d60:	89 04 24             	mov    %eax,(%esp)
f0104d63:	e8 07 c5 ff ff       	call   f010126f <page_insert>
f0104d68:	89 c3                	mov    %eax,%ebx
f0104d6a:	85 c0                	test   %eax,%eax
f0104d6c:	0f 8e ec 02 00 00    	jle    f010505e <syscall+0x626>
f0104d72:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104d77:	e9 e2 02 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((r = envid2env(dstenvid, &dstenv_store, true)) < 0) {
		return r;
	}
	if ((uintptr_t)srcva % PGSIZE != 0 || (uintptr_t)dstva % PGSIZE != 0) {
		return -E_INVAL;
f0104d7c:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d81:	e9 d8 02 00 00       	jmp    f010505e <syscall+0x626>
	if ((uintptr_t)srcva >= UTOP || (uintptr_t)dstva >= UTOP) {
		cprintf("dstva is now %x\n", dstva);
		return -E_INVAL;
	}
	if ((perm & (PTE_P | PTE_U)) != 5) {
		return -E_INVAL;
f0104d86:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d8b:	e9 ce 02 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
		return -E_INVAL;
f0104d90:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d95:	e9 c4 02 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((srcPage = page_lookup(srcenv_store->env_pgdir, srcva, &srcpte_store)) == NULL) {
		return -E_INVAL;
f0104d9a:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d9f:	e9 ba 02 00 00       	jmp    f010505e <syscall+0x626>
	}
	if ((perm & PTE_W) && !(*srcpte_store & PTE_W)) {
		return -E_INVAL;
f0104da4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_alloc:
		ret = sys_page_alloc((envid_t)a1, (void *)a2, (int)a3);
		break;
	case SYS_page_map:
		ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
		break;
f0104da9:	e9 b0 02 00 00       	jmp    f010505e <syscall+0x626>
	// Hint: This function is a wrapper around page_remove().

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((uintptr_t)va >= UTOP) {
f0104dae:	81 fe ff ff bf ee    	cmp    $0xeebfffff,%esi
f0104db4:	77 3d                	ja     f0104df3 <syscall+0x3bb>
		return -E_INVAL;
	}
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104db6:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104dbd:	00 
f0104dbe:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104dc1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104dc5:	89 1c 24             	mov    %ebx,(%esp)
f0104dc8:	e8 bb e6 ff ff       	call   f0103488 <envid2env>
f0104dcd:	89 c3                	mov    %eax,%ebx
f0104dcf:	85 c0                	test   %eax,%eax
f0104dd1:	0f 88 87 02 00 00    	js     f010505e <syscall+0x626>
		return r;
	}
	page_remove(env_store->env_pgdir, va);
f0104dd7:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104ddb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104dde:	8b 40 60             	mov    0x60(%eax),%eax
f0104de1:	89 04 24             	mov    %eax,(%esp)
f0104de4:	e8 3d c4 ff ff       	call   f0101226 <page_remove>
	return 0;
f0104de9:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104dee:	e9 6b 02 00 00       	jmp    f010505e <syscall+0x626>

	// LAB 4: Your code here.
	int r;
	struct Env *env_store;
	if ((uintptr_t)va >= UTOP) {
		return -E_INVAL;
f0104df3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
	case SYS_page_map:
		ret = sys_page_map((envid_t)a1, (void *)a2, (envid_t)a3, (void *)a4, (int)a5);
		break;
	case SYS_page_unmap:
		ret = sys_page_unmap((envid_t)a1, (void *)a2);
		break;
f0104df8:	e9 61 02 00 00       	jmp    f010505e <syscall+0x626>
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 4: Your code here.
	int r;
	struct Env *env_store; 
	if ((r = envid2env(envid, &env_store, true)) < 0) {
f0104dfd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104e04:	00 
f0104e05:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e08:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e0c:	89 1c 24             	mov    %ebx,(%esp)
f0104e0f:	e8 74 e6 ff ff       	call   f0103488 <envid2env>
f0104e14:	89 c3                	mov    %eax,%ebx
f0104e16:	85 c0                	test   %eax,%eax
f0104e18:	0f 88 40 02 00 00    	js     f010505e <syscall+0x626>
		return r;
	}
	env_store->env_pgfault_upcall = func;
f0104e1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e21:	89 70 64             	mov    %esi,0x64(%eax)
	return 0;
f0104e24:	bb 00 00 00 00       	mov    $0x0,%ebx
	case SYS_page_unmap:
		ret = sys_page_unmap((envid_t)a1, (void *)a2);
		break;
	case SYS_env_set_pgfault_upcall:
		ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		break;
f0104e29:	e9 30 02 00 00       	jmp    f010505e <syscall+0x626>
	// LAB 4: Your code here.
	struct PageInfo *srcPage;
	struct Env *env_store;
	pte_t *pte_store;
	int r;
	if ((r = envid2env(envid, &env_store, false)) < 0) {
f0104e2e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0104e35:	00 
f0104e36:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e39:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104e3d:	89 1c 24             	mov    %ebx,(%esp)
f0104e40:	e8 43 e6 ff ff       	call   f0103488 <envid2env>
f0104e45:	89 c3                	mov    %eax,%ebx
f0104e47:	85 c0                	test   %eax,%eax
f0104e49:	0f 88 0f 02 00 00    	js     f010505e <syscall+0x626>
		return r;
	}
	if ((env_store->env_ipc_recving == false) || (env_store->env_ipc_from != 0)) {
f0104e4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e52:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104e56:	0f 84 01 01 00 00    	je     f0104f5d <syscall+0x525>
f0104e5c:	83 78 74 00          	cmpl   $0x0,0x74(%eax)
f0104e60:	0f 85 01 01 00 00    	jne    f0104f67 <syscall+0x52f>
		return -E_IPC_NOT_RECV;
	}
	// If srcva is less then UTOP
	if ((uintptr_t)srcva < UTOP) {
f0104e66:	81 ff ff ff bf ee    	cmp    $0xeebfffff,%edi
f0104e6c:	0f 87 af 00 00 00    	ja     f0104f21 <syscall+0x4e9>
		if ((uintptr_t)srcva % PGSIZE != 0) {
f0104e72:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
f0104e78:	0f 85 f3 00 00 00    	jne    f0104f71 <syscall+0x539>
			return -E_INVAL;
		}
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) {
f0104e7e:	8b 45 18             	mov    0x18(%ebp),%eax
f0104e81:	83 e0 05             	and    $0x5,%eax
f0104e84:	83 f8 05             	cmp    $0x5,%eax
f0104e87:	0f 85 ee 00 00 00    	jne    f0104f7b <syscall+0x543>
			return -E_INVAL;
		}
		if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
f0104e8d:	f7 45 18 f8 f1 ff ff 	testl  $0xfffff1f8,0x18(%ebp)
f0104e94:	0f 85 eb 00 00 00    	jne    f0104f85 <syscall+0x54d>
			return -E_INVAL;
		}
		if ((srcPage = page_lookup(curenv->env_pgdir, srcva, &pte_store)) == NULL) {
f0104e9a:	e8 8d 12 00 00       	call   f010612c <cpunum>
f0104e9f:	8d 55 e0             	lea    -0x20(%ebp),%edx
f0104ea2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104ea6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0104eaa:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104eb1:	29 c2                	sub    %eax,%edx
f0104eb3:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104eb6:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104ebd:	8b 40 60             	mov    0x60(%eax),%eax
f0104ec0:	89 04 24             	mov    %eax,(%esp)
f0104ec3:	e8 9c c2 ff ff       	call   f0101164 <page_lookup>
f0104ec8:	85 c0                	test   %eax,%eax
f0104eca:	0f 84 bf 00 00 00    	je     f0104f8f <syscall+0x557>
			return -E_INVAL;
		}
		if ((perm & PTE_W) && (!(*pte_store & PTE_W))) {
f0104ed0:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ed4:	74 0c                	je     f0104ee2 <syscall+0x4aa>
f0104ed6:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ed9:	f6 02 02             	testb  $0x2,(%edx)
f0104edc:	0f 84 b7 00 00 00    	je     f0104f99 <syscall+0x561>
			return -E_INVAL;
		}
		// Updates
		if ((uintptr_t)env_store->env_ipc_dstva < UTOP) {
f0104ee2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104ee5:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104ee8:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104eee:	77 2a                	ja     f0104f1a <syscall+0x4e2>
			if (page_insert(env_store->env_pgdir, srcPage, env_store->env_ipc_dstva, perm) < 0) {
f0104ef0:	8b 5d 18             	mov    0x18(%ebp),%ebx
f0104ef3:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104ef7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104efb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104eff:	8b 42 60             	mov    0x60(%edx),%eax
f0104f02:	89 04 24             	mov    %eax,(%esp)
f0104f05:	e8 65 c3 ff ff       	call   f010126f <page_insert>
f0104f0a:	85 c0                	test   %eax,%eax
f0104f0c:	0f 88 91 00 00 00    	js     f0104fa3 <syscall+0x56b>
				return -E_NO_MEM;
			}
			env_store->env_ipc_perm = perm;
f0104f12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f15:	89 58 78             	mov    %ebx,0x78(%eax)
f0104f18:	eb 07                	jmp    f0104f21 <syscall+0x4e9>
		}
		else {
			env_store->env_ipc_perm = 0;
f0104f1a:	c7 42 78 00 00 00 00 	movl   $0x0,0x78(%edx)
		}
	}
	// Updates
	env_store->env_ipc_recving = false;
f0104f21:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104f24:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_store->env_ipc_from = curenv->env_id;
f0104f28:	e8 ff 11 00 00       	call   f010612c <cpunum>
f0104f2d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0104f34:	29 c2                	sub    %eax,%edx
f0104f36:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0104f39:	8b 04 85 28 30 22 f0 	mov    -0xfddcfd8(,%eax,4),%eax
f0104f40:	8b 40 48             	mov    0x48(%eax),%eax
f0104f43:	89 43 74             	mov    %eax,0x74(%ebx)
	env_store->env_ipc_value = value;
f0104f46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f49:	89 70 70             	mov    %esi,0x70(%eax)
	env_store->env_status = ENV_RUNNABLE;
f0104f4c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	return 0;
f0104f53:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104f58:	e9 01 01 00 00       	jmp    f010505e <syscall+0x626>
	int r;
	if ((r = envid2env(envid, &env_store, false)) < 0) {
		return r;
	}
	if ((env_store->env_ipc_recving == false) || (env_store->env_ipc_from != 0)) {
		return -E_IPC_NOT_RECV;
f0104f5d:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104f62:	e9 f7 00 00 00       	jmp    f010505e <syscall+0x626>
f0104f67:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
f0104f6c:	e9 ed 00 00 00       	jmp    f010505e <syscall+0x626>
	}
	// If srcva is less then UTOP
	if ((uintptr_t)srcva < UTOP) {
		if ((uintptr_t)srcva % PGSIZE != 0) {
			return -E_INVAL;
f0104f71:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f76:	e9 e3 00 00 00       	jmp    f010505e <syscall+0x626>
		}
		if ((perm & (PTE_P | PTE_U)) != (PTE_P | PTE_U)) {
			return -E_INVAL;
f0104f7b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f80:	e9 d9 00 00 00       	jmp    f010505e <syscall+0x626>
		}
		if ((perm & ~(PTE_P | PTE_U | PTE_W | PTE_AVAIL)) != 0) {
			return -E_INVAL;
f0104f85:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f8a:	e9 cf 00 00 00       	jmp    f010505e <syscall+0x626>
		}
		if ((srcPage = page_lookup(curenv->env_pgdir, srcva, &pte_store)) == NULL) {
			return -E_INVAL;
f0104f8f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f94:	e9 c5 00 00 00       	jmp    f010505e <syscall+0x626>
		}
		if ((perm & PTE_W) && (!(*pte_store & PTE_W))) {
			return -E_INVAL;
f0104f99:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f9e:	e9 bb 00 00 00       	jmp    f010505e <syscall+0x626>
		}
		// Updates
		if ((uintptr_t)env_store->env_ipc_dstva < UTOP) {
			if (page_insert(env_store->env_pgdir, srcPage, env_store->env_ipc_dstva, perm) < 0) {
				return -E_NO_MEM;
f0104fa3:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
	case SYS_env_set_pgfault_upcall:
		ret = sys_env_set_pgfault_upcall((envid_t)a1, (void *)a2);
		break;
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
f0104fa8:	e9 b1 00 00 00       	jmp    f010505e <syscall+0x626>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP) {
f0104fad:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
f0104fb3:	77 39                	ja     f0104fee <syscall+0x5b6>
		if ((uintptr_t)dstva % PGSIZE != 0) {
f0104fb5:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
f0104fbb:	74 1e                	je     f0104fdb <syscall+0x5a3>
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
		cprintf("value is %d\n", ret);
f0104fbd:	c7 44 24 04 fd ff ff 	movl   $0xfffffffd,0x4(%esp)
f0104fc4:	ff 
f0104fc5:	c7 04 24 1c 7e 10 f0 	movl   $0xf0107e1c,(%esp)
f0104fcc:	e8 79 ec ff ff       	call   f0103c4a <cprintf>
		break;
	case SYS_ipc_try_send:
		ret = sys_ipc_try_send((envid_t)a1, a2, (void *)a3, (unsigned int)a4);
		break;
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
f0104fd1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		cprintf("value is %d\n", ret);
		break;
f0104fd6:	e9 83 00 00 00       	jmp    f010505e <syscall+0x626>
	// LAB 4: Your code here.
	if ((uintptr_t)dstva < UTOP) {
		if ((uintptr_t)dstva % PGSIZE != 0) {
			return -E_INVAL;
		}
		curenv->env_ipc_dstva = dstva;
f0104fdb:	e8 4c 11 00 00       	call   f010612c <cpunum>
f0104fe0:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fe3:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104fe9:	89 58 6c             	mov    %ebx,0x6c(%eax)
f0104fec:	eb 15                	jmp    f0105003 <syscall+0x5cb>
	}
	else {
		curenv->env_ipc_dstva = (void *)UTOP;
f0104fee:	e8 39 11 00 00       	call   f010612c <cpunum>
f0104ff3:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ff6:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0104ffc:	c7 40 6c 00 00 c0 ee 	movl   $0xeec00000,0x6c(%eax)
	}
	// Mark itself as not runnable
	curenv->env_status = ENV_NOT_RUNNABLE;
f0105003:	e8 24 11 00 00       	call   f010612c <cpunum>
f0105008:	6b c0 74             	imul   $0x74,%eax,%eax
f010500b:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0105011:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_recving = true;
f0105018:	e8 0f 11 00 00       	call   f010612c <cpunum>
f010501d:	6b c0 74             	imul   $0x74,%eax,%eax
f0105020:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0105026:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_from = 0;
f010502a:	e8 fd 10 00 00       	call   f010612c <cpunum>
f010502f:	6b c0 74             	imul   $0x74,%eax,%eax
f0105032:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f0105038:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f010503f:	e8 e8 10 00 00       	call   f010612c <cpunum>
f0105044:	6b c0 74             	imul   $0x74,%eax,%eax
f0105047:	8b 80 28 30 22 f0    	mov    -0xfddcfd8(%eax),%eax
f010504d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	// Give up the CPU
	sched_yield();
f0105054:	e8 fd f8 ff ff       	call   f0104956 <sched_yield>
	case SYS_ipc_recv:
		ret = sys_ipc_recv((void *)a1);
		cprintf("value is %d\n", ret);
		break;
	default:
		ret = -E_INVAL;
f0105059:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		break;
	}

	return ret;
}
f010505e:	89 d8                	mov    %ebx,%eax
f0105060:	83 c4 3c             	add    $0x3c,%esp
f0105063:	5b                   	pop    %ebx
f0105064:	5e                   	pop    %esi
f0105065:	5f                   	pop    %edi
f0105066:	5d                   	pop    %ebp
f0105067:	c3                   	ret    

f0105068 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0105068:	55                   	push   %ebp
f0105069:	89 e5                	mov    %esp,%ebp
f010506b:	57                   	push   %edi
f010506c:	56                   	push   %esi
f010506d:	53                   	push   %ebx
f010506e:	83 ec 14             	sub    $0x14,%esp
f0105071:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105074:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0105077:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010507a:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f010507d:	8b 1a                	mov    (%edx),%ebx
f010507f:	8b 01                	mov    (%ecx),%eax
f0105081:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105084:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f010508b:	e9 83 00 00 00       	jmp    f0105113 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0105090:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105093:	01 d8                	add    %ebx,%eax
f0105095:	89 c7                	mov    %eax,%edi
f0105097:	c1 ef 1f             	shr    $0x1f,%edi
f010509a:	01 c7                	add    %eax,%edi
f010509c:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010509e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01050a1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01050a4:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f01050a8:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01050aa:	eb 01                	jmp    f01050ad <stab_binsearch+0x45>
			m--;
f01050ac:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01050ad:	39 c3                	cmp    %eax,%ebx
f01050af:	7f 1e                	jg     f01050cf <stab_binsearch+0x67>
f01050b1:	0f b6 0a             	movzbl (%edx),%ecx
f01050b4:	83 ea 0c             	sub    $0xc,%edx
f01050b7:	39 f1                	cmp    %esi,%ecx
f01050b9:	75 f1                	jne    f01050ac <stab_binsearch+0x44>
f01050bb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01050be:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01050c1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01050c4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01050c8:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01050cb:	76 18                	jbe    f01050e5 <stab_binsearch+0x7d>
f01050cd:	eb 05                	jmp    f01050d4 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01050cf:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f01050d2:	eb 3f                	jmp    f0105113 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01050d4:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01050d7:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f01050d9:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01050dc:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01050e3:	eb 2e                	jmp    f0105113 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01050e5:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01050e8:	73 15                	jae    f01050ff <stab_binsearch+0x97>
			*region_right = m - 1;
f01050ea:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01050ed:	49                   	dec    %ecx
f01050ee:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01050f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01050f4:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01050f6:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f01050fd:	eb 14                	jmp    f0105113 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01050ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0105102:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105105:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f0105107:	ff 45 0c             	incl   0xc(%ebp)
f010510a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010510c:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0105113:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0105116:	0f 8e 74 ff ff ff    	jle    f0105090 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010511c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105120:	75 0d                	jne    f010512f <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0105122:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105125:	8b 02                	mov    (%edx),%eax
f0105127:	48                   	dec    %eax
f0105128:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f010512b:	89 01                	mov    %eax,(%ecx)
f010512d:	eb 2a                	jmp    f0105159 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010512f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105132:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105134:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105137:	8b 0a                	mov    (%edx),%ecx
f0105139:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f010513c:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f010513f:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105143:	eb 01                	jmp    f0105146 <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0105145:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0105146:	39 c8                	cmp    %ecx,%eax
f0105148:	7e 0a                	jle    f0105154 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f010514a:	0f b6 1a             	movzbl (%edx),%ebx
f010514d:	83 ea 0c             	sub    $0xc,%edx
f0105150:	39 f3                	cmp    %esi,%ebx
f0105152:	75 f1                	jne    f0105145 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f0105154:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0105157:	89 02                	mov    %eax,(%edx)
	}
}
f0105159:	83 c4 14             	add    $0x14,%esp
f010515c:	5b                   	pop    %ebx
f010515d:	5e                   	pop    %esi
f010515e:	5f                   	pop    %edi
f010515f:	5d                   	pop    %ebp
f0105160:	c3                   	ret    

f0105161 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0105161:	55                   	push   %ebp
f0105162:	89 e5                	mov    %esp,%ebp
f0105164:	57                   	push   %edi
f0105165:	56                   	push   %esi
f0105166:	53                   	push   %ebx
f0105167:	83 ec 3c             	sub    $0x3c,%esp
f010516a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010516d:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0105170:	c7 06 64 7e 10 f0    	movl   $0xf0107e64,(%esi)
	info->eip_line = 0;
f0105176:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010517d:	c7 46 08 64 7e 10 f0 	movl   $0xf0107e64,0x8(%esi)
	info->eip_fn_namelen = 9;
f0105184:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f010518b:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010518e:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0105195:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f010519b:	77 22                	ja     f01051bf <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010519d:	8b 1d 00 00 20 00    	mov    0x200000,%ebx
f01051a3:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
		stab_end = usd->stab_end;
f01051a6:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01051ab:	8b 1d 08 00 20 00    	mov    0x200008,%ebx
f01051b1:	89 5d cc             	mov    %ebx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f01051b4:	8b 1d 0c 00 20 00    	mov    0x20000c,%ebx
f01051ba:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f01051bd:	eb 1a                	jmp    f01051d9 <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01051bf:	c7 45 d0 f6 dc 11 f0 	movl   $0xf011dcf6,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01051c6:	c7 45 cc b1 31 11 f0 	movl   $0xf01131b1,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01051cd:	b8 b0 31 11 f0       	mov    $0xf01131b0,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01051d2:	c7 45 d4 10 84 10 f0 	movl   $0xf0108410,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01051d9:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f01051dc:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f01051df:	0f 83 24 01 00 00    	jae    f0105309 <debuginfo_eip+0x1a8>
f01051e5:	80 7b ff 00          	cmpb   $0x0,-0x1(%ebx)
f01051e9:	0f 85 21 01 00 00    	jne    f0105310 <debuginfo_eip+0x1af>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01051ef:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01051f6:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f01051f9:	c1 f8 02             	sar    $0x2,%eax
f01051fc:	8d 14 80             	lea    (%eax,%eax,4),%edx
f01051ff:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105202:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0105205:	89 d1                	mov    %edx,%ecx
f0105207:	c1 e1 08             	shl    $0x8,%ecx
f010520a:	01 ca                	add    %ecx,%edx
f010520c:	89 d1                	mov    %edx,%ecx
f010520e:	c1 e1 10             	shl    $0x10,%ecx
f0105211:	01 ca                	add    %ecx,%edx
f0105213:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f0105217:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010521a:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010521e:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0105225:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0105228:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010522b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010522e:	e8 35 fe ff ff       	call   f0105068 <stab_binsearch>
	if (lfile == 0)
f0105233:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105236:	85 c0                	test   %eax,%eax
f0105238:	0f 84 d9 00 00 00    	je     f0105317 <debuginfo_eip+0x1b6>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010523e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105241:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105244:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105247:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010524b:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0105252:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0105255:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105258:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010525b:	e8 08 fe ff ff       	call   f0105068 <stab_binsearch>

	if (lfun <= rfun) {
f0105260:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0105263:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0105266:	7f 23                	jg     f010528b <debuginfo_eip+0x12a>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0105268:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010526b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010526e:	8d 04 82             	lea    (%edx,%eax,4),%eax
f0105271:	8b 10                	mov    (%eax),%edx
f0105273:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0105276:	2b 4d cc             	sub    -0x34(%ebp),%ecx
f0105279:	39 ca                	cmp    %ecx,%edx
f010527b:	73 06                	jae    f0105283 <debuginfo_eip+0x122>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010527d:	03 55 cc             	add    -0x34(%ebp),%edx
f0105280:	89 56 08             	mov    %edx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f0105283:	8b 40 08             	mov    0x8(%eax),%eax
f0105286:	89 46 10             	mov    %eax,0x10(%esi)
f0105289:	eb 06                	jmp    f0105291 <debuginfo_eip+0x130>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f010528b:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f010528e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0105291:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0105298:	00 
f0105299:	8b 46 08             	mov    0x8(%esi),%eax
f010529c:	89 04 24             	mov    %eax,(%esp)
f010529f:	e8 42 08 00 00       	call   f0105ae6 <strfind>
f01052a4:	2b 46 08             	sub    0x8(%esi),%eax
f01052a7:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01052aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01052ad:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01052b0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01052b3:	8d 44 82 08          	lea    0x8(%edx,%eax,4),%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01052b7:	eb 04                	jmp    f01052bd <debuginfo_eip+0x15c>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01052b9:	4b                   	dec    %ebx
f01052ba:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01052bd:	39 fb                	cmp    %edi,%ebx
f01052bf:	7c 19                	jl     f01052da <debuginfo_eip+0x179>
	       && stabs[lline].n_type != N_SOL
f01052c1:	8a 50 fc             	mov    -0x4(%eax),%dl
f01052c4:	80 fa 84             	cmp    $0x84,%dl
f01052c7:	74 69                	je     f0105332 <debuginfo_eip+0x1d1>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01052c9:	80 fa 64             	cmp    $0x64,%dl
f01052cc:	75 eb                	jne    f01052b9 <debuginfo_eip+0x158>
f01052ce:	83 38 00             	cmpl   $0x0,(%eax)
f01052d1:	74 e6                	je     f01052b9 <debuginfo_eip+0x158>
f01052d3:	eb 5d                	jmp    f0105332 <debuginfo_eip+0x1d1>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01052d5:	03 45 cc             	add    -0x34(%ebp),%eax
f01052d8:	89 06                	mov    %eax,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052da:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01052dd:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f01052e0:	39 c8                	cmp    %ecx,%eax
f01052e2:	7d 3a                	jge    f010531e <debuginfo_eip+0x1bd>
		for (lline = lfun + 1;
f01052e4:	40                   	inc    %eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01052e5:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01052e8:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01052eb:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01052ef:	eb 04                	jmp    f01052f5 <debuginfo_eip+0x194>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01052f1:	ff 46 14             	incl   0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01052f4:	40                   	inc    %eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01052f5:	39 c8                	cmp    %ecx,%eax
f01052f7:	74 2c                	je     f0105325 <debuginfo_eip+0x1c4>
f01052f9:	83 c2 0c             	add    $0xc,%edx
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01052fc:	80 7a f4 a0          	cmpb   $0xa0,-0xc(%edx)
f0105300:	74 ef                	je     f01052f1 <debuginfo_eip+0x190>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0105302:	b8 00 00 00 00       	mov    $0x0,%eax
f0105307:	eb 21                	jmp    f010532a <debuginfo_eip+0x1c9>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0105309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010530e:	eb 1a                	jmp    f010532a <debuginfo_eip+0x1c9>
f0105310:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0105315:	eb 13                	jmp    f010532a <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0105317:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010531c:	eb 0c                	jmp    f010532a <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010531e:	b8 00 00 00 00       	mov    $0x0,%eax
f0105323:	eb 05                	jmp    f010532a <debuginfo_eip+0x1c9>
f0105325:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010532a:	83 c4 3c             	add    $0x3c,%esp
f010532d:	5b                   	pop    %ebx
f010532e:	5e                   	pop    %esi
f010532f:	5f                   	pop    %edi
f0105330:	5d                   	pop    %ebp
f0105331:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0105332:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0105335:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105338:	8b 04 83             	mov    (%ebx,%eax,4),%eax
f010533b:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010533e:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0105341:	39 d0                	cmp    %edx,%eax
f0105343:	72 90                	jb     f01052d5 <debuginfo_eip+0x174>
f0105345:	eb 93                	jmp    f01052da <debuginfo_eip+0x179>
	...

f0105348 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0105348:	55                   	push   %ebp
f0105349:	89 e5                	mov    %esp,%ebp
f010534b:	57                   	push   %edi
f010534c:	56                   	push   %esi
f010534d:	53                   	push   %ebx
f010534e:	83 ec 3c             	sub    $0x3c,%esp
f0105351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105354:	89 d7                	mov    %edx,%edi
f0105356:	8b 45 08             	mov    0x8(%ebp),%eax
f0105359:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010535c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010535f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105362:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0105365:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105368:	85 c0                	test   %eax,%eax
f010536a:	75 08                	jne    f0105374 <printnum+0x2c>
f010536c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010536f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0105372:	77 57                	ja     f01053cb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105374:	89 74 24 10          	mov    %esi,0x10(%esp)
f0105378:	4b                   	dec    %ebx
f0105379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010537d:	8b 45 10             	mov    0x10(%ebp),%eax
f0105380:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105384:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0105388:	8b 74 24 0c          	mov    0xc(%esp),%esi
f010538c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0105393:	00 
f0105394:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0105397:	89 04 24             	mov    %eax,(%esp)
f010539a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010539d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053a1:	e8 f6 11 00 00       	call   f010659c <__udivdi3>
f01053a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01053aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01053ae:	89 04 24             	mov    %eax,(%esp)
f01053b1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01053b5:	89 fa                	mov    %edi,%edx
f01053b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01053ba:	e8 89 ff ff ff       	call   f0105348 <printnum>
f01053bf:	eb 0f                	jmp    f01053d0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01053c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01053c5:	89 34 24             	mov    %esi,(%esp)
f01053c8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01053cb:	4b                   	dec    %ebx
f01053cc:	85 db                	test   %ebx,%ebx
f01053ce:	7f f1                	jg     f01053c1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01053d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01053d4:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01053d8:	8b 45 10             	mov    0x10(%ebp),%eax
f01053db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01053e6:	00 
f01053e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01053ea:	89 04 24             	mov    %eax,(%esp)
f01053ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01053f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01053f4:	e8 c3 12 00 00       	call   f01066bc <__umoddi3>
f01053f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01053fd:	0f be 80 6e 7e 10 f0 	movsbl -0xfef8192(%eax),%eax
f0105404:	89 04 24             	mov    %eax,(%esp)
f0105407:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010540a:	83 c4 3c             	add    $0x3c,%esp
f010540d:	5b                   	pop    %ebx
f010540e:	5e                   	pop    %esi
f010540f:	5f                   	pop    %edi
f0105410:	5d                   	pop    %ebp
f0105411:	c3                   	ret    

f0105412 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0105412:	55                   	push   %ebp
f0105413:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0105415:	83 fa 01             	cmp    $0x1,%edx
f0105418:	7e 0e                	jle    f0105428 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010541a:	8b 10                	mov    (%eax),%edx
f010541c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010541f:	89 08                	mov    %ecx,(%eax)
f0105421:	8b 02                	mov    (%edx),%eax
f0105423:	8b 52 04             	mov    0x4(%edx),%edx
f0105426:	eb 22                	jmp    f010544a <getuint+0x38>
	else if (lflag)
f0105428:	85 d2                	test   %edx,%edx
f010542a:	74 10                	je     f010543c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010542c:	8b 10                	mov    (%eax),%edx
f010542e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105431:	89 08                	mov    %ecx,(%eax)
f0105433:	8b 02                	mov    (%edx),%eax
f0105435:	ba 00 00 00 00       	mov    $0x0,%edx
f010543a:	eb 0e                	jmp    f010544a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010543c:	8b 10                	mov    (%eax),%edx
f010543e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0105441:	89 08                	mov    %ecx,(%eax)
f0105443:	8b 02                	mov    (%edx),%eax
f0105445:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010544a:	5d                   	pop    %ebp
f010544b:	c3                   	ret    

f010544c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010544c:	55                   	push   %ebp
f010544d:	89 e5                	mov    %esp,%ebp
f010544f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0105452:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0105455:	8b 10                	mov    (%eax),%edx
f0105457:	3b 50 04             	cmp    0x4(%eax),%edx
f010545a:	73 08                	jae    f0105464 <sprintputch+0x18>
		*b->buf++ = ch;
f010545c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010545f:	88 0a                	mov    %cl,(%edx)
f0105461:	42                   	inc    %edx
f0105462:	89 10                	mov    %edx,(%eax)
}
f0105464:	5d                   	pop    %ebp
f0105465:	c3                   	ret    

f0105466 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0105466:	55                   	push   %ebp
f0105467:	89 e5                	mov    %esp,%ebp
f0105469:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010546c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010546f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105473:	8b 45 10             	mov    0x10(%ebp),%eax
f0105476:	89 44 24 08          	mov    %eax,0x8(%esp)
f010547a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010547d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105481:	8b 45 08             	mov    0x8(%ebp),%eax
f0105484:	89 04 24             	mov    %eax,(%esp)
f0105487:	e8 02 00 00 00       	call   f010548e <vprintfmt>
	va_end(ap);
}
f010548c:	c9                   	leave  
f010548d:	c3                   	ret    

f010548e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010548e:	55                   	push   %ebp
f010548f:	89 e5                	mov    %esp,%ebp
f0105491:	57                   	push   %edi
f0105492:	56                   	push   %esi
f0105493:	53                   	push   %ebx
f0105494:	83 ec 4c             	sub    $0x4c,%esp
f0105497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010549a:	8b 75 10             	mov    0x10(%ebp),%esi
f010549d:	eb 12                	jmp    f01054b1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010549f:	85 c0                	test   %eax,%eax
f01054a1:	0f 84 8b 03 00 00    	je     f0105832 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
f01054a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01054ab:	89 04 24             	mov    %eax,(%esp)
f01054ae:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01054b1:	0f b6 06             	movzbl (%esi),%eax
f01054b4:	46                   	inc    %esi
f01054b5:	83 f8 25             	cmp    $0x25,%eax
f01054b8:	75 e5                	jne    f010549f <vprintfmt+0x11>
f01054ba:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01054be:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01054c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01054ca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01054d1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01054d6:	eb 26                	jmp    f01054fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054d8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01054db:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01054df:	eb 1d                	jmp    f01054fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01054e4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01054e8:	eb 14                	jmp    f01054fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01054ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01054f4:	eb 08                	jmp    f01054fe <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01054f6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01054f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01054fe:	0f b6 06             	movzbl (%esi),%eax
f0105501:	8d 56 01             	lea    0x1(%esi),%edx
f0105504:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0105507:	8a 16                	mov    (%esi),%dl
f0105509:	83 ea 23             	sub    $0x23,%edx
f010550c:	80 fa 55             	cmp    $0x55,%dl
f010550f:	0f 87 01 03 00 00    	ja     f0105816 <vprintfmt+0x388>
f0105515:	0f b6 d2             	movzbl %dl,%edx
f0105518:	ff 24 95 c0 7f 10 f0 	jmp    *-0xfef8040(,%edx,4)
f010551f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105522:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105527:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010552a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010552e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0105531:	8d 50 d0             	lea    -0x30(%eax),%edx
f0105534:	83 fa 09             	cmp    $0x9,%edx
f0105537:	77 2a                	ja     f0105563 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0105539:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010553a:	eb eb                	jmp    f0105527 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010553c:	8b 45 14             	mov    0x14(%ebp),%eax
f010553f:	8d 50 04             	lea    0x4(%eax),%edx
f0105542:	89 55 14             	mov    %edx,0x14(%ebp)
f0105545:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105547:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010554a:	eb 17                	jmp    f0105563 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f010554c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105550:	78 98                	js     f01054ea <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105552:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0105555:	eb a7                	jmp    f01054fe <vprintfmt+0x70>
f0105557:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010555a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0105561:	eb 9b                	jmp    f01054fe <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0105563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105567:	79 95                	jns    f01054fe <vprintfmt+0x70>
f0105569:	eb 8b                	jmp    f01054f6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010556b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010556c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010556f:	eb 8d                	jmp    f01054fe <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0105571:	8b 45 14             	mov    0x14(%ebp),%eax
f0105574:	8d 50 04             	lea    0x4(%eax),%edx
f0105577:	89 55 14             	mov    %edx,0x14(%ebp)
f010557a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010557e:	8b 00                	mov    (%eax),%eax
f0105580:	89 04 24             	mov    %eax,(%esp)
f0105583:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0105586:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0105589:	e9 23 ff ff ff       	jmp    f01054b1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010558e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105591:	8d 50 04             	lea    0x4(%eax),%edx
f0105594:	89 55 14             	mov    %edx,0x14(%ebp)
f0105597:	8b 00                	mov    (%eax),%eax
f0105599:	85 c0                	test   %eax,%eax
f010559b:	79 02                	jns    f010559f <vprintfmt+0x111>
f010559d:	f7 d8                	neg    %eax
f010559f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01055a1:	83 f8 0f             	cmp    $0xf,%eax
f01055a4:	7f 0b                	jg     f01055b1 <vprintfmt+0x123>
f01055a6:	8b 04 85 20 81 10 f0 	mov    -0xfef7ee0(,%eax,4),%eax
f01055ad:	85 c0                	test   %eax,%eax
f01055af:	75 23                	jne    f01055d4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01055b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01055b5:	c7 44 24 08 86 7e 10 	movl   $0xf0107e86,0x8(%esp)
f01055bc:	f0 
f01055bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01055c4:	89 04 24             	mov    %eax,(%esp)
f01055c7:	e8 9a fe ff ff       	call   f0105466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01055cf:	e9 dd fe ff ff       	jmp    f01054b1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01055d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01055d8:	c7 44 24 08 e4 76 10 	movl   $0xf01076e4,0x8(%esp)
f01055df:	f0 
f01055e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01055e4:	8b 55 08             	mov    0x8(%ebp),%edx
f01055e7:	89 14 24             	mov    %edx,(%esp)
f01055ea:	e8 77 fe ff ff       	call   f0105466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01055ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01055f2:	e9 ba fe ff ff       	jmp    f01054b1 <vprintfmt+0x23>
f01055f7:	89 f9                	mov    %edi,%ecx
f01055f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01055fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01055ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0105602:	8d 50 04             	lea    0x4(%eax),%edx
f0105605:	89 55 14             	mov    %edx,0x14(%ebp)
f0105608:	8b 30                	mov    (%eax),%esi
f010560a:	85 f6                	test   %esi,%esi
f010560c:	75 05                	jne    f0105613 <vprintfmt+0x185>
				p = "(null)";
f010560e:	be 7f 7e 10 f0       	mov    $0xf0107e7f,%esi
			if (width > 0 && padc != '-')
f0105613:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0105617:	0f 8e 84 00 00 00    	jle    f01056a1 <vprintfmt+0x213>
f010561d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0105621:	74 7e                	je     f01056a1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105623:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0105627:	89 34 24             	mov    %esi,(%esp)
f010562a:	e8 83 03 00 00       	call   f01059b2 <strnlen>
f010562f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0105632:	29 c2                	sub    %eax,%edx
f0105634:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0105637:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010563b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010563e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0105641:	89 de                	mov    %ebx,%esi
f0105643:	89 d3                	mov    %edx,%ebx
f0105645:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105647:	eb 0b                	jmp    f0105654 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0105649:	89 74 24 04          	mov    %esi,0x4(%esp)
f010564d:	89 3c 24             	mov    %edi,(%esp)
f0105650:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0105653:	4b                   	dec    %ebx
f0105654:	85 db                	test   %ebx,%ebx
f0105656:	7f f1                	jg     f0105649 <vprintfmt+0x1bb>
f0105658:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010565b:	89 f3                	mov    %esi,%ebx
f010565d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0105660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105663:	85 c0                	test   %eax,%eax
f0105665:	79 05                	jns    f010566c <vprintfmt+0x1de>
f0105667:	b8 00 00 00 00       	mov    $0x0,%eax
f010566c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010566f:	29 c2                	sub    %eax,%edx
f0105671:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0105674:	eb 2b                	jmp    f01056a1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105676:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010567a:	74 18                	je     f0105694 <vprintfmt+0x206>
f010567c:	8d 50 e0             	lea    -0x20(%eax),%edx
f010567f:	83 fa 5e             	cmp    $0x5e,%edx
f0105682:	76 10                	jbe    f0105694 <vprintfmt+0x206>
					putch('?', putdat);
f0105684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105688:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010568f:	ff 55 08             	call   *0x8(%ebp)
f0105692:	eb 0a                	jmp    f010569e <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0105694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105698:	89 04 24             	mov    %eax,(%esp)
f010569b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010569e:	ff 4d e4             	decl   -0x1c(%ebp)
f01056a1:	0f be 06             	movsbl (%esi),%eax
f01056a4:	46                   	inc    %esi
f01056a5:	85 c0                	test   %eax,%eax
f01056a7:	74 21                	je     f01056ca <vprintfmt+0x23c>
f01056a9:	85 ff                	test   %edi,%edi
f01056ab:	78 c9                	js     f0105676 <vprintfmt+0x1e8>
f01056ad:	4f                   	dec    %edi
f01056ae:	79 c6                	jns    f0105676 <vprintfmt+0x1e8>
f01056b0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056b3:	89 de                	mov    %ebx,%esi
f01056b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01056b8:	eb 18                	jmp    f01056d2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01056ba:	89 74 24 04          	mov    %esi,0x4(%esp)
f01056be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01056c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01056c7:	4b                   	dec    %ebx
f01056c8:	eb 08                	jmp    f01056d2 <vprintfmt+0x244>
f01056ca:	8b 7d 08             	mov    0x8(%ebp),%edi
f01056cd:	89 de                	mov    %ebx,%esi
f01056cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01056d2:	85 db                	test   %ebx,%ebx
f01056d4:	7f e4                	jg     f01056ba <vprintfmt+0x22c>
f01056d6:	89 7d 08             	mov    %edi,0x8(%ebp)
f01056d9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01056db:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01056de:	e9 ce fd ff ff       	jmp    f01054b1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01056e3:	83 f9 01             	cmp    $0x1,%ecx
f01056e6:	7e 10                	jle    f01056f8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f01056e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01056eb:	8d 50 08             	lea    0x8(%eax),%edx
f01056ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01056f1:	8b 30                	mov    (%eax),%esi
f01056f3:	8b 78 04             	mov    0x4(%eax),%edi
f01056f6:	eb 26                	jmp    f010571e <vprintfmt+0x290>
	else if (lflag)
f01056f8:	85 c9                	test   %ecx,%ecx
f01056fa:	74 12                	je     f010570e <vprintfmt+0x280>
		return va_arg(*ap, long);
f01056fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01056ff:	8d 50 04             	lea    0x4(%eax),%edx
f0105702:	89 55 14             	mov    %edx,0x14(%ebp)
f0105705:	8b 30                	mov    (%eax),%esi
f0105707:	89 f7                	mov    %esi,%edi
f0105709:	c1 ff 1f             	sar    $0x1f,%edi
f010570c:	eb 10                	jmp    f010571e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010570e:	8b 45 14             	mov    0x14(%ebp),%eax
f0105711:	8d 50 04             	lea    0x4(%eax),%edx
f0105714:	89 55 14             	mov    %edx,0x14(%ebp)
f0105717:	8b 30                	mov    (%eax),%esi
f0105719:	89 f7                	mov    %esi,%edi
f010571b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010571e:	85 ff                	test   %edi,%edi
f0105720:	78 0a                	js     f010572c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0105722:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105727:	e9 ac 00 00 00       	jmp    f01057d8 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010572c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105730:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0105737:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010573a:	f7 de                	neg    %esi
f010573c:	83 d7 00             	adc    $0x0,%edi
f010573f:	f7 df                	neg    %edi
			}
			base = 10;
f0105741:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105746:	e9 8d 00 00 00       	jmp    f01057d8 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010574b:	89 ca                	mov    %ecx,%edx
f010574d:	8d 45 14             	lea    0x14(%ebp),%eax
f0105750:	e8 bd fc ff ff       	call   f0105412 <getuint>
f0105755:	89 c6                	mov    %eax,%esi
f0105757:	89 d7                	mov    %edx,%edi
			base = 10;
f0105759:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010575e:	eb 78                	jmp    f01057d8 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0105760:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105764:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f010576b:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010576e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105772:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105779:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
f010577c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105780:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105787:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010578a:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f010578d:	e9 1f fd ff ff       	jmp    f01054b1 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
f0105792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105796:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010579d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01057a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01057a4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01057ab:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01057ae:	8b 45 14             	mov    0x14(%ebp),%eax
f01057b1:	8d 50 04             	lea    0x4(%eax),%edx
f01057b4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01057b7:	8b 30                	mov    (%eax),%esi
f01057b9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01057be:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01057c3:	eb 13                	jmp    f01057d8 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01057c5:	89 ca                	mov    %ecx,%edx
f01057c7:	8d 45 14             	lea    0x14(%ebp),%eax
f01057ca:	e8 43 fc ff ff       	call   f0105412 <getuint>
f01057cf:	89 c6                	mov    %eax,%esi
f01057d1:	89 d7                	mov    %edx,%edi
			base = 16;
f01057d3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01057d8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01057dc:	89 54 24 10          	mov    %edx,0x10(%esp)
f01057e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01057e3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01057e7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01057eb:	89 34 24             	mov    %esi,(%esp)
f01057ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057f2:	89 da                	mov    %ebx,%edx
f01057f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01057f7:	e8 4c fb ff ff       	call   f0105348 <printnum>
			break;
f01057fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01057ff:	e9 ad fc ff ff       	jmp    f01054b1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105804:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0105808:	89 04 24             	mov    %eax,(%esp)
f010580b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010580e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105811:	e9 9b fc ff ff       	jmp    f01054b1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105816:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010581a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105821:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105824:	eb 01                	jmp    f0105827 <vprintfmt+0x399>
f0105826:	4e                   	dec    %esi
f0105827:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010582b:	75 f9                	jne    f0105826 <vprintfmt+0x398>
f010582d:	e9 7f fc ff ff       	jmp    f01054b1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0105832:	83 c4 4c             	add    $0x4c,%esp
f0105835:	5b                   	pop    %ebx
f0105836:	5e                   	pop    %esi
f0105837:	5f                   	pop    %edi
f0105838:	5d                   	pop    %ebp
f0105839:	c3                   	ret    

f010583a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010583a:	55                   	push   %ebp
f010583b:	89 e5                	mov    %esp,%ebp
f010583d:	83 ec 28             	sub    $0x28,%esp
f0105840:	8b 45 08             	mov    0x8(%ebp),%eax
f0105843:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105846:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0105849:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010584d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105850:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0105857:	85 c0                	test   %eax,%eax
f0105859:	74 30                	je     f010588b <vsnprintf+0x51>
f010585b:	85 d2                	test   %edx,%edx
f010585d:	7e 33                	jle    f0105892 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010585f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105862:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105866:	8b 45 10             	mov    0x10(%ebp),%eax
f0105869:	89 44 24 08          	mov    %eax,0x8(%esp)
f010586d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0105870:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105874:	c7 04 24 4c 54 10 f0 	movl   $0xf010544c,(%esp)
f010587b:	e8 0e fc ff ff       	call   f010548e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105880:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0105883:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105886:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105889:	eb 0c                	jmp    f0105897 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010588b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105890:	eb 05                	jmp    f0105897 <vsnprintf+0x5d>
f0105892:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0105897:	c9                   	leave  
f0105898:	c3                   	ret    

f0105899 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105899:	55                   	push   %ebp
f010589a:	89 e5                	mov    %esp,%ebp
f010589c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010589f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01058a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058a6:	8b 45 10             	mov    0x10(%ebp),%eax
f01058a9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01058ad:	8b 45 0c             	mov    0xc(%ebp),%eax
f01058b0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058b4:	8b 45 08             	mov    0x8(%ebp),%eax
f01058b7:	89 04 24             	mov    %eax,(%esp)
f01058ba:	e8 7b ff ff ff       	call   f010583a <vsnprintf>
	va_end(ap);

	return rc;
}
f01058bf:	c9                   	leave  
f01058c0:	c3                   	ret    
f01058c1:	00 00                	add    %al,(%eax)
	...

f01058c4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01058c4:	55                   	push   %ebp
f01058c5:	89 e5                	mov    %esp,%ebp
f01058c7:	57                   	push   %edi
f01058c8:	56                   	push   %esi
f01058c9:	53                   	push   %ebx
f01058ca:	83 ec 1c             	sub    $0x1c,%esp
f01058cd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f01058d0:	85 c0                	test   %eax,%eax
f01058d2:	74 10                	je     f01058e4 <readline+0x20>
		cprintf("%s", prompt);
f01058d4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01058d8:	c7 04 24 e4 76 10 f0 	movl   $0xf01076e4,(%esp)
f01058df:	e8 66 e3 ff ff       	call   f0103c4a <cprintf>
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f01058e4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01058eb:	e8 bb ae ff ff       	call   f01007ab <iscons>
f01058f0:	89 c7                	mov    %eax,%edi
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f01058f2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01058f7:	e8 9e ae ff ff       	call   f010079a <getchar>
f01058fc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01058fe:	85 c0                	test   %eax,%eax
f0105900:	79 20                	jns    f0105922 <readline+0x5e>
			if (c != -E_EOF)
f0105902:	83 f8 f8             	cmp    $0xfffffff8,%eax
f0105905:	0f 84 82 00 00 00    	je     f010598d <readline+0xc9>
				cprintf("read error: %e\n", c);
f010590b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010590f:	c7 04 24 7f 81 10 f0 	movl   $0xf010817f,(%esp)
f0105916:	e8 2f e3 ff ff       	call   f0103c4a <cprintf>
			return NULL;
f010591b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105920:	eb 70                	jmp    f0105992 <readline+0xce>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105922:	83 f8 08             	cmp    $0x8,%eax
f0105925:	74 05                	je     f010592c <readline+0x68>
f0105927:	83 f8 7f             	cmp    $0x7f,%eax
f010592a:	75 17                	jne    f0105943 <readline+0x7f>
f010592c:	85 f6                	test   %esi,%esi
f010592e:	7e 13                	jle    f0105943 <readline+0x7f>
			if (echoing)
f0105930:	85 ff                	test   %edi,%edi
f0105932:	74 0c                	je     f0105940 <readline+0x7c>
				cputchar('\b');
f0105934:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f010593b:	e8 4a ae ff ff       	call   f010078a <cputchar>
			i--;
f0105940:	4e                   	dec    %esi
f0105941:	eb b4                	jmp    f01058f7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105943:	83 fb 1f             	cmp    $0x1f,%ebx
f0105946:	7e 1d                	jle    f0105965 <readline+0xa1>
f0105948:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010594e:	7f 15                	jg     f0105965 <readline+0xa1>
			if (echoing)
f0105950:	85 ff                	test   %edi,%edi
f0105952:	74 08                	je     f010595c <readline+0x98>
				cputchar(c);
f0105954:	89 1c 24             	mov    %ebx,(%esp)
f0105957:	e8 2e ae ff ff       	call   f010078a <cputchar>
			buf[i++] = c;
f010595c:	88 9e 80 2a 22 f0    	mov    %bl,-0xfddd580(%esi)
f0105962:	46                   	inc    %esi
f0105963:	eb 92                	jmp    f01058f7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105965:	83 fb 0a             	cmp    $0xa,%ebx
f0105968:	74 05                	je     f010596f <readline+0xab>
f010596a:	83 fb 0d             	cmp    $0xd,%ebx
f010596d:	75 88                	jne    f01058f7 <readline+0x33>
			if (echoing)
f010596f:	85 ff                	test   %edi,%edi
f0105971:	74 0c                	je     f010597f <readline+0xbb>
				cputchar('\n');
f0105973:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010597a:	e8 0b ae ff ff       	call   f010078a <cputchar>
			buf[i] = 0;
f010597f:	c6 86 80 2a 22 f0 00 	movb   $0x0,-0xfddd580(%esi)
			return buf;
f0105986:	b8 80 2a 22 f0       	mov    $0xf0222a80,%eax
f010598b:	eb 05                	jmp    f0105992 <readline+0xce>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f010598d:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f0105992:	83 c4 1c             	add    $0x1c,%esp
f0105995:	5b                   	pop    %ebx
f0105996:	5e                   	pop    %esi
f0105997:	5f                   	pop    %edi
f0105998:	5d                   	pop    %ebp
f0105999:	c3                   	ret    
	...

f010599c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010599c:	55                   	push   %ebp
f010599d:	89 e5                	mov    %esp,%ebp
f010599f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01059a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01059a7:	eb 01                	jmp    f01059aa <strlen+0xe>
		n++;
f01059a9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01059aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01059ae:	75 f9                	jne    f01059a9 <strlen+0xd>
		n++;
	return n;
}
f01059b0:	5d                   	pop    %ebp
f01059b1:	c3                   	ret    

f01059b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01059b2:	55                   	push   %ebp
f01059b3:	89 e5                	mov    %esp,%ebp
f01059b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01059b8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01059bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01059c0:	eb 01                	jmp    f01059c3 <strnlen+0x11>
		n++;
f01059c2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01059c3:	39 d0                	cmp    %edx,%eax
f01059c5:	74 06                	je     f01059cd <strnlen+0x1b>
f01059c7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01059cb:	75 f5                	jne    f01059c2 <strnlen+0x10>
		n++;
	return n;
}
f01059cd:	5d                   	pop    %ebp
f01059ce:	c3                   	ret    

f01059cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01059cf:	55                   	push   %ebp
f01059d0:	89 e5                	mov    %esp,%ebp
f01059d2:	53                   	push   %ebx
f01059d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01059d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01059d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01059de:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01059e1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01059e4:	42                   	inc    %edx
f01059e5:	84 c9                	test   %cl,%cl
f01059e7:	75 f5                	jne    f01059de <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01059e9:	5b                   	pop    %ebx
f01059ea:	5d                   	pop    %ebp
f01059eb:	c3                   	ret    

f01059ec <strcat>:

char *
strcat(char *dst, const char *src)
{
f01059ec:	55                   	push   %ebp
f01059ed:	89 e5                	mov    %esp,%ebp
f01059ef:	53                   	push   %ebx
f01059f0:	83 ec 08             	sub    $0x8,%esp
f01059f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01059f6:	89 1c 24             	mov    %ebx,(%esp)
f01059f9:	e8 9e ff ff ff       	call   f010599c <strlen>
	strcpy(dst + len, src);
f01059fe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a01:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105a05:	01 d8                	add    %ebx,%eax
f0105a07:	89 04 24             	mov    %eax,(%esp)
f0105a0a:	e8 c0 ff ff ff       	call   f01059cf <strcpy>
	return dst;
}
f0105a0f:	89 d8                	mov    %ebx,%eax
f0105a11:	83 c4 08             	add    $0x8,%esp
f0105a14:	5b                   	pop    %ebx
f0105a15:	5d                   	pop    %ebp
f0105a16:	c3                   	ret    

f0105a17 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105a17:	55                   	push   %ebp
f0105a18:	89 e5                	mov    %esp,%ebp
f0105a1a:	56                   	push   %esi
f0105a1b:	53                   	push   %ebx
f0105a1c:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a1f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a22:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105a25:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a2a:	eb 0c                	jmp    f0105a38 <strncpy+0x21>
		*dst++ = *src;
f0105a2c:	8a 1a                	mov    (%edx),%bl
f0105a2e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105a31:	80 3a 01             	cmpb   $0x1,(%edx)
f0105a34:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105a37:	41                   	inc    %ecx
f0105a38:	39 f1                	cmp    %esi,%ecx
f0105a3a:	75 f0                	jne    f0105a2c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105a3c:	5b                   	pop    %ebx
f0105a3d:	5e                   	pop    %esi
f0105a3e:	5d                   	pop    %ebp
f0105a3f:	c3                   	ret    

f0105a40 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a40:	55                   	push   %ebp
f0105a41:	89 e5                	mov    %esp,%ebp
f0105a43:	56                   	push   %esi
f0105a44:	53                   	push   %ebx
f0105a45:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105a4b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a4e:	85 d2                	test   %edx,%edx
f0105a50:	75 0a                	jne    f0105a5c <strlcpy+0x1c>
f0105a52:	89 f0                	mov    %esi,%eax
f0105a54:	eb 1a                	jmp    f0105a70 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0105a56:	88 18                	mov    %bl,(%eax)
f0105a58:	40                   	inc    %eax
f0105a59:	41                   	inc    %ecx
f0105a5a:	eb 02                	jmp    f0105a5e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a5c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0105a5e:	4a                   	dec    %edx
f0105a5f:	74 0a                	je     f0105a6b <strlcpy+0x2b>
f0105a61:	8a 19                	mov    (%ecx),%bl
f0105a63:	84 db                	test   %bl,%bl
f0105a65:	75 ef                	jne    f0105a56 <strlcpy+0x16>
f0105a67:	89 c2                	mov    %eax,%edx
f0105a69:	eb 02                	jmp    f0105a6d <strlcpy+0x2d>
f0105a6b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0105a6d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0105a70:	29 f0                	sub    %esi,%eax
}
f0105a72:	5b                   	pop    %ebx
f0105a73:	5e                   	pop    %esi
f0105a74:	5d                   	pop    %ebp
f0105a75:	c3                   	ret    

f0105a76 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105a76:	55                   	push   %ebp
f0105a77:	89 e5                	mov    %esp,%ebp
f0105a79:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105a7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105a7f:	eb 02                	jmp    f0105a83 <strcmp+0xd>
		p++, q++;
f0105a81:	41                   	inc    %ecx
f0105a82:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0105a83:	8a 01                	mov    (%ecx),%al
f0105a85:	84 c0                	test   %al,%al
f0105a87:	74 04                	je     f0105a8d <strcmp+0x17>
f0105a89:	3a 02                	cmp    (%edx),%al
f0105a8b:	74 f4                	je     f0105a81 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105a8d:	0f b6 c0             	movzbl %al,%eax
f0105a90:	0f b6 12             	movzbl (%edx),%edx
f0105a93:	29 d0                	sub    %edx,%eax
}
f0105a95:	5d                   	pop    %ebp
f0105a96:	c3                   	ret    

f0105a97 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105a97:	55                   	push   %ebp
f0105a98:	89 e5                	mov    %esp,%ebp
f0105a9a:	53                   	push   %ebx
f0105a9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0105a9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105aa1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0105aa4:	eb 03                	jmp    f0105aa9 <strncmp+0x12>
		n--, p++, q++;
f0105aa6:	4a                   	dec    %edx
f0105aa7:	40                   	inc    %eax
f0105aa8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105aa9:	85 d2                	test   %edx,%edx
f0105aab:	74 14                	je     f0105ac1 <strncmp+0x2a>
f0105aad:	8a 18                	mov    (%eax),%bl
f0105aaf:	84 db                	test   %bl,%bl
f0105ab1:	74 04                	je     f0105ab7 <strncmp+0x20>
f0105ab3:	3a 19                	cmp    (%ecx),%bl
f0105ab5:	74 ef                	je     f0105aa6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ab7:	0f b6 00             	movzbl (%eax),%eax
f0105aba:	0f b6 11             	movzbl (%ecx),%edx
f0105abd:	29 d0                	sub    %edx,%eax
f0105abf:	eb 05                	jmp    f0105ac6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105ac1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105ac6:	5b                   	pop    %ebx
f0105ac7:	5d                   	pop    %ebp
f0105ac8:	c3                   	ret    

f0105ac9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105ac9:	55                   	push   %ebp
f0105aca:	89 e5                	mov    %esp,%ebp
f0105acc:	8b 45 08             	mov    0x8(%ebp),%eax
f0105acf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105ad2:	eb 05                	jmp    f0105ad9 <strchr+0x10>
		if (*s == c)
f0105ad4:	38 ca                	cmp    %cl,%dl
f0105ad6:	74 0c                	je     f0105ae4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105ad8:	40                   	inc    %eax
f0105ad9:	8a 10                	mov    (%eax),%dl
f0105adb:	84 d2                	test   %dl,%dl
f0105add:	75 f5                	jne    f0105ad4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0105adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105ae4:	5d                   	pop    %ebp
f0105ae5:	c3                   	ret    

f0105ae6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105ae6:	55                   	push   %ebp
f0105ae7:	89 e5                	mov    %esp,%ebp
f0105ae9:	8b 45 08             	mov    0x8(%ebp),%eax
f0105aec:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0105aef:	eb 05                	jmp    f0105af6 <strfind+0x10>
		if (*s == c)
f0105af1:	38 ca                	cmp    %cl,%dl
f0105af3:	74 07                	je     f0105afc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0105af5:	40                   	inc    %eax
f0105af6:	8a 10                	mov    (%eax),%dl
f0105af8:	84 d2                	test   %dl,%dl
f0105afa:	75 f5                	jne    f0105af1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0105afc:	5d                   	pop    %ebp
f0105afd:	c3                   	ret    

f0105afe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105afe:	55                   	push   %ebp
f0105aff:	89 e5                	mov    %esp,%ebp
f0105b01:	57                   	push   %edi
f0105b02:	56                   	push   %esi
f0105b03:	53                   	push   %ebx
f0105b04:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b07:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105b0d:	85 c9                	test   %ecx,%ecx
f0105b0f:	74 30                	je     f0105b41 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105b11:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105b17:	75 25                	jne    f0105b3e <memset+0x40>
f0105b19:	f6 c1 03             	test   $0x3,%cl
f0105b1c:	75 20                	jne    f0105b3e <memset+0x40>
		c &= 0xFF;
f0105b1e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b21:	89 d3                	mov    %edx,%ebx
f0105b23:	c1 e3 08             	shl    $0x8,%ebx
f0105b26:	89 d6                	mov    %edx,%esi
f0105b28:	c1 e6 18             	shl    $0x18,%esi
f0105b2b:	89 d0                	mov    %edx,%eax
f0105b2d:	c1 e0 10             	shl    $0x10,%eax
f0105b30:	09 f0                	or     %esi,%eax
f0105b32:	09 d0                	or     %edx,%eax
f0105b34:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105b36:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0105b39:	fc                   	cld    
f0105b3a:	f3 ab                	rep stos %eax,%es:(%edi)
f0105b3c:	eb 03                	jmp    f0105b41 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105b3e:	fc                   	cld    
f0105b3f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105b41:	89 f8                	mov    %edi,%eax
f0105b43:	5b                   	pop    %ebx
f0105b44:	5e                   	pop    %esi
f0105b45:	5f                   	pop    %edi
f0105b46:	5d                   	pop    %ebp
f0105b47:	c3                   	ret    

f0105b48 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105b48:	55                   	push   %ebp
f0105b49:	89 e5                	mov    %esp,%ebp
f0105b4b:	57                   	push   %edi
f0105b4c:	56                   	push   %esi
f0105b4d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b50:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105b53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105b56:	39 c6                	cmp    %eax,%esi
f0105b58:	73 34                	jae    f0105b8e <memmove+0x46>
f0105b5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105b5d:	39 d0                	cmp    %edx,%eax
f0105b5f:	73 2d                	jae    f0105b8e <memmove+0x46>
		s += n;
		d += n;
f0105b61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b64:	f6 c2 03             	test   $0x3,%dl
f0105b67:	75 1b                	jne    f0105b84 <memmove+0x3c>
f0105b69:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105b6f:	75 13                	jne    f0105b84 <memmove+0x3c>
f0105b71:	f6 c1 03             	test   $0x3,%cl
f0105b74:	75 0e                	jne    f0105b84 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105b76:	83 ef 04             	sub    $0x4,%edi
f0105b79:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105b7c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105b7f:	fd                   	std    
f0105b80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105b82:	eb 07                	jmp    f0105b8b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105b84:	4f                   	dec    %edi
f0105b85:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0105b88:	fd                   	std    
f0105b89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105b8b:	fc                   	cld    
f0105b8c:	eb 20                	jmp    f0105bae <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105b8e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105b94:	75 13                	jne    f0105ba9 <memmove+0x61>
f0105b96:	a8 03                	test   $0x3,%al
f0105b98:	75 0f                	jne    f0105ba9 <memmove+0x61>
f0105b9a:	f6 c1 03             	test   $0x3,%cl
f0105b9d:	75 0a                	jne    f0105ba9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105b9f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105ba2:	89 c7                	mov    %eax,%edi
f0105ba4:	fc                   	cld    
f0105ba5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105ba7:	eb 05                	jmp    f0105bae <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105ba9:	89 c7                	mov    %eax,%edi
f0105bab:	fc                   	cld    
f0105bac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105bae:	5e                   	pop    %esi
f0105baf:	5f                   	pop    %edi
f0105bb0:	5d                   	pop    %ebp
f0105bb1:	c3                   	ret    

f0105bb2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105bb2:	55                   	push   %ebp
f0105bb3:	89 e5                	mov    %esp,%ebp
f0105bb5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105bb8:	8b 45 10             	mov    0x10(%ebp),%eax
f0105bbb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105bbf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105bc2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105bc6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105bc9:	89 04 24             	mov    %eax,(%esp)
f0105bcc:	e8 77 ff ff ff       	call   f0105b48 <memmove>
}
f0105bd1:	c9                   	leave  
f0105bd2:	c3                   	ret    

f0105bd3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105bd3:	55                   	push   %ebp
f0105bd4:	89 e5                	mov    %esp,%ebp
f0105bd6:	57                   	push   %edi
f0105bd7:	56                   	push   %esi
f0105bd8:	53                   	push   %ebx
f0105bd9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105bdc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105bdf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105be2:	ba 00 00 00 00       	mov    $0x0,%edx
f0105be7:	eb 16                	jmp    f0105bff <memcmp+0x2c>
		if (*s1 != *s2)
f0105be9:	8a 04 17             	mov    (%edi,%edx,1),%al
f0105bec:	42                   	inc    %edx
f0105bed:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0105bf1:	38 c8                	cmp    %cl,%al
f0105bf3:	74 0a                	je     f0105bff <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0105bf5:	0f b6 c0             	movzbl %al,%eax
f0105bf8:	0f b6 c9             	movzbl %cl,%ecx
f0105bfb:	29 c8                	sub    %ecx,%eax
f0105bfd:	eb 09                	jmp    f0105c08 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105bff:	39 da                	cmp    %ebx,%edx
f0105c01:	75 e6                	jne    f0105be9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105c03:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c08:	5b                   	pop    %ebx
f0105c09:	5e                   	pop    %esi
f0105c0a:	5f                   	pop    %edi
f0105c0b:	5d                   	pop    %ebp
f0105c0c:	c3                   	ret    

f0105c0d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105c0d:	55                   	push   %ebp
f0105c0e:	89 e5                	mov    %esp,%ebp
f0105c10:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105c16:	89 c2                	mov    %eax,%edx
f0105c18:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105c1b:	eb 05                	jmp    f0105c22 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105c1d:	38 08                	cmp    %cl,(%eax)
f0105c1f:	74 05                	je     f0105c26 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105c21:	40                   	inc    %eax
f0105c22:	39 d0                	cmp    %edx,%eax
f0105c24:	72 f7                	jb     f0105c1d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105c26:	5d                   	pop    %ebp
f0105c27:	c3                   	ret    

f0105c28 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c28:	55                   	push   %ebp
f0105c29:	89 e5                	mov    %esp,%ebp
f0105c2b:	57                   	push   %edi
f0105c2c:	56                   	push   %esi
f0105c2d:	53                   	push   %ebx
f0105c2e:	8b 55 08             	mov    0x8(%ebp),%edx
f0105c31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c34:	eb 01                	jmp    f0105c37 <strtol+0xf>
		s++;
f0105c36:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c37:	8a 02                	mov    (%edx),%al
f0105c39:	3c 20                	cmp    $0x20,%al
f0105c3b:	74 f9                	je     f0105c36 <strtol+0xe>
f0105c3d:	3c 09                	cmp    $0x9,%al
f0105c3f:	74 f5                	je     f0105c36 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105c41:	3c 2b                	cmp    $0x2b,%al
f0105c43:	75 08                	jne    f0105c4d <strtol+0x25>
		s++;
f0105c45:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105c46:	bf 00 00 00 00       	mov    $0x0,%edi
f0105c4b:	eb 13                	jmp    f0105c60 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0105c4d:	3c 2d                	cmp    $0x2d,%al
f0105c4f:	75 0a                	jne    f0105c5b <strtol+0x33>
		s++, neg = 1;
f0105c51:	8d 52 01             	lea    0x1(%edx),%edx
f0105c54:	bf 01 00 00 00       	mov    $0x1,%edi
f0105c59:	eb 05                	jmp    f0105c60 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0105c5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105c60:	85 db                	test   %ebx,%ebx
f0105c62:	74 05                	je     f0105c69 <strtol+0x41>
f0105c64:	83 fb 10             	cmp    $0x10,%ebx
f0105c67:	75 28                	jne    f0105c91 <strtol+0x69>
f0105c69:	8a 02                	mov    (%edx),%al
f0105c6b:	3c 30                	cmp    $0x30,%al
f0105c6d:	75 10                	jne    f0105c7f <strtol+0x57>
f0105c6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0105c73:	75 0a                	jne    f0105c7f <strtol+0x57>
		s += 2, base = 16;
f0105c75:	83 c2 02             	add    $0x2,%edx
f0105c78:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105c7d:	eb 12                	jmp    f0105c91 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0105c7f:	85 db                	test   %ebx,%ebx
f0105c81:	75 0e                	jne    f0105c91 <strtol+0x69>
f0105c83:	3c 30                	cmp    $0x30,%al
f0105c85:	75 05                	jne    f0105c8c <strtol+0x64>
		s++, base = 8;
f0105c87:	42                   	inc    %edx
f0105c88:	b3 08                	mov    $0x8,%bl
f0105c8a:	eb 05                	jmp    f0105c91 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0105c8c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105c91:	b8 00 00 00 00       	mov    $0x0,%eax
f0105c96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105c98:	8a 0a                	mov    (%edx),%cl
f0105c9a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105c9d:	80 fb 09             	cmp    $0x9,%bl
f0105ca0:	77 08                	ja     f0105caa <strtol+0x82>
			dig = *s - '0';
f0105ca2:	0f be c9             	movsbl %cl,%ecx
f0105ca5:	83 e9 30             	sub    $0x30,%ecx
f0105ca8:	eb 1e                	jmp    f0105cc8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0105caa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0105cad:	80 fb 19             	cmp    $0x19,%bl
f0105cb0:	77 08                	ja     f0105cba <strtol+0x92>
			dig = *s - 'a' + 10;
f0105cb2:	0f be c9             	movsbl %cl,%ecx
f0105cb5:	83 e9 57             	sub    $0x57,%ecx
f0105cb8:	eb 0e                	jmp    f0105cc8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0105cba:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0105cbd:	80 fb 19             	cmp    $0x19,%bl
f0105cc0:	77 12                	ja     f0105cd4 <strtol+0xac>
			dig = *s - 'A' + 10;
f0105cc2:	0f be c9             	movsbl %cl,%ecx
f0105cc5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0105cc8:	39 f1                	cmp    %esi,%ecx
f0105cca:	7d 0c                	jge    f0105cd8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0105ccc:	42                   	inc    %edx
f0105ccd:	0f af c6             	imul   %esi,%eax
f0105cd0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0105cd2:	eb c4                	jmp    f0105c98 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0105cd4:	89 c1                	mov    %eax,%ecx
f0105cd6:	eb 02                	jmp    f0105cda <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105cd8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0105cda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105cde:	74 05                	je     f0105ce5 <strtol+0xbd>
		*endptr = (char *) s;
f0105ce0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105ce3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0105ce5:	85 ff                	test   %edi,%edi
f0105ce7:	74 04                	je     f0105ced <strtol+0xc5>
f0105ce9:	89 c8                	mov    %ecx,%eax
f0105ceb:	f7 d8                	neg    %eax
}
f0105ced:	5b                   	pop    %ebx
f0105cee:	5e                   	pop    %esi
f0105cef:	5f                   	pop    %edi
f0105cf0:	5d                   	pop    %ebp
f0105cf1:	c3                   	ret    
	...

f0105cf4 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105cf4:	fa                   	cli    

	xorw    %ax, %ax
f0105cf5:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105cf7:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105cf9:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105cfb:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105cfd:	0f 01 16             	lgdtl  (%esi)
f0105d00:	74 70                	je     f0105d72 <sum+0x2>
	movl    %cr0, %eax
f0105d02:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105d05:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105d09:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105d0c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105d12:	08 00                	or     %al,(%eax)

f0105d14 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105d14:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105d18:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d1a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d1c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105d1e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105d22:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105d24:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105d26:	b8 00 60 12 00       	mov    $0x126000,%eax
	movl    %eax, %cr3
f0105d2b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105d2e:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105d31:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105d36:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105d39:	8b 25 84 2e 22 f0    	mov    0xf0222e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105d3f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105d44:	b8 a8 00 10 f0       	mov    $0xf01000a8,%eax
	call    *%eax
f0105d49:	ff d0                	call   *%eax

f0105d4b <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105d4b:	eb fe                	jmp    f0105d4b <spin>
f0105d4d:	8d 76 00             	lea    0x0(%esi),%esi

f0105d50 <gdt>:
	...
f0105d58:	ff                   	(bad)  
f0105d59:	ff 00                	incl   (%eax)
f0105d5b:	00 00                	add    %al,(%eax)
f0105d5d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105d64:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105d68 <gdtdesc>:
f0105d68:	17                   	pop    %ss
f0105d69:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105d6e <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105d6e:	90                   	nop
	...

f0105d70 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105d70:	55                   	push   %ebp
f0105d71:	89 e5                	mov    %esp,%ebp
f0105d73:	56                   	push   %esi
f0105d74:	53                   	push   %ebx
	int i, sum;

	sum = 0;
f0105d75:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < len; i++)
f0105d7a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105d7f:	eb 07                	jmp    f0105d88 <sum+0x18>
		sum += ((uint8_t *)addr)[i];
f0105d81:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105d85:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105d87:	41                   	inc    %ecx
f0105d88:	39 d1                	cmp    %edx,%ecx
f0105d8a:	7c f5                	jl     f0105d81 <sum+0x11>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105d8c:	88 d8                	mov    %bl,%al
f0105d8e:	5b                   	pop    %ebx
f0105d8f:	5e                   	pop    %esi
f0105d90:	5d                   	pop    %ebp
f0105d91:	c3                   	ret    

f0105d92 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105d92:	55                   	push   %ebp
f0105d93:	89 e5                	mov    %esp,%ebp
f0105d95:	56                   	push   %esi
f0105d96:	53                   	push   %ebx
f0105d97:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105d9a:	8b 0d 88 2e 22 f0    	mov    0xf0222e88,%ecx
f0105da0:	89 c3                	mov    %eax,%ebx
f0105da2:	c1 eb 0c             	shr    $0xc,%ebx
f0105da5:	39 cb                	cmp    %ecx,%ebx
f0105da7:	72 20                	jb     f0105dc9 <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105da9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105dad:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0105db4:	f0 
f0105db5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105dbc:	00 
f0105dbd:	c7 04 24 1d 83 10 f0 	movl   $0xf010831d,(%esp)
f0105dc4:	e8 77 a2 ff ff       	call   f0100040 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105dc9:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105dcc:	89 f2                	mov    %esi,%edx
f0105dce:	c1 ea 0c             	shr    $0xc,%edx
f0105dd1:	39 d1                	cmp    %edx,%ecx
f0105dd3:	77 20                	ja     f0105df5 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105dd5:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105dd9:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0105de0:	f0 
f0105de1:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105de8:	00 
f0105de9:	c7 04 24 1d 83 10 f0 	movl   $0xf010831d,(%esp)
f0105df0:	e8 4b a2 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105df5:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105dfb:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105e01:	eb 2f                	jmp    f0105e32 <mpsearch1+0xa0>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e03:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105e0a:	00 
f0105e0b:	c7 44 24 04 2d 83 10 	movl   $0xf010832d,0x4(%esp)
f0105e12:	f0 
f0105e13:	89 1c 24             	mov    %ebx,(%esp)
f0105e16:	e8 b8 fd ff ff       	call   f0105bd3 <memcmp>
f0105e1b:	85 c0                	test   %eax,%eax
f0105e1d:	75 10                	jne    f0105e2f <mpsearch1+0x9d>
		    sum(mp, sizeof(*mp)) == 0)
f0105e1f:	ba 10 00 00 00       	mov    $0x10,%edx
f0105e24:	89 d8                	mov    %ebx,%eax
f0105e26:	e8 45 ff ff ff       	call   f0105d70 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e2b:	84 c0                	test   %al,%al
f0105e2d:	74 0c                	je     f0105e3b <mpsearch1+0xa9>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105e2f:	83 c3 10             	add    $0x10,%ebx
f0105e32:	39 f3                	cmp    %esi,%ebx
f0105e34:	72 cd                	jb     f0105e03 <mpsearch1+0x71>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105e36:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105e3b:	89 d8                	mov    %ebx,%eax
f0105e3d:	83 c4 10             	add    $0x10,%esp
f0105e40:	5b                   	pop    %ebx
f0105e41:	5e                   	pop    %esi
f0105e42:	5d                   	pop    %ebp
f0105e43:	c3                   	ret    

f0105e44 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105e44:	55                   	push   %ebp
f0105e45:	89 e5                	mov    %esp,%ebp
f0105e47:	57                   	push   %edi
f0105e48:	56                   	push   %esi
f0105e49:	53                   	push   %ebx
f0105e4a:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e4d:	c7 05 c0 33 22 f0 20 	movl   $0xf0223020,0xf02233c0
f0105e54:	30 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105e57:	83 3d 88 2e 22 f0 00 	cmpl   $0x0,0xf0222e88
f0105e5e:	75 24                	jne    f0105e84 <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e60:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0105e67:	00 
f0105e68:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0105e6f:	f0 
f0105e70:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0105e77:	00 
f0105e78:	c7 04 24 1d 83 10 f0 	movl   $0xf010831d,(%esp)
f0105e7f:	e8 bc a1 ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105e84:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105e8b:	85 c0                	test   %eax,%eax
f0105e8d:	74 16                	je     f0105ea5 <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
f0105e8f:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105e92:	ba 00 04 00 00       	mov    $0x400,%edx
f0105e97:	e8 f6 fe ff ff       	call   f0105d92 <mpsearch1>
f0105e9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105e9f:	85 c0                	test   %eax,%eax
f0105ea1:	75 3c                	jne    f0105edf <mp_init+0x9b>
f0105ea3:	eb 20                	jmp    f0105ec5 <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105ea5:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105eac:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105eaf:	2d 00 04 00 00       	sub    $0x400,%eax
f0105eb4:	ba 00 04 00 00       	mov    $0x400,%edx
f0105eb9:	e8 d4 fe ff ff       	call   f0105d92 <mpsearch1>
f0105ebe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ec1:	85 c0                	test   %eax,%eax
f0105ec3:	75 1a                	jne    f0105edf <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105ec5:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105eca:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ecf:	e8 be fe ff ff       	call   f0105d92 <mpsearch1>
f0105ed4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105ed7:	85 c0                	test   %eax,%eax
f0105ed9:	0f 84 2c 02 00 00    	je     f010610b <mp_init+0x2c7>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105edf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ee2:	8b 58 04             	mov    0x4(%eax),%ebx
f0105ee5:	85 db                	test   %ebx,%ebx
f0105ee7:	74 06                	je     f0105eef <mp_init+0xab>
f0105ee9:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105eed:	74 11                	je     f0105f00 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0105eef:	c7 04 24 90 81 10 f0 	movl   $0xf0108190,(%esp)
f0105ef6:	e8 4f dd ff ff       	call   f0103c4a <cprintf>
f0105efb:	e9 0b 02 00 00       	jmp    f010610b <mp_init+0x2c7>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105f00:	89 d8                	mov    %ebx,%eax
f0105f02:	c1 e8 0c             	shr    $0xc,%eax
f0105f05:	3b 05 88 2e 22 f0    	cmp    0xf0222e88,%eax
f0105f0b:	72 20                	jb     f0105f2d <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f0d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0105f11:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f0105f18:	f0 
f0105f19:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0105f20:	00 
f0105f21:	c7 04 24 1d 83 10 f0 	movl   $0xf010831d,(%esp)
f0105f28:	e8 13 a1 ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105f2d:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105f33:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105f3a:	00 
f0105f3b:	c7 44 24 04 32 83 10 	movl   $0xf0108332,0x4(%esp)
f0105f42:	f0 
f0105f43:	89 1c 24             	mov    %ebx,(%esp)
f0105f46:	e8 88 fc ff ff       	call   f0105bd3 <memcmp>
f0105f4b:	85 c0                	test   %eax,%eax
f0105f4d:	74 11                	je     f0105f60 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105f4f:	c7 04 24 c0 81 10 f0 	movl   $0xf01081c0,(%esp)
f0105f56:	e8 ef dc ff ff       	call   f0103c4a <cprintf>
f0105f5b:	e9 ab 01 00 00       	jmp    f010610b <mp_init+0x2c7>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105f60:	66 8b 73 04          	mov    0x4(%ebx),%si
f0105f64:	0f b7 d6             	movzwl %si,%edx
f0105f67:	89 d8                	mov    %ebx,%eax
f0105f69:	e8 02 fe ff ff       	call   f0105d70 <sum>
f0105f6e:	84 c0                	test   %al,%al
f0105f70:	74 11                	je     f0105f83 <mp_init+0x13f>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105f72:	c7 04 24 f4 81 10 f0 	movl   $0xf01081f4,(%esp)
f0105f79:	e8 cc dc ff ff       	call   f0103c4a <cprintf>
f0105f7e:	e9 88 01 00 00       	jmp    f010610b <mp_init+0x2c7>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105f83:	8a 43 06             	mov    0x6(%ebx),%al
f0105f86:	3c 01                	cmp    $0x1,%al
f0105f88:	74 1c                	je     f0105fa6 <mp_init+0x162>
f0105f8a:	3c 04                	cmp    $0x4,%al
f0105f8c:	74 18                	je     f0105fa6 <mp_init+0x162>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105f8e:	0f b6 c0             	movzbl %al,%eax
f0105f91:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105f95:	c7 04 24 18 82 10 f0 	movl   $0xf0108218,(%esp)
f0105f9c:	e8 a9 dc ff ff       	call   f0103c4a <cprintf>
f0105fa1:	e9 65 01 00 00       	jmp    f010610b <mp_init+0x2c7>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0105fa6:	0f b7 53 28          	movzwl 0x28(%ebx),%edx
f0105faa:	0f b7 c6             	movzwl %si,%eax
f0105fad:	01 d8                	add    %ebx,%eax
f0105faf:	e8 bc fd ff ff       	call   f0105d70 <sum>
f0105fb4:	02 43 2a             	add    0x2a(%ebx),%al
f0105fb7:	84 c0                	test   %al,%al
f0105fb9:	74 11                	je     f0105fcc <mp_init+0x188>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105fbb:	c7 04 24 38 82 10 f0 	movl   $0xf0108238,(%esp)
f0105fc2:	e8 83 dc ff ff       	call   f0103c4a <cprintf>
f0105fc7:	e9 3f 01 00 00       	jmp    f010610b <mp_init+0x2c7>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105fcc:	85 db                	test   %ebx,%ebx
f0105fce:	0f 84 37 01 00 00    	je     f010610b <mp_init+0x2c7>
		return;
	ismp = 1;
f0105fd4:	c7 05 00 30 22 f0 01 	movl   $0x1,0xf0223000
f0105fdb:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105fde:	8b 43 24             	mov    0x24(%ebx),%eax
f0105fe1:	a3 00 40 26 f0       	mov    %eax,0xf0264000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105fe6:	8d 73 2c             	lea    0x2c(%ebx),%esi
f0105fe9:	bf 00 00 00 00       	mov    $0x0,%edi
f0105fee:	e9 94 00 00 00       	jmp    f0106087 <mp_init+0x243>
		switch (*p) {
f0105ff3:	8a 06                	mov    (%esi),%al
f0105ff5:	84 c0                	test   %al,%al
f0105ff7:	74 06                	je     f0105fff <mp_init+0x1bb>
f0105ff9:	3c 04                	cmp    $0x4,%al
f0105ffb:	77 68                	ja     f0106065 <mp_init+0x221>
f0105ffd:	eb 61                	jmp    f0106060 <mp_init+0x21c>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f0105fff:	f6 46 03 02          	testb  $0x2,0x3(%esi)
f0106003:	74 1d                	je     f0106022 <mp_init+0x1de>
				bootcpu = &cpus[ncpu];
f0106005:	a1 c4 33 22 f0       	mov    0xf02233c4,%eax
f010600a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106011:	29 c2                	sub    %eax,%edx
f0106013:	8d 04 90             	lea    (%eax,%edx,4),%eax
f0106016:	8d 04 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%eax
f010601d:	a3 c0 33 22 f0       	mov    %eax,0xf02233c0
			if (ncpu < NCPU) {
f0106022:	a1 c4 33 22 f0       	mov    0xf02233c4,%eax
f0106027:	83 f8 07             	cmp    $0x7,%eax
f010602a:	7f 1b                	jg     f0106047 <mp_init+0x203>
				cpus[ncpu].cpu_id = ncpu;
f010602c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f0106033:	29 c2                	sub    %eax,%edx
f0106035:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0106038:	88 04 95 20 30 22 f0 	mov    %al,-0xfddcfe0(,%edx,4)
				ncpu++;
f010603f:	40                   	inc    %eax
f0106040:	a3 c4 33 22 f0       	mov    %eax,0xf02233c4
f0106045:	eb 14                	jmp    f010605b <mp_init+0x217>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106047:	0f b6 46 01          	movzbl 0x1(%esi),%eax
f010604b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010604f:	c7 04 24 68 82 10 f0 	movl   $0xf0108268,(%esp)
f0106056:	e8 ef db ff ff       	call   f0103c4a <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f010605b:	83 c6 14             	add    $0x14,%esi
			continue;
f010605e:	eb 26                	jmp    f0106086 <mp_init+0x242>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0106060:	83 c6 08             	add    $0x8,%esi
			continue;
f0106063:	eb 21                	jmp    f0106086 <mp_init+0x242>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0106065:	0f b6 c0             	movzbl %al,%eax
f0106068:	89 44 24 04          	mov    %eax,0x4(%esp)
f010606c:	c7 04 24 90 82 10 f0 	movl   $0xf0108290,(%esp)
f0106073:	e8 d2 db ff ff       	call   f0103c4a <cprintf>
			ismp = 0;
f0106078:	c7 05 00 30 22 f0 00 	movl   $0x0,0xf0223000
f010607f:	00 00 00 
			i = conf->entry;
f0106082:	0f b7 7b 22          	movzwl 0x22(%ebx),%edi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106086:	47                   	inc    %edi
f0106087:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f010608b:	39 c7                	cmp    %eax,%edi
f010608d:	0f 82 60 ff ff ff    	jb     f0105ff3 <mp_init+0x1af>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0106093:	a1 c0 33 22 f0       	mov    0xf02233c0,%eax
f0106098:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f010609f:	83 3d 00 30 22 f0 00 	cmpl   $0x0,0xf0223000
f01060a6:	75 22                	jne    f01060ca <mp_init+0x286>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01060a8:	c7 05 c4 33 22 f0 01 	movl   $0x1,0xf02233c4
f01060af:	00 00 00 
		lapicaddr = 0;
f01060b2:	c7 05 00 40 26 f0 00 	movl   $0x0,0xf0264000
f01060b9:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01060bc:	c7 04 24 b0 82 10 f0 	movl   $0xf01082b0,(%esp)
f01060c3:	e8 82 db ff ff       	call   f0103c4a <cprintf>
		return;
f01060c8:	eb 41                	jmp    f010610b <mp_init+0x2c7>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01060ca:	8b 15 c4 33 22 f0    	mov    0xf02233c4,%edx
f01060d0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01060d4:	0f b6 00             	movzbl (%eax),%eax
f01060d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01060db:	c7 04 24 37 83 10 f0 	movl   $0xf0108337,(%esp)
f01060e2:	e8 63 db ff ff       	call   f0103c4a <cprintf>

	if (mp->imcrp) {
f01060e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060ea:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f01060ee:	74 1b                	je     f010610b <mp_init+0x2c7>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f01060f0:	c7 04 24 dc 82 10 f0 	movl   $0xf01082dc,(%esp)
f01060f7:	e8 4e db ff ff       	call   f0103c4a <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01060fc:	ba 22 00 00 00       	mov    $0x22,%edx
f0106101:	b0 70                	mov    $0x70,%al
f0106103:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0106104:	b2 23                	mov    $0x23,%dl
f0106106:	ec                   	in     (%dx),%al
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106107:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010610a:	ee                   	out    %al,(%dx)
	}
}
f010610b:	83 c4 2c             	add    $0x2c,%esp
f010610e:	5b                   	pop    %ebx
f010610f:	5e                   	pop    %esi
f0106110:	5f                   	pop    %edi
f0106111:	5d                   	pop    %ebp
f0106112:	c3                   	ret    
	...

f0106114 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0106114:	55                   	push   %ebp
f0106115:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0106117:	c1 e0 02             	shl    $0x2,%eax
f010611a:	03 05 04 40 26 f0    	add    0xf0264004,%eax
f0106120:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106122:	a1 04 40 26 f0       	mov    0xf0264004,%eax
f0106127:	8b 40 20             	mov    0x20(%eax),%eax
}
f010612a:	5d                   	pop    %ebp
f010612b:	c3                   	ret    

f010612c <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010612c:	55                   	push   %ebp
f010612d:	89 e5                	mov    %esp,%ebp
	if (lapic)
f010612f:	a1 04 40 26 f0       	mov    0xf0264004,%eax
f0106134:	85 c0                	test   %eax,%eax
f0106136:	74 08                	je     f0106140 <cpunum+0x14>
		return lapic[ID] >> 24;
f0106138:	8b 40 20             	mov    0x20(%eax),%eax
f010613b:	c1 e8 18             	shr    $0x18,%eax
f010613e:	eb 05                	jmp    f0106145 <cpunum+0x19>
	return 0;
f0106140:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0106145:	5d                   	pop    %ebp
f0106146:	c3                   	ret    

f0106147 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0106147:	55                   	push   %ebp
f0106148:	89 e5                	mov    %esp,%ebp
f010614a:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f010614d:	a1 00 40 26 f0       	mov    0xf0264000,%eax
f0106152:	85 c0                	test   %eax,%eax
f0106154:	0f 84 27 01 00 00    	je     f0106281 <lapic_init+0x13a>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f010615a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0106161:	00 
f0106162:	89 04 24             	mov    %eax,(%esp)
f0106165:	e8 7f b1 ff ff       	call   f01012e9 <mmio_map_region>
f010616a:	a3 04 40 26 f0       	mov    %eax,0xf0264004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f010616f:	ba 27 01 00 00       	mov    $0x127,%edx
f0106174:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0106179:	e8 96 ff ff ff       	call   f0106114 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f010617e:	ba 0b 00 00 00       	mov    $0xb,%edx
f0106183:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0106188:	e8 87 ff ff ff       	call   f0106114 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f010618d:	ba 20 00 02 00       	mov    $0x20020,%edx
f0106192:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0106197:	e8 78 ff ff ff       	call   f0106114 <lapicw>
	lapicw(TICR, 10000000); 
f010619c:	ba 80 96 98 00       	mov    $0x989680,%edx
f01061a1:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01061a6:	e8 69 ff ff ff       	call   f0106114 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01061ab:	e8 7c ff ff ff       	call   f010612c <cpunum>
f01061b0:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01061b7:	29 c2                	sub    %eax,%edx
f01061b9:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01061bc:	8d 04 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%eax
f01061c3:	39 05 c0 33 22 f0    	cmp    %eax,0xf02233c0
f01061c9:	74 0f                	je     f01061da <lapic_init+0x93>
		lapicw(LINT0, MASKED);
f01061cb:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061d0:	b8 d4 00 00 00       	mov    $0xd4,%eax
f01061d5:	e8 3a ff ff ff       	call   f0106114 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f01061da:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061df:	b8 d8 00 00 00       	mov    $0xd8,%eax
f01061e4:	e8 2b ff ff ff       	call   f0106114 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f01061e9:	a1 04 40 26 f0       	mov    0xf0264004,%eax
f01061ee:	8b 40 30             	mov    0x30(%eax),%eax
f01061f1:	c1 e8 10             	shr    $0x10,%eax
f01061f4:	3c 03                	cmp    $0x3,%al
f01061f6:	76 0f                	jbe    f0106207 <lapic_init+0xc0>
		lapicw(PCINT, MASKED);
f01061f8:	ba 00 00 01 00       	mov    $0x10000,%edx
f01061fd:	b8 d0 00 00 00       	mov    $0xd0,%eax
f0106202:	e8 0d ff ff ff       	call   f0106114 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0106207:	ba 33 00 00 00       	mov    $0x33,%edx
f010620c:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106211:	e8 fe fe ff ff       	call   f0106114 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0106216:	ba 00 00 00 00       	mov    $0x0,%edx
f010621b:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106220:	e8 ef fe ff ff       	call   f0106114 <lapicw>
	lapicw(ESR, 0);
f0106225:	ba 00 00 00 00       	mov    $0x0,%edx
f010622a:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010622f:	e8 e0 fe ff ff       	call   f0106114 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0106234:	ba 00 00 00 00       	mov    $0x0,%edx
f0106239:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010623e:	e8 d1 fe ff ff       	call   f0106114 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0106243:	ba 00 00 00 00       	mov    $0x0,%edx
f0106248:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010624d:	e8 c2 fe ff ff       	call   f0106114 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106252:	ba 00 85 08 00       	mov    $0x88500,%edx
f0106257:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010625c:	e8 b3 fe ff ff       	call   f0106114 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106261:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
f0106267:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010626d:	f6 c4 10             	test   $0x10,%ah
f0106270:	75 f5                	jne    f0106267 <lapic_init+0x120>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f0106272:	ba 00 00 00 00       	mov    $0x0,%edx
f0106277:	b8 20 00 00 00       	mov    $0x20,%eax
f010627c:	e8 93 fe ff ff       	call   f0106114 <lapicw>
}
f0106281:	c9                   	leave  
f0106282:	c3                   	ret    

f0106283 <lapic_eoi>:
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0106283:	55                   	push   %ebp
f0106284:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0106286:	83 3d 04 40 26 f0 00 	cmpl   $0x0,0xf0264004
f010628d:	74 0f                	je     f010629e <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f010628f:	ba 00 00 00 00       	mov    $0x0,%edx
f0106294:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106299:	e8 76 fe ff ff       	call   f0106114 <lapicw>
}
f010629e:	5d                   	pop    %ebp
f010629f:	c3                   	ret    

f01062a0 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01062a0:	55                   	push   %ebp
f01062a1:	89 e5                	mov    %esp,%ebp
f01062a3:	56                   	push   %esi
f01062a4:	53                   	push   %ebx
f01062a5:	83 ec 10             	sub    $0x10,%esp
f01062a8:	8b 75 0c             	mov    0xc(%ebp),%esi
f01062ab:	8a 5d 08             	mov    0x8(%ebp),%bl
f01062ae:	ba 70 00 00 00       	mov    $0x70,%edx
f01062b3:	b0 0f                	mov    $0xf,%al
f01062b5:	ee                   	out    %al,(%dx)
f01062b6:	b2 71                	mov    $0x71,%dl
f01062b8:	b0 0a                	mov    $0xa,%al
f01062ba:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01062bb:	83 3d 88 2e 22 f0 00 	cmpl   $0x0,0xf0222e88
f01062c2:	75 24                	jne    f01062e8 <lapic_startap+0x48>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01062c4:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f01062cb:	00 
f01062cc:	c7 44 24 08 48 68 10 	movl   $0xf0106848,0x8(%esp)
f01062d3:	f0 
f01062d4:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f01062db:	00 
f01062dc:	c7 04 24 54 83 10 f0 	movl   $0xf0108354,(%esp)
f01062e3:	e8 58 9d ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f01062e8:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f01062ef:	00 00 
	wrv[1] = addr >> 4;
f01062f1:	89 f0                	mov    %esi,%eax
f01062f3:	c1 e8 04             	shr    $0x4,%eax
f01062f6:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f01062fc:	c1 e3 18             	shl    $0x18,%ebx
f01062ff:	89 da                	mov    %ebx,%edx
f0106301:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106306:	e8 09 fe ff ff       	call   f0106114 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f010630b:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106310:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106315:	e8 fa fd ff ff       	call   f0106114 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f010631a:	ba 00 85 00 00       	mov    $0x8500,%edx
f010631f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106324:	e8 eb fd ff ff       	call   f0106114 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106329:	c1 ee 0c             	shr    $0xc,%esi
f010632c:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0106332:	89 da                	mov    %ebx,%edx
f0106334:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106339:	e8 d6 fd ff ff       	call   f0106114 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010633e:	89 f2                	mov    %esi,%edx
f0106340:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106345:	e8 ca fd ff ff       	call   f0106114 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010634a:	89 da                	mov    %ebx,%edx
f010634c:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106351:	e8 be fd ff ff       	call   f0106114 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106356:	89 f2                	mov    %esi,%edx
f0106358:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010635d:	e8 b2 fd ff ff       	call   f0106114 <lapicw>
		microdelay(200);
	}
}
f0106362:	83 c4 10             	add    $0x10,%esp
f0106365:	5b                   	pop    %ebx
f0106366:	5e                   	pop    %esi
f0106367:	5d                   	pop    %ebp
f0106368:	c3                   	ret    

f0106369 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f0106369:	55                   	push   %ebp
f010636a:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f010636c:	8b 55 08             	mov    0x8(%ebp),%edx
f010636f:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0106375:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010637a:	e8 95 fd ff ff       	call   f0106114 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f010637f:	8b 15 04 40 26 f0    	mov    0xf0264004,%edx
f0106385:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f010638b:	f6 c4 10             	test   $0x10,%ah
f010638e:	75 f5                	jne    f0106385 <lapic_ipi+0x1c>
		;
}
f0106390:	5d                   	pop    %ebp
f0106391:	c3                   	ret    
	...

f0106394 <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f0106394:	55                   	push   %ebp
f0106395:	89 e5                	mov    %esp,%ebp
f0106397:	53                   	push   %ebx
f0106398:	83 ec 04             	sub    $0x4,%esp
	return lock->locked && lock->cpu == thiscpu;
f010639b:	83 38 00             	cmpl   $0x0,(%eax)
f010639e:	74 25                	je     f01063c5 <holding+0x31>
f01063a0:	8b 58 08             	mov    0x8(%eax),%ebx
f01063a3:	e8 84 fd ff ff       	call   f010612c <cpunum>
f01063a8:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f01063af:	29 c2                	sub    %eax,%edx
f01063b1:	8d 04 90             	lea    (%eax,%edx,4),%eax
f01063b4:	8d 04 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%eax
		pcs[i] = 0;
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
f01063bb:	39 c3                	cmp    %eax,%ebx
{
	return lock->locked && lock->cpu == thiscpu;
f01063bd:	0f 94 c0             	sete   %al
f01063c0:	0f b6 c0             	movzbl %al,%eax
f01063c3:	eb 05                	jmp    f01063ca <holding+0x36>
f01063c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01063ca:	83 c4 04             	add    $0x4,%esp
f01063cd:	5b                   	pop    %ebx
f01063ce:	5d                   	pop    %ebp
f01063cf:	c3                   	ret    

f01063d0 <__spin_initlock>:
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01063d0:	55                   	push   %ebp
f01063d1:	89 e5                	mov    %esp,%ebp
f01063d3:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01063d6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01063dc:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063df:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01063e2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01063e9:	5d                   	pop    %ebp
f01063ea:	c3                   	ret    

f01063eb <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01063eb:	55                   	push   %ebp
f01063ec:	89 e5                	mov    %esp,%ebp
f01063ee:	53                   	push   %ebx
f01063ef:	83 ec 24             	sub    $0x24,%esp
f01063f2:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f01063f5:	89 d8                	mov    %ebx,%eax
f01063f7:	e8 98 ff ff ff       	call   f0106394 <holding>
f01063fc:	85 c0                	test   %eax,%eax
f01063fe:	74 30                	je     f0106430 <spin_lock+0x45>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106400:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106403:	e8 24 fd ff ff       	call   f010612c <cpunum>
f0106408:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f010640c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106410:	c7 44 24 08 64 83 10 	movl   $0xf0108364,0x8(%esp)
f0106417:	f0 
f0106418:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f010641f:	00 
f0106420:	c7 04 24 c8 83 10 f0 	movl   $0xf01083c8,(%esp)
f0106427:	e8 14 9c ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f010642c:	f3 90                	pause  
f010642e:	eb 05                	jmp    f0106435 <spin_lock+0x4a>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0106430:	ba 01 00 00 00       	mov    $0x1,%edx
f0106435:	89 d0                	mov    %edx,%eax
f0106437:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010643a:	85 c0                	test   %eax,%eax
f010643c:	75 ee                	jne    f010642c <spin_lock+0x41>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010643e:	e8 e9 fc ff ff       	call   f010612c <cpunum>
f0106443:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
f010644a:	29 c2                	sub    %eax,%edx
f010644c:	8d 04 90             	lea    (%eax,%edx,4),%eax
f010644f:	8d 04 85 20 30 22 f0 	lea    -0xfddcfe0(,%eax,4),%eax
f0106456:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106459:	83 c3 0c             	add    $0xc,%ebx
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f010645c:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010645e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106463:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106469:	76 10                	jbe    f010647b <spin_lock+0x90>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010646b:	8b 4a 04             	mov    0x4(%edx),%ecx
f010646e:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106471:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106473:	40                   	inc    %eax
f0106474:	83 f8 0a             	cmp    $0xa,%eax
f0106477:	75 ea                	jne    f0106463 <spin_lock+0x78>
f0106479:	eb 0d                	jmp    f0106488 <spin_lock+0x9d>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010647b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0106482:	40                   	inc    %eax
f0106483:	83 f8 09             	cmp    $0x9,%eax
f0106486:	7e f3                	jle    f010647b <spin_lock+0x90>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0106488:	83 c4 24             	add    $0x24,%esp
f010648b:	5b                   	pop    %ebx
f010648c:	5d                   	pop    %ebp
f010648d:	c3                   	ret    

f010648e <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f010648e:	55                   	push   %ebp
f010648f:	89 e5                	mov    %esp,%ebp
f0106491:	57                   	push   %edi
f0106492:	56                   	push   %esi
f0106493:	53                   	push   %ebx
f0106494:	83 ec 7c             	sub    $0x7c,%esp
f0106497:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f010649a:	89 d8                	mov    %ebx,%eax
f010649c:	e8 f3 fe ff ff       	call   f0106394 <holding>
f01064a1:	85 c0                	test   %eax,%eax
f01064a3:	0f 85 d3 00 00 00    	jne    f010657c <spin_unlock+0xee>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01064a9:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f01064b0:	00 
f01064b1:	8d 43 0c             	lea    0xc(%ebx),%eax
f01064b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064b8:	8d 75 a8             	lea    -0x58(%ebp),%esi
f01064bb:	89 34 24             	mov    %esi,(%esp)
f01064be:	e8 85 f6 ff ff       	call   f0105b48 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01064c3:	8b 43 08             	mov    0x8(%ebx),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01064c6:	0f b6 38             	movzbl (%eax),%edi
f01064c9:	8b 5b 04             	mov    0x4(%ebx),%ebx
f01064cc:	e8 5b fc ff ff       	call   f010612c <cpunum>
f01064d1:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01064d5:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01064d9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01064dd:	c7 04 24 90 83 10 f0 	movl   $0xf0108390,(%esp)
f01064e4:	e8 61 d7 ff ff       	call   f0103c4a <cprintf>
f01064e9:	89 f3                	mov    %esi,%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f01064eb:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01064ee:	89 45 a4             	mov    %eax,-0x5c(%ebp)
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01064f1:	89 c7                	mov    %eax,%edi
f01064f3:	eb 63                	jmp    f0106558 <spin_unlock+0xca>
f01064f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01064f9:	89 04 24             	mov    %eax,(%esp)
f01064fc:	e8 60 ec ff ff       	call   f0105161 <debuginfo_eip>
f0106501:	85 c0                	test   %eax,%eax
f0106503:	78 39                	js     f010653e <spin_unlock+0xb0>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0106505:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106507:	89 c2                	mov    %eax,%edx
f0106509:	2b 55 e0             	sub    -0x20(%ebp),%edx
f010650c:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106510:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0106513:	89 54 24 14          	mov    %edx,0x14(%esp)
f0106517:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010651a:	89 54 24 10          	mov    %edx,0x10(%esp)
f010651e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106521:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0106525:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106528:	89 54 24 08          	mov    %edx,0x8(%esp)
f010652c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106530:	c7 04 24 d8 83 10 f0 	movl   $0xf01083d8,(%esp)
f0106537:	e8 0e d7 ff ff       	call   f0103c4a <cprintf>
f010653c:	eb 12                	jmp    f0106550 <spin_unlock+0xc2>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f010653e:	8b 06                	mov    (%esi),%eax
f0106540:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106544:	c7 04 24 ef 83 10 f0 	movl   $0xf01083ef,(%esp)
f010654b:	e8 fa d6 ff ff       	call   f0103c4a <cprintf>
f0106550:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106553:	3b 5d a4             	cmp    -0x5c(%ebp),%ebx
f0106556:	74 08                	je     f0106560 <spin_unlock+0xd2>
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106558:	89 de                	mov    %ebx,%esi
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010655a:	8b 03                	mov    (%ebx),%eax
f010655c:	85 c0                	test   %eax,%eax
f010655e:	75 95                	jne    f01064f5 <spin_unlock+0x67>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0106560:	c7 44 24 08 f7 83 10 	movl   $0xf01083f7,0x8(%esp)
f0106567:	f0 
f0106568:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f010656f:	00 
f0106570:	c7 04 24 c8 83 10 f0 	movl   $0xf01083c8,(%esp)
f0106577:	e8 c4 9a ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f010657c:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f0106583:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
f010658a:	b8 00 00 00 00       	mov    $0x0,%eax
f010658f:	f0 87 03             	lock xchg %eax,(%ebx)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106592:	83 c4 7c             	add    $0x7c,%esp
f0106595:	5b                   	pop    %ebx
f0106596:	5e                   	pop    %esi
f0106597:	5f                   	pop    %edi
f0106598:	5d                   	pop    %ebp
f0106599:	c3                   	ret    
	...

f010659c <__udivdi3>:
f010659c:	55                   	push   %ebp
f010659d:	57                   	push   %edi
f010659e:	56                   	push   %esi
f010659f:	83 ec 10             	sub    $0x10,%esp
f01065a2:	8b 74 24 20          	mov    0x20(%esp),%esi
f01065a6:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01065aa:	89 74 24 04          	mov    %esi,0x4(%esp)
f01065ae:	8b 7c 24 24          	mov    0x24(%esp),%edi
f01065b2:	89 cd                	mov    %ecx,%ebp
f01065b4:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f01065b8:	85 c0                	test   %eax,%eax
f01065ba:	75 2c                	jne    f01065e8 <__udivdi3+0x4c>
f01065bc:	39 f9                	cmp    %edi,%ecx
f01065be:	77 68                	ja     f0106628 <__udivdi3+0x8c>
f01065c0:	85 c9                	test   %ecx,%ecx
f01065c2:	75 0b                	jne    f01065cf <__udivdi3+0x33>
f01065c4:	b8 01 00 00 00       	mov    $0x1,%eax
f01065c9:	31 d2                	xor    %edx,%edx
f01065cb:	f7 f1                	div    %ecx
f01065cd:	89 c1                	mov    %eax,%ecx
f01065cf:	31 d2                	xor    %edx,%edx
f01065d1:	89 f8                	mov    %edi,%eax
f01065d3:	f7 f1                	div    %ecx
f01065d5:	89 c7                	mov    %eax,%edi
f01065d7:	89 f0                	mov    %esi,%eax
f01065d9:	f7 f1                	div    %ecx
f01065db:	89 c6                	mov    %eax,%esi
f01065dd:	89 f0                	mov    %esi,%eax
f01065df:	89 fa                	mov    %edi,%edx
f01065e1:	83 c4 10             	add    $0x10,%esp
f01065e4:	5e                   	pop    %esi
f01065e5:	5f                   	pop    %edi
f01065e6:	5d                   	pop    %ebp
f01065e7:	c3                   	ret    
f01065e8:	39 f8                	cmp    %edi,%eax
f01065ea:	77 2c                	ja     f0106618 <__udivdi3+0x7c>
f01065ec:	0f bd f0             	bsr    %eax,%esi
f01065ef:	83 f6 1f             	xor    $0x1f,%esi
f01065f2:	75 4c                	jne    f0106640 <__udivdi3+0xa4>
f01065f4:	39 f8                	cmp    %edi,%eax
f01065f6:	bf 00 00 00 00       	mov    $0x0,%edi
f01065fb:	72 0a                	jb     f0106607 <__udivdi3+0x6b>
f01065fd:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0106601:	0f 87 ad 00 00 00    	ja     f01066b4 <__udivdi3+0x118>
f0106607:	be 01 00 00 00       	mov    $0x1,%esi
f010660c:	89 f0                	mov    %esi,%eax
f010660e:	89 fa                	mov    %edi,%edx
f0106610:	83 c4 10             	add    $0x10,%esp
f0106613:	5e                   	pop    %esi
f0106614:	5f                   	pop    %edi
f0106615:	5d                   	pop    %ebp
f0106616:	c3                   	ret    
f0106617:	90                   	nop
f0106618:	31 ff                	xor    %edi,%edi
f010661a:	31 f6                	xor    %esi,%esi
f010661c:	89 f0                	mov    %esi,%eax
f010661e:	89 fa                	mov    %edi,%edx
f0106620:	83 c4 10             	add    $0x10,%esp
f0106623:	5e                   	pop    %esi
f0106624:	5f                   	pop    %edi
f0106625:	5d                   	pop    %ebp
f0106626:	c3                   	ret    
f0106627:	90                   	nop
f0106628:	89 fa                	mov    %edi,%edx
f010662a:	89 f0                	mov    %esi,%eax
f010662c:	f7 f1                	div    %ecx
f010662e:	89 c6                	mov    %eax,%esi
f0106630:	31 ff                	xor    %edi,%edi
f0106632:	89 f0                	mov    %esi,%eax
f0106634:	89 fa                	mov    %edi,%edx
f0106636:	83 c4 10             	add    $0x10,%esp
f0106639:	5e                   	pop    %esi
f010663a:	5f                   	pop    %edi
f010663b:	5d                   	pop    %ebp
f010663c:	c3                   	ret    
f010663d:	8d 76 00             	lea    0x0(%esi),%esi
f0106640:	89 f1                	mov    %esi,%ecx
f0106642:	d3 e0                	shl    %cl,%eax
f0106644:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0106648:	b8 20 00 00 00       	mov    $0x20,%eax
f010664d:	29 f0                	sub    %esi,%eax
f010664f:	89 ea                	mov    %ebp,%edx
f0106651:	88 c1                	mov    %al,%cl
f0106653:	d3 ea                	shr    %cl,%edx
f0106655:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0106659:	09 ca                	or     %ecx,%edx
f010665b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010665f:	89 f1                	mov    %esi,%ecx
f0106661:	d3 e5                	shl    %cl,%ebp
f0106663:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0106667:	89 fd                	mov    %edi,%ebp
f0106669:	88 c1                	mov    %al,%cl
f010666b:	d3 ed                	shr    %cl,%ebp
f010666d:	89 fa                	mov    %edi,%edx
f010666f:	89 f1                	mov    %esi,%ecx
f0106671:	d3 e2                	shl    %cl,%edx
f0106673:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0106677:	88 c1                	mov    %al,%cl
f0106679:	d3 ef                	shr    %cl,%edi
f010667b:	09 d7                	or     %edx,%edi
f010667d:	89 f8                	mov    %edi,%eax
f010667f:	89 ea                	mov    %ebp,%edx
f0106681:	f7 74 24 08          	divl   0x8(%esp)
f0106685:	89 d1                	mov    %edx,%ecx
f0106687:	89 c7                	mov    %eax,%edi
f0106689:	f7 64 24 0c          	mull   0xc(%esp)
f010668d:	39 d1                	cmp    %edx,%ecx
f010668f:	72 17                	jb     f01066a8 <__udivdi3+0x10c>
f0106691:	74 09                	je     f010669c <__udivdi3+0x100>
f0106693:	89 fe                	mov    %edi,%esi
f0106695:	31 ff                	xor    %edi,%edi
f0106697:	e9 41 ff ff ff       	jmp    f01065dd <__udivdi3+0x41>
f010669c:	8b 54 24 04          	mov    0x4(%esp),%edx
f01066a0:	89 f1                	mov    %esi,%ecx
f01066a2:	d3 e2                	shl    %cl,%edx
f01066a4:	39 c2                	cmp    %eax,%edx
f01066a6:	73 eb                	jae    f0106693 <__udivdi3+0xf7>
f01066a8:	8d 77 ff             	lea    -0x1(%edi),%esi
f01066ab:	31 ff                	xor    %edi,%edi
f01066ad:	e9 2b ff ff ff       	jmp    f01065dd <__udivdi3+0x41>
f01066b2:	66 90                	xchg   %ax,%ax
f01066b4:	31 f6                	xor    %esi,%esi
f01066b6:	e9 22 ff ff ff       	jmp    f01065dd <__udivdi3+0x41>
	...

f01066bc <__umoddi3>:
f01066bc:	55                   	push   %ebp
f01066bd:	57                   	push   %edi
f01066be:	56                   	push   %esi
f01066bf:	83 ec 20             	sub    $0x20,%esp
f01066c2:	8b 44 24 30          	mov    0x30(%esp),%eax
f01066c6:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f01066ca:	89 44 24 14          	mov    %eax,0x14(%esp)
f01066ce:	8b 74 24 34          	mov    0x34(%esp),%esi
f01066d2:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01066d6:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f01066da:	89 c7                	mov    %eax,%edi
f01066dc:	89 f2                	mov    %esi,%edx
f01066de:	85 ed                	test   %ebp,%ebp
f01066e0:	75 16                	jne    f01066f8 <__umoddi3+0x3c>
f01066e2:	39 f1                	cmp    %esi,%ecx
f01066e4:	0f 86 a6 00 00 00    	jbe    f0106790 <__umoddi3+0xd4>
f01066ea:	f7 f1                	div    %ecx
f01066ec:	89 d0                	mov    %edx,%eax
f01066ee:	31 d2                	xor    %edx,%edx
f01066f0:	83 c4 20             	add    $0x20,%esp
f01066f3:	5e                   	pop    %esi
f01066f4:	5f                   	pop    %edi
f01066f5:	5d                   	pop    %ebp
f01066f6:	c3                   	ret    
f01066f7:	90                   	nop
f01066f8:	39 f5                	cmp    %esi,%ebp
f01066fa:	0f 87 ac 00 00 00    	ja     f01067ac <__umoddi3+0xf0>
f0106700:	0f bd c5             	bsr    %ebp,%eax
f0106703:	83 f0 1f             	xor    $0x1f,%eax
f0106706:	89 44 24 10          	mov    %eax,0x10(%esp)
f010670a:	0f 84 a8 00 00 00    	je     f01067b8 <__umoddi3+0xfc>
f0106710:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106714:	d3 e5                	shl    %cl,%ebp
f0106716:	bf 20 00 00 00       	mov    $0x20,%edi
f010671b:	2b 7c 24 10          	sub    0x10(%esp),%edi
f010671f:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106723:	89 f9                	mov    %edi,%ecx
f0106725:	d3 e8                	shr    %cl,%eax
f0106727:	09 e8                	or     %ebp,%eax
f0106729:	89 44 24 18          	mov    %eax,0x18(%esp)
f010672d:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0106731:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106735:	d3 e0                	shl    %cl,%eax
f0106737:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010673b:	89 f2                	mov    %esi,%edx
f010673d:	d3 e2                	shl    %cl,%edx
f010673f:	8b 44 24 14          	mov    0x14(%esp),%eax
f0106743:	d3 e0                	shl    %cl,%eax
f0106745:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0106749:	8b 44 24 14          	mov    0x14(%esp),%eax
f010674d:	89 f9                	mov    %edi,%ecx
f010674f:	d3 e8                	shr    %cl,%eax
f0106751:	09 d0                	or     %edx,%eax
f0106753:	d3 ee                	shr    %cl,%esi
f0106755:	89 f2                	mov    %esi,%edx
f0106757:	f7 74 24 18          	divl   0x18(%esp)
f010675b:	89 d6                	mov    %edx,%esi
f010675d:	f7 64 24 0c          	mull   0xc(%esp)
f0106761:	89 c5                	mov    %eax,%ebp
f0106763:	89 d1                	mov    %edx,%ecx
f0106765:	39 d6                	cmp    %edx,%esi
f0106767:	72 67                	jb     f01067d0 <__umoddi3+0x114>
f0106769:	74 75                	je     f01067e0 <__umoddi3+0x124>
f010676b:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010676f:	29 e8                	sub    %ebp,%eax
f0106771:	19 ce                	sbb    %ecx,%esi
f0106773:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106777:	d3 e8                	shr    %cl,%eax
f0106779:	89 f2                	mov    %esi,%edx
f010677b:	89 f9                	mov    %edi,%ecx
f010677d:	d3 e2                	shl    %cl,%edx
f010677f:	09 d0                	or     %edx,%eax
f0106781:	89 f2                	mov    %esi,%edx
f0106783:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0106787:	d3 ea                	shr    %cl,%edx
f0106789:	83 c4 20             	add    $0x20,%esp
f010678c:	5e                   	pop    %esi
f010678d:	5f                   	pop    %edi
f010678e:	5d                   	pop    %ebp
f010678f:	c3                   	ret    
f0106790:	85 c9                	test   %ecx,%ecx
f0106792:	75 0b                	jne    f010679f <__umoddi3+0xe3>
f0106794:	b8 01 00 00 00       	mov    $0x1,%eax
f0106799:	31 d2                	xor    %edx,%edx
f010679b:	f7 f1                	div    %ecx
f010679d:	89 c1                	mov    %eax,%ecx
f010679f:	89 f0                	mov    %esi,%eax
f01067a1:	31 d2                	xor    %edx,%edx
f01067a3:	f7 f1                	div    %ecx
f01067a5:	89 f8                	mov    %edi,%eax
f01067a7:	e9 3e ff ff ff       	jmp    f01066ea <__umoddi3+0x2e>
f01067ac:	89 f2                	mov    %esi,%edx
f01067ae:	83 c4 20             	add    $0x20,%esp
f01067b1:	5e                   	pop    %esi
f01067b2:	5f                   	pop    %edi
f01067b3:	5d                   	pop    %ebp
f01067b4:	c3                   	ret    
f01067b5:	8d 76 00             	lea    0x0(%esi),%esi
f01067b8:	39 f5                	cmp    %esi,%ebp
f01067ba:	72 04                	jb     f01067c0 <__umoddi3+0x104>
f01067bc:	39 f9                	cmp    %edi,%ecx
f01067be:	77 06                	ja     f01067c6 <__umoddi3+0x10a>
f01067c0:	89 f2                	mov    %esi,%edx
f01067c2:	29 cf                	sub    %ecx,%edi
f01067c4:	19 ea                	sbb    %ebp,%edx
f01067c6:	89 f8                	mov    %edi,%eax
f01067c8:	83 c4 20             	add    $0x20,%esp
f01067cb:	5e                   	pop    %esi
f01067cc:	5f                   	pop    %edi
f01067cd:	5d                   	pop    %ebp
f01067ce:	c3                   	ret    
f01067cf:	90                   	nop
f01067d0:	89 d1                	mov    %edx,%ecx
f01067d2:	89 c5                	mov    %eax,%ebp
f01067d4:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f01067d8:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f01067dc:	eb 8d                	jmp    f010676b <__umoddi3+0xaf>
f01067de:	66 90                	xchg   %ax,%ax
f01067e0:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f01067e4:	72 ea                	jb     f01067d0 <__umoddi3+0x114>
f01067e6:	89 f1                	mov    %esi,%ecx
f01067e8:	eb 81                	jmp    f010676b <__umoddi3+0xaf>
