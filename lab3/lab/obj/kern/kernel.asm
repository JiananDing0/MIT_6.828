
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
f0100015:	b8 00 00 12 00       	mov    $0x120000,%eax
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
f0100034:	bc 00 00 12 f0       	mov    $0xf0120000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 18             	sub    $0x18,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 40 0e 1e f0       	mov    $0xf01e0e40,%eax
f010004b:	2d 60 ff 1d f0       	sub    $0xf01dff60,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 60 ff 1d f0 	movl   $0xf01dff60,(%esp)
f0100063:	e8 6a 41 00 00       	call   f01041d2 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 90 04 00 00       	call   f01004fd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 46 10 f0 	movl   $0xf0104620,(%esp)
f010007c:	e8 45 32 00 00       	call   f01032c6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 e6 10 00 00       	call   f010116c <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 16 2e 00 00       	call   f0102ea1 <env_init>
	trap_init();
f010008b:	e8 b6 32 00 00       	call   f0103346 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100097:	00 
f0100098:	c7 04 24 49 dc 14 f0 	movl   $0xf014dc49,(%esp)
f010009f:	e8 4e 2f 00 00       	call   f0102ff2 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a4:	a1 a8 01 1e f0       	mov    0xf01e01a8,%eax
f01000a9:	89 04 24             	mov    %eax,(%esp)
f01000ac:	e8 84 31 00 00       	call   f0103235 <env_run>

f01000b1 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000b1:	55                   	push   %ebp
f01000b2:	89 e5                	mov    %esp,%ebp
f01000b4:	56                   	push   %esi
f01000b5:	53                   	push   %ebx
f01000b6:	83 ec 10             	sub    $0x10,%esp
f01000b9:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000bc:	83 3d 44 0e 1e f0 00 	cmpl   $0x0,0xf01e0e44
f01000c3:	75 3d                	jne    f0100102 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000c5:	89 35 44 0e 1e f0    	mov    %esi,0xf01e0e44

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000cb:	fa                   	cli    
f01000cc:	fc                   	cld    

	va_start(ap, fmt);
f01000cd:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000d0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000d3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01000da:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000de:	c7 04 24 3b 46 10 f0 	movl   $0xf010463b,(%esp)
f01000e5:	e8 dc 31 00 00       	call   f01032c6 <cprintf>
	vcprintf(fmt, ap);
f01000ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000ee:	89 34 24             	mov    %esi,(%esp)
f01000f1:	e8 9d 31 00 00       	call   f0103293 <vcprintf>
	cprintf("\n");
f01000f6:	c7 04 24 2d 56 10 f0 	movl   $0xf010562d,(%esp)
f01000fd:	e8 c4 31 00 00       	call   f01032c6 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100102:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0100109:	e8 c3 06 00 00       	call   f01007d1 <monitor>
f010010e:	eb f2                	jmp    f0100102 <_panic+0x51>

f0100110 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100110:	55                   	push   %ebp
f0100111:	89 e5                	mov    %esp,%ebp
f0100113:	53                   	push   %ebx
f0100114:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f0100117:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010011a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010011d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100121:	8b 45 08             	mov    0x8(%ebp),%eax
f0100124:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100128:	c7 04 24 53 46 10 f0 	movl   $0xf0104653,(%esp)
f010012f:	e8 92 31 00 00       	call   f01032c6 <cprintf>
	vcprintf(fmt, ap);
f0100134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100138:	8b 45 10             	mov    0x10(%ebp),%eax
f010013b:	89 04 24             	mov    %eax,(%esp)
f010013e:	e8 50 31 00 00       	call   f0103293 <vcprintf>
	cprintf("\n");
f0100143:	c7 04 24 2d 56 10 f0 	movl   $0xf010562d,(%esp)
f010014a:	e8 77 31 00 00       	call   f01032c6 <cprintf>
	va_end(ap);
}
f010014f:	83 c4 14             	add    $0x14,%esp
f0100152:	5b                   	pop    %ebx
f0100153:	5d                   	pop    %ebp
f0100154:	c3                   	ret    
f0100155:	00 00                	add    %al,(%eax)
	...

f0100158 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100158:	55                   	push   %ebp
f0100159:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010015b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100160:	ec                   	in     (%dx),%al
f0100161:	ec                   	in     (%dx),%al
f0100162:	ec                   	in     (%dx),%al
f0100163:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100164:	5d                   	pop    %ebp
f0100165:	c3                   	ret    

f0100166 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100166:	55                   	push   %ebp
f0100167:	89 e5                	mov    %esp,%ebp
f0100169:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010016e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010016f:	a8 01                	test   $0x1,%al
f0100171:	74 08                	je     f010017b <serial_proc_data+0x15>
f0100173:	b2 f8                	mov    $0xf8,%dl
f0100175:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100176:	0f b6 c0             	movzbl %al,%eax
f0100179:	eb 05                	jmp    f0100180 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010017b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100180:	5d                   	pop    %ebp
f0100181:	c3                   	ret    

f0100182 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100182:	55                   	push   %ebp
f0100183:	89 e5                	mov    %esp,%ebp
f0100185:	53                   	push   %ebx
f0100186:	83 ec 04             	sub    $0x4,%esp
f0100189:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010018b:	eb 29                	jmp    f01001b6 <cons_intr+0x34>
		if (c == 0)
f010018d:	85 c0                	test   %eax,%eax
f010018f:	74 25                	je     f01001b6 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100191:	8b 15 84 01 1e f0    	mov    0xf01e0184,%edx
f0100197:	88 82 80 ff 1d f0    	mov    %al,-0xfe20080(%edx)
f010019d:	8d 42 01             	lea    0x1(%edx),%eax
f01001a0:	a3 84 01 1e f0       	mov    %eax,0xf01e0184
		if (cons.wpos == CONSBUFSIZE)
f01001a5:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001aa:	75 0a                	jne    f01001b6 <cons_intr+0x34>
			cons.wpos = 0;
f01001ac:	c7 05 84 01 1e f0 00 	movl   $0x0,0xf01e0184
f01001b3:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001b6:	ff d3                	call   *%ebx
f01001b8:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001bb:	75 d0                	jne    f010018d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001bd:	83 c4 04             	add    $0x4,%esp
f01001c0:	5b                   	pop    %ebx
f01001c1:	5d                   	pop    %ebp
f01001c2:	c3                   	ret    

f01001c3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001c3:	55                   	push   %ebp
f01001c4:	89 e5                	mov    %esp,%ebp
f01001c6:	57                   	push   %edi
f01001c7:	56                   	push   %esi
f01001c8:	53                   	push   %ebx
f01001c9:	83 ec 2c             	sub    $0x2c,%esp
f01001cc:	89 c6                	mov    %eax,%esi
f01001ce:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01001d3:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01001d8:	eb 05                	jmp    f01001df <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001da:	e8 79 ff ff ff       	call   f0100158 <delay>
f01001df:	89 fa                	mov    %edi,%edx
f01001e1:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001e2:	a8 20                	test   $0x20,%al
f01001e4:	75 03                	jne    f01001e9 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001e6:	4b                   	dec    %ebx
f01001e7:	75 f1                	jne    f01001da <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001e9:	89 f2                	mov    %esi,%edx
f01001eb:	89 f0                	mov    %esi,%eax
f01001ed:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001f5:	ee                   	out    %al,(%dx)
f01001f6:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001fb:	bf 79 03 00 00       	mov    $0x379,%edi
f0100200:	eb 05                	jmp    f0100207 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f0100202:	e8 51 ff ff ff       	call   f0100158 <delay>
f0100207:	89 fa                	mov    %edi,%edx
f0100209:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010020a:	84 c0                	test   %al,%al
f010020c:	78 03                	js     f0100211 <cons_putc+0x4e>
f010020e:	4b                   	dec    %ebx
f010020f:	75 f1                	jne    f0100202 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100211:	ba 78 03 00 00       	mov    $0x378,%edx
f0100216:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100219:	ee                   	out    %al,(%dx)
f010021a:	b2 7a                	mov    $0x7a,%dl
f010021c:	b0 0d                	mov    $0xd,%al
f010021e:	ee                   	out    %al,(%dx)
f010021f:	b0 08                	mov    $0x8,%al
f0100221:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100222:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100228:	75 06                	jne    f0100230 <cons_putc+0x6d>
		c |= 0x0700;
f010022a:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100230:	89 f0                	mov    %esi,%eax
f0100232:	25 ff 00 00 00       	and    $0xff,%eax
f0100237:	83 f8 09             	cmp    $0x9,%eax
f010023a:	74 78                	je     f01002b4 <cons_putc+0xf1>
f010023c:	83 f8 09             	cmp    $0x9,%eax
f010023f:	7f 0b                	jg     f010024c <cons_putc+0x89>
f0100241:	83 f8 08             	cmp    $0x8,%eax
f0100244:	0f 85 9e 00 00 00    	jne    f01002e8 <cons_putc+0x125>
f010024a:	eb 10                	jmp    f010025c <cons_putc+0x99>
f010024c:	83 f8 0a             	cmp    $0xa,%eax
f010024f:	74 39                	je     f010028a <cons_putc+0xc7>
f0100251:	83 f8 0d             	cmp    $0xd,%eax
f0100254:	0f 85 8e 00 00 00    	jne    f01002e8 <cons_putc+0x125>
f010025a:	eb 36                	jmp    f0100292 <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f010025c:	66 a1 94 01 1e f0    	mov    0xf01e0194,%ax
f0100262:	66 85 c0             	test   %ax,%ax
f0100265:	0f 84 e2 00 00 00    	je     f010034d <cons_putc+0x18a>
			crt_pos--;
f010026b:	48                   	dec    %eax
f010026c:	66 a3 94 01 1e f0    	mov    %ax,0xf01e0194
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100272:	0f b7 c0             	movzwl %ax,%eax
f0100275:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010027b:	83 ce 20             	or     $0x20,%esi
f010027e:	8b 15 90 01 1e f0    	mov    0xf01e0190,%edx
f0100284:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100288:	eb 78                	jmp    f0100302 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010028a:	66 83 05 94 01 1e f0 	addw   $0x50,0xf01e0194
f0100291:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100292:	66 8b 0d 94 01 1e f0 	mov    0xf01e0194,%cx
f0100299:	bb 50 00 00 00       	mov    $0x50,%ebx
f010029e:	89 c8                	mov    %ecx,%eax
f01002a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01002a5:	66 f7 f3             	div    %bx
f01002a8:	66 29 d1             	sub    %dx,%cx
f01002ab:	66 89 0d 94 01 1e f0 	mov    %cx,0xf01e0194
f01002b2:	eb 4e                	jmp    f0100302 <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f01002b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b9:	e8 05 ff ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002be:	b8 20 00 00 00       	mov    $0x20,%eax
f01002c3:	e8 fb fe ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01002cd:	e8 f1 fe ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01002d7:	e8 e7 fe ff ff       	call   f01001c3 <cons_putc>
		cons_putc(' ');
f01002dc:	b8 20 00 00 00       	mov    $0x20,%eax
f01002e1:	e8 dd fe ff ff       	call   f01001c3 <cons_putc>
f01002e6:	eb 1a                	jmp    f0100302 <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002e8:	66 a1 94 01 1e f0    	mov    0xf01e0194,%ax
f01002ee:	0f b7 c8             	movzwl %ax,%ecx
f01002f1:	8b 15 90 01 1e f0    	mov    0xf01e0190,%edx
f01002f7:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002fb:	40                   	inc    %eax
f01002fc:	66 a3 94 01 1e f0    	mov    %ax,0xf01e0194
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100302:	66 81 3d 94 01 1e f0 	cmpw   $0x7cf,0xf01e0194
f0100309:	cf 07 
f010030b:	76 40                	jbe    f010034d <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010030d:	a1 90 01 1e f0       	mov    0xf01e0190,%eax
f0100312:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100319:	00 
f010031a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100320:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100324:	89 04 24             	mov    %eax,(%esp)
f0100327:	e8 f0 3e 00 00       	call   f010421c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010032c:	8b 15 90 01 1e f0    	mov    0xf01e0190,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100332:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100337:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010033d:	40                   	inc    %eax
f010033e:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100343:	75 f2                	jne    f0100337 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100345:	66 83 2d 94 01 1e f0 	subw   $0x50,0xf01e0194
f010034c:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010034d:	8b 0d 8c 01 1e f0    	mov    0xf01e018c,%ecx
f0100353:	b0 0e                	mov    $0xe,%al
f0100355:	89 ca                	mov    %ecx,%edx
f0100357:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100358:	66 8b 35 94 01 1e f0 	mov    0xf01e0194,%si
f010035f:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100362:	89 f0                	mov    %esi,%eax
f0100364:	66 c1 e8 08          	shr    $0x8,%ax
f0100368:	89 da                	mov    %ebx,%edx
f010036a:	ee                   	out    %al,(%dx)
f010036b:	b0 0f                	mov    $0xf,%al
f010036d:	89 ca                	mov    %ecx,%edx
f010036f:	ee                   	out    %al,(%dx)
f0100370:	89 f0                	mov    %esi,%eax
f0100372:	89 da                	mov    %ebx,%edx
f0100374:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100375:	83 c4 2c             	add    $0x2c,%esp
f0100378:	5b                   	pop    %ebx
f0100379:	5e                   	pop    %esi
f010037a:	5f                   	pop    %edi
f010037b:	5d                   	pop    %ebp
f010037c:	c3                   	ret    

f010037d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010037d:	55                   	push   %ebp
f010037e:	89 e5                	mov    %esp,%ebp
f0100380:	53                   	push   %ebx
f0100381:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100384:	ba 64 00 00 00       	mov    $0x64,%edx
f0100389:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f010038a:	0f b6 c0             	movzbl %al,%eax
f010038d:	a8 01                	test   $0x1,%al
f010038f:	0f 84 e0 00 00 00    	je     f0100475 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100395:	a8 20                	test   $0x20,%al
f0100397:	0f 85 df 00 00 00    	jne    f010047c <kbd_proc_data+0xff>
f010039d:	b2 60                	mov    $0x60,%dl
f010039f:	ec                   	in     (%dx),%al
f01003a0:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01003a2:	3c e0                	cmp    $0xe0,%al
f01003a4:	75 11                	jne    f01003b7 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f01003a6:	83 0d 88 01 1e f0 40 	orl    $0x40,0xf01e0188
		return 0;
f01003ad:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b2:	e9 ca 00 00 00       	jmp    f0100481 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f01003b7:	84 c0                	test   %al,%al
f01003b9:	79 33                	jns    f01003ee <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003bb:	8b 0d 88 01 1e f0    	mov    0xf01e0188,%ecx
f01003c1:	f6 c1 40             	test   $0x40,%cl
f01003c4:	75 05                	jne    f01003cb <kbd_proc_data+0x4e>
f01003c6:	88 c2                	mov    %al,%dl
f01003c8:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003cb:	0f b6 d2             	movzbl %dl,%edx
f01003ce:	8a 82 a0 46 10 f0    	mov    -0xfefb960(%edx),%al
f01003d4:	83 c8 40             	or     $0x40,%eax
f01003d7:	0f b6 c0             	movzbl %al,%eax
f01003da:	f7 d0                	not    %eax
f01003dc:	21 c1                	and    %eax,%ecx
f01003de:	89 0d 88 01 1e f0    	mov    %ecx,0xf01e0188
		return 0;
f01003e4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003e9:	e9 93 00 00 00       	jmp    f0100481 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f01003ee:	8b 0d 88 01 1e f0    	mov    0xf01e0188,%ecx
f01003f4:	f6 c1 40             	test   $0x40,%cl
f01003f7:	74 0e                	je     f0100407 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003f9:	88 c2                	mov    %al,%dl
f01003fb:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100401:	89 0d 88 01 1e f0    	mov    %ecx,0xf01e0188
	}

	shift |= shiftcode[data];
f0100407:	0f b6 d2             	movzbl %dl,%edx
f010040a:	0f b6 82 a0 46 10 f0 	movzbl -0xfefb960(%edx),%eax
f0100411:	0b 05 88 01 1e f0    	or     0xf01e0188,%eax
	shift ^= togglecode[data];
f0100417:	0f b6 8a a0 47 10 f0 	movzbl -0xfefb860(%edx),%ecx
f010041e:	31 c8                	xor    %ecx,%eax
f0100420:	a3 88 01 1e f0       	mov    %eax,0xf01e0188

	c = charcode[shift & (CTL | SHIFT)][data];
f0100425:	89 c1                	mov    %eax,%ecx
f0100427:	83 e1 03             	and    $0x3,%ecx
f010042a:	8b 0c 8d a0 48 10 f0 	mov    -0xfefb760(,%ecx,4),%ecx
f0100431:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100435:	a8 08                	test   $0x8,%al
f0100437:	74 18                	je     f0100451 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f0100439:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010043c:	83 fa 19             	cmp    $0x19,%edx
f010043f:	77 05                	ja     f0100446 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f0100441:	83 eb 20             	sub    $0x20,%ebx
f0100444:	eb 0b                	jmp    f0100451 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f0100446:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100449:	83 fa 19             	cmp    $0x19,%edx
f010044c:	77 03                	ja     f0100451 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f010044e:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100451:	f7 d0                	not    %eax
f0100453:	a8 06                	test   $0x6,%al
f0100455:	75 2a                	jne    f0100481 <kbd_proc_data+0x104>
f0100457:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010045d:	75 22                	jne    f0100481 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010045f:	c7 04 24 6d 46 10 f0 	movl   $0xf010466d,(%esp)
f0100466:	e8 5b 2e 00 00       	call   f01032c6 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010046b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100470:	b0 03                	mov    $0x3,%al
f0100472:	ee                   	out    %al,(%dx)
f0100473:	eb 0c                	jmp    f0100481 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100475:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010047a:	eb 05                	jmp    f0100481 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010047c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100481:	89 d8                	mov    %ebx,%eax
f0100483:	83 c4 14             	add    $0x14,%esp
f0100486:	5b                   	pop    %ebx
f0100487:	5d                   	pop    %ebp
f0100488:	c3                   	ret    

f0100489 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010048f:	80 3d 60 ff 1d f0 00 	cmpb   $0x0,0xf01dff60
f0100496:	74 0a                	je     f01004a2 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100498:	b8 66 01 10 f0       	mov    $0xf0100166,%eax
f010049d:	e8 e0 fc ff ff       	call   f0100182 <cons_intr>
}
f01004a2:	c9                   	leave  
f01004a3:	c3                   	ret    

f01004a4 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004a4:	55                   	push   %ebp
f01004a5:	89 e5                	mov    %esp,%ebp
f01004a7:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004aa:	b8 7d 03 10 f0       	mov    $0xf010037d,%eax
f01004af:	e8 ce fc ff ff       	call   f0100182 <cons_intr>
}
f01004b4:	c9                   	leave  
f01004b5:	c3                   	ret    

f01004b6 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004b6:	55                   	push   %ebp
f01004b7:	89 e5                	mov    %esp,%ebp
f01004b9:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004bc:	e8 c8 ff ff ff       	call   f0100489 <serial_intr>
	kbd_intr();
f01004c1:	e8 de ff ff ff       	call   f01004a4 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004c6:	8b 15 80 01 1e f0    	mov    0xf01e0180,%edx
f01004cc:	3b 15 84 01 1e f0    	cmp    0xf01e0184,%edx
f01004d2:	74 22                	je     f01004f6 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004d4:	0f b6 82 80 ff 1d f0 	movzbl -0xfe20080(%edx),%eax
f01004db:	42                   	inc    %edx
f01004dc:	89 15 80 01 1e f0    	mov    %edx,0xf01e0180
		if (cons.rpos == CONSBUFSIZE)
f01004e2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e8:	75 11                	jne    f01004fb <cons_getc+0x45>
			cons.rpos = 0;
f01004ea:	c7 05 80 01 1e f0 00 	movl   $0x0,0xf01e0180
f01004f1:	00 00 00 
f01004f4:	eb 05                	jmp    f01004fb <cons_getc+0x45>
		return c;
	}
	return 0;
f01004f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004fb:	c9                   	leave  
f01004fc:	c3                   	ret    

f01004fd <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004fd:	55                   	push   %ebp
f01004fe:	89 e5                	mov    %esp,%ebp
f0100500:	57                   	push   %edi
f0100501:	56                   	push   %esi
f0100502:	53                   	push   %ebx
f0100503:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100506:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f010050d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100514:	5a a5 
	if (*cp != 0xA55A) {
f0100516:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f010051c:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100520:	74 11                	je     f0100533 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100522:	c7 05 8c 01 1e f0 b4 	movl   $0x3b4,0xf01e018c
f0100529:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010052c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100531:	eb 16                	jmp    f0100549 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100533:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010053a:	c7 05 8c 01 1e f0 d4 	movl   $0x3d4,0xf01e018c
f0100541:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100544:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100549:	8b 0d 8c 01 1e f0    	mov    0xf01e018c,%ecx
f010054f:	b0 0e                	mov    $0xe,%al
f0100551:	89 ca                	mov    %ecx,%edx
f0100553:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100554:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100557:	89 da                	mov    %ebx,%edx
f0100559:	ec                   	in     (%dx),%al
f010055a:	0f b6 f8             	movzbl %al,%edi
f010055d:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100560:	b0 0f                	mov    $0xf,%al
f0100562:	89 ca                	mov    %ecx,%edx
f0100564:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100565:	89 da                	mov    %ebx,%edx
f0100567:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100568:	89 35 90 01 1e f0    	mov    %esi,0xf01e0190

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010056e:	0f b6 d8             	movzbl %al,%ebx
f0100571:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100573:	66 89 3d 94 01 1e f0 	mov    %di,0xf01e0194
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010057f:	b0 00                	mov    $0x0,%al
f0100581:	89 da                	mov    %ebx,%edx
f0100583:	ee                   	out    %al,(%dx)
f0100584:	b2 fb                	mov    $0xfb,%dl
f0100586:	b0 80                	mov    $0x80,%al
f0100588:	ee                   	out    %al,(%dx)
f0100589:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010058e:	b0 0c                	mov    $0xc,%al
f0100590:	89 ca                	mov    %ecx,%edx
f0100592:	ee                   	out    %al,(%dx)
f0100593:	b2 f9                	mov    $0xf9,%dl
f0100595:	b0 00                	mov    $0x0,%al
f0100597:	ee                   	out    %al,(%dx)
f0100598:	b2 fb                	mov    $0xfb,%dl
f010059a:	b0 03                	mov    $0x3,%al
f010059c:	ee                   	out    %al,(%dx)
f010059d:	b2 fc                	mov    $0xfc,%dl
f010059f:	b0 00                	mov    $0x0,%al
f01005a1:	ee                   	out    %al,(%dx)
f01005a2:	b2 f9                	mov    $0xf9,%dl
f01005a4:	b0 01                	mov    $0x1,%al
f01005a6:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a7:	b2 fd                	mov    $0xfd,%dl
f01005a9:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005aa:	3c ff                	cmp    $0xff,%al
f01005ac:	0f 95 45 e7          	setne  -0x19(%ebp)
f01005b0:	8a 45 e7             	mov    -0x19(%ebp),%al
f01005b3:	a2 60 ff 1d f0       	mov    %al,0xf01dff60
f01005b8:	89 da                	mov    %ebx,%edx
f01005ba:	ec                   	in     (%dx),%al
f01005bb:	89 ca                	mov    %ecx,%edx
f01005bd:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005be:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005c2:	75 0c                	jne    f01005d0 <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f01005c4:	c7 04 24 79 46 10 f0 	movl   $0xf0104679,(%esp)
f01005cb:	e8 f6 2c 00 00       	call   f01032c6 <cprintf>
}
f01005d0:	83 c4 2c             	add    $0x2c,%esp
f01005d3:	5b                   	pop    %ebx
f01005d4:	5e                   	pop    %esi
f01005d5:	5f                   	pop    %edi
f01005d6:	5d                   	pop    %ebp
f01005d7:	c3                   	ret    

f01005d8 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005d8:	55                   	push   %ebp
f01005d9:	89 e5                	mov    %esp,%ebp
f01005db:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005de:	8b 45 08             	mov    0x8(%ebp),%eax
f01005e1:	e8 dd fb ff ff       	call   f01001c3 <cons_putc>
}
f01005e6:	c9                   	leave  
f01005e7:	c3                   	ret    

f01005e8 <getchar>:

int
getchar(void)
{
f01005e8:	55                   	push   %ebp
f01005e9:	89 e5                	mov    %esp,%ebp
f01005eb:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005ee:	e8 c3 fe ff ff       	call   f01004b6 <cons_getc>
f01005f3:	85 c0                	test   %eax,%eax
f01005f5:	74 f7                	je     f01005ee <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005f7:	c9                   	leave  
f01005f8:	c3                   	ret    

f01005f9 <iscons>:

int
iscons(int fdnum)
{
f01005f9:	55                   	push   %ebp
f01005fa:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01005fc:	b8 01 00 00 00       	mov    $0x1,%eax
f0100601:	5d                   	pop    %ebp
f0100602:	c3                   	ret    
	...

f0100604 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100604:	55                   	push   %ebp
f0100605:	89 e5                	mov    %esp,%ebp
f0100607:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010060a:	c7 04 24 b0 48 10 f0 	movl   $0xf01048b0,(%esp)
f0100611:	e8 b0 2c 00 00       	call   f01032c6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100616:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010061d:	00 
f010061e:	c7 04 24 68 49 10 f0 	movl   $0xf0104968,(%esp)
f0100625:	e8 9c 2c 00 00       	call   f01032c6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010062a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100631:	00 
f0100632:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100639:	f0 
f010063a:	c7 04 24 90 49 10 f0 	movl   $0xf0104990,(%esp)
f0100641:	e8 80 2c 00 00       	call   f01032c6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100646:	c7 44 24 08 16 46 10 	movl   $0x104616,0x8(%esp)
f010064d:	00 
f010064e:	c7 44 24 04 16 46 10 	movl   $0xf0104616,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 b4 49 10 f0 	movl   $0xf01049b4,(%esp)
f010065d:	e8 64 2c 00 00       	call   f01032c6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100662:	c7 44 24 08 60 ff 1d 	movl   $0x1dff60,0x8(%esp)
f0100669:	00 
f010066a:	c7 44 24 04 60 ff 1d 	movl   $0xf01dff60,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 d8 49 10 f0 	movl   $0xf01049d8,(%esp)
f0100679:	e8 48 2c 00 00       	call   f01032c6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010067e:	c7 44 24 08 40 0e 1e 	movl   $0x1e0e40,0x8(%esp)
f0100685:	00 
f0100686:	c7 44 24 04 40 0e 1e 	movl   $0xf01e0e40,0x4(%esp)
f010068d:	f0 
f010068e:	c7 04 24 fc 49 10 f0 	movl   $0xf01049fc,(%esp)
f0100695:	e8 2c 2c 00 00       	call   f01032c6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010069a:	b8 3f 12 1e f0       	mov    $0xf01e123f,%eax
f010069f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f01006a4:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006a9:	89 c2                	mov    %eax,%edx
f01006ab:	85 c0                	test   %eax,%eax
f01006ad:	79 06                	jns    f01006b5 <mon_kerninfo+0xb1>
f01006af:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006b5:	c1 fa 0a             	sar    $0xa,%edx
f01006b8:	89 54 24 04          	mov    %edx,0x4(%esp)
f01006bc:	c7 04 24 20 4a 10 f0 	movl   $0xf0104a20,(%esp)
f01006c3:	e8 fe 2b 00 00       	call   f01032c6 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006cd:	c9                   	leave  
f01006ce:	c3                   	ret    

f01006cf <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006cf:	55                   	push   %ebp
f01006d0:	89 e5                	mov    %esp,%ebp
f01006d2:	53                   	push   %ebx
f01006d3:	83 ec 14             	sub    $0x14,%esp
f01006d6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006db:	8b 83 24 4b 10 f0    	mov    -0xfefb4dc(%ebx),%eax
f01006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006e5:	8b 83 20 4b 10 f0    	mov    -0xfefb4e0(%ebx),%eax
f01006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006ef:	c7 04 24 c9 48 10 f0 	movl   $0xf01048c9,(%esp)
f01006f6:	e8 cb 2b 00 00       	call   f01032c6 <cprintf>
f01006fb:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01006fe:	83 fb 24             	cmp    $0x24,%ebx
f0100701:	75 d8                	jne    f01006db <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f0100703:	b8 00 00 00 00       	mov    $0x0,%eax
f0100708:	83 c4 14             	add    $0x14,%esp
f010070b:	5b                   	pop    %ebx
f010070c:	5d                   	pop    %ebp
f010070d:	c3                   	ret    

f010070e <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010070e:	55                   	push   %ebp
f010070f:	89 e5                	mov    %esp,%ebp
f0100711:	57                   	push   %edi
f0100712:	56                   	push   %esi
f0100713:	53                   	push   %ebx
f0100714:	83 ec 5c             	sub    $0x5c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0100717:	89 eb                	mov    %ebp,%ebx
	uint32_t ebp = read_ebp();
	uint32_t eip;
	uint32_t args[5];
	struct Eipdebuginfo info;
	// Print statements
	cprintf("Stack backtrace:\n");
f0100719:	c7 04 24 d2 48 10 f0 	movl   $0xf01048d2,(%esp)
f0100720:	e8 a1 2b 00 00       	call   f01032c6 <cprintf>
	while (ebp) {
f0100725:	e9 92 00 00 00       	jmp    f01007bc <mon_backtrace+0xae>
		// CALL assembly will always push the return address to stack. As a result, we 
		// can always find it on stack before the function is called.
		eip = *((uint32_t *)(ebp + 1 * sizeof(uint32_t)));
f010072a:	8b 73 04             	mov    0x4(%ebx),%esi
		// All the arguments are pushed onto the stack right before function is CALLed, 
		// which means we can find them before the CALL command is executed and push.
		args[0] = *((uint32_t *)(ebp + 2 * sizeof(uint32_t)));
f010072d:	8b 43 08             	mov    0x8(%ebx),%eax
f0100730:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		args[1] = *((uint32_t *)(ebp + 3 * sizeof(uint32_t)));
f0100733:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100736:	89 45 c0             	mov    %eax,-0x40(%ebp)
		args[2] = *((uint32_t *)(ebp + 4 * sizeof(uint32_t)));
f0100739:	8b 43 10             	mov    0x10(%ebx),%eax
f010073c:	89 45 bc             	mov    %eax,-0x44(%ebp)
		args[3] = *((uint32_t *)(ebp + 5 * sizeof(uint32_t)));
f010073f:	8b 43 14             	mov    0x14(%ebx),%eax
f0100742:	89 45 b8             	mov    %eax,-0x48(%ebp)
		args[4] = *((uint32_t *)(ebp + 6 * sizeof(uint32_t)));
f0100745:	8b 7b 18             	mov    0x18(%ebx),%edi
		// Get corresponding debug information from debuginfo_eip() function
		debuginfo_eip(eip, &info);
f0100748:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010074b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010074f:	89 34 24             	mov    %esi,(%esp)
f0100752:	e8 92 30 00 00       	call   f01037e9 <debuginfo_eip>
		// Print debug line
		cprintf("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, args[0], args[1], args[2], args[3], args[4]);
f0100757:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f010075b:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010075e:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100762:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100765:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100769:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010076c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100770:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100773:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100777:	89 74 24 08          	mov    %esi,0x8(%esp)
f010077b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010077f:	c7 04 24 4c 4a 10 f0 	movl   $0xf0104a4c,(%esp)
f0100786:	e8 3b 2b 00 00       	call   f01032c6 <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (uint32_t)(eip - info.eip_fn_addr));
f010078b:	2b 75 e0             	sub    -0x20(%ebp),%esi
f010078e:	89 74 24 14          	mov    %esi,0x14(%esp)
f0100792:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100795:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100799:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010079c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01007a0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01007a3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01007a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01007aa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01007ae:	c7 04 24 e4 48 10 f0 	movl   $0xf01048e4,(%esp)
f01007b5:	e8 0c 2b 00 00       	call   f01032c6 <cprintf>
		// Update value of %ebp
		ebp = (uint32_t)(* (uint32_t *)ebp);
f01007ba:	8b 1b                	mov    (%ebx),%ebx
	uint32_t eip;
	uint32_t args[5];
	struct Eipdebuginfo info;
	// Print statements
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01007bc:	85 db                	test   %ebx,%ebx
f01007be:	0f 85 66 ff ff ff    	jne    f010072a <mon_backtrace+0x1c>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (uint32_t)(eip - info.eip_fn_addr));
		// Update value of %ebp
		ebp = (uint32_t)(* (uint32_t *)ebp);
	}
	return 0;
}
f01007c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c9:	83 c4 5c             	add    $0x5c,%esp
f01007cc:	5b                   	pop    %ebx
f01007cd:	5e                   	pop    %esi
f01007ce:	5f                   	pop    %edi
f01007cf:	5d                   	pop    %ebp
f01007d0:	c3                   	ret    

f01007d1 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007d1:	55                   	push   %ebp
f01007d2:	89 e5                	mov    %esp,%ebp
f01007d4:	57                   	push   %edi
f01007d5:	56                   	push   %esi
f01007d6:	53                   	push   %ebx
f01007d7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007da:	c7 04 24 80 4a 10 f0 	movl   $0xf0104a80,(%esp)
f01007e1:	e8 e0 2a 00 00       	call   f01032c6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007e6:	c7 04 24 a4 4a 10 f0 	movl   $0xf0104aa4,(%esp)
f01007ed:	e8 d4 2a 00 00       	call   f01032c6 <cprintf>

	if (tf != NULL)
f01007f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007f6:	74 0b                	je     f0100803 <monitor+0x32>
		print_trapframe(tf);
f01007f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01007fb:	89 04 24             	mov    %eax,(%esp)
f01007fe:	e8 f4 2b 00 00       	call   f01033f7 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100803:	c7 04 24 f5 48 10 f0 	movl   $0xf01048f5,(%esp)
f010080a:	e8 99 37 00 00       	call   f0103fa8 <readline>
f010080f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100811:	85 c0                	test   %eax,%eax
f0100813:	74 ee                	je     f0100803 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100815:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010081c:	be 00 00 00 00       	mov    $0x0,%esi
f0100821:	eb 04                	jmp    f0100827 <monitor+0x56>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100823:	c6 03 00             	movb   $0x0,(%ebx)
f0100826:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100827:	8a 03                	mov    (%ebx),%al
f0100829:	84 c0                	test   %al,%al
f010082b:	74 5e                	je     f010088b <monitor+0xba>
f010082d:	0f be c0             	movsbl %al,%eax
f0100830:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100834:	c7 04 24 f9 48 10 f0 	movl   $0xf01048f9,(%esp)
f010083b:	e8 5d 39 00 00       	call   f010419d <strchr>
f0100840:	85 c0                	test   %eax,%eax
f0100842:	75 df                	jne    f0100823 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100844:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100847:	74 42                	je     f010088b <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100849:	83 fe 0f             	cmp    $0xf,%esi
f010084c:	75 16                	jne    f0100864 <monitor+0x93>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010084e:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100855:	00 
f0100856:	c7 04 24 fe 48 10 f0 	movl   $0xf01048fe,(%esp)
f010085d:	e8 64 2a 00 00       	call   f01032c6 <cprintf>
f0100862:	eb 9f                	jmp    f0100803 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f0100864:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100868:	46                   	inc    %esi
f0100869:	eb 01                	jmp    f010086c <monitor+0x9b>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010086b:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010086c:	8a 03                	mov    (%ebx),%al
f010086e:	84 c0                	test   %al,%al
f0100870:	74 b5                	je     f0100827 <monitor+0x56>
f0100872:	0f be c0             	movsbl %al,%eax
f0100875:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100879:	c7 04 24 f9 48 10 f0 	movl   $0xf01048f9,(%esp)
f0100880:	e8 18 39 00 00       	call   f010419d <strchr>
f0100885:	85 c0                	test   %eax,%eax
f0100887:	74 e2                	je     f010086b <monitor+0x9a>
f0100889:	eb 9c                	jmp    f0100827 <monitor+0x56>
			buf++;
	}
	argv[argc] = 0;
f010088b:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100892:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100893:	85 f6                	test   %esi,%esi
f0100895:	0f 84 68 ff ff ff    	je     f0100803 <monitor+0x32>
f010089b:	bb 20 4b 10 f0       	mov    $0xf0104b20,%ebx
f01008a0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008a5:	8b 03                	mov    (%ebx),%eax
f01008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ab:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ae:	89 04 24             	mov    %eax,(%esp)
f01008b1:	e8 94 38 00 00       	call   f010414a <strcmp>
f01008b6:	85 c0                	test   %eax,%eax
f01008b8:	75 24                	jne    f01008de <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f01008ba:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008bd:	8b 55 08             	mov    0x8(%ebp),%edx
f01008c0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008c4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008c7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008cb:	89 34 24             	mov    %esi,(%esp)
f01008ce:	ff 14 85 28 4b 10 f0 	call   *-0xfefb4d8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008d5:	85 c0                	test   %eax,%eax
f01008d7:	78 26                	js     f01008ff <monitor+0x12e>
f01008d9:	e9 25 ff ff ff       	jmp    f0100803 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008de:	47                   	inc    %edi
f01008df:	83 c3 0c             	add    $0xc,%ebx
f01008e2:	83 ff 03             	cmp    $0x3,%edi
f01008e5:	75 be                	jne    f01008a5 <monitor+0xd4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008e7:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ee:	c7 04 24 1b 49 10 f0 	movl   $0xf010491b,(%esp)
f01008f5:	e8 cc 29 00 00       	call   f01032c6 <cprintf>
f01008fa:	e9 04 ff ff ff       	jmp    f0100803 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008ff:	83 c4 5c             	add    $0x5c,%esp
f0100902:	5b                   	pop    %ebx
f0100903:	5e                   	pop    %esi
f0100904:	5f                   	pop    %edi
f0100905:	5d                   	pop    %ebp
f0100906:	c3                   	ret    
	...

f0100908 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100908:	55                   	push   %ebp
f0100909:	89 e5                	mov    %esp,%ebp
f010090b:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f010090e:	89 d1                	mov    %edx,%ecx
f0100910:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100913:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100916:	a8 01                	test   $0x1,%al
f0100918:	74 4d                	je     f0100967 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f010091a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010091f:	89 c1                	mov    %eax,%ecx
f0100921:	c1 e9 0c             	shr    $0xc,%ecx
f0100924:	3b 0d 48 0e 1e f0    	cmp    0xf01e0e48,%ecx
f010092a:	72 20                	jb     f010094c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010092c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100930:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0100937:	f0 
f0100938:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f010093f:	00 
f0100940:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100947:	e8 65 f7 ff ff       	call   f01000b1 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f010094c:	c1 ea 0c             	shr    $0xc,%edx
f010094f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100955:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010095c:	a8 01                	test   $0x1,%al
f010095e:	74 0e                	je     f010096e <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100960:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100965:	eb 0c                	jmp    f0100973 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100967:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010096c:	eb 05                	jmp    f0100973 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f010096e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100973:	c9                   	leave  
f0100974:	c3                   	ret    

f0100975 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100975:	55                   	push   %ebp
f0100976:	89 e5                	mov    %esp,%ebp
f0100978:	56                   	push   %esi
f0100979:	53                   	push   %ebx
f010097a:	83 ec 10             	sub    $0x10,%esp
f010097d:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010097f:	89 04 24             	mov    %eax,(%esp)
f0100982:	e8 d1 28 00 00       	call   f0103258 <mc146818_read>
f0100987:	89 c6                	mov    %eax,%esi
f0100989:	43                   	inc    %ebx
f010098a:	89 1c 24             	mov    %ebx,(%esp)
f010098d:	e8 c6 28 00 00       	call   f0103258 <mc146818_read>
f0100992:	c1 e0 08             	shl    $0x8,%eax
f0100995:	09 f0                	or     %esi,%eax
}
f0100997:	83 c4 10             	add    $0x10,%esp
f010099a:	5b                   	pop    %ebx
f010099b:	5e                   	pop    %esi
f010099c:	5d                   	pop    %ebp
f010099d:	c3                   	ret    

f010099e <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010099e:	55                   	push   %ebp
f010099f:	89 e5                	mov    %esp,%ebp
f01009a1:	57                   	push   %edi
f01009a2:	56                   	push   %esi
f01009a3:	53                   	push   %ebx
f01009a4:	83 ec 1c             	sub    $0x1c,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f01009a7:	83 3d 9c 01 1e f0 00 	cmpl   $0x0,0xf01e019c
f01009ae:	75 11                	jne    f01009c1 <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01009b0:	ba 3f 1e 1e f0       	mov    $0xf01e1e3f,%edx
f01009b5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009bb:	89 15 9c 01 1e f0    	mov    %edx,0xf01e019c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	assert(n >= 0);
	// Convert to physical address
	result = (char *)PADDR(nextfree);
f01009c1:	8b 15 9c 01 1e f0    	mov    0xf01e019c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01009c7:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01009cd:	77 20                	ja     f01009ef <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01009cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01009d3:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f01009da:	f0 
f01009db:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f01009e2:	00 
f01009e3:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01009ea:	e8 c2 f6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01009ef:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	// Determine whether it is out of bound
	if ((physaddr_t)result + n > PGSIZE * npages) {
f01009f5:	8b 1d 48 0e 1e f0    	mov    0xf01e0e48,%ebx
f01009fb:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
f01009fe:	89 de                	mov    %ebx,%esi
f0100a00:	c1 e6 0c             	shl    $0xc,%esi
f0100a03:	39 f7                	cmp    %esi,%edi
f0100a05:	76 1c                	jbe    f0100a23 <boot_alloc+0x85>
		panic("boot_alloc: out of memory!");
f0100a07:	c7 44 24 08 6d 53 10 	movl   $0xf010536d,0x8(%esp)
f0100a0e:	f0 
f0100a0f:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0100a16:	00 
f0100a17:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100a1e:	e8 8e f6 ff ff       	call   f01000b1 <_panic>
	}
	// Otherwise, update value of nextfree, no update when n == 0
	nextfree += ROUNDUP(n, PGSIZE);
f0100a23:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100a28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a2d:	01 d0                	add    %edx,%eax
f0100a2f:	a3 9c 01 1e f0       	mov    %eax,0xf01e019c
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a34:	89 c8                	mov    %ecx,%eax
f0100a36:	c1 e8 0c             	shr    $0xc,%eax
f0100a39:	39 c3                	cmp    %eax,%ebx
f0100a3b:	77 20                	ja     f0100a5d <boot_alloc+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a3d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100a41:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0100a48:	f0 
f0100a49:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f0100a50:	00 
f0100a51:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100a58:	e8 54 f6 ff ff       	call   f01000b1 <_panic>
	// Convert back to kernel virtual address and return
	return KADDR((physaddr_t)result);
}
f0100a5d:	89 d0                	mov    %edx,%eax
f0100a5f:	83 c4 1c             	add    $0x1c,%esp
f0100a62:	5b                   	pop    %ebx
f0100a63:	5e                   	pop    %esi
f0100a64:	5f                   	pop    %edi
f0100a65:	5d                   	pop    %ebp
f0100a66:	c3                   	ret    

f0100a67 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a67:	55                   	push   %ebp
f0100a68:	89 e5                	mov    %esp,%ebp
f0100a6a:	57                   	push   %edi
f0100a6b:	56                   	push   %esi
f0100a6c:	53                   	push   %ebx
f0100a6d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a70:	3c 01                	cmp    $0x1,%al
f0100a72:	19 f6                	sbb    %esi,%esi
f0100a74:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100a7a:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100a7b:	8b 15 a0 01 1e f0    	mov    0xf01e01a0,%edx
f0100a81:	85 d2                	test   %edx,%edx
f0100a83:	75 1c                	jne    f0100aa1 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100a85:	c7 44 24 08 8c 4b 10 	movl   $0xf0104b8c,0x8(%esp)
f0100a8c:	f0 
f0100a8d:	c7 44 24 04 6f 02 00 	movl   $0x26f,0x4(%esp)
f0100a94:	00 
f0100a95:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100a9c:	e8 10 f6 ff ff       	call   f01000b1 <_panic>

	if (only_low_memory) {
f0100aa1:	84 c0                	test   %al,%al
f0100aa3:	74 4b                	je     f0100af0 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100aa5:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100aa8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100aab:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100aae:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ab1:	89 d0                	mov    %edx,%eax
f0100ab3:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0100ab9:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100abc:	c1 e8 16             	shr    $0x16,%eax
f0100abf:	39 c6                	cmp    %eax,%esi
f0100ac1:	0f 96 c0             	setbe  %al
f0100ac4:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100ac7:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100acb:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100acd:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ad1:	8b 12                	mov    (%edx),%edx
f0100ad3:	85 d2                	test   %edx,%edx
f0100ad5:	75 da                	jne    f0100ab1 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100ad7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ada:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ae0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ae3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ae6:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ae8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aeb:	a3 a0 01 1e f0       	mov    %eax,0xf01e01a0
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100af0:	8b 1d a0 01 1e f0    	mov    0xf01e01a0,%ebx
f0100af6:	eb 63                	jmp    f0100b5b <check_page_free_list+0xf4>
f0100af8:	89 d8                	mov    %ebx,%eax
f0100afa:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0100b00:	c1 f8 03             	sar    $0x3,%eax
f0100b03:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b06:	89 c2                	mov    %eax,%edx
f0100b08:	c1 ea 16             	shr    $0x16,%edx
f0100b0b:	39 d6                	cmp    %edx,%esi
f0100b0d:	76 4a                	jbe    f0100b59 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b0f:	89 c2                	mov    %eax,%edx
f0100b11:	c1 ea 0c             	shr    $0xc,%edx
f0100b14:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0100b1a:	72 20                	jb     f0100b3c <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b20:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0100b27:	f0 
f0100b28:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100b2f:	00 
f0100b30:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f0100b37:	e8 75 f5 ff ff       	call   f01000b1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b3c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b43:	00 
f0100b44:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b4b:	00 
	return (void *)(pa + KERNBASE);
f0100b4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b51:	89 04 24             	mov    %eax,(%esp)
f0100b54:	e8 79 36 00 00       	call   f01041d2 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b59:	8b 1b                	mov    (%ebx),%ebx
f0100b5b:	85 db                	test   %ebx,%ebx
f0100b5d:	75 99                	jne    f0100af8 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b5f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b64:	e8 35 fe ff ff       	call   f010099e <boot_alloc>
f0100b69:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b6c:	8b 15 a0 01 1e f0    	mov    0xf01e01a0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b72:	8b 0d 50 0e 1e f0    	mov    0xf01e0e50,%ecx
		assert(pp < pages + npages);
f0100b78:	a1 48 0e 1e f0       	mov    0xf01e0e48,%eax
f0100b7d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b80:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b83:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b86:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b89:	be 00 00 00 00       	mov    $0x0,%esi
f0100b8e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b91:	e9 91 01 00 00       	jmp    f0100d27 <check_page_free_list+0x2c0>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b96:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100b99:	73 24                	jae    f0100bbf <check_page_free_list+0x158>
f0100b9b:	c7 44 24 0c 96 53 10 	movl   $0xf0105396,0xc(%esp)
f0100ba2:	f0 
f0100ba3:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100baa:	f0 
f0100bab:	c7 44 24 04 89 02 00 	movl   $0x289,0x4(%esp)
f0100bb2:	00 
f0100bb3:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100bba:	e8 f2 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100bbf:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100bc2:	72 24                	jb     f0100be8 <check_page_free_list+0x181>
f0100bc4:	c7 44 24 0c b7 53 10 	movl   $0xf01053b7,0xc(%esp)
f0100bcb:	f0 
f0100bcc:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100bd3:	f0 
f0100bd4:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
f0100bdb:	00 
f0100bdc:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100be3:	e8 c9 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100be8:	89 d0                	mov    %edx,%eax
f0100bea:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bed:	a8 07                	test   $0x7,%al
f0100bef:	74 24                	je     f0100c15 <check_page_free_list+0x1ae>
f0100bf1:	c7 44 24 0c b0 4b 10 	movl   $0xf0104bb0,0xc(%esp)
f0100bf8:	f0 
f0100bf9:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100c00:	f0 
f0100c01:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0100c08:	00 
f0100c09:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100c10:	e8 9c f4 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c15:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c18:	c1 e0 0c             	shl    $0xc,%eax
f0100c1b:	75 24                	jne    f0100c41 <check_page_free_list+0x1da>
f0100c1d:	c7 44 24 0c cb 53 10 	movl   $0xf01053cb,0xc(%esp)
f0100c24:	f0 
f0100c25:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100c2c:	f0 
f0100c2d:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f0100c34:	00 
f0100c35:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100c3c:	e8 70 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c41:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c46:	75 24                	jne    f0100c6c <check_page_free_list+0x205>
f0100c48:	c7 44 24 0c dc 53 10 	movl   $0xf01053dc,0xc(%esp)
f0100c4f:	f0 
f0100c50:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100c57:	f0 
f0100c58:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f0100c5f:	00 
f0100c60:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100c67:	e8 45 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c6c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c71:	75 24                	jne    f0100c97 <check_page_free_list+0x230>
f0100c73:	c7 44 24 0c e4 4b 10 	movl   $0xf0104be4,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100c92:	e8 1a f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c97:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c9c:	75 24                	jne    f0100cc2 <check_page_free_list+0x25b>
f0100c9e:	c7 44 24 0c f5 53 10 	movl   $0xf01053f5,0xc(%esp)
f0100ca5:	f0 
f0100ca6:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100cad:	f0 
f0100cae:	c7 44 24 04 91 02 00 	movl   $0x291,0x4(%esp)
f0100cb5:	00 
f0100cb6:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100cbd:	e8 ef f3 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cc2:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cc7:	76 58                	jbe    f0100d21 <check_page_free_list+0x2ba>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cc9:	89 c1                	mov    %eax,%ecx
f0100ccb:	c1 e9 0c             	shr    $0xc,%ecx
f0100cce:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100cd1:	77 20                	ja     f0100cf3 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cd3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cd7:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0100cde:	f0 
f0100cdf:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ce6:	00 
f0100ce7:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f0100cee:	e8 be f3 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0100cf3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cf8:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100cfb:	76 27                	jbe    f0100d24 <check_page_free_list+0x2bd>
f0100cfd:	c7 44 24 0c 08 4c 10 	movl   $0xf0104c08,0xc(%esp)
f0100d04:	f0 
f0100d05:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100d0c:	f0 
f0100d0d:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
f0100d14:	00 
f0100d15:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100d1c:	e8 90 f3 ff ff       	call   f01000b1 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d21:	46                   	inc    %esi
f0100d22:	eb 01                	jmp    f0100d25 <check_page_free_list+0x2be>
		else
			++nfree_extmem;
f0100d24:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d25:	8b 12                	mov    (%edx),%edx
f0100d27:	85 d2                	test   %edx,%edx
f0100d29:	0f 85 67 fe ff ff    	jne    f0100b96 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d2f:	85 f6                	test   %esi,%esi
f0100d31:	7f 24                	jg     f0100d57 <check_page_free_list+0x2f0>
f0100d33:	c7 44 24 0c 0f 54 10 	movl   $0xf010540f,0xc(%esp)
f0100d3a:	f0 
f0100d3b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100d42:	f0 
f0100d43:	c7 44 24 04 9a 02 00 	movl   $0x29a,0x4(%esp)
f0100d4a:	00 
f0100d4b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100d52:	e8 5a f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100d57:	85 db                	test   %ebx,%ebx
f0100d59:	7f 24                	jg     f0100d7f <check_page_free_list+0x318>
f0100d5b:	c7 44 24 0c 21 54 10 	movl   $0xf0105421,0xc(%esp)
f0100d62:	f0 
f0100d63:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0100d6a:	f0 
f0100d6b:	c7 44 24 04 9b 02 00 	movl   $0x29b,0x4(%esp)
f0100d72:	00 
f0100d73:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100d7a:	e8 32 f3 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d7f:	c7 04 24 50 4c 10 f0 	movl   $0xf0104c50,(%esp)
f0100d86:	e8 3b 25 00 00       	call   f01032c6 <cprintf>
}
f0100d8b:	83 c4 4c             	add    $0x4c,%esp
f0100d8e:	5b                   	pop    %ebx
f0100d8f:	5e                   	pop    %esi
f0100d90:	5f                   	pop    %edi
f0100d91:	5d                   	pop    %ebp
f0100d92:	c3                   	ret    

f0100d93 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d93:	55                   	push   %ebp
f0100d94:	89 e5                	mov    %esp,%ebp
f0100d96:	57                   	push   %edi
f0100d97:	56                   	push   %esi
f0100d98:	53                   	push   %ebx
f0100d99:	83 ec 1c             	sub    $0x1c,%esp
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
f0100d9c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100da1:	e8 f8 fb ff ff       	call   f010099e <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100da6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100dab:	77 20                	ja     f0100dcd <page_init+0x3a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100db1:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f0100db8:	f0 
f0100db9:	c7 44 24 04 18 01 00 	movl   $0x118,0x4(%esp)
f0100dc0:	00 
f0100dc1:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100dc8:	e8 e4 f2 ff ff       	call   f01000b1 <_panic>
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE)) {
f0100dcd:	8b 35 98 01 1e f0    	mov    0xf01e0198,%esi
	return (physaddr_t)kva - KERNBASE;
f0100dd3:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0100dd9:	c1 ef 0c             	shr    $0xc,%edi
f0100ddc:	8b 1d a0 01 1e f0    	mov    0xf01e01a0,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100de2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100de7:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dec:	eb 36                	jmp    f0100e24 <page_init+0x91>
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE)) {
f0100dee:	85 d2                	test   %edx,%edx
f0100df0:	74 08                	je     f0100dfa <page_init+0x67>
f0100df2:	39 f2                	cmp    %esi,%edx
f0100df4:	72 12                	jb     f0100e08 <page_init+0x75>
f0100df6:	39 fa                	cmp    %edi,%edx
f0100df8:	73 0e                	jae    f0100e08 <page_init+0x75>
			pages[i].pp_ref = 1;
f0100dfa:	a1 50 0e 1e f0       	mov    0xf01e0e50,%eax
f0100dff:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
f0100e06:	eb 18                	jmp    f0100e20 <page_init+0x8d>
		}
		// Rest of memory are free
		else {
			pages[i].pp_ref = 0;
f0100e08:	89 c8                	mov    %ecx,%eax
f0100e0a:	03 05 50 0e 1e f0    	add    0xf01e0e50,%eax
f0100e10:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100e16:	89 18                	mov    %ebx,(%eax)
			page_free_list = &pages[i];
f0100e18:	89 cb                	mov    %ecx,%ebx
f0100e1a:	03 1d 50 0e 1e f0    	add    0xf01e0e50,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100e20:	42                   	inc    %edx
f0100e21:	83 c1 08             	add    $0x8,%ecx
f0100e24:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0100e2a:	72 c2                	jb     f0100dee <page_init+0x5b>
f0100e2c:	89 1d a0 01 1e f0    	mov    %ebx,0xf01e01a0
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100e32:	83 c4 1c             	add    $0x1c,%esp
f0100e35:	5b                   	pop    %ebx
f0100e36:	5e                   	pop    %esi
f0100e37:	5f                   	pop    %edi
f0100e38:	5d                   	pop    %ebp
f0100e39:	c3                   	ret    

f0100e3a <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e3a:	55                   	push   %ebp
f0100e3b:	89 e5                	mov    %esp,%ebp
f0100e3d:	53                   	push   %ebx
f0100e3e:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo *currPage = page_free_list;
f0100e41:	8b 1d a0 01 1e f0    	mov    0xf01e01a0,%ebx
	// Check whether out of free memory
	if (!page_free_list) {
f0100e47:	85 db                	test   %ebx,%ebx
f0100e49:	74 6b                	je     f0100eb6 <page_alloc+0x7c>
		return NULL;
	}
	// Set the page without change the reference bit.
	page_free_list = currPage->pp_link;
f0100e4b:	8b 03                	mov    (%ebx),%eax
f0100e4d:	a3 a0 01 1e f0       	mov    %eax,0xf01e01a0
	currPage->pp_link = NULL;
f0100e52:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100e58:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e5c:	74 58                	je     f0100eb6 <page_alloc+0x7c>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e5e:	89 d8                	mov    %ebx,%eax
f0100e60:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0100e66:	c1 f8 03             	sar    $0x3,%eax
f0100e69:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e6c:	89 c2                	mov    %eax,%edx
f0100e6e:	c1 ea 0c             	shr    $0xc,%edx
f0100e71:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0100e77:	72 20                	jb     f0100e99 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e7d:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e8c:	00 
f0100e8d:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f0100e94:	e8 18 f2 ff ff       	call   f01000b1 <_panic>
	{
		memset(page2kva(currPage), 0, PGSIZE);
f0100e99:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100ea0:	00 
f0100ea1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100ea8:	00 
	return (void *)(pa + KERNBASE);
f0100ea9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eae:	89 04 24             	mov    %eax,(%esp)
f0100eb1:	e8 1c 33 00 00       	call   f01041d2 <memset>
	}
	return currPage;
}
f0100eb6:	89 d8                	mov    %ebx,%eax
f0100eb8:	83 c4 14             	add    $0x14,%esp
f0100ebb:	5b                   	pop    %ebx
f0100ebc:	5d                   	pop    %ebp
f0100ebd:	c3                   	ret    

f0100ebe <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100ebe:	55                   	push   %ebp
f0100ebf:	89 e5                	mov    %esp,%ebp
f0100ec1:	83 ec 18             	sub    $0x18,%esp
f0100ec4:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref || pp->pp_link) {
f0100ec7:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ecc:	75 05                	jne    f0100ed3 <page_free+0x15>
f0100ece:	83 38 00             	cmpl   $0x0,(%eax)
f0100ed1:	74 1c                	je     f0100eef <page_free+0x31>
		panic("page_free: reference bit is nonzero or link is not NULL!");
f0100ed3:	c7 44 24 08 74 4c 10 	movl   $0xf0104c74,0x8(%esp)
f0100eda:	f0 
f0100edb:	c7 44 24 04 53 01 00 	movl   $0x153,0x4(%esp)
f0100ee2:	00 
f0100ee3:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100eea:	e8 c2 f1 ff ff       	call   f01000b1 <_panic>
	}
	// Update the free list
	pp->pp_link = page_free_list;
f0100eef:	8b 15 a0 01 1e f0    	mov    0xf01e01a0,%edx
f0100ef5:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ef7:	a3 a0 01 1e f0       	mov    %eax,0xf01e01a0
}
f0100efc:	c9                   	leave  
f0100efd:	c3                   	ret    

f0100efe <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100efe:	55                   	push   %ebp
f0100eff:	89 e5                	mov    %esp,%ebp
f0100f01:	83 ec 18             	sub    $0x18,%esp
f0100f04:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0) 
f0100f07:	8b 50 04             	mov    0x4(%eax),%edx
f0100f0a:	4a                   	dec    %edx
f0100f0b:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100f0f:	66 85 d2             	test   %dx,%dx
f0100f12:	75 08                	jne    f0100f1c <page_decref+0x1e>
		page_free(pp);
f0100f14:	89 04 24             	mov    %eax,(%esp)
f0100f17:	e8 a2 ff ff ff       	call   f0100ebe <page_free>
}
f0100f1c:	c9                   	leave  
f0100f1d:	c3                   	ret    

f0100f1e <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f1e:	55                   	push   %ebp
f0100f1f:	89 e5                	mov    %esp,%ebp
f0100f21:	56                   	push   %esi
f0100f22:	53                   	push   %ebx
f0100f23:	83 ec 10             	sub    $0x10,%esp
f0100f26:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	struct PageInfo *newPage;
	pde_t *pdeEntry = &pgdir[PDX(va)];
f0100f29:	89 f3                	mov    %esi,%ebx
f0100f2b:	c1 eb 16             	shr    $0x16,%ebx
f0100f2e:	c1 e3 02             	shl    $0x2,%ebx
f0100f31:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t *pteEntry;
	// First extract the content stored in the page directory, 
	// it should be a physical address with some PTE information.
	// If the content is not null, convert it into virtual 
	// address and return
	if (*pdeEntry & PTE_P) {
f0100f34:	f6 03 01             	testb  $0x1,(%ebx)
f0100f37:	75 2b                	jne    f0100f64 <pgdir_walk+0x46>
		goto good;
	}
	// Otherwise, intialize a new page if permitted
	if (create) {
f0100f39:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f3d:	74 6b                	je     f0100faa <pgdir_walk+0x8c>
		newPage = page_alloc(1);
f0100f3f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f46:	e8 ef fe ff ff       	call   f0100e3a <page_alloc>
		// If the page allocation success
		if (newPage) {
f0100f4b:	85 c0                	test   %eax,%eax
f0100f4d:	74 62                	je     f0100fb1 <pgdir_walk+0x93>
			newPage->pp_ref++;
f0100f4f:	66 ff 40 04          	incw   0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f53:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0100f59:	c1 f8 03             	sar    $0x3,%eax
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
f0100f5c:	c1 e0 0c             	shl    $0xc,%eax
f0100f5f:	83 c8 07             	or     $0x7,%eax
f0100f62:	89 03                	mov    %eax,(%ebx)
		}
	}
	return NULL;

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
f0100f64:	8b 03                	mov    (%ebx),%eax
f0100f66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f6b:	89 c2                	mov    %eax,%edx
f0100f6d:	c1 ea 0c             	shr    $0xc,%edx
f0100f70:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0100f76:	72 20                	jb     f0100f98 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f78:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f7c:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0100f83:	f0 
f0100f84:	c7 44 24 04 97 01 00 	movl   $0x197,0x4(%esp)
f0100f8b:	00 
f0100f8c:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0100f93:	e8 19 f1 ff ff       	call   f01000b1 <_panic>
	return &pteEntry[PTX(va)];
f0100f98:	c1 ee 0a             	shr    $0xa,%esi
f0100f9b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100fa1:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100fa8:	eb 0c                	jmp    f0100fb6 <pgdir_walk+0x98>
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
			goto good;
		}
	}
	return NULL;
f0100faa:	b8 00 00 00 00       	mov    $0x0,%eax
f0100faf:	eb 05                	jmp    f0100fb6 <pgdir_walk+0x98>
f0100fb1:	b8 00 00 00 00       	mov    $0x0,%eax

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
	return &pteEntry[PTX(va)];
}
f0100fb6:	83 c4 10             	add    $0x10,%esp
f0100fb9:	5b                   	pop    %ebx
f0100fba:	5e                   	pop    %esi
f0100fbb:	5d                   	pop    %ebp
f0100fbc:	c3                   	ret    

f0100fbd <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100fbd:	55                   	push   %ebp
f0100fbe:	89 e5                	mov    %esp,%ebp
f0100fc0:	57                   	push   %edi
f0100fc1:	56                   	push   %esi
f0100fc2:	53                   	push   %ebx
f0100fc3:	83 ec 2c             	sub    $0x2c,%esp
f0100fc6:	89 c7                	mov    %eax,%edi
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
f0100fc8:	c1 e9 0c             	shr    $0xc,%ecx
f0100fcb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0100fce:	89 d3                	mov    %edx,%ebx
f0100fd0:	be 00 00 00 00       	mov    $0x0,%esi
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		if ((*pteEntry & PTE_P) == 0) {
			*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f0100fd5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fd8:	83 c8 01             	or     $0x1,%eax
f0100fdb:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0100fde:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fe1:	29 d0                	sub    %edx,%eax
f0100fe3:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0100fe6:	eb 30                	jmp    f0101018 <boot_map_region+0x5b>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
f0100fe8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100fef:	00 
f0100ff0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100ff4:	89 3c 24             	mov    %edi,(%esp)
f0100ff7:	e8 22 ff ff ff       	call   f0100f1e <pgdir_walk>
		if ((*pteEntry & PTE_P) == 0) {
f0100ffc:	f6 00 01             	testb  $0x1,(%eax)
f0100fff:	75 10                	jne    f0101011 <boot_map_region+0x54>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0101001:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101004:	01 da                	add    %ebx,%edx
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		if ((*pteEntry & PTE_P) == 0) {
			*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f0101006:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010100c:	0b 55 e0             	or     -0x20(%ebp),%edx
f010100f:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0101011:	46                   	inc    %esi
f0101012:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101018:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f010101b:	75 cb                	jne    f0100fe8 <boot_map_region+0x2b>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		if ((*pteEntry & PTE_P) == 0) {
			*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
		}
	}	
}
f010101d:	83 c4 2c             	add    $0x2c,%esp
f0101020:	5b                   	pop    %ebx
f0101021:	5e                   	pop    %esi
f0101022:	5f                   	pop    %edi
f0101023:	5d                   	pop    %ebp
f0101024:	c3                   	ret    

f0101025 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101025:	55                   	push   %ebp
f0101026:	89 e5                	mov    %esp,%ebp
f0101028:	53                   	push   %ebx
f0101029:	83 ec 14             	sub    $0x14,%esp
f010102c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
f010102f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101036:	00 
f0101037:	8b 45 0c             	mov    0xc(%ebp),%eax
f010103a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010103e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101041:	89 04 24             	mov    %eax,(%esp)
f0101044:	e8 d5 fe ff ff       	call   f0100f1e <pgdir_walk>
	physaddr_t pp;
	if (!pteEntry) {
f0101049:	85 c0                	test   %eax,%eax
f010104b:	74 3f                	je     f010108c <page_lookup+0x67>
		return NULL;
	}
	if (*pteEntry & PTE_P) {
f010104d:	f6 00 01             	testb  $0x1,(%eax)
f0101050:	74 41                	je     f0101093 <page_lookup+0x6e>
		// Modify pte_store passed as a reference
		if (pte_store) {
f0101052:	85 db                	test   %ebx,%ebx
f0101054:	74 02                	je     f0101058 <page_lookup+0x33>
		 	*pte_store = pteEntry;
f0101056:	89 03                	mov    %eax,(%ebx)
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
f0101058:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010105a:	c1 e8 0c             	shr    $0xc,%eax
f010105d:	3b 05 48 0e 1e f0    	cmp    0xf01e0e48,%eax
f0101063:	72 1c                	jb     f0101081 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101065:	c7 44 24 08 b0 4c 10 	movl   $0xf0104cb0,0x8(%esp)
f010106c:	f0 
f010106d:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101074:	00 
f0101075:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f010107c:	e8 30 f0 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0101081:	c1 e0 03             	shl    $0x3,%eax
f0101084:	03 05 50 0e 1e f0    	add    0xf01e0e50,%eax
		return pa2page(pp);
f010108a:	eb 0c                	jmp    f0101098 <page_lookup+0x73>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
	physaddr_t pp;
	if (!pteEntry) {
		return NULL;
f010108c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101091:	eb 05                	jmp    f0101098 <page_lookup+0x73>
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
		return pa2page(pp);
	}
	return NULL;
f0101093:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101098:	83 c4 14             	add    $0x14,%esp
f010109b:	5b                   	pop    %ebx
f010109c:	5d                   	pop    %ebp
f010109d:	c3                   	ret    

f010109e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010109e:	55                   	push   %ebp
f010109f:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010a1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010a4:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01010a7:	5d                   	pop    %ebp
f01010a8:	c3                   	ret    

f01010a9 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010a9:	55                   	push   %ebp
f01010aa:	89 e5                	mov    %esp,%ebp
f01010ac:	56                   	push   %esi
f01010ad:	53                   	push   %ebx
f01010ae:	83 ec 20             	sub    $0x20,%esp
f01010b1:	8b 75 08             	mov    0x8(%ebp),%esi
f01010b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// Create a ptep store
	pte_t *pteEntry;
	// Look up the page and the entry for the page
	struct PageInfo *pp = page_lookup(pgdir, va, &pteEntry);
f01010b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010ba:	89 44 24 08          	mov    %eax,0x8(%esp)
f01010be:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010c2:	89 34 24             	mov    %esi,(%esp)
f01010c5:	e8 5b ff ff ff       	call   f0101025 <page_lookup>
	if (!pp) {
f01010ca:	85 c0                	test   %eax,%eax
f01010cc:	74 1d                	je     f01010eb <page_remove+0x42>
		return;
	}
	page_decref(pp);
f01010ce:	89 04 24             	mov    %eax,(%esp)
f01010d1:	e8 28 fe ff ff       	call   f0100efe <page_decref>
	tlb_invalidate(pgdir, va);
f01010d6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010da:	89 34 24             	mov    %esi,(%esp)
f01010dd:	e8 bc ff ff ff       	call   f010109e <tlb_invalidate>
	// Enpty the page table
	*pteEntry = 0;
f01010e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010e5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f01010eb:	83 c4 20             	add    $0x20,%esp
f01010ee:	5b                   	pop    %ebx
f01010ef:	5e                   	pop    %esi
f01010f0:	5d                   	pop    %ebp
f01010f1:	c3                   	ret    

f01010f2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010f2:	55                   	push   %ebp
f01010f3:	89 e5                	mov    %esp,%ebp
f01010f5:	57                   	push   %edi
f01010f6:	56                   	push   %esi
f01010f7:	53                   	push   %ebx
f01010f8:	83 ec 1c             	sub    $0x1c,%esp
f01010fb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01010fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
f0101101:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101108:	00 
f0101109:	8b 45 10             	mov    0x10(%ebp),%eax
f010110c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101110:	89 3c 24             	mov    %edi,(%esp)
f0101113:	e8 06 fe ff ff       	call   f0100f1e <pgdir_walk>
f0101118:	89 c6                	mov    %eax,%esi
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
f010111a:	85 c0                	test   %eax,%eax
f010111c:	74 41                	je     f010115f <page_insert+0x6d>
		return -E_NO_MEM;
	}
	// Increment reference bit
	pp->pp_ref++;
f010111e:	66 ff 43 04          	incw   0x4(%ebx)
	// If the page itself is valid, remove it
	if (*pteEntry & PTE_P) {
f0101122:	f6 00 01             	testb  $0x1,(%eax)
f0101125:	74 0f                	je     f0101136 <page_insert+0x44>
		// If there is already a page at va, it should be removed
		page_remove(pgdir, va);
f0101127:	8b 55 10             	mov    0x10(%ebp),%edx
f010112a:	89 54 24 04          	mov    %edx,0x4(%esp)
f010112e:	89 3c 24             	mov    %edi,(%esp)
f0101131:	e8 73 ff ff ff       	call   f01010a9 <page_remove>
	}
	// Modify premission for both directory entry and page table entry
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f0101136:	8b 45 14             	mov    0x14(%ebp),%eax
f0101139:	83 c8 01             	or     $0x1,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010113c:	2b 1d 50 0e 1e f0    	sub    0xf01e0e50,%ebx
f0101142:	c1 fb 03             	sar    $0x3,%ebx
f0101145:	c1 e3 0c             	shl    $0xc,%ebx
f0101148:	09 c3                	or     %eax,%ebx
f010114a:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm;
f010114c:	8b 45 10             	mov    0x10(%ebp),%eax
f010114f:	c1 e8 16             	shr    $0x16,%eax
f0101152:	8b 55 14             	mov    0x14(%ebp),%edx
f0101155:	09 14 87             	or     %edx,(%edi,%eax,4)
	// Return success
	return 0;
f0101158:	b8 00 00 00 00       	mov    $0x0,%eax
f010115d:	eb 05                	jmp    f0101164 <page_insert+0x72>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
		return -E_NO_MEM;
f010115f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	pgdir[PDX(va)] |= perm;
	// Return success
	return 0;
	
}
f0101164:	83 c4 1c             	add    $0x1c,%esp
f0101167:	5b                   	pop    %ebx
f0101168:	5e                   	pop    %esi
f0101169:	5f                   	pop    %edi
f010116a:	5d                   	pop    %ebp
f010116b:	c3                   	ret    

f010116c <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010116c:	55                   	push   %ebp
f010116d:	89 e5                	mov    %esp,%ebp
f010116f:	57                   	push   %edi
f0101170:	56                   	push   %esi
f0101171:	53                   	push   %ebx
f0101172:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101175:	b8 15 00 00 00       	mov    $0x15,%eax
f010117a:	e8 f6 f7 ff ff       	call   f0100975 <nvram_read>
f010117f:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101181:	b8 17 00 00 00       	mov    $0x17,%eax
f0101186:	e8 ea f7 ff ff       	call   f0100975 <nvram_read>
f010118b:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010118d:	b8 34 00 00 00       	mov    $0x34,%eax
f0101192:	e8 de f7 ff ff       	call   f0100975 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101197:	c1 e0 06             	shl    $0x6,%eax
f010119a:	74 08                	je     f01011a4 <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f010119c:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f01011a2:	eb 0e                	jmp    f01011b2 <mem_init+0x46>
	else if (extmem)
f01011a4:	85 f6                	test   %esi,%esi
f01011a6:	74 08                	je     f01011b0 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f01011a8:	81 c6 00 04 00 00    	add    $0x400,%esi
f01011ae:	eb 02                	jmp    f01011b2 <mem_init+0x46>
	else
		totalmem = basemem;
f01011b0:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f01011b2:	89 f0                	mov    %esi,%eax
f01011b4:	c1 e8 02             	shr    $0x2,%eax
f01011b7:	a3 48 0e 1e f0       	mov    %eax,0xf01e0e48
	npages_basemem = basemem / (PGSIZE / 1024);
f01011bc:	89 d8                	mov    %ebx,%eax
f01011be:	c1 e8 02             	shr    $0x2,%eax
f01011c1:	a3 98 01 1e f0       	mov    %eax,0xf01e0198

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c6:	89 f0                	mov    %esi,%eax
f01011c8:	29 d8                	sub    %ebx,%eax
f01011ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01011d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011d6:	c7 04 24 d0 4c 10 f0 	movl   $0xf0104cd0,(%esp)
f01011dd:	e8 e4 20 00 00       	call   f01032c6 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011e2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011e7:	e8 b2 f7 ff ff       	call   f010099e <boot_alloc>
f01011ec:	a3 4c 0e 1e f0       	mov    %eax,0xf01e0e4c
	memset(kern_pgdir, 0, PGSIZE);
f01011f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011f8:	00 
f01011f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101200:	00 
f0101201:	89 04 24             	mov    %eax,(%esp)
f0101204:	e8 c9 2f 00 00       	call   f01041d2 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101209:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010120e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101213:	77 20                	ja     f0101235 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101215:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101219:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f0101220:	f0 
f0101221:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0101228:	00 
f0101229:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101230:	e8 7c ee ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101235:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010123b:	83 ca 05             	or     $0x5,%edx
f010123e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101244:	a1 48 0e 1e f0       	mov    0xf01e0e48,%eax
f0101249:	c1 e0 03             	shl    $0x3,%eax
f010124c:	e8 4d f7 ff ff       	call   f010099e <boot_alloc>
f0101251:	a3 50 0e 1e f0       	mov    %eax,0xf01e0e50
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101256:	8b 15 48 0e 1e f0    	mov    0xf01e0e48,%edx
f010125c:	c1 e2 03             	shl    $0x3,%edx
f010125f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101263:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010126a:	00 
f010126b:	89 04 24             	mov    %eax,(%esp)
f010126e:	e8 5f 2f 00 00       	call   f01041d2 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101273:	e8 1b fb ff ff       	call   f0100d93 <page_init>

	check_page_free_list(1);
f0101278:	b8 01 00 00 00       	mov    $0x1,%eax
f010127d:	e8 e5 f7 ff ff       	call   f0100a67 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101282:	83 3d 50 0e 1e f0 00 	cmpl   $0x0,0xf01e0e50
f0101289:	75 1c                	jne    f01012a7 <mem_init+0x13b>
		panic("'pages' is a null pointer!");
f010128b:	c7 44 24 08 32 54 10 	movl   $0xf0105432,0x8(%esp)
f0101292:	f0 
f0101293:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
f010129a:	00 
f010129b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01012a2:	e8 0a ee ff ff       	call   f01000b1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012a7:	a1 a0 01 1e f0       	mov    0xf01e01a0,%eax
f01012ac:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012b1:	eb 03                	jmp    f01012b6 <mem_init+0x14a>
		++nfree;
f01012b3:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012b4:	8b 00                	mov    (%eax),%eax
f01012b6:	85 c0                	test   %eax,%eax
f01012b8:	75 f9                	jne    f01012b3 <mem_init+0x147>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012c1:	e8 74 fb ff ff       	call   f0100e3a <page_alloc>
f01012c6:	89 c6                	mov    %eax,%esi
f01012c8:	85 c0                	test   %eax,%eax
f01012ca:	75 24                	jne    f01012f0 <mem_init+0x184>
f01012cc:	c7 44 24 0c 4d 54 10 	movl   $0xf010544d,0xc(%esp)
f01012d3:	f0 
f01012d4:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01012db:	f0 
f01012dc:	c7 44 24 04 b6 02 00 	movl   $0x2b6,0x4(%esp)
f01012e3:	00 
f01012e4:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01012eb:	e8 c1 ed ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01012f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012f7:	e8 3e fb ff ff       	call   f0100e3a <page_alloc>
f01012fc:	89 c7                	mov    %eax,%edi
f01012fe:	85 c0                	test   %eax,%eax
f0101300:	75 24                	jne    f0101326 <mem_init+0x1ba>
f0101302:	c7 44 24 0c 63 54 10 	movl   $0xf0105463,0xc(%esp)
f0101309:	f0 
f010130a:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101311:	f0 
f0101312:	c7 44 24 04 b7 02 00 	movl   $0x2b7,0x4(%esp)
f0101319:	00 
f010131a:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101321:	e8 8b ed ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101326:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010132d:	e8 08 fb ff ff       	call   f0100e3a <page_alloc>
f0101332:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101335:	85 c0                	test   %eax,%eax
f0101337:	75 24                	jne    f010135d <mem_init+0x1f1>
f0101339:	c7 44 24 0c 79 54 10 	movl   $0xf0105479,0xc(%esp)
f0101340:	f0 
f0101341:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101348:	f0 
f0101349:	c7 44 24 04 b8 02 00 	movl   $0x2b8,0x4(%esp)
f0101350:	00 
f0101351:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101358:	e8 54 ed ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010135d:	39 fe                	cmp    %edi,%esi
f010135f:	75 24                	jne    f0101385 <mem_init+0x219>
f0101361:	c7 44 24 0c 8f 54 10 	movl   $0xf010548f,0xc(%esp)
f0101368:	f0 
f0101369:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101370:	f0 
f0101371:	c7 44 24 04 bb 02 00 	movl   $0x2bb,0x4(%esp)
f0101378:	00 
f0101379:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101380:	e8 2c ed ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101385:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101388:	74 05                	je     f010138f <mem_init+0x223>
f010138a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010138d:	75 24                	jne    f01013b3 <mem_init+0x247>
f010138f:	c7 44 24 0c 0c 4d 10 	movl   $0xf0104d0c,0xc(%esp)
f0101396:	f0 
f0101397:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010139e:	f0 
f010139f:	c7 44 24 04 bc 02 00 	movl   $0x2bc,0x4(%esp)
f01013a6:	00 
f01013a7:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01013ae:	e8 fe ec ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013b3:	8b 15 50 0e 1e f0    	mov    0xf01e0e50,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013b9:	a1 48 0e 1e f0       	mov    0xf01e0e48,%eax
f01013be:	c1 e0 0c             	shl    $0xc,%eax
f01013c1:	89 f1                	mov    %esi,%ecx
f01013c3:	29 d1                	sub    %edx,%ecx
f01013c5:	c1 f9 03             	sar    $0x3,%ecx
f01013c8:	c1 e1 0c             	shl    $0xc,%ecx
f01013cb:	39 c1                	cmp    %eax,%ecx
f01013cd:	72 24                	jb     f01013f3 <mem_init+0x287>
f01013cf:	c7 44 24 0c a1 54 10 	movl   $0xf01054a1,0xc(%esp)
f01013d6:	f0 
f01013d7:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01013de:	f0 
f01013df:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f01013e6:	00 
f01013e7:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01013ee:	e8 be ec ff ff       	call   f01000b1 <_panic>
f01013f3:	89 f9                	mov    %edi,%ecx
f01013f5:	29 d1                	sub    %edx,%ecx
f01013f7:	c1 f9 03             	sar    $0x3,%ecx
f01013fa:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01013fd:	39 c8                	cmp    %ecx,%eax
f01013ff:	77 24                	ja     f0101425 <mem_init+0x2b9>
f0101401:	c7 44 24 0c be 54 10 	movl   $0xf01054be,0xc(%esp)
f0101408:	f0 
f0101409:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101410:	f0 
f0101411:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0101418:	00 
f0101419:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101420:	e8 8c ec ff ff       	call   f01000b1 <_panic>
f0101425:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101428:	29 d1                	sub    %edx,%ecx
f010142a:	89 ca                	mov    %ecx,%edx
f010142c:	c1 fa 03             	sar    $0x3,%edx
f010142f:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101432:	39 d0                	cmp    %edx,%eax
f0101434:	77 24                	ja     f010145a <mem_init+0x2ee>
f0101436:	c7 44 24 0c db 54 10 	movl   $0xf01054db,0xc(%esp)
f010143d:	f0 
f010143e:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101445:	f0 
f0101446:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f010144d:	00 
f010144e:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101455:	e8 57 ec ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010145a:	a1 a0 01 1e f0       	mov    0xf01e01a0,%eax
f010145f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101462:	c7 05 a0 01 1e f0 00 	movl   $0x0,0xf01e01a0
f0101469:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010146c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101473:	e8 c2 f9 ff ff       	call   f0100e3a <page_alloc>
f0101478:	85 c0                	test   %eax,%eax
f010147a:	74 24                	je     f01014a0 <mem_init+0x334>
f010147c:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f0101483:	f0 
f0101484:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010148b:	f0 
f010148c:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f0101493:	00 
f0101494:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010149b:	e8 11 ec ff ff       	call   f01000b1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014a0:	89 34 24             	mov    %esi,(%esp)
f01014a3:	e8 16 fa ff ff       	call   f0100ebe <page_free>
	page_free(pp1);
f01014a8:	89 3c 24             	mov    %edi,(%esp)
f01014ab:	e8 0e fa ff ff       	call   f0100ebe <page_free>
	page_free(pp2);
f01014b0:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014b3:	89 04 24             	mov    %eax,(%esp)
f01014b6:	e8 03 fa ff ff       	call   f0100ebe <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014c2:	e8 73 f9 ff ff       	call   f0100e3a <page_alloc>
f01014c7:	89 c6                	mov    %eax,%esi
f01014c9:	85 c0                	test   %eax,%eax
f01014cb:	75 24                	jne    f01014f1 <mem_init+0x385>
f01014cd:	c7 44 24 0c 4d 54 10 	movl   $0xf010544d,0xc(%esp)
f01014d4:	f0 
f01014d5:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01014dc:	f0 
f01014dd:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f01014e4:	00 
f01014e5:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01014ec:	e8 c0 eb ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01014f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014f8:	e8 3d f9 ff ff       	call   f0100e3a <page_alloc>
f01014fd:	89 c7                	mov    %eax,%edi
f01014ff:	85 c0                	test   %eax,%eax
f0101501:	75 24                	jne    f0101527 <mem_init+0x3bb>
f0101503:	c7 44 24 0c 63 54 10 	movl   $0xf0105463,0xc(%esp)
f010150a:	f0 
f010150b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101512:	f0 
f0101513:	c7 44 24 04 ce 02 00 	movl   $0x2ce,0x4(%esp)
f010151a:	00 
f010151b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101522:	e8 8a eb ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101527:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010152e:	e8 07 f9 ff ff       	call   f0100e3a <page_alloc>
f0101533:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101536:	85 c0                	test   %eax,%eax
f0101538:	75 24                	jne    f010155e <mem_init+0x3f2>
f010153a:	c7 44 24 0c 79 54 10 	movl   $0xf0105479,0xc(%esp)
f0101541:	f0 
f0101542:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101549:	f0 
f010154a:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0101551:	00 
f0101552:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101559:	e8 53 eb ff ff       	call   f01000b1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010155e:	39 fe                	cmp    %edi,%esi
f0101560:	75 24                	jne    f0101586 <mem_init+0x41a>
f0101562:	c7 44 24 0c 8f 54 10 	movl   $0xf010548f,0xc(%esp)
f0101569:	f0 
f010156a:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101571:	f0 
f0101572:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f0101579:	00 
f010157a:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101581:	e8 2b eb ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101586:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101589:	74 05                	je     f0101590 <mem_init+0x424>
f010158b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010158e:	75 24                	jne    f01015b4 <mem_init+0x448>
f0101590:	c7 44 24 0c 0c 4d 10 	movl   $0xf0104d0c,0xc(%esp)
f0101597:	f0 
f0101598:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010159f:	f0 
f01015a0:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f01015a7:	00 
f01015a8:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01015af:	e8 fd ea ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01015b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015bb:	e8 7a f8 ff ff       	call   f0100e3a <page_alloc>
f01015c0:	85 c0                	test   %eax,%eax
f01015c2:	74 24                	je     f01015e8 <mem_init+0x47c>
f01015c4:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f01015cb:	f0 
f01015cc:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01015d3:	f0 
f01015d4:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f01015db:	00 
f01015dc:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01015e3:	e8 c9 ea ff ff       	call   f01000b1 <_panic>
f01015e8:	89 f0                	mov    %esi,%eax
f01015ea:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f01015f0:	c1 f8 03             	sar    $0x3,%eax
f01015f3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015f6:	89 c2                	mov    %eax,%edx
f01015f8:	c1 ea 0c             	shr    $0xc,%edx
f01015fb:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0101601:	72 20                	jb     f0101623 <mem_init+0x4b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101603:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101607:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f010160e:	f0 
f010160f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0101616:	00 
f0101617:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f010161e:	e8 8e ea ff ff       	call   f01000b1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101623:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010162a:	00 
f010162b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101632:	00 
	return (void *)(pa + KERNBASE);
f0101633:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101638:	89 04 24             	mov    %eax,(%esp)
f010163b:	e8 92 2b 00 00       	call   f01041d2 <memset>
	page_free(pp0);
f0101640:	89 34 24             	mov    %esi,(%esp)
f0101643:	e8 76 f8 ff ff       	call   f0100ebe <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101648:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010164f:	e8 e6 f7 ff ff       	call   f0100e3a <page_alloc>
f0101654:	85 c0                	test   %eax,%eax
f0101656:	75 24                	jne    f010167c <mem_init+0x510>
f0101658:	c7 44 24 0c 07 55 10 	movl   $0xf0105507,0xc(%esp)
f010165f:	f0 
f0101660:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101667:	f0 
f0101668:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010166f:	00 
f0101670:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101677:	e8 35 ea ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f010167c:	39 c6                	cmp    %eax,%esi
f010167e:	74 24                	je     f01016a4 <mem_init+0x538>
f0101680:	c7 44 24 0c 25 55 10 	movl   $0xf0105525,0xc(%esp)
f0101687:	f0 
f0101688:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010168f:	f0 
f0101690:	c7 44 24 04 d9 02 00 	movl   $0x2d9,0x4(%esp)
f0101697:	00 
f0101698:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010169f:	e8 0d ea ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016a4:	89 f2                	mov    %esi,%edx
f01016a6:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f01016ac:	c1 fa 03             	sar    $0x3,%edx
f01016af:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016b2:	89 d0                	mov    %edx,%eax
f01016b4:	c1 e8 0c             	shr    $0xc,%eax
f01016b7:	3b 05 48 0e 1e f0    	cmp    0xf01e0e48,%eax
f01016bd:	72 20                	jb     f01016df <mem_init+0x573>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016bf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01016c3:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f01016ca:	f0 
f01016cb:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01016d2:	00 
f01016d3:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f01016da:	e8 d2 e9 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f01016df:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01016e5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016eb:	80 38 00             	cmpb   $0x0,(%eax)
f01016ee:	74 24                	je     f0101714 <mem_init+0x5a8>
f01016f0:	c7 44 24 0c 35 55 10 	movl   $0xf0105535,0xc(%esp)
f01016f7:	f0 
f01016f8:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01016ff:	f0 
f0101700:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0101707:	00 
f0101708:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010170f:	e8 9d e9 ff ff       	call   f01000b1 <_panic>
f0101714:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101715:	39 d0                	cmp    %edx,%eax
f0101717:	75 d2                	jne    f01016eb <mem_init+0x57f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101719:	8b 55 d0             	mov    -0x30(%ebp),%edx
f010171c:	89 15 a0 01 1e f0    	mov    %edx,0xf01e01a0

	// free the pages we took
	page_free(pp0);
f0101722:	89 34 24             	mov    %esi,(%esp)
f0101725:	e8 94 f7 ff ff       	call   f0100ebe <page_free>
	page_free(pp1);
f010172a:	89 3c 24             	mov    %edi,(%esp)
f010172d:	e8 8c f7 ff ff       	call   f0100ebe <page_free>
	page_free(pp2);
f0101732:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101735:	89 04 24             	mov    %eax,(%esp)
f0101738:	e8 81 f7 ff ff       	call   f0100ebe <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010173d:	a1 a0 01 1e f0       	mov    0xf01e01a0,%eax
f0101742:	eb 03                	jmp    f0101747 <mem_init+0x5db>
		--nfree;
f0101744:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101745:	8b 00                	mov    (%eax),%eax
f0101747:	85 c0                	test   %eax,%eax
f0101749:	75 f9                	jne    f0101744 <mem_init+0x5d8>
		--nfree;
	assert(nfree == 0);
f010174b:	85 db                	test   %ebx,%ebx
f010174d:	74 24                	je     f0101773 <mem_init+0x607>
f010174f:	c7 44 24 0c 3f 55 10 	movl   $0xf010553f,0xc(%esp)
f0101756:	f0 
f0101757:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010175e:	f0 
f010175f:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f0101766:	00 
f0101767:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010176e:	e8 3e e9 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101773:	c7 04 24 2c 4d 10 f0 	movl   $0xf0104d2c,(%esp)
f010177a:	e8 47 1b 00 00       	call   f01032c6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010177f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101786:	e8 af f6 ff ff       	call   f0100e3a <page_alloc>
f010178b:	89 c7                	mov    %eax,%edi
f010178d:	85 c0                	test   %eax,%eax
f010178f:	75 24                	jne    f01017b5 <mem_init+0x649>
f0101791:	c7 44 24 0c 4d 54 10 	movl   $0xf010544d,0xc(%esp)
f0101798:	f0 
f0101799:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01017a0:	f0 
f01017a1:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f01017a8:	00 
f01017a9:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01017b0:	e8 fc e8 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017bc:	e8 79 f6 ff ff       	call   f0100e3a <page_alloc>
f01017c1:	89 c6                	mov    %eax,%esi
f01017c3:	85 c0                	test   %eax,%eax
f01017c5:	75 24                	jne    f01017eb <mem_init+0x67f>
f01017c7:	c7 44 24 0c 63 54 10 	movl   $0xf0105463,0xc(%esp)
f01017ce:	f0 
f01017cf:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01017d6:	f0 
f01017d7:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f01017de:	00 
f01017df:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01017e6:	e8 c6 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f01017eb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017f2:	e8 43 f6 ff ff       	call   f0100e3a <page_alloc>
f01017f7:	89 c3                	mov    %eax,%ebx
f01017f9:	85 c0                	test   %eax,%eax
f01017fb:	75 24                	jne    f0101821 <mem_init+0x6b5>
f01017fd:	c7 44 24 0c 79 54 10 	movl   $0xf0105479,0xc(%esp)
f0101804:	f0 
f0101805:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010180c:	f0 
f010180d:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101814:	00 
f0101815:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010181c:	e8 90 e8 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101821:	39 f7                	cmp    %esi,%edi
f0101823:	75 24                	jne    f0101849 <mem_init+0x6dd>
f0101825:	c7 44 24 0c 8f 54 10 	movl   $0xf010548f,0xc(%esp)
f010182c:	f0 
f010182d:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101834:	f0 
f0101835:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f010183c:	00 
f010183d:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101844:	e8 68 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101849:	39 c6                	cmp    %eax,%esi
f010184b:	74 04                	je     f0101851 <mem_init+0x6e5>
f010184d:	39 c7                	cmp    %eax,%edi
f010184f:	75 24                	jne    f0101875 <mem_init+0x709>
f0101851:	c7 44 24 0c 0c 4d 10 	movl   $0xf0104d0c,0xc(%esp)
f0101858:	f0 
f0101859:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101860:	f0 
f0101861:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101868:	00 
f0101869:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101870:	e8 3c e8 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101875:	8b 15 a0 01 1e f0    	mov    0xf01e01a0,%edx
f010187b:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010187e:	c7 05 a0 01 1e f0 00 	movl   $0x0,0xf01e01a0
f0101885:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101888:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010188f:	e8 a6 f5 ff ff       	call   f0100e3a <page_alloc>
f0101894:	85 c0                	test   %eax,%eax
f0101896:	74 24                	je     f01018bc <mem_init+0x750>
f0101898:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f010189f:	f0 
f01018a0:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01018a7:	f0 
f01018a8:	c7 44 24 04 54 03 00 	movl   $0x354,0x4(%esp)
f01018af:	00 
f01018b0:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01018b7:	e8 f5 e7 ff ff       	call   f01000b1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018c3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018ca:	00 
f01018cb:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f01018d0:	89 04 24             	mov    %eax,(%esp)
f01018d3:	e8 4d f7 ff ff       	call   f0101025 <page_lookup>
f01018d8:	85 c0                	test   %eax,%eax
f01018da:	74 24                	je     f0101900 <mem_init+0x794>
f01018dc:	c7 44 24 0c 4c 4d 10 	movl   $0xf0104d4c,0xc(%esp)
f01018e3:	f0 
f01018e4:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01018eb:	f0 
f01018ec:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f01018f3:	00 
f01018f4:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01018fb:	e8 b1 e7 ff ff       	call   f01000b1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101900:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101907:	00 
f0101908:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010190f:	00 
f0101910:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101914:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101919:	89 04 24             	mov    %eax,(%esp)
f010191c:	e8 d1 f7 ff ff       	call   f01010f2 <page_insert>
f0101921:	85 c0                	test   %eax,%eax
f0101923:	78 24                	js     f0101949 <mem_init+0x7dd>
f0101925:	c7 44 24 0c 84 4d 10 	movl   $0xf0104d84,0xc(%esp)
f010192c:	f0 
f010192d:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101934:	f0 
f0101935:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f010193c:	00 
f010193d:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101944:	e8 68 e7 ff ff       	call   f01000b1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101949:	89 3c 24             	mov    %edi,(%esp)
f010194c:	e8 6d f5 ff ff       	call   f0100ebe <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101951:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101958:	00 
f0101959:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101960:	00 
f0101961:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101965:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f010196a:	89 04 24             	mov    %eax,(%esp)
f010196d:	e8 80 f7 ff ff       	call   f01010f2 <page_insert>
f0101972:	85 c0                	test   %eax,%eax
f0101974:	74 24                	je     f010199a <mem_init+0x82e>
f0101976:	c7 44 24 0c b4 4d 10 	movl   $0xf0104db4,0xc(%esp)
f010197d:	f0 
f010197e:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101985:	f0 
f0101986:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f010198d:	00 
f010198e:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101995:	e8 17 e7 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010199a:	8b 0d 4c 0e 1e f0    	mov    0xf01e0e4c,%ecx
f01019a0:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019a3:	a1 50 0e 1e f0       	mov    0xf01e0e50,%eax
f01019a8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01019ab:	8b 11                	mov    (%ecx),%edx
f01019ad:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019b3:	89 f8                	mov    %edi,%eax
f01019b5:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01019b8:	c1 f8 03             	sar    $0x3,%eax
f01019bb:	c1 e0 0c             	shl    $0xc,%eax
f01019be:	39 c2                	cmp    %eax,%edx
f01019c0:	74 24                	je     f01019e6 <mem_init+0x87a>
f01019c2:	c7 44 24 0c e4 4d 10 	movl   $0xf0104de4,0xc(%esp)
f01019c9:	f0 
f01019ca:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01019d1:	f0 
f01019d2:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f01019d9:	00 
f01019da:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01019e1:	e8 cb e6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019e6:	ba 00 00 00 00       	mov    $0x0,%edx
f01019eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019ee:	e8 15 ef ff ff       	call   f0100908 <check_va2pa>
f01019f3:	89 f2                	mov    %esi,%edx
f01019f5:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019f8:	c1 fa 03             	sar    $0x3,%edx
f01019fb:	c1 e2 0c             	shl    $0xc,%edx
f01019fe:	39 d0                	cmp    %edx,%eax
f0101a00:	74 24                	je     f0101a26 <mem_init+0x8ba>
f0101a02:	c7 44 24 0c 0c 4e 10 	movl   $0xf0104e0c,0xc(%esp)
f0101a09:	f0 
f0101a0a:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101a11:	f0 
f0101a12:	c7 44 24 04 60 03 00 	movl   $0x360,0x4(%esp)
f0101a19:	00 
f0101a1a:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101a21:	e8 8b e6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0101a26:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a2b:	74 24                	je     f0101a51 <mem_init+0x8e5>
f0101a2d:	c7 44 24 0c 4a 55 10 	movl   $0xf010554a,0xc(%esp)
f0101a34:	f0 
f0101a35:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101a3c:	f0 
f0101a3d:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101a44:	00 
f0101a45:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101a4c:	e8 60 e6 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0101a51:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a56:	74 24                	je     f0101a7c <mem_init+0x910>
f0101a58:	c7 44 24 0c 5b 55 10 	movl   $0xf010555b,0xc(%esp)
f0101a5f:	f0 
f0101a60:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101a67:	f0 
f0101a68:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f0101a6f:	00 
f0101a70:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101a77:	e8 35 e6 ff ff       	call   f01000b1 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a7c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a83:	00 
f0101a84:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a8b:	00 
f0101a8c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a90:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a93:	89 14 24             	mov    %edx,(%esp)
f0101a96:	e8 57 f6 ff ff       	call   f01010f2 <page_insert>
f0101a9b:	85 c0                	test   %eax,%eax
f0101a9d:	74 24                	je     f0101ac3 <mem_init+0x957>
f0101a9f:	c7 44 24 0c 3c 4e 10 	movl   $0xf0104e3c,0xc(%esp)
f0101aa6:	f0 
f0101aa7:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101aae:	f0 
f0101aaf:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f0101ab6:	00 
f0101ab7:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101abe:	e8 ee e5 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ac3:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ac8:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101acd:	e8 36 ee ff ff       	call   f0100908 <check_va2pa>
f0101ad2:	89 da                	mov    %ebx,%edx
f0101ad4:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f0101ada:	c1 fa 03             	sar    $0x3,%edx
f0101add:	c1 e2 0c             	shl    $0xc,%edx
f0101ae0:	39 d0                	cmp    %edx,%eax
f0101ae2:	74 24                	je     f0101b08 <mem_init+0x99c>
f0101ae4:	c7 44 24 0c 78 4e 10 	movl   $0xf0104e78,0xc(%esp)
f0101aeb:	f0 
f0101aec:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101af3:	f0 
f0101af4:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0101afb:	00 
f0101afc:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101b03:	e8 a9 e5 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0101b08:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b0d:	74 24                	je     f0101b33 <mem_init+0x9c7>
f0101b0f:	c7 44 24 0c 6c 55 10 	movl   $0xf010556c,0xc(%esp)
f0101b16:	f0 
f0101b17:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101b1e:	f0 
f0101b1f:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0101b26:	00 
f0101b27:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101b2e:	e8 7e e5 ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b33:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b3a:	e8 fb f2 ff ff       	call   f0100e3a <page_alloc>
f0101b3f:	85 c0                	test   %eax,%eax
f0101b41:	74 24                	je     f0101b67 <mem_init+0x9fb>
f0101b43:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f0101b4a:	f0 
f0101b4b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101b52:	f0 
f0101b53:	c7 44 24 04 6a 03 00 	movl   $0x36a,0x4(%esp)
f0101b5a:	00 
f0101b5b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101b62:	e8 4a e5 ff ff       	call   f01000b1 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b67:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b6e:	00 
f0101b6f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b76:	00 
f0101b77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b7b:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101b80:	89 04 24             	mov    %eax,(%esp)
f0101b83:	e8 6a f5 ff ff       	call   f01010f2 <page_insert>
f0101b88:	85 c0                	test   %eax,%eax
f0101b8a:	74 24                	je     f0101bb0 <mem_init+0xa44>
f0101b8c:	c7 44 24 0c 3c 4e 10 	movl   $0xf0104e3c,0xc(%esp)
f0101b93:	f0 
f0101b94:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101b9b:	f0 
f0101b9c:	c7 44 24 04 6d 03 00 	movl   $0x36d,0x4(%esp)
f0101ba3:	00 
f0101ba4:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101bab:	e8 01 e5 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bb0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bb5:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101bba:	e8 49 ed ff ff       	call   f0100908 <check_va2pa>
f0101bbf:	89 da                	mov    %ebx,%edx
f0101bc1:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f0101bc7:	c1 fa 03             	sar    $0x3,%edx
f0101bca:	c1 e2 0c             	shl    $0xc,%edx
f0101bcd:	39 d0                	cmp    %edx,%eax
f0101bcf:	74 24                	je     f0101bf5 <mem_init+0xa89>
f0101bd1:	c7 44 24 0c 78 4e 10 	movl   $0xf0104e78,0xc(%esp)
f0101bd8:	f0 
f0101bd9:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101be0:	f0 
f0101be1:	c7 44 24 04 6e 03 00 	movl   $0x36e,0x4(%esp)
f0101be8:	00 
f0101be9:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101bf0:	e8 bc e4 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0101bf5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bfa:	74 24                	je     f0101c20 <mem_init+0xab4>
f0101bfc:	c7 44 24 0c 6c 55 10 	movl   $0xf010556c,0xc(%esp)
f0101c03:	f0 
f0101c04:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101c0b:	f0 
f0101c0c:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101c13:	00 
f0101c14:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101c1b:	e8 91 e4 ff ff       	call   f01000b1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c27:	e8 0e f2 ff ff       	call   f0100e3a <page_alloc>
f0101c2c:	85 c0                	test   %eax,%eax
f0101c2e:	74 24                	je     f0101c54 <mem_init+0xae8>
f0101c30:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f0101c37:	f0 
f0101c38:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101c3f:	f0 
f0101c40:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f0101c47:	00 
f0101c48:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101c4f:	e8 5d e4 ff ff       	call   f01000b1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c54:	8b 15 4c 0e 1e f0    	mov    0xf01e0e4c,%edx
f0101c5a:	8b 02                	mov    (%edx),%eax
f0101c5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c61:	89 c1                	mov    %eax,%ecx
f0101c63:	c1 e9 0c             	shr    $0xc,%ecx
f0101c66:	3b 0d 48 0e 1e f0    	cmp    0xf01e0e48,%ecx
f0101c6c:	72 20                	jb     f0101c8e <mem_init+0xb22>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c6e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c72:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0101c79:	f0 
f0101c7a:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101c81:	00 
f0101c82:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101c89:	e8 23 e4 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0101c8e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c9d:	00 
f0101c9e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ca5:	00 
f0101ca6:	89 14 24             	mov    %edx,(%esp)
f0101ca9:	e8 70 f2 ff ff       	call   f0100f1e <pgdir_walk>
f0101cae:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101cb1:	83 c2 04             	add    $0x4,%edx
f0101cb4:	39 d0                	cmp    %edx,%eax
f0101cb6:	74 24                	je     f0101cdc <mem_init+0xb70>
f0101cb8:	c7 44 24 0c a8 4e 10 	movl   $0xf0104ea8,0xc(%esp)
f0101cbf:	f0 
f0101cc0:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101cc7:	f0 
f0101cc8:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101ccf:	00 
f0101cd0:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101cd7:	e8 d5 e3 ff ff       	call   f01000b1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cdc:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101ce3:	00 
f0101ce4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ceb:	00 
f0101cec:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cf0:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101cf5:	89 04 24             	mov    %eax,(%esp)
f0101cf8:	e8 f5 f3 ff ff       	call   f01010f2 <page_insert>
f0101cfd:	85 c0                	test   %eax,%eax
f0101cff:	74 24                	je     f0101d25 <mem_init+0xbb9>
f0101d01:	c7 44 24 0c e8 4e 10 	movl   $0xf0104ee8,0xc(%esp)
f0101d08:	f0 
f0101d09:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101d10:	f0 
f0101d11:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101d18:	00 
f0101d19:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101d20:	e8 8c e3 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d25:	8b 0d 4c 0e 1e f0    	mov    0xf01e0e4c,%ecx
f0101d2b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101d2e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d33:	89 c8                	mov    %ecx,%eax
f0101d35:	e8 ce eb ff ff       	call   f0100908 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d3a:	89 da                	mov    %ebx,%edx
f0101d3c:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f0101d42:	c1 fa 03             	sar    $0x3,%edx
f0101d45:	c1 e2 0c             	shl    $0xc,%edx
f0101d48:	39 d0                	cmp    %edx,%eax
f0101d4a:	74 24                	je     f0101d70 <mem_init+0xc04>
f0101d4c:	c7 44 24 0c 78 4e 10 	movl   $0xf0104e78,0xc(%esp)
f0101d53:	f0 
f0101d54:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101d5b:	f0 
f0101d5c:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101d63:	00 
f0101d64:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101d6b:	e8 41 e3 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0101d70:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d75:	74 24                	je     f0101d9b <mem_init+0xc2f>
f0101d77:	c7 44 24 0c 6c 55 10 	movl   $0xf010556c,0xc(%esp)
f0101d7e:	f0 
f0101d7f:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101d86:	f0 
f0101d87:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101d8e:	00 
f0101d8f:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101d96:	e8 16 e3 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d9b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101da2:	00 
f0101da3:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101daa:	00 
f0101dab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dae:	89 04 24             	mov    %eax,(%esp)
f0101db1:	e8 68 f1 ff ff       	call   f0100f1e <pgdir_walk>
f0101db6:	f6 00 04             	testb  $0x4,(%eax)
f0101db9:	75 24                	jne    f0101ddf <mem_init+0xc73>
f0101dbb:	c7 44 24 0c 28 4f 10 	movl   $0xf0104f28,0xc(%esp)
f0101dc2:	f0 
f0101dc3:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101dca:	f0 
f0101dcb:	c7 44 24 04 7d 03 00 	movl   $0x37d,0x4(%esp)
f0101dd2:	00 
f0101dd3:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101dda:	e8 d2 e2 ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101ddf:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101de4:	f6 00 04             	testb  $0x4,(%eax)
f0101de7:	75 24                	jne    f0101e0d <mem_init+0xca1>
f0101de9:	c7 44 24 0c 7d 55 10 	movl   $0xf010557d,0xc(%esp)
f0101df0:	f0 
f0101df1:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101df8:	f0 
f0101df9:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f0101e00:	00 
f0101e01:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101e08:	e8 a4 e2 ff ff       	call   f01000b1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e0d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e14:	00 
f0101e15:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e1c:	00 
f0101e1d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e21:	89 04 24             	mov    %eax,(%esp)
f0101e24:	e8 c9 f2 ff ff       	call   f01010f2 <page_insert>
f0101e29:	85 c0                	test   %eax,%eax
f0101e2b:	74 24                	je     f0101e51 <mem_init+0xce5>
f0101e2d:	c7 44 24 0c 3c 4e 10 	movl   $0xf0104e3c,0xc(%esp)
f0101e34:	f0 
f0101e35:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101e3c:	f0 
f0101e3d:	c7 44 24 04 81 03 00 	movl   $0x381,0x4(%esp)
f0101e44:	00 
f0101e45:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101e4c:	e8 60 e2 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e51:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e58:	00 
f0101e59:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e60:	00 
f0101e61:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101e66:	89 04 24             	mov    %eax,(%esp)
f0101e69:	e8 b0 f0 ff ff       	call   f0100f1e <pgdir_walk>
f0101e6e:	f6 00 02             	testb  $0x2,(%eax)
f0101e71:	75 24                	jne    f0101e97 <mem_init+0xd2b>
f0101e73:	c7 44 24 0c 5c 4f 10 	movl   $0xf0104f5c,0xc(%esp)
f0101e7a:	f0 
f0101e7b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101e82:	f0 
f0101e83:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101e8a:	00 
f0101e8b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101e92:	e8 1a e2 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e9e:	00 
f0101e9f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ea6:	00 
f0101ea7:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101eac:	89 04 24             	mov    %eax,(%esp)
f0101eaf:	e8 6a f0 ff ff       	call   f0100f1e <pgdir_walk>
f0101eb4:	f6 00 04             	testb  $0x4,(%eax)
f0101eb7:	74 24                	je     f0101edd <mem_init+0xd71>
f0101eb9:	c7 44 24 0c 90 4f 10 	movl   $0xf0104f90,0xc(%esp)
f0101ec0:	f0 
f0101ec1:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101ec8:	f0 
f0101ec9:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0101ed0:	00 
f0101ed1:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101ed8:	e8 d4 e1 ff ff       	call   f01000b1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101edd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ee4:	00 
f0101ee5:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101eec:	00 
f0101eed:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ef1:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101ef6:	89 04 24             	mov    %eax,(%esp)
f0101ef9:	e8 f4 f1 ff ff       	call   f01010f2 <page_insert>
f0101efe:	85 c0                	test   %eax,%eax
f0101f00:	78 24                	js     f0101f26 <mem_init+0xdba>
f0101f02:	c7 44 24 0c c8 4f 10 	movl   $0xf0104fc8,0xc(%esp)
f0101f09:	f0 
f0101f0a:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101f11:	f0 
f0101f12:	c7 44 24 04 86 03 00 	movl   $0x386,0x4(%esp)
f0101f19:	00 
f0101f1a:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101f21:	e8 8b e1 ff ff       	call   f01000b1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f26:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f2d:	00 
f0101f2e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f35:	00 
f0101f36:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f3a:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101f3f:	89 04 24             	mov    %eax,(%esp)
f0101f42:	e8 ab f1 ff ff       	call   f01010f2 <page_insert>
f0101f47:	85 c0                	test   %eax,%eax
f0101f49:	74 24                	je     f0101f6f <mem_init+0xe03>
f0101f4b:	c7 44 24 0c 00 50 10 	movl   $0xf0105000,0xc(%esp)
f0101f52:	f0 
f0101f53:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101f5a:	f0 
f0101f5b:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f0101f62:	00 
f0101f63:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101f6a:	e8 42 e1 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f6f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f76:	00 
f0101f77:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f7e:	00 
f0101f7f:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101f84:	89 04 24             	mov    %eax,(%esp)
f0101f87:	e8 92 ef ff ff       	call   f0100f1e <pgdir_walk>
f0101f8c:	f6 00 04             	testb  $0x4,(%eax)
f0101f8f:	74 24                	je     f0101fb5 <mem_init+0xe49>
f0101f91:	c7 44 24 0c 90 4f 10 	movl   $0xf0104f90,0xc(%esp)
f0101f98:	f0 
f0101f99:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101fa0:	f0 
f0101fa1:	c7 44 24 04 8a 03 00 	movl   $0x38a,0x4(%esp)
f0101fa8:	00 
f0101fa9:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101fb0:	e8 fc e0 ff ff       	call   f01000b1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fb5:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0101fba:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fbd:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fc2:	e8 41 e9 ff ff       	call   f0100908 <check_va2pa>
f0101fc7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fca:	89 f0                	mov    %esi,%eax
f0101fcc:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0101fd2:	c1 f8 03             	sar    $0x3,%eax
f0101fd5:	c1 e0 0c             	shl    $0xc,%eax
f0101fd8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fdb:	74 24                	je     f0102001 <mem_init+0xe95>
f0101fdd:	c7 44 24 0c 3c 50 10 	movl   $0xf010503c,0xc(%esp)
f0101fe4:	f0 
f0101fe5:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0101fec:	f0 
f0101fed:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0101ff4:	00 
f0101ff5:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0101ffc:	e8 b0 e0 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102001:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102006:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102009:	e8 fa e8 ff ff       	call   f0100908 <check_va2pa>
f010200e:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102011:	74 24                	je     f0102037 <mem_init+0xecb>
f0102013:	c7 44 24 0c 68 50 10 	movl   $0xf0105068,0xc(%esp)
f010201a:	f0 
f010201b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102022:	f0 
f0102023:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f010202a:	00 
f010202b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102032:	e8 7a e0 ff ff       	call   f01000b1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102037:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010203c:	74 24                	je     f0102062 <mem_init+0xef6>
f010203e:	c7 44 24 0c 93 55 10 	movl   $0xf0105593,0xc(%esp)
f0102045:	f0 
f0102046:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010204d:	f0 
f010204e:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0102055:	00 
f0102056:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010205d:	e8 4f e0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102062:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102067:	74 24                	je     f010208d <mem_init+0xf21>
f0102069:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f0102070:	f0 
f0102071:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102078:	f0 
f0102079:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0102080:	00 
f0102081:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102088:	e8 24 e0 ff ff       	call   f01000b1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010208d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102094:	e8 a1 ed ff ff       	call   f0100e3a <page_alloc>
f0102099:	85 c0                	test   %eax,%eax
f010209b:	74 04                	je     f01020a1 <mem_init+0xf35>
f010209d:	39 c3                	cmp    %eax,%ebx
f010209f:	74 24                	je     f01020c5 <mem_init+0xf59>
f01020a1:	c7 44 24 0c 98 50 10 	movl   $0xf0105098,0xc(%esp)
f01020a8:	f0 
f01020a9:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01020b0:	f0 
f01020b1:	c7 44 24 04 94 03 00 	movl   $0x394,0x4(%esp)
f01020b8:	00 
f01020b9:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01020c0:	e8 ec df ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020c5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020cc:	00 
f01020cd:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f01020d2:	89 04 24             	mov    %eax,(%esp)
f01020d5:	e8 cf ef ff ff       	call   f01010a9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020da:	8b 15 4c 0e 1e f0    	mov    0xf01e0e4c,%edx
f01020e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01020e3:	ba 00 00 00 00       	mov    $0x0,%edx
f01020e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020eb:	e8 18 e8 ff ff       	call   f0100908 <check_va2pa>
f01020f0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020f3:	74 24                	je     f0102119 <mem_init+0xfad>
f01020f5:	c7 44 24 0c bc 50 10 	movl   $0xf01050bc,0xc(%esp)
f01020fc:	f0 
f01020fd:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102104:	f0 
f0102105:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f010210c:	00 
f010210d:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102114:	e8 98 df ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102119:	ba 00 10 00 00       	mov    $0x1000,%edx
f010211e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102121:	e8 e2 e7 ff ff       	call   f0100908 <check_va2pa>
f0102126:	89 f2                	mov    %esi,%edx
f0102128:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f010212e:	c1 fa 03             	sar    $0x3,%edx
f0102131:	c1 e2 0c             	shl    $0xc,%edx
f0102134:	39 d0                	cmp    %edx,%eax
f0102136:	74 24                	je     f010215c <mem_init+0xff0>
f0102138:	c7 44 24 0c 68 50 10 	movl   $0xf0105068,0xc(%esp)
f010213f:	f0 
f0102140:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102147:	f0 
f0102148:	c7 44 24 04 99 03 00 	movl   $0x399,0x4(%esp)
f010214f:	00 
f0102150:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102157:	e8 55 df ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f010215c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102161:	74 24                	je     f0102187 <mem_init+0x101b>
f0102163:	c7 44 24 0c 4a 55 10 	movl   $0xf010554a,0xc(%esp)
f010216a:	f0 
f010216b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102172:	f0 
f0102173:	c7 44 24 04 9a 03 00 	movl   $0x39a,0x4(%esp)
f010217a:	00 
f010217b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102182:	e8 2a df ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102187:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010218c:	74 24                	je     f01021b2 <mem_init+0x1046>
f010218e:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f0102195:	f0 
f0102196:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010219d:	f0 
f010219e:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f01021a5:	00 
f01021a6:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01021ad:	e8 ff de ff ff       	call   f01000b1 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021b2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021b9:	00 
f01021ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021c1:	00 
f01021c2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021c6:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01021c9:	89 0c 24             	mov    %ecx,(%esp)
f01021cc:	e8 21 ef ff ff       	call   f01010f2 <page_insert>
f01021d1:	85 c0                	test   %eax,%eax
f01021d3:	74 24                	je     f01021f9 <mem_init+0x108d>
f01021d5:	c7 44 24 0c e0 50 10 	movl   $0xf01050e0,0xc(%esp)
f01021dc:	f0 
f01021dd:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01021e4:	f0 
f01021e5:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01021ec:	00 
f01021ed:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01021f4:	e8 b8 de ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f01021f9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021fe:	75 24                	jne    f0102224 <mem_init+0x10b8>
f0102200:	c7 44 24 0c b5 55 10 	movl   $0xf01055b5,0xc(%esp)
f0102207:	f0 
f0102208:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010220f:	f0 
f0102210:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102217:	00 
f0102218:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010221f:	e8 8d de ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f0102224:	83 3e 00             	cmpl   $0x0,(%esi)
f0102227:	74 24                	je     f010224d <mem_init+0x10e1>
f0102229:	c7 44 24 0c c1 55 10 	movl   $0xf01055c1,0xc(%esp)
f0102230:	f0 
f0102231:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102238:	f0 
f0102239:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102240:	00 
f0102241:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102248:	e8 64 de ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010224d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102254:	00 
f0102255:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f010225a:	89 04 24             	mov    %eax,(%esp)
f010225d:	e8 47 ee ff ff       	call   f01010a9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102262:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102267:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010226a:	ba 00 00 00 00       	mov    $0x0,%edx
f010226f:	e8 94 e6 ff ff       	call   f0100908 <check_va2pa>
f0102274:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102277:	74 24                	je     f010229d <mem_init+0x1131>
f0102279:	c7 44 24 0c bc 50 10 	movl   $0xf01050bc,0xc(%esp)
f0102280:	f0 
f0102281:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102288:	f0 
f0102289:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102290:	00 
f0102291:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102298:	e8 14 de ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010229d:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022a5:	e8 5e e6 ff ff       	call   f0100908 <check_va2pa>
f01022aa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022ad:	74 24                	je     f01022d3 <mem_init+0x1167>
f01022af:	c7 44 24 0c 18 51 10 	movl   $0xf0105118,0xc(%esp)
f01022b6:	f0 
f01022b7:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01022be:	f0 
f01022bf:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f01022c6:	00 
f01022c7:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01022ce:	e8 de dd ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01022d3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022d8:	74 24                	je     f01022fe <mem_init+0x1192>
f01022da:	c7 44 24 0c d6 55 10 	movl   $0xf01055d6,0xc(%esp)
f01022e1:	f0 
f01022e2:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01022e9:	f0 
f01022ea:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f01022f1:	00 
f01022f2:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01022f9:	e8 b3 dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01022fe:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102303:	74 24                	je     f0102329 <mem_init+0x11bd>
f0102305:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f010230c:	f0 
f010230d:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102314:	f0 
f0102315:	c7 44 24 04 a7 03 00 	movl   $0x3a7,0x4(%esp)
f010231c:	00 
f010231d:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102324:	e8 88 dd ff ff       	call   f01000b1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102329:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102330:	e8 05 eb ff ff       	call   f0100e3a <page_alloc>
f0102335:	85 c0                	test   %eax,%eax
f0102337:	74 04                	je     f010233d <mem_init+0x11d1>
f0102339:	39 c6                	cmp    %eax,%esi
f010233b:	74 24                	je     f0102361 <mem_init+0x11f5>
f010233d:	c7 44 24 0c 40 51 10 	movl   $0xf0105140,0xc(%esp)
f0102344:	f0 
f0102345:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010234c:	f0 
f010234d:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102354:	00 
f0102355:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010235c:	e8 50 dd ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102361:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102368:	e8 cd ea ff ff       	call   f0100e3a <page_alloc>
f010236d:	85 c0                	test   %eax,%eax
f010236f:	74 24                	je     f0102395 <mem_init+0x1229>
f0102371:	c7 44 24 0c f8 54 10 	movl   $0xf01054f8,0xc(%esp)
f0102378:	f0 
f0102379:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102380:	f0 
f0102381:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0102388:	00 
f0102389:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102390:	e8 1c dd ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102395:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f010239a:	8b 08                	mov    (%eax),%ecx
f010239c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01023a2:	89 fa                	mov    %edi,%edx
f01023a4:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f01023aa:	c1 fa 03             	sar    $0x3,%edx
f01023ad:	c1 e2 0c             	shl    $0xc,%edx
f01023b0:	39 d1                	cmp    %edx,%ecx
f01023b2:	74 24                	je     f01023d8 <mem_init+0x126c>
f01023b4:	c7 44 24 0c e4 4d 10 	movl   $0xf0104de4,0xc(%esp)
f01023bb:	f0 
f01023bc:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01023c3:	f0 
f01023c4:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f01023cb:	00 
f01023cc:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01023d3:	e8 d9 dc ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f01023d8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023de:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023e3:	74 24                	je     f0102409 <mem_init+0x129d>
f01023e5:	c7 44 24 0c 5b 55 10 	movl   $0xf010555b,0xc(%esp)
f01023ec:	f0 
f01023ed:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01023f4:	f0 
f01023f5:	c7 44 24 04 b2 03 00 	movl   $0x3b2,0x4(%esp)
f01023fc:	00 
f01023fd:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102404:	e8 a8 dc ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0102409:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f010240f:	89 3c 24             	mov    %edi,(%esp)
f0102412:	e8 a7 ea ff ff       	call   f0100ebe <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102417:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010241e:	00 
f010241f:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102426:	00 
f0102427:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f010242c:	89 04 24             	mov    %eax,(%esp)
f010242f:	e8 ea ea ff ff       	call   f0100f1e <pgdir_walk>
f0102434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102437:	8b 0d 4c 0e 1e f0    	mov    0xf01e0e4c,%ecx
f010243d:	8b 51 04             	mov    0x4(%ecx),%edx
f0102440:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102446:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102449:	8b 15 48 0e 1e f0    	mov    0xf01e0e48,%edx
f010244f:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102452:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102455:	c1 ea 0c             	shr    $0xc,%edx
f0102458:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010245b:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010245e:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102461:	72 23                	jb     f0102486 <mem_init+0x131a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102463:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102466:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010246a:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0102471:	f0 
f0102472:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0102479:	00 
f010247a:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102481:	e8 2b dc ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102486:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102489:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010248f:	39 d0                	cmp    %edx,%eax
f0102491:	74 24                	je     f01024b7 <mem_init+0x134b>
f0102493:	c7 44 24 0c e7 55 10 	movl   $0xf01055e7,0xc(%esp)
f010249a:	f0 
f010249b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01024a2:	f0 
f01024a3:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f01024aa:	00 
f01024ab:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01024b2:	e8 fa db ff ff       	call   f01000b1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024b7:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024be:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024c4:	89 f8                	mov    %edi,%eax
f01024c6:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f01024cc:	c1 f8 03             	sar    $0x3,%eax
f01024cf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024d2:	89 c1                	mov    %eax,%ecx
f01024d4:	c1 e9 0c             	shr    $0xc,%ecx
f01024d7:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01024da:	77 20                	ja     f01024fc <mem_init+0x1390>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024dc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024e0:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f01024e7:	f0 
f01024e8:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01024ef:	00 
f01024f0:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f01024f7:	e8 b5 db ff ff       	call   f01000b1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024fc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102503:	00 
f0102504:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f010250b:	00 
	return (void *)(pa + KERNBASE);
f010250c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102511:	89 04 24             	mov    %eax,(%esp)
f0102514:	e8 b9 1c 00 00       	call   f01041d2 <memset>
	page_free(pp0);
f0102519:	89 3c 24             	mov    %edi,(%esp)
f010251c:	e8 9d e9 ff ff       	call   f0100ebe <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102521:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102528:	00 
f0102529:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102530:	00 
f0102531:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102536:	89 04 24             	mov    %eax,(%esp)
f0102539:	e8 e0 e9 ff ff       	call   f0100f1e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010253e:	89 fa                	mov    %edi,%edx
f0102540:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f0102546:	c1 fa 03             	sar    $0x3,%edx
f0102549:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010254c:	89 d0                	mov    %edx,%eax
f010254e:	c1 e8 0c             	shr    $0xc,%eax
f0102551:	3b 05 48 0e 1e f0    	cmp    0xf01e0e48,%eax
f0102557:	72 20                	jb     f0102579 <mem_init+0x140d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102559:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010255d:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0102564:	f0 
f0102565:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010256c:	00 
f010256d:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f0102574:	e8 38 db ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0102579:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010257f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102582:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102588:	f6 00 01             	testb  $0x1,(%eax)
f010258b:	74 24                	je     f01025b1 <mem_init+0x1445>
f010258d:	c7 44 24 0c ff 55 10 	movl   $0xf01055ff,0xc(%esp)
f0102594:	f0 
f0102595:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010259c:	f0 
f010259d:	c7 44 24 04 c4 03 00 	movl   $0x3c4,0x4(%esp)
f01025a4:	00 
f01025a5:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01025ac:	e8 00 db ff ff       	call   f01000b1 <_panic>
f01025b1:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025b4:	39 d0                	cmp    %edx,%eax
f01025b6:	75 d0                	jne    f0102588 <mem_init+0x141c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025b8:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f01025bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025c3:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01025c9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01025cc:	89 0d a0 01 1e f0    	mov    %ecx,0xf01e01a0

	// free the pages we took
	page_free(pp0);
f01025d2:	89 3c 24             	mov    %edi,(%esp)
f01025d5:	e8 e4 e8 ff ff       	call   f0100ebe <page_free>
	page_free(pp1);
f01025da:	89 34 24             	mov    %esi,(%esp)
f01025dd:	e8 dc e8 ff ff       	call   f0100ebe <page_free>
	page_free(pp2);
f01025e2:	89 1c 24             	mov    %ebx,(%esp)
f01025e5:	e8 d4 e8 ff ff       	call   f0100ebe <page_free>

	cprintf("check_page() succeeded!\n");
f01025ea:	c7 04 24 16 56 10 f0 	movl   $0xf0105616,(%esp)
f01025f1:	e8 d0 0c 00 00       	call   f01032c6 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_W);
f01025f6:	a1 50 0e 1e f0       	mov    0xf01e0e50,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025fb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102600:	77 20                	ja     f0102622 <mem_init+0x14b6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102602:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102606:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f010260d:	f0 
f010260e:	c7 44 24 04 be 00 00 	movl   $0xbe,0x4(%esp)
f0102615:	00 
f0102616:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010261d:	e8 8f da ff ff       	call   f01000b1 <_panic>
f0102622:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102629:	00 
	return (physaddr_t)kva - KERNBASE;
f010262a:	05 00 00 00 10       	add    $0x10000000,%eax
f010262f:	89 04 24             	mov    %eax,(%esp)
f0102632:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102637:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010263c:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102641:	e8 77 e9 ff ff       	call   f0100fbd <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102646:	b8 00 80 11 f0       	mov    $0xf0118000,%eax
f010264b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102650:	77 20                	ja     f0102672 <mem_init+0x1506>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102652:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102656:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f010265d:	f0 
f010265e:	c7 44 24 04 d3 00 00 	movl   $0xd3,0x4(%esp)
f0102665:	00 
f0102666:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010266d:	e8 3f da ff ff       	call   f01000b1 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102672:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102679:	00 
f010267a:	c7 04 24 00 80 11 00 	movl   $0x118000,(%esp)
f0102681:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102686:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010268b:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102690:	e8 28 e9 ff ff       	call   f0100fbd <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 2*npages*PGSIZE, 0, PTE_W);
f0102695:	8b 0d 48 0e 1e f0    	mov    0xf01e0e48,%ecx
f010269b:	c1 e1 0d             	shl    $0xd,%ecx
f010269e:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01026a5:	00 
f01026a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01026ad:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01026b2:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f01026b7:	e8 01 e9 ff ff       	call   f0100fbd <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01026bc:	8b 1d 4c 0e 1e f0    	mov    0xf01e0e4c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01026c2:	8b 15 48 0e 1e f0    	mov    0xf01e0e48,%edx
f01026c8:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01026cb:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
f01026d2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f01026d8:	be 00 00 00 00       	mov    $0x0,%esi
f01026dd:	eb 70                	jmp    f010274f <mem_init+0x15e3>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01026df:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026e5:	89 d8                	mov    %ebx,%eax
f01026e7:	e8 1c e2 ff ff       	call   f0100908 <check_va2pa>
f01026ec:	8b 15 50 0e 1e f0    	mov    0xf01e0e50,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026f2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026f8:	77 20                	ja     f010271a <mem_init+0x15ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026fa:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01026fe:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f0102705:	f0 
f0102706:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f010270d:	00 
f010270e:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102715:	e8 97 d9 ff ff       	call   f01000b1 <_panic>
f010271a:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102721:	39 d0                	cmp    %edx,%eax
f0102723:	74 24                	je     f0102749 <mem_init+0x15dd>
f0102725:	c7 44 24 0c 64 51 10 	movl   $0xf0105164,0xc(%esp)
f010272c:	f0 
f010272d:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102734:	f0 
f0102735:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f010273c:	00 
f010273d:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102744:	e8 68 d9 ff ff       	call   f01000b1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102749:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010274f:	39 f7                	cmp    %esi,%edi
f0102751:	77 8c                	ja     f01026df <mem_init+0x1573>
f0102753:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102758:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010275e:	89 d8                	mov    %ebx,%eax
f0102760:	e8 a3 e1 ff ff       	call   f0100908 <check_va2pa>
f0102765:	8b 15 a8 01 1e f0    	mov    0xf01e01a8,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010276b:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102771:	77 20                	ja     f0102793 <mem_init+0x1627>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102773:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102777:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f010277e:	f0 
f010277f:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0102786:	00 
f0102787:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010278e:	e8 1e d9 ff ff       	call   f01000b1 <_panic>
f0102793:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010279a:	39 d0                	cmp    %edx,%eax
f010279c:	74 24                	je     f01027c2 <mem_init+0x1656>
f010279e:	c7 44 24 0c 98 51 10 	movl   $0xf0105198,0xc(%esp)
f01027a5:	f0 
f01027a6:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01027ad:	f0 
f01027ae:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f01027b5:	00 
f01027b6:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01027bd:	e8 ef d8 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027c2:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027c8:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f01027ce:	75 88                	jne    f0102758 <mem_init+0x15ec>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01027d0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01027d3:	c1 e7 0c             	shl    $0xc,%edi
f01027d6:	be 00 00 00 00       	mov    $0x0,%esi
f01027db:	eb 3b                	jmp    f0102818 <mem_init+0x16ac>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027dd:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01027e3:	89 d8                	mov    %ebx,%eax
f01027e5:	e8 1e e1 ff ff       	call   f0100908 <check_va2pa>
f01027ea:	39 c6                	cmp    %eax,%esi
f01027ec:	74 24                	je     f0102812 <mem_init+0x16a6>
f01027ee:	c7 44 24 0c cc 51 10 	movl   $0xf01051cc,0xc(%esp)
f01027f5:	f0 
f01027f6:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01027fd:	f0 
f01027fe:	c7 44 24 04 0a 03 00 	movl   $0x30a,0x4(%esp)
f0102805:	00 
f0102806:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010280d:	e8 9f d8 ff ff       	call   f01000b1 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102812:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102818:	39 fe                	cmp    %edi,%esi
f010281a:	72 c1                	jb     f01027dd <mem_init+0x1671>
f010281c:	be 00 80 ff ef       	mov    $0xefff8000,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102821:	bf 00 80 11 f0       	mov    $0xf0118000,%edi
f0102826:	81 c7 00 80 00 20    	add    $0x20008000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010282c:	89 f2                	mov    %esi,%edx
f010282e:	89 d8                	mov    %ebx,%eax
f0102830:	e8 d3 e0 ff ff       	call   f0100908 <check_va2pa>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102835:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102838:	39 d0                	cmp    %edx,%eax
f010283a:	74 24                	je     f0102860 <mem_init+0x16f4>
f010283c:	c7 44 24 0c f4 51 10 	movl   $0xf01051f4,0xc(%esp)
f0102843:	f0 
f0102844:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010284b:	f0 
f010284c:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f0102853:	00 
f0102854:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010285b:	e8 51 d8 ff ff       	call   f01000b1 <_panic>
f0102860:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102866:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010286c:	75 be                	jne    f010282c <mem_init+0x16c0>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010286e:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102873:	89 d8                	mov    %ebx,%eax
f0102875:	e8 8e e0 ff ff       	call   f0100908 <check_va2pa>
f010287a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010287d:	74 24                	je     f01028a3 <mem_init+0x1737>
f010287f:	c7 44 24 0c 3c 52 10 	movl   $0xf010523c,0xc(%esp)
f0102886:	f0 
f0102887:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010288e:	f0 
f010288f:	c7 44 24 04 0f 03 00 	movl   $0x30f,0x4(%esp)
f0102896:	00 
f0102897:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010289e:	e8 0e d8 ff ff       	call   f01000b1 <_panic>
f01028a3:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01028a8:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f01028ad:	72 3c                	jb     f01028eb <mem_init+0x177f>
f01028af:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01028b4:	76 07                	jbe    f01028bd <mem_init+0x1751>
f01028b6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028bb:	75 2e                	jne    f01028eb <mem_init+0x177f>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01028bd:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01028c1:	0f 85 aa 00 00 00    	jne    f0102971 <mem_init+0x1805>
f01028c7:	c7 44 24 0c 2f 56 10 	movl   $0xf010562f,0xc(%esp)
f01028ce:	f0 
f01028cf:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01028d6:	f0 
f01028d7:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f01028de:	00 
f01028df:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01028e6:	e8 c6 d7 ff ff       	call   f01000b1 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01028eb:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01028f0:	76 55                	jbe    f0102947 <mem_init+0x17db>
				assert(pgdir[i] & PTE_P);
f01028f2:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01028f5:	f6 c2 01             	test   $0x1,%dl
f01028f8:	75 24                	jne    f010291e <mem_init+0x17b2>
f01028fa:	c7 44 24 0c 2f 56 10 	movl   $0xf010562f,0xc(%esp)
f0102901:	f0 
f0102902:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102909:	f0 
f010290a:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0102911:	00 
f0102912:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102919:	e8 93 d7 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_W);
f010291e:	f6 c2 02             	test   $0x2,%dl
f0102921:	75 4e                	jne    f0102971 <mem_init+0x1805>
f0102923:	c7 44 24 0c 40 56 10 	movl   $0xf0105640,0xc(%esp)
f010292a:	f0 
f010292b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102932:	f0 
f0102933:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f010293a:	00 
f010293b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102942:	e8 6a d7 ff ff       	call   f01000b1 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102947:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010294b:	74 24                	je     f0102971 <mem_init+0x1805>
f010294d:	c7 44 24 0c 51 56 10 	movl   $0xf0105651,0xc(%esp)
f0102954:	f0 
f0102955:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f010295c:	f0 
f010295d:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0102964:	00 
f0102965:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f010296c:	e8 40 d7 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102971:	40                   	inc    %eax
f0102972:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102977:	0f 85 2b ff ff ff    	jne    f01028a8 <mem_init+0x173c>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010297d:	c7 04 24 6c 52 10 f0 	movl   $0xf010526c,(%esp)
f0102984:	e8 3d 09 00 00       	call   f01032c6 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102989:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010298e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102993:	77 20                	ja     f01029b5 <mem_init+0x1849>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102995:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102999:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f01029a0:	f0 
f01029a1:	c7 44 24 04 e9 00 00 	movl   $0xe9,0x4(%esp)
f01029a8:	00 
f01029a9:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f01029b0:	e8 fc d6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01029b5:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01029ba:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01029bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01029c2:	e8 a0 e0 ff ff       	call   f0100a67 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01029c7:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f01029ca:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f01029cf:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01029d2:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01029d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01029dc:	e8 59 e4 ff ff       	call   f0100e3a <page_alloc>
f01029e1:	89 c6                	mov    %eax,%esi
f01029e3:	85 c0                	test   %eax,%eax
f01029e5:	75 24                	jne    f0102a0b <mem_init+0x189f>
f01029e7:	c7 44 24 0c 4d 54 10 	movl   $0xf010544d,0xc(%esp)
f01029ee:	f0 
f01029ef:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01029f6:	f0 
f01029f7:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01029fe:	00 
f01029ff:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102a06:	e8 a6 d6 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a12:	e8 23 e4 ff ff       	call   f0100e3a <page_alloc>
f0102a17:	89 c7                	mov    %eax,%edi
f0102a19:	85 c0                	test   %eax,%eax
f0102a1b:	75 24                	jne    f0102a41 <mem_init+0x18d5>
f0102a1d:	c7 44 24 0c 63 54 10 	movl   $0xf0105463,0xc(%esp)
f0102a24:	f0 
f0102a25:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102a2c:	f0 
f0102a2d:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f0102a34:	00 
f0102a35:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102a3c:	e8 70 d6 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102a41:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a48:	e8 ed e3 ff ff       	call   f0100e3a <page_alloc>
f0102a4d:	89 c3                	mov    %eax,%ebx
f0102a4f:	85 c0                	test   %eax,%eax
f0102a51:	75 24                	jne    f0102a77 <mem_init+0x190b>
f0102a53:	c7 44 24 0c 79 54 10 	movl   $0xf0105479,0xc(%esp)
f0102a5a:	f0 
f0102a5b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102a62:	f0 
f0102a63:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102a6a:	00 
f0102a6b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102a72:	e8 3a d6 ff ff       	call   f01000b1 <_panic>
	page_free(pp0);
f0102a77:	89 34 24             	mov    %esi,(%esp)
f0102a7a:	e8 3f e4 ff ff       	call   f0100ebe <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a7f:	89 f8                	mov    %edi,%eax
f0102a81:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0102a87:	c1 f8 03             	sar    $0x3,%eax
f0102a8a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a8d:	89 c2                	mov    %eax,%edx
f0102a8f:	c1 ea 0c             	shr    $0xc,%edx
f0102a92:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0102a98:	72 20                	jb     f0102aba <mem_init+0x194e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a9a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a9e:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0102aa5:	f0 
f0102aa6:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102aad:	00 
f0102aae:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f0102ab5:	e8 f7 d5 ff ff       	call   f01000b1 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102aba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102ac1:	00 
f0102ac2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102ac9:	00 
	return (void *)(pa + KERNBASE);
f0102aca:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102acf:	89 04 24             	mov    %eax,(%esp)
f0102ad2:	e8 fb 16 00 00       	call   f01041d2 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ad7:	89 d8                	mov    %ebx,%eax
f0102ad9:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0102adf:	c1 f8 03             	sar    $0x3,%eax
f0102ae2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ae5:	89 c2                	mov    %eax,%edx
f0102ae7:	c1 ea 0c             	shr    $0xc,%edx
f0102aea:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0102af0:	72 20                	jb     f0102b12 <mem_init+0x19a6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102af2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102af6:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0102afd:	f0 
f0102afe:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102b05:	00 
f0102b06:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f0102b0d:	e8 9f d5 ff ff       	call   f01000b1 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b12:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b19:	00 
f0102b1a:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b21:	00 
	return (void *)(pa + KERNBASE);
f0102b22:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b27:	89 04 24             	mov    %eax,(%esp)
f0102b2a:	e8 a3 16 00 00       	call   f01041d2 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102b2f:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b36:	00 
f0102b37:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b3e:	00 
f0102b3f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102b43:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102b48:	89 04 24             	mov    %eax,(%esp)
f0102b4b:	e8 a2 e5 ff ff       	call   f01010f2 <page_insert>
	assert(pp1->pp_ref == 1);
f0102b50:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102b55:	74 24                	je     f0102b7b <mem_init+0x1a0f>
f0102b57:	c7 44 24 0c 4a 55 10 	movl   $0xf010554a,0xc(%esp)
f0102b5e:	f0 
f0102b5f:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102b66:	f0 
f0102b67:	c7 44 24 04 e6 03 00 	movl   $0x3e6,0x4(%esp)
f0102b6e:	00 
f0102b6f:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102b76:	e8 36 d5 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102b7b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102b82:	01 01 01 
f0102b85:	74 24                	je     f0102bab <mem_init+0x1a3f>
f0102b87:	c7 44 24 0c 8c 52 10 	movl   $0xf010528c,0xc(%esp)
f0102b8e:	f0 
f0102b8f:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102b96:	f0 
f0102b97:	c7 44 24 04 e7 03 00 	movl   $0x3e7,0x4(%esp)
f0102b9e:	00 
f0102b9f:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102ba6:	e8 06 d5 ff ff       	call   f01000b1 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102bab:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102bb2:	00 
f0102bb3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bba:	00 
f0102bbb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102bbf:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102bc4:	89 04 24             	mov    %eax,(%esp)
f0102bc7:	e8 26 e5 ff ff       	call   f01010f2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102bcc:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102bd3:	02 02 02 
f0102bd6:	74 24                	je     f0102bfc <mem_init+0x1a90>
f0102bd8:	c7 44 24 0c b0 52 10 	movl   $0xf01052b0,0xc(%esp)
f0102bdf:	f0 
f0102be0:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102be7:	f0 
f0102be8:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f0102bef:	00 
f0102bf0:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102bf7:	e8 b5 d4 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102bfc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c01:	74 24                	je     f0102c27 <mem_init+0x1abb>
f0102c03:	c7 44 24 0c 6c 55 10 	movl   $0xf010556c,0xc(%esp)
f0102c0a:	f0 
f0102c0b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102c12:	f0 
f0102c13:	c7 44 24 04 ea 03 00 	movl   $0x3ea,0x4(%esp)
f0102c1a:	00 
f0102c1b:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102c22:	e8 8a d4 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102c27:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c2c:	74 24                	je     f0102c52 <mem_init+0x1ae6>
f0102c2e:	c7 44 24 0c d6 55 10 	movl   $0xf01055d6,0xc(%esp)
f0102c35:	f0 
f0102c36:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102c3d:	f0 
f0102c3e:	c7 44 24 04 eb 03 00 	movl   $0x3eb,0x4(%esp)
f0102c45:	00 
f0102c46:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102c4d:	e8 5f d4 ff ff       	call   f01000b1 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c52:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c59:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c5c:	89 d8                	mov    %ebx,%eax
f0102c5e:	2b 05 50 0e 1e f0    	sub    0xf01e0e50,%eax
f0102c64:	c1 f8 03             	sar    $0x3,%eax
f0102c67:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c6a:	89 c2                	mov    %eax,%edx
f0102c6c:	c1 ea 0c             	shr    $0xc,%edx
f0102c6f:	3b 15 48 0e 1e f0    	cmp    0xf01e0e48,%edx
f0102c75:	72 20                	jb     f0102c97 <mem_init+0x1b2b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c77:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c7b:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f0102c82:	f0 
f0102c83:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102c8a:	00 
f0102c8b:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f0102c92:	e8 1a d4 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102c97:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102c9e:	03 03 03 
f0102ca1:	74 24                	je     f0102cc7 <mem_init+0x1b5b>
f0102ca3:	c7 44 24 0c d4 52 10 	movl   $0xf01052d4,0xc(%esp)
f0102caa:	f0 
f0102cab:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102cb2:	f0 
f0102cb3:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102cba:	00 
f0102cbb:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102cc2:	e8 ea d3 ff ff       	call   f01000b1 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102cc7:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102cce:	00 
f0102ccf:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102cd4:	89 04 24             	mov    %eax,(%esp)
f0102cd7:	e8 cd e3 ff ff       	call   f01010a9 <page_remove>
	assert(pp2->pp_ref == 0);
f0102cdc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102ce1:	74 24                	je     f0102d07 <mem_init+0x1b9b>
f0102ce3:	c7 44 24 0c a4 55 10 	movl   $0xf01055a4,0xc(%esp)
f0102cea:	f0 
f0102ceb:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102cf2:	f0 
f0102cf3:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f0102cfa:	00 
f0102cfb:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102d02:	e8 aa d3 ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d07:	a1 4c 0e 1e f0       	mov    0xf01e0e4c,%eax
f0102d0c:	8b 08                	mov    (%eax),%ecx
f0102d0e:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d14:	89 f2                	mov    %esi,%edx
f0102d16:	2b 15 50 0e 1e f0    	sub    0xf01e0e50,%edx
f0102d1c:	c1 fa 03             	sar    $0x3,%edx
f0102d1f:	c1 e2 0c             	shl    $0xc,%edx
f0102d22:	39 d1                	cmp    %edx,%ecx
f0102d24:	74 24                	je     f0102d4a <mem_init+0x1bde>
f0102d26:	c7 44 24 0c e4 4d 10 	movl   $0xf0104de4,0xc(%esp)
f0102d2d:	f0 
f0102d2e:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102d35:	f0 
f0102d36:	c7 44 24 04 f2 03 00 	movl   $0x3f2,0x4(%esp)
f0102d3d:	00 
f0102d3e:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102d45:	e8 67 d3 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f0102d4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102d50:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d55:	74 24                	je     f0102d7b <mem_init+0x1c0f>
f0102d57:	c7 44 24 0c 5b 55 10 	movl   $0xf010555b,0xc(%esp)
f0102d5e:	f0 
f0102d5f:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0102d66:	f0 
f0102d67:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102d6e:	00 
f0102d6f:	c7 04 24 61 53 10 f0 	movl   $0xf0105361,(%esp)
f0102d76:	e8 36 d3 ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0102d7b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d81:	89 34 24             	mov    %esi,(%esp)
f0102d84:	e8 35 e1 ff ff       	call   f0100ebe <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d89:	c7 04 24 00 53 10 f0 	movl   $0xf0105300,(%esp)
f0102d90:	e8 31 05 00 00       	call   f01032c6 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102d95:	83 c4 3c             	add    $0x3c,%esp
f0102d98:	5b                   	pop    %ebx
f0102d99:	5e                   	pop    %esi
f0102d9a:	5f                   	pop    %edi
f0102d9b:	5d                   	pop    %ebp
f0102d9c:	c3                   	ret    

f0102d9d <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102d9d:	55                   	push   %ebp
f0102d9e:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.

	return 0;
}
f0102da0:	b8 00 00 00 00       	mov    $0x0,%eax
f0102da5:	5d                   	pop    %ebp
f0102da6:	c3                   	ret    

f0102da7 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102da7:	55                   	push   %ebp
f0102da8:	89 e5                	mov    %esp,%ebp
f0102daa:	53                   	push   %ebx
f0102dab:	83 ec 14             	sub    $0x14,%esp
f0102dae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102db1:	8b 45 14             	mov    0x14(%ebp),%eax
f0102db4:	83 c8 04             	or     $0x4,%eax
f0102db7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102dbb:	8b 45 10             	mov    0x10(%ebp),%eax
f0102dbe:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dc5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102dc9:	89 1c 24             	mov    %ebx,(%esp)
f0102dcc:	e8 cc ff ff ff       	call   f0102d9d <user_mem_check>
f0102dd1:	85 c0                	test   %eax,%eax
f0102dd3:	79 23                	jns    f0102df8 <user_mem_assert+0x51>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102dd5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102ddc:	00 
f0102ddd:	8b 43 48             	mov    0x48(%ebx),%eax
f0102de0:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102de4:	c7 04 24 2c 53 10 f0 	movl   $0xf010532c,(%esp)
f0102deb:	e8 d6 04 00 00       	call   f01032c6 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102df0:	89 1c 24             	mov    %ebx,(%esp)
f0102df3:	e8 e6 03 00 00       	call   f01031de <env_destroy>
	}
}
f0102df8:	83 c4 14             	add    $0x14,%esp
f0102dfb:	5b                   	pop    %ebx
f0102dfc:	5d                   	pop    %ebp
f0102dfd:	c3                   	ret    
	...

f0102e00 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102e00:	55                   	push   %ebp
f0102e01:	89 e5                	mov    %esp,%ebp
f0102e03:	53                   	push   %ebx
f0102e04:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102e0a:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102e0d:	85 c0                	test   %eax,%eax
f0102e0f:	75 0e                	jne    f0102e1f <envid2env+0x1f>
		*env_store = curenv;
f0102e11:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f0102e16:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102e18:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e1d:	eb 55                	jmp    f0102e74 <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102e1f:	89 c2                	mov    %eax,%edx
f0102e21:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102e27:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102e2a:	c1 e2 05             	shl    $0x5,%edx
f0102e2d:	03 15 a8 01 1e f0    	add    0xf01e01a8,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102e33:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102e37:	74 05                	je     f0102e3e <envid2env+0x3e>
f0102e39:	39 42 48             	cmp    %eax,0x48(%edx)
f0102e3c:	74 0d                	je     f0102e4b <envid2env+0x4b>
		*env_store = 0;
f0102e3e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102e44:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e49:	eb 29                	jmp    f0102e74 <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102e4b:	84 db                	test   %bl,%bl
f0102e4d:	74 1e                	je     f0102e6d <envid2env+0x6d>
f0102e4f:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f0102e54:	39 c2                	cmp    %eax,%edx
f0102e56:	74 15                	je     f0102e6d <envid2env+0x6d>
f0102e58:	8b 58 48             	mov    0x48(%eax),%ebx
f0102e5b:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102e5e:	74 0d                	je     f0102e6d <envid2env+0x6d>
		*env_store = 0;
f0102e60:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102e66:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102e6b:	eb 07                	jmp    f0102e74 <envid2env+0x74>
	}

	*env_store = e;
f0102e6d:	89 11                	mov    %edx,(%ecx)
	return 0;
f0102e6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e74:	5b                   	pop    %ebx
f0102e75:	5d                   	pop    %ebp
f0102e76:	c3                   	ret    

f0102e77 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102e77:	55                   	push   %ebp
f0102e78:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102e7a:	b8 00 23 12 f0       	mov    $0xf0122300,%eax
f0102e7f:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102e82:	b8 23 00 00 00       	mov    $0x23,%eax
f0102e87:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102e89:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102e8b:	b0 10                	mov    $0x10,%al
f0102e8d:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102e8f:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102e91:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102e93:	ea 9a 2e 10 f0 08 00 	ljmp   $0x8,$0xf0102e9a
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102e9a:	b0 00                	mov    $0x0,%al
f0102e9c:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102e9f:	5d                   	pop    %ebp
f0102ea0:	c3                   	ret    

f0102ea1 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102ea1:	55                   	push   %ebp
f0102ea2:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	// Per-CPU part of the initialization
	env_init_percpu();
f0102ea4:	e8 ce ff ff ff       	call   f0102e77 <env_init_percpu>
}
f0102ea9:	5d                   	pop    %ebp
f0102eaa:	c3                   	ret    

f0102eab <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102eab:	55                   	push   %ebp
f0102eac:	89 e5                	mov    %esp,%ebp
f0102eae:	56                   	push   %esi
f0102eaf:	53                   	push   %ebx
f0102eb0:	83 ec 10             	sub    $0x10,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102eb3:	8b 1d ac 01 1e f0    	mov    0xf01e01ac,%ebx
f0102eb9:	85 db                	test   %ebx,%ebx
f0102ebb:	0f 84 1e 01 00 00    	je     f0102fdf <env_alloc+0x134>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102ec1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0102ec8:	e8 6d df ff ff       	call   f0100e3a <page_alloc>
f0102ecd:	85 c0                	test   %eax,%eax
f0102ecf:	0f 84 11 01 00 00    	je     f0102fe6 <env_alloc+0x13b>

	// LAB 3: Your code here.

	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102ed5:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ed8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102edd:	77 20                	ja     f0102eff <env_alloc+0x54>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102edf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ee3:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f0102eea:	f0 
f0102eeb:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f0102ef2:	00 
f0102ef3:	c7 04 24 96 56 10 f0 	movl   $0xf0105696,(%esp)
f0102efa:	e8 b2 d1 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102eff:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102f05:	83 ca 05             	or     $0x5,%edx
f0102f08:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102f0e:	8b 43 48             	mov    0x48(%ebx),%eax
f0102f11:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102f16:	89 c1                	mov    %eax,%ecx
f0102f18:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0102f1e:	7f 05                	jg     f0102f25 <env_alloc+0x7a>
		generation = 1 << ENVGENSHIFT;
f0102f20:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0102f25:	89 d8                	mov    %ebx,%eax
f0102f27:	2b 05 a8 01 1e f0    	sub    0xf01e01a8,%eax
f0102f2d:	c1 f8 05             	sar    $0x5,%eax
f0102f30:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0102f33:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102f36:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0102f39:	89 d6                	mov    %edx,%esi
f0102f3b:	c1 e6 08             	shl    $0x8,%esi
f0102f3e:	01 f2                	add    %esi,%edx
f0102f40:	89 d6                	mov    %edx,%esi
f0102f42:	c1 e6 10             	shl    $0x10,%esi
f0102f45:	01 f2                	add    %esi,%edx
f0102f47:	8d 04 50             	lea    (%eax,%edx,2),%eax
f0102f4a:	09 c1                	or     %eax,%ecx
f0102f4c:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102f4f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f52:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102f55:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102f5c:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102f63:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f6a:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0102f71:	00 
f0102f72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102f79:	00 
f0102f7a:	89 1c 24             	mov    %ebx,(%esp)
f0102f7d:	e8 50 12 00 00       	call   f01041d2 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f82:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102f88:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f8e:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102f94:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102f9b:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102fa1:	8b 43 44             	mov    0x44(%ebx),%eax
f0102fa4:	a3 ac 01 1e f0       	mov    %eax,0xf01e01ac
	*newenv_store = e;
f0102fa9:	8b 45 08             	mov    0x8(%ebp),%eax
f0102fac:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102fae:	8b 53 48             	mov    0x48(%ebx),%edx
f0102fb1:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f0102fb6:	85 c0                	test   %eax,%eax
f0102fb8:	74 05                	je     f0102fbf <env_alloc+0x114>
f0102fba:	8b 40 48             	mov    0x48(%eax),%eax
f0102fbd:	eb 05                	jmp    f0102fc4 <env_alloc+0x119>
f0102fbf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fc4:	89 54 24 08          	mov    %edx,0x8(%esp)
f0102fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fcc:	c7 04 24 a1 56 10 f0 	movl   $0xf01056a1,(%esp)
f0102fd3:	e8 ee 02 00 00       	call   f01032c6 <cprintf>
	return 0;
f0102fd8:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fdd:	eb 0c                	jmp    f0102feb <env_alloc+0x140>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102fdf:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102fe4:	eb 05                	jmp    f0102feb <env_alloc+0x140>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102fe6:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102feb:	83 c4 10             	add    $0x10,%esp
f0102fee:	5b                   	pop    %ebx
f0102fef:	5e                   	pop    %esi
f0102ff0:	5d                   	pop    %ebp
f0102ff1:	c3                   	ret    

f0102ff2 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102ff2:	55                   	push   %ebp
f0102ff3:	89 e5                	mov    %esp,%ebp
	// LAB 3: Your code here.
}
f0102ff5:	5d                   	pop    %ebp
f0102ff6:	c3                   	ret    

f0102ff7 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102ff7:	55                   	push   %ebp
f0102ff8:	89 e5                	mov    %esp,%ebp
f0102ffa:	57                   	push   %edi
f0102ffb:	56                   	push   %esi
f0102ffc:	53                   	push   %ebx
f0102ffd:	83 ec 2c             	sub    $0x2c,%esp
f0103000:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0103003:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f0103008:	39 c7                	cmp    %eax,%edi
f010300a:	75 37                	jne    f0103043 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f010300c:	8b 15 4c 0e 1e f0    	mov    0xf01e0e4c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103012:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103018:	77 20                	ja     f010303a <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010301a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010301e:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f0103025:	f0 
f0103026:	c7 44 24 04 68 01 00 	movl   $0x168,0x4(%esp)
f010302d:	00 
f010302e:	c7 04 24 96 56 10 f0 	movl   $0xf0105696,(%esp)
f0103035:	e8 77 d0 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010303a:	81 c2 00 00 00 10    	add    $0x10000000,%edx
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103040:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103043:	8b 57 48             	mov    0x48(%edi),%edx
f0103046:	85 c0                	test   %eax,%eax
f0103048:	74 05                	je     f010304f <env_free+0x58>
f010304a:	8b 40 48             	mov    0x48(%eax),%eax
f010304d:	eb 05                	jmp    f0103054 <env_free+0x5d>
f010304f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103054:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103058:	89 44 24 04          	mov    %eax,0x4(%esp)
f010305c:	c7 04 24 b6 56 10 f0 	movl   $0xf01056b6,(%esp)
f0103063:	e8 5e 02 00 00       	call   f01032c6 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103068:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010306f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103072:	c1 e0 02             	shl    $0x2,%eax
f0103075:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103078:	8b 47 5c             	mov    0x5c(%edi),%eax
f010307b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010307e:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103081:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103087:	0f 84 b6 00 00 00    	je     f0103143 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010308d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103093:	89 f0                	mov    %esi,%eax
f0103095:	c1 e8 0c             	shr    $0xc,%eax
f0103098:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010309b:	3b 05 48 0e 1e f0    	cmp    0xf01e0e48,%eax
f01030a1:	72 20                	jb     f01030c3 <env_free+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030a3:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01030a7:	c7 44 24 08 44 4b 10 	movl   $0xf0104b44,0x8(%esp)
f01030ae:	f0 
f01030af:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f01030b6:	00 
f01030b7:	c7 04 24 96 56 10 f0 	movl   $0xf0105696,(%esp)
f01030be:	e8 ee cf ff ff       	call   f01000b1 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01030c3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01030c6:	c1 e2 16             	shl    $0x16,%edx
f01030c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01030cc:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01030d1:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01030d8:	01 
f01030d9:	74 17                	je     f01030f2 <env_free+0xfb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01030db:	89 d8                	mov    %ebx,%eax
f01030dd:	c1 e0 0c             	shl    $0xc,%eax
f01030e0:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01030e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030e7:	8b 47 5c             	mov    0x5c(%edi),%eax
f01030ea:	89 04 24             	mov    %eax,(%esp)
f01030ed:	e8 b7 df ff ff       	call   f01010a9 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01030f2:	43                   	inc    %ebx
f01030f3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01030f9:	75 d6                	jne    f01030d1 <env_free+0xda>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01030fb:	8b 47 5c             	mov    0x5c(%edi),%eax
f01030fe:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103101:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103108:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010310b:	3b 05 48 0e 1e f0    	cmp    0xf01e0e48,%eax
f0103111:	72 1c                	jb     f010312f <env_free+0x138>
		panic("pa2page called with invalid pa");
f0103113:	c7 44 24 08 b0 4c 10 	movl   $0xf0104cb0,0x8(%esp)
f010311a:	f0 
f010311b:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103122:	00 
f0103123:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f010312a:	e8 82 cf ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f010312f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103132:	c1 e0 03             	shl    $0x3,%eax
f0103135:	03 05 50 0e 1e f0    	add    0xf01e0e50,%eax
		page_decref(pa2page(pa));
f010313b:	89 04 24             	mov    %eax,(%esp)
f010313e:	e8 bb dd ff ff       	call   f0100efe <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103143:	ff 45 e0             	incl   -0x20(%ebp)
f0103146:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f010314d:	0f 85 1c ff ff ff    	jne    f010306f <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103153:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103156:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010315b:	77 20                	ja     f010317d <env_free+0x186>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010315d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103161:	c7 44 24 08 68 4b 10 	movl   $0xf0104b68,0x8(%esp)
f0103168:	f0 
f0103169:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f0103170:	00 
f0103171:	c7 04 24 96 56 10 f0 	movl   $0xf0105696,(%esp)
f0103178:	e8 34 cf ff ff       	call   f01000b1 <_panic>
	e->env_pgdir = 0;
f010317d:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103184:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103189:	c1 e8 0c             	shr    $0xc,%eax
f010318c:	3b 05 48 0e 1e f0    	cmp    0xf01e0e48,%eax
f0103192:	72 1c                	jb     f01031b0 <env_free+0x1b9>
		panic("pa2page called with invalid pa");
f0103194:	c7 44 24 08 b0 4c 10 	movl   $0xf0104cb0,0x8(%esp)
f010319b:	f0 
f010319c:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01031a3:	00 
f01031a4:	c7 04 24 88 53 10 f0 	movl   $0xf0105388,(%esp)
f01031ab:	e8 01 cf ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f01031b0:	c1 e0 03             	shl    $0x3,%eax
f01031b3:	03 05 50 0e 1e f0    	add    0xf01e0e50,%eax
	page_decref(pa2page(pa));
f01031b9:	89 04 24             	mov    %eax,(%esp)
f01031bc:	e8 3d dd ff ff       	call   f0100efe <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01031c1:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01031c8:	a1 ac 01 1e f0       	mov    0xf01e01ac,%eax
f01031cd:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01031d0:	89 3d ac 01 1e f0    	mov    %edi,0xf01e01ac
}
f01031d6:	83 c4 2c             	add    $0x2c,%esp
f01031d9:	5b                   	pop    %ebx
f01031da:	5e                   	pop    %esi
f01031db:	5f                   	pop    %edi
f01031dc:	5d                   	pop    %ebp
f01031dd:	c3                   	ret    

f01031de <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f01031de:	55                   	push   %ebp
f01031df:	89 e5                	mov    %esp,%ebp
f01031e1:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f01031e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01031e7:	89 04 24             	mov    %eax,(%esp)
f01031ea:	e8 08 fe ff ff       	call   f0102ff7 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01031ef:	c7 04 24 60 56 10 f0 	movl   $0xf0105660,(%esp)
f01031f6:	e8 cb 00 00 00       	call   f01032c6 <cprintf>
	while (1)
		monitor(NULL);
f01031fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103202:	e8 ca d5 ff ff       	call   f01007d1 <monitor>
f0103207:	eb f2                	jmp    f01031fb <env_destroy+0x1d>

f0103209 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103209:	55                   	push   %ebp
f010320a:	89 e5                	mov    %esp,%ebp
f010320c:	83 ec 18             	sub    $0x18,%esp
	asm volatile(
f010320f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103212:	61                   	popa   
f0103213:	07                   	pop    %es
f0103214:	1f                   	pop    %ds
f0103215:	83 c4 08             	add    $0x8,%esp
f0103218:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103219:	c7 44 24 08 cc 56 10 	movl   $0xf01056cc,0x8(%esp)
f0103220:	f0 
f0103221:	c7 44 24 04 ae 01 00 	movl   $0x1ae,0x4(%esp)
f0103228:	00 
f0103229:	c7 04 24 96 56 10 f0 	movl   $0xf0105696,(%esp)
f0103230:	e8 7c ce ff ff       	call   f01000b1 <_panic>

f0103235 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103235:	55                   	push   %ebp
f0103236:	89 e5                	mov    %esp,%ebp
f0103238:	83 ec 18             	sub    $0x18,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	panic("env_run not yet implemented");
f010323b:	c7 44 24 08 d8 56 10 	movl   $0xf01056d8,0x8(%esp)
f0103242:	f0 
f0103243:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
f010324a:	00 
f010324b:	c7 04 24 96 56 10 f0 	movl   $0xf0105696,(%esp)
f0103252:	e8 5a ce ff ff       	call   f01000b1 <_panic>
	...

f0103258 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103258:	55                   	push   %ebp
f0103259:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010325b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103260:	8b 45 08             	mov    0x8(%ebp),%eax
f0103263:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103264:	b2 71                	mov    $0x71,%dl
f0103266:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103267:	0f b6 c0             	movzbl %al,%eax
}
f010326a:	5d                   	pop    %ebp
f010326b:	c3                   	ret    

f010326c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010326c:	55                   	push   %ebp
f010326d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010326f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103274:	8b 45 08             	mov    0x8(%ebp),%eax
f0103277:	ee                   	out    %al,(%dx)
f0103278:	b2 71                	mov    $0x71,%dl
f010327a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010327d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010327e:	5d                   	pop    %ebp
f010327f:	c3                   	ret    

f0103280 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103280:	55                   	push   %ebp
f0103281:	89 e5                	mov    %esp,%ebp
f0103283:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103286:	8b 45 08             	mov    0x8(%ebp),%eax
f0103289:	89 04 24             	mov    %eax,(%esp)
f010328c:	e8 47 d3 ff ff       	call   f01005d8 <cputchar>
	*cnt++;
}
f0103291:	c9                   	leave  
f0103292:	c3                   	ret    

f0103293 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103293:	55                   	push   %ebp
f0103294:	89 e5                	mov    %esp,%ebp
f0103296:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103299:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01032a0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01032a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01032a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01032aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01032ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01032b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032b5:	c7 04 24 80 32 10 f0 	movl   $0xf0103280,(%esp)
f01032bc:	e8 d1 08 00 00       	call   f0103b92 <vprintfmt>
	return cnt;
}
f01032c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01032c4:	c9                   	leave  
f01032c5:	c3                   	ret    

f01032c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01032c6:	55                   	push   %ebp
f01032c7:	89 e5                	mov    %esp,%ebp
f01032c9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01032cc:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01032cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01032d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01032d6:	89 04 24             	mov    %eax,(%esp)
f01032d9:	e8 b5 ff ff ff       	call   f0103293 <vcprintf>
	va_end(ap);

	return cnt;
}
f01032de:	c9                   	leave  
f01032df:	c3                   	ret    

f01032e0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01032e0:	55                   	push   %ebp
f01032e1:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01032e3:	c7 05 c4 09 1e f0 00 	movl   $0xf0000000,0xf01e09c4
f01032ea:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01032ed:	66 c7 05 c8 09 1e f0 	movw   $0x10,0xf01e09c8
f01032f4:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f01032f6:	66 c7 05 26 0a 1e f0 	movw   $0x68,0xf01e0a26
f01032fd:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01032ff:	66 c7 05 48 23 12 f0 	movw   $0x67,0xf0122348
f0103306:	67 00 
f0103308:	b8 c0 09 1e f0       	mov    $0xf01e09c0,%eax
f010330d:	66 a3 4a 23 12 f0    	mov    %ax,0xf012234a
f0103313:	89 c2                	mov    %eax,%edx
f0103315:	c1 ea 10             	shr    $0x10,%edx
f0103318:	88 15 4c 23 12 f0    	mov    %dl,0xf012234c
f010331e:	c6 05 4e 23 12 f0 40 	movb   $0x40,0xf012234e
f0103325:	c1 e8 18             	shr    $0x18,%eax
f0103328:	a2 4f 23 12 f0       	mov    %al,0xf012234f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010332d:	c6 05 4d 23 12 f0 89 	movb   $0x89,0xf012234d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103334:	b8 28 00 00 00       	mov    $0x28,%eax
f0103339:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010333c:	b8 50 23 12 f0       	mov    $0xf0122350,%eax
f0103341:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103344:	5d                   	pop    %ebp
f0103345:	c3                   	ret    

f0103346 <trap_init>:
}


void
trap_init(void)
{
f0103346:	55                   	push   %ebp
f0103347:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.

	// Per-CPU setup 
	trap_init_percpu();
f0103349:	e8 92 ff ff ff       	call   f01032e0 <trap_init_percpu>
}
f010334e:	5d                   	pop    %ebp
f010334f:	c3                   	ret    

f0103350 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103350:	55                   	push   %ebp
f0103351:	89 e5                	mov    %esp,%ebp
f0103353:	53                   	push   %ebx
f0103354:	83 ec 14             	sub    $0x14,%esp
f0103357:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f010335a:	8b 03                	mov    (%ebx),%eax
f010335c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103360:	c7 04 24 f4 56 10 f0 	movl   $0xf01056f4,(%esp)
f0103367:	e8 5a ff ff ff       	call   f01032c6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010336c:	8b 43 04             	mov    0x4(%ebx),%eax
f010336f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103373:	c7 04 24 03 57 10 f0 	movl   $0xf0105703,(%esp)
f010337a:	e8 47 ff ff ff       	call   f01032c6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010337f:	8b 43 08             	mov    0x8(%ebx),%eax
f0103382:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103386:	c7 04 24 12 57 10 f0 	movl   $0xf0105712,(%esp)
f010338d:	e8 34 ff ff ff       	call   f01032c6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103392:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103395:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103399:	c7 04 24 21 57 10 f0 	movl   $0xf0105721,(%esp)
f01033a0:	e8 21 ff ff ff       	call   f01032c6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01033a5:	8b 43 10             	mov    0x10(%ebx),%eax
f01033a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033ac:	c7 04 24 30 57 10 f0 	movl   $0xf0105730,(%esp)
f01033b3:	e8 0e ff ff ff       	call   f01032c6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01033b8:	8b 43 14             	mov    0x14(%ebx),%eax
f01033bb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033bf:	c7 04 24 3f 57 10 f0 	movl   $0xf010573f,(%esp)
f01033c6:	e8 fb fe ff ff       	call   f01032c6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f01033cb:	8b 43 18             	mov    0x18(%ebx),%eax
f01033ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033d2:	c7 04 24 4e 57 10 f0 	movl   $0xf010574e,(%esp)
f01033d9:	e8 e8 fe ff ff       	call   f01032c6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f01033de:	8b 43 1c             	mov    0x1c(%ebx),%eax
f01033e1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01033e5:	c7 04 24 5d 57 10 f0 	movl   $0xf010575d,(%esp)
f01033ec:	e8 d5 fe ff ff       	call   f01032c6 <cprintf>
}
f01033f1:	83 c4 14             	add    $0x14,%esp
f01033f4:	5b                   	pop    %ebx
f01033f5:	5d                   	pop    %ebp
f01033f6:	c3                   	ret    

f01033f7 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f01033f7:	55                   	push   %ebp
f01033f8:	89 e5                	mov    %esp,%ebp
f01033fa:	53                   	push   %ebx
f01033fb:	83 ec 14             	sub    $0x14,%esp
f01033fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103401:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103405:	c7 04 24 93 58 10 f0 	movl   $0xf0105893,(%esp)
f010340c:	e8 b5 fe ff ff       	call   f01032c6 <cprintf>
	print_regs(&tf->tf_regs);
f0103411:	89 1c 24             	mov    %ebx,(%esp)
f0103414:	e8 37 ff ff ff       	call   f0103350 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103419:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f010341d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103421:	c7 04 24 ae 57 10 f0 	movl   $0xf01057ae,(%esp)
f0103428:	e8 99 fe ff ff       	call   f01032c6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f010342d:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103431:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103435:	c7 04 24 c1 57 10 f0 	movl   $0xf01057c1,(%esp)
f010343c:	e8 85 fe ff ff       	call   f01032c6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103441:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103444:	83 f8 13             	cmp    $0x13,%eax
f0103447:	77 09                	ja     f0103452 <print_trapframe+0x5b>
		return excnames[trapno];
f0103449:	8b 14 85 60 5a 10 f0 	mov    -0xfefa5a0(,%eax,4),%edx
f0103450:	eb 11                	jmp    f0103463 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
f0103452:	83 f8 30             	cmp    $0x30,%eax
f0103455:	75 07                	jne    f010345e <print_trapframe+0x67>
		return "System call";
f0103457:	ba 6c 57 10 f0       	mov    $0xf010576c,%edx
f010345c:	eb 05                	jmp    f0103463 <print_trapframe+0x6c>
	return "(unknown trap)";
f010345e:	ba 78 57 10 f0       	mov    $0xf0105778,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103463:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103467:	89 44 24 04          	mov    %eax,0x4(%esp)
f010346b:	c7 04 24 d4 57 10 f0 	movl   $0xf01057d4,(%esp)
f0103472:	e8 4f fe ff ff       	call   f01032c6 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103477:	3b 1d 28 0a 1e f0    	cmp    0xf01e0a28,%ebx
f010347d:	75 19                	jne    f0103498 <print_trapframe+0xa1>
f010347f:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103483:	75 13                	jne    f0103498 <print_trapframe+0xa1>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103485:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103488:	89 44 24 04          	mov    %eax,0x4(%esp)
f010348c:	c7 04 24 e6 57 10 f0 	movl   $0xf01057e6,(%esp)
f0103493:	e8 2e fe ff ff       	call   f01032c6 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103498:	8b 43 2c             	mov    0x2c(%ebx),%eax
f010349b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010349f:	c7 04 24 f5 57 10 f0 	movl   $0xf01057f5,(%esp)
f01034a6:	e8 1b fe ff ff       	call   f01032c6 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f01034ab:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01034af:	75 4d                	jne    f01034fe <print_trapframe+0x107>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f01034b1:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f01034b4:	a8 01                	test   $0x1,%al
f01034b6:	74 07                	je     f01034bf <print_trapframe+0xc8>
f01034b8:	b9 87 57 10 f0       	mov    $0xf0105787,%ecx
f01034bd:	eb 05                	jmp    f01034c4 <print_trapframe+0xcd>
f01034bf:	b9 92 57 10 f0       	mov    $0xf0105792,%ecx
f01034c4:	a8 02                	test   $0x2,%al
f01034c6:	74 07                	je     f01034cf <print_trapframe+0xd8>
f01034c8:	ba 9e 57 10 f0       	mov    $0xf010579e,%edx
f01034cd:	eb 05                	jmp    f01034d4 <print_trapframe+0xdd>
f01034cf:	ba a4 57 10 f0       	mov    $0xf01057a4,%edx
f01034d4:	a8 04                	test   $0x4,%al
f01034d6:	74 07                	je     f01034df <print_trapframe+0xe8>
f01034d8:	b8 a9 57 10 f0       	mov    $0xf01057a9,%eax
f01034dd:	eb 05                	jmp    f01034e4 <print_trapframe+0xed>
f01034df:	b8 be 58 10 f0       	mov    $0xf01058be,%eax
f01034e4:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01034e8:	89 54 24 08          	mov    %edx,0x8(%esp)
f01034ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034f0:	c7 04 24 03 58 10 f0 	movl   $0xf0105803,(%esp)
f01034f7:	e8 ca fd ff ff       	call   f01032c6 <cprintf>
f01034fc:	eb 0c                	jmp    f010350a <print_trapframe+0x113>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01034fe:	c7 04 24 2d 56 10 f0 	movl   $0xf010562d,(%esp)
f0103505:	e8 bc fd ff ff       	call   f01032c6 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f010350a:	8b 43 30             	mov    0x30(%ebx),%eax
f010350d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103511:	c7 04 24 12 58 10 f0 	movl   $0xf0105812,(%esp)
f0103518:	e8 a9 fd ff ff       	call   f01032c6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f010351d:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103521:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103525:	c7 04 24 21 58 10 f0 	movl   $0xf0105821,(%esp)
f010352c:	e8 95 fd ff ff       	call   f01032c6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103531:	8b 43 38             	mov    0x38(%ebx),%eax
f0103534:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103538:	c7 04 24 34 58 10 f0 	movl   $0xf0105834,(%esp)
f010353f:	e8 82 fd ff ff       	call   f01032c6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103544:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103548:	74 27                	je     f0103571 <print_trapframe+0x17a>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f010354a:	8b 43 3c             	mov    0x3c(%ebx),%eax
f010354d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103551:	c7 04 24 43 58 10 f0 	movl   $0xf0105843,(%esp)
f0103558:	e8 69 fd ff ff       	call   f01032c6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f010355d:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103561:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103565:	c7 04 24 52 58 10 f0 	movl   $0xf0105852,(%esp)
f010356c:	e8 55 fd ff ff       	call   f01032c6 <cprintf>
	}
}
f0103571:	83 c4 14             	add    $0x14,%esp
f0103574:	5b                   	pop    %ebx
f0103575:	5d                   	pop    %ebp
f0103576:	c3                   	ret    

f0103577 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103577:	55                   	push   %ebp
f0103578:	89 e5                	mov    %esp,%ebp
f010357a:	57                   	push   %edi
f010357b:	56                   	push   %esi
f010357c:	83 ec 10             	sub    $0x10,%esp
f010357f:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103582:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103583:	9c                   	pushf  
f0103584:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103585:	f6 c4 02             	test   $0x2,%ah
f0103588:	74 24                	je     f01035ae <trap+0x37>
f010358a:	c7 44 24 0c 65 58 10 	movl   $0xf0105865,0xc(%esp)
f0103591:	f0 
f0103592:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0103599:	f0 
f010359a:	c7 44 24 04 a8 00 00 	movl   $0xa8,0x4(%esp)
f01035a1:	00 
f01035a2:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f01035a9:	e8 03 cb ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f01035ae:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035b2:	c7 04 24 8a 58 10 f0 	movl   $0xf010588a,(%esp)
f01035b9:	e8 08 fd ff ff       	call   f01032c6 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f01035be:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01035c2:	83 e0 03             	and    $0x3,%eax
f01035c5:	83 f8 03             	cmp    $0x3,%eax
f01035c8:	75 3c                	jne    f0103606 <trap+0x8f>
		// Trapped from user mode.
		assert(curenv);
f01035ca:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f01035cf:	85 c0                	test   %eax,%eax
f01035d1:	75 24                	jne    f01035f7 <trap+0x80>
f01035d3:	c7 44 24 0c a5 58 10 	movl   $0xf01058a5,0xc(%esp)
f01035da:	f0 
f01035db:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f01035e2:	f0 
f01035e3:	c7 44 24 04 ae 00 00 	movl   $0xae,0x4(%esp)
f01035ea:	00 
f01035eb:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f01035f2:	e8 ba ca ff ff       	call   f01000b1 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01035f7:	b9 11 00 00 00       	mov    $0x11,%ecx
f01035fc:	89 c7                	mov    %eax,%edi
f01035fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103600:	8b 35 a4 01 1e f0    	mov    0xf01e01a4,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103606:	89 35 28 0a 1e f0    	mov    %esi,0xf01e0a28
{
	// Handle processor exceptions.
	// LAB 3: Your code here.

	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f010360c:	89 34 24             	mov    %esi,(%esp)
f010360f:	e8 e3 fd ff ff       	call   f01033f7 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103614:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103619:	75 1c                	jne    f0103637 <trap+0xc0>
		panic("unhandled trap in kernel");
f010361b:	c7 44 24 08 ac 58 10 	movl   $0xf01058ac,0x8(%esp)
f0103622:	f0 
f0103623:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f010362a:	00 
f010362b:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f0103632:	e8 7a ca ff ff       	call   f01000b1 <_panic>
	else {
		env_destroy(curenv);
f0103637:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f010363c:	89 04 24             	mov    %eax,(%esp)
f010363f:	e8 9a fb ff ff       	call   f01031de <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103644:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f0103649:	85 c0                	test   %eax,%eax
f010364b:	74 06                	je     f0103653 <trap+0xdc>
f010364d:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103651:	74 24                	je     f0103677 <trap+0x100>
f0103653:	c7 44 24 0c 08 5a 10 	movl   $0xf0105a08,0xc(%esp)
f010365a:	f0 
f010365b:	c7 44 24 08 a2 53 10 	movl   $0xf01053a2,0x8(%esp)
f0103662:	f0 
f0103663:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
f010366a:	00 
f010366b:	c7 04 24 7e 58 10 f0 	movl   $0xf010587e,(%esp)
f0103672:	e8 3a ca ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0103677:	89 04 24             	mov    %eax,(%esp)
f010367a:	e8 b6 fb ff ff       	call   f0103235 <env_run>

f010367f <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f010367f:	55                   	push   %ebp
f0103680:	89 e5                	mov    %esp,%ebp
f0103682:	53                   	push   %ebx
f0103683:	83 ec 14             	sub    $0x14,%esp
f0103686:	8b 5d 08             	mov    0x8(%ebp),%ebx

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103689:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010368c:	8b 53 30             	mov    0x30(%ebx),%edx
f010368f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103693:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103697:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010369c:	8b 40 48             	mov    0x48(%eax),%eax
f010369f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036a3:	c7 04 24 34 5a 10 f0 	movl   $0xf0105a34,(%esp)
f01036aa:	e8 17 fc ff ff       	call   f01032c6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f01036af:	89 1c 24             	mov    %ebx,(%esp)
f01036b2:	e8 40 fd ff ff       	call   f01033f7 <print_trapframe>
	env_destroy(curenv);
f01036b7:	a1 a4 01 1e f0       	mov    0xf01e01a4,%eax
f01036bc:	89 04 24             	mov    %eax,(%esp)
f01036bf:	e8 1a fb ff ff       	call   f01031de <env_destroy>
}
f01036c4:	83 c4 14             	add    $0x14,%esp
f01036c7:	5b                   	pop    %ebx
f01036c8:	5d                   	pop    %ebp
f01036c9:	c3                   	ret    
	...

f01036cc <syscall>:
f01036cc:	55                   	push   %ebp
f01036cd:	89 e5                	mov    %esp,%ebp
f01036cf:	83 ec 18             	sub    $0x18,%esp
f01036d2:	c7 44 24 08 b0 5a 10 	movl   $0xf0105ab0,0x8(%esp)
f01036d9:	f0 
f01036da:	c7 44 24 04 49 00 00 	movl   $0x49,0x4(%esp)
f01036e1:	00 
f01036e2:	c7 04 24 c8 5a 10 f0 	movl   $0xf0105ac8,(%esp)
f01036e9:	e8 c3 c9 ff ff       	call   f01000b1 <_panic>
	...

f01036f0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01036f0:	55                   	push   %ebp
f01036f1:	89 e5                	mov    %esp,%ebp
f01036f3:	57                   	push   %edi
f01036f4:	56                   	push   %esi
f01036f5:	53                   	push   %ebx
f01036f6:	83 ec 14             	sub    $0x14,%esp
f01036f9:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01036fc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f01036ff:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103702:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0103705:	8b 1a                	mov    (%edx),%ebx
f0103707:	8b 01                	mov    (%ecx),%eax
f0103709:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010370c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f0103713:	e9 83 00 00 00       	jmp    f010379b <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0103718:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010371b:	01 d8                	add    %ebx,%eax
f010371d:	89 c7                	mov    %eax,%edi
f010371f:	c1 ef 1f             	shr    $0x1f,%edi
f0103722:	01 c7                	add    %eax,%edi
f0103724:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103726:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0103729:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010372c:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0103730:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103732:	eb 01                	jmp    f0103735 <stab_binsearch+0x45>
			m--;
f0103734:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103735:	39 c3                	cmp    %eax,%ebx
f0103737:	7f 1e                	jg     f0103757 <stab_binsearch+0x67>
f0103739:	0f b6 0a             	movzbl (%edx),%ecx
f010373c:	83 ea 0c             	sub    $0xc,%edx
f010373f:	39 f1                	cmp    %esi,%ecx
f0103741:	75 f1                	jne    f0103734 <stab_binsearch+0x44>
f0103743:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103746:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103749:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010374c:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0103750:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103753:	76 18                	jbe    f010376d <stab_binsearch+0x7d>
f0103755:	eb 05                	jmp    f010375c <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0103757:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f010375a:	eb 3f                	jmp    f010379b <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f010375c:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010375f:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f0103761:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103764:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f010376b:	eb 2e                	jmp    f010379b <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010376d:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103770:	73 15                	jae    f0103787 <stab_binsearch+0x97>
			*region_right = m - 1;
f0103772:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103775:	49                   	dec    %ecx
f0103776:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103779:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010377c:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010377e:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0103785:	eb 14                	jmp    f010379b <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103787:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f010378a:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010378d:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010378f:	ff 45 0c             	incl   0xc(%ebp)
f0103792:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103794:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010379b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010379e:	0f 8e 74 ff ff ff    	jle    f0103718 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01037a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01037a8:	75 0d                	jne    f01037b7 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01037aa:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01037ad:	8b 02                	mov    (%edx),%eax
f01037af:	48                   	dec    %eax
f01037b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01037b3:	89 01                	mov    %eax,(%ecx)
f01037b5:	eb 2a                	jmp    f01037e1 <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037b7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01037ba:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01037bc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01037bf:	8b 0a                	mov    (%edx),%ecx
f01037c1:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01037c4:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01037c7:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037cb:	eb 01                	jmp    f01037ce <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01037cd:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037ce:	39 c8                	cmp    %ecx,%eax
f01037d0:	7e 0a                	jle    f01037dc <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f01037d2:	0f b6 1a             	movzbl (%edx),%ebx
f01037d5:	83 ea 0c             	sub    $0xc,%edx
f01037d8:	39 f3                	cmp    %esi,%ebx
f01037da:	75 f1                	jne    f01037cd <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f01037dc:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01037df:	89 02                	mov    %eax,(%edx)
	}
}
f01037e1:	83 c4 14             	add    $0x14,%esp
f01037e4:	5b                   	pop    %ebx
f01037e5:	5e                   	pop    %esi
f01037e6:	5f                   	pop    %edi
f01037e7:	5d                   	pop    %ebp
f01037e8:	c3                   	ret    

f01037e9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01037e9:	55                   	push   %ebp
f01037ea:	89 e5                	mov    %esp,%ebp
f01037ec:	57                   	push   %edi
f01037ed:	56                   	push   %esi
f01037ee:	53                   	push   %ebx
f01037ef:	83 ec 5c             	sub    $0x5c,%esp
f01037f2:	8b 75 08             	mov    0x8(%ebp),%esi
f01037f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01037f8:	c7 03 d7 5a 10 f0    	movl   $0xf0105ad7,(%ebx)
	info->eip_line = 0;
f01037fe:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0103805:	c7 43 08 d7 5a 10 f0 	movl   $0xf0105ad7,0x8(%ebx)
	info->eip_fn_namelen = 9;
f010380c:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0103813:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0103816:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010381d:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0103823:	77 22                	ja     f0103847 <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103825:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f010382b:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010382e:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103833:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0103839:	89 7d bc             	mov    %edi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f010383c:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0103842:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0103845:	eb 1a                	jmp    f0103861 <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0103847:	c7 45 c0 22 7b 11 f0 	movl   $0xf0117b22,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010384e:	c7 45 bc 91 dd 10 f0 	movl   $0xf010dd91,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103855:	b8 90 dd 10 f0       	mov    $0xf010dd90,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010385a:	c7 45 c4 f0 5c 10 f0 	movl   $0xf0105cf0,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103861:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103864:	39 7d bc             	cmp    %edi,-0x44(%ebp)
f0103867:	0f 83 8b 01 00 00    	jae    f01039f8 <debuginfo_eip+0x20f>
f010386d:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0103871:	0f 85 88 01 00 00    	jne    f01039ff <debuginfo_eip+0x216>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103877:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010387e:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f0103881:	c1 f8 02             	sar    $0x2,%eax
f0103884:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0103887:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010388a:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010388d:	89 d1                	mov    %edx,%ecx
f010388f:	c1 e1 08             	shl    $0x8,%ecx
f0103892:	01 ca                	add    %ecx,%edx
f0103894:	89 d1                	mov    %edx,%ecx
f0103896:	c1 e1 10             	shl    $0x10,%ecx
f0103899:	01 ca                	add    %ecx,%edx
f010389b:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f010389f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01038a2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01038a6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01038ad:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01038b0:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01038b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01038b6:	e8 35 fe ff ff       	call   f01036f0 <stab_binsearch>
	if (lfile == 0)
f01038bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01038be:	85 c0                	test   %eax,%eax
f01038c0:	0f 84 40 01 00 00    	je     f0103a06 <debuginfo_eip+0x21d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01038c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01038c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01038cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01038cf:	89 74 24 04          	mov    %esi,0x4(%esp)
f01038d3:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01038da:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01038dd:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01038e0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01038e3:	e8 08 fe ff ff       	call   f01036f0 <stab_binsearch>

	if (lfun <= rfun) {
f01038e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01038eb:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01038ee:	39 d0                	cmp    %edx,%eax
f01038f0:	7f 32                	jg     f0103924 <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01038f2:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01038f5:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01038f8:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01038fb:	8b 39                	mov    (%ecx),%edi
f01038fd:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f0103900:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0103903:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0103906:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0103909:	73 09                	jae    f0103914 <debuginfo_eip+0x12b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010390b:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010390e:	03 7d bc             	add    -0x44(%ebp),%edi
f0103911:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0103914:	8b 49 08             	mov    0x8(%ecx),%ecx
f0103917:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f010391a:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f010391c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010391f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0103922:	eb 0f                	jmp    f0103933 <debuginfo_eip+0x14a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103924:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0103927:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010392a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f010392d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103930:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0103933:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f010393a:	00 
f010393b:	8b 43 08             	mov    0x8(%ebx),%eax
f010393e:	89 04 24             	mov    %eax,(%esp)
f0103941:	e8 74 08 00 00       	call   f01041ba <strfind>
f0103946:	2b 43 08             	sub    0x8(%ebx),%eax
f0103949:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f010394c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103950:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0103957:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f010395a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f010395d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0103960:	e8 8b fd ff ff       	call   f01036f0 <stab_binsearch>
	if (lline > rline) {
f0103965:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103968:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010396b:	0f 8f 9c 00 00 00    	jg     f0103a0d <debuginfo_eip+0x224>
		return -1;
	}
	info->eip_line = stabs[rline].n_desc;
f0103971:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0103974:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103977:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f010397c:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010397f:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0103982:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103985:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0103988:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f010398c:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010398f:	eb 04                	jmp    f0103995 <debuginfo_eip+0x1ac>
f0103991:	48                   	dec    %eax
f0103992:	83 ea 0c             	sub    $0xc,%edx
f0103995:	89 c7                	mov    %eax,%edi
f0103997:	39 c6                	cmp    %eax,%esi
f0103999:	7f 25                	jg     f01039c0 <debuginfo_eip+0x1d7>
	       && stabs[lline].n_type != N_SOL
f010399b:	8a 4a fc             	mov    -0x4(%edx),%cl
f010399e:	80 f9 84             	cmp    $0x84,%cl
f01039a1:	0f 84 81 00 00 00    	je     f0103a28 <debuginfo_eip+0x23f>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01039a7:	80 f9 64             	cmp    $0x64,%cl
f01039aa:	75 e5                	jne    f0103991 <debuginfo_eip+0x1a8>
f01039ac:	83 3a 00             	cmpl   $0x0,(%edx)
f01039af:	74 e0                	je     f0103991 <debuginfo_eip+0x1a8>
f01039b1:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01039b4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01039b7:	eb 75                	jmp    f0103a2e <debuginfo_eip+0x245>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01039b9:	03 45 bc             	add    -0x44(%ebp),%eax
f01039bc:	89 03                	mov    %eax,(%ebx)
f01039be:	eb 03                	jmp    f01039c3 <debuginfo_eip+0x1da>
f01039c0:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01039c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01039c6:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01039c9:	39 f2                	cmp    %esi,%edx
f01039cb:	7d 47                	jge    f0103a14 <debuginfo_eip+0x22b>
		for (lline = lfun + 1;
f01039cd:	42                   	inc    %edx
f01039ce:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01039d1:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01039d3:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01039d6:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01039d9:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01039dd:	eb 03                	jmp    f01039e2 <debuginfo_eip+0x1f9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01039df:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01039e2:	39 f0                	cmp    %esi,%eax
f01039e4:	7d 35                	jge    f0103a1b <debuginfo_eip+0x232>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01039e6:	8a 0a                	mov    (%edx),%cl
f01039e8:	40                   	inc    %eax
f01039e9:	83 c2 0c             	add    $0xc,%edx
f01039ec:	80 f9 a0             	cmp    $0xa0,%cl
f01039ef:	74 ee                	je     f01039df <debuginfo_eip+0x1f6>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01039f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01039f6:	eb 28                	jmp    f0103a20 <debuginfo_eip+0x237>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01039f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01039fd:	eb 21                	jmp    f0103a20 <debuginfo_eip+0x237>
f01039ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a04:	eb 1a                	jmp    f0103a20 <debuginfo_eip+0x237>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103a06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a0b:	eb 13                	jmp    f0103a20 <debuginfo_eip+0x237>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
		return -1;
f0103a0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103a12:	eb 0c                	jmp    f0103a20 <debuginfo_eip+0x237>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103a14:	b8 00 00 00 00       	mov    $0x0,%eax
f0103a19:	eb 05                	jmp    f0103a20 <debuginfo_eip+0x237>
f0103a1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103a20:	83 c4 5c             	add    $0x5c,%esp
f0103a23:	5b                   	pop    %ebx
f0103a24:	5e                   	pop    %esi
f0103a25:	5f                   	pop    %edi
f0103a26:	5d                   	pop    %ebp
f0103a27:	c3                   	ret    
f0103a28:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103a2b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0103a2e:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0103a31:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0103a34:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0103a37:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0103a3a:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0103a3d:	39 d0                	cmp    %edx,%eax
f0103a3f:	0f 82 74 ff ff ff    	jb     f01039b9 <debuginfo_eip+0x1d0>
f0103a45:	e9 79 ff ff ff       	jmp    f01039c3 <debuginfo_eip+0x1da>
	...

f0103a4c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103a4c:	55                   	push   %ebp
f0103a4d:	89 e5                	mov    %esp,%ebp
f0103a4f:	57                   	push   %edi
f0103a50:	56                   	push   %esi
f0103a51:	53                   	push   %ebx
f0103a52:	83 ec 3c             	sub    $0x3c,%esp
f0103a55:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103a58:	89 d7                	mov    %edx,%edi
f0103a5a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a5d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103a60:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103a63:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103a66:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103a69:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103a6c:	85 c0                	test   %eax,%eax
f0103a6e:	75 08                	jne    f0103a78 <printnum+0x2c>
f0103a70:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a73:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103a76:	77 57                	ja     f0103acf <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103a78:	89 74 24 10          	mov    %esi,0x10(%esp)
f0103a7c:	4b                   	dec    %ebx
f0103a7d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103a81:	8b 45 10             	mov    0x10(%ebp),%eax
f0103a84:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103a88:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0103a8c:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0103a90:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103a97:	00 
f0103a98:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103a9b:	89 04 24             	mov    %eax,(%esp)
f0103a9e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aa5:	e8 1e 09 00 00       	call   f01043c8 <__udivdi3>
f0103aaa:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103aae:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103ab2:	89 04 24             	mov    %eax,(%esp)
f0103ab5:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103ab9:	89 fa                	mov    %edi,%edx
f0103abb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103abe:	e8 89 ff ff ff       	call   f0103a4c <printnum>
f0103ac3:	eb 0f                	jmp    f0103ad4 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103ac5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103ac9:	89 34 24             	mov    %esi,(%esp)
f0103acc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103acf:	4b                   	dec    %ebx
f0103ad0:	85 db                	test   %ebx,%ebx
f0103ad2:	7f f1                	jg     f0103ac5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103ad4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103ad8:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103adc:	8b 45 10             	mov    0x10(%ebp),%eax
f0103adf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ae3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103aea:	00 
f0103aeb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103aee:	89 04 24             	mov    %eax,(%esp)
f0103af1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103af4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103af8:	e8 eb 09 00 00       	call   f01044e8 <__umoddi3>
f0103afd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103b01:	0f be 80 e1 5a 10 f0 	movsbl -0xfefa51f(%eax),%eax
f0103b08:	89 04 24             	mov    %eax,(%esp)
f0103b0b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0103b0e:	83 c4 3c             	add    $0x3c,%esp
f0103b11:	5b                   	pop    %ebx
f0103b12:	5e                   	pop    %esi
f0103b13:	5f                   	pop    %edi
f0103b14:	5d                   	pop    %ebp
f0103b15:	c3                   	ret    

f0103b16 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103b16:	55                   	push   %ebp
f0103b17:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103b19:	83 fa 01             	cmp    $0x1,%edx
f0103b1c:	7e 0e                	jle    f0103b2c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0103b1e:	8b 10                	mov    (%eax),%edx
f0103b20:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103b23:	89 08                	mov    %ecx,(%eax)
f0103b25:	8b 02                	mov    (%edx),%eax
f0103b27:	8b 52 04             	mov    0x4(%edx),%edx
f0103b2a:	eb 22                	jmp    f0103b4e <getuint+0x38>
	else if (lflag)
f0103b2c:	85 d2                	test   %edx,%edx
f0103b2e:	74 10                	je     f0103b40 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103b30:	8b 10                	mov    (%eax),%edx
f0103b32:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103b35:	89 08                	mov    %ecx,(%eax)
f0103b37:	8b 02                	mov    (%edx),%eax
f0103b39:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b3e:	eb 0e                	jmp    f0103b4e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103b40:	8b 10                	mov    (%eax),%edx
f0103b42:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103b45:	89 08                	mov    %ecx,(%eax)
f0103b47:	8b 02                	mov    (%edx),%eax
f0103b49:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0103b4e:	5d                   	pop    %ebp
f0103b4f:	c3                   	ret    

f0103b50 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103b50:	55                   	push   %ebp
f0103b51:	89 e5                	mov    %esp,%ebp
f0103b53:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103b56:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103b59:	8b 10                	mov    (%eax),%edx
f0103b5b:	3b 50 04             	cmp    0x4(%eax),%edx
f0103b5e:	73 08                	jae    f0103b68 <sprintputch+0x18>
		*b->buf++ = ch;
f0103b60:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103b63:	88 0a                	mov    %cl,(%edx)
f0103b65:	42                   	inc    %edx
f0103b66:	89 10                	mov    %edx,(%eax)
}
f0103b68:	5d                   	pop    %ebp
f0103b69:	c3                   	ret    

f0103b6a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103b6a:	55                   	push   %ebp
f0103b6b:	89 e5                	mov    %esp,%ebp
f0103b6d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103b70:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103b73:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b77:	8b 45 10             	mov    0x10(%ebp),%eax
f0103b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b81:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b85:	8b 45 08             	mov    0x8(%ebp),%eax
f0103b88:	89 04 24             	mov    %eax,(%esp)
f0103b8b:	e8 02 00 00 00       	call   f0103b92 <vprintfmt>
	va_end(ap);
}
f0103b90:	c9                   	leave  
f0103b91:	c3                   	ret    

f0103b92 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103b92:	55                   	push   %ebp
f0103b93:	89 e5                	mov    %esp,%ebp
f0103b95:	57                   	push   %edi
f0103b96:	56                   	push   %esi
f0103b97:	53                   	push   %ebx
f0103b98:	83 ec 4c             	sub    $0x4c,%esp
f0103b9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103b9e:	8b 75 10             	mov    0x10(%ebp),%esi
f0103ba1:	eb 12                	jmp    f0103bb5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103ba3:	85 c0                	test   %eax,%eax
f0103ba5:	0f 84 6b 03 00 00    	je     f0103f16 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f0103bab:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103baf:	89 04 24             	mov    %eax,(%esp)
f0103bb2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103bb5:	0f b6 06             	movzbl (%esi),%eax
f0103bb8:	46                   	inc    %esi
f0103bb9:	83 f8 25             	cmp    $0x25,%eax
f0103bbc:	75 e5                	jne    f0103ba3 <vprintfmt+0x11>
f0103bbe:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0103bc2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103bc9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f0103bce:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103bd5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103bda:	eb 26                	jmp    f0103c02 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103bdc:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103bdf:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0103be3:	eb 1d                	jmp    f0103c02 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103be5:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103be8:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103bec:	eb 14                	jmp    f0103c02 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103bee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103bf1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103bf8:	eb 08                	jmp    f0103c02 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103bfa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103bfd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c02:	0f b6 06             	movzbl (%esi),%eax
f0103c05:	8d 56 01             	lea    0x1(%esi),%edx
f0103c08:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103c0b:	8a 16                	mov    (%esi),%dl
f0103c0d:	83 ea 23             	sub    $0x23,%edx
f0103c10:	80 fa 55             	cmp    $0x55,%dl
f0103c13:	0f 87 e1 02 00 00    	ja     f0103efa <vprintfmt+0x368>
f0103c19:	0f b6 d2             	movzbl %dl,%edx
f0103c1c:	ff 24 95 6c 5b 10 f0 	jmp    *-0xfefa494(,%edx,4)
f0103c23:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103c26:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103c2b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f0103c2e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103c32:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103c35:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103c38:	83 fa 09             	cmp    $0x9,%edx
f0103c3b:	77 2a                	ja     f0103c67 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103c3d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103c3e:	eb eb                	jmp    f0103c2b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103c40:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c43:	8d 50 04             	lea    0x4(%eax),%edx
f0103c46:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c49:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c4b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103c4e:	eb 17                	jmp    f0103c67 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0103c50:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103c54:	78 98                	js     f0103bee <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c56:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103c59:	eb a7                	jmp    f0103c02 <vprintfmt+0x70>
f0103c5b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103c5e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103c65:	eb 9b                	jmp    f0103c02 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0103c67:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103c6b:	79 95                	jns    f0103c02 <vprintfmt+0x70>
f0103c6d:	eb 8b                	jmp    f0103bfa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103c6f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c70:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103c73:	eb 8d                	jmp    f0103c02 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103c75:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c78:	8d 50 04             	lea    0x4(%eax),%edx
f0103c7b:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c7e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103c82:	8b 00                	mov    (%eax),%eax
f0103c84:	89 04 24             	mov    %eax,(%esp)
f0103c87:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103c8a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103c8d:	e9 23 ff ff ff       	jmp    f0103bb5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103c92:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c95:	8d 50 04             	lea    0x4(%eax),%edx
f0103c98:	89 55 14             	mov    %edx,0x14(%ebp)
f0103c9b:	8b 00                	mov    (%eax),%eax
f0103c9d:	85 c0                	test   %eax,%eax
f0103c9f:	79 02                	jns    f0103ca3 <vprintfmt+0x111>
f0103ca1:	f7 d8                	neg    %eax
f0103ca3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103ca5:	83 f8 06             	cmp    $0x6,%eax
f0103ca8:	7f 0b                	jg     f0103cb5 <vprintfmt+0x123>
f0103caa:	8b 04 85 c4 5c 10 f0 	mov    -0xfefa33c(,%eax,4),%eax
f0103cb1:	85 c0                	test   %eax,%eax
f0103cb3:	75 23                	jne    f0103cd8 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0103cb5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103cb9:	c7 44 24 08 f9 5a 10 	movl   $0xf0105af9,0x8(%esp)
f0103cc0:	f0 
f0103cc1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103cc5:	8b 45 08             	mov    0x8(%ebp),%eax
f0103cc8:	89 04 24             	mov    %eax,(%esp)
f0103ccb:	e8 9a fe ff ff       	call   f0103b6a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cd0:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103cd3:	e9 dd fe ff ff       	jmp    f0103bb5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103cd8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103cdc:	c7 44 24 08 b4 53 10 	movl   $0xf01053b4,0x8(%esp)
f0103ce3:	f0 
f0103ce4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103ce8:	8b 55 08             	mov    0x8(%ebp),%edx
f0103ceb:	89 14 24             	mov    %edx,(%esp)
f0103cee:	e8 77 fe ff ff       	call   f0103b6a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103cf3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103cf6:	e9 ba fe ff ff       	jmp    f0103bb5 <vprintfmt+0x23>
f0103cfb:	89 f9                	mov    %edi,%ecx
f0103cfd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d00:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103d03:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d06:	8d 50 04             	lea    0x4(%eax),%edx
f0103d09:	89 55 14             	mov    %edx,0x14(%ebp)
f0103d0c:	8b 30                	mov    (%eax),%esi
f0103d0e:	85 f6                	test   %esi,%esi
f0103d10:	75 05                	jne    f0103d17 <vprintfmt+0x185>
				p = "(null)";
f0103d12:	be f2 5a 10 f0       	mov    $0xf0105af2,%esi
			if (width > 0 && padc != '-')
f0103d17:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103d1b:	0f 8e 84 00 00 00    	jle    f0103da5 <vprintfmt+0x213>
f0103d21:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103d25:	74 7e                	je     f0103da5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d27:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103d2b:	89 34 24             	mov    %esi,(%esp)
f0103d2e:	e8 53 03 00 00       	call   f0104086 <strnlen>
f0103d33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103d36:	29 c2                	sub    %eax,%edx
f0103d38:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0103d3b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f0103d3f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103d42:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0103d45:	89 de                	mov    %ebx,%esi
f0103d47:	89 d3                	mov    %edx,%ebx
f0103d49:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d4b:	eb 0b                	jmp    f0103d58 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0103d4d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d51:	89 3c 24             	mov    %edi,(%esp)
f0103d54:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103d57:	4b                   	dec    %ebx
f0103d58:	85 db                	test   %ebx,%ebx
f0103d5a:	7f f1                	jg     f0103d4d <vprintfmt+0x1bb>
f0103d5c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103d5f:	89 f3                	mov    %esi,%ebx
f0103d61:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0103d64:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103d67:	85 c0                	test   %eax,%eax
f0103d69:	79 05                	jns    f0103d70 <vprintfmt+0x1de>
f0103d6b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103d70:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103d73:	29 c2                	sub    %eax,%edx
f0103d75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103d78:	eb 2b                	jmp    f0103da5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103d7a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103d7e:	74 18                	je     f0103d98 <vprintfmt+0x206>
f0103d80:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103d83:	83 fa 5e             	cmp    $0x5e,%edx
f0103d86:	76 10                	jbe    f0103d98 <vprintfmt+0x206>
					putch('?', putdat);
f0103d88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d8c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103d93:	ff 55 08             	call   *0x8(%ebp)
f0103d96:	eb 0a                	jmp    f0103da2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0103d98:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103d9c:	89 04 24             	mov    %eax,(%esp)
f0103d9f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103da2:	ff 4d e4             	decl   -0x1c(%ebp)
f0103da5:	0f be 06             	movsbl (%esi),%eax
f0103da8:	46                   	inc    %esi
f0103da9:	85 c0                	test   %eax,%eax
f0103dab:	74 21                	je     f0103dce <vprintfmt+0x23c>
f0103dad:	85 ff                	test   %edi,%edi
f0103daf:	78 c9                	js     f0103d7a <vprintfmt+0x1e8>
f0103db1:	4f                   	dec    %edi
f0103db2:	79 c6                	jns    f0103d7a <vprintfmt+0x1e8>
f0103db4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103db7:	89 de                	mov    %ebx,%esi
f0103db9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103dbc:	eb 18                	jmp    f0103dd6 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103dbe:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103dc2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103dc9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103dcb:	4b                   	dec    %ebx
f0103dcc:	eb 08                	jmp    f0103dd6 <vprintfmt+0x244>
f0103dce:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103dd1:	89 de                	mov    %ebx,%esi
f0103dd3:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103dd6:	85 db                	test   %ebx,%ebx
f0103dd8:	7f e4                	jg     f0103dbe <vprintfmt+0x22c>
f0103dda:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103ddd:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ddf:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103de2:	e9 ce fd ff ff       	jmp    f0103bb5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103de7:	83 f9 01             	cmp    $0x1,%ecx
f0103dea:	7e 10                	jle    f0103dfc <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0103dec:	8b 45 14             	mov    0x14(%ebp),%eax
f0103def:	8d 50 08             	lea    0x8(%eax),%edx
f0103df2:	89 55 14             	mov    %edx,0x14(%ebp)
f0103df5:	8b 30                	mov    (%eax),%esi
f0103df7:	8b 78 04             	mov    0x4(%eax),%edi
f0103dfa:	eb 26                	jmp    f0103e22 <vprintfmt+0x290>
	else if (lflag)
f0103dfc:	85 c9                	test   %ecx,%ecx
f0103dfe:	74 12                	je     f0103e12 <vprintfmt+0x280>
		return va_arg(*ap, long);
f0103e00:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e03:	8d 50 04             	lea    0x4(%eax),%edx
f0103e06:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e09:	8b 30                	mov    (%eax),%esi
f0103e0b:	89 f7                	mov    %esi,%edi
f0103e0d:	c1 ff 1f             	sar    $0x1f,%edi
f0103e10:	eb 10                	jmp    f0103e22 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0103e12:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e15:	8d 50 04             	lea    0x4(%eax),%edx
f0103e18:	89 55 14             	mov    %edx,0x14(%ebp)
f0103e1b:	8b 30                	mov    (%eax),%esi
f0103e1d:	89 f7                	mov    %esi,%edi
f0103e1f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103e22:	85 ff                	test   %edi,%edi
f0103e24:	78 0a                	js     f0103e30 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103e26:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e2b:	e9 8c 00 00 00       	jmp    f0103ebc <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103e30:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e34:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103e3b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f0103e3e:	f7 de                	neg    %esi
f0103e40:	83 d7 00             	adc    $0x0,%edi
f0103e43:	f7 df                	neg    %edi
			}
			base = 10;
f0103e45:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103e4a:	eb 70                	jmp    f0103ebc <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103e4c:	89 ca                	mov    %ecx,%edx
f0103e4e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103e51:	e8 c0 fc ff ff       	call   f0103b16 <getuint>
f0103e56:	89 c6                	mov    %eax,%esi
f0103e58:	89 d7                	mov    %edx,%edi
			base = 10;
f0103e5a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f0103e5f:	eb 5b                	jmp    f0103ebc <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0103e61:	89 ca                	mov    %ecx,%edx
f0103e63:	8d 45 14             	lea    0x14(%ebp),%eax
f0103e66:	e8 ab fc ff ff       	call   f0103b16 <getuint>
f0103e6b:	89 c6                	mov    %eax,%esi
f0103e6d:	89 d7                	mov    %edx,%edi
			base = 8;
f0103e6f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0103e74:	eb 46                	jmp    f0103ebc <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f0103e76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e7a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103e81:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103e84:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e88:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0103e8f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103e92:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e95:	8d 50 04             	lea    0x4(%eax),%edx
f0103e98:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103e9b:	8b 30                	mov    (%eax),%esi
f0103e9d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103ea2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103ea7:	eb 13                	jmp    f0103ebc <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103ea9:	89 ca                	mov    %ecx,%edx
f0103eab:	8d 45 14             	lea    0x14(%ebp),%eax
f0103eae:	e8 63 fc ff ff       	call   f0103b16 <getuint>
f0103eb3:	89 c6                	mov    %eax,%esi
f0103eb5:	89 d7                	mov    %edx,%edi
			base = 16;
f0103eb7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103ebc:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0103ec0:	89 54 24 10          	mov    %edx,0x10(%esp)
f0103ec4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103ec7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103ecb:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103ecf:	89 34 24             	mov    %esi,(%esp)
f0103ed2:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103ed6:	89 da                	mov    %ebx,%edx
f0103ed8:	8b 45 08             	mov    0x8(%ebp),%eax
f0103edb:	e8 6c fb ff ff       	call   f0103a4c <printnum>
			break;
f0103ee0:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103ee3:	e9 cd fc ff ff       	jmp    f0103bb5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103ee8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103eec:	89 04 24             	mov    %eax,(%esp)
f0103eef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ef2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103ef5:	e9 bb fc ff ff       	jmp    f0103bb5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103efa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103efe:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103f05:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103f08:	eb 01                	jmp    f0103f0b <vprintfmt+0x379>
f0103f0a:	4e                   	dec    %esi
f0103f0b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f0103f0f:	75 f9                	jne    f0103f0a <vprintfmt+0x378>
f0103f11:	e9 9f fc ff ff       	jmp    f0103bb5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103f16:	83 c4 4c             	add    $0x4c,%esp
f0103f19:	5b                   	pop    %ebx
f0103f1a:	5e                   	pop    %esi
f0103f1b:	5f                   	pop    %edi
f0103f1c:	5d                   	pop    %ebp
f0103f1d:	c3                   	ret    

f0103f1e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103f1e:	55                   	push   %ebp
f0103f1f:	89 e5                	mov    %esp,%ebp
f0103f21:	83 ec 28             	sub    $0x28,%esp
f0103f24:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f27:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103f2a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103f2d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103f31:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103f34:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103f3b:	85 c0                	test   %eax,%eax
f0103f3d:	74 30                	je     f0103f6f <vsnprintf+0x51>
f0103f3f:	85 d2                	test   %edx,%edx
f0103f41:	7e 33                	jle    f0103f76 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103f43:	8b 45 14             	mov    0x14(%ebp),%eax
f0103f46:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f4a:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f4d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f51:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103f54:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f58:	c7 04 24 50 3b 10 f0 	movl   $0xf0103b50,(%esp)
f0103f5f:	e8 2e fc ff ff       	call   f0103b92 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103f64:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f67:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103f6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f6d:	eb 0c                	jmp    f0103f7b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103f6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103f74:	eb 05                	jmp    f0103f7b <vsnprintf+0x5d>
f0103f76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103f7b:	c9                   	leave  
f0103f7c:	c3                   	ret    

f0103f7d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103f7d:	55                   	push   %ebp
f0103f7e:	89 e5                	mov    %esp,%ebp
f0103f80:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103f83:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103f86:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f8a:	8b 45 10             	mov    0x10(%ebp),%eax
f0103f8d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f91:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f94:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f98:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f9b:	89 04 24             	mov    %eax,(%esp)
f0103f9e:	e8 7b ff ff ff       	call   f0103f1e <vsnprintf>
	va_end(ap);

	return rc;
}
f0103fa3:	c9                   	leave  
f0103fa4:	c3                   	ret    
f0103fa5:	00 00                	add    %al,(%eax)
	...

f0103fa8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103fa8:	55                   	push   %ebp
f0103fa9:	89 e5                	mov    %esp,%ebp
f0103fab:	57                   	push   %edi
f0103fac:	56                   	push   %esi
f0103fad:	53                   	push   %ebx
f0103fae:	83 ec 1c             	sub    $0x1c,%esp
f0103fb1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103fb4:	85 c0                	test   %eax,%eax
f0103fb6:	74 10                	je     f0103fc8 <readline+0x20>
		cprintf("%s", prompt);
f0103fb8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fbc:	c7 04 24 b4 53 10 f0 	movl   $0xf01053b4,(%esp)
f0103fc3:	e8 fe f2 ff ff       	call   f01032c6 <cprintf>

	i = 0;
	echoing = iscons(0);
f0103fc8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103fcf:	e8 25 c6 ff ff       	call   f01005f9 <iscons>
f0103fd4:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103fd6:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103fdb:	e8 08 c6 ff ff       	call   f01005e8 <getchar>
f0103fe0:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103fe2:	85 c0                	test   %eax,%eax
f0103fe4:	79 17                	jns    f0103ffd <readline+0x55>
			cprintf("read error: %e\n", c);
f0103fe6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fea:	c7 04 24 e0 5c 10 f0 	movl   $0xf0105ce0,(%esp)
f0103ff1:	e8 d0 f2 ff ff       	call   f01032c6 <cprintf>
			return NULL;
f0103ff6:	b8 00 00 00 00       	mov    $0x0,%eax
f0103ffb:	eb 69                	jmp    f0104066 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103ffd:	83 f8 08             	cmp    $0x8,%eax
f0104000:	74 05                	je     f0104007 <readline+0x5f>
f0104002:	83 f8 7f             	cmp    $0x7f,%eax
f0104005:	75 17                	jne    f010401e <readline+0x76>
f0104007:	85 f6                	test   %esi,%esi
f0104009:	7e 13                	jle    f010401e <readline+0x76>
			if (echoing)
f010400b:	85 ff                	test   %edi,%edi
f010400d:	74 0c                	je     f010401b <readline+0x73>
				cputchar('\b');
f010400f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104016:	e8 bd c5 ff ff       	call   f01005d8 <cputchar>
			i--;
f010401b:	4e                   	dec    %esi
f010401c:	eb bd                	jmp    f0103fdb <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010401e:	83 fb 1f             	cmp    $0x1f,%ebx
f0104021:	7e 1d                	jle    f0104040 <readline+0x98>
f0104023:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104029:	7f 15                	jg     f0104040 <readline+0x98>
			if (echoing)
f010402b:	85 ff                	test   %edi,%edi
f010402d:	74 08                	je     f0104037 <readline+0x8f>
				cputchar(c);
f010402f:	89 1c 24             	mov    %ebx,(%esp)
f0104032:	e8 a1 c5 ff ff       	call   f01005d8 <cputchar>
			buf[i++] = c;
f0104037:	88 9e 40 0a 1e f0    	mov    %bl,-0xfe1f5c0(%esi)
f010403d:	46                   	inc    %esi
f010403e:	eb 9b                	jmp    f0103fdb <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0104040:	83 fb 0a             	cmp    $0xa,%ebx
f0104043:	74 05                	je     f010404a <readline+0xa2>
f0104045:	83 fb 0d             	cmp    $0xd,%ebx
f0104048:	75 91                	jne    f0103fdb <readline+0x33>
			if (echoing)
f010404a:	85 ff                	test   %edi,%edi
f010404c:	74 0c                	je     f010405a <readline+0xb2>
				cputchar('\n');
f010404e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104055:	e8 7e c5 ff ff       	call   f01005d8 <cputchar>
			buf[i] = 0;
f010405a:	c6 86 40 0a 1e f0 00 	movb   $0x0,-0xfe1f5c0(%esi)
			return buf;
f0104061:	b8 40 0a 1e f0       	mov    $0xf01e0a40,%eax
		}
	}
}
f0104066:	83 c4 1c             	add    $0x1c,%esp
f0104069:	5b                   	pop    %ebx
f010406a:	5e                   	pop    %esi
f010406b:	5f                   	pop    %edi
f010406c:	5d                   	pop    %ebp
f010406d:	c3                   	ret    
	...

f0104070 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104070:	55                   	push   %ebp
f0104071:	89 e5                	mov    %esp,%ebp
f0104073:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104076:	b8 00 00 00 00       	mov    $0x0,%eax
f010407b:	eb 01                	jmp    f010407e <strlen+0xe>
		n++;
f010407d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010407e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104082:	75 f9                	jne    f010407d <strlen+0xd>
		n++;
	return n;
}
f0104084:	5d                   	pop    %ebp
f0104085:	c3                   	ret    

f0104086 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104086:	55                   	push   %ebp
f0104087:	89 e5                	mov    %esp,%ebp
f0104089:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f010408c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010408f:	b8 00 00 00 00       	mov    $0x0,%eax
f0104094:	eb 01                	jmp    f0104097 <strnlen+0x11>
		n++;
f0104096:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104097:	39 d0                	cmp    %edx,%eax
f0104099:	74 06                	je     f01040a1 <strnlen+0x1b>
f010409b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010409f:	75 f5                	jne    f0104096 <strnlen+0x10>
		n++;
	return n;
}
f01040a1:	5d                   	pop    %ebp
f01040a2:	c3                   	ret    

f01040a3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01040a3:	55                   	push   %ebp
f01040a4:	89 e5                	mov    %esp,%ebp
f01040a6:	53                   	push   %ebx
f01040a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01040aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01040ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01040b2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01040b5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01040b8:	42                   	inc    %edx
f01040b9:	84 c9                	test   %cl,%cl
f01040bb:	75 f5                	jne    f01040b2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01040bd:	5b                   	pop    %ebx
f01040be:	5d                   	pop    %ebp
f01040bf:	c3                   	ret    

f01040c0 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01040c0:	55                   	push   %ebp
f01040c1:	89 e5                	mov    %esp,%ebp
f01040c3:	53                   	push   %ebx
f01040c4:	83 ec 08             	sub    $0x8,%esp
f01040c7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01040ca:	89 1c 24             	mov    %ebx,(%esp)
f01040cd:	e8 9e ff ff ff       	call   f0104070 <strlen>
	strcpy(dst + len, src);
f01040d2:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040d5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01040d9:	01 d8                	add    %ebx,%eax
f01040db:	89 04 24             	mov    %eax,(%esp)
f01040de:	e8 c0 ff ff ff       	call   f01040a3 <strcpy>
	return dst;
}
f01040e3:	89 d8                	mov    %ebx,%eax
f01040e5:	83 c4 08             	add    $0x8,%esp
f01040e8:	5b                   	pop    %ebx
f01040e9:	5d                   	pop    %ebp
f01040ea:	c3                   	ret    

f01040eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01040eb:	55                   	push   %ebp
f01040ec:	89 e5                	mov    %esp,%ebp
f01040ee:	56                   	push   %esi
f01040ef:	53                   	push   %ebx
f01040f0:	8b 45 08             	mov    0x8(%ebp),%eax
f01040f3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01040f6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01040f9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01040fe:	eb 0c                	jmp    f010410c <strncpy+0x21>
		*dst++ = *src;
f0104100:	8a 1a                	mov    (%edx),%bl
f0104102:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104105:	80 3a 01             	cmpb   $0x1,(%edx)
f0104108:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010410b:	41                   	inc    %ecx
f010410c:	39 f1                	cmp    %esi,%ecx
f010410e:	75 f0                	jne    f0104100 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104110:	5b                   	pop    %ebx
f0104111:	5e                   	pop    %esi
f0104112:	5d                   	pop    %ebp
f0104113:	c3                   	ret    

f0104114 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104114:	55                   	push   %ebp
f0104115:	89 e5                	mov    %esp,%ebp
f0104117:	56                   	push   %esi
f0104118:	53                   	push   %ebx
f0104119:	8b 75 08             	mov    0x8(%ebp),%esi
f010411c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010411f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104122:	85 d2                	test   %edx,%edx
f0104124:	75 0a                	jne    f0104130 <strlcpy+0x1c>
f0104126:	89 f0                	mov    %esi,%eax
f0104128:	eb 1a                	jmp    f0104144 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010412a:	88 18                	mov    %bl,(%eax)
f010412c:	40                   	inc    %eax
f010412d:	41                   	inc    %ecx
f010412e:	eb 02                	jmp    f0104132 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104130:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0104132:	4a                   	dec    %edx
f0104133:	74 0a                	je     f010413f <strlcpy+0x2b>
f0104135:	8a 19                	mov    (%ecx),%bl
f0104137:	84 db                	test   %bl,%bl
f0104139:	75 ef                	jne    f010412a <strlcpy+0x16>
f010413b:	89 c2                	mov    %eax,%edx
f010413d:	eb 02                	jmp    f0104141 <strlcpy+0x2d>
f010413f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104141:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104144:	29 f0                	sub    %esi,%eax
}
f0104146:	5b                   	pop    %ebx
f0104147:	5e                   	pop    %esi
f0104148:	5d                   	pop    %ebp
f0104149:	c3                   	ret    

f010414a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010414a:	55                   	push   %ebp
f010414b:	89 e5                	mov    %esp,%ebp
f010414d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104150:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104153:	eb 02                	jmp    f0104157 <strcmp+0xd>
		p++, q++;
f0104155:	41                   	inc    %ecx
f0104156:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104157:	8a 01                	mov    (%ecx),%al
f0104159:	84 c0                	test   %al,%al
f010415b:	74 04                	je     f0104161 <strcmp+0x17>
f010415d:	3a 02                	cmp    (%edx),%al
f010415f:	74 f4                	je     f0104155 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104161:	0f b6 c0             	movzbl %al,%eax
f0104164:	0f b6 12             	movzbl (%edx),%edx
f0104167:	29 d0                	sub    %edx,%eax
}
f0104169:	5d                   	pop    %ebp
f010416a:	c3                   	ret    

f010416b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010416b:	55                   	push   %ebp
f010416c:	89 e5                	mov    %esp,%ebp
f010416e:	53                   	push   %ebx
f010416f:	8b 45 08             	mov    0x8(%ebp),%eax
f0104172:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104175:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0104178:	eb 03                	jmp    f010417d <strncmp+0x12>
		n--, p++, q++;
f010417a:	4a                   	dec    %edx
f010417b:	40                   	inc    %eax
f010417c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010417d:	85 d2                	test   %edx,%edx
f010417f:	74 14                	je     f0104195 <strncmp+0x2a>
f0104181:	8a 18                	mov    (%eax),%bl
f0104183:	84 db                	test   %bl,%bl
f0104185:	74 04                	je     f010418b <strncmp+0x20>
f0104187:	3a 19                	cmp    (%ecx),%bl
f0104189:	74 ef                	je     f010417a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010418b:	0f b6 00             	movzbl (%eax),%eax
f010418e:	0f b6 11             	movzbl (%ecx),%edx
f0104191:	29 d0                	sub    %edx,%eax
f0104193:	eb 05                	jmp    f010419a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104195:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010419a:	5b                   	pop    %ebx
f010419b:	5d                   	pop    %ebp
f010419c:	c3                   	ret    

f010419d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010419d:	55                   	push   %ebp
f010419e:	89 e5                	mov    %esp,%ebp
f01041a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01041a3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01041a6:	eb 05                	jmp    f01041ad <strchr+0x10>
		if (*s == c)
f01041a8:	38 ca                	cmp    %cl,%dl
f01041aa:	74 0c                	je     f01041b8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01041ac:	40                   	inc    %eax
f01041ad:	8a 10                	mov    (%eax),%dl
f01041af:	84 d2                	test   %dl,%dl
f01041b1:	75 f5                	jne    f01041a8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01041b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01041b8:	5d                   	pop    %ebp
f01041b9:	c3                   	ret    

f01041ba <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01041ba:	55                   	push   %ebp
f01041bb:	89 e5                	mov    %esp,%ebp
f01041bd:	8b 45 08             	mov    0x8(%ebp),%eax
f01041c0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01041c3:	eb 05                	jmp    f01041ca <strfind+0x10>
		if (*s == c)
f01041c5:	38 ca                	cmp    %cl,%dl
f01041c7:	74 07                	je     f01041d0 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01041c9:	40                   	inc    %eax
f01041ca:	8a 10                	mov    (%eax),%dl
f01041cc:	84 d2                	test   %dl,%dl
f01041ce:	75 f5                	jne    f01041c5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01041d0:	5d                   	pop    %ebp
f01041d1:	c3                   	ret    

f01041d2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01041d2:	55                   	push   %ebp
f01041d3:	89 e5                	mov    %esp,%ebp
f01041d5:	57                   	push   %edi
f01041d6:	56                   	push   %esi
f01041d7:	53                   	push   %ebx
f01041d8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041db:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01041e1:	85 c9                	test   %ecx,%ecx
f01041e3:	74 30                	je     f0104215 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01041e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01041eb:	75 25                	jne    f0104212 <memset+0x40>
f01041ed:	f6 c1 03             	test   $0x3,%cl
f01041f0:	75 20                	jne    f0104212 <memset+0x40>
		c &= 0xFF;
f01041f2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01041f5:	89 d3                	mov    %edx,%ebx
f01041f7:	c1 e3 08             	shl    $0x8,%ebx
f01041fa:	89 d6                	mov    %edx,%esi
f01041fc:	c1 e6 18             	shl    $0x18,%esi
f01041ff:	89 d0                	mov    %edx,%eax
f0104201:	c1 e0 10             	shl    $0x10,%eax
f0104204:	09 f0                	or     %esi,%eax
f0104206:	09 d0                	or     %edx,%eax
f0104208:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010420a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010420d:	fc                   	cld    
f010420e:	f3 ab                	rep stos %eax,%es:(%edi)
f0104210:	eb 03                	jmp    f0104215 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104212:	fc                   	cld    
f0104213:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104215:	89 f8                	mov    %edi,%eax
f0104217:	5b                   	pop    %ebx
f0104218:	5e                   	pop    %esi
f0104219:	5f                   	pop    %edi
f010421a:	5d                   	pop    %ebp
f010421b:	c3                   	ret    

f010421c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010421c:	55                   	push   %ebp
f010421d:	89 e5                	mov    %esp,%ebp
f010421f:	57                   	push   %edi
f0104220:	56                   	push   %esi
f0104221:	8b 45 08             	mov    0x8(%ebp),%eax
f0104224:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104227:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010422a:	39 c6                	cmp    %eax,%esi
f010422c:	73 34                	jae    f0104262 <memmove+0x46>
f010422e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104231:	39 d0                	cmp    %edx,%eax
f0104233:	73 2d                	jae    f0104262 <memmove+0x46>
		s += n;
		d += n;
f0104235:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104238:	f6 c2 03             	test   $0x3,%dl
f010423b:	75 1b                	jne    f0104258 <memmove+0x3c>
f010423d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104243:	75 13                	jne    f0104258 <memmove+0x3c>
f0104245:	f6 c1 03             	test   $0x3,%cl
f0104248:	75 0e                	jne    f0104258 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010424a:	83 ef 04             	sub    $0x4,%edi
f010424d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104250:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104253:	fd                   	std    
f0104254:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104256:	eb 07                	jmp    f010425f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104258:	4f                   	dec    %edi
f0104259:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010425c:	fd                   	std    
f010425d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010425f:	fc                   	cld    
f0104260:	eb 20                	jmp    f0104282 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104262:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104268:	75 13                	jne    f010427d <memmove+0x61>
f010426a:	a8 03                	test   $0x3,%al
f010426c:	75 0f                	jne    f010427d <memmove+0x61>
f010426e:	f6 c1 03             	test   $0x3,%cl
f0104271:	75 0a                	jne    f010427d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104273:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104276:	89 c7                	mov    %eax,%edi
f0104278:	fc                   	cld    
f0104279:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010427b:	eb 05                	jmp    f0104282 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010427d:	89 c7                	mov    %eax,%edi
f010427f:	fc                   	cld    
f0104280:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104282:	5e                   	pop    %esi
f0104283:	5f                   	pop    %edi
f0104284:	5d                   	pop    %ebp
f0104285:	c3                   	ret    

f0104286 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104286:	55                   	push   %ebp
f0104287:	89 e5                	mov    %esp,%ebp
f0104289:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010428c:	8b 45 10             	mov    0x10(%ebp),%eax
f010428f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104293:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104296:	89 44 24 04          	mov    %eax,0x4(%esp)
f010429a:	8b 45 08             	mov    0x8(%ebp),%eax
f010429d:	89 04 24             	mov    %eax,(%esp)
f01042a0:	e8 77 ff ff ff       	call   f010421c <memmove>
}
f01042a5:	c9                   	leave  
f01042a6:	c3                   	ret    

f01042a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01042a7:	55                   	push   %ebp
f01042a8:	89 e5                	mov    %esp,%ebp
f01042aa:	57                   	push   %edi
f01042ab:	56                   	push   %esi
f01042ac:	53                   	push   %ebx
f01042ad:	8b 7d 08             	mov    0x8(%ebp),%edi
f01042b0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01042b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01042b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01042bb:	eb 16                	jmp    f01042d3 <memcmp+0x2c>
		if (*s1 != *s2)
f01042bd:	8a 04 17             	mov    (%edi,%edx,1),%al
f01042c0:	42                   	inc    %edx
f01042c1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01042c5:	38 c8                	cmp    %cl,%al
f01042c7:	74 0a                	je     f01042d3 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01042c9:	0f b6 c0             	movzbl %al,%eax
f01042cc:	0f b6 c9             	movzbl %cl,%ecx
f01042cf:	29 c8                	sub    %ecx,%eax
f01042d1:	eb 09                	jmp    f01042dc <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01042d3:	39 da                	cmp    %ebx,%edx
f01042d5:	75 e6                	jne    f01042bd <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01042d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042dc:	5b                   	pop    %ebx
f01042dd:	5e                   	pop    %esi
f01042de:	5f                   	pop    %edi
f01042df:	5d                   	pop    %ebp
f01042e0:	c3                   	ret    

f01042e1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01042e1:	55                   	push   %ebp
f01042e2:	89 e5                	mov    %esp,%ebp
f01042e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01042e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f01042ea:	89 c2                	mov    %eax,%edx
f01042ec:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01042ef:	eb 05                	jmp    f01042f6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01042f1:	38 08                	cmp    %cl,(%eax)
f01042f3:	74 05                	je     f01042fa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01042f5:	40                   	inc    %eax
f01042f6:	39 d0                	cmp    %edx,%eax
f01042f8:	72 f7                	jb     f01042f1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01042fa:	5d                   	pop    %ebp
f01042fb:	c3                   	ret    

f01042fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01042fc:	55                   	push   %ebp
f01042fd:	89 e5                	mov    %esp,%ebp
f01042ff:	57                   	push   %edi
f0104300:	56                   	push   %esi
f0104301:	53                   	push   %ebx
f0104302:	8b 55 08             	mov    0x8(%ebp),%edx
f0104305:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104308:	eb 01                	jmp    f010430b <strtol+0xf>
		s++;
f010430a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010430b:	8a 02                	mov    (%edx),%al
f010430d:	3c 20                	cmp    $0x20,%al
f010430f:	74 f9                	je     f010430a <strtol+0xe>
f0104311:	3c 09                	cmp    $0x9,%al
f0104313:	74 f5                	je     f010430a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104315:	3c 2b                	cmp    $0x2b,%al
f0104317:	75 08                	jne    f0104321 <strtol+0x25>
		s++;
f0104319:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010431a:	bf 00 00 00 00       	mov    $0x0,%edi
f010431f:	eb 13                	jmp    f0104334 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104321:	3c 2d                	cmp    $0x2d,%al
f0104323:	75 0a                	jne    f010432f <strtol+0x33>
		s++, neg = 1;
f0104325:	8d 52 01             	lea    0x1(%edx),%edx
f0104328:	bf 01 00 00 00       	mov    $0x1,%edi
f010432d:	eb 05                	jmp    f0104334 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010432f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104334:	85 db                	test   %ebx,%ebx
f0104336:	74 05                	je     f010433d <strtol+0x41>
f0104338:	83 fb 10             	cmp    $0x10,%ebx
f010433b:	75 28                	jne    f0104365 <strtol+0x69>
f010433d:	8a 02                	mov    (%edx),%al
f010433f:	3c 30                	cmp    $0x30,%al
f0104341:	75 10                	jne    f0104353 <strtol+0x57>
f0104343:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104347:	75 0a                	jne    f0104353 <strtol+0x57>
		s += 2, base = 16;
f0104349:	83 c2 02             	add    $0x2,%edx
f010434c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104351:	eb 12                	jmp    f0104365 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104353:	85 db                	test   %ebx,%ebx
f0104355:	75 0e                	jne    f0104365 <strtol+0x69>
f0104357:	3c 30                	cmp    $0x30,%al
f0104359:	75 05                	jne    f0104360 <strtol+0x64>
		s++, base = 8;
f010435b:	42                   	inc    %edx
f010435c:	b3 08                	mov    $0x8,%bl
f010435e:	eb 05                	jmp    f0104365 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104360:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104365:	b8 00 00 00 00       	mov    $0x0,%eax
f010436a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010436c:	8a 0a                	mov    (%edx),%cl
f010436e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104371:	80 fb 09             	cmp    $0x9,%bl
f0104374:	77 08                	ja     f010437e <strtol+0x82>
			dig = *s - '0';
f0104376:	0f be c9             	movsbl %cl,%ecx
f0104379:	83 e9 30             	sub    $0x30,%ecx
f010437c:	eb 1e                	jmp    f010439c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010437e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104381:	80 fb 19             	cmp    $0x19,%bl
f0104384:	77 08                	ja     f010438e <strtol+0x92>
			dig = *s - 'a' + 10;
f0104386:	0f be c9             	movsbl %cl,%ecx
f0104389:	83 e9 57             	sub    $0x57,%ecx
f010438c:	eb 0e                	jmp    f010439c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010438e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104391:	80 fb 19             	cmp    $0x19,%bl
f0104394:	77 12                	ja     f01043a8 <strtol+0xac>
			dig = *s - 'A' + 10;
f0104396:	0f be c9             	movsbl %cl,%ecx
f0104399:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010439c:	39 f1                	cmp    %esi,%ecx
f010439e:	7d 0c                	jge    f01043ac <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01043a0:	42                   	inc    %edx
f01043a1:	0f af c6             	imul   %esi,%eax
f01043a4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01043a6:	eb c4                	jmp    f010436c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01043a8:	89 c1                	mov    %eax,%ecx
f01043aa:	eb 02                	jmp    f01043ae <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01043ac:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01043ae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01043b2:	74 05                	je     f01043b9 <strtol+0xbd>
		*endptr = (char *) s;
f01043b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01043b7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01043b9:	85 ff                	test   %edi,%edi
f01043bb:	74 04                	je     f01043c1 <strtol+0xc5>
f01043bd:	89 c8                	mov    %ecx,%eax
f01043bf:	f7 d8                	neg    %eax
}
f01043c1:	5b                   	pop    %ebx
f01043c2:	5e                   	pop    %esi
f01043c3:	5f                   	pop    %edi
f01043c4:	5d                   	pop    %ebp
f01043c5:	c3                   	ret    
	...

f01043c8 <__udivdi3>:
f01043c8:	55                   	push   %ebp
f01043c9:	57                   	push   %edi
f01043ca:	56                   	push   %esi
f01043cb:	83 ec 10             	sub    $0x10,%esp
f01043ce:	8b 74 24 20          	mov    0x20(%esp),%esi
f01043d2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f01043d6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01043da:	8b 7c 24 24          	mov    0x24(%esp),%edi
f01043de:	89 cd                	mov    %ecx,%ebp
f01043e0:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f01043e4:	85 c0                	test   %eax,%eax
f01043e6:	75 2c                	jne    f0104414 <__udivdi3+0x4c>
f01043e8:	39 f9                	cmp    %edi,%ecx
f01043ea:	77 68                	ja     f0104454 <__udivdi3+0x8c>
f01043ec:	85 c9                	test   %ecx,%ecx
f01043ee:	75 0b                	jne    f01043fb <__udivdi3+0x33>
f01043f0:	b8 01 00 00 00       	mov    $0x1,%eax
f01043f5:	31 d2                	xor    %edx,%edx
f01043f7:	f7 f1                	div    %ecx
f01043f9:	89 c1                	mov    %eax,%ecx
f01043fb:	31 d2                	xor    %edx,%edx
f01043fd:	89 f8                	mov    %edi,%eax
f01043ff:	f7 f1                	div    %ecx
f0104401:	89 c7                	mov    %eax,%edi
f0104403:	89 f0                	mov    %esi,%eax
f0104405:	f7 f1                	div    %ecx
f0104407:	89 c6                	mov    %eax,%esi
f0104409:	89 f0                	mov    %esi,%eax
f010440b:	89 fa                	mov    %edi,%edx
f010440d:	83 c4 10             	add    $0x10,%esp
f0104410:	5e                   	pop    %esi
f0104411:	5f                   	pop    %edi
f0104412:	5d                   	pop    %ebp
f0104413:	c3                   	ret    
f0104414:	39 f8                	cmp    %edi,%eax
f0104416:	77 2c                	ja     f0104444 <__udivdi3+0x7c>
f0104418:	0f bd f0             	bsr    %eax,%esi
f010441b:	83 f6 1f             	xor    $0x1f,%esi
f010441e:	75 4c                	jne    f010446c <__udivdi3+0xa4>
f0104420:	39 f8                	cmp    %edi,%eax
f0104422:	bf 00 00 00 00       	mov    $0x0,%edi
f0104427:	72 0a                	jb     f0104433 <__udivdi3+0x6b>
f0104429:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f010442d:	0f 87 ad 00 00 00    	ja     f01044e0 <__udivdi3+0x118>
f0104433:	be 01 00 00 00       	mov    $0x1,%esi
f0104438:	89 f0                	mov    %esi,%eax
f010443a:	89 fa                	mov    %edi,%edx
f010443c:	83 c4 10             	add    $0x10,%esp
f010443f:	5e                   	pop    %esi
f0104440:	5f                   	pop    %edi
f0104441:	5d                   	pop    %ebp
f0104442:	c3                   	ret    
f0104443:	90                   	nop
f0104444:	31 ff                	xor    %edi,%edi
f0104446:	31 f6                	xor    %esi,%esi
f0104448:	89 f0                	mov    %esi,%eax
f010444a:	89 fa                	mov    %edi,%edx
f010444c:	83 c4 10             	add    $0x10,%esp
f010444f:	5e                   	pop    %esi
f0104450:	5f                   	pop    %edi
f0104451:	5d                   	pop    %ebp
f0104452:	c3                   	ret    
f0104453:	90                   	nop
f0104454:	89 fa                	mov    %edi,%edx
f0104456:	89 f0                	mov    %esi,%eax
f0104458:	f7 f1                	div    %ecx
f010445a:	89 c6                	mov    %eax,%esi
f010445c:	31 ff                	xor    %edi,%edi
f010445e:	89 f0                	mov    %esi,%eax
f0104460:	89 fa                	mov    %edi,%edx
f0104462:	83 c4 10             	add    $0x10,%esp
f0104465:	5e                   	pop    %esi
f0104466:	5f                   	pop    %edi
f0104467:	5d                   	pop    %ebp
f0104468:	c3                   	ret    
f0104469:	8d 76 00             	lea    0x0(%esi),%esi
f010446c:	89 f1                	mov    %esi,%ecx
f010446e:	d3 e0                	shl    %cl,%eax
f0104470:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104474:	b8 20 00 00 00       	mov    $0x20,%eax
f0104479:	29 f0                	sub    %esi,%eax
f010447b:	89 ea                	mov    %ebp,%edx
f010447d:	88 c1                	mov    %al,%cl
f010447f:	d3 ea                	shr    %cl,%edx
f0104481:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0104485:	09 ca                	or     %ecx,%edx
f0104487:	89 54 24 08          	mov    %edx,0x8(%esp)
f010448b:	89 f1                	mov    %esi,%ecx
f010448d:	d3 e5                	shl    %cl,%ebp
f010448f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0104493:	89 fd                	mov    %edi,%ebp
f0104495:	88 c1                	mov    %al,%cl
f0104497:	d3 ed                	shr    %cl,%ebp
f0104499:	89 fa                	mov    %edi,%edx
f010449b:	89 f1                	mov    %esi,%ecx
f010449d:	d3 e2                	shl    %cl,%edx
f010449f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01044a3:	88 c1                	mov    %al,%cl
f01044a5:	d3 ef                	shr    %cl,%edi
f01044a7:	09 d7                	or     %edx,%edi
f01044a9:	89 f8                	mov    %edi,%eax
f01044ab:	89 ea                	mov    %ebp,%edx
f01044ad:	f7 74 24 08          	divl   0x8(%esp)
f01044b1:	89 d1                	mov    %edx,%ecx
f01044b3:	89 c7                	mov    %eax,%edi
f01044b5:	f7 64 24 0c          	mull   0xc(%esp)
f01044b9:	39 d1                	cmp    %edx,%ecx
f01044bb:	72 17                	jb     f01044d4 <__udivdi3+0x10c>
f01044bd:	74 09                	je     f01044c8 <__udivdi3+0x100>
f01044bf:	89 fe                	mov    %edi,%esi
f01044c1:	31 ff                	xor    %edi,%edi
f01044c3:	e9 41 ff ff ff       	jmp    f0104409 <__udivdi3+0x41>
f01044c8:	8b 54 24 04          	mov    0x4(%esp),%edx
f01044cc:	89 f1                	mov    %esi,%ecx
f01044ce:	d3 e2                	shl    %cl,%edx
f01044d0:	39 c2                	cmp    %eax,%edx
f01044d2:	73 eb                	jae    f01044bf <__udivdi3+0xf7>
f01044d4:	8d 77 ff             	lea    -0x1(%edi),%esi
f01044d7:	31 ff                	xor    %edi,%edi
f01044d9:	e9 2b ff ff ff       	jmp    f0104409 <__udivdi3+0x41>
f01044de:	66 90                	xchg   %ax,%ax
f01044e0:	31 f6                	xor    %esi,%esi
f01044e2:	e9 22 ff ff ff       	jmp    f0104409 <__udivdi3+0x41>
	...

f01044e8 <__umoddi3>:
f01044e8:	55                   	push   %ebp
f01044e9:	57                   	push   %edi
f01044ea:	56                   	push   %esi
f01044eb:	83 ec 20             	sub    $0x20,%esp
f01044ee:	8b 44 24 30          	mov    0x30(%esp),%eax
f01044f2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f01044f6:	89 44 24 14          	mov    %eax,0x14(%esp)
f01044fa:	8b 74 24 34          	mov    0x34(%esp),%esi
f01044fe:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104502:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0104506:	89 c7                	mov    %eax,%edi
f0104508:	89 f2                	mov    %esi,%edx
f010450a:	85 ed                	test   %ebp,%ebp
f010450c:	75 16                	jne    f0104524 <__umoddi3+0x3c>
f010450e:	39 f1                	cmp    %esi,%ecx
f0104510:	0f 86 a6 00 00 00    	jbe    f01045bc <__umoddi3+0xd4>
f0104516:	f7 f1                	div    %ecx
f0104518:	89 d0                	mov    %edx,%eax
f010451a:	31 d2                	xor    %edx,%edx
f010451c:	83 c4 20             	add    $0x20,%esp
f010451f:	5e                   	pop    %esi
f0104520:	5f                   	pop    %edi
f0104521:	5d                   	pop    %ebp
f0104522:	c3                   	ret    
f0104523:	90                   	nop
f0104524:	39 f5                	cmp    %esi,%ebp
f0104526:	0f 87 ac 00 00 00    	ja     f01045d8 <__umoddi3+0xf0>
f010452c:	0f bd c5             	bsr    %ebp,%eax
f010452f:	83 f0 1f             	xor    $0x1f,%eax
f0104532:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104536:	0f 84 a8 00 00 00    	je     f01045e4 <__umoddi3+0xfc>
f010453c:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104540:	d3 e5                	shl    %cl,%ebp
f0104542:	bf 20 00 00 00       	mov    $0x20,%edi
f0104547:	2b 7c 24 10          	sub    0x10(%esp),%edi
f010454b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010454f:	89 f9                	mov    %edi,%ecx
f0104551:	d3 e8                	shr    %cl,%eax
f0104553:	09 e8                	or     %ebp,%eax
f0104555:	89 44 24 18          	mov    %eax,0x18(%esp)
f0104559:	8b 44 24 0c          	mov    0xc(%esp),%eax
f010455d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104561:	d3 e0                	shl    %cl,%eax
f0104563:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104567:	89 f2                	mov    %esi,%edx
f0104569:	d3 e2                	shl    %cl,%edx
f010456b:	8b 44 24 14          	mov    0x14(%esp),%eax
f010456f:	d3 e0                	shl    %cl,%eax
f0104571:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0104575:	8b 44 24 14          	mov    0x14(%esp),%eax
f0104579:	89 f9                	mov    %edi,%ecx
f010457b:	d3 e8                	shr    %cl,%eax
f010457d:	09 d0                	or     %edx,%eax
f010457f:	d3 ee                	shr    %cl,%esi
f0104581:	89 f2                	mov    %esi,%edx
f0104583:	f7 74 24 18          	divl   0x18(%esp)
f0104587:	89 d6                	mov    %edx,%esi
f0104589:	f7 64 24 0c          	mull   0xc(%esp)
f010458d:	89 c5                	mov    %eax,%ebp
f010458f:	89 d1                	mov    %edx,%ecx
f0104591:	39 d6                	cmp    %edx,%esi
f0104593:	72 67                	jb     f01045fc <__umoddi3+0x114>
f0104595:	74 75                	je     f010460c <__umoddi3+0x124>
f0104597:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f010459b:	29 e8                	sub    %ebp,%eax
f010459d:	19 ce                	sbb    %ecx,%esi
f010459f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01045a3:	d3 e8                	shr    %cl,%eax
f01045a5:	89 f2                	mov    %esi,%edx
f01045a7:	89 f9                	mov    %edi,%ecx
f01045a9:	d3 e2                	shl    %cl,%edx
f01045ab:	09 d0                	or     %edx,%eax
f01045ad:	89 f2                	mov    %esi,%edx
f01045af:	8a 4c 24 10          	mov    0x10(%esp),%cl
f01045b3:	d3 ea                	shr    %cl,%edx
f01045b5:	83 c4 20             	add    $0x20,%esp
f01045b8:	5e                   	pop    %esi
f01045b9:	5f                   	pop    %edi
f01045ba:	5d                   	pop    %ebp
f01045bb:	c3                   	ret    
f01045bc:	85 c9                	test   %ecx,%ecx
f01045be:	75 0b                	jne    f01045cb <__umoddi3+0xe3>
f01045c0:	b8 01 00 00 00       	mov    $0x1,%eax
f01045c5:	31 d2                	xor    %edx,%edx
f01045c7:	f7 f1                	div    %ecx
f01045c9:	89 c1                	mov    %eax,%ecx
f01045cb:	89 f0                	mov    %esi,%eax
f01045cd:	31 d2                	xor    %edx,%edx
f01045cf:	f7 f1                	div    %ecx
f01045d1:	89 f8                	mov    %edi,%eax
f01045d3:	e9 3e ff ff ff       	jmp    f0104516 <__umoddi3+0x2e>
f01045d8:	89 f2                	mov    %esi,%edx
f01045da:	83 c4 20             	add    $0x20,%esp
f01045dd:	5e                   	pop    %esi
f01045de:	5f                   	pop    %edi
f01045df:	5d                   	pop    %ebp
f01045e0:	c3                   	ret    
f01045e1:	8d 76 00             	lea    0x0(%esi),%esi
f01045e4:	39 f5                	cmp    %esi,%ebp
f01045e6:	72 04                	jb     f01045ec <__umoddi3+0x104>
f01045e8:	39 f9                	cmp    %edi,%ecx
f01045ea:	77 06                	ja     f01045f2 <__umoddi3+0x10a>
f01045ec:	89 f2                	mov    %esi,%edx
f01045ee:	29 cf                	sub    %ecx,%edi
f01045f0:	19 ea                	sbb    %ebp,%edx
f01045f2:	89 f8                	mov    %edi,%eax
f01045f4:	83 c4 20             	add    $0x20,%esp
f01045f7:	5e                   	pop    %esi
f01045f8:	5f                   	pop    %edi
f01045f9:	5d                   	pop    %ebp
f01045fa:	c3                   	ret    
f01045fb:	90                   	nop
f01045fc:	89 d1                	mov    %edx,%ecx
f01045fe:	89 c5                	mov    %eax,%ebp
f0104600:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0104604:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0104608:	eb 8d                	jmp    f0104597 <__umoddi3+0xaf>
f010460a:	66 90                	xchg   %ax,%ax
f010460c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0104610:	72 ea                	jb     f01045fc <__umoddi3+0x114>
f0104612:	89 f1                	mov    %esi,%ecx
f0104614:	eb 81                	jmp    f0104597 <__umoddi3+0xaf>
