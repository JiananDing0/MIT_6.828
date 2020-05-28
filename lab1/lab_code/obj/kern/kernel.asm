
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5f 00 00 00       	call   f010009d <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010004e:	c7 04 24 60 18 10 f0 	movl   $0xf0101860,(%esp)
f0100055:	e8 24 09 00 00       	call   f010097e <cprintf>
	if (x > 0)
f010005a:	85 db                	test   %ebx,%ebx
f010005c:	7e 0d                	jle    f010006b <test_backtrace+0x2b>
		test_backtrace(x-1);
f010005e:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100061:	89 04 24             	mov    %eax,(%esp)
f0100064:	e8 d7 ff ff ff       	call   f0100040 <test_backtrace>
f0100069:	eb 1c                	jmp    f0100087 <test_backtrace+0x47>
	else
		mon_backtrace(0, 0, 0);
f010006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100072:	00 
f0100073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010007a:	00 
f010007b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100082:	e8 cb 06 00 00       	call   f0100752 <mon_backtrace>
	cprintf("leaving test_backtrace %d\n", x);
f0100087:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010008b:	c7 04 24 7c 18 10 f0 	movl   $0xf010187c,(%esp)
f0100092:	e8 e7 08 00 00       	call   f010097e <cprintf>
}
f0100097:	83 c4 14             	add    $0x14,%esp
f010009a:	5b                   	pop    %ebx
f010009b:	5d                   	pop    %ebp
f010009c:	c3                   	ret    

f010009d <i386_init>:

void
i386_init(void)
{
f010009d:	55                   	push   %ebp
f010009e:	89 e5                	mov    %esp,%ebp
f01000a0:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a3:	b8 40 a9 11 f0       	mov    $0xf011a940,%eax
f01000a8:	2d 00 a3 11 f0       	sub    $0xf011a300,%eax
f01000ad:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000b1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01000b8:	00 
f01000b9:	c7 04 24 00 a3 11 f0 	movl   $0xf011a300,(%esp)
f01000c0:	e8 49 13 00 00       	call   f010140e <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000c5:	e8 77 04 00 00       	call   f0100541 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000ca:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f01000d1:	00 
f01000d2:	c7 04 24 97 18 10 f0 	movl   $0xf0101897,(%esp)
f01000d9:	e8 a0 08 00 00       	call   f010097e <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000de:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000e5:	e8 56 ff ff ff       	call   f0100040 <test_backtrace>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000f1:	e8 1c 07 00 00       	call   f0100812 <monitor>
f01000f6:	eb f2                	jmp    f01000ea <i386_init+0x4d>

f01000f8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f8:	55                   	push   %ebp
f01000f9:	89 e5                	mov    %esp,%ebp
f01000fb:	56                   	push   %esi
f01000fc:	53                   	push   %ebx
f01000fd:	83 ec 10             	sub    $0x10,%esp
f0100100:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100103:	83 3d 44 a9 11 f0 00 	cmpl   $0x0,0xf011a944
f010010a:	75 3d                	jne    f0100149 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f010010c:	89 35 44 a9 11 f0    	mov    %esi,0xf011a944

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100112:	fa                   	cli    
f0100113:	fc                   	cld    

	va_start(ap, fmt);
f0100114:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100117:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010011e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100121:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100125:	c7 04 24 b2 18 10 f0 	movl   $0xf01018b2,(%esp)
f010012c:	e8 4d 08 00 00       	call   f010097e <cprintf>
	vcprintf(fmt, ap);
f0100131:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100135:	89 34 24             	mov    %esi,(%esp)
f0100138:	e8 0e 08 00 00       	call   f010094b <vcprintf>
	cprintf("\n");
f010013d:	c7 04 24 ee 18 10 f0 	movl   $0xf01018ee,(%esp)
f0100144:	e8 35 08 00 00       	call   f010097e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100149:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100150:	e8 bd 06 00 00       	call   f0100812 <monitor>
f0100155:	eb f2                	jmp    f0100149 <_panic+0x51>

f0100157 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100157:	55                   	push   %ebp
f0100158:	89 e5                	mov    %esp,%ebp
f010015a:	53                   	push   %ebx
f010015b:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f010015e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100161:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100164:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100168:	8b 45 08             	mov    0x8(%ebp),%eax
f010016b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010016f:	c7 04 24 ca 18 10 f0 	movl   $0xf01018ca,(%esp)
f0100176:	e8 03 08 00 00       	call   f010097e <cprintf>
	vcprintf(fmt, ap);
f010017b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010017f:	8b 45 10             	mov    0x10(%ebp),%eax
f0100182:	89 04 24             	mov    %eax,(%esp)
f0100185:	e8 c1 07 00 00       	call   f010094b <vcprintf>
	cprintf("\n");
f010018a:	c7 04 24 ee 18 10 f0 	movl   $0xf01018ee,(%esp)
f0100191:	e8 e8 07 00 00       	call   f010097e <cprintf>
	va_end(ap);
}
f0100196:	83 c4 14             	add    $0x14,%esp
f0100199:	5b                   	pop    %ebx
f010019a:	5d                   	pop    %ebp
f010019b:	c3                   	ret    

f010019c <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f010019c:	55                   	push   %ebp
f010019d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010019f:	ba 84 00 00 00       	mov    $0x84,%edx
f01001a4:	ec                   	in     (%dx),%al
f01001a5:	ec                   	in     (%dx),%al
f01001a6:	ec                   	in     (%dx),%al
f01001a7:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01001a8:	5d                   	pop    %ebp
f01001a9:	c3                   	ret    

f01001aa <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001aa:	55                   	push   %ebp
f01001ab:	89 e5                	mov    %esp,%ebp
f01001ad:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001b2:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001b3:	a8 01                	test   $0x1,%al
f01001b5:	74 08                	je     f01001bf <serial_proc_data+0x15>
f01001b7:	b2 f8                	mov    $0xf8,%dl
f01001b9:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001ba:	0f b6 c0             	movzbl %al,%eax
f01001bd:	eb 05                	jmp    f01001c4 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001c4:	5d                   	pop    %ebp
f01001c5:	c3                   	ret    

f01001c6 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001c6:	55                   	push   %ebp
f01001c7:	89 e5                	mov    %esp,%ebp
f01001c9:	53                   	push   %ebx
f01001ca:	83 ec 04             	sub    $0x4,%esp
f01001cd:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001cf:	eb 29                	jmp    f01001fa <cons_intr+0x34>
		if (c == 0)
f01001d1:	85 c0                	test   %eax,%eax
f01001d3:	74 25                	je     f01001fa <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f01001d5:	8b 15 24 a5 11 f0    	mov    0xf011a524,%edx
f01001db:	88 82 20 a3 11 f0    	mov    %al,-0xfee5ce0(%edx)
f01001e1:	8d 42 01             	lea    0x1(%edx),%eax
f01001e4:	a3 24 a5 11 f0       	mov    %eax,0xf011a524
		if (cons.wpos == CONSBUFSIZE)
f01001e9:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001ee:	75 0a                	jne    f01001fa <cons_intr+0x34>
			cons.wpos = 0;
f01001f0:	c7 05 24 a5 11 f0 00 	movl   $0x0,0xf011a524
f01001f7:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001fa:	ff d3                	call   *%ebx
f01001fc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001ff:	75 d0                	jne    f01001d1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100201:	83 c4 04             	add    $0x4,%esp
f0100204:	5b                   	pop    %ebx
f0100205:	5d                   	pop    %ebp
f0100206:	c3                   	ret    

f0100207 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100207:	55                   	push   %ebp
f0100208:	89 e5                	mov    %esp,%ebp
f010020a:	57                   	push   %edi
f010020b:	56                   	push   %esi
f010020c:	53                   	push   %ebx
f010020d:	83 ec 2c             	sub    $0x2c,%esp
f0100210:	89 c6                	mov    %eax,%esi
f0100212:	bb 01 32 00 00       	mov    $0x3201,%ebx
f0100217:	bf fd 03 00 00       	mov    $0x3fd,%edi
f010021c:	eb 05                	jmp    f0100223 <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f010021e:	e8 79 ff ff ff       	call   f010019c <delay>
f0100223:	89 fa                	mov    %edi,%edx
f0100225:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100226:	a8 20                	test   $0x20,%al
f0100228:	75 03                	jne    f010022d <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010022a:	4b                   	dec    %ebx
f010022b:	75 f1                	jne    f010021e <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f010022d:	89 f2                	mov    %esi,%edx
f010022f:	89 f0                	mov    %esi,%eax
f0100231:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100234:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100239:	ee                   	out    %al,(%dx)
f010023a:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010023f:	bf 79 03 00 00       	mov    $0x379,%edi
f0100244:	eb 05                	jmp    f010024b <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100246:	e8 51 ff ff ff       	call   f010019c <delay>
f010024b:	89 fa                	mov    %edi,%edx
f010024d:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010024e:	84 c0                	test   %al,%al
f0100250:	78 03                	js     f0100255 <cons_putc+0x4e>
f0100252:	4b                   	dec    %ebx
f0100253:	75 f1                	jne    f0100246 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100255:	ba 78 03 00 00       	mov    $0x378,%edx
f010025a:	8a 45 e7             	mov    -0x19(%ebp),%al
f010025d:	ee                   	out    %al,(%dx)
f010025e:	b2 7a                	mov    $0x7a,%dl
f0100260:	b0 0d                	mov    $0xd,%al
f0100262:	ee                   	out    %al,(%dx)
f0100263:	b0 08                	mov    $0x8,%al
f0100265:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100266:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f010026c:	75 06                	jne    f0100274 <cons_putc+0x6d>
		c |= 0x0700;
f010026e:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100274:	89 f0                	mov    %esi,%eax
f0100276:	25 ff 00 00 00       	and    $0xff,%eax
f010027b:	83 f8 09             	cmp    $0x9,%eax
f010027e:	74 78                	je     f01002f8 <cons_putc+0xf1>
f0100280:	83 f8 09             	cmp    $0x9,%eax
f0100283:	7f 0b                	jg     f0100290 <cons_putc+0x89>
f0100285:	83 f8 08             	cmp    $0x8,%eax
f0100288:	0f 85 9e 00 00 00    	jne    f010032c <cons_putc+0x125>
f010028e:	eb 10                	jmp    f01002a0 <cons_putc+0x99>
f0100290:	83 f8 0a             	cmp    $0xa,%eax
f0100293:	74 39                	je     f01002ce <cons_putc+0xc7>
f0100295:	83 f8 0d             	cmp    $0xd,%eax
f0100298:	0f 85 8e 00 00 00    	jne    f010032c <cons_putc+0x125>
f010029e:	eb 36                	jmp    f01002d6 <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f01002a0:	66 a1 34 a5 11 f0    	mov    0xf011a534,%ax
f01002a6:	66 85 c0             	test   %ax,%ax
f01002a9:	0f 84 e2 00 00 00    	je     f0100391 <cons_putc+0x18a>
			crt_pos--;
f01002af:	48                   	dec    %eax
f01002b0:	66 a3 34 a5 11 f0    	mov    %ax,0xf011a534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01002b6:	0f b7 c0             	movzwl %ax,%eax
f01002b9:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f01002bf:	83 ce 20             	or     $0x20,%esi
f01002c2:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
f01002c8:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f01002cc:	eb 78                	jmp    f0100346 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01002ce:	66 83 05 34 a5 11 f0 	addw   $0x50,0xf011a534
f01002d5:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01002d6:	66 8b 0d 34 a5 11 f0 	mov    0xf011a534,%cx
f01002dd:	bb 50 00 00 00       	mov    $0x50,%ebx
f01002e2:	89 c8                	mov    %ecx,%eax
f01002e4:	ba 00 00 00 00       	mov    $0x0,%edx
f01002e9:	66 f7 f3             	div    %bx
f01002ec:	66 29 d1             	sub    %dx,%cx
f01002ef:	66 89 0d 34 a5 11 f0 	mov    %cx,0xf011a534
f01002f6:	eb 4e                	jmp    f0100346 <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f01002f8:	b8 20 00 00 00       	mov    $0x20,%eax
f01002fd:	e8 05 ff ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100302:	b8 20 00 00 00       	mov    $0x20,%eax
f0100307:	e8 fb fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f010030c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100311:	e8 f1 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100316:	b8 20 00 00 00       	mov    $0x20,%eax
f010031b:	e8 e7 fe ff ff       	call   f0100207 <cons_putc>
		cons_putc(' ');
f0100320:	b8 20 00 00 00       	mov    $0x20,%eax
f0100325:	e8 dd fe ff ff       	call   f0100207 <cons_putc>
f010032a:	eb 1a                	jmp    f0100346 <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010032c:	66 a1 34 a5 11 f0    	mov    0xf011a534,%ax
f0100332:	0f b7 c8             	movzwl %ax,%ecx
f0100335:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
f010033b:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f010033f:	40                   	inc    %eax
f0100340:	66 a3 34 a5 11 f0    	mov    %ax,0xf011a534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100346:	66 81 3d 34 a5 11 f0 	cmpw   $0x7cf,0xf011a534
f010034d:	cf 07 
f010034f:	76 40                	jbe    f0100391 <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100351:	a1 30 a5 11 f0       	mov    0xf011a530,%eax
f0100356:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010035d:	00 
f010035e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100364:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100368:	89 04 24             	mov    %eax,(%esp)
f010036b:	e8 e8 10 00 00       	call   f0101458 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100370:	8b 15 30 a5 11 f0    	mov    0xf011a530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100376:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f010037b:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100381:	40                   	inc    %eax
f0100382:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100387:	75 f2                	jne    f010037b <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100389:	66 83 2d 34 a5 11 f0 	subw   $0x50,0xf011a534
f0100390:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100391:	8b 0d 2c a5 11 f0    	mov    0xf011a52c,%ecx
f0100397:	b0 0e                	mov    $0xe,%al
f0100399:	89 ca                	mov    %ecx,%edx
f010039b:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010039c:	66 8b 35 34 a5 11 f0 	mov    0xf011a534,%si
f01003a3:	8d 59 01             	lea    0x1(%ecx),%ebx
f01003a6:	89 f0                	mov    %esi,%eax
f01003a8:	66 c1 e8 08          	shr    $0x8,%ax
f01003ac:	89 da                	mov    %ebx,%edx
f01003ae:	ee                   	out    %al,(%dx)
f01003af:	b0 0f                	mov    $0xf,%al
f01003b1:	89 ca                	mov    %ecx,%edx
f01003b3:	ee                   	out    %al,(%dx)
f01003b4:	89 f0                	mov    %esi,%eax
f01003b6:	89 da                	mov    %ebx,%edx
f01003b8:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01003b9:	83 c4 2c             	add    $0x2c,%esp
f01003bc:	5b                   	pop    %ebx
f01003bd:	5e                   	pop    %esi
f01003be:	5f                   	pop    %edi
f01003bf:	5d                   	pop    %ebp
f01003c0:	c3                   	ret    

f01003c1 <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01003c1:	55                   	push   %ebp
f01003c2:	89 e5                	mov    %esp,%ebp
f01003c4:	53                   	push   %ebx
f01003c5:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003c8:	ba 64 00 00 00       	mov    $0x64,%edx
f01003cd:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01003ce:	0f b6 c0             	movzbl %al,%eax
f01003d1:	a8 01                	test   $0x1,%al
f01003d3:	0f 84 e0 00 00 00    	je     f01004b9 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01003d9:	a8 20                	test   $0x20,%al
f01003db:	0f 85 df 00 00 00    	jne    f01004c0 <kbd_proc_data+0xff>
f01003e1:	b2 60                	mov    $0x60,%dl
f01003e3:	ec                   	in     (%dx),%al
f01003e4:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003e6:	3c e0                	cmp    $0xe0,%al
f01003e8:	75 11                	jne    f01003fb <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f01003ea:	83 0d 28 a5 11 f0 40 	orl    $0x40,0xf011a528
		return 0;
f01003f1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003f6:	e9 ca 00 00 00       	jmp    f01004c5 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f01003fb:	84 c0                	test   %al,%al
f01003fd:	79 33                	jns    f0100432 <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003ff:	8b 0d 28 a5 11 f0    	mov    0xf011a528,%ecx
f0100405:	f6 c1 40             	test   $0x40,%cl
f0100408:	75 05                	jne    f010040f <kbd_proc_data+0x4e>
f010040a:	88 c2                	mov    %al,%dl
f010040c:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010040f:	0f b6 d2             	movzbl %dl,%edx
f0100412:	8a 82 20 19 10 f0    	mov    -0xfefe6e0(%edx),%al
f0100418:	83 c8 40             	or     $0x40,%eax
f010041b:	0f b6 c0             	movzbl %al,%eax
f010041e:	f7 d0                	not    %eax
f0100420:	21 c1                	and    %eax,%ecx
f0100422:	89 0d 28 a5 11 f0    	mov    %ecx,0xf011a528
		return 0;
f0100428:	bb 00 00 00 00       	mov    $0x0,%ebx
f010042d:	e9 93 00 00 00       	jmp    f01004c5 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f0100432:	8b 0d 28 a5 11 f0    	mov    0xf011a528,%ecx
f0100438:	f6 c1 40             	test   $0x40,%cl
f010043b:	74 0e                	je     f010044b <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010043d:	88 c2                	mov    %al,%dl
f010043f:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f0100442:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100445:	89 0d 28 a5 11 f0    	mov    %ecx,0xf011a528
	}

	shift |= shiftcode[data];
f010044b:	0f b6 d2             	movzbl %dl,%edx
f010044e:	0f b6 82 20 19 10 f0 	movzbl -0xfefe6e0(%edx),%eax
f0100455:	0b 05 28 a5 11 f0    	or     0xf011a528,%eax
	shift ^= togglecode[data];
f010045b:	0f b6 8a 20 1a 10 f0 	movzbl -0xfefe5e0(%edx),%ecx
f0100462:	31 c8                	xor    %ecx,%eax
f0100464:	a3 28 a5 11 f0       	mov    %eax,0xf011a528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100469:	89 c1                	mov    %eax,%ecx
f010046b:	83 e1 03             	and    $0x3,%ecx
f010046e:	8b 0c 8d 20 1b 10 f0 	mov    -0xfefe4e0(,%ecx,4),%ecx
f0100475:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100479:	a8 08                	test   $0x8,%al
f010047b:	74 18                	je     f0100495 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f010047d:	8d 53 9f             	lea    -0x61(%ebx),%edx
f0100480:	83 fa 19             	cmp    $0x19,%edx
f0100483:	77 05                	ja     f010048a <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f0100485:	83 eb 20             	sub    $0x20,%ebx
f0100488:	eb 0b                	jmp    f0100495 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f010048a:	8d 53 bf             	lea    -0x41(%ebx),%edx
f010048d:	83 fa 19             	cmp    $0x19,%edx
f0100490:	77 03                	ja     f0100495 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f0100492:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100495:	f7 d0                	not    %eax
f0100497:	a8 06                	test   $0x6,%al
f0100499:	75 2a                	jne    f01004c5 <kbd_proc_data+0x104>
f010049b:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01004a1:	75 22                	jne    f01004c5 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01004a3:	c7 04 24 e4 18 10 f0 	movl   $0xf01018e4,(%esp)
f01004aa:	e8 cf 04 00 00       	call   f010097e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01004af:	ba 92 00 00 00       	mov    $0x92,%edx
f01004b4:	b0 03                	mov    $0x3,%al
f01004b6:	ee                   	out    %al,(%dx)
f01004b7:	eb 0c                	jmp    f01004c5 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01004b9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01004be:	eb 05                	jmp    f01004c5 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01004c0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01004c5:	89 d8                	mov    %ebx,%eax
f01004c7:	83 c4 14             	add    $0x14,%esp
f01004ca:	5b                   	pop    %ebx
f01004cb:	5d                   	pop    %ebp
f01004cc:	c3                   	ret    

f01004cd <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004cd:	55                   	push   %ebp
f01004ce:	89 e5                	mov    %esp,%ebp
f01004d0:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f01004d3:	80 3d 00 a3 11 f0 00 	cmpb   $0x0,0xf011a300
f01004da:	74 0a                	je     f01004e6 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f01004dc:	b8 aa 01 10 f0       	mov    $0xf01001aa,%eax
f01004e1:	e8 e0 fc ff ff       	call   f01001c6 <cons_intr>
}
f01004e6:	c9                   	leave  
f01004e7:	c3                   	ret    

f01004e8 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e8:	55                   	push   %ebp
f01004e9:	89 e5                	mov    %esp,%ebp
f01004eb:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ee:	b8 c1 03 10 f0       	mov    $0xf01003c1,%eax
f01004f3:	e8 ce fc ff ff       	call   f01001c6 <cons_intr>
}
f01004f8:	c9                   	leave  
f01004f9:	c3                   	ret    

f01004fa <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004fa:	55                   	push   %ebp
f01004fb:	89 e5                	mov    %esp,%ebp
f01004fd:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100500:	e8 c8 ff ff ff       	call   f01004cd <serial_intr>
	kbd_intr();
f0100505:	e8 de ff ff ff       	call   f01004e8 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010050a:	8b 15 20 a5 11 f0    	mov    0xf011a520,%edx
f0100510:	3b 15 24 a5 11 f0    	cmp    0xf011a524,%edx
f0100516:	74 22                	je     f010053a <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f0100518:	0f b6 82 20 a3 11 f0 	movzbl -0xfee5ce0(%edx),%eax
f010051f:	42                   	inc    %edx
f0100520:	89 15 20 a5 11 f0    	mov    %edx,0xf011a520
		if (cons.rpos == CONSBUFSIZE)
f0100526:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010052c:	75 11                	jne    f010053f <cons_getc+0x45>
			cons.rpos = 0;
f010052e:	c7 05 20 a5 11 f0 00 	movl   $0x0,0xf011a520
f0100535:	00 00 00 
f0100538:	eb 05                	jmp    f010053f <cons_getc+0x45>
		return c;
	}
	return 0;
f010053a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010053f:	c9                   	leave  
f0100540:	c3                   	ret    

f0100541 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100541:	55                   	push   %ebp
f0100542:	89 e5                	mov    %esp,%ebp
f0100544:	57                   	push   %edi
f0100545:	56                   	push   %esi
f0100546:	53                   	push   %ebx
f0100547:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010054a:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f0100551:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100558:	5a a5 
	if (*cp != 0xA55A) {
f010055a:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f0100560:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100564:	74 11                	je     f0100577 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100566:	c7 05 2c a5 11 f0 b4 	movl   $0x3b4,0xf011a52c
f010056d:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100570:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100575:	eb 16                	jmp    f010058d <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100577:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010057e:	c7 05 2c a5 11 f0 d4 	movl   $0x3d4,0xf011a52c
f0100585:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100588:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010058d:	8b 0d 2c a5 11 f0    	mov    0xf011a52c,%ecx
f0100593:	b0 0e                	mov    $0xe,%al
f0100595:	89 ca                	mov    %ecx,%edx
f0100597:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100598:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010059b:	89 da                	mov    %ebx,%edx
f010059d:	ec                   	in     (%dx),%al
f010059e:	0f b6 f8             	movzbl %al,%edi
f01005a1:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a4:	b0 0f                	mov    $0xf,%al
f01005a6:	89 ca                	mov    %ecx,%edx
f01005a8:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a9:	89 da                	mov    %ebx,%edx
f01005ab:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005ac:	89 35 30 a5 11 f0    	mov    %esi,0xf011a530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005b2:	0f b6 d8             	movzbl %al,%ebx
f01005b5:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005b7:	66 89 3d 34 a5 11 f0 	mov    %di,0xf011a534
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005be:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005c3:	b0 00                	mov    $0x0,%al
f01005c5:	89 da                	mov    %ebx,%edx
f01005c7:	ee                   	out    %al,(%dx)
f01005c8:	b2 fb                	mov    $0xfb,%dl
f01005ca:	b0 80                	mov    $0x80,%al
f01005cc:	ee                   	out    %al,(%dx)
f01005cd:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f01005d2:	b0 0c                	mov    $0xc,%al
f01005d4:	89 ca                	mov    %ecx,%edx
f01005d6:	ee                   	out    %al,(%dx)
f01005d7:	b2 f9                	mov    $0xf9,%dl
f01005d9:	b0 00                	mov    $0x0,%al
f01005db:	ee                   	out    %al,(%dx)
f01005dc:	b2 fb                	mov    $0xfb,%dl
f01005de:	b0 03                	mov    $0x3,%al
f01005e0:	ee                   	out    %al,(%dx)
f01005e1:	b2 fc                	mov    $0xfc,%dl
f01005e3:	b0 00                	mov    $0x0,%al
f01005e5:	ee                   	out    %al,(%dx)
f01005e6:	b2 f9                	mov    $0xf9,%dl
f01005e8:	b0 01                	mov    $0x1,%al
f01005ea:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005eb:	b2 fd                	mov    $0xfd,%dl
f01005ed:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005ee:	3c ff                	cmp    $0xff,%al
f01005f0:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005f4:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005f7:	a2 00 a3 11 f0       	mov    %al,0xf011a300
f01005fc:	89 da                	mov    %ebx,%edx
f01005fe:	ec                   	in     (%dx),%al
f01005ff:	89 ca                	mov    %ecx,%edx
f0100601:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100602:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f0100606:	75 0c                	jne    f0100614 <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f0100608:	c7 04 24 f0 18 10 f0 	movl   $0xf01018f0,(%esp)
f010060f:	e8 6a 03 00 00       	call   f010097e <cprintf>
}
f0100614:	83 c4 2c             	add    $0x2c,%esp
f0100617:	5b                   	pop    %ebx
f0100618:	5e                   	pop    %esi
f0100619:	5f                   	pop    %edi
f010061a:	5d                   	pop    %ebp
f010061b:	c3                   	ret    

f010061c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010061c:	55                   	push   %ebp
f010061d:	89 e5                	mov    %esp,%ebp
f010061f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100622:	8b 45 08             	mov    0x8(%ebp),%eax
f0100625:	e8 dd fb ff ff       	call   f0100207 <cons_putc>
}
f010062a:	c9                   	leave  
f010062b:	c3                   	ret    

f010062c <getchar>:

int
getchar(void)
{
f010062c:	55                   	push   %ebp
f010062d:	89 e5                	mov    %esp,%ebp
f010062f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100632:	e8 c3 fe ff ff       	call   f01004fa <cons_getc>
f0100637:	85 c0                	test   %eax,%eax
f0100639:	74 f7                	je     f0100632 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010063b:	c9                   	leave  
f010063c:	c3                   	ret    

f010063d <iscons>:

int
iscons(int fdnum)
{
f010063d:	55                   	push   %ebp
f010063e:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100640:	b8 01 00 00 00       	mov    $0x1,%eax
f0100645:	5d                   	pop    %ebp
f0100646:	c3                   	ret    
	...

f0100648 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100648:	55                   	push   %ebp
f0100649:	89 e5                	mov    %esp,%ebp
f010064b:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010064e:	c7 04 24 30 1b 10 f0 	movl   $0xf0101b30,(%esp)
f0100655:	e8 24 03 00 00       	call   f010097e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010065a:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100661:	00 
f0100662:	c7 04 24 e8 1b 10 f0 	movl   $0xf0101be8,(%esp)
f0100669:	e8 10 03 00 00       	call   f010097e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010066e:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100675:	00 
f0100676:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f010067d:	f0 
f010067e:	c7 04 24 10 1c 10 f0 	movl   $0xf0101c10,(%esp)
f0100685:	e8 f4 02 00 00       	call   f010097e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010068a:	c7 44 24 08 52 18 10 	movl   $0x101852,0x8(%esp)
f0100691:	00 
f0100692:	c7 44 24 04 52 18 10 	movl   $0xf0101852,0x4(%esp)
f0100699:	f0 
f010069a:	c7 04 24 34 1c 10 f0 	movl   $0xf0101c34,(%esp)
f01006a1:	e8 d8 02 00 00       	call   f010097e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006a6:	c7 44 24 08 00 a3 11 	movl   $0x11a300,0x8(%esp)
f01006ad:	00 
f01006ae:	c7 44 24 04 00 a3 11 	movl   $0xf011a300,0x4(%esp)
f01006b5:	f0 
f01006b6:	c7 04 24 58 1c 10 f0 	movl   $0xf0101c58,(%esp)
f01006bd:	e8 bc 02 00 00       	call   f010097e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006c2:	c7 44 24 08 40 a9 11 	movl   $0x11a940,0x8(%esp)
f01006c9:	00 
f01006ca:	c7 44 24 04 40 a9 11 	movl   $0xf011a940,0x4(%esp)
f01006d1:	f0 
f01006d2:	c7 04 24 7c 1c 10 f0 	movl   $0xf0101c7c,(%esp)
f01006d9:	e8 a0 02 00 00       	call   f010097e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006de:	b8 3f ad 11 f0       	mov    $0xf011ad3f,%eax
f01006e3:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006e8:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006ed:	89 c2                	mov    %eax,%edx
f01006ef:	85 c0                	test   %eax,%eax
f01006f1:	79 06                	jns    f01006f9 <mon_kerninfo+0xb1>
f01006f3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006f9:	c1 fa 0a             	sar    $0xa,%edx
f01006fc:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100700:	c7 04 24 a0 1c 10 f0 	movl   $0xf0101ca0,(%esp)
f0100707:	e8 72 02 00 00       	call   f010097e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010070c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100711:	c9                   	leave  
f0100712:	c3                   	ret    

f0100713 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100713:	55                   	push   %ebp
f0100714:	89 e5                	mov    %esp,%ebp
f0100716:	53                   	push   %ebx
f0100717:	83 ec 14             	sub    $0x14,%esp
f010071a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010071f:	8b 83 a4 1d 10 f0    	mov    -0xfefe25c(%ebx),%eax
f0100725:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100729:	8b 83 a0 1d 10 f0    	mov    -0xfefe260(%ebx),%eax
f010072f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100733:	c7 04 24 49 1b 10 f0 	movl   $0xf0101b49,(%esp)
f010073a:	e8 3f 02 00 00       	call   f010097e <cprintf>
f010073f:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f0100742:	83 fb 24             	cmp    $0x24,%ebx
f0100745:	75 d8                	jne    f010071f <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100747:	b8 00 00 00 00       	mov    $0x0,%eax
f010074c:	83 c4 14             	add    $0x14,%esp
f010074f:	5b                   	pop    %ebx
f0100750:	5d                   	pop    %ebp
f0100751:	c3                   	ret    

f0100752 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100752:	55                   	push   %ebp
f0100753:	89 e5                	mov    %esp,%ebp
f0100755:	57                   	push   %edi
f0100756:	56                   	push   %esi
f0100757:	53                   	push   %ebx
f0100758:	83 ec 5c             	sub    $0x5c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010075b:	89 eb                	mov    %ebp,%ebx
	uint32_t ebp = read_ebp();
	uint32_t eip;
	uint32_t args[5];
	struct Eipdebuginfo info;
	// Print statements
	cprintf("Stack backtrace:\n");
f010075d:	c7 04 24 52 1b 10 f0 	movl   $0xf0101b52,(%esp)
f0100764:	e8 15 02 00 00       	call   f010097e <cprintf>
	while (ebp) {
f0100769:	e9 8f 00 00 00       	jmp    f01007fd <mon_backtrace+0xab>
		// CALL assembly will always push the return address to stack. As a result, we 
		// can always find it on stack before the function is called.
		eip = *((uint32_t *)(ebp + 4));
f010076e:	8b 73 04             	mov    0x4(%ebx),%esi
		// All the arguments are pushed onto the stack right before function is CALLed, 
		// which means we can find them before the CALL command is executed and push.
		args[0] = *((uint32_t *)(ebp + 8));
f0100771:	8b 43 08             	mov    0x8(%ebx),%eax
f0100774:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		args[1] = *((uint32_t *)(ebp + 12));
f0100777:	8b 43 0c             	mov    0xc(%ebx),%eax
f010077a:	89 45 c0             	mov    %eax,-0x40(%ebp)
		args[2] = *((uint32_t *)(ebp + 16));
f010077d:	8b 43 10             	mov    0x10(%ebx),%eax
f0100780:	89 45 bc             	mov    %eax,-0x44(%ebp)
		args[3] = *((uint32_t *)(ebp + 20));
f0100783:	8b 43 14             	mov    0x14(%ebx),%eax
f0100786:	89 45 b8             	mov    %eax,-0x48(%ebp)
		args[4] = *((uint32_t *)(ebp + 24));
f0100789:	8b 7b 18             	mov    0x18(%ebx),%edi
		// Get corresponding debug information from debuginfo_eip() function
		debuginfo_eip(eip, &info);
f010078c:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010078f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100793:	89 34 24             	mov    %esi,(%esp)
f0100796:	e8 dd 02 00 00       	call   f0100a78 <debuginfo_eip>
		// Print debug line
		cprintf("  ebp %08x  eip %08x  arg %08x %08x %08x %08x %08x\n", ebp, eip, args[0], args[1], args[2], args[3], args[4]);
f010079b:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f010079f:	8b 45 b8             	mov    -0x48(%ebp),%eax
f01007a2:	89 44 24 18          	mov    %eax,0x18(%esp)
f01007a6:	8b 45 bc             	mov    -0x44(%ebp),%eax
f01007a9:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007ad:	8b 45 c0             	mov    -0x40(%ebp),%eax
f01007b0:	89 44 24 10          	mov    %eax,0x10(%esp)
f01007b4:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01007b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007bb:	89 74 24 08          	mov    %esi,0x8(%esp)
f01007bf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01007c3:	c7 04 24 cc 1c 10 f0 	movl   $0xf0101ccc,(%esp)
f01007ca:	e8 af 01 00 00       	call   f010097e <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, info.eip_line);
f01007cf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01007d2:	89 44 24 14          	mov    %eax,0x14(%esp)
f01007d6:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01007d9:	89 54 24 10          	mov    %edx,0x10(%esp)
f01007dd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01007e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01007e4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007e8:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ef:	c7 04 24 64 1b 10 f0 	movl   $0xf0101b64,(%esp)
f01007f6:	e8 83 01 00 00       	call   f010097e <cprintf>
		ebp = (uint32_t)(* (uint32_t *)ebp);
f01007fb:	8b 1b                	mov    (%ebx),%ebx
	uint32_t eip;
	uint32_t args[5];
	struct Eipdebuginfo info;
	// Print statements
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01007fd:	85 db                	test   %ebx,%ebx
f01007ff:	0f 85 69 ff ff ff    	jne    f010076e <mon_backtrace+0x1c>
		cprintf("  ebp %08x  eip %08x  arg %08x %08x %08x %08x %08x\n", ebp, eip, args[0], args[1], args[2], args[3], args[4]);
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, info.eip_line);
		ebp = (uint32_t)(* (uint32_t *)ebp);
	}
	return 0;
}
f0100805:	b8 00 00 00 00       	mov    $0x0,%eax
f010080a:	83 c4 5c             	add    $0x5c,%esp
f010080d:	5b                   	pop    %ebx
f010080e:	5e                   	pop    %esi
f010080f:	5f                   	pop    %edi
f0100810:	5d                   	pop    %ebp
f0100811:	c3                   	ret    

f0100812 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100812:	55                   	push   %ebp
f0100813:	89 e5                	mov    %esp,%ebp
f0100815:	57                   	push   %edi
f0100816:	56                   	push   %esi
f0100817:	53                   	push   %ebx
f0100818:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010081b:	c7 04 24 00 1d 10 f0 	movl   $0xf0101d00,(%esp)
f0100822:	e8 57 01 00 00       	call   f010097e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100827:	c7 04 24 24 1d 10 f0 	movl   $0xf0101d24,(%esp)
f010082e:	e8 4b 01 00 00       	call   f010097e <cprintf>


	while (1) {
		buf = readline("K> ");
f0100833:	c7 04 24 75 1b 10 f0 	movl   $0xf0101b75,(%esp)
f010083a:	e8 a5 09 00 00       	call   f01011e4 <readline>
f010083f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100841:	85 c0                	test   %eax,%eax
f0100843:	74 ee                	je     f0100833 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100845:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010084c:	be 00 00 00 00       	mov    $0x0,%esi
f0100851:	eb 04                	jmp    f0100857 <monitor+0x45>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100853:	c6 03 00             	movb   $0x0,(%ebx)
f0100856:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100857:	8a 03                	mov    (%ebx),%al
f0100859:	84 c0                	test   %al,%al
f010085b:	74 5e                	je     f01008bb <monitor+0xa9>
f010085d:	0f be c0             	movsbl %al,%eax
f0100860:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100864:	c7 04 24 79 1b 10 f0 	movl   $0xf0101b79,(%esp)
f010086b:	e8 69 0b 00 00       	call   f01013d9 <strchr>
f0100870:	85 c0                	test   %eax,%eax
f0100872:	75 df                	jne    f0100853 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100874:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100877:	74 42                	je     f01008bb <monitor+0xa9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100879:	83 fe 0f             	cmp    $0xf,%esi
f010087c:	75 16                	jne    f0100894 <monitor+0x82>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010087e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100885:	00 
f0100886:	c7 04 24 7e 1b 10 f0 	movl   $0xf0101b7e,(%esp)
f010088d:	e8 ec 00 00 00       	call   f010097e <cprintf>
f0100892:	eb 9f                	jmp    f0100833 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100894:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100898:	46                   	inc    %esi
f0100899:	eb 01                	jmp    f010089c <monitor+0x8a>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010089b:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010089c:	8a 03                	mov    (%ebx),%al
f010089e:	84 c0                	test   %al,%al
f01008a0:	74 b5                	je     f0100857 <monitor+0x45>
f01008a2:	0f be c0             	movsbl %al,%eax
f01008a5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a9:	c7 04 24 79 1b 10 f0 	movl   $0xf0101b79,(%esp)
f01008b0:	e8 24 0b 00 00       	call   f01013d9 <strchr>
f01008b5:	85 c0                	test   %eax,%eax
f01008b7:	74 e2                	je     f010089b <monitor+0x89>
f01008b9:	eb 9c                	jmp    f0100857 <monitor+0x45>
			buf++;
	}
	argv[argc] = 0;
f01008bb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01008c2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008c3:	85 f6                	test   %esi,%esi
f01008c5:	0f 84 68 ff ff ff    	je     f0100833 <monitor+0x21>
f01008cb:	bb a0 1d 10 f0       	mov    $0xf0101da0,%ebx
f01008d0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008d5:	8b 03                	mov    (%ebx),%eax
f01008d7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008db:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008de:	89 04 24             	mov    %eax,(%esp)
f01008e1:	e8 a0 0a 00 00       	call   f0101386 <strcmp>
f01008e6:	85 c0                	test   %eax,%eax
f01008e8:	75 24                	jne    f010090e <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f01008ea:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008ed:	8b 55 08             	mov    0x8(%ebp),%edx
f01008f0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008f4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008f7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008fb:	89 34 24             	mov    %esi,(%esp)
f01008fe:	ff 14 85 a8 1d 10 f0 	call   *-0xfefe258(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100905:	85 c0                	test   %eax,%eax
f0100907:	78 26                	js     f010092f <monitor+0x11d>
f0100909:	e9 25 ff ff ff       	jmp    f0100833 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010090e:	47                   	inc    %edi
f010090f:	83 c3 0c             	add    $0xc,%ebx
f0100912:	83 ff 03             	cmp    $0x3,%edi
f0100915:	75 be                	jne    f01008d5 <monitor+0xc3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100917:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010091a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010091e:	c7 04 24 9b 1b 10 f0 	movl   $0xf0101b9b,(%esp)
f0100925:	e8 54 00 00 00       	call   f010097e <cprintf>
f010092a:	e9 04 ff ff ff       	jmp    f0100833 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010092f:	83 c4 5c             	add    $0x5c,%esp
f0100932:	5b                   	pop    %ebx
f0100933:	5e                   	pop    %esi
f0100934:	5f                   	pop    %edi
f0100935:	5d                   	pop    %ebp
f0100936:	c3                   	ret    
	...

f0100938 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100938:	55                   	push   %ebp
f0100939:	89 e5                	mov    %esp,%ebp
f010093b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f010093e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100941:	89 04 24             	mov    %eax,(%esp)
f0100944:	e8 d3 fc ff ff       	call   f010061c <cputchar>
	*cnt++;
}
f0100949:	c9                   	leave  
f010094a:	c3                   	ret    

f010094b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010094b:	55                   	push   %ebp
f010094c:	89 e5                	mov    %esp,%ebp
f010094e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0100951:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100958:	8b 45 0c             	mov    0xc(%ebp),%eax
f010095b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010095f:	8b 45 08             	mov    0x8(%ebp),%eax
f0100962:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100966:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100969:	89 44 24 04          	mov    %eax,0x4(%esp)
f010096d:	c7 04 24 38 09 10 f0 	movl   $0xf0100938,(%esp)
f0100974:	e8 55 04 00 00       	call   f0100dce <vprintfmt>
	return cnt;
}
f0100979:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010097c:	c9                   	leave  
f010097d:	c3                   	ret    

f010097e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010097e:	55                   	push   %ebp
f010097f:	89 e5                	mov    %esp,%ebp
f0100981:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0100984:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0100987:	89 44 24 04          	mov    %eax,0x4(%esp)
f010098b:	8b 45 08             	mov    0x8(%ebp),%eax
f010098e:	89 04 24             	mov    %eax,(%esp)
f0100991:	e8 b5 ff ff ff       	call   f010094b <vcprintf>
	va_end(ap);

	return cnt;
}
f0100996:	c9                   	leave  
f0100997:	c3                   	ret    

f0100998 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0100998:	55                   	push   %ebp
f0100999:	89 e5                	mov    %esp,%ebp
f010099b:	57                   	push   %edi
f010099c:	56                   	push   %esi
f010099d:	53                   	push   %ebx
f010099e:	83 ec 10             	sub    $0x10,%esp
f01009a1:	89 c3                	mov    %eax,%ebx
f01009a3:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01009a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f01009a9:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009ac:	8b 0a                	mov    (%edx),%ecx
f01009ae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009b1:	8b 00                	mov    (%eax),%eax
f01009b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009b6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f01009bd:	eb 77                	jmp    f0100a36 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f01009bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009c2:	01 c8                	add    %ecx,%eax
f01009c4:	bf 02 00 00 00       	mov    $0x2,%edi
f01009c9:	99                   	cltd   
f01009ca:	f7 ff                	idiv   %edi
f01009cc:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009ce:	eb 01                	jmp    f01009d1 <stab_binsearch+0x39>
			m--;
f01009d0:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009d1:	39 ca                	cmp    %ecx,%edx
f01009d3:	7c 1d                	jl     f01009f2 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01009d5:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009d8:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f01009dd:	39 f7                	cmp    %esi,%edi
f01009df:	75 ef                	jne    f01009d0 <stab_binsearch+0x38>
f01009e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01009e4:	6b fa 0c             	imul   $0xc,%edx,%edi
f01009e7:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f01009eb:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f01009ee:	73 18                	jae    f0100a08 <stab_binsearch+0x70>
f01009f0:	eb 05                	jmp    f01009f7 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01009f2:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f01009f5:	eb 3f                	jmp    f0100a36 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f01009f7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f01009fa:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f01009fc:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01009ff:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a06:	eb 2e                	jmp    f0100a36 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a08:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0100a0b:	76 15                	jbe    f0100a22 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0100a0d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100a10:	4f                   	dec    %edi
f0100a11:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0100a14:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a17:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a19:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0100a20:	eb 14                	jmp    f0100a36 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a22:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0100a25:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0100a28:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0100a2a:	ff 45 0c             	incl   0xc(%ebp)
f0100a2d:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a2f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a36:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0100a39:	7e 84                	jle    f01009bf <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a3b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0100a3f:	75 0d                	jne    f0100a4e <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0100a41:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a44:	8b 02                	mov    (%edx),%eax
f0100a46:	48                   	dec    %eax
f0100a47:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100a4a:	89 01                	mov    %eax,(%ecx)
f0100a4c:	eb 22                	jmp    f0100a70 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a4e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0100a51:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a53:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a56:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a58:	eb 01                	jmp    f0100a5b <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a5a:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a5b:	39 c1                	cmp    %eax,%ecx
f0100a5d:	7d 0c                	jge    f0100a6b <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0100a5f:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0100a62:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0100a67:	39 f2                	cmp    %esi,%edx
f0100a69:	75 ef                	jne    f0100a5a <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a6b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0100a6e:	89 02                	mov    %eax,(%edx)
	}
}
f0100a70:	83 c4 10             	add    $0x10,%esp
f0100a73:	5b                   	pop    %ebx
f0100a74:	5e                   	pop    %esi
f0100a75:	5f                   	pop    %edi
f0100a76:	5d                   	pop    %ebp
f0100a77:	c3                   	ret    

f0100a78 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100a78:	55                   	push   %ebp
f0100a79:	89 e5                	mov    %esp,%ebp
f0100a7b:	57                   	push   %edi
f0100a7c:	56                   	push   %esi
f0100a7d:	53                   	push   %ebx
f0100a7e:	83 ec 4c             	sub    $0x4c,%esp
f0100a81:	8b 75 08             	mov    0x8(%ebp),%esi
f0100a84:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100a87:	c7 03 c4 1d 10 f0    	movl   $0xf0101dc4,(%ebx)
	info->eip_line = 0;
f0100a8d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100a94:	c7 43 08 c4 1d 10 f0 	movl   $0xf0101dc4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100a9b:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100aa2:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100aa5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100aac:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ab2:	76 12                	jbe    f0100ac6 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ab4:	b8 79 f2 10 f0       	mov    $0xf010f279,%eax
f0100ab9:	3d ed 65 10 f0       	cmp    $0xf01065ed,%eax
f0100abe:	0f 86 93 01 00 00    	jbe    f0100c57 <debuginfo_eip+0x1df>
f0100ac4:	eb 1c                	jmp    f0100ae2 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100ac6:	c7 44 24 08 ce 1d 10 	movl   $0xf0101dce,0x8(%esp)
f0100acd:	f0 
f0100ace:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0100ad5:	00 
f0100ad6:	c7 04 24 db 1d 10 f0 	movl   $0xf0101ddb,(%esp)
f0100add:	e8 16 f6 ff ff       	call   f01000f8 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ae2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ae7:	80 3d 78 f2 10 f0 00 	cmpb   $0x0,0xf010f278
f0100aee:	0f 85 6f 01 00 00    	jne    f0100c63 <debuginfo_eip+0x1eb>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100af4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100afb:	b8 ec 65 10 f0       	mov    $0xf01065ec,%eax
f0100b00:	2d fc 1f 10 f0       	sub    $0xf0101ffc,%eax
f0100b05:	c1 f8 02             	sar    $0x2,%eax
f0100b08:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b0e:	48                   	dec    %eax
f0100b0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b12:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b16:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0100b1d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b20:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b23:	b8 fc 1f 10 f0       	mov    $0xf0101ffc,%eax
f0100b28:	e8 6b fe ff ff       	call   f0100998 <stab_binsearch>
	if (lfile == 0)
f0100b2d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0100b30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0100b35:	85 d2                	test   %edx,%edx
f0100b37:	0f 84 26 01 00 00    	je     f0100c63 <debuginfo_eip+0x1eb>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b3d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0100b40:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b43:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b46:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100b4a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0100b51:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b54:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b57:	b8 fc 1f 10 f0       	mov    $0xf0101ffc,%eax
f0100b5c:	e8 37 fe ff ff       	call   f0100998 <stab_binsearch>

	if (lfun <= rfun) {
f0100b61:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b64:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b67:	39 d0                	cmp    %edx,%eax
f0100b69:	7f 3e                	jg     f0100ba9 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b6b:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0100b6e:	8d b9 fc 1f 10 f0    	lea    -0xfefe004(%ecx),%edi
f0100b74:	8b 89 fc 1f 10 f0    	mov    -0xfefe004(%ecx),%ecx
f0100b7a:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0100b7d:	b9 79 f2 10 f0       	mov    $0xf010f279,%ecx
f0100b82:	81 e9 ed 65 10 f0    	sub    $0xf01065ed,%ecx
f0100b88:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0100b8b:	73 0c                	jae    f0100b99 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100b8d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0100b90:	81 c1 ed 65 10 f0    	add    $0xf01065ed,%ecx
f0100b96:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100b99:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100b9c:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100b9f:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100ba1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100ba4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100ba7:	eb 0f                	jmp    f0100bb8 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100ba9:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100baf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bb2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bb5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bb8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0100bbf:	00 
f0100bc0:	8b 43 08             	mov    0x8(%ebx),%eax
f0100bc3:	89 04 24             	mov    %eax,(%esp)
f0100bc6:	e8 2b 08 00 00       	call   f01013f6 <strfind>
f0100bcb:	2b 43 08             	sub    0x8(%ebx),%eax
f0100bce:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100bd1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100bd5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0100bdc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bdf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100be2:	b8 fc 1f 10 f0       	mov    $0xf0101ffc,%eax
f0100be7:	e8 ac fd ff ff       	call   f0100998 <stab_binsearch>
	info->eip_line = rline;
f0100bec:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100bef:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100bf2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100bf5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100bf8:	eb 01                	jmp    f0100bfb <debuginfo_eip+0x183>
f0100bfa:	48                   	dec    %eax
f0100bfb:	89 c6                	mov    %eax,%esi
f0100bfd:	39 c7                	cmp    %eax,%edi
f0100bff:	7f 26                	jg     f0100c27 <debuginfo_eip+0x1af>
	       && stabs[lline].n_type != N_SOL
f0100c01:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100c04:	8d 0c 95 fc 1f 10 f0 	lea    -0xfefe004(,%edx,4),%ecx
f0100c0b:	8a 51 04             	mov    0x4(%ecx),%dl
f0100c0e:	80 fa 84             	cmp    $0x84,%dl
f0100c11:	74 58                	je     f0100c6b <debuginfo_eip+0x1f3>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c13:	80 fa 64             	cmp    $0x64,%dl
f0100c16:	75 e2                	jne    f0100bfa <debuginfo_eip+0x182>
f0100c18:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0100c1c:	74 dc                	je     f0100bfa <debuginfo_eip+0x182>
f0100c1e:	eb 4b                	jmp    f0100c6b <debuginfo_eip+0x1f3>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c20:	05 ed 65 10 f0       	add    $0xf01065ed,%eax
f0100c25:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c27:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0100c2a:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c2d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c32:	39 d1                	cmp    %edx,%ecx
f0100c34:	7d 2d                	jge    f0100c63 <debuginfo_eip+0x1eb>
		for (lline = lfun + 1;
f0100c36:	8d 41 01             	lea    0x1(%ecx),%eax
f0100c39:	eb 03                	jmp    f0100c3e <debuginfo_eip+0x1c6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c3b:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c3e:	39 d0                	cmp    %edx,%eax
f0100c40:	7d 1c                	jge    f0100c5e <debuginfo_eip+0x1e6>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c42:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100c45:	40                   	inc    %eax
f0100c46:	80 3c 8d 00 20 10 f0 	cmpb   $0xa0,-0xfefe000(,%ecx,4)
f0100c4d:	a0 
f0100c4e:	74 eb                	je     f0100c3b <debuginfo_eip+0x1c3>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c50:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c55:	eb 0c                	jmp    f0100c63 <debuginfo_eip+0x1eb>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100c5c:	eb 05                	jmp    f0100c63 <debuginfo_eip+0x1eb>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100c63:	83 c4 4c             	add    $0x4c,%esp
f0100c66:	5b                   	pop    %ebx
f0100c67:	5e                   	pop    %esi
f0100c68:	5f                   	pop    %edi
f0100c69:	5d                   	pop    %ebp
f0100c6a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c6b:	6b f6 0c             	imul   $0xc,%esi,%esi
f0100c6e:	8b 86 fc 1f 10 f0    	mov    -0xfefe004(%esi),%eax
f0100c74:	ba 79 f2 10 f0       	mov    $0xf010f279,%edx
f0100c79:	81 ea ed 65 10 f0    	sub    $0xf01065ed,%edx
f0100c7f:	39 d0                	cmp    %edx,%eax
f0100c81:	72 9d                	jb     f0100c20 <debuginfo_eip+0x1a8>
f0100c83:	eb a2                	jmp    f0100c27 <debuginfo_eip+0x1af>
f0100c85:	00 00                	add    %al,(%eax)
	...

f0100c88 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100c88:	55                   	push   %ebp
f0100c89:	89 e5                	mov    %esp,%ebp
f0100c8b:	57                   	push   %edi
f0100c8c:	56                   	push   %esi
f0100c8d:	53                   	push   %ebx
f0100c8e:	83 ec 3c             	sub    $0x3c,%esp
f0100c91:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100c94:	89 d7                	mov    %edx,%edi
f0100c96:	8b 45 08             	mov    0x8(%ebp),%eax
f0100c99:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0100c9c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100c9f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100ca2:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0100ca5:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ca8:	85 c0                	test   %eax,%eax
f0100caa:	75 08                	jne    f0100cb4 <printnum+0x2c>
f0100cac:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100caf:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cb2:	77 57                	ja     f0100d0b <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cb4:	89 74 24 10          	mov    %esi,0x10(%esp)
f0100cb8:	4b                   	dec    %ebx
f0100cb9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0100cbd:	8b 45 10             	mov    0x10(%ebp),%eax
f0100cc0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100cc4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0100cc8:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0100ccc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100cd3:	00 
f0100cd4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100cd7:	89 04 24             	mov    %eax,(%esp)
f0100cda:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100cdd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ce1:	e8 1e 09 00 00       	call   f0101604 <__udivdi3>
f0100ce6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100cea:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0100cee:	89 04 24             	mov    %eax,(%esp)
f0100cf1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100cf5:	89 fa                	mov    %edi,%edx
f0100cf7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100cfa:	e8 89 ff ff ff       	call   f0100c88 <printnum>
f0100cff:	eb 0f                	jmp    f0100d10 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d01:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d05:	89 34 24             	mov    %esi,(%esp)
f0100d08:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d0b:	4b                   	dec    %ebx
f0100d0c:	85 db                	test   %ebx,%ebx
f0100d0e:	7f f1                	jg     f0100d01 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d10:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d14:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0100d18:	8b 45 10             	mov    0x10(%ebp),%eax
f0100d1b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100d1f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0100d26:	00 
f0100d27:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100d2a:	89 04 24             	mov    %eax,(%esp)
f0100d2d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100d30:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100d34:	e8 eb 09 00 00       	call   f0101724 <__umoddi3>
f0100d39:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100d3d:	0f be 80 e9 1d 10 f0 	movsbl -0xfefe217(%eax),%eax
f0100d44:	89 04 24             	mov    %eax,(%esp)
f0100d47:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0100d4a:	83 c4 3c             	add    $0x3c,%esp
f0100d4d:	5b                   	pop    %ebx
f0100d4e:	5e                   	pop    %esi
f0100d4f:	5f                   	pop    %edi
f0100d50:	5d                   	pop    %ebp
f0100d51:	c3                   	ret    

f0100d52 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d52:	55                   	push   %ebp
f0100d53:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d55:	83 fa 01             	cmp    $0x1,%edx
f0100d58:	7e 0e                	jle    f0100d68 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d5a:	8b 10                	mov    (%eax),%edx
f0100d5c:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d5f:	89 08                	mov    %ecx,(%eax)
f0100d61:	8b 02                	mov    (%edx),%eax
f0100d63:	8b 52 04             	mov    0x4(%edx),%edx
f0100d66:	eb 22                	jmp    f0100d8a <getuint+0x38>
	else if (lflag)
f0100d68:	85 d2                	test   %edx,%edx
f0100d6a:	74 10                	je     f0100d7c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d6c:	8b 10                	mov    (%eax),%edx
f0100d6e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d71:	89 08                	mov    %ecx,(%eax)
f0100d73:	8b 02                	mov    (%edx),%eax
f0100d75:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d7a:	eb 0e                	jmp    f0100d8a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100d7c:	8b 10                	mov    (%eax),%edx
f0100d7e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d81:	89 08                	mov    %ecx,(%eax)
f0100d83:	8b 02                	mov    (%edx),%eax
f0100d85:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100d8a:	5d                   	pop    %ebp
f0100d8b:	c3                   	ret    

f0100d8c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100d8c:	55                   	push   %ebp
f0100d8d:	89 e5                	mov    %esp,%ebp
f0100d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100d92:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0100d95:	8b 10                	mov    (%eax),%edx
f0100d97:	3b 50 04             	cmp    0x4(%eax),%edx
f0100d9a:	73 08                	jae    f0100da4 <sprintputch+0x18>
		*b->buf++ = ch;
f0100d9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0100d9f:	88 0a                	mov    %cl,(%edx)
f0100da1:	42                   	inc    %edx
f0100da2:	89 10                	mov    %edx,(%eax)
}
f0100da4:	5d                   	pop    %ebp
f0100da5:	c3                   	ret    

f0100da6 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100da6:	55                   	push   %ebp
f0100da7:	89 e5                	mov    %esp,%ebp
f0100da9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0100dac:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100daf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100db3:	8b 45 10             	mov    0x10(%ebp),%eax
f0100db6:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100dba:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100dbd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100dc1:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dc4:	89 04 24             	mov    %eax,(%esp)
f0100dc7:	e8 02 00 00 00       	call   f0100dce <vprintfmt>
	va_end(ap);
}
f0100dcc:	c9                   	leave  
f0100dcd:	c3                   	ret    

f0100dce <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100dce:	55                   	push   %ebp
f0100dcf:	89 e5                	mov    %esp,%ebp
f0100dd1:	57                   	push   %edi
f0100dd2:	56                   	push   %esi
f0100dd3:	53                   	push   %ebx
f0100dd4:	83 ec 4c             	sub    $0x4c,%esp
f0100dd7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dda:	8b 75 10             	mov    0x10(%ebp),%esi
f0100ddd:	eb 12                	jmp    f0100df1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100ddf:	85 c0                	test   %eax,%eax
f0100de1:	0f 84 6b 03 00 00    	je     f0101152 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0100de7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100deb:	89 04 24             	mov    %eax,(%esp)
f0100dee:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100df1:	0f b6 06             	movzbl (%esi),%eax
f0100df4:	46                   	inc    %esi
f0100df5:	83 f8 25             	cmp    $0x25,%eax
f0100df8:	75 e5                	jne    f0100ddf <vprintfmt+0x11>
f0100dfa:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0100dfe:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0100e05:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0100e0a:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0100e11:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e16:	eb 26                	jmp    f0100e3e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e18:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e1b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0100e1f:	eb 1d                	jmp    f0100e3e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e21:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e24:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0100e28:	eb 14                	jmp    f0100e3e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e2a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0100e2d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0100e34:	eb 08                	jmp    f0100e3e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0100e36:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0100e39:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e3e:	0f b6 06             	movzbl (%esi),%eax
f0100e41:	8d 56 01             	lea    0x1(%esi),%edx
f0100e44:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100e47:	8a 16                	mov    (%esi),%dl
f0100e49:	83 ea 23             	sub    $0x23,%edx
f0100e4c:	80 fa 55             	cmp    $0x55,%dl
f0100e4f:	0f 87 e1 02 00 00    	ja     f0101136 <vprintfmt+0x368>
f0100e55:	0f b6 d2             	movzbl %dl,%edx
f0100e58:	ff 24 95 78 1e 10 f0 	jmp    *-0xfefe188(,%edx,4)
f0100e5f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e62:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e67:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0100e6a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0100e6e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0100e71:	8d 50 d0             	lea    -0x30(%eax),%edx
f0100e74:	83 fa 09             	cmp    $0x9,%edx
f0100e77:	77 2a                	ja     f0100ea3 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e79:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e7a:	eb eb                	jmp    f0100e67 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e7c:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e7f:	8d 50 04             	lea    0x4(%eax),%edx
f0100e82:	89 55 14             	mov    %edx,0x14(%ebp)
f0100e85:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e87:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100e8a:	eb 17                	jmp    f0100ea3 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0100e8c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100e90:	78 98                	js     f0100e2a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e92:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100e95:	eb a7                	jmp    f0100e3e <vprintfmt+0x70>
f0100e97:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100e9a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0100ea1:	eb 9b                	jmp    f0100e3e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0100ea3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0100ea7:	79 95                	jns    f0100e3e <vprintfmt+0x70>
f0100ea9:	eb 8b                	jmp    f0100e36 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100eab:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eac:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100eaf:	eb 8d                	jmp    f0100e3e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100eb1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100eb4:	8d 50 04             	lea    0x4(%eax),%edx
f0100eb7:	89 55 14             	mov    %edx,0x14(%ebp)
f0100eba:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ebe:	8b 00                	mov    (%eax),%eax
f0100ec0:	89 04 24             	mov    %eax,(%esp)
f0100ec3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ec6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100ec9:	e9 23 ff ff ff       	jmp    f0100df1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100ece:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ed1:	8d 50 04             	lea    0x4(%eax),%edx
f0100ed4:	89 55 14             	mov    %edx,0x14(%ebp)
f0100ed7:	8b 00                	mov    (%eax),%eax
f0100ed9:	85 c0                	test   %eax,%eax
f0100edb:	79 02                	jns    f0100edf <vprintfmt+0x111>
f0100edd:	f7 d8                	neg    %eax
f0100edf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100ee1:	83 f8 06             	cmp    $0x6,%eax
f0100ee4:	7f 0b                	jg     f0100ef1 <vprintfmt+0x123>
f0100ee6:	8b 04 85 d0 1f 10 f0 	mov    -0xfefe030(,%eax,4),%eax
f0100eed:	85 c0                	test   %eax,%eax
f0100eef:	75 23                	jne    f0100f14 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0100ef1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100ef5:	c7 44 24 08 01 1e 10 	movl   $0xf0101e01,0x8(%esp)
f0100efc:	f0 
f0100efd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f01:	8b 45 08             	mov    0x8(%ebp),%eax
f0100f04:	89 04 24             	mov    %eax,(%esp)
f0100f07:	e8 9a fe ff ff       	call   f0100da6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f0c:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f0f:	e9 dd fe ff ff       	jmp    f0100df1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0100f14:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f18:	c7 44 24 08 0a 1e 10 	movl   $0xf0101e0a,0x8(%esp)
f0100f1f:	f0 
f0100f20:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100f24:	8b 55 08             	mov    0x8(%ebp),%edx
f0100f27:	89 14 24             	mov    %edx,(%esp)
f0100f2a:	e8 77 fe ff ff       	call   f0100da6 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f2f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100f32:	e9 ba fe ff ff       	jmp    f0100df1 <vprintfmt+0x23>
f0100f37:	89 f9                	mov    %edi,%ecx
f0100f39:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100f3c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f3f:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f42:	8d 50 04             	lea    0x4(%eax),%edx
f0100f45:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f48:	8b 30                	mov    (%eax),%esi
f0100f4a:	85 f6                	test   %esi,%esi
f0100f4c:	75 05                	jne    f0100f53 <vprintfmt+0x185>
				p = "(null)";
f0100f4e:	be fa 1d 10 f0       	mov    $0xf0101dfa,%esi
			if (width > 0 && padc != '-')
f0100f53:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0100f57:	0f 8e 84 00 00 00    	jle    f0100fe1 <vprintfmt+0x213>
f0100f5d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0100f61:	74 7e                	je     f0100fe1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f63:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0100f67:	89 34 24             	mov    %esi,(%esp)
f0100f6a:	e8 53 03 00 00       	call   f01012c2 <strnlen>
f0100f6f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100f72:	29 c2                	sub    %eax,%edx
f0100f74:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0100f77:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0100f7b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0100f7e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0100f81:	89 de                	mov    %ebx,%esi
f0100f83:	89 d3                	mov    %edx,%ebx
f0100f85:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f87:	eb 0b                	jmp    f0100f94 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0100f89:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100f8d:	89 3c 24             	mov    %edi,(%esp)
f0100f90:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f93:	4b                   	dec    %ebx
f0100f94:	85 db                	test   %ebx,%ebx
f0100f96:	7f f1                	jg     f0100f89 <vprintfmt+0x1bb>
f0100f98:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0100f9b:	89 f3                	mov    %esi,%ebx
f0100f9d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0100fa0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100fa3:	85 c0                	test   %eax,%eax
f0100fa5:	79 05                	jns    f0100fac <vprintfmt+0x1de>
f0100fa7:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100faf:	29 c2                	sub    %eax,%edx
f0100fb1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100fb4:	eb 2b                	jmp    f0100fe1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fb6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0100fba:	74 18                	je     f0100fd4 <vprintfmt+0x206>
f0100fbc:	8d 50 e0             	lea    -0x20(%eax),%edx
f0100fbf:	83 fa 5e             	cmp    $0x5e,%edx
f0100fc2:	76 10                	jbe    f0100fd4 <vprintfmt+0x206>
					putch('?', putdat);
f0100fc4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fc8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0100fcf:	ff 55 08             	call   *0x8(%ebp)
f0100fd2:	eb 0a                	jmp    f0100fde <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0100fd4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fd8:	89 04 24             	mov    %eax,(%esp)
f0100fdb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0100fde:	ff 4d e4             	decl   -0x1c(%ebp)
f0100fe1:	0f be 06             	movsbl (%esi),%eax
f0100fe4:	46                   	inc    %esi
f0100fe5:	85 c0                	test   %eax,%eax
f0100fe7:	74 21                	je     f010100a <vprintfmt+0x23c>
f0100fe9:	85 ff                	test   %edi,%edi
f0100feb:	78 c9                	js     f0100fb6 <vprintfmt+0x1e8>
f0100fed:	4f                   	dec    %edi
f0100fee:	79 c6                	jns    f0100fb6 <vprintfmt+0x1e8>
f0100ff0:	8b 7d 08             	mov    0x8(%ebp),%edi
f0100ff3:	89 de                	mov    %ebx,%esi
f0100ff5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100ff8:	eb 18                	jmp    f0101012 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0100ffa:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100ffe:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0101005:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101007:	4b                   	dec    %ebx
f0101008:	eb 08                	jmp    f0101012 <vprintfmt+0x244>
f010100a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010100d:	89 de                	mov    %ebx,%esi
f010100f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0101012:	85 db                	test   %ebx,%ebx
f0101014:	7f e4                	jg     f0100ffa <vprintfmt+0x22c>
f0101016:	89 7d 08             	mov    %edi,0x8(%ebp)
f0101019:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010101b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010101e:	e9 ce fd ff ff       	jmp    f0100df1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101023:	83 f9 01             	cmp    $0x1,%ecx
f0101026:	7e 10                	jle    f0101038 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0101028:	8b 45 14             	mov    0x14(%ebp),%eax
f010102b:	8d 50 08             	lea    0x8(%eax),%edx
f010102e:	89 55 14             	mov    %edx,0x14(%ebp)
f0101031:	8b 30                	mov    (%eax),%esi
f0101033:	8b 78 04             	mov    0x4(%eax),%edi
f0101036:	eb 26                	jmp    f010105e <vprintfmt+0x290>
	else if (lflag)
f0101038:	85 c9                	test   %ecx,%ecx
f010103a:	74 12                	je     f010104e <vprintfmt+0x280>
		return va_arg(*ap, long);
f010103c:	8b 45 14             	mov    0x14(%ebp),%eax
f010103f:	8d 50 04             	lea    0x4(%eax),%edx
f0101042:	89 55 14             	mov    %edx,0x14(%ebp)
f0101045:	8b 30                	mov    (%eax),%esi
f0101047:	89 f7                	mov    %esi,%edi
f0101049:	c1 ff 1f             	sar    $0x1f,%edi
f010104c:	eb 10                	jmp    f010105e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010104e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101051:	8d 50 04             	lea    0x4(%eax),%edx
f0101054:	89 55 14             	mov    %edx,0x14(%ebp)
f0101057:	8b 30                	mov    (%eax),%esi
f0101059:	89 f7                	mov    %esi,%edi
f010105b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010105e:	85 ff                	test   %edi,%edi
f0101060:	78 0a                	js     f010106c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101062:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101067:	e9 8c 00 00 00       	jmp    f01010f8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010106c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101070:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0101077:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010107a:	f7 de                	neg    %esi
f010107c:	83 d7 00             	adc    $0x0,%edi
f010107f:	f7 df                	neg    %edi
			}
			base = 10;
f0101081:	b8 0a 00 00 00       	mov    $0xa,%eax
f0101086:	eb 70                	jmp    f01010f8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101088:	89 ca                	mov    %ecx,%edx
f010108a:	8d 45 14             	lea    0x14(%ebp),%eax
f010108d:	e8 c0 fc ff ff       	call   f0100d52 <getuint>
f0101092:	89 c6                	mov    %eax,%esi
f0101094:	89 d7                	mov    %edx,%edi
			base = 10;
f0101096:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010109b:	eb 5b                	jmp    f01010f8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010109d:	89 ca                	mov    %ecx,%edx
f010109f:	8d 45 14             	lea    0x14(%ebp),%eax
f01010a2:	e8 ab fc ff ff       	call   f0100d52 <getuint>
f01010a7:	89 c6                	mov    %eax,%esi
f01010a9:	89 d7                	mov    %edx,%edi
			base = 8;
f01010ab:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01010b0:	eb 46                	jmp    f01010f8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f01010b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010b6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01010bd:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01010c0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010c4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01010cb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01010ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d1:	8d 50 04             	lea    0x4(%eax),%edx
f01010d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01010d7:	8b 30                	mov    (%eax),%esi
f01010d9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01010de:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01010e3:	eb 13                	jmp    f01010f8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01010e5:	89 ca                	mov    %ecx,%edx
f01010e7:	8d 45 14             	lea    0x14(%ebp),%eax
f01010ea:	e8 63 fc ff ff       	call   f0100d52 <getuint>
f01010ef:	89 c6                	mov    %eax,%esi
f01010f1:	89 d7                	mov    %edx,%edi
			base = 16;
f01010f3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01010f8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01010fc:	89 54 24 10          	mov    %edx,0x10(%esp)
f0101100:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101103:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101107:	89 44 24 08          	mov    %eax,0x8(%esp)
f010110b:	89 34 24             	mov    %esi,(%esp)
f010110e:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101112:	89 da                	mov    %ebx,%edx
f0101114:	8b 45 08             	mov    0x8(%ebp),%eax
f0101117:	e8 6c fb ff ff       	call   f0100c88 <printnum>
			break;
f010111c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010111f:	e9 cd fc ff ff       	jmp    f0100df1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101124:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101128:	89 04 24             	mov    %eax,(%esp)
f010112b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010112e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101131:	e9 bb fc ff ff       	jmp    f0100df1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101136:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010113a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0101141:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101144:	eb 01                	jmp    f0101147 <vprintfmt+0x379>
f0101146:	4e                   	dec    %esi
f0101147:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010114b:	75 f9                	jne    f0101146 <vprintfmt+0x378>
f010114d:	e9 9f fc ff ff       	jmp    f0100df1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0101152:	83 c4 4c             	add    $0x4c,%esp
f0101155:	5b                   	pop    %ebx
f0101156:	5e                   	pop    %esi
f0101157:	5f                   	pop    %edi
f0101158:	5d                   	pop    %ebp
f0101159:	c3                   	ret    

f010115a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010115a:	55                   	push   %ebp
f010115b:	89 e5                	mov    %esp,%ebp
f010115d:	83 ec 28             	sub    $0x28,%esp
f0101160:	8b 45 08             	mov    0x8(%ebp),%eax
f0101163:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101166:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101169:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010116d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101170:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101177:	85 c0                	test   %eax,%eax
f0101179:	74 30                	je     f01011ab <vsnprintf+0x51>
f010117b:	85 d2                	test   %edx,%edx
f010117d:	7e 33                	jle    f01011b2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010117f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101182:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101186:	8b 45 10             	mov    0x10(%ebp),%eax
f0101189:	89 44 24 08          	mov    %eax,0x8(%esp)
f010118d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101190:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101194:	c7 04 24 8c 0d 10 f0 	movl   $0xf0100d8c,(%esp)
f010119b:	e8 2e fc ff ff       	call   f0100dce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011a0:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011a3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011a9:	eb 0c                	jmp    f01011b7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01011b0:	eb 05                	jmp    f01011b7 <vsnprintf+0x5d>
f01011b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011b7:	c9                   	leave  
f01011b8:	c3                   	ret    

f01011b9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011b9:	55                   	push   %ebp
f01011ba:	89 e5                	mov    %esp,%ebp
f01011bc:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011bf:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011c6:	8b 45 10             	mov    0x10(%ebp),%eax
f01011c9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01011cd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011d0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01011d7:	89 04 24             	mov    %eax,(%esp)
f01011da:	e8 7b ff ff ff       	call   f010115a <vsnprintf>
	va_end(ap);

	return rc;
}
f01011df:	c9                   	leave  
f01011e0:	c3                   	ret    
f01011e1:	00 00                	add    %al,(%eax)
	...

f01011e4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01011e4:	55                   	push   %ebp
f01011e5:	89 e5                	mov    %esp,%ebp
f01011e7:	57                   	push   %edi
f01011e8:	56                   	push   %esi
f01011e9:	53                   	push   %ebx
f01011ea:	83 ec 1c             	sub    $0x1c,%esp
f01011ed:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01011f0:	85 c0                	test   %eax,%eax
f01011f2:	74 10                	je     f0101204 <readline+0x20>
		cprintf("%s", prompt);
f01011f4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01011f8:	c7 04 24 0a 1e 10 f0 	movl   $0xf0101e0a,(%esp)
f01011ff:	e8 7a f7 ff ff       	call   f010097e <cprintf>

	i = 0;
	echoing = iscons(0);
f0101204:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010120b:	e8 2d f4 ff ff       	call   f010063d <iscons>
f0101210:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101212:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101217:	e8 10 f4 ff ff       	call   f010062c <getchar>
f010121c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010121e:	85 c0                	test   %eax,%eax
f0101220:	79 17                	jns    f0101239 <readline+0x55>
			cprintf("read error: %e\n", c);
f0101222:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101226:	c7 04 24 ec 1f 10 f0 	movl   $0xf0101fec,(%esp)
f010122d:	e8 4c f7 ff ff       	call   f010097e <cprintf>
			return NULL;
f0101232:	b8 00 00 00 00       	mov    $0x0,%eax
f0101237:	eb 69                	jmp    f01012a2 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101239:	83 f8 08             	cmp    $0x8,%eax
f010123c:	74 05                	je     f0101243 <readline+0x5f>
f010123e:	83 f8 7f             	cmp    $0x7f,%eax
f0101241:	75 17                	jne    f010125a <readline+0x76>
f0101243:	85 f6                	test   %esi,%esi
f0101245:	7e 13                	jle    f010125a <readline+0x76>
			if (echoing)
f0101247:	85 ff                	test   %edi,%edi
f0101249:	74 0c                	je     f0101257 <readline+0x73>
				cputchar('\b');
f010124b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0101252:	e8 c5 f3 ff ff       	call   f010061c <cputchar>
			i--;
f0101257:	4e                   	dec    %esi
f0101258:	eb bd                	jmp    f0101217 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010125a:	83 fb 1f             	cmp    $0x1f,%ebx
f010125d:	7e 1d                	jle    f010127c <readline+0x98>
f010125f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101265:	7f 15                	jg     f010127c <readline+0x98>
			if (echoing)
f0101267:	85 ff                	test   %edi,%edi
f0101269:	74 08                	je     f0101273 <readline+0x8f>
				cputchar(c);
f010126b:	89 1c 24             	mov    %ebx,(%esp)
f010126e:	e8 a9 f3 ff ff       	call   f010061c <cputchar>
			buf[i++] = c;
f0101273:	88 9e 40 a5 11 f0    	mov    %bl,-0xfee5ac0(%esi)
f0101279:	46                   	inc    %esi
f010127a:	eb 9b                	jmp    f0101217 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010127c:	83 fb 0a             	cmp    $0xa,%ebx
f010127f:	74 05                	je     f0101286 <readline+0xa2>
f0101281:	83 fb 0d             	cmp    $0xd,%ebx
f0101284:	75 91                	jne    f0101217 <readline+0x33>
			if (echoing)
f0101286:	85 ff                	test   %edi,%edi
f0101288:	74 0c                	je     f0101296 <readline+0xb2>
				cputchar('\n');
f010128a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0101291:	e8 86 f3 ff ff       	call   f010061c <cputchar>
			buf[i] = 0;
f0101296:	c6 86 40 a5 11 f0 00 	movb   $0x0,-0xfee5ac0(%esi)
			return buf;
f010129d:	b8 40 a5 11 f0       	mov    $0xf011a540,%eax
		}
	}
}
f01012a2:	83 c4 1c             	add    $0x1c,%esp
f01012a5:	5b                   	pop    %ebx
f01012a6:	5e                   	pop    %esi
f01012a7:	5f                   	pop    %edi
f01012a8:	5d                   	pop    %ebp
f01012a9:	c3                   	ret    
	...

f01012ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012ac:	55                   	push   %ebp
f01012ad:	89 e5                	mov    %esp,%ebp
f01012af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01012b7:	eb 01                	jmp    f01012ba <strlen+0xe>
		n++;
f01012b9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012ba:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012be:	75 f9                	jne    f01012b9 <strlen+0xd>
		n++;
	return n;
}
f01012c0:	5d                   	pop    %ebp
f01012c1:	c3                   	ret    

f01012c2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012c2:	55                   	push   %ebp
f01012c3:	89 e5                	mov    %esp,%ebp
f01012c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01012c8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01012d0:	eb 01                	jmp    f01012d3 <strnlen+0x11>
		n++;
f01012d2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012d3:	39 d0                	cmp    %edx,%eax
f01012d5:	74 06                	je     f01012dd <strnlen+0x1b>
f01012d7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01012db:	75 f5                	jne    f01012d2 <strnlen+0x10>
		n++;
	return n;
}
f01012dd:	5d                   	pop    %ebp
f01012de:	c3                   	ret    

f01012df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01012df:	55                   	push   %ebp
f01012e0:	89 e5                	mov    %esp,%ebp
f01012e2:	53                   	push   %ebx
f01012e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01012e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01012e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01012ee:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01012f1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01012f4:	42                   	inc    %edx
f01012f5:	84 c9                	test   %cl,%cl
f01012f7:	75 f5                	jne    f01012ee <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01012f9:	5b                   	pop    %ebx
f01012fa:	5d                   	pop    %ebp
f01012fb:	c3                   	ret    

f01012fc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01012fc:	55                   	push   %ebp
f01012fd:	89 e5                	mov    %esp,%ebp
f01012ff:	53                   	push   %ebx
f0101300:	83 ec 08             	sub    $0x8,%esp
f0101303:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101306:	89 1c 24             	mov    %ebx,(%esp)
f0101309:	e8 9e ff ff ff       	call   f01012ac <strlen>
	strcpy(dst + len, src);
f010130e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101311:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101315:	01 d8                	add    %ebx,%eax
f0101317:	89 04 24             	mov    %eax,(%esp)
f010131a:	e8 c0 ff ff ff       	call   f01012df <strcpy>
	return dst;
}
f010131f:	89 d8                	mov    %ebx,%eax
f0101321:	83 c4 08             	add    $0x8,%esp
f0101324:	5b                   	pop    %ebx
f0101325:	5d                   	pop    %ebp
f0101326:	c3                   	ret    

f0101327 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101327:	55                   	push   %ebp
f0101328:	89 e5                	mov    %esp,%ebp
f010132a:	56                   	push   %esi
f010132b:	53                   	push   %ebx
f010132c:	8b 45 08             	mov    0x8(%ebp),%eax
f010132f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101332:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101335:	b9 00 00 00 00       	mov    $0x0,%ecx
f010133a:	eb 0c                	jmp    f0101348 <strncpy+0x21>
		*dst++ = *src;
f010133c:	8a 1a                	mov    (%edx),%bl
f010133e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101341:	80 3a 01             	cmpb   $0x1,(%edx)
f0101344:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101347:	41                   	inc    %ecx
f0101348:	39 f1                	cmp    %esi,%ecx
f010134a:	75 f0                	jne    f010133c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010134c:	5b                   	pop    %ebx
f010134d:	5e                   	pop    %esi
f010134e:	5d                   	pop    %ebp
f010134f:	c3                   	ret    

f0101350 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101350:	55                   	push   %ebp
f0101351:	89 e5                	mov    %esp,%ebp
f0101353:	56                   	push   %esi
f0101354:	53                   	push   %ebx
f0101355:	8b 75 08             	mov    0x8(%ebp),%esi
f0101358:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010135b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010135e:	85 d2                	test   %edx,%edx
f0101360:	75 0a                	jne    f010136c <strlcpy+0x1c>
f0101362:	89 f0                	mov    %esi,%eax
f0101364:	eb 1a                	jmp    f0101380 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101366:	88 18                	mov    %bl,(%eax)
f0101368:	40                   	inc    %eax
f0101369:	41                   	inc    %ecx
f010136a:	eb 02                	jmp    f010136e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010136c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010136e:	4a                   	dec    %edx
f010136f:	74 0a                	je     f010137b <strlcpy+0x2b>
f0101371:	8a 19                	mov    (%ecx),%bl
f0101373:	84 db                	test   %bl,%bl
f0101375:	75 ef                	jne    f0101366 <strlcpy+0x16>
f0101377:	89 c2                	mov    %eax,%edx
f0101379:	eb 02                	jmp    f010137d <strlcpy+0x2d>
f010137b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010137d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0101380:	29 f0                	sub    %esi,%eax
}
f0101382:	5b                   	pop    %ebx
f0101383:	5e                   	pop    %esi
f0101384:	5d                   	pop    %ebp
f0101385:	c3                   	ret    

f0101386 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101386:	55                   	push   %ebp
f0101387:	89 e5                	mov    %esp,%ebp
f0101389:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010138c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010138f:	eb 02                	jmp    f0101393 <strcmp+0xd>
		p++, q++;
f0101391:	41                   	inc    %ecx
f0101392:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101393:	8a 01                	mov    (%ecx),%al
f0101395:	84 c0                	test   %al,%al
f0101397:	74 04                	je     f010139d <strcmp+0x17>
f0101399:	3a 02                	cmp    (%edx),%al
f010139b:	74 f4                	je     f0101391 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010139d:	0f b6 c0             	movzbl %al,%eax
f01013a0:	0f b6 12             	movzbl (%edx),%edx
f01013a3:	29 d0                	sub    %edx,%eax
}
f01013a5:	5d                   	pop    %ebp
f01013a6:	c3                   	ret    

f01013a7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013a7:	55                   	push   %ebp
f01013a8:	89 e5                	mov    %esp,%ebp
f01013aa:	53                   	push   %ebx
f01013ab:	8b 45 08             	mov    0x8(%ebp),%eax
f01013ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013b1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01013b4:	eb 03                	jmp    f01013b9 <strncmp+0x12>
		n--, p++, q++;
f01013b6:	4a                   	dec    %edx
f01013b7:	40                   	inc    %eax
f01013b8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013b9:	85 d2                	test   %edx,%edx
f01013bb:	74 14                	je     f01013d1 <strncmp+0x2a>
f01013bd:	8a 18                	mov    (%eax),%bl
f01013bf:	84 db                	test   %bl,%bl
f01013c1:	74 04                	je     f01013c7 <strncmp+0x20>
f01013c3:	3a 19                	cmp    (%ecx),%bl
f01013c5:	74 ef                	je     f01013b6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01013c7:	0f b6 00             	movzbl (%eax),%eax
f01013ca:	0f b6 11             	movzbl (%ecx),%edx
f01013cd:	29 d0                	sub    %edx,%eax
f01013cf:	eb 05                	jmp    f01013d6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01013d1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01013d6:	5b                   	pop    %ebx
f01013d7:	5d                   	pop    %ebp
f01013d8:	c3                   	ret    

f01013d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01013d9:	55                   	push   %ebp
f01013da:	89 e5                	mov    %esp,%ebp
f01013dc:	8b 45 08             	mov    0x8(%ebp),%eax
f01013df:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013e2:	eb 05                	jmp    f01013e9 <strchr+0x10>
		if (*s == c)
f01013e4:	38 ca                	cmp    %cl,%dl
f01013e6:	74 0c                	je     f01013f4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01013e8:	40                   	inc    %eax
f01013e9:	8a 10                	mov    (%eax),%dl
f01013eb:	84 d2                	test   %dl,%dl
f01013ed:	75 f5                	jne    f01013e4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01013ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01013f4:	5d                   	pop    %ebp
f01013f5:	c3                   	ret    

f01013f6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01013f6:	55                   	push   %ebp
f01013f7:	89 e5                	mov    %esp,%ebp
f01013f9:	8b 45 08             	mov    0x8(%ebp),%eax
f01013fc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01013ff:	eb 05                	jmp    f0101406 <strfind+0x10>
		if (*s == c)
f0101401:	38 ca                	cmp    %cl,%dl
f0101403:	74 07                	je     f010140c <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0101405:	40                   	inc    %eax
f0101406:	8a 10                	mov    (%eax),%dl
f0101408:	84 d2                	test   %dl,%dl
f010140a:	75 f5                	jne    f0101401 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f010140c:	5d                   	pop    %ebp
f010140d:	c3                   	ret    

f010140e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f010140e:	55                   	push   %ebp
f010140f:	89 e5                	mov    %esp,%ebp
f0101411:	57                   	push   %edi
f0101412:	56                   	push   %esi
f0101413:	53                   	push   %ebx
f0101414:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101417:	8b 45 0c             	mov    0xc(%ebp),%eax
f010141a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010141d:	85 c9                	test   %ecx,%ecx
f010141f:	74 30                	je     f0101451 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101421:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0101427:	75 25                	jne    f010144e <memset+0x40>
f0101429:	f6 c1 03             	test   $0x3,%cl
f010142c:	75 20                	jne    f010144e <memset+0x40>
		c &= 0xFF;
f010142e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101431:	89 d3                	mov    %edx,%ebx
f0101433:	c1 e3 08             	shl    $0x8,%ebx
f0101436:	89 d6                	mov    %edx,%esi
f0101438:	c1 e6 18             	shl    $0x18,%esi
f010143b:	89 d0                	mov    %edx,%eax
f010143d:	c1 e0 10             	shl    $0x10,%eax
f0101440:	09 f0                	or     %esi,%eax
f0101442:	09 d0                	or     %edx,%eax
f0101444:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0101446:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0101449:	fc                   	cld    
f010144a:	f3 ab                	rep stos %eax,%es:(%edi)
f010144c:	eb 03                	jmp    f0101451 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010144e:	fc                   	cld    
f010144f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0101451:	89 f8                	mov    %edi,%eax
f0101453:	5b                   	pop    %ebx
f0101454:	5e                   	pop    %esi
f0101455:	5f                   	pop    %edi
f0101456:	5d                   	pop    %ebp
f0101457:	c3                   	ret    

f0101458 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0101458:	55                   	push   %ebp
f0101459:	89 e5                	mov    %esp,%ebp
f010145b:	57                   	push   %edi
f010145c:	56                   	push   %esi
f010145d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101460:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101463:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0101466:	39 c6                	cmp    %eax,%esi
f0101468:	73 34                	jae    f010149e <memmove+0x46>
f010146a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010146d:	39 d0                	cmp    %edx,%eax
f010146f:	73 2d                	jae    f010149e <memmove+0x46>
		s += n;
		d += n;
f0101471:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101474:	f6 c2 03             	test   $0x3,%dl
f0101477:	75 1b                	jne    f0101494 <memmove+0x3c>
f0101479:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010147f:	75 13                	jne    f0101494 <memmove+0x3c>
f0101481:	f6 c1 03             	test   $0x3,%cl
f0101484:	75 0e                	jne    f0101494 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0101486:	83 ef 04             	sub    $0x4,%edi
f0101489:	8d 72 fc             	lea    -0x4(%edx),%esi
f010148c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010148f:	fd                   	std    
f0101490:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101492:	eb 07                	jmp    f010149b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0101494:	4f                   	dec    %edi
f0101495:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101498:	fd                   	std    
f0101499:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010149b:	fc                   	cld    
f010149c:	eb 20                	jmp    f01014be <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010149e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014a4:	75 13                	jne    f01014b9 <memmove+0x61>
f01014a6:	a8 03                	test   $0x3,%al
f01014a8:	75 0f                	jne    f01014b9 <memmove+0x61>
f01014aa:	f6 c1 03             	test   $0x3,%cl
f01014ad:	75 0a                	jne    f01014b9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01014af:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01014b2:	89 c7                	mov    %eax,%edi
f01014b4:	fc                   	cld    
f01014b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014b7:	eb 05                	jmp    f01014be <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01014b9:	89 c7                	mov    %eax,%edi
f01014bb:	fc                   	cld    
f01014bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01014be:	5e                   	pop    %esi
f01014bf:	5f                   	pop    %edi
f01014c0:	5d                   	pop    %ebp
f01014c1:	c3                   	ret    

f01014c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01014c2:	55                   	push   %ebp
f01014c3:	89 e5                	mov    %esp,%ebp
f01014c5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01014c8:	8b 45 10             	mov    0x10(%ebp),%eax
f01014cb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01014cf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014d2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01014d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d9:	89 04 24             	mov    %eax,(%esp)
f01014dc:	e8 77 ff ff ff       	call   f0101458 <memmove>
}
f01014e1:	c9                   	leave  
f01014e2:	c3                   	ret    

f01014e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01014e3:	55                   	push   %ebp
f01014e4:	89 e5                	mov    %esp,%ebp
f01014e6:	57                   	push   %edi
f01014e7:	56                   	push   %esi
f01014e8:	53                   	push   %ebx
f01014e9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014ec:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01014f2:	ba 00 00 00 00       	mov    $0x0,%edx
f01014f7:	eb 16                	jmp    f010150f <memcmp+0x2c>
		if (*s1 != *s2)
f01014f9:	8a 04 17             	mov    (%edi,%edx,1),%al
f01014fc:	42                   	inc    %edx
f01014fd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0101501:	38 c8                	cmp    %cl,%al
f0101503:	74 0a                	je     f010150f <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0101505:	0f b6 c0             	movzbl %al,%eax
f0101508:	0f b6 c9             	movzbl %cl,%ecx
f010150b:	29 c8                	sub    %ecx,%eax
f010150d:	eb 09                	jmp    f0101518 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010150f:	39 da                	cmp    %ebx,%edx
f0101511:	75 e6                	jne    f01014f9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101513:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101518:	5b                   	pop    %ebx
f0101519:	5e                   	pop    %esi
f010151a:	5f                   	pop    %edi
f010151b:	5d                   	pop    %ebp
f010151c:	c3                   	ret    

f010151d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010151d:	55                   	push   %ebp
f010151e:	89 e5                	mov    %esp,%ebp
f0101520:	8b 45 08             	mov    0x8(%ebp),%eax
f0101523:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0101526:	89 c2                	mov    %eax,%edx
f0101528:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010152b:	eb 05                	jmp    f0101532 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f010152d:	38 08                	cmp    %cl,(%eax)
f010152f:	74 05                	je     f0101536 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101531:	40                   	inc    %eax
f0101532:	39 d0                	cmp    %edx,%eax
f0101534:	72 f7                	jb     f010152d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101536:	5d                   	pop    %ebp
f0101537:	c3                   	ret    

f0101538 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0101538:	55                   	push   %ebp
f0101539:	89 e5                	mov    %esp,%ebp
f010153b:	57                   	push   %edi
f010153c:	56                   	push   %esi
f010153d:	53                   	push   %ebx
f010153e:	8b 55 08             	mov    0x8(%ebp),%edx
f0101541:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101544:	eb 01                	jmp    f0101547 <strtol+0xf>
		s++;
f0101546:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101547:	8a 02                	mov    (%edx),%al
f0101549:	3c 20                	cmp    $0x20,%al
f010154b:	74 f9                	je     f0101546 <strtol+0xe>
f010154d:	3c 09                	cmp    $0x9,%al
f010154f:	74 f5                	je     f0101546 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101551:	3c 2b                	cmp    $0x2b,%al
f0101553:	75 08                	jne    f010155d <strtol+0x25>
		s++;
f0101555:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0101556:	bf 00 00 00 00       	mov    $0x0,%edi
f010155b:	eb 13                	jmp    f0101570 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010155d:	3c 2d                	cmp    $0x2d,%al
f010155f:	75 0a                	jne    f010156b <strtol+0x33>
		s++, neg = 1;
f0101561:	8d 52 01             	lea    0x1(%edx),%edx
f0101564:	bf 01 00 00 00       	mov    $0x1,%edi
f0101569:	eb 05                	jmp    f0101570 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010156b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0101570:	85 db                	test   %ebx,%ebx
f0101572:	74 05                	je     f0101579 <strtol+0x41>
f0101574:	83 fb 10             	cmp    $0x10,%ebx
f0101577:	75 28                	jne    f01015a1 <strtol+0x69>
f0101579:	8a 02                	mov    (%edx),%al
f010157b:	3c 30                	cmp    $0x30,%al
f010157d:	75 10                	jne    f010158f <strtol+0x57>
f010157f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0101583:	75 0a                	jne    f010158f <strtol+0x57>
		s += 2, base = 16;
f0101585:	83 c2 02             	add    $0x2,%edx
f0101588:	bb 10 00 00 00       	mov    $0x10,%ebx
f010158d:	eb 12                	jmp    f01015a1 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010158f:	85 db                	test   %ebx,%ebx
f0101591:	75 0e                	jne    f01015a1 <strtol+0x69>
f0101593:	3c 30                	cmp    $0x30,%al
f0101595:	75 05                	jne    f010159c <strtol+0x64>
		s++, base = 8;
f0101597:	42                   	inc    %edx
f0101598:	b3 08                	mov    $0x8,%bl
f010159a:	eb 05                	jmp    f01015a1 <strtol+0x69>
	else if (base == 0)
		base = 10;
f010159c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01015a1:	b8 00 00 00 00       	mov    $0x0,%eax
f01015a6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015a8:	8a 0a                	mov    (%edx),%cl
f01015aa:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01015ad:	80 fb 09             	cmp    $0x9,%bl
f01015b0:	77 08                	ja     f01015ba <strtol+0x82>
			dig = *s - '0';
f01015b2:	0f be c9             	movsbl %cl,%ecx
f01015b5:	83 e9 30             	sub    $0x30,%ecx
f01015b8:	eb 1e                	jmp    f01015d8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01015ba:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01015bd:	80 fb 19             	cmp    $0x19,%bl
f01015c0:	77 08                	ja     f01015ca <strtol+0x92>
			dig = *s - 'a' + 10;
f01015c2:	0f be c9             	movsbl %cl,%ecx
f01015c5:	83 e9 57             	sub    $0x57,%ecx
f01015c8:	eb 0e                	jmp    f01015d8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01015ca:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01015cd:	80 fb 19             	cmp    $0x19,%bl
f01015d0:	77 12                	ja     f01015e4 <strtol+0xac>
			dig = *s - 'A' + 10;
f01015d2:	0f be c9             	movsbl %cl,%ecx
f01015d5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01015d8:	39 f1                	cmp    %esi,%ecx
f01015da:	7d 0c                	jge    f01015e8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01015dc:	42                   	inc    %edx
f01015dd:	0f af c6             	imul   %esi,%eax
f01015e0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01015e2:	eb c4                	jmp    f01015a8 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01015e4:	89 c1                	mov    %eax,%ecx
f01015e6:	eb 02                	jmp    f01015ea <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01015e8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01015ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01015ee:	74 05                	je     f01015f5 <strtol+0xbd>
		*endptr = (char *) s;
f01015f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01015f3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01015f5:	85 ff                	test   %edi,%edi
f01015f7:	74 04                	je     f01015fd <strtol+0xc5>
f01015f9:	89 c8                	mov    %ecx,%eax
f01015fb:	f7 d8                	neg    %eax
}
f01015fd:	5b                   	pop    %ebx
f01015fe:	5e                   	pop    %esi
f01015ff:	5f                   	pop    %edi
f0101600:	5d                   	pop    %ebp
f0101601:	c3                   	ret    
	...

f0101604 <__udivdi3>:
f0101604:	55                   	push   %ebp
f0101605:	57                   	push   %edi
f0101606:	56                   	push   %esi
f0101607:	83 ec 10             	sub    $0x10,%esp
f010160a:	8b 74 24 20          	mov    0x20(%esp),%esi
f010160e:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0101612:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101616:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010161a:	89 cd                	mov    %ecx,%ebp
f010161c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0101620:	85 c0                	test   %eax,%eax
f0101622:	75 2c                	jne    f0101650 <__udivdi3+0x4c>
f0101624:	39 f9                	cmp    %edi,%ecx
f0101626:	77 68                	ja     f0101690 <__udivdi3+0x8c>
f0101628:	85 c9                	test   %ecx,%ecx
f010162a:	75 0b                	jne    f0101637 <__udivdi3+0x33>
f010162c:	b8 01 00 00 00       	mov    $0x1,%eax
f0101631:	31 d2                	xor    %edx,%edx
f0101633:	f7 f1                	div    %ecx
f0101635:	89 c1                	mov    %eax,%ecx
f0101637:	31 d2                	xor    %edx,%edx
f0101639:	89 f8                	mov    %edi,%eax
f010163b:	f7 f1                	div    %ecx
f010163d:	89 c7                	mov    %eax,%edi
f010163f:	89 f0                	mov    %esi,%eax
f0101641:	f7 f1                	div    %ecx
f0101643:	89 c6                	mov    %eax,%esi
f0101645:	89 f0                	mov    %esi,%eax
f0101647:	89 fa                	mov    %edi,%edx
f0101649:	83 c4 10             	add    $0x10,%esp
f010164c:	5e                   	pop    %esi
f010164d:	5f                   	pop    %edi
f010164e:	5d                   	pop    %ebp
f010164f:	c3                   	ret    
f0101650:	39 f8                	cmp    %edi,%eax
f0101652:	77 2c                	ja     f0101680 <__udivdi3+0x7c>
f0101654:	0f bd f0             	bsr    %eax,%esi
f0101657:	83 f6 1f             	xor    $0x1f,%esi
f010165a:	75 4c                	jne    f01016a8 <__udivdi3+0xa4>
f010165c:	39 f8                	cmp    %edi,%eax
f010165e:	bf 00 00 00 00       	mov    $0x0,%edi
f0101663:	72 0a                	jb     f010166f <__udivdi3+0x6b>
f0101665:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0101669:	0f 87 ad 00 00 00    	ja     f010171c <__udivdi3+0x118>
f010166f:	be 01 00 00 00       	mov    $0x1,%esi
f0101674:	89 f0                	mov    %esi,%eax
f0101676:	89 fa                	mov    %edi,%edx
f0101678:	83 c4 10             	add    $0x10,%esp
f010167b:	5e                   	pop    %esi
f010167c:	5f                   	pop    %edi
f010167d:	5d                   	pop    %ebp
f010167e:	c3                   	ret    
f010167f:	90                   	nop
f0101680:	31 ff                	xor    %edi,%edi
f0101682:	31 f6                	xor    %esi,%esi
f0101684:	89 f0                	mov    %esi,%eax
f0101686:	89 fa                	mov    %edi,%edx
f0101688:	83 c4 10             	add    $0x10,%esp
f010168b:	5e                   	pop    %esi
f010168c:	5f                   	pop    %edi
f010168d:	5d                   	pop    %ebp
f010168e:	c3                   	ret    
f010168f:	90                   	nop
f0101690:	89 fa                	mov    %edi,%edx
f0101692:	89 f0                	mov    %esi,%eax
f0101694:	f7 f1                	div    %ecx
f0101696:	89 c6                	mov    %eax,%esi
f0101698:	31 ff                	xor    %edi,%edi
f010169a:	89 f0                	mov    %esi,%eax
f010169c:	89 fa                	mov    %edi,%edx
f010169e:	83 c4 10             	add    $0x10,%esp
f01016a1:	5e                   	pop    %esi
f01016a2:	5f                   	pop    %edi
f01016a3:	5d                   	pop    %ebp
f01016a4:	c3                   	ret    
f01016a5:	8d 76 00             	lea    0x0(%esi),%esi
f01016a8:	89 f1                	mov    %esi,%ecx
f01016aa:	d3 e0                	shl    %cl,%eax
f01016ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016b0:	b8 20 00 00 00       	mov    $0x20,%eax
f01016b5:	29 f0                	sub    %esi,%eax
f01016b7:	89 ea                	mov    %ebp,%edx
f01016b9:	88 c1                	mov    %al,%cl
f01016bb:	d3 ea                	shr    %cl,%edx
f01016bd:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f01016c1:	09 ca                	or     %ecx,%edx
f01016c3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01016c7:	89 f1                	mov    %esi,%ecx
f01016c9:	d3 e5                	shl    %cl,%ebp
f01016cb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f01016cf:	89 fd                	mov    %edi,%ebp
f01016d1:	88 c1                	mov    %al,%cl
f01016d3:	d3 ed                	shr    %cl,%ebp
f01016d5:	89 fa                	mov    %edi,%edx
f01016d7:	89 f1                	mov    %esi,%ecx
f01016d9:	d3 e2                	shl    %cl,%edx
f01016db:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01016df:	88 c1                	mov    %al,%cl
f01016e1:	d3 ef                	shr    %cl,%edi
f01016e3:	09 d7                	or     %edx,%edi
f01016e5:	89 f8                	mov    %edi,%eax
f01016e7:	89 ea                	mov    %ebp,%edx
f01016e9:	f7 74 24 08          	divl   0x8(%esp)
f01016ed:	89 d1                	mov    %edx,%ecx
f01016ef:	89 c7                	mov    %eax,%edi
f01016f1:	f7 64 24 0c          	mull   0xc(%esp)
f01016f5:	39 d1                	cmp    %edx,%ecx
f01016f7:	72 17                	jb     f0101710 <__udivdi3+0x10c>
f01016f9:	74 09                	je     f0101704 <__udivdi3+0x100>
f01016fb:	89 fe                	mov    %edi,%esi
f01016fd:	31 ff                	xor    %edi,%edi
f01016ff:	e9 41 ff ff ff       	jmp    f0101645 <__udivdi3+0x41>
f0101704:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101708:	89 f1                	mov    %esi,%ecx
f010170a:	d3 e2                	shl    %cl,%edx
f010170c:	39 c2                	cmp    %eax,%edx
f010170e:	73 eb                	jae    f01016fb <__udivdi3+0xf7>
f0101710:	8d 77 ff             	lea    -0x1(%edi),%esi
f0101713:	31 ff                	xor    %edi,%edi
f0101715:	e9 2b ff ff ff       	jmp    f0101645 <__udivdi3+0x41>
f010171a:	66 90                	xchg   %ax,%ax
f010171c:	31 f6                	xor    %esi,%esi
f010171e:	e9 22 ff ff ff       	jmp    f0101645 <__udivdi3+0x41>
	...

f0101724 <__umoddi3>:
f0101724:	55                   	push   %ebp
f0101725:	57                   	push   %edi
f0101726:	56                   	push   %esi
f0101727:	83 ec 20             	sub    $0x20,%esp
f010172a:	8b 44 24 30          	mov    0x30(%esp),%eax
f010172e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0101732:	89 44 24 14          	mov    %eax,0x14(%esp)
f0101736:	8b 74 24 34          	mov    0x34(%esp),%esi
f010173a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010173e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0101742:	89 c7                	mov    %eax,%edi
f0101744:	89 f2                	mov    %esi,%edx
f0101746:	85 ed                	test   %ebp,%ebp
f0101748:	75 16                	jne    f0101760 <__umoddi3+0x3c>
f010174a:	39 f1                	cmp    %esi,%ecx
f010174c:	0f 86 a6 00 00 00    	jbe    f01017f8 <__umoddi3+0xd4>
f0101752:	f7 f1                	div    %ecx
f0101754:	89 d0                	mov    %edx,%eax
f0101756:	31 d2                	xor    %edx,%edx
f0101758:	83 c4 20             	add    $0x20,%esp
f010175b:	5e                   	pop    %esi
f010175c:	5f                   	pop    %edi
f010175d:	5d                   	pop    %ebp
f010175e:	c3                   	ret    
f010175f:	90                   	nop
f0101760:	39 f5                	cmp    %esi,%ebp
f0101762:	0f 87 ac 00 00 00    	ja     f0101814 <__umoddi3+0xf0>
f0101768:	0f bd c5             	bsr    %ebp,%eax
f010176b:	83 f0 1f             	xor    $0x1f,%eax
f010176e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0101772:	0f 84 a8 00 00 00    	je     f0101820 <__umoddi3+0xfc>
f0101778:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010177c:	d3 e5                	shl    %cl,%ebp
f010177e:	bf 20 00 00 00       	mov    $0x20,%edi
f0101783:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0101787:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010178b:	89 f9                	mov    %edi,%ecx
f010178d:	d3 e8                	shr    %cl,%eax
f010178f:	09 e8                	or     %ebp,%eax
f0101791:	89 44 24 18          	mov    %eax,0x18(%esp)
f0101795:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0101799:	8a 4c 24 10          	mov    0x10(%esp),%cl
f010179d:	d3 e0                	shl    %cl,%eax
f010179f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01017a3:	89 f2                	mov    %esi,%edx
f01017a5:	d3 e2                	shl    %cl,%edx
f01017a7:	8b 44 24 14          	mov    0x14(%esp),%eax
f01017ab:	d3 e0                	shl    %cl,%eax
f01017ad:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f01017b1:	8b 44 24 14          	mov    0x14(%esp),%eax
f01017b5:	89 f9                	mov    %edi,%ecx
f01017b7:	d3 e8                	shr    %cl,%eax
f01017b9:	09 d0                	or     %edx,%eax
f01017bb:	d3 ee                	shr    %cl,%esi
f01017bd:	89 f2                	mov    %esi,%edx
f01017bf:	f7 74 24 18          	divl   0x18(%esp)
f01017c3:	89 d6                	mov    %edx,%esi
f01017c5:	f7 64 24 0c          	mull   0xc(%esp)
f01017c9:	89 c5                	mov    %eax,%ebp
f01017cb:	89 d1                	mov    %edx,%ecx
f01017cd:	39 d6                	cmp    %edx,%esi
f01017cf:	72 67                	jb     f0101838 <__umoddi3+0x114>
f01017d1:	74 75                	je     f0101848 <__umoddi3+0x124>
f01017d3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f01017d7:	29 e8                	sub    %ebp,%eax
f01017d9:	19 ce                	sbb    %ecx,%esi
f01017db:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01017df:	d3 e8                	shr    %cl,%eax
f01017e1:	89 f2                	mov    %esi,%edx
f01017e3:	89 f9                	mov    %edi,%ecx
f01017e5:	d3 e2                	shl    %cl,%edx
f01017e7:	09 d0                	or     %edx,%eax
f01017e9:	89 f2                	mov    %esi,%edx
f01017eb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01017ef:	d3 ea                	shr    %cl,%edx
f01017f1:	83 c4 20             	add    $0x20,%esp
f01017f4:	5e                   	pop    %esi
f01017f5:	5f                   	pop    %edi
f01017f6:	5d                   	pop    %ebp
f01017f7:	c3                   	ret    
f01017f8:	85 c9                	test   %ecx,%ecx
f01017fa:	75 0b                	jne    f0101807 <__umoddi3+0xe3>
f01017fc:	b8 01 00 00 00       	mov    $0x1,%eax
f0101801:	31 d2                	xor    %edx,%edx
f0101803:	f7 f1                	div    %ecx
f0101805:	89 c1                	mov    %eax,%ecx
f0101807:	89 f0                	mov    %esi,%eax
f0101809:	31 d2                	xor    %edx,%edx
f010180b:	f7 f1                	div    %ecx
f010180d:	89 f8                	mov    %edi,%eax
f010180f:	e9 3e ff ff ff       	jmp    f0101752 <__umoddi3+0x2e>
f0101814:	89 f2                	mov    %esi,%edx
f0101816:	83 c4 20             	add    $0x20,%esp
f0101819:	5e                   	pop    %esi
f010181a:	5f                   	pop    %edi
f010181b:	5d                   	pop    %ebp
f010181c:	c3                   	ret    
f010181d:	8d 76 00             	lea    0x0(%esi),%esi
f0101820:	39 f5                	cmp    %esi,%ebp
f0101822:	72 04                	jb     f0101828 <__umoddi3+0x104>
f0101824:	39 f9                	cmp    %edi,%ecx
f0101826:	77 06                	ja     f010182e <__umoddi3+0x10a>
f0101828:	89 f2                	mov    %esi,%edx
f010182a:	29 cf                	sub    %ecx,%edi
f010182c:	19 ea                	sbb    %ebp,%edx
f010182e:	89 f8                	mov    %edi,%eax
f0101830:	83 c4 20             	add    $0x20,%esp
f0101833:	5e                   	pop    %esi
f0101834:	5f                   	pop    %edi
f0101835:	5d                   	pop    %ebp
f0101836:	c3                   	ret    
f0101837:	90                   	nop
f0101838:	89 d1                	mov    %edx,%ecx
f010183a:	89 c5                	mov    %eax,%ebp
f010183c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0101840:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0101844:	eb 8d                	jmp    f01017d3 <__umoddi3+0xaf>
f0101846:	66 90                	xchg   %ax,%ax
f0101848:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f010184c:	72 ea                	jb     f0101838 <__umoddi3+0x114>
f010184e:	89 f1                	mov    %esi,%ecx
f0101850:	eb 81                	jmp    f01017d3 <__umoddi3+0xaf>
