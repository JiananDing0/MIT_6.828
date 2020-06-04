
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
f0100063:	e8 9a 37 00 00       	call   f0103802 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100068:	e8 70 04 00 00       	call   f01004dd <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f010006d:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f0100074:	00 
f0100075:	c7 04 24 60 3c 10 f0 	movl   $0xf0103c60,(%esp)
f010007c:	e8 dd 2c 00 00       	call   f0102d5e <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100081:	e8 b6 10 00 00       	call   f010113c <mem_init>

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
f01000c1:	c7 04 24 7b 3c 10 f0 	movl   $0xf0103c7b,(%esp)
f01000c8:	e8 91 2c 00 00       	call   f0102d5e <cprintf>
	vcprintf(fmt, ap);
f01000cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000d1:	89 34 24             	mov    %esi,(%esp)
f01000d4:	e8 52 2c 00 00       	call   f0102d2b <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 04 4c 10 f0 	movl   $0xf0104c04,(%esp)
f01000e0:	e8 79 2c 00 00       	call   f0102d5e <cprintf>
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
f010010b:	c7 04 24 93 3c 10 f0 	movl   $0xf0103c93,(%esp)
f0100112:	e8 47 2c 00 00       	call   f0102d5e <cprintf>
	vcprintf(fmt, ap);
f0100117:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010011b:	8b 45 10             	mov    0x10(%ebp),%eax
f010011e:	89 04 24             	mov    %eax,(%esp)
f0100121:	e8 05 2c 00 00       	call   f0102d2b <vcprintf>
	cprintf("\n");
f0100126:	c7 04 24 04 4c 10 f0 	movl   $0xf0104c04,(%esp)
f010012d:	e8 2c 2c 00 00       	call   f0102d5e <cprintf>
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
f0100307:	e8 40 35 00 00       	call   f010384c <memmove>
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
f01003ae:	8a 82 e0 3c 10 f0    	mov    -0xfefc320(%edx),%al
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
f01003ea:	0f b6 82 e0 3c 10 f0 	movzbl -0xfefc320(%edx),%eax
f01003f1:	0b 05 28 f5 11 f0    	or     0xf011f528,%eax
	shift ^= togglecode[data];
f01003f7:	0f b6 8a e0 3d 10 f0 	movzbl -0xfefc220(%edx),%ecx
f01003fe:	31 c8                	xor    %ecx,%eax
f0100400:	a3 28 f5 11 f0       	mov    %eax,0xf011f528

	c = charcode[shift & (CTL | SHIFT)][data];
f0100405:	89 c1                	mov    %eax,%ecx
f0100407:	83 e1 03             	and    $0x3,%ecx
f010040a:	8b 0c 8d e0 3e 10 f0 	mov    -0xfefc120(,%ecx,4),%ecx
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
f010043f:	c7 04 24 ad 3c 10 f0 	movl   $0xf0103cad,(%esp)
f0100446:	e8 13 29 00 00       	call   f0102d5e <cprintf>
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
f01005a4:	c7 04 24 b9 3c 10 f0 	movl   $0xf0103cb9,(%esp)
f01005ab:	e8 ae 27 00 00       	call   f0102d5e <cprintf>
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
f01005ea:	c7 04 24 f0 3e 10 f0 	movl   $0xf0103ef0,(%esp)
f01005f1:	e8 68 27 00 00       	call   f0102d5e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01005f6:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f01005fd:	00 
f01005fe:	c7 04 24 a8 3f 10 f0 	movl   $0xf0103fa8,(%esp)
f0100605:	e8 54 27 00 00       	call   f0102d5e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010060a:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f0100611:	00 
f0100612:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100619:	f0 
f010061a:	c7 04 24 d0 3f 10 f0 	movl   $0xf0103fd0,(%esp)
f0100621:	e8 38 27 00 00       	call   f0102d5e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100626:	c7 44 24 08 46 3c 10 	movl   $0x103c46,0x8(%esp)
f010062d:	00 
f010062e:	c7 44 24 04 46 3c 10 	movl   $0xf0103c46,0x4(%esp)
f0100635:	f0 
f0100636:	c7 04 24 f4 3f 10 f0 	movl   $0xf0103ff4,(%esp)
f010063d:	e8 1c 27 00 00       	call   f0102d5e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100642:	c7 44 24 08 00 f3 11 	movl   $0x11f300,0x8(%esp)
f0100649:	00 
f010064a:	c7 44 24 04 00 f3 11 	movl   $0xf011f300,0x4(%esp)
f0100651:	f0 
f0100652:	c7 04 24 18 40 10 f0 	movl   $0xf0104018,(%esp)
f0100659:	e8 00 27 00 00       	call   f0102d5e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010065e:	c7 44 24 08 60 f9 11 	movl   $0x11f960,0x8(%esp)
f0100665:	00 
f0100666:	c7 44 24 04 60 f9 11 	movl   $0xf011f960,0x4(%esp)
f010066d:	f0 
f010066e:	c7 04 24 3c 40 10 f0 	movl   $0xf010403c,(%esp)
f0100675:	e8 e4 26 00 00       	call   f0102d5e <cprintf>
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
f010069c:	c7 04 24 60 40 10 f0 	movl   $0xf0104060,(%esp)
f01006a3:	e8 b6 26 00 00       	call   f0102d5e <cprintf>
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
f01006bb:	8b 83 64 41 10 f0    	mov    -0xfefbe9c(%ebx),%eax
f01006c1:	89 44 24 08          	mov    %eax,0x8(%esp)
f01006c5:	8b 83 60 41 10 f0    	mov    -0xfefbea0(%ebx),%eax
f01006cb:	89 44 24 04          	mov    %eax,0x4(%esp)
f01006cf:	c7 04 24 09 3f 10 f0 	movl   $0xf0103f09,(%esp)
f01006d6:	e8 83 26 00 00       	call   f0102d5e <cprintf>
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
f01006f9:	c7 04 24 12 3f 10 f0 	movl   $0xf0103f12,(%esp)
f0100700:	e8 59 26 00 00       	call   f0102d5e <cprintf>
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
f0100732:	e8 21 27 00 00       	call   f0102e58 <debuginfo_eip>
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
f010075f:	c7 04 24 8c 40 10 f0 	movl   $0xf010408c,(%esp)
f0100766:	e8 f3 25 00 00       	call   f0102d5e <cprintf>
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
f010078e:	c7 04 24 24 3f 10 f0 	movl   $0xf0103f24,(%esp)
f0100795:	e8 c4 25 00 00       	call   f0102d5e <cprintf>
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
f01007ba:	c7 04 24 c0 40 10 f0 	movl   $0xf01040c0,(%esp)
f01007c1:	e8 98 25 00 00       	call   f0102d5e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01007c6:	c7 04 24 e4 40 10 f0 	movl   $0xf01040e4,(%esp)
f01007cd:	e8 8c 25 00 00       	call   f0102d5e <cprintf>


	while (1) {
		buf = readline("K> ");
f01007d2:	c7 04 24 35 3f 10 f0 	movl   $0xf0103f35,(%esp)
f01007d9:	e8 fa 2d 00 00       	call   f01035d8 <readline>
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
f0100803:	c7 04 24 39 3f 10 f0 	movl   $0xf0103f39,(%esp)
f010080a:	e8 be 2f 00 00       	call   f01037cd <strchr>
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
f0100825:	c7 04 24 3e 3f 10 f0 	movl   $0xf0103f3e,(%esp)
f010082c:	e8 2d 25 00 00       	call   f0102d5e <cprintf>
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
f0100848:	c7 04 24 39 3f 10 f0 	movl   $0xf0103f39,(%esp)
f010084f:	e8 79 2f 00 00       	call   f01037cd <strchr>
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
f010086a:	bb 60 41 10 f0       	mov    $0xf0104160,%ebx
f010086f:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100874:	8b 03                	mov    (%ebx),%eax
f0100876:	89 44 24 04          	mov    %eax,0x4(%esp)
f010087a:	8b 45 a8             	mov    -0x58(%ebp),%eax
f010087d:	89 04 24             	mov    %eax,(%esp)
f0100880:	e8 f5 2e 00 00       	call   f010377a <strcmp>
f0100885:	85 c0                	test   %eax,%eax
f0100887:	75 24                	jne    f01008ad <monitor+0xfc>
			return commands[i].func(argc, argv, tf);
f0100889:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f010088c:	8b 55 08             	mov    0x8(%ebp),%edx
f010088f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0100893:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100896:	89 54 24 04          	mov    %edx,0x4(%esp)
f010089a:	89 34 24             	mov    %esi,(%esp)
f010089d:	ff 14 85 68 41 10 f0 	call   *-0xfefbe98(,%eax,4)


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
f01008bd:	c7 04 24 5b 3f 10 f0 	movl   $0xf0103f5b,(%esp)
f01008c4:	e8 95 24 00 00       	call   f0102d5e <cprintf>
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
f0100900:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0100907:	f0 
f0100908:	c7 44 24 04 f2 02 00 	movl   $0x2f2,0x4(%esp)
f010090f:	00 
f0100910:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100952:	e8 99 23 00 00       	call   f0102cf0 <mc146818_read>
f0100957:	89 c6                	mov    %eax,%esi
f0100959:	43                   	inc    %ebx
f010095a:	89 1c 24             	mov    %ebx,(%esp)
f010095d:	e8 8e 23 00 00       	call   f0102cf0 <mc146818_read>
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
f01009a3:	c7 44 24 08 a8 41 10 	movl   $0xf01041a8,0x8(%esp)
f01009aa:	f0 
f01009ab:	c7 44 24 04 6b 00 00 	movl   $0x6b,0x4(%esp)
f01009b2:	00 
f01009b3:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f01009d7:	c7 44 24 08 44 49 10 	movl   $0xf0104944,0x8(%esp)
f01009de:	f0 
f01009df:	c7 44 24 04 6e 00 00 	movl   $0x6e,0x4(%esp)
f01009e6:	00 
f01009e7:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100a11:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0100a18:	f0 
f0100a19:	c7 44 24 04 73 00 00 	movl   $0x73,0x4(%esp)
f0100a20:	00 
f0100a21:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100a55:	c7 44 24 08 cc 41 10 	movl   $0xf01041cc,0x8(%esp)
f0100a5c:	f0 
f0100a5d:	c7 44 24 04 35 02 00 	movl   $0x235,0x4(%esp)
f0100a64:	00 
f0100a65:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100af0:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0100af7:	f0 
f0100af8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100aff:	00 
f0100b00:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f0100b07:	e8 88 f5 ff ff       	call   f0100094 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b0c:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100b13:	00 
f0100b14:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100b1b:	00 
	return (void *)(pa + KERNBASE);
f0100b1c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b21:	89 04 24             	mov    %eax,(%esp)
f0100b24:	e8 d9 2c 00 00       	call   f0103802 <memset>
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
f0100b6b:	c7 44 24 0c 6d 49 10 	movl   $0xf010496d,0xc(%esp)
f0100b72:	f0 
f0100b73:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100b7a:	f0 
f0100b7b:	c7 44 24 04 4f 02 00 	movl   $0x24f,0x4(%esp)
f0100b82:	00 
f0100b83:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0100b8a:	e8 05 f5 ff ff       	call   f0100094 <_panic>
		assert(pp < pages + npages);
f0100b8f:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100b92:	72 24                	jb     f0100bb8 <check_page_free_list+0x181>
f0100b94:	c7 44 24 0c 8e 49 10 	movl   $0xf010498e,0xc(%esp)
f0100b9b:	f0 
f0100b9c:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100ba3:	f0 
f0100ba4:	c7 44 24 04 50 02 00 	movl   $0x250,0x4(%esp)
f0100bab:	00 
f0100bac:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0100bb3:	e8 dc f4 ff ff       	call   f0100094 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bb8:	89 d0                	mov    %edx,%eax
f0100bba:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bbd:	a8 07                	test   $0x7,%al
f0100bbf:	74 24                	je     f0100be5 <check_page_free_list+0x1ae>
f0100bc1:	c7 44 24 0c f0 41 10 	movl   $0xf01041f0,0xc(%esp)
f0100bc8:	f0 
f0100bc9:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100bd0:	f0 
f0100bd1:	c7 44 24 04 51 02 00 	movl   $0x251,0x4(%esp)
f0100bd8:	00 
f0100bd9:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100bed:	c7 44 24 0c a2 49 10 	movl   $0xf01049a2,0xc(%esp)
f0100bf4:	f0 
f0100bf5:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100bfc:	f0 
f0100bfd:	c7 44 24 04 54 02 00 	movl   $0x254,0x4(%esp)
f0100c04:	00 
f0100c05:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0100c0c:	e8 83 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c11:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c16:	75 24                	jne    f0100c3c <check_page_free_list+0x205>
f0100c18:	c7 44 24 0c b3 49 10 	movl   $0xf01049b3,0xc(%esp)
f0100c1f:	f0 
f0100c20:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100c27:	f0 
f0100c28:	c7 44 24 04 55 02 00 	movl   $0x255,0x4(%esp)
f0100c2f:	00 
f0100c30:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0100c37:	e8 58 f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c3c:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c41:	75 24                	jne    f0100c67 <check_page_free_list+0x230>
f0100c43:	c7 44 24 0c 24 42 10 	movl   $0xf0104224,0xc(%esp)
f0100c4a:	f0 
f0100c4b:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100c52:	f0 
f0100c53:	c7 44 24 04 56 02 00 	movl   $0x256,0x4(%esp)
f0100c5a:	00 
f0100c5b:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0100c62:	e8 2d f4 ff ff       	call   f0100094 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c67:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c6c:	75 24                	jne    f0100c92 <check_page_free_list+0x25b>
f0100c6e:	c7 44 24 0c cc 49 10 	movl   $0xf01049cc,0xc(%esp)
f0100c75:	f0 
f0100c76:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100c7d:	f0 
f0100c7e:	c7 44 24 04 57 02 00 	movl   $0x257,0x4(%esp)
f0100c85:	00 
f0100c86:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100ca7:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0100cae:	f0 
f0100caf:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100cb6:	00 
f0100cb7:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f0100cbe:	e8 d1 f3 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0100cc3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100cc8:	39 45 c4             	cmp    %eax,-0x3c(%ebp)
f0100ccb:	76 27                	jbe    f0100cf4 <check_page_free_list+0x2bd>
f0100ccd:	c7 44 24 0c 48 42 10 	movl   $0xf0104248,0xc(%esp)
f0100cd4:	f0 
f0100cd5:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100cdc:	f0 
f0100cdd:	c7 44 24 04 58 02 00 	movl   $0x258,0x4(%esp)
f0100ce4:	00 
f0100ce5:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100d03:	c7 44 24 0c e6 49 10 	movl   $0xf01049e6,0xc(%esp)
f0100d0a:	f0 
f0100d0b:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100d12:	f0 
f0100d13:	c7 44 24 04 60 02 00 	movl   $0x260,0x4(%esp)
f0100d1a:	00 
f0100d1b:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0100d22:	e8 6d f3 ff ff       	call   f0100094 <_panic>
	assert(nfree_extmem > 0);
f0100d27:	85 db                	test   %ebx,%ebx
f0100d29:	7f 24                	jg     f0100d4f <check_page_free_list+0x318>
f0100d2b:	c7 44 24 0c f8 49 10 	movl   $0xf01049f8,0xc(%esp)
f0100d32:	f0 
f0100d33:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0100d3a:	f0 
f0100d3b:	c7 44 24 04 61 02 00 	movl   $0x261,0x4(%esp)
f0100d42:	00 
f0100d43:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0100d4a:	e8 45 f3 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d4f:	c7 04 24 90 42 10 f0 	movl   $0xf0104290,(%esp)
f0100d56:	e8 03 20 00 00       	call   f0102d5e <cprintf>
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
f0100d81:	c7 44 24 08 a8 41 10 	movl   $0xf01041a8,0x8(%esp)
f0100d88:	f0 
f0100d89:	c7 44 24 04 0b 01 00 	movl   $0x10b,0x4(%esp)
f0100d90:	00 
f0100d91:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100e4d:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0100e54:	f0 
f0100e55:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0100e5c:	00 
f0100e5d:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
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
f0100e81:	e8 7c 29 00 00       	call   f0103802 <memset>
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
f0100ea3:	c7 44 24 08 b4 42 10 	movl   $0xf01042b4,0x8(%esp)
f0100eaa:	f0 
f0100eab:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
f0100eb2:	00 
f0100eb3:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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
f0100f4c:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0100f53:	f0 
f0100f54:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
f0100f5b:	00 
f0100f5c:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
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

f0100f8d <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100f8d:	55                   	push   %ebp
f0100f8e:	89 e5                	mov    %esp,%ebp
f0100f90:	57                   	push   %edi
f0100f91:	56                   	push   %esi
f0100f92:	53                   	push   %ebx
f0100f93:	83 ec 2c             	sub    $0x2c,%esp
f0100f96:	89 c7                	mov    %eax,%edi
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
f0100f98:	c1 e9 0c             	shr    $0xc,%ecx
f0100f9b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0100f9e:	89 d3                	mov    %edx,%ebx
f0100fa0:	be 00 00 00 00       	mov    $0x0,%esi
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		if ((*pteEntry & PTE_P) == 0) {
			*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f0100fa5:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100fa8:	83 c8 01             	or     $0x1,%eax
f0100fab:	89 45 e0             	mov    %eax,-0x20(%ebp)
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0100fae:	8b 45 08             	mov    0x8(%ebp),%eax
f0100fb1:	29 d0                	sub    %edx,%eax
f0100fb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0100fb6:	eb 30                	jmp    f0100fe8 <boot_map_region+0x5b>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
f0100fb8:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0100fbf:	00 
f0100fc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100fc4:	89 3c 24             	mov    %edi,(%esp)
f0100fc7:	e8 22 ff ff ff       	call   f0100eee <pgdir_walk>
		if ((*pteEntry & PTE_P) == 0) {
f0100fcc:	f6 00 01             	testb  $0x1,(%eax)
f0100fcf:	75 10                	jne    f0100fe1 <boot_map_region+0x54>
// above UTOP. As such, it should *not* change the pp_ref field on the
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
f0100fd1:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100fd4:	01 da                	add    %ebx,%edx
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		if ((*pteEntry & PTE_P) == 0) {
			*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
f0100fd6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100fdc:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100fdf:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uint32_t total = size / PGSIZE, i;
	pte_t *pteEntry; 
	for (i = 0; i < total; i++) {
f0100fe1:	46                   	inc    %esi
f0100fe2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100fe8:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f0100feb:	75 cb                	jne    f0100fb8 <boot_map_region+0x2b>
		pteEntry = pgdir_walk(pgdir, (void *)(va + i * PGSIZE), true);
		if ((*pteEntry & PTE_P) == 0) {
			*pteEntry = PTE_ADDR(pa + i * PGSIZE) | perm | PTE_P;
		}
	}	
}
f0100fed:	83 c4 2c             	add    $0x2c,%esp
f0100ff0:	5b                   	pop    %ebx
f0100ff1:	5e                   	pop    %esi
f0100ff2:	5f                   	pop    %edi
f0100ff3:	5d                   	pop    %ebp
f0100ff4:	c3                   	ret    

f0100ff5 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100ff5:	55                   	push   %ebp
f0100ff6:	89 e5                	mov    %esp,%ebp
f0100ff8:	53                   	push   %ebx
f0100ff9:	83 ec 14             	sub    $0x14,%esp
f0100ffc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
f0100fff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101006:	00 
f0101007:	8b 45 0c             	mov    0xc(%ebp),%eax
f010100a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010100e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101011:	89 04 24             	mov    %eax,(%esp)
f0101014:	e8 d5 fe ff ff       	call   f0100eee <pgdir_walk>
	physaddr_t pp;
	if (!pteEntry) {
f0101019:	85 c0                	test   %eax,%eax
f010101b:	74 3f                	je     f010105c <page_lookup+0x67>
		return NULL;
	}
	if (*pteEntry & PTE_P) {
f010101d:	f6 00 01             	testb  $0x1,(%eax)
f0101020:	74 41                	je     f0101063 <page_lookup+0x6e>
		// Modify pte_store passed as a reference
		if (pte_store) {
f0101022:	85 db                	test   %ebx,%ebx
f0101024:	74 02                	je     f0101028 <page_lookup+0x33>
		 	*pte_store = pteEntry;
f0101026:	89 03                	mov    %eax,(%ebx)
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
f0101028:	8b 00                	mov    (%eax),%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010102a:	c1 e8 0c             	shr    $0xc,%eax
f010102d:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f0101033:	72 1c                	jb     f0101051 <page_lookup+0x5c>
		panic("pa2page called with invalid pa");
f0101035:	c7 44 24 08 f0 42 10 	movl   $0xf01042f0,0x8(%esp)
f010103c:	f0 
f010103d:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
f0101044:	00 
f0101045:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f010104c:	e8 43 f0 ff ff       	call   f0100094 <_panic>
	return &pages[PGNUM(pa)];
f0101051:	c1 e0 03             	shl    $0x3,%eax
f0101054:	03 05 70 f9 11 f0    	add    0xf011f970,%eax
		return pa2page(pp);
f010105a:	eb 0c                	jmp    f0101068 <page_lookup+0x73>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, false);
	physaddr_t pp;
	if (!pteEntry) {
		return NULL;
f010105c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101061:	eb 05                	jmp    f0101068 <page_lookup+0x73>
		}
		// Get physical address
		pp = PTE_ADDR(*pteEntry);
		return pa2page(pp);
	}
	return NULL;
f0101063:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101068:	83 c4 14             	add    $0x14,%esp
f010106b:	5b                   	pop    %ebx
f010106c:	5d                   	pop    %ebp
f010106d:	c3                   	ret    

f010106e <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010106e:	55                   	push   %ebp
f010106f:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0101071:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101074:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101077:	5d                   	pop    %ebp
f0101078:	c3                   	ret    

f0101079 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101079:	55                   	push   %ebp
f010107a:	89 e5                	mov    %esp,%ebp
f010107c:	56                   	push   %esi
f010107d:	53                   	push   %ebx
f010107e:	83 ec 20             	sub    $0x20,%esp
f0101081:	8b 75 08             	mov    0x8(%ebp),%esi
f0101084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// Create a ptep store
	pte_t *pteEntry;
	// Look up the page and the entry for the page
	struct PageInfo *pp = page_lookup(pgdir, va, &pteEntry);
f0101087:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010108a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010108e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101092:	89 34 24             	mov    %esi,(%esp)
f0101095:	e8 5b ff ff ff       	call   f0100ff5 <page_lookup>
	if (!pp) {
f010109a:	85 c0                	test   %eax,%eax
f010109c:	74 1d                	je     f01010bb <page_remove+0x42>
		return;
	}
	page_decref(pp);
f010109e:	89 04 24             	mov    %eax,(%esp)
f01010a1:	e8 28 fe ff ff       	call   f0100ece <page_decref>
	tlb_invalidate(pgdir, va);
f01010a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01010aa:	89 34 24             	mov    %esi,(%esp)
f01010ad:	e8 bc ff ff ff       	call   f010106e <tlb_invalidate>
	// Enpty the page table
	*pteEntry = 0;
f01010b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01010b5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
f01010bb:	83 c4 20             	add    $0x20,%esp
f01010be:	5b                   	pop    %ebx
f01010bf:	5e                   	pop    %esi
f01010c0:	5d                   	pop    %ebp
f01010c1:	c3                   	ret    

f01010c2 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f01010c2:	55                   	push   %ebp
f01010c3:	89 e5                	mov    %esp,%ebp
f01010c5:	57                   	push   %edi
f01010c6:	56                   	push   %esi
f01010c7:	53                   	push   %ebx
f01010c8:	83 ec 1c             	sub    $0x1c,%esp
f01010cb:	8b 7d 08             	mov    0x8(%ebp),%edi
f01010ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
f01010d1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01010d8:	00 
f01010d9:	8b 45 10             	mov    0x10(%ebp),%eax
f01010dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01010e0:	89 3c 24             	mov    %edi,(%esp)
f01010e3:	e8 06 fe ff ff       	call   f0100eee <pgdir_walk>
f01010e8:	89 c6                	mov    %eax,%esi
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
f01010ea:	85 c0                	test   %eax,%eax
f01010ec:	74 41                	je     f010112f <page_insert+0x6d>
		return -E_NO_MEM;
	}
	// Increment reference bit
	pp->pp_ref++;
f01010ee:	66 ff 43 04          	incw   0x4(%ebx)
	// If the page itself is valid, remove it
	if (*pteEntry & PTE_P) {
f01010f2:	f6 00 01             	testb  $0x1,(%eax)
f01010f5:	74 0f                	je     f0101106 <page_insert+0x44>
		// If there is already a page at va, it should be removed
		page_remove(pgdir, va);
f01010f7:	8b 55 10             	mov    0x10(%ebp),%edx
f01010fa:	89 54 24 04          	mov    %edx,0x4(%esp)
f01010fe:	89 3c 24             	mov    %edi,(%esp)
f0101101:	e8 73 ff ff ff       	call   f0101079 <page_remove>
	}
	// Modify premission for both directory entry and page table entry
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
f0101106:	8b 45 14             	mov    0x14(%ebp),%eax
f0101109:	83 c8 01             	or     $0x1,%eax
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010110c:	2b 1d 70 f9 11 f0    	sub    0xf011f970,%ebx
f0101112:	c1 fb 03             	sar    $0x3,%ebx
f0101115:	c1 e3 0c             	shl    $0xc,%ebx
f0101118:	09 c3                	or     %eax,%ebx
f010111a:	89 1e                	mov    %ebx,(%esi)
	pgdir[PDX(va)] |= perm;
f010111c:	8b 45 10             	mov    0x10(%ebp),%eax
f010111f:	c1 e8 16             	shr    $0x16,%eax
f0101122:	8b 55 14             	mov    0x14(%ebp),%edx
f0101125:	09 14 87             	or     %edx,(%edi,%eax,4)
	// Return success
	return 0;
f0101128:	b8 00 00 00 00       	mov    $0x0,%eax
f010112d:	eb 05                	jmp    f0101134 <page_insert+0x72>
{
	// Fill this function in
	pte_t *pteEntry = pgdir_walk(pgdir, va, true);
	// If value is NULL, allocation fails, no memory available
	if (!pteEntry) {
		return -E_NO_MEM;
f010112f:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	*pteEntry = PTE_ADDR(page2pa(pp)) | perm | PTE_P;
	pgdir[PDX(va)] |= perm;
	// Return success
	return 0;
	
}
f0101134:	83 c4 1c             	add    $0x1c,%esp
f0101137:	5b                   	pop    %ebx
f0101138:	5e                   	pop    %esi
f0101139:	5f                   	pop    %edi
f010113a:	5d                   	pop    %ebp
f010113b:	c3                   	ret    

f010113c <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010113c:	55                   	push   %ebp
f010113d:	89 e5                	mov    %esp,%ebp
f010113f:	57                   	push   %edi
f0101140:	56                   	push   %esi
f0101141:	53                   	push   %ebx
f0101142:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101145:	b8 15 00 00 00       	mov    $0x15,%eax
f010114a:	e8 f6 f7 ff ff       	call   f0100945 <nvram_read>
f010114f:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0101151:	b8 17 00 00 00       	mov    $0x17,%eax
f0101156:	e8 ea f7 ff ff       	call   f0100945 <nvram_read>
f010115b:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010115d:	b8 34 00 00 00       	mov    $0x34,%eax
f0101162:	e8 de f7 ff ff       	call   f0100945 <nvram_read>

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101167:	c1 e0 06             	shl    $0x6,%eax
f010116a:	74 08                	je     f0101174 <mem_init+0x38>
		totalmem = 16 * 1024 + ext16mem;
f010116c:	8d b0 00 40 00 00    	lea    0x4000(%eax),%esi
f0101172:	eb 0e                	jmp    f0101182 <mem_init+0x46>
	else if (extmem)
f0101174:	85 f6                	test   %esi,%esi
f0101176:	74 08                	je     f0101180 <mem_init+0x44>
		totalmem = 1 * 1024 + extmem;
f0101178:	81 c6 00 04 00 00    	add    $0x400,%esi
f010117e:	eb 02                	jmp    f0101182 <mem_init+0x46>
	else
		totalmem = basemem;
f0101180:	89 de                	mov    %ebx,%esi

	npages = totalmem / (PGSIZE / 1024);
f0101182:	89 f0                	mov    %esi,%eax
f0101184:	c1 e8 02             	shr    $0x2,%eax
f0101187:	a3 68 f9 11 f0       	mov    %eax,0xf011f968
	npages_basemem = basemem / (PGSIZE / 1024);
f010118c:	89 d8                	mov    %ebx,%eax
f010118e:	c1 e8 02             	shr    $0x2,%eax
f0101191:	a3 38 f5 11 f0       	mov    %eax,0xf011f538

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101196:	89 f0                	mov    %esi,%eax
f0101198:	29 d8                	sub    %ebx,%eax
f010119a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010119e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01011a2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01011a6:	c7 04 24 10 43 10 f0 	movl   $0xf0104310,(%esp)
f01011ad:	e8 ac 1b 00 00       	call   f0102d5e <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01011b2:	b8 00 10 00 00       	mov    $0x1000,%eax
f01011b7:	e8 b2 f7 ff ff       	call   f010096e <boot_alloc>
f01011bc:	a3 6c f9 11 f0       	mov    %eax,0xf011f96c
	memset(kern_pgdir, 0, PGSIZE);
f01011c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011c8:	00 
f01011c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011d0:	00 
f01011d1:	89 04 24             	mov    %eax,(%esp)
f01011d4:	e8 29 26 00 00       	call   f0103802 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01011d9:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01011de:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01011e3:	77 20                	ja     f0101205 <mem_init+0xc9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01011e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011e9:	c7 44 24 08 a8 41 10 	movl   $0xf01041a8,0x8(%esp)
f01011f0:	f0 
f01011f1:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f01011f8:	00 
f01011f9:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101200:	e8 8f ee ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101205:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010120b:	83 ca 05             	or     $0x5,%edx
f010120e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(sizeof(struct PageInfo) * npages);
f0101214:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f0101219:	c1 e0 03             	shl    $0x3,%eax
f010121c:	e8 4d f7 ff ff       	call   f010096e <boot_alloc>
f0101221:	a3 70 f9 11 f0       	mov    %eax,0xf011f970
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101226:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f010122c:	c1 e2 03             	shl    $0x3,%edx
f010122f:	89 54 24 08          	mov    %edx,0x8(%esp)
f0101233:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010123a:	00 
f010123b:	89 04 24             	mov    %eax,(%esp)
f010123e:	e8 bf 25 00 00       	call   f0103802 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101243:	e8 1b fb ff ff       	call   f0100d63 <page_init>

	check_page_free_list(1);
f0101248:	b8 01 00 00 00       	mov    $0x1,%eax
f010124d:	e8 e5 f7 ff ff       	call   f0100a37 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101252:	83 3d 70 f9 11 f0 00 	cmpl   $0x0,0xf011f970
f0101259:	75 1c                	jne    f0101277 <mem_init+0x13b>
		panic("'pages' is a null pointer!");
f010125b:	c7 44 24 08 09 4a 10 	movl   $0xf0104a09,0x8(%esp)
f0101262:	f0 
f0101263:	c7 44 24 04 74 02 00 	movl   $0x274,0x4(%esp)
f010126a:	00 
f010126b:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101272:	e8 1d ee ff ff       	call   f0100094 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101277:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f010127c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101281:	eb 03                	jmp    f0101286 <mem_init+0x14a>
		++nfree;
f0101283:	43                   	inc    %ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101284:	8b 00                	mov    (%eax),%eax
f0101286:	85 c0                	test   %eax,%eax
f0101288:	75 f9                	jne    f0101283 <mem_init+0x147>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010128a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101291:	e8 74 fb ff ff       	call   f0100e0a <page_alloc>
f0101296:	89 c6                	mov    %eax,%esi
f0101298:	85 c0                	test   %eax,%eax
f010129a:	75 24                	jne    f01012c0 <mem_init+0x184>
f010129c:	c7 44 24 0c 24 4a 10 	movl   $0xf0104a24,0xc(%esp)
f01012a3:	f0 
f01012a4:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01012ab:	f0 
f01012ac:	c7 44 24 04 7c 02 00 	movl   $0x27c,0x4(%esp)
f01012b3:	00 
f01012b4:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01012bb:	e8 d4 ed ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01012c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012c7:	e8 3e fb ff ff       	call   f0100e0a <page_alloc>
f01012cc:	89 c7                	mov    %eax,%edi
f01012ce:	85 c0                	test   %eax,%eax
f01012d0:	75 24                	jne    f01012f6 <mem_init+0x1ba>
f01012d2:	c7 44 24 0c 3a 4a 10 	movl   $0xf0104a3a,0xc(%esp)
f01012d9:	f0 
f01012da:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01012e1:	f0 
f01012e2:	c7 44 24 04 7d 02 00 	movl   $0x27d,0x4(%esp)
f01012e9:	00 
f01012ea:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01012f1:	e8 9e ed ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01012f6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01012fd:	e8 08 fb ff ff       	call   f0100e0a <page_alloc>
f0101302:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101305:	85 c0                	test   %eax,%eax
f0101307:	75 24                	jne    f010132d <mem_init+0x1f1>
f0101309:	c7 44 24 0c 50 4a 10 	movl   $0xf0104a50,0xc(%esp)
f0101310:	f0 
f0101311:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101318:	f0 
f0101319:	c7 44 24 04 7e 02 00 	movl   $0x27e,0x4(%esp)
f0101320:	00 
f0101321:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101328:	e8 67 ed ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010132d:	39 fe                	cmp    %edi,%esi
f010132f:	75 24                	jne    f0101355 <mem_init+0x219>
f0101331:	c7 44 24 0c 66 4a 10 	movl   $0xf0104a66,0xc(%esp)
f0101338:	f0 
f0101339:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101340:	f0 
f0101341:	c7 44 24 04 81 02 00 	movl   $0x281,0x4(%esp)
f0101348:	00 
f0101349:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101350:	e8 3f ed ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101355:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101358:	74 05                	je     f010135f <mem_init+0x223>
f010135a:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010135d:	75 24                	jne    f0101383 <mem_init+0x247>
f010135f:	c7 44 24 0c 4c 43 10 	movl   $0xf010434c,0xc(%esp)
f0101366:	f0 
f0101367:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010136e:	f0 
f010136f:	c7 44 24 04 82 02 00 	movl   $0x282,0x4(%esp)
f0101376:	00 
f0101377:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010137e:	e8 11 ed ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101383:	8b 15 70 f9 11 f0    	mov    0xf011f970,%edx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101389:	a1 68 f9 11 f0       	mov    0xf011f968,%eax
f010138e:	c1 e0 0c             	shl    $0xc,%eax
f0101391:	89 f1                	mov    %esi,%ecx
f0101393:	29 d1                	sub    %edx,%ecx
f0101395:	c1 f9 03             	sar    $0x3,%ecx
f0101398:	c1 e1 0c             	shl    $0xc,%ecx
f010139b:	39 c1                	cmp    %eax,%ecx
f010139d:	72 24                	jb     f01013c3 <mem_init+0x287>
f010139f:	c7 44 24 0c 78 4a 10 	movl   $0xf0104a78,0xc(%esp)
f01013a6:	f0 
f01013a7:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01013ae:	f0 
f01013af:	c7 44 24 04 83 02 00 	movl   $0x283,0x4(%esp)
f01013b6:	00 
f01013b7:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01013be:	e8 d1 ec ff ff       	call   f0100094 <_panic>
f01013c3:	89 f9                	mov    %edi,%ecx
f01013c5:	29 d1                	sub    %edx,%ecx
f01013c7:	c1 f9 03             	sar    $0x3,%ecx
f01013ca:	c1 e1 0c             	shl    $0xc,%ecx
	assert(page2pa(pp1) < npages*PGSIZE);
f01013cd:	39 c8                	cmp    %ecx,%eax
f01013cf:	77 24                	ja     f01013f5 <mem_init+0x2b9>
f01013d1:	c7 44 24 0c 95 4a 10 	movl   $0xf0104a95,0xc(%esp)
f01013d8:	f0 
f01013d9:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01013e0:	f0 
f01013e1:	c7 44 24 04 84 02 00 	movl   $0x284,0x4(%esp)
f01013e8:	00 
f01013e9:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01013f0:	e8 9f ec ff ff       	call   f0100094 <_panic>
f01013f5:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01013f8:	29 d1                	sub    %edx,%ecx
f01013fa:	89 ca                	mov    %ecx,%edx
f01013fc:	c1 fa 03             	sar    $0x3,%edx
f01013ff:	c1 e2 0c             	shl    $0xc,%edx
	assert(page2pa(pp2) < npages*PGSIZE);
f0101402:	39 d0                	cmp    %edx,%eax
f0101404:	77 24                	ja     f010142a <mem_init+0x2ee>
f0101406:	c7 44 24 0c b2 4a 10 	movl   $0xf0104ab2,0xc(%esp)
f010140d:	f0 
f010140e:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101415:	f0 
f0101416:	c7 44 24 04 85 02 00 	movl   $0x285,0x4(%esp)
f010141d:	00 
f010141e:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101425:	e8 6a ec ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010142a:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f010142f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101432:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f0101439:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010143c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101443:	e8 c2 f9 ff ff       	call   f0100e0a <page_alloc>
f0101448:	85 c0                	test   %eax,%eax
f010144a:	74 24                	je     f0101470 <mem_init+0x334>
f010144c:	c7 44 24 0c cf 4a 10 	movl   $0xf0104acf,0xc(%esp)
f0101453:	f0 
f0101454:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010145b:	f0 
f010145c:	c7 44 24 04 8c 02 00 	movl   $0x28c,0x4(%esp)
f0101463:	00 
f0101464:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010146b:	e8 24 ec ff ff       	call   f0100094 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101470:	89 34 24             	mov    %esi,(%esp)
f0101473:	e8 16 fa ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f0101478:	89 3c 24             	mov    %edi,(%esp)
f010147b:	e8 0e fa ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f0101480:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101483:	89 04 24             	mov    %eax,(%esp)
f0101486:	e8 03 fa ff ff       	call   f0100e8e <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010148b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101492:	e8 73 f9 ff ff       	call   f0100e0a <page_alloc>
f0101497:	89 c6                	mov    %eax,%esi
f0101499:	85 c0                	test   %eax,%eax
f010149b:	75 24                	jne    f01014c1 <mem_init+0x385>
f010149d:	c7 44 24 0c 24 4a 10 	movl   $0xf0104a24,0xc(%esp)
f01014a4:	f0 
f01014a5:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01014ac:	f0 
f01014ad:	c7 44 24 04 93 02 00 	movl   $0x293,0x4(%esp)
f01014b4:	00 
f01014b5:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01014bc:	e8 d3 eb ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f01014c1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014c8:	e8 3d f9 ff ff       	call   f0100e0a <page_alloc>
f01014cd:	89 c7                	mov    %eax,%edi
f01014cf:	85 c0                	test   %eax,%eax
f01014d1:	75 24                	jne    f01014f7 <mem_init+0x3bb>
f01014d3:	c7 44 24 0c 3a 4a 10 	movl   $0xf0104a3a,0xc(%esp)
f01014da:	f0 
f01014db:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01014e2:	f0 
f01014e3:	c7 44 24 04 94 02 00 	movl   $0x294,0x4(%esp)
f01014ea:	00 
f01014eb:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01014f2:	e8 9d eb ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01014f7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014fe:	e8 07 f9 ff ff       	call   f0100e0a <page_alloc>
f0101503:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101506:	85 c0                	test   %eax,%eax
f0101508:	75 24                	jne    f010152e <mem_init+0x3f2>
f010150a:	c7 44 24 0c 50 4a 10 	movl   $0xf0104a50,0xc(%esp)
f0101511:	f0 
f0101512:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101519:	f0 
f010151a:	c7 44 24 04 95 02 00 	movl   $0x295,0x4(%esp)
f0101521:	00 
f0101522:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101529:	e8 66 eb ff ff       	call   f0100094 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010152e:	39 fe                	cmp    %edi,%esi
f0101530:	75 24                	jne    f0101556 <mem_init+0x41a>
f0101532:	c7 44 24 0c 66 4a 10 	movl   $0xf0104a66,0xc(%esp)
f0101539:	f0 
f010153a:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101541:	f0 
f0101542:	c7 44 24 04 97 02 00 	movl   $0x297,0x4(%esp)
f0101549:	00 
f010154a:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101551:	e8 3e eb ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101556:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101559:	74 05                	je     f0101560 <mem_init+0x424>
f010155b:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f010155e:	75 24                	jne    f0101584 <mem_init+0x448>
f0101560:	c7 44 24 0c 4c 43 10 	movl   $0xf010434c,0xc(%esp)
f0101567:	f0 
f0101568:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010156f:	f0 
f0101570:	c7 44 24 04 98 02 00 	movl   $0x298,0x4(%esp)
f0101577:	00 
f0101578:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010157f:	e8 10 eb ff ff       	call   f0100094 <_panic>
	assert(!page_alloc(0));
f0101584:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010158b:	e8 7a f8 ff ff       	call   f0100e0a <page_alloc>
f0101590:	85 c0                	test   %eax,%eax
f0101592:	74 24                	je     f01015b8 <mem_init+0x47c>
f0101594:	c7 44 24 0c cf 4a 10 	movl   $0xf0104acf,0xc(%esp)
f010159b:	f0 
f010159c:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01015a3:	f0 
f01015a4:	c7 44 24 04 99 02 00 	movl   $0x299,0x4(%esp)
f01015ab:	00 
f01015ac:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01015b3:	e8 dc ea ff ff       	call   f0100094 <_panic>
f01015b8:	89 f0                	mov    %esi,%eax
f01015ba:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f01015c0:	c1 f8 03             	sar    $0x3,%eax
f01015c3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015c6:	89 c2                	mov    %eax,%edx
f01015c8:	c1 ea 0c             	shr    $0xc,%edx
f01015cb:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f01015d1:	72 20                	jb     f01015f3 <mem_init+0x4b7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01015d7:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f01015de:	f0 
f01015df:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01015e6:	00 
f01015e7:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f01015ee:	e8 a1 ea ff ff       	call   f0100094 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01015f3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01015fa:	00 
f01015fb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101602:	00 
	return (void *)(pa + KERNBASE);
f0101603:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101608:	89 04 24             	mov    %eax,(%esp)
f010160b:	e8 f2 21 00 00       	call   f0103802 <memset>
	page_free(pp0);
f0101610:	89 34 24             	mov    %esi,(%esp)
f0101613:	e8 76 f8 ff ff       	call   f0100e8e <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101618:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010161f:	e8 e6 f7 ff ff       	call   f0100e0a <page_alloc>
f0101624:	85 c0                	test   %eax,%eax
f0101626:	75 24                	jne    f010164c <mem_init+0x510>
f0101628:	c7 44 24 0c de 4a 10 	movl   $0xf0104ade,0xc(%esp)
f010162f:	f0 
f0101630:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101637:	f0 
f0101638:	c7 44 24 04 9e 02 00 	movl   $0x29e,0x4(%esp)
f010163f:	00 
f0101640:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101647:	e8 48 ea ff ff       	call   f0100094 <_panic>
	assert(pp && pp0 == pp);
f010164c:	39 c6                	cmp    %eax,%esi
f010164e:	74 24                	je     f0101674 <mem_init+0x538>
f0101650:	c7 44 24 0c fc 4a 10 	movl   $0xf0104afc,0xc(%esp)
f0101657:	f0 
f0101658:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010165f:	f0 
f0101660:	c7 44 24 04 9f 02 00 	movl   $0x29f,0x4(%esp)
f0101667:	00 
f0101668:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010166f:	e8 20 ea ff ff       	call   f0100094 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101674:	89 f2                	mov    %esi,%edx
f0101676:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f010167c:	c1 fa 03             	sar    $0x3,%edx
f010167f:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101682:	89 d0                	mov    %edx,%eax
f0101684:	c1 e8 0c             	shr    $0xc,%eax
f0101687:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f010168d:	72 20                	jb     f01016af <mem_init+0x573>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010168f:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101693:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f010169a:	f0 
f010169b:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01016a2:	00 
f01016a3:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f01016aa:	e8 e5 e9 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f01016af:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01016b5:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016bb:	80 38 00             	cmpb   $0x0,(%eax)
f01016be:	74 24                	je     f01016e4 <mem_init+0x5a8>
f01016c0:	c7 44 24 0c 0c 4b 10 	movl   $0xf0104b0c,0xc(%esp)
f01016c7:	f0 
f01016c8:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01016cf:	f0 
f01016d0:	c7 44 24 04 a2 02 00 	movl   $0x2a2,0x4(%esp)
f01016d7:	00 
f01016d8:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01016df:	e8 b0 e9 ff ff       	call   f0100094 <_panic>
f01016e4:	40                   	inc    %eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016e5:	39 d0                	cmp    %edx,%eax
f01016e7:	75 d2                	jne    f01016bb <mem_init+0x57f>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01016e9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01016ec:	89 15 40 f5 11 f0    	mov    %edx,0xf011f540

	// free the pages we took
	page_free(pp0);
f01016f2:	89 34 24             	mov    %esi,(%esp)
f01016f5:	e8 94 f7 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f01016fa:	89 3c 24             	mov    %edi,(%esp)
f01016fd:	e8 8c f7 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f0101702:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101705:	89 04 24             	mov    %eax,(%esp)
f0101708:	e8 81 f7 ff ff       	call   f0100e8e <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010170d:	a1 40 f5 11 f0       	mov    0xf011f540,%eax
f0101712:	eb 03                	jmp    f0101717 <mem_init+0x5db>
		--nfree;
f0101714:	4b                   	dec    %ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101715:	8b 00                	mov    (%eax),%eax
f0101717:	85 c0                	test   %eax,%eax
f0101719:	75 f9                	jne    f0101714 <mem_init+0x5d8>
		--nfree;
	assert(nfree == 0);
f010171b:	85 db                	test   %ebx,%ebx
f010171d:	74 24                	je     f0101743 <mem_init+0x607>
f010171f:	c7 44 24 0c 16 4b 10 	movl   $0xf0104b16,0xc(%esp)
f0101726:	f0 
f0101727:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010172e:	f0 
f010172f:	c7 44 24 04 af 02 00 	movl   $0x2af,0x4(%esp)
f0101736:	00 
f0101737:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010173e:	e8 51 e9 ff ff       	call   f0100094 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101743:	c7 04 24 6c 43 10 f0 	movl   $0xf010436c,(%esp)
f010174a:	e8 0f 16 00 00       	call   f0102d5e <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010174f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101756:	e8 af f6 ff ff       	call   f0100e0a <page_alloc>
f010175b:	89 c7                	mov    %eax,%edi
f010175d:	85 c0                	test   %eax,%eax
f010175f:	75 24                	jne    f0101785 <mem_init+0x649>
f0101761:	c7 44 24 0c 24 4a 10 	movl   $0xf0104a24,0xc(%esp)
f0101768:	f0 
f0101769:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101770:	f0 
f0101771:	c7 44 24 04 06 03 00 	movl   $0x306,0x4(%esp)
f0101778:	00 
f0101779:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101780:	e8 0f e9 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f0101785:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010178c:	e8 79 f6 ff ff       	call   f0100e0a <page_alloc>
f0101791:	89 c6                	mov    %eax,%esi
f0101793:	85 c0                	test   %eax,%eax
f0101795:	75 24                	jne    f01017bb <mem_init+0x67f>
f0101797:	c7 44 24 0c 3a 4a 10 	movl   $0xf0104a3a,0xc(%esp)
f010179e:	f0 
f010179f:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01017a6:	f0 
f01017a7:	c7 44 24 04 07 03 00 	movl   $0x307,0x4(%esp)
f01017ae:	00 
f01017af:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01017b6:	e8 d9 e8 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f01017bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01017c2:	e8 43 f6 ff ff       	call   f0100e0a <page_alloc>
f01017c7:	89 c3                	mov    %eax,%ebx
f01017c9:	85 c0                	test   %eax,%eax
f01017cb:	75 24                	jne    f01017f1 <mem_init+0x6b5>
f01017cd:	c7 44 24 0c 50 4a 10 	movl   $0xf0104a50,0xc(%esp)
f01017d4:	f0 
f01017d5:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01017dc:	f0 
f01017dd:	c7 44 24 04 08 03 00 	movl   $0x308,0x4(%esp)
f01017e4:	00 
f01017e5:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01017ec:	e8 a3 e8 ff ff       	call   f0100094 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017f1:	39 f7                	cmp    %esi,%edi
f01017f3:	75 24                	jne    f0101819 <mem_init+0x6dd>
f01017f5:	c7 44 24 0c 66 4a 10 	movl   $0xf0104a66,0xc(%esp)
f01017fc:	f0 
f01017fd:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101804:	f0 
f0101805:	c7 44 24 04 0b 03 00 	movl   $0x30b,0x4(%esp)
f010180c:	00 
f010180d:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101814:	e8 7b e8 ff ff       	call   f0100094 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101819:	39 c6                	cmp    %eax,%esi
f010181b:	74 04                	je     f0101821 <mem_init+0x6e5>
f010181d:	39 c7                	cmp    %eax,%edi
f010181f:	75 24                	jne    f0101845 <mem_init+0x709>
f0101821:	c7 44 24 0c 4c 43 10 	movl   $0xf010434c,0xc(%esp)
f0101828:	f0 
f0101829:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101830:	f0 
f0101831:	c7 44 24 04 0c 03 00 	movl   $0x30c,0x4(%esp)
f0101838:	00 
f0101839:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101840:	e8 4f e8 ff ff       	call   f0100094 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101845:	8b 15 40 f5 11 f0    	mov    0xf011f540,%edx
f010184b:	89 55 cc             	mov    %edx,-0x34(%ebp)
	page_free_list = 0;
f010184e:	c7 05 40 f5 11 f0 00 	movl   $0x0,0xf011f540
f0101855:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101858:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010185f:	e8 a6 f5 ff ff       	call   f0100e0a <page_alloc>
f0101864:	85 c0                	test   %eax,%eax
f0101866:	74 24                	je     f010188c <mem_init+0x750>
f0101868:	c7 44 24 0c cf 4a 10 	movl   $0xf0104acf,0xc(%esp)
f010186f:	f0 
f0101870:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101877:	f0 
f0101878:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f010187f:	00 
f0101880:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101887:	e8 08 e8 ff ff       	call   f0100094 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010188c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010188f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101893:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010189a:	00 
f010189b:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01018a0:	89 04 24             	mov    %eax,(%esp)
f01018a3:	e8 4d f7 ff ff       	call   f0100ff5 <page_lookup>
f01018a8:	85 c0                	test   %eax,%eax
f01018aa:	74 24                	je     f01018d0 <mem_init+0x794>
f01018ac:	c7 44 24 0c 8c 43 10 	movl   $0xf010438c,0xc(%esp)
f01018b3:	f0 
f01018b4:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01018bb:	f0 
f01018bc:	c7 44 24 04 16 03 00 	movl   $0x316,0x4(%esp)
f01018c3:	00 
f01018c4:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01018cb:	e8 c4 e7 ff ff       	call   f0100094 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018d0:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01018d7:	00 
f01018d8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01018df:	00 
f01018e0:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018e4:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01018e9:	89 04 24             	mov    %eax,(%esp)
f01018ec:	e8 d1 f7 ff ff       	call   f01010c2 <page_insert>
f01018f1:	85 c0                	test   %eax,%eax
f01018f3:	78 24                	js     f0101919 <mem_init+0x7dd>
f01018f5:	c7 44 24 0c c4 43 10 	movl   $0xf01043c4,0xc(%esp)
f01018fc:	f0 
f01018fd:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101904:	f0 
f0101905:	c7 44 24 04 19 03 00 	movl   $0x319,0x4(%esp)
f010190c:	00 
f010190d:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101914:	e8 7b e7 ff ff       	call   f0100094 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101919:	89 3c 24             	mov    %edi,(%esp)
f010191c:	e8 6d f5 ff ff       	call   f0100e8e <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101921:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101928:	00 
f0101929:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101930:	00 
f0101931:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101935:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f010193a:	89 04 24             	mov    %eax,(%esp)
f010193d:	e8 80 f7 ff ff       	call   f01010c2 <page_insert>
f0101942:	85 c0                	test   %eax,%eax
f0101944:	74 24                	je     f010196a <mem_init+0x82e>
f0101946:	c7 44 24 0c f4 43 10 	movl   $0xf01043f4,0xc(%esp)
f010194d:	f0 
f010194e:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101955:	f0 
f0101956:	c7 44 24 04 1d 03 00 	movl   $0x31d,0x4(%esp)
f010195d:	00 
f010195e:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101965:	e8 2a e7 ff ff       	call   f0100094 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010196a:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f0101970:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101973:	a1 70 f9 11 f0       	mov    0xf011f970,%eax
f0101978:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010197b:	8b 11                	mov    (%ecx),%edx
f010197d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101983:	89 f8                	mov    %edi,%eax
f0101985:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101988:	c1 f8 03             	sar    $0x3,%eax
f010198b:	c1 e0 0c             	shl    $0xc,%eax
f010198e:	39 c2                	cmp    %eax,%edx
f0101990:	74 24                	je     f01019b6 <mem_init+0x87a>
f0101992:	c7 44 24 0c 24 44 10 	movl   $0xf0104424,0xc(%esp)
f0101999:	f0 
f010199a:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01019a1:	f0 
f01019a2:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f01019a9:	00 
f01019aa:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01019b1:	e8 de e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01019b6:	ba 00 00 00 00       	mov    $0x0,%edx
f01019bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01019be:	e8 15 ef ff ff       	call   f01008d8 <check_va2pa>
f01019c3:	89 f2                	mov    %esi,%edx
f01019c5:	2b 55 d0             	sub    -0x30(%ebp),%edx
f01019c8:	c1 fa 03             	sar    $0x3,%edx
f01019cb:	c1 e2 0c             	shl    $0xc,%edx
f01019ce:	39 d0                	cmp    %edx,%eax
f01019d0:	74 24                	je     f01019f6 <mem_init+0x8ba>
f01019d2:	c7 44 24 0c 4c 44 10 	movl   $0xf010444c,0xc(%esp)
f01019d9:	f0 
f01019da:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01019e1:	f0 
f01019e2:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f01019e9:	00 
f01019ea:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01019f1:	e8 9e e6 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f01019f6:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019fb:	74 24                	je     f0101a21 <mem_init+0x8e5>
f01019fd:	c7 44 24 0c 21 4b 10 	movl   $0xf0104b21,0xc(%esp)
f0101a04:	f0 
f0101a05:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101a0c:	f0 
f0101a0d:	c7 44 24 04 20 03 00 	movl   $0x320,0x4(%esp)
f0101a14:	00 
f0101a15:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101a1c:	e8 73 e6 ff ff       	call   f0100094 <_panic>
	assert(pp0->pp_ref == 1);
f0101a21:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101a26:	74 24                	je     f0101a4c <mem_init+0x910>
f0101a28:	c7 44 24 0c 32 4b 10 	movl   $0xf0104b32,0xc(%esp)
f0101a2f:	f0 
f0101a30:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101a37:	f0 
f0101a38:	c7 44 24 04 21 03 00 	movl   $0x321,0x4(%esp)
f0101a3f:	00 
f0101a40:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101a47:	e8 48 e6 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a4c:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101a53:	00 
f0101a54:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101a5b:	00 
f0101a5c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101a60:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101a63:	89 14 24             	mov    %edx,(%esp)
f0101a66:	e8 57 f6 ff ff       	call   f01010c2 <page_insert>
f0101a6b:	85 c0                	test   %eax,%eax
f0101a6d:	74 24                	je     f0101a93 <mem_init+0x957>
f0101a6f:	c7 44 24 0c 7c 44 10 	movl   $0xf010447c,0xc(%esp)
f0101a76:	f0 
f0101a77:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101a7e:	f0 
f0101a7f:	c7 44 24 04 24 03 00 	movl   $0x324,0x4(%esp)
f0101a86:	00 
f0101a87:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101a8e:	e8 01 e6 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a93:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a98:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101a9d:	e8 36 ee ff ff       	call   f01008d8 <check_va2pa>
f0101aa2:	89 da                	mov    %ebx,%edx
f0101aa4:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101aaa:	c1 fa 03             	sar    $0x3,%edx
f0101aad:	c1 e2 0c             	shl    $0xc,%edx
f0101ab0:	39 d0                	cmp    %edx,%eax
f0101ab2:	74 24                	je     f0101ad8 <mem_init+0x99c>
f0101ab4:	c7 44 24 0c b8 44 10 	movl   $0xf01044b8,0xc(%esp)
f0101abb:	f0 
f0101abc:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101ac3:	f0 
f0101ac4:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101acb:	00 
f0101acc:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101ad3:	e8 bc e5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101ad8:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101add:	74 24                	je     f0101b03 <mem_init+0x9c7>
f0101adf:	c7 44 24 0c 43 4b 10 	movl   $0xf0104b43,0xc(%esp)
f0101ae6:	f0 
f0101ae7:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101aee:	f0 
f0101aef:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101af6:	00 
f0101af7:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101afe:	e8 91 e5 ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101b03:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b0a:	e8 fb f2 ff ff       	call   f0100e0a <page_alloc>
f0101b0f:	85 c0                	test   %eax,%eax
f0101b11:	74 24                	je     f0101b37 <mem_init+0x9fb>
f0101b13:	c7 44 24 0c cf 4a 10 	movl   $0xf0104acf,0xc(%esp)
f0101b1a:	f0 
f0101b1b:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101b22:	f0 
f0101b23:	c7 44 24 04 29 03 00 	movl   $0x329,0x4(%esp)
f0101b2a:	00 
f0101b2b:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101b32:	e8 5d e5 ff ff       	call   f0100094 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101b37:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101b3e:	00 
f0101b3f:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101b46:	00 
f0101b47:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101b4b:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101b50:	89 04 24             	mov    %eax,(%esp)
f0101b53:	e8 6a f5 ff ff       	call   f01010c2 <page_insert>
f0101b58:	85 c0                	test   %eax,%eax
f0101b5a:	74 24                	je     f0101b80 <mem_init+0xa44>
f0101b5c:	c7 44 24 0c 7c 44 10 	movl   $0xf010447c,0xc(%esp)
f0101b63:	f0 
f0101b64:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101b6b:	f0 
f0101b6c:	c7 44 24 04 2c 03 00 	movl   $0x32c,0x4(%esp)
f0101b73:	00 
f0101b74:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101b7b:	e8 14 e5 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b80:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b85:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101b8a:	e8 49 ed ff ff       	call   f01008d8 <check_va2pa>
f0101b8f:	89 da                	mov    %ebx,%edx
f0101b91:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101b97:	c1 fa 03             	sar    $0x3,%edx
f0101b9a:	c1 e2 0c             	shl    $0xc,%edx
f0101b9d:	39 d0                	cmp    %edx,%eax
f0101b9f:	74 24                	je     f0101bc5 <mem_init+0xa89>
f0101ba1:	c7 44 24 0c b8 44 10 	movl   $0xf01044b8,0xc(%esp)
f0101ba8:	f0 
f0101ba9:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101bb0:	f0 
f0101bb1:	c7 44 24 04 2d 03 00 	movl   $0x32d,0x4(%esp)
f0101bb8:	00 
f0101bb9:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101bc0:	e8 cf e4 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101bc5:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101bca:	74 24                	je     f0101bf0 <mem_init+0xab4>
f0101bcc:	c7 44 24 0c 43 4b 10 	movl   $0xf0104b43,0xc(%esp)
f0101bd3:	f0 
f0101bd4:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101bdb:	f0 
f0101bdc:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101be3:	00 
f0101be4:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101beb:	e8 a4 e4 ff ff       	call   f0100094 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101bf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101bf7:	e8 0e f2 ff ff       	call   f0100e0a <page_alloc>
f0101bfc:	85 c0                	test   %eax,%eax
f0101bfe:	74 24                	je     f0101c24 <mem_init+0xae8>
f0101c00:	c7 44 24 0c cf 4a 10 	movl   $0xf0104acf,0xc(%esp)
f0101c07:	f0 
f0101c08:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101c0f:	f0 
f0101c10:	c7 44 24 04 32 03 00 	movl   $0x332,0x4(%esp)
f0101c17:	00 
f0101c18:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101c1f:	e8 70 e4 ff ff       	call   f0100094 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101c24:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
f0101c2a:	8b 02                	mov    (%edx),%eax
f0101c2c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101c31:	89 c1                	mov    %eax,%ecx
f0101c33:	c1 e9 0c             	shr    $0xc,%ecx
f0101c36:	3b 0d 68 f9 11 f0    	cmp    0xf011f968,%ecx
f0101c3c:	72 20                	jb     f0101c5e <mem_init+0xb22>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101c3e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101c42:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0101c49:	f0 
f0101c4a:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101c51:	00 
f0101c52:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101c59:	e8 36 e4 ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0101c5e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101c63:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101c66:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101c6d:	00 
f0101c6e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101c75:	00 
f0101c76:	89 14 24             	mov    %edx,(%esp)
f0101c79:	e8 70 f2 ff ff       	call   f0100eee <pgdir_walk>
f0101c7e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101c81:	83 c2 04             	add    $0x4,%edx
f0101c84:	39 d0                	cmp    %edx,%eax
f0101c86:	74 24                	je     f0101cac <mem_init+0xb70>
f0101c88:	c7 44 24 0c e8 44 10 	movl   $0xf01044e8,0xc(%esp)
f0101c8f:	f0 
f0101c90:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101c97:	f0 
f0101c98:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101c9f:	00 
f0101ca0:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101ca7:	e8 e8 e3 ff ff       	call   f0100094 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101cac:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0101cb3:	00 
f0101cb4:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101cbb:	00 
f0101cbc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101cc0:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101cc5:	89 04 24             	mov    %eax,(%esp)
f0101cc8:	e8 f5 f3 ff ff       	call   f01010c2 <page_insert>
f0101ccd:	85 c0                	test   %eax,%eax
f0101ccf:	74 24                	je     f0101cf5 <mem_init+0xbb9>
f0101cd1:	c7 44 24 0c 28 45 10 	movl   $0xf0104528,0xc(%esp)
f0101cd8:	f0 
f0101cd9:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101ce0:	f0 
f0101ce1:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101ce8:	00 
f0101ce9:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101cf0:	e8 9f e3 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101cf5:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f0101cfb:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f0101cfe:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d03:	89 c8                	mov    %ecx,%eax
f0101d05:	e8 ce eb ff ff       	call   f01008d8 <check_va2pa>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101d0a:	89 da                	mov    %ebx,%edx
f0101d0c:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0101d12:	c1 fa 03             	sar    $0x3,%edx
f0101d15:	c1 e2 0c             	shl    $0xc,%edx
f0101d18:	39 d0                	cmp    %edx,%eax
f0101d1a:	74 24                	je     f0101d40 <mem_init+0xc04>
f0101d1c:	c7 44 24 0c b8 44 10 	movl   $0xf01044b8,0xc(%esp)
f0101d23:	f0 
f0101d24:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101d2b:	f0 
f0101d2c:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101d33:	00 
f0101d34:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101d3b:	e8 54 e3 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0101d40:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101d45:	74 24                	je     f0101d6b <mem_init+0xc2f>
f0101d47:	c7 44 24 0c 43 4b 10 	movl   $0xf0104b43,0xc(%esp)
f0101d4e:	f0 
f0101d4f:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101d56:	f0 
f0101d57:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0101d5e:	00 
f0101d5f:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101d66:	e8 29 e3 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101d6b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101d72:	00 
f0101d73:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101d7a:	00 
f0101d7b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d7e:	89 04 24             	mov    %eax,(%esp)
f0101d81:	e8 68 f1 ff ff       	call   f0100eee <pgdir_walk>
f0101d86:	f6 00 04             	testb  $0x4,(%eax)
f0101d89:	75 24                	jne    f0101daf <mem_init+0xc73>
f0101d8b:	c7 44 24 0c 68 45 10 	movl   $0xf0104568,0xc(%esp)
f0101d92:	f0 
f0101d93:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101d9a:	f0 
f0101d9b:	c7 44 24 04 3c 03 00 	movl   $0x33c,0x4(%esp)
f0101da2:	00 
f0101da3:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101daa:	e8 e5 e2 ff ff       	call   f0100094 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101daf:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101db4:	f6 00 04             	testb  $0x4,(%eax)
f0101db7:	75 24                	jne    f0101ddd <mem_init+0xca1>
f0101db9:	c7 44 24 0c 54 4b 10 	movl   $0xf0104b54,0xc(%esp)
f0101dc0:	f0 
f0101dc1:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101dc8:	f0 
f0101dc9:	c7 44 24 04 3d 03 00 	movl   $0x33d,0x4(%esp)
f0101dd0:	00 
f0101dd1:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101dd8:	e8 b7 e2 ff ff       	call   f0100094 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101ddd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101de4:	00 
f0101de5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101dec:	00 
f0101ded:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101df1:	89 04 24             	mov    %eax,(%esp)
f0101df4:	e8 c9 f2 ff ff       	call   f01010c2 <page_insert>
f0101df9:	85 c0                	test   %eax,%eax
f0101dfb:	74 24                	je     f0101e21 <mem_init+0xce5>
f0101dfd:	c7 44 24 0c 7c 44 10 	movl   $0xf010447c,0xc(%esp)
f0101e04:	f0 
f0101e05:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101e0c:	f0 
f0101e0d:	c7 44 24 04 40 03 00 	movl   $0x340,0x4(%esp)
f0101e14:	00 
f0101e15:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101e1c:	e8 73 e2 ff ff       	call   f0100094 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101e21:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e28:	00 
f0101e29:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e30:	00 
f0101e31:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101e36:	89 04 24             	mov    %eax,(%esp)
f0101e39:	e8 b0 f0 ff ff       	call   f0100eee <pgdir_walk>
f0101e3e:	f6 00 02             	testb  $0x2,(%eax)
f0101e41:	75 24                	jne    f0101e67 <mem_init+0xd2b>
f0101e43:	c7 44 24 0c 9c 45 10 	movl   $0xf010459c,0xc(%esp)
f0101e4a:	f0 
f0101e4b:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101e52:	f0 
f0101e53:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101e5a:	00 
f0101e5b:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101e62:	e8 2d e2 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101e67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101e6e:	00 
f0101e6f:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101e76:	00 
f0101e77:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101e7c:	89 04 24             	mov    %eax,(%esp)
f0101e7f:	e8 6a f0 ff ff       	call   f0100eee <pgdir_walk>
f0101e84:	f6 00 04             	testb  $0x4,(%eax)
f0101e87:	74 24                	je     f0101ead <mem_init+0xd71>
f0101e89:	c7 44 24 0c d0 45 10 	movl   $0xf01045d0,0xc(%esp)
f0101e90:	f0 
f0101e91:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101e98:	f0 
f0101e99:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0101ea0:	00 
f0101ea1:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101ea8:	e8 e7 e1 ff ff       	call   f0100094 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ead:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101eb4:	00 
f0101eb5:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f0101ebc:	00 
f0101ebd:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0101ec1:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101ec6:	89 04 24             	mov    %eax,(%esp)
f0101ec9:	e8 f4 f1 ff ff       	call   f01010c2 <page_insert>
f0101ece:	85 c0                	test   %eax,%eax
f0101ed0:	78 24                	js     f0101ef6 <mem_init+0xdba>
f0101ed2:	c7 44 24 0c 08 46 10 	movl   $0xf0104608,0xc(%esp)
f0101ed9:	f0 
f0101eda:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101ee1:	f0 
f0101ee2:	c7 44 24 04 45 03 00 	movl   $0x345,0x4(%esp)
f0101ee9:	00 
f0101eea:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101ef1:	e8 9e e1 ff ff       	call   f0100094 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ef6:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101efd:	00 
f0101efe:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101f05:	00 
f0101f06:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101f0a:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101f0f:	89 04 24             	mov    %eax,(%esp)
f0101f12:	e8 ab f1 ff ff       	call   f01010c2 <page_insert>
f0101f17:	85 c0                	test   %eax,%eax
f0101f19:	74 24                	je     f0101f3f <mem_init+0xe03>
f0101f1b:	c7 44 24 0c 40 46 10 	movl   $0xf0104640,0xc(%esp)
f0101f22:	f0 
f0101f23:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101f2a:	f0 
f0101f2b:	c7 44 24 04 48 03 00 	movl   $0x348,0x4(%esp)
f0101f32:	00 
f0101f33:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101f3a:	e8 55 e1 ff ff       	call   f0100094 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101f3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101f46:	00 
f0101f47:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0101f4e:	00 
f0101f4f:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101f54:	89 04 24             	mov    %eax,(%esp)
f0101f57:	e8 92 ef ff ff       	call   f0100eee <pgdir_walk>
f0101f5c:	f6 00 04             	testb  $0x4,(%eax)
f0101f5f:	74 24                	je     f0101f85 <mem_init+0xe49>
f0101f61:	c7 44 24 0c d0 45 10 	movl   $0xf01045d0,0xc(%esp)
f0101f68:	f0 
f0101f69:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101f70:	f0 
f0101f71:	c7 44 24 04 49 03 00 	movl   $0x349,0x4(%esp)
f0101f78:	00 
f0101f79:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101f80:	e8 0f e1 ff ff       	call   f0100094 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101f85:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0101f8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f8d:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f92:	e8 41 e9 ff ff       	call   f01008d8 <check_va2pa>
f0101f97:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101f9a:	89 f0                	mov    %esi,%eax
f0101f9c:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0101fa2:	c1 f8 03             	sar    $0x3,%eax
f0101fa5:	c1 e0 0c             	shl    $0xc,%eax
f0101fa8:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fab:	74 24                	je     f0101fd1 <mem_init+0xe95>
f0101fad:	c7 44 24 0c 7c 46 10 	movl   $0xf010467c,0xc(%esp)
f0101fb4:	f0 
f0101fb5:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101fbc:	f0 
f0101fbd:	c7 44 24 04 4c 03 00 	movl   $0x34c,0x4(%esp)
f0101fc4:	00 
f0101fc5:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0101fcc:	e8 c3 e0 ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101fd1:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fd6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fd9:	e8 fa e8 ff ff       	call   f01008d8 <check_va2pa>
f0101fde:	39 45 d0             	cmp    %eax,-0x30(%ebp)
f0101fe1:	74 24                	je     f0102007 <mem_init+0xecb>
f0101fe3:	c7 44 24 0c a8 46 10 	movl   $0xf01046a8,0xc(%esp)
f0101fea:	f0 
f0101feb:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0101ff2:	f0 
f0101ff3:	c7 44 24 04 4d 03 00 	movl   $0x34d,0x4(%esp)
f0101ffa:	00 
f0101ffb:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102002:	e8 8d e0 ff ff       	call   f0100094 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102007:	66 83 7e 04 02       	cmpw   $0x2,0x4(%esi)
f010200c:	74 24                	je     f0102032 <mem_init+0xef6>
f010200e:	c7 44 24 0c 6a 4b 10 	movl   $0xf0104b6a,0xc(%esp)
f0102015:	f0 
f0102016:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010201d:	f0 
f010201e:	c7 44 24 04 4f 03 00 	movl   $0x34f,0x4(%esp)
f0102025:	00 
f0102026:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010202d:	e8 62 e0 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102032:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102037:	74 24                	je     f010205d <mem_init+0xf21>
f0102039:	c7 44 24 0c 7b 4b 10 	movl   $0xf0104b7b,0xc(%esp)
f0102040:	f0 
f0102041:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102048:	f0 
f0102049:	c7 44 24 04 50 03 00 	movl   $0x350,0x4(%esp)
f0102050:	00 
f0102051:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102058:	e8 37 e0 ff ff       	call   f0100094 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010205d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102064:	e8 a1 ed ff ff       	call   f0100e0a <page_alloc>
f0102069:	85 c0                	test   %eax,%eax
f010206b:	74 04                	je     f0102071 <mem_init+0xf35>
f010206d:	39 c3                	cmp    %eax,%ebx
f010206f:	74 24                	je     f0102095 <mem_init+0xf59>
f0102071:	c7 44 24 0c d8 46 10 	movl   $0xf01046d8,0xc(%esp)
f0102078:	f0 
f0102079:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102080:	f0 
f0102081:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0102088:	00 
f0102089:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102090:	e8 ff df ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0102095:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f010209c:	00 
f010209d:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01020a2:	89 04 24             	mov    %eax,(%esp)
f01020a5:	e8 cf ef ff ff       	call   f0101079 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01020aa:	8b 15 6c f9 11 f0    	mov    0xf011f96c,%edx
f01020b0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01020b3:	ba 00 00 00 00       	mov    $0x0,%edx
f01020b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020bb:	e8 18 e8 ff ff       	call   f01008d8 <check_va2pa>
f01020c0:	83 f8 ff             	cmp    $0xffffffff,%eax
f01020c3:	74 24                	je     f01020e9 <mem_init+0xfad>
f01020c5:	c7 44 24 0c fc 46 10 	movl   $0xf01046fc,0xc(%esp)
f01020cc:	f0 
f01020cd:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01020d4:	f0 
f01020d5:	c7 44 24 04 57 03 00 	movl   $0x357,0x4(%esp)
f01020dc:	00 
f01020dd:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01020e4:	e8 ab df ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01020e9:	ba 00 10 00 00       	mov    $0x1000,%edx
f01020ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020f1:	e8 e2 e7 ff ff       	call   f01008d8 <check_va2pa>
f01020f6:	89 f2                	mov    %esi,%edx
f01020f8:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f01020fe:	c1 fa 03             	sar    $0x3,%edx
f0102101:	c1 e2 0c             	shl    $0xc,%edx
f0102104:	39 d0                	cmp    %edx,%eax
f0102106:	74 24                	je     f010212c <mem_init+0xff0>
f0102108:	c7 44 24 0c a8 46 10 	movl   $0xf01046a8,0xc(%esp)
f010210f:	f0 
f0102110:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102117:	f0 
f0102118:	c7 44 24 04 58 03 00 	movl   $0x358,0x4(%esp)
f010211f:	00 
f0102120:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102127:	e8 68 df ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 1);
f010212c:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102131:	74 24                	je     f0102157 <mem_init+0x101b>
f0102133:	c7 44 24 0c 21 4b 10 	movl   $0xf0104b21,0xc(%esp)
f010213a:	f0 
f010213b:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102142:	f0 
f0102143:	c7 44 24 04 59 03 00 	movl   $0x359,0x4(%esp)
f010214a:	00 
f010214b:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102152:	e8 3d df ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f0102157:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f010215c:	74 24                	je     f0102182 <mem_init+0x1046>
f010215e:	c7 44 24 0c 7b 4b 10 	movl   $0xf0104b7b,0xc(%esp)
f0102165:	f0 
f0102166:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010216d:	f0 
f010216e:	c7 44 24 04 5a 03 00 	movl   $0x35a,0x4(%esp)
f0102175:	00 
f0102176:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010217d:	e8 12 df ff ff       	call   f0100094 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102182:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0102189:	00 
f010218a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102191:	00 
f0102192:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102196:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102199:	89 0c 24             	mov    %ecx,(%esp)
f010219c:	e8 21 ef ff ff       	call   f01010c2 <page_insert>
f01021a1:	85 c0                	test   %eax,%eax
f01021a3:	74 24                	je     f01021c9 <mem_init+0x108d>
f01021a5:	c7 44 24 0c 20 47 10 	movl   $0xf0104720,0xc(%esp)
f01021ac:	f0 
f01021ad:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01021b4:	f0 
f01021b5:	c7 44 24 04 5d 03 00 	movl   $0x35d,0x4(%esp)
f01021bc:	00 
f01021bd:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01021c4:	e8 cb de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref);
f01021c9:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01021ce:	75 24                	jne    f01021f4 <mem_init+0x10b8>
f01021d0:	c7 44 24 0c 8c 4b 10 	movl   $0xf0104b8c,0xc(%esp)
f01021d7:	f0 
f01021d8:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01021df:	f0 
f01021e0:	c7 44 24 04 5e 03 00 	movl   $0x35e,0x4(%esp)
f01021e7:	00 
f01021e8:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01021ef:	e8 a0 de ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_link == NULL);
f01021f4:	83 3e 00             	cmpl   $0x0,(%esi)
f01021f7:	74 24                	je     f010221d <mem_init+0x10e1>
f01021f9:	c7 44 24 0c 98 4b 10 	movl   $0xf0104b98,0xc(%esp)
f0102200:	f0 
f0102201:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102208:	f0 
f0102209:	c7 44 24 04 5f 03 00 	movl   $0x35f,0x4(%esp)
f0102210:	00 
f0102211:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102218:	e8 77 de ff ff       	call   f0100094 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f010221d:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102224:	00 
f0102225:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f010222a:	89 04 24             	mov    %eax,(%esp)
f010222d:	e8 47 ee ff ff       	call   f0101079 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102232:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102237:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010223a:	ba 00 00 00 00       	mov    $0x0,%edx
f010223f:	e8 94 e6 ff ff       	call   f01008d8 <check_va2pa>
f0102244:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102247:	74 24                	je     f010226d <mem_init+0x1131>
f0102249:	c7 44 24 0c fc 46 10 	movl   $0xf01046fc,0xc(%esp)
f0102250:	f0 
f0102251:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102258:	f0 
f0102259:	c7 44 24 04 63 03 00 	movl   $0x363,0x4(%esp)
f0102260:	00 
f0102261:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102268:	e8 27 de ff ff       	call   f0100094 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f010226d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102272:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102275:	e8 5e e6 ff ff       	call   f01008d8 <check_va2pa>
f010227a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010227d:	74 24                	je     f01022a3 <mem_init+0x1167>
f010227f:	c7 44 24 0c 58 47 10 	movl   $0xf0104758,0xc(%esp)
f0102286:	f0 
f0102287:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010228e:	f0 
f010228f:	c7 44 24 04 64 03 00 	movl   $0x364,0x4(%esp)
f0102296:	00 
f0102297:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010229e:	e8 f1 dd ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f01022a3:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01022a8:	74 24                	je     f01022ce <mem_init+0x1192>
f01022aa:	c7 44 24 0c ad 4b 10 	movl   $0xf0104bad,0xc(%esp)
f01022b1:	f0 
f01022b2:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01022b9:	f0 
f01022ba:	c7 44 24 04 65 03 00 	movl   $0x365,0x4(%esp)
f01022c1:	00 
f01022c2:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01022c9:	e8 c6 dd ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 0);
f01022ce:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f01022d3:	74 24                	je     f01022f9 <mem_init+0x11bd>
f01022d5:	c7 44 24 0c 7b 4b 10 	movl   $0xf0104b7b,0xc(%esp)
f01022dc:	f0 
f01022dd:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01022e4:	f0 
f01022e5:	c7 44 24 04 66 03 00 	movl   $0x366,0x4(%esp)
f01022ec:	00 
f01022ed:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01022f4:	e8 9b dd ff ff       	call   f0100094 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f01022f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102300:	e8 05 eb ff ff       	call   f0100e0a <page_alloc>
f0102305:	85 c0                	test   %eax,%eax
f0102307:	74 04                	je     f010230d <mem_init+0x11d1>
f0102309:	39 c6                	cmp    %eax,%esi
f010230b:	74 24                	je     f0102331 <mem_init+0x11f5>
f010230d:	c7 44 24 0c 80 47 10 	movl   $0xf0104780,0xc(%esp)
f0102314:	f0 
f0102315:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010231c:	f0 
f010231d:	c7 44 24 04 69 03 00 	movl   $0x369,0x4(%esp)
f0102324:	00 
f0102325:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010232c:	e8 63 dd ff ff       	call   f0100094 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102331:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102338:	e8 cd ea ff ff       	call   f0100e0a <page_alloc>
f010233d:	85 c0                	test   %eax,%eax
f010233f:	74 24                	je     f0102365 <mem_init+0x1229>
f0102341:	c7 44 24 0c cf 4a 10 	movl   $0xf0104acf,0xc(%esp)
f0102348:	f0 
f0102349:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102350:	f0 
f0102351:	c7 44 24 04 6c 03 00 	movl   $0x36c,0x4(%esp)
f0102358:	00 
f0102359:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102360:	e8 2f dd ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102365:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f010236a:	8b 08                	mov    (%eax),%ecx
f010236c:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102372:	89 fa                	mov    %edi,%edx
f0102374:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f010237a:	c1 fa 03             	sar    $0x3,%edx
f010237d:	c1 e2 0c             	shl    $0xc,%edx
f0102380:	39 d1                	cmp    %edx,%ecx
f0102382:	74 24                	je     f01023a8 <mem_init+0x126c>
f0102384:	c7 44 24 0c 24 44 10 	movl   $0xf0104424,0xc(%esp)
f010238b:	f0 
f010238c:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102393:	f0 
f0102394:	c7 44 24 04 6f 03 00 	movl   $0x36f,0x4(%esp)
f010239b:	00 
f010239c:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01023a3:	e8 ec dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f01023a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f01023ae:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01023b3:	74 24                	je     f01023d9 <mem_init+0x129d>
f01023b5:	c7 44 24 0c 32 4b 10 	movl   $0xf0104b32,0xc(%esp)
f01023bc:	f0 
f01023bd:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01023c4:	f0 
f01023c5:	c7 44 24 04 71 03 00 	movl   $0x371,0x4(%esp)
f01023cc:	00 
f01023cd:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01023d4:	e8 bb dc ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f01023d9:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01023df:	89 3c 24             	mov    %edi,(%esp)
f01023e2:	e8 a7 ea ff ff       	call   f0100e8e <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01023e7:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01023ee:	00 
f01023ef:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f01023f6:	00 
f01023f7:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f01023fc:	89 04 24             	mov    %eax,(%esp)
f01023ff:	e8 ea ea ff ff       	call   f0100eee <pgdir_walk>
f0102404:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102407:	8b 0d 6c f9 11 f0    	mov    0xf011f96c,%ecx
f010240d:	8b 51 04             	mov    0x4(%ecx),%edx
f0102410:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102416:	89 55 d4             	mov    %edx,-0x2c(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102419:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f010241f:	89 55 c8             	mov    %edx,-0x38(%ebp)
f0102422:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102425:	c1 ea 0c             	shr    $0xc,%edx
f0102428:	89 55 d0             	mov    %edx,-0x30(%ebp)
f010242b:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010242e:	39 55 d0             	cmp    %edx,-0x30(%ebp)
f0102431:	72 23                	jb     f0102456 <mem_init+0x131a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102433:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102436:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f010243a:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0102441:	f0 
f0102442:	c7 44 24 04 78 03 00 	movl   $0x378,0x4(%esp)
f0102449:	00 
f010244a:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102451:	e8 3e dc ff ff       	call   f0100094 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102456:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102459:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f010245f:	39 d0                	cmp    %edx,%eax
f0102461:	74 24                	je     f0102487 <mem_init+0x134b>
f0102463:	c7 44 24 0c be 4b 10 	movl   $0xf0104bbe,0xc(%esp)
f010246a:	f0 
f010246b:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102472:	f0 
f0102473:	c7 44 24 04 79 03 00 	movl   $0x379,0x4(%esp)
f010247a:	00 
f010247b:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102482:	e8 0d dc ff ff       	call   f0100094 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102487:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f010248e:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102494:	89 f8                	mov    %edi,%eax
f0102496:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f010249c:	c1 f8 03             	sar    $0x3,%eax
f010249f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024a2:	89 c1                	mov    %eax,%ecx
f01024a4:	c1 e9 0c             	shr    $0xc,%ecx
f01024a7:	39 4d c8             	cmp    %ecx,-0x38(%ebp)
f01024aa:	77 20                	ja     f01024cc <mem_init+0x1390>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01024ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01024b0:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f01024b7:	f0 
f01024b8:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f01024bf:	00 
f01024c0:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f01024c7:	e8 c8 db ff ff       	call   f0100094 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01024cc:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024d3:	00 
f01024d4:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f01024db:	00 
	return (void *)(pa + KERNBASE);
f01024dc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024e1:	89 04 24             	mov    %eax,(%esp)
f01024e4:	e8 19 13 00 00       	call   f0103802 <memset>
	page_free(pp0);
f01024e9:	89 3c 24             	mov    %edi,(%esp)
f01024ec:	e8 9d e9 ff ff       	call   f0100e8e <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01024f1:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01024f8:	00 
f01024f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102500:	00 
f0102501:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102506:	89 04 24             	mov    %eax,(%esp)
f0102509:	e8 e0 e9 ff ff       	call   f0100eee <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010250e:	89 fa                	mov    %edi,%edx
f0102510:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102516:	c1 fa 03             	sar    $0x3,%edx
f0102519:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010251c:	89 d0                	mov    %edx,%eax
f010251e:	c1 e8 0c             	shr    $0xc,%eax
f0102521:	3b 05 68 f9 11 f0    	cmp    0xf011f968,%eax
f0102527:	72 20                	jb     f0102549 <mem_init+0x140d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102529:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010252d:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0102534:	f0 
f0102535:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f010253c:	00 
f010253d:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f0102544:	e8 4b db ff ff       	call   f0100094 <_panic>
	return (void *)(pa + KERNBASE);
f0102549:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f010254f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102552:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102558:	f6 00 01             	testb  $0x1,(%eax)
f010255b:	74 24                	je     f0102581 <mem_init+0x1445>
f010255d:	c7 44 24 0c d6 4b 10 	movl   $0xf0104bd6,0xc(%esp)
f0102564:	f0 
f0102565:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010256c:	f0 
f010256d:	c7 44 24 04 83 03 00 	movl   $0x383,0x4(%esp)
f0102574:	00 
f0102575:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010257c:	e8 13 db ff ff       	call   f0100094 <_panic>
f0102581:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102584:	39 d0                	cmp    %edx,%eax
f0102586:	75 d0                	jne    f0102558 <mem_init+0x141c>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102588:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f010258d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102593:	66 c7 47 04 00 00    	movw   $0x0,0x4(%edi)

	// give free list back
	page_free_list = fl;
f0102599:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010259c:	89 0d 40 f5 11 f0    	mov    %ecx,0xf011f540

	// free the pages we took
	page_free(pp0);
f01025a2:	89 3c 24             	mov    %edi,(%esp)
f01025a5:	e8 e4 e8 ff ff       	call   f0100e8e <page_free>
	page_free(pp1);
f01025aa:	89 34 24             	mov    %esi,(%esp)
f01025ad:	e8 dc e8 ff ff       	call   f0100e8e <page_free>
	page_free(pp2);
f01025b2:	89 1c 24             	mov    %ebx,(%esp)
f01025b5:	e8 d4 e8 ff ff       	call   f0100e8e <page_free>

	cprintf("check_page() succeeded!\n");
f01025ba:	c7 04 24 ed 4b 10 f0 	movl   $0xf0104bed,(%esp)
f01025c1:	e8 98 07 00 00       	call   f0102d5e <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U | PTE_P);
f01025c6:	a1 70 f9 11 f0       	mov    0xf011f970,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025cb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01025d0:	77 20                	ja     f01025f2 <mem_init+0x14b6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01025d6:	c7 44 24 08 a8 41 10 	movl   $0xf01041a8,0x8(%esp)
f01025dd:	f0 
f01025de:	c7 44 24 04 b9 00 00 	movl   $0xb9,0x4(%esp)
f01025e5:	00 
f01025e6:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01025ed:	e8 a2 da ff ff       	call   f0100094 <_panic>
f01025f2:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
f01025f9:	00 
	return (physaddr_t)kva - KERNBASE;
f01025fa:	05 00 00 00 10       	add    $0x10000000,%eax
f01025ff:	89 04 24             	mov    %eax,(%esp)
f0102602:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102607:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010260c:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102611:	e8 77 e9 ff ff       	call   f0100f8d <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102616:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f010261b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102620:	77 20                	ja     f0102642 <mem_init+0x1506>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102622:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102626:	c7 44 24 08 a8 41 10 	movl   $0xf01041a8,0x8(%esp)
f010262d:	f0 
f010262e:	c7 44 24 04 c6 00 00 	movl   $0xc6,0x4(%esp)
f0102635:	00 
f0102636:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010263d:	e8 52 da ff ff       	call   f0100094 <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W | PTE_P);
f0102642:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102649:	00 
f010264a:	c7 04 24 00 50 11 00 	movl   $0x115000,(%esp)
f0102651:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102656:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010265b:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102660:	e8 28 e9 ff ff       	call   f0100f8d <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, 2*npages*PGSIZE, 0, PTE_W | PTE_P);
f0102665:	8b 0d 68 f9 11 f0    	mov    0xf011f968,%ecx
f010266b:	c1 e1 0d             	shl    $0xd,%ecx
f010266e:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
f0102675:	00 
f0102676:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010267d:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102682:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102687:	e8 01 e9 ff ff       	call   f0100f8d <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f010268c:	8b 1d 6c f9 11 f0    	mov    0xf011f96c,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0102692:	8b 15 68 f9 11 f0    	mov    0xf011f968,%edx
f0102698:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f010269b:	8d 3c d5 ff 0f 00 00 	lea    0xfff(,%edx,8),%edi
f01026a2:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = 0; i < n; i += PGSIZE) {
f01026a8:	be 00 00 00 00       	mov    $0x0,%esi
f01026ad:	eb 70                	jmp    f010271f <mem_init+0x15e3>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f01026af:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) {
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01026b5:	89 d8                	mov    %ebx,%eax
f01026b7:	e8 1c e2 ff ff       	call   f01008d8 <check_va2pa>
f01026bc:	8b 15 70 f9 11 f0    	mov    0xf011f970,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01026c2:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01026c8:	77 20                	ja     f01026ea <mem_init+0x15ae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01026ca:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01026ce:	c7 44 24 08 a8 41 10 	movl   $0xf01041a8,0x8(%esp)
f01026d5:	f0 
f01026d6:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f01026dd:	00 
f01026de:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01026e5:	e8 aa d9 ff ff       	call   f0100094 <_panic>
f01026ea:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f01026f1:	39 d0                	cmp    %edx,%eax
f01026f3:	74 24                	je     f0102719 <mem_init+0x15dd>
f01026f5:	c7 44 24 0c a4 47 10 	movl   $0xf01047a4,0xc(%esp)
f01026fc:	f0 
f01026fd:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102704:	f0 
f0102705:	c7 44 24 04 c7 02 00 	movl   $0x2c7,0x4(%esp)
f010270c:	00 
f010270d:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102714:	e8 7b d9 ff ff       	call   f0100094 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) {
f0102719:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010271f:	39 f7                	cmp    %esi,%edi
f0102721:	77 8c                	ja     f01026af <mem_init+0x1573>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) 
f0102723:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102726:	c1 e7 0c             	shl    $0xc,%edi
f0102729:	be 00 00 00 00       	mov    $0x0,%esi
f010272e:	eb 3b                	jmp    f010276b <mem_init+0x162f>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102730:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
	for (i = 0; i < n; i += PGSIZE) {
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) 
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102736:	89 d8                	mov    %ebx,%eax
f0102738:	e8 9b e1 ff ff       	call   f01008d8 <check_va2pa>
f010273d:	39 c6                	cmp    %eax,%esi
f010273f:	74 24                	je     f0102765 <mem_init+0x1629>
f0102741:	c7 44 24 0c d8 47 10 	movl   $0xf01047d8,0xc(%esp)
f0102748:	f0 
f0102749:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102750:	f0 
f0102751:	c7 44 24 04 cb 02 00 	movl   $0x2cb,0x4(%esp)
f0102758:	00 
f0102759:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102760:	e8 2f d9 ff ff       	call   f0100094 <_panic>
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE) {
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
	}
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) 
f0102765:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010276b:	39 fe                	cmp    %edi,%esi
f010276d:	72 c1                	jb     f0102730 <mem_init+0x15f4>
f010276f:	be 00 80 ff ef       	mov    $0xefff8000,%esi
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102774:	bf 00 50 11 f0       	mov    $0xf0115000,%edi
f0102779:	81 c7 00 80 00 20    	add    $0x20008000,%edi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) 
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010277f:	89 f2                	mov    %esi,%edx
f0102781:	89 d8                	mov    %ebx,%eax
f0102783:	e8 50 e1 ff ff       	call   f01008d8 <check_va2pa>
// will be set up later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102788:	8d 14 37             	lea    (%edi,%esi,1),%edx
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) 
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010278b:	39 d0                	cmp    %edx,%eax
f010278d:	74 24                	je     f01027b3 <mem_init+0x1677>
f010278f:	c7 44 24 0c 00 48 10 	movl   $0xf0104800,0xc(%esp)
f0102796:	f0 
f0102797:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010279e:	f0 
f010279f:	c7 44 24 04 cf 02 00 	movl   $0x2cf,0x4(%esp)
f01027a6:	00 
f01027a7:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01027ae:	e8 e1 d8 ff ff       	call   f0100094 <_panic>
f01027b3:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE) 
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01027b9:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f01027bf:	75 be                	jne    f010277f <mem_init+0x1643>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01027c1:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01027c6:	89 d8                	mov    %ebx,%eax
f01027c8:	e8 0b e1 ff ff       	call   f01008d8 <check_va2pa>
f01027cd:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027d0:	74 24                	je     f01027f6 <mem_init+0x16ba>
f01027d2:	c7 44 24 0c 48 48 10 	movl   $0xf0104848,0xc(%esp)
f01027d9:	f0 
f01027da:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01027e1:	f0 
f01027e2:	c7 44 24 04 d0 02 00 	movl   $0x2d0,0x4(%esp)
f01027e9:	00 
f01027ea:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01027f1:	e8 9e d8 ff ff       	call   f0100094 <_panic>
f01027f6:	b8 00 00 00 00       	mov    $0x0,%eax

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01027fb:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102800:	72 3c                	jb     f010283e <mem_init+0x1702>
f0102802:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102807:	76 07                	jbe    f0102810 <mem_init+0x16d4>
f0102809:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f010280e:	75 2e                	jne    f010283e <mem_init+0x1702>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102810:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0102814:	0f 85 aa 00 00 00    	jne    f01028c4 <mem_init+0x1788>
f010281a:	c7 44 24 0c 06 4c 10 	movl   $0xf0104c06,0xc(%esp)
f0102821:	f0 
f0102822:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102829:	f0 
f010282a:	c7 44 24 04 d8 02 00 	movl   $0x2d8,0x4(%esp)
f0102831:	00 
f0102832:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102839:	e8 56 d8 ff ff       	call   f0100094 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010283e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102843:	76 55                	jbe    f010289a <mem_init+0x175e>
				assert(pgdir[i] & PTE_P);
f0102845:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0102848:	f6 c2 01             	test   $0x1,%dl
f010284b:	75 24                	jne    f0102871 <mem_init+0x1735>
f010284d:	c7 44 24 0c 06 4c 10 	movl   $0xf0104c06,0xc(%esp)
f0102854:	f0 
f0102855:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010285c:	f0 
f010285d:	c7 44 24 04 dc 02 00 	movl   $0x2dc,0x4(%esp)
f0102864:	00 
f0102865:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010286c:	e8 23 d8 ff ff       	call   f0100094 <_panic>
				assert(pgdir[i] & PTE_W);
f0102871:	f6 c2 02             	test   $0x2,%dl
f0102874:	75 4e                	jne    f01028c4 <mem_init+0x1788>
f0102876:	c7 44 24 0c 17 4c 10 	movl   $0xf0104c17,0xc(%esp)
f010287d:	f0 
f010287e:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102885:	f0 
f0102886:	c7 44 24 04 dd 02 00 	movl   $0x2dd,0x4(%esp)
f010288d:	00 
f010288e:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102895:	e8 fa d7 ff ff       	call   f0100094 <_panic>
			} else
				assert(pgdir[i] == 0);
f010289a:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010289e:	74 24                	je     f01028c4 <mem_init+0x1788>
f01028a0:	c7 44 24 0c 28 4c 10 	movl   $0xf0104c28,0xc(%esp)
f01028a7:	f0 
f01028a8:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01028af:	f0 
f01028b0:	c7 44 24 04 df 02 00 	movl   $0x2df,0x4(%esp)
f01028b7:	00 
f01028b8:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01028bf:	e8 d0 d7 ff ff       	call   f0100094 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01028c4:	40                   	inc    %eax
f01028c5:	3d 00 04 00 00       	cmp    $0x400,%eax
f01028ca:	0f 85 2b ff ff ff    	jne    f01027fb <mem_init+0x16bf>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01028d0:	c7 04 24 78 48 10 f0 	movl   $0xf0104878,(%esp)
f01028d7:	e8 82 04 00 00       	call   f0102d5e <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01028dc:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028e1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028e6:	77 20                	ja     f0102908 <mem_init+0x17cc>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01028ec:	c7 44 24 08 a8 41 10 	movl   $0xf01041a8,0x8(%esp)
f01028f3:	f0 
f01028f4:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
f01028fb:	00 
f01028fc:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102903:	e8 8c d7 ff ff       	call   f0100094 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102908:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010290d:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102910:	b8 00 00 00 00       	mov    $0x0,%eax
f0102915:	e8 1d e1 ff ff       	call   f0100a37 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f010291a:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010291d:	0d 23 00 05 80       	or     $0x80050023,%eax
	cr0 &= ~(CR0_TS|CR0_EM);
f0102922:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102925:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102928:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010292f:	e8 d6 e4 ff ff       	call   f0100e0a <page_alloc>
f0102934:	89 c6                	mov    %eax,%esi
f0102936:	85 c0                	test   %eax,%eax
f0102938:	75 24                	jne    f010295e <mem_init+0x1822>
f010293a:	c7 44 24 0c 24 4a 10 	movl   $0xf0104a24,0xc(%esp)
f0102941:	f0 
f0102942:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102949:	f0 
f010294a:	c7 44 24 04 9e 03 00 	movl   $0x39e,0x4(%esp)
f0102951:	00 
f0102952:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102959:	e8 36 d7 ff ff       	call   f0100094 <_panic>
	assert((pp1 = page_alloc(0)));
f010295e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102965:	e8 a0 e4 ff ff       	call   f0100e0a <page_alloc>
f010296a:	89 c7                	mov    %eax,%edi
f010296c:	85 c0                	test   %eax,%eax
f010296e:	75 24                	jne    f0102994 <mem_init+0x1858>
f0102970:	c7 44 24 0c 3a 4a 10 	movl   $0xf0104a3a,0xc(%esp)
f0102977:	f0 
f0102978:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f010297f:	f0 
f0102980:	c7 44 24 04 9f 03 00 	movl   $0x39f,0x4(%esp)
f0102987:	00 
f0102988:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f010298f:	e8 00 d7 ff ff       	call   f0100094 <_panic>
	assert((pp2 = page_alloc(0)));
f0102994:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010299b:	e8 6a e4 ff ff       	call   f0100e0a <page_alloc>
f01029a0:	89 c3                	mov    %eax,%ebx
f01029a2:	85 c0                	test   %eax,%eax
f01029a4:	75 24                	jne    f01029ca <mem_init+0x188e>
f01029a6:	c7 44 24 0c 50 4a 10 	movl   $0xf0104a50,0xc(%esp)
f01029ad:	f0 
f01029ae:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f01029b5:	f0 
f01029b6:	c7 44 24 04 a0 03 00 	movl   $0x3a0,0x4(%esp)
f01029bd:	00 
f01029be:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f01029c5:	e8 ca d6 ff ff       	call   f0100094 <_panic>
	page_free(pp0);
f01029ca:	89 34 24             	mov    %esi,(%esp)
f01029cd:	e8 bc e4 ff ff       	call   f0100e8e <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029d2:	89 f8                	mov    %edi,%eax
f01029d4:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f01029da:	c1 f8 03             	sar    $0x3,%eax
f01029dd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029e0:	89 c2                	mov    %eax,%edx
f01029e2:	c1 ea 0c             	shr    $0xc,%edx
f01029e5:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f01029eb:	72 20                	jb     f0102a0d <mem_init+0x18d1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01029f1:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f01029f8:	f0 
f01029f9:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102a00:	00 
f0102a01:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f0102a08:	e8 87 d6 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102a0d:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a14:	00 
f0102a15:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0102a1c:	00 
	return (void *)(pa + KERNBASE);
f0102a1d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a22:	89 04 24             	mov    %eax,(%esp)
f0102a25:	e8 d8 0d 00 00       	call   f0103802 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102a2a:	89 d8                	mov    %ebx,%eax
f0102a2c:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0102a32:	c1 f8 03             	sar    $0x3,%eax
f0102a35:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102a38:	89 c2                	mov    %eax,%edx
f0102a3a:	c1 ea 0c             	shr    $0xc,%edx
f0102a3d:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0102a43:	72 20                	jb     f0102a65 <mem_init+0x1929>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102a45:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102a49:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0102a50:	f0 
f0102a51:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102a58:	00 
f0102a59:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f0102a60:	e8 2f d6 ff ff       	call   f0100094 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102a65:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a6c:	00 
f0102a6d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0102a74:	00 
	return (void *)(pa + KERNBASE);
f0102a75:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a7a:	89 04 24             	mov    %eax,(%esp)
f0102a7d:	e8 80 0d 00 00       	call   f0103802 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a82:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102a89:	00 
f0102a8a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102a91:	00 
f0102a92:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102a96:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102a9b:	89 04 24             	mov    %eax,(%esp)
f0102a9e:	e8 1f e6 ff ff       	call   f01010c2 <page_insert>
	assert(pp1->pp_ref == 1);
f0102aa3:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102aa8:	74 24                	je     f0102ace <mem_init+0x1992>
f0102aaa:	c7 44 24 0c 21 4b 10 	movl   $0xf0104b21,0xc(%esp)
f0102ab1:	f0 
f0102ab2:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102ab9:	f0 
f0102aba:	c7 44 24 04 a5 03 00 	movl   $0x3a5,0x4(%esp)
f0102ac1:	00 
f0102ac2:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102ac9:	e8 c6 d5 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ace:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102ad5:	01 01 01 
f0102ad8:	74 24                	je     f0102afe <mem_init+0x19c2>
f0102ada:	c7 44 24 0c 98 48 10 	movl   $0xf0104898,0xc(%esp)
f0102ae1:	f0 
f0102ae2:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102ae9:	f0 
f0102aea:	c7 44 24 04 a6 03 00 	movl   $0x3a6,0x4(%esp)
f0102af1:	00 
f0102af2:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102af9:	e8 96 d5 ff ff       	call   f0100094 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102afe:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102b05:	00 
f0102b06:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102b0d:	00 
f0102b0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102b12:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102b17:	89 04 24             	mov    %eax,(%esp)
f0102b1a:	e8 a3 e5 ff ff       	call   f01010c2 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102b1f:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102b26:	02 02 02 
f0102b29:	74 24                	je     f0102b4f <mem_init+0x1a13>
f0102b2b:	c7 44 24 0c bc 48 10 	movl   $0xf01048bc,0xc(%esp)
f0102b32:	f0 
f0102b33:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102b3a:	f0 
f0102b3b:	c7 44 24 04 a8 03 00 	movl   $0x3a8,0x4(%esp)
f0102b42:	00 
f0102b43:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102b4a:	e8 45 d5 ff ff       	call   f0100094 <_panic>
	assert(pp2->pp_ref == 1);
f0102b4f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b54:	74 24                	je     f0102b7a <mem_init+0x1a3e>
f0102b56:	c7 44 24 0c 43 4b 10 	movl   $0xf0104b43,0xc(%esp)
f0102b5d:	f0 
f0102b5e:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102b65:	f0 
f0102b66:	c7 44 24 04 a9 03 00 	movl   $0x3a9,0x4(%esp)
f0102b6d:	00 
f0102b6e:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102b75:	e8 1a d5 ff ff       	call   f0100094 <_panic>
	assert(pp1->pp_ref == 0);
f0102b7a:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102b7f:	74 24                	je     f0102ba5 <mem_init+0x1a69>
f0102b81:	c7 44 24 0c ad 4b 10 	movl   $0xf0104bad,0xc(%esp)
f0102b88:	f0 
f0102b89:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102b90:	f0 
f0102b91:	c7 44 24 04 aa 03 00 	movl   $0x3aa,0x4(%esp)
f0102b98:	00 
f0102b99:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102ba0:	e8 ef d4 ff ff       	call   f0100094 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102ba5:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102bac:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102baf:	89 d8                	mov    %ebx,%eax
f0102bb1:	2b 05 70 f9 11 f0    	sub    0xf011f970,%eax
f0102bb7:	c1 f8 03             	sar    $0x3,%eax
f0102bba:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bbd:	89 c2                	mov    %eax,%edx
f0102bbf:	c1 ea 0c             	shr    $0xc,%edx
f0102bc2:	3b 15 68 f9 11 f0    	cmp    0xf011f968,%edx
f0102bc8:	72 20                	jb     f0102bea <mem_init+0x1aae>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bca:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102bce:	c7 44 24 08 84 41 10 	movl   $0xf0104184,0x8(%esp)
f0102bd5:	f0 
f0102bd6:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
f0102bdd:	00 
f0102bde:	c7 04 24 5f 49 10 f0 	movl   $0xf010495f,(%esp)
f0102be5:	e8 aa d4 ff ff       	call   f0100094 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102bea:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102bf1:	03 03 03 
f0102bf4:	74 24                	je     f0102c1a <mem_init+0x1ade>
f0102bf6:	c7 44 24 0c e0 48 10 	movl   $0xf01048e0,0xc(%esp)
f0102bfd:	f0 
f0102bfe:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102c05:	f0 
f0102c06:	c7 44 24 04 ac 03 00 	movl   $0x3ac,0x4(%esp)
f0102c0d:	00 
f0102c0e:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102c15:	e8 7a d4 ff ff       	call   f0100094 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102c1a:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102c21:	00 
f0102c22:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102c27:	89 04 24             	mov    %eax,(%esp)
f0102c2a:	e8 4a e4 ff ff       	call   f0101079 <page_remove>
	assert(pp2->pp_ref == 0);
f0102c2f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102c34:	74 24                	je     f0102c5a <mem_init+0x1b1e>
f0102c36:	c7 44 24 0c 7b 4b 10 	movl   $0xf0104b7b,0xc(%esp)
f0102c3d:	f0 
f0102c3e:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102c45:	f0 
f0102c46:	c7 44 24 04 ae 03 00 	movl   $0x3ae,0x4(%esp)
f0102c4d:	00 
f0102c4e:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102c55:	e8 3a d4 ff ff       	call   f0100094 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102c5a:	a1 6c f9 11 f0       	mov    0xf011f96c,%eax
f0102c5f:	8b 08                	mov    (%eax),%ecx
f0102c61:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c67:	89 f2                	mov    %esi,%edx
f0102c69:	2b 15 70 f9 11 f0    	sub    0xf011f970,%edx
f0102c6f:	c1 fa 03             	sar    $0x3,%edx
f0102c72:	c1 e2 0c             	shl    $0xc,%edx
f0102c75:	39 d1                	cmp    %edx,%ecx
f0102c77:	74 24                	je     f0102c9d <mem_init+0x1b61>
f0102c79:	c7 44 24 0c 24 44 10 	movl   $0xf0104424,0xc(%esp)
f0102c80:	f0 
f0102c81:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102c88:	f0 
f0102c89:	c7 44 24 04 b1 03 00 	movl   $0x3b1,0x4(%esp)
f0102c90:	00 
f0102c91:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102c98:	e8 f7 d3 ff ff       	call   f0100094 <_panic>
	kern_pgdir[0] = 0;
f0102c9d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102ca3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102ca8:	74 24                	je     f0102cce <mem_init+0x1b92>
f0102caa:	c7 44 24 0c 32 4b 10 	movl   $0xf0104b32,0xc(%esp)
f0102cb1:	f0 
f0102cb2:	c7 44 24 08 79 49 10 	movl   $0xf0104979,0x8(%esp)
f0102cb9:	f0 
f0102cba:	c7 44 24 04 b3 03 00 	movl   $0x3b3,0x4(%esp)
f0102cc1:	00 
f0102cc2:	c7 04 24 38 49 10 f0 	movl   $0xf0104938,(%esp)
f0102cc9:	e8 c6 d3 ff ff       	call   f0100094 <_panic>
	pp0->pp_ref = 0;
f0102cce:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102cd4:	89 34 24             	mov    %esi,(%esp)
f0102cd7:	e8 b2 e1 ff ff       	call   f0100e8e <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102cdc:	c7 04 24 0c 49 10 f0 	movl   $0xf010490c,(%esp)
f0102ce3:	e8 76 00 00 00       	call   f0102d5e <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102ce8:	83 c4 3c             	add    $0x3c,%esp
f0102ceb:	5b                   	pop    %ebx
f0102cec:	5e                   	pop    %esi
f0102ced:	5f                   	pop    %edi
f0102cee:	5d                   	pop    %ebp
f0102cef:	c3                   	ret    

f0102cf0 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102cf0:	55                   	push   %ebp
f0102cf1:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102cf3:	ba 70 00 00 00       	mov    $0x70,%edx
f0102cf8:	8b 45 08             	mov    0x8(%ebp),%eax
f0102cfb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102cfc:	b2 71                	mov    $0x71,%dl
f0102cfe:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102cff:	0f b6 c0             	movzbl %al,%eax
}
f0102d02:	5d                   	pop    %ebp
f0102d03:	c3                   	ret    

f0102d04 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102d04:	55                   	push   %ebp
f0102d05:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102d07:	ba 70 00 00 00       	mov    $0x70,%edx
f0102d0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d0f:	ee                   	out    %al,(%dx)
f0102d10:	b2 71                	mov    $0x71,%dl
f0102d12:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d15:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102d16:	5d                   	pop    %ebp
f0102d17:	c3                   	ret    

f0102d18 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102d18:	55                   	push   %ebp
f0102d19:	89 e5                	mov    %esp,%ebp
f0102d1b:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0102d1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d21:	89 04 24             	mov    %eax,(%esp)
f0102d24:	e8 8f d8 ff ff       	call   f01005b8 <cputchar>
	*cnt++;
}
f0102d29:	c9                   	leave  
f0102d2a:	c3                   	ret    

f0102d2b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102d2b:	55                   	push   %ebp
f0102d2c:	89 e5                	mov    %esp,%ebp
f0102d2e:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0102d31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102d38:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d3b:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102d3f:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d42:	89 44 24 08          	mov    %eax,0x8(%esp)
f0102d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102d49:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d4d:	c7 04 24 18 2d 10 f0 	movl   $0xf0102d18,(%esp)
f0102d54:	e8 69 04 00 00       	call   f01031c2 <vprintfmt>
	return cnt;
}
f0102d59:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102d5c:	c9                   	leave  
f0102d5d:	c3                   	ret    

f0102d5e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102d5e:	55                   	push   %ebp
f0102d5f:	89 e5                	mov    %esp,%ebp
f0102d61:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102d64:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102d67:	89 44 24 04          	mov    %eax,0x4(%esp)
f0102d6b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d6e:	89 04 24             	mov    %eax,(%esp)
f0102d71:	e8 b5 ff ff ff       	call   f0102d2b <vcprintf>
	va_end(ap);

	return cnt;
}
f0102d76:	c9                   	leave  
f0102d77:	c3                   	ret    

f0102d78 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102d78:	55                   	push   %ebp
f0102d79:	89 e5                	mov    %esp,%ebp
f0102d7b:	57                   	push   %edi
f0102d7c:	56                   	push   %esi
f0102d7d:	53                   	push   %ebx
f0102d7e:	83 ec 10             	sub    $0x10,%esp
f0102d81:	89 c3                	mov    %eax,%ebx
f0102d83:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0102d86:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
f0102d89:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102d8c:	8b 0a                	mov    (%edx),%ecx
f0102d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102d91:	8b 00                	mov    (%eax),%eax
f0102d93:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102d96:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)

	while (l <= r) {
f0102d9d:	eb 77                	jmp    f0102e16 <stab_binsearch+0x9e>
		int true_m = (l + r) / 2, m = true_m;
f0102d9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0102da2:	01 c8                	add    %ecx,%eax
f0102da4:	bf 02 00 00 00       	mov    $0x2,%edi
f0102da9:	99                   	cltd   
f0102daa:	f7 ff                	idiv   %edi
f0102dac:	89 c2                	mov    %eax,%edx

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102dae:	eb 01                	jmp    f0102db1 <stab_binsearch+0x39>
			m--;
f0102db0:	4a                   	dec    %edx

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102db1:	39 ca                	cmp    %ecx,%edx
f0102db3:	7c 1d                	jl     f0102dd2 <stab_binsearch+0x5a>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102db5:	6b fa 0c             	imul   $0xc,%edx,%edi

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102db8:	0f b6 7c 3b 04       	movzbl 0x4(%ebx,%edi,1),%edi
f0102dbd:	39 f7                	cmp    %esi,%edi
f0102dbf:	75 ef                	jne    f0102db0 <stab_binsearch+0x38>
f0102dc1:	89 55 ec             	mov    %edx,-0x14(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102dc4:	6b fa 0c             	imul   $0xc,%edx,%edi
f0102dc7:	8b 7c 3b 08          	mov    0x8(%ebx,%edi,1),%edi
f0102dcb:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102dce:	73 18                	jae    f0102de8 <stab_binsearch+0x70>
f0102dd0:	eb 05                	jmp    f0102dd7 <stab_binsearch+0x5f>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102dd2:	8d 48 01             	lea    0x1(%eax),%ecx
			continue;
f0102dd5:	eb 3f                	jmp    f0102e16 <stab_binsearch+0x9e>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102dd7:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102dda:	89 11                	mov    %edx,(%ecx)
			l = true_m + 1;
f0102ddc:	8d 48 01             	lea    0x1(%eax),%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102ddf:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102de6:	eb 2e                	jmp    f0102e16 <stab_binsearch+0x9e>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102de8:	3b 7d 0c             	cmp    0xc(%ebp),%edi
f0102deb:	76 15                	jbe    f0102e02 <stab_binsearch+0x8a>
			*region_right = m - 1;
f0102ded:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102df0:	4f                   	dec    %edi
f0102df1:	89 7d f0             	mov    %edi,-0x10(%ebp)
f0102df4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102df7:	89 38                	mov    %edi,(%eax)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102df9:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
f0102e00:	eb 14                	jmp    f0102e16 <stab_binsearch+0x9e>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102e02:	8b 7d ec             	mov    -0x14(%ebp),%edi
f0102e05:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0102e08:	89 39                	mov    %edi,(%ecx)
			l = m;
			addr++;
f0102e0a:	ff 45 0c             	incl   0xc(%ebp)
f0102e0d:	89 d1                	mov    %edx,%ecx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102e0f:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102e16:	3b 4d f0             	cmp    -0x10(%ebp),%ecx
f0102e19:	7e 84                	jle    f0102d9f <stab_binsearch+0x27>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102e1b:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
f0102e1f:	75 0d                	jne    f0102e2e <stab_binsearch+0xb6>
		*region_right = *region_left - 1;
f0102e21:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e24:	8b 02                	mov    (%edx),%eax
f0102e26:	48                   	dec    %eax
f0102e27:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e2a:	89 01                	mov    %eax,(%ecx)
f0102e2c:	eb 22                	jmp    f0102e50 <stab_binsearch+0xd8>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e2e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102e31:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102e33:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e36:	8b 0a                	mov    (%edx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e38:	eb 01                	jmp    f0102e3b <stab_binsearch+0xc3>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102e3a:	48                   	dec    %eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102e3b:	39 c1                	cmp    %eax,%ecx
f0102e3d:	7d 0c                	jge    f0102e4b <stab_binsearch+0xd3>
//		left = 0, right = 657;
//		stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
f0102e3f:	6b d0 0c             	imul   $0xc,%eax,%edx
	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
		     l > *region_left && stabs[l].n_type != type;
f0102e42:	0f b6 54 13 04       	movzbl 0x4(%ebx,%edx,1),%edx
f0102e47:	39 f2                	cmp    %esi,%edx
f0102e49:	75 ef                	jne    f0102e3a <stab_binsearch+0xc2>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102e4b:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0102e4e:	89 02                	mov    %eax,(%edx)
	}
}
f0102e50:	83 c4 10             	add    $0x10,%esp
f0102e53:	5b                   	pop    %ebx
f0102e54:	5e                   	pop    %esi
f0102e55:	5f                   	pop    %edi
f0102e56:	5d                   	pop    %ebp
f0102e57:	c3                   	ret    

f0102e58 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102e58:	55                   	push   %ebp
f0102e59:	89 e5                	mov    %esp,%ebp
f0102e5b:	57                   	push   %edi
f0102e5c:	56                   	push   %esi
f0102e5d:	53                   	push   %ebx
f0102e5e:	83 ec 4c             	sub    $0x4c,%esp
f0102e61:	8b 75 08             	mov    0x8(%ebp),%esi
f0102e64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102e67:	c7 03 36 4c 10 f0    	movl   $0xf0104c36,(%ebx)
	info->eip_line = 0;
f0102e6d:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0102e74:	c7 43 08 36 4c 10 f0 	movl   $0xf0104c36,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0102e7b:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0102e82:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0102e85:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0102e8c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0102e92:	76 12                	jbe    f0102ea6 <debuginfo_eip+0x4e>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102e94:	b8 8e 4a 11 f0       	mov    $0xf0114a8e,%eax
f0102e99:	3d ed b8 10 f0       	cmp    $0xf010b8ed,%eax
f0102e9e:	0f 86 a7 01 00 00    	jbe    f010304b <debuginfo_eip+0x1f3>
f0102ea4:	eb 1c                	jmp    f0102ec2 <debuginfo_eip+0x6a>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0102ea6:	c7 44 24 08 40 4c 10 	movl   $0xf0104c40,0x8(%esp)
f0102ead:	f0 
f0102eae:	c7 44 24 04 7f 00 00 	movl   $0x7f,0x4(%esp)
f0102eb5:	00 
f0102eb6:	c7 04 24 4d 4c 10 f0 	movl   $0xf0104c4d,(%esp)
f0102ebd:	e8 d2 d1 ff ff       	call   f0100094 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102ec2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102ec7:	80 3d 8d 4a 11 f0 00 	cmpb   $0x0,0xf0114a8d
f0102ece:	0f 85 83 01 00 00    	jne    f0103057 <debuginfo_eip+0x1ff>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102ed4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0102edb:	b8 ec b8 10 f0       	mov    $0xf010b8ec,%eax
f0102ee0:	2d 6c 4e 10 f0       	sub    $0xf0104e6c,%eax
f0102ee5:	c1 f8 02             	sar    $0x2,%eax
f0102ee8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0102eee:	48                   	dec    %eax
f0102eef:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102ef2:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102ef6:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0102efd:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0102f00:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102f03:	b8 6c 4e 10 f0       	mov    $0xf0104e6c,%eax
f0102f08:	e8 6b fe ff ff       	call   f0102d78 <stab_binsearch>
	if (lfile == 0)
f0102f0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
		return -1;
f0102f10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
f0102f15:	85 d2                	test   %edx,%edx
f0102f17:	0f 84 3a 01 00 00    	je     f0103057 <debuginfo_eip+0x1ff>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102f1d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	rfun = rfile;
f0102f20:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f23:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102f26:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102f2a:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0102f31:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102f34:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0102f37:	b8 6c 4e 10 f0       	mov    $0xf0104e6c,%eax
f0102f3c:	e8 37 fe ff ff       	call   f0102d78 <stab_binsearch>

	if (lfun <= rfun) {
f0102f41:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102f44:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f47:	39 d0                	cmp    %edx,%eax
f0102f49:	7f 3e                	jg     f0102f89 <debuginfo_eip+0x131>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102f4b:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0102f4e:	8d b9 6c 4e 10 f0    	lea    -0xfefb194(%ecx),%edi
f0102f54:	8b 89 6c 4e 10 f0    	mov    -0xfefb194(%ecx),%ecx
f0102f5a:	89 4d c0             	mov    %ecx,-0x40(%ebp)
f0102f5d:	b9 8e 4a 11 f0       	mov    $0xf0114a8e,%ecx
f0102f62:	81 e9 ed b8 10 f0    	sub    $0xf010b8ed,%ecx
f0102f68:	39 4d c0             	cmp    %ecx,-0x40(%ebp)
f0102f6b:	73 0c                	jae    f0102f79 <debuginfo_eip+0x121>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102f6d:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0102f70:	81 c1 ed b8 10 f0    	add    $0xf010b8ed,%ecx
f0102f76:	89 4b 08             	mov    %ecx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0102f79:	8b 4f 08             	mov    0x8(%edi),%ecx
f0102f7c:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0102f7f:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0102f81:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0102f84:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0102f87:	eb 0f                	jmp    f0102f98 <debuginfo_eip+0x140>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102f89:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0102f8c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102f8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0102f92:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f95:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102f98:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0102f9f:	00 
f0102fa0:	8b 43 08             	mov    0x8(%ebx),%eax
f0102fa3:	89 04 24             	mov    %eax,(%esp)
f0102fa6:	e8 3f 08 00 00       	call   f01037ea <strfind>
f0102fab:	2b 43 08             	sub    0x8(%ebx),%eax
f0102fae:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0102fb1:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102fb5:	c7 04 24 44 00 00 00 	movl   $0x44,(%esp)
f0102fbc:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0102fbf:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0102fc2:	b8 6c 4e 10 f0       	mov    $0xf0104e6c,%eax
f0102fc7:	e8 ac fd ff ff       	call   f0102d78 <stab_binsearch>
	if (lline > rline) {
f0102fcc:	8b 55 d0             	mov    -0x30(%ebp),%edx
		return -1;
f0102fcf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline) {
f0102fd4:	39 55 d4             	cmp    %edx,-0x2c(%ebp)
f0102fd7:	7f 7e                	jg     f0103057 <debuginfo_eip+0x1ff>
		return -1;
	}
	info->eip_line = stabs[rline].n_desc;
f0102fd9:	6b d2 0c             	imul   $0xc,%edx,%edx
f0102fdc:	0f b7 82 72 4e 10 f0 	movzwl -0xfefb18e(%edx),%eax
f0102fe3:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0102fe6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102fe9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102fec:	eb 01                	jmp    f0102fef <debuginfo_eip+0x197>
f0102fee:	48                   	dec    %eax
f0102fef:	89 c6                	mov    %eax,%esi
f0102ff1:	39 c7                	cmp    %eax,%edi
f0102ff3:	7f 26                	jg     f010301b <debuginfo_eip+0x1c3>
	       && stabs[lline].n_type != N_SOL
f0102ff5:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0102ff8:	8d 0c 95 6c 4e 10 f0 	lea    -0xfefb194(,%edx,4),%ecx
f0102fff:	8a 51 04             	mov    0x4(%ecx),%dl
f0103002:	80 fa 84             	cmp    $0x84,%dl
f0103005:	74 58                	je     f010305f <debuginfo_eip+0x207>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0103007:	80 fa 64             	cmp    $0x64,%dl
f010300a:	75 e2                	jne    f0102fee <debuginfo_eip+0x196>
f010300c:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0103010:	74 dc                	je     f0102fee <debuginfo_eip+0x196>
f0103012:	eb 4b                	jmp    f010305f <debuginfo_eip+0x207>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0103014:	05 ed b8 10 f0       	add    $0xf010b8ed,%eax
f0103019:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010301b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f010301e:	8b 55 d8             	mov    -0x28(%ebp),%edx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103021:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103026:	39 d1                	cmp    %edx,%ecx
f0103028:	7d 2d                	jge    f0103057 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
f010302a:	8d 41 01             	lea    0x1(%ecx),%eax
f010302d:	eb 03                	jmp    f0103032 <debuginfo_eip+0x1da>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010302f:	ff 43 14             	incl   0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103032:	39 d0                	cmp    %edx,%eax
f0103034:	7d 1c                	jge    f0103052 <debuginfo_eip+0x1fa>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103036:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0103039:	40                   	inc    %eax
f010303a:	80 3c 8d 70 4e 10 f0 	cmpb   $0xa0,-0xfefb190(,%ecx,4)
f0103041:	a0 
f0103042:	74 eb                	je     f010302f <debuginfo_eip+0x1d7>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103044:	b8 00 00 00 00       	mov    $0x0,%eax
f0103049:	eb 0c                	jmp    f0103057 <debuginfo_eip+0x1ff>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010304b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103050:	eb 05                	jmp    f0103057 <debuginfo_eip+0x1ff>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103052:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103057:	83 c4 4c             	add    $0x4c,%esp
f010305a:	5b                   	pop    %ebx
f010305b:	5e                   	pop    %esi
f010305c:	5f                   	pop    %edi
f010305d:	5d                   	pop    %ebp
f010305e:	c3                   	ret    
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010305f:	6b f6 0c             	imul   $0xc,%esi,%esi
f0103062:	8b 86 6c 4e 10 f0    	mov    -0xfefb194(%esi),%eax
f0103068:	ba 8e 4a 11 f0       	mov    $0xf0114a8e,%edx
f010306d:	81 ea ed b8 10 f0    	sub    $0xf010b8ed,%edx
f0103073:	39 d0                	cmp    %edx,%eax
f0103075:	72 9d                	jb     f0103014 <debuginfo_eip+0x1bc>
f0103077:	eb a2                	jmp    f010301b <debuginfo_eip+0x1c3>
f0103079:	00 00                	add    %al,(%eax)
	...

f010307c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010307c:	55                   	push   %ebp
f010307d:	89 e5                	mov    %esp,%ebp
f010307f:	57                   	push   %edi
f0103080:	56                   	push   %esi
f0103081:	53                   	push   %ebx
f0103082:	83 ec 3c             	sub    $0x3c,%esp
f0103085:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103088:	89 d7                	mov    %edx,%edi
f010308a:	8b 45 08             	mov    0x8(%ebp),%eax
f010308d:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103090:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103093:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103096:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0103099:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010309c:	85 c0                	test   %eax,%eax
f010309e:	75 08                	jne    f01030a8 <printnum+0x2c>
f01030a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01030a3:	39 45 10             	cmp    %eax,0x10(%ebp)
f01030a6:	77 57                	ja     f01030ff <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01030a8:	89 74 24 10          	mov    %esi,0x10(%esp)
f01030ac:	4b                   	dec    %ebx
f01030ad:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f01030b1:	8b 45 10             	mov    0x10(%ebp),%eax
f01030b4:	89 44 24 08          	mov    %eax,0x8(%esp)
f01030b8:	8b 5c 24 08          	mov    0x8(%esp),%ebx
f01030bc:	8b 74 24 0c          	mov    0xc(%esp),%esi
f01030c0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f01030c7:	00 
f01030c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01030cb:	89 04 24             	mov    %eax,(%esp)
f01030ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01030d1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01030d5:	e8 1e 09 00 00       	call   f01039f8 <__udivdi3>
f01030da:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01030de:	89 74 24 0c          	mov    %esi,0xc(%esp)
f01030e2:	89 04 24             	mov    %eax,(%esp)
f01030e5:	89 54 24 04          	mov    %edx,0x4(%esp)
f01030e9:	89 fa                	mov    %edi,%edx
f01030eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030ee:	e8 89 ff ff ff       	call   f010307c <printnum>
f01030f3:	eb 0f                	jmp    f0103104 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01030f5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01030f9:	89 34 24             	mov    %esi,(%esp)
f01030fc:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01030ff:	4b                   	dec    %ebx
f0103100:	85 db                	test   %ebx,%ebx
f0103102:	7f f1                	jg     f01030f5 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103104:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103108:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010310c:	8b 45 10             	mov    0x10(%ebp),%eax
f010310f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103113:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f010311a:	00 
f010311b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010311e:	89 04 24             	mov    %eax,(%esp)
f0103121:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103124:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103128:	e8 eb 09 00 00       	call   f0103b18 <__umoddi3>
f010312d:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103131:	0f be 80 5b 4c 10 f0 	movsbl -0xfefb3a5(%eax),%eax
f0103138:	89 04 24             	mov    %eax,(%esp)
f010313b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f010313e:	83 c4 3c             	add    $0x3c,%esp
f0103141:	5b                   	pop    %ebx
f0103142:	5e                   	pop    %esi
f0103143:	5f                   	pop    %edi
f0103144:	5d                   	pop    %ebp
f0103145:	c3                   	ret    

f0103146 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0103146:	55                   	push   %ebp
f0103147:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0103149:	83 fa 01             	cmp    $0x1,%edx
f010314c:	7e 0e                	jle    f010315c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f010314e:	8b 10                	mov    (%eax),%edx
f0103150:	8d 4a 08             	lea    0x8(%edx),%ecx
f0103153:	89 08                	mov    %ecx,(%eax)
f0103155:	8b 02                	mov    (%edx),%eax
f0103157:	8b 52 04             	mov    0x4(%edx),%edx
f010315a:	eb 22                	jmp    f010317e <getuint+0x38>
	else if (lflag)
f010315c:	85 d2                	test   %edx,%edx
f010315e:	74 10                	je     f0103170 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0103160:	8b 10                	mov    (%eax),%edx
f0103162:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103165:	89 08                	mov    %ecx,(%eax)
f0103167:	8b 02                	mov    (%edx),%eax
f0103169:	ba 00 00 00 00       	mov    $0x0,%edx
f010316e:	eb 0e                	jmp    f010317e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0103170:	8b 10                	mov    (%eax),%edx
f0103172:	8d 4a 04             	lea    0x4(%edx),%ecx
f0103175:	89 08                	mov    %ecx,(%eax)
f0103177:	8b 02                	mov    (%edx),%eax
f0103179:	ba 00 00 00 00       	mov    $0x0,%edx
}
f010317e:	5d                   	pop    %ebp
f010317f:	c3                   	ret    

f0103180 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103180:	55                   	push   %ebp
f0103181:	89 e5                	mov    %esp,%ebp
f0103183:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103186:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
f0103189:	8b 10                	mov    (%eax),%edx
f010318b:	3b 50 04             	cmp    0x4(%eax),%edx
f010318e:	73 08                	jae    f0103198 <sprintputch+0x18>
		*b->buf++ = ch;
f0103190:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103193:	88 0a                	mov    %cl,(%edx)
f0103195:	42                   	inc    %edx
f0103196:	89 10                	mov    %edx,(%eax)
}
f0103198:	5d                   	pop    %ebp
f0103199:	c3                   	ret    

f010319a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010319a:	55                   	push   %ebp
f010319b:	89 e5                	mov    %esp,%ebp
f010319d:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
f01031a0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01031a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01031a7:	8b 45 10             	mov    0x10(%ebp),%eax
f01031aa:	89 44 24 08          	mov    %eax,0x8(%esp)
f01031ae:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031b1:	89 44 24 04          	mov    %eax,0x4(%esp)
f01031b5:	8b 45 08             	mov    0x8(%ebp),%eax
f01031b8:	89 04 24             	mov    %eax,(%esp)
f01031bb:	e8 02 00 00 00       	call   f01031c2 <vprintfmt>
	va_end(ap);
}
f01031c0:	c9                   	leave  
f01031c1:	c3                   	ret    

f01031c2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f01031c2:	55                   	push   %ebp
f01031c3:	89 e5                	mov    %esp,%ebp
f01031c5:	57                   	push   %edi
f01031c6:	56                   	push   %esi
f01031c7:	53                   	push   %ebx
f01031c8:	83 ec 4c             	sub    $0x4c,%esp
f01031cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01031ce:	8b 75 10             	mov    0x10(%ebp),%esi
f01031d1:	eb 12                	jmp    f01031e5 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f01031d3:	85 c0                	test   %eax,%eax
f01031d5:	0f 84 6b 03 00 00    	je     f0103546 <vprintfmt+0x384>
				return;
			putch(ch, putdat);
f01031db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01031df:	89 04 24             	mov    %eax,(%esp)
f01031e2:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01031e5:	0f b6 06             	movzbl (%esi),%eax
f01031e8:	46                   	inc    %esi
f01031e9:	83 f8 25             	cmp    $0x25,%eax
f01031ec:	75 e5                	jne    f01031d3 <vprintfmt+0x11>
f01031ee:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
f01031f2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
f01031f9:	bf ff ff ff ff       	mov    $0xffffffff,%edi
f01031fe:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0103205:	b9 00 00 00 00       	mov    $0x0,%ecx
f010320a:	eb 26                	jmp    f0103232 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010320c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
f010320f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
f0103213:	eb 1d                	jmp    f0103232 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103215:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103218:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
f010321c:	eb 14                	jmp    f0103232 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010321e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
f0103221:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0103228:	eb 08                	jmp    f0103232 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
f010322a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
f010322d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103232:	0f b6 06             	movzbl (%esi),%eax
f0103235:	8d 56 01             	lea    0x1(%esi),%edx
f0103238:	89 55 e0             	mov    %edx,-0x20(%ebp)
f010323b:	8a 16                	mov    (%esi),%dl
f010323d:	83 ea 23             	sub    $0x23,%edx
f0103240:	80 fa 55             	cmp    $0x55,%dl
f0103243:	0f 87 e1 02 00 00    	ja     f010352a <vprintfmt+0x368>
f0103249:	0f b6 d2             	movzbl %dl,%edx
f010324c:	ff 24 95 e8 4c 10 f0 	jmp    *-0xfefb318(,%edx,4)
f0103253:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103256:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f010325b:	8d 14 bf             	lea    (%edi,%edi,4),%edx
f010325e:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
f0103262:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
f0103265:	8d 50 d0             	lea    -0x30(%eax),%edx
f0103268:	83 fa 09             	cmp    $0x9,%edx
f010326b:	77 2a                	ja     f0103297 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010326d:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f010326e:	eb eb                	jmp    f010325b <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103270:	8b 45 14             	mov    0x14(%ebp),%eax
f0103273:	8d 50 04             	lea    0x4(%eax),%edx
f0103276:	89 55 14             	mov    %edx,0x14(%ebp)
f0103279:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010327b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f010327e:	eb 17                	jmp    f0103297 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
f0103280:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0103284:	78 98                	js     f010321e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103286:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103289:	eb a7                	jmp    f0103232 <vprintfmt+0x70>
f010328b:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f010328e:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
f0103295:	eb 9b                	jmp    f0103232 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
f0103297:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f010329b:	79 95                	jns    f0103232 <vprintfmt+0x70>
f010329d:	eb 8b                	jmp    f010322a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f010329f:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032a0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f01032a3:	eb 8d                	jmp    f0103232 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01032a5:	8b 45 14             	mov    0x14(%ebp),%eax
f01032a8:	8d 50 04             	lea    0x4(%eax),%edx
f01032ab:	89 55 14             	mov    %edx,0x14(%ebp)
f01032ae:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032b2:	8b 00                	mov    (%eax),%eax
f01032b4:	89 04 24             	mov    %eax,(%esp)
f01032b7:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01032ba:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f01032bd:	e9 23 ff ff ff       	jmp    f01031e5 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
f01032c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01032c5:	8d 50 04             	lea    0x4(%eax),%edx
f01032c8:	89 55 14             	mov    %edx,0x14(%ebp)
f01032cb:	8b 00                	mov    (%eax),%eax
f01032cd:	85 c0                	test   %eax,%eax
f01032cf:	79 02                	jns    f01032d3 <vprintfmt+0x111>
f01032d1:	f7 d8                	neg    %eax
f01032d3:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01032d5:	83 f8 06             	cmp    $0x6,%eax
f01032d8:	7f 0b                	jg     f01032e5 <vprintfmt+0x123>
f01032da:	8b 04 85 40 4e 10 f0 	mov    -0xfefb1c0(,%eax,4),%eax
f01032e1:	85 c0                	test   %eax,%eax
f01032e3:	75 23                	jne    f0103308 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
f01032e5:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01032e9:	c7 44 24 08 73 4c 10 	movl   $0xf0104c73,0x8(%esp)
f01032f0:	f0 
f01032f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01032f5:	8b 45 08             	mov    0x8(%ebp),%eax
f01032f8:	89 04 24             	mov    %eax,(%esp)
f01032fb:	e8 9a fe ff ff       	call   f010319a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103300:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103303:	e9 dd fe ff ff       	jmp    f01031e5 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
f0103308:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010330c:	c7 44 24 08 8b 49 10 	movl   $0xf010498b,0x8(%esp)
f0103313:	f0 
f0103314:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103318:	8b 55 08             	mov    0x8(%ebp),%edx
f010331b:	89 14 24             	mov    %edx,(%esp)
f010331e:	e8 77 fe ff ff       	call   f010319a <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103323:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103326:	e9 ba fe ff ff       	jmp    f01031e5 <vprintfmt+0x23>
f010332b:	89 f9                	mov    %edi,%ecx
f010332d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103330:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103333:	8b 45 14             	mov    0x14(%ebp),%eax
f0103336:	8d 50 04             	lea    0x4(%eax),%edx
f0103339:	89 55 14             	mov    %edx,0x14(%ebp)
f010333c:	8b 30                	mov    (%eax),%esi
f010333e:	85 f6                	test   %esi,%esi
f0103340:	75 05                	jne    f0103347 <vprintfmt+0x185>
				p = "(null)";
f0103342:	be 6c 4c 10 f0       	mov    $0xf0104c6c,%esi
			if (width > 0 && padc != '-')
f0103347:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010334b:	0f 8e 84 00 00 00    	jle    f01033d5 <vprintfmt+0x213>
f0103351:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
f0103355:	74 7e                	je     f01033d5 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103357:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f010335b:	89 34 24             	mov    %esi,(%esp)
f010335e:	e8 53 03 00 00       	call   f01036b6 <strnlen>
f0103363:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103366:	29 c2                	sub    %eax,%edx
f0103368:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
f010336b:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
f010336f:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0103372:	89 7d cc             	mov    %edi,-0x34(%ebp)
f0103375:	89 de                	mov    %ebx,%esi
f0103377:	89 d3                	mov    %edx,%ebx
f0103379:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f010337b:	eb 0b                	jmp    f0103388 <vprintfmt+0x1c6>
					putch(padc, putdat);
f010337d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103381:	89 3c 24             	mov    %edi,(%esp)
f0103384:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103387:	4b                   	dec    %ebx
f0103388:	85 db                	test   %ebx,%ebx
f010338a:	7f f1                	jg     f010337d <vprintfmt+0x1bb>
f010338c:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010338f:	89 f3                	mov    %esi,%ebx
f0103391:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
f0103394:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103397:	85 c0                	test   %eax,%eax
f0103399:	79 05                	jns    f01033a0 <vprintfmt+0x1de>
f010339b:	b8 00 00 00 00       	mov    $0x0,%eax
f01033a0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01033a3:	29 c2                	sub    %eax,%edx
f01033a5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01033a8:	eb 2b                	jmp    f01033d5 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f01033aa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01033ae:	74 18                	je     f01033c8 <vprintfmt+0x206>
f01033b0:	8d 50 e0             	lea    -0x20(%eax),%edx
f01033b3:	83 fa 5e             	cmp    $0x5e,%edx
f01033b6:	76 10                	jbe    f01033c8 <vprintfmt+0x206>
					putch('?', putdat);
f01033b8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033bc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f01033c3:	ff 55 08             	call   *0x8(%ebp)
f01033c6:	eb 0a                	jmp    f01033d2 <vprintfmt+0x210>
				else
					putch(ch, putdat);
f01033c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01033cc:	89 04 24             	mov    %eax,(%esp)
f01033cf:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01033d2:	ff 4d e4             	decl   -0x1c(%ebp)
f01033d5:	0f be 06             	movsbl (%esi),%eax
f01033d8:	46                   	inc    %esi
f01033d9:	85 c0                	test   %eax,%eax
f01033db:	74 21                	je     f01033fe <vprintfmt+0x23c>
f01033dd:	85 ff                	test   %edi,%edi
f01033df:	78 c9                	js     f01033aa <vprintfmt+0x1e8>
f01033e1:	4f                   	dec    %edi
f01033e2:	79 c6                	jns    f01033aa <vprintfmt+0x1e8>
f01033e4:	8b 7d 08             	mov    0x8(%ebp),%edi
f01033e7:	89 de                	mov    %ebx,%esi
f01033e9:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01033ec:	eb 18                	jmp    f0103406 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f01033ee:	89 74 24 04          	mov    %esi,0x4(%esp)
f01033f2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f01033f9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f01033fb:	4b                   	dec    %ebx
f01033fc:	eb 08                	jmp    f0103406 <vprintfmt+0x244>
f01033fe:	8b 7d 08             	mov    0x8(%ebp),%edi
f0103401:	89 de                	mov    %ebx,%esi
f0103403:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103406:	85 db                	test   %ebx,%ebx
f0103408:	7f e4                	jg     f01033ee <vprintfmt+0x22c>
f010340a:	89 7d 08             	mov    %edi,0x8(%ebp)
f010340d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010340f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103412:	e9 ce fd ff ff       	jmp    f01031e5 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103417:	83 f9 01             	cmp    $0x1,%ecx
f010341a:	7e 10                	jle    f010342c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
f010341c:	8b 45 14             	mov    0x14(%ebp),%eax
f010341f:	8d 50 08             	lea    0x8(%eax),%edx
f0103422:	89 55 14             	mov    %edx,0x14(%ebp)
f0103425:	8b 30                	mov    (%eax),%esi
f0103427:	8b 78 04             	mov    0x4(%eax),%edi
f010342a:	eb 26                	jmp    f0103452 <vprintfmt+0x290>
	else if (lflag)
f010342c:	85 c9                	test   %ecx,%ecx
f010342e:	74 12                	je     f0103442 <vprintfmt+0x280>
		return va_arg(*ap, long);
f0103430:	8b 45 14             	mov    0x14(%ebp),%eax
f0103433:	8d 50 04             	lea    0x4(%eax),%edx
f0103436:	89 55 14             	mov    %edx,0x14(%ebp)
f0103439:	8b 30                	mov    (%eax),%esi
f010343b:	89 f7                	mov    %esi,%edi
f010343d:	c1 ff 1f             	sar    $0x1f,%edi
f0103440:	eb 10                	jmp    f0103452 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
f0103442:	8b 45 14             	mov    0x14(%ebp),%eax
f0103445:	8d 50 04             	lea    0x4(%eax),%edx
f0103448:	89 55 14             	mov    %edx,0x14(%ebp)
f010344b:	8b 30                	mov    (%eax),%esi
f010344d:	89 f7                	mov    %esi,%edi
f010344f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103452:	85 ff                	test   %edi,%edi
f0103454:	78 0a                	js     f0103460 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103456:	b8 0a 00 00 00       	mov    $0xa,%eax
f010345b:	e9 8c 00 00 00       	jmp    f01034ec <vprintfmt+0x32a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
f0103460:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103464:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010346b:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
f010346e:	f7 de                	neg    %esi
f0103470:	83 d7 00             	adc    $0x0,%edi
f0103473:	f7 df                	neg    %edi
			}
			base = 10;
f0103475:	b8 0a 00 00 00       	mov    $0xa,%eax
f010347a:	eb 70                	jmp    f01034ec <vprintfmt+0x32a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f010347c:	89 ca                	mov    %ecx,%edx
f010347e:	8d 45 14             	lea    0x14(%ebp),%eax
f0103481:	e8 c0 fc ff ff       	call   f0103146 <getuint>
f0103486:	89 c6                	mov    %eax,%esi
f0103488:	89 d7                	mov    %edx,%edi
			base = 10;
f010348a:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
f010348f:	eb 5b                	jmp    f01034ec <vprintfmt+0x32a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0103491:	89 ca                	mov    %ecx,%edx
f0103493:	8d 45 14             	lea    0x14(%ebp),%eax
f0103496:	e8 ab fc ff ff       	call   f0103146 <getuint>
f010349b:	89 c6                	mov    %eax,%esi
f010349d:	89 d7                	mov    %edx,%edi
			base = 8;
f010349f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
f01034a4:	eb 46                	jmp    f01034ec <vprintfmt+0x32a>

		// pointer
		case 'p':
			putch('0', putdat);
f01034a6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034aa:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f01034b1:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
f01034b4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01034b8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f01034bf:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f01034c2:	8b 45 14             	mov    0x14(%ebp),%eax
f01034c5:	8d 50 04             	lea    0x4(%eax),%edx
f01034c8:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f01034cb:	8b 30                	mov    (%eax),%esi
f01034cd:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f01034d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f01034d7:	eb 13                	jmp    f01034ec <vprintfmt+0x32a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01034d9:	89 ca                	mov    %ecx,%edx
f01034db:	8d 45 14             	lea    0x14(%ebp),%eax
f01034de:	e8 63 fc ff ff       	call   f0103146 <getuint>
f01034e3:	89 c6                	mov    %eax,%esi
f01034e5:	89 d7                	mov    %edx,%edi
			base = 16;
f01034e7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f01034ec:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
f01034f0:	89 54 24 10          	mov    %edx,0x10(%esp)
f01034f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01034f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01034fb:	89 44 24 08          	mov    %eax,0x8(%esp)
f01034ff:	89 34 24             	mov    %esi,(%esp)
f0103502:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0103506:	89 da                	mov    %ebx,%edx
f0103508:	8b 45 08             	mov    0x8(%ebp),%eax
f010350b:	e8 6c fb ff ff       	call   f010307c <printnum>
			break;
f0103510:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103513:	e9 cd fc ff ff       	jmp    f01031e5 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103518:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010351c:	89 04 24             	mov    %eax,(%esp)
f010351f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103522:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103525:	e9 bb fc ff ff       	jmp    f01031e5 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f010352a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010352e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0103535:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103538:	eb 01                	jmp    f010353b <vprintfmt+0x379>
f010353a:	4e                   	dec    %esi
f010353b:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
f010353f:	75 f9                	jne    f010353a <vprintfmt+0x378>
f0103541:	e9 9f fc ff ff       	jmp    f01031e5 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
f0103546:	83 c4 4c             	add    $0x4c,%esp
f0103549:	5b                   	pop    %ebx
f010354a:	5e                   	pop    %esi
f010354b:	5f                   	pop    %edi
f010354c:	5d                   	pop    %ebp
f010354d:	c3                   	ret    

f010354e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010354e:	55                   	push   %ebp
f010354f:	89 e5                	mov    %esp,%ebp
f0103551:	83 ec 28             	sub    $0x28,%esp
f0103554:	8b 45 08             	mov    0x8(%ebp),%eax
f0103557:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010355a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010355d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103561:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103564:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010356b:	85 c0                	test   %eax,%eax
f010356d:	74 30                	je     f010359f <vsnprintf+0x51>
f010356f:	85 d2                	test   %edx,%edx
f0103571:	7e 33                	jle    f01035a6 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103573:	8b 45 14             	mov    0x14(%ebp),%eax
f0103576:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010357a:	8b 45 10             	mov    0x10(%ebp),%eax
f010357d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103581:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103584:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103588:	c7 04 24 80 31 10 f0 	movl   $0xf0103180,(%esp)
f010358f:	e8 2e fc ff ff       	call   f01031c2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103594:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103597:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010359a:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010359d:	eb 0c                	jmp    f01035ab <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010359f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01035a4:	eb 05                	jmp    f01035ab <vsnprintf+0x5d>
f01035a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01035ab:	c9                   	leave  
f01035ac:	c3                   	ret    

f01035ad <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01035ad:	55                   	push   %ebp
f01035ae:	89 e5                	mov    %esp,%ebp
f01035b0:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01035b3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01035b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01035ba:	8b 45 10             	mov    0x10(%ebp),%eax
f01035bd:	89 44 24 08          	mov    %eax,0x8(%esp)
f01035c1:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035c4:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035c8:	8b 45 08             	mov    0x8(%ebp),%eax
f01035cb:	89 04 24             	mov    %eax,(%esp)
f01035ce:	e8 7b ff ff ff       	call   f010354e <vsnprintf>
	va_end(ap);

	return rc;
}
f01035d3:	c9                   	leave  
f01035d4:	c3                   	ret    
f01035d5:	00 00                	add    %al,(%eax)
	...

f01035d8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01035d8:	55                   	push   %ebp
f01035d9:	89 e5                	mov    %esp,%ebp
f01035db:	57                   	push   %edi
f01035dc:	56                   	push   %esi
f01035dd:	53                   	push   %ebx
f01035de:	83 ec 1c             	sub    $0x1c,%esp
f01035e1:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01035e4:	85 c0                	test   %eax,%eax
f01035e6:	74 10                	je     f01035f8 <readline+0x20>
		cprintf("%s", prompt);
f01035e8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01035ec:	c7 04 24 8b 49 10 f0 	movl   $0xf010498b,(%esp)
f01035f3:	e8 66 f7 ff ff       	call   f0102d5e <cprintf>

	i = 0;
	echoing = iscons(0);
f01035f8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01035ff:	e8 d5 cf ff ff       	call   f01005d9 <iscons>
f0103604:	89 c7                	mov    %eax,%edi
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103606:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010360b:	e8 b8 cf ff ff       	call   f01005c8 <getchar>
f0103610:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103612:	85 c0                	test   %eax,%eax
f0103614:	79 17                	jns    f010362d <readline+0x55>
			cprintf("read error: %e\n", c);
f0103616:	89 44 24 04          	mov    %eax,0x4(%esp)
f010361a:	c7 04 24 5c 4e 10 f0 	movl   $0xf0104e5c,(%esp)
f0103621:	e8 38 f7 ff ff       	call   f0102d5e <cprintf>
			return NULL;
f0103626:	b8 00 00 00 00       	mov    $0x0,%eax
f010362b:	eb 69                	jmp    f0103696 <readline+0xbe>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010362d:	83 f8 08             	cmp    $0x8,%eax
f0103630:	74 05                	je     f0103637 <readline+0x5f>
f0103632:	83 f8 7f             	cmp    $0x7f,%eax
f0103635:	75 17                	jne    f010364e <readline+0x76>
f0103637:	85 f6                	test   %esi,%esi
f0103639:	7e 13                	jle    f010364e <readline+0x76>
			if (echoing)
f010363b:	85 ff                	test   %edi,%edi
f010363d:	74 0c                	je     f010364b <readline+0x73>
				cputchar('\b');
f010363f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0103646:	e8 6d cf ff ff       	call   f01005b8 <cputchar>
			i--;
f010364b:	4e                   	dec    %esi
f010364c:	eb bd                	jmp    f010360b <readline+0x33>
		} else if (c >= ' ' && i < BUFLEN-1) {
f010364e:	83 fb 1f             	cmp    $0x1f,%ebx
f0103651:	7e 1d                	jle    f0103670 <readline+0x98>
f0103653:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103659:	7f 15                	jg     f0103670 <readline+0x98>
			if (echoing)
f010365b:	85 ff                	test   %edi,%edi
f010365d:	74 08                	je     f0103667 <readline+0x8f>
				cputchar(c);
f010365f:	89 1c 24             	mov    %ebx,(%esp)
f0103662:	e8 51 cf ff ff       	call   f01005b8 <cputchar>
			buf[i++] = c;
f0103667:	88 9e 60 f5 11 f0    	mov    %bl,-0xfee0aa0(%esi)
f010366d:	46                   	inc    %esi
f010366e:	eb 9b                	jmp    f010360b <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0103670:	83 fb 0a             	cmp    $0xa,%ebx
f0103673:	74 05                	je     f010367a <readline+0xa2>
f0103675:	83 fb 0d             	cmp    $0xd,%ebx
f0103678:	75 91                	jne    f010360b <readline+0x33>
			if (echoing)
f010367a:	85 ff                	test   %edi,%edi
f010367c:	74 0c                	je     f010368a <readline+0xb2>
				cputchar('\n');
f010367e:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f0103685:	e8 2e cf ff ff       	call   f01005b8 <cputchar>
			buf[i] = 0;
f010368a:	c6 86 60 f5 11 f0 00 	movb   $0x0,-0xfee0aa0(%esi)
			return buf;
f0103691:	b8 60 f5 11 f0       	mov    $0xf011f560,%eax
		}
	}
}
f0103696:	83 c4 1c             	add    $0x1c,%esp
f0103699:	5b                   	pop    %ebx
f010369a:	5e                   	pop    %esi
f010369b:	5f                   	pop    %edi
f010369c:	5d                   	pop    %ebp
f010369d:	c3                   	ret    
	...

f01036a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01036a0:	55                   	push   %ebp
f01036a1:	89 e5                	mov    %esp,%ebp
f01036a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01036a6:	b8 00 00 00 00       	mov    $0x0,%eax
f01036ab:	eb 01                	jmp    f01036ae <strlen+0xe>
		n++;
f01036ad:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01036ae:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01036b2:	75 f9                	jne    f01036ad <strlen+0xd>
		n++;
	return n;
}
f01036b4:	5d                   	pop    %ebp
f01036b5:	c3                   	ret    

f01036b6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01036b6:	55                   	push   %ebp
f01036b7:	89 e5                	mov    %esp,%ebp
f01036b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
f01036bc:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01036c4:	eb 01                	jmp    f01036c7 <strnlen+0x11>
		n++;
f01036c6:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01036c7:	39 d0                	cmp    %edx,%eax
f01036c9:	74 06                	je     f01036d1 <strnlen+0x1b>
f01036cb:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01036cf:	75 f5                	jne    f01036c6 <strnlen+0x10>
		n++;
	return n;
}
f01036d1:	5d                   	pop    %ebp
f01036d2:	c3                   	ret    

f01036d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01036d3:	55                   	push   %ebp
f01036d4:	89 e5                	mov    %esp,%ebp
f01036d6:	53                   	push   %ebx
f01036d7:	8b 45 08             	mov    0x8(%ebp),%eax
f01036da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01036dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01036e2:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
f01036e5:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f01036e8:	42                   	inc    %edx
f01036e9:	84 c9                	test   %cl,%cl
f01036eb:	75 f5                	jne    f01036e2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f01036ed:	5b                   	pop    %ebx
f01036ee:	5d                   	pop    %ebp
f01036ef:	c3                   	ret    

f01036f0 <strcat>:

char *
strcat(char *dst, const char *src)
{
f01036f0:	55                   	push   %ebp
f01036f1:	89 e5                	mov    %esp,%ebp
f01036f3:	53                   	push   %ebx
f01036f4:	83 ec 08             	sub    $0x8,%esp
f01036f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f01036fa:	89 1c 24             	mov    %ebx,(%esp)
f01036fd:	e8 9e ff ff ff       	call   f01036a0 <strlen>
	strcpy(dst + len, src);
f0103702:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103705:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103709:	01 d8                	add    %ebx,%eax
f010370b:	89 04 24             	mov    %eax,(%esp)
f010370e:	e8 c0 ff ff ff       	call   f01036d3 <strcpy>
	return dst;
}
f0103713:	89 d8                	mov    %ebx,%eax
f0103715:	83 c4 08             	add    $0x8,%esp
f0103718:	5b                   	pop    %ebx
f0103719:	5d                   	pop    %ebp
f010371a:	c3                   	ret    

f010371b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010371b:	55                   	push   %ebp
f010371c:	89 e5                	mov    %esp,%ebp
f010371e:	56                   	push   %esi
f010371f:	53                   	push   %ebx
f0103720:	8b 45 08             	mov    0x8(%ebp),%eax
f0103723:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103726:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103729:	b9 00 00 00 00       	mov    $0x0,%ecx
f010372e:	eb 0c                	jmp    f010373c <strncpy+0x21>
		*dst++ = *src;
f0103730:	8a 1a                	mov    (%edx),%bl
f0103732:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0103735:	80 3a 01             	cmpb   $0x1,(%edx)
f0103738:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010373b:	41                   	inc    %ecx
f010373c:	39 f1                	cmp    %esi,%ecx
f010373e:	75 f0                	jne    f0103730 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103740:	5b                   	pop    %ebx
f0103741:	5e                   	pop    %esi
f0103742:	5d                   	pop    %ebp
f0103743:	c3                   	ret    

f0103744 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103744:	55                   	push   %ebp
f0103745:	89 e5                	mov    %esp,%ebp
f0103747:	56                   	push   %esi
f0103748:	53                   	push   %ebx
f0103749:	8b 75 08             	mov    0x8(%ebp),%esi
f010374c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010374f:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103752:	85 d2                	test   %edx,%edx
f0103754:	75 0a                	jne    f0103760 <strlcpy+0x1c>
f0103756:	89 f0                	mov    %esi,%eax
f0103758:	eb 1a                	jmp    f0103774 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010375a:	88 18                	mov    %bl,(%eax)
f010375c:	40                   	inc    %eax
f010375d:	41                   	inc    %ecx
f010375e:	eb 02                	jmp    f0103762 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103760:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
f0103762:	4a                   	dec    %edx
f0103763:	74 0a                	je     f010376f <strlcpy+0x2b>
f0103765:	8a 19                	mov    (%ecx),%bl
f0103767:	84 db                	test   %bl,%bl
f0103769:	75 ef                	jne    f010375a <strlcpy+0x16>
f010376b:	89 c2                	mov    %eax,%edx
f010376d:	eb 02                	jmp    f0103771 <strlcpy+0x2d>
f010376f:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
f0103771:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
f0103774:	29 f0                	sub    %esi,%eax
}
f0103776:	5b                   	pop    %ebx
f0103777:	5e                   	pop    %esi
f0103778:	5d                   	pop    %ebp
f0103779:	c3                   	ret    

f010377a <strcmp>:

int
strcmp(const char *p, const char *q)
{
f010377a:	55                   	push   %ebp
f010377b:	89 e5                	mov    %esp,%ebp
f010377d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103780:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0103783:	eb 02                	jmp    f0103787 <strcmp+0xd>
		p++, q++;
f0103785:	41                   	inc    %ecx
f0103786:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103787:	8a 01                	mov    (%ecx),%al
f0103789:	84 c0                	test   %al,%al
f010378b:	74 04                	je     f0103791 <strcmp+0x17>
f010378d:	3a 02                	cmp    (%edx),%al
f010378f:	74 f4                	je     f0103785 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103791:	0f b6 c0             	movzbl %al,%eax
f0103794:	0f b6 12             	movzbl (%edx),%edx
f0103797:	29 d0                	sub    %edx,%eax
}
f0103799:	5d                   	pop    %ebp
f010379a:	c3                   	ret    

f010379b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010379b:	55                   	push   %ebp
f010379c:	89 e5                	mov    %esp,%ebp
f010379e:	53                   	push   %ebx
f010379f:	8b 45 08             	mov    0x8(%ebp),%eax
f01037a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01037a5:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
f01037a8:	eb 03                	jmp    f01037ad <strncmp+0x12>
		n--, p++, q++;
f01037aa:	4a                   	dec    %edx
f01037ab:	40                   	inc    %eax
f01037ac:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01037ad:	85 d2                	test   %edx,%edx
f01037af:	74 14                	je     f01037c5 <strncmp+0x2a>
f01037b1:	8a 18                	mov    (%eax),%bl
f01037b3:	84 db                	test   %bl,%bl
f01037b5:	74 04                	je     f01037bb <strncmp+0x20>
f01037b7:	3a 19                	cmp    (%ecx),%bl
f01037b9:	74 ef                	je     f01037aa <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f01037bb:	0f b6 00             	movzbl (%eax),%eax
f01037be:	0f b6 11             	movzbl (%ecx),%edx
f01037c1:	29 d0                	sub    %edx,%eax
f01037c3:	eb 05                	jmp    f01037ca <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f01037c5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01037ca:	5b                   	pop    %ebx
f01037cb:	5d                   	pop    %ebp
f01037cc:	c3                   	ret    

f01037cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f01037cd:	55                   	push   %ebp
f01037ce:	89 e5                	mov    %esp,%ebp
f01037d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01037d3:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01037d6:	eb 05                	jmp    f01037dd <strchr+0x10>
		if (*s == c)
f01037d8:	38 ca                	cmp    %cl,%dl
f01037da:	74 0c                	je     f01037e8 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f01037dc:	40                   	inc    %eax
f01037dd:	8a 10                	mov    (%eax),%dl
f01037df:	84 d2                	test   %dl,%dl
f01037e1:	75 f5                	jne    f01037d8 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
f01037e3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01037e8:	5d                   	pop    %ebp
f01037e9:	c3                   	ret    

f01037ea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f01037ea:	55                   	push   %ebp
f01037eb:	89 e5                	mov    %esp,%ebp
f01037ed:	8b 45 08             	mov    0x8(%ebp),%eax
f01037f0:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
f01037f3:	eb 05                	jmp    f01037fa <strfind+0x10>
		if (*s == c)
f01037f5:	38 ca                	cmp    %cl,%dl
f01037f7:	74 07                	je     f0103800 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f01037f9:	40                   	inc    %eax
f01037fa:	8a 10                	mov    (%eax),%dl
f01037fc:	84 d2                	test   %dl,%dl
f01037fe:	75 f5                	jne    f01037f5 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
f0103800:	5d                   	pop    %ebp
f0103801:	c3                   	ret    

f0103802 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103802:	55                   	push   %ebp
f0103803:	89 e5                	mov    %esp,%ebp
f0103805:	57                   	push   %edi
f0103806:	56                   	push   %esi
f0103807:	53                   	push   %ebx
f0103808:	8b 7d 08             	mov    0x8(%ebp),%edi
f010380b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010380e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103811:	85 c9                	test   %ecx,%ecx
f0103813:	74 30                	je     f0103845 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103815:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010381b:	75 25                	jne    f0103842 <memset+0x40>
f010381d:	f6 c1 03             	test   $0x3,%cl
f0103820:	75 20                	jne    f0103842 <memset+0x40>
		c &= 0xFF;
f0103822:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103825:	89 d3                	mov    %edx,%ebx
f0103827:	c1 e3 08             	shl    $0x8,%ebx
f010382a:	89 d6                	mov    %edx,%esi
f010382c:	c1 e6 18             	shl    $0x18,%esi
f010382f:	89 d0                	mov    %edx,%eax
f0103831:	c1 e0 10             	shl    $0x10,%eax
f0103834:	09 f0                	or     %esi,%eax
f0103836:	09 d0                	or     %edx,%eax
f0103838:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f010383a:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f010383d:	fc                   	cld    
f010383e:	f3 ab                	rep stos %eax,%es:(%edi)
f0103840:	eb 03                	jmp    f0103845 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103842:	fc                   	cld    
f0103843:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0103845:	89 f8                	mov    %edi,%eax
f0103847:	5b                   	pop    %ebx
f0103848:	5e                   	pop    %esi
f0103849:	5f                   	pop    %edi
f010384a:	5d                   	pop    %ebp
f010384b:	c3                   	ret    

f010384c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f010384c:	55                   	push   %ebp
f010384d:	89 e5                	mov    %esp,%ebp
f010384f:	57                   	push   %edi
f0103850:	56                   	push   %esi
f0103851:	8b 45 08             	mov    0x8(%ebp),%eax
f0103854:	8b 75 0c             	mov    0xc(%ebp),%esi
f0103857:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f010385a:	39 c6                	cmp    %eax,%esi
f010385c:	73 34                	jae    f0103892 <memmove+0x46>
f010385e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0103861:	39 d0                	cmp    %edx,%eax
f0103863:	73 2d                	jae    f0103892 <memmove+0x46>
		s += n;
		d += n;
f0103865:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103868:	f6 c2 03             	test   $0x3,%dl
f010386b:	75 1b                	jne    f0103888 <memmove+0x3c>
f010386d:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0103873:	75 13                	jne    f0103888 <memmove+0x3c>
f0103875:	f6 c1 03             	test   $0x3,%cl
f0103878:	75 0e                	jne    f0103888 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f010387a:	83 ef 04             	sub    $0x4,%edi
f010387d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0103880:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0103883:	fd                   	std    
f0103884:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0103886:	eb 07                	jmp    f010388f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0103888:	4f                   	dec    %edi
f0103889:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010388c:	fd                   	std    
f010388d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010388f:	fc                   	cld    
f0103890:	eb 20                	jmp    f01038b2 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0103892:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0103898:	75 13                	jne    f01038ad <memmove+0x61>
f010389a:	a8 03                	test   $0x3,%al
f010389c:	75 0f                	jne    f01038ad <memmove+0x61>
f010389e:	f6 c1 03             	test   $0x3,%cl
f01038a1:	75 0a                	jne    f01038ad <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f01038a3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f01038a6:	89 c7                	mov    %eax,%edi
f01038a8:	fc                   	cld    
f01038a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01038ab:	eb 05                	jmp    f01038b2 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f01038ad:	89 c7                	mov    %eax,%edi
f01038af:	fc                   	cld    
f01038b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f01038b2:	5e                   	pop    %esi
f01038b3:	5f                   	pop    %edi
f01038b4:	5d                   	pop    %ebp
f01038b5:	c3                   	ret    

f01038b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f01038b6:	55                   	push   %ebp
f01038b7:	89 e5                	mov    %esp,%ebp
f01038b9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f01038bc:	8b 45 10             	mov    0x10(%ebp),%eax
f01038bf:	89 44 24 08          	mov    %eax,0x8(%esp)
f01038c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01038c6:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038ca:	8b 45 08             	mov    0x8(%ebp),%eax
f01038cd:	89 04 24             	mov    %eax,(%esp)
f01038d0:	e8 77 ff ff ff       	call   f010384c <memmove>
}
f01038d5:	c9                   	leave  
f01038d6:	c3                   	ret    

f01038d7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f01038d7:	55                   	push   %ebp
f01038d8:	89 e5                	mov    %esp,%ebp
f01038da:	57                   	push   %edi
f01038db:	56                   	push   %esi
f01038dc:	53                   	push   %ebx
f01038dd:	8b 7d 08             	mov    0x8(%ebp),%edi
f01038e0:	8b 75 0c             	mov    0xc(%ebp),%esi
f01038e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01038e6:	ba 00 00 00 00       	mov    $0x0,%edx
f01038eb:	eb 16                	jmp    f0103903 <memcmp+0x2c>
		if (*s1 != *s2)
f01038ed:	8a 04 17             	mov    (%edi,%edx,1),%al
f01038f0:	42                   	inc    %edx
f01038f1:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
f01038f5:	38 c8                	cmp    %cl,%al
f01038f7:	74 0a                	je     f0103903 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
f01038f9:	0f b6 c0             	movzbl %al,%eax
f01038fc:	0f b6 c9             	movzbl %cl,%ecx
f01038ff:	29 c8                	sub    %ecx,%eax
f0103901:	eb 09                	jmp    f010390c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103903:	39 da                	cmp    %ebx,%edx
f0103905:	75 e6                	jne    f01038ed <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103907:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010390c:	5b                   	pop    %ebx
f010390d:	5e                   	pop    %esi
f010390e:	5f                   	pop    %edi
f010390f:	5d                   	pop    %ebp
f0103910:	c3                   	ret    

f0103911 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103911:	55                   	push   %ebp
f0103912:	89 e5                	mov    %esp,%ebp
f0103914:	8b 45 08             	mov    0x8(%ebp),%eax
f0103917:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010391a:	89 c2                	mov    %eax,%edx
f010391c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010391f:	eb 05                	jmp    f0103926 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103921:	38 08                	cmp    %cl,(%eax)
f0103923:	74 05                	je     f010392a <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103925:	40                   	inc    %eax
f0103926:	39 d0                	cmp    %edx,%eax
f0103928:	72 f7                	jb     f0103921 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010392a:	5d                   	pop    %ebp
f010392b:	c3                   	ret    

f010392c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010392c:	55                   	push   %ebp
f010392d:	89 e5                	mov    %esp,%ebp
f010392f:	57                   	push   %edi
f0103930:	56                   	push   %esi
f0103931:	53                   	push   %ebx
f0103932:	8b 55 08             	mov    0x8(%ebp),%edx
f0103935:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103938:	eb 01                	jmp    f010393b <strtol+0xf>
		s++;
f010393a:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010393b:	8a 02                	mov    (%edx),%al
f010393d:	3c 20                	cmp    $0x20,%al
f010393f:	74 f9                	je     f010393a <strtol+0xe>
f0103941:	3c 09                	cmp    $0x9,%al
f0103943:	74 f5                	je     f010393a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103945:	3c 2b                	cmp    $0x2b,%al
f0103947:	75 08                	jne    f0103951 <strtol+0x25>
		s++;
f0103949:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010394a:	bf 00 00 00 00       	mov    $0x0,%edi
f010394f:	eb 13                	jmp    f0103964 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f0103951:	3c 2d                	cmp    $0x2d,%al
f0103953:	75 0a                	jne    f010395f <strtol+0x33>
		s++, neg = 1;
f0103955:	8d 52 01             	lea    0x1(%edx),%edx
f0103958:	bf 01 00 00 00       	mov    $0x1,%edi
f010395d:	eb 05                	jmp    f0103964 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010395f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0103964:	85 db                	test   %ebx,%ebx
f0103966:	74 05                	je     f010396d <strtol+0x41>
f0103968:	83 fb 10             	cmp    $0x10,%ebx
f010396b:	75 28                	jne    f0103995 <strtol+0x69>
f010396d:	8a 02                	mov    (%edx),%al
f010396f:	3c 30                	cmp    $0x30,%al
f0103971:	75 10                	jne    f0103983 <strtol+0x57>
f0103973:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f0103977:	75 0a                	jne    f0103983 <strtol+0x57>
		s += 2, base = 16;
f0103979:	83 c2 02             	add    $0x2,%edx
f010397c:	bb 10 00 00 00       	mov    $0x10,%ebx
f0103981:	eb 12                	jmp    f0103995 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
f0103983:	85 db                	test   %ebx,%ebx
f0103985:	75 0e                	jne    f0103995 <strtol+0x69>
f0103987:	3c 30                	cmp    $0x30,%al
f0103989:	75 05                	jne    f0103990 <strtol+0x64>
		s++, base = 8;
f010398b:	42                   	inc    %edx
f010398c:	b3 08                	mov    $0x8,%bl
f010398e:	eb 05                	jmp    f0103995 <strtol+0x69>
	else if (base == 0)
		base = 10;
f0103990:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0103995:	b8 00 00 00 00       	mov    $0x0,%eax
f010399a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010399c:	8a 0a                	mov    (%edx),%cl
f010399e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f01039a1:	80 fb 09             	cmp    $0x9,%bl
f01039a4:	77 08                	ja     f01039ae <strtol+0x82>
			dig = *s - '0';
f01039a6:	0f be c9             	movsbl %cl,%ecx
f01039a9:	83 e9 30             	sub    $0x30,%ecx
f01039ac:	eb 1e                	jmp    f01039cc <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
f01039ae:	8d 59 9f             	lea    -0x61(%ecx),%ebx
f01039b1:	80 fb 19             	cmp    $0x19,%bl
f01039b4:	77 08                	ja     f01039be <strtol+0x92>
			dig = *s - 'a' + 10;
f01039b6:	0f be c9             	movsbl %cl,%ecx
f01039b9:	83 e9 57             	sub    $0x57,%ecx
f01039bc:	eb 0e                	jmp    f01039cc <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
f01039be:	8d 59 bf             	lea    -0x41(%ecx),%ebx
f01039c1:	80 fb 19             	cmp    $0x19,%bl
f01039c4:	77 12                	ja     f01039d8 <strtol+0xac>
			dig = *s - 'A' + 10;
f01039c6:	0f be c9             	movsbl %cl,%ecx
f01039c9:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01039cc:	39 f1                	cmp    %esi,%ecx
f01039ce:	7d 0c                	jge    f01039dc <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
f01039d0:	42                   	inc    %edx
f01039d1:	0f af c6             	imul   %esi,%eax
f01039d4:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
f01039d6:	eb c4                	jmp    f010399c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f01039d8:	89 c1                	mov    %eax,%ecx
f01039da:	eb 02                	jmp    f01039de <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f01039dc:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
f01039de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01039e2:	74 05                	je     f01039e9 <strtol+0xbd>
		*endptr = (char *) s;
f01039e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01039e7:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01039e9:	85 ff                	test   %edi,%edi
f01039eb:	74 04                	je     f01039f1 <strtol+0xc5>
f01039ed:	89 c8                	mov    %ecx,%eax
f01039ef:	f7 d8                	neg    %eax
}
f01039f1:	5b                   	pop    %ebx
f01039f2:	5e                   	pop    %esi
f01039f3:	5f                   	pop    %edi
f01039f4:	5d                   	pop    %ebp
f01039f5:	c3                   	ret    
	...

f01039f8 <__udivdi3>:
f01039f8:	55                   	push   %ebp
f01039f9:	57                   	push   %edi
f01039fa:	56                   	push   %esi
f01039fb:	83 ec 10             	sub    $0x10,%esp
f01039fe:	8b 74 24 20          	mov    0x20(%esp),%esi
f0103a02:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0103a06:	89 74 24 04          	mov    %esi,0x4(%esp)
f0103a0a:	8b 7c 24 24          	mov    0x24(%esp),%edi
f0103a0e:	89 cd                	mov    %ecx,%ebp
f0103a10:	8b 44 24 2c          	mov    0x2c(%esp),%eax
f0103a14:	85 c0                	test   %eax,%eax
f0103a16:	75 2c                	jne    f0103a44 <__udivdi3+0x4c>
f0103a18:	39 f9                	cmp    %edi,%ecx
f0103a1a:	77 68                	ja     f0103a84 <__udivdi3+0x8c>
f0103a1c:	85 c9                	test   %ecx,%ecx
f0103a1e:	75 0b                	jne    f0103a2b <__udivdi3+0x33>
f0103a20:	b8 01 00 00 00       	mov    $0x1,%eax
f0103a25:	31 d2                	xor    %edx,%edx
f0103a27:	f7 f1                	div    %ecx
f0103a29:	89 c1                	mov    %eax,%ecx
f0103a2b:	31 d2                	xor    %edx,%edx
f0103a2d:	89 f8                	mov    %edi,%eax
f0103a2f:	f7 f1                	div    %ecx
f0103a31:	89 c7                	mov    %eax,%edi
f0103a33:	89 f0                	mov    %esi,%eax
f0103a35:	f7 f1                	div    %ecx
f0103a37:	89 c6                	mov    %eax,%esi
f0103a39:	89 f0                	mov    %esi,%eax
f0103a3b:	89 fa                	mov    %edi,%edx
f0103a3d:	83 c4 10             	add    $0x10,%esp
f0103a40:	5e                   	pop    %esi
f0103a41:	5f                   	pop    %edi
f0103a42:	5d                   	pop    %ebp
f0103a43:	c3                   	ret    
f0103a44:	39 f8                	cmp    %edi,%eax
f0103a46:	77 2c                	ja     f0103a74 <__udivdi3+0x7c>
f0103a48:	0f bd f0             	bsr    %eax,%esi
f0103a4b:	83 f6 1f             	xor    $0x1f,%esi
f0103a4e:	75 4c                	jne    f0103a9c <__udivdi3+0xa4>
f0103a50:	39 f8                	cmp    %edi,%eax
f0103a52:	bf 00 00 00 00       	mov    $0x0,%edi
f0103a57:	72 0a                	jb     f0103a63 <__udivdi3+0x6b>
f0103a59:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0103a5d:	0f 87 ad 00 00 00    	ja     f0103b10 <__udivdi3+0x118>
f0103a63:	be 01 00 00 00       	mov    $0x1,%esi
f0103a68:	89 f0                	mov    %esi,%eax
f0103a6a:	89 fa                	mov    %edi,%edx
f0103a6c:	83 c4 10             	add    $0x10,%esp
f0103a6f:	5e                   	pop    %esi
f0103a70:	5f                   	pop    %edi
f0103a71:	5d                   	pop    %ebp
f0103a72:	c3                   	ret    
f0103a73:	90                   	nop
f0103a74:	31 ff                	xor    %edi,%edi
f0103a76:	31 f6                	xor    %esi,%esi
f0103a78:	89 f0                	mov    %esi,%eax
f0103a7a:	89 fa                	mov    %edi,%edx
f0103a7c:	83 c4 10             	add    $0x10,%esp
f0103a7f:	5e                   	pop    %esi
f0103a80:	5f                   	pop    %edi
f0103a81:	5d                   	pop    %ebp
f0103a82:	c3                   	ret    
f0103a83:	90                   	nop
f0103a84:	89 fa                	mov    %edi,%edx
f0103a86:	89 f0                	mov    %esi,%eax
f0103a88:	f7 f1                	div    %ecx
f0103a8a:	89 c6                	mov    %eax,%esi
f0103a8c:	31 ff                	xor    %edi,%edi
f0103a8e:	89 f0                	mov    %esi,%eax
f0103a90:	89 fa                	mov    %edi,%edx
f0103a92:	83 c4 10             	add    $0x10,%esp
f0103a95:	5e                   	pop    %esi
f0103a96:	5f                   	pop    %edi
f0103a97:	5d                   	pop    %ebp
f0103a98:	c3                   	ret    
f0103a99:	8d 76 00             	lea    0x0(%esi),%esi
f0103a9c:	89 f1                	mov    %esi,%ecx
f0103a9e:	d3 e0                	shl    %cl,%eax
f0103aa0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103aa4:	b8 20 00 00 00       	mov    $0x20,%eax
f0103aa9:	29 f0                	sub    %esi,%eax
f0103aab:	89 ea                	mov    %ebp,%edx
f0103aad:	88 c1                	mov    %al,%cl
f0103aaf:	d3 ea                	shr    %cl,%edx
f0103ab1:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
f0103ab5:	09 ca                	or     %ecx,%edx
f0103ab7:	89 54 24 08          	mov    %edx,0x8(%esp)
f0103abb:	89 f1                	mov    %esi,%ecx
f0103abd:	d3 e5                	shl    %cl,%ebp
f0103abf:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
f0103ac3:	89 fd                	mov    %edi,%ebp
f0103ac5:	88 c1                	mov    %al,%cl
f0103ac7:	d3 ed                	shr    %cl,%ebp
f0103ac9:	89 fa                	mov    %edi,%edx
f0103acb:	89 f1                	mov    %esi,%ecx
f0103acd:	d3 e2                	shl    %cl,%edx
f0103acf:	8b 7c 24 04          	mov    0x4(%esp),%edi
f0103ad3:	88 c1                	mov    %al,%cl
f0103ad5:	d3 ef                	shr    %cl,%edi
f0103ad7:	09 d7                	or     %edx,%edi
f0103ad9:	89 f8                	mov    %edi,%eax
f0103adb:	89 ea                	mov    %ebp,%edx
f0103add:	f7 74 24 08          	divl   0x8(%esp)
f0103ae1:	89 d1                	mov    %edx,%ecx
f0103ae3:	89 c7                	mov    %eax,%edi
f0103ae5:	f7 64 24 0c          	mull   0xc(%esp)
f0103ae9:	39 d1                	cmp    %edx,%ecx
f0103aeb:	72 17                	jb     f0103b04 <__udivdi3+0x10c>
f0103aed:	74 09                	je     f0103af8 <__udivdi3+0x100>
f0103aef:	89 fe                	mov    %edi,%esi
f0103af1:	31 ff                	xor    %edi,%edi
f0103af3:	e9 41 ff ff ff       	jmp    f0103a39 <__udivdi3+0x41>
f0103af8:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103afc:	89 f1                	mov    %esi,%ecx
f0103afe:	d3 e2                	shl    %cl,%edx
f0103b00:	39 c2                	cmp    %eax,%edx
f0103b02:	73 eb                	jae    f0103aef <__udivdi3+0xf7>
f0103b04:	8d 77 ff             	lea    -0x1(%edi),%esi
f0103b07:	31 ff                	xor    %edi,%edi
f0103b09:	e9 2b ff ff ff       	jmp    f0103a39 <__udivdi3+0x41>
f0103b0e:	66 90                	xchg   %ax,%ax
f0103b10:	31 f6                	xor    %esi,%esi
f0103b12:	e9 22 ff ff ff       	jmp    f0103a39 <__udivdi3+0x41>
	...

f0103b18 <__umoddi3>:
f0103b18:	55                   	push   %ebp
f0103b19:	57                   	push   %edi
f0103b1a:	56                   	push   %esi
f0103b1b:	83 ec 20             	sub    $0x20,%esp
f0103b1e:	8b 44 24 30          	mov    0x30(%esp),%eax
f0103b22:	8b 4c 24 38          	mov    0x38(%esp),%ecx
f0103b26:	89 44 24 14          	mov    %eax,0x14(%esp)
f0103b2a:	8b 74 24 34          	mov    0x34(%esp),%esi
f0103b2e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0103b32:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
f0103b36:	89 c7                	mov    %eax,%edi
f0103b38:	89 f2                	mov    %esi,%edx
f0103b3a:	85 ed                	test   %ebp,%ebp
f0103b3c:	75 16                	jne    f0103b54 <__umoddi3+0x3c>
f0103b3e:	39 f1                	cmp    %esi,%ecx
f0103b40:	0f 86 a6 00 00 00    	jbe    f0103bec <__umoddi3+0xd4>
f0103b46:	f7 f1                	div    %ecx
f0103b48:	89 d0                	mov    %edx,%eax
f0103b4a:	31 d2                	xor    %edx,%edx
f0103b4c:	83 c4 20             	add    $0x20,%esp
f0103b4f:	5e                   	pop    %esi
f0103b50:	5f                   	pop    %edi
f0103b51:	5d                   	pop    %ebp
f0103b52:	c3                   	ret    
f0103b53:	90                   	nop
f0103b54:	39 f5                	cmp    %esi,%ebp
f0103b56:	0f 87 ac 00 00 00    	ja     f0103c08 <__umoddi3+0xf0>
f0103b5c:	0f bd c5             	bsr    %ebp,%eax
f0103b5f:	83 f0 1f             	xor    $0x1f,%eax
f0103b62:	89 44 24 10          	mov    %eax,0x10(%esp)
f0103b66:	0f 84 a8 00 00 00    	je     f0103c14 <__umoddi3+0xfc>
f0103b6c:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103b70:	d3 e5                	shl    %cl,%ebp
f0103b72:	bf 20 00 00 00       	mov    $0x20,%edi
f0103b77:	2b 7c 24 10          	sub    0x10(%esp),%edi
f0103b7b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103b7f:	89 f9                	mov    %edi,%ecx
f0103b81:	d3 e8                	shr    %cl,%eax
f0103b83:	09 e8                	or     %ebp,%eax
f0103b85:	89 44 24 18          	mov    %eax,0x18(%esp)
f0103b89:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0103b8d:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103b91:	d3 e0                	shl    %cl,%eax
f0103b93:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103b97:	89 f2                	mov    %esi,%edx
f0103b99:	d3 e2                	shl    %cl,%edx
f0103b9b:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103b9f:	d3 e0                	shl    %cl,%eax
f0103ba1:	89 44 24 1c          	mov    %eax,0x1c(%esp)
f0103ba5:	8b 44 24 14          	mov    0x14(%esp),%eax
f0103ba9:	89 f9                	mov    %edi,%ecx
f0103bab:	d3 e8                	shr    %cl,%eax
f0103bad:	09 d0                	or     %edx,%eax
f0103baf:	d3 ee                	shr    %cl,%esi
f0103bb1:	89 f2                	mov    %esi,%edx
f0103bb3:	f7 74 24 18          	divl   0x18(%esp)
f0103bb7:	89 d6                	mov    %edx,%esi
f0103bb9:	f7 64 24 0c          	mull   0xc(%esp)
f0103bbd:	89 c5                	mov    %eax,%ebp
f0103bbf:	89 d1                	mov    %edx,%ecx
f0103bc1:	39 d6                	cmp    %edx,%esi
f0103bc3:	72 67                	jb     f0103c2c <__umoddi3+0x114>
f0103bc5:	74 75                	je     f0103c3c <__umoddi3+0x124>
f0103bc7:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0103bcb:	29 e8                	sub    %ebp,%eax
f0103bcd:	19 ce                	sbb    %ecx,%esi
f0103bcf:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103bd3:	d3 e8                	shr    %cl,%eax
f0103bd5:	89 f2                	mov    %esi,%edx
f0103bd7:	89 f9                	mov    %edi,%ecx
f0103bd9:	d3 e2                	shl    %cl,%edx
f0103bdb:	09 d0                	or     %edx,%eax
f0103bdd:	89 f2                	mov    %esi,%edx
f0103bdf:	8a 4c 24 10          	mov    0x10(%esp),%cl
f0103be3:	d3 ea                	shr    %cl,%edx
f0103be5:	83 c4 20             	add    $0x20,%esp
f0103be8:	5e                   	pop    %esi
f0103be9:	5f                   	pop    %edi
f0103bea:	5d                   	pop    %ebp
f0103beb:	c3                   	ret    
f0103bec:	85 c9                	test   %ecx,%ecx
f0103bee:	75 0b                	jne    f0103bfb <__umoddi3+0xe3>
f0103bf0:	b8 01 00 00 00       	mov    $0x1,%eax
f0103bf5:	31 d2                	xor    %edx,%edx
f0103bf7:	f7 f1                	div    %ecx
f0103bf9:	89 c1                	mov    %eax,%ecx
f0103bfb:	89 f0                	mov    %esi,%eax
f0103bfd:	31 d2                	xor    %edx,%edx
f0103bff:	f7 f1                	div    %ecx
f0103c01:	89 f8                	mov    %edi,%eax
f0103c03:	e9 3e ff ff ff       	jmp    f0103b46 <__umoddi3+0x2e>
f0103c08:	89 f2                	mov    %esi,%edx
f0103c0a:	83 c4 20             	add    $0x20,%esp
f0103c0d:	5e                   	pop    %esi
f0103c0e:	5f                   	pop    %edi
f0103c0f:	5d                   	pop    %ebp
f0103c10:	c3                   	ret    
f0103c11:	8d 76 00             	lea    0x0(%esi),%esi
f0103c14:	39 f5                	cmp    %esi,%ebp
f0103c16:	72 04                	jb     f0103c1c <__umoddi3+0x104>
f0103c18:	39 f9                	cmp    %edi,%ecx
f0103c1a:	77 06                	ja     f0103c22 <__umoddi3+0x10a>
f0103c1c:	89 f2                	mov    %esi,%edx
f0103c1e:	29 cf                	sub    %ecx,%edi
f0103c20:	19 ea                	sbb    %ebp,%edx
f0103c22:	89 f8                	mov    %edi,%eax
f0103c24:	83 c4 20             	add    $0x20,%esp
f0103c27:	5e                   	pop    %esi
f0103c28:	5f                   	pop    %edi
f0103c29:	5d                   	pop    %ebp
f0103c2a:	c3                   	ret    
f0103c2b:	90                   	nop
f0103c2c:	89 d1                	mov    %edx,%ecx
f0103c2e:	89 c5                	mov    %eax,%ebp
f0103c30:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
f0103c34:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
f0103c38:	eb 8d                	jmp    f0103bc7 <__umoddi3+0xaf>
f0103c3a:	66 90                	xchg   %ax,%ax
f0103c3c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
f0103c40:	72 ea                	jb     f0103c2c <__umoddi3+0x114>
f0103c42:	89 f1                	mov    %esi,%ecx
f0103c44:	eb 81                	jmp    f0103bc7 <__umoddi3+0xaf>
