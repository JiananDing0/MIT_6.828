
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
f0100063:	e8 1a 37 00 00       	call   f0103782 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 70 04 00 00       	call   f01004dd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 e0 3b 10 f0 	movl   $0xf0103be0,(%esp)
f010007c:	e8 5d 2c 00 00       	call   f0102cde <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 d1 10 00 00       	call   f0101157 <mem_init>

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
f01000c1:	c7 04 24 fb 3b 10 f0 	movl   $0xf0103bfb,(%esp)
f01000c8:	e8 11 2c 00 00       	call   f0102cde <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 d2 2b 00 00       	call   f0102cab <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 84 4b 10 f0 	movl   $0xf0104b84,(%esp)
f01000e0:	e8 f9 2b 00 00       	call   f0102cde <cprintf>
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
f010010b:	c7 04 24 13 3c 10 f0 	movl   $0xf0103c13,(%esp)
f0100112:	e8 c7 2b 00 00       	call   f0102cde <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 85 2b 00 00       	call   f0102cab <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 84 4b 10 f0 	movl   $0xf0104b84,(%esp)
f010012d:	e8 ac 2b 00 00       	call   f0102cde <cprintf>
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
f0100307:	e8 c0 34 00 00       	call   f01037cc <memmove>
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
f01003ae:	8a 82 60 3c 10 f0    	mov    -0xfefc3a0(%edx),%al
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
f01003ea:	0f b6 82 60 3c 10 f0 	movzbl -0xfefc3a0(%edx),%eax
f01003f1:	0b 05 28 f5 11 f0    	or     0xf011f528,%eax
	shift ^= togglecode[data];
f01003f7:	0f b6 8a 60 3d 10 f0 	movzbl -0xfefc2a0(%edx),%ecx
f01003fe:	31 c8                	xor    %ecx,%eax
f0100400:	a3 28 f5 11 f0       	mov    %eax,0xf011f528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100405:	89 c1                	mov    %eax,%ecx
f0100407:	83 e1 03             	and    $0x3,%ecx
f010040a:	8b 0c 8d 60 3e 10 f0 	mov    -0xfefc1a0(,%ecx,4),%ecx
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
f010043f:	c7 04 24 2d 3c 10 f0 	movl   $0xf0103c2d,(%esp)
f0100446:	e8 93 28 00 00       	call   f0102cde <cprintf>
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
f01005a4:	c7 04 24 39 3c 10 f0 	movl   $0xf0103c39,(%esp)
f01005ab:	e8 2e 27 00 00       	call   f0102cde <cprintf>
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
f01005ea:	c7 04 24 70 3e 10 f0 	movl   $0xf0103e70,(%esp)
f01005f1:	e8 e8 26 00 00       	call   f0102cde <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005f6:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01005fd:	00 
f01005fe:	c7 04 24 28 3f 10 f0 	movl   $0xf0103f28,(%esp)
f0100605:	e8 d4 26 00 00       	call   f0102cde <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010060a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100611:	00 
f0100612:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100619:	f0 
f010061a:	c7 04 24 50 3f 10 f0 	movl   $0xf0103f50,(%esp)
f0100621:	e8 b8 26 00 00       	call   f0102cde <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100626:	c7 44 24 08 c6 3b 10 	movl   $0x103bc6,0x8(%esp)
f010062d:	00 
f010062e:	c7 44 24 04 c6 3b 10 	movl   $0xf0103bc6,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 74 3f 10 f0 	movl   $0xf0103f74,(%esp)
f010063d:	e8 9c 26 00 00       	call   f0102cde <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100642:	c7 44 24 08 00 f3 11 	movl   $0x11f300,0x8(%esp)
f0100649:	00 
f010064a:	c7 44 24 04 00 f3 11 	movl   $0xf011f300,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 98 3f 10 f0 	movl   $0xf0103f98,(%esp)
f0100659:	e8 80 26 00 00       	call   f0102cde <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010065e:	c7 44 24 08 60 f9 11 	movl   $0x11f960,0x8(%esp)
f0100665:	00 
f0100666:	c7 44 24 04 60 f9 11 	movl   $0xf011f960,0x4(%esp)
f010066d:	f0 
f010066e:	c7 04 24 bc 3f 10 f0 	movl   $0xf0103fbc,(%esp)
f0100675:	e8 64 26 00 00       	call   f0102cde <cprintf>
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
f010069c:	c7 04 24 e0 3f 10 f0 	movl   $0xf0103fe0,(%esp)
f01006a3:	e8 36 26 00 00       	call   f0102cde <cprintf>
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
f01006bb:	8b 83 e4 40 10 f0    	mov    -0xfefbf1c(%ebx),%eax
f01006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006c5:	8b 83 e0 40 10 f0    	mov    -0xfefbf20(%ebx),%eax
f01006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006cf:	c7 04 24 89 3e 10 f0 	movl   $0xf0103e89,(%esp)
f01006d6:	e8 03 26 00 00       	call   f0102cde <cprintf>
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
f01006f9:	c7 04 24 92 3e 10 f0 	movl   $0xf0103e92,(%esp)
f0100700:	e8 d9 25 00 00       	call   f0102cde <cprintf>
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
f0100732:	e8 a1 26 00 00       	call   f0102dd8 <debuginfo_eip>
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
f010075f:	c7 04 24 0c 40 10 f0 	movl   $0xf010400c,(%esp)
f0100766:	e8 73 25 00 00       	call   f0102cde <cprintf>
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
f010078e:	c7 04 24 a4 3e 10 f0 	movl   $0xf0103ea4,(%esp)
f0100795:	e8 44 25 00 00       	call   f0102cde <cprintf>
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
f01007ba:	c7 04 24 40 40 10 f0 	movl   $0xf0104040,(%esp)
f01007c1:	e8 18 25 00 00       	call   f0102cde <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007c6:	c7 04 24 64 40 10 f0 	movl   $0xf0104064,(%esp)
f01007cd:	e8 0c 25 00 00       	call   f0102cde <cprintf>


	while (1) {
		buf = readline("K> ");
f01007d2:	c7 04 24 b5 3e 10 f0 	movl   $0xf0103eb5,(%esp)
f01007d9:	e8 7a 2d 00 00       	call   f0103558 <readline>
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
f0100803:	c7 04 24 b9 3e 10 f0 	movl   $0xf0103eb9,(%esp)
f010080a:	e8 3e 2f 00 00       	call   f010374d <strchr>
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
f0100825:	c7 04 24 be 3e 10 f0 	movl   $0xf0103ebe,(%esp)
f010082c:	e8 ad 24 00 00       	call   f0102cde <cprintf>
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
f0100848:	c7 04 24 b9 3e 10 f0 	movl   $0xf0103eb9,(%esp)
f010084f:	e8 f9 2e 00 00       	call   f010374d <strchr>
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
f010086a:	bb e0 40 10 f0       	mov    $0xf01040e0,%ebx
f010086f:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100874:	8b 03                	mov    (%ebx),%eax
f0100876:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010087d:	89 04 24             	mov    %eax,(%esp)
f0100880:	e8 75 2e 00 00       	call   f01036fa <strcmp>
f0100885:	85 c0                	test   %eax,%eax
f0100887:	75 24                	jne    f01008ad <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f0100889:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010088c:	8b 55 08             	mov    0x8(%ebp),%edx
f010088f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100893:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100896:	89 54 24 04          	mov    %edx,0x4(%esp)
f010089a:	89 34 24             	mov    %esi,(%esp)
f010089d:	ff 14 85 e8 40 10 f0 	call   *-0xfefbf18(,%eax,4)


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
f01008bd:	c7 04 24 db 3e 10 f0 	movl   $0xf0103edb,(%esp)
f01008c4:	e8 15 24 00 00       	call   f0102cde <cprintf>
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
f0100900:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0100907:	f0 
f0100908:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f010090f:	00 
f0100910:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100952:	e8 19 23 00 00       	call   f0102c70 <mc146818_read>
f0100957:	89 c6                	mov    %eax,%esi
f0100959:	43                   	inc    %ebx
f010095a:	89 1c 24             	mov    %ebx,(%esp)
f010095d:	e8 0e 23 00 00       	call   f0102c70 <mc146818_read>
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
f01009a3:	c7 44 24 08 28 41 10 	movl   $0xf0104128,0x8(%esp)
f01009aa:	f0 
f01009ab:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01009b2:	00 
f01009b3:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f01009d7:	c7 44 24 08 c4 48 10 	movl   $0xf01048c4,0x8(%esp)
f01009de:	f0 
f01009df:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f01009e6:	00 
f01009e7:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100a11:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0100a18:	f0 
f0100a19:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100a20:	00 
f0100a21:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100a55:	c7 44 24 08 4c 41 10 	movl   $0xf010414c,0x8(%esp)
f0100a5c:	f0 
f0100a5d:	c7 44 24 04 34 02 00 	movl   $0x234,0x4(%esp)
f0100a64:	00 
f0100a65:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100af0:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0100af7:	f0 
f0100af8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100aff:	00 
f0100b00:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f0100b07:	e8 88 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b0c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b13:	00 
f0100b14:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b1b:	00 
	return (void *)(pa + KERNBASE);
f0100b1c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b21:	89 04 24             	mov    %eax,(%esp)
f0100b24:	e8 59 2c 00 00       	call   f0103782 <memset>
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
f0100b6b:	c7 44 24 0c ed 48 10 	movl   $0xf01048ed,0xc(%esp)
f0100b72:	f0 
f0100b73:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100b7a:	f0 
f0100b7b:	c7 44 24 04 4e 02 00 	movl   $0x24e,0x4(%esp)
f0100b82:	00 
f0100b83:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100b8a:	e8 05 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b8f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b92:	72 24                	jb     f0100bb8 <check_page_free_list+0x181>
f0100b94:	c7 44 24 0c 0e 49 10 	movl   $0xf010490e,0xc(%esp)
f0100b9b:	f0 
f0100b9c:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100ba3:	f0 
f0100ba4:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
f0100bab:	00 
f0100bac:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100bb3:	e8 dc f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bb8:	89 d0                	mov    %edx,%eax
f0100bba:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bbd:	a8 07                	test   $0x7,%al
f0100bbf:	74 24                	je     f0100be5 <check_page_free_list+0x1ae>
f0100bc1:	c7 44 24 0c 70 41 10 	movl   $0xf0104170,0xc(%esp)
f0100bc8:	f0 
f0100bc9:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100bd0:	f0 
f0100bd1:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
f0100bd8:	00 
f0100bd9:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100bed:	c7 44 24 0c 22 49 10 	movl   $0xf0104922,0xc(%esp)
f0100bf4:	f0 
f0100bf5:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100bfc:	f0 
f0100bfd:	c7 44 24 04 53 02 00 	movl   $0x253,0x4(%esp)
f0100c04:	00 
f0100c05:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100c0c:	e8 83 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c11:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c16:	75 24                	jne    f0100c3c <check_page_free_list+0x205>
f0100c18:	c7 44 24 0c 33 49 10 	movl   $0xf0104933,0xc(%esp)
f0100c1f:	f0 
f0100c20:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100c27:	f0 
f0100c28:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
f0100c2f:	00 
f0100c30:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100c37:	e8 58 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c3c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c41:	75 24                	jne    f0100c67 <check_page_free_list+0x230>
f0100c43:	c7 44 24 0c a4 41 10 	movl   $0xf01041a4,0xc(%esp)
f0100c4a:	f0 
f0100c4b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100c52:	f0 
f0100c53:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
f0100c5a:	00 
f0100c5b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100c62:	e8 2d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c67:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c6c:	75 24                	jne    f0100c92 <check_page_free_list+0x25b>
f0100c6e:	c7 44 24 0c 4c 49 10 	movl   $0xf010494c,0xc(%esp)
f0100c75:	f0 
f0100c76:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100c7d:	f0 
f0100c7e:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
f0100c85:	00 
f0100c86:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100ca7:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100cb6:	00 
f0100cb7:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f0100cbe:	e8 d1 f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100cc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cc8:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100ccb:	76 27                	jbe    f0100cf4 <check_page_free_list+0x2bd>
f0100ccd:	c7 44 24 0c c8 41 10 	movl   $0xf01041c8,0xc(%esp)
f0100cd4:	f0 
f0100cd5:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100cdc:	f0 
f0100cdd:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
f0100ce4:	00 
f0100ce5:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100d03:	c7 44 24 0c 66 49 10 	movl   $0xf0104966,0xc(%esp)
f0100d0a:	f0 
f0100d0b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100d12:	f0 
f0100d13:	c7 44 24 04 5f 02 00 	movl   $0x25f,0x4(%esp)
f0100d1a:	00 
f0100d1b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100d22:	e8 6d f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100d27:	85 db                	test   %ebx,%ebx
f0100d29:	7f 24                	jg     f0100d4f <check_page_free_list+0x318>
f0100d2b:	c7 44 24 0c 78 49 10 	movl   $0xf0104978,0xc(%esp)
f0100d32:	f0 
f0100d33:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0100d3a:	f0 
f0100d3b:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
f0100d42:	00 
f0100d43:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100d4a:	e8 45 f3 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d4f:	c7 04 24 10 42 10 f0 	movl   $0xf0104210,(%esp)
f0100d56:	e8 83 1f 00 00       	call   f0102cde <cprintf>
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
f0100d81:	c7 44 24 08 28 41 10 	movl   $0xf0104128,0x8(%esp)
f0100d88:	f0 
f0100d89:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
f0100d90:	00 
f0100d91:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100e4d:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0100e54:	f0 
f0100e55:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e5c:	00 
f0100e5d:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
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
f0100e81:	e8 fc 28 00 00       	call   f0103782 <memset>
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
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100e97:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100e9c:	75 05                	jne    f0100ea3 <page_free+0x15>
f0100e9e:	83 38 00             	cmpl   $0x0,(%eax)
f0100ea1:	74 1c                	je     f0100ebf <page_free+0x31>
		panic("page_free: reference bit is nonzero or link is not NULL!");
f0100ea3:	c7 44 24 08 34 42 10 	movl   $0xf0104234,0x8(%esp)
f0100eaa:	f0 
f0100eab:	c7 44 24 04 43 01 00 	movl   $0x143,0x4(%esp)
f0100eb2:	00 
f0100eb3:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
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
f0100ef1:	53                   	push   %ebx
f0100ef2:	83 ec 14             	sub    $0x14,%esp
	// First extract the content stored in the page directory, 
	// it should be a physical address with some PTE information.
	pte_t * entry;
	// If the content is not null, convert it into virtual 
	// address and return
	if (pgdir[PDX(va)]) {
f0100ef5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100ef8:	c1 eb 16             	shr    $0x16,%ebx
f0100efb:	c1 e3 02             	shl    $0x2,%ebx
f0100efe:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f01:	8b 03                	mov    (%ebx),%eax
f0100f03:	85 c0                	test   %eax,%eax
f0100f05:	74 3c                	je     f0100f43 <pgdir_walk+0x55>
		entry = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]) | PTE_U);
f0100f07:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100f0c:	83 c8 04             	or     $0x4,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f0f:	89 c2                	mov    %eax,%edx
f0100f11:	c1 ea 0c             	shr    $0xc,%edx
f0100f14:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0100f1a:	72 20                	jb     f0100f3c <pgdir_walk+0x4e>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f20:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0100f27:	f0 
f0100f28:	c7 44 24 04 76 01 00 	movl   $0x176,0x4(%esp)
f0100f2f:	00 
f0100f30:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100f37:	e8 58 f1 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100f3c:	2d 00 00 00 10       	sub    $0x10000000,%eax
		return entry;
f0100f41:	eb 6b                	jmp    f0100fae <pgdir_walk+0xc0>
	}
	// Otherwise, intialize a new page if permitted
	if (create) {
f0100f43:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f47:	74 59                	je     f0100fa2 <pgdir_walk+0xb4>
		newPage = page_alloc(1);
f0100f49:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0100f50:	e8 b5 fe ff ff       	call   f0100e0a <page_alloc>
		if (newPage) {
f0100f55:	85 c0                	test   %eax,%eax
f0100f57:	74 50                	je     f0100fa9 <pgdir_walk+0xbb>
			newPage->pp_ref++;
f0100f59:	66 ff 40 04          	incw   0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f5d:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0100f63:	c1 f8 03             	sar    $0x3,%eax
			// Store correct information
			pgdir[PDX(va)] = PTE_ADDR(page2pa(newPage));
f0100f66:	c1 e0 0c             	shl    $0xc,%eax
f0100f69:	89 03                	mov    %eax,(%ebx)
			// Convert to virtual address and return
			entry = (pte_t *)KADDR(PTE_ADDR(pgdir[PDX(va)]) | PTE_U);
f0100f6b:	83 c8 04             	or     $0x4,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f6e:	89 c2                	mov    %eax,%edx
f0100f70:	c1 ea 0c             	shr    $0xc,%edx
f0100f73:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0100f79:	72 20                	jb     f0100f9b <pgdir_walk+0xad>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100f7f:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0100f86:	f0 
f0100f87:	c7 44 24 04 81 01 00 	movl   $0x181,0x4(%esp)
f0100f8e:	00 
f0100f8f:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0100f96:	e8 f9 f0 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100f9b:	2d 00 00 00 10       	sub    $0x10000000,%eax
			return entry;
f0100fa0:	eb 0c                	jmp    f0100fae <pgdir_walk+0xc0>
		}
	}
	return NULL;
f0100fa2:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fa7:	eb 05                	jmp    f0100fae <pgdir_walk+0xc0>
f0100fa9:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100fae:	83 c4 14             	add    $0x14,%esp
f0100fb1:	5b                   	pop    %ebx
f0100fb2:	5d                   	pop    %ebp
f0100fb3:	c3                   	ret    

f0100fb4 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100fb4:	55                   	push   %ebp
f0100fb5:	89 e5                	mov    %esp,%ebp
f0100fb7:	56                   	push   %esi
f0100fb8:	53                   	push   %ebx
f0100fb9:	83 ec 10             	sub    $0x10,%esp
f0100fbc:	8b 75 0c             	mov    0xc(%ebp),%esi
f0100fbf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	physaddr_t physAddr;
	pte_t *entry = (pte_t *)PTE_ADDR(pgdir_walk(pgdir, va, false));
f0100fc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0100fc9:	00 
f0100fca:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100fce:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fd1:	89 04 24             	mov    %eax,(%esp)
f0100fd4:	e8 15 ff ff ff       	call   f0100eee <pgdir_walk>
	if (entry) {
f0100fd9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100fde:	74 44                	je     f0101024 <page_lookup+0x70>
		if (pte_store) {
f0100fe0:	85 db                	test   %ebx,%ebx
f0100fe2:	74 02                	je     f0100fe6 <page_lookup+0x32>
		 	*pte_store = entry;
f0100fe4:	89 03                	mov    %eax,(%ebx)
		}
		physAddr = (physaddr_t)(PTE_ADDR(entry[PTX(va)]) | PGOFF(va));
f0100fe6:	c1 ee 0c             	shr    $0xc,%esi
f0100fe9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100fef:	8b 04 b0             	mov    (%eax,%esi,4),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ff2:	c1 e8 0c             	shr    $0xc,%eax
f0100ff5:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f0100ffb:	72 1c                	jb     f0101019 <page_lookup+0x65>
		panic("pa2page called with invalid pa");
f0100ffd:	c7 44 24 08 70 42 10 	movl   $0xf0104270,0x8(%esp)
f0101004:	f0 
f0101005:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f010100c:	00 
f010100d:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f0101014:	e8 7b f0 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101019:	c1 e0 03             	shl    $0x3,%eax
f010101c:	03 05 70 f9 11 f0    	add    0xf011f970,%eax
		return pa2page(physAddr);
f0101022:	eb 05                	jmp    f0101029 <page_lookup+0x75>
	}
	return NULL;
f0101024:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101029:	83 c4 10             	add    $0x10,%esp
f010102c:	5b                   	pop    %ebx
f010102d:	5e                   	pop    %esi
f010102e:	5d                   	pop    %ebp
f010102f:	c3                   	ret    

f0101030 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101030:	55                   	push   %ebp
f0101031:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101033:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101036:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101039:	5d                   	pop    %ebp
f010103a:	c3                   	ret    

f010103b <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f010103b:	55                   	push   %ebp
f010103c:	89 e5                	mov    %esp,%ebp
f010103e:	56                   	push   %esi
f010103f:	53                   	push   %ebx
f0101040:	83 ec 20             	sub    $0x20,%esp
f0101043:	8b 75 08             	mov    0x8(%ebp),%esi
f0101046:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// Create a ptep store
	pte_t *entry;
	struct PageInfo *pp = page_lookup(pgdir, va, &entry);
f0101049:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010104c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101050:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101054:	89 34 24             	mov    %esi,(%esp)
f0101057:	e8 58 ff ff ff       	call   f0100fb4 <page_lookup>
	page_decref(pp);
f010105c:	89 04 24             	mov    %eax,(%esp)
f010105f:	e8 6a fe ff ff       	call   f0100ece <page_decref>
	tlb_invalidate(pgdir, va);
f0101064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101068:	89 34 24             	mov    %esi,(%esp)
f010106b:	e8 c0 ff ff ff       	call   f0101030 <tlb_invalidate>
	entry[PTX(va)] = 0;
f0101070:	c1 eb 0c             	shr    $0xc,%ebx
f0101073:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0101079:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010107c:	c7 04 98 00 00 00 00 	movl   $0x0,(%eax,%ebx,4)
}
f0101083:	83 c4 20             	add    $0x20,%esp
f0101086:	5b                   	pop    %ebx
f0101087:	5e                   	pop    %esi
f0101088:	5d                   	pop    %ebp
f0101089:	c3                   	ret    

f010108a <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010108a:	55                   	push   %ebp
f010108b:	89 e5                	mov    %esp,%ebp
f010108d:	57                   	push   %edi
f010108e:	56                   	push   %esi
f010108f:	53                   	push   %ebx
f0101090:	83 ec 1c             	sub    $0x1c,%esp
f0101093:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101096:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	physaddr_t pageAddr;
	struct PageInfo *temp, *tempNext;
	pte_t *ptEntry = (pte_t *)PTE_ADDR(pgdir_walk(pgdir, va, true));
f0101099:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010a0:	00 
f01010a1:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010a5:	8b 45 08             	mov    0x8(%ebp),%eax
f01010a8:	89 04 24             	mov    %eax,(%esp)
f01010ab:	e8 3e fe ff ff       	call   f0100eee <pgdir_walk>
	if (ptEntry) {
f01010b0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01010b5:	0f 84 8f 00 00 00    	je     f010114a <page_insert+0xc0>
		// If there is already a page at va, it should be removed
		if (ptEntry[PTX(va)]) {
f01010bb:	89 fe                	mov    %edi,%esi
f01010bd:	c1 ee 0a             	shr    $0xa,%esi
f01010c0:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f01010c6:	01 c6                	add    %eax,%esi
f01010c8:	83 3e 00             	cmpl   $0x0,(%esi)
f01010cb:	74 0f                	je     f01010dc <page_insert+0x52>
			page_remove(pgdir, va);
f01010cd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01010d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01010d4:	89 04 24             	mov    %eax,(%esp)
f01010d7:	e8 5f ff ff ff       	call   f010103b <page_remove>
		}
		// Allocate the page and change reference bit of the page
		if (pp->pp_ref == 0) {
f01010dc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01010e1:	75 31                	jne    f0101114 <page_insert+0x8a>
			temp = page_free_list;
f01010e3:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
			// Find the page from free list and remove it
			if (temp) {
f01010e9:	85 d2                	test   %edx,%edx
f01010eb:	74 27                	je     f0101114 <page_insert+0x8a>
				// If the first one is the page.
				if (temp == pp) {
f01010ed:	39 da                	cmp    %ebx,%edx
f01010ef:	75 09                	jne    f01010fa <page_insert+0x70>
					page_free_list = pp->pp_link;
f01010f1:	8b 02                	mov    (%edx),%eax
f01010f3:	a3 40 f5 11 f0       	mov    %eax,0xf011f540
f01010f8:	eb 1a                	jmp    f0101114 <page_insert+0x8a>
				}
				// If the page is in the middle of the list
				else {
					tempNext = ((struct PageInfo)(*temp)).pp_link;
f01010fa:	8b 02                	mov    (%edx),%eax
					while (tempNext != NULL) {
f01010fc:	eb 12                	jmp    f0101110 <page_insert+0x86>
						if (tempNext == pp) {
f01010fe:	39 d8                	cmp    %ebx,%eax
f0101100:	75 0a                	jne    f010110c <page_insert+0x82>
							temp->pp_link = tempNext->pp_link;
f0101102:	8b 0b                	mov    (%ebx),%ecx
f0101104:	89 0a                	mov    %ecx,(%edx)
							tempNext->pp_link = NULL;
f0101106:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
						}
						temp = tempNext;
f010110c:	89 c2                	mov    %eax,%edx
						tempNext = ((struct PageInfo)(*temp)).pp_link;
f010110e:	8b 00                	mov    (%eax),%eax
					page_free_list = pp->pp_link;
				}
				// If the page is in the middle of the list
				else {
					tempNext = ((struct PageInfo)(*temp)).pp_link;
					while (tempNext != NULL) {
f0101110:	85 c0                	test   %eax,%eax
f0101112:	75 ea                	jne    f01010fe <page_insert+0x74>
						tempNext = ((struct PageInfo)(*temp)).pp_link;
					}
				}
			}
		}
		pp->pp_ref++;
f0101114:	66 ff 43 04          	incw   0x4(%ebx)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101118:	2b 1d 70 f9 11 f0    	sub    0xf011f970,%ebx
f010111e:	c1 fb 03             	sar    $0x3,%ebx
		pageAddr = page2pa(pp);
		pgdir[PDX(va)] = (PTE_ADDR(pgdir[PDX(va)]) | perm | PTE_P);
f0101121:	c1 ef 16             	shr    $0x16,%edi
f0101124:	8b 45 08             	mov    0x8(%ebp),%eax
f0101127:	8d 14 b8             	lea    (%eax,%edi,4),%edx
f010112a:	8b 45 14             	mov    0x14(%ebp),%eax
f010112d:	83 c8 01             	or     $0x1,%eax
f0101130:	8b 0a                	mov    (%edx),%ecx
f0101132:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101138:	09 c1                	or     %eax,%ecx
f010113a:	89 0a                	mov    %ecx,(%edx)
		ptEntry[PTX(va)] = (PTE_ADDR(pageAddr) | perm | PTE_P);
f010113c:	c1 e3 0c             	shl    $0xc,%ebx
f010113f:	09 d8                	or     %ebx,%eax
f0101141:	89 06                	mov    %eax,(%esi)
		return 0;
f0101143:	b8 00 00 00 00       	mov    $0x0,%eax
f0101148:	eb 05                	jmp    f010114f <page_insert+0xc5>
	}
	return -E_NO_MEM;
f010114a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	
}
f010114f:	83 c4 1c             	add    $0x1c,%esp
f0101152:	5b                   	pop    %ebx
f0101153:	5e                   	pop    %esi
f0101154:	5f                   	pop    %edi
f0101155:	5d                   	pop    %ebp
f0101156:	c3                   	ret    

f0101157 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101157:	55                   	push   %ebp
f0101158:	89 e5                	mov    %esp,%ebp
f010115a:	57                   	push   %edi
f010115b:	56                   	push   %esi
f010115c:	53                   	push   %ebx
f010115d:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101160:	b8 15 00 00 00       	mov    $0x15,%eax
f0101165:	e8 db f7 ff ff       	call   f0100945 <nvram_read>
f010116a:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010116c:	b8 17 00 00 00       	mov    $0x17,%eax
f0101171:	e8 cf f7 ff ff       	call   f0100945 <nvram_read>
f0101176:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101178:	b8 34 00 00 00       	mov    $0x34,%eax
f010117d:	e8 c3 f7 ff ff       	call   f0100945 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101182:	c1 e0 06             	shl    $0x6,%eax
f0101185:	74 08                	je     f010118f <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f0101187:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f010118d:	eb 0e                	jmp    f010119d <mem_init+0x46>
	else if (extmem)
f010118f:	85 f6                	test   %esi,%esi
f0101191:	74 08                	je     f010119b <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0101193:	81 c6 00 04 00 00    	add    $0x400,%esi
f0101199:	eb 02                	jmp    f010119d <mem_init+0x46>
	else
		totalmem = basemem;
f010119b:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f010119d:	89 f0                	mov    %esi,%eax
f010119f:	c1 e8 02             	shr    $0x2,%eax
f01011a2:	a3 68 f9 11 f0       	mov    %eax,0xf011f968
	npages_basemem = basemem / (PGSIZE / 1024);
f01011a7:	89 d8                	mov    %ebx,%eax
f01011a9:	c1 e8 02             	shr    $0x2,%eax
f01011ac:	a3 38 f5 11 f0       	mov    %eax,0xf011f538

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01011b1:	89 f0                	mov    %esi,%eax
f01011b3:	29 d8                	sub    %ebx,%eax
f01011b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011b9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01011bd:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011c1:	c7 04 24 90 42 10 f0 	movl   $0xf0104290,(%esp)
f01011c8:	e8 11 1b 00 00       	call   f0102cde <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011cd:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011d2:	e8 97 f7 ff ff       	call   f010096e <boot_alloc>
f01011d7:	a3 6c f9 11 f0       	mov    %eax,0xf011f96c
	memset(kern_pgdir, 0, PGSIZE);
f01011dc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011e3:	00 
f01011e4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011eb:	00 
f01011ec:	89 04 24             	mov    %eax,(%esp)
f01011ef:	e8 8e 25 00 00       	call   f0103782 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011f4:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011f9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011fe:	77 20                	ja     f0101220 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101200:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101204:	c7 44 24 08 28 41 10 	movl   $0xf0104128,0x8(%esp)
f010120b:	f0 
f010120c:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0101213:	00 
f0101214:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010121b:	e8 74 ee ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101220:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101226:	83 ca 05             	or     $0x5,%edx
f0101229:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f010122f:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101234:	c1 e0 03             	shl    $0x3,%eax
f0101237:	e8 32 f7 ff ff       	call   f010096e <boot_alloc>
f010123c:	a3 70 f9 11 f0       	mov    %eax,0xf011f970
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101241:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f0101247:	c1 e2 03             	shl    $0x3,%edx
f010124a:	89 54 24 08          	mov    %edx,0x8(%esp)
f010124e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0101255:	00 
f0101256:	89 04 24             	mov    %eax,(%esp)
f0101259:	e8 24 25 00 00       	call   f0103782 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010125e:	e8 00 fb ff ff       	call   f0100d63 <page_init>

	check_page_free_list(1);
f0101263:	b8 01 00 00 00       	mov    $0x1,%eax
f0101268:	e8 ca f7 ff ff       	call   f0100a37 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010126d:	83 3d 70 f9 11 f0 00 	cmpl   $0x0,0xf011f970
f0101274:	75 1c                	jne    f0101292 <mem_init+0x13b>
		panic("'pages' is a null pointer!");
f0101276:	c7 44 24 08 89 49 10 	movl   $0xf0104989,0x8(%esp)
f010127d:	f0 
f010127e:	c7 44 24 04 73 02 00 	movl   $0x273,0x4(%esp)
f0101285:	00 
f0101286:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010128d:	e8 02 ee ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101292:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f0101297:	bb 00 00 00 00       	mov    $0x0,%ebx
f010129c:	eb 03                	jmp    f01012a1 <mem_init+0x14a>
		++nfree;
f010129e:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010129f:	8b 00                	mov    (%eax),%eax
f01012a1:	85 c0                	test   %eax,%eax
f01012a3:	75 f9                	jne    f010129e <mem_init+0x147>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01012a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012ac:	e8 59 fb ff ff       	call   f0100e0a <page_alloc>
f01012b1:	89 c6                	mov    %eax,%esi
f01012b3:	85 c0                	test   %eax,%eax
f01012b5:	75 24                	jne    f01012db <mem_init+0x184>
f01012b7:	c7 44 24 0c a4 49 10 	movl   $0xf01049a4,0xc(%esp)
f01012be:	f0 
f01012bf:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01012c6:	f0 
f01012c7:	c7 44 24 04 7b 02 00 	movl   $0x27b,0x4(%esp)
f01012ce:	00 
f01012cf:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01012d6:	e8 b9 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012e2:	e8 23 fb ff ff       	call   f0100e0a <page_alloc>
f01012e7:	89 c7                	mov    %eax,%edi
f01012e9:	85 c0                	test   %eax,%eax
f01012eb:	75 24                	jne    f0101311 <mem_init+0x1ba>
f01012ed:	c7 44 24 0c ba 49 10 	movl   $0xf01049ba,0xc(%esp)
f01012f4:	f0 
f01012f5:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01012fc:	f0 
f01012fd:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f0101304:	00 
f0101305:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010130c:	e8 83 ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101311:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101318:	e8 ed fa ff ff       	call   f0100e0a <page_alloc>
f010131d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101320:	85 c0                	test   %eax,%eax
f0101322:	75 24                	jne    f0101348 <mem_init+0x1f1>
f0101324:	c7 44 24 0c d0 49 10 	movl   $0xf01049d0,0xc(%esp)
f010132b:	f0 
f010132c:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101333:	f0 
f0101334:	c7 44 24 04 7d 02 00 	movl   $0x27d,0x4(%esp)
f010133b:	00 
f010133c:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101343:	e8 4c ed ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101348:	39 fe                	cmp    %edi,%esi
f010134a:	75 24                	jne    f0101370 <mem_init+0x219>
f010134c:	c7 44 24 0c e6 49 10 	movl   $0xf01049e6,0xc(%esp)
f0101353:	f0 
f0101354:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010135b:	f0 
f010135c:	c7 44 24 04 80 02 00 	movl   $0x280,0x4(%esp)
f0101363:	00 
f0101364:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010136b:	e8 24 ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101370:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101373:	74 05                	je     f010137a <mem_init+0x223>
f0101375:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101378:	75 24                	jne    f010139e <mem_init+0x247>
f010137a:	c7 44 24 0c cc 42 10 	movl   $0xf01042cc,0xc(%esp)
f0101381:	f0 
f0101382:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101389:	f0 
f010138a:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
f0101391:	00 
f0101392:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101399:	e8 f6 ec ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010139e:	8b 15 70 f9 11 f0    	mov    0xf011f970,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013a4:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f01013a9:	c1 e0 0c             	shl    $0xc,%eax
f01013ac:	89 f1                	mov    %esi,%ecx
f01013ae:	29 d1                	sub    %edx,%ecx
f01013b0:	c1 f9 03             	sar    $0x3,%ecx
f01013b3:	c1 e1 0c             	shl    $0xc,%ecx
f01013b6:	39 c1                	cmp    %eax,%ecx
f01013b8:	72 24                	jb     f01013de <mem_init+0x287>
f01013ba:	c7 44 24 0c f8 49 10 	movl   $0xf01049f8,0xc(%esp)
f01013c1:	f0 
f01013c2:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01013c9:	f0 
f01013ca:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f01013d1:	00 
f01013d2:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01013d9:	e8 b6 ec ff ff       	call   f0100094 <_panic>
f01013de:	89 f9                	mov    %edi,%ecx
f01013e0:	29 d1                	sub    %edx,%ecx
f01013e2:	c1 f9 03             	sar    $0x3,%ecx
f01013e5:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01013e8:	39 c8                	cmp    %ecx,%eax
f01013ea:	77 24                	ja     f0101410 <mem_init+0x2b9>
f01013ec:	c7 44 24 0c 15 4a 10 	movl   $0xf0104a15,0xc(%esp)
f01013f3:	f0 
f01013f4:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01013fb:	f0 
f01013fc:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
f0101403:	00 
f0101404:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010140b:	e8 84 ec ff ff       	call   f0100094 <_panic>
f0101410:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101413:	29 d1                	sub    %edx,%ecx
f0101415:	89 ca                	mov    %ecx,%edx
f0101417:	c1 fa 03             	sar    $0x3,%edx
f010141a:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f010141d:	39 d0                	cmp    %edx,%eax
f010141f:	77 24                	ja     f0101445 <mem_init+0x2ee>
f0101421:	c7 44 24 0c 32 4a 10 	movl   $0xf0104a32,0xc(%esp)
f0101428:	f0 
f0101429:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101430:	f0 
f0101431:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
f0101438:	00 
f0101439:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101440:	e8 4f ec ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101445:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f010144a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010144d:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f0101454:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101457:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010145e:	e8 a7 f9 ff ff       	call   f0100e0a <page_alloc>
f0101463:	85 c0                	test   %eax,%eax
f0101465:	74 24                	je     f010148b <mem_init+0x334>
f0101467:	c7 44 24 0c 4f 4a 10 	movl   $0xf0104a4f,0xc(%esp)
f010146e:	f0 
f010146f:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101476:	f0 
f0101477:	c7 44 24 04 8b 02 00 	movl   $0x28b,0x4(%esp)
f010147e:	00 
f010147f:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101486:	e8 09 ec ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010148b:	89 34 24             	mov    %esi,(%esp)
f010148e:	e8 fb f9 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f0101493:	89 3c 24             	mov    %edi,(%esp)
f0101496:	e8 f3 f9 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f010149b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010149e:	89 04 24             	mov    %eax,(%esp)
f01014a1:	e8 e8 f9 ff ff       	call   f0100e8e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014ad:	e8 58 f9 ff ff       	call   f0100e0a <page_alloc>
f01014b2:	89 c6                	mov    %eax,%esi
f01014b4:	85 c0                	test   %eax,%eax
f01014b6:	75 24                	jne    f01014dc <mem_init+0x385>
f01014b8:	c7 44 24 0c a4 49 10 	movl   $0xf01049a4,0xc(%esp)
f01014bf:	f0 
f01014c0:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01014c7:	f0 
f01014c8:	c7 44 24 04 92 02 00 	movl   $0x292,0x4(%esp)
f01014cf:	00 
f01014d0:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01014d7:	e8 b8 eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01014dc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014e3:	e8 22 f9 ff ff       	call   f0100e0a <page_alloc>
f01014e8:	89 c7                	mov    %eax,%edi
f01014ea:	85 c0                	test   %eax,%eax
f01014ec:	75 24                	jne    f0101512 <mem_init+0x3bb>
f01014ee:	c7 44 24 0c ba 49 10 	movl   $0xf01049ba,0xc(%esp)
f01014f5:	f0 
f01014f6:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01014fd:	f0 
f01014fe:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f0101505:	00 
f0101506:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010150d:	e8 82 eb ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0101512:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101519:	e8 ec f8 ff ff       	call   f0100e0a <page_alloc>
f010151e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101521:	85 c0                	test   %eax,%eax
f0101523:	75 24                	jne    f0101549 <mem_init+0x3f2>
f0101525:	c7 44 24 0c d0 49 10 	movl   $0xf01049d0,0xc(%esp)
f010152c:	f0 
f010152d:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101534:	f0 
f0101535:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f010153c:	00 
f010153d:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101544:	e8 4b eb ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101549:	39 fe                	cmp    %edi,%esi
f010154b:	75 24                	jne    f0101571 <mem_init+0x41a>
f010154d:	c7 44 24 0c e6 49 10 	movl   $0xf01049e6,0xc(%esp)
f0101554:	f0 
f0101555:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010155c:	f0 
f010155d:	c7 44 24 04 96 02 00 	movl   $0x296,0x4(%esp)
f0101564:	00 
f0101565:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010156c:	e8 23 eb ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101571:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101574:	74 05                	je     f010157b <mem_init+0x424>
f0101576:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101579:	75 24                	jne    f010159f <mem_init+0x448>
f010157b:	c7 44 24 0c cc 42 10 	movl   $0xf01042cc,0xc(%esp)
f0101582:	f0 
f0101583:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010158a:	f0 
f010158b:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0101592:	00 
f0101593:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010159a:	e8 f5 ea ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f010159f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015a6:	e8 5f f8 ff ff       	call   f0100e0a <page_alloc>
f01015ab:	85 c0                	test   %eax,%eax
f01015ad:	74 24                	je     f01015d3 <mem_init+0x47c>
f01015af:	c7 44 24 0c 4f 4a 10 	movl   $0xf0104a4f,0xc(%esp)
f01015b6:	f0 
f01015b7:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01015be:	f0 
f01015bf:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f01015c6:	00 
f01015c7:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01015ce:	e8 c1 ea ff ff       	call   f0100094 <_panic>
f01015d3:	89 f0                	mov    %esi,%eax
f01015d5:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f01015db:	c1 f8 03             	sar    $0x3,%eax
f01015de:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015e1:	89 c2                	mov    %eax,%edx
f01015e3:	c1 ea 0c             	shr    $0xc,%edx
f01015e6:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f01015ec:	72 20                	jb     f010160e <mem_init+0x4b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015f2:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f01015f9:	f0 
f01015fa:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0101601:	00 
f0101602:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f0101609:	e8 86 ea ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f010160e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101615:	00 
f0101616:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f010161d:	00 
	return (void *)(pa + KERNBASE);
f010161e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101623:	89 04 24             	mov    %eax,(%esp)
f0101626:	e8 57 21 00 00       	call   f0103782 <memset>
	page_free(pp0);
f010162b:	89 34 24             	mov    %esi,(%esp)
f010162e:	e8 5b f8 ff ff       	call   f0100e8e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101633:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010163a:	e8 cb f7 ff ff       	call   f0100e0a <page_alloc>
f010163f:	85 c0                	test   %eax,%eax
f0101641:	75 24                	jne    f0101667 <mem_init+0x510>
f0101643:	c7 44 24 0c 5e 4a 10 	movl   $0xf0104a5e,0xc(%esp)
f010164a:	f0 
f010164b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101652:	f0 
f0101653:	c7 44 24 04 9d 02 00 	movl   $0x29d,0x4(%esp)
f010165a:	00 
f010165b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101662:	e8 2d ea ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f0101667:	39 c6                	cmp    %eax,%esi
f0101669:	74 24                	je     f010168f <mem_init+0x538>
f010166b:	c7 44 24 0c 7c 4a 10 	movl   $0xf0104a7c,0xc(%esp)
f0101672:	f0 
f0101673:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010167a:	f0 
f010167b:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f0101682:	00 
f0101683:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010168a:	e8 05 ea ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010168f:	89 f2                	mov    %esi,%edx
f0101691:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101697:	c1 fa 03             	sar    $0x3,%edx
f010169a:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010169d:	89 d0                	mov    %edx,%eax
f010169f:	c1 e8 0c             	shr    $0xc,%eax
f01016a2:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f01016a8:	72 20                	jb     f01016ca <mem_init+0x573>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016aa:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01016ae:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f01016b5:	f0 
f01016b6:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01016bd:	00 
f01016be:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f01016c5:	e8 ca e9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01016ca:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01016d0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016d6:	80 38 00             	cmpb   $0x0,(%eax)
f01016d9:	74 24                	je     f01016ff <mem_init+0x5a8>
f01016db:	c7 44 24 0c 8c 4a 10 	movl   $0xf0104a8c,0xc(%esp)
f01016e2:	f0 
f01016e3:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01016ea:	f0 
f01016eb:	c7 44 24 04 a1 02 00 	movl   $0x2a1,0x4(%esp)
f01016f2:	00 
f01016f3:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01016fa:	e8 95 e9 ff ff       	call   f0100094 <_panic>
f01016ff:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101700:	39 d0                	cmp    %edx,%eax
f0101702:	75 d2                	jne    f01016d6 <mem_init+0x57f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101704:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101707:	89 15 40 f5 11 f0    	mov    %edx,0xf011f540

	// free the pages we took
	page_free(pp0);
f010170d:	89 34 24             	mov    %esi,(%esp)
f0101710:	e8 79 f7 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f0101715:	89 3c 24             	mov    %edi,(%esp)
f0101718:	e8 71 f7 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f010171d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101720:	89 04 24             	mov    %eax,(%esp)
f0101723:	e8 66 f7 ff ff       	call   f0100e8e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101728:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f010172d:	eb 03                	jmp    f0101732 <mem_init+0x5db>
		--nfree;
f010172f:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101730:	8b 00                	mov    (%eax),%eax
f0101732:	85 c0                	test   %eax,%eax
f0101734:	75 f9                	jne    f010172f <mem_init+0x5d8>
		--nfree;
	assert(nfree == 0);
f0101736:	85 db                	test   %ebx,%ebx
f0101738:	74 24                	je     f010175e <mem_init+0x607>
f010173a:	c7 44 24 0c 96 4a 10 	movl   $0xf0104a96,0xc(%esp)
f0101741:	f0 
f0101742:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101749:	f0 
f010174a:	c7 44 24 04 ae 02 00 	movl   $0x2ae,0x4(%esp)
f0101751:	00 
f0101752:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101759:	e8 36 e9 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010175e:	c7 04 24 ec 42 10 f0 	movl   $0xf01042ec,(%esp)
f0101765:	e8 74 15 00 00       	call   f0102cde <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010176a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101771:	e8 94 f6 ff ff       	call   f0100e0a <page_alloc>
f0101776:	89 c7                	mov    %eax,%edi
f0101778:	85 c0                	test   %eax,%eax
f010177a:	75 24                	jne    f01017a0 <mem_init+0x649>
f010177c:	c7 44 24 0c a4 49 10 	movl   $0xf01049a4,0xc(%esp)
f0101783:	f0 
f0101784:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010178b:	f0 
f010178c:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101793:	00 
f0101794:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010179b:	e8 f4 e8 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01017a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017a7:	e8 5e f6 ff ff       	call   f0100e0a <page_alloc>
f01017ac:	89 c6                	mov    %eax,%esi
f01017ae:	85 c0                	test   %eax,%eax
f01017b0:	75 24                	jne    f01017d6 <mem_init+0x67f>
f01017b2:	c7 44 24 0c ba 49 10 	movl   $0xf01049ba,0xc(%esp)
f01017b9:	f0 
f01017ba:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01017c1:	f0 
f01017c2:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01017c9:	00 
f01017ca:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01017d1:	e8 be e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017dd:	e8 28 f6 ff ff       	call   f0100e0a <page_alloc>
f01017e2:	89 c3                	mov    %eax,%ebx
f01017e4:	85 c0                	test   %eax,%eax
f01017e6:	75 24                	jne    f010180c <mem_init+0x6b5>
f01017e8:	c7 44 24 0c d0 49 10 	movl   $0xf01049d0,0xc(%esp)
f01017ef:	f0 
f01017f0:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01017f7:	f0 
f01017f8:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01017ff:	00 
f0101800:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101807:	e8 88 e8 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010180c:	39 f7                	cmp    %esi,%edi
f010180e:	75 24                	jne    f0101834 <mem_init+0x6dd>
f0101810:	c7 44 24 0c e6 49 10 	movl   $0xf01049e6,0xc(%esp)
f0101817:	f0 
f0101818:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010181f:	f0 
f0101820:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f0101827:	00 
f0101828:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010182f:	e8 60 e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101834:	39 c6                	cmp    %eax,%esi
f0101836:	74 04                	je     f010183c <mem_init+0x6e5>
f0101838:	39 c7                	cmp    %eax,%edi
f010183a:	75 24                	jne    f0101860 <mem_init+0x709>
f010183c:	c7 44 24 0c cc 42 10 	movl   $0xf01042cc,0xc(%esp)
f0101843:	f0 
f0101844:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010184b:	f0 
f010184c:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0101853:	00 
f0101854:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010185b:	e8 34 e8 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101860:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f0101866:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f0101869:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f0101870:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101873:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010187a:	e8 8b f5 ff ff       	call   f0100e0a <page_alloc>
f010187f:	85 c0                	test   %eax,%eax
f0101881:	74 24                	je     f01018a7 <mem_init+0x750>
f0101883:	c7 44 24 0c 4f 4a 10 	movl   $0xf0104a4f,0xc(%esp)
f010188a:	f0 
f010188b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101892:	f0 
f0101893:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f010189a:	00 
f010189b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01018a2:	e8 ed e7 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01018a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01018ae:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01018b5:	00 
f01018b6:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01018bb:	89 04 24             	mov    %eax,(%esp)
f01018be:	e8 f1 f6 ff ff       	call   f0100fb4 <page_lookup>
f01018c3:	85 c0                	test   %eax,%eax
f01018c5:	74 24                	je     f01018eb <mem_init+0x794>
f01018c7:	c7 44 24 0c 0c 43 10 	movl   $0xf010430c,0xc(%esp)
f01018ce:	f0 
f01018cf:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01018d6:	f0 
f01018d7:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f01018de:	00 
f01018df:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01018e6:	e8 a9 e7 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018eb:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018f2:	00 
f01018f3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018fa:	00 
f01018fb:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018ff:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101904:	89 04 24             	mov    %eax,(%esp)
f0101907:	e8 7e f7 ff ff       	call   f010108a <page_insert>
f010190c:	85 c0                	test   %eax,%eax
f010190e:	78 24                	js     f0101934 <mem_init+0x7dd>
f0101910:	c7 44 24 0c 44 43 10 	movl   $0xf0104344,0xc(%esp)
f0101917:	f0 
f0101918:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010191f:	f0 
f0101920:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f0101927:	00 
f0101928:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010192f:	e8 60 e7 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101934:	89 3c 24             	mov    %edi,(%esp)
f0101937:	e8 52 f5 ff ff       	call   f0100e8e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010193c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101943:	00 
f0101944:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010194b:	00 
f010194c:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101950:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101955:	89 04 24             	mov    %eax,(%esp)
f0101958:	e8 2d f7 ff ff       	call   f010108a <page_insert>
f010195d:	85 c0                	test   %eax,%eax
f010195f:	74 24                	je     f0101985 <mem_init+0x82e>
f0101961:	c7 44 24 0c 74 43 10 	movl   $0xf0104374,0xc(%esp)
f0101968:	f0 
f0101969:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101970:	f0 
f0101971:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f0101978:	00 
f0101979:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101980:	e8 0f e7 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101985:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f010198b:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010198e:	a1 70 f9 11 f0       	mov    0xf011f970,%eax
f0101993:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101996:	8b 11                	mov    (%ecx),%edx
f0101998:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010199e:	89 f8                	mov    %edi,%eax
f01019a0:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01019a3:	c1 f8 03             	sar    $0x3,%eax
f01019a6:	c1 e0 0c             	shl    $0xc,%eax
f01019a9:	39 c2                	cmp    %eax,%edx
f01019ab:	74 24                	je     f01019d1 <mem_init+0x87a>
f01019ad:	c7 44 24 0c a4 43 10 	movl   $0xf01043a4,0xc(%esp)
f01019b4:	f0 
f01019b5:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01019bc:	f0 
f01019bd:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f01019c4:	00 
f01019c5:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01019cc:	e8 c3 e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019d1:	ba 00 00 00 00       	mov    $0x0,%edx
f01019d6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019d9:	e8 fa ee ff ff       	call   f01008d8 <check_va2pa>
f01019de:	89 f2                	mov    %esi,%edx
f01019e0:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019e3:	c1 fa 03             	sar    $0x3,%edx
f01019e6:	c1 e2 0c             	shl    $0xc,%edx
f01019e9:	39 d0                	cmp    %edx,%eax
f01019eb:	74 24                	je     f0101a11 <mem_init+0x8ba>
f01019ed:	c7 44 24 0c cc 43 10 	movl   $0xf01043cc,0xc(%esp)
f01019f4:	f0 
f01019f5:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01019fc:	f0 
f01019fd:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101a04:	00 
f0101a05:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101a0c:	e8 83 e6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0101a11:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a16:	74 24                	je     f0101a3c <mem_init+0x8e5>
f0101a18:	c7 44 24 0c a1 4a 10 	movl   $0xf0104aa1,0xc(%esp)
f0101a1f:	f0 
f0101a20:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101a27:	f0 
f0101a28:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101a2f:	00 
f0101a30:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101a37:	e8 58 e6 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101a3c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a41:	74 24                	je     f0101a67 <mem_init+0x910>
f0101a43:	c7 44 24 0c b2 4a 10 	movl   $0xf0104ab2,0xc(%esp)
f0101a4a:	f0 
f0101a4b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101a52:	f0 
f0101a53:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101a5a:	00 
f0101a5b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101a62:	e8 2d e6 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a67:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a6e:	00 
f0101a6f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a76:	00 
f0101a77:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a7b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a7e:	89 14 24             	mov    %edx,(%esp)
f0101a81:	e8 04 f6 ff ff       	call   f010108a <page_insert>
f0101a86:	85 c0                	test   %eax,%eax
f0101a88:	74 24                	je     f0101aae <mem_init+0x957>
f0101a8a:	c7 44 24 0c fc 43 10 	movl   $0xf01043fc,0xc(%esp)
f0101a91:	f0 
f0101a92:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101a99:	f0 
f0101a9a:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101aa1:	00 
f0101aa2:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101aa9:	e8 e6 e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aae:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ab3:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101ab8:	e8 1b ee ff ff       	call   f01008d8 <check_va2pa>
f0101abd:	89 da                	mov    %ebx,%edx
f0101abf:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101ac5:	c1 fa 03             	sar    $0x3,%edx
f0101ac8:	c1 e2 0c             	shl    $0xc,%edx
f0101acb:	39 d0                	cmp    %edx,%eax
f0101acd:	74 24                	je     f0101af3 <mem_init+0x99c>
f0101acf:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f0101ad6:	f0 
f0101ad7:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101ade:	f0 
f0101adf:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101ae6:	00 
f0101ae7:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101aee:	e8 a1 e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101af3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101af8:	74 24                	je     f0101b1e <mem_init+0x9c7>
f0101afa:	c7 44 24 0c c3 4a 10 	movl   $0xf0104ac3,0xc(%esp)
f0101b01:	f0 
f0101b02:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101b09:	f0 
f0101b0a:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101b11:	00 
f0101b12:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101b19:	e8 76 e5 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b1e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b25:	e8 e0 f2 ff ff       	call   f0100e0a <page_alloc>
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	74 24                	je     f0101b52 <mem_init+0x9fb>
f0101b2e:	c7 44 24 0c 4f 4a 10 	movl   $0xf0104a4f,0xc(%esp)
f0101b35:	f0 
f0101b36:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101b3d:	f0 
f0101b3e:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101b45:	00 
f0101b46:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101b4d:	e8 42 e5 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b52:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b59:	00 
f0101b5a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b61:	00 
f0101b62:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b66:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101b6b:	89 04 24             	mov    %eax,(%esp)
f0101b6e:	e8 17 f5 ff ff       	call   f010108a <page_insert>
f0101b73:	85 c0                	test   %eax,%eax
f0101b75:	74 24                	je     f0101b9b <mem_init+0xa44>
f0101b77:	c7 44 24 0c fc 43 10 	movl   $0xf01043fc,0xc(%esp)
f0101b7e:	f0 
f0101b7f:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101b86:	f0 
f0101b87:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0101b8e:	00 
f0101b8f:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101b96:	e8 f9 e4 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b9b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ba0:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101ba5:	e8 2e ed ff ff       	call   f01008d8 <check_va2pa>
f0101baa:	89 da                	mov    %ebx,%edx
f0101bac:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101bb2:	c1 fa 03             	sar    $0x3,%edx
f0101bb5:	c1 e2 0c             	shl    $0xc,%edx
f0101bb8:	39 d0                	cmp    %edx,%eax
f0101bba:	74 24                	je     f0101be0 <mem_init+0xa89>
f0101bbc:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f0101bc3:	f0 
f0101bc4:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101bcb:	f0 
f0101bcc:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0101bd3:	00 
f0101bd4:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101bdb:	e8 b4 e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101be0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101be5:	74 24                	je     f0101c0b <mem_init+0xab4>
f0101be7:	c7 44 24 0c c3 4a 10 	movl   $0xf0104ac3,0xc(%esp)
f0101bee:	f0 
f0101bef:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101bf6:	f0 
f0101bf7:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101bfe:	00 
f0101bff:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101c06:	e8 89 e4 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101c0b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c12:	e8 f3 f1 ff ff       	call   f0100e0a <page_alloc>
f0101c17:	85 c0                	test   %eax,%eax
f0101c19:	74 24                	je     f0101c3f <mem_init+0xae8>
f0101c1b:	c7 44 24 0c 4f 4a 10 	movl   $0xf0104a4f,0xc(%esp)
f0101c22:	f0 
f0101c23:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101c2a:	f0 
f0101c2b:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101c32:	00 
f0101c33:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101c3a:	e8 55 e4 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c3f:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
f0101c45:	8b 02                	mov    (%edx),%eax
f0101c47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c4c:	89 c1                	mov    %eax,%ecx
f0101c4e:	c1 e9 0c             	shr    $0xc,%ecx
f0101c51:	3b 0d 68 f9 11 f0    	cmp    0xf011f968,%ecx
f0101c57:	72 20                	jb     f0101c79 <mem_init+0xb22>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c5d:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0101c64:	f0 
f0101c65:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101c6c:	00 
f0101c6d:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101c74:	e8 1b e4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101c79:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c81:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c88:	00 
f0101c89:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c90:	00 
f0101c91:	89 14 24             	mov    %edx,(%esp)
f0101c94:	e8 55 f2 ff ff       	call   f0100eee <pgdir_walk>
f0101c99:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c9c:	83 c2 04             	add    $0x4,%edx
f0101c9f:	39 d0                	cmp    %edx,%eax
f0101ca1:	74 24                	je     f0101cc7 <mem_init+0xb70>
f0101ca3:	c7 44 24 0c 68 44 10 	movl   $0xf0104468,0xc(%esp)
f0101caa:	f0 
f0101cab:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101cb2:	f0 
f0101cb3:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101cba:	00 
f0101cbb:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101cc2:	e8 cd e3 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cc7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101cce:	00 
f0101ccf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cd6:	00 
f0101cd7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cdb:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101ce0:	89 04 24             	mov    %eax,(%esp)
f0101ce3:	e8 a2 f3 ff ff       	call   f010108a <page_insert>
f0101ce8:	85 c0                	test   %eax,%eax
f0101cea:	74 24                	je     f0101d10 <mem_init+0xbb9>
f0101cec:	c7 44 24 0c a8 44 10 	movl   $0xf01044a8,0xc(%esp)
f0101cf3:	f0 
f0101cf4:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101cfb:	f0 
f0101cfc:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101d03:	00 
f0101d04:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101d0b:	e8 84 e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101d10:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f0101d16:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101d19:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d1e:	89 c8                	mov    %ecx,%eax
f0101d20:	e8 b3 eb ff ff       	call   f01008d8 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d25:	89 da                	mov    %ebx,%edx
f0101d27:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101d2d:	c1 fa 03             	sar    $0x3,%edx
f0101d30:	c1 e2 0c             	shl    $0xc,%edx
f0101d33:	39 d0                	cmp    %edx,%eax
f0101d35:	74 24                	je     f0101d5b <mem_init+0xc04>
f0101d37:	c7 44 24 0c 38 44 10 	movl   $0xf0104438,0xc(%esp)
f0101d3e:	f0 
f0101d3f:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101d46:	f0 
f0101d47:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101d4e:	00 
f0101d4f:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101d56:	e8 39 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101d5b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d60:	74 24                	je     f0101d86 <mem_init+0xc2f>
f0101d62:	c7 44 24 0c c3 4a 10 	movl   $0xf0104ac3,0xc(%esp)
f0101d69:	f0 
f0101d6a:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101d71:	f0 
f0101d72:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0101d79:	00 
f0101d7a:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101d81:	e8 0e e3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d8d:	00 
f0101d8e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d95:	00 
f0101d96:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d99:	89 04 24             	mov    %eax,(%esp)
f0101d9c:	e8 4d f1 ff ff       	call   f0100eee <pgdir_walk>
f0101da1:	f6 00 04             	testb  $0x4,(%eax)
f0101da4:	75 24                	jne    f0101dca <mem_init+0xc73>
f0101da6:	c7 44 24 0c e8 44 10 	movl   $0xf01044e8,0xc(%esp)
f0101dad:	f0 
f0101dae:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101db5:	f0 
f0101db6:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0101dbd:	00 
f0101dbe:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101dc5:	e8 ca e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101dca:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101dcf:	f6 00 04             	testb  $0x4,(%eax)
f0101dd2:	75 24                	jne    f0101df8 <mem_init+0xca1>
f0101dd4:	c7 44 24 0c d4 4a 10 	movl   $0xf0104ad4,0xc(%esp)
f0101ddb:	f0 
f0101ddc:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101de3:	f0 
f0101de4:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101deb:	00 
f0101dec:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101df3:	e8 9c e2 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101df8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101dff:	00 
f0101e00:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e07:	00 
f0101e08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101e0c:	89 04 24             	mov    %eax,(%esp)
f0101e0f:	e8 76 f2 ff ff       	call   f010108a <page_insert>
f0101e14:	85 c0                	test   %eax,%eax
f0101e16:	74 24                	je     f0101e3c <mem_init+0xce5>
f0101e18:	c7 44 24 0c fc 43 10 	movl   $0xf01043fc,0xc(%esp)
f0101e1f:	f0 
f0101e20:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101e27:	f0 
f0101e28:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101e2f:	00 
f0101e30:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101e37:	e8 58 e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e3c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e43:	00 
f0101e44:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e4b:	00 
f0101e4c:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101e51:	89 04 24             	mov    %eax,(%esp)
f0101e54:	e8 95 f0 ff ff       	call   f0100eee <pgdir_walk>
f0101e59:	f6 00 02             	testb  $0x2,(%eax)
f0101e5c:	75 24                	jne    f0101e82 <mem_init+0xd2b>
f0101e5e:	c7 44 24 0c 1c 45 10 	movl   $0xf010451c,0xc(%esp)
f0101e65:	f0 
f0101e66:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101e6d:	f0 
f0101e6e:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101e75:	00 
f0101e76:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101e7d:	e8 12 e2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e89:	00 
f0101e8a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e91:	00 
f0101e92:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101e97:	89 04 24             	mov    %eax,(%esp)
f0101e9a:	e8 4f f0 ff ff       	call   f0100eee <pgdir_walk>
f0101e9f:	f6 00 04             	testb  $0x4,(%eax)
f0101ea2:	74 24                	je     f0101ec8 <mem_init+0xd71>
f0101ea4:	c7 44 24 0c 50 45 10 	movl   $0xf0104550,0xc(%esp)
f0101eab:	f0 
f0101eac:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101eb3:	f0 
f0101eb4:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0101ebb:	00 
f0101ebc:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101ec3:	e8 cc e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ec8:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101ecf:	00 
f0101ed0:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101ed7:	00 
f0101ed8:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101edc:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101ee1:	89 04 24             	mov    %eax,(%esp)
f0101ee4:	e8 a1 f1 ff ff       	call   f010108a <page_insert>
f0101ee9:	85 c0                	test   %eax,%eax
f0101eeb:	78 24                	js     f0101f11 <mem_init+0xdba>
f0101eed:	c7 44 24 0c 88 45 10 	movl   $0xf0104588,0xc(%esp)
f0101ef4:	f0 
f0101ef5:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101efc:	f0 
f0101efd:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101f04:	00 
f0101f05:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101f0c:	e8 83 e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101f11:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101f18:	00 
f0101f19:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f20:	00 
f0101f21:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f25:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101f2a:	89 04 24             	mov    %eax,(%esp)
f0101f2d:	e8 58 f1 ff ff       	call   f010108a <page_insert>
f0101f32:	85 c0                	test   %eax,%eax
f0101f34:	74 24                	je     f0101f5a <mem_init+0xe03>
f0101f36:	c7 44 24 0c c0 45 10 	movl   $0xf01045c0,0xc(%esp)
f0101f3d:	f0 
f0101f3e:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101f45:	f0 
f0101f46:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101f4d:	00 
f0101f4e:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101f55:	e8 3a e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f61:	00 
f0101f62:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f69:	00 
f0101f6a:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101f6f:	89 04 24             	mov    %eax,(%esp)
f0101f72:	e8 77 ef ff ff       	call   f0100eee <pgdir_walk>
f0101f77:	f6 00 04             	testb  $0x4,(%eax)
f0101f7a:	74 24                	je     f0101fa0 <mem_init+0xe49>
f0101f7c:	c7 44 24 0c 50 45 10 	movl   $0xf0104550,0xc(%esp)
f0101f83:	f0 
f0101f84:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101f8b:	f0 
f0101f8c:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101f93:	00 
f0101f94:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101f9b:	e8 f4 e0 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101fa0:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101fa5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101fa8:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fad:	e8 26 e9 ff ff       	call   f01008d8 <check_va2pa>
f0101fb2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101fb5:	89 f0                	mov    %esi,%eax
f0101fb7:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0101fbd:	c1 f8 03             	sar    $0x3,%eax
f0101fc0:	c1 e0 0c             	shl    $0xc,%eax
f0101fc3:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fc6:	74 24                	je     f0101fec <mem_init+0xe95>
f0101fc8:	c7 44 24 0c fc 45 10 	movl   $0xf01045fc,0xc(%esp)
f0101fcf:	f0 
f0101fd0:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0101fd7:	f0 
f0101fd8:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101fdf:	00 
f0101fe0:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0101fe7:	e8 a8 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fec:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ff1:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ff4:	e8 df e8 ff ff       	call   f01008d8 <check_va2pa>
f0101ff9:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101ffc:	74 24                	je     f0102022 <mem_init+0xecb>
f0101ffe:	c7 44 24 0c 28 46 10 	movl   $0xf0104628,0xc(%esp)
f0102005:	f0 
f0102006:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010200d:	f0 
f010200e:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0102015:	00 
f0102016:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010201d:	e8 72 e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102022:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f0102027:	74 24                	je     f010204d <mem_init+0xef6>
f0102029:	c7 44 24 0c ea 4a 10 	movl   $0xf0104aea,0xc(%esp)
f0102030:	f0 
f0102031:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102038:	f0 
f0102039:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0102040:	00 
f0102041:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102048:	e8 47 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f010204d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102052:	74 24                	je     f0102078 <mem_init+0xf21>
f0102054:	c7 44 24 0c fb 4a 10 	movl   $0xf0104afb,0xc(%esp)
f010205b:	f0 
f010205c:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102063:	f0 
f0102064:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f010206b:	00 
f010206c:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102073:	e8 1c e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0102078:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010207f:	e8 86 ed ff ff       	call   f0100e0a <page_alloc>
f0102084:	85 c0                	test   %eax,%eax
f0102086:	74 04                	je     f010208c <mem_init+0xf35>
f0102088:	39 c3                	cmp    %eax,%ebx
f010208a:	74 24                	je     f01020b0 <mem_init+0xf59>
f010208c:	c7 44 24 0c 58 46 10 	movl   $0xf0104658,0xc(%esp)
f0102093:	f0 
f0102094:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010209b:	f0 
f010209c:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f01020a3:	00 
f01020a4:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01020ab:	e8 e4 df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01020b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020b7:	00 
f01020b8:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01020bd:	89 04 24             	mov    %eax,(%esp)
f01020c0:	e8 76 ef ff ff       	call   f010103b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020c5:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
f01020cb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01020ce:	ba 00 00 00 00       	mov    $0x0,%edx
f01020d3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020d6:	e8 fd e7 ff ff       	call   f01008d8 <check_va2pa>
f01020db:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020de:	74 24                	je     f0102104 <mem_init+0xfad>
f01020e0:	c7 44 24 0c 7c 46 10 	movl   $0xf010467c,0xc(%esp)
f01020e7:	f0 
f01020e8:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01020ef:	f0 
f01020f0:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f01020f7:	00 
f01020f8:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01020ff:	e8 90 df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102104:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102109:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010210c:	e8 c7 e7 ff ff       	call   f01008d8 <check_va2pa>
f0102111:	89 f2                	mov    %esi,%edx
f0102113:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102119:	c1 fa 03             	sar    $0x3,%edx
f010211c:	c1 e2 0c             	shl    $0xc,%edx
f010211f:	39 d0                	cmp    %edx,%eax
f0102121:	74 24                	je     f0102147 <mem_init+0xff0>
f0102123:	c7 44 24 0c 28 46 10 	movl   $0xf0104628,0xc(%esp)
f010212a:	f0 
f010212b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102132:	f0 
f0102133:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f010213a:	00 
f010213b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102142:	e8 4d df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f0102147:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010214c:	74 24                	je     f0102172 <mem_init+0x101b>
f010214e:	c7 44 24 0c a1 4a 10 	movl   $0xf0104aa1,0xc(%esp)
f0102155:	f0 
f0102156:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010215d:	f0 
f010215e:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f0102165:	00 
f0102166:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010216d:	e8 22 df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102172:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102177:	74 24                	je     f010219d <mem_init+0x1046>
f0102179:	c7 44 24 0c fb 4a 10 	movl   $0xf0104afb,0xc(%esp)
f0102180:	f0 
f0102181:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102188:	f0 
f0102189:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102190:	00 
f0102191:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102198:	e8 f7 de ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f010219d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01021a4:	00 
f01021a5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01021ac:	00 
f01021ad:	89 74 24 04          	mov    %esi,0x4(%esp)
f01021b1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01021b4:	89 0c 24             	mov    %ecx,(%esp)
f01021b7:	e8 ce ee ff ff       	call   f010108a <page_insert>
f01021bc:	85 c0                	test   %eax,%eax
f01021be:	74 24                	je     f01021e4 <mem_init+0x108d>
f01021c0:	c7 44 24 0c a0 46 10 	movl   $0xf01046a0,0xc(%esp)
f01021c7:	f0 
f01021c8:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01021cf:	f0 
f01021d0:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f01021d7:	00 
f01021d8:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01021df:	e8 b0 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f01021e4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021e9:	75 24                	jne    f010220f <mem_init+0x10b8>
f01021eb:	c7 44 24 0c 0c 4b 10 	movl   $0xf0104b0c,0xc(%esp)
f01021f2:	f0 
f01021f3:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01021fa:	f0 
f01021fb:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f0102202:	00 
f0102203:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010220a:	e8 85 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f010220f:	83 3e 00             	cmpl   $0x0,(%esi)
f0102212:	74 24                	je     f0102238 <mem_init+0x10e1>
f0102214:	c7 44 24 0c 18 4b 10 	movl   $0xf0104b18,0xc(%esp)
f010221b:	f0 
f010221c:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102223:	f0 
f0102224:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f010222b:	00 
f010222c:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102233:	e8 5c de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102238:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f010223f:	00 
f0102240:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102245:	89 04 24             	mov    %eax,(%esp)
f0102248:	e8 ee ed ff ff       	call   f010103b <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010224d:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102252:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102255:	ba 00 00 00 00       	mov    $0x0,%edx
f010225a:	e8 79 e6 ff ff       	call   f01008d8 <check_va2pa>
f010225f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102262:	74 24                	je     f0102288 <mem_init+0x1131>
f0102264:	c7 44 24 0c 7c 46 10 	movl   $0xf010467c,0xc(%esp)
f010226b:	f0 
f010226c:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102273:	f0 
f0102274:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f010227b:	00 
f010227c:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102283:	e8 0c de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102288:	ba 00 10 00 00       	mov    $0x1000,%edx
f010228d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102290:	e8 43 e6 ff ff       	call   f01008d8 <check_va2pa>
f0102295:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102298:	74 24                	je     f01022be <mem_init+0x1167>
f010229a:	c7 44 24 0c d8 46 10 	movl   $0xf01046d8,0xc(%esp)
f01022a1:	f0 
f01022a2:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01022a9:	f0 
f01022aa:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f01022b1:	00 
f01022b2:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01022b9:	e8 d6 dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01022be:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022c3:	74 24                	je     f01022e9 <mem_init+0x1192>
f01022c5:	c7 44 24 0c 2d 4b 10 	movl   $0xf0104b2d,0xc(%esp)
f01022cc:	f0 
f01022cd:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01022d4:	f0 
f01022d5:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f01022dc:	00 
f01022dd:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01022e4:	e8 ab dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01022e9:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022ee:	74 24                	je     f0102314 <mem_init+0x11bd>
f01022f0:	c7 44 24 0c fb 4a 10 	movl   $0xf0104afb,0xc(%esp)
f01022f7:	f0 
f01022f8:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01022ff:	f0 
f0102300:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f0102307:	00 
f0102308:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010230f:	e8 80 dd ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102314:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010231b:	e8 ea ea ff ff       	call   f0100e0a <page_alloc>
f0102320:	85 c0                	test   %eax,%eax
f0102322:	74 04                	je     f0102328 <mem_init+0x11d1>
f0102324:	39 c6                	cmp    %eax,%esi
f0102326:	74 24                	je     f010234c <mem_init+0x11f5>
f0102328:	c7 44 24 0c 00 47 10 	movl   $0xf0104700,0xc(%esp)
f010232f:	f0 
f0102330:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102337:	f0 
f0102338:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f010233f:	00 
f0102340:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102347:	e8 48 dd ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f010234c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102353:	e8 b2 ea ff ff       	call   f0100e0a <page_alloc>
f0102358:	85 c0                	test   %eax,%eax
f010235a:	74 24                	je     f0102380 <mem_init+0x1229>
f010235c:	c7 44 24 0c 4f 4a 10 	movl   $0xf0104a4f,0xc(%esp)
f0102363:	f0 
f0102364:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010236b:	f0 
f010236c:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0102373:	00 
f0102374:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010237b:	e8 14 dd ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102380:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102385:	8b 08                	mov    (%eax),%ecx
f0102387:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f010238d:	89 fa                	mov    %edi,%edx
f010238f:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102395:	c1 fa 03             	sar    $0x3,%edx
f0102398:	c1 e2 0c             	shl    $0xc,%edx
f010239b:	39 d1                	cmp    %edx,%ecx
f010239d:	74 24                	je     f01023c3 <mem_init+0x126c>
f010239f:	c7 44 24 0c a4 43 10 	movl   $0xf01043a4,0xc(%esp)
f01023a6:	f0 
f01023a7:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01023ae:	f0 
f01023af:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f01023b6:	00 
f01023b7:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01023be:	e8 d1 dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01023c3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023c9:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023ce:	74 24                	je     f01023f4 <mem_init+0x129d>
f01023d0:	c7 44 24 0c b2 4a 10 	movl   $0xf0104ab2,0xc(%esp)
f01023d7:	f0 
f01023d8:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01023df:	f0 
f01023e0:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f01023e7:	00 
f01023e8:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01023ef:	e8 a0 dc ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01023f4:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023fa:	89 3c 24             	mov    %edi,(%esp)
f01023fd:	e8 8c ea ff ff       	call   f0100e8e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102402:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102409:	00 
f010240a:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102411:	00 
f0102412:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102417:	89 04 24             	mov    %eax,(%esp)
f010241a:	e8 cf ea ff ff       	call   f0100eee <pgdir_walk>
f010241f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102422:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f0102428:	8b 51 04             	mov    0x4(%ecx),%edx
f010242b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102431:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102434:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f010243a:	89 55 c8             	mov    %edx,-0x38(%ebp)
f010243d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102440:	c1 ea 0c             	shr    $0xc,%edx
f0102443:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102446:	8b 55 c8             	mov    -0x38(%ebp),%edx
f0102449:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f010244c:	72 23                	jb     f0102471 <mem_init+0x131a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010244e:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102451:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102455:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f010245c:	f0 
f010245d:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0102464:	00 
f0102465:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010246c:	e8 23 dc ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102471:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102474:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010247a:	39 d0                	cmp    %edx,%eax
f010247c:	74 24                	je     f01024a2 <mem_init+0x134b>
f010247e:	c7 44 24 0c 3e 4b 10 	movl   $0xf0104b3e,0xc(%esp)
f0102485:	f0 
f0102486:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010248d:	f0 
f010248e:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f0102495:	00 
f0102496:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010249d:	e8 f2 db ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f01024a2:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f01024a9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024af:	89 f8                	mov    %edi,%eax
f01024b1:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f01024b7:	c1 f8 03             	sar    $0x3,%eax
f01024ba:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024bd:	89 c1                	mov    %eax,%ecx
f01024bf:	c1 e9 0c             	shr    $0xc,%ecx
f01024c2:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01024c5:	77 20                	ja     f01024e7 <mem_init+0x1390>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024cb:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f01024d2:	f0 
f01024d3:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01024da:	00 
f01024db:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f01024e2:	e8 ad db ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024ee:	00 
f01024ef:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01024f6:	00 
	return (void *)(pa + KERNBASE);
f01024f7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024fc:	89 04 24             	mov    %eax,(%esp)
f01024ff:	e8 7e 12 00 00       	call   f0103782 <memset>
	page_free(pp0);
f0102504:	89 3c 24             	mov    %edi,(%esp)
f0102507:	e8 82 e9 ff ff       	call   f0100e8e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010250c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102513:	00 
f0102514:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010251b:	00 
f010251c:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102521:	89 04 24             	mov    %eax,(%esp)
f0102524:	e8 c5 e9 ff ff       	call   f0100eee <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102529:	89 fa                	mov    %edi,%edx
f010252b:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102531:	c1 fa 03             	sar    $0x3,%edx
f0102534:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102537:	89 d0                	mov    %edx,%eax
f0102539:	c1 e8 0c             	shr    $0xc,%eax
f010253c:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f0102542:	72 20                	jb     f0102564 <mem_init+0x140d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102544:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102548:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f010254f:	f0 
f0102550:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102557:	00 
f0102558:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f010255f:	e8 30 db ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102564:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010256a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f010256d:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102573:	f6 00 01             	testb  $0x1,(%eax)
f0102576:	74 24                	je     f010259c <mem_init+0x1445>
f0102578:	c7 44 24 0c 56 4b 10 	movl   $0xf0104b56,0xc(%esp)
f010257f:	f0 
f0102580:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102587:	f0 
f0102588:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f010258f:	00 
f0102590:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102597:	e8 f8 da ff ff       	call   f0100094 <_panic>
f010259c:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010259f:	39 d0                	cmp    %edx,%eax
f01025a1:	75 d0                	jne    f0102573 <mem_init+0x141c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f01025a3:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01025a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f01025ae:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f01025b4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f01025b7:	89 0d 40 f5 11 f0    	mov    %ecx,0xf011f540

	// free the pages we took
	page_free(pp0);
f01025bd:	89 3c 24             	mov    %edi,(%esp)
f01025c0:	e8 c9 e8 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f01025c5:	89 34 24             	mov    %esi,(%esp)
f01025c8:	e8 c1 e8 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f01025cd:	89 1c 24             	mov    %ebx,(%esp)
f01025d0:	e8 b9 e8 ff ff       	call   f0100e8e <page_free>

	cprintf("check_page() succeeded!\n");
f01025d5:	c7 04 24 6d 4b 10 f0 	movl   $0xf0104b6d,(%esp)
f01025dc:	e8 fd 06 00 00       	call   f0102cde <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01025e1:	8b 1d 6c f9 11 f0    	mov    0xf011f96c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025e7:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f01025ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01025ef:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
f01025f6:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE)
f01025fc:	be 00 00 00 00       	mov    $0x0,%esi
f0102601:	eb 70                	jmp    f0102673 <mem_init+0x151c>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102603:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102609:	89 d8                	mov    %ebx,%eax
f010260b:	e8 c8 e2 ff ff       	call   f01008d8 <check_va2pa>
f0102610:	8b 15 70 f9 11 f0    	mov    0xf011f970,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102616:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f010261c:	77 20                	ja     f010263e <mem_init+0x14e7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010261e:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102622:	c7 44 24 08 28 41 10 	movl   $0xf0104128,0x8(%esp)
f0102629:	f0 
f010262a:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f0102631:	00 
f0102632:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102639:	e8 56 da ff ff       	call   f0100094 <_panic>
f010263e:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f0102645:	39 d0                	cmp    %edx,%eax
f0102647:	74 24                	je     f010266d <mem_init+0x1516>
f0102649:	c7 44 24 0c 24 47 10 	movl   $0xf0104724,0xc(%esp)
f0102650:	f0 
f0102651:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102658:	f0 
f0102659:	c7 44 24 04 c6 02 00 	movl   $0x2c6,0x4(%esp)
f0102660:	00 
f0102661:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102668:	e8 27 da ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010266d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102673:	39 f7                	cmp    %esi,%edi
f0102675:	77 8c                	ja     f0102603 <mem_init+0x14ac>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102677:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010267a:	c1 e7 0c             	shl    $0xc,%edi
f010267d:	be 00 00 00 00       	mov    $0x0,%esi
f0102682:	eb 3b                	jmp    f01026bf <mem_init+0x1568>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102684:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010268a:	89 d8                	mov    %ebx,%eax
f010268c:	e8 47 e2 ff ff       	call   f01008d8 <check_va2pa>
f0102691:	39 c6                	cmp    %eax,%esi
f0102693:	74 24                	je     f01026b9 <mem_init+0x1562>
f0102695:	c7 44 24 0c 58 47 10 	movl   $0xf0104758,0xc(%esp)
f010269c:	f0 
f010269d:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01026a4:	f0 
f01026a5:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f01026ac:	00 
f01026ad:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01026b4:	e8 db d9 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026b9:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01026bf:	39 fe                	cmp    %edi,%esi
f01026c1:	72 c1                	jb     f0102684 <mem_init+0x152d>
f01026c3:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c8:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f01026cd:	89 f2                	mov    %esi,%edx
f01026cf:	89 d8                	mov    %ebx,%eax
f01026d1:	e8 02 e2 ff ff       	call   f01008d8 <check_va2pa>
f01026d6:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01026dc:	77 24                	ja     f0102702 <mem_init+0x15ab>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026de:	c7 44 24 0c 00 50 11 	movl   $0xf0115000,0xc(%esp)
f01026e5:	f0 
f01026e6:	c7 44 24 08 28 41 10 	movl   $0xf0104128,0x8(%esp)
f01026ed:	f0 
f01026ee:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f01026f5:	00 
f01026f6:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01026fd:	e8 92 d9 ff ff       	call   f0100094 <_panic>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102702:	8d 96 00 d0 11 10    	lea    0x1011d000(%esi),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102708:	39 d0                	cmp    %edx,%eax
f010270a:	74 24                	je     f0102730 <mem_init+0x15d9>
f010270c:	c7 44 24 0c 80 47 10 	movl   $0xf0104780,0xc(%esp)
f0102713:	f0 
f0102714:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010271b:	f0 
f010271c:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f0102723:	00 
f0102724:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010272b:	e8 64 d9 ff ff       	call   f0100094 <_panic>
f0102730:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102736:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f010273c:	75 8f                	jne    f01026cd <mem_init+0x1576>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010273e:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f0102743:	89 d8                	mov    %ebx,%eax
f0102745:	e8 8e e1 ff ff       	call   f01008d8 <check_va2pa>
f010274a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010274d:	74 24                	je     f0102773 <mem_init+0x161c>
f010274f:	c7 44 24 0c c8 47 10 	movl   $0xf01047c8,0xc(%esp)
f0102756:	f0 
f0102757:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010275e:	f0 
f010275f:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f0102766:	00 
f0102767:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010276e:	e8 21 d9 ff ff       	call   f0100094 <_panic>
f0102773:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102778:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f010277d:	72 3c                	jb     f01027bb <mem_init+0x1664>
f010277f:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102784:	76 07                	jbe    f010278d <mem_init+0x1636>
f0102786:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010278b:	75 2e                	jne    f01027bb <mem_init+0x1664>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010278d:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102791:	0f 85 aa 00 00 00    	jne    f0102841 <mem_init+0x16ea>
f0102797:	c7 44 24 0c 86 4b 10 	movl   $0xf0104b86,0xc(%esp)
f010279e:	f0 
f010279f:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01027a6:	f0 
f01027a7:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f01027ae:	00 
f01027af:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01027b6:	e8 d9 d8 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01027bb:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027c0:	76 55                	jbe    f0102817 <mem_init+0x16c0>
				assert(pgdir[i] & PTE_P);
f01027c2:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01027c5:	f6 c2 01             	test   $0x1,%dl
f01027c8:	75 24                	jne    f01027ee <mem_init+0x1697>
f01027ca:	c7 44 24 0c 86 4b 10 	movl   $0xf0104b86,0xc(%esp)
f01027d1:	f0 
f01027d2:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01027d9:	f0 
f01027da:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f01027e1:	00 
f01027e2:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01027e9:	e8 a6 d8 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f01027ee:	f6 c2 02             	test   $0x2,%dl
f01027f1:	75 4e                	jne    f0102841 <mem_init+0x16ea>
f01027f3:	c7 44 24 0c 97 4b 10 	movl   $0xf0104b97,0xc(%esp)
f01027fa:	f0 
f01027fb:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102802:	f0 
f0102803:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f010280a:	00 
f010280b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102812:	e8 7d d8 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102817:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010281b:	74 24                	je     f0102841 <mem_init+0x16ea>
f010281d:	c7 44 24 0c a8 4b 10 	movl   $0xf0104ba8,0xc(%esp)
f0102824:	f0 
f0102825:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f010282c:	f0 
f010282d:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f0102834:	00 
f0102835:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010283c:	e8 53 d8 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102841:	40                   	inc    %eax
f0102842:	3d 00 04 00 00       	cmp    $0x400,%eax
f0102847:	0f 85 2b ff ff ff    	jne    f0102778 <mem_init+0x1621>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f010284d:	c7 04 24 f8 47 10 f0 	movl   $0xf01047f8,(%esp)
f0102854:	e8 85 04 00 00       	call   f0102cde <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102859:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010285e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102863:	77 20                	ja     f0102885 <mem_init+0x172e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102865:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102869:	c7 44 24 08 28 41 10 	movl   $0xf0104128,0x8(%esp)
f0102870:	f0 
f0102871:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f0102878:	00 
f0102879:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102880:	e8 0f d8 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102885:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010288a:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010288d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102892:	e8 a0 e1 ff ff       	call   f0100a37 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102897:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010289a:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f010289f:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01028a2:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01028a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028ac:	e8 59 e5 ff ff       	call   f0100e0a <page_alloc>
f01028b1:	89 c6                	mov    %eax,%esi
f01028b3:	85 c0                	test   %eax,%eax
f01028b5:	75 24                	jne    f01028db <mem_init+0x1784>
f01028b7:	c7 44 24 0c a4 49 10 	movl   $0xf01049a4,0xc(%esp)
f01028be:	f0 
f01028bf:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01028c6:	f0 
f01028c7:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f01028ce:	00 
f01028cf:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f01028d6:	e8 b9 d7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01028db:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028e2:	e8 23 e5 ff ff       	call   f0100e0a <page_alloc>
f01028e7:	89 c7                	mov    %eax,%edi
f01028e9:	85 c0                	test   %eax,%eax
f01028eb:	75 24                	jne    f0102911 <mem_init+0x17ba>
f01028ed:	c7 44 24 0c ba 49 10 	movl   $0xf01049ba,0xc(%esp)
f01028f4:	f0 
f01028f5:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f01028fc:	f0 
f01028fd:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102904:	00 
f0102905:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f010290c:	e8 83 d7 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102911:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102918:	e8 ed e4 ff ff       	call   f0100e0a <page_alloc>
f010291d:	89 c3                	mov    %eax,%ebx
f010291f:	85 c0                	test   %eax,%eax
f0102921:	75 24                	jne    f0102947 <mem_init+0x17f0>
f0102923:	c7 44 24 0c d0 49 10 	movl   $0xf01049d0,0xc(%esp)
f010292a:	f0 
f010292b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102932:	f0 
f0102933:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f010293a:	00 
f010293b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102942:	e8 4d d7 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f0102947:	89 34 24             	mov    %esi,(%esp)
f010294a:	e8 3f e5 ff ff       	call   f0100e8e <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010294f:	89 f8                	mov    %edi,%eax
f0102951:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0102957:	c1 f8 03             	sar    $0x3,%eax
f010295a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010295d:	89 c2                	mov    %eax,%edx
f010295f:	c1 ea 0c             	shr    $0xc,%edx
f0102962:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0102968:	72 20                	jb     f010298a <mem_init+0x1833>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010296a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010296e:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0102975:	f0 
f0102976:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010297d:	00 
f010297e:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f0102985:	e8 0a d7 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010298a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102991:	00 
f0102992:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102999:	00 
	return (void *)(pa + KERNBASE);
f010299a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010299f:	89 04 24             	mov    %eax,(%esp)
f01029a2:	e8 db 0d 00 00       	call   f0103782 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029a7:	89 d8                	mov    %ebx,%eax
f01029a9:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f01029af:	c1 f8 03             	sar    $0x3,%eax
f01029b2:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029b5:	89 c2                	mov    %eax,%edx
f01029b7:	c1 ea 0c             	shr    $0xc,%edx
f01029ba:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f01029c0:	72 20                	jb     f01029e2 <mem_init+0x188b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029c2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029c6:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f01029cd:	f0 
f01029ce:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01029d5:	00 
f01029d6:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f01029dd:	e8 b2 d6 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01029e2:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01029e9:	00 
f01029ea:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01029f1:	00 
	return (void *)(pa + KERNBASE);
f01029f2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029f7:	89 04 24             	mov    %eax,(%esp)
f01029fa:	e8 83 0d 00 00       	call   f0103782 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029ff:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102a06:	00 
f0102a07:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a0e:	00 
f0102a0f:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102a13:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102a18:	89 04 24             	mov    %eax,(%esp)
f0102a1b:	e8 6a e6 ff ff       	call   f010108a <page_insert>
	assert(pp1->pp_ref == 1);
f0102a20:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a25:	74 24                	je     f0102a4b <mem_init+0x18f4>
f0102a27:	c7 44 24 0c a1 4a 10 	movl   $0xf0104aa1,0xc(%esp)
f0102a2e:	f0 
f0102a2f:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102a36:	f0 
f0102a37:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102a3e:	00 
f0102a3f:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102a46:	e8 49 d6 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a4b:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a52:	01 01 01 
f0102a55:	74 24                	je     f0102a7b <mem_init+0x1924>
f0102a57:	c7 44 24 0c 18 48 10 	movl   $0xf0104818,0xc(%esp)
f0102a5e:	f0 
f0102a5f:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102a66:	f0 
f0102a67:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102a6e:	00 
f0102a6f:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102a76:	e8 19 d6 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a7b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102a82:	00 
f0102a83:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a8a:	00 
f0102a8b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102a8f:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102a94:	89 04 24             	mov    %eax,(%esp)
f0102a97:	e8 ee e5 ff ff       	call   f010108a <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a9c:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102aa3:	02 02 02 
f0102aa6:	74 24                	je     f0102acc <mem_init+0x1975>
f0102aa8:	c7 44 24 0c 3c 48 10 	movl   $0xf010483c,0xc(%esp)
f0102aaf:	f0 
f0102ab0:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102ab7:	f0 
f0102ab8:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102abf:	00 
f0102ac0:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102ac7:	e8 c8 d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102acc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102ad1:	74 24                	je     f0102af7 <mem_init+0x19a0>
f0102ad3:	c7 44 24 0c c3 4a 10 	movl   $0xf0104ac3,0xc(%esp)
f0102ada:	f0 
f0102adb:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102ae2:	f0 
f0102ae3:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102aea:	00 
f0102aeb:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102af2:	e8 9d d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102af7:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102afc:	74 24                	je     f0102b22 <mem_init+0x19cb>
f0102afe:	c7 44 24 0c 2d 4b 10 	movl   $0xf0104b2d,0xc(%esp)
f0102b05:	f0 
f0102b06:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102b0d:	f0 
f0102b0e:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102b15:	00 
f0102b16:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102b1d:	e8 72 d5 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102b22:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102b29:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102b2c:	89 d8                	mov    %ebx,%eax
f0102b2e:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0102b34:	c1 f8 03             	sar    $0x3,%eax
f0102b37:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102b3a:	89 c2                	mov    %eax,%edx
f0102b3c:	c1 ea 0c             	shr    $0xc,%edx
f0102b3f:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0102b45:	72 20                	jb     f0102b67 <mem_init+0x1a10>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b47:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102b4b:	c7 44 24 08 04 41 10 	movl   $0xf0104104,0x8(%esp)
f0102b52:	f0 
f0102b53:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102b5a:	00 
f0102b5b:	c7 04 24 df 48 10 f0 	movl   $0xf01048df,(%esp)
f0102b62:	e8 2d d5 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b67:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b6e:	03 03 03 
f0102b71:	74 24                	je     f0102b97 <mem_init+0x1a40>
f0102b73:	c7 44 24 0c 60 48 10 	movl   $0xf0104860,0xc(%esp)
f0102b7a:	f0 
f0102b7b:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102b82:	f0 
f0102b83:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102b8a:	00 
f0102b8b:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102b92:	e8 fd d4 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b97:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102b9e:	00 
f0102b9f:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102ba4:	89 04 24             	mov    %eax,(%esp)
f0102ba7:	e8 8f e4 ff ff       	call   f010103b <page_remove>
	assert(pp2->pp_ref == 0);
f0102bac:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102bb1:	74 24                	je     f0102bd7 <mem_init+0x1a80>
f0102bb3:	c7 44 24 0c fb 4a 10 	movl   $0xf0104afb,0xc(%esp)
f0102bba:	f0 
f0102bbb:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102bc2:	f0 
f0102bc3:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102bca:	00 
f0102bcb:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102bd2:	e8 bd d4 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102bd7:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102bdc:	8b 08                	mov    (%eax),%ecx
f0102bde:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102be4:	89 f2                	mov    %esi,%edx
f0102be6:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102bec:	c1 fa 03             	sar    $0x3,%edx
f0102bef:	c1 e2 0c             	shl    $0xc,%edx
f0102bf2:	39 d1                	cmp    %edx,%ecx
f0102bf4:	74 24                	je     f0102c1a <mem_init+0x1ac3>
f0102bf6:	c7 44 24 0c a4 43 10 	movl   $0xf01043a4,0xc(%esp)
f0102bfd:	f0 
f0102bfe:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102c0d:	00 
f0102c0e:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102c15:	e8 7a d4 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102c1a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102c20:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102c25:	74 24                	je     f0102c4b <mem_init+0x1af4>
f0102c27:	c7 44 24 0c b2 4a 10 	movl   $0xf0104ab2,0xc(%esp)
f0102c2e:	f0 
f0102c2f:	c7 44 24 08 f9 48 10 	movl   $0xf01048f9,0x8(%esp)
f0102c36:	f0 
f0102c37:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102c3e:	00 
f0102c3f:	c7 04 24 b8 48 10 f0 	movl   $0xf01048b8,(%esp)
f0102c46:	e8 49 d4 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102c4b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102c51:	89 34 24             	mov    %esi,(%esp)
f0102c54:	e8 35 e2 ff ff       	call   f0100e8e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102c59:	c7 04 24 8c 48 10 f0 	movl   $0xf010488c,(%esp)
f0102c60:	e8 79 00 00 00       	call   f0102cde <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102c65:	83 c4 3c             	add    $0x3c,%esp
f0102c68:	5b                   	pop    %ebx
f0102c69:	5e                   	pop    %esi
f0102c6a:	5f                   	pop    %edi
f0102c6b:	5d                   	pop    %ebp
f0102c6c:	c3                   	ret    
f0102c6d:	00 00                	add    %al,(%eax)
	...

f0102c70 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102c70:	55                   	push   %ebp
f0102c71:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c73:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c78:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c7b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102c7c:	b2 71                	mov    $0x71,%dl
f0102c7e:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102c7f:	0f b6 c0             	movzbl %al,%eax
}
f0102c82:	5d                   	pop    %ebp
f0102c83:	c3                   	ret    

f0102c84 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102c84:	55                   	push   %ebp
f0102c85:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102c87:	ba 70 00 00 00       	mov    $0x70,%edx
f0102c8c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102c8f:	ee                   	out    %al,(%dx)
f0102c90:	b2 71                	mov    $0x71,%dl
f0102c92:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c95:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102c96:	5d                   	pop    %ebp
f0102c97:	c3                   	ret    

f0102c98 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102c98:	55                   	push   %ebp
f0102c99:	89 e5                	mov    %esp,%ebp
f0102c9b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102c9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ca1:	89 04 24             	mov    %eax,(%esp)
f0102ca4:	e8 0f d9 ff ff       	call   f01005b8 <cputchar>
	*cnt++;
}
f0102ca9:	c9                   	leave  
f0102caa:	c3                   	ret    

f0102cab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102cab:	55                   	push   %ebp
f0102cac:	89 e5                	mov    %esp,%ebp
f0102cae:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102cb1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102cbf:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cc2:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102cc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102cc9:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ccd:	c7 04 24 98 2c 10 f0 	movl   $0xf0102c98,(%esp)
f0102cd4:	e8 69 04 00 00       	call   f0103142 <vprintfmt>
	return cnt;
}
f0102cd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102cdc:	c9                   	leave  
f0102cdd:	c3                   	ret    

f0102cde <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102cde:	55                   	push   %ebp
f0102cdf:	89 e5                	mov    %esp,%ebp
f0102ce1:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102ce4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102ceb:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cee:	89 04 24             	mov    %eax,(%esp)
f0102cf1:	e8 b5 ff ff ff       	call   f0102cab <vcprintf>
	va_end(ap);

	return cnt;
}
f0102cf6:	c9                   	leave  
f0102cf7:	c3                   	ret    

f0102cf8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102cf8:	55                   	push   %ebp
f0102cf9:	89 e5                	mov    %esp,%ebp
f0102cfb:	57                   	push   %edi
f0102cfc:	56                   	push   %esi
f0102cfd:	53                   	push   %ebx
f0102cfe:	83 ec 10             	sub    $0x10,%esp
f0102d01:	89 c3                	mov    %eax,%ebx
f0102d03:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102d06:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102d09:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d0c:	8b 0a                	mov    (%edx),%ecx
f0102d0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d11:	8b 00                	mov    (%eax),%eax
f0102d13:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102d16:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102d1d:	eb 77                	jmp    f0102d96 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0102d1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102d22:	01 c8                	add    %ecx,%eax
f0102d24:	bf 02 00 00 00       	mov    $0x2,%edi
f0102d29:	99                   	cltd   
f0102d2a:	f7 ff                	idiv   %edi
f0102d2c:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d2e:	eb 01                	jmp    f0102d31 <stab_binsearch+0x39>
			m--;
f0102d30:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d31:	39 ca                	cmp    %ecx,%edx
f0102d33:	7c 1d                	jl     f0102d52 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102d35:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102d38:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0102d3d:	39 f7                	cmp    %esi,%edi
f0102d3f:	75 ef                	jne    f0102d30 <stab_binsearch+0x38>
f0102d41:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102d44:	6b fa 0c             	imul   $0xc,%edx,%edi
f0102d47:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0102d4b:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102d4e:	73 18                	jae    f0102d68 <stab_binsearch+0x70>
f0102d50:	eb 05                	jmp    f0102d57 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102d52:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0102d55:	eb 3f                	jmp    f0102d96 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102d57:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102d5a:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0102d5c:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d5f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102d66:	eb 2e                	jmp    f0102d96 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102d68:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102d6b:	76 15                	jbe    f0102d82 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0102d6d:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102d70:	4f                   	dec    %edi
f0102d71:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0102d74:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d77:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d79:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102d80:	eb 14                	jmp    f0102d96 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102d82:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102d85:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102d88:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0102d8a:	ff 45 0c             	incl   0xc(%ebp)
f0102d8d:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102d8f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102d96:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0102d99:	7e 84                	jle    f0102d1f <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102d9b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102d9f:	75 0d                	jne    f0102dae <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0102da1:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102da4:	8b 02                	mov    (%edx),%eax
f0102da6:	48                   	dec    %eax
f0102da7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102daa:	89 01                	mov    %eax,(%ecx)
f0102dac:	eb 22                	jmp    f0102dd0 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102dae:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102db1:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102db3:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102db6:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102db8:	eb 01                	jmp    f0102dbb <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102dba:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102dbb:	39 c1                	cmp    %eax,%ecx
f0102dbd:	7d 0c                	jge    f0102dcb <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102dbf:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0102dc2:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0102dc7:	39 f2                	cmp    %esi,%edx
f0102dc9:	75 ef                	jne    f0102dba <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102dcb:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102dce:	89 02                	mov    %eax,(%edx)
	}
}
f0102dd0:	83 c4 10             	add    $0x10,%esp
f0102dd3:	5b                   	pop    %ebx
f0102dd4:	5e                   	pop    %esi
f0102dd5:	5f                   	pop    %edi
f0102dd6:	5d                   	pop    %ebp
f0102dd7:	c3                   	ret    

f0102dd8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102dd8:	55                   	push   %ebp
f0102dd9:	89 e5                	mov    %esp,%ebp
f0102ddb:	57                   	push   %edi
f0102ddc:	56                   	push   %esi
f0102ddd:	53                   	push   %ebx
f0102dde:	83 ec 4c             	sub    $0x4c,%esp
f0102de1:	8b 75 08             	mov    0x8(%ebp),%esi
f0102de4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102de7:	c7 03 b6 4b 10 f0    	movl   $0xf0104bb6,(%ebx)
	info->eip_line = 0;
f0102ded:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102df4:	c7 43 08 b6 4b 10 f0 	movl   $0xf0104bb6,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102dfb:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102e02:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102e05:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102e0c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102e12:	76 12                	jbe    f0102e26 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102e14:	b8 dd 48 11 f0       	mov    $0xf01148dd,%eax
f0102e19:	3d 95 b7 10 f0       	cmp    $0xf010b795,%eax
f0102e1e:	0f 86 a7 01 00 00    	jbe    f0102fcb <debuginfo_eip+0x1f3>
f0102e24:	eb 1c                	jmp    f0102e42 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102e26:	c7 44 24 08 c0 4b 10 	movl   $0xf0104bc0,0x8(%esp)
f0102e2d:	f0 
f0102e2e:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102e35:	00 
f0102e36:	c7 04 24 cd 4b 10 f0 	movl   $0xf0104bcd,(%esp)
f0102e3d:	e8 52 d2 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102e42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102e47:	80 3d dc 48 11 f0 00 	cmpb   $0x0,0xf01148dc
f0102e4e:	0f 85 83 01 00 00    	jne    f0102fd7 <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102e54:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102e5b:	b8 94 b7 10 f0       	mov    $0xf010b794,%eax
f0102e60:	2d ec 4d 10 f0       	sub    $0xf0104dec,%eax
f0102e65:	c1 f8 02             	sar    $0x2,%eax
f0102e68:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102e6e:	48                   	dec    %eax
f0102e6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102e72:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102e76:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102e7d:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102e80:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102e83:	b8 ec 4d 10 f0       	mov    $0xf0104dec,%eax
f0102e88:	e8 6b fe ff ff       	call   f0102cf8 <stab_binsearch>
	if (lfile == 0)
f0102e8d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0102e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102e95:	85 d2                	test   %edx,%edx
f0102e97:	0f 84 3a 01 00 00    	je     f0102fd7 <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102e9d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102ea0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ea3:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102ea6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102eaa:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102eb1:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102eb4:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102eb7:	b8 ec 4d 10 f0       	mov    $0xf0104dec,%eax
f0102ebc:	e8 37 fe ff ff       	call   f0102cf8 <stab_binsearch>

	if (lfun <= rfun) {
f0102ec1:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102ec4:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102ec7:	39 d0                	cmp    %edx,%eax
f0102ec9:	7f 3e                	jg     f0102f09 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102ecb:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0102ece:	8d b9 ec 4d 10 f0    	lea    -0xfefb214(%ecx),%edi
f0102ed4:	8b 89 ec 4d 10 f0    	mov    -0xfefb214(%ecx),%ecx
f0102eda:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0102edd:	b9 dd 48 11 f0       	mov    $0xf01148dd,%ecx
f0102ee2:	81 e9 95 b7 10 f0    	sub    $0xf010b795,%ecx
f0102ee8:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0102eeb:	73 0c                	jae    f0102ef9 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102eed:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0102ef0:	81 c1 95 b7 10 f0    	add    $0xf010b795,%ecx
f0102ef6:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102ef9:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102efc:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102eff:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102f01:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102f04:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102f07:	eb 0f                	jmp    f0102f18 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102f09:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102f0c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f0f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102f12:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f15:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102f18:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102f1f:	00 
f0102f20:	8b 43 08             	mov    0x8(%ebx),%eax
f0102f23:	89 04 24             	mov    %eax,(%esp)
f0102f26:	e8 3f 08 00 00       	call   f010376a <strfind>
f0102f2b:	2b 43 08             	sub    0x8(%ebx),%eax
f0102f2e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102f31:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f35:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0102f3c:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102f3f:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102f42:	b8 ec 4d 10 f0       	mov    $0xf0104dec,%eax
f0102f47:	e8 ac fd ff ff       	call   f0102cf8 <stab_binsearch>
	if (lline > rline) {
f0102f4c:	8b 55 d0             	mov    -0x30(%ebp),%edx
		return -1;
f0102f4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
f0102f54:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102f57:	7f 7e                	jg     f0102fd7 <debuginfo_eip+0x1ff>
		return -1;
	}
	info->eip_line = stabs[rline].n_desc;
f0102f59:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102f5c:	0f b7 82 f2 4d 10 f0 	movzwl -0xfefb20e(%edx),%eax
f0102f63:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102f66:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102f69:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102f6c:	eb 01                	jmp    f0102f6f <debuginfo_eip+0x197>
f0102f6e:	48                   	dec    %eax
f0102f6f:	89 c6                	mov    %eax,%esi
f0102f71:	39 c7                	cmp    %eax,%edi
f0102f73:	7f 26                	jg     f0102f9b <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0102f75:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102f78:	8d 0c 95 ec 4d 10 f0 	lea    -0xfefb214(,%edx,4),%ecx
f0102f7f:	8a 51 04             	mov    0x4(%ecx),%dl
f0102f82:	80 fa 84             	cmp    $0x84,%dl
f0102f85:	74 58                	je     f0102fdf <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102f87:	80 fa 64             	cmp    $0x64,%dl
f0102f8a:	75 e2                	jne    f0102f6e <debuginfo_eip+0x196>
f0102f8c:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0102f90:	74 dc                	je     f0102f6e <debuginfo_eip+0x196>
f0102f92:	eb 4b                	jmp    f0102fdf <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102f94:	05 95 b7 10 f0       	add    $0xf010b795,%eax
f0102f99:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102f9b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102f9e:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102fa1:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102fa6:	39 d1                	cmp    %edx,%ecx
f0102fa8:	7d 2d                	jge    f0102fd7 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f0102faa:	8d 41 01             	lea    0x1(%ecx),%eax
f0102fad:	eb 03                	jmp    f0102fb2 <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0102faf:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102fb2:	39 d0                	cmp    %edx,%eax
f0102fb4:	7d 1c                	jge    f0102fd2 <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102fb6:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102fb9:	40                   	inc    %eax
f0102fba:	80 3c 8d f0 4d 10 f0 	cmpb   $0xa0,-0xfefb210(,%ecx,4)
f0102fc1:	a0 
f0102fc2:	74 eb                	je     f0102faf <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102fc4:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fc9:	eb 0c                	jmp    f0102fd7 <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102fcb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102fd0:	eb 05                	jmp    f0102fd7 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102fd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102fd7:	83 c4 4c             	add    $0x4c,%esp
f0102fda:	5b                   	pop    %ebx
f0102fdb:	5e                   	pop    %esi
f0102fdc:	5f                   	pop    %edi
f0102fdd:	5d                   	pop    %ebp
f0102fde:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0102fdf:	6b f6 0c             	imul   $0xc,%esi,%esi
f0102fe2:	8b 86 ec 4d 10 f0    	mov    -0xfefb214(%esi),%eax
f0102fe8:	ba dd 48 11 f0       	mov    $0xf01148dd,%edx
f0102fed:	81 ea 95 b7 10 f0    	sub    $0xf010b795,%edx
f0102ff3:	39 d0                	cmp    %edx,%eax
f0102ff5:	72 9d                	jb     f0102f94 <debuginfo_eip+0x1bc>
f0102ff7:	eb a2                	jmp    f0102f9b <debuginfo_eip+0x1c3>
f0102ff9:	00 00                	add    %al,(%eax)
	...

f0102ffc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102ffc:	55                   	push   %ebp
f0102ffd:	89 e5                	mov    %esp,%ebp
f0102fff:	57                   	push   %edi
f0103000:	56                   	push   %esi
f0103001:	53                   	push   %ebx
f0103002:	83 ec 3c             	sub    $0x3c,%esp
f0103005:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103008:	89 d7                	mov    %edx,%edi
f010300a:	8b 45 08             	mov    0x8(%ebp),%eax
f010300d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103010:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103013:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103016:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103019:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010301c:	85 c0                	test   %eax,%eax
f010301e:	75 08                	jne    f0103028 <printnum+0x2c>
f0103020:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0103023:	39 45 10             	cmp    %eax,0x10(%ebp)
f0103026:	77 57                	ja     f010307f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103028:	89 74 24 10          	mov    %esi,0x10(%esp)
f010302c:	4b                   	dec    %ebx
f010302d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0103031:	8b 45 10             	mov    0x10(%ebp),%eax
f0103034:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103038:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f010303c:	8b 74 24 0c          	mov    0xc(%esp),%esi
f0103040:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0103047:	00 
f0103048:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010304b:	89 04 24             	mov    %eax,(%esp)
f010304e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103051:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103055:	e8 1e 09 00 00       	call   f0103978 <__udivdi3>
f010305a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010305e:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0103062:	89 04 24             	mov    %eax,(%esp)
f0103065:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103069:	89 fa                	mov    %edi,%edx
f010306b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010306e:	e8 89 ff ff ff       	call   f0102ffc <printnum>
f0103073:	eb 0f                	jmp    f0103084 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103075:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103079:	89 34 24             	mov    %esi,(%esp)
f010307c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010307f:	4b                   	dec    %ebx
f0103080:	85 db                	test   %ebx,%ebx
f0103082:	7f f1                	jg     f0103075 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103084:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103088:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010308c:	8b 45 10             	mov    0x10(%ebp),%eax
f010308f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103093:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010309a:	00 
f010309b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010309e:	89 04 24             	mov    %eax,(%esp)
f01030a1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030a4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030a8:	e8 eb 09 00 00       	call   f0103a98 <__umoddi3>
f01030ad:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01030b1:	0f be 80 db 4b 10 f0 	movsbl -0xfefb425(%eax),%eax
f01030b8:	89 04 24             	mov    %eax,(%esp)
f01030bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
f01030be:	83 c4 3c             	add    $0x3c,%esp
f01030c1:	5b                   	pop    %ebx
f01030c2:	5e                   	pop    %esi
f01030c3:	5f                   	pop    %edi
f01030c4:	5d                   	pop    %ebp
f01030c5:	c3                   	ret    

f01030c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01030c6:	55                   	push   %ebp
f01030c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01030c9:	83 fa 01             	cmp    $0x1,%edx
f01030cc:	7e 0e                	jle    f01030dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01030ce:	8b 10                	mov    (%eax),%edx
f01030d0:	8d 4a 08             	lea    0x8(%edx),%ecx
f01030d3:	89 08                	mov    %ecx,(%eax)
f01030d5:	8b 02                	mov    (%edx),%eax
f01030d7:	8b 52 04             	mov    0x4(%edx),%edx
f01030da:	eb 22                	jmp    f01030fe <getuint+0x38>
	else if (lflag)
f01030dc:	85 d2                	test   %edx,%edx
f01030de:	74 10                	je     f01030f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01030e0:	8b 10                	mov    (%eax),%edx
f01030e2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01030e5:	89 08                	mov    %ecx,(%eax)
f01030e7:	8b 02                	mov    (%edx),%eax
f01030e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01030ee:	eb 0e                	jmp    f01030fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01030f0:	8b 10                	mov    (%eax),%edx
f01030f2:	8d 4a 04             	lea    0x4(%edx),%ecx
f01030f5:	89 08                	mov    %ecx,(%eax)
f01030f7:	8b 02                	mov    (%edx),%eax
f01030f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01030fe:	5d                   	pop    %ebp
f01030ff:	c3                   	ret    

f0103100 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103100:	55                   	push   %ebp
f0103101:	89 e5                	mov    %esp,%ebp
f0103103:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103106:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103109:	8b 10                	mov    (%eax),%edx
f010310b:	3b 50 04             	cmp    0x4(%eax),%edx
f010310e:	73 08                	jae    f0103118 <sprintputch+0x18>
		*b->buf++ = ch;
f0103110:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103113:	88 0a                	mov    %cl,(%edx)
f0103115:	42                   	inc    %edx
f0103116:	89 10                	mov    %edx,(%eax)
}
f0103118:	5d                   	pop    %ebp
f0103119:	c3                   	ret    

f010311a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010311a:	55                   	push   %ebp
f010311b:	89 e5                	mov    %esp,%ebp
f010311d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f0103120:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103123:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103127:	8b 45 10             	mov    0x10(%ebp),%eax
f010312a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010312e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103131:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103135:	8b 45 08             	mov    0x8(%ebp),%eax
f0103138:	89 04 24             	mov    %eax,(%esp)
f010313b:	e8 02 00 00 00       	call   f0103142 <vprintfmt>
	va_end(ap);
}
f0103140:	c9                   	leave  
f0103141:	c3                   	ret    

f0103142 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103142:	55                   	push   %ebp
f0103143:	89 e5                	mov    %esp,%ebp
f0103145:	57                   	push   %edi
f0103146:	56                   	push   %esi
f0103147:	53                   	push   %ebx
f0103148:	83 ec 4c             	sub    $0x4c,%esp
f010314b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010314e:	8b 75 10             	mov    0x10(%ebp),%esi
f0103151:	eb 12                	jmp    f0103165 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103153:	85 c0                	test   %eax,%eax
f0103155:	0f 84 6b 03 00 00    	je     f01034c6 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f010315b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010315f:	89 04 24             	mov    %eax,(%esp)
f0103162:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103165:	0f b6 06             	movzbl (%esi),%eax
f0103168:	46                   	inc    %esi
f0103169:	83 f8 25             	cmp    $0x25,%eax
f010316c:	75 e5                	jne    f0103153 <vprintfmt+0x11>
f010316e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f0103172:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f0103179:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f010317e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103185:	b9 00 00 00 00       	mov    $0x0,%ecx
f010318a:	eb 26                	jmp    f01031b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010318c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010318f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0103193:	eb 1d                	jmp    f01031b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103195:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103198:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010319c:	eb 14                	jmp    f01031b2 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010319e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f01031a1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f01031a8:	eb 08                	jmp    f01031b2 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f01031aa:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f01031ad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031b2:	0f b6 06             	movzbl (%esi),%eax
f01031b5:	8d 56 01             	lea    0x1(%esi),%edx
f01031b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01031bb:	8a 16                	mov    (%esi),%dl
f01031bd:	83 ea 23             	sub    $0x23,%edx
f01031c0:	80 fa 55             	cmp    $0x55,%dl
f01031c3:	0f 87 e1 02 00 00    	ja     f01034aa <vprintfmt+0x368>
f01031c9:	0f b6 d2             	movzbl %dl,%edx
f01031cc:	ff 24 95 68 4c 10 f0 	jmp    *-0xfefb398(,%edx,4)
f01031d3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01031d6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01031db:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f01031de:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f01031e2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f01031e5:	8d 50 d0             	lea    -0x30(%eax),%edx
f01031e8:	83 fa 09             	cmp    $0x9,%edx
f01031eb:	77 2a                	ja     f0103217 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f01031ed:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f01031ee:	eb eb                	jmp    f01031db <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01031f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01031f3:	8d 50 04             	lea    0x4(%eax),%edx
f01031f6:	89 55 14             	mov    %edx,0x14(%ebp)
f01031f9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01031fb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f01031fe:	eb 17                	jmp    f0103217 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0103200:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103204:	78 98                	js     f010319e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103206:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103209:	eb a7                	jmp    f01031b2 <vprintfmt+0x70>
f010320b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010320e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103215:	eb 9b                	jmp    f01031b2 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0103217:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010321b:	79 95                	jns    f01031b2 <vprintfmt+0x70>
f010321d:	eb 8b                	jmp    f01031aa <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010321f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103220:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103223:	eb 8d                	jmp    f01031b2 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103225:	8b 45 14             	mov    0x14(%ebp),%eax
f0103228:	8d 50 04             	lea    0x4(%eax),%edx
f010322b:	89 55 14             	mov    %edx,0x14(%ebp)
f010322e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103232:	8b 00                	mov    (%eax),%eax
f0103234:	89 04 24             	mov    %eax,(%esp)
f0103237:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010323a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f010323d:	e9 23 ff ff ff       	jmp    f0103165 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103242:	8b 45 14             	mov    0x14(%ebp),%eax
f0103245:	8d 50 04             	lea    0x4(%eax),%edx
f0103248:	89 55 14             	mov    %edx,0x14(%ebp)
f010324b:	8b 00                	mov    (%eax),%eax
f010324d:	85 c0                	test   %eax,%eax
f010324f:	79 02                	jns    f0103253 <vprintfmt+0x111>
f0103251:	f7 d8                	neg    %eax
f0103253:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103255:	83 f8 06             	cmp    $0x6,%eax
f0103258:	7f 0b                	jg     f0103265 <vprintfmt+0x123>
f010325a:	8b 04 85 c0 4d 10 f0 	mov    -0xfefb240(,%eax,4),%eax
f0103261:	85 c0                	test   %eax,%eax
f0103263:	75 23                	jne    f0103288 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f0103265:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103269:	c7 44 24 08 f3 4b 10 	movl   $0xf0104bf3,0x8(%esp)
f0103270:	f0 
f0103271:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103275:	8b 45 08             	mov    0x8(%ebp),%eax
f0103278:	89 04 24             	mov    %eax,(%esp)
f010327b:	e8 9a fe ff ff       	call   f010311a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103280:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103283:	e9 dd fe ff ff       	jmp    f0103165 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103288:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010328c:	c7 44 24 08 0b 49 10 	movl   $0xf010490b,0x8(%esp)
f0103293:	f0 
f0103294:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103298:	8b 55 08             	mov    0x8(%ebp),%edx
f010329b:	89 14 24             	mov    %edx,(%esp)
f010329e:	e8 77 fe ff ff       	call   f010311a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01032a6:	e9 ba fe ff ff       	jmp    f0103165 <vprintfmt+0x23>
f01032ab:	89 f9                	mov    %edi,%ecx
f01032ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01032b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01032b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01032b6:	8d 50 04             	lea    0x4(%eax),%edx
f01032b9:	89 55 14             	mov    %edx,0x14(%ebp)
f01032bc:	8b 30                	mov    (%eax),%esi
f01032be:	85 f6                	test   %esi,%esi
f01032c0:	75 05                	jne    f01032c7 <vprintfmt+0x185>
				p = "(null)";
f01032c2:	be ec 4b 10 f0       	mov    $0xf0104bec,%esi
			if (width > 0 && padc != '-')
f01032c7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01032cb:	0f 8e 84 00 00 00    	jle    f0103355 <vprintfmt+0x213>
f01032d1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f01032d5:	74 7e                	je     f0103355 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f01032d7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01032db:	89 34 24             	mov    %esi,(%esp)
f01032de:	e8 53 03 00 00       	call   f0103636 <strnlen>
f01032e3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01032e6:	29 c2                	sub    %eax,%edx
f01032e8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f01032eb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f01032ef:	89 75 d0             	mov    %esi,-0x30(%ebp)
f01032f2:	89 7d cc             	mov    %edi,-0x34(%ebp)
f01032f5:	89 de                	mov    %ebx,%esi
f01032f7:	89 d3                	mov    %edx,%ebx
f01032f9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01032fb:	eb 0b                	jmp    f0103308 <vprintfmt+0x1c6>
					putch(padc, putdat);
f01032fd:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103301:	89 3c 24             	mov    %edi,(%esp)
f0103304:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103307:	4b                   	dec    %ebx
f0103308:	85 db                	test   %ebx,%ebx
f010330a:	7f f1                	jg     f01032fd <vprintfmt+0x1bb>
f010330c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010330f:	89 f3                	mov    %esi,%ebx
f0103311:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0103314:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103317:	85 c0                	test   %eax,%eax
f0103319:	79 05                	jns    f0103320 <vprintfmt+0x1de>
f010331b:	b8 00 00 00 00       	mov    $0x0,%eax
f0103320:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103323:	29 c2                	sub    %eax,%edx
f0103325:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0103328:	eb 2b                	jmp    f0103355 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010332a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f010332e:	74 18                	je     f0103348 <vprintfmt+0x206>
f0103330:	8d 50 e0             	lea    -0x20(%eax),%edx
f0103333:	83 fa 5e             	cmp    $0x5e,%edx
f0103336:	76 10                	jbe    f0103348 <vprintfmt+0x206>
					putch('?', putdat);
f0103338:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010333c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f0103343:	ff 55 08             	call   *0x8(%ebp)
f0103346:	eb 0a                	jmp    f0103352 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f0103348:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010334c:	89 04 24             	mov    %eax,(%esp)
f010334f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103352:	ff 4d e4             	decl   -0x1c(%ebp)
f0103355:	0f be 06             	movsbl (%esi),%eax
f0103358:	46                   	inc    %esi
f0103359:	85 c0                	test   %eax,%eax
f010335b:	74 21                	je     f010337e <vprintfmt+0x23c>
f010335d:	85 ff                	test   %edi,%edi
f010335f:	78 c9                	js     f010332a <vprintfmt+0x1e8>
f0103361:	4f                   	dec    %edi
f0103362:	79 c6                	jns    f010332a <vprintfmt+0x1e8>
f0103364:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103367:	89 de                	mov    %ebx,%esi
f0103369:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010336c:	eb 18                	jmp    f0103386 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010336e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103372:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0103379:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010337b:	4b                   	dec    %ebx
f010337c:	eb 08                	jmp    f0103386 <vprintfmt+0x244>
f010337e:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103381:	89 de                	mov    %ebx,%esi
f0103383:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103386:	85 db                	test   %ebx,%ebx
f0103388:	7f e4                	jg     f010336e <vprintfmt+0x22c>
f010338a:	89 7d 08             	mov    %edi,0x8(%ebp)
f010338d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010338f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103392:	e9 ce fd ff ff       	jmp    f0103165 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103397:	83 f9 01             	cmp    $0x1,%ecx
f010339a:	7e 10                	jle    f01033ac <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f010339c:	8b 45 14             	mov    0x14(%ebp),%eax
f010339f:	8d 50 08             	lea    0x8(%eax),%edx
f01033a2:	89 55 14             	mov    %edx,0x14(%ebp)
f01033a5:	8b 30                	mov    (%eax),%esi
f01033a7:	8b 78 04             	mov    0x4(%eax),%edi
f01033aa:	eb 26                	jmp    f01033d2 <vprintfmt+0x290>
	else if (lflag)
f01033ac:	85 c9                	test   %ecx,%ecx
f01033ae:	74 12                	je     f01033c2 <vprintfmt+0x280>
		return va_arg(*ap, long);
f01033b0:	8b 45 14             	mov    0x14(%ebp),%eax
f01033b3:	8d 50 04             	lea    0x4(%eax),%edx
f01033b6:	89 55 14             	mov    %edx,0x14(%ebp)
f01033b9:	8b 30                	mov    (%eax),%esi
f01033bb:	89 f7                	mov    %esi,%edi
f01033bd:	c1 ff 1f             	sar    $0x1f,%edi
f01033c0:	eb 10                	jmp    f01033d2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f01033c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01033c5:	8d 50 04             	lea    0x4(%eax),%edx
f01033c8:	89 55 14             	mov    %edx,0x14(%ebp)
f01033cb:	8b 30                	mov    (%eax),%esi
f01033cd:	89 f7                	mov    %esi,%edi
f01033cf:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01033d2:	85 ff                	test   %edi,%edi
f01033d4:	78 0a                	js     f01033e0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01033d6:	b8 0a 00 00 00       	mov    $0xa,%eax
f01033db:	e9 8c 00 00 00       	jmp    f010346c <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f01033e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033e4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f01033eb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f01033ee:	f7 de                	neg    %esi
f01033f0:	83 d7 00             	adc    $0x0,%edi
f01033f3:	f7 df                	neg    %edi
			}
			base = 10;
f01033f5:	b8 0a 00 00 00       	mov    $0xa,%eax
f01033fa:	eb 70                	jmp    f010346c <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01033fc:	89 ca                	mov    %ecx,%edx
f01033fe:	8d 45 14             	lea    0x14(%ebp),%eax
f0103401:	e8 c0 fc ff ff       	call   f01030c6 <getuint>
f0103406:	89 c6                	mov    %eax,%esi
f0103408:	89 d7                	mov    %edx,%edi
			base = 10;
f010340a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010340f:	eb 5b                	jmp    f010346c <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0103411:	89 ca                	mov    %ecx,%edx
f0103413:	8d 45 14             	lea    0x14(%ebp),%eax
f0103416:	e8 ab fc ff ff       	call   f01030c6 <getuint>
f010341b:	89 c6                	mov    %eax,%esi
f010341d:	89 d7                	mov    %edx,%edi
			base = 8;
f010341f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f0103424:	eb 46                	jmp    f010346c <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f0103426:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010342a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f0103431:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f0103434:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103438:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f010343f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103442:	8b 45 14             	mov    0x14(%ebp),%eax
f0103445:	8d 50 04             	lea    0x4(%eax),%edx
f0103448:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010344b:	8b 30                	mov    (%eax),%esi
f010344d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0103452:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103457:	eb 13                	jmp    f010346c <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103459:	89 ca                	mov    %ecx,%edx
f010345b:	8d 45 14             	lea    0x14(%ebp),%eax
f010345e:	e8 63 fc ff ff       	call   f01030c6 <getuint>
f0103463:	89 c6                	mov    %eax,%esi
f0103465:	89 d7                	mov    %edx,%edi
			base = 16;
f0103467:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f010346c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f0103470:	89 54 24 10          	mov    %edx,0x10(%esp)
f0103474:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0103477:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010347b:	89 44 24 08          	mov    %eax,0x8(%esp)
f010347f:	89 34 24             	mov    %esi,(%esp)
f0103482:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103486:	89 da                	mov    %ebx,%edx
f0103488:	8b 45 08             	mov    0x8(%ebp),%eax
f010348b:	e8 6c fb ff ff       	call   f0102ffc <printnum>
			break;
f0103490:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103493:	e9 cd fc ff ff       	jmp    f0103165 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103498:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010349c:	89 04 24             	mov    %eax,(%esp)
f010349f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01034a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01034a5:	e9 bb fc ff ff       	jmp    f0103165 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01034aa:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034ae:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f01034b5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f01034b8:	eb 01                	jmp    f01034bb <vprintfmt+0x379>
f01034ba:	4e                   	dec    %esi
f01034bb:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f01034bf:	75 f9                	jne    f01034ba <vprintfmt+0x378>
f01034c1:	e9 9f fc ff ff       	jmp    f0103165 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f01034c6:	83 c4 4c             	add    $0x4c,%esp
f01034c9:	5b                   	pop    %ebx
f01034ca:	5e                   	pop    %esi
f01034cb:	5f                   	pop    %edi
f01034cc:	5d                   	pop    %ebp
f01034cd:	c3                   	ret    

f01034ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01034ce:	55                   	push   %ebp
f01034cf:	89 e5                	mov    %esp,%ebp
f01034d1:	83 ec 28             	sub    $0x28,%esp
f01034d4:	8b 45 08             	mov    0x8(%ebp),%eax
f01034d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01034da:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01034dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01034e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01034e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01034eb:	85 c0                	test   %eax,%eax
f01034ed:	74 30                	je     f010351f <vsnprintf+0x51>
f01034ef:	85 d2                	test   %edx,%edx
f01034f1:	7e 33                	jle    f0103526 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01034f3:	8b 45 14             	mov    0x14(%ebp),%eax
f01034f6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034fa:	8b 45 10             	mov    0x10(%ebp),%eax
f01034fd:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103501:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103504:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103508:	c7 04 24 00 31 10 f0 	movl   $0xf0103100,(%esp)
f010350f:	e8 2e fc ff ff       	call   f0103142 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103514:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103517:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010351a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010351d:	eb 0c                	jmp    f010352b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010351f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0103524:	eb 05                	jmp    f010352b <vsnprintf+0x5d>
f0103526:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010352b:	c9                   	leave  
f010352c:	c3                   	ret    

f010352d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010352d:	55                   	push   %ebp
f010352e:	89 e5                	mov    %esp,%ebp
f0103530:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103533:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103536:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010353a:	8b 45 10             	mov    0x10(%ebp),%eax
f010353d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103541:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103544:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103548:	8b 45 08             	mov    0x8(%ebp),%eax
f010354b:	89 04 24             	mov    %eax,(%esp)
f010354e:	e8 7b ff ff ff       	call   f01034ce <vsnprintf>
	va_end(ap);

	return rc;
}
f0103553:	c9                   	leave  
f0103554:	c3                   	ret    
f0103555:	00 00                	add    %al,(%eax)
	...

f0103558 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103558:	55                   	push   %ebp
f0103559:	89 e5                	mov    %esp,%ebp
f010355b:	57                   	push   %edi
f010355c:	56                   	push   %esi
f010355d:	53                   	push   %ebx
f010355e:	83 ec 1c             	sub    $0x1c,%esp
f0103561:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103564:	85 c0                	test   %eax,%eax
f0103566:	74 10                	je     f0103578 <readline+0x20>
		cprintf("%s", prompt);
f0103568:	89 44 24 04          	mov    %eax,0x4(%esp)
f010356c:	c7 04 24 0b 49 10 f0 	movl   $0xf010490b,(%esp)
f0103573:	e8 66 f7 ff ff       	call   f0102cde <cprintf>

	i = 0;
	echoing = iscons(0);
f0103578:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010357f:	e8 55 d0 ff ff       	call   f01005d9 <iscons>
f0103584:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103586:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010358b:	e8 38 d0 ff ff       	call   f01005c8 <getchar>
f0103590:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103592:	85 c0                	test   %eax,%eax
f0103594:	79 17                	jns    f01035ad <readline+0x55>
			cprintf("read error: %e\n", c);
f0103596:	89 44 24 04          	mov    %eax,0x4(%esp)
f010359a:	c7 04 24 dc 4d 10 f0 	movl   $0xf0104ddc,(%esp)
f01035a1:	e8 38 f7 ff ff       	call   f0102cde <cprintf>
			return NULL;
f01035a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01035ab:	eb 69                	jmp    f0103616 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01035ad:	83 f8 08             	cmp    $0x8,%eax
f01035b0:	74 05                	je     f01035b7 <readline+0x5f>
f01035b2:	83 f8 7f             	cmp    $0x7f,%eax
f01035b5:	75 17                	jne    f01035ce <readline+0x76>
f01035b7:	85 f6                	test   %esi,%esi
f01035b9:	7e 13                	jle    f01035ce <readline+0x76>
			if (echoing)
f01035bb:	85 ff                	test   %edi,%edi
f01035bd:	74 0c                	je     f01035cb <readline+0x73>
				cputchar('\b');
f01035bf:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f01035c6:	e8 ed cf ff ff       	call   f01005b8 <cputchar>
			i--;
f01035cb:	4e                   	dec    %esi
f01035cc:	eb bd                	jmp    f010358b <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01035ce:	83 fb 1f             	cmp    $0x1f,%ebx
f01035d1:	7e 1d                	jle    f01035f0 <readline+0x98>
f01035d3:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01035d9:	7f 15                	jg     f01035f0 <readline+0x98>
			if (echoing)
f01035db:	85 ff                	test   %edi,%edi
f01035dd:	74 08                	je     f01035e7 <readline+0x8f>
				cputchar(c);
f01035df:	89 1c 24             	mov    %ebx,(%esp)
f01035e2:	e8 d1 cf ff ff       	call   f01005b8 <cputchar>
			buf[i++] = c;
f01035e7:	88 9e 60 f5 11 f0    	mov    %bl,-0xfee0aa0(%esi)
f01035ed:	46                   	inc    %esi
f01035ee:	eb 9b                	jmp    f010358b <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f01035f0:	83 fb 0a             	cmp    $0xa,%ebx
f01035f3:	74 05                	je     f01035fa <readline+0xa2>
f01035f5:	83 fb 0d             	cmp    $0xd,%ebx
f01035f8:	75 91                	jne    f010358b <readline+0x33>
			if (echoing)
f01035fa:	85 ff                	test   %edi,%edi
f01035fc:	74 0c                	je     f010360a <readline+0xb2>
				cputchar('\n');
f01035fe:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103605:	e8 ae cf ff ff       	call   f01005b8 <cputchar>
			buf[i] = 0;
f010360a:	c6 86 60 f5 11 f0 00 	movb   $0x0,-0xfee0aa0(%esi)
			return buf;
f0103611:	b8 60 f5 11 f0       	mov    $0xf011f560,%eax
		}
	}
}
f0103616:	83 c4 1c             	add    $0x1c,%esp
f0103619:	5b                   	pop    %ebx
f010361a:	5e                   	pop    %esi
f010361b:	5f                   	pop    %edi
f010361c:	5d                   	pop    %ebp
f010361d:	c3                   	ret    
	...

f0103620 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0103620:	55                   	push   %ebp
f0103621:	89 e5                	mov    %esp,%ebp
f0103623:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0103626:	b8 00 00 00 00       	mov    $0x0,%eax
f010362b:	eb 01                	jmp    f010362e <strlen+0xe>
		n++;
f010362d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010362e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0103632:	75 f9                	jne    f010362d <strlen+0xd>
		n++;
	return n;
}
f0103634:	5d                   	pop    %ebp
f0103635:	c3                   	ret    

f0103636 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103636:	55                   	push   %ebp
f0103637:	89 e5                	mov    %esp,%ebp
f0103639:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f010363c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010363f:	b8 00 00 00 00       	mov    $0x0,%eax
f0103644:	eb 01                	jmp    f0103647 <strnlen+0x11>
		n++;
f0103646:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103647:	39 d0                	cmp    %edx,%eax
f0103649:	74 06                	je     f0103651 <strnlen+0x1b>
f010364b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f010364f:	75 f5                	jne    f0103646 <strnlen+0x10>
		n++;
	return n;
}
f0103651:	5d                   	pop    %ebp
f0103652:	c3                   	ret    

f0103653 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103653:	55                   	push   %ebp
f0103654:	89 e5                	mov    %esp,%ebp
f0103656:	53                   	push   %ebx
f0103657:	8b 45 08             	mov    0x8(%ebp),%eax
f010365a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010365d:	ba 00 00 00 00       	mov    $0x0,%edx
f0103662:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f0103665:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0103668:	42                   	inc    %edx
f0103669:	84 c9                	test   %cl,%cl
f010366b:	75 f5                	jne    f0103662 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f010366d:	5b                   	pop    %ebx
f010366e:	5d                   	pop    %ebp
f010366f:	c3                   	ret    

f0103670 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103670:	55                   	push   %ebp
f0103671:	89 e5                	mov    %esp,%ebp
f0103673:	53                   	push   %ebx
f0103674:	83 ec 08             	sub    $0x8,%esp
f0103677:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010367a:	89 1c 24             	mov    %ebx,(%esp)
f010367d:	e8 9e ff ff ff       	call   f0103620 <strlen>
	strcpy(dst + len, src);
f0103682:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103685:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103689:	01 d8                	add    %ebx,%eax
f010368b:	89 04 24             	mov    %eax,(%esp)
f010368e:	e8 c0 ff ff ff       	call   f0103653 <strcpy>
	return dst;
}
f0103693:	89 d8                	mov    %ebx,%eax
f0103695:	83 c4 08             	add    $0x8,%esp
f0103698:	5b                   	pop    %ebx
f0103699:	5d                   	pop    %ebp
f010369a:	c3                   	ret    

f010369b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010369b:	55                   	push   %ebp
f010369c:	89 e5                	mov    %esp,%ebp
f010369e:	56                   	push   %esi
f010369f:	53                   	push   %ebx
f01036a0:	8b 45 08             	mov    0x8(%ebp),%eax
f01036a3:	8b 55 0c             	mov    0xc(%ebp),%edx
f01036a6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01036a9:	b9 00 00 00 00       	mov    $0x0,%ecx
f01036ae:	eb 0c                	jmp    f01036bc <strncpy+0x21>
		*dst++ = *src;
f01036b0:	8a 1a                	mov    (%edx),%bl
f01036b2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01036b5:	80 3a 01             	cmpb   $0x1,(%edx)
f01036b8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01036bb:	41                   	inc    %ecx
f01036bc:	39 f1                	cmp    %esi,%ecx
f01036be:	75 f0                	jne    f01036b0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01036c0:	5b                   	pop    %ebx
f01036c1:	5e                   	pop    %esi
f01036c2:	5d                   	pop    %ebp
f01036c3:	c3                   	ret    

f01036c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01036c4:	55                   	push   %ebp
f01036c5:	89 e5                	mov    %esp,%ebp
f01036c7:	56                   	push   %esi
f01036c8:	53                   	push   %ebx
f01036c9:	8b 75 08             	mov    0x8(%ebp),%esi
f01036cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01036cf:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01036d2:	85 d2                	test   %edx,%edx
f01036d4:	75 0a                	jne    f01036e0 <strlcpy+0x1c>
f01036d6:	89 f0                	mov    %esi,%eax
f01036d8:	eb 1a                	jmp    f01036f4 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01036da:	88 18                	mov    %bl,(%eax)
f01036dc:	40                   	inc    %eax
f01036dd:	41                   	inc    %ecx
f01036de:	eb 02                	jmp    f01036e2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01036e0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f01036e2:	4a                   	dec    %edx
f01036e3:	74 0a                	je     f01036ef <strlcpy+0x2b>
f01036e5:	8a 19                	mov    (%ecx),%bl
f01036e7:	84 db                	test   %bl,%bl
f01036e9:	75 ef                	jne    f01036da <strlcpy+0x16>
f01036eb:	89 c2                	mov    %eax,%edx
f01036ed:	eb 02                	jmp    f01036f1 <strlcpy+0x2d>
f01036ef:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f01036f1:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f01036f4:	29 f0                	sub    %esi,%eax
}
f01036f6:	5b                   	pop    %ebx
f01036f7:	5e                   	pop    %esi
f01036f8:	5d                   	pop    %ebp
f01036f9:	c3                   	ret    

f01036fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01036fa:	55                   	push   %ebp
f01036fb:	89 e5                	mov    %esp,%ebp
f01036fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103700:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103703:	eb 02                	jmp    f0103707 <strcmp+0xd>
		p++, q++;
f0103705:	41                   	inc    %ecx
f0103706:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103707:	8a 01                	mov    (%ecx),%al
f0103709:	84 c0                	test   %al,%al
f010370b:	74 04                	je     f0103711 <strcmp+0x17>
f010370d:	3a 02                	cmp    (%edx),%al
f010370f:	74 f4                	je     f0103705 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103711:	0f b6 c0             	movzbl %al,%eax
f0103714:	0f b6 12             	movzbl (%edx),%edx
f0103717:	29 d0                	sub    %edx,%eax
}
f0103719:	5d                   	pop    %ebp
f010371a:	c3                   	ret    

f010371b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010371b:	55                   	push   %ebp
f010371c:	89 e5                	mov    %esp,%ebp
f010371e:	53                   	push   %ebx
f010371f:	8b 45 08             	mov    0x8(%ebp),%eax
f0103722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103725:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f0103728:	eb 03                	jmp    f010372d <strncmp+0x12>
		n--, p++, q++;
f010372a:	4a                   	dec    %edx
f010372b:	40                   	inc    %eax
f010372c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010372d:	85 d2                	test   %edx,%edx
f010372f:	74 14                	je     f0103745 <strncmp+0x2a>
f0103731:	8a 18                	mov    (%eax),%bl
f0103733:	84 db                	test   %bl,%bl
f0103735:	74 04                	je     f010373b <strncmp+0x20>
f0103737:	3a 19                	cmp    (%ecx),%bl
f0103739:	74 ef                	je     f010372a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010373b:	0f b6 00             	movzbl (%eax),%eax
f010373e:	0f b6 11             	movzbl (%ecx),%edx
f0103741:	29 d0                	sub    %edx,%eax
f0103743:	eb 05                	jmp    f010374a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103745:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010374a:	5b                   	pop    %ebx
f010374b:	5d                   	pop    %ebp
f010374c:	c3                   	ret    

f010374d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010374d:	55                   	push   %ebp
f010374e:	89 e5                	mov    %esp,%ebp
f0103750:	8b 45 08             	mov    0x8(%ebp),%eax
f0103753:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103756:	eb 05                	jmp    f010375d <strchr+0x10>
		if (*s == c)
f0103758:	38 ca                	cmp    %cl,%dl
f010375a:	74 0c                	je     f0103768 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010375c:	40                   	inc    %eax
f010375d:	8a 10                	mov    (%eax),%dl
f010375f:	84 d2                	test   %dl,%dl
f0103761:	75 f5                	jne    f0103758 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f0103763:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103768:	5d                   	pop    %ebp
f0103769:	c3                   	ret    

f010376a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010376a:	55                   	push   %ebp
f010376b:	89 e5                	mov    %esp,%ebp
f010376d:	8b 45 08             	mov    0x8(%ebp),%eax
f0103770:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f0103773:	eb 05                	jmp    f010377a <strfind+0x10>
		if (*s == c)
f0103775:	38 ca                	cmp    %cl,%dl
f0103777:	74 07                	je     f0103780 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103779:	40                   	inc    %eax
f010377a:	8a 10                	mov    (%eax),%dl
f010377c:	84 d2                	test   %dl,%dl
f010377e:	75 f5                	jne    f0103775 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0103780:	5d                   	pop    %ebp
f0103781:	c3                   	ret    

f0103782 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103782:	55                   	push   %ebp
f0103783:	89 e5                	mov    %esp,%ebp
f0103785:	57                   	push   %edi
f0103786:	56                   	push   %esi
f0103787:	53                   	push   %ebx
f0103788:	8b 7d 08             	mov    0x8(%ebp),%edi
f010378b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010378e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103791:	85 c9                	test   %ecx,%ecx
f0103793:	74 30                	je     f01037c5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103795:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010379b:	75 25                	jne    f01037c2 <memset+0x40>
f010379d:	f6 c1 03             	test   $0x3,%cl
f01037a0:	75 20                	jne    f01037c2 <memset+0x40>
		c &= 0xFF;
f01037a2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01037a5:	89 d3                	mov    %edx,%ebx
f01037a7:	c1 e3 08             	shl    $0x8,%ebx
f01037aa:	89 d6                	mov    %edx,%esi
f01037ac:	c1 e6 18             	shl    $0x18,%esi
f01037af:	89 d0                	mov    %edx,%eax
f01037b1:	c1 e0 10             	shl    $0x10,%eax
f01037b4:	09 f0                	or     %esi,%eax
f01037b6:	09 d0                	or     %edx,%eax
f01037b8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01037ba:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01037bd:	fc                   	cld    
f01037be:	f3 ab                	rep stos %eax,%es:(%edi)
f01037c0:	eb 03                	jmp    f01037c5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01037c2:	fc                   	cld    
f01037c3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01037c5:	89 f8                	mov    %edi,%eax
f01037c7:	5b                   	pop    %ebx
f01037c8:	5e                   	pop    %esi
f01037c9:	5f                   	pop    %edi
f01037ca:	5d                   	pop    %ebp
f01037cb:	c3                   	ret    

f01037cc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01037cc:	55                   	push   %ebp
f01037cd:	89 e5                	mov    %esp,%ebp
f01037cf:	57                   	push   %edi
f01037d0:	56                   	push   %esi
f01037d1:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d4:	8b 75 0c             	mov    0xc(%ebp),%esi
f01037d7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01037da:	39 c6                	cmp    %eax,%esi
f01037dc:	73 34                	jae    f0103812 <memmove+0x46>
f01037de:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01037e1:	39 d0                	cmp    %edx,%eax
f01037e3:	73 2d                	jae    f0103812 <memmove+0x46>
		s += n;
		d += n;
f01037e5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01037e8:	f6 c2 03             	test   $0x3,%dl
f01037eb:	75 1b                	jne    f0103808 <memmove+0x3c>
f01037ed:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01037f3:	75 13                	jne    f0103808 <memmove+0x3c>
f01037f5:	f6 c1 03             	test   $0x3,%cl
f01037f8:	75 0e                	jne    f0103808 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01037fa:	83 ef 04             	sub    $0x4,%edi
f01037fd:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103800:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103803:	fd                   	std    
f0103804:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103806:	eb 07                	jmp    f010380f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103808:	4f                   	dec    %edi
f0103809:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010380c:	fd                   	std    
f010380d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010380f:	fc                   	cld    
f0103810:	eb 20                	jmp    f0103832 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103812:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103818:	75 13                	jne    f010382d <memmove+0x61>
f010381a:	a8 03                	test   $0x3,%al
f010381c:	75 0f                	jne    f010382d <memmove+0x61>
f010381e:	f6 c1 03             	test   $0x3,%cl
f0103821:	75 0a                	jne    f010382d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0103823:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0103826:	89 c7                	mov    %eax,%edi
f0103828:	fc                   	cld    
f0103829:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010382b:	eb 05                	jmp    f0103832 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010382d:	89 c7                	mov    %eax,%edi
f010382f:	fc                   	cld    
f0103830:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103832:	5e                   	pop    %esi
f0103833:	5f                   	pop    %edi
f0103834:	5d                   	pop    %ebp
f0103835:	c3                   	ret    

f0103836 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103836:	55                   	push   %ebp
f0103837:	89 e5                	mov    %esp,%ebp
f0103839:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f010383c:	8b 45 10             	mov    0x10(%ebp),%eax
f010383f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103843:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103846:	89 44 24 04          	mov    %eax,0x4(%esp)
f010384a:	8b 45 08             	mov    0x8(%ebp),%eax
f010384d:	89 04 24             	mov    %eax,(%esp)
f0103850:	e8 77 ff ff ff       	call   f01037cc <memmove>
}
f0103855:	c9                   	leave  
f0103856:	c3                   	ret    

f0103857 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103857:	55                   	push   %ebp
f0103858:	89 e5                	mov    %esp,%ebp
f010385a:	57                   	push   %edi
f010385b:	56                   	push   %esi
f010385c:	53                   	push   %ebx
f010385d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103860:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103863:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103866:	ba 00 00 00 00       	mov    $0x0,%edx
f010386b:	eb 16                	jmp    f0103883 <memcmp+0x2c>
		if (*s1 != *s2)
f010386d:	8a 04 17             	mov    (%edi,%edx,1),%al
f0103870:	42                   	inc    %edx
f0103871:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f0103875:	38 c8                	cmp    %cl,%al
f0103877:	74 0a                	je     f0103883 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f0103879:	0f b6 c0             	movzbl %al,%eax
f010387c:	0f b6 c9             	movzbl %cl,%ecx
f010387f:	29 c8                	sub    %ecx,%eax
f0103881:	eb 09                	jmp    f010388c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103883:	39 da                	cmp    %ebx,%edx
f0103885:	75 e6                	jne    f010386d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103887:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010388c:	5b                   	pop    %ebx
f010388d:	5e                   	pop    %esi
f010388e:	5f                   	pop    %edi
f010388f:	5d                   	pop    %ebp
f0103890:	c3                   	ret    

f0103891 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103891:	55                   	push   %ebp
f0103892:	89 e5                	mov    %esp,%ebp
f0103894:	8b 45 08             	mov    0x8(%ebp),%eax
f0103897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010389a:	89 c2                	mov    %eax,%edx
f010389c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010389f:	eb 05                	jmp    f01038a6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f01038a1:	38 08                	cmp    %cl,(%eax)
f01038a3:	74 05                	je     f01038aa <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01038a5:	40                   	inc    %eax
f01038a6:	39 d0                	cmp    %edx,%eax
f01038a8:	72 f7                	jb     f01038a1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01038aa:	5d                   	pop    %ebp
f01038ab:	c3                   	ret    

f01038ac <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01038ac:	55                   	push   %ebp
f01038ad:	89 e5                	mov    %esp,%ebp
f01038af:	57                   	push   %edi
f01038b0:	56                   	push   %esi
f01038b1:	53                   	push   %ebx
f01038b2:	8b 55 08             	mov    0x8(%ebp),%edx
f01038b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01038b8:	eb 01                	jmp    f01038bb <strtol+0xf>
		s++;
f01038ba:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01038bb:	8a 02                	mov    (%edx),%al
f01038bd:	3c 20                	cmp    $0x20,%al
f01038bf:	74 f9                	je     f01038ba <strtol+0xe>
f01038c1:	3c 09                	cmp    $0x9,%al
f01038c3:	74 f5                	je     f01038ba <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01038c5:	3c 2b                	cmp    $0x2b,%al
f01038c7:	75 08                	jne    f01038d1 <strtol+0x25>
		s++;
f01038c9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01038ca:	bf 00 00 00 00       	mov    $0x0,%edi
f01038cf:	eb 13                	jmp    f01038e4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01038d1:	3c 2d                	cmp    $0x2d,%al
f01038d3:	75 0a                	jne    f01038df <strtol+0x33>
		s++, neg = 1;
f01038d5:	8d 52 01             	lea    0x1(%edx),%edx
f01038d8:	bf 01 00 00 00       	mov    $0x1,%edi
f01038dd:	eb 05                	jmp    f01038e4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01038df:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01038e4:	85 db                	test   %ebx,%ebx
f01038e6:	74 05                	je     f01038ed <strtol+0x41>
f01038e8:	83 fb 10             	cmp    $0x10,%ebx
f01038eb:	75 28                	jne    f0103915 <strtol+0x69>
f01038ed:	8a 02                	mov    (%edx),%al
f01038ef:	3c 30                	cmp    $0x30,%al
f01038f1:	75 10                	jne    f0103903 <strtol+0x57>
f01038f3:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f01038f7:	75 0a                	jne    f0103903 <strtol+0x57>
		s += 2, base = 16;
f01038f9:	83 c2 02             	add    $0x2,%edx
f01038fc:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103901:	eb 12                	jmp    f0103915 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0103903:	85 db                	test   %ebx,%ebx
f0103905:	75 0e                	jne    f0103915 <strtol+0x69>
f0103907:	3c 30                	cmp    $0x30,%al
f0103909:	75 05                	jne    f0103910 <strtol+0x64>
		s++, base = 8;
f010390b:	42                   	inc    %edx
f010390c:	b3 08                	mov    $0x8,%bl
f010390e:	eb 05                	jmp    f0103915 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0103910:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103915:	b8 00 00 00 00       	mov    $0x0,%eax
f010391a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010391c:	8a 0a                	mov    (%edx),%cl
f010391e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0103921:	80 fb 09             	cmp    $0x9,%bl
f0103924:	77 08                	ja     f010392e <strtol+0x82>
			dig = *s - '0';
f0103926:	0f be c9             	movsbl %cl,%ecx
f0103929:	83 e9 30             	sub    $0x30,%ecx
f010392c:	eb 1e                	jmp    f010394c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f010392e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f0103931:	80 fb 19             	cmp    $0x19,%bl
f0103934:	77 08                	ja     f010393e <strtol+0x92>
			dig = *s - 'a' + 10;
f0103936:	0f be c9             	movsbl %cl,%ecx
f0103939:	83 e9 57             	sub    $0x57,%ecx
f010393c:	eb 0e                	jmp    f010394c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f010393e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f0103941:	80 fb 19             	cmp    $0x19,%bl
f0103944:	77 12                	ja     f0103958 <strtol+0xac>
			dig = *s - 'A' + 10;
f0103946:	0f be c9             	movsbl %cl,%ecx
f0103949:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f010394c:	39 f1                	cmp    %esi,%ecx
f010394e:	7d 0c                	jge    f010395c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f0103950:	42                   	inc    %edx
f0103951:	0f af c6             	imul   %esi,%eax
f0103954:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f0103956:	eb c4                	jmp    f010391c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f0103958:	89 c1                	mov    %eax,%ecx
f010395a:	eb 02                	jmp    f010395e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f010395c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f010395e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103962:	74 05                	je     f0103969 <strtol+0xbd>
		*endptr = (char *) s;
f0103964:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103967:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f0103969:	85 ff                	test   %edi,%edi
f010396b:	74 04                	je     f0103971 <strtol+0xc5>
f010396d:	89 c8                	mov    %ecx,%eax
f010396f:	f7 d8                	neg    %eax
}
f0103971:	5b                   	pop    %ebx
f0103972:	5e                   	pop    %esi
f0103973:	5f                   	pop    %edi
f0103974:	5d                   	pop    %ebp
f0103975:	c3                   	ret    
	...

f0103978 <__udivdi3>:
f0103978:	55                   	push   %ebp
f0103979:	57                   	push   %edi
f010397a:	56                   	push   %esi
f010397b:	83 ec 10             	sub    $0x10,%esp
f010397e:	8b 74 24 20          	mov    0x20(%esp),%esi
f0103982:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103986:	89 74 24 04          	mov    %esi,0x4(%esp)
f010398a:	8b 7c 24 24          	mov    0x24(%esp),%edi
f010398e:	89 cd                	mov    %ecx,%ebp
f0103990:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0103994:	85 c0                	test   %eax,%eax
f0103996:	75 2c                	jne    f01039c4 <__udivdi3+0x4c>
f0103998:	39 f9                	cmp    %edi,%ecx
f010399a:	77 68                	ja     f0103a04 <__udivdi3+0x8c>
f010399c:	85 c9                	test   %ecx,%ecx
f010399e:	75 0b                	jne    f01039ab <__udivdi3+0x33>
f01039a0:	b8 01 00 00 00       	mov    $0x1,%eax
f01039a5:	31 d2                	xor    %edx,%edx
f01039a7:	f7 f1                	div    %ecx
f01039a9:	89 c1                	mov    %eax,%ecx
f01039ab:	31 d2                	xor    %edx,%edx
f01039ad:	89 f8                	mov    %edi,%eax
f01039af:	f7 f1                	div    %ecx
f01039b1:	89 c7                	mov    %eax,%edi
f01039b3:	89 f0                	mov    %esi,%eax
f01039b5:	f7 f1                	div    %ecx
f01039b7:	89 c6                	mov    %eax,%esi
f01039b9:	89 f0                	mov    %esi,%eax
f01039bb:	89 fa                	mov    %edi,%edx
f01039bd:	83 c4 10             	add    $0x10,%esp
f01039c0:	5e                   	pop    %esi
f01039c1:	5f                   	pop    %edi
f01039c2:	5d                   	pop    %ebp
f01039c3:	c3                   	ret    
f01039c4:	39 f8                	cmp    %edi,%eax
f01039c6:	77 2c                	ja     f01039f4 <__udivdi3+0x7c>
f01039c8:	0f bd f0             	bsr    %eax,%esi
f01039cb:	83 f6 1f             	xor    $0x1f,%esi
f01039ce:	75 4c                	jne    f0103a1c <__udivdi3+0xa4>
f01039d0:	39 f8                	cmp    %edi,%eax
f01039d2:	bf 00 00 00 00       	mov    $0x0,%edi
f01039d7:	72 0a                	jb     f01039e3 <__udivdi3+0x6b>
f01039d9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f01039dd:	0f 87 ad 00 00 00    	ja     f0103a90 <__udivdi3+0x118>
f01039e3:	be 01 00 00 00       	mov    $0x1,%esi
f01039e8:	89 f0                	mov    %esi,%eax
f01039ea:	89 fa                	mov    %edi,%edx
f01039ec:	83 c4 10             	add    $0x10,%esp
f01039ef:	5e                   	pop    %esi
f01039f0:	5f                   	pop    %edi
f01039f1:	5d                   	pop    %ebp
f01039f2:	c3                   	ret    
f01039f3:	90                   	nop
f01039f4:	31 ff                	xor    %edi,%edi
f01039f6:	31 f6                	xor    %esi,%esi
f01039f8:	89 f0                	mov    %esi,%eax
f01039fa:	89 fa                	mov    %edi,%edx
f01039fc:	83 c4 10             	add    $0x10,%esp
f01039ff:	5e                   	pop    %esi
f0103a00:	5f                   	pop    %edi
f0103a01:	5d                   	pop    %ebp
f0103a02:	c3                   	ret    
f0103a03:	90                   	nop
f0103a04:	89 fa                	mov    %edi,%edx
f0103a06:	89 f0                	mov    %esi,%eax
f0103a08:	f7 f1                	div    %ecx
f0103a0a:	89 c6                	mov    %eax,%esi
f0103a0c:	31 ff                	xor    %edi,%edi
f0103a0e:	89 f0                	mov    %esi,%eax
f0103a10:	89 fa                	mov    %edi,%edx
f0103a12:	83 c4 10             	add    $0x10,%esp
f0103a15:	5e                   	pop    %esi
f0103a16:	5f                   	pop    %edi
f0103a17:	5d                   	pop    %ebp
f0103a18:	c3                   	ret    
f0103a19:	8d 76 00             	lea    0x0(%esi),%esi
f0103a1c:	89 f1                	mov    %esi,%ecx
f0103a1e:	d3 e0                	shl    %cl,%eax
f0103a20:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a24:	b8 20 00 00 00       	mov    $0x20,%eax
f0103a29:	29 f0                	sub    %esi,%eax
f0103a2b:	89 ea                	mov    %ebp,%edx
f0103a2d:	88 c1                	mov    %al,%cl
f0103a2f:	d3 ea                	shr    %cl,%edx
f0103a31:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0103a35:	09 ca                	or     %ecx,%edx
f0103a37:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103a3b:	89 f1                	mov    %esi,%ecx
f0103a3d:	d3 e5                	shl    %cl,%ebp
f0103a3f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0103a43:	89 fd                	mov    %edi,%ebp
f0103a45:	88 c1                	mov    %al,%cl
f0103a47:	d3 ed                	shr    %cl,%ebp
f0103a49:	89 fa                	mov    %edi,%edx
f0103a4b:	89 f1                	mov    %esi,%ecx
f0103a4d:	d3 e2                	shl    %cl,%edx
f0103a4f:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103a53:	88 c1                	mov    %al,%cl
f0103a55:	d3 ef                	shr    %cl,%edi
f0103a57:	09 d7                	or     %edx,%edi
f0103a59:	89 f8                	mov    %edi,%eax
f0103a5b:	89 ea                	mov    %ebp,%edx
f0103a5d:	f7 74 24 08          	divl   0x8(%esp)
f0103a61:	89 d1                	mov    %edx,%ecx
f0103a63:	89 c7                	mov    %eax,%edi
f0103a65:	f7 64 24 0c          	mull   0xc(%esp)
f0103a69:	39 d1                	cmp    %edx,%ecx
f0103a6b:	72 17                	jb     f0103a84 <__udivdi3+0x10c>
f0103a6d:	74 09                	je     f0103a78 <__udivdi3+0x100>
f0103a6f:	89 fe                	mov    %edi,%esi
f0103a71:	31 ff                	xor    %edi,%edi
f0103a73:	e9 41 ff ff ff       	jmp    f01039b9 <__udivdi3+0x41>
f0103a78:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103a7c:	89 f1                	mov    %esi,%ecx
f0103a7e:	d3 e2                	shl    %cl,%edx
f0103a80:	39 c2                	cmp    %eax,%edx
f0103a82:	73 eb                	jae    f0103a6f <__udivdi3+0xf7>
f0103a84:	8d 77 ff             	lea    -0x1(%edi),%esi
f0103a87:	31 ff                	xor    %edi,%edi
f0103a89:	e9 2b ff ff ff       	jmp    f01039b9 <__udivdi3+0x41>
f0103a8e:	66 90                	xchg   %ax,%ax
f0103a90:	31 f6                	xor    %esi,%esi
f0103a92:	e9 22 ff ff ff       	jmp    f01039b9 <__udivdi3+0x41>
	...

f0103a98 <__umoddi3>:
f0103a98:	55                   	push   %ebp
f0103a99:	57                   	push   %edi
f0103a9a:	56                   	push   %esi
f0103a9b:	83 ec 20             	sub    $0x20,%esp
f0103a9e:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103aa2:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0103aa6:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103aaa:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103aae:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103ab2:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103ab6:	89 c7                	mov    %eax,%edi
f0103ab8:	89 f2                	mov    %esi,%edx
f0103aba:	85 ed                	test   %ebp,%ebp
f0103abc:	75 16                	jne    f0103ad4 <__umoddi3+0x3c>
f0103abe:	39 f1                	cmp    %esi,%ecx
f0103ac0:	0f 86 a6 00 00 00    	jbe    f0103b6c <__umoddi3+0xd4>
f0103ac6:	f7 f1                	div    %ecx
f0103ac8:	89 d0                	mov    %edx,%eax
f0103aca:	31 d2                	xor    %edx,%edx
f0103acc:	83 c4 20             	add    $0x20,%esp
f0103acf:	5e                   	pop    %esi
f0103ad0:	5f                   	pop    %edi
f0103ad1:	5d                   	pop    %ebp
f0103ad2:	c3                   	ret    
f0103ad3:	90                   	nop
f0103ad4:	39 f5                	cmp    %esi,%ebp
f0103ad6:	0f 87 ac 00 00 00    	ja     f0103b88 <__umoddi3+0xf0>
f0103adc:	0f bd c5             	bsr    %ebp,%eax
f0103adf:	83 f0 1f             	xor    $0x1f,%eax
f0103ae2:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103ae6:	0f 84 a8 00 00 00    	je     f0103b94 <__umoddi3+0xfc>
f0103aec:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103af0:	d3 e5                	shl    %cl,%ebp
f0103af2:	bf 20 00 00 00       	mov    $0x20,%edi
f0103af7:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0103afb:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103aff:	89 f9                	mov    %edi,%ecx
f0103b01:	d3 e8                	shr    %cl,%eax
f0103b03:	09 e8                	or     %ebp,%eax
f0103b05:	89 44 24 18          	mov    %eax,0x18(%esp)
f0103b09:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103b0d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103b11:	d3 e0                	shl    %cl,%eax
f0103b13:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b17:	89 f2                	mov    %esi,%edx
f0103b19:	d3 e2                	shl    %cl,%edx
f0103b1b:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103b1f:	d3 e0                	shl    %cl,%eax
f0103b21:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0103b25:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103b29:	89 f9                	mov    %edi,%ecx
f0103b2b:	d3 e8                	shr    %cl,%eax
f0103b2d:	09 d0                	or     %edx,%eax
f0103b2f:	d3 ee                	shr    %cl,%esi
f0103b31:	89 f2                	mov    %esi,%edx
f0103b33:	f7 74 24 18          	divl   0x18(%esp)
f0103b37:	89 d6                	mov    %edx,%esi
f0103b39:	f7 64 24 0c          	mull   0xc(%esp)
f0103b3d:	89 c5                	mov    %eax,%ebp
f0103b3f:	89 d1                	mov    %edx,%ecx
f0103b41:	39 d6                	cmp    %edx,%esi
f0103b43:	72 67                	jb     f0103bac <__umoddi3+0x114>
f0103b45:	74 75                	je     f0103bbc <__umoddi3+0x124>
f0103b47:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0103b4b:	29 e8                	sub    %ebp,%eax
f0103b4d:	19 ce                	sbb    %ecx,%esi
f0103b4f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103b53:	d3 e8                	shr    %cl,%eax
f0103b55:	89 f2                	mov    %esi,%edx
f0103b57:	89 f9                	mov    %edi,%ecx
f0103b59:	d3 e2                	shl    %cl,%edx
f0103b5b:	09 d0                	or     %edx,%eax
f0103b5d:	89 f2                	mov    %esi,%edx
f0103b5f:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103b63:	d3 ea                	shr    %cl,%edx
f0103b65:	83 c4 20             	add    $0x20,%esp
f0103b68:	5e                   	pop    %esi
f0103b69:	5f                   	pop    %edi
f0103b6a:	5d                   	pop    %ebp
f0103b6b:	c3                   	ret    
f0103b6c:	85 c9                	test   %ecx,%ecx
f0103b6e:	75 0b                	jne    f0103b7b <__umoddi3+0xe3>
f0103b70:	b8 01 00 00 00       	mov    $0x1,%eax
f0103b75:	31 d2                	xor    %edx,%edx
f0103b77:	f7 f1                	div    %ecx
f0103b79:	89 c1                	mov    %eax,%ecx
f0103b7b:	89 f0                	mov    %esi,%eax
f0103b7d:	31 d2                	xor    %edx,%edx
f0103b7f:	f7 f1                	div    %ecx
f0103b81:	89 f8                	mov    %edi,%eax
f0103b83:	e9 3e ff ff ff       	jmp    f0103ac6 <__umoddi3+0x2e>
f0103b88:	89 f2                	mov    %esi,%edx
f0103b8a:	83 c4 20             	add    $0x20,%esp
f0103b8d:	5e                   	pop    %esi
f0103b8e:	5f                   	pop    %edi
f0103b8f:	5d                   	pop    %ebp
f0103b90:	c3                   	ret    
f0103b91:	8d 76 00             	lea    0x0(%esi),%esi
f0103b94:	39 f5                	cmp    %esi,%ebp
f0103b96:	72 04                	jb     f0103b9c <__umoddi3+0x104>
f0103b98:	39 f9                	cmp    %edi,%ecx
f0103b9a:	77 06                	ja     f0103ba2 <__umoddi3+0x10a>
f0103b9c:	89 f2                	mov    %esi,%edx
f0103b9e:	29 cf                	sub    %ecx,%edi
f0103ba0:	19 ea                	sbb    %ebp,%edx
f0103ba2:	89 f8                	mov    %edi,%eax
f0103ba4:	83 c4 20             	add    $0x20,%esp
f0103ba7:	5e                   	pop    %esi
f0103ba8:	5f                   	pop    %edi
f0103ba9:	5d                   	pop    %ebp
f0103baa:	c3                   	ret    
f0103bab:	90                   	nop
f0103bac:	89 d1                	mov    %edx,%ecx
f0103bae:	89 c5                	mov    %eax,%ebp
f0103bb0:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0103bb4:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0103bb8:	eb 8d                	jmp    f0103b47 <__umoddi3+0xaf>
f0103bba:	66 90                	xchg   %ax,%ax
f0103bbc:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0103bc0:	72 ea                	jb     f0103bac <__umoddi3+0x114>
f0103bc2:	89 f1                	mov    %esi,%ecx
f0103bc4:	eb 81                	jmp    f0103b47 <__umoddi3+0xaf>
