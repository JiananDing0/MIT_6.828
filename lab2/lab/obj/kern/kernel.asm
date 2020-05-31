
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
f0100015:	b8 00 b0 11 00       	mov    $0x11b000,%eax
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
f0100034:	bc 00 b0 11 f0       	mov    $0xf011b000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


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
f0100046:	b8 60 d9 11 f0       	mov    $0xf011d960,%eax
f010004b:	2d 00 d3 11 f0       	sub    $0xf011d300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 d3 11 f0 	movl   $0xf011d300,(%esp)
f0100063:	e8 da 26 00 00       	call   f0102742 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 70 04 00 00       	call   f01004dd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 a0 2b 10 f0 	movl   $0xf0102ba0,(%esp)
f010007c:	e8 1d 1c 00 00       	call   f0101c9e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 81 0e 00 00       	call   f0100f07 <mem_init>

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100086:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010008d:	e8 1f 07 00 00       	call   f01007b1 <monitor>
f0100092:	eb f2                	jmp    f0100086 <i386_init+0x46>

f0100094 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	56                   	push   %esi
f0100098:	53                   	push   %ebx
f0100099:	83 ec 10             	sub    $0x10,%esp
f010009c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010009f:	83 3d 64 d9 11 f0 00 	cmpl   $0x0,0xf011d964
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 64 d9 11 f0    	mov    %esi,0xf011d964

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000ae:	fa                   	cli    
f01000af:	fc                   	cld    

	va_start(ap, fmt);
f01000b0:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01000b6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01000ba:	8b 45 08             	mov    0x8(%ebp),%eax
f01000bd:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000c1:	c7 04 24 bb 2b 10 f0 	movl   $0xf0102bbb,(%esp)
f01000c8:	e8 d1 1b 00 00       	call   f0101c9e <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 92 1b 00 00       	call   f0101c6b <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 f7 2b 10 f0 	movl   $0xf0102bf7,(%esp)
f01000e0:	e8 b9 1b 00 00       	call   f0101c9e <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000ec:	e8 c0 06 00 00       	call   f01007b1 <monitor>
f01000f1:	eb f2                	jmp    f01000e5 <_panic+0x51>

f01000f3 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f3:	55                   	push   %ebp
f01000f4:	89 e5                	mov    %esp,%ebp
f01000f6:	53                   	push   %ebx
f01000f7:	83 ec 14             	sub    $0x14,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fa:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100100:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100104:	8b 45 08             	mov    0x8(%ebp),%eax
f0100107:	89 44 24 04          	mov    %eax,0x4(%esp)
f010010b:	c7 04 24 d3 2b 10 f0 	movl   $0xf0102bd3,(%esp)
f0100112:	e8 87 1b 00 00       	call   f0101c9e <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 45 1b 00 00       	call   f0101c6b <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 f7 2b 10 f0 	movl   $0xf0102bf7,(%esp)
f010012d:	e8 6c 1b 00 00       	call   f0101c9e <cprintf>
	va_end(ap);
}
f0100132:	83 c4 14             	add    $0x14,%esp
f0100135:	5b                   	pop    %ebx
f0100136:	5d                   	pop    %ebp
f0100137:	c3                   	ret    

f0100138 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f0100138:	55                   	push   %ebp
f0100139:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010013b:	ba 84 00 00 00       	mov    $0x84,%edx
f0100140:	ec                   	in     (%dx),%al
f0100141:	ec                   	in     (%dx),%al
f0100142:	ec                   	in     (%dx),%al
f0100143:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f0100144:	5d                   	pop    %ebp
f0100145:	c3                   	ret    

f0100146 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100146:	55                   	push   %ebp
f0100147:	89 e5                	mov    %esp,%ebp
f0100149:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010014e:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010014f:	a8 01                	test   $0x1,%al
f0100151:	74 08                	je     f010015b <serial_proc_data+0x15>
f0100153:	b2 f8                	mov    $0xf8,%dl
f0100155:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100156:	0f b6 c0             	movzbl %al,%eax
f0100159:	eb 05                	jmp    f0100160 <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010015b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100160:	5d                   	pop    %ebp
f0100161:	c3                   	ret    

f0100162 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100162:	55                   	push   %ebp
f0100163:	89 e5                	mov    %esp,%ebp
f0100165:	53                   	push   %ebx
f0100166:	83 ec 04             	sub    $0x4,%esp
f0100169:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010016b:	eb 29                	jmp    f0100196 <cons_intr+0x34>
		if (c == 0)
f010016d:	85 c0                	test   %eax,%eax
f010016f:	74 25                	je     f0100196 <cons_intr+0x34>
			continue;
		cons.buf[cons.wpos++] = c;
f0100171:	8b 15 24 d5 11 f0    	mov    0xf011d524,%edx
f0100177:	88 82 20 d3 11 f0    	mov    %al,-0xfee2ce0(%edx)
f010017d:	8d 42 01             	lea    0x1(%edx),%eax
f0100180:	a3 24 d5 11 f0       	mov    %eax,0xf011d524
		if (cons.wpos == CONSBUFSIZE)
f0100185:	3d 00 02 00 00       	cmp    $0x200,%eax
f010018a:	75 0a                	jne    f0100196 <cons_intr+0x34>
			cons.wpos = 0;
f010018c:	c7 05 24 d5 11 f0 00 	movl   $0x0,0xf011d524
f0100193:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100196:	ff d3                	call   *%ebx
f0100198:	83 f8 ff             	cmp    $0xffffffff,%eax
f010019b:	75 d0                	jne    f010016d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010019d:	83 c4 04             	add    $0x4,%esp
f01001a0:	5b                   	pop    %ebx
f01001a1:	5d                   	pop    %ebp
f01001a2:	c3                   	ret    

f01001a3 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01001a3:	55                   	push   %ebp
f01001a4:	89 e5                	mov    %esp,%ebp
f01001a6:	57                   	push   %edi
f01001a7:	56                   	push   %esi
f01001a8:	53                   	push   %ebx
f01001a9:	83 ec 2c             	sub    $0x2c,%esp
f01001ac:	89 c6                	mov    %eax,%esi
f01001ae:	bb 01 32 00 00       	mov    $0x3201,%ebx
f01001b3:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01001b8:	eb 05                	jmp    f01001bf <cons_putc+0x1c>
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01001ba:	e8 79 ff ff ff       	call   f0100138 <delay>
f01001bf:	89 fa                	mov    %edi,%edx
f01001c1:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01001c2:	a8 20                	test   $0x20,%al
f01001c4:	75 03                	jne    f01001c9 <cons_putc+0x26>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01001c6:	4b                   	dec    %ebx
f01001c7:	75 f1                	jne    f01001ba <cons_putc+0x17>
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f01001c9:	89 f2                	mov    %esi,%edx
f01001cb:	89 f0                	mov    %esi,%eax
f01001cd:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001d5:	ee                   	out    %al,(%dx)
f01001d6:	bb 01 32 00 00       	mov    $0x3201,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001db:	bf 79 03 00 00       	mov    $0x379,%edi
f01001e0:	eb 05                	jmp    f01001e7 <cons_putc+0x44>
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
		delay();
f01001e2:	e8 51 ff ff ff       	call   f0100138 <delay>
f01001e7:	89 fa                	mov    %edi,%edx
f01001e9:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01001ea:	84 c0                	test   %al,%al
f01001ec:	78 03                	js     f01001f1 <cons_putc+0x4e>
f01001ee:	4b                   	dec    %ebx
f01001ef:	75 f1                	jne    f01001e2 <cons_putc+0x3f>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01001f1:	ba 78 03 00 00       	mov    $0x378,%edx
f01001f6:	8a 45 e7             	mov    -0x19(%ebp),%al
f01001f9:	ee                   	out    %al,(%dx)
f01001fa:	b2 7a                	mov    $0x7a,%dl
f01001fc:	b0 0d                	mov    $0xd,%al
f01001fe:	ee                   	out    %al,(%dx)
f01001ff:	b0 08                	mov    $0x8,%al
f0100201:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100202:	f7 c6 00 ff ff ff    	test   $0xffffff00,%esi
f0100208:	75 06                	jne    f0100210 <cons_putc+0x6d>
		c |= 0x0700;
f010020a:	81 ce 00 07 00 00    	or     $0x700,%esi

	switch (c & 0xff) {
f0100210:	89 f0                	mov    %esi,%eax
f0100212:	25 ff 00 00 00       	and    $0xff,%eax
f0100217:	83 f8 09             	cmp    $0x9,%eax
f010021a:	74 78                	je     f0100294 <cons_putc+0xf1>
f010021c:	83 f8 09             	cmp    $0x9,%eax
f010021f:	7f 0b                	jg     f010022c <cons_putc+0x89>
f0100221:	83 f8 08             	cmp    $0x8,%eax
f0100224:	0f 85 9e 00 00 00    	jne    f01002c8 <cons_putc+0x125>
f010022a:	eb 10                	jmp    f010023c <cons_putc+0x99>
f010022c:	83 f8 0a             	cmp    $0xa,%eax
f010022f:	74 39                	je     f010026a <cons_putc+0xc7>
f0100231:	83 f8 0d             	cmp    $0xd,%eax
f0100234:	0f 85 8e 00 00 00    	jne    f01002c8 <cons_putc+0x125>
f010023a:	eb 36                	jmp    f0100272 <cons_putc+0xcf>
	case '\b':
		if (crt_pos > 0) {
f010023c:	66 a1 34 d5 11 f0    	mov    0xf011d534,%ax
f0100242:	66 85 c0             	test   %ax,%ax
f0100245:	0f 84 e2 00 00 00    	je     f010032d <cons_putc+0x18a>
			crt_pos--;
f010024b:	48                   	dec    %eax
f010024c:	66 a3 34 d5 11 f0    	mov    %ax,0xf011d534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100252:	0f b7 c0             	movzwl %ax,%eax
f0100255:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010025b:	83 ce 20             	or     $0x20,%esi
f010025e:	8b 15 30 d5 11 f0    	mov    0xf011d530,%edx
f0100264:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100268:	eb 78                	jmp    f01002e2 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010026a:	66 83 05 34 d5 11 f0 	addw   $0x50,0xf011d534
f0100271:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100272:	66 8b 0d 34 d5 11 f0 	mov    0xf011d534,%cx
f0100279:	bb 50 00 00 00       	mov    $0x50,%ebx
f010027e:	89 c8                	mov    %ecx,%eax
f0100280:	ba 00 00 00 00       	mov    $0x0,%edx
f0100285:	66 f7 f3             	div    %bx
f0100288:	66 29 d1             	sub    %dx,%cx
f010028b:	66 89 0d 34 d5 11 f0 	mov    %cx,0xf011d534
f0100292:	eb 4e                	jmp    f01002e2 <cons_putc+0x13f>
		break;
	case '\t':
		cons_putc(' ');
f0100294:	b8 20 00 00 00       	mov    $0x20,%eax
f0100299:	e8 05 ff ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f010029e:	b8 20 00 00 00       	mov    $0x20,%eax
f01002a3:	e8 fb fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002a8:	b8 20 00 00 00       	mov    $0x20,%eax
f01002ad:	e8 f1 fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002b2:	b8 20 00 00 00       	mov    $0x20,%eax
f01002b7:	e8 e7 fe ff ff       	call   f01001a3 <cons_putc>
		cons_putc(' ');
f01002bc:	b8 20 00 00 00       	mov    $0x20,%eax
f01002c1:	e8 dd fe ff ff       	call   f01001a3 <cons_putc>
f01002c6:	eb 1a                	jmp    f01002e2 <cons_putc+0x13f>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01002c8:	66 a1 34 d5 11 f0    	mov    0xf011d534,%ax
f01002ce:	0f b7 c8             	movzwl %ax,%ecx
f01002d1:	8b 15 30 d5 11 f0    	mov    0xf011d530,%edx
f01002d7:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002db:	40                   	inc    %eax
f01002dc:	66 a3 34 d5 11 f0    	mov    %ax,0xf011d534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01002e2:	66 81 3d 34 d5 11 f0 	cmpw   $0x7cf,0xf011d534
f01002e9:	cf 07 
f01002eb:	76 40                	jbe    f010032d <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002ed:	a1 30 d5 11 f0       	mov    0xf011d530,%eax
f01002f2:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01002f9:	00 
f01002fa:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100300:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100304:	89 04 24             	mov    %eax,(%esp)
f0100307:	e8 80 24 00 00       	call   f010278c <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010030c:	8b 15 30 d5 11 f0    	mov    0xf011d530,%edx
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100312:	b8 80 07 00 00       	mov    $0x780,%eax
			crt_buf[i] = 0x0700 | ' ';
f0100317:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010031d:	40                   	inc    %eax
f010031e:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100323:	75 f2                	jne    f0100317 <cons_putc+0x174>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100325:	66 83 2d 34 d5 11 f0 	subw   $0x50,0xf011d534
f010032c:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010032d:	8b 0d 2c d5 11 f0    	mov    0xf011d52c,%ecx
f0100333:	b0 0e                	mov    $0xe,%al
f0100335:	89 ca                	mov    %ecx,%edx
f0100337:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100338:	66 8b 35 34 d5 11 f0 	mov    0xf011d534,%si
f010033f:	8d 59 01             	lea    0x1(%ecx),%ebx
f0100342:	89 f0                	mov    %esi,%eax
f0100344:	66 c1 e8 08          	shr    $0x8,%ax
f0100348:	89 da                	mov    %ebx,%edx
f010034a:	ee                   	out    %al,(%dx)
f010034b:	b0 0f                	mov    $0xf,%al
f010034d:	89 ca                	mov    %ecx,%edx
f010034f:	ee                   	out    %al,(%dx)
f0100350:	89 f0                	mov    %esi,%eax
f0100352:	89 da                	mov    %ebx,%edx
f0100354:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100355:	83 c4 2c             	add    $0x2c,%esp
f0100358:	5b                   	pop    %ebx
f0100359:	5e                   	pop    %esi
f010035a:	5f                   	pop    %edi
f010035b:	5d                   	pop    %ebp
f010035c:	c3                   	ret    

f010035d <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010035d:	55                   	push   %ebp
f010035e:	89 e5                	mov    %esp,%ebp
f0100360:	53                   	push   %ebx
f0100361:	83 ec 14             	sub    $0x14,%esp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100364:	ba 64 00 00 00       	mov    $0x64,%edx
f0100369:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f010036a:	0f b6 c0             	movzbl %al,%eax
f010036d:	a8 01                	test   $0x1,%al
f010036f:	0f 84 e0 00 00 00    	je     f0100455 <kbd_proc_data+0xf8>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100375:	a8 20                	test   $0x20,%al
f0100377:	0f 85 df 00 00 00    	jne    f010045c <kbd_proc_data+0xff>
f010037d:	b2 60                	mov    $0x60,%dl
f010037f:	ec                   	in     (%dx),%al
f0100380:	88 c2                	mov    %al,%dl
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100382:	3c e0                	cmp    $0xe0,%al
f0100384:	75 11                	jne    f0100397 <kbd_proc_data+0x3a>
		// E0 escape character
		shift |= E0ESC;
f0100386:	83 0d 28 d5 11 f0 40 	orl    $0x40,0xf011d528
		return 0;
f010038d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100392:	e9 ca 00 00 00       	jmp    f0100461 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100397:	84 c0                	test   %al,%al
f0100399:	79 33                	jns    f01003ce <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010039b:	8b 0d 28 d5 11 f0    	mov    0xf011d528,%ecx
f01003a1:	f6 c1 40             	test   $0x40,%cl
f01003a4:	75 05                	jne    f01003ab <kbd_proc_data+0x4e>
f01003a6:	88 c2                	mov    %al,%dl
f01003a8:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003ab:	0f b6 d2             	movzbl %dl,%edx
f01003ae:	8a 82 20 2c 10 f0    	mov    -0xfefd3e0(%edx),%al
f01003b4:	83 c8 40             	or     $0x40,%eax
f01003b7:	0f b6 c0             	movzbl %al,%eax
f01003ba:	f7 d0                	not    %eax
f01003bc:	21 c1                	and    %eax,%ecx
f01003be:	89 0d 28 d5 11 f0    	mov    %ecx,0xf011d528
		return 0;
f01003c4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c9:	e9 93 00 00 00       	jmp    f0100461 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f01003ce:	8b 0d 28 d5 11 f0    	mov    0xf011d528,%ecx
f01003d4:	f6 c1 40             	test   $0x40,%cl
f01003d7:	74 0e                	je     f01003e7 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003d9:	88 c2                	mov    %al,%dl
f01003db:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003de:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003e1:	89 0d 28 d5 11 f0    	mov    %ecx,0xf011d528
	}

	shift |= shiftcode[data];
f01003e7:	0f b6 d2             	movzbl %dl,%edx
f01003ea:	0f b6 82 20 2c 10 f0 	movzbl -0xfefd3e0(%edx),%eax
f01003f1:	0b 05 28 d5 11 f0    	or     0xf011d528,%eax
	shift ^= togglecode[data];
f01003f7:	0f b6 8a 20 2d 10 f0 	movzbl -0xfefd2e0(%edx),%ecx
f01003fe:	31 c8                	xor    %ecx,%eax
f0100400:	a3 28 d5 11 f0       	mov    %eax,0xf011d528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100405:	89 c1                	mov    %eax,%ecx
f0100407:	83 e1 03             	and    $0x3,%ecx
f010040a:	8b 0c 8d 20 2e 10 f0 	mov    -0xfefd1e0(,%ecx,4),%ecx
f0100411:	0f b6 1c 11          	movzbl (%ecx,%edx,1),%ebx
	if (shift & CAPSLOCK) {
f0100415:	a8 08                	test   $0x8,%al
f0100417:	74 18                	je     f0100431 <kbd_proc_data+0xd4>
		if ('a' <= c && c <= 'z')
f0100419:	8d 53 9f             	lea    -0x61(%ebx),%edx
f010041c:	83 fa 19             	cmp    $0x19,%edx
f010041f:	77 05                	ja     f0100426 <kbd_proc_data+0xc9>
			c += 'A' - 'a';
f0100421:	83 eb 20             	sub    $0x20,%ebx
f0100424:	eb 0b                	jmp    f0100431 <kbd_proc_data+0xd4>
		else if ('A' <= c && c <= 'Z')
f0100426:	8d 53 bf             	lea    -0x41(%ebx),%edx
f0100429:	83 fa 19             	cmp    $0x19,%edx
f010042c:	77 03                	ja     f0100431 <kbd_proc_data+0xd4>
			c += 'a' - 'A';
f010042e:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100431:	f7 d0                	not    %eax
f0100433:	a8 06                	test   $0x6,%al
f0100435:	75 2a                	jne    f0100461 <kbd_proc_data+0x104>
f0100437:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f010043d:	75 22                	jne    f0100461 <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f010043f:	c7 04 24 ed 2b 10 f0 	movl   $0xf0102bed,(%esp)
f0100446:	e8 53 18 00 00       	call   f0101c9e <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010044b:	ba 92 00 00 00       	mov    $0x92,%edx
f0100450:	b0 03                	mov    $0x3,%al
f0100452:	ee                   	out    %al,(%dx)
f0100453:	eb 0c                	jmp    f0100461 <kbd_proc_data+0x104>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100455:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f010045a:	eb 05                	jmp    f0100461 <kbd_proc_data+0x104>
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010045c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100461:	89 d8                	mov    %ebx,%eax
f0100463:	83 c4 14             	add    $0x14,%esp
f0100466:	5b                   	pop    %ebx
f0100467:	5d                   	pop    %ebp
f0100468:	c3                   	ret    

f0100469 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100469:	55                   	push   %ebp
f010046a:	89 e5                	mov    %esp,%ebp
f010046c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f010046f:	80 3d 00 d3 11 f0 00 	cmpb   $0x0,0xf011d300
f0100476:	74 0a                	je     f0100482 <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100478:	b8 46 01 10 f0       	mov    $0xf0100146,%eax
f010047d:	e8 e0 fc ff ff       	call   f0100162 <cons_intr>
}
f0100482:	c9                   	leave  
f0100483:	c3                   	ret    

f0100484 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100484:	55                   	push   %ebp
f0100485:	89 e5                	mov    %esp,%ebp
f0100487:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010048a:	b8 5d 03 10 f0       	mov    $0xf010035d,%eax
f010048f:	e8 ce fc ff ff       	call   f0100162 <cons_intr>
}
f0100494:	c9                   	leave  
f0100495:	c3                   	ret    

f0100496 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100496:	55                   	push   %ebp
f0100497:	89 e5                	mov    %esp,%ebp
f0100499:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010049c:	e8 c8 ff ff ff       	call   f0100469 <serial_intr>
	kbd_intr();
f01004a1:	e8 de ff ff ff       	call   f0100484 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004a6:	8b 15 20 d5 11 f0    	mov    0xf011d520,%edx
f01004ac:	3b 15 24 d5 11 f0    	cmp    0xf011d524,%edx
f01004b2:	74 22                	je     f01004d6 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004b4:	0f b6 82 20 d3 11 f0 	movzbl -0xfee2ce0(%edx),%eax
f01004bb:	42                   	inc    %edx
f01004bc:	89 15 20 d5 11 f0    	mov    %edx,0xf011d520
		if (cons.rpos == CONSBUFSIZE)
f01004c2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004c8:	75 11                	jne    f01004db <cons_getc+0x45>
			cons.rpos = 0;
f01004ca:	c7 05 20 d5 11 f0 00 	movl   $0x0,0xf011d520
f01004d1:	00 00 00 
f01004d4:	eb 05                	jmp    f01004db <cons_getc+0x45>
		return c;
	}
	return 0;
f01004d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004db:	c9                   	leave  
f01004dc:	c3                   	ret    

f01004dd <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004dd:	55                   	push   %ebp
f01004de:	89 e5                	mov    %esp,%ebp
f01004e0:	57                   	push   %edi
f01004e1:	56                   	push   %esi
f01004e2:	53                   	push   %ebx
f01004e3:	83 ec 2c             	sub    $0x2c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01004e6:	66 8b 15 00 80 0b f0 	mov    0xf00b8000,%dx
	*cp = (uint16_t) 0xA55A;
f01004ed:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01004f4:	5a a5 
	if (*cp != 0xA55A) {
f01004f6:	66 a1 00 80 0b f0    	mov    0xf00b8000,%ax
f01004fc:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100500:	74 11                	je     f0100513 <cons_init+0x36>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100502:	c7 05 2c d5 11 f0 b4 	movl   $0x3b4,0xf011d52c
f0100509:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010050c:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100511:	eb 16                	jmp    f0100529 <cons_init+0x4c>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100513:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010051a:	c7 05 2c d5 11 f0 d4 	movl   $0x3d4,0xf011d52c
f0100521:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100524:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100529:	8b 0d 2c d5 11 f0    	mov    0xf011d52c,%ecx
f010052f:	b0 0e                	mov    $0xe,%al
f0100531:	89 ca                	mov    %ecx,%edx
f0100533:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100534:	8d 59 01             	lea    0x1(%ecx),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100537:	89 da                	mov    %ebx,%edx
f0100539:	ec                   	in     (%dx),%al
f010053a:	0f b6 f8             	movzbl %al,%edi
f010053d:	c1 e7 08             	shl    $0x8,%edi
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100540:	b0 0f                	mov    $0xf,%al
f0100542:	89 ca                	mov    %ecx,%edx
f0100544:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100545:	89 da                	mov    %ebx,%edx
f0100547:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100548:	89 35 30 d5 11 f0    	mov    %esi,0xf011d530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010054e:	0f b6 d8             	movzbl %al,%ebx
f0100551:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100553:	66 89 3d 34 d5 11 f0 	mov    %di,0xf011d534
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055a:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f010055f:	b0 00                	mov    $0x0,%al
f0100561:	89 da                	mov    %ebx,%edx
f0100563:	ee                   	out    %al,(%dx)
f0100564:	b2 fb                	mov    $0xfb,%dl
f0100566:	b0 80                	mov    $0x80,%al
f0100568:	ee                   	out    %al,(%dx)
f0100569:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010056e:	b0 0c                	mov    $0xc,%al
f0100570:	89 ca                	mov    %ecx,%edx
f0100572:	ee                   	out    %al,(%dx)
f0100573:	b2 f9                	mov    $0xf9,%dl
f0100575:	b0 00                	mov    $0x0,%al
f0100577:	ee                   	out    %al,(%dx)
f0100578:	b2 fb                	mov    $0xfb,%dl
f010057a:	b0 03                	mov    $0x3,%al
f010057c:	ee                   	out    %al,(%dx)
f010057d:	b2 fc                	mov    $0xfc,%dl
f010057f:	b0 00                	mov    $0x0,%al
f0100581:	ee                   	out    %al,(%dx)
f0100582:	b2 f9                	mov    $0xf9,%dl
f0100584:	b0 01                	mov    $0x1,%al
f0100586:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100587:	b2 fd                	mov    $0xfd,%dl
f0100589:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010058a:	3c ff                	cmp    $0xff,%al
f010058c:	0f 95 45 e7          	setne  -0x19(%ebp)
f0100590:	8a 45 e7             	mov    -0x19(%ebp),%al
f0100593:	a2 00 d3 11 f0       	mov    %al,0xf011d300
f0100598:	89 da                	mov    %ebx,%edx
f010059a:	ec                   	in     (%dx),%al
f010059b:	89 ca                	mov    %ecx,%edx
f010059d:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010059e:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
f01005a2:	75 0c                	jne    f01005b0 <cons_init+0xd3>
		cprintf("Serial port does not exist!\n");
f01005a4:	c7 04 24 f9 2b 10 f0 	movl   $0xf0102bf9,(%esp)
f01005ab:	e8 ee 16 00 00       	call   f0101c9e <cprintf>
}
f01005b0:	83 c4 2c             	add    $0x2c,%esp
f01005b3:	5b                   	pop    %ebx
f01005b4:	5e                   	pop    %esi
f01005b5:	5f                   	pop    %edi
f01005b6:	5d                   	pop    %ebp
f01005b7:	c3                   	ret    

f01005b8 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005b8:	55                   	push   %ebp
f01005b9:	89 e5                	mov    %esp,%ebp
f01005bb:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005be:	8b 45 08             	mov    0x8(%ebp),%eax
f01005c1:	e8 dd fb ff ff       	call   f01001a3 <cons_putc>
}
f01005c6:	c9                   	leave  
f01005c7:	c3                   	ret    

f01005c8 <getchar>:

int
getchar(void)
{
f01005c8:	55                   	push   %ebp
f01005c9:	89 e5                	mov    %esp,%ebp
f01005cb:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01005ce:	e8 c3 fe ff ff       	call   f0100496 <cons_getc>
f01005d3:	85 c0                	test   %eax,%eax
f01005d5:	74 f7                	je     f01005ce <getchar+0x6>
		/* do nothing */;
	return c;
}
f01005d7:	c9                   	leave  
f01005d8:	c3                   	ret    

f01005d9 <iscons>:

int
iscons(int fdnum)
{
f01005d9:	55                   	push   %ebp
f01005da:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01005dc:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e1:	5d                   	pop    %ebp
f01005e2:	c3                   	ret    
	...

f01005e4 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01005e4:	55                   	push   %ebp
f01005e5:	89 e5                	mov    %esp,%ebp
f01005e7:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01005ea:	c7 04 24 30 2e 10 f0 	movl   $0xf0102e30,(%esp)
f01005f1:	e8 a8 16 00 00       	call   f0101c9e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005f6:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01005fd:	00 
f01005fe:	c7 04 24 e8 2e 10 f0 	movl   $0xf0102ee8,(%esp)
f0100605:	e8 94 16 00 00       	call   f0101c9e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010060a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100611:	00 
f0100612:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100619:	f0 
f010061a:	c7 04 24 10 2f 10 f0 	movl   $0xf0102f10,(%esp)
f0100621:	e8 78 16 00 00       	call   f0101c9e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100626:	c7 44 24 08 86 2b 10 	movl   $0x102b86,0x8(%esp)
f010062d:	00 
f010062e:	c7 44 24 04 86 2b 10 	movl   $0xf0102b86,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 34 2f 10 f0 	movl   $0xf0102f34,(%esp)
f010063d:	e8 5c 16 00 00       	call   f0101c9e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100642:	c7 44 24 08 00 d3 11 	movl   $0x11d300,0x8(%esp)
f0100649:	00 
f010064a:	c7 44 24 04 00 d3 11 	movl   $0xf011d300,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 58 2f 10 f0 	movl   $0xf0102f58,(%esp)
f0100659:	e8 40 16 00 00       	call   f0101c9e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010065e:	c7 44 24 08 60 d9 11 	movl   $0x11d960,0x8(%esp)
f0100665:	00 
f0100666:	c7 44 24 04 60 d9 11 	movl   $0xf011d960,0x4(%esp)
f010066d:	f0 
f010066e:	c7 04 24 7c 2f 10 f0 	movl   $0xf0102f7c,(%esp)
f0100675:	e8 24 16 00 00       	call   f0101c9e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010067a:	b8 5f dd 11 f0       	mov    $0xf011dd5f,%eax
f010067f:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
f0100684:	25 00 fc ff ff       	and    $0xfffffc00,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100689:	89 c2                	mov    %eax,%edx
f010068b:	85 c0                	test   %eax,%eax
f010068d:	79 06                	jns    f0100695 <mon_kerninfo+0xb1>
f010068f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100695:	c1 fa 0a             	sar    $0xa,%edx
f0100698:	89 54 24 04          	mov    %edx,0x4(%esp)
f010069c:	c7 04 24 a0 2f 10 f0 	movl   $0xf0102fa0,(%esp)
f01006a3:	e8 f6 15 00 00       	call   f0101c9e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01006a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ad:	c9                   	leave  
f01006ae:	c3                   	ret    

f01006af <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006af:	55                   	push   %ebp
f01006b0:	89 e5                	mov    %esp,%ebp
f01006b2:	53                   	push   %ebx
f01006b3:	83 ec 14             	sub    $0x14,%esp
f01006b6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006bb:	8b 83 a4 30 10 f0    	mov    -0xfefcf5c(%ebx),%eax
f01006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006c5:	8b 83 a0 30 10 f0    	mov    -0xfefcf60(%ebx),%eax
f01006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006cf:	c7 04 24 49 2e 10 f0 	movl   $0xf0102e49,(%esp)
f01006d6:	e8 c3 15 00 00       	call   f0101c9e <cprintf>
f01006db:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
f01006de:	83 fb 24             	cmp    $0x24,%ebx
f01006e1:	75 d8                	jne    f01006bb <mon_help+0xc>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006e3:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e8:	83 c4 14             	add    $0x14,%esp
f01006eb:	5b                   	pop    %ebx
f01006ec:	5d                   	pop    %ebp
f01006ed:	c3                   	ret    

f01006ee <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01006ee:	55                   	push   %ebp
f01006ef:	89 e5                	mov    %esp,%ebp
f01006f1:	57                   	push   %edi
f01006f2:	56                   	push   %esi
f01006f3:	53                   	push   %ebx
f01006f4:	83 ec 5c             	sub    $0x5c,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01006f7:	89 eb                	mov    %ebp,%ebx
	uint32_t ebp = read_ebp();
	uint32_t eip;
	uint32_t args[5];
	struct Eipdebuginfo info;
	// Print statements
	cprintf("Stack backtrace:\n");
f01006f9:	c7 04 24 52 2e 10 f0 	movl   $0xf0102e52,(%esp)
f0100700:	e8 99 15 00 00       	call   f0101c9e <cprintf>
	while (ebp) {
f0100705:	e9 92 00 00 00       	jmp    f010079c <mon_backtrace+0xae>
		// CALL assembly will always push the return address to stack. As a result, we 
		// can always find it on stack before the function is called.
		eip = *((uint32_t *)(ebp + 1 * sizeof(uint32_t)));
f010070a:	8b 73 04             	mov    0x4(%ebx),%esi
		// All the arguments are pushed onto the stack right before function is CALLed, 
		// which means we can find them before the CALL command is executed and push.
		args[0] = *((uint32_t *)(ebp + 2 * sizeof(uint32_t)));
f010070d:	8b 43 08             	mov    0x8(%ebx),%eax
f0100710:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		args[1] = *((uint32_t *)(ebp + 3 * sizeof(uint32_t)));
f0100713:	8b 43 0c             	mov    0xc(%ebx),%eax
f0100716:	89 45 c0             	mov    %eax,-0x40(%ebp)
		args[2] = *((uint32_t *)(ebp + 4 * sizeof(uint32_t)));
f0100719:	8b 43 10             	mov    0x10(%ebx),%eax
f010071c:	89 45 bc             	mov    %eax,-0x44(%ebp)
		args[3] = *((uint32_t *)(ebp + 5 * sizeof(uint32_t)));
f010071f:	8b 43 14             	mov    0x14(%ebx),%eax
f0100722:	89 45 b8             	mov    %eax,-0x48(%ebp)
		args[4] = *((uint32_t *)(ebp + 6 * sizeof(uint32_t)));
f0100725:	8b 7b 18             	mov    0x18(%ebx),%edi
		// Get corresponding debug information from debuginfo_eip() function
		debuginfo_eip(eip, &info);
f0100728:	8d 45 d0             	lea    -0x30(%ebp),%eax
f010072b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010072f:	89 34 24             	mov    %esi,(%esp)
f0100732:	e8 61 16 00 00       	call   f0101d98 <debuginfo_eip>
		// Print debug line
		cprintf("  ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, args[0], args[1], args[2], args[3], args[4]);
f0100737:	89 7c 24 1c          	mov    %edi,0x1c(%esp)
f010073b:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010073e:	89 44 24 18          	mov    %eax,0x18(%esp)
f0100742:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0100745:	89 44 24 14          	mov    %eax,0x14(%esp)
f0100749:	8b 45 c0             	mov    -0x40(%ebp),%eax
f010074c:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100750:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f0100753:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100757:	89 74 24 08          	mov    %esi,0x8(%esp)
f010075b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010075f:	c7 04 24 cc 2f 10 f0 	movl   $0xf0102fcc,(%esp)
f0100766:	e8 33 15 00 00       	call   f0101c9e <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (uint32_t)(eip - info.eip_fn_addr));
f010076b:	2b 75 e0             	sub    -0x20(%ebp),%esi
f010076e:	89 74 24 14          	mov    %esi,0x14(%esp)
f0100772:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100775:	89 44 24 10          	mov    %eax,0x10(%esp)
f0100779:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010077c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100780:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0100783:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100787:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010078a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010078e:	c7 04 24 64 2e 10 f0 	movl   $0xf0102e64,(%esp)
f0100795:	e8 04 15 00 00       	call   f0101c9e <cprintf>
		// Update value of %ebp
		ebp = (uint32_t)(* (uint32_t *)ebp);
f010079a:	8b 1b                	mov    (%ebx),%ebx
	uint32_t eip;
	uint32_t args[5];
	struct Eipdebuginfo info;
	// Print statements
	cprintf("Stack backtrace:\n");
	while (ebp) {
f010079c:	85 db                	test   %ebx,%ebx
f010079e:	0f 85 66 ff ff ff    	jne    f010070a <mon_backtrace+0x1c>
		cprintf("\t%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, (uint32_t)(eip - info.eip_fn_addr));
		// Update value of %ebp
		ebp = (uint32_t)(* (uint32_t *)ebp);
	}
	return 0;
}
f01007a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01007a9:	83 c4 5c             	add    $0x5c,%esp
f01007ac:	5b                   	pop    %ebx
f01007ad:	5e                   	pop    %esi
f01007ae:	5f                   	pop    %edi
f01007af:	5d                   	pop    %ebp
f01007b0:	c3                   	ret    

f01007b1 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007b1:	55                   	push   %ebp
f01007b2:	89 e5                	mov    %esp,%ebp
f01007b4:	57                   	push   %edi
f01007b5:	56                   	push   %esi
f01007b6:	53                   	push   %ebx
f01007b7:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01007ba:	c7 04 24 00 30 10 f0 	movl   $0xf0103000,(%esp)
f01007c1:	e8 d8 14 00 00       	call   f0101c9e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007c6:	c7 04 24 24 30 10 f0 	movl   $0xf0103024,(%esp)
f01007cd:	e8 cc 14 00 00       	call   f0101c9e <cprintf>


	while (1) {
		buf = readline("K> ");
f01007d2:	c7 04 24 75 2e 10 f0 	movl   $0xf0102e75,(%esp)
f01007d9:	e8 3a 1d 00 00       	call   f0102518 <readline>
f01007de:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01007e0:	85 c0                	test   %eax,%eax
f01007e2:	74 ee                	je     f01007d2 <monitor+0x21>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01007e4:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01007eb:	be 00 00 00 00       	mov    $0x0,%esi
f01007f0:	eb 04                	jmp    f01007f6 <monitor+0x45>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01007f2:	c6 03 00             	movb   $0x0,(%ebx)
f01007f5:	43                   	inc    %ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01007f6:	8a 03                	mov    (%ebx),%al
f01007f8:	84 c0                	test   %al,%al
f01007fa:	74 5e                	je     f010085a <monitor+0xa9>
f01007fc:	0f be c0             	movsbl %al,%eax
f01007ff:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100803:	c7 04 24 79 2e 10 f0 	movl   $0xf0102e79,(%esp)
f010080a:	e8 fe 1e 00 00       	call   f010270d <strchr>
f010080f:	85 c0                	test   %eax,%eax
f0100811:	75 df                	jne    f01007f2 <monitor+0x41>
			*buf++ = 0;
		if (*buf == 0)
f0100813:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100816:	74 42                	je     f010085a <monitor+0xa9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100818:	83 fe 0f             	cmp    $0xf,%esi
f010081b:	75 16                	jne    f0100833 <monitor+0x82>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010081d:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f0100824:	00 
f0100825:	c7 04 24 7e 2e 10 f0 	movl   $0xf0102e7e,(%esp)
f010082c:	e8 6d 14 00 00       	call   f0101c9e <cprintf>
f0100831:	eb 9f                	jmp    f01007d2 <monitor+0x21>
			return 0;
		}
		argv[argc++] = buf;
f0100833:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100837:	46                   	inc    %esi
f0100838:	eb 01                	jmp    f010083b <monitor+0x8a>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010083a:	43                   	inc    %ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010083b:	8a 03                	mov    (%ebx),%al
f010083d:	84 c0                	test   %al,%al
f010083f:	74 b5                	je     f01007f6 <monitor+0x45>
f0100841:	0f be c0             	movsbl %al,%eax
f0100844:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100848:	c7 04 24 79 2e 10 f0 	movl   $0xf0102e79,(%esp)
f010084f:	e8 b9 1e 00 00       	call   f010270d <strchr>
f0100854:	85 c0                	test   %eax,%eax
f0100856:	74 e2                	je     f010083a <monitor+0x89>
f0100858:	eb 9c                	jmp    f01007f6 <monitor+0x45>
			buf++;
	}
	argv[argc] = 0;
f010085a:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100861:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100862:	85 f6                	test   %esi,%esi
f0100864:	0f 84 68 ff ff ff    	je     f01007d2 <monitor+0x21>
f010086a:	bb a0 30 10 f0       	mov    $0xf01030a0,%ebx
f010086f:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100874:	8b 03                	mov    (%ebx),%eax
f0100876:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010087d:	89 04 24             	mov    %eax,(%esp)
f0100880:	e8 35 1e 00 00       	call   f01026ba <strcmp>
f0100885:	85 c0                	test   %eax,%eax
f0100887:	75 24                	jne    f01008ad <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f0100889:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010088c:	8b 55 08             	mov    0x8(%ebp),%edx
f010088f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100893:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100896:	89 54 24 04          	mov    %edx,0x4(%esp)
f010089a:	89 34 24             	mov    %esi,(%esp)
f010089d:	ff 14 85 a8 30 10 f0 	call   *-0xfefcf58(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01008a4:	85 c0                	test   %eax,%eax
f01008a6:	78 26                	js     f01008ce <monitor+0x11d>
f01008a8:	e9 25 ff ff ff       	jmp    f01007d2 <monitor+0x21>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01008ad:	47                   	inc    %edi
f01008ae:	83 c3 0c             	add    $0xc,%ebx
f01008b1:	83 ff 03             	cmp    $0x3,%edi
f01008b4:	75 be                	jne    f0100874 <monitor+0xc3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01008b6:	8b 45 a8             	mov    -0x58(%ebp),%eax
f01008b9:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008bd:	c7 04 24 9b 2e 10 f0 	movl   $0xf0102e9b,(%esp)
f01008c4:	e8 d5 13 00 00       	call   f0101c9e <cprintf>
f01008c9:	e9 04 ff ff ff       	jmp    f01007d2 <monitor+0x21>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01008ce:	83 c4 5c             	add    $0x5c,%esp
f01008d1:	5b                   	pop    %ebx
f01008d2:	5e                   	pop    %esi
f01008d3:	5f                   	pop    %edi
f01008d4:	5d                   	pop    %ebp
f01008d5:	c3                   	ret    
	...

f01008d8 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008d8:	55                   	push   %ebp
f01008d9:	89 e5                	mov    %esp,%ebp
f01008db:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f01008de:	89 d1                	mov    %edx,%ecx
f01008e0:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f01008e3:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01008e6:	a8 01                	test   $0x1,%al
f01008e8:	74 4d                	je     f0100937 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008ea:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008ef:	89 c1                	mov    %eax,%ecx
f01008f1:	c1 e9 0c             	shr    $0xc,%ecx
f01008f4:	3b 0d 68 d9 11 f0    	cmp    0xf011d968,%ecx
f01008fa:	72 20                	jb     f010091c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100900:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f0100907:	f0 
f0100908:	c7 44 24 04 a9 02 00 	movl   $0x2a9,0x4(%esp)
f010090f:	00 
f0100910:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100917:	e8 78 f7 ff ff       	call   f0100094 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f010091c:	c1 ea 0c             	shr    $0xc,%edx
f010091f:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100925:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f010092c:	a8 01                	test   $0x1,%al
f010092e:	74 0e                	je     f010093e <check_va2pa+0x66>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100930:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100935:	eb 0c                	jmp    f0100943 <check_va2pa+0x6b>
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100937:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010093c:	eb 05                	jmp    f0100943 <check_va2pa+0x6b>
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
f010093e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return PTE_ADDR(p[PTX(va)]);
}
f0100943:	c9                   	leave  
f0100944:	c3                   	ret    

f0100945 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100945:	55                   	push   %ebp
f0100946:	89 e5                	mov    %esp,%ebp
f0100948:	56                   	push   %esi
f0100949:	53                   	push   %ebx
f010094a:	83 ec 10             	sub    $0x10,%esp
f010094d:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010094f:	89 04 24             	mov    %eax,(%esp)
f0100952:	e8 d9 12 00 00       	call   f0101c30 <mc146818_read>
f0100957:	89 c6                	mov    %eax,%esi
f0100959:	43                   	inc    %ebx
f010095a:	89 1c 24             	mov    %ebx,(%esp)
f010095d:	e8 ce 12 00 00       	call   f0101c30 <mc146818_read>
f0100962:	c1 e0 08             	shl    $0x8,%eax
f0100965:	09 f0                	or     %esi,%eax
}
f0100967:	83 c4 10             	add    $0x10,%esp
f010096a:	5b                   	pop    %ebx
f010096b:	5e                   	pop    %esi
f010096c:	5d                   	pop    %ebp
f010096d:	c3                   	ret    

f010096e <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f010096e:	55                   	push   %ebp
f010096f:	89 e5                	mov    %esp,%ebp
f0100971:	57                   	push   %edi
f0100972:	56                   	push   %esi
f0100973:	53                   	push   %ebx
f0100974:	83 ec 1c             	sub    $0x1c,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100977:	83 3d 3c d5 11 f0 00 	cmpl   $0x0,0xf011d53c
f010097e:	75 11                	jne    f0100991 <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100980:	ba 5f e9 11 f0       	mov    $0xf011e95f,%edx
f0100985:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010098b:	89 15 3c d5 11 f0    	mov    %edx,0xf011d53c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	assert(n >= 0);
	// Convert to physical address
	result = (char *)PADDR(nextfree);
f0100991:	8b 15 3c d5 11 f0    	mov    0xf011d53c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100997:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010099d:	77 20                	ja     f01009bf <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010099f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01009a3:	c7 44 24 08 e8 30 10 	movl   $0xf01030e8,0x8(%esp)
f01009aa:	f0 
f01009ab:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01009b2:	00 
f01009b3:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01009ba:	e8 d5 f6 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01009bf:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	// Determine whether it is out of bound
	if ((physaddr_t)result + n > PGSIZE * npages) {
f01009c5:	8b 1d 68 d9 11 f0    	mov    0xf011d968,%ebx
f01009cb:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
f01009ce:	89 de                	mov    %ebx,%esi
f01009d0:	c1 e6 0c             	shl    $0xc,%esi
f01009d3:	39 f7                	cmp    %esi,%edi
f01009d5:	76 1c                	jbe    f01009f3 <boot_alloc+0x85>
		panic("boot_alloc: out of memory!");
f01009d7:	c7 44 24 08 1c 35 10 	movl   $0xf010351c,0x8(%esp)
f01009de:	f0 
f01009df:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f01009e6:	00 
f01009e7:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01009ee:	e8 a1 f6 ff ff       	call   f0100094 <_panic>
	}
	// Otherwise, update value of nextfree, no update when n == 0
	nextfree += ROUNDUP(n, PGSIZE);
f01009f3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01009f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009fd:	01 d0                	add    %edx,%eax
f01009ff:	a3 3c d5 11 f0       	mov    %eax,0xf011d53c
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a04:	89 c8                	mov    %ecx,%eax
f0100a06:	c1 e8 0c             	shr    $0xc,%eax
f0100a09:	39 c3                	cmp    %eax,%ebx
f0100a0b:	77 20                	ja     f0100a2d <boot_alloc+0xbf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a0d:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0100a11:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f0100a18:	f0 
f0100a19:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100a20:	00 
f0100a21:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100a28:	e8 67 f6 ff ff       	call   f0100094 <_panic>
	// Convert back to kernel virtual address and return
	return KADDR((physaddr_t)result);
}
f0100a2d:	89 d0                	mov    %edx,%eax
f0100a2f:	83 c4 1c             	add    $0x1c,%esp
f0100a32:	5b                   	pop    %ebx
f0100a33:	5e                   	pop    %esi
f0100a34:	5f                   	pop    %edi
f0100a35:	5d                   	pop    %ebp
f0100a36:	c3                   	ret    

f0100a37 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a37:	55                   	push   %ebp
f0100a38:	89 e5                	mov    %esp,%ebp
f0100a3a:	57                   	push   %edi
f0100a3b:	56                   	push   %esi
f0100a3c:	53                   	push   %ebx
f0100a3d:	83 ec 4c             	sub    $0x4c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a40:	3c 01                	cmp    $0x1,%al
f0100a42:	19 f6                	sbb    %esi,%esi
f0100a44:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100a4a:	46                   	inc    %esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100a4b:	8b 15 40 d5 11 f0    	mov    0xf011d540,%edx
f0100a51:	85 d2                	test   %edx,%edx
f0100a53:	75 1c                	jne    f0100a71 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100a55:	c7 44 24 08 0c 31 10 	movl   $0xf010310c,0x8(%esp)
f0100a5c:	f0 
f0100a5d:	c7 44 24 04 ea 01 00 	movl   $0x1ea,0x4(%esp)
f0100a64:	00 
f0100a65:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100a6c:	e8 23 f6 ff ff       	call   f0100094 <_panic>

	if (only_low_memory) {
f0100a71:	84 c0                	test   %al,%al
f0100a73:	74 4b                	je     f0100ac0 <check_page_free_list+0x89>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100a75:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100a78:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100a7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100a7e:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a81:	89 d0                	mov    %edx,%eax
f0100a83:	2b 05 70 d9 11 f0    	sub    0xf011d970,%eax
f0100a89:	c1 e0 09             	shl    $0x9,%eax
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100a8c:	c1 e8 16             	shr    $0x16,%eax
f0100a8f:	39 c6                	cmp    %eax,%esi
f0100a91:	0f 96 c0             	setbe  %al
f0100a94:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100a97:	8b 4c 85 d8          	mov    -0x28(%ebp,%eax,4),%ecx
f0100a9b:	89 11                	mov    %edx,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100a9d:	89 54 85 d8          	mov    %edx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100aa1:	8b 12                	mov    (%edx),%edx
f0100aa3:	85 d2                	test   %edx,%edx
f0100aa5:	75 da                	jne    f0100a81 <check_page_free_list+0x4a>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100aa7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100aaa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100ab0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ab3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ab6:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ab8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100abb:	a3 40 d5 11 f0       	mov    %eax,0xf011d540
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ac0:	8b 1d 40 d5 11 f0    	mov    0xf011d540,%ebx
f0100ac6:	eb 63                	jmp    f0100b2b <check_page_free_list+0xf4>
f0100ac8:	89 d8                	mov    %ebx,%eax
f0100aca:	2b 05 70 d9 11 f0    	sub    0xf011d970,%eax
f0100ad0:	c1 f8 03             	sar    $0x3,%eax
f0100ad3:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100ad6:	89 c2                	mov    %eax,%edx
f0100ad8:	c1 ea 16             	shr    $0x16,%edx
f0100adb:	39 d6                	cmp    %edx,%esi
f0100add:	76 4a                	jbe    f0100b29 <check_page_free_list+0xf2>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100adf:	89 c2                	mov    %eax,%edx
f0100ae1:	c1 ea 0c             	shr    $0xc,%edx
f0100ae4:	3b 15 68 d9 11 f0    	cmp    0xf011d968,%edx
f0100aea:	72 20                	jb     f0100b0c <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100af0:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f0100af7:	f0 
f0100af8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100aff:	00 
f0100b00:	c7 04 24 37 35 10 f0 	movl   $0xf0103537,(%esp)
f0100b07:	e8 88 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b0c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b13:	00 
f0100b14:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b1b:	00 
	return (void *)(pa + KERNBASE);
f0100b1c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b21:	89 04 24             	mov    %eax,(%esp)
f0100b24:	e8 19 1c 00 00       	call   f0102742 <memset>
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b29:	8b 1b                	mov    (%ebx),%ebx
f0100b2b:	85 db                	test   %ebx,%ebx
f0100b2d:	75 99                	jne    f0100ac8 <check_page_free_list+0x91>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b2f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b34:	e8 35 fe ff ff       	call   f010096e <boot_alloc>
f0100b39:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b3c:	8b 15 40 d5 11 f0    	mov    0xf011d540,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b42:	8b 0d 70 d9 11 f0    	mov    0xf011d970,%ecx
		assert(pp < pages + npages);
f0100b48:	a1 68 d9 11 f0       	mov    0xf011d968,%eax
f0100b4d:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b50:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100b53:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b56:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b59:	be 00 00 00 00       	mov    $0x0,%esi
f0100b5e:	89 4d c0             	mov    %ecx,-0x40(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b61:	e9 91 01 00 00       	jmp    f0100cf7 <check_page_free_list+0x2c0>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b66:	3b 55 c0             	cmp    -0x40(%ebp),%edx
f0100b69:	73 24                	jae    f0100b8f <check_page_free_list+0x158>
f0100b6b:	c7 44 24 0c 45 35 10 	movl   $0xf0103545,0xc(%esp)
f0100b72:	f0 
f0100b73:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100b7a:	f0 
f0100b7b:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
f0100b82:	00 
f0100b83:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100b8a:	e8 05 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b8f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b92:	72 24                	jb     f0100bb8 <check_page_free_list+0x181>
f0100b94:	c7 44 24 0c 66 35 10 	movl   $0xf0103566,0xc(%esp)
f0100b9b:	f0 
f0100b9c:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100ba3:	f0 
f0100ba4:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
f0100bab:	00 
f0100bac:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100bb3:	e8 dc f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bb8:	89 d0                	mov    %edx,%eax
f0100bba:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bbd:	a8 07                	test   $0x7,%al
f0100bbf:	74 24                	je     f0100be5 <check_page_free_list+0x1ae>
f0100bc1:	c7 44 24 0c 30 31 10 	movl   $0xf0103130,0xc(%esp)
f0100bc8:	f0 
f0100bc9:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100bd0:	f0 
f0100bd1:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
f0100bd8:	00 
f0100bd9:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100be0:	e8 af f4 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100be5:	c1 f8 03             	sar    $0x3,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100be8:	c1 e0 0c             	shl    $0xc,%eax
f0100beb:	75 24                	jne    f0100c11 <check_page_free_list+0x1da>
f0100bed:	c7 44 24 0c 7a 35 10 	movl   $0xf010357a,0xc(%esp)
f0100bf4:	f0 
f0100bf5:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100bfc:	f0 
f0100bfd:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
f0100c04:	00 
f0100c05:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100c0c:	e8 83 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c11:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c16:	75 24                	jne    f0100c3c <check_page_free_list+0x205>
f0100c18:	c7 44 24 0c 8b 35 10 	movl   $0xf010358b,0xc(%esp)
f0100c1f:	f0 
f0100c20:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100c27:	f0 
f0100c28:	c7 44 24 04 0a 02 00 	movl   $0x20a,0x4(%esp)
f0100c2f:	00 
f0100c30:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100c37:	e8 58 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c3c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c41:	75 24                	jne    f0100c67 <check_page_free_list+0x230>
f0100c43:	c7 44 24 0c 64 31 10 	movl   $0xf0103164,0xc(%esp)
f0100c4a:	f0 
f0100c4b:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100c52:	f0 
f0100c53:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
f0100c5a:	00 
f0100c5b:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100c62:	e8 2d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c67:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c6c:	75 24                	jne    f0100c92 <check_page_free_list+0x25b>
f0100c6e:	c7 44 24 0c a4 35 10 	movl   $0xf01035a4,0xc(%esp)
f0100c75:	f0 
f0100c76:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100c7d:	f0 
f0100c7e:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
f0100c85:	00 
f0100c86:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100c8d:	e8 02 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c92:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c97:	76 58                	jbe    f0100cf1 <check_page_free_list+0x2ba>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c99:	89 c1                	mov    %eax,%ecx
f0100c9b:	c1 e9 0c             	shr    $0xc,%ecx
f0100c9e:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0100ca1:	77 20                	ja     f0100cc3 <check_page_free_list+0x28c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ca3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100ca7:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100cb6:	00 
f0100cb7:	c7 04 24 37 35 10 f0 	movl   $0xf0103537,(%esp)
f0100cbe:	e8 d1 f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100cc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cc8:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100ccb:	76 27                	jbe    f0100cf4 <check_page_free_list+0x2bd>
f0100ccd:	c7 44 24 0c 88 31 10 	movl   $0xf0103188,0xc(%esp)
f0100cd4:	f0 
f0100cd5:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100cdc:	f0 
f0100cdd:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
f0100ce4:	00 
f0100ce5:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100cec:	e8 a3 f3 ff ff       	call   f0100094 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cf1:	46                   	inc    %esi
f0100cf2:	eb 01                	jmp    f0100cf5 <check_page_free_list+0x2be>
		else
			++nfree_extmem;
f0100cf4:	43                   	inc    %ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cf5:	8b 12                	mov    (%edx),%edx
f0100cf7:	85 d2                	test   %edx,%edx
f0100cf9:	0f 85 67 fe ff ff    	jne    f0100b66 <check_page_free_list+0x12f>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cff:	85 f6                	test   %esi,%esi
f0100d01:	7f 24                	jg     f0100d27 <check_page_free_list+0x2f0>
f0100d03:	c7 44 24 0c be 35 10 	movl   $0xf01035be,0xc(%esp)
f0100d0a:	f0 
f0100d0b:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100d12:	f0 
f0100d13:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
f0100d1a:	00 
f0100d1b:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100d22:	e8 6d f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100d27:	85 db                	test   %ebx,%ebx
f0100d29:	7f 24                	jg     f0100d4f <check_page_free_list+0x318>
f0100d2b:	c7 44 24 0c d0 35 10 	movl   $0xf01035d0,0xc(%esp)
f0100d32:	f0 
f0100d33:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0100d3a:	f0 
f0100d3b:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
f0100d42:	00 
f0100d43:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100d4a:	e8 45 f3 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d4f:	c7 04 24 d0 31 10 f0 	movl   $0xf01031d0,(%esp)
f0100d56:	e8 43 0f 00 00       	call   f0101c9e <cprintf>
}
f0100d5b:	83 c4 4c             	add    $0x4c,%esp
f0100d5e:	5b                   	pop    %ebx
f0100d5f:	5e                   	pop    %esi
f0100d60:	5f                   	pop    %edi
f0100d61:	5d                   	pop    %ebp
f0100d62:	c3                   	ret    

f0100d63 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d63:	55                   	push   %ebp
f0100d64:	89 e5                	mov    %esp,%ebp
f0100d66:	57                   	push   %edi
f0100d67:	56                   	push   %esi
f0100d68:	53                   	push   %ebx
f0100d69:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	// Variable kernBound stores the physical address of the latest nextfree.
	size_t kernBound = (size_t)PADDR(boot_alloc(0));
f0100d6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d71:	e8 f8 fb ff ff       	call   f010096e <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d76:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d7b:	77 20                	ja     f0100d9d <page_init+0x3a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d7d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d81:	c7 44 24 08 e8 30 10 	movl   $0xf01030e8,0x8(%esp)
f0100d88:	f0 
f0100d89:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
f0100d90:	00 
f0100d91:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100d98:	e8 f7 f2 ff ff       	call   f0100094 <_panic>
	// Page initialization
	for (i = 0; i < npages; i++) {
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE)) {
f0100d9d:	8b 35 38 d5 11 f0    	mov    0xf011d538,%esi
	return (physaddr_t)kva - KERNBASE;
f0100da3:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0100da9:	c1 ef 0c             	shr    $0xc,%edi
f0100dac:	8b 1d 40 d5 11 f0    	mov    0xf011d540,%ebx
	// free pages!
	size_t i;
	// Variable kernBound stores the physical address of the latest nextfree.
	size_t kernBound = (size_t)PADDR(boot_alloc(0));
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100db2:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100db7:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dbc:	eb 36                	jmp    f0100df4 <page_init+0x91>
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE)) {
f0100dbe:	85 d2                	test   %edx,%edx
f0100dc0:	74 08                	je     f0100dca <page_init+0x67>
f0100dc2:	39 f2                	cmp    %esi,%edx
f0100dc4:	72 12                	jb     f0100dd8 <page_init+0x75>
f0100dc6:	39 fa                	cmp    %edi,%edx
f0100dc8:	73 0e                	jae    f0100dd8 <page_init+0x75>
			pages[i].pp_ref = 1;
f0100dca:	a1 70 d9 11 f0       	mov    0xf011d970,%eax
f0100dcf:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
f0100dd6:	eb 18                	jmp    f0100df0 <page_init+0x8d>
		}
		// Rest of memory are free
		else {
			pages[i].pp_ref = 0;
f0100dd8:	89 c8                	mov    %ecx,%eax
f0100dda:	03 05 70 d9 11 f0    	add    0xf011d970,%eax
f0100de0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100de6:	89 18                	mov    %ebx,(%eax)
			page_free_list = &pages[i];
f0100de8:	89 cb                	mov    %ecx,%ebx
f0100dea:	03 1d 70 d9 11 f0    	add    0xf011d970,%ebx
	// free pages!
	size_t i;
	// Variable kernBound stores the physical address of the latest nextfree.
	size_t kernBound = (size_t)PADDR(boot_alloc(0));
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100df0:	42                   	inc    %edx
f0100df1:	83 c1 08             	add    $0x8,%ecx
f0100df4:	3b 15 68 d9 11 f0    	cmp    0xf011d968,%edx
f0100dfa:	72 c2                	jb     f0100dbe <page_init+0x5b>
f0100dfc:	89 1d 40 d5 11 f0    	mov    %ebx,0xf011d540
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
}
f0100e02:	83 c4 1c             	add    $0x1c,%esp
f0100e05:	5b                   	pop    %ebx
f0100e06:	5e                   	pop    %esi
f0100e07:	5f                   	pop    %edi
f0100e08:	5d                   	pop    %ebp
f0100e09:	c3                   	ret    

f0100e0a <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e0a:	55                   	push   %ebp
f0100e0b:	89 e5                	mov    %esp,%ebp
f0100e0d:	53                   	push   %ebx
f0100e0e:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo *currPage = page_free_list;
f0100e11:	8b 1d 40 d5 11 f0    	mov    0xf011d540,%ebx
	// Check whether out of free memory
	if (!page_free_list) {
f0100e17:	85 db                	test   %ebx,%ebx
f0100e19:	74 6b                	je     f0100e86 <page_alloc+0x7c>
		return NULL;
	}
	// Set the page without change the reference bit.
	// currPage = ;
	page_free_list = currPage->pp_link;
f0100e1b:	8b 03                	mov    (%ebx),%eax
f0100e1d:	a3 40 d5 11 f0       	mov    %eax,0xf011d540
	currPage->pp_link = NULL;
f0100e22:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100e28:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e2c:	74 58                	je     f0100e86 <page_alloc+0x7c>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e2e:	89 d8                	mov    %ebx,%eax
f0100e30:	2b 05 70 d9 11 f0    	sub    0xf011d970,%eax
f0100e36:	c1 f8 03             	sar    $0x3,%eax
f0100e39:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e3c:	89 c2                	mov    %eax,%edx
f0100e3e:	c1 ea 0c             	shr    $0xc,%edx
f0100e41:	3b 15 68 d9 11 f0    	cmp    0xf011d968,%edx
f0100e47:	72 20                	jb     f0100e69 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e4d:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f0100e54:	f0 
f0100e55:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e5c:	00 
f0100e5d:	c7 04 24 37 35 10 f0 	movl   $0xf0103537,(%esp)
f0100e64:	e8 2b f2 ff ff       	call   f0100094 <_panic>
	{
		memset(page2kva(currPage), 0, PGSIZE);
f0100e69:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100e70:	00 
f0100e71:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100e78:	00 
	return (void *)(pa + KERNBASE);
f0100e79:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e7e:	89 04 24             	mov    %eax,(%esp)
f0100e81:	e8 bc 18 00 00       	call   f0102742 <memset>
	}
	return currPage;
}
f0100e86:	89 d8                	mov    %ebx,%eax
f0100e88:	83 c4 14             	add    $0x14,%esp
f0100e8b:	5b                   	pop    %ebx
f0100e8c:	5d                   	pop    %ebp
f0100e8d:	c3                   	ret    

f0100e8e <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e8e:	55                   	push   %ebp
f0100e8f:	89 e5                	mov    %esp,%ebp
f0100e91:	83 ec 18             	sub    $0x18,%esp
f0100e94:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref) {
f0100e97:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e9c:	74 1c                	je     f0100eba <page_free+0x2c>
		panic("page_free: incorrect reference bit!");
f0100e9e:	c7 44 24 08 f4 31 10 	movl   $0xf01031f4,0x8(%esp)
f0100ea5:	f0 
f0100ea6:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
f0100ead:	00 
f0100eae:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100eb5:	e8 da f1 ff ff       	call   f0100094 <_panic>
	}
	// Update the free list
	pp->pp_link = page_free_list;
f0100eba:	8b 15 40 d5 11 f0    	mov    0xf011d540,%edx
f0100ec0:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ec2:	a3 40 d5 11 f0       	mov    %eax,0xf011d540
}
f0100ec7:	c9                   	leave  
f0100ec8:	c3                   	ret    

f0100ec9 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ec9:	55                   	push   %ebp
f0100eca:	89 e5                	mov    %esp,%ebp
f0100ecc:	83 ec 18             	sub    $0x18,%esp
f0100ecf:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0)
f0100ed2:	8b 50 04             	mov    0x4(%eax),%edx
f0100ed5:	4a                   	dec    %edx
f0100ed6:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100eda:	66 85 d2             	test   %dx,%dx
f0100edd:	75 08                	jne    f0100ee7 <page_decref+0x1e>
		page_free(pp);
f0100edf:	89 04 24             	mov    %eax,(%esp)
f0100ee2:	e8 a7 ff ff ff       	call   f0100e8e <page_free>
}
f0100ee7:	c9                   	leave  
f0100ee8:	c3                   	ret    

f0100ee9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100ee9:	55                   	push   %ebp
f0100eea:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100eec:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef1:	5d                   	pop    %ebp
f0100ef2:	c3                   	ret    

f0100ef3 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100ef3:	55                   	push   %ebp
f0100ef4:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0100ef6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100efb:	5d                   	pop    %ebp
f0100efc:	c3                   	ret    

f0100efd <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100efd:	55                   	push   %ebp
f0100efe:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0100f00:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f05:	5d                   	pop    %ebp
f0100f06:	c3                   	ret    

f0100f07 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100f07:	55                   	push   %ebp
f0100f08:	89 e5                	mov    %esp,%ebp
f0100f0a:	57                   	push   %edi
f0100f0b:	56                   	push   %esi
f0100f0c:	53                   	push   %ebx
f0100f0d:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100f10:	b8 15 00 00 00       	mov    $0x15,%eax
f0100f15:	e8 2b fa ff ff       	call   f0100945 <nvram_read>
f0100f1a:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100f1c:	b8 17 00 00 00       	mov    $0x17,%eax
f0100f21:	e8 1f fa ff ff       	call   f0100945 <nvram_read>
f0100f26:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100f28:	b8 34 00 00 00       	mov    $0x34,%eax
f0100f2d:	e8 13 fa ff ff       	call   f0100945 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100f32:	c1 e0 06             	shl    $0x6,%eax
f0100f35:	74 07                	je     f0100f3e <mem_init+0x37>
		totalmem = 16 * 1024 + ext16mem;
f0100f37:	05 00 40 00 00       	add    $0x4000,%eax
f0100f3c:	eb 0c                	jmp    f0100f4a <mem_init+0x43>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
	else
		totalmem = basemem;
f0100f3e:	89 d8                	mov    %ebx,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
		totalmem = 16 * 1024 + ext16mem;
	else if (extmem)
f0100f40:	85 f6                	test   %esi,%esi
f0100f42:	74 06                	je     f0100f4a <mem_init+0x43>
		totalmem = 1 * 1024 + extmem;
f0100f44:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100f4a:	89 c2                	mov    %eax,%edx
f0100f4c:	c1 ea 02             	shr    $0x2,%edx
f0100f4f:	89 15 68 d9 11 f0    	mov    %edx,0xf011d968
	npages_basemem = basemem / (PGSIZE / 1024);
f0100f55:	89 da                	mov    %ebx,%edx
f0100f57:	c1 ea 02             	shr    $0x2,%edx
f0100f5a:	89 15 38 d5 11 f0    	mov    %edx,0xf011d538

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f60:	89 c2                	mov    %eax,%edx
f0100f62:	29 da                	sub    %ebx,%edx
f0100f64:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0100f68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100f6c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100f70:	c7 04 24 18 32 10 f0 	movl   $0xf0103218,(%esp)
f0100f77:	e8 22 0d 00 00       	call   f0101c9e <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100f7c:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100f81:	e8 e8 f9 ff ff       	call   f010096e <boot_alloc>
f0100f86:	a3 6c d9 11 f0       	mov    %eax,0xf011d96c
	memset(kern_pgdir, 0, PGSIZE);
f0100f8b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0100f92:	00 
f0100f93:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100f9a:	00 
f0100f9b:	89 04 24             	mov    %eax,(%esp)
f0100f9e:	e8 9f 17 00 00       	call   f0102742 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100fa3:	a1 6c d9 11 f0       	mov    0xf011d96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100fa8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100fad:	77 20                	ja     f0100fcf <mem_init+0xc8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100faf:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100fb3:	c7 44 24 08 e8 30 10 	movl   $0xf01030e8,0x8(%esp)
f0100fba:	f0 
f0100fbb:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100fc2:	00 
f0100fc3:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0100fca:	e8 c5 f0 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100fcf:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100fd5:	83 ca 05             	or     $0x5,%edx
f0100fd8:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0100fde:	a1 68 d9 11 f0       	mov    0xf011d968,%eax
f0100fe3:	c1 e0 03             	shl    $0x3,%eax
f0100fe6:	e8 83 f9 ff ff       	call   f010096e <boot_alloc>
f0100feb:	a3 70 d9 11 f0       	mov    %eax,0xf011d970
	cprintf("size is %x %x\n", sizeof(struct PageInfo) * npages, npages);
f0100ff0:	a1 68 d9 11 f0       	mov    0xf011d968,%eax
f0100ff5:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ff9:	c1 e0 03             	shl    $0x3,%eax
f0100ffc:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101000:	c7 04 24 e1 35 10 f0 	movl   $0xf01035e1,(%esp)
f0101007:	e8 92 0c 00 00       	call   f0101c9e <cprintf>
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f010100c:	a1 68 d9 11 f0       	mov    0xf011d968,%eax
f0101011:	c1 e0 03             	shl    $0x3,%eax
f0101014:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010101f:	00 
f0101020:	a1 70 d9 11 f0       	mov    0xf011d970,%eax
f0101025:	89 04 24             	mov    %eax,(%esp)
f0101028:	e8 15 17 00 00       	call   f0102742 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010102d:	e8 31 fd ff ff       	call   f0100d63 <page_init>

	check_page_free_list(1);
f0101032:	b8 01 00 00 00       	mov    $0x1,%eax
f0101037:	e8 fb f9 ff ff       	call   f0100a37 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010103c:	83 3d 70 d9 11 f0 00 	cmpl   $0x0,0xf011d970
f0101043:	75 1c                	jne    f0101061 <mem_init+0x15a>
		panic("'pages' is a null pointer!");
f0101045:	c7 44 24 08 f0 35 10 	movl   $0xf01035f0,0x8(%esp)
f010104c:	f0 
f010104d:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
f0101054:	00 
f0101055:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010105c:	e8 33 f0 ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101061:	a1 40 d5 11 f0       	mov    0xf011d540,%eax
f0101066:	bb 00 00 00 00       	mov    $0x0,%ebx
f010106b:	eb 03                	jmp    f0101070 <mem_init+0x169>
		++nfree;
f010106d:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010106e:	8b 00                	mov    (%eax),%eax
f0101070:	85 c0                	test   %eax,%eax
f0101072:	75 f9                	jne    f010106d <mem_init+0x166>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010107b:	e8 8a fd ff ff       	call   f0100e0a <page_alloc>
f0101080:	89 c6                	mov    %eax,%esi
f0101082:	85 c0                	test   %eax,%eax
f0101084:	75 24                	jne    f01010aa <mem_init+0x1a3>
f0101086:	c7 44 24 0c 0b 36 10 	movl   $0xf010360b,0xc(%esp)
f010108d:	f0 
f010108e:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101095:	f0 
f0101096:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
f010109d:	00 
f010109e:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01010a5:	e8 ea ef ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01010aa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010b1:	e8 54 fd ff ff       	call   f0100e0a <page_alloc>
f01010b6:	89 c7                	mov    %eax,%edi
f01010b8:	85 c0                	test   %eax,%eax
f01010ba:	75 24                	jne    f01010e0 <mem_init+0x1d9>
f01010bc:	c7 44 24 0c 21 36 10 	movl   $0xf0103621,0xc(%esp)
f01010c3:	f0 
f01010c4:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01010cb:	f0 
f01010cc:	c7 44 24 04 32 02 00 	movl   $0x232,0x4(%esp)
f01010d3:	00 
f01010d4:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01010db:	e8 b4 ef ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01010e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01010e7:	e8 1e fd ff ff       	call   f0100e0a <page_alloc>
f01010ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01010ef:	85 c0                	test   %eax,%eax
f01010f1:	75 24                	jne    f0101117 <mem_init+0x210>
f01010f3:	c7 44 24 0c 37 36 10 	movl   $0xf0103637,0xc(%esp)
f01010fa:	f0 
f01010fb:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101102:	f0 
f0101103:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
f010110a:	00 
f010110b:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101112:	e8 7d ef ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101117:	39 fe                	cmp    %edi,%esi
f0101119:	75 24                	jne    f010113f <mem_init+0x238>
f010111b:	c7 44 24 0c 4d 36 10 	movl   $0xf010364d,0xc(%esp)
f0101122:	f0 
f0101123:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f010112a:	f0 
f010112b:	c7 44 24 04 36 02 00 	movl   $0x236,0x4(%esp)
f0101132:	00 
f0101133:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010113a:	e8 55 ef ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010113f:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101142:	74 05                	je     f0101149 <mem_init+0x242>
f0101144:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101147:	75 24                	jne    f010116d <mem_init+0x266>
f0101149:	c7 44 24 0c 54 32 10 	movl   $0xf0103254,0xc(%esp)
f0101150:	f0 
f0101151:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101158:	f0 
f0101159:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
f0101160:	00 
f0101161:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101168:	e8 27 ef ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010116d:	8b 15 70 d9 11 f0    	mov    0xf011d970,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101173:	a1 68 d9 11 f0       	mov    0xf011d968,%eax
f0101178:	c1 e0 0c             	shl    $0xc,%eax
f010117b:	89 f1                	mov    %esi,%ecx
f010117d:	29 d1                	sub    %edx,%ecx
f010117f:	c1 f9 03             	sar    $0x3,%ecx
f0101182:	c1 e1 0c             	shl    $0xc,%ecx
f0101185:	39 c1                	cmp    %eax,%ecx
f0101187:	72 24                	jb     f01011ad <mem_init+0x2a6>
f0101189:	c7 44 24 0c 5f 36 10 	movl   $0xf010365f,0xc(%esp)
f0101190:	f0 
f0101191:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101198:	f0 
f0101199:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
f01011a0:	00 
f01011a1:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01011a8:	e8 e7 ee ff ff       	call   f0100094 <_panic>
f01011ad:	89 f9                	mov    %edi,%ecx
f01011af:	29 d1                	sub    %edx,%ecx
f01011b1:	c1 f9 03             	sar    $0x3,%ecx
f01011b4:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01011b7:	39 c8                	cmp    %ecx,%eax
f01011b9:	77 24                	ja     f01011df <mem_init+0x2d8>
f01011bb:	c7 44 24 0c 7c 36 10 	movl   $0xf010367c,0xc(%esp)
f01011c2:	f0 
f01011c3:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01011ca:	f0 
f01011cb:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
f01011d2:	00 
f01011d3:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01011da:	e8 b5 ee ff ff       	call   f0100094 <_panic>
f01011df:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01011e2:	29 d1                	sub    %edx,%ecx
f01011e4:	89 ca                	mov    %ecx,%edx
f01011e6:	c1 fa 03             	sar    $0x3,%edx
f01011e9:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f01011ec:	39 d0                	cmp    %edx,%eax
f01011ee:	77 24                	ja     f0101214 <mem_init+0x30d>
f01011f0:	c7 44 24 0c 99 36 10 	movl   $0xf0103699,0xc(%esp)
f01011f7:	f0 
f01011f8:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01011ff:	f0 
f0101200:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
f0101207:	00 
f0101208:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010120f:	e8 80 ee ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101214:	a1 40 d5 11 f0       	mov    0xf011d540,%eax
f0101219:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010121c:	c7 05 40 d5 11 f0 00 	movl   $0x0,0xf011d540
f0101223:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101226:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010122d:	e8 d8 fb ff ff       	call   f0100e0a <page_alloc>
f0101232:	85 c0                	test   %eax,%eax
f0101234:	74 24                	je     f010125a <mem_init+0x353>
f0101236:	c7 44 24 0c b6 36 10 	movl   $0xf01036b6,0xc(%esp)
f010123d:	f0 
f010123e:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101245:	f0 
f0101246:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
f010124d:	00 
f010124e:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101255:	e8 3a ee ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010125a:	89 34 24             	mov    %esi,(%esp)
f010125d:	e8 2c fc ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f0101262:	89 3c 24             	mov    %edi,(%esp)
f0101265:	e8 24 fc ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f010126a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010126d:	89 04 24             	mov    %eax,(%esp)
f0101270:	e8 19 fc ff ff       	call   f0100e8e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101275:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010127c:	e8 89 fb ff ff       	call   f0100e0a <page_alloc>
f0101281:	89 c6                	mov    %eax,%esi
f0101283:	85 c0                	test   %eax,%eax
f0101285:	75 24                	jne    f01012ab <mem_init+0x3a4>
f0101287:	c7 44 24 0c 0b 36 10 	movl   $0xf010360b,0xc(%esp)
f010128e:	f0 
f010128f:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101296:	f0 
f0101297:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
f010129e:	00 
f010129f:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01012a6:	e8 e9 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012b2:	e8 53 fb ff ff       	call   f0100e0a <page_alloc>
f01012b7:	89 c7                	mov    %eax,%edi
f01012b9:	85 c0                	test   %eax,%eax
f01012bb:	75 24                	jne    f01012e1 <mem_init+0x3da>
f01012bd:	c7 44 24 0c 21 36 10 	movl   $0xf0103621,0xc(%esp)
f01012c4:	f0 
f01012c5:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01012cc:	f0 
f01012cd:	c7 44 24 04 49 02 00 	movl   $0x249,0x4(%esp)
f01012d4:	00 
f01012d5:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01012dc:	e8 b3 ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01012e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012e8:	e8 1d fb ff ff       	call   f0100e0a <page_alloc>
f01012ed:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012f0:	85 c0                	test   %eax,%eax
f01012f2:	75 24                	jne    f0101318 <mem_init+0x411>
f01012f4:	c7 44 24 0c 37 36 10 	movl   $0xf0103637,0xc(%esp)
f01012fb:	f0 
f01012fc:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101303:	f0 
f0101304:	c7 44 24 04 4a 02 00 	movl   $0x24a,0x4(%esp)
f010130b:	00 
f010130c:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101313:	e8 7c ed ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101318:	39 fe                	cmp    %edi,%esi
f010131a:	75 24                	jne    f0101340 <mem_init+0x439>
f010131c:	c7 44 24 0c 4d 36 10 	movl   $0xf010364d,0xc(%esp)
f0101323:	f0 
f0101324:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f010132b:	f0 
f010132c:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
f0101333:	00 
f0101334:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010133b:	e8 54 ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101340:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101343:	74 05                	je     f010134a <mem_init+0x443>
f0101345:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101348:	75 24                	jne    f010136e <mem_init+0x467>
f010134a:	c7 44 24 0c 54 32 10 	movl   $0xf0103254,0xc(%esp)
f0101351:	f0 
f0101352:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101359:	f0 
f010135a:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
f0101361:	00 
f0101362:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101369:	e8 26 ed ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010136e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101375:	e8 90 fa ff ff       	call   f0100e0a <page_alloc>
f010137a:	85 c0                	test   %eax,%eax
f010137c:	74 24                	je     f01013a2 <mem_init+0x49b>
f010137e:	c7 44 24 0c b6 36 10 	movl   $0xf01036b6,0xc(%esp)
f0101385:	f0 
f0101386:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f010138d:	f0 
f010138e:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f0101395:	00 
f0101396:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010139d:	e8 f2 ec ff ff       	call   f0100094 <_panic>
f01013a2:	89 f0                	mov    %esi,%eax
f01013a4:	2b 05 70 d9 11 f0    	sub    0xf011d970,%eax
f01013aa:	c1 f8 03             	sar    $0x3,%eax
f01013ad:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013b0:	89 c2                	mov    %eax,%edx
f01013b2:	c1 ea 0c             	shr    $0xc,%edx
f01013b5:	3b 15 68 d9 11 f0    	cmp    0xf011d968,%edx
f01013bb:	72 20                	jb     f01013dd <mem_init+0x4d6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013bd:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01013c1:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f01013c8:	f0 
f01013c9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01013d0:	00 
f01013d1:	c7 04 24 37 35 10 f0 	movl   $0xf0103537,(%esp)
f01013d8:	e8 b7 ec ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01013dd:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01013e4:	00 
f01013e5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01013ec:	00 
	return (void *)(pa + KERNBASE);
f01013ed:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013f2:	89 04 24             	mov    %eax,(%esp)
f01013f5:	e8 48 13 00 00       	call   f0102742 <memset>
	page_free(pp0);
f01013fa:	89 34 24             	mov    %esi,(%esp)
f01013fd:	e8 8c fa ff ff       	call   f0100e8e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101402:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101409:	e8 fc f9 ff ff       	call   f0100e0a <page_alloc>
f010140e:	85 c0                	test   %eax,%eax
f0101410:	75 24                	jne    f0101436 <mem_init+0x52f>
f0101412:	c7 44 24 0c c5 36 10 	movl   $0xf01036c5,0xc(%esp)
f0101419:	f0 
f010141a:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101421:	f0 
f0101422:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f0101429:	00 
f010142a:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101431:	e8 5e ec ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101436:	39 c6                	cmp    %eax,%esi
f0101438:	74 24                	je     f010145e <mem_init+0x557>
f010143a:	c7 44 24 0c e3 36 10 	movl   $0xf01036e3,0xc(%esp)
f0101441:	f0 
f0101442:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101449:	f0 
f010144a:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
f0101451:	00 
f0101452:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101459:	e8 36 ec ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010145e:	89 f2                	mov    %esi,%edx
f0101460:	2b 15 70 d9 11 f0    	sub    0xf011d970,%edx
f0101466:	c1 fa 03             	sar    $0x3,%edx
f0101469:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010146c:	89 d0                	mov    %edx,%eax
f010146e:	c1 e8 0c             	shr    $0xc,%eax
f0101471:	3b 05 68 d9 11 f0    	cmp    0xf011d968,%eax
f0101477:	72 20                	jb     f0101499 <mem_init+0x592>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101479:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010147d:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f0101484:	f0 
f0101485:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010148c:	00 
f010148d:	c7 04 24 37 35 10 f0 	movl   $0xf0103537,(%esp)
f0101494:	e8 fb eb ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101499:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010149f:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01014a5:	80 38 00             	cmpb   $0x0,(%eax)
f01014a8:	74 24                	je     f01014ce <mem_init+0x5c7>
f01014aa:	c7 44 24 0c f3 36 10 	movl   $0xf01036f3,0xc(%esp)
f01014b1:	f0 
f01014b2:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01014b9:	f0 
f01014ba:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
f01014c1:	00 
f01014c2:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01014c9:	e8 c6 eb ff ff       	call   f0100094 <_panic>
f01014ce:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01014cf:	39 d0                	cmp    %edx,%eax
f01014d1:	75 d2                	jne    f01014a5 <mem_init+0x59e>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01014d3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01014d6:	89 0d 40 d5 11 f0    	mov    %ecx,0xf011d540

	// free the pages we took
	page_free(pp0);
f01014dc:	89 34 24             	mov    %esi,(%esp)
f01014df:	e8 aa f9 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f01014e4:	89 3c 24             	mov    %edi,(%esp)
f01014e7:	e8 a2 f9 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f01014ec:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01014ef:	89 04 24             	mov    %eax,(%esp)
f01014f2:	e8 97 f9 ff ff       	call   f0100e8e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014f7:	a1 40 d5 11 f0       	mov    0xf011d540,%eax
f01014fc:	eb 03                	jmp    f0101501 <mem_init+0x5fa>
		--nfree;
f01014fe:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014ff:	8b 00                	mov    (%eax),%eax
f0101501:	85 c0                	test   %eax,%eax
f0101503:	75 f9                	jne    f01014fe <mem_init+0x5f7>
		--nfree;
	assert(nfree == 0);
f0101505:	85 db                	test   %ebx,%ebx
f0101507:	74 24                	je     f010152d <mem_init+0x626>
f0101509:	c7 44 24 0c fd 36 10 	movl   $0xf01036fd,0xc(%esp)
f0101510:	f0 
f0101511:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101518:	f0 
f0101519:	c7 44 24 04 64 02 00 	movl   $0x264,0x4(%esp)
f0101520:	00 
f0101521:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101528:	e8 67 eb ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010152d:	c7 04 24 74 32 10 f0 	movl   $0xf0103274,(%esp)
f0101534:	e8 65 07 00 00       	call   f0101c9e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101539:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101540:	e8 c5 f8 ff ff       	call   f0100e0a <page_alloc>
f0101545:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101548:	85 c0                	test   %eax,%eax
f010154a:	75 24                	jne    f0101570 <mem_init+0x669>
f010154c:	c7 44 24 0c 0b 36 10 	movl   $0xf010360b,0xc(%esp)
f0101553:	f0 
f0101554:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f010155b:	f0 
f010155c:	c7 44 24 04 bd 02 00 	movl   $0x2bd,0x4(%esp)
f0101563:	00 
f0101564:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010156b:	e8 24 eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101577:	e8 8e f8 ff ff       	call   f0100e0a <page_alloc>
f010157c:	89 c6                	mov    %eax,%esi
f010157e:	85 c0                	test   %eax,%eax
f0101580:	75 24                	jne    f01015a6 <mem_init+0x69f>
f0101582:	c7 44 24 0c 21 36 10 	movl   $0xf0103621,0xc(%esp)
f0101589:	f0 
f010158a:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101591:	f0 
f0101592:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f0101599:	00 
f010159a:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01015a1:	e8 ee ea ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01015a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015ad:	e8 58 f8 ff ff       	call   f0100e0a <page_alloc>
f01015b2:	89 c3                	mov    %eax,%ebx
f01015b4:	85 c0                	test   %eax,%eax
f01015b6:	75 24                	jne    f01015dc <mem_init+0x6d5>
f01015b8:	c7 44 24 0c 37 36 10 	movl   $0xf0103637,0xc(%esp)
f01015bf:	f0 
f01015c0:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01015c7:	f0 
f01015c8:	c7 44 24 04 bf 02 00 	movl   $0x2bf,0x4(%esp)
f01015cf:	00 
f01015d0:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01015d7:	e8 b8 ea ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01015dc:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f01015df:	75 24                	jne    f0101605 <mem_init+0x6fe>
f01015e1:	c7 44 24 0c 4d 36 10 	movl   $0xf010364d,0xc(%esp)
f01015e8:	f0 
f01015e9:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01015f0:	f0 
f01015f1:	c7 44 24 04 c2 02 00 	movl   $0x2c2,0x4(%esp)
f01015f8:	00 
f01015f9:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101600:	e8 8f ea ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101605:	39 c6                	cmp    %eax,%esi
f0101607:	74 05                	je     f010160e <mem_init+0x707>
f0101609:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010160c:	75 24                	jne    f0101632 <mem_init+0x72b>
f010160e:	c7 44 24 0c 54 32 10 	movl   $0xf0103254,0xc(%esp)
f0101615:	f0 
f0101616:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f010161d:	f0 
f010161e:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0101625:	00 
f0101626:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010162d:	e8 62 ea ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f0101632:	c7 05 40 d5 11 f0 00 	movl   $0x0,0xf011d540
f0101639:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010163c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101643:	e8 c2 f7 ff ff       	call   f0100e0a <page_alloc>
f0101648:	85 c0                	test   %eax,%eax
f010164a:	74 24                	je     f0101670 <mem_init+0x769>
f010164c:	c7 44 24 0c b6 36 10 	movl   $0xf01036b6,0xc(%esp)
f0101653:	f0 
f0101654:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f010165b:	f0 
f010165c:	c7 44 24 04 ca 02 00 	movl   $0x2ca,0x4(%esp)
f0101663:	00 
f0101664:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010166b:	e8 24 ea ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101670:	8b 3d 6c d9 11 f0    	mov    0xf011d96c,%edi
f0101676:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101679:	89 44 24 08          	mov    %eax,0x8(%esp)
f010167d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101684:	00 
f0101685:	89 3c 24             	mov    %edi,(%esp)
f0101688:	e8 70 f8 ff ff       	call   f0100efd <page_lookup>
f010168d:	85 c0                	test   %eax,%eax
f010168f:	74 24                	je     f01016b5 <mem_init+0x7ae>
f0101691:	c7 44 24 0c 94 32 10 	movl   $0xf0103294,0xc(%esp)
f0101698:	f0 
f0101699:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01016a0:	f0 
f01016a1:	c7 44 24 04 cd 02 00 	movl   $0x2cd,0x4(%esp)
f01016a8:	00 
f01016a9:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01016b0:	e8 df e9 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016b5:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01016bc:	00 
f01016bd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01016c4:	00 
f01016c5:	89 74 24 04          	mov    %esi,0x4(%esp)
f01016c9:	89 3c 24             	mov    %edi,(%esp)
f01016cc:	e8 22 f8 ff ff       	call   f0100ef3 <page_insert>
f01016d1:	85 c0                	test   %eax,%eax
f01016d3:	78 24                	js     f01016f9 <mem_init+0x7f2>
f01016d5:	c7 44 24 0c cc 32 10 	movl   $0xf01032cc,0xc(%esp)
f01016dc:	f0 
f01016dd:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01016e4:	f0 
f01016e5:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f01016ec:	00 
f01016ed:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01016f4:	e8 9b e9 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01016f9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016fc:	89 04 24             	mov    %eax,(%esp)
f01016ff:	e8 8a f7 ff ff       	call   f0100e8e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101704:	8b 3d 6c d9 11 f0    	mov    0xf011d96c,%edi
f010170a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101711:	00 
f0101712:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101719:	00 
f010171a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010171e:	89 3c 24             	mov    %edi,(%esp)
f0101721:	e8 cd f7 ff ff       	call   f0100ef3 <page_insert>
f0101726:	85 c0                	test   %eax,%eax
f0101728:	74 24                	je     f010174e <mem_init+0x847>
f010172a:	c7 44 24 0c fc 32 10 	movl   $0xf01032fc,0xc(%esp)
f0101731:	f0 
f0101732:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101739:	f0 
f010173a:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f0101741:	00 
f0101742:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101749:	e8 46 e9 ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010174e:	8b 0d 70 d9 11 f0    	mov    0xf011d970,%ecx
f0101754:	89 4d d0             	mov    %ecx,-0x30(%ebp)
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101757:	8b 17                	mov    (%edi),%edx
f0101759:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010175f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101762:	29 c8                	sub    %ecx,%eax
f0101764:	c1 f8 03             	sar    $0x3,%eax
f0101767:	c1 e0 0c             	shl    $0xc,%eax
f010176a:	39 c2                	cmp    %eax,%edx
f010176c:	74 24                	je     f0101792 <mem_init+0x88b>
f010176e:	c7 44 24 0c 2c 33 10 	movl   $0xf010332c,0xc(%esp)
f0101775:	f0 
f0101776:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f010177d:	f0 
f010177e:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0101785:	00 
f0101786:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f010178d:	e8 02 e9 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101792:	ba 00 00 00 00       	mov    $0x0,%edx
f0101797:	89 f8                	mov    %edi,%eax
f0101799:	e8 3a f1 ff ff       	call   f01008d8 <check_va2pa>
f010179e:	89 f2                	mov    %esi,%edx
f01017a0:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01017a3:	c1 fa 03             	sar    $0x3,%edx
f01017a6:	c1 e2 0c             	shl    $0xc,%edx
f01017a9:	39 d0                	cmp    %edx,%eax
f01017ab:	74 24                	je     f01017d1 <mem_init+0x8ca>
f01017ad:	c7 44 24 0c 54 33 10 	movl   $0xf0103354,0xc(%esp)
f01017b4:	f0 
f01017b5:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01017bc:	f0 
f01017bd:	c7 44 24 04 d6 02 00 	movl   $0x2d6,0x4(%esp)
f01017c4:	00 
f01017c5:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01017cc:	e8 c3 e8 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01017d1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01017d6:	74 24                	je     f01017fc <mem_init+0x8f5>
f01017d8:	c7 44 24 0c 08 37 10 	movl   $0xf0103708,0xc(%esp)
f01017df:	f0 
f01017e0:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01017e7:	f0 
f01017e8:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f01017ef:	00 
f01017f0:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01017f7:	e8 98 e8 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01017fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01017ff:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101804:	74 24                	je     f010182a <mem_init+0x923>
f0101806:	c7 44 24 0c 19 37 10 	movl   $0xf0103719,0xc(%esp)
f010180d:	f0 
f010180e:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101815:	f0 
f0101816:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f010181d:	00 
f010181e:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101825:	e8 6a e8 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010182a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101831:	00 
f0101832:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101839:	00 
f010183a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010183e:	89 3c 24             	mov    %edi,(%esp)
f0101841:	e8 ad f6 ff ff       	call   f0100ef3 <page_insert>
f0101846:	85 c0                	test   %eax,%eax
f0101848:	74 24                	je     f010186e <mem_init+0x967>
f010184a:	c7 44 24 0c 84 33 10 	movl   $0xf0103384,0xc(%esp)
f0101851:	f0 
f0101852:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101859:	f0 
f010185a:	c7 44 24 04 db 02 00 	movl   $0x2db,0x4(%esp)
f0101861:	00 
f0101862:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101869:	e8 26 e8 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010186e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101873:	89 f8                	mov    %edi,%eax
f0101875:	e8 5e f0 ff ff       	call   f01008d8 <check_va2pa>
f010187a:	89 da                	mov    %ebx,%edx
f010187c:	2b 55 d0             	sub    -0x30(%ebp),%edx
f010187f:	c1 fa 03             	sar    $0x3,%edx
f0101882:	c1 e2 0c             	shl    $0xc,%edx
f0101885:	39 d0                	cmp    %edx,%eax
f0101887:	74 24                	je     f01018ad <mem_init+0x9a6>
f0101889:	c7 44 24 0c c0 33 10 	movl   $0xf01033c0,0xc(%esp)
f0101890:	f0 
f0101891:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101898:	f0 
f0101899:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f01018a0:	00 
f01018a1:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01018a8:	e8 e7 e7 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f01018ad:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018b2:	74 24                	je     f01018d8 <mem_init+0x9d1>
f01018b4:	c7 44 24 0c 2a 37 10 	movl   $0xf010372a,0xc(%esp)
f01018bb:	f0 
f01018bc:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01018c3:	f0 
f01018c4:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f01018cb:	00 
f01018cc:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01018d3:	e8 bc e7 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01018d8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01018df:	e8 26 f5 ff ff       	call   f0100e0a <page_alloc>
f01018e4:	85 c0                	test   %eax,%eax
f01018e6:	74 24                	je     f010190c <mem_init+0xa05>
f01018e8:	c7 44 24 0c b6 36 10 	movl   $0xf01036b6,0xc(%esp)
f01018ef:	f0 
f01018f0:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01018f7:	f0 
f01018f8:	c7 44 24 04 e0 02 00 	movl   $0x2e0,0x4(%esp)
f01018ff:	00 
f0101900:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101907:	e8 88 e7 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010190c:	8b 35 6c d9 11 f0    	mov    0xf011d96c,%esi
f0101912:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101919:	00 
f010191a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101921:	00 
f0101922:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101926:	89 34 24             	mov    %esi,(%esp)
f0101929:	e8 c5 f5 ff ff       	call   f0100ef3 <page_insert>
f010192e:	85 c0                	test   %eax,%eax
f0101930:	74 24                	je     f0101956 <mem_init+0xa4f>
f0101932:	c7 44 24 0c 84 33 10 	movl   $0xf0103384,0xc(%esp)
f0101939:	f0 
f010193a:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101941:	f0 
f0101942:	c7 44 24 04 e3 02 00 	movl   $0x2e3,0x4(%esp)
f0101949:	00 
f010194a:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101951:	e8 3e e7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101956:	ba 00 10 00 00       	mov    $0x1000,%edx
f010195b:	89 f0                	mov    %esi,%eax
f010195d:	e8 76 ef ff ff       	call   f01008d8 <check_va2pa>
f0101962:	89 da                	mov    %ebx,%edx
f0101964:	2b 15 70 d9 11 f0    	sub    0xf011d970,%edx
f010196a:	c1 fa 03             	sar    $0x3,%edx
f010196d:	c1 e2 0c             	shl    $0xc,%edx
f0101970:	39 d0                	cmp    %edx,%eax
f0101972:	74 24                	je     f0101998 <mem_init+0xa91>
f0101974:	c7 44 24 0c c0 33 10 	movl   $0xf01033c0,0xc(%esp)
f010197b:	f0 
f010197c:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101983:	f0 
f0101984:	c7 44 24 04 e4 02 00 	movl   $0x2e4,0x4(%esp)
f010198b:	00 
f010198c:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101993:	e8 fc e6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101998:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010199d:	74 24                	je     f01019c3 <mem_init+0xabc>
f010199f:	c7 44 24 0c 2a 37 10 	movl   $0xf010372a,0xc(%esp)
f01019a6:	f0 
f01019a7:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01019ae:	f0 
f01019af:	c7 44 24 04 e5 02 00 	movl   $0x2e5,0x4(%esp)
f01019b6:	00 
f01019b7:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01019be:	e8 d1 e6 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f01019c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01019ca:	e8 3b f4 ff ff       	call   f0100e0a <page_alloc>
f01019cf:	85 c0                	test   %eax,%eax
f01019d1:	74 24                	je     f01019f7 <mem_init+0xaf0>
f01019d3:	c7 44 24 0c b6 36 10 	movl   $0xf01036b6,0xc(%esp)
f01019da:	f0 
f01019db:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f01019e2:	f0 
f01019e3:	c7 44 24 04 e9 02 00 	movl   $0x2e9,0x4(%esp)
f01019ea:	00 
f01019eb:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f01019f2:	e8 9d e6 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f01019f7:	8b 35 6c d9 11 f0    	mov    0xf011d96c,%esi
f01019fd:	8b 0e                	mov    (%esi),%ecx
f01019ff:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101a02:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101a08:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a0b:	89 c8                	mov    %ecx,%eax
f0101a0d:	c1 e8 0c             	shr    $0xc,%eax
f0101a10:	3b 05 68 d9 11 f0    	cmp    0xf011d968,%eax
f0101a16:	72 20                	jb     f0101a38 <mem_init+0xb31>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a18:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0101a1c:	c7 44 24 08 c4 30 10 	movl   $0xf01030c4,0x8(%esp)
f0101a23:	f0 
f0101a24:	c7 44 24 04 ec 02 00 	movl   $0x2ec,0x4(%esp)
f0101a2b:	00 
f0101a2c:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101a33:	e8 5c e6 ff ff       	call   f0100094 <_panic>
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a38:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101a3f:	00 
f0101a40:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101a47:	00 
f0101a48:	89 34 24             	mov    %esi,(%esp)
f0101a4b:	e8 99 f4 ff ff       	call   f0100ee9 <pgdir_walk>
f0101a50:	89 c7                	mov    %eax,%edi
f0101a52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101a55:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101a5a:	39 c7                	cmp    %eax,%edi
f0101a5c:	74 24                	je     f0101a82 <mem_init+0xb7b>
f0101a5e:	c7 44 24 0c f0 33 10 	movl   $0xf01033f0,0xc(%esp)
f0101a65:	f0 
f0101a66:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101a6d:	f0 
f0101a6e:	c7 44 24 04 ed 02 00 	movl   $0x2ed,0x4(%esp)
f0101a75:	00 
f0101a76:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101a7d:	e8 12 e6 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101a82:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101a89:	00 
f0101a8a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a91:	00 
f0101a92:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a96:	89 34 24             	mov    %esi,(%esp)
f0101a99:	e8 55 f4 ff ff       	call   f0100ef3 <page_insert>
f0101a9e:	85 c0                	test   %eax,%eax
f0101aa0:	74 24                	je     f0101ac6 <mem_init+0xbbf>
f0101aa2:	c7 44 24 0c 30 34 10 	movl   $0xf0103430,0xc(%esp)
f0101aa9:	f0 
f0101aaa:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101ab1:	f0 
f0101ab2:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0101ab9:	00 
f0101aba:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101ac1:	e8 ce e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101ac6:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101acb:	89 f0                	mov    %esi,%eax
f0101acd:	e8 06 ee ff ff       	call   f01008d8 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ad2:	89 da                	mov    %ebx,%edx
f0101ad4:	2b 15 70 d9 11 f0    	sub    0xf011d970,%edx
f0101ada:	c1 fa 03             	sar    $0x3,%edx
f0101add:	c1 e2 0c             	shl    $0xc,%edx
f0101ae0:	39 d0                	cmp    %edx,%eax
f0101ae2:	74 24                	je     f0101b08 <mem_init+0xc01>
f0101ae4:	c7 44 24 0c c0 33 10 	movl   $0xf01033c0,0xc(%esp)
f0101aeb:	f0 
f0101aec:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101af3:	f0 
f0101af4:	c7 44 24 04 f1 02 00 	movl   $0x2f1,0x4(%esp)
f0101afb:	00 
f0101afc:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101b03:	e8 8c e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101b08:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b0d:	74 24                	je     f0101b33 <mem_init+0xc2c>
f0101b0f:	c7 44 24 0c 2a 37 10 	movl   $0xf010372a,0xc(%esp)
f0101b16:	f0 
f0101b17:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101b1e:	f0 
f0101b1f:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f0101b26:	00 
f0101b27:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101b2e:	e8 61 e5 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101b33:	8b 3f                	mov    (%edi),%edi
f0101b35:	f7 c7 04 00 00 00    	test   $0x4,%edi
f0101b3b:	75 24                	jne    f0101b61 <mem_init+0xc5a>
f0101b3d:	c7 44 24 0c 70 34 10 	movl   $0xf0103470,0xc(%esp)
f0101b44:	f0 
f0101b45:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101b4c:	f0 
f0101b4d:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f0101b54:	00 
f0101b55:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101b5c:	e8 33 e5 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101b61:	f6 45 d0 04          	testb  $0x4,-0x30(%ebp)
f0101b65:	75 24                	jne    f0101b8b <mem_init+0xc84>
f0101b67:	c7 44 24 0c 3b 37 10 	movl   $0xf010373b,0xc(%esp)
f0101b6e:	f0 
f0101b6f:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101b76:	f0 
f0101b77:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0101b7e:	00 
f0101b7f:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101b86:	e8 09 e5 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b8b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b92:	00 
f0101b93:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b9a:	00 
f0101b9b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b9f:	89 34 24             	mov    %esi,(%esp)
f0101ba2:	e8 4c f3 ff ff       	call   f0100ef3 <page_insert>
f0101ba7:	85 c0                	test   %eax,%eax
f0101ba9:	74 24                	je     f0101bcf <mem_init+0xcc8>
f0101bab:	c7 44 24 0c 84 33 10 	movl   $0xf0103384,0xc(%esp)
f0101bb2:	f0 
f0101bb3:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101bba:	f0 
f0101bbb:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f0101bc2:	00 
f0101bc3:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101bca:	e8 c5 e4 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101bcf:	f7 c7 02 00 00 00    	test   $0x2,%edi
f0101bd5:	75 24                	jne    f0101bfb <mem_init+0xcf4>
f0101bd7:	c7 44 24 0c a4 34 10 	movl   $0xf01034a4,0xc(%esp)
f0101bde:	f0 
f0101bdf:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101be6:	f0 
f0101be7:	c7 44 24 04 f8 02 00 	movl   $0x2f8,0x4(%esp)
f0101bee:	00 
f0101bef:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101bf6:	e8 99 e4 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101bfb:	c7 44 24 0c d8 34 10 	movl   $0xf01034d8,0xc(%esp)
f0101c02:	f0 
f0101c03:	c7 44 24 08 51 35 10 	movl   $0xf0103551,0x8(%esp)
f0101c0a:	f0 
f0101c0b:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0101c12:	00 
f0101c13:	c7 04 24 10 35 10 f0 	movl   $0xf0103510,(%esp)
f0101c1a:	e8 75 e4 ff ff       	call   f0100094 <_panic>

f0101c1f <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101c1f:	55                   	push   %ebp
f0101c20:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f0101c22:	5d                   	pop    %ebp
f0101c23:	c3                   	ret    

f0101c24 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101c24:	55                   	push   %ebp
f0101c25:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101c27:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c2a:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101c2d:	5d                   	pop    %ebp
f0101c2e:	c3                   	ret    
	...

f0101c30 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0101c30:	55                   	push   %ebp
f0101c31:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101c33:	ba 70 00 00 00       	mov    $0x70,%edx
f0101c38:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c3b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101c3c:	b2 71                	mov    $0x71,%dl
f0101c3e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101c3f:	0f b6 c0             	movzbl %al,%eax
}
f0101c42:	5d                   	pop    %ebp
f0101c43:	c3                   	ret    

f0101c44 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0101c44:	55                   	push   %ebp
f0101c45:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101c47:	ba 70 00 00 00       	mov    $0x70,%edx
f0101c4c:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c4f:	ee                   	out    %al,(%dx)
f0101c50:	b2 71                	mov    $0x71,%dl
f0101c52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c55:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101c56:	5d                   	pop    %ebp
f0101c57:	c3                   	ret    

f0101c58 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101c58:	55                   	push   %ebp
f0101c59:	89 e5                	mov    %esp,%ebp
f0101c5b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c61:	89 04 24             	mov    %eax,(%esp)
f0101c64:	e8 4f e9 ff ff       	call   f01005b8 <cputchar>
	*cnt++;
}
f0101c69:	c9                   	leave  
f0101c6a:	c3                   	ret    

f0101c6b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0101c6b:	55                   	push   %ebp
f0101c6c:	89 e5                	mov    %esp,%ebp
f0101c6e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0101c71:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0101c78:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101c7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c7f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101c82:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101c86:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101c89:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101c8d:	c7 04 24 58 1c 10 f0 	movl   $0xf0101c58,(%esp)
f0101c94:	e8 69 04 00 00       	call   f0102102 <vprintfmt>
	return cnt;
}
f0101c99:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101c9c:	c9                   	leave  
f0101c9d:	c3                   	ret    

f0101c9e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0101c9e:	55                   	push   %ebp
f0101c9f:	89 e5                	mov    %esp,%ebp
f0101ca1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0101ca4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0101ca7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101cab:	8b 45 08             	mov    0x8(%ebp),%eax
f0101cae:	89 04 24             	mov    %eax,(%esp)
f0101cb1:	e8 b5 ff ff ff       	call   f0101c6b <vcprintf>
	va_end(ap);

	return cnt;
}
f0101cb6:	c9                   	leave  
f0101cb7:	c3                   	ret    

f0101cb8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0101cb8:	55                   	push   %ebp
f0101cb9:	89 e5                	mov    %esp,%ebp
f0101cbb:	57                   	push   %edi
f0101cbc:	56                   	push   %esi
f0101cbd:	53                   	push   %ebx
f0101cbe:	83 ec 10             	sub    $0x10,%esp
f0101cc1:	89 c3                	mov    %eax,%ebx
f0101cc3:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0101cc6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0101cc9:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0101ccc:	8b 0a                	mov    (%edx),%ecx
f0101cce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101cd1:	8b 00                	mov    (%eax),%eax
f0101cd3:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101cd6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0101cdd:	eb 77                	jmp    f0101d56 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0101cdf:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0101ce2:	01 c8                	add    %ecx,%eax
f0101ce4:	bf 02 00 00 00       	mov    $0x2,%edi
f0101ce9:	99                   	cltd   
f0101cea:	f7 ff                	idiv   %edi
f0101cec:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101cee:	eb 01                	jmp    f0101cf1 <stab_binsearch+0x39>
			m--;
f0101cf0:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101cf1:	39 ca                	cmp    %ecx,%edx
f0101cf3:	7c 1d                	jl     f0101d12 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0101cf5:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101cf8:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0101cfd:	39 f7                	cmp    %esi,%edi
f0101cff:	75 ef                	jne    f0101cf0 <stab_binsearch+0x38>
f0101d01:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0101d04:	6b fa 0c             	imul   $0xc,%edx,%edi
f0101d07:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0101d0b:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0101d0e:	73 18                	jae    f0101d28 <stab_binsearch+0x70>
f0101d10:	eb 05                	jmp    f0101d17 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101d12:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0101d15:	eb 3f                	jmp    f0101d56 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0101d17:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101d1a:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0101d1c:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101d1f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101d26:	eb 2e                	jmp    f0101d56 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0101d28:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0101d2b:	76 15                	jbe    f0101d42 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0101d2d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0101d30:	4f                   	dec    %edi
f0101d31:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0101d34:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101d37:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101d39:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0101d40:	eb 14                	jmp    f0101d56 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101d42:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0101d45:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0101d48:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0101d4a:	ff 45 0c             	incl   0xc(%ebp)
f0101d4d:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101d4f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0101d56:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0101d59:	7e 84                	jle    f0101cdf <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0101d5b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0101d5f:	75 0d                	jne    f0101d6e <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0101d61:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101d64:	8b 02                	mov    (%edx),%eax
f0101d66:	48                   	dec    %eax
f0101d67:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d6a:	89 01                	mov    %eax,(%ecx)
f0101d6c:	eb 22                	jmp    f0101d90 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101d6e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101d71:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0101d73:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101d76:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101d78:	eb 01                	jmp    f0101d7b <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0101d7a:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0101d7b:	39 c1                	cmp    %eax,%ecx
f0101d7d:	7d 0c                	jge    f0101d8b <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0101d7f:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0101d82:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0101d87:	39 f2                	cmp    %esi,%edx
f0101d89:	75 ef                	jne    f0101d7a <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0101d8b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0101d8e:	89 02                	mov    %eax,(%edx)
	}
}
f0101d90:	83 c4 10             	add    $0x10,%esp
f0101d93:	5b                   	pop    %ebx
f0101d94:	5e                   	pop    %esi
f0101d95:	5f                   	pop    %edi
f0101d96:	5d                   	pop    %ebp
f0101d97:	c3                   	ret    

f0101d98 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0101d98:	55                   	push   %ebp
f0101d99:	89 e5                	mov    %esp,%ebp
f0101d9b:	57                   	push   %edi
f0101d9c:	56                   	push   %esi
f0101d9d:	53                   	push   %ebx
f0101d9e:	83 ec 4c             	sub    $0x4c,%esp
f0101da1:	8b 75 08             	mov    0x8(%ebp),%esi
f0101da4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0101da7:	c7 03 51 37 10 f0    	movl   $0xf0103751,(%ebx)
	info->eip_line = 0;
f0101dad:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0101db4:	c7 43 08 51 37 10 f0 	movl   $0xf0103751,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0101dbb:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101dc2:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101dc5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0101dcc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101dd2:	76 12                	jbe    f0101de6 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101dd4:	b8 86 26 11 f0       	mov    $0xf0112686,%eax
f0101dd9:	3d c5 95 10 f0       	cmp    $0xf01095c5,%eax
f0101dde:	0f 86 a7 01 00 00    	jbe    f0101f8b <debuginfo_eip+0x1f3>
f0101de4:	eb 1c                	jmp    f0101e02 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101de6:	c7 44 24 08 5b 37 10 	movl   $0xf010375b,0x8(%esp)
f0101ded:	f0 
f0101dee:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0101df5:	00 
f0101df6:	c7 04 24 68 37 10 f0 	movl   $0xf0103768,(%esp)
f0101dfd:	e8 92 e2 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101e02:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101e07:	80 3d 85 26 11 f0 00 	cmpb   $0x0,0xf0112685
f0101e0e:	0f 85 83 01 00 00    	jne    f0101f97 <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101e14:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0101e1b:	b8 c4 95 10 f0       	mov    $0xf01095c4,%eax
f0101e20:	2d 84 39 10 f0       	sub    $0xf0103984,%eax
f0101e25:	c1 f8 02             	sar    $0x2,%eax
f0101e28:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101e2e:	48                   	dec    %eax
f0101e2f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101e32:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e36:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0101e3d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0101e40:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101e43:	b8 84 39 10 f0       	mov    $0xf0103984,%eax
f0101e48:	e8 6b fe ff ff       	call   f0101cb8 <stab_binsearch>
	if (lfile == 0)
f0101e4d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0101e50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0101e55:	85 d2                	test   %edx,%edx
f0101e57:	0f 84 3a 01 00 00    	je     f0101f97 <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0101e5d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0101e60:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101e63:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101e66:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101e6a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0101e71:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0101e74:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0101e77:	b8 84 39 10 f0       	mov    $0xf0103984,%eax
f0101e7c:	e8 37 fe ff ff       	call   f0101cb8 <stab_binsearch>

	if (lfun <= rfun) {
f0101e81:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101e84:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0101e87:	39 d0                	cmp    %edx,%eax
f0101e89:	7f 3e                	jg     f0101ec9 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0101e8b:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0101e8e:	8d b9 84 39 10 f0    	lea    -0xfefc67c(%ecx),%edi
f0101e94:	8b 89 84 39 10 f0    	mov    -0xfefc67c(%ecx),%ecx
f0101e9a:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0101e9d:	b9 86 26 11 f0       	mov    $0xf0112686,%ecx
f0101ea2:	81 e9 c5 95 10 f0    	sub    $0xf01095c5,%ecx
f0101ea8:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0101eab:	73 0c                	jae    f0101eb9 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0101ead:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0101eb0:	81 c1 c5 95 10 f0    	add    $0xf01095c5,%ecx
f0101eb6:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0101eb9:	8b 4f 08             	mov    0x8(%edi),%ecx
f0101ebc:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0101ebf:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0101ec1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0101ec4:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0101ec7:	eb 0f                	jmp    f0101ed8 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0101ec9:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0101ecc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101ecf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0101ed2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101ed5:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101ed8:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0101edf:	00 
f0101ee0:	8b 43 08             	mov    0x8(%ebx),%eax
f0101ee3:	89 04 24             	mov    %eax,(%esp)
f0101ee6:	e8 3f 08 00 00       	call   f010272a <strfind>
f0101eeb:	2b 43 08             	sub    0x8(%ebx),%eax
f0101eee:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0101ef1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ef5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0101efc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0101eff:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0101f02:	b8 84 39 10 f0       	mov    $0xf0103984,%eax
f0101f07:	e8 ac fd ff ff       	call   f0101cb8 <stab_binsearch>
	if (lline > rline) {
f0101f0c:	8b 55 d0             	mov    -0x30(%ebp),%edx
		return -1;
f0101f0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
f0101f14:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0101f17:	7f 7e                	jg     f0101f97 <debuginfo_eip+0x1ff>
		return -1;
	}
	info->eip_line = stabs[rline].n_desc;
f0101f19:	6b d2 0c             	imul   $0xc,%edx,%edx
f0101f1c:	0f b7 82 8a 39 10 f0 	movzwl -0xfefc676(%edx),%eax
f0101f23:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0101f26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101f29:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f2c:	eb 01                	jmp    f0101f2f <debuginfo_eip+0x197>
f0101f2e:	48                   	dec    %eax
f0101f2f:	89 c6                	mov    %eax,%esi
f0101f31:	39 c7                	cmp    %eax,%edi
f0101f33:	7f 26                	jg     f0101f5b <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0101f35:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0101f38:	8d 0c 95 84 39 10 f0 	lea    -0xfefc67c(,%edx,4),%ecx
f0101f3f:	8a 51 04             	mov    0x4(%ecx),%dl
f0101f42:	80 fa 84             	cmp    $0x84,%dl
f0101f45:	74 58                	je     f0101f9f <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101f47:	80 fa 64             	cmp    $0x64,%dl
f0101f4a:	75 e2                	jne    f0101f2e <debuginfo_eip+0x196>
f0101f4c:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0101f50:	74 dc                	je     f0101f2e <debuginfo_eip+0x196>
f0101f52:	eb 4b                	jmp    f0101f9f <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101f54:	05 c5 95 10 f0       	add    $0xf01095c5,%eax
f0101f59:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101f5b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0101f5e:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101f61:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101f66:	39 d1                	cmp    %edx,%ecx
f0101f68:	7d 2d                	jge    f0101f97 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f0101f6a:	8d 41 01             	lea    0x1(%ecx),%eax
f0101f6d:	eb 03                	jmp    f0101f72 <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0101f6f:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0101f72:	39 d0                	cmp    %edx,%eax
f0101f74:	7d 1c                	jge    f0101f92 <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0101f76:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0101f79:	40                   	inc    %eax
f0101f7a:	80 3c 8d 88 39 10 f0 	cmpb   $0xa0,-0xfefc678(,%ecx,4)
f0101f81:	a0 
f0101f82:	74 eb                	je     f0101f6f <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101f84:	b8 00 00 00 00       	mov    $0x0,%eax
f0101f89:	eb 0c                	jmp    f0101f97 <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0101f8b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0101f90:	eb 05                	jmp    f0101f97 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101f92:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101f97:	83 c4 4c             	add    $0x4c,%esp
f0101f9a:	5b                   	pop    %ebx
f0101f9b:	5e                   	pop    %esi
f0101f9c:	5f                   	pop    %edi
f0101f9d:	5d                   	pop    %ebp
f0101f9e:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101f9f:	6b f6 0c             	imul   $0xc,%esi,%esi
f0101fa2:	8b 86 84 39 10 f0    	mov    -0xfefc67c(%esi),%eax
f0101fa8:	ba 86 26 11 f0       	mov    $0xf0112686,%edx
f0101fad:	81 ea c5 95 10 f0    	sub    $0xf01095c5,%edx
f0101fb3:	39 d0                	cmp    %edx,%eax
f0101fb5:	72 9d                	jb     f0101f54 <debuginfo_eip+0x1bc>
f0101fb7:	eb a2                	jmp    f0101f5b <debuginfo_eip+0x1c3>
f0101fb9:	00 00                	add    %al,(%eax)
	...

f0101fbc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0101fbc:	55                   	push   %ebp
f0101fbd:	89 e5                	mov    %esp,%ebp
f0101fbf:	57                   	push   %edi
f0101fc0:	56                   	push   %esi
f0101fc1:	53                   	push   %ebx
f0101fc2:	83 ec 3c             	sub    $0x3c,%esp
f0101fc5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101fc8:	89 d7                	mov    %edx,%edi
f0101fca:	8b 45 08             	mov    0x8(%ebp),%eax
f0101fcd:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0101fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101fd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101fd6:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0101fd9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101fdc:	85 c0                	test   %eax,%eax
f0101fde:	75 08                	jne    f0101fe8 <printnum+0x2c>
f0101fe0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0101fe3:	39 45 10             	cmp    %eax,0x10(%ebp)
f0101fe6:	77 57                	ja     f010203f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101fe8:	89 74 24 10          	mov    %esi,0x10(%esp)
f0101fec:	4b                   	dec    %ebx
f0101fed:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0101ff1:	8b 45 10             	mov    0x10(%ebp),%eax
f0101ff4:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101ff8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0101ffc:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0102000:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102007:	00 
f0102008:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010200b:	89 04 24             	mov    %eax,(%esp)
f010200e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102011:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102015:	e8 1e 09 00 00       	call   f0102938 <__udivdi3>
f010201a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010201e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102022:	89 04 24             	mov    %eax,(%esp)
f0102025:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102029:	89 fa                	mov    %edi,%edx
f010202b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010202e:	e8 89 ff ff ff       	call   f0101fbc <printnum>
f0102033:	eb 0f                	jmp    f0102044 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102035:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102039:	89 34 24             	mov    %esi,(%esp)
f010203c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010203f:	4b                   	dec    %ebx
f0102040:	85 db                	test   %ebx,%ebx
f0102042:	7f f1                	jg     f0102035 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102044:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102048:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010204c:	8b 45 10             	mov    0x10(%ebp),%eax
f010204f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102053:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010205a:	00 
f010205b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010205e:	89 04 24             	mov    %eax,(%esp)
f0102061:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102064:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102068:	e8 eb 09 00 00       	call   f0102a58 <__umoddi3>
f010206d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102071:	0f be 80 76 37 10 f0 	movsbl -0xfefc88a(%eax),%eax
f0102078:	89 04 24             	mov    %eax,(%esp)
f010207b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010207e:	83 c4 3c             	add    $0x3c,%esp
f0102081:	5b                   	pop    %ebx
f0102082:	5e                   	pop    %esi
f0102083:	5f                   	pop    %edi
f0102084:	5d                   	pop    %ebp
f0102085:	c3                   	ret    

f0102086 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102086:	55                   	push   %ebp
f0102087:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102089:	83 fa 01             	cmp    $0x1,%edx
f010208c:	7e 0e                	jle    f010209c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010208e:	8b 10                	mov    (%eax),%edx
f0102090:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102093:	89 08                	mov    %ecx,(%eax)
f0102095:	8b 02                	mov    (%edx),%eax
f0102097:	8b 52 04             	mov    0x4(%edx),%edx
f010209a:	eb 22                	jmp    f01020be <getuint+0x38>
	else if (lflag)
f010209c:	85 d2                	test   %edx,%edx
f010209e:	74 10                	je     f01020b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01020a0:	8b 10                	mov    (%eax),%edx
f01020a2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01020a5:	89 08                	mov    %ecx,(%eax)
f01020a7:	8b 02                	mov    (%edx),%eax
f01020a9:	ba 00 00 00 00       	mov    $0x0,%edx
f01020ae:	eb 0e                	jmp    f01020be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01020b0:	8b 10                	mov    (%eax),%edx
f01020b2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01020b5:	89 08                	mov    %ecx,(%eax)
f01020b7:	8b 02                	mov    (%edx),%eax
f01020b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01020be:	5d                   	pop    %ebp
f01020bf:	c3                   	ret    

f01020c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01020c0:	55                   	push   %ebp
f01020c1:	89 e5                	mov    %esp,%ebp
f01020c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01020c6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f01020c9:	8b 10                	mov    (%eax),%edx
f01020cb:	3b 50 04             	cmp    0x4(%eax),%edx
f01020ce:	73 08                	jae    f01020d8 <sprintputch+0x18>
		*b->buf++ = ch;
f01020d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01020d3:	88 0a                	mov    %cl,(%edx)
f01020d5:	42                   	inc    %edx
f01020d6:	89 10                	mov    %edx,(%eax)
}
f01020d8:	5d                   	pop    %ebp
f01020d9:	c3                   	ret    

f01020da <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01020da:	55                   	push   %ebp
f01020db:	89 e5                	mov    %esp,%ebp
f01020dd:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01020e0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01020e3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01020e7:	8b 45 10             	mov    0x10(%ebp),%eax
f01020ea:	89 44 24 08          	mov    %eax,0x8(%esp)
f01020ee:	8b 45 0c             	mov    0xc(%ebp),%eax
f01020f1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01020f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01020f8:	89 04 24             	mov    %eax,(%esp)
f01020fb:	e8 02 00 00 00       	call   f0102102 <vprintfmt>
	va_end(ap);
}
f0102100:	c9                   	leave  
f0102101:	c3                   	ret    

f0102102 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102102:	55                   	push   %ebp
f0102103:	89 e5                	mov    %esp,%ebp
f0102105:	57                   	push   %edi
f0102106:	56                   	push   %esi
f0102107:	53                   	push   %ebx
f0102108:	83 ec 4c             	sub    $0x4c,%esp
f010210b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010210e:	8b 75 10             	mov    0x10(%ebp),%esi
f0102111:	eb 12                	jmp    f0102125 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102113:	85 c0                	test   %eax,%eax
f0102115:	0f 84 6b 03 00 00    	je     f0102486 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f010211b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010211f:	89 04 24             	mov    %eax,(%esp)
f0102122:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102125:	0f b6 06             	movzbl (%esi),%eax
f0102128:	46                   	inc    %esi
f0102129:	83 f8 25             	cmp    $0x25,%eax
f010212c:	75 e5                	jne    f0102113 <vprintfmt+0x11>
f010212e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0102132:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0102139:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010213e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0102145:	b9 00 00 00 00       	mov    $0x0,%ecx
f010214a:	eb 26                	jmp    f0102172 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010214c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010214f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0102153:	eb 1d                	jmp    f0102172 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102155:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102158:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010215c:	eb 14                	jmp    f0102172 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010215e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0102161:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0102168:	eb 08                	jmp    f0102172 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010216a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010216d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102172:	0f b6 06             	movzbl (%esi),%eax
f0102175:	8d 56 01             	lea    0x1(%esi),%edx
f0102178:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010217b:	8a 16                	mov    (%esi),%dl
f010217d:	83 ea 23             	sub    $0x23,%edx
f0102180:	80 fa 55             	cmp    $0x55,%dl
f0102183:	0f 87 e1 02 00 00    	ja     f010246a <vprintfmt+0x368>
f0102189:	0f b6 d2             	movzbl %dl,%edx
f010218c:	ff 24 95 00 38 10 f0 	jmp    *-0xfefc800(,%edx,4)
f0102193:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102196:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010219b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010219e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01021a2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01021a5:	8d 50 d0             	lea    -0x30(%eax),%edx
f01021a8:	83 fa 09             	cmp    $0x9,%edx
f01021ab:	77 2a                	ja     f01021d7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01021ad:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01021ae:	eb eb                	jmp    f010219b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01021b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01021b3:	8d 50 04             	lea    0x4(%eax),%edx
f01021b6:	89 55 14             	mov    %edx,0x14(%ebp)
f01021b9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01021bb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01021be:	eb 17                	jmp    f01021d7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f01021c0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01021c4:	78 98                	js     f010215e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01021c6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01021c9:	eb a7                	jmp    f0102172 <vprintfmt+0x70>
f01021cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f01021ce:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f01021d5:	eb 9b                	jmp    f0102172 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f01021d7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01021db:	79 95                	jns    f0102172 <vprintfmt+0x70>
f01021dd:	eb 8b                	jmp    f010216a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01021df:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01021e0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01021e3:	eb 8d                	jmp    f0102172 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01021e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01021e8:	8d 50 04             	lea    0x4(%eax),%edx
f01021eb:	89 55 14             	mov    %edx,0x14(%ebp)
f01021ee:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01021f2:	8b 00                	mov    (%eax),%eax
f01021f4:	89 04 24             	mov    %eax,(%esp)
f01021f7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01021fa:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01021fd:	e9 23 ff ff ff       	jmp    f0102125 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102202:	8b 45 14             	mov    0x14(%ebp),%eax
f0102205:	8d 50 04             	lea    0x4(%eax),%edx
f0102208:	89 55 14             	mov    %edx,0x14(%ebp)
f010220b:	8b 00                	mov    (%eax),%eax
f010220d:	85 c0                	test   %eax,%eax
f010220f:	79 02                	jns    f0102213 <vprintfmt+0x111>
f0102211:	f7 d8                	neg    %eax
f0102213:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102215:	83 f8 06             	cmp    $0x6,%eax
f0102218:	7f 0b                	jg     f0102225 <vprintfmt+0x123>
f010221a:	8b 04 85 58 39 10 f0 	mov    -0xfefc6a8(,%eax,4),%eax
f0102221:	85 c0                	test   %eax,%eax
f0102223:	75 23                	jne    f0102248 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0102225:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102229:	c7 44 24 08 8e 37 10 	movl   $0xf010378e,0x8(%esp)
f0102230:	f0 
f0102231:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102235:	8b 45 08             	mov    0x8(%ebp),%eax
f0102238:	89 04 24             	mov    %eax,(%esp)
f010223b:	e8 9a fe ff ff       	call   f01020da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102240:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102243:	e9 dd fe ff ff       	jmp    f0102125 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0102248:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010224c:	c7 44 24 08 63 35 10 	movl   $0xf0103563,0x8(%esp)
f0102253:	f0 
f0102254:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102258:	8b 55 08             	mov    0x8(%ebp),%edx
f010225b:	89 14 24             	mov    %edx,(%esp)
f010225e:	e8 77 fe ff ff       	call   f01020da <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102263:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102266:	e9 ba fe ff ff       	jmp    f0102125 <vprintfmt+0x23>
f010226b:	89 f9                	mov    %edi,%ecx
f010226d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102270:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102273:	8b 45 14             	mov    0x14(%ebp),%eax
f0102276:	8d 50 04             	lea    0x4(%eax),%edx
f0102279:	89 55 14             	mov    %edx,0x14(%ebp)
f010227c:	8b 30                	mov    (%eax),%esi
f010227e:	85 f6                	test   %esi,%esi
f0102280:	75 05                	jne    f0102287 <vprintfmt+0x185>
				p = "(null)";
f0102282:	be 87 37 10 f0       	mov    $0xf0103787,%esi
			if (width > 0 && padc != '-')
f0102287:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010228b:	0f 8e 84 00 00 00    	jle    f0102315 <vprintfmt+0x213>
f0102291:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0102295:	74 7e                	je     f0102315 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102297:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010229b:	89 34 24             	mov    %esi,(%esp)
f010229e:	e8 53 03 00 00       	call   f01025f6 <strnlen>
f01022a3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01022a6:	29 c2                	sub    %eax,%edx
f01022a8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f01022ab:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01022af:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01022b2:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01022b5:	89 de                	mov    %ebx,%esi
f01022b7:	89 d3                	mov    %edx,%ebx
f01022b9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01022bb:	eb 0b                	jmp    f01022c8 <vprintfmt+0x1c6>
					putch(padc, putdat);
f01022bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01022c1:	89 3c 24             	mov    %edi,(%esp)
f01022c4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01022c7:	4b                   	dec    %ebx
f01022c8:	85 db                	test   %ebx,%ebx
f01022ca:	7f f1                	jg     f01022bd <vprintfmt+0x1bb>
f01022cc:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01022cf:	89 f3                	mov    %esi,%ebx
f01022d1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f01022d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01022d7:	85 c0                	test   %eax,%eax
f01022d9:	79 05                	jns    f01022e0 <vprintfmt+0x1de>
f01022db:	b8 00 00 00 00       	mov    $0x0,%eax
f01022e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01022e3:	29 c2                	sub    %eax,%edx
f01022e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01022e8:	eb 2b                	jmp    f0102315 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01022ea:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01022ee:	74 18                	je     f0102308 <vprintfmt+0x206>
f01022f0:	8d 50 e0             	lea    -0x20(%eax),%edx
f01022f3:	83 fa 5e             	cmp    $0x5e,%edx
f01022f6:	76 10                	jbe    f0102308 <vprintfmt+0x206>
					putch('?', putdat);
f01022f8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01022fc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0102303:	ff 55 08             	call   *0x8(%ebp)
f0102306:	eb 0a                	jmp    f0102312 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0102308:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010230c:	89 04 24             	mov    %eax,(%esp)
f010230f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102312:	ff 4d e4             	decl   -0x1c(%ebp)
f0102315:	0f be 06             	movsbl (%esi),%eax
f0102318:	46                   	inc    %esi
f0102319:	85 c0                	test   %eax,%eax
f010231b:	74 21                	je     f010233e <vprintfmt+0x23c>
f010231d:	85 ff                	test   %edi,%edi
f010231f:	78 c9                	js     f01022ea <vprintfmt+0x1e8>
f0102321:	4f                   	dec    %edi
f0102322:	79 c6                	jns    f01022ea <vprintfmt+0x1e8>
f0102324:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102327:	89 de                	mov    %ebx,%esi
f0102329:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010232c:	eb 18                	jmp    f0102346 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010232e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102332:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0102339:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010233b:	4b                   	dec    %ebx
f010233c:	eb 08                	jmp    f0102346 <vprintfmt+0x244>
f010233e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102341:	89 de                	mov    %ebx,%esi
f0102343:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0102346:	85 db                	test   %ebx,%ebx
f0102348:	7f e4                	jg     f010232e <vprintfmt+0x22c>
f010234a:	89 7d 08             	mov    %edi,0x8(%ebp)
f010234d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010234f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102352:	e9 ce fd ff ff       	jmp    f0102125 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102357:	83 f9 01             	cmp    $0x1,%ecx
f010235a:	7e 10                	jle    f010236c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f010235c:	8b 45 14             	mov    0x14(%ebp),%eax
f010235f:	8d 50 08             	lea    0x8(%eax),%edx
f0102362:	89 55 14             	mov    %edx,0x14(%ebp)
f0102365:	8b 30                	mov    (%eax),%esi
f0102367:	8b 78 04             	mov    0x4(%eax),%edi
f010236a:	eb 26                	jmp    f0102392 <vprintfmt+0x290>
	else if (lflag)
f010236c:	85 c9                	test   %ecx,%ecx
f010236e:	74 12                	je     f0102382 <vprintfmt+0x280>
		return va_arg(*ap, long);
f0102370:	8b 45 14             	mov    0x14(%ebp),%eax
f0102373:	8d 50 04             	lea    0x4(%eax),%edx
f0102376:	89 55 14             	mov    %edx,0x14(%ebp)
f0102379:	8b 30                	mov    (%eax),%esi
f010237b:	89 f7                	mov    %esi,%edi
f010237d:	c1 ff 1f             	sar    $0x1f,%edi
f0102380:	eb 10                	jmp    f0102392 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0102382:	8b 45 14             	mov    0x14(%ebp),%eax
f0102385:	8d 50 04             	lea    0x4(%eax),%edx
f0102388:	89 55 14             	mov    %edx,0x14(%ebp)
f010238b:	8b 30                	mov    (%eax),%esi
f010238d:	89 f7                	mov    %esi,%edi
f010238f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102392:	85 ff                	test   %edi,%edi
f0102394:	78 0a                	js     f01023a0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102396:	b8 0a 00 00 00       	mov    $0xa,%eax
f010239b:	e9 8c 00 00 00       	jmp    f010242c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01023a0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023a4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01023ab:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01023ae:	f7 de                	neg    %esi
f01023b0:	83 d7 00             	adc    $0x0,%edi
f01023b3:	f7 df                	neg    %edi
			}
			base = 10;
f01023b5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01023ba:	eb 70                	jmp    f010242c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01023bc:	89 ca                	mov    %ecx,%edx
f01023be:	8d 45 14             	lea    0x14(%ebp),%eax
f01023c1:	e8 c0 fc ff ff       	call   f0102086 <getuint>
f01023c6:	89 c6                	mov    %eax,%esi
f01023c8:	89 d7                	mov    %edx,%edi
			base = 10;
f01023ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f01023cf:	eb 5b                	jmp    f010242c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01023d1:	89 ca                	mov    %ecx,%edx
f01023d3:	8d 45 14             	lea    0x14(%ebp),%eax
f01023d6:	e8 ab fc ff ff       	call   f0102086 <getuint>
f01023db:	89 c6                	mov    %eax,%esi
f01023dd:	89 d7                	mov    %edx,%edi
			base = 8;
f01023df:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01023e4:	eb 46                	jmp    f010242c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f01023e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023ea:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01023f1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01023f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01023f8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01023ff:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102402:	8b 45 14             	mov    0x14(%ebp),%eax
f0102405:	8d 50 04             	lea    0x4(%eax),%edx
f0102408:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010240b:	8b 30                	mov    (%eax),%esi
f010240d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102412:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102417:	eb 13                	jmp    f010242c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102419:	89 ca                	mov    %ecx,%edx
f010241b:	8d 45 14             	lea    0x14(%ebp),%eax
f010241e:	e8 63 fc ff ff       	call   f0102086 <getuint>
f0102423:	89 c6                	mov    %eax,%esi
f0102425:	89 d7                	mov    %edx,%edi
			base = 16;
f0102427:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010242c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0102430:	89 54 24 10          	mov    %edx,0x10(%esp)
f0102434:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102437:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010243b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010243f:	89 34 24             	mov    %esi,(%esp)
f0102442:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102446:	89 da                	mov    %ebx,%edx
f0102448:	8b 45 08             	mov    0x8(%ebp),%eax
f010244b:	e8 6c fb ff ff       	call   f0101fbc <printnum>
			break;
f0102450:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102453:	e9 cd fc ff ff       	jmp    f0102125 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102458:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010245c:	89 04 24             	mov    %eax,(%esp)
f010245f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102462:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102465:	e9 bb fc ff ff       	jmp    f0102125 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010246a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010246e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0102475:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102478:	eb 01                	jmp    f010247b <vprintfmt+0x379>
f010247a:	4e                   	dec    %esi
f010247b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010247f:	75 f9                	jne    f010247a <vprintfmt+0x378>
f0102481:	e9 9f fc ff ff       	jmp    f0102125 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0102486:	83 c4 4c             	add    $0x4c,%esp
f0102489:	5b                   	pop    %ebx
f010248a:	5e                   	pop    %esi
f010248b:	5f                   	pop    %edi
f010248c:	5d                   	pop    %ebp
f010248d:	c3                   	ret    

f010248e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010248e:	55                   	push   %ebp
f010248f:	89 e5                	mov    %esp,%ebp
f0102491:	83 ec 28             	sub    $0x28,%esp
f0102494:	8b 45 08             	mov    0x8(%ebp),%eax
f0102497:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010249a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010249d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01024a1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01024a4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01024ab:	85 c0                	test   %eax,%eax
f01024ad:	74 30                	je     f01024df <vsnprintf+0x51>
f01024af:	85 d2                	test   %edx,%edx
f01024b1:	7e 33                	jle    f01024e6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01024b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01024b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01024bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01024c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01024c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01024c8:	c7 04 24 c0 20 10 f0 	movl   $0xf01020c0,(%esp)
f01024cf:	e8 2e fc ff ff       	call   f0102102 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01024d4:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01024d7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01024da:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01024dd:	eb 0c                	jmp    f01024eb <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01024df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01024e4:	eb 05                	jmp    f01024eb <vsnprintf+0x5d>
f01024e6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01024eb:	c9                   	leave  
f01024ec:	c3                   	ret    

f01024ed <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01024ed:	55                   	push   %ebp
f01024ee:	89 e5                	mov    %esp,%ebp
f01024f0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01024f3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01024f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01024fd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102501:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102504:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102508:	8b 45 08             	mov    0x8(%ebp),%eax
f010250b:	89 04 24             	mov    %eax,(%esp)
f010250e:	e8 7b ff ff ff       	call   f010248e <vsnprintf>
	va_end(ap);

	return rc;
}
f0102513:	c9                   	leave  
f0102514:	c3                   	ret    
f0102515:	00 00                	add    %al,(%eax)
	...

f0102518 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102518:	55                   	push   %ebp
f0102519:	89 e5                	mov    %esp,%ebp
f010251b:	57                   	push   %edi
f010251c:	56                   	push   %esi
f010251d:	53                   	push   %ebx
f010251e:	83 ec 1c             	sub    $0x1c,%esp
f0102521:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102524:	85 c0                	test   %eax,%eax
f0102526:	74 10                	je     f0102538 <readline+0x20>
		cprintf("%s", prompt);
f0102528:	89 44 24 04          	mov    %eax,0x4(%esp)
f010252c:	c7 04 24 63 35 10 f0 	movl   $0xf0103563,(%esp)
f0102533:	e8 66 f7 ff ff       	call   f0101c9e <cprintf>

	i = 0;
	echoing = iscons(0);
f0102538:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010253f:	e8 95 e0 ff ff       	call   f01005d9 <iscons>
f0102544:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102546:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010254b:	e8 78 e0 ff ff       	call   f01005c8 <getchar>
f0102550:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102552:	85 c0                	test   %eax,%eax
f0102554:	79 17                	jns    f010256d <readline+0x55>
			cprintf("read error: %e\n", c);
f0102556:	89 44 24 04          	mov    %eax,0x4(%esp)
f010255a:	c7 04 24 74 39 10 f0 	movl   $0xf0103974,(%esp)
f0102561:	e8 38 f7 ff ff       	call   f0101c9e <cprintf>
			return NULL;
f0102566:	b8 00 00 00 00       	mov    $0x0,%eax
f010256b:	eb 69                	jmp    f01025d6 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010256d:	83 f8 08             	cmp    $0x8,%eax
f0102570:	74 05                	je     f0102577 <readline+0x5f>
f0102572:	83 f8 7f             	cmp    $0x7f,%eax
f0102575:	75 17                	jne    f010258e <readline+0x76>
f0102577:	85 f6                	test   %esi,%esi
f0102579:	7e 13                	jle    f010258e <readline+0x76>
			if (echoing)
f010257b:	85 ff                	test   %edi,%edi
f010257d:	74 0c                	je     f010258b <readline+0x73>
				cputchar('\b');
f010257f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0102586:	e8 2d e0 ff ff       	call   f01005b8 <cputchar>
			i--;
f010258b:	4e                   	dec    %esi
f010258c:	eb bd                	jmp    f010254b <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010258e:	83 fb 1f             	cmp    $0x1f,%ebx
f0102591:	7e 1d                	jle    f01025b0 <readline+0x98>
f0102593:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102599:	7f 15                	jg     f01025b0 <readline+0x98>
			if (echoing)
f010259b:	85 ff                	test   %edi,%edi
f010259d:	74 08                	je     f01025a7 <readline+0x8f>
				cputchar(c);
f010259f:	89 1c 24             	mov    %ebx,(%esp)
f01025a2:	e8 11 e0 ff ff       	call   f01005b8 <cputchar>
			buf[i++] = c;
f01025a7:	88 9e 60 d5 11 f0    	mov    %bl,-0xfee2aa0(%esi)
f01025ad:	46                   	inc    %esi
f01025ae:	eb 9b                	jmp    f010254b <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01025b0:	83 fb 0a             	cmp    $0xa,%ebx
f01025b3:	74 05                	je     f01025ba <readline+0xa2>
f01025b5:	83 fb 0d             	cmp    $0xd,%ebx
f01025b8:	75 91                	jne    f010254b <readline+0x33>
			if (echoing)
f01025ba:	85 ff                	test   %edi,%edi
f01025bc:	74 0c                	je     f01025ca <readline+0xb2>
				cputchar('\n');
f01025be:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f01025c5:	e8 ee df ff ff       	call   f01005b8 <cputchar>
			buf[i] = 0;
f01025ca:	c6 86 60 d5 11 f0 00 	movb   $0x0,-0xfee2aa0(%esi)
			return buf;
f01025d1:	b8 60 d5 11 f0       	mov    $0xf011d560,%eax
		}
	}
}
f01025d6:	83 c4 1c             	add    $0x1c,%esp
f01025d9:	5b                   	pop    %ebx
f01025da:	5e                   	pop    %esi
f01025db:	5f                   	pop    %edi
f01025dc:	5d                   	pop    %ebp
f01025dd:	c3                   	ret    
	...

f01025e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01025e0:	55                   	push   %ebp
f01025e1:	89 e5                	mov    %esp,%ebp
f01025e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01025e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01025eb:	eb 01                	jmp    f01025ee <strlen+0xe>
		n++;
f01025ed:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01025ee:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01025f2:	75 f9                	jne    f01025ed <strlen+0xd>
		n++;
	return n;
}
f01025f4:	5d                   	pop    %ebp
f01025f5:	c3                   	ret    

f01025f6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01025f6:	55                   	push   %ebp
f01025f7:	89 e5                	mov    %esp,%ebp
f01025f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01025fc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01025ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0102604:	eb 01                	jmp    f0102607 <strnlen+0x11>
		n++;
f0102606:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102607:	39 d0                	cmp    %edx,%eax
f0102609:	74 06                	je     f0102611 <strnlen+0x1b>
f010260b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010260f:	75 f5                	jne    f0102606 <strnlen+0x10>
		n++;
	return n;
}
f0102611:	5d                   	pop    %ebp
f0102612:	c3                   	ret    

f0102613 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0102613:	55                   	push   %ebp
f0102614:	89 e5                	mov    %esp,%ebp
f0102616:	53                   	push   %ebx
f0102617:	8b 45 08             	mov    0x8(%ebp),%eax
f010261a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010261d:	ba 00 00 00 00       	mov    $0x0,%edx
f0102622:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0102625:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0102628:	42                   	inc    %edx
f0102629:	84 c9                	test   %cl,%cl
f010262b:	75 f5                	jne    f0102622 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010262d:	5b                   	pop    %ebx
f010262e:	5d                   	pop    %ebp
f010262f:	c3                   	ret    

f0102630 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0102630:	55                   	push   %ebp
f0102631:	89 e5                	mov    %esp,%ebp
f0102633:	53                   	push   %ebx
f0102634:	83 ec 08             	sub    $0x8,%esp
f0102637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010263a:	89 1c 24             	mov    %ebx,(%esp)
f010263d:	e8 9e ff ff ff       	call   f01025e0 <strlen>
	strcpy(dst + len, src);
f0102642:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102645:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102649:	01 d8                	add    %ebx,%eax
f010264b:	89 04 24             	mov    %eax,(%esp)
f010264e:	e8 c0 ff ff ff       	call   f0102613 <strcpy>
	return dst;
}
f0102653:	89 d8                	mov    %ebx,%eax
f0102655:	83 c4 08             	add    $0x8,%esp
f0102658:	5b                   	pop    %ebx
f0102659:	5d                   	pop    %ebp
f010265a:	c3                   	ret    

f010265b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010265b:	55                   	push   %ebp
f010265c:	89 e5                	mov    %esp,%ebp
f010265e:	56                   	push   %esi
f010265f:	53                   	push   %ebx
f0102660:	8b 45 08             	mov    0x8(%ebp),%eax
f0102663:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102666:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0102669:	b9 00 00 00 00       	mov    $0x0,%ecx
f010266e:	eb 0c                	jmp    f010267c <strncpy+0x21>
		*dst++ = *src;
f0102670:	8a 1a                	mov    (%edx),%bl
f0102672:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0102675:	80 3a 01             	cmpb   $0x1,(%edx)
f0102678:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010267b:	41                   	inc    %ecx
f010267c:	39 f1                	cmp    %esi,%ecx
f010267e:	75 f0                	jne    f0102670 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0102680:	5b                   	pop    %ebx
f0102681:	5e                   	pop    %esi
f0102682:	5d                   	pop    %ebp
f0102683:	c3                   	ret    

f0102684 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0102684:	55                   	push   %ebp
f0102685:	89 e5                	mov    %esp,%ebp
f0102687:	56                   	push   %esi
f0102688:	53                   	push   %ebx
f0102689:	8b 75 08             	mov    0x8(%ebp),%esi
f010268c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010268f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0102692:	85 d2                	test   %edx,%edx
f0102694:	75 0a                	jne    f01026a0 <strlcpy+0x1c>
f0102696:	89 f0                	mov    %esi,%eax
f0102698:	eb 1a                	jmp    f01026b4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010269a:	88 18                	mov    %bl,(%eax)
f010269c:	40                   	inc    %eax
f010269d:	41                   	inc    %ecx
f010269e:	eb 02                	jmp    f01026a2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01026a0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f01026a2:	4a                   	dec    %edx
f01026a3:	74 0a                	je     f01026af <strlcpy+0x2b>
f01026a5:	8a 19                	mov    (%ecx),%bl
f01026a7:	84 db                	test   %bl,%bl
f01026a9:	75 ef                	jne    f010269a <strlcpy+0x16>
f01026ab:	89 c2                	mov    %eax,%edx
f01026ad:	eb 02                	jmp    f01026b1 <strlcpy+0x2d>
f01026af:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01026b1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01026b4:	29 f0                	sub    %esi,%eax
}
f01026b6:	5b                   	pop    %ebx
f01026b7:	5e                   	pop    %esi
f01026b8:	5d                   	pop    %ebp
f01026b9:	c3                   	ret    

f01026ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01026ba:	55                   	push   %ebp
f01026bb:	89 e5                	mov    %esp,%ebp
f01026bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01026c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01026c3:	eb 02                	jmp    f01026c7 <strcmp+0xd>
		p++, q++;
f01026c5:	41                   	inc    %ecx
f01026c6:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01026c7:	8a 01                	mov    (%ecx),%al
f01026c9:	84 c0                	test   %al,%al
f01026cb:	74 04                	je     f01026d1 <strcmp+0x17>
f01026cd:	3a 02                	cmp    (%edx),%al
f01026cf:	74 f4                	je     f01026c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01026d1:	0f b6 c0             	movzbl %al,%eax
f01026d4:	0f b6 12             	movzbl (%edx),%edx
f01026d7:	29 d0                	sub    %edx,%eax
}
f01026d9:	5d                   	pop    %ebp
f01026da:	c3                   	ret    

f01026db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01026db:	55                   	push   %ebp
f01026dc:	89 e5                	mov    %esp,%ebp
f01026de:	53                   	push   %ebx
f01026df:	8b 45 08             	mov    0x8(%ebp),%eax
f01026e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01026e5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01026e8:	eb 03                	jmp    f01026ed <strncmp+0x12>
		n--, p++, q++;
f01026ea:	4a                   	dec    %edx
f01026eb:	40                   	inc    %eax
f01026ec:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01026ed:	85 d2                	test   %edx,%edx
f01026ef:	74 14                	je     f0102705 <strncmp+0x2a>
f01026f1:	8a 18                	mov    (%eax),%bl
f01026f3:	84 db                	test   %bl,%bl
f01026f5:	74 04                	je     f01026fb <strncmp+0x20>
f01026f7:	3a 19                	cmp    (%ecx),%bl
f01026f9:	74 ef                	je     f01026ea <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01026fb:	0f b6 00             	movzbl (%eax),%eax
f01026fe:	0f b6 11             	movzbl (%ecx),%edx
f0102701:	29 d0                	sub    %edx,%eax
f0102703:	eb 05                	jmp    f010270a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102705:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010270a:	5b                   	pop    %ebx
f010270b:	5d                   	pop    %ebp
f010270c:	c3                   	ret    

f010270d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010270d:	55                   	push   %ebp
f010270e:	89 e5                	mov    %esp,%ebp
f0102710:	8b 45 08             	mov    0x8(%ebp),%eax
f0102713:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0102716:	eb 05                	jmp    f010271d <strchr+0x10>
		if (*s == c)
f0102718:	38 ca                	cmp    %cl,%dl
f010271a:	74 0c                	je     f0102728 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010271c:	40                   	inc    %eax
f010271d:	8a 10                	mov    (%eax),%dl
f010271f:	84 d2                	test   %dl,%dl
f0102721:	75 f5                	jne    f0102718 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0102723:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102728:	5d                   	pop    %ebp
f0102729:	c3                   	ret    

f010272a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010272a:	55                   	push   %ebp
f010272b:	89 e5                	mov    %esp,%ebp
f010272d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102730:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0102733:	eb 05                	jmp    f010273a <strfind+0x10>
		if (*s == c)
f0102735:	38 ca                	cmp    %cl,%dl
f0102737:	74 07                	je     f0102740 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0102739:	40                   	inc    %eax
f010273a:	8a 10                	mov    (%eax),%dl
f010273c:	84 d2                	test   %dl,%dl
f010273e:	75 f5                	jne    f0102735 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0102740:	5d                   	pop    %ebp
f0102741:	c3                   	ret    

f0102742 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0102742:	55                   	push   %ebp
f0102743:	89 e5                	mov    %esp,%ebp
f0102745:	57                   	push   %edi
f0102746:	56                   	push   %esi
f0102747:	53                   	push   %ebx
f0102748:	8b 7d 08             	mov    0x8(%ebp),%edi
f010274b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010274e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0102751:	85 c9                	test   %ecx,%ecx
f0102753:	74 30                	je     f0102785 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0102755:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010275b:	75 25                	jne    f0102782 <memset+0x40>
f010275d:	f6 c1 03             	test   $0x3,%cl
f0102760:	75 20                	jne    f0102782 <memset+0x40>
		c &= 0xFF;
f0102762:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0102765:	89 d3                	mov    %edx,%ebx
f0102767:	c1 e3 08             	shl    $0x8,%ebx
f010276a:	89 d6                	mov    %edx,%esi
f010276c:	c1 e6 18             	shl    $0x18,%esi
f010276f:	89 d0                	mov    %edx,%eax
f0102771:	c1 e0 10             	shl    $0x10,%eax
f0102774:	09 f0                	or     %esi,%eax
f0102776:	09 d0                	or     %edx,%eax
f0102778:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010277a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010277d:	fc                   	cld    
f010277e:	f3 ab                	rep stos %eax,%es:(%edi)
f0102780:	eb 03                	jmp    f0102785 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0102782:	fc                   	cld    
f0102783:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0102785:	89 f8                	mov    %edi,%eax
f0102787:	5b                   	pop    %ebx
f0102788:	5e                   	pop    %esi
f0102789:	5f                   	pop    %edi
f010278a:	5d                   	pop    %ebp
f010278b:	c3                   	ret    

f010278c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010278c:	55                   	push   %ebp
f010278d:	89 e5                	mov    %esp,%ebp
f010278f:	57                   	push   %edi
f0102790:	56                   	push   %esi
f0102791:	8b 45 08             	mov    0x8(%ebp),%eax
f0102794:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102797:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010279a:	39 c6                	cmp    %eax,%esi
f010279c:	73 34                	jae    f01027d2 <memmove+0x46>
f010279e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01027a1:	39 d0                	cmp    %edx,%eax
f01027a3:	73 2d                	jae    f01027d2 <memmove+0x46>
		s += n;
		d += n;
f01027a5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01027a8:	f6 c2 03             	test   $0x3,%dl
f01027ab:	75 1b                	jne    f01027c8 <memmove+0x3c>
f01027ad:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01027b3:	75 13                	jne    f01027c8 <memmove+0x3c>
f01027b5:	f6 c1 03             	test   $0x3,%cl
f01027b8:	75 0e                	jne    f01027c8 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01027ba:	83 ef 04             	sub    $0x4,%edi
f01027bd:	8d 72 fc             	lea    -0x4(%edx),%esi
f01027c0:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f01027c3:	fd                   	std    
f01027c4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01027c6:	eb 07                	jmp    f01027cf <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f01027c8:	4f                   	dec    %edi
f01027c9:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01027cc:	fd                   	std    
f01027cd:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01027cf:	fc                   	cld    
f01027d0:	eb 20                	jmp    f01027f2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01027d2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01027d8:	75 13                	jne    f01027ed <memmove+0x61>
f01027da:	a8 03                	test   $0x3,%al
f01027dc:	75 0f                	jne    f01027ed <memmove+0x61>
f01027de:	f6 c1 03             	test   $0x3,%cl
f01027e1:	75 0a                	jne    f01027ed <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01027e3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01027e6:	89 c7                	mov    %eax,%edi
f01027e8:	fc                   	cld    
f01027e9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01027eb:	eb 05                	jmp    f01027f2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01027ed:	89 c7                	mov    %eax,%edi
f01027ef:	fc                   	cld    
f01027f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01027f2:	5e                   	pop    %esi
f01027f3:	5f                   	pop    %edi
f01027f4:	5d                   	pop    %ebp
f01027f5:	c3                   	ret    

f01027f6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01027f6:	55                   	push   %ebp
f01027f7:	89 e5                	mov    %esp,%ebp
f01027f9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01027fc:	8b 45 10             	mov    0x10(%ebp),%eax
f01027ff:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102803:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102806:	89 44 24 04          	mov    %eax,0x4(%esp)
f010280a:	8b 45 08             	mov    0x8(%ebp),%eax
f010280d:	89 04 24             	mov    %eax,(%esp)
f0102810:	e8 77 ff ff ff       	call   f010278c <memmove>
}
f0102815:	c9                   	leave  
f0102816:	c3                   	ret    

f0102817 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0102817:	55                   	push   %ebp
f0102818:	89 e5                	mov    %esp,%ebp
f010281a:	57                   	push   %edi
f010281b:	56                   	push   %esi
f010281c:	53                   	push   %ebx
f010281d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102820:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102823:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102826:	ba 00 00 00 00       	mov    $0x0,%edx
f010282b:	eb 16                	jmp    f0102843 <memcmp+0x2c>
		if (*s1 != *s2)
f010282d:	8a 04 17             	mov    (%edi,%edx,1),%al
f0102830:	42                   	inc    %edx
f0102831:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0102835:	38 c8                	cmp    %cl,%al
f0102837:	74 0a                	je     f0102843 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0102839:	0f b6 c0             	movzbl %al,%eax
f010283c:	0f b6 c9             	movzbl %cl,%ecx
f010283f:	29 c8                	sub    %ecx,%eax
f0102841:	eb 09                	jmp    f010284c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0102843:	39 da                	cmp    %ebx,%edx
f0102845:	75 e6                	jne    f010282d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0102847:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010284c:	5b                   	pop    %ebx
f010284d:	5e                   	pop    %esi
f010284e:	5f                   	pop    %edi
f010284f:	5d                   	pop    %ebp
f0102850:	c3                   	ret    

f0102851 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102851:	55                   	push   %ebp
f0102852:	89 e5                	mov    %esp,%ebp
f0102854:	8b 45 08             	mov    0x8(%ebp),%eax
f0102857:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010285a:	89 c2                	mov    %eax,%edx
f010285c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010285f:	eb 05                	jmp    f0102866 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0102861:	38 08                	cmp    %cl,(%eax)
f0102863:	74 05                	je     f010286a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102865:	40                   	inc    %eax
f0102866:	39 d0                	cmp    %edx,%eax
f0102868:	72 f7                	jb     f0102861 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010286a:	5d                   	pop    %ebp
f010286b:	c3                   	ret    

f010286c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010286c:	55                   	push   %ebp
f010286d:	89 e5                	mov    %esp,%ebp
f010286f:	57                   	push   %edi
f0102870:	56                   	push   %esi
f0102871:	53                   	push   %ebx
f0102872:	8b 55 08             	mov    0x8(%ebp),%edx
f0102875:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0102878:	eb 01                	jmp    f010287b <strtol+0xf>
		s++;
f010287a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010287b:	8a 02                	mov    (%edx),%al
f010287d:	3c 20                	cmp    $0x20,%al
f010287f:	74 f9                	je     f010287a <strtol+0xe>
f0102881:	3c 09                	cmp    $0x9,%al
f0102883:	74 f5                	je     f010287a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0102885:	3c 2b                	cmp    $0x2b,%al
f0102887:	75 08                	jne    f0102891 <strtol+0x25>
		s++;
f0102889:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010288a:	bf 00 00 00 00       	mov    $0x0,%edi
f010288f:	eb 13                	jmp    f01028a4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0102891:	3c 2d                	cmp    $0x2d,%al
f0102893:	75 0a                	jne    f010289f <strtol+0x33>
		s++, neg = 1;
f0102895:	8d 52 01             	lea    0x1(%edx),%edx
f0102898:	bf 01 00 00 00       	mov    $0x1,%edi
f010289d:	eb 05                	jmp    f01028a4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010289f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01028a4:	85 db                	test   %ebx,%ebx
f01028a6:	74 05                	je     f01028ad <strtol+0x41>
f01028a8:	83 fb 10             	cmp    $0x10,%ebx
f01028ab:	75 28                	jne    f01028d5 <strtol+0x69>
f01028ad:	8a 02                	mov    (%edx),%al
f01028af:	3c 30                	cmp    $0x30,%al
f01028b1:	75 10                	jne    f01028c3 <strtol+0x57>
f01028b3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01028b7:	75 0a                	jne    f01028c3 <strtol+0x57>
		s += 2, base = 16;
f01028b9:	83 c2 02             	add    $0x2,%edx
f01028bc:	bb 10 00 00 00       	mov    $0x10,%ebx
f01028c1:	eb 12                	jmp    f01028d5 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f01028c3:	85 db                	test   %ebx,%ebx
f01028c5:	75 0e                	jne    f01028d5 <strtol+0x69>
f01028c7:	3c 30                	cmp    $0x30,%al
f01028c9:	75 05                	jne    f01028d0 <strtol+0x64>
		s++, base = 8;
f01028cb:	42                   	inc    %edx
f01028cc:	b3 08                	mov    $0x8,%bl
f01028ce:	eb 05                	jmp    f01028d5 <strtol+0x69>
	else if (base == 0)
		base = 10;
f01028d0:	bb 0a 00 00 00       	mov    $0xa,%ebx
f01028d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01028da:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01028dc:	8a 0a                	mov    (%edx),%cl
f01028de:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01028e1:	80 fb 09             	cmp    $0x9,%bl
f01028e4:	77 08                	ja     f01028ee <strtol+0x82>
			dig = *s - '0';
f01028e6:	0f be c9             	movsbl %cl,%ecx
f01028e9:	83 e9 30             	sub    $0x30,%ecx
f01028ec:	eb 1e                	jmp    f010290c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01028ee:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01028f1:	80 fb 19             	cmp    $0x19,%bl
f01028f4:	77 08                	ja     f01028fe <strtol+0x92>
			dig = *s - 'a' + 10;
f01028f6:	0f be c9             	movsbl %cl,%ecx
f01028f9:	83 e9 57             	sub    $0x57,%ecx
f01028fc:	eb 0e                	jmp    f010290c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01028fe:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0102901:	80 fb 19             	cmp    $0x19,%bl
f0102904:	77 12                	ja     f0102918 <strtol+0xac>
			dig = *s - 'A' + 10;
f0102906:	0f be c9             	movsbl %cl,%ecx
f0102909:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010290c:	39 f1                	cmp    %esi,%ecx
f010290e:	7d 0c                	jge    f010291c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0102910:	42                   	inc    %edx
f0102911:	0f af c6             	imul   %esi,%eax
f0102914:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0102916:	eb c4                	jmp    f01028dc <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0102918:	89 c1                	mov    %eax,%ecx
f010291a:	eb 02                	jmp    f010291e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010291c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010291e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0102922:	74 05                	je     f0102929 <strtol+0xbd>
		*endptr = (char *) s;
f0102924:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102927:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0102929:	85 ff                	test   %edi,%edi
f010292b:	74 04                	je     f0102931 <strtol+0xc5>
f010292d:	89 c8                	mov    %ecx,%eax
f010292f:	f7 d8                	neg    %eax
}
f0102931:	5b                   	pop    %ebx
f0102932:	5e                   	pop    %esi
f0102933:	5f                   	pop    %edi
f0102934:	5d                   	pop    %ebp
f0102935:	c3                   	ret    
	...

f0102938 <__udivdi3>:
f0102938:	55                   	push   %ebp
f0102939:	57                   	push   %edi
f010293a:	56                   	push   %esi
f010293b:	83 ec 10             	sub    $0x10,%esp
f010293e:	8b 74 24 20          	mov    0x20(%esp),%esi
f0102942:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0102946:	89 74 24 04          	mov    %esi,0x4(%esp)
f010294a:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010294e:	89 cd                	mov    %ecx,%ebp
f0102950:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0102954:	85 c0                	test   %eax,%eax
f0102956:	75 2c                	jne    f0102984 <__udivdi3+0x4c>
f0102958:	39 f9                	cmp    %edi,%ecx
f010295a:	77 68                	ja     f01029c4 <__udivdi3+0x8c>
f010295c:	85 c9                	test   %ecx,%ecx
f010295e:	75 0b                	jne    f010296b <__udivdi3+0x33>
f0102960:	b8 01 00 00 00       	mov    $0x1,%eax
f0102965:	31 d2                	xor    %edx,%edx
f0102967:	f7 f1                	div    %ecx
f0102969:	89 c1                	mov    %eax,%ecx
f010296b:	31 d2                	xor    %edx,%edx
f010296d:	89 f8                	mov    %edi,%eax
f010296f:	f7 f1                	div    %ecx
f0102971:	89 c7                	mov    %eax,%edi
f0102973:	89 f0                	mov    %esi,%eax
f0102975:	f7 f1                	div    %ecx
f0102977:	89 c6                	mov    %eax,%esi
f0102979:	89 f0                	mov    %esi,%eax
f010297b:	89 fa                	mov    %edi,%edx
f010297d:	83 c4 10             	add    $0x10,%esp
f0102980:	5e                   	pop    %esi
f0102981:	5f                   	pop    %edi
f0102982:	5d                   	pop    %ebp
f0102983:	c3                   	ret    
f0102984:	39 f8                	cmp    %edi,%eax
f0102986:	77 2c                	ja     f01029b4 <__udivdi3+0x7c>
f0102988:	0f bd f0             	bsr    %eax,%esi
f010298b:	83 f6 1f             	xor    $0x1f,%esi
f010298e:	75 4c                	jne    f01029dc <__udivdi3+0xa4>
f0102990:	39 f8                	cmp    %edi,%eax
f0102992:	bf 00 00 00 00       	mov    $0x0,%edi
f0102997:	72 0a                	jb     f01029a3 <__udivdi3+0x6b>
f0102999:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f010299d:	0f 87 ad 00 00 00    	ja     f0102a50 <__udivdi3+0x118>
f01029a3:	be 01 00 00 00       	mov    $0x1,%esi
f01029a8:	89 f0                	mov    %esi,%eax
f01029aa:	89 fa                	mov    %edi,%edx
f01029ac:	83 c4 10             	add    $0x10,%esp
f01029af:	5e                   	pop    %esi
f01029b0:	5f                   	pop    %edi
f01029b1:	5d                   	pop    %ebp
f01029b2:	c3                   	ret    
f01029b3:	90                   	nop
f01029b4:	31 ff                	xor    %edi,%edi
f01029b6:	31 f6                	xor    %esi,%esi
f01029b8:	89 f0                	mov    %esi,%eax
f01029ba:	89 fa                	mov    %edi,%edx
f01029bc:	83 c4 10             	add    $0x10,%esp
f01029bf:	5e                   	pop    %esi
f01029c0:	5f                   	pop    %edi
f01029c1:	5d                   	pop    %ebp
f01029c2:	c3                   	ret    
f01029c3:	90                   	nop
f01029c4:	89 fa                	mov    %edi,%edx
f01029c6:	89 f0                	mov    %esi,%eax
f01029c8:	f7 f1                	div    %ecx
f01029ca:	89 c6                	mov    %eax,%esi
f01029cc:	31 ff                	xor    %edi,%edi
f01029ce:	89 f0                	mov    %esi,%eax
f01029d0:	89 fa                	mov    %edi,%edx
f01029d2:	83 c4 10             	add    $0x10,%esp
f01029d5:	5e                   	pop    %esi
f01029d6:	5f                   	pop    %edi
f01029d7:	5d                   	pop    %ebp
f01029d8:	c3                   	ret    
f01029d9:	8d 76 00             	lea    0x0(%esi),%esi
f01029dc:	89 f1                	mov    %esi,%ecx
f01029de:	d3 e0                	shl    %cl,%eax
f01029e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029e4:	b8 20 00 00 00       	mov    $0x20,%eax
f01029e9:	29 f0                	sub    %esi,%eax
f01029eb:	89 ea                	mov    %ebp,%edx
f01029ed:	88 c1                	mov    %al,%cl
f01029ef:	d3 ea                	shr    %cl,%edx
f01029f1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f01029f5:	09 ca                	or     %ecx,%edx
f01029f7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01029fb:	89 f1                	mov    %esi,%ecx
f01029fd:	d3 e5                	shl    %cl,%ebp
f01029ff:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0102a03:	89 fd                	mov    %edi,%ebp
f0102a05:	88 c1                	mov    %al,%cl
f0102a07:	d3 ed                	shr    %cl,%ebp
f0102a09:	89 fa                	mov    %edi,%edx
f0102a0b:	89 f1                	mov    %esi,%ecx
f0102a0d:	d3 e2                	shl    %cl,%edx
f0102a0f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0102a13:	88 c1                	mov    %al,%cl
f0102a15:	d3 ef                	shr    %cl,%edi
f0102a17:	09 d7                	or     %edx,%edi
f0102a19:	89 f8                	mov    %edi,%eax
f0102a1b:	89 ea                	mov    %ebp,%edx
f0102a1d:	f7 74 24 08          	divl   0x8(%esp)
f0102a21:	89 d1                	mov    %edx,%ecx
f0102a23:	89 c7                	mov    %eax,%edi
f0102a25:	f7 64 24 0c          	mull   0xc(%esp)
f0102a29:	39 d1                	cmp    %edx,%ecx
f0102a2b:	72 17                	jb     f0102a44 <__udivdi3+0x10c>
f0102a2d:	74 09                	je     f0102a38 <__udivdi3+0x100>
f0102a2f:	89 fe                	mov    %edi,%esi
f0102a31:	31 ff                	xor    %edi,%edi
f0102a33:	e9 41 ff ff ff       	jmp    f0102979 <__udivdi3+0x41>
f0102a38:	8b 54 24 04          	mov    0x4(%esp),%edx
f0102a3c:	89 f1                	mov    %esi,%ecx
f0102a3e:	d3 e2                	shl    %cl,%edx
f0102a40:	39 c2                	cmp    %eax,%edx
f0102a42:	73 eb                	jae    f0102a2f <__udivdi3+0xf7>
f0102a44:	8d 77 ff             	lea    -0x1(%edi),%esi
f0102a47:	31 ff                	xor    %edi,%edi
f0102a49:	e9 2b ff ff ff       	jmp    f0102979 <__udivdi3+0x41>
f0102a4e:	66 90                	xchg   %ax,%ax
f0102a50:	31 f6                	xor    %esi,%esi
f0102a52:	e9 22 ff ff ff       	jmp    f0102979 <__udivdi3+0x41>
	...

f0102a58 <__umoddi3>:
f0102a58:	55                   	push   %ebp
f0102a59:	57                   	push   %edi
f0102a5a:	56                   	push   %esi
f0102a5b:	83 ec 20             	sub    $0x20,%esp
f0102a5e:	8b 44 24 30          	mov    0x30(%esp),%eax
f0102a62:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0102a66:	89 44 24 14          	mov    %eax,0x14(%esp)
f0102a6a:	8b 74 24 34          	mov    0x34(%esp),%esi
f0102a6e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102a72:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0102a76:	89 c7                	mov    %eax,%edi
f0102a78:	89 f2                	mov    %esi,%edx
f0102a7a:	85 ed                	test   %ebp,%ebp
f0102a7c:	75 16                	jne    f0102a94 <__umoddi3+0x3c>
f0102a7e:	39 f1                	cmp    %esi,%ecx
f0102a80:	0f 86 a6 00 00 00    	jbe    f0102b2c <__umoddi3+0xd4>
f0102a86:	f7 f1                	div    %ecx
f0102a88:	89 d0                	mov    %edx,%eax
f0102a8a:	31 d2                	xor    %edx,%edx
f0102a8c:	83 c4 20             	add    $0x20,%esp
f0102a8f:	5e                   	pop    %esi
f0102a90:	5f                   	pop    %edi
f0102a91:	5d                   	pop    %ebp
f0102a92:	c3                   	ret    
f0102a93:	90                   	nop
f0102a94:	39 f5                	cmp    %esi,%ebp
f0102a96:	0f 87 ac 00 00 00    	ja     f0102b48 <__umoddi3+0xf0>
f0102a9c:	0f bd c5             	bsr    %ebp,%eax
f0102a9f:	83 f0 1f             	xor    $0x1f,%eax
f0102aa2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0102aa6:	0f 84 a8 00 00 00    	je     f0102b54 <__umoddi3+0xfc>
f0102aac:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0102ab0:	d3 e5                	shl    %cl,%ebp
f0102ab2:	bf 20 00 00 00       	mov    $0x20,%edi
f0102ab7:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0102abb:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0102abf:	89 f9                	mov    %edi,%ecx
f0102ac1:	d3 e8                	shr    %cl,%eax
f0102ac3:	09 e8                	or     %ebp,%eax
f0102ac5:	89 44 24 18          	mov    %eax,0x18(%esp)
f0102ac9:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0102acd:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0102ad1:	d3 e0                	shl    %cl,%eax
f0102ad3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ad7:	89 f2                	mov    %esi,%edx
f0102ad9:	d3 e2                	shl    %cl,%edx
f0102adb:	8b 44 24 14          	mov    0x14(%esp),%eax
f0102adf:	d3 e0                	shl    %cl,%eax
f0102ae1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0102ae5:	8b 44 24 14          	mov    0x14(%esp),%eax
f0102ae9:	89 f9                	mov    %edi,%ecx
f0102aeb:	d3 e8                	shr    %cl,%eax
f0102aed:	09 d0                	or     %edx,%eax
f0102aef:	d3 ee                	shr    %cl,%esi
f0102af1:	89 f2                	mov    %esi,%edx
f0102af3:	f7 74 24 18          	divl   0x18(%esp)
f0102af7:	89 d6                	mov    %edx,%esi
f0102af9:	f7 64 24 0c          	mull   0xc(%esp)
f0102afd:	89 c5                	mov    %eax,%ebp
f0102aff:	89 d1                	mov    %edx,%ecx
f0102b01:	39 d6                	cmp    %edx,%esi
f0102b03:	72 67                	jb     f0102b6c <__umoddi3+0x114>
f0102b05:	74 75                	je     f0102b7c <__umoddi3+0x124>
f0102b07:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0102b0b:	29 e8                	sub    %ebp,%eax
f0102b0d:	19 ce                	sbb    %ecx,%esi
f0102b0f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0102b13:	d3 e8                	shr    %cl,%eax
f0102b15:	89 f2                	mov    %esi,%edx
f0102b17:	89 f9                	mov    %edi,%ecx
f0102b19:	d3 e2                	shl    %cl,%edx
f0102b1b:	09 d0                	or     %edx,%eax
f0102b1d:	89 f2                	mov    %esi,%edx
f0102b1f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0102b23:	d3 ea                	shr    %cl,%edx
f0102b25:	83 c4 20             	add    $0x20,%esp
f0102b28:	5e                   	pop    %esi
f0102b29:	5f                   	pop    %edi
f0102b2a:	5d                   	pop    %ebp
f0102b2b:	c3                   	ret    
f0102b2c:	85 c9                	test   %ecx,%ecx
f0102b2e:	75 0b                	jne    f0102b3b <__umoddi3+0xe3>
f0102b30:	b8 01 00 00 00       	mov    $0x1,%eax
f0102b35:	31 d2                	xor    %edx,%edx
f0102b37:	f7 f1                	div    %ecx
f0102b39:	89 c1                	mov    %eax,%ecx
f0102b3b:	89 f0                	mov    %esi,%eax
f0102b3d:	31 d2                	xor    %edx,%edx
f0102b3f:	f7 f1                	div    %ecx
f0102b41:	89 f8                	mov    %edi,%eax
f0102b43:	e9 3e ff ff ff       	jmp    f0102a86 <__umoddi3+0x2e>
f0102b48:	89 f2                	mov    %esi,%edx
f0102b4a:	83 c4 20             	add    $0x20,%esp
f0102b4d:	5e                   	pop    %esi
f0102b4e:	5f                   	pop    %edi
f0102b4f:	5d                   	pop    %ebp
f0102b50:	c3                   	ret    
f0102b51:	8d 76 00             	lea    0x0(%esi),%esi
f0102b54:	39 f5                	cmp    %esi,%ebp
f0102b56:	72 04                	jb     f0102b5c <__umoddi3+0x104>
f0102b58:	39 f9                	cmp    %edi,%ecx
f0102b5a:	77 06                	ja     f0102b62 <__umoddi3+0x10a>
f0102b5c:	89 f2                	mov    %esi,%edx
f0102b5e:	29 cf                	sub    %ecx,%edi
f0102b60:	19 ea                	sbb    %ebp,%edx
f0102b62:	89 f8                	mov    %edi,%eax
f0102b64:	83 c4 20             	add    $0x20,%esp
f0102b67:	5e                   	pop    %esi
f0102b68:	5f                   	pop    %edi
f0102b69:	5d                   	pop    %ebp
f0102b6a:	c3                   	ret    
f0102b6b:	90                   	nop
f0102b6c:	89 d1                	mov    %edx,%ecx
f0102b6e:	89 c5                	mov    %eax,%ebp
f0102b70:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0102b74:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0102b78:	eb 8d                	jmp    f0102b07 <__umoddi3+0xaf>
f0102b7a:	66 90                	xchg   %ax,%ax
f0102b7c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0102b80:	72 ea                	jb     f0102b6c <__umoddi3+0x114>
f0102b82:	89 f1                	mov    %esi,%ecx
f0102b84:	eb 81                	jmp    f0102b07 <__umoddi3+0xaf>
