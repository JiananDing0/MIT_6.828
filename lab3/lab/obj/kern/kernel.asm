
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
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
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
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

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
f0100046:	b8 40 3e 1e f0       	mov    $0xf01e3e40,%eax
f010004b:	2d 60 2f 1e f0       	sub    $0xf01e2f60,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 60 2f 1e f0 	movl   $0xf01e2f60,(%esp)
f0100063:	e8 66 4a 00 00       	call   f0104ace <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 90 04 00 00       	call   f01004fd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 20 4f 10 f0 	movl   $0xf0104f20,(%esp)
f010007c:	e8 25 36 00 00       	call   f01036a6 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 e6 10 00 00       	call   f010116c <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100086:	e8 ad 2f 00 00       	call   f0103038 <env_init>
	trap_init();
f010008b:	e8 96 36 00 00       	call   f0103726 <trap_init>

#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100090:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100097:	00 
f0100098:	c7 04 24 49 fc 14 f0 	movl   $0xf014fc49,(%esp)
f010009f:	e8 81 31 00 00       	call   f0103225 <env_create>
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f01000a4:	a1 ac 31 1e f0       	mov    0xf01e31ac,%eax
f01000a9:	89 04 24             	mov    %eax,(%esp)
f01000ac:	e8 35 35 00 00       	call   f01035e6 <env_run>

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
f01000bc:	83 3d 44 3e 1e f0 00 	cmpl   $0x0,0xf01e3e44
f01000c3:	75 3d                	jne    f0100102 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000c5:	89 35 44 3e 1e f0    	mov    %esi,0xf01e3e44

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
f01000de:	c7 04 24 3b 4f 10 f0 	movl   $0xf0104f3b,(%esp)
f01000e5:	e8 bc 35 00 00       	call   f01036a6 <cprintf>
	vcprintf(fmt, ap);
f01000ea:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000ee:	89 34 24             	mov    %esi,(%esp)
f01000f1:	e8 7d 35 00 00       	call   f0103673 <vcprintf>
	cprintf("\n");
f01000f6:	c7 04 24 2d 5f 10 f0 	movl   $0xf0105f2d,(%esp)
f01000fd:	e8 a4 35 00 00       	call   f01036a6 <cprintf>
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
f0100128:	c7 04 24 53 4f 10 f0 	movl   $0xf0104f53,(%esp)
f010012f:	e8 72 35 00 00       	call   f01036a6 <cprintf>
	vcprintf(fmt, ap);
f0100134:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100138:	8b 45 10             	mov    0x10(%ebp),%eax
f010013b:	89 04 24             	mov    %eax,(%esp)
f010013e:	e8 30 35 00 00       	call   f0103673 <vcprintf>
	cprintf("\n");
f0100143:	c7 04 24 2d 5f 10 f0 	movl   $0xf0105f2d,(%esp)
f010014a:	e8 57 35 00 00       	call   f01036a6 <cprintf>
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
f0100191:	8b 15 84 31 1e f0    	mov    0xf01e3184,%edx
f0100197:	88 82 80 2f 1e f0    	mov    %al,-0xfe1d080(%edx)
f010019d:	8d 42 01             	lea    0x1(%edx),%eax
f01001a0:	a3 84 31 1e f0       	mov    %eax,0xf01e3184
		if (cons.wpos == CONSBUFSIZE)
f01001a5:	3d 00 02 00 00       	cmp    $0x200,%eax
f01001aa:	75 0a                	jne    f01001b6 <cons_intr+0x34>
			cons.wpos = 0;
f01001ac:	c7 05 84 31 1e f0 00 	movl   $0x0,0xf01e3184
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
f010025c:	66 a1 94 31 1e f0    	mov    0xf01e3194,%ax
f0100262:	66 85 c0             	test   %ax,%ax
f0100265:	0f 84 e2 00 00 00    	je     f010034d <cons_putc+0x18a>
			crt_pos--;
f010026b:	48                   	dec    %eax
f010026c:	66 a3 94 31 1e f0    	mov    %ax,0xf01e3194
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100272:	0f b7 c0             	movzwl %ax,%eax
f0100275:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010027b:	83 ce 20             	or     $0x20,%esi
f010027e:	8b 15 90 31 1e f0    	mov    0xf01e3190,%edx
f0100284:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100288:	eb 78                	jmp    f0100302 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010028a:	66 83 05 94 31 1e f0 	addw   $0x50,0xf01e3194
f0100291:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100292:	66 8b 0d 94 31 1e f0 	mov    0xf01e3194,%cx
f0100299:	bb 50 00 00 00       	mov    $0x50,%ebx
f010029e:	89 c8                	mov    %ecx,%eax
f01002a0:	ba 00 00 00 00       	mov    $0x0,%edx
f01002a5:	66 f7 f3             	div    %bx
f01002a8:	66 29 d1             	sub    %dx,%cx
f01002ab:	66 89 0d 94 31 1e f0 	mov    %cx,0xf01e3194
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
f01002e8:	66 a1 94 31 1e f0    	mov    0xf01e3194,%ax
f01002ee:	0f b7 c8             	movzwl %ax,%ecx
f01002f1:	8b 15 90 31 1e f0    	mov    0xf01e3190,%edx
f01002f7:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002fb:	40                   	inc    %eax
f01002fc:	66 a3 94 31 1e f0    	mov    %ax,0xf01e3194
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100302:	66 81 3d 94 31 1e f0 	cmpw   $0x7cf,0xf01e3194
f0100309:	cf 07 
f010030b:	76 40                	jbe    f010034d <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010030d:	a1 90 31 1e f0       	mov    0xf01e3190,%eax
f0100312:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f0100319:	00 
f010031a:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100320:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100324:	89 04 24             	mov    %eax,(%esp)
f0100327:	e8 ec 47 00 00       	call   f0104b18 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010032c:	8b 15 90 31 1e f0    	mov    0xf01e3190,%edx
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
f0100345:	66 83 2d 94 31 1e f0 	subw   $0x50,0xf01e3194
f010034c:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010034d:	8b 0d 8c 31 1e f0    	mov    0xf01e318c,%ecx
f0100353:	b0 0e                	mov    $0xe,%al
f0100355:	89 ca                	mov    %ecx,%edx
f0100357:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100358:	66 8b 35 94 31 1e f0 	mov    0xf01e3194,%si
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
f01003a6:	83 0d 88 31 1e f0 40 	orl    $0x40,0xf01e3188
		return 0;
f01003ad:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003b2:	e9 ca 00 00 00       	jmp    f0100481 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f01003b7:	84 c0                	test   %al,%al
f01003b9:	79 33                	jns    f01003ee <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01003bb:	8b 0d 88 31 1e f0    	mov    0xf01e3188,%ecx
f01003c1:	f6 c1 40             	test   $0x40,%cl
f01003c4:	75 05                	jne    f01003cb <kbd_proc_data+0x4e>
f01003c6:	88 c2                	mov    %al,%dl
f01003c8:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003cb:	0f b6 d2             	movzbl %dl,%edx
f01003ce:	8a 82 a0 4f 10 f0    	mov    -0xfefb060(%edx),%al
f01003d4:	83 c8 40             	or     $0x40,%eax
f01003d7:	0f b6 c0             	movzbl %al,%eax
f01003da:	f7 d0                	not    %eax
f01003dc:	21 c1                	and    %eax,%ecx
f01003de:	89 0d 88 31 1e f0    	mov    %ecx,0xf01e3188
		return 0;
f01003e4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003e9:	e9 93 00 00 00       	jmp    f0100481 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f01003ee:	8b 0d 88 31 1e f0    	mov    0xf01e3188,%ecx
f01003f4:	f6 c1 40             	test   $0x40,%cl
f01003f7:	74 0e                	je     f0100407 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003f9:	88 c2                	mov    %al,%dl
f01003fb:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100401:	89 0d 88 31 1e f0    	mov    %ecx,0xf01e3188
	}

	shift |= shiftcode[data];
f0100407:	0f b6 d2             	movzbl %dl,%edx
f010040a:	0f b6 82 a0 4f 10 f0 	movzbl -0xfefb060(%edx),%eax
f0100411:	0b 05 88 31 1e f0    	or     0xf01e3188,%eax
	shift ^= togglecode[data];
f0100417:	0f b6 8a a0 50 10 f0 	movzbl -0xfefaf60(%edx),%ecx
f010041e:	31 c8                	xor    %ecx,%eax
f0100420:	a3 88 31 1e f0       	mov    %eax,0xf01e3188

	c = charcode[shift & (CTL | SHIFT)][data];
f0100425:	89 c1                	mov    %eax,%ecx
f0100427:	83 e1 03             	and    $0x3,%ecx
f010042a:	8b 0c 8d a0 51 10 f0 	mov    -0xfefae60(,%ecx,4),%ecx
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
f010045f:	c7 04 24 6d 4f 10 f0 	movl   $0xf0104f6d,(%esp)
f0100466:	e8 3b 32 00 00       	call   f01036a6 <cprintf>
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
f010048f:	80 3d 60 2f 1e f0 00 	cmpb   $0x0,0xf01e2f60
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
f01004c6:	8b 15 80 31 1e f0    	mov    0xf01e3180,%edx
f01004cc:	3b 15 84 31 1e f0    	cmp    0xf01e3184,%edx
f01004d2:	74 22                	je     f01004f6 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004d4:	0f b6 82 80 2f 1e f0 	movzbl -0xfe1d080(%edx),%eax
f01004db:	42                   	inc    %edx
f01004dc:	89 15 80 31 1e f0    	mov    %edx,0xf01e3180
		if (cons.rpos == CONSBUFSIZE)
f01004e2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e8:	75 11                	jne    f01004fb <cons_getc+0x45>
			cons.rpos = 0;
f01004ea:	c7 05 80 31 1e f0 00 	movl   $0x0,0xf01e3180
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
f0100522:	c7 05 8c 31 1e f0 b4 	movl   $0x3b4,0xf01e318c
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
f010053a:	c7 05 8c 31 1e f0 d4 	movl   $0x3d4,0xf01e318c
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
f0100549:	8b 0d 8c 31 1e f0    	mov    0xf01e318c,%ecx
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
f0100568:	89 35 90 31 1e f0    	mov    %esi,0xf01e3190

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010056e:	0f b6 d8             	movzbl %al,%ebx
f0100571:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100573:	66 89 3d 94 31 1e f0 	mov    %di,0xf01e3194
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
f01005b3:	a2 60 2f 1e f0       	mov    %al,0xf01e2f60
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
f01005c4:	c7 04 24 79 4f 10 f0 	movl   $0xf0104f79,(%esp)
f01005cb:	e8 d6 30 00 00       	call   f01036a6 <cprintf>
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
f010060a:	c7 04 24 b0 51 10 f0 	movl   $0xf01051b0,(%esp)
f0100611:	e8 90 30 00 00       	call   f01036a6 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100616:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f010061d:	00 
f010061e:	c7 04 24 68 52 10 f0 	movl   $0xf0105268,(%esp)
f0100625:	e8 7c 30 00 00       	call   f01036a6 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010062a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100631:	00 
f0100632:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100639:	f0 
f010063a:	c7 04 24 90 52 10 f0 	movl   $0xf0105290,(%esp)
f0100641:	e8 60 30 00 00       	call   f01036a6 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100646:	c7 44 24 08 12 4f 10 	movl   $0x104f12,0x8(%esp)
f010064d:	00 
f010064e:	c7 44 24 04 12 4f 10 	movl   $0xf0104f12,0x4(%esp)
f0100655:	f0 
f0100656:	c7 04 24 b4 52 10 f0 	movl   $0xf01052b4,(%esp)
f010065d:	e8 44 30 00 00       	call   f01036a6 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100662:	c7 44 24 08 60 2f 1e 	movl   $0x1e2f60,0x8(%esp)
f0100669:	00 
f010066a:	c7 44 24 04 60 2f 1e 	movl   $0xf01e2f60,0x4(%esp)
f0100671:	f0 
f0100672:	c7 04 24 d8 52 10 f0 	movl   $0xf01052d8,(%esp)
f0100679:	e8 28 30 00 00       	call   f01036a6 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010067e:	c7 44 24 08 40 3e 1e 	movl   $0x1e3e40,0x8(%esp)
f0100685:	00 
f0100686:	c7 44 24 04 40 3e 1e 	movl   $0xf01e3e40,0x4(%esp)
f010068d:	f0 
f010068e:	c7 04 24 fc 52 10 f0 	movl   $0xf01052fc,(%esp)
f0100695:	e8 0c 30 00 00       	call   f01036a6 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010069a:	b8 3f 42 1e f0       	mov    $0xf01e423f,%eax
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
f01006bc:	c7 04 24 20 53 10 f0 	movl   $0xf0105320,(%esp)
f01006c3:	e8 de 2f 00 00       	call   f01036a6 <cprintf>
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
f01006db:	8b 83 24 54 10 f0    	mov    -0xfefabdc(%ebx),%eax
f01006e1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006e5:	8b 83 20 54 10 f0    	mov    -0xfefabe0(%ebx),%eax
f01006eb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006ef:	c7 04 24 c9 51 10 f0 	movl   $0xf01051c9,(%esp)
f01006f6:	e8 ab 2f 00 00       	call   f01036a6 <cprintf>
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
f0100719:	c7 04 24 d2 51 10 f0 	movl   $0xf01051d2,(%esp)
f0100720:	e8 81 2f 00 00       	call   f01036a6 <cprintf>
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
f0100752:	e8 8e 39 00 00       	call   f01040e5 <debuginfo_eip>
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
f010077f:	c7 04 24 4c 53 10 f0 	movl   $0xf010534c,(%esp)
f0100786:	e8 1b 2f 00 00       	call   f01036a6 <cprintf>
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
f01007ae:	c7 04 24 e4 51 10 f0 	movl   $0xf01051e4,(%esp)
f01007b5:	e8 ec 2e 00 00       	call   f01036a6 <cprintf>
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
f01007da:	c7 04 24 80 53 10 f0 	movl   $0xf0105380,(%esp)
f01007e1:	e8 c0 2e 00 00       	call   f01036a6 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007e6:	c7 04 24 a4 53 10 f0 	movl   $0xf01053a4,(%esp)
f01007ed:	e8 b4 2e 00 00       	call   f01036a6 <cprintf>

	if (tf != NULL)
f01007f2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01007f6:	74 0b                	je     f0100803 <monitor+0x32>
		print_trapframe(tf);
f01007f8:	8b 45 08             	mov    0x8(%ebp),%eax
f01007fb:	89 04 24             	mov    %eax,(%esp)
f01007fe:	e8 05 33 00 00       	call   f0103b08 <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100803:	c7 04 24 f5 51 10 f0 	movl   $0xf01051f5,(%esp)
f010080a:	e8 95 40 00 00       	call   f01048a4 <readline>
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
f0100834:	c7 04 24 f9 51 10 f0 	movl   $0xf01051f9,(%esp)
f010083b:	e8 59 42 00 00       	call   f0104a99 <strchr>
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
f0100856:	c7 04 24 fe 51 10 f0 	movl   $0xf01051fe,(%esp)
f010085d:	e8 44 2e 00 00       	call   f01036a6 <cprintf>
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
f0100879:	c7 04 24 f9 51 10 f0 	movl   $0xf01051f9,(%esp)
f0100880:	e8 14 42 00 00       	call   f0104a99 <strchr>
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
f010089b:	bb 20 54 10 f0       	mov    $0xf0105420,%ebx
f01008a0:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008a5:	8b 03                	mov    (%ebx),%eax
f01008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008ab:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008ae:	89 04 24             	mov    %eax,(%esp)
f01008b1:	e8 90 41 00 00       	call   f0104a46 <strcmp>
f01008b6:	85 c0                	test   %eax,%eax
f01008b8:	75 24                	jne    f01008de <monitor+0x10d>
			return commands[i].func(argc, argv, tf);
f01008ba:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f01008bd:	8b 55 08             	mov    0x8(%ebp),%edx
f01008c0:	89 54 24 08          	mov    %edx,0x8(%esp)
f01008c4:	8d 55 a8             	lea    -0x58(%ebp),%edx
f01008c7:	89 54 24 04          	mov    %edx,0x4(%esp)
f01008cb:	89 34 24             	mov    %esi,(%esp)
f01008ce:	ff 14 85 28 54 10 f0 	call   *-0xfefabd8(,%eax,4)
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
f01008ee:	c7 04 24 1b 52 10 f0 	movl   $0xf010521b,(%esp)
f01008f5:	e8 ac 2d 00 00       	call   f01036a6 <cprintf>
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
f0100924:	3b 0d 48 3e 1e f0    	cmp    0xf01e3e48,%ecx
f010092a:	72 20                	jb     f010094c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010092c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100930:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0100937:	f0 
f0100938:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f010093f:	00 
f0100940:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f0100982:	e8 b1 2c 00 00       	call   f0103638 <mc146818_read>
f0100987:	89 c6                	mov    %eax,%esi
f0100989:	43                   	inc    %ebx
f010098a:	89 1c 24             	mov    %ebx,(%esp)
f010098d:	e8 a6 2c 00 00       	call   f0103638 <mc146818_read>
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
f01009a7:	83 3d 9c 31 1e f0 00 	cmpl   $0x0,0xf01e319c
f01009ae:	75 11                	jne    f01009c1 <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01009b0:	ba 3f 4e 1e f0       	mov    $0xf01e4e3f,%edx
f01009b5:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009bb:	89 15 9c 31 1e f0    	mov    %edx,0xf01e319c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	assert(n >= 0);
	// Convert to physical address
	result = (char *)PADDR(nextfree);
f01009c1:	8b 15 9c 31 1e f0    	mov    0xf01e319c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01009c7:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01009cd:	77 20                	ja     f01009ef <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01009cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01009d3:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f01009da:	f0 
f01009db:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
f01009e2:	00 
f01009e3:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01009ea:	e8 c2 f6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01009ef:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	// Determine whether it is out of bound
	if ((physaddr_t)result + n > PGSIZE * npages) {
f01009f5:	8b 1d 48 3e 1e f0    	mov    0xf01e3e48,%ebx
f01009fb:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
f01009fe:	89 de                	mov    %ebx,%esi
f0100a00:	c1 e6 0c             	shl    $0xc,%esi
f0100a03:	39 f7                	cmp    %esi,%edi
f0100a05:	76 1c                	jbe    f0100a23 <boot_alloc+0x85>
		panic("boot_alloc: out of memory!");
f0100a07:	c7 44 24 08 6d 5c 10 	movl   $0xf0105c6d,0x8(%esp)
f0100a0e:	f0 
f0100a0f:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0100a16:	00 
f0100a17:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100a1e:	e8 8e f6 ff ff       	call   f01000b1 <_panic>
	}
	// Otherwise, update value of nextfree, no update when n == 0
	nextfree += ROUNDUP(n, PGSIZE);
f0100a23:	05 ff 0f 00 00       	add    $0xfff,%eax
f0100a28:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a2d:	01 d0                	add    %edx,%eax
f0100a2f:	a3 9c 31 1e f0       	mov    %eax,0xf01e319c
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
f0100a41:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0100a48:	f0 
f0100a49:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f0100a50:	00 
f0100a51:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f0100a7b:	8b 15 a0 31 1e f0    	mov    0xf01e31a0,%edx
f0100a81:	85 d2                	test   %edx,%edx
f0100a83:	75 1c                	jne    f0100aa1 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100a85:	c7 44 24 08 8c 54 10 	movl   $0xf010548c,0x8(%esp)
f0100a8c:	f0 
f0100a8d:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
f0100a94:	00 
f0100a95:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f0100ab3:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
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
f0100aeb:	a3 a0 31 1e f0       	mov    %eax,0xf01e31a0
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100af0:	8b 1d a0 31 1e f0    	mov    0xf01e31a0,%ebx
f0100af6:	eb 63                	jmp    f0100b5b <check_page_free_list+0xf4>
f0100af8:	89 d8                	mov    %ebx,%eax
f0100afa:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
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
f0100b14:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0100b1a:	72 20                	jb     f0100b3c <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100b20:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0100b27:	f0 
f0100b28:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100b2f:	00 
f0100b30:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0100b37:	e8 75 f5 ff ff       	call   f01000b1 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b3c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b43:	00 
f0100b44:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b4b:	00 
	return (void *)(pa + KERNBASE);
f0100b4c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b51:	89 04 24             	mov    %eax,(%esp)
f0100b54:	e8 75 3f 00 00       	call   f0104ace <memset>
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
f0100b6c:	8b 15 a0 31 1e f0    	mov    0xf01e31a0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b72:	8b 0d 50 3e 1e f0    	mov    0xf01e3e50,%ecx
		assert(pp < pages + npages);
f0100b78:	a1 48 3e 1e f0       	mov    0xf01e3e48,%eax
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
f0100b9b:	c7 44 24 0c 96 5c 10 	movl   $0xf0105c96,0xc(%esp)
f0100ba2:	f0 
f0100ba3:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100baa:	f0 
f0100bab:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f0100bb2:	00 
f0100bb3:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100bba:	e8 f2 f4 ff ff       	call   f01000b1 <_panic>
		assert(pp < pages + npages);
f0100bbf:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100bc2:	72 24                	jb     f0100be8 <check_page_free_list+0x181>
f0100bc4:	c7 44 24 0c b7 5c 10 	movl   $0xf0105cb7,0xc(%esp)
f0100bcb:	f0 
f0100bcc:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100bd3:	f0 
f0100bd4:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f0100bdb:	00 
f0100bdc:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100be3:	e8 c9 f4 ff ff       	call   f01000b1 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100be8:	89 d0                	mov    %edx,%eax
f0100bea:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bed:	a8 07                	test   $0x7,%al
f0100bef:	74 24                	je     f0100c15 <check_page_free_list+0x1ae>
f0100bf1:	c7 44 24 0c b0 54 10 	movl   $0xf01054b0,0xc(%esp)
f0100bf8:	f0 
f0100bf9:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100c00:	f0 
f0100c01:	c7 44 24 04 a0 02 00 	movl   $0x2a0,0x4(%esp)
f0100c08:	00 
f0100c09:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f0100c1d:	c7 44 24 0c cb 5c 10 	movl   $0xf0105ccb,0xc(%esp)
f0100c24:	f0 
f0100c25:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100c2c:	f0 
f0100c2d:	c7 44 24 04 a3 02 00 	movl   $0x2a3,0x4(%esp)
f0100c34:	00 
f0100c35:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100c3c:	e8 70 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c41:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c46:	75 24                	jne    f0100c6c <check_page_free_list+0x205>
f0100c48:	c7 44 24 0c dc 5c 10 	movl   $0xf0105cdc,0xc(%esp)
f0100c4f:	f0 
f0100c50:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100c57:	f0 
f0100c58:	c7 44 24 04 a4 02 00 	movl   $0x2a4,0x4(%esp)
f0100c5f:	00 
f0100c60:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100c67:	e8 45 f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c6c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c71:	75 24                	jne    f0100c97 <check_page_free_list+0x230>
f0100c73:	c7 44 24 0c e4 54 10 	movl   $0xf01054e4,0xc(%esp)
f0100c7a:	f0 
f0100c7b:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100c82:	f0 
f0100c83:	c7 44 24 04 a5 02 00 	movl   $0x2a5,0x4(%esp)
f0100c8a:	00 
f0100c8b:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100c92:	e8 1a f4 ff ff       	call   f01000b1 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c97:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c9c:	75 24                	jne    f0100cc2 <check_page_free_list+0x25b>
f0100c9e:	c7 44 24 0c f5 5c 10 	movl   $0xf0105cf5,0xc(%esp)
f0100ca5:	f0 
f0100ca6:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100cad:	f0 
f0100cae:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
f0100cb5:	00 
f0100cb6:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f0100cd7:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0100cde:	f0 
f0100cdf:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100ce6:	00 
f0100ce7:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0100cee:	e8 be f3 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0100cf3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cf8:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100cfb:	76 27                	jbe    f0100d24 <check_page_free_list+0x2bd>
f0100cfd:	c7 44 24 0c 08 55 10 	movl   $0xf0105508,0xc(%esp)
f0100d04:	f0 
f0100d05:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100d0c:	f0 
f0100d0d:	c7 44 24 04 a7 02 00 	movl   $0x2a7,0x4(%esp)
f0100d14:	00 
f0100d15:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f0100d33:	c7 44 24 0c 0f 5d 10 	movl   $0xf0105d0f,0xc(%esp)
f0100d3a:	f0 
f0100d3b:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100d42:	f0 
f0100d43:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f0100d4a:	00 
f0100d4b:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100d52:	e8 5a f3 ff ff       	call   f01000b1 <_panic>
	assert(nfree_extmem > 0);
f0100d57:	85 db                	test   %ebx,%ebx
f0100d59:	7f 24                	jg     f0100d7f <check_page_free_list+0x318>
f0100d5b:	c7 44 24 0c 21 5d 10 	movl   $0xf0105d21,0xc(%esp)
f0100d62:	f0 
f0100d63:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0100d6a:	f0 
f0100d6b:	c7 44 24 04 b0 02 00 	movl   $0x2b0,0x4(%esp)
f0100d72:	00 
f0100d73:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100d7a:	e8 32 f3 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d7f:	c7 04 24 50 55 10 f0 	movl   $0xf0105550,(%esp)
f0100d86:	e8 1b 29 00 00       	call   f01036a6 <cprintf>
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
f0100db1:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f0100db8:	f0 
f0100db9:	c7 44 24 04 1b 01 00 	movl   $0x11b,0x4(%esp)
f0100dc0:	00 
f0100dc1:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100dc8:	e8 e4 f2 ff ff       	call   f01000b1 <_panic>
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE)) {
f0100dcd:	8b 35 98 31 1e f0    	mov    0xf01e3198,%esi
	return (physaddr_t)kva - KERNBASE;
f0100dd3:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0100dd9:	c1 ef 0c             	shr    $0xc,%edi
f0100ddc:	8b 1d a0 31 1e f0    	mov    0xf01e31a0,%ebx
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
f0100dfa:	a1 50 3e 1e f0       	mov    0xf01e3e50,%eax
f0100dff:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
f0100e06:	eb 18                	jmp    f0100e20 <page_init+0x8d>
		}
		// Rest of memory are free
		else {
			pages[i].pp_ref = 0;
f0100e08:	89 c8                	mov    %ecx,%eax
f0100e0a:	03 05 50 3e 1e f0    	add    0xf01e3e50,%eax
f0100e10:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100e16:	89 18                	mov    %ebx,(%eax)
			page_free_list = &pages[i];
f0100e18:	89 cb                	mov    %ecx,%ebx
f0100e1a:	03 1d 50 3e 1e f0    	add    0xf01e3e50,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100e20:	42                   	inc    %edx
f0100e21:	83 c1 08             	add    $0x8,%ecx
f0100e24:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0100e2a:	72 c2                	jb     f0100dee <page_init+0x5b>
f0100e2c:	89 1d a0 31 1e f0    	mov    %ebx,0xf01e31a0
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
f0100e41:	8b 1d a0 31 1e f0    	mov    0xf01e31a0,%ebx
	// Check whether out of free memory
	if (!page_free_list) {
f0100e47:	85 db                	test   %ebx,%ebx
f0100e49:	74 6b                	je     f0100eb6 <page_alloc+0x7c>
		return NULL;
	}
	// Set the page without change the reference bit.
	page_free_list = currPage->pp_link;
f0100e4b:	8b 03                	mov    (%ebx),%eax
f0100e4d:	a3 a0 31 1e f0       	mov    %eax,0xf01e31a0
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
f0100e60:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f0100e66:	c1 f8 03             	sar    $0x3,%eax
f0100e69:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e6c:	89 c2                	mov    %eax,%edx
f0100e6e:	c1 ea 0c             	shr    $0xc,%edx
f0100e71:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0100e77:	72 20                	jb     f0100e99 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e79:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e7d:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0100e84:	f0 
f0100e85:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0100e8c:	00 
f0100e8d:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
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
f0100eb1:	e8 18 3c 00 00       	call   f0104ace <memset>
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
f0100ed3:	c7 44 24 08 74 55 10 	movl   $0xf0105574,0x8(%esp)
f0100eda:	f0 
f0100edb:	c7 44 24 04 56 01 00 	movl   $0x156,0x4(%esp)
f0100ee2:	00 
f0100ee3:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0100eea:	e8 c2 f1 ff ff       	call   f01000b1 <_panic>
	}
	// Update the free list
	pp->pp_link = page_free_list;
f0100eef:	8b 15 a0 31 1e f0    	mov    0xf01e31a0,%edx
f0100ef5:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ef7:	a3 a0 31 1e f0       	mov    %eax,0xf01e31a0
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
		newPage = page_alloc(ALLOC_ZERO);
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
f0100f53:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
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
f0100f70:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0100f76:	72 20                	jb     f0100f98 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f78:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f7c:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0100f83:	f0 
f0100f84:	c7 44 24 04 9a 01 00 	movl   $0x19a,0x4(%esp)
f0100f8b:	00 
f0100f8c:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f010105d:	3b 05 48 3e 1e f0    	cmp    0xf01e3e48,%eax
f0101063:	72 1c                	jb     f0101081 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101065:	c7 44 24 08 b0 55 10 	movl   $0xf01055b0,0x8(%esp)
f010106c:	f0 
f010106d:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0101074:	00 
f0101075:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f010107c:	e8 30 f0 ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0101081:	c1 e0 03             	shl    $0x3,%eax
f0101084:	03 05 50 3e 1e f0    	add    0xf01e3e50,%eax
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
f010113c:	2b 1d 50 3e 1e f0    	sub    0xf01e3e50,%ebx
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
f01011b7:	a3 48 3e 1e f0       	mov    %eax,0xf01e3e48
	npages_basemem = basemem / (PGSIZE / 1024);
f01011bc:	89 d8                	mov    %ebx,%eax
f01011be:	c1 e8 02             	shr    $0x2,%eax
f01011c1:	a3 98 31 1e f0       	mov    %eax,0xf01e3198

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011c6:	89 f0                	mov    %esi,%eax
f01011c8:	29 d8                	sub    %ebx,%eax
f01011ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01011d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011d6:	c7 04 24 d0 55 10 f0 	movl   $0xf01055d0,(%esp)
f01011dd:	e8 c4 24 00 00       	call   f01036a6 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011e2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011e7:	e8 b2 f7 ff ff       	call   f010099e <boot_alloc>
f01011ec:	a3 4c 3e 1e f0       	mov    %eax,0xf01e3e4c
	memset(kern_pgdir, 0, PGSIZE);
f01011f1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011f8:	00 
f01011f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101200:	00 
f0101201:	89 04 24             	mov    %eax,(%esp)
f0101204:	e8 c5 38 00 00       	call   f0104ace <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101209:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010120e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101213:	77 20                	ja     f0101235 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101215:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101219:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f0101220:	f0 
f0101221:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0101228:	00 
f0101229:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
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
f0101244:	a1 48 3e 1e f0       	mov    0xf01e3e48,%eax
f0101249:	c1 e0 03             	shl    $0x3,%eax
f010124c:	e8 4d f7 ff ff       	call   f010099e <boot_alloc>
f0101251:	a3 50 3e 1e f0       	mov    %eax,0xf01e3e50
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101256:	8b 15 48 3e 1e f0    	mov    0xf01e3e48,%edx
f010125c:	c1 e2 03             	shl    $0x3,%edx
f010125f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101263:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010126a:	00 
f010126b:	89 04 24             	mov    %eax,(%esp)
f010126e:	e8 5b 38 00 00       	call   f0104ace <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f0101273:	b8 00 80 01 00       	mov    $0x18000,%eax
f0101278:	e8 21 f7 ff ff       	call   f010099e <boot_alloc>
f010127d:	a3 ac 31 1e f0       	mov    %eax,0xf01e31ac
	memset(envs, 0, sizeof(struct Env) * NENV);
f0101282:	c7 44 24 08 00 80 01 	movl   $0x18000,0x8(%esp)
f0101289:	00 
f010128a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101291:	00 
f0101292:	89 04 24             	mov    %eax,(%esp)
f0101295:	e8 34 38 00 00       	call   f0104ace <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010129a:	e8 f4 fa ff ff       	call   f0100d93 <page_init>

	check_page_free_list(1);
f010129f:	b8 01 00 00 00       	mov    $0x1,%eax
f01012a4:	e8 be f7 ff ff       	call   f0100a67 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012a9:	83 3d 50 3e 1e f0 00 	cmpl   $0x0,0xf01e3e50
f01012b0:	75 1c                	jne    f01012ce <mem_init+0x162>
		panic("'pages' is a null pointer!");
f01012b2:	c7 44 24 08 32 5d 10 	movl   $0xf0105d32,0x8(%esp)
f01012b9:	f0 
f01012ba:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f01012c1:	00 
f01012c2:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01012c9:	e8 e3 ed ff ff       	call   f01000b1 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012ce:	a1 a0 31 1e f0       	mov    0xf01e31a0,%eax
f01012d3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01012d8:	eb 03                	jmp    f01012dd <mem_init+0x171>
		++nfree;
f01012da:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01012db:	8b 00                	mov    (%eax),%eax
f01012dd:	85 c0                	test   %eax,%eax
f01012df:	75 f9                	jne    f01012da <mem_init+0x16e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012e8:	e8 4d fb ff ff       	call   f0100e3a <page_alloc>
f01012ed:	89 c6                	mov    %eax,%esi
f01012ef:	85 c0                	test   %eax,%eax
f01012f1:	75 24                	jne    f0101317 <mem_init+0x1ab>
f01012f3:	c7 44 24 0c 4d 5d 10 	movl   $0xf0105d4d,0xc(%esp)
f01012fa:	f0 
f01012fb:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101302:	f0 
f0101303:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f010130a:	00 
f010130b:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101312:	e8 9a ed ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101317:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010131e:	e8 17 fb ff ff       	call   f0100e3a <page_alloc>
f0101323:	89 c7                	mov    %eax,%edi
f0101325:	85 c0                	test   %eax,%eax
f0101327:	75 24                	jne    f010134d <mem_init+0x1e1>
f0101329:	c7 44 24 0c 63 5d 10 	movl   $0xf0105d63,0xc(%esp)
f0101330:	f0 
f0101331:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101338:	f0 
f0101339:	c7 44 24 04 cc 02 00 	movl   $0x2cc,0x4(%esp)
f0101340:	00 
f0101341:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101348:	e8 64 ed ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010134d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101354:	e8 e1 fa ff ff       	call   f0100e3a <page_alloc>
f0101359:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010135c:	85 c0                	test   %eax,%eax
f010135e:	75 24                	jne    f0101384 <mem_init+0x218>
f0101360:	c7 44 24 0c 79 5d 10 	movl   $0xf0105d79,0xc(%esp)
f0101367:	f0 
f0101368:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010136f:	f0 
f0101370:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f0101377:	00 
f0101378:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010137f:	e8 2d ed ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101384:	39 fe                	cmp    %edi,%esi
f0101386:	75 24                	jne    f01013ac <mem_init+0x240>
f0101388:	c7 44 24 0c 8f 5d 10 	movl   $0xf0105d8f,0xc(%esp)
f010138f:	f0 
f0101390:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101397:	f0 
f0101398:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f010139f:	00 
f01013a0:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01013a7:	e8 05 ed ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ac:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01013af:	74 05                	je     f01013b6 <mem_init+0x24a>
f01013b1:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01013b4:	75 24                	jne    f01013da <mem_init+0x26e>
f01013b6:	c7 44 24 0c 0c 56 10 	movl   $0xf010560c,0xc(%esp)
f01013bd:	f0 
f01013be:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01013c5:	f0 
f01013c6:	c7 44 24 04 d1 02 00 	movl   $0x2d1,0x4(%esp)
f01013cd:	00 
f01013ce:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01013d5:	e8 d7 ec ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013da:	8b 15 50 3e 1e f0    	mov    0xf01e3e50,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013e0:	a1 48 3e 1e f0       	mov    0xf01e3e48,%eax
f01013e5:	c1 e0 0c             	shl    $0xc,%eax
f01013e8:	89 f1                	mov    %esi,%ecx
f01013ea:	29 d1                	sub    %edx,%ecx
f01013ec:	c1 f9 03             	sar    $0x3,%ecx
f01013ef:	c1 e1 0c             	shl    $0xc,%ecx
f01013f2:	39 c1                	cmp    %eax,%ecx
f01013f4:	72 24                	jb     f010141a <mem_init+0x2ae>
f01013f6:	c7 44 24 0c a1 5d 10 	movl   $0xf0105da1,0xc(%esp)
f01013fd:	f0 
f01013fe:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101405:	f0 
f0101406:	c7 44 24 04 d2 02 00 	movl   $0x2d2,0x4(%esp)
f010140d:	00 
f010140e:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101415:	e8 97 ec ff ff       	call   f01000b1 <_panic>
f010141a:	89 f9                	mov    %edi,%ecx
f010141c:	29 d1                	sub    %edx,%ecx
f010141e:	c1 f9 03             	sar    $0x3,%ecx
f0101421:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101424:	39 c8                	cmp    %ecx,%eax
f0101426:	77 24                	ja     f010144c <mem_init+0x2e0>
f0101428:	c7 44 24 0c be 5d 10 	movl   $0xf0105dbe,0xc(%esp)
f010142f:	f0 
f0101430:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101437:	f0 
f0101438:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f010143f:	00 
f0101440:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101447:	e8 65 ec ff ff       	call   f01000b1 <_panic>
f010144c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010144f:	29 d1                	sub    %edx,%ecx
f0101451:	89 ca                	mov    %ecx,%edx
f0101453:	c1 fa 03             	sar    $0x3,%edx
f0101456:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101459:	39 d0                	cmp    %edx,%eax
f010145b:	77 24                	ja     f0101481 <mem_init+0x315>
f010145d:	c7 44 24 0c db 5d 10 	movl   $0xf0105ddb,0xc(%esp)
f0101464:	f0 
f0101465:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010146c:	f0 
f010146d:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0101474:	00 
f0101475:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010147c:	e8 30 ec ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101481:	a1 a0 31 1e f0       	mov    0xf01e31a0,%eax
f0101486:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101489:	c7 05 a0 31 1e f0 00 	movl   $0x0,0xf01e31a0
f0101490:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101493:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010149a:	e8 9b f9 ff ff       	call   f0100e3a <page_alloc>
f010149f:	85 c0                	test   %eax,%eax
f01014a1:	74 24                	je     f01014c7 <mem_init+0x35b>
f01014a3:	c7 44 24 0c f8 5d 10 	movl   $0xf0105df8,0xc(%esp)
f01014aa:	f0 
f01014ab:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01014b2:	f0 
f01014b3:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f01014ba:	00 
f01014bb:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01014c2:	e8 ea eb ff ff       	call   f01000b1 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014c7:	89 34 24             	mov    %esi,(%esp)
f01014ca:	e8 ef f9 ff ff       	call   f0100ebe <page_free>
	page_free(pp1);
f01014cf:	89 3c 24             	mov    %edi,(%esp)
f01014d2:	e8 e7 f9 ff ff       	call   f0100ebe <page_free>
	page_free(pp2);
f01014d7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014da:	89 04 24             	mov    %eax,(%esp)
f01014dd:	e8 dc f9 ff ff       	call   f0100ebe <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014e2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014e9:	e8 4c f9 ff ff       	call   f0100e3a <page_alloc>
f01014ee:	89 c6                	mov    %eax,%esi
f01014f0:	85 c0                	test   %eax,%eax
f01014f2:	75 24                	jne    f0101518 <mem_init+0x3ac>
f01014f4:	c7 44 24 0c 4d 5d 10 	movl   $0xf0105d4d,0xc(%esp)
f01014fb:	f0 
f01014fc:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101503:	f0 
f0101504:	c7 44 24 04 e2 02 00 	movl   $0x2e2,0x4(%esp)
f010150b:	00 
f010150c:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101513:	e8 99 eb ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0101518:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010151f:	e8 16 f9 ff ff       	call   f0100e3a <page_alloc>
f0101524:	89 c7                	mov    %eax,%edi
f0101526:	85 c0                	test   %eax,%eax
f0101528:	75 24                	jne    f010154e <mem_init+0x3e2>
f010152a:	c7 44 24 0c 63 5d 10 	movl   $0xf0105d63,0xc(%esp)
f0101531:	f0 
f0101532:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101539:	f0 
f010153a:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0101541:	00 
f0101542:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101549:	e8 63 eb ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f010154e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101555:	e8 e0 f8 ff ff       	call   f0100e3a <page_alloc>
f010155a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010155d:	85 c0                	test   %eax,%eax
f010155f:	75 24                	jne    f0101585 <mem_init+0x419>
f0101561:	c7 44 24 0c 79 5d 10 	movl   $0xf0105d79,0xc(%esp)
f0101568:	f0 
f0101569:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101570:	f0 
f0101571:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f0101578:	00 
f0101579:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101580:	e8 2c eb ff ff       	call   f01000b1 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101585:	39 fe                	cmp    %edi,%esi
f0101587:	75 24                	jne    f01015ad <mem_init+0x441>
f0101589:	c7 44 24 0c 8f 5d 10 	movl   $0xf0105d8f,0xc(%esp)
f0101590:	f0 
f0101591:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101598:	f0 
f0101599:	c7 44 24 04 e6 02 00 	movl   $0x2e6,0x4(%esp)
f01015a0:	00 
f01015a1:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01015a8:	e8 04 eb ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01015ad:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01015b0:	74 05                	je     f01015b7 <mem_init+0x44b>
f01015b2:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01015b5:	75 24                	jne    f01015db <mem_init+0x46f>
f01015b7:	c7 44 24 0c 0c 56 10 	movl   $0xf010560c,0xc(%esp)
f01015be:	f0 
f01015bf:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01015c6:	f0 
f01015c7:	c7 44 24 04 e7 02 00 	movl   $0x2e7,0x4(%esp)
f01015ce:	00 
f01015cf:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01015d6:	e8 d6 ea ff ff       	call   f01000b1 <_panic>
	assert(!page_alloc(0));
f01015db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015e2:	e8 53 f8 ff ff       	call   f0100e3a <page_alloc>
f01015e7:	85 c0                	test   %eax,%eax
f01015e9:	74 24                	je     f010160f <mem_init+0x4a3>
f01015eb:	c7 44 24 0c f8 5d 10 	movl   $0xf0105df8,0xc(%esp)
f01015f2:	f0 
f01015f3:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01015fa:	f0 
f01015fb:	c7 44 24 04 e8 02 00 	movl   $0x2e8,0x4(%esp)
f0101602:	00 
f0101603:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010160a:	e8 a2 ea ff ff       	call   f01000b1 <_panic>
f010160f:	89 f0                	mov    %esi,%eax
f0101611:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f0101617:	c1 f8 03             	sar    $0x3,%eax
f010161a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010161d:	89 c2                	mov    %eax,%edx
f010161f:	c1 ea 0c             	shr    $0xc,%edx
f0101622:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0101628:	72 20                	jb     f010164a <mem_init+0x4de>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010162a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010162e:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0101635:	f0 
f0101636:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f010163d:	00 
f010163e:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0101645:	e8 67 ea ff ff       	call   f01000b1 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010164a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101651:	00 
f0101652:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101659:	00 
	return (void *)(pa + KERNBASE);
f010165a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010165f:	89 04 24             	mov    %eax,(%esp)
f0101662:	e8 67 34 00 00       	call   f0104ace <memset>
	page_free(pp0);
f0101667:	89 34 24             	mov    %esi,(%esp)
f010166a:	e8 4f f8 ff ff       	call   f0100ebe <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f010166f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101676:	e8 bf f7 ff ff       	call   f0100e3a <page_alloc>
f010167b:	85 c0                	test   %eax,%eax
f010167d:	75 24                	jne    f01016a3 <mem_init+0x537>
f010167f:	c7 44 24 0c 07 5e 10 	movl   $0xf0105e07,0xc(%esp)
f0101686:	f0 
f0101687:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010168e:	f0 
f010168f:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101696:	00 
f0101697:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010169e:	e8 0e ea ff ff       	call   f01000b1 <_panic>
	assert(pp && pp0 == pp);
f01016a3:	39 c6                	cmp    %eax,%esi
f01016a5:	74 24                	je     f01016cb <mem_init+0x55f>
f01016a7:	c7 44 24 0c 25 5e 10 	movl   $0xf0105e25,0xc(%esp)
f01016ae:	f0 
f01016af:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01016b6:	f0 
f01016b7:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f01016be:	00 
f01016bf:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01016c6:	e8 e6 e9 ff ff       	call   f01000b1 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016cb:	89 f2                	mov    %esi,%edx
f01016cd:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f01016d3:	c1 fa 03             	sar    $0x3,%edx
f01016d6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016d9:	89 d0                	mov    %edx,%eax
f01016db:	c1 e8 0c             	shr    $0xc,%eax
f01016de:	3b 05 48 3e 1e f0    	cmp    0xf01e3e48,%eax
f01016e4:	72 20                	jb     f0101706 <mem_init+0x59a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016e6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01016ea:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f01016f1:	f0 
f01016f2:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01016f9:	00 
f01016fa:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0101701:	e8 ab e9 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0101706:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010170c:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101712:	80 38 00             	cmpb   $0x0,(%eax)
f0101715:	74 24                	je     f010173b <mem_init+0x5cf>
f0101717:	c7 44 24 0c 35 5e 10 	movl   $0xf0105e35,0xc(%esp)
f010171e:	f0 
f010171f:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101726:	f0 
f0101727:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f010172e:	00 
f010172f:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101736:	e8 76 e9 ff ff       	call   f01000b1 <_panic>
f010173b:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010173c:	39 d0                	cmp    %edx,%eax
f010173e:	75 d2                	jne    f0101712 <mem_init+0x5a6>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101740:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101743:	89 15 a0 31 1e f0    	mov    %edx,0xf01e31a0

	// free the pages we took
	page_free(pp0);
f0101749:	89 34 24             	mov    %esi,(%esp)
f010174c:	e8 6d f7 ff ff       	call   f0100ebe <page_free>
	page_free(pp1);
f0101751:	89 3c 24             	mov    %edi,(%esp)
f0101754:	e8 65 f7 ff ff       	call   f0100ebe <page_free>
	page_free(pp2);
f0101759:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010175c:	89 04 24             	mov    %eax,(%esp)
f010175f:	e8 5a f7 ff ff       	call   f0100ebe <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101764:	a1 a0 31 1e f0       	mov    0xf01e31a0,%eax
f0101769:	eb 03                	jmp    f010176e <mem_init+0x602>
		--nfree;
f010176b:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010176c:	8b 00                	mov    (%eax),%eax
f010176e:	85 c0                	test   %eax,%eax
f0101770:	75 f9                	jne    f010176b <mem_init+0x5ff>
		--nfree;
	assert(nfree == 0);
f0101772:	85 db                	test   %ebx,%ebx
f0101774:	74 24                	je     f010179a <mem_init+0x62e>
f0101776:	c7 44 24 0c 3f 5e 10 	movl   $0xf0105e3f,0xc(%esp)
f010177d:	f0 
f010177e:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101785:	f0 
f0101786:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f010178d:	00 
f010178e:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101795:	e8 17 e9 ff ff       	call   f01000b1 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010179a:	c7 04 24 2c 56 10 f0 	movl   $0xf010562c,(%esp)
f01017a1:	e8 00 1f 00 00       	call   f01036a6 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01017a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017ad:	e8 88 f6 ff ff       	call   f0100e3a <page_alloc>
f01017b2:	89 c7                	mov    %eax,%edi
f01017b4:	85 c0                	test   %eax,%eax
f01017b6:	75 24                	jne    f01017dc <mem_init+0x670>
f01017b8:	c7 44 24 0c 4d 5d 10 	movl   $0xf0105d4d,0xc(%esp)
f01017bf:	f0 
f01017c0:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01017c7:	f0 
f01017c8:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f01017cf:	00 
f01017d0:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01017d7:	e8 d5 e8 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f01017dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017e3:	e8 52 f6 ff ff       	call   f0100e3a <page_alloc>
f01017e8:	89 c6                	mov    %eax,%esi
f01017ea:	85 c0                	test   %eax,%eax
f01017ec:	75 24                	jne    f0101812 <mem_init+0x6a6>
f01017ee:	c7 44 24 0c 63 5d 10 	movl   $0xf0105d63,0xc(%esp)
f01017f5:	f0 
f01017f6:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01017fd:	f0 
f01017fe:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0101805:	00 
f0101806:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010180d:	e8 9f e8 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0101812:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101819:	e8 1c f6 ff ff       	call   f0100e3a <page_alloc>
f010181e:	89 c3                	mov    %eax,%ebx
f0101820:	85 c0                	test   %eax,%eax
f0101822:	75 24                	jne    f0101848 <mem_init+0x6dc>
f0101824:	c7 44 24 0c 79 5d 10 	movl   $0xf0105d79,0xc(%esp)
f010182b:	f0 
f010182c:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101833:	f0 
f0101834:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f010183b:	00 
f010183c:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101843:	e8 69 e8 ff ff       	call   f01000b1 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101848:	39 f7                	cmp    %esi,%edi
f010184a:	75 24                	jne    f0101870 <mem_init+0x704>
f010184c:	c7 44 24 0c 8f 5d 10 	movl   $0xf0105d8f,0xc(%esp)
f0101853:	f0 
f0101854:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010185b:	f0 
f010185c:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f0101863:	00 
f0101864:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010186b:	e8 41 e8 ff ff       	call   f01000b1 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101870:	39 c6                	cmp    %eax,%esi
f0101872:	74 04                	je     f0101878 <mem_init+0x70c>
f0101874:	39 c7                	cmp    %eax,%edi
f0101876:	75 24                	jne    f010189c <mem_init+0x730>
f0101878:	c7 44 24 0c 0c 56 10 	movl   $0xf010560c,0xc(%esp)
f010187f:	f0 
f0101880:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101887:	f0 
f0101888:	c7 44 24 04 62 03 00 	movl   $0x362,0x4(%esp)
f010188f:	00 
f0101890:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101897:	e8 15 e8 ff ff       	call   f01000b1 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010189c:	8b 15 a0 31 1e f0    	mov    0xf01e31a0,%edx
f01018a2:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f01018a5:	c7 05 a0 31 1e f0 00 	movl   $0x0,0xf01e31a0
f01018ac:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018b6:	e8 7f f5 ff ff       	call   f0100e3a <page_alloc>
f01018bb:	85 c0                	test   %eax,%eax
f01018bd:	74 24                	je     f01018e3 <mem_init+0x777>
f01018bf:	c7 44 24 0c f8 5d 10 	movl   $0xf0105df8,0xc(%esp)
f01018c6:	f0 
f01018c7:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01018ce:	f0 
f01018cf:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f01018d6:	00 
f01018d7:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01018de:	e8 ce e7 ff ff       	call   f01000b1 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018e3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018e6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018ea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018f1:	00 
f01018f2:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f01018f7:	89 04 24             	mov    %eax,(%esp)
f01018fa:	e8 26 f7 ff ff       	call   f0101025 <page_lookup>
f01018ff:	85 c0                	test   %eax,%eax
f0101901:	74 24                	je     f0101927 <mem_init+0x7bb>
f0101903:	c7 44 24 0c 4c 56 10 	movl   $0xf010564c,0xc(%esp)
f010190a:	f0 
f010190b:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101912:	f0 
f0101913:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f010191a:	00 
f010191b:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101922:	e8 8a e7 ff ff       	call   f01000b1 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101927:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010192e:	00 
f010192f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101936:	00 
f0101937:	89 74 24 04          	mov    %esi,0x4(%esp)
f010193b:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101940:	89 04 24             	mov    %eax,(%esp)
f0101943:	e8 aa f7 ff ff       	call   f01010f2 <page_insert>
f0101948:	85 c0                	test   %eax,%eax
f010194a:	78 24                	js     f0101970 <mem_init+0x804>
f010194c:	c7 44 24 0c 84 56 10 	movl   $0xf0105684,0xc(%esp)
f0101953:	f0 
f0101954:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010195b:	f0 
f010195c:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f0101963:	00 
f0101964:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010196b:	e8 41 e7 ff ff       	call   f01000b1 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101970:	89 3c 24             	mov    %edi,(%esp)
f0101973:	e8 46 f5 ff ff       	call   f0100ebe <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101978:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010197f:	00 
f0101980:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101987:	00 
f0101988:	89 74 24 04          	mov    %esi,0x4(%esp)
f010198c:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101991:	89 04 24             	mov    %eax,(%esp)
f0101994:	e8 59 f7 ff ff       	call   f01010f2 <page_insert>
f0101999:	85 c0                	test   %eax,%eax
f010199b:	74 24                	je     f01019c1 <mem_init+0x855>
f010199d:	c7 44 24 0c b4 56 10 	movl   $0xf01056b4,0xc(%esp)
f01019a4:	f0 
f01019a5:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01019ac:	f0 
f01019ad:	c7 44 24 04 73 03 00 	movl   $0x373,0x4(%esp)
f01019b4:	00 
f01019b5:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01019bc:	e8 f0 e6 ff ff       	call   f01000b1 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01019c1:	8b 0d 4c 3e 1e f0    	mov    0xf01e3e4c,%ecx
f01019c7:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01019ca:	a1 50 3e 1e f0       	mov    0xf01e3e50,%eax
f01019cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01019d2:	8b 11                	mov    (%ecx),%edx
f01019d4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01019da:	89 f8                	mov    %edi,%eax
f01019dc:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01019df:	c1 f8 03             	sar    $0x3,%eax
f01019e2:	c1 e0 0c             	shl    $0xc,%eax
f01019e5:	39 c2                	cmp    %eax,%edx
f01019e7:	74 24                	je     f0101a0d <mem_init+0x8a1>
f01019e9:	c7 44 24 0c e4 56 10 	movl   $0xf01056e4,0xc(%esp)
f01019f0:	f0 
f01019f1:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01019f8:	f0 
f01019f9:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f0101a00:	00 
f0101a01:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101a08:	e8 a4 e6 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101a0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a12:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a15:	e8 ee ee ff ff       	call   f0100908 <check_va2pa>
f0101a1a:	89 f2                	mov    %esi,%edx
f0101a1c:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101a1f:	c1 fa 03             	sar    $0x3,%edx
f0101a22:	c1 e2 0c             	shl    $0xc,%edx
f0101a25:	39 d0                	cmp    %edx,%eax
f0101a27:	74 24                	je     f0101a4d <mem_init+0x8e1>
f0101a29:	c7 44 24 0c 0c 57 10 	movl   $0xf010570c,0xc(%esp)
f0101a30:	f0 
f0101a31:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101a38:	f0 
f0101a39:	c7 44 24 04 75 03 00 	movl   $0x375,0x4(%esp)
f0101a40:	00 
f0101a41:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101a48:	e8 64 e6 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0101a4d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a52:	74 24                	je     f0101a78 <mem_init+0x90c>
f0101a54:	c7 44 24 0c 4a 5e 10 	movl   $0xf0105e4a,0xc(%esp)
f0101a5b:	f0 
f0101a5c:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101a63:	f0 
f0101a64:	c7 44 24 04 76 03 00 	movl   $0x376,0x4(%esp)
f0101a6b:	00 
f0101a6c:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101a73:	e8 39 e6 ff ff       	call   f01000b1 <_panic>
	assert(pp0->pp_ref == 1);
f0101a78:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a7d:	74 24                	je     f0101aa3 <mem_init+0x937>
f0101a7f:	c7 44 24 0c 5b 5e 10 	movl   $0xf0105e5b,0xc(%esp)
f0101a86:	f0 
f0101a87:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101a8e:	f0 
f0101a8f:	c7 44 24 04 77 03 00 	movl   $0x377,0x4(%esp)
f0101a96:	00 
f0101a97:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101a9e:	e8 0e e6 ff ff       	call   f01000b1 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101aa3:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101aaa:	00 
f0101aab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ab2:	00 
f0101ab3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ab7:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101aba:	89 14 24             	mov    %edx,(%esp)
f0101abd:	e8 30 f6 ff ff       	call   f01010f2 <page_insert>
f0101ac2:	85 c0                	test   %eax,%eax
f0101ac4:	74 24                	je     f0101aea <mem_init+0x97e>
f0101ac6:	c7 44 24 0c 3c 57 10 	movl   $0xf010573c,0xc(%esp)
f0101acd:	f0 
f0101ace:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101ad5:	f0 
f0101ad6:	c7 44 24 04 7a 03 00 	movl   $0x37a,0x4(%esp)
f0101add:	00 
f0101ade:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101ae5:	e8 c7 e5 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aea:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101aef:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101af4:	e8 0f ee ff ff       	call   f0100908 <check_va2pa>
f0101af9:	89 da                	mov    %ebx,%edx
f0101afb:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f0101b01:	c1 fa 03             	sar    $0x3,%edx
f0101b04:	c1 e2 0c             	shl    $0xc,%edx
f0101b07:	39 d0                	cmp    %edx,%eax
f0101b09:	74 24                	je     f0101b2f <mem_init+0x9c3>
f0101b0b:	c7 44 24 0c 78 57 10 	movl   $0xf0105778,0xc(%esp)
f0101b12:	f0 
f0101b13:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101b1a:	f0 
f0101b1b:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f0101b22:	00 
f0101b23:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101b2a:	e8 82 e5 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0101b2f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b34:	74 24                	je     f0101b5a <mem_init+0x9ee>
f0101b36:	c7 44 24 0c 6c 5e 10 	movl   $0xf0105e6c,0xc(%esp)
f0101b3d:	f0 
f0101b3e:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101b45:	f0 
f0101b46:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0101b4d:	00 
f0101b4e:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101b55:	e8 57 e5 ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b61:	e8 d4 f2 ff ff       	call   f0100e3a <page_alloc>
f0101b66:	85 c0                	test   %eax,%eax
f0101b68:	74 24                	je     f0101b8e <mem_init+0xa22>
f0101b6a:	c7 44 24 0c f8 5d 10 	movl   $0xf0105df8,0xc(%esp)
f0101b71:	f0 
f0101b72:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101b79:	f0 
f0101b7a:	c7 44 24 04 7f 03 00 	movl   $0x37f,0x4(%esp)
f0101b81:	00 
f0101b82:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101b89:	e8 23 e5 ff ff       	call   f01000b1 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b8e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b95:	00 
f0101b96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b9d:	00 
f0101b9e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ba2:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101ba7:	89 04 24             	mov    %eax,(%esp)
f0101baa:	e8 43 f5 ff ff       	call   f01010f2 <page_insert>
f0101baf:	85 c0                	test   %eax,%eax
f0101bb1:	74 24                	je     f0101bd7 <mem_init+0xa6b>
f0101bb3:	c7 44 24 0c 3c 57 10 	movl   $0xf010573c,0xc(%esp)
f0101bba:	f0 
f0101bbb:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101bc2:	f0 
f0101bc3:	c7 44 24 04 82 03 00 	movl   $0x382,0x4(%esp)
f0101bca:	00 
f0101bcb:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101bd2:	e8 da e4 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101bd7:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101bdc:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101be1:	e8 22 ed ff ff       	call   f0100908 <check_va2pa>
f0101be6:	89 da                	mov    %ebx,%edx
f0101be8:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f0101bee:	c1 fa 03             	sar    $0x3,%edx
f0101bf1:	c1 e2 0c             	shl    $0xc,%edx
f0101bf4:	39 d0                	cmp    %edx,%eax
f0101bf6:	74 24                	je     f0101c1c <mem_init+0xab0>
f0101bf8:	c7 44 24 0c 78 57 10 	movl   $0xf0105778,0xc(%esp)
f0101bff:	f0 
f0101c00:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101c07:	f0 
f0101c08:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0101c0f:	00 
f0101c10:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101c17:	e8 95 e4 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0101c1c:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c21:	74 24                	je     f0101c47 <mem_init+0xadb>
f0101c23:	c7 44 24 0c 6c 5e 10 	movl   $0xf0105e6c,0xc(%esp)
f0101c2a:	f0 
f0101c2b:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101c32:	f0 
f0101c33:	c7 44 24 04 84 03 00 	movl   $0x384,0x4(%esp)
f0101c3a:	00 
f0101c3b:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101c42:	e8 6a e4 ff ff       	call   f01000b1 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c47:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c4e:	e8 e7 f1 ff ff       	call   f0100e3a <page_alloc>
f0101c53:	85 c0                	test   %eax,%eax
f0101c55:	74 24                	je     f0101c7b <mem_init+0xb0f>
f0101c57:	c7 44 24 0c f8 5d 10 	movl   $0xf0105df8,0xc(%esp)
f0101c5e:	f0 
f0101c5f:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101c66:	f0 
f0101c67:	c7 44 24 04 88 03 00 	movl   $0x388,0x4(%esp)
f0101c6e:	00 
f0101c6f:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101c76:	e8 36 e4 ff ff       	call   f01000b1 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c7b:	8b 15 4c 3e 1e f0    	mov    0xf01e3e4c,%edx
f0101c81:	8b 02                	mov    (%edx),%eax
f0101c83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c88:	89 c1                	mov    %eax,%ecx
f0101c8a:	c1 e9 0c             	shr    $0xc,%ecx
f0101c8d:	3b 0d 48 3e 1e f0    	cmp    0xf01e3e48,%ecx
f0101c93:	72 20                	jb     f0101cb5 <mem_init+0xb49>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c95:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c99:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0101ca0:	f0 
f0101ca1:	c7 44 24 04 8b 03 00 	movl   $0x38b,0x4(%esp)
f0101ca8:	00 
f0101ca9:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101cb0:	e8 fc e3 ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f0101cb5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101cba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101cbd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101cc4:	00 
f0101cc5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ccc:	00 
f0101ccd:	89 14 24             	mov    %edx,(%esp)
f0101cd0:	e8 49 f2 ff ff       	call   f0100f1e <pgdir_walk>
f0101cd5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101cd8:	83 c2 04             	add    $0x4,%edx
f0101cdb:	39 d0                	cmp    %edx,%eax
f0101cdd:	74 24                	je     f0101d03 <mem_init+0xb97>
f0101cdf:	c7 44 24 0c a8 57 10 	movl   $0xf01057a8,0xc(%esp)
f0101ce6:	f0 
f0101ce7:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101cee:	f0 
f0101cef:	c7 44 24 04 8c 03 00 	movl   $0x38c,0x4(%esp)
f0101cf6:	00 
f0101cf7:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101cfe:	e8 ae e3 ff ff       	call   f01000b1 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101d03:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101d0a:	00 
f0101d0b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d12:	00 
f0101d13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d17:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101d1c:	89 04 24             	mov    %eax,(%esp)
f0101d1f:	e8 ce f3 ff ff       	call   f01010f2 <page_insert>
f0101d24:	85 c0                	test   %eax,%eax
f0101d26:	74 24                	je     f0101d4c <mem_init+0xbe0>
f0101d28:	c7 44 24 0c e8 57 10 	movl   $0xf01057e8,0xc(%esp)
f0101d2f:	f0 
f0101d30:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101d37:	f0 
f0101d38:	c7 44 24 04 8f 03 00 	movl   $0x38f,0x4(%esp)
f0101d3f:	00 
f0101d40:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101d47:	e8 65 e3 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d4c:	8b 0d 4c 3e 1e f0    	mov    0xf01e3e4c,%ecx
f0101d52:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101d55:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d5a:	89 c8                	mov    %ecx,%eax
f0101d5c:	e8 a7 eb ff ff       	call   f0100908 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d61:	89 da                	mov    %ebx,%edx
f0101d63:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f0101d69:	c1 fa 03             	sar    $0x3,%edx
f0101d6c:	c1 e2 0c             	shl    $0xc,%edx
f0101d6f:	39 d0                	cmp    %edx,%eax
f0101d71:	74 24                	je     f0101d97 <mem_init+0xc2b>
f0101d73:	c7 44 24 0c 78 57 10 	movl   $0xf0105778,0xc(%esp)
f0101d7a:	f0 
f0101d7b:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101d82:	f0 
f0101d83:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f0101d8a:	00 
f0101d8b:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101d92:	e8 1a e3 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0101d97:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d9c:	74 24                	je     f0101dc2 <mem_init+0xc56>
f0101d9e:	c7 44 24 0c 6c 5e 10 	movl   $0xf0105e6c,0xc(%esp)
f0101da5:	f0 
f0101da6:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101dad:	f0 
f0101dae:	c7 44 24 04 91 03 00 	movl   $0x391,0x4(%esp)
f0101db5:	00 
f0101db6:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101dbd:	e8 ef e2 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101dc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101dc9:	00 
f0101dca:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101dd1:	00 
f0101dd2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101dd5:	89 04 24             	mov    %eax,(%esp)
f0101dd8:	e8 41 f1 ff ff       	call   f0100f1e <pgdir_walk>
f0101ddd:	f6 00 04             	testb  $0x4,(%eax)
f0101de0:	75 24                	jne    f0101e06 <mem_init+0xc9a>
f0101de2:	c7 44 24 0c 28 58 10 	movl   $0xf0105828,0xc(%esp)
f0101de9:	f0 
f0101dea:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101df1:	f0 
f0101df2:	c7 44 24 04 92 03 00 	movl   $0x392,0x4(%esp)
f0101df9:	00 
f0101dfa:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101e01:	e8 ab e2 ff ff       	call   f01000b1 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101e06:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101e0b:	f6 00 04             	testb  $0x4,(%eax)
f0101e0e:	75 24                	jne    f0101e34 <mem_init+0xcc8>
f0101e10:	c7 44 24 0c 7d 5e 10 	movl   $0xf0105e7d,0xc(%esp)
f0101e17:	f0 
f0101e18:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 04 93 03 00 	movl   $0x393,0x4(%esp)
f0101e27:	00 
f0101e28:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101e2f:	e8 7d e2 ff ff       	call   f01000b1 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101e34:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e3b:	00 
f0101e3c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e43:	00 
f0101e44:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e48:	89 04 24             	mov    %eax,(%esp)
f0101e4b:	e8 a2 f2 ff ff       	call   f01010f2 <page_insert>
f0101e50:	85 c0                	test   %eax,%eax
f0101e52:	74 24                	je     f0101e78 <mem_init+0xd0c>
f0101e54:	c7 44 24 0c 3c 57 10 	movl   $0xf010573c,0xc(%esp)
f0101e5b:	f0 
f0101e5c:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101e63:	f0 
f0101e64:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f0101e6b:	00 
f0101e6c:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101e73:	e8 39 e2 ff ff       	call   f01000b1 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e78:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e7f:	00 
f0101e80:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e87:	00 
f0101e88:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101e8d:	89 04 24             	mov    %eax,(%esp)
f0101e90:	e8 89 f0 ff ff       	call   f0100f1e <pgdir_walk>
f0101e95:	f6 00 02             	testb  $0x2,(%eax)
f0101e98:	75 24                	jne    f0101ebe <mem_init+0xd52>
f0101e9a:	c7 44 24 0c 5c 58 10 	movl   $0xf010585c,0xc(%esp)
f0101ea1:	f0 
f0101ea2:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101ea9:	f0 
f0101eaa:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0101eb1:	00 
f0101eb2:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101eb9:	e8 f3 e1 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ebe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ec5:	00 
f0101ec6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ecd:	00 
f0101ece:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101ed3:	89 04 24             	mov    %eax,(%esp)
f0101ed6:	e8 43 f0 ff ff       	call   f0100f1e <pgdir_walk>
f0101edb:	f6 00 04             	testb  $0x4,(%eax)
f0101ede:	74 24                	je     f0101f04 <mem_init+0xd98>
f0101ee0:	c7 44 24 0c 90 58 10 	movl   $0xf0105890,0xc(%esp)
f0101ee7:	f0 
f0101ee8:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101eef:	f0 
f0101ef0:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f0101ef7:	00 
f0101ef8:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101eff:	e8 ad e1 ff ff       	call   f01000b1 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101f04:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f0b:	00 
f0101f0c:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101f13:	00 
f0101f14:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101f18:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101f1d:	89 04 24             	mov    %eax,(%esp)
f0101f20:	e8 cd f1 ff ff       	call   f01010f2 <page_insert>
f0101f25:	85 c0                	test   %eax,%eax
f0101f27:	78 24                	js     f0101f4d <mem_init+0xde1>
f0101f29:	c7 44 24 0c c8 58 10 	movl   $0xf01058c8,0xc(%esp)
f0101f30:	f0 
f0101f31:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101f38:	f0 
f0101f39:	c7 44 24 04 9b 03 00 	movl   $0x39b,0x4(%esp)
f0101f40:	00 
f0101f41:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101f48:	e8 64 e1 ff ff       	call   f01000b1 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f4d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f54:	00 
f0101f55:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f5c:	00 
f0101f5d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f61:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101f66:	89 04 24             	mov    %eax,(%esp)
f0101f69:	e8 84 f1 ff ff       	call   f01010f2 <page_insert>
f0101f6e:	85 c0                	test   %eax,%eax
f0101f70:	74 24                	je     f0101f96 <mem_init+0xe2a>
f0101f72:	c7 44 24 0c 00 59 10 	movl   $0xf0105900,0xc(%esp)
f0101f79:	f0 
f0101f7a:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101f81:	f0 
f0101f82:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0101f89:	00 
f0101f8a:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101f91:	e8 1b e1 ff ff       	call   f01000b1 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f9d:	00 
f0101f9e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101fa5:	00 
f0101fa6:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101fab:	89 04 24             	mov    %eax,(%esp)
f0101fae:	e8 6b ef ff ff       	call   f0100f1e <pgdir_walk>
f0101fb3:	f6 00 04             	testb  $0x4,(%eax)
f0101fb6:	74 24                	je     f0101fdc <mem_init+0xe70>
f0101fb8:	c7 44 24 0c 90 58 10 	movl   $0xf0105890,0xc(%esp)
f0101fbf:	f0 
f0101fc0:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0101fc7:	f0 
f0101fc8:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0101fcf:	00 
f0101fd0:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0101fd7:	e8 d5 e0 ff ff       	call   f01000b1 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fdc:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0101fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fe4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fe9:	e8 1a e9 ff ff       	call   f0100908 <check_va2pa>
f0101fee:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101ff1:	89 f0                	mov    %esi,%eax
f0101ff3:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f0101ff9:	c1 f8 03             	sar    $0x3,%eax
f0101ffc:	c1 e0 0c             	shl    $0xc,%eax
f0101fff:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102002:	74 24                	je     f0102028 <mem_init+0xebc>
f0102004:	c7 44 24 0c 3c 59 10 	movl   $0xf010593c,0xc(%esp)
f010200b:	f0 
f010200c:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102013:	f0 
f0102014:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f010201b:	00 
f010201c:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102023:	e8 89 e0 ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102028:	ba 00 10 00 00       	mov    $0x1000,%edx
f010202d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102030:	e8 d3 e8 ff ff       	call   f0100908 <check_va2pa>
f0102035:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0102038:	74 24                	je     f010205e <mem_init+0xef2>
f010203a:	c7 44 24 0c 68 59 10 	movl   $0xf0105968,0xc(%esp)
f0102041:	f0 
f0102042:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102049:	f0 
f010204a:	c7 44 24 04 a3 03 00 	movl   $0x3a3,0x4(%esp)
f0102051:	00 
f0102052:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102059:	e8 53 e0 ff ff       	call   f01000b1 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f010205e:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102063:	74 24                	je     f0102089 <mem_init+0xf1d>
f0102065:	c7 44 24 0c 93 5e 10 	movl   $0xf0105e93,0xc(%esp)
f010206c:	f0 
f010206d:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102074:	f0 
f0102075:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f010207c:	00 
f010207d:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102084:	e8 28 e0 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102089:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010208e:	74 24                	je     f01020b4 <mem_init+0xf48>
f0102090:	c7 44 24 0c a4 5e 10 	movl   $0xf0105ea4,0xc(%esp)
f0102097:	f0 
f0102098:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010209f:	f0 
f01020a0:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f01020a7:	00 
f01020a8:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01020af:	e8 fd df ff ff       	call   f01000b1 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f01020b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01020bb:	e8 7a ed ff ff       	call   f0100e3a <page_alloc>
f01020c0:	85 c0                	test   %eax,%eax
f01020c2:	74 04                	je     f01020c8 <mem_init+0xf5c>
f01020c4:	39 c3                	cmp    %eax,%ebx
f01020c6:	74 24                	je     f01020ec <mem_init+0xf80>
f01020c8:	c7 44 24 0c 98 59 10 	movl   $0xf0105998,0xc(%esp)
f01020cf:	f0 
f01020d0:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01020d7:	f0 
f01020d8:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f01020df:	00 
f01020e0:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01020e7:	e8 c5 df ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020ec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020f3:	00 
f01020f4:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f01020f9:	89 04 24             	mov    %eax,(%esp)
f01020fc:	e8 a8 ef ff ff       	call   f01010a9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102101:	8b 15 4c 3e 1e f0    	mov    0xf01e3e4c,%edx
f0102107:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010210a:	ba 00 00 00 00       	mov    $0x0,%edx
f010210f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102112:	e8 f1 e7 ff ff       	call   f0100908 <check_va2pa>
f0102117:	83 f8 ff             	cmp    $0xffffffff,%eax
f010211a:	74 24                	je     f0102140 <mem_init+0xfd4>
f010211c:	c7 44 24 0c bc 59 10 	movl   $0xf01059bc,0xc(%esp)
f0102123:	f0 
f0102124:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010212b:	f0 
f010212c:	c7 44 24 04 ad 03 00 	movl   $0x3ad,0x4(%esp)
f0102133:	00 
f0102134:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010213b:	e8 71 df ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102140:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102145:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102148:	e8 bb e7 ff ff       	call   f0100908 <check_va2pa>
f010214d:	89 f2                	mov    %esi,%edx
f010214f:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f0102155:	c1 fa 03             	sar    $0x3,%edx
f0102158:	c1 e2 0c             	shl    $0xc,%edx
f010215b:	39 d0                	cmp    %edx,%eax
f010215d:	74 24                	je     f0102183 <mem_init+0x1017>
f010215f:	c7 44 24 0c 68 59 10 	movl   $0xf0105968,0xc(%esp)
f0102166:	f0 
f0102167:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010216e:	f0 
f010216f:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102176:	00 
f0102177:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010217e:	e8 2e df ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 1);
f0102183:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102188:	74 24                	je     f01021ae <mem_init+0x1042>
f010218a:	c7 44 24 0c 4a 5e 10 	movl   $0xf0105e4a,0xc(%esp)
f0102191:	f0 
f0102192:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102199:	f0 
f010219a:	c7 44 24 04 af 03 00 	movl   $0x3af,0x4(%esp)
f01021a1:	00 
f01021a2:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01021a9:	e8 03 df ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f01021ae:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01021b3:	74 24                	je     f01021d9 <mem_init+0x106d>
f01021b5:	c7 44 24 0c a4 5e 10 	movl   $0xf0105ea4,0xc(%esp)
f01021bc:	f0 
f01021bd:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01021c4:	f0 
f01021c5:	c7 44 24 04 b0 03 00 	movl   $0x3b0,0x4(%esp)
f01021cc:	00 
f01021cd:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01021d4:	e8 d8 de ff ff       	call   f01000b1 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f01021d9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021e0:	00 
f01021e1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021e8:	00 
f01021e9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021ed:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01021f0:	89 0c 24             	mov    %ecx,(%esp)
f01021f3:	e8 fa ee ff ff       	call   f01010f2 <page_insert>
f01021f8:	85 c0                	test   %eax,%eax
f01021fa:	74 24                	je     f0102220 <mem_init+0x10b4>
f01021fc:	c7 44 24 0c e0 59 10 	movl   $0xf01059e0,0xc(%esp)
f0102203:	f0 
f0102204:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010220b:	f0 
f010220c:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102213:	00 
f0102214:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010221b:	e8 91 de ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref);
f0102220:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102225:	75 24                	jne    f010224b <mem_init+0x10df>
f0102227:	c7 44 24 0c b5 5e 10 	movl   $0xf0105eb5,0xc(%esp)
f010222e:	f0 
f010222f:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102236:	f0 
f0102237:	c7 44 24 04 b4 03 00 	movl   $0x3b4,0x4(%esp)
f010223e:	00 
f010223f:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102246:	e8 66 de ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_link == NULL);
f010224b:	83 3e 00             	cmpl   $0x0,(%esi)
f010224e:	74 24                	je     f0102274 <mem_init+0x1108>
f0102250:	c7 44 24 0c c1 5e 10 	movl   $0xf0105ec1,0xc(%esp)
f0102257:	f0 
f0102258:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010225f:	f0 
f0102260:	c7 44 24 04 b5 03 00 	movl   $0x3b5,0x4(%esp)
f0102267:	00 
f0102268:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010226f:	e8 3d de ff ff       	call   f01000b1 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102274:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010227b:	00 
f010227c:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102281:	89 04 24             	mov    %eax,(%esp)
f0102284:	e8 20 ee ff ff       	call   f01010a9 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102289:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f010228e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102291:	ba 00 00 00 00       	mov    $0x0,%edx
f0102296:	e8 6d e6 ff ff       	call   f0100908 <check_va2pa>
f010229b:	83 f8 ff             	cmp    $0xffffffff,%eax
f010229e:	74 24                	je     f01022c4 <mem_init+0x1158>
f01022a0:	c7 44 24 0c bc 59 10 	movl   $0xf01059bc,0xc(%esp)
f01022a7:	f0 
f01022a8:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01022af:	f0 
f01022b0:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f01022b7:	00 
f01022b8:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01022bf:	e8 ed dd ff ff       	call   f01000b1 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f01022c4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01022cc:	e8 37 e6 ff ff       	call   f0100908 <check_va2pa>
f01022d1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01022d4:	74 24                	je     f01022fa <mem_init+0x118e>
f01022d6:	c7 44 24 0c 18 5a 10 	movl   $0xf0105a18,0xc(%esp)
f01022dd:	f0 
f01022de:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01022e5:	f0 
f01022e6:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f01022ed:	00 
f01022ee:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01022f5:	e8 b7 dd ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f01022fa:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022ff:	74 24                	je     f0102325 <mem_init+0x11b9>
f0102301:	c7 44 24 0c d6 5e 10 	movl   $0xf0105ed6,0xc(%esp)
f0102308:	f0 
f0102309:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102310:	f0 
f0102311:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0102318:	00 
f0102319:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102320:	e8 8c dd ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 0);
f0102325:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010232a:	74 24                	je     f0102350 <mem_init+0x11e4>
f010232c:	c7 44 24 0c a4 5e 10 	movl   $0xf0105ea4,0xc(%esp)
f0102333:	f0 
f0102334:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010233b:	f0 
f010233c:	c7 44 24 04 bc 03 00 	movl   $0x3bc,0x4(%esp)
f0102343:	00 
f0102344:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010234b:	e8 61 dd ff ff       	call   f01000b1 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102350:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102357:	e8 de ea ff ff       	call   f0100e3a <page_alloc>
f010235c:	85 c0                	test   %eax,%eax
f010235e:	74 04                	je     f0102364 <mem_init+0x11f8>
f0102360:	39 c6                	cmp    %eax,%esi
f0102362:	74 24                	je     f0102388 <mem_init+0x121c>
f0102364:	c7 44 24 0c 40 5a 10 	movl   $0xf0105a40,0xc(%esp)
f010236b:	f0 
f010236c:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102373:	f0 
f0102374:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f010237b:	00 
f010237c:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102383:	e8 29 dd ff ff       	call   f01000b1 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102388:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010238f:	e8 a6 ea ff ff       	call   f0100e3a <page_alloc>
f0102394:	85 c0                	test   %eax,%eax
f0102396:	74 24                	je     f01023bc <mem_init+0x1250>
f0102398:	c7 44 24 0c f8 5d 10 	movl   $0xf0105df8,0xc(%esp)
f010239f:	f0 
f01023a0:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01023a7:	f0 
f01023a8:	c7 44 24 04 c2 03 00 	movl   $0x3c2,0x4(%esp)
f01023af:	00 
f01023b0:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01023b7:	e8 f5 dc ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01023bc:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f01023c1:	8b 08                	mov    (%eax),%ecx
f01023c3:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01023c9:	89 fa                	mov    %edi,%edx
f01023cb:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f01023d1:	c1 fa 03             	sar    $0x3,%edx
f01023d4:	c1 e2 0c             	shl    $0xc,%edx
f01023d7:	39 d1                	cmp    %edx,%ecx
f01023d9:	74 24                	je     f01023ff <mem_init+0x1293>
f01023db:	c7 44 24 0c e4 56 10 	movl   $0xf01056e4,0xc(%esp)
f01023e2:	f0 
f01023e3:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01023ea:	f0 
f01023eb:	c7 44 24 04 c5 03 00 	movl   $0x3c5,0x4(%esp)
f01023f2:	00 
f01023f3:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01023fa:	e8 b2 dc ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f01023ff:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102405:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010240a:	74 24                	je     f0102430 <mem_init+0x12c4>
f010240c:	c7 44 24 0c 5b 5e 10 	movl   $0xf0105e5b,0xc(%esp)
f0102413:	f0 
f0102414:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010241b:	f0 
f010241c:	c7 44 24 04 c7 03 00 	movl   $0x3c7,0x4(%esp)
f0102423:	00 
f0102424:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010242b:	e8 81 dc ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0102430:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102436:	89 3c 24             	mov    %edi,(%esp)
f0102439:	e8 80 ea ff ff       	call   f0100ebe <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010243e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102445:	00 
f0102446:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010244d:	00 
f010244e:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102453:	89 04 24             	mov    %eax,(%esp)
f0102456:	e8 c3 ea ff ff       	call   f0100f1e <pgdir_walk>
f010245b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010245e:	8b 0d 4c 3e 1e f0    	mov    0xf01e3e4c,%ecx
f0102464:	8b 51 04             	mov    0x4(%ecx),%edx
f0102467:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010246d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102470:	8b 15 48 3e 1e f0    	mov    0xf01e3e48,%edx
f0102476:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102479:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010247c:	c1 ea 0c             	shr    $0xc,%edx
f010247f:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102482:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102485:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102488:	72 23                	jb     f01024ad <mem_init+0x1341>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010248a:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010248d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102491:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0102498:	f0 
f0102499:	c7 44 24 04 ce 03 00 	movl   $0x3ce,0x4(%esp)
f01024a0:	00 
f01024a1:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01024a8:	e8 04 dc ff ff       	call   f01000b1 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01024ad:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01024b0:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01024b6:	39 d0                	cmp    %edx,%eax
f01024b8:	74 24                	je     f01024de <mem_init+0x1372>
f01024ba:	c7 44 24 0c e7 5e 10 	movl   $0xf0105ee7,0xc(%esp)
f01024c1:	f0 
f01024c2:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01024c9:	f0 
f01024ca:	c7 44 24 04 cf 03 00 	movl   $0x3cf,0x4(%esp)
f01024d1:	00 
f01024d2:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01024d9:	e8 d3 db ff ff       	call   f01000b1 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024de:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024e5:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024eb:	89 f8                	mov    %edi,%eax
f01024ed:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f01024f3:	c1 f8 03             	sar    $0x3,%eax
f01024f6:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024f9:	89 c1                	mov    %eax,%ecx
f01024fb:	c1 e9 0c             	shr    $0xc,%ecx
f01024fe:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102501:	77 20                	ja     f0102523 <mem_init+0x13b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102503:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102507:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f010250e:	f0 
f010250f:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102516:	00 
f0102517:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f010251e:	e8 8e db ff ff       	call   f01000b1 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102523:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010252a:	00 
f010252b:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102532:	00 
	return (void *)(pa + KERNBASE);
f0102533:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102538:	89 04 24             	mov    %eax,(%esp)
f010253b:	e8 8e 25 00 00       	call   f0104ace <memset>
	page_free(pp0);
f0102540:	89 3c 24             	mov    %edi,(%esp)
f0102543:	e8 76 e9 ff ff       	call   f0100ebe <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102548:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f010254f:	00 
f0102550:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102557:	00 
f0102558:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f010255d:	89 04 24             	mov    %eax,(%esp)
f0102560:	e8 b9 e9 ff ff       	call   f0100f1e <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102565:	89 fa                	mov    %edi,%edx
f0102567:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f010256d:	c1 fa 03             	sar    $0x3,%edx
f0102570:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102573:	89 d0                	mov    %edx,%eax
f0102575:	c1 e8 0c             	shr    $0xc,%eax
f0102578:	3b 05 48 3e 1e f0    	cmp    0xf01e3e48,%eax
f010257e:	72 20                	jb     f01025a0 <mem_init+0x1434>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102580:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102584:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f010258b:	f0 
f010258c:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102593:	00 
f0102594:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f010259b:	e8 11 db ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f01025a0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01025a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01025a9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01025af:	f6 00 01             	testb  $0x1,(%eax)
f01025b2:	74 24                	je     f01025d8 <mem_init+0x146c>
f01025b4:	c7 44 24 0c ff 5e 10 	movl   $0xf0105eff,0xc(%esp)
f01025bb:	f0 
f01025bc:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01025c3:	f0 
f01025c4:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f01025cb:	00 
f01025cc:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01025d3:	e8 d9 da ff ff       	call   f01000b1 <_panic>
f01025d8:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f01025db:	39 d0                	cmp    %edx,%eax
f01025dd:	75 d0                	jne    f01025af <mem_init+0x1443>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025df:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f01025e4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025ea:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01025f0:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01025f3:	89 0d a0 31 1e f0    	mov    %ecx,0xf01e31a0

	// free the pages we took
	page_free(pp0);
f01025f9:	89 3c 24             	mov    %edi,(%esp)
f01025fc:	e8 bd e8 ff ff       	call   f0100ebe <page_free>
	page_free(pp1);
f0102601:	89 34 24             	mov    %esi,(%esp)
f0102604:	e8 b5 e8 ff ff       	call   f0100ebe <page_free>
	page_free(pp2);
f0102609:	89 1c 24             	mov    %ebx,(%esp)
f010260c:	e8 ad e8 ff ff       	call   f0100ebe <page_free>

	cprintf("check_page() succeeded!\n");
f0102611:	c7 04 24 16 5f 10 f0 	movl   $0xf0105f16,(%esp)
f0102618:	e8 89 10 00 00       	call   f01036a6 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_W);
f010261d:	a1 50 3e 1e f0       	mov    0xf01e3e50,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102622:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102627:	77 20                	ja     f0102649 <mem_init+0x14dd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102629:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010262d:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f0102634:	f0 
f0102635:	c7 44 24 04 c0 00 00 	movl   $0xc0,0x4(%esp)
f010263c:	00 
f010263d:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102644:	e8 68 da ff ff       	call   f01000b1 <_panic>
f0102649:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102650:	00 
	return (physaddr_t)kva - KERNBASE;
f0102651:	05 00 00 00 10       	add    $0x10000000,%eax
f0102656:	89 04 24             	mov    %eax,(%esp)
f0102659:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010265e:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102663:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102668:	e8 50 e9 ff ff       	call   f0100fbd <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_W | PTE_U);
f010266d:	a1 ac 31 1e f0       	mov    0xf01e31ac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102672:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102677:	77 20                	ja     f0102699 <mem_init+0x152d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102679:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010267d:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f0102684:	f0 
f0102685:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
f010268c:	00 
f010268d:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102694:	e8 18 da ff ff       	call   f01000b1 <_panic>
f0102699:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
f01026a0:	00 
	return (physaddr_t)kva - KERNBASE;
f01026a1:	05 00 00 00 10       	add    $0x10000000,%eax
f01026a6:	89 04 24             	mov    %eax,(%esp)
f01026a9:	b9 00 80 01 00       	mov    $0x18000,%ecx
f01026ae:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01026b3:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f01026b8:	e8 00 e9 ff ff       	call   f0100fbd <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026bd:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01026c2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01026c7:	77 20                	ja     f01026e9 <mem_init+0x157d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01026cd:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f01026d4:	f0 
f01026d5:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
f01026dc:	00 
f01026dd:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01026e4:	e8 c8 d9 ff ff       	call   f01000b1 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01026e9:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01026f0:	00 
f01026f1:	c7 04 24 00 90 11 00 	movl   $0x119000,(%esp)
f01026f8:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01026fd:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102702:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102707:	e8 b1 e8 ff ff       	call   f0100fbd <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 2*npages*PGSIZE, 0, PTE_W);
f010270c:	8b 0d 48 3e 1e f0    	mov    0xf01e3e48,%ecx
f0102712:	c1 e1 0d             	shl    $0xd,%ecx
f0102715:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010271c:	00 
f010271d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102724:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102729:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f010272e:	e8 8a e8 ff ff       	call   f0100fbd <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102733:	8b 1d 4c 3e 1e f0    	mov    0xf01e3e4c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102739:	8b 15 48 3e 1e f0    	mov    0xf01e3e48,%edx
f010273f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0102742:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
f0102749:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f010274f:	be 00 00 00 00       	mov    $0x0,%esi
f0102754:	eb 70                	jmp    f01027c6 <mem_init+0x165a>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102756:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010275c:	89 d8                	mov    %ebx,%eax
f010275e:	e8 a5 e1 ff ff       	call   f0100908 <check_va2pa>
f0102763:	8b 15 50 3e 1e f0    	mov    0xf01e3e50,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102769:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010276f:	77 20                	ja     f0102791 <mem_init+0x1625>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102771:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102775:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f010277c:	f0 
f010277d:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0102784:	00 
f0102785:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010278c:	e8 20 d9 ff ff       	call   f01000b1 <_panic>
f0102791:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102798:	39 d0                	cmp    %edx,%eax
f010279a:	74 24                	je     f01027c0 <mem_init+0x1654>
f010279c:	c7 44 24 0c 64 5a 10 	movl   $0xf0105a64,0xc(%esp)
f01027a3:	f0 
f01027a4:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01027ab:	f0 
f01027ac:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f01027b3:	00 
f01027b4:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01027bb:	e8 f1 d8 ff ff       	call   f01000b1 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01027c0:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01027c6:	39 f7                	cmp    %esi,%edi
f01027c8:	77 8c                	ja     f0102756 <mem_init+0x15ea>
f01027ca:	be 00 00 00 00       	mov    $0x0,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01027cf:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01027d5:	89 d8                	mov    %ebx,%eax
f01027d7:	e8 2c e1 ff ff       	call   f0100908 <check_va2pa>
f01027dc:	8b 15 ac 31 1e f0    	mov    0xf01e31ac,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027e2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01027e8:	77 20                	ja     f010280a <mem_init+0x169e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027ea:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01027ee:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f01027f5:	f0 
f01027f6:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f01027fd:	00 
f01027fe:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102805:	e8 a7 d8 ff ff       	call   f01000b1 <_panic>
f010280a:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102811:	39 d0                	cmp    %edx,%eax
f0102813:	74 24                	je     f0102839 <mem_init+0x16cd>
f0102815:	c7 44 24 0c 98 5a 10 	movl   $0xf0105a98,0xc(%esp)
f010281c:	f0 
f010281d:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102824:	f0 
f0102825:	c7 44 24 04 1b 03 00 	movl   $0x31b,0x4(%esp)
f010282c:	00 
f010282d:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102834:	e8 78 d8 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102839:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010283f:	81 fe 00 80 01 00    	cmp    $0x18000,%esi
f0102845:	75 88                	jne    f01027cf <mem_init+0x1663>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102847:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010284a:	c1 e7 0c             	shl    $0xc,%edi
f010284d:	be 00 00 00 00       	mov    $0x0,%esi
f0102852:	eb 3b                	jmp    f010288f <mem_init+0x1723>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102854:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010285a:	89 d8                	mov    %ebx,%eax
f010285c:	e8 a7 e0 ff ff       	call   f0100908 <check_va2pa>
f0102861:	39 c6                	cmp    %eax,%esi
f0102863:	74 24                	je     f0102889 <mem_init+0x171d>
f0102865:	c7 44 24 0c cc 5a 10 	movl   $0xf0105acc,0xc(%esp)
f010286c:	f0 
f010286d:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102874:	f0 
f0102875:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f010287c:	00 
f010287d:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102884:	e8 28 d8 ff ff       	call   f01000b1 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102889:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010288f:	39 fe                	cmp    %edi,%esi
f0102891:	72 c1                	jb     f0102854 <mem_init+0x16e8>
f0102893:	be 00 80 ff ef       	mov    $0xefff8000,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102898:	bf 00 90 11 f0       	mov    $0xf0119000,%edi
f010289d:	81 c7 00 80 00 20    	add    $0x20008000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028a3:	89 f2                	mov    %esi,%edx
f01028a5:	89 d8                	mov    %ebx,%eax
f01028a7:	e8 5c e0 ff ff       	call   f0100908 <check_va2pa>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01028ac:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01028af:	39 d0                	cmp    %edx,%eax
f01028b1:	74 24                	je     f01028d7 <mem_init+0x176b>
f01028b3:	c7 44 24 0c f4 5a 10 	movl   $0xf0105af4,0xc(%esp)
f01028ba:	f0 
f01028bb:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01028c2:	f0 
f01028c3:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f01028ca:	00 
f01028cb:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01028d2:	e8 da d7 ff ff       	call   f01000b1 <_panic>
f01028d7:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01028dd:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01028e3:	75 be                	jne    f01028a3 <mem_init+0x1737>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01028e5:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01028ea:	89 d8                	mov    %ebx,%eax
f01028ec:	e8 17 e0 ff ff       	call   f0100908 <check_va2pa>
f01028f1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028f4:	74 24                	je     f010291a <mem_init+0x17ae>
f01028f6:	c7 44 24 0c 3c 5b 10 	movl   $0xf0105b3c,0xc(%esp)
f01028fd:	f0 
f01028fe:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102905:	f0 
f0102906:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f010290d:	00 
f010290e:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102915:	e8 97 d7 ff ff       	call   f01000b1 <_panic>
f010291a:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f010291f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102924:	72 3c                	jb     f0102962 <mem_init+0x17f6>
f0102926:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f010292b:	76 07                	jbe    f0102934 <mem_init+0x17c8>
f010292d:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102932:	75 2e                	jne    f0102962 <mem_init+0x17f6>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f0102934:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102938:	0f 85 aa 00 00 00    	jne    f01029e8 <mem_init+0x187c>
f010293e:	c7 44 24 0c 2f 5f 10 	movl   $0xf0105f2f,0xc(%esp)
f0102945:	f0 
f0102946:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f010294d:	f0 
f010294e:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0102955:	00 
f0102956:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f010295d:	e8 4f d7 ff ff       	call   f01000b1 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102962:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102967:	76 55                	jbe    f01029be <mem_init+0x1852>
				assert(pgdir[i] & PTE_P);
f0102969:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f010296c:	f6 c2 01             	test   $0x1,%dl
f010296f:	75 24                	jne    f0102995 <mem_init+0x1829>
f0102971:	c7 44 24 0c 2f 5f 10 	movl   $0xf0105f2f,0xc(%esp)
f0102978:	f0 
f0102979:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102980:	f0 
f0102981:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0102988:	00 
f0102989:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102990:	e8 1c d7 ff ff       	call   f01000b1 <_panic>
				assert(pgdir[i] & PTE_W);
f0102995:	f6 c2 02             	test   $0x2,%dl
f0102998:	75 4e                	jne    f01029e8 <mem_init+0x187c>
f010299a:	c7 44 24 0c 40 5f 10 	movl   $0xf0105f40,0xc(%esp)
f01029a1:	f0 
f01029a2:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01029a9:	f0 
f01029aa:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f01029b1:	00 
f01029b2:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01029b9:	e8 f3 d6 ff ff       	call   f01000b1 <_panic>
			} else
				assert(pgdir[i] == 0);
f01029be:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f01029c2:	74 24                	je     f01029e8 <mem_init+0x187c>
f01029c4:	c7 44 24 0c 51 5f 10 	movl   $0xf0105f51,0xc(%esp)
f01029cb:	f0 
f01029cc:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f01029d3:	f0 
f01029d4:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f01029db:	00 
f01029dc:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f01029e3:	e8 c9 d6 ff ff       	call   f01000b1 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01029e8:	40                   	inc    %eax
f01029e9:	3d 00 04 00 00       	cmp    $0x400,%eax
f01029ee:	0f 85 2b ff ff ff    	jne    f010291f <mem_init+0x17b3>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01029f4:	c7 04 24 6c 5b 10 f0 	movl   $0xf0105b6c,(%esp)
f01029fb:	e8 a6 0c 00 00       	call   f01036a6 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102a00:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102a05:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102a0a:	77 20                	ja     f0102a2c <mem_init+0x18c0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a0c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a10:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f0102a17:	f0 
f0102a18:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
f0102a1f:	00 
f0102a20:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102a27:	e8 85 d6 ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102a2c:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102a31:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102a34:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a39:	e8 29 e0 ff ff       	call   f0100a67 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102a3e:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102a41:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102a46:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102a49:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102a4c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a53:	e8 e2 e3 ff ff       	call   f0100e3a <page_alloc>
f0102a58:	89 c6                	mov    %eax,%esi
f0102a5a:	85 c0                	test   %eax,%eax
f0102a5c:	75 24                	jne    f0102a82 <mem_init+0x1916>
f0102a5e:	c7 44 24 0c 4d 5d 10 	movl   $0xf0105d4d,0xc(%esp)
f0102a65:	f0 
f0102a66:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102a6d:	f0 
f0102a6e:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102a75:	00 
f0102a76:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102a7d:	e8 2f d6 ff ff       	call   f01000b1 <_panic>
	assert((pp1 = page_alloc(0)));
f0102a82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102a89:	e8 ac e3 ff ff       	call   f0100e3a <page_alloc>
f0102a8e:	89 c7                	mov    %eax,%edi
f0102a90:	85 c0                	test   %eax,%eax
f0102a92:	75 24                	jne    f0102ab8 <mem_init+0x194c>
f0102a94:	c7 44 24 0c 63 5d 10 	movl   $0xf0105d63,0xc(%esp)
f0102a9b:	f0 
f0102a9c:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102aa3:	f0 
f0102aa4:	c7 44 24 04 f5 03 00 	movl   $0x3f5,0x4(%esp)
f0102aab:	00 
f0102aac:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102ab3:	e8 f9 d5 ff ff       	call   f01000b1 <_panic>
	assert((pp2 = page_alloc(0)));
f0102ab8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102abf:	e8 76 e3 ff ff       	call   f0100e3a <page_alloc>
f0102ac4:	89 c3                	mov    %eax,%ebx
f0102ac6:	85 c0                	test   %eax,%eax
f0102ac8:	75 24                	jne    f0102aee <mem_init+0x1982>
f0102aca:	c7 44 24 0c 79 5d 10 	movl   $0xf0105d79,0xc(%esp)
f0102ad1:	f0 
f0102ad2:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102ad9:	f0 
f0102ada:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f0102ae1:	00 
f0102ae2:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102ae9:	e8 c3 d5 ff ff       	call   f01000b1 <_panic>
	page_free(pp0);
f0102aee:	89 34 24             	mov    %esi,(%esp)
f0102af1:	e8 c8 e3 ff ff       	call   f0100ebe <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102af6:	89 f8                	mov    %edi,%eax
f0102af8:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f0102afe:	c1 f8 03             	sar    $0x3,%eax
f0102b01:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b04:	89 c2                	mov    %eax,%edx
f0102b06:	c1 ea 0c             	shr    $0xc,%edx
f0102b09:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0102b0f:	72 20                	jb     f0102b31 <mem_init+0x19c5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b11:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b15:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0102b1c:	f0 
f0102b1d:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102b24:	00 
f0102b25:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0102b2c:	e8 80 d5 ff ff       	call   f01000b1 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102b31:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b38:	00 
f0102b39:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102b40:	00 
	return (void *)(pa + KERNBASE);
f0102b41:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b46:	89 04 24             	mov    %eax,(%esp)
f0102b49:	e8 80 1f 00 00       	call   f0104ace <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b4e:	89 d8                	mov    %ebx,%eax
f0102b50:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f0102b56:	c1 f8 03             	sar    $0x3,%eax
f0102b59:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b5c:	89 c2                	mov    %eax,%edx
f0102b5e:	c1 ea 0c             	shr    $0xc,%edx
f0102b61:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0102b67:	72 20                	jb     f0102b89 <mem_init+0x1a1d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b69:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b6d:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0102b74:	f0 
f0102b75:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102b7c:	00 
f0102b7d:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0102b84:	e8 28 d5 ff ff       	call   f01000b1 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102b89:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b90:	00 
f0102b91:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102b98:	00 
	return (void *)(pa + KERNBASE);
f0102b99:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102b9e:	89 04 24             	mov    %eax,(%esp)
f0102ba1:	e8 28 1f 00 00       	call   f0104ace <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102ba6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102bad:	00 
f0102bae:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102bb5:	00 
f0102bb6:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102bba:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102bbf:	89 04 24             	mov    %eax,(%esp)
f0102bc2:	e8 2b e5 ff ff       	call   f01010f2 <page_insert>
	assert(pp1->pp_ref == 1);
f0102bc7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102bcc:	74 24                	je     f0102bf2 <mem_init+0x1a86>
f0102bce:	c7 44 24 0c 4a 5e 10 	movl   $0xf0105e4a,0xc(%esp)
f0102bd5:	f0 
f0102bd6:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102bdd:	f0 
f0102bde:	c7 44 24 04 fb 03 00 	movl   $0x3fb,0x4(%esp)
f0102be5:	00 
f0102be6:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102bed:	e8 bf d4 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102bf2:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102bf9:	01 01 01 
f0102bfc:	74 24                	je     f0102c22 <mem_init+0x1ab6>
f0102bfe:	c7 44 24 0c 8c 5b 10 	movl   $0xf0105b8c,0xc(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102c0d:	f0 
f0102c0e:	c7 44 24 04 fc 03 00 	movl   $0x3fc,0x4(%esp)
f0102c15:	00 
f0102c16:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102c1d:	e8 8f d4 ff ff       	call   f01000b1 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102c22:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102c29:	00 
f0102c2a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c31:	00 
f0102c32:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102c36:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102c3b:	89 04 24             	mov    %eax,(%esp)
f0102c3e:	e8 af e4 ff ff       	call   f01010f2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c43:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c4a:	02 02 02 
f0102c4d:	74 24                	je     f0102c73 <mem_init+0x1b07>
f0102c4f:	c7 44 24 0c b0 5b 10 	movl   $0xf0105bb0,0xc(%esp)
f0102c56:	f0 
f0102c57:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102c5e:	f0 
f0102c5f:	c7 44 24 04 fe 03 00 	movl   $0x3fe,0x4(%esp)
f0102c66:	00 
f0102c67:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102c6e:	e8 3e d4 ff ff       	call   f01000b1 <_panic>
	assert(pp2->pp_ref == 1);
f0102c73:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c78:	74 24                	je     f0102c9e <mem_init+0x1b32>
f0102c7a:	c7 44 24 0c 6c 5e 10 	movl   $0xf0105e6c,0xc(%esp)
f0102c81:	f0 
f0102c82:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102c89:	f0 
f0102c8a:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102c91:	00 
f0102c92:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102c99:	e8 13 d4 ff ff       	call   f01000b1 <_panic>
	assert(pp1->pp_ref == 0);
f0102c9e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ca3:	74 24                	je     f0102cc9 <mem_init+0x1b5d>
f0102ca5:	c7 44 24 0c d6 5e 10 	movl   $0xf0105ed6,0xc(%esp)
f0102cac:	f0 
f0102cad:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102cb4:	f0 
f0102cb5:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f0102cbc:	00 
f0102cbd:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102cc4:	e8 e8 d3 ff ff       	call   f01000b1 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102cc9:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102cd0:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102cd3:	89 d8                	mov    %ebx,%eax
f0102cd5:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f0102cdb:	c1 f8 03             	sar    $0x3,%eax
f0102cde:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ce1:	89 c2                	mov    %eax,%edx
f0102ce3:	c1 ea 0c             	shr    $0xc,%edx
f0102ce6:	3b 15 48 3e 1e f0    	cmp    0xf01e3e48,%edx
f0102cec:	72 20                	jb     f0102d0e <mem_init+0x1ba2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cf2:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f0102cf9:	f0 
f0102cfa:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f0102d01:	00 
f0102d02:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f0102d09:	e8 a3 d3 ff ff       	call   f01000b1 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102d0e:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102d15:	03 03 03 
f0102d18:	74 24                	je     f0102d3e <mem_init+0x1bd2>
f0102d1a:	c7 44 24 0c d4 5b 10 	movl   $0xf0105bd4,0xc(%esp)
f0102d21:	f0 
f0102d22:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102d29:	f0 
f0102d2a:	c7 44 24 04 02 04 00 	movl   $0x402,0x4(%esp)
f0102d31:	00 
f0102d32:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102d39:	e8 73 d3 ff ff       	call   f01000b1 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102d3e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d45:	00 
f0102d46:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102d4b:	89 04 24             	mov    %eax,(%esp)
f0102d4e:	e8 56 e3 ff ff       	call   f01010a9 <page_remove>
	assert(pp2->pp_ref == 0);
f0102d53:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102d58:	74 24                	je     f0102d7e <mem_init+0x1c12>
f0102d5a:	c7 44 24 0c a4 5e 10 	movl   $0xf0105ea4,0xc(%esp)
f0102d61:	f0 
f0102d62:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102d69:	f0 
f0102d6a:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102d71:	00 
f0102d72:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102d79:	e8 33 d3 ff ff       	call   f01000b1 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102d7e:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
f0102d83:	8b 08                	mov    (%eax),%ecx
f0102d85:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102d8b:	89 f2                	mov    %esi,%edx
f0102d8d:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f0102d93:	c1 fa 03             	sar    $0x3,%edx
f0102d96:	c1 e2 0c             	shl    $0xc,%edx
f0102d99:	39 d1                	cmp    %edx,%ecx
f0102d9b:	74 24                	je     f0102dc1 <mem_init+0x1c55>
f0102d9d:	c7 44 24 0c e4 56 10 	movl   $0xf01056e4,0xc(%esp)
f0102da4:	f0 
f0102da5:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102dac:	f0 
f0102dad:	c7 44 24 04 07 04 00 	movl   $0x407,0x4(%esp)
f0102db4:	00 
f0102db5:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102dbc:	e8 f0 d2 ff ff       	call   f01000b1 <_panic>
	kern_pgdir[0] = 0;
f0102dc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102dc7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102dcc:	74 24                	je     f0102df2 <mem_init+0x1c86>
f0102dce:	c7 44 24 0c 5b 5e 10 	movl   $0xf0105e5b,0xc(%esp)
f0102dd5:	f0 
f0102dd6:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0102ddd:	f0 
f0102dde:	c7 44 24 04 09 04 00 	movl   $0x409,0x4(%esp)
f0102de5:	00 
f0102de6:	c7 04 24 61 5c 10 f0 	movl   $0xf0105c61,(%esp)
f0102ded:	e8 bf d2 ff ff       	call   f01000b1 <_panic>
	pp0->pp_ref = 0;
f0102df2:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102df8:	89 34 24             	mov    %esi,(%esp)
f0102dfb:	e8 be e0 ff ff       	call   f0100ebe <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102e00:	c7 04 24 00 5c 10 f0 	movl   $0xf0105c00,(%esp)
f0102e07:	e8 9a 08 00 00       	call   f01036a6 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102e0c:	83 c4 3c             	add    $0x3c,%esp
f0102e0f:	5b                   	pop    %ebx
f0102e10:	5e                   	pop    %esi
f0102e11:	5f                   	pop    %edi
f0102e12:	5d                   	pop    %ebp
f0102e13:	c3                   	ret    

f0102e14 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102e14:	55                   	push   %ebp
f0102e15:	89 e5                	mov    %esp,%ebp
f0102e17:	57                   	push   %edi
f0102e18:	56                   	push   %esi
f0102e19:	53                   	push   %ebx
f0102e1a:	83 ec 2c             	sub    $0x2c,%esp
f0102e1d:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e20:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// LAB 3: Your code here.
	uintptr_t upperBound = (uintptr_t)va + len;
f0102e23:	8b 45 10             	mov    0x10(%ebp),%eax
f0102e26:	01 d8                	add    %ebx,%eax
f0102e28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((uint32_t)va + len > ULIM) {
f0102e2b:	3d 00 00 80 ef       	cmp    $0xef800000,%eax
f0102e30:	76 5b                	jbe    f0102e8d <user_mem_check+0x79>
		user_mem_check_addr = (uintptr_t)va;
f0102e32:	89 1d a4 31 1e f0    	mov    %ebx,0xf01e31a4
		return -E_FAULT;
f0102e38:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e3d:	eb 5a                	jmp    f0102e99 <user_mem_check+0x85>
	}
	
	while ((uintptr_t)va < upperBound) {
		pte_t *pgEntry = pgdir_walk(env->env_pgdir, va, false);
f0102e3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102e46:	00 
f0102e47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102e4b:	8b 46 5c             	mov    0x5c(%esi),%eax
f0102e4e:	89 04 24             	mov    %eax,(%esp)
f0102e51:	e8 c8 e0 ff ff       	call   f0100f1e <pgdir_walk>
		if (!pgEntry) {
f0102e56:	85 c0                	test   %eax,%eax
f0102e58:	75 0d                	jne    f0102e67 <user_mem_check+0x53>
			user_mem_check_addr = (uintptr_t)va;
f0102e5a:	89 3d a4 31 1e f0    	mov    %edi,0xf01e31a4
			return -E_FAULT;
f0102e60:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e65:	eb 32                	jmp    f0102e99 <user_mem_check+0x85>
		}
		if (!(*pgEntry & perm) || !(*pgEntry & PTE_P)) {
f0102e67:	8b 00                	mov    (%eax),%eax
f0102e69:	85 45 14             	test   %eax,0x14(%ebp)
f0102e6c:	74 04                	je     f0102e72 <user_mem_check+0x5e>
f0102e6e:	a8 01                	test   $0x1,%al
f0102e70:	75 0d                	jne    f0102e7f <user_mem_check+0x6b>
			user_mem_check_addr = (uintptr_t)va;
f0102e72:	89 3d a4 31 1e f0    	mov    %edi,0xf01e31a4
			return -E_FAULT;
f0102e78:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102e7d:	eb 1a                	jmp    f0102e99 <user_mem_check+0x85>
		}
		va -= (uintptr_t)va % PGSIZE;
f0102e7f:	81 e7 ff 0f 00 00    	and    $0xfff,%edi
f0102e85:	29 fb                	sub    %edi,%ebx
		va += PGSIZE; 
f0102e87:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	if ((uint32_t)va + len > ULIM) {
		user_mem_check_addr = (uintptr_t)va;
		return -E_FAULT;
	}
	
	while ((uintptr_t)va < upperBound) {
f0102e8d:	89 df                	mov    %ebx,%edi
f0102e8f:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0102e92:	77 ab                	ja     f0102e3f <user_mem_check+0x2b>
			return -E_FAULT;
		}
		va -= (uintptr_t)va % PGSIZE;
		va += PGSIZE; 
	}
	return 0;
f0102e94:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102e99:	83 c4 2c             	add    $0x2c,%esp
f0102e9c:	5b                   	pop    %ebx
f0102e9d:	5e                   	pop    %esi
f0102e9e:	5f                   	pop    %edi
f0102e9f:	5d                   	pop    %ebp
f0102ea0:	c3                   	ret    

f0102ea1 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102ea1:	55                   	push   %ebp
f0102ea2:	89 e5                	mov    %esp,%ebp
f0102ea4:	53                   	push   %ebx
f0102ea5:	83 ec 14             	sub    $0x14,%esp
f0102ea8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102eab:	8b 45 14             	mov    0x14(%ebp),%eax
f0102eae:	83 c8 04             	or     $0x4,%eax
f0102eb1:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102eb5:	8b 45 10             	mov    0x10(%ebp),%eax
f0102eb8:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ec3:	89 1c 24             	mov    %ebx,(%esp)
f0102ec6:	e8 49 ff ff ff       	call   f0102e14 <user_mem_check>
f0102ecb:	85 c0                	test   %eax,%eax
f0102ecd:	79 24                	jns    f0102ef3 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102ecf:	a1 a4 31 1e f0       	mov    0xf01e31a4,%eax
f0102ed4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102ed8:	8b 43 48             	mov    0x48(%ebx),%eax
f0102edb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102edf:	c7 04 24 2c 5c 10 f0 	movl   $0xf0105c2c,(%esp)
f0102ee6:	e8 bb 07 00 00       	call   f01036a6 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102eeb:	89 1c 24             	mov    %ebx,(%esp)
f0102eee:	e8 9c 06 00 00       	call   f010358f <env_destroy>
	}
}
f0102ef3:	83 c4 14             	add    $0x14,%esp
f0102ef6:	5b                   	pop    %ebx
f0102ef7:	5d                   	pop    %ebp
f0102ef8:	c3                   	ret    
f0102ef9:	00 00                	add    %al,(%eax)
	...

f0102efc <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102efc:	55                   	push   %ebp
f0102efd:	89 e5                	mov    %esp,%ebp
f0102eff:	57                   	push   %edi
f0102f00:	56                   	push   %esi
f0102f01:	53                   	push   %ebx
f0102f02:	83 ec 1c             	sub    $0x1c,%esp
f0102f05:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *pp;
	uint32_t i;
	for (i = ROUNDDOWN((uint32_t)va, PGSIZE); i < ROUNDUP((uint32_t)va + len, PGSIZE); i+=PGSIZE) {
f0102f07:	89 d3                	mov    %edx,%ebx
f0102f09:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f0f:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0102f16:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0102f1c:	eb 6d                	jmp    f0102f8b <region_alloc+0x8f>
		pp = page_alloc(0);
f0102f1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102f25:	e8 10 df ff ff       	call   f0100e3a <page_alloc>
		if (!pp) {
f0102f2a:	85 c0                	test   %eax,%eax
f0102f2c:	75 1c                	jne    f0102f4a <region_alloc+0x4e>
			panic("Region alloc: Page allocation fail, not enough memory");
f0102f2e:	c7 44 24 08 60 5f 10 	movl   $0xf0105f60,0x8(%esp)
f0102f35:	f0 
f0102f36:	c7 44 24 04 22 01 00 	movl   $0x122,0x4(%esp)
f0102f3d:	00 
f0102f3e:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f0102f45:	e8 67 d1 ff ff       	call   f01000b1 <_panic>
		}
		if (page_insert(e->env_pgdir, pp, (void *)i, PTE_W|PTE_U) < 0) {
f0102f4a:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0102f51:	00 
f0102f52:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102f56:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102f5a:	8b 46 5c             	mov    0x5c(%esi),%eax
f0102f5d:	89 04 24             	mov    %eax,(%esp)
f0102f60:	e8 8d e1 ff ff       	call   f01010f2 <page_insert>
f0102f65:	85 c0                	test   %eax,%eax
f0102f67:	79 1c                	jns    f0102f85 <region_alloc+0x89>
			panic("Region alloc: Page insert fail, not enough memory");
f0102f69:	c7 44 24 08 98 5f 10 	movl   $0xf0105f98,0x8(%esp)
f0102f70:	f0 
f0102f71:	c7 44 24 04 25 01 00 	movl   $0x125,0x4(%esp)
f0102f78:	00 
f0102f79:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f0102f80:	e8 2c d1 ff ff       	call   f01000b1 <_panic>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	struct PageInfo *pp;
	uint32_t i;
	for (i = ROUNDDOWN((uint32_t)va, PGSIZE); i < ROUNDUP((uint32_t)va + len, PGSIZE); i+=PGSIZE) {
f0102f85:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102f8b:	39 fb                	cmp    %edi,%ebx
f0102f8d:	72 8f                	jb     f0102f1e <region_alloc+0x22>
		}
		if (page_insert(e->env_pgdir, pp, (void *)i, PTE_W|PTE_U) < 0) {
			panic("Region alloc: Page insert fail, not enough memory");
		}
	}
}
f0102f8f:	83 c4 1c             	add    $0x1c,%esp
f0102f92:	5b                   	pop    %ebx
f0102f93:	5e                   	pop    %esi
f0102f94:	5f                   	pop    %edi
f0102f95:	5d                   	pop    %ebp
f0102f96:	c3                   	ret    

f0102f97 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102f97:	55                   	push   %ebp
f0102f98:	89 e5                	mov    %esp,%ebp
f0102f9a:	53                   	push   %ebx
f0102f9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102fa1:	8a 5d 10             	mov    0x10(%ebp),%bl
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102fa4:	85 c0                	test   %eax,%eax
f0102fa6:	75 0e                	jne    f0102fb6 <envid2env+0x1f>
		*env_store = curenv;
f0102fa8:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0102fad:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102faf:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fb4:	eb 55                	jmp    f010300b <envid2env+0x74>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102fb6:	89 c2                	mov    %eax,%edx
f0102fb8:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0102fbe:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102fc1:	c1 e2 05             	shl    $0x5,%edx
f0102fc4:	03 15 ac 31 1e f0    	add    0xf01e31ac,%edx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102fca:	83 7a 54 00          	cmpl   $0x0,0x54(%edx)
f0102fce:	74 05                	je     f0102fd5 <envid2env+0x3e>
f0102fd0:	39 42 48             	cmp    %eax,0x48(%edx)
f0102fd3:	74 0d                	je     f0102fe2 <envid2env+0x4b>
		*env_store = 0;
f0102fd5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102fdb:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102fe0:	eb 29                	jmp    f010300b <envid2env+0x74>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102fe2:	84 db                	test   %bl,%bl
f0102fe4:	74 1e                	je     f0103004 <envid2env+0x6d>
f0102fe6:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0102feb:	39 c2                	cmp    %eax,%edx
f0102fed:	74 15                	je     f0103004 <envid2env+0x6d>
f0102fef:	8b 58 48             	mov    0x48(%eax),%ebx
f0102ff2:	39 5a 4c             	cmp    %ebx,0x4c(%edx)
f0102ff5:	74 0d                	je     f0103004 <envid2env+0x6d>
		*env_store = 0;
f0102ff7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
		return -E_BAD_ENV;
f0102ffd:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103002:	eb 07                	jmp    f010300b <envid2env+0x74>
	}

	*env_store = e;
f0103004:	89 11                	mov    %edx,(%ecx)
	return 0;
f0103006:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010300b:	5b                   	pop    %ebx
f010300c:	5d                   	pop    %ebp
f010300d:	c3                   	ret    

f010300e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f010300e:	55                   	push   %ebp
f010300f:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0103011:	b8 00 33 12 f0       	mov    $0xf0123300,%eax
f0103016:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0103019:	b8 23 00 00 00       	mov    $0x23,%eax
f010301e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0103020:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0103022:	b0 10                	mov    $0x10,%al
f0103024:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0103026:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0103028:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f010302a:	ea 31 30 10 f0 08 00 	ljmp   $0x8,$0xf0103031
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0103031:	b0 00                	mov    $0x0,%al
f0103033:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0103036:	5d                   	pop    %ebp
f0103037:	c3                   	ret    

f0103038 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0103038:	55                   	push   %ebp
f0103039:	89 e5                	mov    %esp,%ebp
f010303b:	56                   	push   %esi
f010303c:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f010303d:	8b 35 ac 31 1e f0    	mov    0xf01e31ac,%esi
f0103043:	8b 0d b0 31 1e f0    	mov    0xf01e31b0,%ecx
// Make sure the environments are in the free list in the same order
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
f0103049:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f010304f:	ba ff 03 00 00       	mov    $0x3ff,%edx
f0103054:	eb 02                	jmp    f0103058 <env_init+0x20>
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
f0103056:	89 d9                	mov    %ebx,%ecx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
		envs[i].env_id = 0;
f0103058:	89 c3                	mov    %eax,%ebx
f010305a:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0103061:	89 48 44             	mov    %ecx,0x44(%eax)
env_init(void)
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	for(i = NENV - 1; i >= 0; i--) {
f0103064:	4a                   	dec    %edx
f0103065:	83 e8 60             	sub    $0x60,%eax
f0103068:	83 fa ff             	cmp    $0xffffffff,%edx
f010306b:	75 e9                	jne    f0103056 <env_init+0x1e>
f010306d:	89 35 b0 31 1e f0    	mov    %esi,0xf01e31b0
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = &envs[i];
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0103073:	e8 96 ff ff ff       	call   f010300e <env_init_percpu>
}
f0103078:	5b                   	pop    %ebx
f0103079:	5e                   	pop    %esi
f010307a:	5d                   	pop    %ebp
f010307b:	c3                   	ret    

f010307c <env_alloc>:
//	-E_NO_FREE_ENV if all NENV environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f010307c:	55                   	push   %ebp
f010307d:	89 e5                	mov    %esp,%ebp
f010307f:	57                   	push   %edi
f0103080:	56                   	push   %esi
f0103081:	53                   	push   %ebx
f0103082:	83 ec 1c             	sub    $0x1c,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103085:	8b 1d b0 31 1e f0    	mov    0xf01e31b0,%ebx
f010308b:	85 db                	test   %ebx,%ebx
f010308d:	0f 84 7e 01 00 00    	je     f0103211 <env_alloc+0x195>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103093:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010309a:	e8 9b dd ff ff       	call   f0100e3a <page_alloc>
f010309f:	85 c0                	test   %eax,%eax
f01030a1:	0f 84 71 01 00 00    	je     f0103218 <env_alloc+0x19c>
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
f01030a7:	66 ff 40 04          	incw   0x4(%eax)
f01030ab:	89 c2                	mov    %eax,%edx
f01030ad:	2b 15 50 3e 1e f0    	sub    0xf01e3e50,%edx
f01030b3:	c1 fa 03             	sar    $0x3,%edx
f01030b6:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01030b9:	89 d1                	mov    %edx,%ecx
f01030bb:	c1 e9 0c             	shr    $0xc,%ecx
f01030be:	3b 0d 48 3e 1e f0    	cmp    0xf01e3e48,%ecx
f01030c4:	72 20                	jb     f01030e6 <env_alloc+0x6a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01030c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01030ca:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f01030d1:	f0 
f01030d2:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
f01030d9:	00 
f01030da:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f01030e1:	e8 cb cf ff ff       	call   f01000b1 <_panic>
	return (void *)(pa + KERNBASE);
f01030e6:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01030ec:	89 53 5c             	mov    %edx,0x5c(%ebx)
	e->env_pgdir = (pde_t *)page2kva(p);
f01030ef:	b9 00 00 00 00       	mov    $0x0,%ecx
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f01030f4:	ba 00 00 00 00       	mov    $0x0,%edx
		if (i < PDX(UTOP))
f01030f9:	81 fa ba 03 00 00    	cmp    $0x3ba,%edx
f01030ff:	77 0c                	ja     f010310d <env_alloc+0x91>
			e->env_pgdir[i] = 0;
f0103101:	8b 73 5c             	mov    0x5c(%ebx),%esi
f0103104:	c7 04 0e 00 00 00 00 	movl   $0x0,(%esi,%ecx,1)
f010310b:	eb 0f                	jmp    f010311c <env_alloc+0xa0>
		else {
			e->env_pgdir[i] = kern_pgdir[i];
f010310d:	8b 35 4c 3e 1e f0    	mov    0xf01e3e4c,%esi
f0103113:	8b 3c 0e             	mov    (%esi,%ecx,1),%edi
f0103116:	8b 73 5c             	mov    0x5c(%ebx),%esi
f0103119:	89 3c 0e             	mov    %edi,(%esi,%ecx,1)
	// LAB 3: Your code here.
	// Set e->env_pgdir
	p->pp_ref++;
	e->env_pgdir = (pde_t *)page2kva(p);
	// Initialize page directory
	for (i = 0; i < NPDENTRIES; i++) {
f010311c:	42                   	inc    %edx
f010311d:	83 c1 04             	add    $0x4,%ecx
f0103120:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0103126:	75 d1                	jne    f01030f9 <env_alloc+0x7d>
			e->env_pgdir[i] = kern_pgdir[i];
		}
	}
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = page2pa(p) | PTE_P | PTE_U;
f0103128:	8b 53 5c             	mov    0x5c(%ebx),%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010312b:	2b 05 50 3e 1e f0    	sub    0xf01e3e50,%eax
f0103131:	c1 f8 03             	sar    $0x3,%eax
f0103134:	c1 e0 0c             	shl    $0xc,%eax
f0103137:	83 c8 05             	or     $0x5,%eax
f010313a:	89 82 f4 0e 00 00    	mov    %eax,0xef4(%edx)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103140:	8b 43 48             	mov    0x48(%ebx),%eax
f0103143:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103148:	89 c1                	mov    %eax,%ecx
f010314a:	81 e1 00 fc ff ff    	and    $0xfffffc00,%ecx
f0103150:	7f 05                	jg     f0103157 <env_alloc+0xdb>
		generation = 1 << ENVGENSHIFT;
f0103152:	b9 00 10 00 00       	mov    $0x1000,%ecx
	e->env_id = generation | (e - envs);
f0103157:	89 d8                	mov    %ebx,%eax
f0103159:	2b 05 ac 31 1e f0    	sub    0xf01e31ac,%eax
f010315f:	c1 f8 05             	sar    $0x5,%eax
f0103162:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0103165:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0103168:	8d 14 90             	lea    (%eax,%edx,4),%edx
f010316b:	89 d6                	mov    %edx,%esi
f010316d:	c1 e6 08             	shl    $0x8,%esi
f0103170:	01 f2                	add    %esi,%edx
f0103172:	89 d6                	mov    %edx,%esi
f0103174:	c1 e6 10             	shl    $0x10,%esi
f0103177:	01 f2                	add    %esi,%edx
f0103179:	8d 04 50             	lea    (%eax,%edx,2),%eax
f010317c:	09 c1                	or     %eax,%ecx
f010317e:	89 4b 48             	mov    %ecx,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103181:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103184:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103187:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f010318e:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103195:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f010319c:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f01031a3:	00 
f01031a4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01031ab:	00 
f01031ac:	89 1c 24             	mov    %ebx,(%esp)
f01031af:	e8 1a 19 00 00       	call   f0104ace <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01031b4:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01031ba:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01031c0:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01031c6:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01031cd:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f01031d3:	8b 43 44             	mov    0x44(%ebx),%eax
f01031d6:	a3 b0 31 1e f0       	mov    %eax,0xf01e31b0
	*newenv_store = e;
f01031db:	8b 45 08             	mov    0x8(%ebp),%eax
f01031de:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01031e0:	8b 53 48             	mov    0x48(%ebx),%edx
f01031e3:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f01031e8:	85 c0                	test   %eax,%eax
f01031ea:	74 05                	je     f01031f1 <env_alloc+0x175>
f01031ec:	8b 40 48             	mov    0x48(%eax),%eax
f01031ef:	eb 05                	jmp    f01031f6 <env_alloc+0x17a>
f01031f1:	b8 00 00 00 00       	mov    $0x0,%eax
f01031f6:	89 54 24 08          	mov    %edx,0x8(%esp)
f01031fa:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031fe:	c7 04 24 65 60 10 f0 	movl   $0xf0106065,(%esp)
f0103205:	e8 9c 04 00 00       	call   f01036a6 <cprintf>
	return 0;
f010320a:	b8 00 00 00 00       	mov    $0x0,%eax
f010320f:	eb 0c                	jmp    f010321d <env_alloc+0x1a1>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0103211:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0103216:	eb 05                	jmp    f010321d <env_alloc+0x1a1>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0103218:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f010321d:	83 c4 1c             	add    $0x1c,%esp
f0103220:	5b                   	pop    %ebx
f0103221:	5e                   	pop    %esi
f0103222:	5f                   	pop    %edi
f0103223:	5d                   	pop    %ebp
f0103224:	c3                   	ret    

f0103225 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0103225:	55                   	push   %ebp
f0103226:	89 e5                	mov    %esp,%ebp
f0103228:	57                   	push   %edi
f0103229:	56                   	push   %esi
f010322a:	53                   	push   %ebx
f010322b:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	struct Env *newenv;
	int e = env_alloc(&newenv, 0);
f010322e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103235:	00 
f0103236:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103239:	89 04 24             	mov    %eax,(%esp)
f010323c:	e8 3b fe ff ff       	call   f010307c <env_alloc>
	if (e < 0) {
f0103241:	85 c0                	test   %eax,%eax
f0103243:	79 20                	jns    f0103265 <env_create+0x40>
		panic("Env create: %e", e);
f0103245:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103249:	c7 44 24 08 7a 60 10 	movl   $0xf010607a,0x8(%esp)
f0103250:	f0 
f0103251:	c7 44 24 04 96 01 00 	movl   $0x196,0x4(%esp)
f0103258:	00 
f0103259:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f0103260:	e8 4c ce ff ff       	call   f01000b1 <_panic>
	}
	load_icode(newenv, binary);
f0103265:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103268:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Elf *elf = (struct Elf *)binary;
	struct PageInfo *pp;
	struct Proghdr *proghdr;
	int i;
	// Verify whether it is an ELF file
	if (elf->e_magic != ELF_MAGIC) {
f010326b:	8b 55 08             	mov    0x8(%ebp),%edx
f010326e:	81 3a 7f 45 4c 46    	cmpl   $0x464c457f,(%edx)
f0103274:	74 1c                	je     f0103292 <env_create+0x6d>
		panic("Load icode: Not a valid ELF file format");
f0103276:	c7 44 24 08 cc 5f 10 	movl   $0xf0105fcc,0x8(%esp)
f010327d:	f0 
f010327e:	c7 44 24 04 66 01 00 	movl   $0x166,0x4(%esp)
f0103285:	00 
f0103286:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f010328d:	e8 1f ce ff ff       	call   f01000b1 <_panic>
	}
	// Set entry point
	e->env_tf.tf_eip = elf->e_entry;
f0103292:	8b 55 08             	mov    0x8(%ebp),%edx
f0103295:	8b 42 18             	mov    0x18(%edx),%eax
f0103298:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f010329b:	89 42 30             	mov    %eax,0x30(%edx)
	// Switch to environment
	lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
f010329e:	8b 42 5c             	mov    0x5c(%edx),%eax
f01032a1:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f01032a7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01032ac:	0f 22 d8             	mov    %eax,%cr3
	// If valid, go to the program headers
	proghdr = (struct Proghdr *)((uint8_t *) binary + elf->e_phoff);
f01032af:	8b 75 08             	mov    0x8(%ebp),%esi
f01032b2:	03 76 1c             	add    0x1c(%esi),%esi
	for (i = 0; i < elf->e_phnum; i++) {
f01032b5:	bf 00 00 00 00       	mov    $0x0,%edi
f01032ba:	eb 6e                	jmp    f010332a <env_create+0x105>
		// Check if the segments is loadable
		if (proghdr[i].p_type == ELF_PROG_LOAD) {
f01032bc:	83 3e 01             	cmpl   $0x1,(%esi)
f01032bf:	75 65                	jne    f0103326 <env_create+0x101>
			// Check if memory size is greater than or equal to file size
			if (proghdr[i].p_filesz > proghdr[i].p_memsz) {
f01032c1:	8b 4e 14             	mov    0x14(%esi),%ecx
f01032c4:	39 4e 10             	cmp    %ecx,0x10(%esi)
f01032c7:	76 1c                	jbe    f01032e5 <env_create+0xc0>
				panic("Load icode: File size greater than memory size");
f01032c9:	c7 44 24 08 f4 5f 10 	movl   $0xf0105ff4,0x8(%esp)
f01032d0:	f0 
f01032d1:	c7 44 24 04 73 01 00 	movl   $0x173,0x4(%esp)
f01032d8:	00 
f01032d9:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f01032e0:	e8 cc cd ff ff       	call   f01000b1 <_panic>
			}
			// Allocate page table entries for program to be copied
			region_alloc(e, (void *)proghdr[i].p_va, proghdr[i].p_memsz);
f01032e5:	8b 56 08             	mov    0x8(%esi),%edx
f01032e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01032eb:	e8 0c fc ff ff       	call   f0102efc <region_alloc>
			// Copy file 
			memset((void *)proghdr[i].p_va, 0, proghdr[i].p_memsz);
f01032f0:	8b 46 14             	mov    0x14(%esi),%eax
f01032f3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01032f7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01032fe:	00 
f01032ff:	8b 46 08             	mov    0x8(%esi),%eax
f0103302:	89 04 24             	mov    %eax,(%esp)
f0103305:	e8 c4 17 00 00       	call   f0104ace <memset>
			memmove((void *)proghdr[i].p_va, (void *)(binary + proghdr[i].p_offset), proghdr[i].p_filesz);
f010330a:	8b 46 10             	mov    0x10(%esi),%eax
f010330d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103311:	8b 45 08             	mov    0x8(%ebp),%eax
f0103314:	03 46 04             	add    0x4(%esi),%eax
f0103317:	89 44 24 04          	mov    %eax,0x4(%esp)
f010331b:	8b 46 08             	mov    0x8(%esi),%eax
f010331e:	89 04 24             	mov    %eax,(%esp)
f0103321:	e8 f2 17 00 00       	call   f0104b18 <memmove>
	e->env_tf.tf_eip = elf->e_entry;
	// Switch to environment
	lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
	// If valid, go to the program headers
	proghdr = (struct Proghdr *)((uint8_t *) binary + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++) {
f0103326:	47                   	inc    %edi
f0103327:	83 c6 20             	add    $0x20,%esi
f010332a:	8b 55 08             	mov    0x8(%ebp),%edx
f010332d:	0f b7 42 2c          	movzwl 0x2c(%edx),%eax
f0103331:	39 c7                	cmp    %eax,%edi
f0103333:	7c 87                	jl     f01032bc <env_create+0x97>

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *)(USTACKTOP - PGSIZE), PGSIZE);
f0103335:	b9 00 10 00 00       	mov    $0x1000,%ecx
f010333a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f010333f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103342:	e8 b5 fb ff ff       	call   f0102efc <region_alloc>
	memset((void *)(USTACKTOP - PGSIZE), 0, PGSIZE);
f0103347:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010334e:	00 
f010334f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103356:	00 
f0103357:	c7 04 24 00 d0 bf ee 	movl   $0xeebfd000,(%esp)
f010335e:	e8 6b 17 00 00       	call   f0104ace <memset>

	// switch back to kern_pgdir to be on the safe side
	lcr3(PADDR(kern_pgdir));
f0103363:	a1 4c 3e 1e f0       	mov    0xf01e3e4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103368:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010336d:	77 20                	ja     f010338f <env_create+0x16a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010336f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103373:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f010337a:	f0 
f010337b:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
f0103382:	00 
f0103383:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f010338a:	e8 22 cd ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010338f:	05 00 00 00 10       	add    $0x10000000,%eax
f0103394:	0f 22 d8             	mov    %eax,%cr3
	int e = env_alloc(&newenv, 0);
	if (e < 0) {
		panic("Env create: %e", e);
	}
	load_icode(newenv, binary);
	newenv->env_type = type;
f0103397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010339a:	8b 55 0c             	mov    0xc(%ebp),%edx
f010339d:	89 50 50             	mov    %edx,0x50(%eax)
}
f01033a0:	83 c4 3c             	add    $0x3c,%esp
f01033a3:	5b                   	pop    %ebx
f01033a4:	5e                   	pop    %esi
f01033a5:	5f                   	pop    %edi
f01033a6:	5d                   	pop    %ebp
f01033a7:	c3                   	ret    

f01033a8 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033a8:	55                   	push   %ebp
f01033a9:	89 e5                	mov    %esp,%ebp
f01033ab:	57                   	push   %edi
f01033ac:	56                   	push   %esi
f01033ad:	53                   	push   %ebx
f01033ae:	83 ec 2c             	sub    $0x2c,%esp
f01033b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033b4:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f01033b9:	39 c7                	cmp    %eax,%edi
f01033bb:	75 37                	jne    f01033f4 <env_free+0x4c>
		lcr3(PADDR(kern_pgdir));
f01033bd:	8b 15 4c 3e 1e f0    	mov    0xf01e3e4c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033c3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01033c9:	77 20                	ja     f01033eb <env_free+0x43>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01033cf:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f01033d6:	f0 
f01033d7:	c7 44 24 04 aa 01 00 	movl   $0x1aa,0x4(%esp)
f01033de:	00 
f01033df:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f01033e6:	e8 c6 cc ff ff       	call   f01000b1 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01033eb:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01033f1:	0f 22 da             	mov    %edx,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f01033f4:	8b 57 48             	mov    0x48(%edi),%edx
f01033f7:	85 c0                	test   %eax,%eax
f01033f9:	74 05                	je     f0103400 <env_free+0x58>
f01033fb:	8b 40 48             	mov    0x48(%eax),%eax
f01033fe:	eb 05                	jmp    f0103405 <env_free+0x5d>
f0103400:	b8 00 00 00 00       	mov    $0x0,%eax
f0103405:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103409:	89 44 24 04          	mov    %eax,0x4(%esp)
f010340d:	c7 04 24 89 60 10 f0 	movl   $0xf0106089,(%esp)
f0103414:	e8 8d 02 00 00       	call   f01036a6 <cprintf>

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103419:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103420:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103423:	c1 e0 02             	shl    $0x2,%eax
f0103426:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103429:	8b 47 5c             	mov    0x5c(%edi),%eax
f010342c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f010342f:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103432:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103438:	0f 84 b6 00 00 00    	je     f01034f4 <env_free+0x14c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010343e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103444:	89 f0                	mov    %esi,%eax
f0103446:	c1 e8 0c             	shr    $0xc,%eax
f0103449:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010344c:	3b 05 48 3e 1e f0    	cmp    0xf01e3e48,%eax
f0103452:	72 20                	jb     f0103474 <env_free+0xcc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103454:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103458:	c7 44 24 08 44 54 10 	movl   $0xf0105444,0x8(%esp)
f010345f:	f0 
f0103460:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
f0103467:	00 
f0103468:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f010346f:	e8 3d cc ff ff       	call   f01000b1 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103474:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103477:	c1 e2 16             	shl    $0x16,%edx
f010347a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010347d:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103482:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0103489:	01 
f010348a:	74 17                	je     f01034a3 <env_free+0xfb>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010348c:	89 d8                	mov    %ebx,%eax
f010348e:	c1 e0 0c             	shl    $0xc,%eax
f0103491:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103494:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103498:	8b 47 5c             	mov    0x5c(%edi),%eax
f010349b:	89 04 24             	mov    %eax,(%esp)
f010349e:	e8 06 dc ff ff       	call   f01010a9 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034a3:	43                   	inc    %ebx
f01034a4:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034aa:	75 d6                	jne    f0103482 <env_free+0xda>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034ac:	8b 47 5c             	mov    0x5c(%edi),%eax
f01034af:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034b2:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01034b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034bc:	3b 05 48 3e 1e f0    	cmp    0xf01e3e48,%eax
f01034c2:	72 1c                	jb     f01034e0 <env_free+0x138>
		panic("pa2page called with invalid pa");
f01034c4:	c7 44 24 08 b0 55 10 	movl   $0xf01055b0,0x8(%esp)
f01034cb:	f0 
f01034cc:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f01034d3:	00 
f01034d4:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f01034db:	e8 d1 cb ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f01034e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01034e3:	c1 e0 03             	shl    $0x3,%eax
f01034e6:	03 05 50 3e 1e f0    	add    0xf01e3e50,%eax
		page_decref(pa2page(pa));
f01034ec:	89 04 24             	mov    %eax,(%esp)
f01034ef:	e8 0a da ff ff       	call   f0100efe <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034f4:	ff 45 e0             	incl   -0x20(%ebp)
f01034f7:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f01034fe:	0f 85 1c ff ff ff    	jne    f0103420 <env_free+0x78>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103504:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103507:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010350c:	77 20                	ja     f010352e <env_free+0x186>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010350e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103512:	c7 44 24 08 68 54 10 	movl   $0xf0105468,0x8(%esp)
f0103519:	f0 
f010351a:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
f0103521:	00 
f0103522:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f0103529:	e8 83 cb ff ff       	call   f01000b1 <_panic>
	e->env_pgdir = 0;
f010352e:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103535:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010353a:	c1 e8 0c             	shr    $0xc,%eax
f010353d:	3b 05 48 3e 1e f0    	cmp    0xf01e3e48,%eax
f0103543:	72 1c                	jb     f0103561 <env_free+0x1b9>
		panic("pa2page called with invalid pa");
f0103545:	c7 44 24 08 b0 55 10 	movl   $0xf01055b0,0x8(%esp)
f010354c:	f0 
f010354d:	c7 44 24 04 4f 00 00 	movl   $0x4f,0x4(%esp)
f0103554:	00 
f0103555:	c7 04 24 88 5c 10 f0 	movl   $0xf0105c88,(%esp)
f010355c:	e8 50 cb ff ff       	call   f01000b1 <_panic>
	return &pages[PGNUM(pa)];
f0103561:	c1 e0 03             	shl    $0x3,%eax
f0103564:	03 05 50 3e 1e f0    	add    0xf01e3e50,%eax
	page_decref(pa2page(pa));
f010356a:	89 04 24             	mov    %eax,(%esp)
f010356d:	e8 8c d9 ff ff       	call   f0100efe <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103572:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103579:	a1 b0 31 1e f0       	mov    0xf01e31b0,%eax
f010357e:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103581:	89 3d b0 31 1e f0    	mov    %edi,0xf01e31b0
}
f0103587:	83 c4 2c             	add    $0x2c,%esp
f010358a:	5b                   	pop    %ebx
f010358b:	5e                   	pop    %esi
f010358c:	5f                   	pop    %edi
f010358d:	5d                   	pop    %ebp
f010358e:	c3                   	ret    

f010358f <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f010358f:	55                   	push   %ebp
f0103590:	89 e5                	mov    %esp,%ebp
f0103592:	83 ec 18             	sub    $0x18,%esp
	env_free(e);
f0103595:	8b 45 08             	mov    0x8(%ebp),%eax
f0103598:	89 04 24             	mov    %eax,(%esp)
f010359b:	e8 08 fe ff ff       	call   f01033a8 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f01035a0:	c7 04 24 24 60 10 f0 	movl   $0xf0106024,(%esp)
f01035a7:	e8 fa 00 00 00       	call   f01036a6 <cprintf>
	while (1)
		monitor(NULL);
f01035ac:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035b3:	e8 19 d2 ff ff       	call   f01007d1 <monitor>
f01035b8:	eb f2                	jmp    f01035ac <env_destroy+0x1d>

f01035ba <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f01035ba:	55                   	push   %ebp
f01035bb:	89 e5                	mov    %esp,%ebp
f01035bd:	83 ec 18             	sub    $0x18,%esp
	asm volatile(
f01035c0:	8b 65 08             	mov    0x8(%ebp),%esp
f01035c3:	61                   	popa   
f01035c4:	07                   	pop    %es
f01035c5:	1f                   	pop    %ds
f01035c6:	83 c4 08             	add    $0x8,%esp
f01035c9:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01035ca:	c7 44 24 08 9f 60 10 	movl   $0xf010609f,0x8(%esp)
f01035d1:	f0 
f01035d2:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
f01035d9:	00 
f01035da:	c7 04 24 5a 60 10 f0 	movl   $0xf010605a,(%esp)
f01035e1:	e8 cb ca ff ff       	call   f01000b1 <_panic>

f01035e6 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01035e6:	55                   	push   %ebp
f01035e7:	89 e5                	mov    %esp,%ebp
f01035e9:	83 ec 18             	sub    $0x18,%esp
f01035ec:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (e != curenv) {
f01035ef:	8b 15 a8 31 1e f0    	mov    0xf01e31a8,%edx
f01035f5:	39 d0                	cmp    %edx,%eax
f01035f7:	74 31                	je     f010362a <env_run+0x44>
		// Step 1-1:
		if (curenv) {
f01035f9:	85 d2                	test   %edx,%edx
f01035fb:	74 0d                	je     f010360a <env_run+0x24>
			if (curenv->env_status == ENV_RUNNING)
f01035fd:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0103601:	75 07                	jne    f010360a <env_run+0x24>
				curenv->env_status = ENV_RUNNABLE;
f0103603:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
		}
		// Step 1-2:
		curenv = e;
f010360a:	a3 a8 31 1e f0       	mov    %eax,0xf01e31a8
		// Step 1-3:
		curenv->env_status = ENV_RUNNING;
f010360f:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
		// Step 1-4:
		curenv->env_runs++;
f0103616:	ff 40 58             	incl   0x58(%eax)
		// Step 1-5:
		lcr3(PTE_ADDR(e->env_pgdir[PDX(UVPT)]));
f0103619:	8b 40 5c             	mov    0x5c(%eax),%eax
f010361c:	8b 80 f4 0e 00 00    	mov    0xef4(%eax),%eax
f0103622:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0103627:	0f 22 d8             	mov    %eax,%cr3
	}
	// Step 2:
	env_pop_tf(&(curenv->env_tf));
f010362a:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f010362f:	89 04 24             	mov    %eax,(%esp)
f0103632:	e8 83 ff ff ff       	call   f01035ba <env_pop_tf>
	...

f0103638 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103638:	55                   	push   %ebp
f0103639:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010363b:	ba 70 00 00 00       	mov    $0x70,%edx
f0103640:	8b 45 08             	mov    0x8(%ebp),%eax
f0103643:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103644:	b2 71                	mov    $0x71,%dl
f0103646:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103647:	0f b6 c0             	movzbl %al,%eax
}
f010364a:	5d                   	pop    %ebp
f010364b:	c3                   	ret    

f010364c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010364c:	55                   	push   %ebp
f010364d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010364f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103654:	8b 45 08             	mov    0x8(%ebp),%eax
f0103657:	ee                   	out    %al,(%dx)
f0103658:	b2 71                	mov    $0x71,%dl
f010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010365d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010365e:	5d                   	pop    %ebp
f010365f:	c3                   	ret    

f0103660 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103660:	55                   	push   %ebp
f0103661:	89 e5                	mov    %esp,%ebp
f0103663:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103666:	8b 45 08             	mov    0x8(%ebp),%eax
f0103669:	89 04 24             	mov    %eax,(%esp)
f010366c:	e8 67 cf ff ff       	call   f01005d8 <cputchar>
	*cnt++;
}
f0103671:	c9                   	leave  
f0103672:	c3                   	ret    

f0103673 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103673:	55                   	push   %ebp
f0103674:	89 e5                	mov    %esp,%ebp
f0103676:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103679:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103680:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103683:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103687:	8b 45 08             	mov    0x8(%ebp),%eax
f010368a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010368e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103691:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103695:	c7 04 24 60 36 10 f0 	movl   $0xf0103660,(%esp)
f010369c:	e8 ed 0d 00 00       	call   f010448e <vprintfmt>
	return cnt;
}
f01036a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01036a4:	c9                   	leave  
f01036a5:	c3                   	ret    

f01036a6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01036a6:	55                   	push   %ebp
f01036a7:	89 e5                	mov    %esp,%ebp
f01036a9:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01036ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01036af:	89 44 24 04          	mov    %eax,0x4(%esp)
f01036b3:	8b 45 08             	mov    0x8(%ebp),%eax
f01036b6:	89 04 24             	mov    %eax,(%esp)
f01036b9:	e8 b5 ff ff ff       	call   f0103673 <vcprintf>
	va_end(ap);

	return cnt;
}
f01036be:	c9                   	leave  
f01036bf:	c3                   	ret    

f01036c0 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f01036c0:	55                   	push   %ebp
f01036c1:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f01036c3:	c7 05 c4 39 1e f0 00 	movl   $0xf0000000,0xf01e39c4
f01036ca:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f01036cd:	66 c7 05 c8 39 1e f0 	movw   $0x10,0xf01e39c8
f01036d4:	10 00 
	ts.ts_iomb = sizeof(struct Taskstate);
f01036d6:	66 c7 05 26 3a 1e f0 	movw   $0x68,0xf01e3a26
f01036dd:	68 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f01036df:	66 c7 05 48 33 12 f0 	movw   $0x67,0xf0123348
f01036e6:	67 00 
f01036e8:	b8 c0 39 1e f0       	mov    $0xf01e39c0,%eax
f01036ed:	66 a3 4a 33 12 f0    	mov    %ax,0xf012334a
f01036f3:	89 c2                	mov    %eax,%edx
f01036f5:	c1 ea 10             	shr    $0x10,%edx
f01036f8:	88 15 4c 33 12 f0    	mov    %dl,0xf012334c
f01036fe:	c6 05 4e 33 12 f0 40 	movb   $0x40,0xf012334e
f0103705:	c1 e8 18             	shr    $0x18,%eax
f0103708:	a2 4f 33 12 f0       	mov    %al,0xf012334f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010370d:	c6 05 4d 33 12 f0 89 	movb   $0x89,0xf012334d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103714:	b8 28 00 00 00       	mov    $0x28,%eax
f0103719:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010371c:	b8 50 33 12 f0       	mov    $0xf0123350,%eax
f0103721:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103724:	5d                   	pop    %ebp
f0103725:	c3                   	ret    

f0103726 <trap_init>:
}


void
trap_init(void)
{
f0103726:	55                   	push   %ebp
f0103727:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[0], 0, GD_KT, T_DIVIDE_handler, 0);			// divide error
f0103729:	b8 34 3e 10 f0       	mov    $0xf0103e34,%eax
f010372e:	66 a3 c0 31 1e f0    	mov    %ax,0xf01e31c0
f0103734:	66 c7 05 c2 31 1e f0 	movw   $0x8,0xf01e31c2
f010373b:	08 00 
f010373d:	c6 05 c4 31 1e f0 00 	movb   $0x0,0xf01e31c4
f0103744:	c6 05 c5 31 1e f0 8e 	movb   $0x8e,0xf01e31c5
f010374b:	c1 e8 10             	shr    $0x10,%eax
f010374e:	66 a3 c6 31 1e f0    	mov    %ax,0xf01e31c6
	SETGATE(idt[1], 0, GD_KT, T_DEBUG_handler, 0);			// debug exception
f0103754:	b8 3e 3e 10 f0       	mov    $0xf0103e3e,%eax
f0103759:	66 a3 c8 31 1e f0    	mov    %ax,0xf01e31c8
f010375f:	66 c7 05 ca 31 1e f0 	movw   $0x8,0xf01e31ca
f0103766:	08 00 
f0103768:	c6 05 cc 31 1e f0 00 	movb   $0x0,0xf01e31cc
f010376f:	c6 05 cd 31 1e f0 8e 	movb   $0x8e,0xf01e31cd
f0103776:	c1 e8 10             	shr    $0x10,%eax
f0103779:	66 a3 ce 31 1e f0    	mov    %ax,0xf01e31ce
	SETGATE(idt[2], 0, GD_KT, T_NMI_handler, 0);			// non-maskable interrupt
f010377f:	b8 48 3e 10 f0       	mov    $0xf0103e48,%eax
f0103784:	66 a3 d0 31 1e f0    	mov    %ax,0xf01e31d0
f010378a:	66 c7 05 d2 31 1e f0 	movw   $0x8,0xf01e31d2
f0103791:	08 00 
f0103793:	c6 05 d4 31 1e f0 00 	movb   $0x0,0xf01e31d4
f010379a:	c6 05 d5 31 1e f0 8e 	movb   $0x8e,0xf01e31d5
f01037a1:	c1 e8 10             	shr    $0x10,%eax
f01037a4:	66 a3 d6 31 1e f0    	mov    %ax,0xf01e31d6
	SETGATE(idt[3], 0, GD_KT, T_BRKPT_handler, 3);			// breakpoint
f01037aa:	b8 52 3e 10 f0       	mov    $0xf0103e52,%eax
f01037af:	66 a3 d8 31 1e f0    	mov    %ax,0xf01e31d8
f01037b5:	66 c7 05 da 31 1e f0 	movw   $0x8,0xf01e31da
f01037bc:	08 00 
f01037be:	c6 05 dc 31 1e f0 00 	movb   $0x0,0xf01e31dc
f01037c5:	c6 05 dd 31 1e f0 ee 	movb   $0xee,0xf01e31dd
f01037cc:	c1 e8 10             	shr    $0x10,%eax
f01037cf:	66 a3 de 31 1e f0    	mov    %ax,0xf01e31de
	SETGATE(idt[4], 0, GD_KT, T_OFLOW_handler, 0);			// overflow
f01037d5:	b8 5c 3e 10 f0       	mov    $0xf0103e5c,%eax
f01037da:	66 a3 e0 31 1e f0    	mov    %ax,0xf01e31e0
f01037e0:	66 c7 05 e2 31 1e f0 	movw   $0x8,0xf01e31e2
f01037e7:	08 00 
f01037e9:	c6 05 e4 31 1e f0 00 	movb   $0x0,0xf01e31e4
f01037f0:	c6 05 e5 31 1e f0 8e 	movb   $0x8e,0xf01e31e5
f01037f7:	c1 e8 10             	shr    $0x10,%eax
f01037fa:	66 a3 e6 31 1e f0    	mov    %ax,0xf01e31e6
	SETGATE(idt[5], 0, GD_KT, T_BOUND_handler, 0);			// bounds check
f0103800:	b8 66 3e 10 f0       	mov    $0xf0103e66,%eax
f0103805:	66 a3 e8 31 1e f0    	mov    %ax,0xf01e31e8
f010380b:	66 c7 05 ea 31 1e f0 	movw   $0x8,0xf01e31ea
f0103812:	08 00 
f0103814:	c6 05 ec 31 1e f0 00 	movb   $0x0,0xf01e31ec
f010381b:	c6 05 ed 31 1e f0 8e 	movb   $0x8e,0xf01e31ed
f0103822:	c1 e8 10             	shr    $0x10,%eax
f0103825:	66 a3 ee 31 1e f0    	mov    %ax,0xf01e31ee
	SETGATE(idt[6], 0, GD_KT, T_ILLOP_handler, 0);			// illegal opcode
f010382b:	b8 70 3e 10 f0       	mov    $0xf0103e70,%eax
f0103830:	66 a3 f0 31 1e f0    	mov    %ax,0xf01e31f0
f0103836:	66 c7 05 f2 31 1e f0 	movw   $0x8,0xf01e31f2
f010383d:	08 00 
f010383f:	c6 05 f4 31 1e f0 00 	movb   $0x0,0xf01e31f4
f0103846:	c6 05 f5 31 1e f0 8e 	movb   $0x8e,0xf01e31f5
f010384d:	c1 e8 10             	shr    $0x10,%eax
f0103850:	66 a3 f6 31 1e f0    	mov    %ax,0xf01e31f6
	SETGATE(idt[7], 0, GD_KT, T_DEVICE_handler, 0);			// device not available
f0103856:	b8 7a 3e 10 f0       	mov    $0xf0103e7a,%eax
f010385b:	66 a3 f8 31 1e f0    	mov    %ax,0xf01e31f8
f0103861:	66 c7 05 fa 31 1e f0 	movw   $0x8,0xf01e31fa
f0103868:	08 00 
f010386a:	c6 05 fc 31 1e f0 00 	movb   $0x0,0xf01e31fc
f0103871:	c6 05 fd 31 1e f0 8e 	movb   $0x8e,0xf01e31fd
f0103878:	c1 e8 10             	shr    $0x10,%eax
f010387b:	66 a3 fe 31 1e f0    	mov    %ax,0xf01e31fe
	SETGATE(idt[8], 0, GD_KT, T_DBLFLT_handler, 0);			// double fault
f0103881:	b8 84 3e 10 f0       	mov    $0xf0103e84,%eax
f0103886:	66 a3 00 32 1e f0    	mov    %ax,0xf01e3200
f010388c:	66 c7 05 02 32 1e f0 	movw   $0x8,0xf01e3202
f0103893:	08 00 
f0103895:	c6 05 04 32 1e f0 00 	movb   $0x0,0xf01e3204
f010389c:	c6 05 05 32 1e f0 8e 	movb   $0x8e,0xf01e3205
f01038a3:	c1 e8 10             	shr    $0x10,%eax
f01038a6:	66 a3 06 32 1e f0    	mov    %ax,0xf01e3206

	SETGATE(idt[10], 0, GD_KT, T_TSS_handler, 0);			// invalid task switch segment
f01038ac:	b8 8e 3e 10 f0       	mov    $0xf0103e8e,%eax
f01038b1:	66 a3 10 32 1e f0    	mov    %ax,0xf01e3210
f01038b7:	66 c7 05 12 32 1e f0 	movw   $0x8,0xf01e3212
f01038be:	08 00 
f01038c0:	c6 05 14 32 1e f0 00 	movb   $0x0,0xf01e3214
f01038c7:	c6 05 15 32 1e f0 8e 	movb   $0x8e,0xf01e3215
f01038ce:	c1 e8 10             	shr    $0x10,%eax
f01038d1:	66 a3 16 32 1e f0    	mov    %ax,0xf01e3216
	SETGATE(idt[11], 0, GD_KT, T_SEGNP_handler, 0);			// segment not present
f01038d7:	b8 98 3e 10 f0       	mov    $0xf0103e98,%eax
f01038dc:	66 a3 18 32 1e f0    	mov    %ax,0xf01e3218
f01038e2:	66 c7 05 1a 32 1e f0 	movw   $0x8,0xf01e321a
f01038e9:	08 00 
f01038eb:	c6 05 1c 32 1e f0 00 	movb   $0x0,0xf01e321c
f01038f2:	c6 05 1d 32 1e f0 8e 	movb   $0x8e,0xf01e321d
f01038f9:	c1 e8 10             	shr    $0x10,%eax
f01038fc:	66 a3 1e 32 1e f0    	mov    %ax,0xf01e321e
	SETGATE(idt[12], 0, GD_KT, T_STACK_handler, 0);			// stack exception
f0103902:	b8 a2 3e 10 f0       	mov    $0xf0103ea2,%eax
f0103907:	66 a3 20 32 1e f0    	mov    %ax,0xf01e3220
f010390d:	66 c7 05 22 32 1e f0 	movw   $0x8,0xf01e3222
f0103914:	08 00 
f0103916:	c6 05 24 32 1e f0 00 	movb   $0x0,0xf01e3224
f010391d:	c6 05 25 32 1e f0 8e 	movb   $0x8e,0xf01e3225
f0103924:	c1 e8 10             	shr    $0x10,%eax
f0103927:	66 a3 26 32 1e f0    	mov    %ax,0xf01e3226
	SETGATE(idt[13], 0, GD_KT, T_GPFLT_handler, 0);			// general protection fault
f010392d:	b8 ac 3e 10 f0       	mov    $0xf0103eac,%eax
f0103932:	66 a3 28 32 1e f0    	mov    %ax,0xf01e3228
f0103938:	66 c7 05 2a 32 1e f0 	movw   $0x8,0xf01e322a
f010393f:	08 00 
f0103941:	c6 05 2c 32 1e f0 00 	movb   $0x0,0xf01e322c
f0103948:	c6 05 2d 32 1e f0 8e 	movb   $0x8e,0xf01e322d
f010394f:	c1 e8 10             	shr    $0x10,%eax
f0103952:	66 a3 2e 32 1e f0    	mov    %ax,0xf01e322e
	SETGATE(idt[14], 0, GD_KT, T_PGFLT_handler, 0);			// page fault
f0103958:	b8 b4 3e 10 f0       	mov    $0xf0103eb4,%eax
f010395d:	66 a3 30 32 1e f0    	mov    %ax,0xf01e3230
f0103963:	66 c7 05 32 32 1e f0 	movw   $0x8,0xf01e3232
f010396a:	08 00 
f010396c:	c6 05 34 32 1e f0 00 	movb   $0x0,0xf01e3234
f0103973:	c6 05 35 32 1e f0 8e 	movb   $0x8e,0xf01e3235
f010397a:	c1 e8 10             	shr    $0x10,%eax
f010397d:	66 a3 36 32 1e f0    	mov    %ax,0xf01e3236

	SETGATE(idt[16], 0, GD_KT, T_FPERR_handler, 0);			// floating point error
f0103983:	b8 bc 3e 10 f0       	mov    $0xf0103ebc,%eax
f0103988:	66 a3 40 32 1e f0    	mov    %ax,0xf01e3240
f010398e:	66 c7 05 42 32 1e f0 	movw   $0x8,0xf01e3242
f0103995:	08 00 
f0103997:	c6 05 44 32 1e f0 00 	movb   $0x0,0xf01e3244
f010399e:	c6 05 45 32 1e f0 8e 	movb   $0x8e,0xf01e3245
f01039a5:	c1 e8 10             	shr    $0x10,%eax
f01039a8:	66 a3 46 32 1e f0    	mov    %ax,0xf01e3246
	SETGATE(idt[17], 0, GD_KT, T_ALIGN_handler, 0);			// aligment check
f01039ae:	b8 c6 3e 10 f0       	mov    $0xf0103ec6,%eax
f01039b3:	66 a3 48 32 1e f0    	mov    %ax,0xf01e3248
f01039b9:	66 c7 05 4a 32 1e f0 	movw   $0x8,0xf01e324a
f01039c0:	08 00 
f01039c2:	c6 05 4c 32 1e f0 00 	movb   $0x0,0xf01e324c
f01039c9:	c6 05 4d 32 1e f0 8e 	movb   $0x8e,0xf01e324d
f01039d0:	c1 e8 10             	shr    $0x10,%eax
f01039d3:	66 a3 4e 32 1e f0    	mov    %ax,0xf01e324e
	SETGATE(idt[18], 0, GD_KT, T_MCHK_handler, 0);			// machine check
f01039d9:	b8 d0 3e 10 f0       	mov    $0xf0103ed0,%eax
f01039de:	66 a3 50 32 1e f0    	mov    %ax,0xf01e3250
f01039e4:	66 c7 05 52 32 1e f0 	movw   $0x8,0xf01e3252
f01039eb:	08 00 
f01039ed:	c6 05 54 32 1e f0 00 	movb   $0x0,0xf01e3254
f01039f4:	c6 05 55 32 1e f0 8e 	movb   $0x8e,0xf01e3255
f01039fb:	c1 e8 10             	shr    $0x10,%eax
f01039fe:	66 a3 56 32 1e f0    	mov    %ax,0xf01e3256
	SETGATE(idt[19], 0, GD_KT, T_SIMDERR_handler, 0);		// SIMD floating point error
f0103a04:	b8 da 3e 10 f0       	mov    $0xf0103eda,%eax
f0103a09:	66 a3 58 32 1e f0    	mov    %ax,0xf01e3258
f0103a0f:	66 c7 05 5a 32 1e f0 	movw   $0x8,0xf01e325a
f0103a16:	08 00 
f0103a18:	c6 05 5c 32 1e f0 00 	movb   $0x0,0xf01e325c
f0103a1f:	c6 05 5d 32 1e f0 8e 	movb   $0x8e,0xf01e325d
f0103a26:	c1 e8 10             	shr    $0x10,%eax
f0103a29:	66 a3 5e 32 1e f0    	mov    %ax,0xf01e325e
	// Add for exercise 7
	SETGATE(idt[48], 0, GD_KT, T_SYSCALL_handler, 3);		// System call handler
f0103a2f:	b8 e4 3e 10 f0       	mov    $0xf0103ee4,%eax
f0103a34:	66 a3 40 33 1e f0    	mov    %ax,0xf01e3340
f0103a3a:	66 c7 05 42 33 1e f0 	movw   $0x8,0xf01e3342
f0103a41:	08 00 
f0103a43:	c6 05 44 33 1e f0 00 	movb   $0x0,0xf01e3344
f0103a4a:	c6 05 45 33 1e f0 ee 	movb   $0xee,0xf01e3345
f0103a51:	c1 e8 10             	shr    $0x10,%eax
f0103a54:	66 a3 46 33 1e f0    	mov    %ax,0xf01e3346
	
	// Per-CPU setup 
	trap_init_percpu();
f0103a5a:	e8 61 fc ff ff       	call   f01036c0 <trap_init_percpu>
}
f0103a5f:	5d                   	pop    %ebp
f0103a60:	c3                   	ret    

f0103a61 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f0103a61:	55                   	push   %ebp
f0103a62:	89 e5                	mov    %esp,%ebp
f0103a64:	53                   	push   %ebx
f0103a65:	83 ec 14             	sub    $0x14,%esp
f0103a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103a6b:	8b 03                	mov    (%ebx),%eax
f0103a6d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a71:	c7 04 24 ab 60 10 f0 	movl   $0xf01060ab,(%esp)
f0103a78:	e8 29 fc ff ff       	call   f01036a6 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103a7d:	8b 43 04             	mov    0x4(%ebx),%eax
f0103a80:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a84:	c7 04 24 ba 60 10 f0 	movl   $0xf01060ba,(%esp)
f0103a8b:	e8 16 fc ff ff       	call   f01036a6 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103a90:	8b 43 08             	mov    0x8(%ebx),%eax
f0103a93:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103a97:	c7 04 24 c9 60 10 f0 	movl   $0xf01060c9,(%esp)
f0103a9e:	e8 03 fc ff ff       	call   f01036a6 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103aa3:	8b 43 0c             	mov    0xc(%ebx),%eax
f0103aa6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103aaa:	c7 04 24 d8 60 10 f0 	movl   $0xf01060d8,(%esp)
f0103ab1:	e8 f0 fb ff ff       	call   f01036a6 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103ab6:	8b 43 10             	mov    0x10(%ebx),%eax
f0103ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103abd:	c7 04 24 e7 60 10 f0 	movl   $0xf01060e7,(%esp)
f0103ac4:	e8 dd fb ff ff       	call   f01036a6 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103ac9:	8b 43 14             	mov    0x14(%ebx),%eax
f0103acc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ad0:	c7 04 24 f6 60 10 f0 	movl   $0xf01060f6,(%esp)
f0103ad7:	e8 ca fb ff ff       	call   f01036a6 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103adc:	8b 43 18             	mov    0x18(%ebx),%eax
f0103adf:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103ae3:	c7 04 24 05 61 10 f0 	movl   $0xf0106105,(%esp)
f0103aea:	e8 b7 fb ff ff       	call   f01036a6 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103aef:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0103af2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103af6:	c7 04 24 14 61 10 f0 	movl   $0xf0106114,(%esp)
f0103afd:	e8 a4 fb ff ff       	call   f01036a6 <cprintf>
}
f0103b02:	83 c4 14             	add    $0x14,%esp
f0103b05:	5b                   	pop    %ebx
f0103b06:	5d                   	pop    %ebp
f0103b07:	c3                   	ret    

f0103b08 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103b08:	55                   	push   %ebp
f0103b09:	89 e5                	mov    %esp,%ebp
f0103b0b:	53                   	push   %ebx
f0103b0c:	83 ec 14             	sub    $0x14,%esp
f0103b0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103b12:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103b16:	c7 04 24 4a 62 10 f0 	movl   $0xf010624a,(%esp)
f0103b1d:	e8 84 fb ff ff       	call   f01036a6 <cprintf>
	print_regs(&tf->tf_regs);
f0103b22:	89 1c 24             	mov    %ebx,(%esp)
f0103b25:	e8 37 ff ff ff       	call   f0103a61 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103b2a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103b2e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b32:	c7 04 24 65 61 10 f0 	movl   $0xf0106165,(%esp)
f0103b39:	e8 68 fb ff ff       	call   f01036a6 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103b3e:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103b42:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b46:	c7 04 24 78 61 10 f0 	movl   $0xf0106178,(%esp)
f0103b4d:	e8 54 fb ff ff       	call   f01036a6 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103b52:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103b55:	83 f8 13             	cmp    $0x13,%eax
f0103b58:	77 09                	ja     f0103b63 <print_trapframe+0x5b>
		return excnames[trapno];
f0103b5a:	8b 14 85 20 64 10 f0 	mov    -0xfef9be0(,%eax,4),%edx
f0103b61:	eb 11                	jmp    f0103b74 <print_trapframe+0x6c>
	if (trapno == T_SYSCALL)
f0103b63:	83 f8 30             	cmp    $0x30,%eax
f0103b66:	75 07                	jne    f0103b6f <print_trapframe+0x67>
		return "System call";
f0103b68:	ba 23 61 10 f0       	mov    $0xf0106123,%edx
f0103b6d:	eb 05                	jmp    f0103b74 <print_trapframe+0x6c>
	return "(unknown trap)";
f0103b6f:	ba 2f 61 10 f0       	mov    $0xf010612f,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103b74:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103b78:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b7c:	c7 04 24 8b 61 10 f0 	movl   $0xf010618b,(%esp)
f0103b83:	e8 1e fb ff ff       	call   f01036a6 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103b88:	3b 1d 28 3a 1e f0    	cmp    0xf01e3a28,%ebx
f0103b8e:	75 19                	jne    f0103ba9 <print_trapframe+0xa1>
f0103b90:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103b94:	75 13                	jne    f0103ba9 <print_trapframe+0xa1>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103b96:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103b99:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103b9d:	c7 04 24 9d 61 10 f0 	movl   $0xf010619d,(%esp)
f0103ba4:	e8 fd fa ff ff       	call   f01036a6 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0103ba9:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103bac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103bb0:	c7 04 24 ac 61 10 f0 	movl   $0xf01061ac,(%esp)
f0103bb7:	e8 ea fa ff ff       	call   f01036a6 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103bbc:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103bc0:	75 4d                	jne    f0103c0f <print_trapframe+0x107>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103bc2:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103bc5:	a8 01                	test   $0x1,%al
f0103bc7:	74 07                	je     f0103bd0 <print_trapframe+0xc8>
f0103bc9:	b9 3e 61 10 f0       	mov    $0xf010613e,%ecx
f0103bce:	eb 05                	jmp    f0103bd5 <print_trapframe+0xcd>
f0103bd0:	b9 49 61 10 f0       	mov    $0xf0106149,%ecx
f0103bd5:	a8 02                	test   $0x2,%al
f0103bd7:	74 07                	je     f0103be0 <print_trapframe+0xd8>
f0103bd9:	ba 55 61 10 f0       	mov    $0xf0106155,%edx
f0103bde:	eb 05                	jmp    f0103be5 <print_trapframe+0xdd>
f0103be0:	ba 5b 61 10 f0       	mov    $0xf010615b,%edx
f0103be5:	a8 04                	test   $0x4,%al
f0103be7:	74 07                	je     f0103bf0 <print_trapframe+0xe8>
f0103be9:	b8 60 61 10 f0       	mov    $0xf0106160,%eax
f0103bee:	eb 05                	jmp    f0103bf5 <print_trapframe+0xed>
f0103bf0:	b8 75 62 10 f0       	mov    $0xf0106275,%eax
f0103bf5:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103bf9:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c01:	c7 04 24 ba 61 10 f0 	movl   $0xf01061ba,(%esp)
f0103c08:	e8 99 fa ff ff       	call   f01036a6 <cprintf>
f0103c0d:	eb 0c                	jmp    f0103c1b <print_trapframe+0x113>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103c0f:	c7 04 24 2d 5f 10 f0 	movl   $0xf0105f2d,(%esp)
f0103c16:	e8 8b fa ff ff       	call   f01036a6 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103c1b:	8b 43 30             	mov    0x30(%ebx),%eax
f0103c1e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c22:	c7 04 24 c9 61 10 f0 	movl   $0xf01061c9,(%esp)
f0103c29:	e8 78 fa ff ff       	call   f01036a6 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103c2e:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103c32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c36:	c7 04 24 d8 61 10 f0 	movl   $0xf01061d8,(%esp)
f0103c3d:	e8 64 fa ff ff       	call   f01036a6 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103c42:	8b 43 38             	mov    0x38(%ebx),%eax
f0103c45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c49:	c7 04 24 eb 61 10 f0 	movl   $0xf01061eb,(%esp)
f0103c50:	e8 51 fa ff ff       	call   f01036a6 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103c55:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103c59:	74 27                	je     f0103c82 <print_trapframe+0x17a>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103c5b:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c62:	c7 04 24 fa 61 10 f0 	movl   $0xf01061fa,(%esp)
f0103c69:	e8 38 fa ff ff       	call   f01036a6 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103c6e:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103c72:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c76:	c7 04 24 09 62 10 f0 	movl   $0xf0106209,(%esp)
f0103c7d:	e8 24 fa ff ff       	call   f01036a6 <cprintf>
	}
}
f0103c82:	83 c4 14             	add    $0x14,%esp
f0103c85:	5b                   	pop    %ebx
f0103c86:	5d                   	pop    %ebp
f0103c87:	c3                   	ret    

f0103c88 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103c88:	55                   	push   %ebp
f0103c89:	89 e5                	mov    %esp,%ebp
f0103c8b:	53                   	push   %ebx
f0103c8c:	83 ec 14             	sub    $0x14,%esp
f0103c8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103c92:	0f 20 d0             	mov    %cr2,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c95:	8b 53 30             	mov    0x30(%ebx),%edx
f0103c98:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103c9c:	89 44 24 08          	mov    %eax,0x8(%esp)
		curenv->env_id, fault_va, tf->tf_eip);
f0103ca0:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103ca5:	8b 40 48             	mov    0x48(%eax),%eax
f0103ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103cac:	c7 04 24 c0 63 10 f0 	movl   $0xf01063c0,(%esp)
f0103cb3:	e8 ee f9 ff ff       	call   f01036a6 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103cb8:	89 1c 24             	mov    %ebx,(%esp)
f0103cbb:	e8 48 fe ff ff       	call   f0103b08 <print_trapframe>
	env_destroy(curenv);
f0103cc0:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0103cc5:	89 04 24             	mov    %eax,(%esp)
f0103cc8:	e8 c2 f8 ff ff       	call   f010358f <env_destroy>
}
f0103ccd:	83 c4 14             	add    $0x14,%esp
f0103cd0:	5b                   	pop    %ebx
f0103cd1:	5d                   	pop    %ebp
f0103cd2:	c3                   	ret    

f0103cd3 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103cd3:	55                   	push   %ebp
f0103cd4:	89 e5                	mov    %esp,%ebp
f0103cd6:	57                   	push   %edi
f0103cd7:	56                   	push   %esi
f0103cd8:	83 ec 20             	sub    $0x20,%esp
f0103cdb:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103cde:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103cdf:	9c                   	pushf  
f0103ce0:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103ce1:	f6 c4 02             	test   $0x2,%ah
f0103ce4:	74 24                	je     f0103d0a <trap+0x37>
f0103ce6:	c7 44 24 0c 1c 62 10 	movl   $0xf010621c,0xc(%esp)
f0103ced:	f0 
f0103cee:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0103cf5:	f0 
f0103cf6:	c7 44 24 04 e7 00 00 	movl   $0xe7,0x4(%esp)
f0103cfd:	00 
f0103cfe:	c7 04 24 35 62 10 f0 	movl   $0xf0106235,(%esp)
f0103d05:	e8 a7 c3 ff ff       	call   f01000b1 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103d0a:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103d0e:	c7 04 24 41 62 10 f0 	movl   $0xf0106241,(%esp)
f0103d15:	e8 8c f9 ff ff       	call   f01036a6 <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f0103d1a:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103d1e:	83 e0 03             	and    $0x3,%eax
f0103d21:	83 f8 03             	cmp    $0x3,%eax
f0103d24:	75 3c                	jne    f0103d62 <trap+0x8f>
		// Trapped from user mode.
		assert(curenv);
f0103d26:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0103d2b:	85 c0                	test   %eax,%eax
f0103d2d:	75 24                	jne    f0103d53 <trap+0x80>
f0103d2f:	c7 44 24 0c 5c 62 10 	movl   $0xf010625c,0xc(%esp)
f0103d36:	f0 
f0103d37:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0103d3e:	f0 
f0103d3f:	c7 44 24 04 ed 00 00 	movl   $0xed,0x4(%esp)
f0103d46:	00 
f0103d47:	c7 04 24 35 62 10 f0 	movl   $0xf0106235,(%esp)
f0103d4e:	e8 5e c3 ff ff       	call   f01000b1 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103d53:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103d58:	89 c7                	mov    %eax,%edi
f0103d5a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103d5c:	8b 35 a8 31 1e f0    	mov    0xf01e31a8,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103d62:	89 35 28 3a 1e f0    	mov    %esi,0xf01e3a28
trap_dispatch(struct Trapframe *tf)
{
	// Handle processor exceptions.
	// LAB 3: Your code here.
	// Trap 3
	if (tf->tf_trapno == T_BRKPT) {
f0103d68:	8b 46 28             	mov    0x28(%esi),%eax
f0103d6b:	83 f8 03             	cmp    $0x3,%eax
f0103d6e:	75 0a                	jne    f0103d7a <trap+0xa7>
		monitor(tf);
f0103d70:	89 34 24             	mov    %esi,(%esp)
f0103d73:	e8 59 ca ff ff       	call   f01007d1 <monitor>
f0103d78:	eb 7e                	jmp    f0103df8 <trap+0x125>
		return;
	}
	// Trap 14
	if (tf->tf_trapno == T_PGFLT) {
f0103d7a:	83 f8 0e             	cmp    $0xe,%eax
f0103d7d:	75 0a                	jne    f0103d89 <trap+0xb6>
		page_fault_handler(tf);
f0103d7f:	89 34 24             	mov    %esi,(%esp)
f0103d82:	e8 01 ff ff ff       	call   f0103c88 <page_fault_handler>
f0103d87:	eb 6f                	jmp    f0103df8 <trap+0x125>
		return;
	}
	// Trap 48
	if (tf->tf_trapno == T_SYSCALL) {
f0103d89:	83 f8 30             	cmp    $0x30,%eax
f0103d8c:	75 32                	jne    f0103dc0 <trap+0xed>
		int32_t ret;
		ret = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx, 
f0103d8e:	8b 46 04             	mov    0x4(%esi),%eax
f0103d91:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103d95:	8b 06                	mov    (%esi),%eax
f0103d97:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103d9b:	8b 46 10             	mov    0x10(%esi),%eax
f0103d9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103da2:	8b 46 18             	mov    0x18(%esi),%eax
f0103da5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103da9:	8b 46 14             	mov    0x14(%esi),%eax
f0103dac:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103db0:	8b 46 1c             	mov    0x1c(%esi),%eax
f0103db3:	89 04 24             	mov    %eax,(%esp)
f0103db6:	e8 45 01 00 00       	call   f0103f00 <syscall>
			tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		tf->tf_regs.reg_eax = ret;
f0103dbb:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103dbe:	eb 38                	jmp    f0103df8 <trap+0x125>
		return;
	}
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0103dc0:	89 34 24             	mov    %esi,(%esp)
f0103dc3:	e8 40 fd ff ff       	call   f0103b08 <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0103dc8:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103dcd:	75 1c                	jne    f0103deb <trap+0x118>
		panic("unhandled trap in kernel");
f0103dcf:	c7 44 24 08 63 62 10 	movl   $0xf0106263,0x8(%esp)
f0103dd6:	f0 
f0103dd7:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
f0103dde:	00 
f0103ddf:	c7 04 24 35 62 10 f0 	movl   $0xf0106235,(%esp)
f0103de6:	e8 c6 c2 ff ff       	call   f01000b1 <_panic>
	else {
		env_destroy(curenv);
f0103deb:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0103df0:	89 04 24             	mov    %eax,(%esp)
f0103df3:	e8 97 f7 ff ff       	call   f010358f <env_destroy>

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103df8:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0103dfd:	85 c0                	test   %eax,%eax
f0103dff:	74 06                	je     f0103e07 <trap+0x134>
f0103e01:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103e05:	74 24                	je     f0103e2b <trap+0x158>
f0103e07:	c7 44 24 0c e4 63 10 	movl   $0xf01063e4,0xc(%esp)
f0103e0e:	f0 
f0103e0f:	c7 44 24 08 a2 5c 10 	movl   $0xf0105ca2,0x8(%esp)
f0103e16:	f0 
f0103e17:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0103e1e:	00 
f0103e1f:	c7 04 24 35 62 10 f0 	movl   $0xf0106235,(%esp)
f0103e26:	e8 86 c2 ff ff       	call   f01000b1 <_panic>
	env_run(curenv);
f0103e2b:	89 04 24             	mov    %eax,(%esp)
f0103e2e:	e8 b3 f7 ff ff       	call   f01035e6 <env_run>
	...

f0103e34 <T_DIVIDE_handler>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(T_DIVIDE_handler, T_DIVIDE)
f0103e34:	6a 00                	push   $0x0
f0103e36:	6a 00                	push   $0x0
f0103e38:	e9 b0 00 00 00       	jmp    f0103eed <_alltraps>
f0103e3d:	90                   	nop

f0103e3e <T_DEBUG_handler>:
TRAPHANDLER_NOEC(T_DEBUG_handler, T_DEBUG)
f0103e3e:	6a 00                	push   $0x0
f0103e40:	6a 01                	push   $0x1
f0103e42:	e9 a6 00 00 00       	jmp    f0103eed <_alltraps>
f0103e47:	90                   	nop

f0103e48 <T_NMI_handler>:
TRAPHANDLER_NOEC(T_NMI_handler, T_NMI)
f0103e48:	6a 00                	push   $0x0
f0103e4a:	6a 02                	push   $0x2
f0103e4c:	e9 9c 00 00 00       	jmp    f0103eed <_alltraps>
f0103e51:	90                   	nop

f0103e52 <T_BRKPT_handler>:
TRAPHANDLER_NOEC(T_BRKPT_handler, T_BRKPT)
f0103e52:	6a 00                	push   $0x0
f0103e54:	6a 03                	push   $0x3
f0103e56:	e9 92 00 00 00       	jmp    f0103eed <_alltraps>
f0103e5b:	90                   	nop

f0103e5c <T_OFLOW_handler>:
TRAPHANDLER_NOEC(T_OFLOW_handler, T_OFLOW)
f0103e5c:	6a 00                	push   $0x0
f0103e5e:	6a 04                	push   $0x4
f0103e60:	e9 88 00 00 00       	jmp    f0103eed <_alltraps>
f0103e65:	90                   	nop

f0103e66 <T_BOUND_handler>:
TRAPHANDLER_NOEC(T_BOUND_handler, T_BOUND)
f0103e66:	6a 00                	push   $0x0
f0103e68:	6a 05                	push   $0x5
f0103e6a:	e9 7e 00 00 00       	jmp    f0103eed <_alltraps>
f0103e6f:	90                   	nop

f0103e70 <T_ILLOP_handler>:
TRAPHANDLER_NOEC(T_ILLOP_handler, T_ILLOP)
f0103e70:	6a 00                	push   $0x0
f0103e72:	6a 06                	push   $0x6
f0103e74:	e9 74 00 00 00       	jmp    f0103eed <_alltraps>
f0103e79:	90                   	nop

f0103e7a <T_DEVICE_handler>:
TRAPHANDLER_NOEC(T_DEVICE_handler, T_DEVICE)
f0103e7a:	6a 00                	push   $0x0
f0103e7c:	6a 07                	push   $0x7
f0103e7e:	e9 6a 00 00 00       	jmp    f0103eed <_alltraps>
f0103e83:	90                   	nop

f0103e84 <T_DBLFLT_handler>:
TRAPHANDLER_NOEC(T_DBLFLT_handler, T_DBLFLT)
f0103e84:	6a 00                	push   $0x0
f0103e86:	6a 08                	push   $0x8
f0103e88:	e9 60 00 00 00       	jmp    f0103eed <_alltraps>
f0103e8d:	90                   	nop

f0103e8e <T_TSS_handler>:

TRAPHANDLER_NOEC(T_TSS_handler, T_TSS)
f0103e8e:	6a 00                	push   $0x0
f0103e90:	6a 0a                	push   $0xa
f0103e92:	e9 56 00 00 00       	jmp    f0103eed <_alltraps>
f0103e97:	90                   	nop

f0103e98 <T_SEGNP_handler>:
TRAPHANDLER_NOEC(T_SEGNP_handler, T_SEGNP)
f0103e98:	6a 00                	push   $0x0
f0103e9a:	6a 0b                	push   $0xb
f0103e9c:	e9 4c 00 00 00       	jmp    f0103eed <_alltraps>
f0103ea1:	90                   	nop

f0103ea2 <T_STACK_handler>:
TRAPHANDLER_NOEC(T_STACK_handler, T_STACK)
f0103ea2:	6a 00                	push   $0x0
f0103ea4:	6a 0c                	push   $0xc
f0103ea6:	e9 42 00 00 00       	jmp    f0103eed <_alltraps>
f0103eab:	90                   	nop

f0103eac <T_GPFLT_handler>:
TRAPHANDLER(T_GPFLT_handler, T_GPFLT)
f0103eac:	6a 0d                	push   $0xd
f0103eae:	e9 3a 00 00 00       	jmp    f0103eed <_alltraps>
f0103eb3:	90                   	nop

f0103eb4 <T_PGFLT_handler>:
TRAPHANDLER(T_PGFLT_handler, T_PGFLT)
f0103eb4:	6a 0e                	push   $0xe
f0103eb6:	e9 32 00 00 00       	jmp    f0103eed <_alltraps>
f0103ebb:	90                   	nop

f0103ebc <T_FPERR_handler>:

TRAPHANDLER_NOEC(T_FPERR_handler, T_FPERR)
f0103ebc:	6a 00                	push   $0x0
f0103ebe:	6a 10                	push   $0x10
f0103ec0:	e9 28 00 00 00       	jmp    f0103eed <_alltraps>
f0103ec5:	90                   	nop

f0103ec6 <T_ALIGN_handler>:
TRAPHANDLER_NOEC(T_ALIGN_handler, T_ALIGN)
f0103ec6:	6a 00                	push   $0x0
f0103ec8:	6a 11                	push   $0x11
f0103eca:	e9 1e 00 00 00       	jmp    f0103eed <_alltraps>
f0103ecf:	90                   	nop

f0103ed0 <T_MCHK_handler>:
TRAPHANDLER_NOEC(T_MCHK_handler, T_MCHK)
f0103ed0:	6a 00                	push   $0x0
f0103ed2:	6a 12                	push   $0x12
f0103ed4:	e9 14 00 00 00       	jmp    f0103eed <_alltraps>
f0103ed9:	90                   	nop

f0103eda <T_SIMDERR_handler>:
TRAPHANDLER_NOEC(T_SIMDERR_handler, T_SIMDERR)
f0103eda:	6a 00                	push   $0x0
f0103edc:	6a 13                	push   $0x13
f0103ede:	e9 0a 00 00 00       	jmp    f0103eed <_alltraps>
f0103ee3:	90                   	nop

f0103ee4 <T_SYSCALL_handler>:

TRAPHANDLER_NOEC(T_SYSCALL_handler, T_SYSCALL)
f0103ee4:	6a 00                	push   $0x0
f0103ee6:	6a 30                	push   $0x30
f0103ee8:	e9 00 00 00 00       	jmp    f0103eed <_alltraps>

f0103eed <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
.globl _alltraps
_alltraps:
  # Build trap frame.
  pushl %ds
f0103eed:	1e                   	push   %ds
  pushl %es
f0103eee:	06                   	push   %es
  pushal
f0103eef:	60                   	pusha  

  # Save information
  movl $GD_KD, %eax
f0103ef0:	b8 10 00 00 00       	mov    $0x10,%eax
  movw %ax, %ds
f0103ef5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
f0103ef7:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
f0103ef9:	54                   	push   %esp
  call trap
f0103efa:	e8 d4 fd ff ff       	call   f0103cd3 <trap>
	...

f0103f00 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103f00:	55                   	push   %ebp
f0103f01:	89 e5                	mov    %esp,%ebp
f0103f03:	56                   	push   %esi
f0103f04:	53                   	push   %ebx
f0103f05:	83 ec 20             	sub    $0x20,%esp
f0103f08:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103f0e:	8b 75 10             	mov    0x10(%ebp),%esi
	// LAB 3: Your code here.

	// panic("syscall not implemented");
	int32_t ret;

	switch (syscallno) {
f0103f11:	83 f8 01             	cmp    $0x1,%eax
f0103f14:	74 4d                	je     f0103f63 <syscall+0x63>
f0103f16:	83 f8 01             	cmp    $0x1,%eax
f0103f19:	72 10                	jb     f0103f2b <syscall+0x2b>
f0103f1b:	83 f8 02             	cmp    $0x2,%eax
f0103f1e:	74 4a                	je     f0103f6a <syscall+0x6a>
f0103f20:	83 f8 03             	cmp    $0x3,%eax
f0103f23:	0f 85 b4 00 00 00    	jne    f0103fdd <syscall+0xdd>
f0103f29:	eb 49                	jmp    f0103f74 <syscall+0x74>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);
f0103f2b:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0103f32:	00 
f0103f33:	89 74 24 08          	mov    %esi,0x8(%esp)
f0103f37:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103f3b:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0103f40:	89 04 24             	mov    %eax,(%esp)
f0103f43:	e8 59 ef ff ff       	call   f0102ea1 <user_mem_assert>
	
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0103f48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103f4c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103f50:	c7 04 24 70 64 10 f0 	movl   $0xf0106470,(%esp)
f0103f57:	e8 4a f7 ff ff       	call   f01036a6 <cprintf>
	int32_t ret;

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
f0103f5c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103f61:	eb 7f                	jmp    f0103fe2 <syscall+0xe2>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0103f63:	e8 4e c5 ff ff       	call   f01004b6 <cons_getc>
		sys_cputs((char *)a1, (size_t)a2);
		ret = 0;
		break;
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
f0103f68:	eb 78                	jmp    f0103fe2 <syscall+0xe2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103f6a:	a1 a8 31 1e f0       	mov    0xf01e31a8,%eax
f0103f6f:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cgetc:
		ret = sys_cgetc();
		break;
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
f0103f72:	eb 6e                	jmp    f0103fe2 <syscall+0xe2>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0103f74:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0103f7b:	00 
f0103f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f7f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f83:	89 1c 24             	mov    %ebx,(%esp)
f0103f86:	e8 0c f0 ff ff       	call   f0102f97 <envid2env>
f0103f8b:	85 c0                	test   %eax,%eax
f0103f8d:	78 53                	js     f0103fe2 <syscall+0xe2>
		return r;
	if (e == curenv)
f0103f8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f92:	8b 15 a8 31 1e f0    	mov    0xf01e31a8,%edx
f0103f98:	39 d0                	cmp    %edx,%eax
f0103f9a:	75 15                	jne    f0103fb1 <syscall+0xb1>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103f9c:	8b 40 48             	mov    0x48(%eax),%eax
f0103f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fa3:	c7 04 24 75 64 10 f0 	movl   $0xf0106475,(%esp)
f0103faa:	e8 f7 f6 ff ff       	call   f01036a6 <cprintf>
f0103faf:	eb 1a                	jmp    f0103fcb <syscall+0xcb>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0103fb1:	8b 40 48             	mov    0x48(%eax),%eax
f0103fb4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103fb8:	8b 42 48             	mov    0x48(%edx),%eax
f0103fbb:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103fbf:	c7 04 24 90 64 10 f0 	movl   $0xf0106490,(%esp)
f0103fc6:	e8 db f6 ff ff       	call   f01036a6 <cprintf>
	env_destroy(e);
f0103fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103fce:	89 04 24             	mov    %eax,(%esp)
f0103fd1:	e8 b9 f5 ff ff       	call   f010358f <env_destroy>
	return 0;
f0103fd6:	b8 00 00 00 00       	mov    $0x0,%eax
	case SYS_getenvid:
		ret = sys_getenvid();
		break;
	case SYS_env_destroy:
		ret = sys_env_destroy((envid_t)a1);
		break;
f0103fdb:	eb 05                	jmp    f0103fe2 <syscall+0xe2>
	default:
		ret = -E_INVAL;
f0103fdd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		break;
	}

	return ret;
}
f0103fe2:	83 c4 20             	add    $0x20,%esp
f0103fe5:	5b                   	pop    %ebx
f0103fe6:	5e                   	pop    %esi
f0103fe7:	5d                   	pop    %ebp
f0103fe8:	c3                   	ret    
f0103fe9:	00 00                	add    %al,(%eax)
	...

f0103fec <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0103fec:	55                   	push   %ebp
f0103fed:	89 e5                	mov    %esp,%ebp
f0103fef:	57                   	push   %edi
f0103ff0:	56                   	push   %esi
f0103ff1:	53                   	push   %ebx
f0103ff2:	83 ec 14             	sub    $0x14,%esp
f0103ff5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103ff8:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0103ffb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0103ffe:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104001:	8b 1a                	mov    (%edx),%ebx
f0104003:	8b 01                	mov    (%ecx),%eax
f0104005:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104008:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	while (l <= r) {
f010400f:	e9 83 00 00 00       	jmp    f0104097 <stab_binsearch+0xab>
		int true_m = (l + r) / 2, m = true_m;
f0104014:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104017:	01 d8                	add    %ebx,%eax
f0104019:	89 c7                	mov    %eax,%edi
f010401b:	c1 ef 1f             	shr    $0x1f,%edi
f010401e:	01 c7                	add    %eax,%edi
f0104020:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104022:	8d 04 7f             	lea    (%edi,%edi,2),%eax
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0104025:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104028:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f010402c:	89 f8                	mov    %edi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010402e:	eb 01                	jmp    f0104031 <stab_binsearch+0x45>
			m--;
f0104030:	48                   	dec    %eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104031:	39 c3                	cmp    %eax,%ebx
f0104033:	7f 1e                	jg     f0104053 <stab_binsearch+0x67>
f0104035:	0f b6 0a             	movzbl (%edx),%ecx
f0104038:	83 ea 0c             	sub    $0xc,%edx
f010403b:	39 f1                	cmp    %esi,%ecx
f010403d:	75 f1                	jne    f0104030 <stab_binsearch+0x44>
f010403f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104042:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104045:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104048:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010404c:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010404f:	76 18                	jbe    f0104069 <stab_binsearch+0x7d>
f0104051:	eb 05                	jmp    f0104058 <stab_binsearch+0x6c>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104053:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104056:	eb 3f                	jmp    f0104097 <stab_binsearch+0xab>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104058:	8b 55 e8             	mov    -0x18(%ebp),%edx
f010405b:	89 02                	mov    %eax,(%edx)
			l = true_m + 1;
f010405d:	8d 5f 01             	lea    0x1(%edi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104060:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104067:	eb 2e                	jmp    f0104097 <stab_binsearch+0xab>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104069:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010406c:	73 15                	jae    f0104083 <stab_binsearch+0x97>
			*region_right = m - 1;
f010406e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104071:	49                   	dec    %ecx
f0104072:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104075:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104078:	89 08                	mov    %ecx,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010407a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104081:	eb 14                	jmp    f0104097 <stab_binsearch+0xab>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104083:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104086:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104089:	89 0a                	mov    %ecx,(%edx)
			l = m;
			addr++;
f010408b:	ff 45 0c             	incl   0xc(%ebp)
f010408e:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104090:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104097:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010409a:	0f 8e 74 ff ff ff    	jle    f0104014 <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f01040a0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01040a4:	75 0d                	jne    f01040b3 <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f01040a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01040a9:	8b 02                	mov    (%edx),%eax
f01040ab:	48                   	dec    %eax
f01040ac:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01040af:	89 01                	mov    %eax,(%ecx)
f01040b1:	eb 2a                	jmp    f01040dd <stab_binsearch+0xf1>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01040b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01040b6:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f01040b8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01040bb:	8b 0a                	mov    (%edx),%ecx
f01040bd:	8d 14 40             	lea    (%eax,%eax,2),%edx
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f01040c0:	8b 5d ec             	mov    -0x14(%ebp),%ebx
f01040c3:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01040c7:	eb 01                	jmp    f01040ca <stab_binsearch+0xde>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01040c9:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01040ca:	39 c8                	cmp    %ecx,%eax
f01040cc:	7e 0a                	jle    f01040d8 <stab_binsearch+0xec>
		     l > *region_left && stabs[l].n_type != type;
f01040ce:	0f b6 1a             	movzbl (%edx),%ebx
f01040d1:	83 ea 0c             	sub    $0xc,%edx
f01040d4:	39 f3                	cmp    %esi,%ebx
f01040d6:	75 f1                	jne    f01040c9 <stab_binsearch+0xdd>
		     l--)
			/* do nothing */;
		*region_left = l;
f01040d8:	8b 55 e8             	mov    -0x18(%ebp),%edx
f01040db:	89 02                	mov    %eax,(%edx)
	}
}
f01040dd:	83 c4 14             	add    $0x14,%esp
f01040e0:	5b                   	pop    %ebx
f01040e1:	5e                   	pop    %esi
f01040e2:	5f                   	pop    %edi
f01040e3:	5d                   	pop    %ebp
f01040e4:	c3                   	ret    

f01040e5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01040e5:	55                   	push   %ebp
f01040e6:	89 e5                	mov    %esp,%ebp
f01040e8:	57                   	push   %edi
f01040e9:	56                   	push   %esi
f01040ea:	53                   	push   %ebx
f01040eb:	83 ec 5c             	sub    $0x5c,%esp
f01040ee:	8b 75 08             	mov    0x8(%ebp),%esi
f01040f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01040f4:	c7 03 a8 64 10 f0    	movl   $0xf01064a8,(%ebx)
	info->eip_line = 0;
f01040fa:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104101:	c7 43 08 a8 64 10 f0 	movl   $0xf01064a8,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104108:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f010410f:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104112:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104119:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f010411f:	77 22                	ja     f0104143 <debuginfo_eip+0x5e>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0104121:	8b 3d 00 00 20 00    	mov    0x200000,%edi
f0104127:	89 7d c4             	mov    %edi,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010412a:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010412f:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0104135:	89 7d bc             	mov    %edi,-0x44(%ebp)
		stabstr_end = usd->stabstr_end;
f0104138:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f010413e:	89 7d c0             	mov    %edi,-0x40(%ebp)
f0104141:	eb 1a                	jmp    f010415d <debuginfo_eip+0x78>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104143:	c7 45 c0 d6 8f 11 f0 	movl   $0xf0118fd6,-0x40(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f010414a:	c7 45 bc 51 f1 10 f0 	movl   $0xf010f151,-0x44(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104151:	b8 50 f1 10 f0       	mov    $0xf010f150,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104156:	c7 45 c4 c0 66 10 f0 	movl   $0xf01066c0,-0x3c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010415d:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0104160:	39 7d bc             	cmp    %edi,-0x44(%ebp)
f0104163:	0f 83 8b 01 00 00    	jae    f01042f4 <debuginfo_eip+0x20f>
f0104169:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010416d:	0f 85 88 01 00 00    	jne    f01042fb <debuginfo_eip+0x216>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104173:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010417a:	2b 45 c4             	sub    -0x3c(%ebp),%eax
f010417d:	c1 f8 02             	sar    $0x2,%eax
f0104180:	8d 14 80             	lea    (%eax,%eax,4),%edx
f0104183:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104186:	8d 14 90             	lea    (%eax,%edx,4),%edx
f0104189:	89 d1                	mov    %edx,%ecx
f010418b:	c1 e1 08             	shl    $0x8,%ecx
f010418e:	01 ca                	add    %ecx,%edx
f0104190:	89 d1                	mov    %edx,%ecx
f0104192:	c1 e1 10             	shl    $0x10,%ecx
f0104195:	01 ca                	add    %ecx,%edx
f0104197:	8d 44 50 ff          	lea    -0x1(%eax,%edx,2),%eax
f010419b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010419e:	89 74 24 04          	mov    %esi,0x4(%esp)
f01041a2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f01041a9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01041ac:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01041af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01041b2:	e8 35 fe ff ff       	call   f0103fec <stab_binsearch>
	if (lfile == 0)
f01041b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01041ba:	85 c0                	test   %eax,%eax
f01041bc:	0f 84 40 01 00 00    	je     f0104302 <debuginfo_eip+0x21d>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01041c2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01041c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01041c8:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01041cb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01041cf:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f01041d6:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01041d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01041dc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01041df:	e8 08 fe ff ff       	call   f0103fec <stab_binsearch>

	if (lfun <= rfun) {
f01041e4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01041e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01041ea:	39 d0                	cmp    %edx,%eax
f01041ec:	7f 32                	jg     f0104220 <debuginfo_eip+0x13b>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01041ee:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01041f1:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01041f4:	8d 0c 8f             	lea    (%edi,%ecx,4),%ecx
f01041f7:	8b 39                	mov    (%ecx),%edi
f01041f9:	89 7d b4             	mov    %edi,-0x4c(%ebp)
f01041fc:	8b 7d c0             	mov    -0x40(%ebp),%edi
f01041ff:	2b 7d bc             	sub    -0x44(%ebp),%edi
f0104202:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0104205:	73 09                	jae    f0104210 <debuginfo_eip+0x12b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104207:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010420a:	03 7d bc             	add    -0x44(%ebp),%edi
f010420d:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104210:	8b 49 08             	mov    0x8(%ecx),%ecx
f0104213:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104216:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0104218:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f010421b:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010421e:	eb 0f                	jmp    f010422f <debuginfo_eip+0x14a>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104220:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104223:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104226:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104229:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010422c:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010422f:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104236:	00 
f0104237:	8b 43 08             	mov    0x8(%ebx),%eax
f010423a:	89 04 24             	mov    %eax,(%esp)
f010423d:	e8 74 08 00 00       	call   f0104ab6 <strfind>
f0104242:	2b 43 08             	sub    0x8(%ebx),%eax
f0104245:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104248:	89 74 24 04          	mov    %esi,0x4(%esp)
f010424c:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0104253:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104256:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104259:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f010425c:	e8 8b fd ff ff       	call   f0103fec <stab_binsearch>
	if (lline > rline) {
f0104261:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104264:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0104267:	0f 8f 9c 00 00 00    	jg     f0104309 <debuginfo_eip+0x224>
		return -1;
	}
	info->eip_line = stabs[rline].n_desc;
f010426d:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104270:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104273:	0f b7 44 87 06       	movzwl 0x6(%edi,%eax,4),%eax
f0104278:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010427b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010427e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104281:	8d 14 40             	lea    (%eax,%eax,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f0104284:	8d 54 97 08          	lea    0x8(%edi,%edx,4),%edx
f0104288:	89 5d b8             	mov    %ebx,-0x48(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010428b:	eb 04                	jmp    f0104291 <debuginfo_eip+0x1ac>
f010428d:	48                   	dec    %eax
f010428e:	83 ea 0c             	sub    $0xc,%edx
f0104291:	89 c7                	mov    %eax,%edi
f0104293:	39 c6                	cmp    %eax,%esi
f0104295:	7f 25                	jg     f01042bc <debuginfo_eip+0x1d7>
	       && stabs[lline].n_type != N_SOL
f0104297:	8a 4a fc             	mov    -0x4(%edx),%cl
f010429a:	80 f9 84             	cmp    $0x84,%cl
f010429d:	0f 84 81 00 00 00    	je     f0104324 <debuginfo_eip+0x23f>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01042a3:	80 f9 64             	cmp    $0x64,%cl
f01042a6:	75 e5                	jne    f010428d <debuginfo_eip+0x1a8>
f01042a8:	83 3a 00             	cmpl   $0x0,(%edx)
f01042ab:	74 e0                	je     f010428d <debuginfo_eip+0x1a8>
f01042ad:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f01042b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01042b3:	eb 75                	jmp    f010432a <debuginfo_eip+0x245>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f01042b5:	03 45 bc             	add    -0x44(%ebp),%eax
f01042b8:	89 03                	mov    %eax,(%ebx)
f01042ba:	eb 03                	jmp    f01042bf <debuginfo_eip+0x1da>
f01042bc:	8b 5d b8             	mov    -0x48(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01042bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01042c2:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01042c5:	39 f2                	cmp    %esi,%edx
f01042c7:	7d 47                	jge    f0104310 <debuginfo_eip+0x22b>
		for (lline = lfun + 1;
f01042c9:	42                   	inc    %edx
f01042ca:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01042cd:	89 d0                	mov    %edx,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01042cf:	8d 14 52             	lea    (%edx,%edx,2),%edx
//	instruction address, 'addr'.  Returns 0 if information was found, and
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
f01042d2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01042d5:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01042d9:	eb 03                	jmp    f01042de <debuginfo_eip+0x1f9>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01042db:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01042de:	39 f0                	cmp    %esi,%eax
f01042e0:	7d 35                	jge    f0104317 <debuginfo_eip+0x232>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01042e2:	8a 0a                	mov    (%edx),%cl
f01042e4:	40                   	inc    %eax
f01042e5:	83 c2 0c             	add    $0xc,%edx
f01042e8:	80 f9 a0             	cmp    $0xa0,%cl
f01042eb:	74 ee                	je     f01042db <debuginfo_eip+0x1f6>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01042ed:	b8 00 00 00 00       	mov    $0x0,%eax
f01042f2:	eb 28                	jmp    f010431c <debuginfo_eip+0x237>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01042f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01042f9:	eb 21                	jmp    f010431c <debuginfo_eip+0x237>
f01042fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104300:	eb 1a                	jmp    f010431c <debuginfo_eip+0x237>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104307:	eb 13                	jmp    f010431c <debuginfo_eip+0x237>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
		return -1;
f0104309:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010430e:	eb 0c                	jmp    f010431c <debuginfo_eip+0x237>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104310:	b8 00 00 00 00       	mov    $0x0,%eax
f0104315:	eb 05                	jmp    f010431c <debuginfo_eip+0x237>
f0104317:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010431c:	83 c4 5c             	add    $0x5c,%esp
f010431f:	5b                   	pop    %ebx
f0104320:	5e                   	pop    %esi
f0104321:	5f                   	pop    %edi
f0104322:	5d                   	pop    %ebp
f0104323:	c3                   	ret    
f0104324:	8b 5d b8             	mov    -0x48(%ebp),%ebx

	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104327:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010432a:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010432d:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104330:	8b 04 87             	mov    (%edi,%eax,4),%eax
f0104333:	8b 55 c0             	mov    -0x40(%ebp),%edx
f0104336:	2b 55 bc             	sub    -0x44(%ebp),%edx
f0104339:	39 d0                	cmp    %edx,%eax
f010433b:	0f 82 74 ff ff ff    	jb     f01042b5 <debuginfo_eip+0x1d0>
f0104341:	e9 79 ff ff ff       	jmp    f01042bf <debuginfo_eip+0x1da>
	...

f0104348 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104348:	55                   	push   %ebp
f0104349:	89 e5                	mov    %esp,%ebp
f010434b:	57                   	push   %edi
f010434c:	56                   	push   %esi
f010434d:	53                   	push   %ebx
f010434e:	83 ec 3c             	sub    $0x3c,%esp
f0104351:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104354:	89 d7                	mov    %edx,%edi
f0104356:	8b 45 08             	mov    0x8(%ebp),%eax
f0104359:	89 45 dc             	mov    %eax,-0x24(%ebp)
f010435c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010435f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104362:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104365:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104368:	85 c0                	test   %eax,%eax
f010436a:	75 08                	jne    f0104374 <printnum+0x2c>
f010436c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010436f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104372:	77 57                	ja     f01043cb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104374:	89 74 24 10          	mov    %esi,0x10(%esp)
f0104378:	4b                   	dec    %ebx
f0104379:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010437d:	8b 45 10             	mov    0x10(%ebp),%eax
f0104380:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104384:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0104388:	8b 74 24 0c          	mov    0xc(%esp),%esi
f010438c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104393:	00 
f0104394:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104397:	89 04 24             	mov    %eax,(%esp)
f010439a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010439d:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043a1:	e8 1e 09 00 00       	call   f0104cc4 <__udivdi3>
f01043a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01043aa:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01043ae:	89 04 24             	mov    %eax,(%esp)
f01043b1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01043b5:	89 fa                	mov    %edi,%edx
f01043b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01043ba:	e8 89 ff ff ff       	call   f0104348 <printnum>
f01043bf:	eb 0f                	jmp    f01043d0 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01043c1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01043c5:	89 34 24             	mov    %esi,(%esp)
f01043c8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01043cb:	4b                   	dec    %ebx
f01043cc:	85 db                	test   %ebx,%ebx
f01043ce:	7f f1                	jg     f01043c1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01043d0:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01043d4:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01043d8:	8b 45 10             	mov    0x10(%ebp),%eax
f01043db:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043df:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01043e6:	00 
f01043e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01043ea:	89 04 24             	mov    %eax,(%esp)
f01043ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01043f0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043f4:	e8 eb 09 00 00       	call   f0104de4 <__umoddi3>
f01043f9:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01043fd:	0f be 80 b2 64 10 f0 	movsbl -0xfef9b4e(%eax),%eax
f0104404:	89 04 24             	mov    %eax,(%esp)
f0104407:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010440a:	83 c4 3c             	add    $0x3c,%esp
f010440d:	5b                   	pop    %ebx
f010440e:	5e                   	pop    %esi
f010440f:	5f                   	pop    %edi
f0104410:	5d                   	pop    %ebp
f0104411:	c3                   	ret    

f0104412 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104412:	55                   	push   %ebp
f0104413:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104415:	83 fa 01             	cmp    $0x1,%edx
f0104418:	7e 0e                	jle    f0104428 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010441a:	8b 10                	mov    (%eax),%edx
f010441c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010441f:	89 08                	mov    %ecx,(%eax)
f0104421:	8b 02                	mov    (%edx),%eax
f0104423:	8b 52 04             	mov    0x4(%edx),%edx
f0104426:	eb 22                	jmp    f010444a <getuint+0x38>
	else if (lflag)
f0104428:	85 d2                	test   %edx,%edx
f010442a:	74 10                	je     f010443c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010442c:	8b 10                	mov    (%eax),%edx
f010442e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104431:	89 08                	mov    %ecx,(%eax)
f0104433:	8b 02                	mov    (%edx),%eax
f0104435:	ba 00 00 00 00       	mov    $0x0,%edx
f010443a:	eb 0e                	jmp    f010444a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010443c:	8b 10                	mov    (%eax),%edx
f010443e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104441:	89 08                	mov    %ecx,(%eax)
f0104443:	8b 02                	mov    (%edx),%eax
f0104445:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010444a:	5d                   	pop    %ebp
f010444b:	c3                   	ret    

f010444c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010444c:	55                   	push   %ebp
f010444d:	89 e5                	mov    %esp,%ebp
f010444f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104452:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0104455:	8b 10                	mov    (%eax),%edx
f0104457:	3b 50 04             	cmp    0x4(%eax),%edx
f010445a:	73 08                	jae    f0104464 <sprintputch+0x18>
		*b->buf++ = ch;
f010445c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010445f:	88 0a                	mov    %cl,(%edx)
f0104461:	42                   	inc    %edx
f0104462:	89 10                	mov    %edx,(%eax)
}
f0104464:	5d                   	pop    %ebp
f0104465:	c3                   	ret    

f0104466 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104466:	55                   	push   %ebp
f0104467:	89 e5                	mov    %esp,%ebp
f0104469:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010446c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010446f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104473:	8b 45 10             	mov    0x10(%ebp),%eax
f0104476:	89 44 24 08          	mov    %eax,0x8(%esp)
f010447a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010447d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104481:	8b 45 08             	mov    0x8(%ebp),%eax
f0104484:	89 04 24             	mov    %eax,(%esp)
f0104487:	e8 02 00 00 00       	call   f010448e <vprintfmt>
	va_end(ap);
}
f010448c:	c9                   	leave  
f010448d:	c3                   	ret    

f010448e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010448e:	55                   	push   %ebp
f010448f:	89 e5                	mov    %esp,%ebp
f0104491:	57                   	push   %edi
f0104492:	56                   	push   %esi
f0104493:	53                   	push   %ebx
f0104494:	83 ec 4c             	sub    $0x4c,%esp
f0104497:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010449a:	8b 75 10             	mov    0x10(%ebp),%esi
f010449d:	eb 12                	jmp    f01044b1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f010449f:	85 c0                	test   %eax,%eax
f01044a1:	0f 84 6b 03 00 00    	je     f0104812 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f01044a7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01044ab:	89 04 24             	mov    %eax,(%esp)
f01044ae:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01044b1:	0f b6 06             	movzbl (%esi),%eax
f01044b4:	46                   	inc    %esi
f01044b5:	83 f8 25             	cmp    $0x25,%eax
f01044b8:	75 e5                	jne    f010449f <vprintfmt+0x11>
f01044ba:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01044be:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01044c5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01044ca:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f01044d1:	b9 00 00 00 00       	mov    $0x0,%ecx
f01044d6:	eb 26                	jmp    f01044fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044d8:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f01044db:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f01044df:	eb 1d                	jmp    f01044fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044e1:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01044e4:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f01044e8:	eb 14                	jmp    f01044fe <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044ea:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01044ed:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01044f4:	eb 08                	jmp    f01044fe <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01044f6:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01044f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01044fe:	0f b6 06             	movzbl (%esi),%eax
f0104501:	8d 56 01             	lea    0x1(%esi),%edx
f0104504:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104507:	8a 16                	mov    (%esi),%dl
f0104509:	83 ea 23             	sub    $0x23,%edx
f010450c:	80 fa 55             	cmp    $0x55,%dl
f010450f:	0f 87 e1 02 00 00    	ja     f01047f6 <vprintfmt+0x368>
f0104515:	0f b6 d2             	movzbl %dl,%edx
f0104518:	ff 24 95 3c 65 10 f0 	jmp    *-0xfef9ac4(,%edx,4)
f010451f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104522:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104527:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010452a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010452e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0104531:	8d 50 d0             	lea    -0x30(%eax),%edx
f0104534:	83 fa 09             	cmp    $0x9,%edx
f0104537:	77 2a                	ja     f0104563 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104539:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010453a:	eb eb                	jmp    f0104527 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010453c:	8b 45 14             	mov    0x14(%ebp),%eax
f010453f:	8d 50 04             	lea    0x4(%eax),%edx
f0104542:	89 55 14             	mov    %edx,0x14(%ebp)
f0104545:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104547:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010454a:	eb 17                	jmp    f0104563 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f010454c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104550:	78 98                	js     f01044ea <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104552:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104555:	eb a7                	jmp    f01044fe <vprintfmt+0x70>
f0104557:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010455a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0104561:	eb 9b                	jmp    f01044fe <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0104563:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104567:	79 95                	jns    f01044fe <vprintfmt+0x70>
f0104569:	eb 8b                	jmp    f01044f6 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010456b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010456c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010456f:	eb 8d                	jmp    f01044fe <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104571:	8b 45 14             	mov    0x14(%ebp),%eax
f0104574:	8d 50 04             	lea    0x4(%eax),%edx
f0104577:	89 55 14             	mov    %edx,0x14(%ebp)
f010457a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010457e:	8b 00                	mov    (%eax),%eax
f0104580:	89 04 24             	mov    %eax,(%esp)
f0104583:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104586:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104589:	e9 23 ff ff ff       	jmp    f01044b1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f010458e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104591:	8d 50 04             	lea    0x4(%eax),%edx
f0104594:	89 55 14             	mov    %edx,0x14(%ebp)
f0104597:	8b 00                	mov    (%eax),%eax
f0104599:	85 c0                	test   %eax,%eax
f010459b:	79 02                	jns    f010459f <vprintfmt+0x111>
f010459d:	f7 d8                	neg    %eax
f010459f:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01045a1:	83 f8 06             	cmp    $0x6,%eax
f01045a4:	7f 0b                	jg     f01045b1 <vprintfmt+0x123>
f01045a6:	8b 04 85 94 66 10 f0 	mov    -0xfef996c(,%eax,4),%eax
f01045ad:	85 c0                	test   %eax,%eax
f01045af:	75 23                	jne    f01045d4 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01045b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01045b5:	c7 44 24 08 ca 64 10 	movl   $0xf01064ca,0x8(%esp)
f01045bc:	f0 
f01045bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045c1:	8b 45 08             	mov    0x8(%ebp),%eax
f01045c4:	89 04 24             	mov    %eax,(%esp)
f01045c7:	e8 9a fe ff ff       	call   f0104466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045cc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01045cf:	e9 dd fe ff ff       	jmp    f01044b1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f01045d4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01045d8:	c7 44 24 08 b4 5c 10 	movl   $0xf0105cb4,0x8(%esp)
f01045df:	f0 
f01045e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01045e4:	8b 55 08             	mov    0x8(%ebp),%edx
f01045e7:	89 14 24             	mov    %edx,(%esp)
f01045ea:	e8 77 fe ff ff       	call   f0104466 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01045ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01045f2:	e9 ba fe ff ff       	jmp    f01044b1 <vprintfmt+0x23>
f01045f7:	89 f9                	mov    %edi,%ecx
f01045f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01045fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01045ff:	8b 45 14             	mov    0x14(%ebp),%eax
f0104602:	8d 50 04             	lea    0x4(%eax),%edx
f0104605:	89 55 14             	mov    %edx,0x14(%ebp)
f0104608:	8b 30                	mov    (%eax),%esi
f010460a:	85 f6                	test   %esi,%esi
f010460c:	75 05                	jne    f0104613 <vprintfmt+0x185>
				p = "(null)";
f010460e:	be c3 64 10 f0       	mov    $0xf01064c3,%esi
			if (width > 0 && padc != '-')
f0104613:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0104617:	0f 8e 84 00 00 00    	jle    f01046a1 <vprintfmt+0x213>
f010461d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0104621:	74 7e                	je     f01046a1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104623:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104627:	89 34 24             	mov    %esi,(%esp)
f010462a:	e8 53 03 00 00       	call   f0104982 <strnlen>
f010462f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104632:	29 c2                	sub    %eax,%edx
f0104634:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0104637:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010463b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010463e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0104641:	89 de                	mov    %ebx,%esi
f0104643:	89 d3                	mov    %edx,%ebx
f0104645:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104647:	eb 0b                	jmp    f0104654 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0104649:	89 74 24 04          	mov    %esi,0x4(%esp)
f010464d:	89 3c 24             	mov    %edi,(%esp)
f0104650:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104653:	4b                   	dec    %ebx
f0104654:	85 db                	test   %ebx,%ebx
f0104656:	7f f1                	jg     f0104649 <vprintfmt+0x1bb>
f0104658:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010465b:	89 f3                	mov    %esi,%ebx
f010465d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0104660:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104663:	85 c0                	test   %eax,%eax
f0104665:	79 05                	jns    f010466c <vprintfmt+0x1de>
f0104667:	b8 00 00 00 00       	mov    $0x0,%eax
f010466c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010466f:	29 c2                	sub    %eax,%edx
f0104671:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104674:	eb 2b                	jmp    f01046a1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104676:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010467a:	74 18                	je     f0104694 <vprintfmt+0x206>
f010467c:	8d 50 e0             	lea    -0x20(%eax),%edx
f010467f:	83 fa 5e             	cmp    $0x5e,%edx
f0104682:	76 10                	jbe    f0104694 <vprintfmt+0x206>
					putch('?', putdat);
f0104684:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104688:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010468f:	ff 55 08             	call   *0x8(%ebp)
f0104692:	eb 0a                	jmp    f010469e <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0104694:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104698:	89 04 24             	mov    %eax,(%esp)
f010469b:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010469e:	ff 4d e4             	decl   -0x1c(%ebp)
f01046a1:	0f be 06             	movsbl (%esi),%eax
f01046a4:	46                   	inc    %esi
f01046a5:	85 c0                	test   %eax,%eax
f01046a7:	74 21                	je     f01046ca <vprintfmt+0x23c>
f01046a9:	85 ff                	test   %edi,%edi
f01046ab:	78 c9                	js     f0104676 <vprintfmt+0x1e8>
f01046ad:	4f                   	dec    %edi
f01046ae:	79 c6                	jns    f0104676 <vprintfmt+0x1e8>
f01046b0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01046b3:	89 de                	mov    %ebx,%esi
f01046b5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01046b8:	eb 18                	jmp    f01046d2 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01046ba:	89 74 24 04          	mov    %esi,0x4(%esp)
f01046be:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01046c5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01046c7:	4b                   	dec    %ebx
f01046c8:	eb 08                	jmp    f01046d2 <vprintfmt+0x244>
f01046ca:	8b 7d 08             	mov    0x8(%ebp),%edi
f01046cd:	89 de                	mov    %ebx,%esi
f01046cf:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01046d2:	85 db                	test   %ebx,%ebx
f01046d4:	7f e4                	jg     f01046ba <vprintfmt+0x22c>
f01046d6:	89 7d 08             	mov    %edi,0x8(%ebp)
f01046d9:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01046db:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01046de:	e9 ce fd ff ff       	jmp    f01044b1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01046e3:	83 f9 01             	cmp    $0x1,%ecx
f01046e6:	7e 10                	jle    f01046f8 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f01046e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01046eb:	8d 50 08             	lea    0x8(%eax),%edx
f01046ee:	89 55 14             	mov    %edx,0x14(%ebp)
f01046f1:	8b 30                	mov    (%eax),%esi
f01046f3:	8b 78 04             	mov    0x4(%eax),%edi
f01046f6:	eb 26                	jmp    f010471e <vprintfmt+0x290>
	else if (lflag)
f01046f8:	85 c9                	test   %ecx,%ecx
f01046fa:	74 12                	je     f010470e <vprintfmt+0x280>
		return va_arg(*ap, long);
f01046fc:	8b 45 14             	mov    0x14(%ebp),%eax
f01046ff:	8d 50 04             	lea    0x4(%eax),%edx
f0104702:	89 55 14             	mov    %edx,0x14(%ebp)
f0104705:	8b 30                	mov    (%eax),%esi
f0104707:	89 f7                	mov    %esi,%edi
f0104709:	c1 ff 1f             	sar    $0x1f,%edi
f010470c:	eb 10                	jmp    f010471e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010470e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104711:	8d 50 04             	lea    0x4(%eax),%edx
f0104714:	89 55 14             	mov    %edx,0x14(%ebp)
f0104717:	8b 30                	mov    (%eax),%esi
f0104719:	89 f7                	mov    %esi,%edi
f010471b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010471e:	85 ff                	test   %edi,%edi
f0104720:	78 0a                	js     f010472c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104722:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104727:	e9 8c 00 00 00       	jmp    f01047b8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010472c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104730:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0104737:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010473a:	f7 de                	neg    %esi
f010473c:	83 d7 00             	adc    $0x0,%edi
f010473f:	f7 df                	neg    %edi
			}
			base = 10;
f0104741:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104746:	eb 70                	jmp    f01047b8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104748:	89 ca                	mov    %ecx,%edx
f010474a:	8d 45 14             	lea    0x14(%ebp),%eax
f010474d:	e8 c0 fc ff ff       	call   f0104412 <getuint>
f0104752:	89 c6                	mov    %eax,%esi
f0104754:	89 d7                	mov    %edx,%edi
			base = 10;
f0104756:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010475b:	eb 5b                	jmp    f01047b8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010475d:	89 ca                	mov    %ecx,%edx
f010475f:	8d 45 14             	lea    0x14(%ebp),%eax
f0104762:	e8 ab fc ff ff       	call   f0104412 <getuint>
f0104767:	89 c6                	mov    %eax,%esi
f0104769:	89 d7                	mov    %edx,%edi
			base = 8;
f010476b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0104770:	eb 46                	jmp    f01047b8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f0104772:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104776:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010477d:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0104780:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0104784:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010478b:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010478e:	8b 45 14             	mov    0x14(%ebp),%eax
f0104791:	8d 50 04             	lea    0x4(%eax),%edx
f0104794:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0104797:	8b 30                	mov    (%eax),%esi
f0104799:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010479e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01047a3:	eb 13                	jmp    f01047b8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01047a5:	89 ca                	mov    %ecx,%edx
f01047a7:	8d 45 14             	lea    0x14(%ebp),%eax
f01047aa:	e8 63 fc ff ff       	call   f0104412 <getuint>
f01047af:	89 c6                	mov    %eax,%esi
f01047b1:	89 d7                	mov    %edx,%edi
			base = 16;
f01047b3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01047b8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01047bc:	89 54 24 10          	mov    %edx,0x10(%esp)
f01047c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01047c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01047c7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01047cb:	89 34 24             	mov    %esi,(%esp)
f01047ce:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01047d2:	89 da                	mov    %ebx,%edx
f01047d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01047d7:	e8 6c fb ff ff       	call   f0104348 <printnum>
			break;
f01047dc:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01047df:	e9 cd fc ff ff       	jmp    f01044b1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01047e4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047e8:	89 04 24             	mov    %eax,(%esp)
f01047eb:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01047ee:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01047f1:	e9 bb fc ff ff       	jmp    f01044b1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01047f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01047fa:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0104801:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104804:	eb 01                	jmp    f0104807 <vprintfmt+0x379>
f0104806:	4e                   	dec    %esi
f0104807:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010480b:	75 f9                	jne    f0104806 <vprintfmt+0x378>
f010480d:	e9 9f fc ff ff       	jmp    f01044b1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0104812:	83 c4 4c             	add    $0x4c,%esp
f0104815:	5b                   	pop    %ebx
f0104816:	5e                   	pop    %esi
f0104817:	5f                   	pop    %edi
f0104818:	5d                   	pop    %ebp
f0104819:	c3                   	ret    

f010481a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010481a:	55                   	push   %ebp
f010481b:	89 e5                	mov    %esp,%ebp
f010481d:	83 ec 28             	sub    $0x28,%esp
f0104820:	8b 45 08             	mov    0x8(%ebp),%eax
f0104823:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104826:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104829:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010482d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104830:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104837:	85 c0                	test   %eax,%eax
f0104839:	74 30                	je     f010486b <vsnprintf+0x51>
f010483b:	85 d2                	test   %edx,%edx
f010483d:	7e 33                	jle    f0104872 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010483f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104842:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104846:	8b 45 10             	mov    0x10(%ebp),%eax
f0104849:	89 44 24 08          	mov    %eax,0x8(%esp)
f010484d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104850:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104854:	c7 04 24 4c 44 10 f0 	movl   $0xf010444c,(%esp)
f010485b:	e8 2e fc ff ff       	call   f010448e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104860:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104863:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104866:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104869:	eb 0c                	jmp    f0104877 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010486b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104870:	eb 05                	jmp    f0104877 <vsnprintf+0x5d>
f0104872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104877:	c9                   	leave  
f0104878:	c3                   	ret    

f0104879 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104879:	55                   	push   %ebp
f010487a:	89 e5                	mov    %esp,%ebp
f010487c:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f010487f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104882:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104886:	8b 45 10             	mov    0x10(%ebp),%eax
f0104889:	89 44 24 08          	mov    %eax,0x8(%esp)
f010488d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104890:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104894:	8b 45 08             	mov    0x8(%ebp),%eax
f0104897:	89 04 24             	mov    %eax,(%esp)
f010489a:	e8 7b ff ff ff       	call   f010481a <vsnprintf>
	va_end(ap);

	return rc;
}
f010489f:	c9                   	leave  
f01048a0:	c3                   	ret    
f01048a1:	00 00                	add    %al,(%eax)
	...

f01048a4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01048a4:	55                   	push   %ebp
f01048a5:	89 e5                	mov    %esp,%ebp
f01048a7:	57                   	push   %edi
f01048a8:	56                   	push   %esi
f01048a9:	53                   	push   %ebx
f01048aa:	83 ec 1c             	sub    $0x1c,%esp
f01048ad:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01048b0:	85 c0                	test   %eax,%eax
f01048b2:	74 10                	je     f01048c4 <readline+0x20>
		cprintf("%s", prompt);
f01048b4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048b8:	c7 04 24 b4 5c 10 f0 	movl   $0xf0105cb4,(%esp)
f01048bf:	e8 e2 ed ff ff       	call   f01036a6 <cprintf>

	i = 0;
	echoing = iscons(0);
f01048c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048cb:	e8 29 bd ff ff       	call   f01005f9 <iscons>
f01048d0:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f01048d2:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f01048d7:	e8 0c bd ff ff       	call   f01005e8 <getchar>
f01048dc:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f01048de:	85 c0                	test   %eax,%eax
f01048e0:	79 17                	jns    f01048f9 <readline+0x55>
			cprintf("read error: %e\n", c);
f01048e2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01048e6:	c7 04 24 b0 66 10 f0 	movl   $0xf01066b0,(%esp)
f01048ed:	e8 b4 ed ff ff       	call   f01036a6 <cprintf>
			return NULL;
f01048f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01048f7:	eb 69                	jmp    f0104962 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01048f9:	83 f8 08             	cmp    $0x8,%eax
f01048fc:	74 05                	je     f0104903 <readline+0x5f>
f01048fe:	83 f8 7f             	cmp    $0x7f,%eax
f0104901:	75 17                	jne    f010491a <readline+0x76>
f0104903:	85 f6                	test   %esi,%esi
f0104905:	7e 13                	jle    f010491a <readline+0x76>
			if (echoing)
f0104907:	85 ff                	test   %edi,%edi
f0104909:	74 0c                	je     f0104917 <readline+0x73>
				cputchar('\b');
f010490b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0104912:	e8 c1 bc ff ff       	call   f01005d8 <cputchar>
			i--;
f0104917:	4e                   	dec    %esi
f0104918:	eb bd                	jmp    f01048d7 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010491a:	83 fb 1f             	cmp    $0x1f,%ebx
f010491d:	7e 1d                	jle    f010493c <readline+0x98>
f010491f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104925:	7f 15                	jg     f010493c <readline+0x98>
			if (echoing)
f0104927:	85 ff                	test   %edi,%edi
f0104929:	74 08                	je     f0104933 <readline+0x8f>
				cputchar(c);
f010492b:	89 1c 24             	mov    %ebx,(%esp)
f010492e:	e8 a5 bc ff ff       	call   f01005d8 <cputchar>
			buf[i++] = c;
f0104933:	88 9e 40 3a 1e f0    	mov    %bl,-0xfe1c5c0(%esi)
f0104939:	46                   	inc    %esi
f010493a:	eb 9b                	jmp    f01048d7 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010493c:	83 fb 0a             	cmp    $0xa,%ebx
f010493f:	74 05                	je     f0104946 <readline+0xa2>
f0104941:	83 fb 0d             	cmp    $0xd,%ebx
f0104944:	75 91                	jne    f01048d7 <readline+0x33>
			if (echoing)
f0104946:	85 ff                	test   %edi,%edi
f0104948:	74 0c                	je     f0104956 <readline+0xb2>
				cputchar('\n');
f010494a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0104951:	e8 82 bc ff ff       	call   f01005d8 <cputchar>
			buf[i] = 0;
f0104956:	c6 86 40 3a 1e f0 00 	movb   $0x0,-0xfe1c5c0(%esi)
			return buf;
f010495d:	b8 40 3a 1e f0       	mov    $0xf01e3a40,%eax
		}
	}
}
f0104962:	83 c4 1c             	add    $0x1c,%esp
f0104965:	5b                   	pop    %ebx
f0104966:	5e                   	pop    %esi
f0104967:	5f                   	pop    %edi
f0104968:	5d                   	pop    %ebp
f0104969:	c3                   	ret    
	...

f010496c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010496c:	55                   	push   %ebp
f010496d:	89 e5                	mov    %esp,%ebp
f010496f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104972:	b8 00 00 00 00       	mov    $0x0,%eax
f0104977:	eb 01                	jmp    f010497a <strlen+0xe>
		n++;
f0104979:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010497a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010497e:	75 f9                	jne    f0104979 <strlen+0xd>
		n++;
	return n;
}
f0104980:	5d                   	pop    %ebp
f0104981:	c3                   	ret    

f0104982 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104982:	55                   	push   %ebp
f0104983:	89 e5                	mov    %esp,%ebp
f0104985:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f0104988:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010498b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104990:	eb 01                	jmp    f0104993 <strnlen+0x11>
		n++;
f0104992:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104993:	39 d0                	cmp    %edx,%eax
f0104995:	74 06                	je     f010499d <strnlen+0x1b>
f0104997:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010499b:	75 f5                	jne    f0104992 <strnlen+0x10>
		n++;
	return n;
}
f010499d:	5d                   	pop    %ebp
f010499e:	c3                   	ret    

f010499f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010499f:	55                   	push   %ebp
f01049a0:	89 e5                	mov    %esp,%ebp
f01049a2:	53                   	push   %ebx
f01049a3:	8b 45 08             	mov    0x8(%ebp),%eax
f01049a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01049a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01049ae:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01049b1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01049b4:	42                   	inc    %edx
f01049b5:	84 c9                	test   %cl,%cl
f01049b7:	75 f5                	jne    f01049ae <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01049b9:	5b                   	pop    %ebx
f01049ba:	5d                   	pop    %ebp
f01049bb:	c3                   	ret    

f01049bc <strcat>:

char *
strcat(char *dst, const char *src)
{
f01049bc:	55                   	push   %ebp
f01049bd:	89 e5                	mov    %esp,%ebp
f01049bf:	53                   	push   %ebx
f01049c0:	83 ec 08             	sub    $0x8,%esp
f01049c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01049c6:	89 1c 24             	mov    %ebx,(%esp)
f01049c9:	e8 9e ff ff ff       	call   f010496c <strlen>
	strcpy(dst + len, src);
f01049ce:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049d1:	89 54 24 04          	mov    %edx,0x4(%esp)
f01049d5:	01 d8                	add    %ebx,%eax
f01049d7:	89 04 24             	mov    %eax,(%esp)
f01049da:	e8 c0 ff ff ff       	call   f010499f <strcpy>
	return dst;
}
f01049df:	89 d8                	mov    %ebx,%eax
f01049e1:	83 c4 08             	add    $0x8,%esp
f01049e4:	5b                   	pop    %ebx
f01049e5:	5d                   	pop    %ebp
f01049e6:	c3                   	ret    

f01049e7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01049e7:	55                   	push   %ebp
f01049e8:	89 e5                	mov    %esp,%ebp
f01049ea:	56                   	push   %esi
f01049eb:	53                   	push   %ebx
f01049ec:	8b 45 08             	mov    0x8(%ebp),%eax
f01049ef:	8b 55 0c             	mov    0xc(%ebp),%edx
f01049f2:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01049f5:	b9 00 00 00 00       	mov    $0x0,%ecx
f01049fa:	eb 0c                	jmp    f0104a08 <strncpy+0x21>
		*dst++ = *src;
f01049fc:	8a 1a                	mov    (%edx),%bl
f01049fe:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0104a01:	80 3a 01             	cmpb   $0x1,(%edx)
f0104a04:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0104a07:	41                   	inc    %ecx
f0104a08:	39 f1                	cmp    %esi,%ecx
f0104a0a:	75 f0                	jne    f01049fc <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0104a0c:	5b                   	pop    %ebx
f0104a0d:	5e                   	pop    %esi
f0104a0e:	5d                   	pop    %ebp
f0104a0f:	c3                   	ret    

f0104a10 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0104a10:	55                   	push   %ebp
f0104a11:	89 e5                	mov    %esp,%ebp
f0104a13:	56                   	push   %esi
f0104a14:	53                   	push   %ebx
f0104a15:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a1b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104a1e:	85 d2                	test   %edx,%edx
f0104a20:	75 0a                	jne    f0104a2c <strlcpy+0x1c>
f0104a22:	89 f0                	mov    %esi,%eax
f0104a24:	eb 1a                	jmp    f0104a40 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0104a26:	88 18                	mov    %bl,(%eax)
f0104a28:	40                   	inc    %eax
f0104a29:	41                   	inc    %ecx
f0104a2a:	eb 02                	jmp    f0104a2e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0104a2c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0104a2e:	4a                   	dec    %edx
f0104a2f:	74 0a                	je     f0104a3b <strlcpy+0x2b>
f0104a31:	8a 19                	mov    (%ecx),%bl
f0104a33:	84 db                	test   %bl,%bl
f0104a35:	75 ef                	jne    f0104a26 <strlcpy+0x16>
f0104a37:	89 c2                	mov    %eax,%edx
f0104a39:	eb 02                	jmp    f0104a3d <strlcpy+0x2d>
f0104a3b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0104a3d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0104a40:	29 f0                	sub    %esi,%eax
}
f0104a42:	5b                   	pop    %ebx
f0104a43:	5e                   	pop    %esi
f0104a44:	5d                   	pop    %ebp
f0104a45:	c3                   	ret    

f0104a46 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104a46:	55                   	push   %ebp
f0104a47:	89 e5                	mov    %esp,%ebp
f0104a49:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104a4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104a4f:	eb 02                	jmp    f0104a53 <strcmp+0xd>
		p++, q++;
f0104a51:	41                   	inc    %ecx
f0104a52:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104a53:	8a 01                	mov    (%ecx),%al
f0104a55:	84 c0                	test   %al,%al
f0104a57:	74 04                	je     f0104a5d <strcmp+0x17>
f0104a59:	3a 02                	cmp    (%edx),%al
f0104a5b:	74 f4                	je     f0104a51 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a5d:	0f b6 c0             	movzbl %al,%eax
f0104a60:	0f b6 12             	movzbl (%edx),%edx
f0104a63:	29 d0                	sub    %edx,%eax
}
f0104a65:	5d                   	pop    %ebp
f0104a66:	c3                   	ret    

f0104a67 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104a67:	55                   	push   %ebp
f0104a68:	89 e5                	mov    %esp,%ebp
f0104a6a:	53                   	push   %ebx
f0104a6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0104a71:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0104a74:	eb 03                	jmp    f0104a79 <strncmp+0x12>
		n--, p++, q++;
f0104a76:	4a                   	dec    %edx
f0104a77:	40                   	inc    %eax
f0104a78:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0104a79:	85 d2                	test   %edx,%edx
f0104a7b:	74 14                	je     f0104a91 <strncmp+0x2a>
f0104a7d:	8a 18                	mov    (%eax),%bl
f0104a7f:	84 db                	test   %bl,%bl
f0104a81:	74 04                	je     f0104a87 <strncmp+0x20>
f0104a83:	3a 19                	cmp    (%ecx),%bl
f0104a85:	74 ef                	je     f0104a76 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0104a87:	0f b6 00             	movzbl (%eax),%eax
f0104a8a:	0f b6 11             	movzbl (%ecx),%edx
f0104a8d:	29 d0                	sub    %edx,%eax
f0104a8f:	eb 05                	jmp    f0104a96 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104a91:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0104a96:	5b                   	pop    %ebx
f0104a97:	5d                   	pop    %ebp
f0104a98:	c3                   	ret    

f0104a99 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0104a99:	55                   	push   %ebp
f0104a9a:	89 e5                	mov    %esp,%ebp
f0104a9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a9f:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104aa2:	eb 05                	jmp    f0104aa9 <strchr+0x10>
		if (*s == c)
f0104aa4:	38 ca                	cmp    %cl,%dl
f0104aa6:	74 0c                	je     f0104ab4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0104aa8:	40                   	inc    %eax
f0104aa9:	8a 10                	mov    (%eax),%dl
f0104aab:	84 d2                	test   %dl,%dl
f0104aad:	75 f5                	jne    f0104aa4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0104aaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104ab4:	5d                   	pop    %ebp
f0104ab5:	c3                   	ret    

f0104ab6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0104ab6:	55                   	push   %ebp
f0104ab7:	89 e5                	mov    %esp,%ebp
f0104ab9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104abc:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0104abf:	eb 05                	jmp    f0104ac6 <strfind+0x10>
		if (*s == c)
f0104ac1:	38 ca                	cmp    %cl,%dl
f0104ac3:	74 07                	je     f0104acc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0104ac5:	40                   	inc    %eax
f0104ac6:	8a 10                	mov    (%eax),%dl
f0104ac8:	84 d2                	test   %dl,%dl
f0104aca:	75 f5                	jne    f0104ac1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0104acc:	5d                   	pop    %ebp
f0104acd:	c3                   	ret    

f0104ace <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0104ace:	55                   	push   %ebp
f0104acf:	89 e5                	mov    %esp,%ebp
f0104ad1:	57                   	push   %edi
f0104ad2:	56                   	push   %esi
f0104ad3:	53                   	push   %ebx
f0104ad4:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104ada:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0104add:	85 c9                	test   %ecx,%ecx
f0104adf:	74 30                	je     f0104b11 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0104ae1:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104ae7:	75 25                	jne    f0104b0e <memset+0x40>
f0104ae9:	f6 c1 03             	test   $0x3,%cl
f0104aec:	75 20                	jne    f0104b0e <memset+0x40>
		c &= 0xFF;
f0104aee:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0104af1:	89 d3                	mov    %edx,%ebx
f0104af3:	c1 e3 08             	shl    $0x8,%ebx
f0104af6:	89 d6                	mov    %edx,%esi
f0104af8:	c1 e6 18             	shl    $0x18,%esi
f0104afb:	89 d0                	mov    %edx,%eax
f0104afd:	c1 e0 10             	shl    $0x10,%eax
f0104b00:	09 f0                	or     %esi,%eax
f0104b02:	09 d0                	or     %edx,%eax
f0104b04:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0104b06:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0104b09:	fc                   	cld    
f0104b0a:	f3 ab                	rep stos %eax,%es:(%edi)
f0104b0c:	eb 03                	jmp    f0104b11 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0104b0e:	fc                   	cld    
f0104b0f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0104b11:	89 f8                	mov    %edi,%eax
f0104b13:	5b                   	pop    %ebx
f0104b14:	5e                   	pop    %esi
f0104b15:	5f                   	pop    %edi
f0104b16:	5d                   	pop    %ebp
f0104b17:	c3                   	ret    

f0104b18 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0104b18:	55                   	push   %ebp
f0104b19:	89 e5                	mov    %esp,%ebp
f0104b1b:	57                   	push   %edi
f0104b1c:	56                   	push   %esi
f0104b1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b20:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104b23:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104b26:	39 c6                	cmp    %eax,%esi
f0104b28:	73 34                	jae    f0104b5e <memmove+0x46>
f0104b2a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0104b2d:	39 d0                	cmp    %edx,%eax
f0104b2f:	73 2d                	jae    f0104b5e <memmove+0x46>
		s += n;
		d += n;
f0104b31:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b34:	f6 c2 03             	test   $0x3,%dl
f0104b37:	75 1b                	jne    f0104b54 <memmove+0x3c>
f0104b39:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0104b3f:	75 13                	jne    f0104b54 <memmove+0x3c>
f0104b41:	f6 c1 03             	test   $0x3,%cl
f0104b44:	75 0e                	jne    f0104b54 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0104b46:	83 ef 04             	sub    $0x4,%edi
f0104b49:	8d 72 fc             	lea    -0x4(%edx),%esi
f0104b4c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0104b4f:	fd                   	std    
f0104b50:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b52:	eb 07                	jmp    f0104b5b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0104b54:	4f                   	dec    %edi
f0104b55:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104b58:	fd                   	std    
f0104b59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0104b5b:	fc                   	cld    
f0104b5c:	eb 20                	jmp    f0104b7e <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104b5e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0104b64:	75 13                	jne    f0104b79 <memmove+0x61>
f0104b66:	a8 03                	test   $0x3,%al
f0104b68:	75 0f                	jne    f0104b79 <memmove+0x61>
f0104b6a:	f6 c1 03             	test   $0x3,%cl
f0104b6d:	75 0a                	jne    f0104b79 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0104b6f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0104b72:	89 c7                	mov    %eax,%edi
f0104b74:	fc                   	cld    
f0104b75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104b77:	eb 05                	jmp    f0104b7e <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104b79:	89 c7                	mov    %eax,%edi
f0104b7b:	fc                   	cld    
f0104b7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0104b7e:	5e                   	pop    %esi
f0104b7f:	5f                   	pop    %edi
f0104b80:	5d                   	pop    %ebp
f0104b81:	c3                   	ret    

f0104b82 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104b82:	55                   	push   %ebp
f0104b83:	89 e5                	mov    %esp,%ebp
f0104b85:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0104b88:	8b 45 10             	mov    0x10(%ebp),%eax
f0104b8b:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104b8f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0104b92:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104b96:	8b 45 08             	mov    0x8(%ebp),%eax
f0104b99:	89 04 24             	mov    %eax,(%esp)
f0104b9c:	e8 77 ff ff ff       	call   f0104b18 <memmove>
}
f0104ba1:	c9                   	leave  
f0104ba2:	c3                   	ret    

f0104ba3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104ba3:	55                   	push   %ebp
f0104ba4:	89 e5                	mov    %esp,%ebp
f0104ba6:	57                   	push   %edi
f0104ba7:	56                   	push   %esi
f0104ba8:	53                   	push   %ebx
f0104ba9:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104bac:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104bb2:	ba 00 00 00 00       	mov    $0x0,%edx
f0104bb7:	eb 16                	jmp    f0104bcf <memcmp+0x2c>
		if (*s1 != *s2)
f0104bb9:	8a 04 17             	mov    (%edi,%edx,1),%al
f0104bbc:	42                   	inc    %edx
f0104bbd:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0104bc1:	38 c8                	cmp    %cl,%al
f0104bc3:	74 0a                	je     f0104bcf <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0104bc5:	0f b6 c0             	movzbl %al,%eax
f0104bc8:	0f b6 c9             	movzbl %cl,%ecx
f0104bcb:	29 c8                	sub    %ecx,%eax
f0104bcd:	eb 09                	jmp    f0104bd8 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104bcf:	39 da                	cmp    %ebx,%edx
f0104bd1:	75 e6                	jne    f0104bb9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0104bd3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bd8:	5b                   	pop    %ebx
f0104bd9:	5e                   	pop    %esi
f0104bda:	5f                   	pop    %edi
f0104bdb:	5d                   	pop    %ebp
f0104bdc:	c3                   	ret    

f0104bdd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0104bdd:	55                   	push   %ebp
f0104bde:	89 e5                	mov    %esp,%ebp
f0104be0:	8b 45 08             	mov    0x8(%ebp),%eax
f0104be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0104be6:	89 c2                	mov    %eax,%edx
f0104be8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0104beb:	eb 05                	jmp    f0104bf2 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0104bed:	38 08                	cmp    %cl,(%eax)
f0104bef:	74 05                	je     f0104bf6 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0104bf1:	40                   	inc    %eax
f0104bf2:	39 d0                	cmp    %edx,%eax
f0104bf4:	72 f7                	jb     f0104bed <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104bf6:	5d                   	pop    %ebp
f0104bf7:	c3                   	ret    

f0104bf8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104bf8:	55                   	push   %ebp
f0104bf9:	89 e5                	mov    %esp,%ebp
f0104bfb:	57                   	push   %edi
f0104bfc:	56                   	push   %esi
f0104bfd:	53                   	push   %ebx
f0104bfe:	8b 55 08             	mov    0x8(%ebp),%edx
f0104c01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104c04:	eb 01                	jmp    f0104c07 <strtol+0xf>
		s++;
f0104c06:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0104c07:	8a 02                	mov    (%edx),%al
f0104c09:	3c 20                	cmp    $0x20,%al
f0104c0b:	74 f9                	je     f0104c06 <strtol+0xe>
f0104c0d:	3c 09                	cmp    $0x9,%al
f0104c0f:	74 f5                	je     f0104c06 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0104c11:	3c 2b                	cmp    $0x2b,%al
f0104c13:	75 08                	jne    f0104c1d <strtol+0x25>
		s++;
f0104c15:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104c16:	bf 00 00 00 00       	mov    $0x0,%edi
f0104c1b:	eb 13                	jmp    f0104c30 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0104c1d:	3c 2d                	cmp    $0x2d,%al
f0104c1f:	75 0a                	jne    f0104c2b <strtol+0x33>
		s++, neg = 1;
f0104c21:	8d 52 01             	lea    0x1(%edx),%edx
f0104c24:	bf 01 00 00 00       	mov    $0x1,%edi
f0104c29:	eb 05                	jmp    f0104c30 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104c2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0104c30:	85 db                	test   %ebx,%ebx
f0104c32:	74 05                	je     f0104c39 <strtol+0x41>
f0104c34:	83 fb 10             	cmp    $0x10,%ebx
f0104c37:	75 28                	jne    f0104c61 <strtol+0x69>
f0104c39:	8a 02                	mov    (%edx),%al
f0104c3b:	3c 30                	cmp    $0x30,%al
f0104c3d:	75 10                	jne    f0104c4f <strtol+0x57>
f0104c3f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0104c43:	75 0a                	jne    f0104c4f <strtol+0x57>
		s += 2, base = 16;
f0104c45:	83 c2 02             	add    $0x2,%edx
f0104c48:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104c4d:	eb 12                	jmp    f0104c61 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0104c4f:	85 db                	test   %ebx,%ebx
f0104c51:	75 0e                	jne    f0104c61 <strtol+0x69>
f0104c53:	3c 30                	cmp    $0x30,%al
f0104c55:	75 05                	jne    f0104c5c <strtol+0x64>
		s++, base = 8;
f0104c57:	42                   	inc    %edx
f0104c58:	b3 08                	mov    $0x8,%bl
f0104c5a:	eb 05                	jmp    f0104c61 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0104c5c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0104c61:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104c68:	8a 0a                	mov    (%edx),%cl
f0104c6a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0104c6d:	80 fb 09             	cmp    $0x9,%bl
f0104c70:	77 08                	ja     f0104c7a <strtol+0x82>
			dig = *s - '0';
f0104c72:	0f be c9             	movsbl %cl,%ecx
f0104c75:	83 e9 30             	sub    $0x30,%ecx
f0104c78:	eb 1e                	jmp    f0104c98 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f0104c7a:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0104c7d:	80 fb 19             	cmp    $0x19,%bl
f0104c80:	77 08                	ja     f0104c8a <strtol+0x92>
			dig = *s - 'a' + 10;
f0104c82:	0f be c9             	movsbl %cl,%ecx
f0104c85:	83 e9 57             	sub    $0x57,%ecx
f0104c88:	eb 0e                	jmp    f0104c98 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f0104c8a:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0104c8d:	80 fb 19             	cmp    $0x19,%bl
f0104c90:	77 12                	ja     f0104ca4 <strtol+0xac>
			dig = *s - 'A' + 10;
f0104c92:	0f be c9             	movsbl %cl,%ecx
f0104c95:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f0104c98:	39 f1                	cmp    %esi,%ecx
f0104c9a:	7d 0c                	jge    f0104ca8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0104c9c:	42                   	inc    %edx
f0104c9d:	0f af c6             	imul   %esi,%eax
f0104ca0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0104ca2:	eb c4                	jmp    f0104c68 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0104ca4:	89 c1                	mov    %eax,%ecx
f0104ca6:	eb 02                	jmp    f0104caa <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0104ca8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f0104caa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104cae:	74 05                	je     f0104cb5 <strtol+0xbd>
		*endptr = (char *) s;
f0104cb0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cb3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0104cb5:	85 ff                	test   %edi,%edi
f0104cb7:	74 04                	je     f0104cbd <strtol+0xc5>
f0104cb9:	89 c8                	mov    %ecx,%eax
f0104cbb:	f7 d8                	neg    %eax
}
f0104cbd:	5b                   	pop    %ebx
f0104cbe:	5e                   	pop    %esi
f0104cbf:	5f                   	pop    %edi
f0104cc0:	5d                   	pop    %ebp
f0104cc1:	c3                   	ret    
	...

f0104cc4 <__udivdi3>:
f0104cc4:	55                   	push   %ebp
f0104cc5:	57                   	push   %edi
f0104cc6:	56                   	push   %esi
f0104cc7:	83 ec 10             	sub    $0x10,%esp
f0104cca:	8b 74 24 20          	mov    0x20(%esp),%esi
f0104cce:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0104cd2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104cd6:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0104cda:	89 cd                	mov    %ecx,%ebp
f0104cdc:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0104ce0:	85 c0                	test   %eax,%eax
f0104ce2:	75 2c                	jne    f0104d10 <__udivdi3+0x4c>
f0104ce4:	39 f9                	cmp    %edi,%ecx
f0104ce6:	77 68                	ja     f0104d50 <__udivdi3+0x8c>
f0104ce8:	85 c9                	test   %ecx,%ecx
f0104cea:	75 0b                	jne    f0104cf7 <__udivdi3+0x33>
f0104cec:	b8 01 00 00 00       	mov    $0x1,%eax
f0104cf1:	31 d2                	xor    %edx,%edx
f0104cf3:	f7 f1                	div    %ecx
f0104cf5:	89 c1                	mov    %eax,%ecx
f0104cf7:	31 d2                	xor    %edx,%edx
f0104cf9:	89 f8                	mov    %edi,%eax
f0104cfb:	f7 f1                	div    %ecx
f0104cfd:	89 c7                	mov    %eax,%edi
f0104cff:	89 f0                	mov    %esi,%eax
f0104d01:	f7 f1                	div    %ecx
f0104d03:	89 c6                	mov    %eax,%esi
f0104d05:	89 f0                	mov    %esi,%eax
f0104d07:	89 fa                	mov    %edi,%edx
f0104d09:	83 c4 10             	add    $0x10,%esp
f0104d0c:	5e                   	pop    %esi
f0104d0d:	5f                   	pop    %edi
f0104d0e:	5d                   	pop    %ebp
f0104d0f:	c3                   	ret    
f0104d10:	39 f8                	cmp    %edi,%eax
f0104d12:	77 2c                	ja     f0104d40 <__udivdi3+0x7c>
f0104d14:	0f bd f0             	bsr    %eax,%esi
f0104d17:	83 f6 1f             	xor    $0x1f,%esi
f0104d1a:	75 4c                	jne    f0104d68 <__udivdi3+0xa4>
f0104d1c:	39 f8                	cmp    %edi,%eax
f0104d1e:	bf 00 00 00 00       	mov    $0x0,%edi
f0104d23:	72 0a                	jb     f0104d2f <__udivdi3+0x6b>
f0104d25:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0104d29:	0f 87 ad 00 00 00    	ja     f0104ddc <__udivdi3+0x118>
f0104d2f:	be 01 00 00 00       	mov    $0x1,%esi
f0104d34:	89 f0                	mov    %esi,%eax
f0104d36:	89 fa                	mov    %edi,%edx
f0104d38:	83 c4 10             	add    $0x10,%esp
f0104d3b:	5e                   	pop    %esi
f0104d3c:	5f                   	pop    %edi
f0104d3d:	5d                   	pop    %ebp
f0104d3e:	c3                   	ret    
f0104d3f:	90                   	nop
f0104d40:	31 ff                	xor    %edi,%edi
f0104d42:	31 f6                	xor    %esi,%esi
f0104d44:	89 f0                	mov    %esi,%eax
f0104d46:	89 fa                	mov    %edi,%edx
f0104d48:	83 c4 10             	add    $0x10,%esp
f0104d4b:	5e                   	pop    %esi
f0104d4c:	5f                   	pop    %edi
f0104d4d:	5d                   	pop    %ebp
f0104d4e:	c3                   	ret    
f0104d4f:	90                   	nop
f0104d50:	89 fa                	mov    %edi,%edx
f0104d52:	89 f0                	mov    %esi,%eax
f0104d54:	f7 f1                	div    %ecx
f0104d56:	89 c6                	mov    %eax,%esi
f0104d58:	31 ff                	xor    %edi,%edi
f0104d5a:	89 f0                	mov    %esi,%eax
f0104d5c:	89 fa                	mov    %edi,%edx
f0104d5e:	83 c4 10             	add    $0x10,%esp
f0104d61:	5e                   	pop    %esi
f0104d62:	5f                   	pop    %edi
f0104d63:	5d                   	pop    %ebp
f0104d64:	c3                   	ret    
f0104d65:	8d 76 00             	lea    0x0(%esi),%esi
f0104d68:	89 f1                	mov    %esi,%ecx
f0104d6a:	d3 e0                	shl    %cl,%eax
f0104d6c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104d70:	b8 20 00 00 00       	mov    $0x20,%eax
f0104d75:	29 f0                	sub    %esi,%eax
f0104d77:	89 ea                	mov    %ebp,%edx
f0104d79:	88 c1                	mov    %al,%cl
f0104d7b:	d3 ea                	shr    %cl,%edx
f0104d7d:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0104d81:	09 ca                	or     %ecx,%edx
f0104d83:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104d87:	89 f1                	mov    %esi,%ecx
f0104d89:	d3 e5                	shl    %cl,%ebp
f0104d8b:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0104d8f:	89 fd                	mov    %edi,%ebp
f0104d91:	88 c1                	mov    %al,%cl
f0104d93:	d3 ed                	shr    %cl,%ebp
f0104d95:	89 fa                	mov    %edi,%edx
f0104d97:	89 f1                	mov    %esi,%ecx
f0104d99:	d3 e2                	shl    %cl,%edx
f0104d9b:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0104d9f:	88 c1                	mov    %al,%cl
f0104da1:	d3 ef                	shr    %cl,%edi
f0104da3:	09 d7                	or     %edx,%edi
f0104da5:	89 f8                	mov    %edi,%eax
f0104da7:	89 ea                	mov    %ebp,%edx
f0104da9:	f7 74 24 08          	divl   0x8(%esp)
f0104dad:	89 d1                	mov    %edx,%ecx
f0104daf:	89 c7                	mov    %eax,%edi
f0104db1:	f7 64 24 0c          	mull   0xc(%esp)
f0104db5:	39 d1                	cmp    %edx,%ecx
f0104db7:	72 17                	jb     f0104dd0 <__udivdi3+0x10c>
f0104db9:	74 09                	je     f0104dc4 <__udivdi3+0x100>
f0104dbb:	89 fe                	mov    %edi,%esi
f0104dbd:	31 ff                	xor    %edi,%edi
f0104dbf:	e9 41 ff ff ff       	jmp    f0104d05 <__udivdi3+0x41>
f0104dc4:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104dc8:	89 f1                	mov    %esi,%ecx
f0104dca:	d3 e2                	shl    %cl,%edx
f0104dcc:	39 c2                	cmp    %eax,%edx
f0104dce:	73 eb                	jae    f0104dbb <__udivdi3+0xf7>
f0104dd0:	8d 77 ff             	lea    -0x1(%edi),%esi
f0104dd3:	31 ff                	xor    %edi,%edi
f0104dd5:	e9 2b ff ff ff       	jmp    f0104d05 <__udivdi3+0x41>
f0104dda:	66 90                	xchg   %ax,%ax
f0104ddc:	31 f6                	xor    %esi,%esi
f0104dde:	e9 22 ff ff ff       	jmp    f0104d05 <__udivdi3+0x41>
	...

f0104de4 <__umoddi3>:
f0104de4:	55                   	push   %ebp
f0104de5:	57                   	push   %edi
f0104de6:	56                   	push   %esi
f0104de7:	83 ec 20             	sub    $0x20,%esp
f0104dea:	8b 44 24 30          	mov    0x30(%esp),%eax
f0104dee:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0104df2:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104df6:	8b 74 24 34          	mov    0x34(%esp),%esi
f0104dfa:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0104dfe:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0104e02:	89 c7                	mov    %eax,%edi
f0104e04:	89 f2                	mov    %esi,%edx
f0104e06:	85 ed                	test   %ebp,%ebp
f0104e08:	75 16                	jne    f0104e20 <__umoddi3+0x3c>
f0104e0a:	39 f1                	cmp    %esi,%ecx
f0104e0c:	0f 86 a6 00 00 00    	jbe    f0104eb8 <__umoddi3+0xd4>
f0104e12:	f7 f1                	div    %ecx
f0104e14:	89 d0                	mov    %edx,%eax
f0104e16:	31 d2                	xor    %edx,%edx
f0104e18:	83 c4 20             	add    $0x20,%esp
f0104e1b:	5e                   	pop    %esi
f0104e1c:	5f                   	pop    %edi
f0104e1d:	5d                   	pop    %ebp
f0104e1e:	c3                   	ret    
f0104e1f:	90                   	nop
f0104e20:	39 f5                	cmp    %esi,%ebp
f0104e22:	0f 87 ac 00 00 00    	ja     f0104ed4 <__umoddi3+0xf0>
f0104e28:	0f bd c5             	bsr    %ebp,%eax
f0104e2b:	83 f0 1f             	xor    $0x1f,%eax
f0104e2e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0104e32:	0f 84 a8 00 00 00    	je     f0104ee0 <__umoddi3+0xfc>
f0104e38:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104e3c:	d3 e5                	shl    %cl,%ebp
f0104e3e:	bf 20 00 00 00       	mov    $0x20,%edi
f0104e43:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0104e47:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104e4b:	89 f9                	mov    %edi,%ecx
f0104e4d:	d3 e8                	shr    %cl,%eax
f0104e4f:	09 e8                	or     %ebp,%eax
f0104e51:	89 44 24 18          	mov    %eax,0x18(%esp)
f0104e55:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0104e59:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104e5d:	d3 e0                	shl    %cl,%eax
f0104e5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104e63:	89 f2                	mov    %esi,%edx
f0104e65:	d3 e2                	shl    %cl,%edx
f0104e67:	8b 44 24 14          	mov    0x14(%esp),%eax
f0104e6b:	d3 e0                	shl    %cl,%eax
f0104e6d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0104e71:	8b 44 24 14          	mov    0x14(%esp),%eax
f0104e75:	89 f9                	mov    %edi,%ecx
f0104e77:	d3 e8                	shr    %cl,%eax
f0104e79:	09 d0                	or     %edx,%eax
f0104e7b:	d3 ee                	shr    %cl,%esi
f0104e7d:	89 f2                	mov    %esi,%edx
f0104e7f:	f7 74 24 18          	divl   0x18(%esp)
f0104e83:	89 d6                	mov    %edx,%esi
f0104e85:	f7 64 24 0c          	mull   0xc(%esp)
f0104e89:	89 c5                	mov    %eax,%ebp
f0104e8b:	89 d1                	mov    %edx,%ecx
f0104e8d:	39 d6                	cmp    %edx,%esi
f0104e8f:	72 67                	jb     f0104ef8 <__umoddi3+0x114>
f0104e91:	74 75                	je     f0104f08 <__umoddi3+0x124>
f0104e93:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0104e97:	29 e8                	sub    %ebp,%eax
f0104e99:	19 ce                	sbb    %ecx,%esi
f0104e9b:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104e9f:	d3 e8                	shr    %cl,%eax
f0104ea1:	89 f2                	mov    %esi,%edx
f0104ea3:	89 f9                	mov    %edi,%ecx
f0104ea5:	d3 e2                	shl    %cl,%edx
f0104ea7:	09 d0                	or     %edx,%eax
f0104ea9:	89 f2                	mov    %esi,%edx
f0104eab:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0104eaf:	d3 ea                	shr    %cl,%edx
f0104eb1:	83 c4 20             	add    $0x20,%esp
f0104eb4:	5e                   	pop    %esi
f0104eb5:	5f                   	pop    %edi
f0104eb6:	5d                   	pop    %ebp
f0104eb7:	c3                   	ret    
f0104eb8:	85 c9                	test   %ecx,%ecx
f0104eba:	75 0b                	jne    f0104ec7 <__umoddi3+0xe3>
f0104ebc:	b8 01 00 00 00       	mov    $0x1,%eax
f0104ec1:	31 d2                	xor    %edx,%edx
f0104ec3:	f7 f1                	div    %ecx
f0104ec5:	89 c1                	mov    %eax,%ecx
f0104ec7:	89 f0                	mov    %esi,%eax
f0104ec9:	31 d2                	xor    %edx,%edx
f0104ecb:	f7 f1                	div    %ecx
f0104ecd:	89 f8                	mov    %edi,%eax
f0104ecf:	e9 3e ff ff ff       	jmp    f0104e12 <__umoddi3+0x2e>
f0104ed4:	89 f2                	mov    %esi,%edx
f0104ed6:	83 c4 20             	add    $0x20,%esp
f0104ed9:	5e                   	pop    %esi
f0104eda:	5f                   	pop    %edi
f0104edb:	5d                   	pop    %ebp
f0104edc:	c3                   	ret    
f0104edd:	8d 76 00             	lea    0x0(%esi),%esi
f0104ee0:	39 f5                	cmp    %esi,%ebp
f0104ee2:	72 04                	jb     f0104ee8 <__umoddi3+0x104>
f0104ee4:	39 f9                	cmp    %edi,%ecx
f0104ee6:	77 06                	ja     f0104eee <__umoddi3+0x10a>
f0104ee8:	89 f2                	mov    %esi,%edx
f0104eea:	29 cf                	sub    %ecx,%edi
f0104eec:	19 ea                	sbb    %ebp,%edx
f0104eee:	89 f8                	mov    %edi,%eax
f0104ef0:	83 c4 20             	add    $0x20,%esp
f0104ef3:	5e                   	pop    %esi
f0104ef4:	5f                   	pop    %edi
f0104ef5:	5d                   	pop    %ebp
f0104ef6:	c3                   	ret    
f0104ef7:	90                   	nop
f0104ef8:	89 d1                	mov    %edx,%ecx
f0104efa:	89 c5                	mov    %eax,%ebp
f0104efc:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0104f00:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0104f04:	eb 8d                	jmp    f0104e93 <__umoddi3+0xaf>
f0104f06:	66 90                	xchg   %ax,%ax
f0104f08:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0104f0c:	72 ea                	jb     f0104ef8 <__umoddi3+0x114>
f0104f0e:	89 f1                	mov    %esi,%ecx
f0104f10:	eb 81                	jmp    f0104e93 <__umoddi3+0xaf>
