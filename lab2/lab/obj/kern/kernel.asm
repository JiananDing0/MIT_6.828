
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
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

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
f0100046:	b8 60 f9 11 f0       	mov    $0xf011f960,%eax
f010004b:	2d 00 f3 11 f0       	sub    $0xf011f300,%eax
f0100050:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100054:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010005b:	00 
f010005c:	c7 04 24 00 f3 11 f0 	movl   $0xf011f300,(%esp)
f0100063:	e8 96 36 00 00       	call   f01036fe <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 70 04 00 00       	call   f01004dd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 60 3b 10 f0 	movl   $0xf0103b60,(%esp)
f010007c:	e8 d9 2b 00 00       	call   f0102c5a <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 4e 10 00 00       	call   f01010d4 <mem_init>

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
f010009f:	83 3d 64 f9 11 f0 00 	cmpl   $0x0,0xf011f964
f01000a6:	75 3d                	jne    f01000e5 <_panic+0x51>
		goto dead;
	panicstr = fmt;
f01000a8:	89 35 64 f9 11 f0    	mov    %esi,0xf011f964

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
f01000c1:	c7 04 24 7b 3b 10 f0 	movl   $0xf0103b7b,(%esp)
f01000c8:	e8 8d 2b 00 00       	call   f0102c5a <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 4e 2b 00 00       	call   f0102c27 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 04 4b 10 f0 	movl   $0xf0104b04,(%esp)
f01000e0:	e8 75 2b 00 00       	call   f0102c5a <cprintf>
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
f010010b:	c7 04 24 93 3b 10 f0 	movl   $0xf0103b93,(%esp)
f0100112:	e8 43 2b 00 00       	call   f0102c5a <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 01 2b 00 00       	call   f0102c27 <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 04 4b 10 f0 	movl   $0xf0104b04,(%esp)
f010012d:	e8 28 2b 00 00       	call   f0102c5a <cprintf>
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
f0100171:	8b 15 24 f5 11 f0    	mov    0xf011f524,%edx
f0100177:	88 82 20 f3 11 f0    	mov    %al,-0xfee0ce0(%edx)
f010017d:	8d 42 01             	lea    0x1(%edx),%eax
f0100180:	a3 24 f5 11 f0       	mov    %eax,0xf011f524
		if (cons.wpos == CONSBUFSIZE)
f0100185:	3d 00 02 00 00       	cmp    $0x200,%eax
f010018a:	75 0a                	jne    f0100196 <cons_intr+0x34>
			cons.wpos = 0;
f010018c:	c7 05 24 f5 11 f0 00 	movl   $0x0,0xf011f524
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
f010023c:	66 a1 34 f5 11 f0    	mov    0xf011f534,%ax
f0100242:	66 85 c0             	test   %ax,%ax
f0100245:	0f 84 e2 00 00 00    	je     f010032d <cons_putc+0x18a>
			crt_pos--;
f010024b:	48                   	dec    %eax
f010024c:	66 a3 34 f5 11 f0    	mov    %ax,0xf011f534
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100252:	0f b7 c0             	movzwl %ax,%eax
f0100255:	81 e6 00 ff ff ff    	and    $0xffffff00,%esi
f010025b:	83 ce 20             	or     $0x20,%esi
f010025e:	8b 15 30 f5 11 f0    	mov    0xf011f530,%edx
f0100264:	66 89 34 42          	mov    %si,(%edx,%eax,2)
f0100268:	eb 78                	jmp    f01002e2 <cons_putc+0x13f>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010026a:	66 83 05 34 f5 11 f0 	addw   $0x50,0xf011f534
f0100271:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100272:	66 8b 0d 34 f5 11 f0 	mov    0xf011f534,%cx
f0100279:	bb 50 00 00 00       	mov    $0x50,%ebx
f010027e:	89 c8                	mov    %ecx,%eax
f0100280:	ba 00 00 00 00       	mov    $0x0,%edx
f0100285:	66 f7 f3             	div    %bx
f0100288:	66 29 d1             	sub    %dx,%cx
f010028b:	66 89 0d 34 f5 11 f0 	mov    %cx,0xf011f534
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
f01002c8:	66 a1 34 f5 11 f0    	mov    0xf011f534,%ax
f01002ce:	0f b7 c8             	movzwl %ax,%ecx
f01002d1:	8b 15 30 f5 11 f0    	mov    0xf011f530,%edx
f01002d7:	66 89 34 4a          	mov    %si,(%edx,%ecx,2)
f01002db:	40                   	inc    %eax
f01002dc:	66 a3 34 f5 11 f0    	mov    %ax,0xf011f534
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01002e2:	66 81 3d 34 f5 11 f0 	cmpw   $0x7cf,0xf011f534
f01002e9:	cf 07 
f01002eb:	76 40                	jbe    f010032d <cons_putc+0x18a>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01002ed:	a1 30 f5 11 f0       	mov    0xf011f530,%eax
f01002f2:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f01002f9:	00 
f01002fa:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100300:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100304:	89 04 24             	mov    %eax,(%esp)
f0100307:	e8 3c 34 00 00       	call   f0103748 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010030c:	8b 15 30 f5 11 f0    	mov    0xf011f530,%edx
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
f0100325:	66 83 2d 34 f5 11 f0 	subw   $0x50,0xf011f534
f010032c:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010032d:	8b 0d 2c f5 11 f0    	mov    0xf011f52c,%ecx
f0100333:	b0 0e                	mov    $0xe,%al
f0100335:	89 ca                	mov    %ecx,%edx
f0100337:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100338:	66 8b 35 34 f5 11 f0 	mov    0xf011f534,%si
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
f0100386:	83 0d 28 f5 11 f0 40 	orl    $0x40,0xf011f528
		return 0;
f010038d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100392:	e9 ca 00 00 00       	jmp    f0100461 <kbd_proc_data+0x104>
	} else if (data & 0x80) {
f0100397:	84 c0                	test   %al,%al
f0100399:	79 33                	jns    f01003ce <kbd_proc_data+0x71>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010039b:	8b 0d 28 f5 11 f0    	mov    0xf011f528,%ecx
f01003a1:	f6 c1 40             	test   $0x40,%cl
f01003a4:	75 05                	jne    f01003ab <kbd_proc_data+0x4e>
f01003a6:	88 c2                	mov    %al,%dl
f01003a8:	83 e2 7f             	and    $0x7f,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01003ab:	0f b6 d2             	movzbl %dl,%edx
f01003ae:	8a 82 e0 3b 10 f0    	mov    -0xfefc420(%edx),%al
f01003b4:	83 c8 40             	or     $0x40,%eax
f01003b7:	0f b6 c0             	movzbl %al,%eax
f01003ba:	f7 d0                	not    %eax
f01003bc:	21 c1                	and    %eax,%ecx
f01003be:	89 0d 28 f5 11 f0    	mov    %ecx,0xf011f528
		return 0;
f01003c4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003c9:	e9 93 00 00 00       	jmp    f0100461 <kbd_proc_data+0x104>
	} else if (shift & E0ESC) {
f01003ce:	8b 0d 28 f5 11 f0    	mov    0xf011f528,%ecx
f01003d4:	f6 c1 40             	test   $0x40,%cl
f01003d7:	74 0e                	je     f01003e7 <kbd_proc_data+0x8a>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01003d9:	88 c2                	mov    %al,%dl
f01003db:	83 ca 80             	or     $0xffffff80,%edx
		shift &= ~E0ESC;
f01003de:	83 e1 bf             	and    $0xffffffbf,%ecx
f01003e1:	89 0d 28 f5 11 f0    	mov    %ecx,0xf011f528
	}

	shift |= shiftcode[data];
f01003e7:	0f b6 d2             	movzbl %dl,%edx
f01003ea:	0f b6 82 e0 3b 10 f0 	movzbl -0xfefc420(%edx),%eax
f01003f1:	0b 05 28 f5 11 f0    	or     0xf011f528,%eax
	shift ^= togglecode[data];
f01003f7:	0f b6 8a e0 3c 10 f0 	movzbl -0xfefc320(%edx),%ecx
f01003fe:	31 c8                	xor    %ecx,%eax
f0100400:	a3 28 f5 11 f0       	mov    %eax,0xf011f528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100405:	89 c1                	mov    %eax,%ecx
f0100407:	83 e1 03             	and    $0x3,%ecx
f010040a:	8b 0c 8d e0 3d 10 f0 	mov    -0xfefc220(,%ecx,4),%ecx
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
f010043f:	c7 04 24 ad 3b 10 f0 	movl   $0xf0103bad,(%esp)
f0100446:	e8 0f 28 00 00       	call   f0102c5a <cprintf>
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
f010046f:	80 3d 00 f3 11 f0 00 	cmpb   $0x0,0xf011f300
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
f01004a6:	8b 15 20 f5 11 f0    	mov    0xf011f520,%edx
f01004ac:	3b 15 24 f5 11 f0    	cmp    0xf011f524,%edx
f01004b2:	74 22                	je     f01004d6 <cons_getc+0x40>
		c = cons.buf[cons.rpos++];
f01004b4:	0f b6 82 20 f3 11 f0 	movzbl -0xfee0ce0(%edx),%eax
f01004bb:	42                   	inc    %edx
f01004bc:	89 15 20 f5 11 f0    	mov    %edx,0xf011f520
		if (cons.rpos == CONSBUFSIZE)
f01004c2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004c8:	75 11                	jne    f01004db <cons_getc+0x45>
			cons.rpos = 0;
f01004ca:	c7 05 20 f5 11 f0 00 	movl   $0x0,0xf011f520
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
f0100502:	c7 05 2c f5 11 f0 b4 	movl   $0x3b4,0xf011f52c
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
f010051a:	c7 05 2c f5 11 f0 d4 	movl   $0x3d4,0xf011f52c
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
f0100529:	8b 0d 2c f5 11 f0    	mov    0xf011f52c,%ecx
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
f0100548:	89 35 30 f5 11 f0    	mov    %esi,0xf011f530

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f010054e:	0f b6 d8             	movzbl %al,%ebx
f0100551:	09 df                	or     %ebx,%edi

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f0100553:	66 89 3d 34 f5 11 f0 	mov    %di,0xf011f534
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
f0100593:	a2 00 f3 11 f0       	mov    %al,0xf011f300
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
f01005a4:	c7 04 24 b9 3b 10 f0 	movl   $0xf0103bb9,(%esp)
f01005ab:	e8 aa 26 00 00       	call   f0102c5a <cprintf>
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
f01005ea:	c7 04 24 f0 3d 10 f0 	movl   $0xf0103df0,(%esp)
f01005f1:	e8 64 26 00 00       	call   f0102c5a <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005f6:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01005fd:	00 
f01005fe:	c7 04 24 a8 3e 10 f0 	movl   $0xf0103ea8,(%esp)
f0100605:	e8 50 26 00 00       	call   f0102c5a <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010060a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100611:	00 
f0100612:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100619:	f0 
f010061a:	c7 04 24 d0 3e 10 f0 	movl   $0xf0103ed0,(%esp)
f0100621:	e8 34 26 00 00       	call   f0102c5a <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100626:	c7 44 24 08 42 3b 10 	movl   $0x103b42,0x8(%esp)
f010062d:	00 
f010062e:	c7 44 24 04 42 3b 10 	movl   $0xf0103b42,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 f4 3e 10 f0 	movl   $0xf0103ef4,(%esp)
f010063d:	e8 18 26 00 00       	call   f0102c5a <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100642:	c7 44 24 08 00 f3 11 	movl   $0x11f300,0x8(%esp)
f0100649:	00 
f010064a:	c7 44 24 04 00 f3 11 	movl   $0xf011f300,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 18 3f 10 f0 	movl   $0xf0103f18,(%esp)
f0100659:	e8 fc 25 00 00       	call   f0102c5a <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010065e:	c7 44 24 08 60 f9 11 	movl   $0x11f960,0x8(%esp)
f0100665:	00 
f0100666:	c7 44 24 04 60 f9 11 	movl   $0xf011f960,0x4(%esp)
f010066d:	f0 
f010066e:	c7 04 24 3c 3f 10 f0 	movl   $0xf0103f3c,(%esp)
f0100675:	e8 e0 25 00 00       	call   f0102c5a <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010067a:	b8 5f fd 11 f0       	mov    $0xf011fd5f,%eax
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
f010069c:	c7 04 24 60 3f 10 f0 	movl   $0xf0103f60,(%esp)
f01006a3:	e8 b2 25 00 00       	call   f0102c5a <cprintf>
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
f01006bb:	8b 83 64 40 10 f0    	mov    -0xfefbf9c(%ebx),%eax
f01006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006c5:	8b 83 60 40 10 f0    	mov    -0xfefbfa0(%ebx),%eax
f01006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006cf:	c7 04 24 09 3e 10 f0 	movl   $0xf0103e09,(%esp)
f01006d6:	e8 7f 25 00 00       	call   f0102c5a <cprintf>
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
f01006f9:	c7 04 24 12 3e 10 f0 	movl   $0xf0103e12,(%esp)
f0100700:	e8 55 25 00 00       	call   f0102c5a <cprintf>
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
f0100732:	e8 1d 26 00 00       	call   f0102d54 <debuginfo_eip>
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
f010075f:	c7 04 24 8c 3f 10 f0 	movl   $0xf0103f8c,(%esp)
f0100766:	e8 ef 24 00 00       	call   f0102c5a <cprintf>
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
f010078e:	c7 04 24 24 3e 10 f0 	movl   $0xf0103e24,(%esp)
f0100795:	e8 c0 24 00 00       	call   f0102c5a <cprintf>
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
f01007ba:	c7 04 24 c0 3f 10 f0 	movl   $0xf0103fc0,(%esp)
f01007c1:	e8 94 24 00 00       	call   f0102c5a <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007c6:	c7 04 24 e4 3f 10 f0 	movl   $0xf0103fe4,(%esp)
f01007cd:	e8 88 24 00 00       	call   f0102c5a <cprintf>


	while (1) {
		buf = readline("K> ");
f01007d2:	c7 04 24 35 3e 10 f0 	movl   $0xf0103e35,(%esp)
f01007d9:	e8 f6 2c 00 00       	call   f01034d4 <readline>
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
f0100803:	c7 04 24 39 3e 10 f0 	movl   $0xf0103e39,(%esp)
f010080a:	e8 ba 2e 00 00       	call   f01036c9 <strchr>
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
f0100825:	c7 04 24 3e 3e 10 f0 	movl   $0xf0103e3e,(%esp)
f010082c:	e8 29 24 00 00       	call   f0102c5a <cprintf>
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
f0100848:	c7 04 24 39 3e 10 f0 	movl   $0xf0103e39,(%esp)
f010084f:	e8 75 2e 00 00       	call   f01036c9 <strchr>
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
f010086a:	bb 60 40 10 f0       	mov    $0xf0104060,%ebx
f010086f:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100874:	8b 03                	mov    (%ebx),%eax
f0100876:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010087d:	89 04 24             	mov    %eax,(%esp)
f0100880:	e8 f1 2d 00 00       	call   f0103676 <strcmp>
f0100885:	85 c0                	test   %eax,%eax
f0100887:	75 24                	jne    f01008ad <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f0100889:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010088c:	8b 55 08             	mov    0x8(%ebp),%edx
f010088f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100893:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100896:	89 54 24 04          	mov    %edx,0x4(%esp)
f010089a:	89 34 24             	mov    %esi,(%esp)
f010089d:	ff 14 85 68 40 10 f0 	call   *-0xfefbf98(,%eax,4)


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
f01008bd:	c7 04 24 5b 3e 10 f0 	movl   $0xf0103e5b,(%esp)
f01008c4:	e8 91 23 00 00       	call   f0102c5a <cprintf>
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
f01008f4:	3b 0d 68 f9 11 f0    	cmp    0xf011f968,%ecx
f01008fa:	72 20                	jb     f010091c <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008fc:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100900:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0100907:	f0 
f0100908:	c7 44 24 04 ea 02 00 	movl   $0x2ea,0x4(%esp)
f010090f:	00 
f0100910:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
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
check_va2pa(pde_t *pgdir, uintptr_t va)
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
f0100952:	e8 95 22 00 00       	call   f0102bec <mc146818_read>
f0100957:	89 c6                	mov    %eax,%esi
f0100959:	43                   	inc    %ebx
f010095a:	89 1c 24             	mov    %ebx,(%esp)
f010095d:	e8 8a 22 00 00       	call   f0102bec <mc146818_read>
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
f0100977:	83 3d 3c f5 11 f0 00 	cmpl   $0x0,0xf011f53c
f010097e:	75 11                	jne    f0100991 <boot_alloc+0x23>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100980:	ba 5f 09 12 f0       	mov    $0xf012095f,%edx
f0100985:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010098b:	89 15 3c f5 11 f0    	mov    %edx,0xf011f53c
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	assert(n >= 0);
	// Convert to physical address
	result = (char *)PADDR(nextfree);
f0100991:	8b 15 3c f5 11 f0    	mov    0xf011f53c,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100997:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010099d:	77 20                	ja     f01009bf <boot_alloc+0x51>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010099f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01009a3:	c7 44 24 08 a8 40 10 	movl   $0xf01040a8,0x8(%esp)
f01009aa:	f0 
f01009ab:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01009b2:	00 
f01009b3:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01009ba:	e8 d5 f6 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f01009bf:	8d 8a 00 00 00 10    	lea    0x10000000(%edx),%ecx
	// Determine whether it is out of bound
	if ((physaddr_t)result + n > PGSIZE * npages) {
f01009c5:	8b 1d 68 f9 11 f0    	mov    0xf011f968,%ebx
f01009cb:	8d 3c 01             	lea    (%ecx,%eax,1),%edi
f01009ce:	89 de                	mov    %ebx,%esi
f01009d0:	c1 e6 0c             	shl    $0xc,%esi
f01009d3:	39 f7                	cmp    %esi,%edi
f01009d5:	76 1c                	jbe    f01009f3 <boot_alloc+0x85>
		panic("boot_alloc: out of memory!");
f01009d7:	c7 44 24 08 44 48 10 	movl   $0xf0104844,0x8(%esp)
f01009de:	f0 
f01009df:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f01009e6:	00 
f01009e7:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01009ee:	e8 a1 f6 ff ff       	call   f0100094 <_panic>
	}
	// Otherwise, update value of nextfree, no update when n == 0
	nextfree += ROUNDUP(n, PGSIZE);
f01009f3:	05 ff 0f 00 00       	add    $0xfff,%eax
f01009f8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01009fd:	01 d0                	add    %edx,%eax
f01009ff:	a3 3c f5 11 f0       	mov    %eax,0xf011f53c
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
f0100a11:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0100a18:	f0 
f0100a19:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100a20:	00 
f0100a21:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
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
f0100a4b:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f0100a51:	85 d2                	test   %edx,%edx
f0100a53:	75 1c                	jne    f0100a71 <check_page_free_list+0x3a>
		panic("'page_free_list' is a null pointer!");
f0100a55:	c7 44 24 08 cc 40 10 	movl   $0xf01040cc,0x8(%esp)
f0100a5c:	f0 
f0100a5d:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
f0100a64:	00 
f0100a65:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
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
f0100a83:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
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
f0100abb:	a3 40 f5 11 f0       	mov    %eax,0xf011f540
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ac0:	8b 1d 40 f5 11 f0    	mov    0xf011f540,%ebx
f0100ac6:	eb 63                	jmp    f0100b2b <check_page_free_list+0xf4>
f0100ac8:	89 d8                	mov    %ebx,%eax
f0100aca:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
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
f0100ae4:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0100aea:	72 20                	jb     f0100b0c <check_page_free_list+0xd5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100aec:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100af0:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0100af7:	f0 
f0100af8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100aff:	00 
f0100b00:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f0100b07:	e8 88 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b0c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b13:	00 
f0100b14:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b1b:	00 
	return (void *)(pa + KERNBASE);
f0100b1c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b21:	89 04 24             	mov    %eax,(%esp)
f0100b24:	e8 d5 2b 00 00       	call   f01036fe <memset>
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
f0100b3c:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b42:	8b 0d 70 f9 11 f0    	mov    0xf011f970,%ecx
		assert(pp < pages + npages);
f0100b48:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
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
f0100b6b:	c7 44 24 0c 6d 48 10 	movl   $0xf010486d,0xc(%esp)
f0100b72:	f0 
f0100b73:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100b7a:	f0 
f0100b7b:	c7 44 24 04 46 02 00 	movl   $0x246,0x4(%esp)
f0100b82:	00 
f0100b83:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100b8a:	e8 05 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b8f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b92:	72 24                	jb     f0100bb8 <check_page_free_list+0x181>
f0100b94:	c7 44 24 0c 8e 48 10 	movl   $0xf010488e,0xc(%esp)
f0100b9b:	f0 
f0100b9c:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100ba3:	f0 
f0100ba4:	c7 44 24 04 47 02 00 	movl   $0x247,0x4(%esp)
f0100bab:	00 
f0100bac:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100bb3:	e8 dc f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bb8:	89 d0                	mov    %edx,%eax
f0100bba:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bbd:	a8 07                	test   $0x7,%al
f0100bbf:	74 24                	je     f0100be5 <check_page_free_list+0x1ae>
f0100bc1:	c7 44 24 0c f0 40 10 	movl   $0xf01040f0,0xc(%esp)
f0100bc8:	f0 
f0100bc9:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100bd0:	f0 
f0100bd1:	c7 44 24 04 48 02 00 	movl   $0x248,0x4(%esp)
f0100bd8:	00 
f0100bd9:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
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
f0100bed:	c7 44 24 0c a2 48 10 	movl   $0xf01048a2,0xc(%esp)
f0100bf4:	f0 
f0100bf5:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100bfc:	f0 
f0100bfd:	c7 44 24 04 4b 02 00 	movl   $0x24b,0x4(%esp)
f0100c04:	00 
f0100c05:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100c0c:	e8 83 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c11:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c16:	75 24                	jne    f0100c3c <check_page_free_list+0x205>
f0100c18:	c7 44 24 0c b3 48 10 	movl   $0xf01048b3,0xc(%esp)
f0100c1f:	f0 
f0100c20:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100c27:	f0 
f0100c28:	c7 44 24 04 4c 02 00 	movl   $0x24c,0x4(%esp)
f0100c2f:	00 
f0100c30:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100c37:	e8 58 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c3c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c41:	75 24                	jne    f0100c67 <check_page_free_list+0x230>
f0100c43:	c7 44 24 0c 24 41 10 	movl   $0xf0104124,0xc(%esp)
f0100c4a:	f0 
f0100c4b:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100c52:	f0 
f0100c53:	c7 44 24 04 4d 02 00 	movl   $0x24d,0x4(%esp)
f0100c5a:	00 
f0100c5b:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100c62:	e8 2d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c67:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c6c:	75 24                	jne    f0100c92 <check_page_free_list+0x25b>
f0100c6e:	c7 44 24 0c cc 48 10 	movl   $0xf01048cc,0xc(%esp)
f0100c75:	f0 
f0100c76:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100c7d:	f0 
f0100c7e:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f0100c85:	00 
f0100c86:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
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
f0100ca7:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100cb6:	00 
f0100cb7:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f0100cbe:	e8 d1 f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100cc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cc8:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100ccb:	76 27                	jbe    f0100cf4 <check_page_free_list+0x2bd>
f0100ccd:	c7 44 24 0c 48 41 10 	movl   $0xf0104148,0xc(%esp)
f0100cd4:	f0 
f0100cd5:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100cdc:	f0 
f0100cdd:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
f0100ce4:	00 
f0100ce5:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
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
f0100d03:	c7 44 24 0c e6 48 10 	movl   $0xf01048e6,0xc(%esp)
f0100d0a:	f0 
f0100d0b:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100d12:	f0 
f0100d13:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
f0100d1a:	00 
f0100d1b:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100d22:	e8 6d f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100d27:	85 db                	test   %ebx,%ebx
f0100d29:	7f 24                	jg     f0100d4f <check_page_free_list+0x318>
f0100d2b:	c7 44 24 0c f8 48 10 	movl   $0xf01048f8,0xc(%esp)
f0100d32:	f0 
f0100d33:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0100d3a:	f0 
f0100d3b:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
f0100d42:	00 
f0100d43:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100d4a:	e8 45 f3 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d4f:	c7 04 24 90 41 10 f0 	movl   $0xf0104190,(%esp)
f0100d56:	e8 ff 1e 00 00       	call   f0102c5a <cprintf>
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
	//     page tables and other data structures?
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
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
f0100d81:	c7 44 24 08 a8 40 10 	movl   $0xf01040a8,0x8(%esp)
f0100d88:	f0 
f0100d89:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
f0100d90:	00 
f0100d91:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100d98:	e8 f7 f2 ff ff       	call   f0100094 <_panic>
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
		// Mark first page, IO hole and first few pages on extend memory as in use.
		if ((i == 0) || (i >= npages_basemem && i < kernBound / PGSIZE)) {
f0100d9d:	8b 35 38 f5 11 f0    	mov    0xf011f538,%esi
	return (physaddr_t)kva - KERNBASE;
f0100da3:	8d b8 00 00 00 10    	lea    0x10000000(%eax),%edi
f0100da9:	c1 ef 0c             	shr    $0xc,%edi
f0100dac:	8b 1d 40 f5 11 f0    	mov    0xf011f540,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
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
f0100dca:	a1 70 f9 11 f0       	mov    0xf011f970,%eax
f0100dcf:	66 c7 44 08 04 01 00 	movw   $0x1,0x4(%eax,%ecx,1)
f0100dd6:	eb 18                	jmp    f0100df0 <page_init+0x8d>
		}
		// Rest of memory are free
		else {
			pages[i].pp_ref = 0;
f0100dd8:	89 c8                	mov    %ecx,%eax
f0100dda:	03 05 70 f9 11 f0    	add    0xf011f970,%eax
f0100de0:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
			pages[i].pp_link = page_free_list;
f0100de6:	89 18                	mov    %ebx,(%eax)
			page_free_list = &pages[i];
f0100de8:	89 cb                	mov    %ecx,%ebx
f0100dea:	03 1d 70 f9 11 f0    	add    0xf011f970,%ebx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i, kernBound = (size_t)PADDR(boot_alloc(0));
	// Variable kernBound stores the physical address of the latest nextfree.
	// Page initialization
	for (i = 0; i < npages; i++) {
f0100df0:	42                   	inc    %edx
f0100df1:	83 c1 08             	add    $0x8,%ecx
f0100df4:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0100dfa:	72 c2                	jb     f0100dbe <page_init+0x5b>
f0100dfc:	89 1d 40 f5 11 f0    	mov    %ebx,0xf011f540
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
f0100e11:	8b 1d 40 f5 11 f0    	mov    0xf011f540,%ebx
	// Check whether out of free memory
	if (!page_free_list) {
f0100e17:	85 db                	test   %ebx,%ebx
f0100e19:	74 6b                	je     f0100e86 <page_alloc+0x7c>
		return NULL;
	}
	// Set the page without change the reference bit.
	page_free_list = currPage->pp_link;
f0100e1b:	8b 03                	mov    (%ebx),%eax
f0100e1d:	a3 40 f5 11 f0       	mov    %eax,0xf011f540
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
f0100e30:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0100e36:	c1 f8 03             	sar    $0x3,%eax
f0100e39:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e3c:	89 c2                	mov    %eax,%edx
f0100e3e:	c1 ea 0c             	shr    $0xc,%edx
f0100e41:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0100e47:	72 20                	jb     f0100e69 <page_alloc+0x5f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e49:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e4d:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0100e54:	f0 
f0100e55:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e5c:	00 
f0100e5d:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
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
f0100e81:	e8 78 28 00 00       	call   f01036fe <memset>
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
	if (pp->pp_ref || pp->pp_link) {
f0100e97:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e9c:	75 05                	jne    f0100ea3 <page_free+0x15>
f0100e9e:	83 38 00             	cmpl   $0x0,(%eax)
f0100ea1:	74 1c                	je     f0100ebf <page_free+0x31>
		panic("page_free: reference bit is nonzero or link is not NULL!");
f0100ea3:	c7 44 24 08 b4 41 10 	movl   $0xf01041b4,0x8(%esp)
f0100eaa:	f0 
f0100eab:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0100eb2:	00 
f0100eb3:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100eba:	e8 d5 f1 ff ff       	call   f0100094 <_panic>
	}
	// Update the free list
	pp->pp_link = page_free_list;
f0100ebf:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f0100ec5:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ec7:	a3 40 f5 11 f0       	mov    %eax,0xf011f540
}
f0100ecc:	c9                   	leave  
f0100ecd:	c3                   	ret    

f0100ece <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ece:	55                   	push   %ebp
f0100ecf:	89 e5                	mov    %esp,%ebp
f0100ed1:	83 ec 18             	sub    $0x18,%esp
f0100ed4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (--pp->pp_ref == 0) 
f0100ed7:	8b 50 04             	mov    0x4(%eax),%edx
f0100eda:	4a                   	dec    %edx
f0100edb:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100edf:	66 85 d2             	test   %dx,%dx
f0100ee2:	75 08                	jne    f0100eec <page_decref+0x1e>
		page_free(pp);
f0100ee4:	89 04 24             	mov    %eax,(%esp)
f0100ee7:	e8 a2 ff ff ff       	call   f0100e8e <page_free>
}
f0100eec:	c9                   	leave  
f0100eed:	c3                   	ret    

f0100eee <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that manipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100eee:	55                   	push   %ebp
f0100eef:	89 e5                	mov    %esp,%ebp
f0100ef1:	56                   	push   %esi
f0100ef2:	53                   	push   %ebx
f0100ef3:	83 ec 10             	sub    $0x10,%esp
f0100ef6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	struct PageInfo *newPage;
	pde_t *pdeEntry = &pgdir[PDX(va)];
f0100ef9:	89 f3                	mov    %esi,%ebx
f0100efb:	c1 eb 16             	shr    $0x16,%ebx
f0100efe:	c1 e3 02             	shl    $0x2,%ebx
f0100f01:	03 5d 08             	add    0x8(%ebp),%ebx
	pte_t *pteEntry;
	// First extract the content stored in the page directory, 
	// it should be a physical address with some PTE information.
	// If the content is not null, convert it into virtual 
	// address and return
	if (*pdeEntry & PTE_P) {
f0100f04:	f6 03 01             	testb  $0x1,(%ebx)
f0100f07:	75 2b                	jne    f0100f34 <pgdir_walk+0x46>
		goto good;
	}
	// Otherwise, intialize a new page if permitted
	if (create) {
f0100f09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f0d:	74 6b                	je     f0100f7a <pgdir_walk+0x8c>
		newPage = page_alloc(1);
f0100f0f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f16:	e8 ef fe ff ff       	call   f0100e0a <page_alloc>
		// If the page allocation success
		if (newPage) {
f0100f1b:	85 c0                	test   %eax,%eax
f0100f1d:	74 62                	je     f0100f81 <pgdir_walk+0x93>
			newPage->pp_ref++;
f0100f1f:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f23:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0100f29:	c1 f8 03             	sar    $0x3,%eax
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
f0100f2c:	c1 e0 0c             	shl    $0xc,%eax
f0100f2f:	83 c8 07             	or     $0x7,%eax
f0100f32:	89 03                	mov    %eax,(%ebx)
		}
	}
	return NULL;

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
f0100f34:	8b 03                	mov    (%ebx),%eax
f0100f36:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f3b:	89 c2                	mov    %eax,%edx
f0100f3d:	c1 ea 0c             	shr    $0xc,%edx
f0100f40:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0100f46:	72 20                	jb     f0100f68 <pgdir_walk+0x7a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f48:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f4c:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0100f53:	f0 
f0100f54:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
f0100f5b:	00 
f0100f5c:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0100f63:	e8 2c f1 ff ff       	call   f0100094 <_panic>
	return &pteEntry[PTX(va)];
f0100f68:	c1 ee 0a             	shr    $0xa,%esi
f0100f6b:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f0100f71:	8d 84 30 00 00 00 f0 	lea    -0x10000000(%eax,%esi,1),%eax
f0100f78:	eb 0c                	jmp    f0100f86 <pgdir_walk+0x98>
			// Store correct information
			*pdeEntry = PTE_ADDR(page2pa(newPage)) | PTE_U | PTE_W | PTE_P;
			goto good;
		}
	}
	return NULL;
f0100f7a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f7f:	eb 05                	jmp    f0100f86 <pgdir_walk+0x98>
f0100f81:	b8 00 00 00 00       	mov    $0x0,%eax

good:
	pteEntry = KADDR(PTE_ADDR(*pdeEntry));
	return &pteEntry[PTX(va)];
}
f0100f86:	83 c4 10             	add    $0x10,%esp
f0100f89:	5b                   	pop    %ebx
f0100f8a:	5e                   	pop    %esi
f0100f8b:	5d                   	pop    %ebp
f0100f8c:	c3                   	ret    

f0100f8d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f8d:	55                   	push   %ebp
f0100f8e:	89 e5                	mov    %esp,%ebp
f0100f90:	53                   	push   %ebx
f0100f91:	83 ec 14             	sub    $0x14,%esp
f0100f94:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
f0100f97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100f9e:	00 
f0100f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100fa6:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fa9:	89 04 24             	mov    %eax,(%esp)
f0100fac:	e8 3d ff ff ff       	call   f0100eee <pgdir_walk>
	physaddr_t pp;
	if (!pteEntry) {
f0100fb1:	85 c0                	test   %eax,%eax
f0100fb3:	74 3f                	je     f0100ff4 <page_lookup+0x67>
		return NULL;
	}
	if (*pteEntry & PTE_P) {
f0100fb5:	f6 00 01             	testb  $0x1,(%eax)
f0100fb8:	74 41                	je     f0100ffb <page_lookup+0x6e>
		// Modify pte_store passed as a reference
		if (pte_store) {
f0100fba:	85 db                	test   %ebx,%ebx
f0100fbc:	74 02                	je     f0100fc0 <page_lookup+0x33>
		 	*pte_store = pteEntry;
f0100fbe:	89 03                	mov    %eax,(%ebx)
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
f0100fc0:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fc2:	c1 e8 0c             	shr    $0xc,%eax
f0100fc5:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f0100fcb:	72 1c                	jb     f0100fe9 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0100fcd:	c7 44 24 08 f0 41 10 	movl   $0xf01041f0,0x8(%esp)
f0100fd4:	f0 
f0100fd5:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0100fdc:	00 
f0100fdd:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f0100fe4:	e8 ab f0 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0100fe9:	c1 e0 03             	shl    $0x3,%eax
f0100fec:	03 05 70 f9 11 f0    	add    0xf011f970,%eax
		return pa2page(pp);
f0100ff2:	eb 0c                	jmp    f0101000 <page_lookup+0x73>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
	physaddr_t pp;
	if (!pteEntry) {
		return NULL;
f0100ff4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff9:	eb 05                	jmp    f0101000 <page_lookup+0x73>
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
		return pa2page(pp);
	}
	return NULL;
f0100ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101000:	83 c4 14             	add    $0x14,%esp
f0101003:	5b                   	pop    %ebx
f0101004:	5d                   	pop    %ebp
f0101005:	c3                   	ret    

f0101006 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101006:	55                   	push   %ebp
f0101007:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101009:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100c:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f010100f:	5d                   	pop    %ebp
f0101010:	c3                   	ret    

f0101011 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101011:	55                   	push   %ebp
f0101012:	89 e5                	mov    %esp,%ebp
f0101014:	56                   	push   %esi
f0101015:	53                   	push   %ebx
f0101016:	83 ec 20             	sub    $0x20,%esp
f0101019:	8b 75 08             	mov    0x8(%ebp),%esi
f010101c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// Create a ptep store
	pte_t *pteEntry;
	// Look up the page and the entry for the page
	struct PageInfo *pp = page_lookup(pgdir, va, &pteEntry);
f010101f:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101022:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101026:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010102a:	89 34 24             	mov    %esi,(%esp)
f010102d:	e8 5b ff ff ff       	call   f0100f8d <page_lookup>
	if (!pp) {
f0101032:	85 c0                	test   %eax,%eax
f0101034:	74 1d                	je     f0101053 <page_remove+0x42>
		return;
	}
	page_decref(pp);
f0101036:	89 04 24             	mov    %eax,(%esp)
f0101039:	e8 90 fe ff ff       	call   f0100ece <page_decref>
	tlb_invalidate(pgdir, va);
f010103e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101042:	89 34 24             	mov    %esi,(%esp)
f0101045:	e8 bc ff ff ff       	call   f0101006 <tlb_invalidate>
	// Enpty the page table
	*pteEntry = 0;
f010104a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010104d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f0101053:	83 c4 20             	add    $0x20,%esp
f0101056:	5b                   	pop    %ebx
f0101057:	5e                   	pop    %esi
f0101058:	5d                   	pop    %ebp
f0101059:	c3                   	ret    

f010105a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010105a:	55                   	push   %ebp
f010105b:	89 e5                	mov    %esp,%ebp
f010105d:	57                   	push   %edi
f010105e:	56                   	push   %esi
f010105f:	53                   	push   %ebx
f0101060:	83 ec 1c             	sub    $0x1c,%esp
f0101063:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101066:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
f0101069:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101070:	00 
f0101071:	8b 45 10             	mov    0x10(%ebp),%eax
f0101074:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101078:	89 3c 24             	mov    %edi,(%esp)
f010107b:	e8 6e fe ff ff       	call   f0100eee <pgdir_walk>
f0101080:	89 c6                	mov    %eax,%esi
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
f0101082:	85 c0                	test   %eax,%eax
f0101084:	74 41                	je     f01010c7 <page_insert+0x6d>
		return -E_NO_MEM;
	}
	// Increment reference bit
	pp->pp_ref++;
f0101086:	66 ff 43 04          	incw   0x4(%ebx)
	// If the page itself is valid, remove it
	if (*pteEntry & PTE_P) {
f010108a:	f6 00 01             	testb  $0x1,(%eax)
f010108d:	74 0f                	je     f010109e <page_insert+0x44>
		// If there is already a page at va, it should be removed
		page_remove(pgdir, va);
f010108f:	8b 55 10             	mov    0x10(%ebp),%edx
f0101092:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101096:	89 3c 24             	mov    %edi,(%esp)
f0101099:	e8 73 ff ff ff       	call   f0101011 <page_remove>
	}
	// Modify premission for both directory entry and page table entry
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f010109e:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a1:	83 c8 01             	or     $0x1,%eax
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010a4:	2b 1d 70 f9 11 f0    	sub    0xf011f970,%ebx
f01010aa:	c1 fb 03             	sar    $0x3,%ebx
f01010ad:	c1 e3 0c             	shl    $0xc,%ebx
f01010b0:	09 c3                	or     %eax,%ebx
f01010b2:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm;
f01010b4:	8b 45 10             	mov    0x10(%ebp),%eax
f01010b7:	c1 e8 16             	shr    $0x16,%eax
f01010ba:	8b 55 14             	mov    0x14(%ebp),%edx
f01010bd:	09 14 87             	or     %edx,(%edi,%eax,4)
	// Return success
	return 0;
f01010c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01010c5:	eb 05                	jmp    f01010cc <page_insert+0x72>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
		return -E_NO_MEM;
f01010c7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	pgdir[PDX(va)] |= perm;
	// Return success
	return 0;
	
}
f01010cc:	83 c4 1c             	add    $0x1c,%esp
f01010cf:	5b                   	pop    %ebx
f01010d0:	5e                   	pop    %esi
f01010d1:	5f                   	pop    %edi
f01010d2:	5d                   	pop    %ebp
f01010d3:	c3                   	ret    

f01010d4 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01010d4:	55                   	push   %ebp
f01010d5:	89 e5                	mov    %esp,%ebp
f01010d7:	57                   	push   %edi
f01010d8:	56                   	push   %esi
f01010d9:	53                   	push   %ebx
f01010da:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01010dd:	b8 15 00 00 00       	mov    $0x15,%eax
f01010e2:	e8 5e f8 ff ff       	call   f0100945 <nvram_read>
f01010e7:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01010e9:	b8 17 00 00 00       	mov    $0x17,%eax
f01010ee:	e8 52 f8 ff ff       	call   f0100945 <nvram_read>
f01010f3:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01010f5:	b8 34 00 00 00       	mov    $0x34,%eax
f01010fa:	e8 46 f8 ff ff       	call   f0100945 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01010ff:	c1 e0 06             	shl    $0x6,%eax
f0101102:	74 08                	je     f010110c <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f0101104:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f010110a:	eb 0e                	jmp    f010111a <mem_init+0x46>
	else if (extmem)
f010110c:	85 f6                	test   %esi,%esi
f010110e:	74 08                	je     f0101118 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0101110:	81 c6 00 04 00 00    	add    $0x400,%esi
f0101116:	eb 02                	jmp    f010111a <mem_init+0x46>
	else
		totalmem = basemem;
f0101118:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f010111a:	89 f0                	mov    %esi,%eax
f010111c:	c1 e8 02             	shr    $0x2,%eax
f010111f:	a3 68 f9 11 f0       	mov    %eax,0xf011f968
	npages_basemem = basemem / (PGSIZE / 1024);
f0101124:	89 d8                	mov    %ebx,%eax
f0101126:	c1 e8 02             	shr    $0x2,%eax
f0101129:	a3 38 f5 11 f0       	mov    %eax,0xf011f538

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010112e:	89 f0                	mov    %esi,%eax
f0101130:	29 d8                	sub    %ebx,%eax
f0101132:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101136:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010113a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010113e:	c7 04 24 10 42 10 f0 	movl   $0xf0104210,(%esp)
f0101145:	e8 10 1b 00 00       	call   f0102c5a <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010114a:	b8 00 10 00 00       	mov    $0x1000,%eax
f010114f:	e8 1a f8 ff ff       	call   f010096e <boot_alloc>
f0101154:	a3 6c f9 11 f0       	mov    %eax,0xf011f96c
	memset(kern_pgdir, 0, PGSIZE);
f0101159:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101160:	00 
f0101161:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101168:	00 
f0101169:	89 04 24             	mov    %eax,(%esp)
f010116c:	e8 8d 25 00 00       	call   f01036fe <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101171:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101176:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010117b:	77 20                	ja     f010119d <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010117d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101181:	c7 44 24 08 a8 40 10 	movl   $0xf01040a8,0x8(%esp)
f0101188:	f0 
f0101189:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101190:	00 
f0101191:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101198:	e8 f7 ee ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010119d:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01011a3:	83 ca 05             	or     $0x5,%edx
f01011a6:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f01011ac:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f01011b1:	c1 e0 03             	shl    $0x3,%eax
f01011b4:	e8 b5 f7 ff ff       	call   f010096e <boot_alloc>
f01011b9:	a3 70 f9 11 f0       	mov    %eax,0xf011f970
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f01011be:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f01011c4:	c1 e2 03             	shl    $0x3,%edx
f01011c7:	89 54 24 08          	mov    %edx,0x8(%esp)
f01011cb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011d2:	00 
f01011d3:	89 04 24             	mov    %eax,(%esp)
f01011d6:	e8 23 25 00 00       	call   f01036fe <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01011db:	e8 83 fb ff ff       	call   f0100d63 <page_init>

	check_page_free_list(1);
f01011e0:	b8 01 00 00 00       	mov    $0x1,%eax
f01011e5:	e8 4d f8 ff ff       	call   f0100a37 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01011ea:	83 3d 70 f9 11 f0 00 	cmpl   $0x0,0xf011f970
f01011f1:	75 1c                	jne    f010120f <mem_init+0x13b>
		panic("'pages' is a null pointer!");
f01011f3:	c7 44 24 08 09 49 10 	movl   $0xf0104909,0x8(%esp)
f01011fa:	f0 
f01011fb:	c7 44 24 04 6b 02 00 	movl   $0x26b,0x4(%esp)
f0101202:	00 
f0101203:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010120a:	e8 85 ee ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010120f:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f0101214:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101219:	eb 03                	jmp    f010121e <mem_init+0x14a>
		++nfree;
f010121b:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010121c:	8b 00                	mov    (%eax),%eax
f010121e:	85 c0                	test   %eax,%eax
f0101220:	75 f9                	jne    f010121b <mem_init+0x147>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101222:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101229:	e8 dc fb ff ff       	call   f0100e0a <page_alloc>
f010122e:	89 c6                	mov    %eax,%esi
f0101230:	85 c0                	test   %eax,%eax
f0101232:	75 24                	jne    f0101258 <mem_init+0x184>
f0101234:	c7 44 24 0c 24 49 10 	movl   $0xf0104924,0xc(%esp)
f010123b:	f0 
f010123c:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101243:	f0 
f0101244:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f010124b:	00 
f010124c:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101253:	e8 3c ee ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101258:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010125f:	e8 a6 fb ff ff       	call   f0100e0a <page_alloc>
f0101264:	89 c7                	mov    %eax,%edi
f0101266:	85 c0                	test   %eax,%eax
f0101268:	75 24                	jne    f010128e <mem_init+0x1ba>
f010126a:	c7 44 24 0c 3a 49 10 	movl   $0xf010493a,0xc(%esp)
f0101271:	f0 
f0101272:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101279:	f0 
f010127a:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f0101281:	00 
f0101282:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101289:	e8 06 ee ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010128e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101295:	e8 70 fb ff ff       	call   f0100e0a <page_alloc>
f010129a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010129d:	85 c0                	test   %eax,%eax
f010129f:	75 24                	jne    f01012c5 <mem_init+0x1f1>
f01012a1:	c7 44 24 0c 50 49 10 	movl   $0xf0104950,0xc(%esp)
f01012a8:	f0 
f01012a9:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01012b0:	f0 
f01012b1:	c7 44 24 04 75 02 00 	movl   $0x275,0x4(%esp)
f01012b8:	00 
f01012b9:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01012c0:	e8 cf ed ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01012c5:	39 fe                	cmp    %edi,%esi
f01012c7:	75 24                	jne    f01012ed <mem_init+0x219>
f01012c9:	c7 44 24 0c 66 49 10 	movl   $0xf0104966,0xc(%esp)
f01012d0:	f0 
f01012d1:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01012d8:	f0 
f01012d9:	c7 44 24 04 78 02 00 	movl   $0x278,0x4(%esp)
f01012e0:	00 
f01012e1:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01012e8:	e8 a7 ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01012ed:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01012f0:	74 05                	je     f01012f7 <mem_init+0x223>
f01012f2:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01012f5:	75 24                	jne    f010131b <mem_init+0x247>
f01012f7:	c7 44 24 0c 4c 42 10 	movl   $0xf010424c,0xc(%esp)
f01012fe:	f0 
f01012ff:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101306:	f0 
f0101307:	c7 44 24 04 79 02 00 	movl   $0x279,0x4(%esp)
f010130e:	00 
f010130f:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101316:	e8 79 ed ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010131b:	8b 15 70 f9 11 f0    	mov    0xf011f970,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101321:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101326:	c1 e0 0c             	shl    $0xc,%eax
f0101329:	89 f1                	mov    %esi,%ecx
f010132b:	29 d1                	sub    %edx,%ecx
f010132d:	c1 f9 03             	sar    $0x3,%ecx
f0101330:	c1 e1 0c             	shl    $0xc,%ecx
f0101333:	39 c1                	cmp    %eax,%ecx
f0101335:	72 24                	jb     f010135b <mem_init+0x287>
f0101337:	c7 44 24 0c 78 49 10 	movl   $0xf0104978,0xc(%esp)
f010133e:	f0 
f010133f:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101346:	f0 
f0101347:	c7 44 24 04 7a 02 00 	movl   $0x27a,0x4(%esp)
f010134e:	00 
f010134f:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101356:	e8 39 ed ff ff       	call   f0100094 <_panic>
f010135b:	89 f9                	mov    %edi,%ecx
f010135d:	29 d1                	sub    %edx,%ecx
f010135f:	c1 f9 03             	sar    $0x3,%ecx
f0101362:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f0101365:	39 c8                	cmp    %ecx,%eax
f0101367:	77 24                	ja     f010138d <mem_init+0x2b9>
f0101369:	c7 44 24 0c 95 49 10 	movl   $0xf0104995,0xc(%esp)
f0101370:	f0 
f0101371:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101378:	f0 
f0101379:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
f0101380:	00 
f0101381:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101388:	e8 07 ed ff ff       	call   f0100094 <_panic>
f010138d:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101390:	29 d1                	sub    %edx,%ecx
f0101392:	89 ca                	mov    %ecx,%edx
f0101394:	c1 fa 03             	sar    $0x3,%edx
f0101397:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010139a:	39 d0                	cmp    %edx,%eax
f010139c:	77 24                	ja     f01013c2 <mem_init+0x2ee>
f010139e:	c7 44 24 0c b2 49 10 	movl   $0xf01049b2,0xc(%esp)
f01013a5:	f0 
f01013a6:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01013ad:	f0 
f01013ae:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f01013b5:	00 
f01013b6:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01013bd:	e8 d2 ec ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01013c2:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f01013c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01013ca:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f01013d1:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01013d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01013db:	e8 2a fa ff ff       	call   f0100e0a <page_alloc>
f01013e0:	85 c0                	test   %eax,%eax
f01013e2:	74 24                	je     f0101408 <mem_init+0x334>
f01013e4:	c7 44 24 0c cf 49 10 	movl   $0xf01049cf,0xc(%esp)
f01013eb:	f0 
f01013ec:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01013f3:	f0 
f01013f4:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
f01013fb:	00 
f01013fc:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101403:	e8 8c ec ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101408:	89 34 24             	mov    %esi,(%esp)
f010140b:	e8 7e fa ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f0101410:	89 3c 24             	mov    %edi,(%esp)
f0101413:	e8 76 fa ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f0101418:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010141b:	89 04 24             	mov    %eax,(%esp)
f010141e:	e8 6b fa ff ff       	call   f0100e8e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101423:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010142a:	e8 db f9 ff ff       	call   f0100e0a <page_alloc>
f010142f:	89 c6                	mov    %eax,%esi
f0101431:	85 c0                	test   %eax,%eax
f0101433:	75 24                	jne    f0101459 <mem_init+0x385>
f0101435:	c7 44 24 0c 24 49 10 	movl   $0xf0104924,0xc(%esp)
f010143c:	f0 
f010143d:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101444:	f0 
f0101445:	c7 44 24 04 8a 02 00 	movl   $0x28a,0x4(%esp)
f010144c:	00 
f010144d:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101454:	e8 3b ec ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101459:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101460:	e8 a5 f9 ff ff       	call   f0100e0a <page_alloc>
f0101465:	89 c7                	mov    %eax,%edi
f0101467:	85 c0                	test   %eax,%eax
f0101469:	75 24                	jne    f010148f <mem_init+0x3bb>
f010146b:	c7 44 24 0c 3a 49 10 	movl   $0xf010493a,0xc(%esp)
f0101472:	f0 
f0101473:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010147a:	f0 
f010147b:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f0101482:	00 
f0101483:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010148a:	e8 05 ec ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010148f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101496:	e8 6f f9 ff ff       	call   f0100e0a <page_alloc>
f010149b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010149e:	85 c0                	test   %eax,%eax
f01014a0:	75 24                	jne    f01014c6 <mem_init+0x3f2>
f01014a2:	c7 44 24 0c 50 49 10 	movl   $0xf0104950,0xc(%esp)
f01014a9:	f0 
f01014aa:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01014b1:	f0 
f01014b2:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f01014b9:	00 
f01014ba:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01014c1:	e8 ce eb ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01014c6:	39 fe                	cmp    %edi,%esi
f01014c8:	75 24                	jne    f01014ee <mem_init+0x41a>
f01014ca:	c7 44 24 0c 66 49 10 	movl   $0xf0104966,0xc(%esp)
f01014d1:	f0 
f01014d2:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01014d9:	f0 
f01014da:	c7 44 24 04 8e 02 00 	movl   $0x28e,0x4(%esp)
f01014e1:	00 
f01014e2:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01014e9:	e8 a6 eb ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014ee:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f01014f1:	74 05                	je     f01014f8 <mem_init+0x424>
f01014f3:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f01014f6:	75 24                	jne    f010151c <mem_init+0x448>
f01014f8:	c7 44 24 0c 4c 42 10 	movl   $0xf010424c,0xc(%esp)
f01014ff:	f0 
f0101500:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101507:	f0 
f0101508:	c7 44 24 04 8f 02 00 	movl   $0x28f,0x4(%esp)
f010150f:	00 
f0101510:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101517:	e8 78 eb ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010151c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101523:	e8 e2 f8 ff ff       	call   f0100e0a <page_alloc>
f0101528:	85 c0                	test   %eax,%eax
f010152a:	74 24                	je     f0101550 <mem_init+0x47c>
f010152c:	c7 44 24 0c cf 49 10 	movl   $0xf01049cf,0xc(%esp)
f0101533:	f0 
f0101534:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010153b:	f0 
f010153c:	c7 44 24 04 90 02 00 	movl   $0x290,0x4(%esp)
f0101543:	00 
f0101544:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010154b:	e8 44 eb ff ff       	call   f0100094 <_panic>
f0101550:	89 f0                	mov    %esi,%eax
f0101552:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0101558:	c1 f8 03             	sar    $0x3,%eax
f010155b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010155e:	89 c2                	mov    %eax,%edx
f0101560:	c1 ea 0c             	shr    $0xc,%edx
f0101563:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0101569:	72 20                	jb     f010158b <mem_init+0x4b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010156b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010156f:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0101576:	f0 
f0101577:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010157e:	00 
f010157f:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f0101586:	e8 09 eb ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010158b:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101592:	00 
f0101593:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010159a:	00 
	return (void *)(pa + KERNBASE);
f010159b:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015a0:	89 04 24             	mov    %eax,(%esp)
f01015a3:	e8 56 21 00 00       	call   f01036fe <memset>
	page_free(pp0);
f01015a8:	89 34 24             	mov    %esi,(%esp)
f01015ab:	e8 de f8 ff ff       	call   f0100e8e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015b7:	e8 4e f8 ff ff       	call   f0100e0a <page_alloc>
f01015bc:	85 c0                	test   %eax,%eax
f01015be:	75 24                	jne    f01015e4 <mem_init+0x510>
f01015c0:	c7 44 24 0c de 49 10 	movl   $0xf01049de,0xc(%esp)
f01015c7:	f0 
f01015c8:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01015cf:	f0 
f01015d0:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f01015d7:	00 
f01015d8:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01015df:	e8 b0 ea ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f01015e4:	39 c6                	cmp    %eax,%esi
f01015e6:	74 24                	je     f010160c <mem_init+0x538>
f01015e8:	c7 44 24 0c fc 49 10 	movl   $0xf01049fc,0xc(%esp)
f01015ef:	f0 
f01015f0:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01015f7:	f0 
f01015f8:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f01015ff:	00 
f0101600:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101607:	e8 88 ea ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010160c:	89 f2                	mov    %esi,%edx
f010160e:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101614:	c1 fa 03             	sar    $0x3,%edx
f0101617:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010161a:	89 d0                	mov    %edx,%eax
f010161c:	c1 e8 0c             	shr    $0xc,%eax
f010161f:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f0101625:	72 20                	jb     f0101647 <mem_init+0x573>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101627:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010162b:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0101632:	f0 
f0101633:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010163a:	00 
f010163b:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f0101642:	e8 4d ea ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101647:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010164d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101653:	80 38 00             	cmpb   $0x0,(%eax)
f0101656:	74 24                	je     f010167c <mem_init+0x5a8>
f0101658:	c7 44 24 0c 0c 4a 10 	movl   $0xf0104a0c,0xc(%esp)
f010165f:	f0 
f0101660:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101667:	f0 
f0101668:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f010166f:	00 
f0101670:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101677:	e8 18 ea ff ff       	call   f0100094 <_panic>
f010167c:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010167d:	39 d0                	cmp    %edx,%eax
f010167f:	75 d2                	jne    f0101653 <mem_init+0x57f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101681:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101684:	89 15 40 f5 11 f0    	mov    %edx,0xf011f540

	// free the pages we took
	page_free(pp0);
f010168a:	89 34 24             	mov    %esi,(%esp)
f010168d:	e8 fc f7 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f0101692:	89 3c 24             	mov    %edi,(%esp)
f0101695:	e8 f4 f7 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f010169a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010169d:	89 04 24             	mov    %eax,(%esp)
f01016a0:	e8 e9 f7 ff ff       	call   f0100e8e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016a5:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f01016aa:	eb 03                	jmp    f01016af <mem_init+0x5db>
		--nfree;
f01016ac:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016ad:	8b 00                	mov    (%eax),%eax
f01016af:	85 c0                	test   %eax,%eax
f01016b1:	75 f9                	jne    f01016ac <mem_init+0x5d8>
		--nfree;
	assert(nfree == 0);
f01016b3:	85 db                	test   %ebx,%ebx
f01016b5:	74 24                	je     f01016db <mem_init+0x607>
f01016b7:	c7 44 24 0c 16 4a 10 	movl   $0xf0104a16,0xc(%esp)
f01016be:	f0 
f01016bf:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01016c6:	f0 
f01016c7:	c7 44 24 04 a6 02 00 	movl   $0x2a6,0x4(%esp)
f01016ce:	00 
f01016cf:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01016d6:	e8 b9 e9 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01016db:	c7 04 24 6c 42 10 f0 	movl   $0xf010426c,(%esp)
f01016e2:	e8 73 15 00 00       	call   f0102c5a <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01016e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01016ee:	e8 17 f7 ff ff       	call   f0100e0a <page_alloc>
f01016f3:	89 c7                	mov    %eax,%edi
f01016f5:	85 c0                	test   %eax,%eax
f01016f7:	75 24                	jne    f010171d <mem_init+0x649>
f01016f9:	c7 44 24 0c 24 49 10 	movl   $0xf0104924,0xc(%esp)
f0101700:	f0 
f0101701:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101708:	f0 
f0101709:	c7 44 24 04 fe 02 00 	movl   $0x2fe,0x4(%esp)
f0101710:	00 
f0101711:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101718:	e8 77 e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010171d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101724:	e8 e1 f6 ff ff       	call   f0100e0a <page_alloc>
f0101729:	89 c6                	mov    %eax,%esi
f010172b:	85 c0                	test   %eax,%eax
f010172d:	75 24                	jne    f0101753 <mem_init+0x67f>
f010172f:	c7 44 24 0c 3a 49 10 	movl   $0xf010493a,0xc(%esp)
f0101736:	f0 
f0101737:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010173e:	f0 
f010173f:	c7 44 24 04 ff 02 00 	movl   $0x2ff,0x4(%esp)
f0101746:	00 
f0101747:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010174e:	e8 41 e9 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101753:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010175a:	e8 ab f6 ff ff       	call   f0100e0a <page_alloc>
f010175f:	89 c3                	mov    %eax,%ebx
f0101761:	85 c0                	test   %eax,%eax
f0101763:	75 24                	jne    f0101789 <mem_init+0x6b5>
f0101765:	c7 44 24 0c 50 49 10 	movl   $0xf0104950,0xc(%esp)
f010176c:	f0 
f010176d:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101774:	f0 
f0101775:	c7 44 24 04 00 03 00 	movl   $0x300,0x4(%esp)
f010177c:	00 
f010177d:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101784:	e8 0b e9 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101789:	39 f7                	cmp    %esi,%edi
f010178b:	75 24                	jne    f01017b1 <mem_init+0x6dd>
f010178d:	c7 44 24 0c 66 49 10 	movl   $0xf0104966,0xc(%esp)
f0101794:	f0 
f0101795:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010179c:	f0 
f010179d:	c7 44 24 04 03 03 00 	movl   $0x303,0x4(%esp)
f01017a4:	00 
f01017a5:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01017ac:	e8 e3 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b1:	39 c6                	cmp    %eax,%esi
f01017b3:	74 04                	je     f01017b9 <mem_init+0x6e5>
f01017b5:	39 c7                	cmp    %eax,%edi
f01017b7:	75 24                	jne    f01017dd <mem_init+0x709>
f01017b9:	c7 44 24 0c 4c 42 10 	movl   $0xf010424c,0xc(%esp)
f01017c0:	f0 
f01017c1:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01017c8:	f0 
f01017c9:	c7 44 24 04 04 03 00 	movl   $0x304,0x4(%esp)
f01017d0:	00 
f01017d1:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01017d8:	e8 b7 e8 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017dd:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f01017e3:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f01017e6:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f01017ed:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017f7:	e8 0e f6 ff ff       	call   f0100e0a <page_alloc>
f01017fc:	85 c0                	test   %eax,%eax
f01017fe:	74 24                	je     f0101824 <mem_init+0x750>
f0101800:	c7 44 24 0c cf 49 10 	movl   $0xf01049cf,0xc(%esp)
f0101807:	f0 
f0101808:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010180f:	f0 
f0101810:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0101817:	00 
f0101818:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010181f:	e8 70 e8 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101824:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101827:	89 44 24 08          	mov    %eax,0x8(%esp)
f010182b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101832:	00 
f0101833:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101838:	89 04 24             	mov    %eax,(%esp)
f010183b:	e8 4d f7 ff ff       	call   f0100f8d <page_lookup>
f0101840:	85 c0                	test   %eax,%eax
f0101842:	74 24                	je     f0101868 <mem_init+0x794>
f0101844:	c7 44 24 0c 8c 42 10 	movl   $0xf010428c,0xc(%esp)
f010184b:	f0 
f010184c:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101853:	f0 
f0101854:	c7 44 24 04 0e 03 00 	movl   $0x30e,0x4(%esp)
f010185b:	00 
f010185c:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101863:	e8 2c e8 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101868:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f010186f:	00 
f0101870:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101877:	00 
f0101878:	89 74 24 04          	mov    %esi,0x4(%esp)
f010187c:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101881:	89 04 24             	mov    %eax,(%esp)
f0101884:	e8 d1 f7 ff ff       	call   f010105a <page_insert>
f0101889:	85 c0                	test   %eax,%eax
f010188b:	78 24                	js     f01018b1 <mem_init+0x7dd>
f010188d:	c7 44 24 0c c4 42 10 	movl   $0xf01042c4,0xc(%esp)
f0101894:	f0 
f0101895:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010189c:	f0 
f010189d:	c7 44 24 04 11 03 00 	movl   $0x311,0x4(%esp)
f01018a4:	00 
f01018a5:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01018ac:	e8 e3 e7 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f01018b1:	89 3c 24             	mov    %edi,(%esp)
f01018b4:	e8 d5 f5 ff ff       	call   f0100e8e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018b9:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018c0:	00 
f01018c1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018c8:	00 
f01018c9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018cd:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01018d2:	89 04 24             	mov    %eax,(%esp)
f01018d5:	e8 80 f7 ff ff       	call   f010105a <page_insert>
f01018da:	85 c0                	test   %eax,%eax
f01018dc:	74 24                	je     f0101902 <mem_init+0x82e>
f01018de:	c7 44 24 0c f4 42 10 	movl   $0xf01042f4,0xc(%esp)
f01018e5:	f0 
f01018e6:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01018ed:	f0 
f01018ee:	c7 44 24 04 15 03 00 	movl   $0x315,0x4(%esp)
f01018f5:	00 
f01018f6:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01018fd:	e8 92 e7 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101902:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f0101908:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010190b:	a1 70 f9 11 f0       	mov    0xf011f970,%eax
f0101910:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101913:	8b 11                	mov    (%ecx),%edx
f0101915:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010191b:	89 f8                	mov    %edi,%eax
f010191d:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101920:	c1 f8 03             	sar    $0x3,%eax
f0101923:	c1 e0 0c             	shl    $0xc,%eax
f0101926:	39 c2                	cmp    %eax,%edx
f0101928:	74 24                	je     f010194e <mem_init+0x87a>
f010192a:	c7 44 24 0c 24 43 10 	movl   $0xf0104324,0xc(%esp)
f0101931:	f0 
f0101932:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101939:	f0 
f010193a:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f0101941:	00 
f0101942:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101949:	e8 46 e7 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010194e:	ba 00 00 00 00       	mov    $0x0,%edx
f0101953:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101956:	e8 7d ef ff ff       	call   f01008d8 <check_va2pa>
f010195b:	89 f2                	mov    %esi,%edx
f010195d:	2b 55 d0             	sub    -0x30(%ebp),%edx
f0101960:	c1 fa 03             	sar    $0x3,%edx
f0101963:	c1 e2 0c             	shl    $0xc,%edx
f0101966:	39 d0                	cmp    %edx,%eax
f0101968:	74 24                	je     f010198e <mem_init+0x8ba>
f010196a:	c7 44 24 0c 4c 43 10 	movl   $0xf010434c,0xc(%esp)
f0101971:	f0 
f0101972:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101979:	f0 
f010197a:	c7 44 24 04 17 03 00 	movl   $0x317,0x4(%esp)
f0101981:	00 
f0101982:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101989:	e8 06 e7 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010198e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101993:	74 24                	je     f01019b9 <mem_init+0x8e5>
f0101995:	c7 44 24 0c 21 4a 10 	movl   $0xf0104a21,0xc(%esp)
f010199c:	f0 
f010199d:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01019a4:	f0 
f01019a5:	c7 44 24 04 18 03 00 	movl   $0x318,0x4(%esp)
f01019ac:	00 
f01019ad:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01019b4:	e8 db e6 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f01019b9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01019be:	74 24                	je     f01019e4 <mem_init+0x910>
f01019c0:	c7 44 24 0c 32 4a 10 	movl   $0xf0104a32,0xc(%esp)
f01019c7:	f0 
f01019c8:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01019cf:	f0 
f01019d0:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f01019d7:	00 
f01019d8:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01019df:	e8 b0 e6 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019e4:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01019eb:	00 
f01019ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019f3:	00 
f01019f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01019f8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01019fb:	89 14 24             	mov    %edx,(%esp)
f01019fe:	e8 57 f6 ff ff       	call   f010105a <page_insert>
f0101a03:	85 c0                	test   %eax,%eax
f0101a05:	74 24                	je     f0101a2b <mem_init+0x957>
f0101a07:	c7 44 24 0c 7c 43 10 	movl   $0xf010437c,0xc(%esp)
f0101a0e:	f0 
f0101a0f:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101a16:	f0 
f0101a17:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101a1e:	00 
f0101a1f:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101a26:	e8 69 e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a2b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a30:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101a35:	e8 9e ee ff ff       	call   f01008d8 <check_va2pa>
f0101a3a:	89 da                	mov    %ebx,%edx
f0101a3c:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101a42:	c1 fa 03             	sar    $0x3,%edx
f0101a45:	c1 e2 0c             	shl    $0xc,%edx
f0101a48:	39 d0                	cmp    %edx,%eax
f0101a4a:	74 24                	je     f0101a70 <mem_init+0x99c>
f0101a4c:	c7 44 24 0c b8 43 10 	movl   $0xf01043b8,0xc(%esp)
f0101a53:	f0 
f0101a54:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101a5b:	f0 
f0101a5c:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101a63:	00 
f0101a64:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101a6b:	e8 24 e6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101a70:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a75:	74 24                	je     f0101a9b <mem_init+0x9c7>
f0101a77:	c7 44 24 0c 43 4a 10 	movl   $0xf0104a43,0xc(%esp)
f0101a7e:	f0 
f0101a7f:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101a86:	f0 
f0101a87:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0101a8e:	00 
f0101a8f:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101a96:	e8 f9 e5 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a9b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aa2:	e8 63 f3 ff ff       	call   f0100e0a <page_alloc>
f0101aa7:	85 c0                	test   %eax,%eax
f0101aa9:	74 24                	je     f0101acf <mem_init+0x9fb>
f0101aab:	c7 44 24 0c cf 49 10 	movl   $0xf01049cf,0xc(%esp)
f0101ab2:	f0 
f0101ab3:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101aba:	f0 
f0101abb:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101ac2:	00 
f0101ac3:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101aca:	e8 c5 e5 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101acf:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ad6:	00 
f0101ad7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101ade:	00 
f0101adf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101ae3:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101ae8:	89 04 24             	mov    %eax,(%esp)
f0101aeb:	e8 6a f5 ff ff       	call   f010105a <page_insert>
f0101af0:	85 c0                	test   %eax,%eax
f0101af2:	74 24                	je     f0101b18 <mem_init+0xa44>
f0101af4:	c7 44 24 0c 7c 43 10 	movl   $0xf010437c,0xc(%esp)
f0101afb:	f0 
f0101afc:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101b03:	f0 
f0101b04:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101b0b:	00 
f0101b0c:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101b13:	e8 7c e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b18:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b1d:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101b22:	e8 b1 ed ff ff       	call   f01008d8 <check_va2pa>
f0101b27:	89 da                	mov    %ebx,%edx
f0101b29:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101b2f:	c1 fa 03             	sar    $0x3,%edx
f0101b32:	c1 e2 0c             	shl    $0xc,%edx
f0101b35:	39 d0                	cmp    %edx,%eax
f0101b37:	74 24                	je     f0101b5d <mem_init+0xa89>
f0101b39:	c7 44 24 0c b8 43 10 	movl   $0xf01043b8,0xc(%esp)
f0101b40:	f0 
f0101b41:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101b48:	f0 
f0101b49:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101b50:	00 
f0101b51:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101b58:	e8 37 e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101b5d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101b62:	74 24                	je     f0101b88 <mem_init+0xab4>
f0101b64:	c7 44 24 0c 43 4a 10 	movl   $0xf0104a43,0xc(%esp)
f0101b6b:	f0 
f0101b6c:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101b73:	f0 
f0101b74:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101b7b:	00 
f0101b7c:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101b83:	e8 0c e5 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101b88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b8f:	e8 76 f2 ff ff       	call   f0100e0a <page_alloc>
f0101b94:	85 c0                	test   %eax,%eax
f0101b96:	74 24                	je     f0101bbc <mem_init+0xae8>
f0101b98:	c7 44 24 0c cf 49 10 	movl   $0xf01049cf,0xc(%esp)
f0101b9f:	f0 
f0101ba0:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101ba7:	f0 
f0101ba8:	c7 44 24 04 2a 03 00 	movl   $0x32a,0x4(%esp)
f0101baf:	00 
f0101bb0:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101bb7:	e8 d8 e4 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101bbc:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
f0101bc2:	8b 02                	mov    (%edx),%eax
f0101bc4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101bc9:	89 c1                	mov    %eax,%ecx
f0101bcb:	c1 e9 0c             	shr    $0xc,%ecx
f0101bce:	3b 0d 68 f9 11 f0    	cmp    0xf011f968,%ecx
f0101bd4:	72 20                	jb     f0101bf6 <mem_init+0xb22>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101bd6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101bda:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0101be1:	f0 
f0101be2:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0101be9:	00 
f0101bea:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101bf1:	e8 9e e4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101bf6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101bfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101bfe:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c05:	00 
f0101c06:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c0d:	00 
f0101c0e:	89 14 24             	mov    %edx,(%esp)
f0101c11:	e8 d8 f2 ff ff       	call   f0100eee <pgdir_walk>
f0101c16:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c19:	83 c2 04             	add    $0x4,%edx
f0101c1c:	39 d0                	cmp    %edx,%eax
f0101c1e:	74 24                	je     f0101c44 <mem_init+0xb70>
f0101c20:	c7 44 24 0c e8 43 10 	movl   $0xf01043e8,0xc(%esp)
f0101c27:	f0 
f0101c28:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101c2f:	f0 
f0101c30:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101c37:	00 
f0101c38:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101c3f:	e8 50 e4 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101c44:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101c4b:	00 
f0101c4c:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101c53:	00 
f0101c54:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101c58:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101c5d:	89 04 24             	mov    %eax,(%esp)
f0101c60:	e8 f5 f3 ff ff       	call   f010105a <page_insert>
f0101c65:	85 c0                	test   %eax,%eax
f0101c67:	74 24                	je     f0101c8d <mem_init+0xbb9>
f0101c69:	c7 44 24 0c 28 44 10 	movl   $0xf0104428,0xc(%esp)
f0101c70:	f0 
f0101c71:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101c78:	f0 
f0101c79:	c7 44 24 04 31 03 00 	movl   $0x331,0x4(%esp)
f0101c80:	00 
f0101c81:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101c88:	e8 07 e4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101c8d:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f0101c93:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101c96:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c9b:	89 c8                	mov    %ecx,%eax
f0101c9d:	e8 36 ec ff ff       	call   f01008d8 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ca2:	89 da                	mov    %ebx,%edx
f0101ca4:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101caa:	c1 fa 03             	sar    $0x3,%edx
f0101cad:	c1 e2 0c             	shl    $0xc,%edx
f0101cb0:	39 d0                	cmp    %edx,%eax
f0101cb2:	74 24                	je     f0101cd8 <mem_init+0xc04>
f0101cb4:	c7 44 24 0c b8 43 10 	movl   $0xf01043b8,0xc(%esp)
f0101cbb:	f0 
f0101cbc:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101cc3:	f0 
f0101cc4:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101ccb:	00 
f0101ccc:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101cd3:	e8 bc e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101cd8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101cdd:	74 24                	je     f0101d03 <mem_init+0xc2f>
f0101cdf:	c7 44 24 0c 43 4a 10 	movl   $0xf0104a43,0xc(%esp)
f0101ce6:	f0 
f0101ce7:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101cee:	f0 
f0101cef:	c7 44 24 04 33 03 00 	movl   $0x333,0x4(%esp)
f0101cf6:	00 
f0101cf7:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101cfe:	e8 91 e3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d03:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d0a:	00 
f0101d0b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d12:	00 
f0101d13:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d16:	89 04 24             	mov    %eax,(%esp)
f0101d19:	e8 d0 f1 ff ff       	call   f0100eee <pgdir_walk>
f0101d1e:	f6 00 04             	testb  $0x4,(%eax)
f0101d21:	75 24                	jne    f0101d47 <mem_init+0xc73>
f0101d23:	c7 44 24 0c 68 44 10 	movl   $0xf0104468,0xc(%esp)
f0101d2a:	f0 
f0101d2b:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101d32:	f0 
f0101d33:	c7 44 24 04 34 03 00 	movl   $0x334,0x4(%esp)
f0101d3a:	00 
f0101d3b:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101d42:	e8 4d e3 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101d47:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101d4c:	f6 00 04             	testb  $0x4,(%eax)
f0101d4f:	75 24                	jne    f0101d75 <mem_init+0xca1>
f0101d51:	c7 44 24 0c 54 4a 10 	movl   $0xf0104a54,0xc(%esp)
f0101d58:	f0 
f0101d59:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101d60:	f0 
f0101d61:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101d68:	00 
f0101d69:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101d70:	e8 1f e3 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101d75:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101d7c:	00 
f0101d7d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101d84:	00 
f0101d85:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101d89:	89 04 24             	mov    %eax,(%esp)
f0101d8c:	e8 c9 f2 ff ff       	call   f010105a <page_insert>
f0101d91:	85 c0                	test   %eax,%eax
f0101d93:	74 24                	je     f0101db9 <mem_init+0xce5>
f0101d95:	c7 44 24 0c 7c 43 10 	movl   $0xf010437c,0xc(%esp)
f0101d9c:	f0 
f0101d9d:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101da4:	f0 
f0101da5:	c7 44 24 04 38 03 00 	movl   $0x338,0x4(%esp)
f0101dac:	00 
f0101dad:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101db4:	e8 db e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101db9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101dc0:	00 
f0101dc1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101dc8:	00 
f0101dc9:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101dce:	89 04 24             	mov    %eax,(%esp)
f0101dd1:	e8 18 f1 ff ff       	call   f0100eee <pgdir_walk>
f0101dd6:	f6 00 02             	testb  $0x2,(%eax)
f0101dd9:	75 24                	jne    f0101dff <mem_init+0xd2b>
f0101ddb:	c7 44 24 0c 9c 44 10 	movl   $0xf010449c,0xc(%esp)
f0101de2:	f0 
f0101de3:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101dea:	f0 
f0101deb:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101df2:	00 
f0101df3:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101dfa:	e8 95 e2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101dff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e06:	00 
f0101e07:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e0e:	00 
f0101e0f:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101e14:	89 04 24             	mov    %eax,(%esp)
f0101e17:	e8 d2 f0 ff ff       	call   f0100eee <pgdir_walk>
f0101e1c:	f6 00 04             	testb  $0x4,(%eax)
f0101e1f:	74 24                	je     f0101e45 <mem_init+0xd71>
f0101e21:	c7 44 24 0c d0 44 10 	movl   $0xf01044d0,0xc(%esp)
f0101e28:	f0 
f0101e29:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101e30:	f0 
f0101e31:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101e38:	00 
f0101e39:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101e40:	e8 4f e2 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101e45:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e4c:	00 
f0101e4d:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101e54:	00 
f0101e55:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101e59:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101e5e:	89 04 24             	mov    %eax,(%esp)
f0101e61:	e8 f4 f1 ff ff       	call   f010105a <page_insert>
f0101e66:	85 c0                	test   %eax,%eax
f0101e68:	78 24                	js     f0101e8e <mem_init+0xdba>
f0101e6a:	c7 44 24 0c 08 45 10 	movl   $0xf0104508,0xc(%esp)
f0101e71:	f0 
f0101e72:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101e79:	f0 
f0101e7a:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101e81:	00 
f0101e82:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101e89:	e8 06 e2 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101e8e:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101e95:	00 
f0101e96:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e9d:	00 
f0101e9e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101ea2:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101ea7:	89 04 24             	mov    %eax,(%esp)
f0101eaa:	e8 ab f1 ff ff       	call   f010105a <page_insert>
f0101eaf:	85 c0                	test   %eax,%eax
f0101eb1:	74 24                	je     f0101ed7 <mem_init+0xe03>
f0101eb3:	c7 44 24 0c 40 45 10 	movl   $0xf0104540,0xc(%esp)
f0101eba:	f0 
f0101ebb:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101ec2:	f0 
f0101ec3:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101eca:	00 
f0101ecb:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101ed2:	e8 bd e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ed7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101ede:	00 
f0101edf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101ee6:	00 
f0101ee7:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101eec:	89 04 24             	mov    %eax,(%esp)
f0101eef:	e8 fa ef ff ff       	call   f0100eee <pgdir_walk>
f0101ef4:	f6 00 04             	testb  $0x4,(%eax)
f0101ef7:	74 24                	je     f0101f1d <mem_init+0xe49>
f0101ef9:	c7 44 24 0c d0 44 10 	movl   $0xf01044d0,0xc(%esp)
f0101f00:	f0 
f0101f01:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101f08:	f0 
f0101f09:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101f10:	00 
f0101f11:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101f18:	e8 77 e1 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f1d:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101f22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f25:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f2a:	e8 a9 e9 ff ff       	call   f01008d8 <check_va2pa>
f0101f2f:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101f32:	89 f0                	mov    %esi,%eax
f0101f34:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0101f3a:	c1 f8 03             	sar    $0x3,%eax
f0101f3d:	c1 e0 0c             	shl    $0xc,%eax
f0101f40:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101f43:	74 24                	je     f0101f69 <mem_init+0xe95>
f0101f45:	c7 44 24 0c 7c 45 10 	movl   $0xf010457c,0xc(%esp)
f0101f4c:	f0 
f0101f4d:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101f54:	f0 
f0101f55:	c7 44 24 04 44 03 00 	movl   $0x344,0x4(%esp)
f0101f5c:	00 
f0101f5d:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101f64:	e8 2b e1 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101f69:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f6e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f71:	e8 62 e9 ff ff       	call   f01008d8 <check_va2pa>
f0101f76:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101f79:	74 24                	je     f0101f9f <mem_init+0xecb>
f0101f7b:	c7 44 24 0c a8 45 10 	movl   $0xf01045a8,0xc(%esp)
f0101f82:	f0 
f0101f83:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101f8a:	f0 
f0101f8b:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101f92:	00 
f0101f93:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101f9a:	e8 f5 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101f9f:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0101fa4:	74 24                	je     f0101fca <mem_init+0xef6>
f0101fa6:	c7 44 24 0c 6a 4a 10 	movl   $0xf0104a6a,0xc(%esp)
f0101fad:	f0 
f0101fae:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101fb5:	f0 
f0101fb6:	c7 44 24 04 47 03 00 	movl   $0x347,0x4(%esp)
f0101fbd:	00 
f0101fbe:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101fc5:	e8 ca e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0101fca:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fcf:	74 24                	je     f0101ff5 <mem_init+0xf21>
f0101fd1:	c7 44 24 0c 7b 4a 10 	movl   $0xf0104a7b,0xc(%esp)
f0101fd8:	f0 
f0101fd9:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0101fe0:	f0 
f0101fe1:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101fe8:	00 
f0101fe9:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0101ff0:	e8 9f e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101ff5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ffc:	e8 09 ee ff ff       	call   f0100e0a <page_alloc>
f0102001:	85 c0                	test   %eax,%eax
f0102003:	74 04                	je     f0102009 <mem_init+0xf35>
f0102005:	39 c3                	cmp    %eax,%ebx
f0102007:	74 24                	je     f010202d <mem_init+0xf59>
f0102009:	c7 44 24 0c d8 45 10 	movl   $0xf01045d8,0xc(%esp)
f0102010:	f0 
f0102011:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102018:	f0 
f0102019:	c7 44 24 04 4b 03 00 	movl   $0x34b,0x4(%esp)
f0102020:	00 
f0102021:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102028:	e8 67 e0 ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f010202d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102034:	00 
f0102035:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f010203a:	89 04 24             	mov    %eax,(%esp)
f010203d:	e8 cf ef ff ff       	call   f0101011 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102042:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
f0102048:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010204b:	ba 00 00 00 00       	mov    $0x0,%edx
f0102050:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102053:	e8 80 e8 ff ff       	call   f01008d8 <check_va2pa>
f0102058:	83 f8 ff             	cmp    $0xffffffff,%eax
f010205b:	74 24                	je     f0102081 <mem_init+0xfad>
f010205d:	c7 44 24 0c fc 45 10 	movl   $0xf01045fc,0xc(%esp)
f0102064:	f0 
f0102065:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010206c:	f0 
f010206d:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0102074:	00 
f0102075:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010207c:	e8 13 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102081:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102086:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102089:	e8 4a e8 ff ff       	call   f01008d8 <check_va2pa>
f010208e:	89 f2                	mov    %esi,%edx
f0102090:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102096:	c1 fa 03             	sar    $0x3,%edx
f0102099:	c1 e2 0c             	shl    $0xc,%edx
f010209c:	39 d0                	cmp    %edx,%eax
f010209e:	74 24                	je     f01020c4 <mem_init+0xff0>
f01020a0:	c7 44 24 0c a8 45 10 	movl   $0xf01045a8,0xc(%esp)
f01020a7:	f0 
f01020a8:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01020af:	f0 
f01020b0:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f01020b7:	00 
f01020b8:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01020bf:	e8 d0 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01020c4:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01020c9:	74 24                	je     f01020ef <mem_init+0x101b>
f01020cb:	c7 44 24 0c 21 4a 10 	movl   $0xf0104a21,0xc(%esp)
f01020d2:	f0 
f01020d3:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01020da:	f0 
f01020db:	c7 44 24 04 51 03 00 	movl   $0x351,0x4(%esp)
f01020e2:	00 
f01020e3:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01020ea:	e8 a5 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01020ef:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01020f4:	74 24                	je     f010211a <mem_init+0x1046>
f01020f6:	c7 44 24 0c 7b 4a 10 	movl   $0xf0104a7b,0xc(%esp)
f01020fd:	f0 
f01020fe:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102105:	f0 
f0102106:	c7 44 24 04 52 03 00 	movl   $0x352,0x4(%esp)
f010210d:	00 
f010210e:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102115:	e8 7a df ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010211a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102121:	00 
f0102122:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102129:	00 
f010212a:	89 74 24 04          	mov    %esi,0x4(%esp)
f010212e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102131:	89 0c 24             	mov    %ecx,(%esp)
f0102134:	e8 21 ef ff ff       	call   f010105a <page_insert>
f0102139:	85 c0                	test   %eax,%eax
f010213b:	74 24                	je     f0102161 <mem_init+0x108d>
f010213d:	c7 44 24 0c 20 46 10 	movl   $0xf0104620,0xc(%esp)
f0102144:	f0 
f0102145:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010214c:	f0 
f010214d:	c7 44 24 04 55 03 00 	movl   $0x355,0x4(%esp)
f0102154:	00 
f0102155:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010215c:	e8 33 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f0102161:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102166:	75 24                	jne    f010218c <mem_init+0x10b8>
f0102168:	c7 44 24 0c 8c 4a 10 	movl   $0xf0104a8c,0xc(%esp)
f010216f:	f0 
f0102170:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102177:	f0 
f0102178:	c7 44 24 04 56 03 00 	movl   $0x356,0x4(%esp)
f010217f:	00 
f0102180:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102187:	e8 08 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010218c:	83 3e 00             	cmpl   $0x0,(%esi)
f010218f:	74 24                	je     f01021b5 <mem_init+0x10e1>
f0102191:	c7 44 24 0c 98 4a 10 	movl   $0xf0104a98,0xc(%esp)
f0102198:	f0 
f0102199:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01021a0:	f0 
f01021a1:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f01021a8:	00 
f01021a9:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01021b0:	e8 df de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01021b5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01021bc:	00 
f01021bd:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01021c2:	89 04 24             	mov    %eax,(%esp)
f01021c5:	e8 47 ee ff ff       	call   f0101011 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01021ca:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01021cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01021d2:	ba 00 00 00 00       	mov    $0x0,%edx
f01021d7:	e8 fc e6 ff ff       	call   f01008d8 <check_va2pa>
f01021dc:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021df:	74 24                	je     f0102205 <mem_init+0x1131>
f01021e1:	c7 44 24 0c fc 45 10 	movl   $0xf01045fc,0xc(%esp)
f01021e8:	f0 
f01021e9:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01021f0:	f0 
f01021f1:	c7 44 24 04 5b 03 00 	movl   $0x35b,0x4(%esp)
f01021f8:	00 
f01021f9:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102200:	e8 8f de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102205:	ba 00 10 00 00       	mov    $0x1000,%edx
f010220a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010220d:	e8 c6 e6 ff ff       	call   f01008d8 <check_va2pa>
f0102212:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102215:	74 24                	je     f010223b <mem_init+0x1167>
f0102217:	c7 44 24 0c 58 46 10 	movl   $0xf0104658,0xc(%esp)
f010221e:	f0 
f010221f:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102226:	f0 
f0102227:	c7 44 24 04 5c 03 00 	movl   $0x35c,0x4(%esp)
f010222e:	00 
f010222f:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102236:	e8 59 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f010223b:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102240:	74 24                	je     f0102266 <mem_init+0x1192>
f0102242:	c7 44 24 0c ad 4a 10 	movl   $0xf0104aad,0xc(%esp)
f0102249:	f0 
f010224a:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102251:	f0 
f0102252:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f0102259:	00 
f010225a:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102261:	e8 2e de ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102266:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010226b:	74 24                	je     f0102291 <mem_init+0x11bd>
f010226d:	c7 44 24 0c 7b 4a 10 	movl   $0xf0104a7b,0xc(%esp)
f0102274:	f0 
f0102275:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010227c:	f0 
f010227d:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102284:	00 
f0102285:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010228c:	e8 03 de ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102291:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102298:	e8 6d eb ff ff       	call   f0100e0a <page_alloc>
f010229d:	85 c0                	test   %eax,%eax
f010229f:	74 04                	je     f01022a5 <mem_init+0x11d1>
f01022a1:	39 c6                	cmp    %eax,%esi
f01022a3:	74 24                	je     f01022c9 <mem_init+0x11f5>
f01022a5:	c7 44 24 0c 80 46 10 	movl   $0xf0104680,0xc(%esp)
f01022ac:	f0 
f01022ad:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01022b4:	f0 
f01022b5:	c7 44 24 04 61 03 00 	movl   $0x361,0x4(%esp)
f01022bc:	00 
f01022bd:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01022c4:	e8 cb dd ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01022c9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01022d0:	e8 35 eb ff ff       	call   f0100e0a <page_alloc>
f01022d5:	85 c0                	test   %eax,%eax
f01022d7:	74 24                	je     f01022fd <mem_init+0x1229>
f01022d9:	c7 44 24 0c cf 49 10 	movl   $0xf01049cf,0xc(%esp)
f01022e0:	f0 
f01022e1:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01022e8:	f0 
f01022e9:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f01022f0:	00 
f01022f1:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01022f8:	e8 97 dd ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01022fd:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102302:	8b 08                	mov    (%eax),%ecx
f0102304:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010230a:	89 fa                	mov    %edi,%edx
f010230c:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102312:	c1 fa 03             	sar    $0x3,%edx
f0102315:	c1 e2 0c             	shl    $0xc,%edx
f0102318:	39 d1                	cmp    %edx,%ecx
f010231a:	74 24                	je     f0102340 <mem_init+0x126c>
f010231c:	c7 44 24 0c 24 43 10 	movl   $0xf0104324,0xc(%esp)
f0102323:	f0 
f0102324:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010232b:	f0 
f010232c:	c7 44 24 04 67 03 00 	movl   $0x367,0x4(%esp)
f0102333:	00 
f0102334:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010233b:	e8 54 dd ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102340:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102346:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010234b:	74 24                	je     f0102371 <mem_init+0x129d>
f010234d:	c7 44 24 0c 32 4a 10 	movl   $0xf0104a32,0xc(%esp)
f0102354:	f0 
f0102355:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010235c:	f0 
f010235d:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102364:	00 
f0102365:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010236c:	e8 23 dd ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102371:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102377:	89 3c 24             	mov    %edi,(%esp)
f010237a:	e8 0f eb ff ff       	call   f0100e8e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f010237f:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102386:	00 
f0102387:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f010238e:	00 
f010238f:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102394:	89 04 24             	mov    %eax,(%esp)
f0102397:	e8 52 eb ff ff       	call   f0100eee <pgdir_walk>
f010239c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010239f:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f01023a5:	8b 51 04             	mov    0x4(%ecx),%edx
f01023a8:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01023ae:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023b1:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f01023b7:	89 55 c8             	mov    %edx,-0x38(%ebp)
f01023ba:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023bd:	c1 ea 0c             	shr    $0xc,%edx
f01023c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01023c3:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01023c6:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f01023c9:	72 23                	jb     f01023ee <mem_init+0x131a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023cb:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01023ce:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01023d2:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f01023d9:	f0 
f01023da:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f01023e1:	00 
f01023e2:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01023e9:	e8 a6 dc ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01023ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01023f1:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f01023f7:	39 d0                	cmp    %edx,%eax
f01023f9:	74 24                	je     f010241f <mem_init+0x134b>
f01023fb:	c7 44 24 0c be 4a 10 	movl   $0xf0104abe,0xc(%esp)
f0102402:	f0 
f0102403:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010240a:	f0 
f010240b:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f0102412:	00 
f0102413:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010241a:	e8 75 dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010241f:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0102426:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010242c:	89 f8                	mov    %edi,%eax
f010242e:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0102434:	c1 f8 03             	sar    $0x3,%eax
f0102437:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010243a:	89 c1                	mov    %eax,%ecx
f010243c:	c1 e9 0c             	shr    $0xc,%ecx
f010243f:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f0102442:	77 20                	ja     f0102464 <mem_init+0x1390>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102444:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102448:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f010244f:	f0 
f0102450:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102457:	00 
f0102458:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f010245f:	e8 30 dc ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102464:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010246b:	00 
f010246c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102473:	00 
	return (void *)(pa + KERNBASE);
f0102474:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102479:	89 04 24             	mov    %eax,(%esp)
f010247c:	e8 7d 12 00 00       	call   f01036fe <memset>
	page_free(pp0);
f0102481:	89 3c 24             	mov    %edi,(%esp)
f0102484:	e8 05 ea ff ff       	call   f0100e8e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102489:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102490:	00 
f0102491:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102498:	00 
f0102499:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f010249e:	89 04 24             	mov    %eax,(%esp)
f01024a1:	e8 48 ea ff ff       	call   f0100eee <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024a6:	89 fa                	mov    %edi,%edx
f01024a8:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f01024ae:	c1 fa 03             	sar    $0x3,%edx
f01024b1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024b4:	89 d0                	mov    %edx,%eax
f01024b6:	c1 e8 0c             	shr    $0xc,%eax
f01024b9:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f01024bf:	72 20                	jb     f01024e1 <mem_init+0x140d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01024c5:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f01024cc:	f0 
f01024cd:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01024d4:	00 
f01024d5:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f01024dc:	e8 b3 db ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01024e1:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01024e7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01024ea:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01024f0:	f6 00 01             	testb  $0x1,(%eax)
f01024f3:	74 24                	je     f0102519 <mem_init+0x1445>
f01024f5:	c7 44 24 0c d6 4a 10 	movl   $0xf0104ad6,0xc(%esp)
f01024fc:	f0 
f01024fd:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102504:	f0 
f0102505:	c7 44 24 04 7b 03 00 	movl   $0x37b,0x4(%esp)
f010250c:	00 
f010250d:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102514:	e8 7b db ff ff       	call   f0100094 <_panic>
f0102519:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010251c:	39 d0                	cmp    %edx,%eax
f010251e:	75 d0                	jne    f01024f0 <mem_init+0x141c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102520:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102525:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010252b:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102531:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102534:	89 0d 40 f5 11 f0    	mov    %ecx,0xf011f540

	// free the pages we took
	page_free(pp0);
f010253a:	89 3c 24             	mov    %edi,(%esp)
f010253d:	e8 4c e9 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f0102542:	89 34 24             	mov    %esi,(%esp)
f0102545:	e8 44 e9 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f010254a:	89 1c 24             	mov    %ebx,(%esp)
f010254d:	e8 3c e9 ff ff       	call   f0100e8e <page_free>

	cprintf("check_page() succeeded!\n");
f0102552:	c7 04 24 ed 4a 10 f0 	movl   $0xf0104aed,(%esp)
f0102559:	e8 fc 06 00 00       	call   f0102c5a <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010255e:	8b 1d 6c f9 11 f0    	mov    0xf011f96c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102564:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0102569:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010256c:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
f0102573:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f0102579:	be 00 00 00 00       	mov    $0x0,%esi
f010257e:	eb 70                	jmp    f01025f0 <mem_init+0x151c>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102580:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102586:	89 d8                	mov    %ebx,%eax
f0102588:	e8 4b e3 ff ff       	call   f01008d8 <check_va2pa>
f010258d:	8b 15 70 f9 11 f0    	mov    0xf011f970,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102593:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102599:	77 20                	ja     f01025bb <mem_init+0x14e7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010259b:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010259f:	c7 44 24 08 a8 40 10 	movl   $0xf01040a8,0x8(%esp)
f01025a6:	f0 
f01025a7:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f01025ae:	00 
f01025af:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01025b6:	e8 d9 da ff ff       	call   f0100094 <_panic>
f01025bb:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01025c2:	39 d0                	cmp    %edx,%eax
f01025c4:	74 24                	je     f01025ea <mem_init+0x1516>
f01025c6:	c7 44 24 0c a4 46 10 	movl   $0xf01046a4,0xc(%esp)
f01025cd:	f0 
f01025ce:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01025d5:	f0 
f01025d6:	c7 44 24 04 be 02 00 	movl   $0x2be,0x4(%esp)
f01025dd:	00 
f01025de:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01025e5:	e8 aa da ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025ea:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01025f0:	39 f7                	cmp    %esi,%edi
f01025f2:	77 8c                	ja     f0102580 <mem_init+0x14ac>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01025f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01025f7:	c1 e7 0c             	shl    $0xc,%edi
f01025fa:	be 00 00 00 00       	mov    $0x0,%esi
f01025ff:	eb 3b                	jmp    f010263c <mem_init+0x1568>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102601:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102607:	89 d8                	mov    %ebx,%eax
f0102609:	e8 ca e2 ff ff       	call   f01008d8 <check_va2pa>
f010260e:	39 c6                	cmp    %eax,%esi
f0102610:	74 24                	je     f0102636 <mem_init+0x1562>
f0102612:	c7 44 24 0c d8 46 10 	movl   $0xf01046d8,0xc(%esp)
f0102619:	f0 
f010261a:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102621:	f0 
f0102622:	c7 44 24 04 c3 02 00 	movl   $0x2c3,0x4(%esp)
f0102629:	00 
f010262a:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102631:	e8 5e da ff ff       	call   f0100094 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102636:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010263c:	39 fe                	cmp    %edi,%esi
f010263e:	72 c1                	jb     f0102601 <mem_init+0x152d>
f0102640:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102645:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010264a:	89 f2                	mov    %esi,%edx
f010264c:	89 d8                	mov    %ebx,%eax
f010264e:	e8 85 e2 ff ff       	call   f01008d8 <check_va2pa>
f0102653:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f0102659:	77 24                	ja     f010267f <mem_init+0x15ab>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010265b:	c7 44 24 0c 00 50 11 	movl   $0xf0115000,0xc(%esp)
f0102662:	f0 
f0102663:	c7 44 24 08 a8 40 10 	movl   $0xf01040a8,0x8(%esp)
f010266a:	f0 
f010266b:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f0102672:	00 
f0102673:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010267a:	e8 15 da ff ff       	call   f0100094 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010267f:	8d 96 00 d0 11 10    	lea    0x1011d000(%esi),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102685:	39 d0                	cmp    %edx,%eax
f0102687:	74 24                	je     f01026ad <mem_init+0x15d9>
f0102689:	c7 44 24 0c 00 47 10 	movl   $0xf0104700,0xc(%esp)
f0102690:	f0 
f0102691:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102698:	f0 
f0102699:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f01026a0:	00 
f01026a1:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01026a8:	e8 e7 d9 ff ff       	call   f0100094 <_panic>
f01026ad:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01026b3:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01026b9:	75 8f                	jne    f010264a <mem_init+0x1576>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01026bb:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01026c0:	89 d8                	mov    %ebx,%eax
f01026c2:	e8 11 e2 ff ff       	call   f01008d8 <check_va2pa>
f01026c7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01026ca:	74 24                	je     f01026f0 <mem_init+0x161c>
f01026cc:	c7 44 24 0c 48 47 10 	movl   $0xf0104748,0xc(%esp)
f01026d3:	f0 
f01026d4:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01026db:	f0 
f01026dc:	c7 44 24 04 c8 02 00 	movl   $0x2c8,0x4(%esp)
f01026e3:	00 
f01026e4:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01026eb:	e8 a4 d9 ff ff       	call   f0100094 <_panic>
f01026f0:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01026f5:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01026fa:	72 3c                	jb     f0102738 <mem_init+0x1664>
f01026fc:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102701:	76 07                	jbe    f010270a <mem_init+0x1636>
f0102703:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102708:	75 2e                	jne    f0102738 <mem_init+0x1664>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010270a:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f010270e:	0f 85 aa 00 00 00    	jne    f01027be <mem_init+0x16ea>
f0102714:	c7 44 24 0c 06 4b 10 	movl   $0xf0104b06,0xc(%esp)
f010271b:	f0 
f010271c:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102723:	f0 
f0102724:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f010272b:	00 
f010272c:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102733:	e8 5c d9 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102738:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010273d:	76 55                	jbe    f0102794 <mem_init+0x16c0>
				assert(pgdir[i] & PTE_P);
f010273f:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102742:	f6 c2 01             	test   $0x1,%dl
f0102745:	75 24                	jne    f010276b <mem_init+0x1697>
f0102747:	c7 44 24 0c 06 4b 10 	movl   $0xf0104b06,0xc(%esp)
f010274e:	f0 
f010274f:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102756:	f0 
f0102757:	c7 44 24 04 d4 02 00 	movl   $0x2d4,0x4(%esp)
f010275e:	00 
f010275f:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102766:	e8 29 d9 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f010276b:	f6 c2 02             	test   $0x2,%dl
f010276e:	75 4e                	jne    f01027be <mem_init+0x16ea>
f0102770:	c7 44 24 0c 17 4b 10 	movl   $0xf0104b17,0xc(%esp)
f0102777:	f0 
f0102778:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f010277f:	f0 
f0102780:	c7 44 24 04 d5 02 00 	movl   $0x2d5,0x4(%esp)
f0102787:	00 
f0102788:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f010278f:	e8 00 d9 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102794:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f0102798:	74 24                	je     f01027be <mem_init+0x16ea>
f010279a:	c7 44 24 0c 28 4b 10 	movl   $0xf0104b28,0xc(%esp)
f01027a1:	f0 
f01027a2:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01027a9:	f0 
f01027aa:	c7 44 24 04 d7 02 00 	movl   $0x2d7,0x4(%esp)
f01027b1:	00 
f01027b2:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01027b9:	e8 d6 d8 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01027be:	40                   	inc    %eax
f01027bf:	3d 00 04 00 00       	cmp    $0x400,%eax
f01027c4:	0f 85 2b ff ff ff    	jne    f01026f5 <mem_init+0x1621>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01027ca:	c7 04 24 78 47 10 f0 	movl   $0xf0104778,(%esp)
f01027d1:	e8 84 04 00 00       	call   f0102c5a <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01027d6:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01027db:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01027e0:	77 20                	ja     f0102802 <mem_init+0x172e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01027e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01027e6:	c7 44 24 08 a8 40 10 	movl   $0xf01040a8,0x8(%esp)
f01027ed:	f0 
f01027ee:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f01027f5:	00 
f01027f6:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01027fd:	e8 92 d8 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102802:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102807:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010280a:	b8 00 00 00 00       	mov    $0x0,%eax
f010280f:	e8 23 e2 ff ff       	call   f0100a37 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102814:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f0102817:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010281c:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010281f:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102822:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102829:	e8 dc e5 ff ff       	call   f0100e0a <page_alloc>
f010282e:	89 c6                	mov    %eax,%esi
f0102830:	85 c0                	test   %eax,%eax
f0102832:	75 24                	jne    f0102858 <mem_init+0x1784>
f0102834:	c7 44 24 0c 24 49 10 	movl   $0xf0104924,0xc(%esp)
f010283b:	f0 
f010283c:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102843:	f0 
f0102844:	c7 44 24 04 96 03 00 	movl   $0x396,0x4(%esp)
f010284b:	00 
f010284c:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102853:	e8 3c d8 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0102858:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010285f:	e8 a6 e5 ff ff       	call   f0100e0a <page_alloc>
f0102864:	89 c7                	mov    %eax,%edi
f0102866:	85 c0                	test   %eax,%eax
f0102868:	75 24                	jne    f010288e <mem_init+0x17ba>
f010286a:	c7 44 24 0c 3a 49 10 	movl   $0xf010493a,0xc(%esp)
f0102871:	f0 
f0102872:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102879:	f0 
f010287a:	c7 44 24 04 97 03 00 	movl   $0x397,0x4(%esp)
f0102881:	00 
f0102882:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102889:	e8 06 d8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f010288e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102895:	e8 70 e5 ff ff       	call   f0100e0a <page_alloc>
f010289a:	89 c3                	mov    %eax,%ebx
f010289c:	85 c0                	test   %eax,%eax
f010289e:	75 24                	jne    f01028c4 <mem_init+0x17f0>
f01028a0:	c7 44 24 0c 50 49 10 	movl   $0xf0104950,0xc(%esp)
f01028a7:	f0 
f01028a8:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01028af:	f0 
f01028b0:	c7 44 24 04 98 03 00 	movl   $0x398,0x4(%esp)
f01028b7:	00 
f01028b8:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01028bf:	e8 d0 d7 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f01028c4:	89 34 24             	mov    %esi,(%esp)
f01028c7:	e8 c2 e5 ff ff       	call   f0100e8e <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01028cc:	89 f8                	mov    %edi,%eax
f01028ce:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f01028d4:	c1 f8 03             	sar    $0x3,%eax
f01028d7:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028da:	89 c2                	mov    %eax,%edx
f01028dc:	c1 ea 0c             	shr    $0xc,%edx
f01028df:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f01028e5:	72 20                	jb     f0102907 <mem_init+0x1833>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028eb:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f01028f2:	f0 
f01028f3:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01028fa:	00 
f01028fb:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f0102902:	e8 8d d7 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102907:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010290e:	00 
f010290f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102916:	00 
	return (void *)(pa + KERNBASE);
f0102917:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010291c:	89 04 24             	mov    %eax,(%esp)
f010291f:	e8 da 0d 00 00       	call   f01036fe <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102924:	89 d8                	mov    %ebx,%eax
f0102926:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f010292c:	c1 f8 03             	sar    $0x3,%eax
f010292f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102932:	89 c2                	mov    %eax,%edx
f0102934:	c1 ea 0c             	shr    $0xc,%edx
f0102937:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f010293d:	72 20                	jb     f010295f <mem_init+0x188b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010293f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102943:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f010294a:	f0 
f010294b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102952:	00 
f0102953:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f010295a:	e8 35 d7 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010295f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102966:	00 
f0102967:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010296e:	00 
	return (void *)(pa + KERNBASE);
f010296f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102974:	89 04 24             	mov    %eax,(%esp)
f0102977:	e8 82 0d 00 00       	call   f01036fe <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010297c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102983:	00 
f0102984:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010298b:	00 
f010298c:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102990:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102995:	89 04 24             	mov    %eax,(%esp)
f0102998:	e8 bd e6 ff ff       	call   f010105a <page_insert>
	assert(pp1->pp_ref == 1);
f010299d:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01029a2:	74 24                	je     f01029c8 <mem_init+0x18f4>
f01029a4:	c7 44 24 0c 21 4a 10 	movl   $0xf0104a21,0xc(%esp)
f01029ab:	f0 
f01029ac:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01029b3:	f0 
f01029b4:	c7 44 24 04 9d 03 00 	movl   $0x39d,0x4(%esp)
f01029bb:	00 
f01029bc:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01029c3:	e8 cc d6 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01029c8:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01029cf:	01 01 01 
f01029d2:	74 24                	je     f01029f8 <mem_init+0x1924>
f01029d4:	c7 44 24 0c 98 47 10 	movl   $0xf0104798,0xc(%esp)
f01029db:	f0 
f01029dc:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f01029e3:	f0 
f01029e4:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01029eb:	00 
f01029ec:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f01029f3:	e8 9c d6 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01029f8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01029ff:	00 
f0102a00:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a07:	00 
f0102a08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a0c:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102a11:	89 04 24             	mov    %eax,(%esp)
f0102a14:	e8 41 e6 ff ff       	call   f010105a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a19:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a20:	02 02 02 
f0102a23:	74 24                	je     f0102a49 <mem_init+0x1975>
f0102a25:	c7 44 24 0c bc 47 10 	movl   $0xf01047bc,0xc(%esp)
f0102a2c:	f0 
f0102a2d:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102a34:	f0 
f0102a35:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f0102a3c:	00 
f0102a3d:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102a44:	e8 4b d6 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102a49:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102a4e:	74 24                	je     f0102a74 <mem_init+0x19a0>
f0102a50:	c7 44 24 0c 43 4a 10 	movl   $0xf0104a43,0xc(%esp)
f0102a57:	f0 
f0102a58:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102a5f:	f0 
f0102a60:	c7 44 24 04 a1 03 00 	movl   $0x3a1,0x4(%esp)
f0102a67:	00 
f0102a68:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102a6f:	e8 20 d6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102a74:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a79:	74 24                	je     f0102a9f <mem_init+0x19cb>
f0102a7b:	c7 44 24 0c ad 4a 10 	movl   $0xf0104aad,0xc(%esp)
f0102a82:	f0 
f0102a83:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102a8a:	f0 
f0102a8b:	c7 44 24 04 a2 03 00 	movl   $0x3a2,0x4(%esp)
f0102a92:	00 
f0102a93:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102a9a:	e8 f5 d5 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102a9f:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102aa6:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102aa9:	89 d8                	mov    %ebx,%eax
f0102aab:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0102ab1:	c1 f8 03             	sar    $0x3,%eax
f0102ab4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102ab7:	89 c2                	mov    %eax,%edx
f0102ab9:	c1 ea 0c             	shr    $0xc,%edx
f0102abc:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0102ac2:	72 20                	jb     f0102ae4 <mem_init+0x1a10>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102ac4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102ac8:	c7 44 24 08 84 40 10 	movl   $0xf0104084,0x8(%esp)
f0102acf:	f0 
f0102ad0:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102ad7:	00 
f0102ad8:	c7 04 24 5f 48 10 f0 	movl   $0xf010485f,(%esp)
f0102adf:	e8 b0 d5 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ae4:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102aeb:	03 03 03 
f0102aee:	74 24                	je     f0102b14 <mem_init+0x1a40>
f0102af0:	c7 44 24 0c e0 47 10 	movl   $0xf01047e0,0xc(%esp)
f0102af7:	f0 
f0102af8:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102aff:	f0 
f0102b00:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0102b07:	00 
f0102b08:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102b0f:	e8 80 d5 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b14:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b1b:	00 
f0102b1c:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102b21:	89 04 24             	mov    %eax,(%esp)
f0102b24:	e8 e8 e4 ff ff       	call   f0101011 <page_remove>
	assert(pp2->pp_ref == 0);
f0102b29:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102b2e:	74 24                	je     f0102b54 <mem_init+0x1a80>
f0102b30:	c7 44 24 0c 7b 4a 10 	movl   $0xf0104a7b,0xc(%esp)
f0102b37:	f0 
f0102b38:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102b3f:	f0 
f0102b40:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102b47:	00 
f0102b48:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102b4f:	e8 40 d5 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b54:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102b59:	8b 08                	mov    (%eax),%ecx
f0102b5b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b61:	89 f2                	mov    %esi,%edx
f0102b63:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102b69:	c1 fa 03             	sar    $0x3,%edx
f0102b6c:	c1 e2 0c             	shl    $0xc,%edx
f0102b6f:	39 d1                	cmp    %edx,%ecx
f0102b71:	74 24                	je     f0102b97 <mem_init+0x1ac3>
f0102b73:	c7 44 24 0c 24 43 10 	movl   $0xf0104324,0xc(%esp)
f0102b7a:	f0 
f0102b7b:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102b82:	f0 
f0102b83:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102b8a:	00 
f0102b8b:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102b92:	e8 fd d4 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102b97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b9d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ba2:	74 24                	je     f0102bc8 <mem_init+0x1af4>
f0102ba4:	c7 44 24 0c 32 4a 10 	movl   $0xf0104a32,0xc(%esp)
f0102bab:	f0 
f0102bac:	c7 44 24 08 79 48 10 	movl   $0xf0104879,0x8(%esp)
f0102bb3:	f0 
f0102bb4:	c7 44 24 04 ab 03 00 	movl   $0x3ab,0x4(%esp)
f0102bbb:	00 
f0102bbc:	c7 04 24 38 48 10 f0 	movl   $0xf0104838,(%esp)
f0102bc3:	e8 cc d4 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102bc8:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102bce:	89 34 24             	mov    %esi,(%esp)
f0102bd1:	e8 b8 e2 ff ff       	call   f0100e8e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102bd6:	c7 04 24 0c 48 10 f0 	movl   $0xf010480c,(%esp)
f0102bdd:	e8 78 00 00 00       	call   f0102c5a <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102be2:	83 c4 3c             	add    $0x3c,%esp
f0102be5:	5b                   	pop    %ebx
f0102be6:	5e                   	pop    %esi
f0102be7:	5f                   	pop    %edi
f0102be8:	5d                   	pop    %ebp
f0102be9:	c3                   	ret    
	...

f0102bec <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102bec:	55                   	push   %ebp
f0102bed:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102bef:	ba 70 00 00 00       	mov    $0x70,%edx
f0102bf4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102bf7:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102bf8:	b2 71                	mov    $0x71,%dl
f0102bfa:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102bfb:	0f b6 c0             	movzbl %al,%eax
}
f0102bfe:	5d                   	pop    %ebp
f0102bff:	c3                   	ret    

f0102c00 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102c00:	55                   	push   %ebp
f0102c01:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c03:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c08:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c0b:	ee                   	out    %al,(%dx)
f0102c0c:	b2 71                	mov    $0x71,%dl
f0102c0e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c11:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102c12:	5d                   	pop    %ebp
f0102c13:	c3                   	ret    

f0102c14 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102c14:	55                   	push   %ebp
f0102c15:	89 e5                	mov    %esp,%ebp
f0102c17:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102c1a:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c1d:	89 04 24             	mov    %eax,(%esp)
f0102c20:	e8 93 d9 ff ff       	call   f01005b8 <cputchar>
	*cnt++;
}
f0102c25:	c9                   	leave  
f0102c26:	c3                   	ret    

f0102c27 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102c27:	55                   	push   %ebp
f0102c28:	89 e5                	mov    %esp,%ebp
f0102c2a:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102c2d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102c34:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c37:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c3b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c3e:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102c42:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102c45:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c49:	c7 04 24 14 2c 10 f0 	movl   $0xf0102c14,(%esp)
f0102c50:	e8 69 04 00 00       	call   f01030be <vprintfmt>
	return cnt;
}
f0102c55:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102c58:	c9                   	leave  
f0102c59:	c3                   	ret    

f0102c5a <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102c5a:	55                   	push   %ebp
f0102c5b:	89 e5                	mov    %esp,%ebp
f0102c5d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102c60:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102c63:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102c67:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c6a:	89 04 24             	mov    %eax,(%esp)
f0102c6d:	e8 b5 ff ff ff       	call   f0102c27 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102c72:	c9                   	leave  
f0102c73:	c3                   	ret    

f0102c74 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102c74:	55                   	push   %ebp
f0102c75:	89 e5                	mov    %esp,%ebp
f0102c77:	57                   	push   %edi
f0102c78:	56                   	push   %esi
f0102c79:	53                   	push   %ebx
f0102c7a:	83 ec 10             	sub    $0x10,%esp
f0102c7d:	89 c3                	mov    %eax,%ebx
f0102c7f:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102c82:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102c85:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102c88:	8b 0a                	mov    (%edx),%ecx
f0102c8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102c8d:	8b 00                	mov    (%eax),%eax
f0102c8f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102c92:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102c99:	eb 77                	jmp    f0102d12 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0102c9b:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102c9e:	01 c8                	add    %ecx,%eax
f0102ca0:	bf 02 00 00 00       	mov    $0x2,%edi
f0102ca5:	99                   	cltd   
f0102ca6:	f7 ff                	idiv   %edi
f0102ca8:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102caa:	eb 01                	jmp    f0102cad <stab_binsearch+0x39>
			m--;
f0102cac:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102cad:	39 ca                	cmp    %ecx,%edx
f0102caf:	7c 1d                	jl     f0102cce <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102cb1:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102cb4:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0102cb9:	39 f7                	cmp    %esi,%edi
f0102cbb:	75 ef                	jne    f0102cac <stab_binsearch+0x38>
f0102cbd:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102cc0:	6b fa 0c             	imul   $0xc,%edx,%edi
f0102cc3:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0102cc7:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102cca:	73 18                	jae    f0102ce4 <stab_binsearch+0x70>
f0102ccc:	eb 05                	jmp    f0102cd3 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102cce:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0102cd1:	eb 3f                	jmp    f0102d12 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102cd3:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102cd6:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0102cd8:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cdb:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102ce2:	eb 2e                	jmp    f0102d12 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102ce4:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102ce7:	76 15                	jbe    f0102cfe <stab_binsearch+0x8a>
			*region_right = m - 1;
f0102ce9:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102cec:	4f                   	dec    %edi
f0102ced:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0102cf0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102cf3:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102cf5:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102cfc:	eb 14                	jmp    f0102d12 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102cfe:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102d01:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102d04:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0102d06:	ff 45 0c             	incl   0xc(%ebp)
f0102d09:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d0b:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102d12:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0102d15:	7e 84                	jle    f0102c9b <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102d17:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102d1b:	75 0d                	jne    f0102d2a <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0102d1d:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102d20:	8b 02                	mov    (%edx),%eax
f0102d22:	48                   	dec    %eax
f0102d23:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102d26:	89 01                	mov    %eax,(%ecx)
f0102d28:	eb 22                	jmp    f0102d4c <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d2a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102d2d:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102d2f:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102d32:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d34:	eb 01                	jmp    f0102d37 <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102d36:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102d37:	39 c1                	cmp    %eax,%ecx
f0102d39:	7d 0c                	jge    f0102d47 <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102d3b:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0102d3e:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0102d43:	39 f2                	cmp    %esi,%edx
f0102d45:	75 ef                	jne    f0102d36 <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102d47:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102d4a:	89 02                	mov    %eax,(%edx)
	}
}
f0102d4c:	83 c4 10             	add    $0x10,%esp
f0102d4f:	5b                   	pop    %ebx
f0102d50:	5e                   	pop    %esi
f0102d51:	5f                   	pop    %edi
f0102d52:	5d                   	pop    %ebp
f0102d53:	c3                   	ret    

f0102d54 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102d54:	55                   	push   %ebp
f0102d55:	89 e5                	mov    %esp,%ebp
f0102d57:	57                   	push   %edi
f0102d58:	56                   	push   %esi
f0102d59:	53                   	push   %ebx
f0102d5a:	83 ec 4c             	sub    $0x4c,%esp
f0102d5d:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d60:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102d63:	c7 03 36 4b 10 f0    	movl   $0xf0104b36,(%ebx)
	info->eip_line = 0;
f0102d69:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102d70:	c7 43 08 36 4b 10 f0 	movl   $0xf0104b36,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102d77:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102d7e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102d81:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102d88:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102d8e:	76 12                	jbe    f0102da2 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102d90:	b8 74 47 11 f0       	mov    $0xf0114774,%eax
f0102d95:	3d 3d b6 10 f0       	cmp    $0xf010b63d,%eax
f0102d9a:	0f 86 a7 01 00 00    	jbe    f0102f47 <debuginfo_eip+0x1f3>
f0102da0:	eb 1c                	jmp    f0102dbe <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102da2:	c7 44 24 08 40 4b 10 	movl   $0xf0104b40,0x8(%esp)
f0102da9:	f0 
f0102daa:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102db1:	00 
f0102db2:	c7 04 24 4d 4b 10 f0 	movl   $0xf0104b4d,(%esp)
f0102db9:	e8 d6 d2 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102dbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102dc3:	80 3d 73 47 11 f0 00 	cmpb   $0x0,0xf0114773
f0102dca:	0f 85 83 01 00 00    	jne    f0102f53 <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102dd0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102dd7:	b8 3c b6 10 f0       	mov    $0xf010b63c,%eax
f0102ddc:	2d 6c 4d 10 f0       	sub    $0xf0104d6c,%eax
f0102de1:	c1 f8 02             	sar    $0x2,%eax
f0102de4:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102dea:	48                   	dec    %eax
f0102deb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102dee:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102df2:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102df9:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102dfc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102dff:	b8 6c 4d 10 f0       	mov    $0xf0104d6c,%eax
f0102e04:	e8 6b fe ff ff       	call   f0102c74 <stab_binsearch>
	if (lfile == 0)
f0102e09:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0102e0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102e11:	85 d2                	test   %edx,%edx
f0102e13:	0f 84 3a 01 00 00    	je     f0102f53 <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102e19:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102e1c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e1f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102e22:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102e26:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102e2d:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102e30:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102e33:	b8 6c 4d 10 f0       	mov    $0xf0104d6c,%eax
f0102e38:	e8 37 fe ff ff       	call   f0102c74 <stab_binsearch>

	if (lfun <= rfun) {
f0102e3d:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102e40:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102e43:	39 d0                	cmp    %edx,%eax
f0102e45:	7f 3e                	jg     f0102e85 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102e47:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0102e4a:	8d b9 6c 4d 10 f0    	lea    -0xfefb294(%ecx),%edi
f0102e50:	8b 89 6c 4d 10 f0    	mov    -0xfefb294(%ecx),%ecx
f0102e56:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0102e59:	b9 74 47 11 f0       	mov    $0xf0114774,%ecx
f0102e5e:	81 e9 3d b6 10 f0    	sub    $0xf010b63d,%ecx
f0102e64:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0102e67:	73 0c                	jae    f0102e75 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102e69:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0102e6c:	81 c1 3d b6 10 f0    	add    $0xf010b63d,%ecx
f0102e72:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102e75:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102e78:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102e7b:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102e7d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102e80:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102e83:	eb 0f                	jmp    f0102e94 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102e85:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102e88:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e8b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102e8e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102e91:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102e94:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102e9b:	00 
f0102e9c:	8b 43 08             	mov    0x8(%ebx),%eax
f0102e9f:	89 04 24             	mov    %eax,(%esp)
f0102ea2:	e8 3f 08 00 00       	call   f01036e6 <strfind>
f0102ea7:	2b 43 08             	sub    0x8(%ebx),%eax
f0102eaa:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102ead:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102eb1:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0102eb8:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102ebb:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102ebe:	b8 6c 4d 10 f0       	mov    $0xf0104d6c,%eax
f0102ec3:	e8 ac fd ff ff       	call   f0102c74 <stab_binsearch>
	if (lline > rline) {
f0102ec8:	8b 55 d0             	mov    -0x30(%ebp),%edx
		return -1;
f0102ecb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
f0102ed0:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102ed3:	7f 7e                	jg     f0102f53 <debuginfo_eip+0x1ff>
		return -1;
	}
	info->eip_line = stabs[rline].n_desc;
f0102ed5:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102ed8:	0f b7 82 72 4d 10 f0 	movzwl -0xfefb28e(%edx),%eax
f0102edf:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102ee2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ee5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ee8:	eb 01                	jmp    f0102eeb <debuginfo_eip+0x197>
f0102eea:	48                   	dec    %eax
f0102eeb:	89 c6                	mov    %eax,%esi
f0102eed:	39 c7                	cmp    %eax,%edi
f0102eef:	7f 26                	jg     f0102f17 <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0102ef1:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102ef4:	8d 0c 95 6c 4d 10 f0 	lea    -0xfefb294(,%edx,4),%ecx
f0102efb:	8a 51 04             	mov    0x4(%ecx),%dl
f0102efe:	80 fa 84             	cmp    $0x84,%dl
f0102f01:	74 58                	je     f0102f5b <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102f03:	80 fa 64             	cmp    $0x64,%dl
f0102f06:	75 e2                	jne    f0102eea <debuginfo_eip+0x196>
f0102f08:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0102f0c:	74 dc                	je     f0102eea <debuginfo_eip+0x196>
f0102f0e:	eb 4b                	jmp    f0102f5b <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102f10:	05 3d b6 10 f0       	add    $0xf010b63d,%eax
f0102f15:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f17:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102f1a:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f1d:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f22:	39 d1                	cmp    %edx,%ecx
f0102f24:	7d 2d                	jge    f0102f53 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f0102f26:	8d 41 01             	lea    0x1(%ecx),%eax
f0102f29:	eb 03                	jmp    f0102f2e <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102f2b:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102f2e:	39 d0                	cmp    %edx,%eax
f0102f30:	7d 1c                	jge    f0102f4e <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102f32:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102f35:	40                   	inc    %eax
f0102f36:	80 3c 8d 70 4d 10 f0 	cmpb   $0xa0,-0xfefb290(,%ecx,4)
f0102f3d:	a0 
f0102f3e:	74 eb                	je     f0102f2b <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f40:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f45:	eb 0c                	jmp    f0102f53 <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102f47:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102f4c:	eb 05                	jmp    f0102f53 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102f4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102f53:	83 c4 4c             	add    $0x4c,%esp
f0102f56:	5b                   	pop    %ebx
f0102f57:	5e                   	pop    %esi
f0102f58:	5f                   	pop    %edi
f0102f59:	5d                   	pop    %ebp
f0102f5a:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102f5b:	6b f6 0c             	imul   $0xc,%esi,%esi
f0102f5e:	8b 86 6c 4d 10 f0    	mov    -0xfefb294(%esi),%eax
f0102f64:	ba 74 47 11 f0       	mov    $0xf0114774,%edx
f0102f69:	81 ea 3d b6 10 f0    	sub    $0xf010b63d,%edx
f0102f6f:	39 d0                	cmp    %edx,%eax
f0102f71:	72 9d                	jb     f0102f10 <debuginfo_eip+0x1bc>
f0102f73:	eb a2                	jmp    f0102f17 <debuginfo_eip+0x1c3>
f0102f75:	00 00                	add    %al,(%eax)
	...

f0102f78 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102f78:	55                   	push   %ebp
f0102f79:	89 e5                	mov    %esp,%ebp
f0102f7b:	57                   	push   %edi
f0102f7c:	56                   	push   %esi
f0102f7d:	53                   	push   %ebx
f0102f7e:	83 ec 3c             	sub    $0x3c,%esp
f0102f81:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102f84:	89 d7                	mov    %edx,%edi
f0102f86:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f89:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102f8c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f8f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102f92:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0102f95:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102f98:	85 c0                	test   %eax,%eax
f0102f9a:	75 08                	jne    f0102fa4 <printnum+0x2c>
f0102f9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102f9f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102fa2:	77 57                	ja     f0102ffb <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102fa4:	89 74 24 10          	mov    %esi,0x10(%esp)
f0102fa8:	4b                   	dec    %ebx
f0102fa9:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0102fad:	8b 45 10             	mov    0x10(%ebp),%eax
f0102fb0:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102fb4:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f0102fb8:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0102fbc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102fc3:	00 
f0102fc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102fc7:	89 04 24             	mov    %eax,(%esp)
f0102fca:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102fcd:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102fd1:	e8 1e 09 00 00       	call   f01038f4 <__udivdi3>
f0102fd6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0102fda:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0102fde:	89 04 24             	mov    %eax,(%esp)
f0102fe1:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102fe5:	89 fa                	mov    %edi,%edx
f0102fe7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fea:	e8 89 ff ff ff       	call   f0102f78 <printnum>
f0102fef:	eb 0f                	jmp    f0103000 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102ff1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102ff5:	89 34 24             	mov    %esi,(%esp)
f0102ff8:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102ffb:	4b                   	dec    %ebx
f0102ffc:	85 db                	test   %ebx,%ebx
f0102ffe:	7f f1                	jg     f0102ff1 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103000:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103004:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103008:	8b 45 10             	mov    0x10(%ebp),%eax
f010300b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010300f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103016:	00 
f0103017:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010301a:	89 04 24             	mov    %eax,(%esp)
f010301d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103020:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103024:	e8 eb 09 00 00       	call   f0103a14 <__umoddi3>
f0103029:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010302d:	0f be 80 5b 4b 10 f0 	movsbl -0xfefb4a5(%eax),%eax
f0103034:	89 04 24             	mov    %eax,(%esp)
f0103037:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010303a:	83 c4 3c             	add    $0x3c,%esp
f010303d:	5b                   	pop    %ebx
f010303e:	5e                   	pop    %esi
f010303f:	5f                   	pop    %edi
f0103040:	5d                   	pop    %ebp
f0103041:	c3                   	ret    

f0103042 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103042:	55                   	push   %ebp
f0103043:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103045:	83 fa 01             	cmp    $0x1,%edx
f0103048:	7e 0e                	jle    f0103058 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010304a:	8b 10                	mov    (%eax),%edx
f010304c:	8d 4a 08             	lea    0x8(%edx),%ecx
f010304f:	89 08                	mov    %ecx,(%eax)
f0103051:	8b 02                	mov    (%edx),%eax
f0103053:	8b 52 04             	mov    0x4(%edx),%edx
f0103056:	eb 22                	jmp    f010307a <getuint+0x38>
	else if (lflag)
f0103058:	85 d2                	test   %edx,%edx
f010305a:	74 10                	je     f010306c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f010305c:	8b 10                	mov    (%eax),%edx
f010305e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103061:	89 08                	mov    %ecx,(%eax)
f0103063:	8b 02                	mov    (%edx),%eax
f0103065:	ba 00 00 00 00       	mov    $0x0,%edx
f010306a:	eb 0e                	jmp    f010307a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f010306c:	8b 10                	mov    (%eax),%edx
f010306e:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103071:	89 08                	mov    %ecx,(%eax)
f0103073:	8b 02                	mov    (%edx),%eax
f0103075:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010307a:	5d                   	pop    %ebp
f010307b:	c3                   	ret    

f010307c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f010307c:	55                   	push   %ebp
f010307d:	89 e5                	mov    %esp,%ebp
f010307f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103082:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103085:	8b 10                	mov    (%eax),%edx
f0103087:	3b 50 04             	cmp    0x4(%eax),%edx
f010308a:	73 08                	jae    f0103094 <sprintputch+0x18>
		*b->buf++ = ch;
f010308c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010308f:	88 0a                	mov    %cl,(%edx)
f0103091:	42                   	inc    %edx
f0103092:	89 10                	mov    %edx,(%eax)
}
f0103094:	5d                   	pop    %ebp
f0103095:	c3                   	ret    

f0103096 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103096:	55                   	push   %ebp
f0103097:	89 e5                	mov    %esp,%ebp
f0103099:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f010309c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f010309f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030a3:	8b 45 10             	mov    0x10(%ebp),%eax
f01030a6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030aa:	8b 45 0c             	mov    0xc(%ebp),%eax
f01030ad:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030b1:	8b 45 08             	mov    0x8(%ebp),%eax
f01030b4:	89 04 24             	mov    %eax,(%esp)
f01030b7:	e8 02 00 00 00       	call   f01030be <vprintfmt>
	va_end(ap);
}
f01030bc:	c9                   	leave  
f01030bd:	c3                   	ret    

f01030be <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01030be:	55                   	push   %ebp
f01030bf:	89 e5                	mov    %esp,%ebp
f01030c1:	57                   	push   %edi
f01030c2:	56                   	push   %esi
f01030c3:	53                   	push   %ebx
f01030c4:	83 ec 4c             	sub    $0x4c,%esp
f01030c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01030ca:	8b 75 10             	mov    0x10(%ebp),%esi
f01030cd:	eb 12                	jmp    f01030e1 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01030cf:	85 c0                	test   %eax,%eax
f01030d1:	0f 84 6b 03 00 00    	je     f0103442 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f01030d7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01030db:	89 04 24             	mov    %eax,(%esp)
f01030de:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01030e1:	0f b6 06             	movzbl (%esi),%eax
f01030e4:	46                   	inc    %esi
f01030e5:	83 f8 25             	cmp    $0x25,%eax
f01030e8:	75 e5                	jne    f01030cf <vprintfmt+0x11>
f01030ea:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01030ee:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01030f5:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01030fa:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103101:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103106:	eb 26                	jmp    f010312e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103108:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010310b:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f010310f:	eb 1d                	jmp    f010312e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103111:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103114:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f0103118:	eb 14                	jmp    f010312e <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010311a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f010311d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103124:	eb 08                	jmp    f010312e <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f0103126:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f0103129:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010312e:	0f b6 06             	movzbl (%esi),%eax
f0103131:	8d 56 01             	lea    0x1(%esi),%edx
f0103134:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0103137:	8a 16                	mov    (%esi),%dl
f0103139:	83 ea 23             	sub    $0x23,%edx
f010313c:	80 fa 55             	cmp    $0x55,%dl
f010313f:	0f 87 e1 02 00 00    	ja     f0103426 <vprintfmt+0x368>
f0103145:	0f b6 d2             	movzbl %dl,%edx
f0103148:	ff 24 95 e8 4b 10 f0 	jmp    *-0xfefb418(,%edx,4)
f010314f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103152:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103157:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010315a:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f010315e:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103161:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103164:	83 fa 09             	cmp    $0x9,%edx
f0103167:	77 2a                	ja     f0103193 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103169:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010316a:	eb eb                	jmp    f0103157 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f010316c:	8b 45 14             	mov    0x14(%ebp),%eax
f010316f:	8d 50 04             	lea    0x4(%eax),%edx
f0103172:	89 55 14             	mov    %edx,0x14(%ebp)
f0103175:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103177:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010317a:	eb 17                	jmp    f0103193 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f010317c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103180:	78 98                	js     f010311a <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103182:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103185:	eb a7                	jmp    f010312e <vprintfmt+0x70>
f0103187:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010318a:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103191:	eb 9b                	jmp    f010312e <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0103193:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103197:	79 95                	jns    f010312e <vprintfmt+0x70>
f0103199:	eb 8b                	jmp    f0103126 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010319b:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010319c:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f010319f:	eb 8d                	jmp    f010312e <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01031a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01031a4:	8d 50 04             	lea    0x4(%eax),%edx
f01031a7:	89 55 14             	mov    %edx,0x14(%ebp)
f01031aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031ae:	8b 00                	mov    (%eax),%eax
f01031b0:	89 04 24             	mov    %eax,(%esp)
f01031b3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031b6:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01031b9:	e9 23 ff ff ff       	jmp    f01030e1 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01031be:	8b 45 14             	mov    0x14(%ebp),%eax
f01031c1:	8d 50 04             	lea    0x4(%eax),%edx
f01031c4:	89 55 14             	mov    %edx,0x14(%ebp)
f01031c7:	8b 00                	mov    (%eax),%eax
f01031c9:	85 c0                	test   %eax,%eax
f01031cb:	79 02                	jns    f01031cf <vprintfmt+0x111>
f01031cd:	f7 d8                	neg    %eax
f01031cf:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01031d1:	83 f8 06             	cmp    $0x6,%eax
f01031d4:	7f 0b                	jg     f01031e1 <vprintfmt+0x123>
f01031d6:	8b 04 85 40 4d 10 f0 	mov    -0xfefb2c0(,%eax,4),%eax
f01031dd:	85 c0                	test   %eax,%eax
f01031df:	75 23                	jne    f0103204 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01031e1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01031e5:	c7 44 24 08 73 4b 10 	movl   $0xf0104b73,0x8(%esp)
f01031ec:	f0 
f01031ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031f1:	8b 45 08             	mov    0x8(%ebp),%eax
f01031f4:	89 04 24             	mov    %eax,(%esp)
f01031f7:	e8 9a fe ff ff       	call   f0103096 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031fc:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01031ff:	e9 dd fe ff ff       	jmp    f01030e1 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103204:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103208:	c7 44 24 08 8b 48 10 	movl   $0xf010488b,0x8(%esp)
f010320f:	f0 
f0103210:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103214:	8b 55 08             	mov    0x8(%ebp),%edx
f0103217:	89 14 24             	mov    %edx,(%esp)
f010321a:	e8 77 fe ff ff       	call   f0103096 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010321f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103222:	e9 ba fe ff ff       	jmp    f01030e1 <vprintfmt+0x23>
f0103227:	89 f9                	mov    %edi,%ecx
f0103229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010322c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f010322f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103232:	8d 50 04             	lea    0x4(%eax),%edx
f0103235:	89 55 14             	mov    %edx,0x14(%ebp)
f0103238:	8b 30                	mov    (%eax),%esi
f010323a:	85 f6                	test   %esi,%esi
f010323c:	75 05                	jne    f0103243 <vprintfmt+0x185>
				p = "(null)";
f010323e:	be 6c 4b 10 f0       	mov    $0xf0104b6c,%esi
			if (width > 0 && padc != '-')
f0103243:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f0103247:	0f 8e 84 00 00 00    	jle    f01032d1 <vprintfmt+0x213>
f010324d:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103251:	74 7e                	je     f01032d1 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103253:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0103257:	89 34 24             	mov    %esi,(%esp)
f010325a:	e8 53 03 00 00       	call   f01035b2 <strnlen>
f010325f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103262:	29 c2                	sub    %eax,%edx
f0103264:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f0103267:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010326b:	89 75 d0             	mov    %esi,-0x30(%ebp)
f010326e:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0103271:	89 de                	mov    %ebx,%esi
f0103273:	89 d3                	mov    %edx,%ebx
f0103275:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103277:	eb 0b                	jmp    f0103284 <vprintfmt+0x1c6>
					putch(padc, putdat);
f0103279:	89 74 24 04          	mov    %esi,0x4(%esp)
f010327d:	89 3c 24             	mov    %edi,(%esp)
f0103280:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103283:	4b                   	dec    %ebx
f0103284:	85 db                	test   %ebx,%ebx
f0103286:	7f f1                	jg     f0103279 <vprintfmt+0x1bb>
f0103288:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010328b:	89 f3                	mov    %esi,%ebx
f010328d:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0103290:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103293:	85 c0                	test   %eax,%eax
f0103295:	79 05                	jns    f010329c <vprintfmt+0x1de>
f0103297:	b8 00 00 00 00       	mov    $0x0,%eax
f010329c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010329f:	29 c2                	sub    %eax,%edx
f01032a1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01032a4:	eb 2b                	jmp    f01032d1 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01032a6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01032aa:	74 18                	je     f01032c4 <vprintfmt+0x206>
f01032ac:	8d 50 e0             	lea    -0x20(%eax),%edx
f01032af:	83 fa 5e             	cmp    $0x5e,%edx
f01032b2:	76 10                	jbe    f01032c4 <vprintfmt+0x206>
					putch('?', putdat);
f01032b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032b8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01032bf:	ff 55 08             	call   *0x8(%ebp)
f01032c2:	eb 0a                	jmp    f01032ce <vprintfmt+0x210>
				else
					putch(ch, putdat);
f01032c4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032c8:	89 04 24             	mov    %eax,(%esp)
f01032cb:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01032ce:	ff 4d e4             	decl   -0x1c(%ebp)
f01032d1:	0f be 06             	movsbl (%esi),%eax
f01032d4:	46                   	inc    %esi
f01032d5:	85 c0                	test   %eax,%eax
f01032d7:	74 21                	je     f01032fa <vprintfmt+0x23c>
f01032d9:	85 ff                	test   %edi,%edi
f01032db:	78 c9                	js     f01032a6 <vprintfmt+0x1e8>
f01032dd:	4f                   	dec    %edi
f01032de:	79 c6                	jns    f01032a6 <vprintfmt+0x1e8>
f01032e0:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032e3:	89 de                	mov    %ebx,%esi
f01032e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01032e8:	eb 18                	jmp    f0103302 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01032ea:	89 74 24 04          	mov    %esi,0x4(%esp)
f01032ee:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01032f5:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01032f7:	4b                   	dec    %ebx
f01032f8:	eb 08                	jmp    f0103302 <vprintfmt+0x244>
f01032fa:	8b 7d 08             	mov    0x8(%ebp),%edi
f01032fd:	89 de                	mov    %ebx,%esi
f01032ff:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103302:	85 db                	test   %ebx,%ebx
f0103304:	7f e4                	jg     f01032ea <vprintfmt+0x22c>
f0103306:	89 7d 08             	mov    %edi,0x8(%ebp)
f0103309:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010330b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010330e:	e9 ce fd ff ff       	jmp    f01030e1 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103313:	83 f9 01             	cmp    $0x1,%ecx
f0103316:	7e 10                	jle    f0103328 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f0103318:	8b 45 14             	mov    0x14(%ebp),%eax
f010331b:	8d 50 08             	lea    0x8(%eax),%edx
f010331e:	89 55 14             	mov    %edx,0x14(%ebp)
f0103321:	8b 30                	mov    (%eax),%esi
f0103323:	8b 78 04             	mov    0x4(%eax),%edi
f0103326:	eb 26                	jmp    f010334e <vprintfmt+0x290>
	else if (lflag)
f0103328:	85 c9                	test   %ecx,%ecx
f010332a:	74 12                	je     f010333e <vprintfmt+0x280>
		return va_arg(*ap, long);
f010332c:	8b 45 14             	mov    0x14(%ebp),%eax
f010332f:	8d 50 04             	lea    0x4(%eax),%edx
f0103332:	89 55 14             	mov    %edx,0x14(%ebp)
f0103335:	8b 30                	mov    (%eax),%esi
f0103337:	89 f7                	mov    %esi,%edi
f0103339:	c1 ff 1f             	sar    $0x1f,%edi
f010333c:	eb 10                	jmp    f010334e <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f010333e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103341:	8d 50 04             	lea    0x4(%eax),%edx
f0103344:	89 55 14             	mov    %edx,0x14(%ebp)
f0103347:	8b 30                	mov    (%eax),%esi
f0103349:	89 f7                	mov    %esi,%edi
f010334b:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f010334e:	85 ff                	test   %edi,%edi
f0103350:	78 0a                	js     f010335c <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103352:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103357:	e9 8c 00 00 00       	jmp    f01033e8 <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f010335c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103360:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f0103367:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010336a:	f7 de                	neg    %esi
f010336c:	83 d7 00             	adc    $0x0,%edi
f010336f:	f7 df                	neg    %edi
			}
			base = 10;
f0103371:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103376:	eb 70                	jmp    f01033e8 <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103378:	89 ca                	mov    %ecx,%edx
f010337a:	8d 45 14             	lea    0x14(%ebp),%eax
f010337d:	e8 c0 fc ff ff       	call   f0103042 <getuint>
f0103382:	89 c6                	mov    %eax,%esi
f0103384:	89 d7                	mov    %edx,%edi
			base = 10;
f0103386:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010338b:	eb 5b                	jmp    f01033e8 <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010338d:	89 ca                	mov    %ecx,%edx
f010338f:	8d 45 14             	lea    0x14(%ebp),%eax
f0103392:	e8 ab fc ff ff       	call   f0103042 <getuint>
f0103397:	89 c6                	mov    %eax,%esi
f0103399:	89 d7                	mov    %edx,%edi
			base = 8;
f010339b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01033a0:	eb 46                	jmp    f01033e8 <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f01033a2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033a6:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01033ad:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01033b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033b4:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01033bb:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01033be:	8b 45 14             	mov    0x14(%ebp),%eax
f01033c1:	8d 50 04             	lea    0x4(%eax),%edx
f01033c4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01033c7:	8b 30                	mov    (%eax),%esi
f01033c9:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01033ce:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01033d3:	eb 13                	jmp    f01033e8 <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01033d5:	89 ca                	mov    %ecx,%edx
f01033d7:	8d 45 14             	lea    0x14(%ebp),%eax
f01033da:	e8 63 fc ff ff       	call   f0103042 <getuint>
f01033df:	89 c6                	mov    %eax,%esi
f01033e1:	89 d7                	mov    %edx,%edi
			base = 16;
f01033e3:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01033e8:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01033ec:	89 54 24 10          	mov    %edx,0x10(%esp)
f01033f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01033f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01033f7:	89 44 24 08          	mov    %eax,0x8(%esp)
f01033fb:	89 34 24             	mov    %esi,(%esp)
f01033fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103402:	89 da                	mov    %ebx,%edx
f0103404:	8b 45 08             	mov    0x8(%ebp),%eax
f0103407:	e8 6c fb ff ff       	call   f0102f78 <printnum>
			break;
f010340c:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010340f:	e9 cd fc ff ff       	jmp    f01030e1 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103414:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103418:	89 04 24             	mov    %eax,(%esp)
f010341b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010341e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103421:	e9 bb fc ff ff       	jmp    f01030e1 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103426:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010342a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103431:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103434:	eb 01                	jmp    f0103437 <vprintfmt+0x379>
f0103436:	4e                   	dec    %esi
f0103437:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010343b:	75 f9                	jne    f0103436 <vprintfmt+0x378>
f010343d:	e9 9f fc ff ff       	jmp    f01030e1 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103442:	83 c4 4c             	add    $0x4c,%esp
f0103445:	5b                   	pop    %ebx
f0103446:	5e                   	pop    %esi
f0103447:	5f                   	pop    %edi
f0103448:	5d                   	pop    %ebp
f0103449:	c3                   	ret    

f010344a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010344a:	55                   	push   %ebp
f010344b:	89 e5                	mov    %esp,%ebp
f010344d:	83 ec 28             	sub    $0x28,%esp
f0103450:	8b 45 08             	mov    0x8(%ebp),%eax
f0103453:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103456:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103459:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f010345d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103460:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103467:	85 c0                	test   %eax,%eax
f0103469:	74 30                	je     f010349b <vsnprintf+0x51>
f010346b:	85 d2                	test   %edx,%edx
f010346d:	7e 33                	jle    f01034a2 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010346f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103472:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103476:	8b 45 10             	mov    0x10(%ebp),%eax
f0103479:	89 44 24 08          	mov    %eax,0x8(%esp)
f010347d:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103480:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103484:	c7 04 24 7c 30 10 f0 	movl   $0xf010307c,(%esp)
f010348b:	e8 2e fc ff ff       	call   f01030be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103490:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103493:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103496:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103499:	eb 0c                	jmp    f01034a7 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010349b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01034a0:	eb 05                	jmp    f01034a7 <vsnprintf+0x5d>
f01034a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01034a7:	c9                   	leave  
f01034a8:	c3                   	ret    

f01034a9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01034a9:	55                   	push   %ebp
f01034aa:	89 e5                	mov    %esp,%ebp
f01034ac:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01034af:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01034b2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034b6:	8b 45 10             	mov    0x10(%ebp),%eax
f01034b9:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034bd:	8b 45 0c             	mov    0xc(%ebp),%eax
f01034c0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01034c7:	89 04 24             	mov    %eax,(%esp)
f01034ca:	e8 7b ff ff ff       	call   f010344a <vsnprintf>
	va_end(ap);

	return rc;
}
f01034cf:	c9                   	leave  
f01034d0:	c3                   	ret    
f01034d1:	00 00                	add    %al,(%eax)
	...

f01034d4 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01034d4:	55                   	push   %ebp
f01034d5:	89 e5                	mov    %esp,%ebp
f01034d7:	57                   	push   %edi
f01034d8:	56                   	push   %esi
f01034d9:	53                   	push   %ebx
f01034da:	83 ec 1c             	sub    $0x1c,%esp
f01034dd:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01034e0:	85 c0                	test   %eax,%eax
f01034e2:	74 10                	je     f01034f4 <readline+0x20>
		cprintf("%s", prompt);
f01034e4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01034e8:	c7 04 24 8b 48 10 f0 	movl   $0xf010488b,(%esp)
f01034ef:	e8 66 f7 ff ff       	call   f0102c5a <cprintf>

	i = 0;
	echoing = iscons(0);
f01034f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01034fb:	e8 d9 d0 ff ff       	call   f01005d9 <iscons>
f0103500:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103502:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103507:	e8 bc d0 ff ff       	call   f01005c8 <getchar>
f010350c:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010350e:	85 c0                	test   %eax,%eax
f0103510:	79 17                	jns    f0103529 <readline+0x55>
			cprintf("read error: %e\n", c);
f0103512:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103516:	c7 04 24 5c 4d 10 f0 	movl   $0xf0104d5c,(%esp)
f010351d:	e8 38 f7 ff ff       	call   f0102c5a <cprintf>
			return NULL;
f0103522:	b8 00 00 00 00       	mov    $0x0,%eax
f0103527:	eb 69                	jmp    f0103592 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103529:	83 f8 08             	cmp    $0x8,%eax
f010352c:	74 05                	je     f0103533 <readline+0x5f>
f010352e:	83 f8 7f             	cmp    $0x7f,%eax
f0103531:	75 17                	jne    f010354a <readline+0x76>
f0103533:	85 f6                	test   %esi,%esi
f0103535:	7e 13                	jle    f010354a <readline+0x76>
			if (echoing)
f0103537:	85 ff                	test   %edi,%edi
f0103539:	74 0c                	je     f0103547 <readline+0x73>
				cputchar('\b');
f010353b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103542:	e8 71 d0 ff ff       	call   f01005b8 <cputchar>
			i--;
f0103547:	4e                   	dec    %esi
f0103548:	eb bd                	jmp    f0103507 <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010354a:	83 fb 1f             	cmp    $0x1f,%ebx
f010354d:	7e 1d                	jle    f010356c <readline+0x98>
f010354f:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103555:	7f 15                	jg     f010356c <readline+0x98>
			if (echoing)
f0103557:	85 ff                	test   %edi,%edi
f0103559:	74 08                	je     f0103563 <readline+0x8f>
				cputchar(c);
f010355b:	89 1c 24             	mov    %ebx,(%esp)
f010355e:	e8 55 d0 ff ff       	call   f01005b8 <cputchar>
			buf[i++] = c;
f0103563:	88 9e 60 f5 11 f0    	mov    %bl,-0xfee0aa0(%esi)
f0103569:	46                   	inc    %esi
f010356a:	eb 9b                	jmp    f0103507 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f010356c:	83 fb 0a             	cmp    $0xa,%ebx
f010356f:	74 05                	je     f0103576 <readline+0xa2>
f0103571:	83 fb 0d             	cmp    $0xd,%ebx
f0103574:	75 91                	jne    f0103507 <readline+0x33>
			if (echoing)
f0103576:	85 ff                	test   %edi,%edi
f0103578:	74 0c                	je     f0103586 <readline+0xb2>
				cputchar('\n');
f010357a:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103581:	e8 32 d0 ff ff       	call   f01005b8 <cputchar>
			buf[i] = 0;
f0103586:	c6 86 60 f5 11 f0 00 	movb   $0x0,-0xfee0aa0(%esi)
			return buf;
f010358d:	b8 60 f5 11 f0       	mov    $0xf011f560,%eax
		}
	}
}
f0103592:	83 c4 1c             	add    $0x1c,%esp
f0103595:	5b                   	pop    %ebx
f0103596:	5e                   	pop    %esi
f0103597:	5f                   	pop    %edi
f0103598:	5d                   	pop    %ebp
f0103599:	c3                   	ret    
	...

f010359c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010359c:	55                   	push   %ebp
f010359d:	89 e5                	mov    %esp,%ebp
f010359f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01035a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01035a7:	eb 01                	jmp    f01035aa <strlen+0xe>
		n++;
f01035a9:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01035aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01035ae:	75 f9                	jne    f01035a9 <strlen+0xd>
		n++;
	return n;
}
f01035b0:	5d                   	pop    %ebp
f01035b1:	c3                   	ret    

f01035b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01035b2:	55                   	push   %ebp
f01035b3:	89 e5                	mov    %esp,%ebp
f01035b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01035b8:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01035c0:	eb 01                	jmp    f01035c3 <strnlen+0x11>
		n++;
f01035c2:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01035c3:	39 d0                	cmp    %edx,%eax
f01035c5:	74 06                	je     f01035cd <strnlen+0x1b>
f01035c7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01035cb:	75 f5                	jne    f01035c2 <strnlen+0x10>
		n++;
	return n;
}
f01035cd:	5d                   	pop    %ebp
f01035ce:	c3                   	ret    

f01035cf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01035cf:	55                   	push   %ebp
f01035d0:	89 e5                	mov    %esp,%ebp
f01035d2:	53                   	push   %ebx
f01035d3:	8b 45 08             	mov    0x8(%ebp),%eax
f01035d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01035d9:	ba 00 00 00 00       	mov    $0x0,%edx
f01035de:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01035e1:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01035e4:	42                   	inc    %edx
f01035e5:	84 c9                	test   %cl,%cl
f01035e7:	75 f5                	jne    f01035de <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01035e9:	5b                   	pop    %ebx
f01035ea:	5d                   	pop    %ebp
f01035eb:	c3                   	ret    

f01035ec <strcat>:

char *
strcat(char *dst, const char *src)
{
f01035ec:	55                   	push   %ebp
f01035ed:	89 e5                	mov    %esp,%ebp
f01035ef:	53                   	push   %ebx
f01035f0:	83 ec 08             	sub    $0x8,%esp
f01035f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01035f6:	89 1c 24             	mov    %ebx,(%esp)
f01035f9:	e8 9e ff ff ff       	call   f010359c <strlen>
	strcpy(dst + len, src);
f01035fe:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103601:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103605:	01 d8                	add    %ebx,%eax
f0103607:	89 04 24             	mov    %eax,(%esp)
f010360a:	e8 c0 ff ff ff       	call   f01035cf <strcpy>
	return dst;
}
f010360f:	89 d8                	mov    %ebx,%eax
f0103611:	83 c4 08             	add    $0x8,%esp
f0103614:	5b                   	pop    %ebx
f0103615:	5d                   	pop    %ebp
f0103616:	c3                   	ret    

f0103617 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103617:	55                   	push   %ebp
f0103618:	89 e5                	mov    %esp,%ebp
f010361a:	56                   	push   %esi
f010361b:	53                   	push   %ebx
f010361c:	8b 45 08             	mov    0x8(%ebp),%eax
f010361f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103622:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103625:	b9 00 00 00 00       	mov    $0x0,%ecx
f010362a:	eb 0c                	jmp    f0103638 <strncpy+0x21>
		*dst++ = *src;
f010362c:	8a 1a                	mov    (%edx),%bl
f010362e:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103631:	80 3a 01             	cmpb   $0x1,(%edx)
f0103634:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103637:	41                   	inc    %ecx
f0103638:	39 f1                	cmp    %esi,%ecx
f010363a:	75 f0                	jne    f010362c <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010363c:	5b                   	pop    %ebx
f010363d:	5e                   	pop    %esi
f010363e:	5d                   	pop    %ebp
f010363f:	c3                   	ret    

f0103640 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103640:	55                   	push   %ebp
f0103641:	89 e5                	mov    %esp,%ebp
f0103643:	56                   	push   %esi
f0103644:	53                   	push   %ebx
f0103645:	8b 75 08             	mov    0x8(%ebp),%esi
f0103648:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010364b:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010364e:	85 d2                	test   %edx,%edx
f0103650:	75 0a                	jne    f010365c <strlcpy+0x1c>
f0103652:	89 f0                	mov    %esi,%eax
f0103654:	eb 1a                	jmp    f0103670 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0103656:	88 18                	mov    %bl,(%eax)
f0103658:	40                   	inc    %eax
f0103659:	41                   	inc    %ecx
f010365a:	eb 02                	jmp    f010365e <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010365c:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f010365e:	4a                   	dec    %edx
f010365f:	74 0a                	je     f010366b <strlcpy+0x2b>
f0103661:	8a 19                	mov    (%ecx),%bl
f0103663:	84 db                	test   %bl,%bl
f0103665:	75 ef                	jne    f0103656 <strlcpy+0x16>
f0103667:	89 c2                	mov    %eax,%edx
f0103669:	eb 02                	jmp    f010366d <strlcpy+0x2d>
f010366b:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f010366d:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103670:	29 f0                	sub    %esi,%eax
}
f0103672:	5b                   	pop    %ebx
f0103673:	5e                   	pop    %esi
f0103674:	5d                   	pop    %ebp
f0103675:	c3                   	ret    

f0103676 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103676:	55                   	push   %ebp
f0103677:	89 e5                	mov    %esp,%ebp
f0103679:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010367c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010367f:	eb 02                	jmp    f0103683 <strcmp+0xd>
		p++, q++;
f0103681:	41                   	inc    %ecx
f0103682:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103683:	8a 01                	mov    (%ecx),%al
f0103685:	84 c0                	test   %al,%al
f0103687:	74 04                	je     f010368d <strcmp+0x17>
f0103689:	3a 02                	cmp    (%edx),%al
f010368b:	74 f4                	je     f0103681 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010368d:	0f b6 c0             	movzbl %al,%eax
f0103690:	0f b6 12             	movzbl (%edx),%edx
f0103693:	29 d0                	sub    %edx,%eax
}
f0103695:	5d                   	pop    %ebp
f0103696:	c3                   	ret    

f0103697 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0103697:	55                   	push   %ebp
f0103698:	89 e5                	mov    %esp,%ebp
f010369a:	53                   	push   %ebx
f010369b:	8b 45 08             	mov    0x8(%ebp),%eax
f010369e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036a1:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01036a4:	eb 03                	jmp    f01036a9 <strncmp+0x12>
		n--, p++, q++;
f01036a6:	4a                   	dec    %edx
f01036a7:	40                   	inc    %eax
f01036a8:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01036a9:	85 d2                	test   %edx,%edx
f01036ab:	74 14                	je     f01036c1 <strncmp+0x2a>
f01036ad:	8a 18                	mov    (%eax),%bl
f01036af:	84 db                	test   %bl,%bl
f01036b1:	74 04                	je     f01036b7 <strncmp+0x20>
f01036b3:	3a 19                	cmp    (%ecx),%bl
f01036b5:	74 ef                	je     f01036a6 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01036b7:	0f b6 00             	movzbl (%eax),%eax
f01036ba:	0f b6 11             	movzbl (%ecx),%edx
f01036bd:	29 d0                	sub    %edx,%eax
f01036bf:	eb 05                	jmp    f01036c6 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01036c1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01036c6:	5b                   	pop    %ebx
f01036c7:	5d                   	pop    %ebp
f01036c8:	c3                   	ret    

f01036c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01036c9:	55                   	push   %ebp
f01036ca:	89 e5                	mov    %esp,%ebp
f01036cc:	8b 45 08             	mov    0x8(%ebp),%eax
f01036cf:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01036d2:	eb 05                	jmp    f01036d9 <strchr+0x10>
		if (*s == c)
f01036d4:	38 ca                	cmp    %cl,%dl
f01036d6:	74 0c                	je     f01036e4 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01036d8:	40                   	inc    %eax
f01036d9:	8a 10                	mov    (%eax),%dl
f01036db:	84 d2                	test   %dl,%dl
f01036dd:	75 f5                	jne    f01036d4 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01036df:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01036e4:	5d                   	pop    %ebp
f01036e5:	c3                   	ret    

f01036e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01036e6:	55                   	push   %ebp
f01036e7:	89 e5                	mov    %esp,%ebp
f01036e9:	8b 45 08             	mov    0x8(%ebp),%eax
f01036ec:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01036ef:	eb 05                	jmp    f01036f6 <strfind+0x10>
		if (*s == c)
f01036f1:	38 ca                	cmp    %cl,%dl
f01036f3:	74 07                	je     f01036fc <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01036f5:	40                   	inc    %eax
f01036f6:	8a 10                	mov    (%eax),%dl
f01036f8:	84 d2                	test   %dl,%dl
f01036fa:	75 f5                	jne    f01036f1 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f01036fc:	5d                   	pop    %ebp
f01036fd:	c3                   	ret    

f01036fe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01036fe:	55                   	push   %ebp
f01036ff:	89 e5                	mov    %esp,%ebp
f0103701:	57                   	push   %edi
f0103702:	56                   	push   %esi
f0103703:	53                   	push   %ebx
f0103704:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103707:	8b 45 0c             	mov    0xc(%ebp),%eax
f010370a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010370d:	85 c9                	test   %ecx,%ecx
f010370f:	74 30                	je     f0103741 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103711:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103717:	75 25                	jne    f010373e <memset+0x40>
f0103719:	f6 c1 03             	test   $0x3,%cl
f010371c:	75 20                	jne    f010373e <memset+0x40>
		c &= 0xFF;
f010371e:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103721:	89 d3                	mov    %edx,%ebx
f0103723:	c1 e3 08             	shl    $0x8,%ebx
f0103726:	89 d6                	mov    %edx,%esi
f0103728:	c1 e6 18             	shl    $0x18,%esi
f010372b:	89 d0                	mov    %edx,%eax
f010372d:	c1 e0 10             	shl    $0x10,%eax
f0103730:	09 f0                	or     %esi,%eax
f0103732:	09 d0                	or     %edx,%eax
f0103734:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0103736:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f0103739:	fc                   	cld    
f010373a:	f3 ab                	rep stos %eax,%es:(%edi)
f010373c:	eb 03                	jmp    f0103741 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f010373e:	fc                   	cld    
f010373f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103741:	89 f8                	mov    %edi,%eax
f0103743:	5b                   	pop    %ebx
f0103744:	5e                   	pop    %esi
f0103745:	5f                   	pop    %edi
f0103746:	5d                   	pop    %ebp
f0103747:	c3                   	ret    

f0103748 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103748:	55                   	push   %ebp
f0103749:	89 e5                	mov    %esp,%ebp
f010374b:	57                   	push   %edi
f010374c:	56                   	push   %esi
f010374d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103750:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103753:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103756:	39 c6                	cmp    %eax,%esi
f0103758:	73 34                	jae    f010378e <memmove+0x46>
f010375a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010375d:	39 d0                	cmp    %edx,%eax
f010375f:	73 2d                	jae    f010378e <memmove+0x46>
		s += n;
		d += n;
f0103761:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103764:	f6 c2 03             	test   $0x3,%dl
f0103767:	75 1b                	jne    f0103784 <memmove+0x3c>
f0103769:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010376f:	75 13                	jne    f0103784 <memmove+0x3c>
f0103771:	f6 c1 03             	test   $0x3,%cl
f0103774:	75 0e                	jne    f0103784 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0103776:	83 ef 04             	sub    $0x4,%edi
f0103779:	8d 72 fc             	lea    -0x4(%edx),%esi
f010377c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f010377f:	fd                   	std    
f0103780:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103782:	eb 07                	jmp    f010378b <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103784:	4f                   	dec    %edi
f0103785:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0103788:	fd                   	std    
f0103789:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010378b:	fc                   	cld    
f010378c:	eb 20                	jmp    f01037ae <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010378e:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103794:	75 13                	jne    f01037a9 <memmove+0x61>
f0103796:	a8 03                	test   $0x3,%al
f0103798:	75 0f                	jne    f01037a9 <memmove+0x61>
f010379a:	f6 c1 03             	test   $0x3,%cl
f010379d:	75 0a                	jne    f01037a9 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f010379f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01037a2:	89 c7                	mov    %eax,%edi
f01037a4:	fc                   	cld    
f01037a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01037a7:	eb 05                	jmp    f01037ae <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01037a9:	89 c7                	mov    %eax,%edi
f01037ab:	fc                   	cld    
f01037ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01037ae:	5e                   	pop    %esi
f01037af:	5f                   	pop    %edi
f01037b0:	5d                   	pop    %ebp
f01037b1:	c3                   	ret    

f01037b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01037b2:	55                   	push   %ebp
f01037b3:	89 e5                	mov    %esp,%ebp
f01037b5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01037b8:	8b 45 10             	mov    0x10(%ebp),%eax
f01037bb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01037bf:	8b 45 0c             	mov    0xc(%ebp),%eax
f01037c2:	89 44 24 04          	mov    %eax,0x4(%esp)
f01037c6:	8b 45 08             	mov    0x8(%ebp),%eax
f01037c9:	89 04 24             	mov    %eax,(%esp)
f01037cc:	e8 77 ff ff ff       	call   f0103748 <memmove>
}
f01037d1:	c9                   	leave  
f01037d2:	c3                   	ret    

f01037d3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01037d3:	55                   	push   %ebp
f01037d4:	89 e5                	mov    %esp,%ebp
f01037d6:	57                   	push   %edi
f01037d7:	56                   	push   %esi
f01037d8:	53                   	push   %ebx
f01037d9:	8b 7d 08             	mov    0x8(%ebp),%edi
f01037dc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01037df:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01037e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01037e7:	eb 16                	jmp    f01037ff <memcmp+0x2c>
		if (*s1 != *s2)
f01037e9:	8a 04 17             	mov    (%edi,%edx,1),%al
f01037ec:	42                   	inc    %edx
f01037ed:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01037f1:	38 c8                	cmp    %cl,%al
f01037f3:	74 0a                	je     f01037ff <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01037f5:	0f b6 c0             	movzbl %al,%eax
f01037f8:	0f b6 c9             	movzbl %cl,%ecx
f01037fb:	29 c8                	sub    %ecx,%eax
f01037fd:	eb 09                	jmp    f0103808 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01037ff:	39 da                	cmp    %ebx,%edx
f0103801:	75 e6                	jne    f01037e9 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103803:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103808:	5b                   	pop    %ebx
f0103809:	5e                   	pop    %esi
f010380a:	5f                   	pop    %edi
f010380b:	5d                   	pop    %ebp
f010380c:	c3                   	ret    

f010380d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f010380d:	55                   	push   %ebp
f010380e:	89 e5                	mov    %esp,%ebp
f0103810:	8b 45 08             	mov    0x8(%ebp),%eax
f0103813:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0103816:	89 c2                	mov    %eax,%edx
f0103818:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010381b:	eb 05                	jmp    f0103822 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f010381d:	38 08                	cmp    %cl,(%eax)
f010381f:	74 05                	je     f0103826 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103821:	40                   	inc    %eax
f0103822:	39 d0                	cmp    %edx,%eax
f0103824:	72 f7                	jb     f010381d <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103826:	5d                   	pop    %ebp
f0103827:	c3                   	ret    

f0103828 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103828:	55                   	push   %ebp
f0103829:	89 e5                	mov    %esp,%ebp
f010382b:	57                   	push   %edi
f010382c:	56                   	push   %esi
f010382d:	53                   	push   %ebx
f010382e:	8b 55 08             	mov    0x8(%ebp),%edx
f0103831:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103834:	eb 01                	jmp    f0103837 <strtol+0xf>
		s++;
f0103836:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103837:	8a 02                	mov    (%edx),%al
f0103839:	3c 20                	cmp    $0x20,%al
f010383b:	74 f9                	je     f0103836 <strtol+0xe>
f010383d:	3c 09                	cmp    $0x9,%al
f010383f:	74 f5                	je     f0103836 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103841:	3c 2b                	cmp    $0x2b,%al
f0103843:	75 08                	jne    f010384d <strtol+0x25>
		s++;
f0103845:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0103846:	bf 00 00 00 00       	mov    $0x0,%edi
f010384b:	eb 13                	jmp    f0103860 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f010384d:	3c 2d                	cmp    $0x2d,%al
f010384f:	75 0a                	jne    f010385b <strtol+0x33>
		s++, neg = 1;
f0103851:	8d 52 01             	lea    0x1(%edx),%edx
f0103854:	bf 01 00 00 00       	mov    $0x1,%edi
f0103859:	eb 05                	jmp    f0103860 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010385b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103860:	85 db                	test   %ebx,%ebx
f0103862:	74 05                	je     f0103869 <strtol+0x41>
f0103864:	83 fb 10             	cmp    $0x10,%ebx
f0103867:	75 28                	jne    f0103891 <strtol+0x69>
f0103869:	8a 02                	mov    (%edx),%al
f010386b:	3c 30                	cmp    $0x30,%al
f010386d:	75 10                	jne    f010387f <strtol+0x57>
f010386f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103873:	75 0a                	jne    f010387f <strtol+0x57>
		s += 2, base = 16;
f0103875:	83 c2 02             	add    $0x2,%edx
f0103878:	bb 10 00 00 00       	mov    $0x10,%ebx
f010387d:	eb 12                	jmp    f0103891 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f010387f:	85 db                	test   %ebx,%ebx
f0103881:	75 0e                	jne    f0103891 <strtol+0x69>
f0103883:	3c 30                	cmp    $0x30,%al
f0103885:	75 05                	jne    f010388c <strtol+0x64>
		s++, base = 8;
f0103887:	42                   	inc    %edx
f0103888:	b3 08                	mov    $0x8,%bl
f010388a:	eb 05                	jmp    f0103891 <strtol+0x69>
	else if (base == 0)
		base = 10;
f010388c:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103891:	b8 00 00 00 00       	mov    $0x0,%eax
f0103896:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0103898:	8a 0a                	mov    (%edx),%cl
f010389a:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f010389d:	80 fb 09             	cmp    $0x9,%bl
f01038a0:	77 08                	ja     f01038aa <strtol+0x82>
			dig = *s - '0';
f01038a2:	0f be c9             	movsbl %cl,%ecx
f01038a5:	83 e9 30             	sub    $0x30,%ecx
f01038a8:	eb 1e                	jmp    f01038c8 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01038aa:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01038ad:	80 fb 19             	cmp    $0x19,%bl
f01038b0:	77 08                	ja     f01038ba <strtol+0x92>
			dig = *s - 'a' + 10;
f01038b2:	0f be c9             	movsbl %cl,%ecx
f01038b5:	83 e9 57             	sub    $0x57,%ecx
f01038b8:	eb 0e                	jmp    f01038c8 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01038ba:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01038bd:	80 fb 19             	cmp    $0x19,%bl
f01038c0:	77 12                	ja     f01038d4 <strtol+0xac>
			dig = *s - 'A' + 10;
f01038c2:	0f be c9             	movsbl %cl,%ecx
f01038c5:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01038c8:	39 f1                	cmp    %esi,%ecx
f01038ca:	7d 0c                	jge    f01038d8 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01038cc:	42                   	inc    %edx
f01038cd:	0f af c6             	imul   %esi,%eax
f01038d0:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01038d2:	eb c4                	jmp    f0103898 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01038d4:	89 c1                	mov    %eax,%ecx
f01038d6:	eb 02                	jmp    f01038da <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01038d8:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01038da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01038de:	74 05                	je     f01038e5 <strtol+0xbd>
		*endptr = (char *) s;
f01038e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01038e3:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01038e5:	85 ff                	test   %edi,%edi
f01038e7:	74 04                	je     f01038ed <strtol+0xc5>
f01038e9:	89 c8                	mov    %ecx,%eax
f01038eb:	f7 d8                	neg    %eax
}
f01038ed:	5b                   	pop    %ebx
f01038ee:	5e                   	pop    %esi
f01038ef:	5f                   	pop    %edi
f01038f0:	5d                   	pop    %ebp
f01038f1:	c3                   	ret    
	...

f01038f4 <__udivdi3>:
f01038f4:	55                   	push   %ebp
f01038f5:	57                   	push   %edi
f01038f6:	56                   	push   %esi
f01038f7:	83 ec 10             	sub    $0x10,%esp
f01038fa:	8b 74 24 20          	mov    0x20(%esp),%esi
f01038fe:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103902:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103906:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010390a:	89 cd                	mov    %ecx,%ebp
f010390c:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0103910:	85 c0                	test   %eax,%eax
f0103912:	75 2c                	jne    f0103940 <__udivdi3+0x4c>
f0103914:	39 f9                	cmp    %edi,%ecx
f0103916:	77 68                	ja     f0103980 <__udivdi3+0x8c>
f0103918:	85 c9                	test   %ecx,%ecx
f010391a:	75 0b                	jne    f0103927 <__udivdi3+0x33>
f010391c:	b8 01 00 00 00       	mov    $0x1,%eax
f0103921:	31 d2                	xor    %edx,%edx
f0103923:	f7 f1                	div    %ecx
f0103925:	89 c1                	mov    %eax,%ecx
f0103927:	31 d2                	xor    %edx,%edx
f0103929:	89 f8                	mov    %edi,%eax
f010392b:	f7 f1                	div    %ecx
f010392d:	89 c7                	mov    %eax,%edi
f010392f:	89 f0                	mov    %esi,%eax
f0103931:	f7 f1                	div    %ecx
f0103933:	89 c6                	mov    %eax,%esi
f0103935:	89 f0                	mov    %esi,%eax
f0103937:	89 fa                	mov    %edi,%edx
f0103939:	83 c4 10             	add    $0x10,%esp
f010393c:	5e                   	pop    %esi
f010393d:	5f                   	pop    %edi
f010393e:	5d                   	pop    %ebp
f010393f:	c3                   	ret    
f0103940:	39 f8                	cmp    %edi,%eax
f0103942:	77 2c                	ja     f0103970 <__udivdi3+0x7c>
f0103944:	0f bd f0             	bsr    %eax,%esi
f0103947:	83 f6 1f             	xor    $0x1f,%esi
f010394a:	75 4c                	jne    f0103998 <__udivdi3+0xa4>
f010394c:	39 f8                	cmp    %edi,%eax
f010394e:	bf 00 00 00 00       	mov    $0x0,%edi
f0103953:	72 0a                	jb     f010395f <__udivdi3+0x6b>
f0103955:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0103959:	0f 87 ad 00 00 00    	ja     f0103a0c <__udivdi3+0x118>
f010395f:	be 01 00 00 00       	mov    $0x1,%esi
f0103964:	89 f0                	mov    %esi,%eax
f0103966:	89 fa                	mov    %edi,%edx
f0103968:	83 c4 10             	add    $0x10,%esp
f010396b:	5e                   	pop    %esi
f010396c:	5f                   	pop    %edi
f010396d:	5d                   	pop    %ebp
f010396e:	c3                   	ret    
f010396f:	90                   	nop
f0103970:	31 ff                	xor    %edi,%edi
f0103972:	31 f6                	xor    %esi,%esi
f0103974:	89 f0                	mov    %esi,%eax
f0103976:	89 fa                	mov    %edi,%edx
f0103978:	83 c4 10             	add    $0x10,%esp
f010397b:	5e                   	pop    %esi
f010397c:	5f                   	pop    %edi
f010397d:	5d                   	pop    %ebp
f010397e:	c3                   	ret    
f010397f:	90                   	nop
f0103980:	89 fa                	mov    %edi,%edx
f0103982:	89 f0                	mov    %esi,%eax
f0103984:	f7 f1                	div    %ecx
f0103986:	89 c6                	mov    %eax,%esi
f0103988:	31 ff                	xor    %edi,%edi
f010398a:	89 f0                	mov    %esi,%eax
f010398c:	89 fa                	mov    %edi,%edx
f010398e:	83 c4 10             	add    $0x10,%esp
f0103991:	5e                   	pop    %esi
f0103992:	5f                   	pop    %edi
f0103993:	5d                   	pop    %ebp
f0103994:	c3                   	ret    
f0103995:	8d 76 00             	lea    0x0(%esi),%esi
f0103998:	89 f1                	mov    %esi,%ecx
f010399a:	d3 e0                	shl    %cl,%eax
f010399c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01039a0:	b8 20 00 00 00       	mov    $0x20,%eax
f01039a5:	29 f0                	sub    %esi,%eax
f01039a7:	89 ea                	mov    %ebp,%edx
f01039a9:	88 c1                	mov    %al,%cl
f01039ab:	d3 ea                	shr    %cl,%edx
f01039ad:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f01039b1:	09 ca                	or     %ecx,%edx
f01039b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01039b7:	89 f1                	mov    %esi,%ecx
f01039b9:	d3 e5                	shl    %cl,%ebp
f01039bb:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f01039bf:	89 fd                	mov    %edi,%ebp
f01039c1:	88 c1                	mov    %al,%cl
f01039c3:	d3 ed                	shr    %cl,%ebp
f01039c5:	89 fa                	mov    %edi,%edx
f01039c7:	89 f1                	mov    %esi,%ecx
f01039c9:	d3 e2                	shl    %cl,%edx
f01039cb:	8b 7c 24 04          	mov    0x4(%esp),%edi
f01039cf:	88 c1                	mov    %al,%cl
f01039d1:	d3 ef                	shr    %cl,%edi
f01039d3:	09 d7                	or     %edx,%edi
f01039d5:	89 f8                	mov    %edi,%eax
f01039d7:	89 ea                	mov    %ebp,%edx
f01039d9:	f7 74 24 08          	divl   0x8(%esp)
f01039dd:	89 d1                	mov    %edx,%ecx
f01039df:	89 c7                	mov    %eax,%edi
f01039e1:	f7 64 24 0c          	mull   0xc(%esp)
f01039e5:	39 d1                	cmp    %edx,%ecx
f01039e7:	72 17                	jb     f0103a00 <__udivdi3+0x10c>
f01039e9:	74 09                	je     f01039f4 <__udivdi3+0x100>
f01039eb:	89 fe                	mov    %edi,%esi
f01039ed:	31 ff                	xor    %edi,%edi
f01039ef:	e9 41 ff ff ff       	jmp    f0103935 <__udivdi3+0x41>
f01039f4:	8b 54 24 04          	mov    0x4(%esp),%edx
f01039f8:	89 f1                	mov    %esi,%ecx
f01039fa:	d3 e2                	shl    %cl,%edx
f01039fc:	39 c2                	cmp    %eax,%edx
f01039fe:	73 eb                	jae    f01039eb <__udivdi3+0xf7>
f0103a00:	8d 77 ff             	lea    -0x1(%edi),%esi
f0103a03:	31 ff                	xor    %edi,%edi
f0103a05:	e9 2b ff ff ff       	jmp    f0103935 <__udivdi3+0x41>
f0103a0a:	66 90                	xchg   %ax,%ax
f0103a0c:	31 f6                	xor    %esi,%esi
f0103a0e:	e9 22 ff ff ff       	jmp    f0103935 <__udivdi3+0x41>
	...

f0103a14 <__umoddi3>:
f0103a14:	55                   	push   %ebp
f0103a15:	57                   	push   %edi
f0103a16:	56                   	push   %esi
f0103a17:	83 ec 20             	sub    $0x20,%esp
f0103a1a:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103a1e:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0103a22:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103a26:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103a2a:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103a2e:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103a32:	89 c7                	mov    %eax,%edi
f0103a34:	89 f2                	mov    %esi,%edx
f0103a36:	85 ed                	test   %ebp,%ebp
f0103a38:	75 16                	jne    f0103a50 <__umoddi3+0x3c>
f0103a3a:	39 f1                	cmp    %esi,%ecx
f0103a3c:	0f 86 a6 00 00 00    	jbe    f0103ae8 <__umoddi3+0xd4>
f0103a42:	f7 f1                	div    %ecx
f0103a44:	89 d0                	mov    %edx,%eax
f0103a46:	31 d2                	xor    %edx,%edx
f0103a48:	83 c4 20             	add    $0x20,%esp
f0103a4b:	5e                   	pop    %esi
f0103a4c:	5f                   	pop    %edi
f0103a4d:	5d                   	pop    %ebp
f0103a4e:	c3                   	ret    
f0103a4f:	90                   	nop
f0103a50:	39 f5                	cmp    %esi,%ebp
f0103a52:	0f 87 ac 00 00 00    	ja     f0103b04 <__umoddi3+0xf0>
f0103a58:	0f bd c5             	bsr    %ebp,%eax
f0103a5b:	83 f0 1f             	xor    $0x1f,%eax
f0103a5e:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103a62:	0f 84 a8 00 00 00    	je     f0103b10 <__umoddi3+0xfc>
f0103a68:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103a6c:	d3 e5                	shl    %cl,%ebp
f0103a6e:	bf 20 00 00 00       	mov    $0x20,%edi
f0103a73:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0103a77:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103a7b:	89 f9                	mov    %edi,%ecx
f0103a7d:	d3 e8                	shr    %cl,%eax
f0103a7f:	09 e8                	or     %ebp,%eax
f0103a81:	89 44 24 18          	mov    %eax,0x18(%esp)
f0103a85:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103a89:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103a8d:	d3 e0                	shl    %cl,%eax
f0103a8f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a93:	89 f2                	mov    %esi,%edx
f0103a95:	d3 e2                	shl    %cl,%edx
f0103a97:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103a9b:	d3 e0                	shl    %cl,%eax
f0103a9d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0103aa1:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103aa5:	89 f9                	mov    %edi,%ecx
f0103aa7:	d3 e8                	shr    %cl,%eax
f0103aa9:	09 d0                	or     %edx,%eax
f0103aab:	d3 ee                	shr    %cl,%esi
f0103aad:	89 f2                	mov    %esi,%edx
f0103aaf:	f7 74 24 18          	divl   0x18(%esp)
f0103ab3:	89 d6                	mov    %edx,%esi
f0103ab5:	f7 64 24 0c          	mull   0xc(%esp)
f0103ab9:	89 c5                	mov    %eax,%ebp
f0103abb:	89 d1                	mov    %edx,%ecx
f0103abd:	39 d6                	cmp    %edx,%esi
f0103abf:	72 67                	jb     f0103b28 <__umoddi3+0x114>
f0103ac1:	74 75                	je     f0103b38 <__umoddi3+0x124>
f0103ac3:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0103ac7:	29 e8                	sub    %ebp,%eax
f0103ac9:	19 ce                	sbb    %ecx,%esi
f0103acb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103acf:	d3 e8                	shr    %cl,%eax
f0103ad1:	89 f2                	mov    %esi,%edx
f0103ad3:	89 f9                	mov    %edi,%ecx
f0103ad5:	d3 e2                	shl    %cl,%edx
f0103ad7:	09 d0                	or     %edx,%eax
f0103ad9:	89 f2                	mov    %esi,%edx
f0103adb:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103adf:	d3 ea                	shr    %cl,%edx
f0103ae1:	83 c4 20             	add    $0x20,%esp
f0103ae4:	5e                   	pop    %esi
f0103ae5:	5f                   	pop    %edi
f0103ae6:	5d                   	pop    %ebp
f0103ae7:	c3                   	ret    
f0103ae8:	85 c9                	test   %ecx,%ecx
f0103aea:	75 0b                	jne    f0103af7 <__umoddi3+0xe3>
f0103aec:	b8 01 00 00 00       	mov    $0x1,%eax
f0103af1:	31 d2                	xor    %edx,%edx
f0103af3:	f7 f1                	div    %ecx
f0103af5:	89 c1                	mov    %eax,%ecx
f0103af7:	89 f0                	mov    %esi,%eax
f0103af9:	31 d2                	xor    %edx,%edx
f0103afb:	f7 f1                	div    %ecx
f0103afd:	89 f8                	mov    %edi,%eax
f0103aff:	e9 3e ff ff ff       	jmp    f0103a42 <__umoddi3+0x2e>
f0103b04:	89 f2                	mov    %esi,%edx
f0103b06:	83 c4 20             	add    $0x20,%esp
f0103b09:	5e                   	pop    %esi
f0103b0a:	5f                   	pop    %edi
f0103b0b:	5d                   	pop    %ebp
f0103b0c:	c3                   	ret    
f0103b0d:	8d 76 00             	lea    0x0(%esi),%esi
f0103b10:	39 f5                	cmp    %esi,%ebp
f0103b12:	72 04                	jb     f0103b18 <__umoddi3+0x104>
f0103b14:	39 f9                	cmp    %edi,%ecx
f0103b16:	77 06                	ja     f0103b1e <__umoddi3+0x10a>
f0103b18:	89 f2                	mov    %esi,%edx
f0103b1a:	29 cf                	sub    %ecx,%edi
f0103b1c:	19 ea                	sbb    %ebp,%edx
f0103b1e:	89 f8                	mov    %edi,%eax
f0103b20:	83 c4 20             	add    $0x20,%esp
f0103b23:	5e                   	pop    %esi
f0103b24:	5f                   	pop    %edi
f0103b25:	5d                   	pop    %ebp
f0103b26:	c3                   	ret    
f0103b27:	90                   	nop
f0103b28:	89 d1                	mov    %edx,%ecx
f0103b2a:	89 c5                	mov    %eax,%ebp
f0103b2c:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0103b30:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0103b34:	eb 8d                	jmp    f0103ac3 <__umoddi3+0xaf>
f0103b36:	66 90                	xchg   %ax,%ax
f0103b38:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0103b3c:	72 ea                	jb     f0103b28 <__umoddi3+0x114>
f0103b3e:	89 f1                	mov    %esi,%ecx
f0103b40:	eb 81                	jmp    f0103ac3 <__umoddi3+0xaf>
