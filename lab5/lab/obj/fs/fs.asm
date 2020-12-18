
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 ff 1b 00 00       	call   801c30 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	53                   	push   %ebx
  800038:	88 c1                	mov    %al,%cl

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  80003a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003f:	ec                   	in     (%dx),%al
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800040:	0f b6 c0             	movzbl %al,%eax
  800043:	89 c3                	mov    %eax,%ebx
  800045:	81 e3 c0 00 00 00    	and    $0xc0,%ebx
  80004b:	83 fb 40             	cmp    $0x40,%ebx
  80004e:	75 ef                	jne    80003f <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  800050:	84 c9                	test   %cl,%cl
  800052:	74 0c                	je     800060 <ide_wait_ready+0x2c>
  800054:	83 e0 21             	and    $0x21,%eax
		return -1;
	return 0;
  800057:	83 f8 01             	cmp    $0x1,%eax
  80005a:	19 c0                	sbb    %eax,%eax
  80005c:	f7 d0                	not    %eax
  80005e:	eb 05                	jmp    800065 <ide_wait_ready+0x31>
  800060:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800065:	5b                   	pop    %ebx
  800066:	5d                   	pop    %ebp
  800067:	c3                   	ret    

00800068 <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	53                   	push   %ebx
  80006c:	83 ec 14             	sub    $0x14,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  80006f:	b8 00 00 00 00       	mov    $0x0,%eax
  800074:	e8 bb ff ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800079:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80007e:	b0 f0                	mov    $0xf0,%al
  800080:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800081:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800086:	b2 f7                	mov    $0xf7,%dl
  800088:	eb 09                	jmp    800093 <ide_probe_disk1+0x2b>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  80008a:	43                   	inc    %ebx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008b:	81 fb e8 03 00 00    	cmp    $0x3e8,%ebx
  800091:	74 05                	je     800098 <ide_probe_disk1+0x30>
  800093:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800094:	a8 a1                	test   $0xa1,%al
  800096:	75 f2                	jne    80008a <ide_probe_disk1+0x22>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800098:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009d:	b0 e0                	mov    $0xe0,%al
  80009f:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a0:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000a6:	0f 9e c0             	setle  %al
  8000a9:	0f b6 c0             	movzbl %al,%eax
  8000ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b0:	c7 04 24 c0 3b 80 00 	movl   $0x803bc0,(%esp)
  8000b7:	e8 dc 1c 00 00       	call   801d98 <cprintf>
	return (x < 1000);
  8000bc:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  8000c2:	0f 9e c0             	setle  %al
}
  8000c5:	83 c4 14             	add    $0x14,%esp
  8000c8:	5b                   	pop    %ebx
  8000c9:	5d                   	pop    %ebp
  8000ca:	c3                   	ret    

008000cb <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000cb:	55                   	push   %ebp
  8000cc:	89 e5                	mov    %esp,%ebp
  8000ce:	83 ec 18             	sub    $0x18,%esp
  8000d1:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000d4:	83 f8 01             	cmp    $0x1,%eax
  8000d7:	76 1c                	jbe    8000f5 <ide_set_disk+0x2a>
		panic("bad disk number");
  8000d9:	c7 44 24 08 d7 3b 80 	movl   $0x803bd7,0x8(%esp)
  8000e0:	00 
  8000e1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e8:	00 
  8000e9:	c7 04 24 e7 3b 80 00 	movl   $0x803be7,(%esp)
  8000f0:	e8 ab 1b 00 00       	call   801ca0 <_panic>
	diskno = d;
  8000f5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000fa:	c9                   	leave  
  8000fb:	c3                   	ret    

008000fc <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	57                   	push   %edi
  800100:	56                   	push   %esi
  800101:	53                   	push   %ebx
  800102:	83 ec 1c             	sub    $0x1c,%esp
  800105:	8b 7d 08             	mov    0x8(%ebp),%edi
  800108:	8b 75 0c             	mov    0xc(%ebp),%esi
  80010b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  80010e:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  800114:	76 24                	jbe    80013a <ide_read+0x3e>
  800116:	c7 44 24 0c f0 3b 80 	movl   $0x803bf0,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 e7 3b 80 00 	movl   $0x803be7,(%esp)
  800135:	e8 66 1b 00 00       	call   801ca0 <_panic>

	ide_wait_ready(0);
  80013a:	b8 00 00 00 00       	mov    $0x0,%eax
  80013f:	e8 f0 fe ff ff       	call   800034 <ide_wait_ready>
  800144:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800149:	88 d8                	mov    %bl,%al
  80014b:	ee                   	out    %al,(%dx)
  80014c:	b2 f3                	mov    $0xf3,%dl
  80014e:	89 f8                	mov    %edi,%eax
  800150:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800151:	89 f8                	mov    %edi,%eax
  800153:	c1 e8 08             	shr    $0x8,%eax
  800156:	b2 f4                	mov    $0xf4,%dl
  800158:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800159:	89 f8                	mov    %edi,%eax
  80015b:	c1 e8 10             	shr    $0x10,%eax
  80015e:	b2 f5                	mov    $0xf5,%dl
  800160:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800161:	a1 00 50 80 00       	mov    0x805000,%eax
  800166:	83 e0 01             	and    $0x1,%eax
  800169:	c1 e0 04             	shl    $0x4,%eax
  80016c:	83 c8 e0             	or     $0xffffffe0,%eax
  80016f:	c1 ef 18             	shr    $0x18,%edi
  800172:	83 e7 0f             	and    $0xf,%edi
  800175:	09 f8                	or     %edi,%eax
  800177:	b2 f6                	mov    $0xf6,%dl
  800179:	ee                   	out    %al,(%dx)
  80017a:	b2 f7                	mov    $0xf7,%dl
  80017c:	b0 20                	mov    $0x20,%al
  80017e:	ee                   	out    %al,(%dx)
  80017f:	eb 24                	jmp    8001a5 <ide_read+0xa9>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800181:	b8 01 00 00 00       	mov    $0x1,%eax
  800186:	e8 a9 fe ff ff       	call   800034 <ide_wait_ready>
  80018b:	85 c0                	test   %eax,%eax
  80018d:	78 1f                	js     8001ae <ide_read+0xb2>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018f:	89 f7                	mov    %esi,%edi
  800191:	b9 80 00 00 00       	mov    $0x80,%ecx
  800196:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80019b:	fc                   	cld    
  80019c:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  80019e:	4b                   	dec    %ebx
  80019f:	81 c6 00 02 00 00    	add    $0x200,%esi
  8001a5:	85 db                	test   %ebx,%ebx
  8001a7:	75 d8                	jne    800181 <ide_read+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001ae:	83 c4 1c             	add    $0x1c,%esp
  8001b1:	5b                   	pop    %ebx
  8001b2:	5e                   	pop    %esi
  8001b3:	5f                   	pop    %edi
  8001b4:	5d                   	pop    %ebp
  8001b5:	c3                   	ret    

008001b6 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c2:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8001c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int r;

	assert(nsecs <= 256);
  8001c8:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
  8001ce:	76 24                	jbe    8001f4 <ide_write+0x3e>
  8001d0:	c7 44 24 0c f0 3b 80 	movl   $0x803bf0,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 e7 3b 80 00 	movl   $0x803be7,(%esp)
  8001ef:	e8 ac 1a 00 00       	call   801ca0 <_panic>

	ide_wait_ready(0);
  8001f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001f9:	e8 36 fe ff ff       	call   800034 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001fe:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800203:	88 d8                	mov    %bl,%al
  800205:	ee                   	out    %al,(%dx)
  800206:	b2 f3                	mov    $0xf3,%dl
  800208:	89 f0                	mov    %esi,%eax
  80020a:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  80020b:	89 f0                	mov    %esi,%eax
  80020d:	c1 e8 08             	shr    $0x8,%eax
  800210:	b2 f4                	mov    $0xf4,%dl
  800212:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800213:	89 f0                	mov    %esi,%eax
  800215:	c1 e8 10             	shr    $0x10,%eax
  800218:	b2 f5                	mov    $0xf5,%dl
  80021a:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  80021b:	a1 00 50 80 00       	mov    0x805000,%eax
  800220:	83 e0 01             	and    $0x1,%eax
  800223:	c1 e0 04             	shl    $0x4,%eax
  800226:	83 c8 e0             	or     $0xffffffe0,%eax
  800229:	c1 ee 18             	shr    $0x18,%esi
  80022c:	83 e6 0f             	and    $0xf,%esi
  80022f:	09 f0                	or     %esi,%eax
  800231:	b2 f6                	mov    $0xf6,%dl
  800233:	ee                   	out    %al,(%dx)
  800234:	b2 f7                	mov    $0xf7,%dl
  800236:	b0 30                	mov    $0x30,%al
  800238:	ee                   	out    %al,(%dx)
  800239:	eb 24                	jmp    80025f <ide_write+0xa9>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80023b:	b8 01 00 00 00       	mov    $0x1,%eax
  800240:	e8 ef fd ff ff       	call   800034 <ide_wait_ready>
  800245:	85 c0                	test   %eax,%eax
  800247:	78 1f                	js     800268 <ide_write+0xb2>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  800249:	89 fe                	mov    %edi,%esi
  80024b:	b9 80 00 00 00       	mov    $0x80,%ecx
  800250:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800255:	fc                   	cld    
  800256:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  800258:	4b                   	dec    %ebx
  800259:	81 c7 00 02 00 00    	add    $0x200,%edi
  80025f:	85 db                	test   %ebx,%ebx
  800261:	75 d8                	jne    80023b <ide_write+0x85>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800263:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800268:	83 c4 1c             	add    $0x1c,%esp
  80026b:	5b                   	pop    %ebx
  80026c:	5e                   	pop    %esi
  80026d:	5f                   	pop    %edi
  80026e:	5d                   	pop    %ebp
  80026f:	c3                   	ret    

00800270 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 20             	sub    $0x20,%esp
  800278:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80027b:	8b 18                	mov    (%eax),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80027d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
  800283:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800289:	76 2e                	jbe    8002b9 <bc_pgfault+0x49>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80028b:	8b 50 04             	mov    0x4(%eax),%edx
  80028e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800292:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  800296:	8b 40 28             	mov    0x28(%eax),%eax
  800299:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029d:	c7 44 24 08 14 3c 80 	movl   $0x803c14,0x8(%esp)
  8002a4:	00 
  8002a5:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ac:	00 
  8002ad:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  8002b4:	e8 e7 19 00 00       	call   801ca0 <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002b9:	8d b3 00 00 00 f0    	lea    -0x10000000(%ebx),%esi
  8002bf:	c1 ee 0c             	shr    $0xc,%esi
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c2:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002c7:	85 c0                	test   %eax,%eax
  8002c9:	74 25                	je     8002f0 <bc_pgfault+0x80>
  8002cb:	3b 70 04             	cmp    0x4(%eax),%esi
  8002ce:	72 20                	jb     8002f0 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8002d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8002d4:	c7 44 24 08 44 3c 80 	movl   $0x803c44,0x8(%esp)
  8002db:	00 
  8002dc:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e3:	00 
  8002e4:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  8002eb:	e8 b0 19 00 00       	call   801ca0 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 5: you code here:
	addr = (void *)((uintptr_t)addr & ~(PGSIZE - 1));
  8002f0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if ((r = sys_page_alloc(0, addr, PTE_SYSCALL)) < 0) {
  8002f6:	c7 44 24 08 07 0e 00 	movl   $0xe07,0x8(%esp)
  8002fd:	00 
  8002fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800302:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800309:	e8 47 24 00 00       	call   802755 <sys_page_alloc>
  80030e:	85 c0                	test   %eax,%eax
  800310:	79 20                	jns    800332 <bc_pgfault+0xc2>
		panic("page allocation fail: %e", r);
  800312:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800316:	c7 44 24 08 d8 3c 80 	movl   $0x803cd8,0x8(%esp)
  80031d:	00 
  80031e:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  800325:	00 
  800326:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  80032d:	e8 6e 19 00 00       	call   801ca0 <_panic>
	}
	// Read 8 times for the whole page
	ide_read(blockno * BLKSECTS, addr, BLKSECTS);
  800332:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  800339:	00 
  80033a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80033e:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800345:	89 04 24             	mov    %eax,(%esp)
  800348:	e8 af fd ff ff       	call   8000fc <ide_read>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  80034d:	89 d8                	mov    %ebx,%eax
  80034f:	c1 e8 0c             	shr    $0xc,%eax
  800352:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800359:	25 07 0e 00 00       	and    $0xe07,%eax
  80035e:	89 44 24 10          	mov    %eax,0x10(%esp)
  800362:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800366:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80036d:	00 
  80036e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800372:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800379:	e8 2b 24 00 00       	call   8027a9 <sys_page_map>
  80037e:	85 c0                	test   %eax,%eax
  800380:	79 20                	jns    8003a2 <bc_pgfault+0x132>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800382:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800386:	c7 44 24 08 68 3c 80 	movl   $0x803c68,0x8(%esp)
  80038d:	00 
  80038e:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  800395:	00 
  800396:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  80039d:	e8 fe 18 00 00       	call   801ca0 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  8003a2:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  8003a9:	74 2c                	je     8003d7 <bc_pgfault+0x167>
  8003ab:	89 34 24             	mov    %esi,(%esp)
  8003ae:	e8 50 05 00 00       	call   800903 <block_is_free>
  8003b3:	84 c0                	test   %al,%al
  8003b5:	74 20                	je     8003d7 <bc_pgfault+0x167>
		panic("reading free block %08x\n", blockno);
  8003b7:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8003bb:	c7 44 24 08 f1 3c 80 	movl   $0x803cf1,0x8(%esp)
  8003c2:	00 
  8003c3:	c7 44 24 04 43 00 00 	movl   $0x43,0x4(%esp)
  8003ca:	00 
  8003cb:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  8003d2:	e8 c9 18 00 00       	call   801ca0 <_panic>
}
  8003d7:	83 c4 20             	add    $0x20,%esp
  8003da:	5b                   	pop    %ebx
  8003db:	5e                   	pop    %esi
  8003dc:	5d                   	pop    %ebp
  8003dd:	c3                   	ret    

008003de <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  8003de:	55                   	push   %ebp
  8003df:	89 e5                	mov    %esp,%ebp
  8003e1:	83 ec 18             	sub    $0x18,%esp
  8003e4:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  8003e7:	85 c0                	test   %eax,%eax
  8003e9:	74 0f                	je     8003fa <diskaddr+0x1c>
  8003eb:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003f1:	85 d2                	test   %edx,%edx
  8003f3:	74 25                	je     80041a <diskaddr+0x3c>
  8003f5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003f8:	72 20                	jb     80041a <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  8003fa:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003fe:	c7 44 24 08 88 3c 80 	movl   $0x803c88,0x8(%esp)
  800405:	00 
  800406:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  80040d:	00 
  80040e:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  800415:	e8 86 18 00 00       	call   801ca0 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  80041a:	05 00 00 01 00       	add    $0x10000,%eax
  80041f:	c1 e0 0c             	shl    $0xc,%eax
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	8b 45 08             	mov    0x8(%ebp),%eax
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 ea 16             	shr    $0x16,%edx
  80042f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	74 0f                	je     80044a <va_is_mapped+0x26>
  80043b:	c1 e8 0c             	shr    $0xc,%eax
  80043e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800445:	83 e0 01             	and    $0x1,%eax
  800448:	eb 05                	jmp    80044f <va_is_mapped+0x2b>
  80044a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  800454:	8b 45 08             	mov    0x8(%ebp),%eax
  800457:	c1 e8 0c             	shr    $0xc,%eax
  80045a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800461:	a8 40                	test   $0x40,%al
  800463:	0f 95 c0             	setne  %al
}
  800466:	5d                   	pop    %ebp
  800467:	c3                   	ret    

00800468 <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  800468:	55                   	push   %ebp
  800469:	89 e5                	mov    %esp,%ebp
  80046b:	56                   	push   %esi
  80046c:	53                   	push   %ebx
  80046d:	83 ec 20             	sub    $0x20,%esp
  800470:	8b 75 08             	mov    0x8(%ebp),%esi
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800473:	8d 86 00 00 00 f0    	lea    -0x10000000(%esi),%eax
  800479:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80047e:	76 20                	jbe    8004a0 <flush_block+0x38>
		panic("flush_block of bad va %08x", addr);
  800480:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800484:	c7 44 24 08 0a 3d 80 	movl   $0x803d0a,0x8(%esp)
  80048b:	00 
  80048c:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800493:	00 
  800494:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  80049b:	e8 00 18 00 00       	call   801ca0 <_panic>

	// LAB 5: Your code here.
	addr = (void *)((uintptr_t)addr & ~(PGSIZE - 1));
  8004a0:	89 f3                	mov    %esi,%ebx
  8004a2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
  8004a8:	89 1c 24             	mov    %ebx,(%esp)
  8004ab:	e8 74 ff ff ff       	call   800424 <va_is_mapped>
  8004b0:	84 c0                	test   %al,%al
  8004b2:	74 7d                	je     800531 <flush_block+0xc9>
  8004b4:	89 1c 24             	mov    %ebx,(%esp)
  8004b7:	e8 95 ff ff ff       	call   800451 <va_is_dirty>
  8004bc:	84 c0                	test   %al,%al
  8004be:	74 71                	je     800531 <flush_block+0xc9>
		ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  8004c0:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
  8004c7:	00 
  8004c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8004cc:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
  8004d2:	c1 ee 0c             	shr    $0xc,%esi
		panic("flush_block of bad va %08x", addr);

	// LAB 5: Your code here.
	addr = (void *)((uintptr_t)addr & ~(PGSIZE - 1));
	if (va_is_mapped(addr) && va_is_dirty(addr)) {
		ide_write(blockno * BLKSECTS, addr, BLKSECTS);
  8004d5:	c1 e6 03             	shl    $0x3,%esi
  8004d8:	89 34 24             	mov    %esi,(%esp)
  8004db:	e8 d6 fc ff ff       	call   8001b6 <ide_write>
		if (sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL) < 0) {
  8004e0:	89 d8                	mov    %ebx,%eax
  8004e2:	c1 e8 0c             	shr    $0xc,%eax
  8004e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8004ec:	25 07 0e 00 00       	and    $0xe07,%eax
  8004f1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004f5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8004f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800500:	00 
  800501:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800505:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80050c:	e8 98 22 00 00       	call   8027a9 <sys_page_map>
  800511:	85 c0                	test   %eax,%eax
  800513:	79 1c                	jns    800531 <flush_block+0xc9>
			panic("page remap failed");
  800515:	c7 44 24 08 25 3d 80 	movl   $0x803d25,0x8(%esp)
  80051c:	00 
  80051d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800524:	00 
  800525:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  80052c:	e8 6f 17 00 00       	call   801ca0 <_panic>
		}
	}
}
  800531:	83 c4 20             	add    $0x20,%esp
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5d                   	pop    %ebp
  800537:	c3                   	ret    

00800538 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	53                   	push   %ebx
  80053c:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  800542:	c7 04 24 70 02 80 00 	movl   $0x800270,(%esp)
  800549:	e8 72 24 00 00       	call   8029c0 <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  80054e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800555:	e8 84 fe ff ff       	call   8003de <diskaddr>
  80055a:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800561:	00 
  800562:	89 44 24 04          	mov    %eax,0x4(%esp)
  800566:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80056c:	89 04 24             	mov    %eax,(%esp)
  80056f:	e8 68 1f 00 00       	call   8024dc <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800574:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80057b:	e8 5e fe ff ff       	call   8003de <diskaddr>
  800580:	c7 44 24 04 37 3d 80 	movl   $0x803d37,0x4(%esp)
  800587:	00 
  800588:	89 04 24             	mov    %eax,(%esp)
  80058b:	e8 d3 1d 00 00       	call   802363 <strcpy>
	flush_block(diskaddr(1));
  800590:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800597:	e8 42 fe ff ff       	call   8003de <diskaddr>
  80059c:	89 04 24             	mov    %eax,(%esp)
  80059f:	e8 c4 fe ff ff       	call   800468 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  8005a4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ab:	e8 2e fe ff ff       	call   8003de <diskaddr>
  8005b0:	89 04 24             	mov    %eax,(%esp)
  8005b3:	e8 6c fe ff ff       	call   800424 <va_is_mapped>
  8005b8:	84 c0                	test   %al,%al
  8005ba:	75 24                	jne    8005e0 <bc_init+0xa8>
  8005bc:	c7 44 24 0c 59 3d 80 	movl   $0x803d59,0xc(%esp)
  8005c3:	00 
  8005c4:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  8005cb:	00 
  8005cc:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  8005d3:	00 
  8005d4:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  8005db:	e8 c0 16 00 00       	call   801ca0 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  8005e0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005e7:	e8 f2 fd ff ff       	call   8003de <diskaddr>
  8005ec:	89 04 24             	mov    %eax,(%esp)
  8005ef:	e8 5d fe ff ff       	call   800451 <va_is_dirty>
  8005f4:	84 c0                	test   %al,%al
  8005f6:	74 24                	je     80061c <bc_init+0xe4>
  8005f8:	c7 44 24 0c 3e 3d 80 	movl   $0x803d3e,0xc(%esp)
  8005ff:	00 
  800600:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  800607:	00 
  800608:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  80060f:	00 
  800610:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  800617:	e8 84 16 00 00       	call   801ca0 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  80061c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800623:	e8 b6 fd ff ff       	call   8003de <diskaddr>
  800628:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800633:	e8 c4 21 00 00       	call   8027fc <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  800638:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80063f:	e8 9a fd ff ff       	call   8003de <diskaddr>
  800644:	89 04 24             	mov    %eax,(%esp)
  800647:	e8 d8 fd ff ff       	call   800424 <va_is_mapped>
  80064c:	84 c0                	test   %al,%al
  80064e:	74 24                	je     800674 <bc_init+0x13c>
  800650:	c7 44 24 0c 58 3d 80 	movl   $0x803d58,0xc(%esp)
  800657:	00 
  800658:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  80065f:	00 
  800660:	c7 44 24 04 71 00 00 	movl   $0x71,0x4(%esp)
  800667:	00 
  800668:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  80066f:	e8 2c 16 00 00       	call   801ca0 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  800674:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80067b:	e8 5e fd ff ff       	call   8003de <diskaddr>
  800680:	c7 44 24 04 37 3d 80 	movl   $0x803d37,0x4(%esp)
  800687:	00 
  800688:	89 04 24             	mov    %eax,(%esp)
  80068b:	e8 7a 1d 00 00       	call   80240a <strcmp>
  800690:	85 c0                	test   %eax,%eax
  800692:	74 24                	je     8006b8 <bc_init+0x180>
  800694:	c7 44 24 0c ac 3c 80 	movl   $0x803cac,0xc(%esp)
  80069b:	00 
  80069c:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  8006a3:	00 
  8006a4:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
  8006ab:	00 
  8006ac:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  8006b3:	e8 e8 15 00 00       	call   801ca0 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  8006b8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006bf:	e8 1a fd ff ff       	call   8003de <diskaddr>
  8006c4:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  8006cb:	00 
  8006cc:	8d 9d e8 fd ff ff    	lea    -0x218(%ebp),%ebx
  8006d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	e8 fe 1d 00 00       	call   8024dc <memmove>
	flush_block(diskaddr(1));
  8006de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006e5:	e8 f4 fc ff ff       	call   8003de <diskaddr>
  8006ea:	89 04 24             	mov    %eax,(%esp)
  8006ed:	e8 76 fd ff ff       	call   800468 <flush_block>

	// Now repeat the same experiment, but pass an unaligned address to
	// flush_block.

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8006f2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006f9:	e8 e0 fc ff ff       	call   8003de <diskaddr>
  8006fe:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800705:	00 
  800706:	89 44 24 04          	mov    %eax,0x4(%esp)
  80070a:	89 1c 24             	mov    %ebx,(%esp)
  80070d:	e8 ca 1d 00 00       	call   8024dc <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800712:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800719:	e8 c0 fc ff ff       	call   8003de <diskaddr>
  80071e:	c7 44 24 04 37 3d 80 	movl   $0x803d37,0x4(%esp)
  800725:	00 
  800726:	89 04 24             	mov    %eax,(%esp)
  800729:	e8 35 1c 00 00       	call   802363 <strcpy>

	// Pass an unaligned address to flush_block.
	flush_block(diskaddr(1) + 20);
  80072e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800735:	e8 a4 fc ff ff       	call   8003de <diskaddr>
  80073a:	83 c0 14             	add    $0x14,%eax
  80073d:	89 04 24             	mov    %eax,(%esp)
  800740:	e8 23 fd ff ff       	call   800468 <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800745:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80074c:	e8 8d fc ff ff       	call   8003de <diskaddr>
  800751:	89 04 24             	mov    %eax,(%esp)
  800754:	e8 cb fc ff ff       	call   800424 <va_is_mapped>
  800759:	84 c0                	test   %al,%al
  80075b:	75 24                	jne    800781 <bc_init+0x249>
  80075d:	c7 44 24 0c 59 3d 80 	movl   $0x803d59,0xc(%esp)
  800764:	00 
  800765:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  80076c:	00 
  80076d:	c7 44 24 04 85 00 00 	movl   $0x85,0x4(%esp)
  800774:	00 
  800775:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  80077c:	e8 1f 15 00 00       	call   801ca0 <_panic>
	// Skip the !va_is_dirty() check because it makes the bug somewhat
	// obscure and hence harder to debug.
	//assert(!va_is_dirty(diskaddr(1)));

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800781:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800788:	e8 51 fc ff ff       	call   8003de <diskaddr>
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800798:	e8 5f 20 00 00       	call   8027fc <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80079d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007a4:	e8 35 fc ff ff       	call   8003de <diskaddr>
  8007a9:	89 04 24             	mov    %eax,(%esp)
  8007ac:	e8 73 fc ff ff       	call   800424 <va_is_mapped>
  8007b1:	84 c0                	test   %al,%al
  8007b3:	74 24                	je     8007d9 <bc_init+0x2a1>
  8007b5:	c7 44 24 0c 58 3d 80 	movl   $0x803d58,0xc(%esp)
  8007bc:	00 
  8007bd:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  8007c4:	00 
  8007c5:	c7 44 24 04 8d 00 00 	movl   $0x8d,0x4(%esp)
  8007cc:	00 
  8007cd:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  8007d4:	e8 c7 14 00 00       	call   801ca0 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8007d9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8007e0:	e8 f9 fb ff ff       	call   8003de <diskaddr>
  8007e5:	c7 44 24 04 37 3d 80 	movl   $0x803d37,0x4(%esp)
  8007ec:	00 
  8007ed:	89 04 24             	mov    %eax,(%esp)
  8007f0:	e8 15 1c 00 00       	call   80240a <strcmp>
  8007f5:	85 c0                	test   %eax,%eax
  8007f7:	74 24                	je     80081d <bc_init+0x2e5>
  8007f9:	c7 44 24 0c ac 3c 80 	movl   $0x803cac,0xc(%esp)
  800800:	00 
  800801:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  800808:	00 
  800809:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  800810:	00 
  800811:	c7 04 24 d0 3c 80 00 	movl   $0x803cd0,(%esp)
  800818:	e8 83 14 00 00       	call   801ca0 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  80081d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800824:	e8 b5 fb ff ff       	call   8003de <diskaddr>
  800829:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800830:	00 
  800831:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  800837:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083b:	89 04 24             	mov    %eax,(%esp)
  80083e:	e8 99 1c 00 00       	call   8024dc <memmove>
	flush_block(diskaddr(1));
  800843:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80084a:	e8 8f fb ff ff       	call   8003de <diskaddr>
  80084f:	89 04 24             	mov    %eax,(%esp)
  800852:	e8 11 fc ff ff       	call   800468 <flush_block>

	cprintf("block cache is good\n");
  800857:	c7 04 24 73 3d 80 00 	movl   $0x803d73,(%esp)
  80085e:	e8 35 15 00 00       	call   801d98 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800863:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80086a:	e8 6f fb ff ff       	call   8003de <diskaddr>
  80086f:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  800876:	00 
  800877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800881:	89 04 24             	mov    %eax,(%esp)
  800884:	e8 53 1c 00 00       	call   8024dc <memmove>
}
  800889:	81 c4 24 02 00 00    	add    $0x224,%esp
  80088f:	5b                   	pop    %ebx
  800890:	5d                   	pop    %ebp
  800891:	c3                   	ret    
	...

00800894 <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  800897:	eb 01                	jmp    80089a <skip_slash+0x6>
		p++;
  800899:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  80089a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80089d:	74 fa                	je     800899 <skip_slash+0x5>
		p++;
	return p;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  8008a1:	55                   	push   %ebp
  8008a2:	89 e5                	mov    %esp,%ebp
  8008a4:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  8008a7:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8008ac:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  8008b2:	74 1c                	je     8008d0 <check_super+0x2f>
		panic("bad file system magic number");
  8008b4:	c7 44 24 08 88 3d 80 	movl   $0x803d88,0x8(%esp)
  8008bb:	00 
  8008bc:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8008c3:	00 
  8008c4:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  8008cb:	e8 d0 13 00 00       	call   801ca0 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  8008d0:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8008d7:	76 1c                	jbe    8008f5 <check_super+0x54>
		panic("file system is too large");
  8008d9:	c7 44 24 08 ad 3d 80 	movl   $0x803dad,0x8(%esp)
  8008e0:	00 
  8008e1:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  8008e8:	00 
  8008e9:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  8008f0:	e8 ab 13 00 00       	call   801ca0 <_panic>

	cprintf("superblock is good\n");
  8008f5:	c7 04 24 c6 3d 80 00 	movl   $0x803dc6,(%esp)
  8008fc:	e8 97 14 00 00       	call   801d98 <cprintf>
}
  800901:	c9                   	leave  
  800902:	c3                   	ret    

00800903 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  800909:	a1 08 a0 80 00       	mov    0x80a008,%eax
  80090e:	85 c0                	test   %eax,%eax
  800910:	74 1d                	je     80092f <block_is_free+0x2c>
  800912:	39 48 04             	cmp    %ecx,0x4(%eax)
  800915:	76 1c                	jbe    800933 <block_is_free+0x30>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800917:	b8 01 00 00 00       	mov    $0x1,%eax
  80091c:	d3 e0                	shl    %cl,%eax
  80091e:	c1 e9 05             	shr    $0x5,%ecx
// --------------------------------------------------------------

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
  800921:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800927:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  80092a:	0f 95 c0             	setne  %al
  80092d:	eb 06                	jmp    800935 <block_is_free+0x32>
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  80092f:	b0 00                	mov    $0x0,%al
  800931:	eb 02                	jmp    800935 <block_is_free+0x32>
  800933:	b0 00                	mov    $0x0,%al
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	83 ec 18             	sub    $0x18,%esp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800940:	85 c9                	test   %ecx,%ecx
  800942:	75 1c                	jne    800960 <free_block+0x29>
		panic("attempt to free zero block");
  800944:	c7 44 24 08 da 3d 80 	movl   $0x803dda,0x8(%esp)
  80094b:	00 
  80094c:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800953:	00 
  800954:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  80095b:	e8 40 13 00 00       	call   801ca0 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800960:	89 c8                	mov    %ecx,%eax
  800962:	c1 e8 05             	shr    $0x5,%eax
  800965:	c1 e0 02             	shl    $0x2,%eax
  800968:	03 05 04 a0 80 00    	add    0x80a004,%eax
  80096e:	ba 01 00 00 00       	mov    $0x1,%edx
  800973:	d3 e2                	shl    %cl,%edx
  800975:	09 10                	or     %edx,(%eax)
}
  800977:	c9                   	leave  
  800978:	c3                   	ret    

00800979 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	53                   	push   %ebx
  80097d:	83 ec 04             	sub    $0x4,%esp
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	int i;
	for (i = 0; i < super->s_nblocks; i++) {
  800980:	bb 00 00 00 00       	mov    $0x0,%ebx
  800985:	eb 3c                	jmp    8009c3 <alloc_block+0x4a>
		if (block_is_free(i)) {
  800987:	89 1c 24             	mov    %ebx,(%esp)
  80098a:	e8 74 ff ff ff       	call   800903 <block_is_free>
  80098f:	84 c0                	test   %al,%al
  800991:	74 2f                	je     8009c2 <alloc_block+0x49>
  800993:	89 d9                	mov    %ebx,%ecx
			bitmap[i/32] &= ~(1 << (i%32));
  800995:	89 d8                	mov    %ebx,%eax
  800997:	85 db                	test   %ebx,%ebx
  800999:	79 03                	jns    80099e <alloc_block+0x25>
  80099b:	8d 43 1f             	lea    0x1f(%ebx),%eax
  80099e:	c1 f8 05             	sar    $0x5,%eax
  8009a1:	c1 e0 02             	shl    $0x2,%eax
  8009a4:	03 05 04 a0 80 00    	add    0x80a004,%eax
  8009aa:	81 e1 1f 00 00 80    	and    $0x8000001f,%ecx
  8009b0:	79 05                	jns    8009b7 <alloc_block+0x3e>
  8009b2:	49                   	dec    %ecx
  8009b3:	83 c9 e0             	or     $0xffffffe0,%ecx
  8009b6:	41                   	inc    %ecx
  8009b7:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
  8009bc:	d3 c2                	rol    %cl,%edx
  8009be:	21 10                	and    %edx,(%eax)
			return i;
  8009c0:	eb 10                	jmp    8009d2 <alloc_block+0x59>
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	int i;
	for (i = 0; i < super->s_nblocks; i++) {
  8009c2:	43                   	inc    %ebx
  8009c3:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8009c8:	3b 58 04             	cmp    0x4(%eax),%ebx
  8009cb:	72 ba                	jb     800987 <alloc_block+0xe>
		if (block_is_free(i)) {
			bitmap[i/32] &= ~(1 << (i%32));
			return i;
		}
	}
	return -E_NO_DISK;
  8009cd:	bb f7 ff ff ff       	mov    $0xfffffff7,%ebx
}
  8009d2:	89 d8                	mov    %ebx,%eax
  8009d4:	83 c4 04             	add    $0x4,%esp
  8009d7:	5b                   	pop    %ebx
  8009d8:	5d                   	pop    %ebp
  8009d9:	c3                   	ret    

008009da <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	57                   	push   %edi
  8009de:	56                   	push   %esi
  8009df:	53                   	push   %ebx
  8009e0:	89 c6                	mov    %eax,%esi
  8009e2:	89 d3                	mov    %edx,%ebx
  8009e4:	89 cf                	mov    %ecx,%edi
  8009e6:	8a 45 08             	mov    0x8(%ebp),%al
	// LAB 5: Your code here.
	uint32_t *inBlkAddr;
	int r;
	if (filebno >= NDIRECT + NINDIRECT) {
  8009e9:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8009ef:	77 5d                	ja     800a4e <file_block_walk+0x74>
		return -E_INVAL;
	}
	// First, find out whether the block is already linked
	// The block can be either less than NDIRECT
	if ((filebno >= 0) && (filebno < NDIRECT)) {
  8009f1:	83 fa 09             	cmp    $0x9,%edx
  8009f4:	77 10                	ja     800a06 <file_block_walk+0x2c>
		*ppdiskbno = &(f->f_direct[filebno]);
  8009f6:	8d 84 96 88 00 00 00 	lea    0x88(%esi,%edx,4),%eax
  8009fd:	89 01                	mov    %eax,(%ecx)
		return 0;
  8009ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800a04:	eb 5b                	jmp    800a61 <file_block_walk+0x87>
	}
	// Or greater than or equal to NDIRECT
	if ((filebno >= NDIRECT) && (f->f_indirect != 0)) {
  800a06:	8b 96 b0 00 00 00    	mov    0xb0(%esi),%edx
  800a0c:	85 d2                	test   %edx,%edx
  800a0e:	74 16                	je     800a26 <file_block_walk+0x4c>
		inBlkAddr = (uint32_t *)(f->f_indirect * BLKSIZE + DISKMAP);
  800a10:	81 c2 00 00 01 00    	add    $0x10000,%edx
  800a16:	c1 e2 0c             	shl    $0xc,%edx
		*ppdiskbno = &inBlkAddr[filebno - 4];
  800a19:	8d 44 9a f0          	lea    -0x10(%edx,%ebx,4),%eax
  800a1d:	89 01                	mov    %eax,(%ecx)
		return 0;
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a24:	eb 3b                	jmp    800a61 <file_block_walk+0x87>
	}
	// Allocate a new page if necessary
	if (alloc && (f->f_indirect == 0)) {
  800a26:	84 c0                	test   %al,%al
  800a28:	74 2b                	je     800a55 <file_block_walk+0x7b>
		if ((r = alloc_block()) < 0) {
  800a2a:	e8 4a ff ff ff       	call   800979 <alloc_block>
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	78 29                	js     800a5c <file_block_walk+0x82>
			return -E_NO_DISK;
		}
		f->f_indirect = r;
  800a33:	89 86 b0 00 00 00    	mov    %eax,0xb0(%esi)
		inBlkAddr = (uint32_t *)(f->f_indirect * BLKSIZE + DISKMAP);
  800a39:	05 00 00 01 00       	add    $0x10000,%eax
  800a3e:	c1 e0 0c             	shl    $0xc,%eax
		*ppdiskbno = &inBlkAddr[filebno - 4];
  800a41:	8d 44 98 f0          	lea    -0x10(%eax,%ebx,4),%eax
  800a45:	89 07                	mov    %eax,(%edi)
		return 0;
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4c:	eb 13                	jmp    800a61 <file_block_walk+0x87>
{
	// LAB 5: Your code here.
	uint32_t *inBlkAddr;
	int r;
	if (filebno >= NDIRECT + NINDIRECT) {
		return -E_INVAL;
  800a4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a53:	eb 0c                	jmp    800a61 <file_block_walk+0x87>
		f->f_indirect = r;
		inBlkAddr = (uint32_t *)(f->f_indirect * BLKSIZE + DISKMAP);
		*ppdiskbno = &inBlkAddr[filebno - 4];
		return 0;
	}
	return -E_NOT_FOUND;
  800a55:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800a5a:	eb 05                	jmp    800a61 <file_block_walk+0x87>
		return 0;
	}
	// Allocate a new page if necessary
	if (alloc && (f->f_indirect == 0)) {
		if ((r = alloc_block()) < 0) {
			return -E_NO_DISK;
  800a5c:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		inBlkAddr = (uint32_t *)(f->f_indirect * BLKSIZE + DISKMAP);
		*ppdiskbno = &inBlkAddr[filebno - 4];
		return 0;
	}
	return -E_NOT_FOUND;
}
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5f                   	pop    %edi
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	53                   	push   %ebx
  800a6a:	83 ec 14             	sub    $0x14,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800a6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a72:	eb 34                	jmp    800aa8 <check_bitmap+0x42>
		assert(!block_is_free(2+i));
  800a74:	8d 43 02             	lea    0x2(%ebx),%eax
  800a77:	89 04 24             	mov    %eax,(%esp)
  800a7a:	e8 84 fe ff ff       	call   800903 <block_is_free>
  800a7f:	84 c0                	test   %al,%al
  800a81:	74 24                	je     800aa7 <check_bitmap+0x41>
  800a83:	c7 44 24 0c f5 3d 80 	movl   $0x803df5,0xc(%esp)
  800a8a:	00 
  800a8b:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  800a92:	00 
  800a93:	c7 44 24 04 56 00 00 	movl   $0x56,0x4(%esp)
  800a9a:	00 
  800a9b:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  800aa2:	e8 f9 11 00 00       	call   801ca0 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800aa7:	43                   	inc    %ebx
  800aa8:	89 da                	mov    %ebx,%edx
  800aaa:	c1 e2 0f             	shl    $0xf,%edx
  800aad:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800ab2:	3b 50 04             	cmp    0x4(%eax),%edx
  800ab5:	72 bd                	jb     800a74 <check_bitmap+0xe>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  800ab7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800abe:	e8 40 fe ff ff       	call   800903 <block_is_free>
  800ac3:	84 c0                	test   %al,%al
  800ac5:	74 24                	je     800aeb <check_bitmap+0x85>
  800ac7:	c7 44 24 0c 09 3e 80 	movl   $0x803e09,0xc(%esp)
  800ace:	00 
  800acf:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  800ad6:	00 
  800ad7:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  800ade:	00 
  800adf:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  800ae6:	e8 b5 11 00 00       	call   801ca0 <_panic>
	assert(!block_is_free(1));
  800aeb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800af2:	e8 0c fe ff ff       	call   800903 <block_is_free>
  800af7:	84 c0                	test   %al,%al
  800af9:	74 24                	je     800b1f <check_bitmap+0xb9>
  800afb:	c7 44 24 0c 1b 3e 80 	movl   $0x803e1b,0xc(%esp)
  800b02:	00 
  800b03:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  800b0a:	00 
  800b0b:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  800b12:	00 
  800b13:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  800b1a:	e8 81 11 00 00       	call   801ca0 <_panic>

	cprintf("bitmap is good\n");
  800b1f:	c7 04 24 2d 3e 80 00 	movl   $0x803e2d,(%esp)
  800b26:	e8 6d 12 00 00       	call   801d98 <cprintf>
}
  800b2b:	83 c4 14             	add    $0x14,%esp
  800b2e:	5b                   	pop    %ebx
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800b37:	e8 2c f5 ff ff       	call   800068 <ide_probe_disk1>
  800b3c:	84 c0                	test   %al,%al
  800b3e:	74 0e                	je     800b4e <fs_init+0x1d>
		ide_set_disk(1);
  800b40:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b47:	e8 7f f5 ff ff       	call   8000cb <ide_set_disk>
  800b4c:	eb 0c                	jmp    800b5a <fs_init+0x29>
	else
		ide_set_disk(0);
  800b4e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b55:	e8 71 f5 ff ff       	call   8000cb <ide_set_disk>
	bc_init();
  800b5a:	e8 d9 f9 ff ff       	call   800538 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800b5f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b66:	e8 73 f8 ff ff       	call   8003de <diskaddr>
  800b6b:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800b70:	e8 2c fd ff ff       	call   8008a1 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  800b75:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800b7c:	e8 5d f8 ff ff       	call   8003de <diskaddr>
  800b81:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800b86:	e8 db fe ff ff       	call   800a66 <check_bitmap>
	
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	53                   	push   %ebx
  800b91:	83 ec 14             	sub    $0x14,%esp
    // LAB 5: Your code here.
	uint32_t *ppdiskbno;
	int r;
    if ((r = file_block_walk(f, filebno, &ppdiskbno, true)) < 0) {
  800b94:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800b9b:	8d 4d f8             	lea    -0x8(%ebp),%ecx
  800b9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba4:	e8 31 fe ff ff       	call   8009da <file_block_walk>
  800ba9:	85 c0                	test   %eax,%eax
  800bab:	78 27                	js     800bd4 <file_get_block+0x47>
		return r;
	}
	// If filebno is not allocated
	if (*ppdiskbno == 0) {
  800bad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800bb0:	83 3b 00             	cmpl   $0x0,(%ebx)
  800bb3:	75 07                	jne    800bbc <file_get_block+0x2f>
		// If allocate not success
		if ((*ppdiskbno = alloc_block()) < 0) {
  800bb5:	e8 bf fd ff ff       	call   800979 <alloc_block>
  800bba:	89 03                	mov    %eax,(%ebx)
			return -E_NO_DISK;
		}
	}
	*blk = (char *)(*ppdiskbno * BLKSIZE + DISKMAP);
  800bbc:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800bbf:	8b 10                	mov    (%eax),%edx
  800bc1:	81 c2 00 00 01 00    	add    $0x10000,%edx
  800bc7:	c1 e2 0c             	shl    $0xc,%edx
  800bca:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcd:	89 10                	mov    %edx,(%eax)
	return 0;
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bd4:	83 c4 14             	add    $0x14,%esp
  800bd7:	5b                   	pop    %ebx
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    

00800bda <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	81 ec cc 00 00 00    	sub    $0xcc,%esp
  800be6:	89 95 44 ff ff ff    	mov    %edx,-0xbc(%ebp)
  800bec:	89 8d 40 ff ff ff    	mov    %ecx,-0xc0(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  800bf2:	e8 9d fc ff ff       	call   800894 <skip_slash>
  800bf7:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
	f = &super->s_root;
  800bfd:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800c02:	83 c0 08             	add    $0x8,%eax
  800c05:	89 85 50 ff ff ff    	mov    %eax,-0xb0(%ebp)
	dir = 0;
	name[0] = 0;
  800c0b:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800c12:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800c19:	74 0c                	je     800c27 <walk_path+0x4d>
		*pdir = 0;
  800c1b:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800c21:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  800c27:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800c2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800c33:	b8 00 00 00 00       	mov    $0x0,%eax
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800c38:	e9 95 01 00 00       	jmp    800dd2 <walk_path+0x1f8>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800c3d:	46                   	inc    %esi
  800c3e:	eb 06                	jmp    800c46 <walk_path+0x6c>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800c40:	8b b5 4c ff ff ff    	mov    -0xb4(%ebp),%esi
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800c46:	8a 06                	mov    (%esi),%al
  800c48:	3c 2f                	cmp    $0x2f,%al
  800c4a:	74 04                	je     800c50 <walk_path+0x76>
  800c4c:	84 c0                	test   %al,%al
  800c4e:	75 ed                	jne    800c3d <walk_path+0x63>
			path++;
		if (path - p >= MAXNAMELEN)
  800c50:	89 f3                	mov    %esi,%ebx
  800c52:	2b 9d 4c ff ff ff    	sub    -0xb4(%ebp),%ebx
  800c58:	83 fb 7f             	cmp    $0x7f,%ebx
  800c5b:	0f 8f a6 01 00 00    	jg     800e07 <walk_path+0x22d>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800c61:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800c65:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800c6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c6f:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800c75:	89 14 24             	mov    %edx,(%esp)
  800c78:	e8 5f 18 00 00       	call   8024dc <memmove>
		name[path - p] = '\0';
  800c7d:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800c84:	00 
		path = skip_slash(path);
  800c85:	89 f0                	mov    %esi,%eax
  800c87:	e8 08 fc ff ff       	call   800894 <skip_slash>
  800c8c:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)

		if (dir->f_type != FTYPE_DIR)
  800c92:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800c98:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800c9f:	0f 85 69 01 00 00    	jne    800e0e <walk_path+0x234>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800ca5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800cab:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800cb0:	74 24                	je     800cd6 <walk_path+0xfc>
  800cb2:	c7 44 24 0c 3d 3e 80 	movl   $0x803e3d,0xc(%esp)
  800cb9:	00 
  800cba:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  800cc1:	00 
  800cc2:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
  800cc9:	00 
  800cca:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  800cd1:	e8 ca 0f 00 00       	call   801ca0 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800cd6:	89 c2                	mov    %eax,%edx
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	79 06                	jns    800ce2 <walk_path+0x108>
  800cdc:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800ce2:	c1 fa 0c             	sar    $0xc,%edx
  800ce5:	89 95 48 ff ff ff    	mov    %edx,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800ceb:	c7 85 54 ff ff ff 00 	movl   $0x0,-0xac(%ebp)
  800cf2:	00 00 00 
  800cf5:	eb 62                	jmp    800d59 <walk_path+0x17f>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800cf7:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800cfd:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d01:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  800d07:	89 54 24 04          	mov    %edx,0x4(%esp)
  800d0b:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800d11:	89 04 24             	mov    %eax,(%esp)
  800d14:	e8 74 fe ff ff       	call   800b8d <file_get_block>
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	78 4c                	js     800d69 <walk_path+0x18f>
			return r;
		f = (struct File*) blk;
  800d1d:	8b bd 64 ff ff ff    	mov    -0x9c(%ebp),%edi
  800d23:	bb 00 00 00 00       	mov    $0x0,%ebx
// and set *pdir to the directory the file is in.
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
  800d28:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
  800d2b:	8d 95 68 ff ff ff    	lea    -0x98(%ebp),%edx
  800d31:	89 54 24 04          	mov    %edx,0x4(%esp)
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800d35:	89 34 24             	mov    %esi,(%esp)
  800d38:	e8 cd 16 00 00       	call   80240a <strcmp>
  800d3d:	85 c0                	test   %eax,%eax
  800d3f:	0f 84 81 00 00 00    	je     800dc6 <walk_path+0x1ec>
  800d45:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800d4b:	81 fb 00 10 00 00    	cmp    $0x1000,%ebx
  800d51:	75 d5                	jne    800d28 <walk_path+0x14e>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800d53:	ff 85 54 ff ff ff    	incl   -0xac(%ebp)
  800d59:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800d5f:	39 85 48 ff ff ff    	cmp    %eax,-0xb8(%ebp)
  800d65:	75 90                	jne    800cf7 <walk_path+0x11d>
  800d67:	eb 09                	jmp    800d72 <walk_path+0x198>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800d69:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800d6c:	0f 85 a8 00 00 00    	jne    800e1a <walk_path+0x240>
  800d72:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800d78:	80 38 00             	cmpb   $0x0,(%eax)
  800d7b:	0f 85 94 00 00 00    	jne    800e15 <walk_path+0x23b>
				if (pdir)
  800d81:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800d88:	74 0e                	je     800d98 <walk_path+0x1be>
					*pdir = dir;
  800d8a:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800d90:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800d96:	89 02                	mov    %eax,(%edx)
				if (lastelem)
  800d98:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800d9c:	74 15                	je     800db3 <walk_path+0x1d9>
					strcpy(lastelem, name);
  800d9e:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800da4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800da8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dab:	89 14 24             	mov    %edx,(%esp)
  800dae:	e8 b0 15 00 00       	call   802363 <strcpy>
				*pf = 0;
  800db3:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800db9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800dbf:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800dc4:	eb 54                	jmp    800e1a <walk_path+0x240>
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800dc6:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800dcc:	89 b5 50 ff ff ff    	mov    %esi,-0xb0(%ebp)
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800dd2:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  800dd8:	80 3a 00             	cmpb   $0x0,(%edx)
  800ddb:	0f 85 5f fe ff ff    	jne    800c40 <walk_path+0x66>
			}
			return r;
		}
	}

	if (pdir)
  800de1:	83 bd 44 ff ff ff 00 	cmpl   $0x0,-0xbc(%ebp)
  800de8:	74 08                	je     800df2 <walk_path+0x218>
		*pdir = dir;
  800dea:	8b 95 44 ff ff ff    	mov    -0xbc(%ebp),%edx
  800df0:	89 02                	mov    %eax,(%edx)
	*pf = f;
  800df2:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800df8:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800dfe:	89 10                	mov    %edx,(%eax)
	return 0;
  800e00:	b8 00 00 00 00       	mov    $0x0,%eax
  800e05:	eb 13                	jmp    800e1a <walk_path+0x240>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800e07:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800e0c:	eb 0c                	jmp    800e1a <walk_path+0x240>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800e0e:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800e13:	eb 05                	jmp    800e1a <walk_path+0x240>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800e15:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800e1a:	81 c4 cc 00 00 00    	add    $0xcc,%esp
  800e20:	5b                   	pop    %ebx
  800e21:	5e                   	pop    %esi
  800e22:	5f                   	pop    %edi
  800e23:	5d                   	pop    %ebp
  800e24:	c3                   	ret    

00800e25 <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  800e2b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3d:	e8 98 fd ff ff       	call   800bda <walk_path>
}
  800e42:	c9                   	leave  
  800e43:	c3                   	ret    

00800e44 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	57                   	push   %edi
  800e48:	56                   	push   %esi
  800e49:	53                   	push   %ebx
  800e4a:	83 ec 3c             	sub    $0x3c,%esp
  800e4d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e50:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e53:	8b 45 14             	mov    0x14(%ebp),%eax
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800e56:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e59:	8b 93 80 00 00 00    	mov    0x80(%ebx),%edx
  800e5f:	39 c2                	cmp    %eax,%edx
  800e61:	0f 8e 8a 00 00 00    	jle    800ef1 <file_read+0xad>
		return 0;

	count = MIN(count, f->f_size - offset);
  800e67:	29 c2                	sub    %eax,%edx
  800e69:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800e6c:	39 ca                	cmp    %ecx,%edx
  800e6e:	76 03                	jbe    800e73 <file_read+0x2f>
  800e70:	89 4d d0             	mov    %ecx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800e73:	89 c3                	mov    %eax,%ebx
  800e75:	03 45 d0             	add    -0x30(%ebp),%eax
  800e78:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800e7b:	eb 68                	jmp    800ee5 <file_read+0xa1>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800e7d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800e80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e84:	89 d8                	mov    %ebx,%eax
  800e86:	85 db                	test   %ebx,%ebx
  800e88:	79 06                	jns    800e90 <file_read+0x4c>
  800e8a:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  800e90:	c1 f8 0c             	sar    $0xc,%eax
  800e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	89 04 24             	mov    %eax,(%esp)
  800e9d:	e8 eb fc ff ff       	call   800b8d <file_get_block>
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	78 50                	js     800ef6 <file_read+0xb2>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800ea6:	89 d8                	mov    %ebx,%eax
  800ea8:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  800ead:	79 07                	jns    800eb6 <file_read+0x72>
  800eaf:	48                   	dec    %eax
  800eb0:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  800eb5:	40                   	inc    %eax
  800eb6:	89 c2                	mov    %eax,%edx
  800eb8:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800ebd:	29 c1                	sub    %eax,%ecx
  800ebf:	89 c8                	mov    %ecx,%eax
  800ec1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800ec4:	29 f1                	sub    %esi,%ecx
  800ec6:	89 c6                	mov    %eax,%esi
  800ec8:	39 c8                	cmp    %ecx,%eax
  800eca:	76 02                	jbe    800ece <file_read+0x8a>
  800ecc:	89 ce                	mov    %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800ece:	89 74 24 08          	mov    %esi,0x8(%esp)
  800ed2:	03 55 e4             	add    -0x1c(%ebp),%edx
  800ed5:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ed9:	89 3c 24             	mov    %edi,(%esp)
  800edc:	e8 fb 15 00 00       	call   8024dc <memmove>
		pos += bn;
  800ee1:	01 f3                	add    %esi,%ebx
		buf += bn;
  800ee3:	01 f7                	add    %esi,%edi
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800ee5:	89 de                	mov    %ebx,%esi
  800ee7:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800eea:	72 91                	jb     800e7d <file_read+0x39>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800eec:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800eef:	eb 05                	jmp    800ef6 <file_read+0xb2>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800ef6:	83 c4 3c             	add    $0x3c,%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 3c             	sub    $0x3c,%esp
  800f07:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800f0a:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f10:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800f13:	0f 8e 9c 00 00 00    	jle    800fb5 <file_set_size+0xb7>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800f19:	05 ff 0f 00 00       	add    $0xfff,%eax
  800f1e:	89 c7                	mov    %eax,%edi
  800f20:	85 c0                	test   %eax,%eax
  800f22:	79 06                	jns    800f2a <file_set_size+0x2c>
  800f24:	8d b8 ff 0f 00 00    	lea    0xfff(%eax),%edi
  800f2a:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f30:	05 ff 0f 00 00       	add    $0xfff,%eax
  800f35:	89 c2                	mov    %eax,%edx
  800f37:	85 c0                	test   %eax,%eax
  800f39:	79 06                	jns    800f41 <file_set_size+0x43>
  800f3b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f41:	c1 fa 0c             	sar    $0xc,%edx
  800f44:	89 55 d4             	mov    %edx,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f47:	89 d3                	mov    %edx,%ebx
  800f49:	eb 44                	jmp    800f8f <file_set_size+0x91>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800f4b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f52:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800f55:	89 da                	mov    %ebx,%edx
  800f57:	89 f0                	mov    %esi,%eax
  800f59:	e8 7c fa ff ff       	call   8009da <file_block_walk>
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	78 1c                	js     800f7e <file_set_size+0x80>
		return r;
	if (*ptr) {
  800f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f65:	8b 00                	mov    (%eax),%eax
  800f67:	85 c0                	test   %eax,%eax
  800f69:	74 23                	je     800f8e <file_set_size+0x90>
		free_block(*ptr);
  800f6b:	89 04 24             	mov    %eax,(%esp)
  800f6e:	e8 c4 f9 ff ff       	call   800937 <free_block>
		*ptr = 0;
  800f73:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800f76:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800f7c:	eb 10                	jmp    800f8e <file_set_size+0x90>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800f7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f82:	c7 04 24 5a 3e 80 00 	movl   $0x803e5a,(%esp)
  800f89:	e8 0a 0e 00 00       	call   801d98 <cprintf>
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800f8e:	43                   	inc    %ebx
  800f8f:	39 df                	cmp    %ebx,%edi
  800f91:	77 b8                	ja     800f4b <file_set_size+0x4d>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800f93:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800f97:	77 1c                	ja     800fb5 <file_set_size+0xb7>
  800f99:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	74 12                	je     800fb5 <file_set_size+0xb7>
		free_block(f->f_indirect);
  800fa3:	89 04 24             	mov    %eax,(%esp)
  800fa6:	e8 8c f9 ff ff       	call   800937 <free_block>
		f->f_indirect = 0;
  800fab:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800fb2:	00 00 00 
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800fb5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb8:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800fbe:	89 34 24             	mov    %esi,(%esp)
  800fc1:	e8 a2 f4 ff ff       	call   800468 <flush_block>
	return 0;
}
  800fc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800fcb:	83 c4 3c             	add    $0x3c,%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	57                   	push   %edi
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	83 ec 3c             	sub    $0x3c,%esp
  800fdc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800fdf:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800fe2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe5:	01 d8                	add    %ebx,%eax
  800fe7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800fea:	8b 55 08             	mov    0x8(%ebp),%edx
  800fed:	3b 82 80 00 00 00    	cmp    0x80(%edx),%eax
  800ff3:	76 7a                	jbe    80106f <file_write+0x9c>
		if ((r = file_set_size(f, offset + count)) < 0)
  800ff5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff9:	89 14 24             	mov    %edx,(%esp)
  800ffc:	e8 fd fe ff ff       	call   800efe <file_set_size>
  801001:	85 c0                	test   %eax,%eax
  801003:	79 6a                	jns    80106f <file_write+0x9c>
  801005:	eb 72                	jmp    801079 <file_write+0xa6>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  801007:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80100a:	89 54 24 08          	mov    %edx,0x8(%esp)
  80100e:	89 d8                	mov    %ebx,%eax
  801010:	85 db                	test   %ebx,%ebx
  801012:	79 06                	jns    80101a <file_write+0x47>
  801014:	8d 83 ff 0f 00 00    	lea    0xfff(%ebx),%eax
  80101a:	c1 f8 0c             	sar    $0xc,%eax
  80101d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801021:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801024:	89 0c 24             	mov    %ecx,(%esp)
  801027:	e8 61 fb ff ff       	call   800b8d <file_get_block>
  80102c:	85 c0                	test   %eax,%eax
  80102e:	78 49                	js     801079 <file_write+0xa6>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  801030:	89 d8                	mov    %ebx,%eax
  801032:	25 ff 0f 00 80       	and    $0x80000fff,%eax
  801037:	79 07                	jns    801040 <file_write+0x6d>
  801039:	48                   	dec    %eax
  80103a:	0d 00 f0 ff ff       	or     $0xfffff000,%eax
  80103f:	40                   	inc    %eax
  801040:	89 c2                	mov    %eax,%edx
  801042:	b9 00 10 00 00       	mov    $0x1000,%ecx
  801047:	29 c1                	sub    %eax,%ecx
  801049:	89 c8                	mov    %ecx,%eax
  80104b:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  80104e:	29 f1                	sub    %esi,%ecx
  801050:	89 c6                	mov    %eax,%esi
  801052:	39 c8                	cmp    %ecx,%eax
  801054:	76 02                	jbe    801058 <file_write+0x85>
  801056:	89 ce                	mov    %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  801058:	89 74 24 08          	mov    %esi,0x8(%esp)
  80105c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801060:	03 55 e4             	add    -0x1c(%ebp),%edx
  801063:	89 14 24             	mov    %edx,(%esp)
  801066:	e8 71 14 00 00       	call   8024dc <memmove>
		pos += bn;
  80106b:	01 f3                	add    %esi,%ebx
		buf += bn;
  80106d:	01 f7                	add    %esi,%edi
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  80106f:	89 de                	mov    %ebx,%esi
  801071:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  801074:	77 91                	ja     801007 <file_write+0x34>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  801076:	8b 45 10             	mov    0x10(%ebp),%eax
}
  801079:	83 c4 3c             	add    $0x3c,%esp
  80107c:	5b                   	pop    %ebx
  80107d:	5e                   	pop    %esi
  80107e:	5f                   	pop    %edi
  80107f:	5d                   	pop    %ebp
  801080:	c3                   	ret    

00801081 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 20             	sub    $0x20,%esp
  801089:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  80108c:	be 00 00 00 00       	mov    $0x0,%esi
  801091:	eb 35                	jmp    8010c8 <file_flush+0x47>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  801093:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80109a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  80109d:	89 f2                	mov    %esi,%edx
  80109f:	89 d8                	mov    %ebx,%eax
  8010a1:	e8 34 f9 ff ff       	call   8009da <file_block_walk>
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	78 1d                	js     8010c7 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  8010aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  8010ad:	85 c0                	test   %eax,%eax
  8010af:	74 16                	je     8010c7 <file_flush+0x46>
		    pdiskbno == NULL || *pdiskbno == 0)
  8010b1:	8b 00                	mov    (%eax),%eax
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	74 10                	je     8010c7 <file_flush+0x46>
			continue;
		flush_block(diskaddr(*pdiskbno));
  8010b7:	89 04 24             	mov    %eax,(%esp)
  8010ba:	e8 1f f3 ff ff       	call   8003de <diskaddr>
  8010bf:	89 04 24             	mov    %eax,(%esp)
  8010c2:	e8 a1 f3 ff ff       	call   800468 <flush_block>
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  8010c7:	46                   	inc    %esi
  8010c8:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  8010ce:	05 ff 0f 00 00       	add    $0xfff,%eax
  8010d3:	89 c2                	mov    %eax,%edx
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	79 06                	jns    8010df <file_flush+0x5e>
  8010d9:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  8010df:	c1 fa 0c             	sar    $0xc,%edx
  8010e2:	39 d6                	cmp    %edx,%esi
  8010e4:	7c ad                	jl     801093 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  8010e6:	89 1c 24             	mov    %ebx,(%esp)
  8010e9:	e8 7a f3 ff ff       	call   800468 <flush_block>
	if (f->f_indirect)
  8010ee:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  8010f4:	85 c0                	test   %eax,%eax
  8010f6:	74 10                	je     801108 <file_flush+0x87>
		flush_block(diskaddr(f->f_indirect));
  8010f8:	89 04 24             	mov    %eax,(%esp)
  8010fb:	e8 de f2 ff ff       	call   8003de <diskaddr>
  801100:	89 04 24             	mov    %eax,(%esp)
  801103:	e8 60 f3 ff ff       	call   800468 <flush_block>
}
  801108:	83 c4 20             	add    $0x20,%esp
  80110b:	5b                   	pop    %ebx
  80110c:	5e                   	pop    %esi
  80110d:	5d                   	pop    %ebp
  80110e:	c3                   	ret    

0080110f <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	81 ec bc 00 00 00    	sub    $0xbc,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  80111b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801121:	89 04 24             	mov    %eax,(%esp)
  801124:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  80112a:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	e8 a2 fa ff ff       	call   800bda <walk_path>
  801138:	85 c0                	test   %eax,%eax
  80113a:	0f 84 dc 00 00 00    	je     80121c <file_create+0x10d>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  801140:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801143:	0f 85 d8 00 00 00    	jne    801221 <file_create+0x112>
  801149:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  80114f:	85 db                	test   %ebx,%ebx
  801151:	0f 84 ca 00 00 00    	je     801221 <file_create+0x112>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  801157:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  80115d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  801162:	74 24                	je     801188 <file_create+0x79>
  801164:	c7 44 24 0c 3d 3e 80 	movl   $0x803e3d,0xc(%esp)
  80116b:	00 
  80116c:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801173:	00 
  801174:	c7 44 24 04 f2 00 00 	movl   $0xf2,0x4(%esp)
  80117b:	00 
  80117c:	c7 04 24 a5 3d 80 00 	movl   $0x803da5,(%esp)
  801183:	e8 18 0b 00 00       	call   801ca0 <_panic>
	nblock = dir->f_size / BLKSIZE;
  801188:	89 c2                	mov    %eax,%edx
  80118a:	85 c0                	test   %eax,%eax
  80118c:	79 06                	jns    801194 <file_create+0x85>
  80118e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  801194:	c1 fa 0c             	sar    $0xc,%edx
  801197:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  80119d:	be 00 00 00 00       	mov    $0x0,%esi
		if ((r = file_get_block(dir, i, &blk)) < 0)
  8011a2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8011a8:	eb 38                	jmp    8011e2 <file_create+0xd3>
  8011aa:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8011ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b2:	89 1c 24             	mov    %ebx,(%esp)
  8011b5:	e8 d3 f9 ff ff       	call   800b8d <file_get_block>
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 63                	js     801221 <file_create+0x112>
  8011be:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8011c4:	ba 00 00 00 00       	mov    $0x0,%edx
			if (f[j].f_name[0] == '\0') {
  8011c9:	80 38 00             	cmpb   $0x0,(%eax)
  8011cc:	75 08                	jne    8011d6 <file_create+0xc7>
				*file = &f[j];
  8011ce:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  8011d4:	eb 56                	jmp    80122c <file_create+0x11d>
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  8011d6:	42                   	inc    %edx
  8011d7:	05 00 01 00 00       	add    $0x100,%eax
  8011dc:	83 fa 10             	cmp    $0x10,%edx
  8011df:	75 e8                	jne    8011c9 <file_create+0xba>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  8011e1:	46                   	inc    %esi
  8011e2:	39 b5 54 ff ff ff    	cmp    %esi,-0xac(%ebp)
  8011e8:	75 c0                	jne    8011aa <file_create+0x9b>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  8011ea:	81 83 80 00 00 00 00 	addl   $0x1000,0x80(%ebx)
  8011f1:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  8011f4:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  8011fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  801202:	89 1c 24             	mov    %ebx,(%esp)
  801205:	e8 83 f9 ff ff       	call   800b8d <file_get_block>
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 13                	js     801221 <file_create+0x112>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  80120e:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  801214:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  80121a:	eb 10                	jmp    80122c <file_create+0x11d>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  80121c:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  801221:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  801227:	5b                   	pop    %ebx
  801228:	5e                   	pop    %esi
  801229:	5f                   	pop    %edi
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  80122c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
  80123c:	89 04 24             	mov    %eax,(%esp)
  80123f:	e8 1f 11 00 00       	call   802363 <strcpy>
	*pf = f;
  801244:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  80124a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124d:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  80124f:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
  801255:	89 04 24             	mov    %eax,(%esp)
  801258:	e8 24 fe ff ff       	call   801081 <file_flush>
	return 0;
  80125d:	b8 00 00 00 00       	mov    $0x0,%eax
  801262:	eb bd                	jmp    801221 <file_create+0x112>

00801264 <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	53                   	push   %ebx
  801268:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80126b:	bb 01 00 00 00       	mov    $0x1,%ebx
  801270:	eb 11                	jmp    801283 <fs_sync+0x1f>
		flush_block(diskaddr(i));
  801272:	89 1c 24             	mov    %ebx,(%esp)
  801275:	e8 64 f1 ff ff       	call   8003de <diskaddr>
  80127a:	89 04 24             	mov    %eax,(%esp)
  80127d:	e8 e6 f1 ff ff       	call   800468 <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801282:	43                   	inc    %ebx
  801283:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801288:	3b 58 04             	cmp    0x4(%eax),%ebx
  80128b:	72 e5                	jb     801272 <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80128d:	83 c4 14             	add    $0x14,%esp
  801290:	5b                   	pop    %ebx
  801291:	5d                   	pop    %ebp
  801292:	c3                   	ret    
	...

00801294 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  801294:	55                   	push   %ebp
  801295:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  801297:	b8 00 00 00 00       	mov    $0x0,%eax
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  8012a4:	e8 bb ff ff ff       	call   801264 <fs_sync>
	return 0;
}
  8012a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ae:	c9                   	leave  
  8012af:	c3                   	ret    

008012b0 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
  8012b3:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  8012b6:	c7 44 24 08 77 3e 80 	movl   $0x803e77,0x8(%esp)
  8012bd:	00 
  8012be:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  8012c5:	00 
  8012c6:	c7 04 24 93 3e 80 00 	movl   $0x803e93,(%esp)
  8012cd:	e8 ce 09 00 00       	call   801ca0 <_panic>

008012d2 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8012d5:	ba 60 50 80 00       	mov    $0x805060,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  8012da:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  8012df:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  8012e4:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  8012e6:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  8012e9:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  8012ef:	40                   	inc    %eax
  8012f0:	83 c2 10             	add    $0x10,%edx
  8012f3:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012f8:	75 ea                	jne    8012e4 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
  801301:	83 ec 10             	sub    $0x10,%esp
  801304:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801307:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  80130c:	89 d8                	mov    %ebx,%eax
  80130e:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  801311:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  801317:	89 04 24             	mov    %eax,(%esp)
  80131a:	e8 dd 20 00 00       	call   8033fc <pageref>
  80131f:	85 c0                	test   %eax,%eax
  801321:	74 07                	je     80132a <openfile_alloc+0x2e>
  801323:	83 f8 01             	cmp    $0x1,%eax
  801326:	75 62                	jne    80138a <openfile_alloc+0x8e>
  801328:	eb 27                	jmp    801351 <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  80132a:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801331:	00 
  801332:	89 d8                	mov    %ebx,%eax
  801334:	c1 e0 04             	shl    $0x4,%eax
  801337:	8b 80 6c 50 80 00    	mov    0x80506c(%eax),%eax
  80133d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801341:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801348:	e8 08 14 00 00       	call   802755 <sys_page_alloc>
  80134d:	85 c0                	test   %eax,%eax
  80134f:	78 4b                	js     80139c <openfile_alloc+0xa0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  801351:	c1 e3 04             	shl    $0x4,%ebx
  801354:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  80135a:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  801361:	04 00 00 
			*o = &opentab[i];
  801364:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  801366:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80136d:	00 
  80136e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801375:	00 
  801376:	8b 83 6c 50 80 00    	mov    0x80506c(%ebx),%eax
  80137c:	89 04 24             	mov    %eax,(%esp)
  80137f:	e8 0e 11 00 00       	call   802492 <memset>
			return (*o)->o_fileid;
  801384:	8b 06                	mov    (%esi),%eax
  801386:	8b 00                	mov    (%eax),%eax
  801388:	eb 12                	jmp    80139c <openfile_alloc+0xa0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  80138a:	43                   	inc    %ebx
  80138b:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801391:	0f 85 75 ff ff ff    	jne    80130c <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801397:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	5b                   	pop    %ebx
  8013a0:	5e                   	pop    %esi
  8013a1:	5d                   	pop    %ebp
  8013a2:	c3                   	ret    

008013a3 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	57                   	push   %edi
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 1c             	sub    $0x1c,%esp
  8013ac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  8013af:	89 fe                	mov    %edi,%esi
  8013b1:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8013b7:	c1 e6 04             	shl    $0x4,%esi
  8013ba:	8d 9e 60 50 80 00    	lea    0x805060(%esi),%ebx
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  8013c0:	8b 86 6c 50 80 00    	mov    0x80506c(%esi),%eax
  8013c6:	89 04 24             	mov    %eax,(%esp)
  8013c9:	e8 2e 20 00 00       	call   8033fc <pageref>
  8013ce:	83 f8 01             	cmp    $0x1,%eax
  8013d1:	7e 14                	jle    8013e7 <openfile_lookup+0x44>
  8013d3:	39 be 60 50 80 00    	cmp    %edi,0x805060(%esi)
  8013d9:	75 13                	jne    8013ee <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  8013db:	8b 45 10             	mov    0x10(%ebp),%eax
  8013de:	89 18                	mov    %ebx,(%eax)
	return 0;
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e5:	eb 0c                	jmp    8013f3 <openfile_lookup+0x50>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  8013e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013ec:	eb 05                	jmp    8013f3 <openfile_lookup+0x50>
  8013ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  8013f3:	83 c4 1c             	add    $0x1c,%esp
  8013f6:	5b                   	pop    %ebx
  8013f7:	5e                   	pop    %esi
  8013f8:	5f                   	pop    %edi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    

008013fb <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801401:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801404:	89 44 24 08          	mov    %eax,0x8(%esp)
  801408:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140b:	8b 00                	mov    (%eax),%eax
  80140d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801411:	8b 45 08             	mov    0x8(%ebp),%eax
  801414:	89 04 24             	mov    %eax,(%esp)
  801417:	e8 87 ff ff ff       	call   8013a3 <openfile_lookup>
  80141c:	85 c0                	test   %eax,%eax
  80141e:	78 13                	js     801433 <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  801420:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801423:	8b 40 04             	mov    0x4(%eax),%eax
  801426:	89 04 24             	mov    %eax,(%esp)
  801429:	e8 53 fc ff ff       	call   801081 <file_flush>
	return 0;
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	53                   	push   %ebx
  801439:	83 ec 24             	sub    $0x24,%esp
  80143c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80143f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801442:	89 44 24 08          	mov    %eax,0x8(%esp)
  801446:	8b 03                	mov    (%ebx),%eax
  801448:	89 44 24 04          	mov    %eax,0x4(%esp)
  80144c:	8b 45 08             	mov    0x8(%ebp),%eax
  80144f:	89 04 24             	mov    %eax,(%esp)
  801452:	e8 4c ff ff ff       	call   8013a3 <openfile_lookup>
  801457:	85 c0                	test   %eax,%eax
  801459:	78 3f                	js     80149a <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80145b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145e:	8b 40 04             	mov    0x4(%eax),%eax
  801461:	89 44 24 04          	mov    %eax,0x4(%esp)
  801465:	89 1c 24             	mov    %ebx,(%esp)
  801468:	e8 f6 0e 00 00       	call   802363 <strcpy>
	ret->ret_size = o->o_file->f_size;
  80146d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801470:	8b 50 04             	mov    0x4(%eax),%edx
  801473:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  801479:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  80147f:	8b 40 04             	mov    0x4(%eax),%eax
  801482:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  801489:	0f 94 c0             	sete   %al
  80148c:	0f b6 c0             	movzbl %al,%eax
  80148f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801495:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149a:	83 c4 24             	add    $0x24,%esp
  80149d:	5b                   	pop    %ebx
  80149e:	5d                   	pop    %ebp
  80149f:	c3                   	ret    

008014a0 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  8014a0:	55                   	push   %ebp
  8014a1:	89 e5                	mov    %esp,%ebp
  8014a3:	53                   	push   %ebx
  8014a4:	83 ec 24             	sub    $0x24,%esp
  8014a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014b1:	8b 03                	mov    (%ebx),%eax
  8014b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ba:	89 04 24             	mov    %eax,(%esp)
  8014bd:	e8 e1 fe ff ff       	call   8013a3 <openfile_lookup>
  8014c2:	85 c0                	test   %eax,%eax
  8014c4:	78 15                	js     8014db <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8014c6:	8b 43 04             	mov    0x4(%ebx),%eax
  8014c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d0:	8b 40 04             	mov    0x4(%eax),%eax
  8014d3:	89 04 24             	mov    %eax,(%esp)
  8014d6:	e8 23 fa ff ff       	call   800efe <file_set_size>
}
  8014db:	83 c4 24             	add    $0x24,%esp
  8014de:	5b                   	pop    %ebx
  8014df:	5d                   	pop    %ebp
  8014e0:	c3                   	ret    

008014e1 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	53                   	push   %ebx
  8014e5:	81 ec 24 04 00 00    	sub    $0x424,%esp
  8014eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  8014ee:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  8014f5:	00 
  8014f6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8014fa:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801500:	89 04 24             	mov    %eax,(%esp)
  801503:	e8 d4 0f 00 00       	call   8024dc <memmove>
	path[MAXPATHLEN-1] = 0;
  801508:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80150c:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801512:	89 04 24             	mov    %eax,(%esp)
  801515:	e8 e2 fd ff ff       	call   8012fc <openfile_alloc>
  80151a:	85 c0                	test   %eax,%eax
  80151c:	0f 88 f0 00 00 00    	js     801612 <serve_open+0x131>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801522:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  801529:	74 32                	je     80155d <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  80152b:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801531:	89 44 24 04          	mov    %eax,0x4(%esp)
  801535:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80153b:	89 04 24             	mov    %eax,(%esp)
  80153e:	e8 cc fb ff ff       	call   80110f <file_create>
  801543:	85 c0                	test   %eax,%eax
  801545:	79 36                	jns    80157d <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  801547:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  80154e:	0f 85 be 00 00 00    	jne    801612 <serve_open+0x131>
  801554:	83 f8 f3             	cmp    $0xfffffff3,%eax
  801557:	0f 85 b5 00 00 00    	jne    801612 <serve_open+0x131>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  80155d:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801563:	89 44 24 04          	mov    %eax,0x4(%esp)
  801567:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80156d:	89 04 24             	mov    %eax,(%esp)
  801570:	e8 b0 f8 ff ff       	call   800e25 <file_open>
  801575:	85 c0                	test   %eax,%eax
  801577:	0f 88 95 00 00 00    	js     801612 <serve_open+0x131>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  80157d:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  801584:	74 1a                	je     8015a0 <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  801586:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80158d:	00 
  80158e:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  801594:	89 04 24             	mov    %eax,(%esp)
  801597:	e8 62 f9 ff ff       	call   800efe <file_set_size>
  80159c:	85 c0                	test   %eax,%eax
  80159e:	78 72                	js     801612 <serve_open+0x131>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8015a0:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8015a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015aa:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8015b0:	89 04 24             	mov    %eax,(%esp)
  8015b3:	e8 6d f8 ff ff       	call   800e25 <file_open>
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	78 56                	js     801612 <serve_open+0x131>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8015bc:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015c2:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8015c8:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8015cb:	8b 50 0c             	mov    0xc(%eax),%edx
  8015ce:	8b 08                	mov    (%eax),%ecx
  8015d0:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8015d3:	8b 50 0c             	mov    0xc(%eax),%edx
  8015d6:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  8015dc:	83 e1 03             	and    $0x3,%ecx
  8015df:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  8015e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e5:	8b 15 64 90 80 00    	mov    0x809064,%edx
  8015eb:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  8015ed:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8015f3:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8015f9:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  8015fc:	8b 50 0c             	mov    0xc(%eax),%edx
  8015ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801602:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801604:	8b 45 14             	mov    0x14(%ebp),%eax
  801607:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80160d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801612:	81 c4 24 04 00 00    	add    $0x424,%esp
  801618:	5b                   	pop    %ebx
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801623:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801626:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801629:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801630:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801634:	a1 44 50 80 00       	mov    0x805044,%eax
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	89 34 24             	mov    %esi,(%esp)
  801640:	e8 3f 14 00 00       	call   802a84 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801645:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801649:	75 15                	jne    801660 <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  80164b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801652:	c7 04 24 c0 3e 80 00 	movl   $0x803ec0,(%esp)
  801659:	e8 3a 07 00 00       	call   801d98 <cprintf>
				whom);
			continue; // just leave it hanging...
  80165e:	eb c9                	jmp    801629 <serve+0xe>
		}

		pg = NULL;
  801660:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  801667:	83 f8 01             	cmp    $0x1,%eax
  80166a:	75 21                	jne    80168d <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  80166c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801670:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801673:	89 44 24 08          	mov    %eax,0x8(%esp)
  801677:	a1 44 50 80 00       	mov    0x805044,%eax
  80167c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801680:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801683:	89 04 24             	mov    %eax,(%esp)
  801686:	e8 56 fe ff ff       	call   8014e1 <serve_open>
  80168b:	eb 3f                	jmp    8016cc <serve+0xb1>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  80168d:	83 f8 08             	cmp    $0x8,%eax
  801690:	77 1e                	ja     8016b0 <serve+0x95>
  801692:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  801699:	85 d2                	test   %edx,%edx
  80169b:	74 13                	je     8016b0 <serve+0x95>
			r = handlers[req](whom, fsreq);
  80169d:	a1 44 50 80 00       	mov    0x805044,%eax
  8016a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a9:	89 04 24             	mov    %eax,(%esp)
  8016ac:	ff d2                	call   *%edx
  8016ae:	eb 1c                	jmp    8016cc <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8016b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016b3:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bb:	c7 04 24 f0 3e 80 00 	movl   $0x803ef0,(%esp)
  8016c2:	e8 d1 06 00 00       	call   801d98 <cprintf>
			r = -E_INVAL;
  8016c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8016cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016cf:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8016d3:	8b 55 ec             	mov    -0x14(%ebp),%edx
  8016d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  8016da:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e1:	89 04 24             	mov    %eax,(%esp)
  8016e4:	e8 02 14 00 00       	call   802aeb <ipc_send>
		sys_page_unmap(0, fsreq);
  8016e9:	a1 44 50 80 00       	mov    0x805044,%eax
  8016ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016f2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f9:	e8 fe 10 00 00       	call   8027fc <sys_page_unmap>
  8016fe:	e9 26 ff ff ff       	jmp    801629 <serve+0xe>

00801703 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801703:	55                   	push   %ebp
  801704:	89 e5                	mov    %esp,%ebp
  801706:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801709:	c7 05 60 90 80 00 9d 	movl   $0x803e9d,0x809060
  801710:	3e 80 00 
	cprintf("FS is running\n");
  801713:	c7 04 24 a0 3e 80 00 	movl   $0x803ea0,(%esp)
  80171a:	e8 79 06 00 00       	call   801d98 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80171f:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801724:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801729:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80172b:	c7 04 24 af 3e 80 00 	movl   $0x803eaf,(%esp)
  801732:	e8 61 06 00 00       	call   801d98 <cprintf>

	serve_init();
  801737:	e8 96 fb ff ff       	call   8012d2 <serve_init>
	fs_init();
  80173c:	e8 f0 f3 ff ff       	call   800b31 <fs_init>
        fs_test();
  801741:	e8 06 00 00 00       	call   80174c <fs_test>
	serve();
  801746:	e8 d0 fe ff ff       	call   80161b <serve>
	...

0080174c <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801753:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80175a:	00 
  80175b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  801762:	00 
  801763:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80176a:	e8 e6 0f 00 00       	call   802755 <sys_page_alloc>
  80176f:	85 c0                	test   %eax,%eax
  801771:	79 20                	jns    801793 <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  801773:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801777:	c7 44 24 08 13 3f 80 	movl   $0x803f13,0x8(%esp)
  80177e:	00 
  80177f:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  801786:	00 
  801787:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  80178e:	e8 0d 05 00 00       	call   801ca0 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801793:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80179a:	00 
  80179b:	a1 04 a0 80 00       	mov    0x80a004,%eax
  8017a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017a4:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8017ab:	e8 2c 0d 00 00       	call   8024dc <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8017b0:	e8 c4 f1 ff ff       	call   800979 <alloc_block>
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	79 20                	jns    8017d9 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8017b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017bd:	c7 44 24 08 30 3f 80 	movl   $0x803f30,0x8(%esp)
  8017c4:	00 
  8017c5:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8017cc:	00 
  8017cd:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  8017d4:	e8 c7 04 00 00       	call   801ca0 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8017d9:	89 c2                	mov    %eax,%edx
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	79 03                	jns    8017e2 <fs_test+0x96>
  8017df:	8d 50 1f             	lea    0x1f(%eax),%edx
  8017e2:	c1 fa 05             	sar    $0x5,%edx
  8017e5:	c1 e2 02             	shl    $0x2,%edx
  8017e8:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8017ed:	79 05                	jns    8017f4 <fs_test+0xa8>
  8017ef:	48                   	dec    %eax
  8017f0:	83 c8 e0             	or     $0xffffffe0,%eax
  8017f3:	40                   	inc    %eax
  8017f4:	bb 01 00 00 00       	mov    $0x1,%ebx
  8017f9:	88 c1                	mov    %al,%cl
  8017fb:	d3 e3                	shl    %cl,%ebx
  8017fd:	85 9a 00 10 00 00    	test   %ebx,0x1000(%edx)
  801803:	75 24                	jne    801829 <fs_test+0xdd>
  801805:	c7 44 24 0c 40 3f 80 	movl   $0x803f40,0xc(%esp)
  80180c:	00 
  80180d:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801814:	00 
  801815:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  80181c:	00 
  80181d:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801824:	e8 77 04 00 00       	call   801ca0 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801829:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  80182f:	85 1c 11             	test   %ebx,(%ecx,%edx,1)
  801832:	74 24                	je     801858 <fs_test+0x10c>
  801834:	c7 44 24 0c b8 40 80 	movl   $0x8040b8,0xc(%esp)
  80183b:	00 
  80183c:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801843:	00 
  801844:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  80184b:	00 
  80184c:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801853:	e8 48 04 00 00       	call   801ca0 <_panic>
	cprintf("alloc_block is good\n");
  801858:	c7 04 24 5b 3f 80 00 	movl   $0x803f5b,(%esp)
  80185f:	e8 34 05 00 00       	call   801d98 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801864:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80186b:	c7 04 24 70 3f 80 00 	movl   $0x803f70,(%esp)
  801872:	e8 ae f5 ff ff       	call   800e25 <file_open>
  801877:	85 c0                	test   %eax,%eax
  801879:	79 25                	jns    8018a0 <fs_test+0x154>
  80187b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80187e:	74 40                	je     8018c0 <fs_test+0x174>
		panic("file_open /not-found: %e", r);
  801880:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801884:	c7 44 24 08 7b 3f 80 	movl   $0x803f7b,0x8(%esp)
  80188b:	00 
  80188c:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  801893:	00 
  801894:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  80189b:	e8 00 04 00 00       	call   801ca0 <_panic>
	else if (r == 0)
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	75 1c                	jne    8018c0 <fs_test+0x174>
		panic("file_open /not-found succeeded!");
  8018a4:	c7 44 24 08 d8 40 80 	movl   $0x8040d8,0x8(%esp)
  8018ab:	00 
  8018ac:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8018b3:	00 
  8018b4:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  8018bb:	e8 e0 03 00 00       	call   801ca0 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8018c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018c3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018c7:	c7 04 24 94 3f 80 00 	movl   $0x803f94,(%esp)
  8018ce:	e8 52 f5 ff ff       	call   800e25 <file_open>
  8018d3:	85 c0                	test   %eax,%eax
  8018d5:	79 20                	jns    8018f7 <fs_test+0x1ab>
		panic("file_open /newmotd: %e", r);
  8018d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8018db:	c7 44 24 08 9d 3f 80 	movl   $0x803f9d,0x8(%esp)
  8018e2:	00 
  8018e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8018ea:	00 
  8018eb:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  8018f2:	e8 a9 03 00 00       	call   801ca0 <_panic>
	cprintf("file_open is good\n");
  8018f7:	c7 04 24 b4 3f 80 00 	movl   $0x803fb4,(%esp)
  8018fe:	e8 95 04 00 00       	call   801d98 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  801903:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801906:	89 44 24 08          	mov    %eax,0x8(%esp)
  80190a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801911:	00 
  801912:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801915:	89 04 24             	mov    %eax,(%esp)
  801918:	e8 70 f2 ff ff       	call   800b8d <file_get_block>
  80191d:	85 c0                	test   %eax,%eax
  80191f:	79 20                	jns    801941 <fs_test+0x1f5>
		panic("file_get_block: %e", r);
  801921:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801925:	c7 44 24 08 c7 3f 80 	movl   $0x803fc7,0x8(%esp)
  80192c:	00 
  80192d:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  801934:	00 
  801935:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  80193c:	e8 5f 03 00 00       	call   801ca0 <_panic>
	if (strcmp(blk, msg) != 0)
  801941:	c7 44 24 04 f8 40 80 	movl   $0x8040f8,0x4(%esp)
  801948:	00 
  801949:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194c:	89 04 24             	mov    %eax,(%esp)
  80194f:	e8 b6 0a 00 00       	call   80240a <strcmp>
  801954:	85 c0                	test   %eax,%eax
  801956:	74 1c                	je     801974 <fs_test+0x228>
		panic("file_get_block returned wrong data");
  801958:	c7 44 24 08 20 41 80 	movl   $0x804120,0x8(%esp)
  80195f:	00 
  801960:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  801967:	00 
  801968:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  80196f:	e8 2c 03 00 00       	call   801ca0 <_panic>
	cprintf("file_get_block is good\n");
  801974:	c7 04 24 da 3f 80 00 	movl   $0x803fda,(%esp)
  80197b:	e8 18 04 00 00       	call   801d98 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801980:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801983:	8a 10                	mov    (%eax),%dl
  801985:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80198a:	c1 e8 0c             	shr    $0xc,%eax
  80198d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801994:	a8 40                	test   $0x40,%al
  801996:	75 24                	jne    8019bc <fs_test+0x270>
  801998:	c7 44 24 0c f3 3f 80 	movl   $0x803ff3,0xc(%esp)
  80199f:	00 
  8019a0:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  8019a7:	00 
  8019a8:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8019af:	00 
  8019b0:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  8019b7:	e8 e4 02 00 00       	call   801ca0 <_panic>
	file_flush(f);
  8019bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bf:	89 04 24             	mov    %eax,(%esp)
  8019c2:	e8 ba f6 ff ff       	call   801081 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8019c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ca:	c1 e8 0c             	shr    $0xc,%eax
  8019cd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8019d4:	a8 40                	test   $0x40,%al
  8019d6:	74 24                	je     8019fc <fs_test+0x2b0>
  8019d8:	c7 44 24 0c f2 3f 80 	movl   $0x803ff2,0xc(%esp)
  8019df:	00 
  8019e0:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  8019e7:	00 
  8019e8:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  8019ef:	00 
  8019f0:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  8019f7:	e8 a4 02 00 00       	call   801ca0 <_panic>
	cprintf("file_flush is good\n");
  8019fc:	c7 04 24 0e 40 80 00 	movl   $0x80400e,(%esp)
  801a03:	e8 90 03 00 00       	call   801d98 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801a08:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801a0f:	00 
  801a10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a13:	89 04 24             	mov    %eax,(%esp)
  801a16:	e8 e3 f4 ff ff       	call   800efe <file_set_size>
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	79 20                	jns    801a3f <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  801a1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a23:	c7 44 24 08 22 40 80 	movl   $0x804022,0x8(%esp)
  801a2a:	00 
  801a2b:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  801a32:	00 
  801a33:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801a3a:	e8 61 02 00 00       	call   801ca0 <_panic>
	assert(f->f_direct[0] == 0);
  801a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a42:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801a49:	74 24                	je     801a6f <fs_test+0x323>
  801a4b:	c7 44 24 0c 34 40 80 	movl   $0x804034,0xc(%esp)
  801a52:	00 
  801a53:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801a5a:	00 
  801a5b:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  801a62:	00 
  801a63:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801a6a:	e8 31 02 00 00       	call   801ca0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801a6f:	c1 e8 0c             	shr    $0xc,%eax
  801a72:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801a79:	a8 40                	test   $0x40,%al
  801a7b:	74 24                	je     801aa1 <fs_test+0x355>
  801a7d:	c7 44 24 0c 48 40 80 	movl   $0x804048,0xc(%esp)
  801a84:	00 
  801a85:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801a8c:	00 
  801a8d:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  801a94:	00 
  801a95:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801a9c:	e8 ff 01 00 00       	call   801ca0 <_panic>
	cprintf("file_truncate is good\n");
  801aa1:	c7 04 24 62 40 80 00 	movl   $0x804062,(%esp)
  801aa8:	e8 eb 02 00 00       	call   801d98 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801aad:	c7 04 24 f8 40 80 00 	movl   $0x8040f8,(%esp)
  801ab4:	e8 77 08 00 00       	call   802330 <strlen>
  801ab9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac0:	89 04 24             	mov    %eax,(%esp)
  801ac3:	e8 36 f4 ff ff       	call   800efe <file_set_size>
  801ac8:	85 c0                	test   %eax,%eax
  801aca:	79 20                	jns    801aec <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  801acc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ad0:	c7 44 24 08 79 40 80 	movl   $0x804079,0x8(%esp)
  801ad7:	00 
  801ad8:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  801adf:	00 
  801ae0:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801ae7:	e8 b4 01 00 00       	call   801ca0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801aec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aef:	89 c2                	mov    %eax,%edx
  801af1:	c1 ea 0c             	shr    $0xc,%edx
  801af4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801afb:	f6 c2 40             	test   $0x40,%dl
  801afe:	74 24                	je     801b24 <fs_test+0x3d8>
  801b00:	c7 44 24 0c 48 40 80 	movl   $0x804048,0xc(%esp)
  801b07:	00 
  801b08:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801b0f:	00 
  801b10:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  801b17:	00 
  801b18:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801b1f:	e8 7c 01 00 00       	call   801ca0 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801b24:	8d 55 f0             	lea    -0x10(%ebp),%edx
  801b27:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b2b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b32:	00 
  801b33:	89 04 24             	mov    %eax,(%esp)
  801b36:	e8 52 f0 ff ff       	call   800b8d <file_get_block>
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	79 20                	jns    801b5f <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801b3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801b43:	c7 44 24 08 8d 40 80 	movl   $0x80408d,0x8(%esp)
  801b4a:	00 
  801b4b:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  801b52:	00 
  801b53:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801b5a:	e8 41 01 00 00       	call   801ca0 <_panic>
	strcpy(blk, msg);
  801b5f:	c7 44 24 04 f8 40 80 	movl   $0x8040f8,0x4(%esp)
  801b66:	00 
  801b67:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b6a:	89 04 24             	mov    %eax,(%esp)
  801b6d:	e8 f1 07 00 00       	call   802363 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801b72:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b75:	c1 e8 0c             	shr    $0xc,%eax
  801b78:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801b7f:	a8 40                	test   $0x40,%al
  801b81:	75 24                	jne    801ba7 <fs_test+0x45b>
  801b83:	c7 44 24 0c f3 3f 80 	movl   $0x803ff3,0xc(%esp)
  801b8a:	00 
  801b8b:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801b92:	00 
  801b93:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  801b9a:	00 
  801b9b:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801ba2:	e8 f9 00 00 00       	call   801ca0 <_panic>
	file_flush(f);
  801ba7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801baa:	89 04 24             	mov    %eax,(%esp)
  801bad:	e8 cf f4 ff ff       	call   801081 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801bb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bb5:	c1 e8 0c             	shr    $0xc,%eax
  801bb8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bbf:	a8 40                	test   $0x40,%al
  801bc1:	74 24                	je     801be7 <fs_test+0x49b>
  801bc3:	c7 44 24 0c f2 3f 80 	movl   $0x803ff2,0xc(%esp)
  801bca:	00 
  801bcb:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801bd2:	00 
  801bd3:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  801bda:	00 
  801bdb:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801be2:	e8 b9 00 00 00       	call   801ca0 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bea:	c1 e8 0c             	shr    $0xc,%eax
  801bed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801bf4:	a8 40                	test   $0x40,%al
  801bf6:	74 24                	je     801c1c <fs_test+0x4d0>
  801bf8:	c7 44 24 0c 48 40 80 	movl   $0x804048,0xc(%esp)
  801bff:	00 
  801c00:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  801c07:	00 
  801c08:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801c0f:	00 
  801c10:	c7 04 24 26 3f 80 00 	movl   $0x803f26,(%esp)
  801c17:	e8 84 00 00 00       	call   801ca0 <_panic>
	cprintf("file rewrite is good\n");
  801c1c:	c7 04 24 a2 40 80 00 	movl   $0x8040a2,(%esp)
  801c23:	e8 70 01 00 00       	call   801d98 <cprintf>
}
  801c28:	83 c4 24             	add    $0x24,%esp
  801c2b:	5b                   	pop    %ebx
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
	...

00801c30 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	83 ec 10             	sub    $0x10,%esp
  801c38:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  801c3e:	e8 d4 0a 00 00       	call   802717 <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  801c43:	25 ff 03 00 00       	and    $0x3ff,%eax
  801c48:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801c4f:	c1 e0 07             	shl    $0x7,%eax
  801c52:	29 d0                	sub    %edx,%eax
  801c54:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c59:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801c5e:	85 f6                	test   %esi,%esi
  801c60:	7e 07                	jle    801c69 <libmain+0x39>
		binaryname = argv[0];
  801c62:	8b 03                	mov    (%ebx),%eax
  801c64:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801c69:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c6d:	89 34 24             	mov    %esi,(%esp)
  801c70:	e8 8e fa ff ff       	call   801703 <umain>

	// exit gracefully
	exit();
  801c75:	e8 0a 00 00 00       	call   801c84 <exit>
}
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5d                   	pop    %ebp
  801c80:	c3                   	ret    
  801c81:	00 00                	add    %al,(%eax)
	...

00801c84 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 18             	sub    $0x18,%esp
	close_all();
  801c8a:	e8 f4 10 00 00       	call   802d83 <close_all>
	sys_env_destroy(0);
  801c8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c96:	e8 2a 0a 00 00       	call   8026c5 <sys_env_destroy>
}
  801c9b:	c9                   	leave  
  801c9c:	c3                   	ret    
  801c9d:	00 00                	add    %al,(%eax)
	...

00801ca0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ca0:	55                   	push   %ebp
  801ca1:	89 e5                	mov    %esp,%ebp
  801ca3:	56                   	push   %esi
  801ca4:	53                   	push   %ebx
  801ca5:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  801ca8:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cab:	8b 1d 60 90 80 00    	mov    0x809060,%ebx
  801cb1:	e8 61 0a 00 00       	call   802717 <sys_getenvid>
  801cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801cbd:	8b 55 08             	mov    0x8(%ebp),%edx
  801cc0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cc4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ccc:	c7 04 24 50 41 80 00 	movl   $0x804150,(%esp)
  801cd3:	e8 c0 00 00 00       	call   801d98 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cd8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  801cdf:	89 04 24             	mov    %eax,(%esp)
  801ce2:	e8 50 00 00 00       	call   801d37 <vcprintf>
	cprintf("\n");
  801ce7:	c7 04 24 3c 3d 80 00 	movl   $0x803d3c,(%esp)
  801cee:	e8 a5 00 00 00       	call   801d98 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801cf3:	cc                   	int3   
  801cf4:	eb fd                	jmp    801cf3 <_panic+0x53>
	...

00801cf8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	53                   	push   %ebx
  801cfc:	83 ec 14             	sub    $0x14,%esp
  801cff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801d02:	8b 03                	mov    (%ebx),%eax
  801d04:	8b 55 08             	mov    0x8(%ebp),%edx
  801d07:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801d0b:	40                   	inc    %eax
  801d0c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801d0e:	3d ff 00 00 00       	cmp    $0xff,%eax
  801d13:	75 19                	jne    801d2e <putch+0x36>
		sys_cputs(b->buf, b->idx);
  801d15:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801d1c:	00 
  801d1d:	8d 43 08             	lea    0x8(%ebx),%eax
  801d20:	89 04 24             	mov    %eax,(%esp)
  801d23:	e8 60 09 00 00       	call   802688 <sys_cputs>
		b->idx = 0;
  801d28:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801d2e:	ff 43 04             	incl   0x4(%ebx)
}
  801d31:	83 c4 14             	add    $0x14,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801d40:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801d47:	00 00 00 
	b.cnt = 0;
  801d4a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801d51:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801d54:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d57:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d62:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801d68:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d6c:	c7 04 24 f8 1c 80 00 	movl   $0x801cf8,(%esp)
  801d73:	e8 82 01 00 00       	call   801efa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801d78:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801d7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d82:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801d88:	89 04 24             	mov    %eax,(%esp)
  801d8b:	e8 f8 08 00 00       	call   802688 <sys_cputs>

	return b.cnt;
}
  801d90:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801d96:	c9                   	leave  
  801d97:	c3                   	ret    

00801d98 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801d9e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801da1:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da5:	8b 45 08             	mov    0x8(%ebp),%eax
  801da8:	89 04 24             	mov    %eax,(%esp)
  801dab:	e8 87 ff ff ff       	call   801d37 <vcprintf>
	va_end(ap);

	return cnt;
}
  801db0:	c9                   	leave  
  801db1:	c3                   	ret    
	...

00801db4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801db4:	55                   	push   %ebp
  801db5:	89 e5                	mov    %esp,%ebp
  801db7:	57                   	push   %edi
  801db8:	56                   	push   %esi
  801db9:	53                   	push   %ebx
  801dba:	83 ec 3c             	sub    $0x3c,%esp
  801dbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801dc0:	89 d7                	mov    %edx,%edi
  801dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc5:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dcb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801dce:	8b 5d 14             	mov    0x14(%ebp),%ebx
  801dd1:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801dd4:	85 c0                	test   %eax,%eax
  801dd6:	75 08                	jne    801de0 <printnum+0x2c>
  801dd8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801ddb:	39 45 10             	cmp    %eax,0x10(%ebp)
  801dde:	77 57                	ja     801e37 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801de0:	89 74 24 10          	mov    %esi,0x10(%esp)
  801de4:	4b                   	dec    %ebx
  801de5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801de9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dec:	89 44 24 08          	mov    %eax,0x8(%esp)
  801df0:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  801df4:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801df8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801dff:	00 
  801e00:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801e03:	89 04 24             	mov    %eax,(%esp)
  801e06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e09:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e0d:	e8 46 1b 00 00       	call   803958 <__udivdi3>
  801e12:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e16:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801e1a:	89 04 24             	mov    %eax,(%esp)
  801e1d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e21:	89 fa                	mov    %edi,%edx
  801e23:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801e26:	e8 89 ff ff ff       	call   801db4 <printnum>
  801e2b:	eb 0f                	jmp    801e3c <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801e2d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e31:	89 34 24             	mov    %esi,(%esp)
  801e34:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801e37:	4b                   	dec    %ebx
  801e38:	85 db                	test   %ebx,%ebx
  801e3a:	7f f1                	jg     801e2d <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801e3c:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e40:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801e44:	8b 45 10             	mov    0x10(%ebp),%eax
  801e47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e4b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e52:	00 
  801e53:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801e56:	89 04 24             	mov    %eax,(%esp)
  801e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801e5c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e60:	e8 13 1c 00 00       	call   803a78 <__umoddi3>
  801e65:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e69:	0f be 80 73 41 80 00 	movsbl 0x804173(%eax),%eax
  801e70:	89 04 24             	mov    %eax,(%esp)
  801e73:	ff 55 e4             	call   *-0x1c(%ebp)
}
  801e76:	83 c4 3c             	add    $0x3c,%esp
  801e79:	5b                   	pop    %ebx
  801e7a:	5e                   	pop    %esi
  801e7b:	5f                   	pop    %edi
  801e7c:	5d                   	pop    %ebp
  801e7d:	c3                   	ret    

00801e7e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801e7e:	55                   	push   %ebp
  801e7f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801e81:	83 fa 01             	cmp    $0x1,%edx
  801e84:	7e 0e                	jle    801e94 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801e86:	8b 10                	mov    (%eax),%edx
  801e88:	8d 4a 08             	lea    0x8(%edx),%ecx
  801e8b:	89 08                	mov    %ecx,(%eax)
  801e8d:	8b 02                	mov    (%edx),%eax
  801e8f:	8b 52 04             	mov    0x4(%edx),%edx
  801e92:	eb 22                	jmp    801eb6 <getuint+0x38>
	else if (lflag)
  801e94:	85 d2                	test   %edx,%edx
  801e96:	74 10                	je     801ea8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801e98:	8b 10                	mov    (%eax),%edx
  801e9a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801e9d:	89 08                	mov    %ecx,(%eax)
  801e9f:	8b 02                	mov    (%edx),%eax
  801ea1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ea6:	eb 0e                	jmp    801eb6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801ea8:	8b 10                	mov    (%eax),%edx
  801eaa:	8d 4a 04             	lea    0x4(%edx),%ecx
  801ead:	89 08                	mov    %ecx,(%eax)
  801eaf:	8b 02                	mov    (%edx),%eax
  801eb1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    

00801eb8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801eb8:	55                   	push   %ebp
  801eb9:	89 e5                	mov    %esp,%ebp
  801ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801ebe:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  801ec1:	8b 10                	mov    (%eax),%edx
  801ec3:	3b 50 04             	cmp    0x4(%eax),%edx
  801ec6:	73 08                	jae    801ed0 <sprintputch+0x18>
		*b->buf++ = ch;
  801ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ecb:	88 0a                	mov    %cl,(%edx)
  801ecd:	42                   	inc    %edx
  801ece:	89 10                	mov    %edx,(%eax)
}
  801ed0:	5d                   	pop    %ebp
  801ed1:	c3                   	ret    

00801ed2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801ed2:	55                   	push   %ebp
  801ed3:	89 e5                	mov    %esp,%ebp
  801ed5:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  801ed8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801edb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801edf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ee2:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ee6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801eed:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef0:	89 04 24             	mov    %eax,(%esp)
  801ef3:	e8 02 00 00 00       	call   801efa <vprintfmt>
	va_end(ap);
}
  801ef8:	c9                   	leave  
  801ef9:	c3                   	ret    

00801efa <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	57                   	push   %edi
  801efe:	56                   	push   %esi
  801eff:	53                   	push   %ebx
  801f00:	83 ec 4c             	sub    $0x4c,%esp
  801f03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f06:	8b 75 10             	mov    0x10(%ebp),%esi
  801f09:	eb 12                	jmp    801f1d <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	0f 84 8b 03 00 00    	je     80229e <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  801f13:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801f17:	89 04 24             	mov    %eax,(%esp)
  801f1a:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801f1d:	0f b6 06             	movzbl (%esi),%eax
  801f20:	46                   	inc    %esi
  801f21:	83 f8 25             	cmp    $0x25,%eax
  801f24:	75 e5                	jne    801f0b <vprintfmt+0x11>
  801f26:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801f2a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801f31:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  801f36:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801f3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f42:	eb 26                	jmp    801f6a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f44:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  801f47:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801f4b:	eb 1d                	jmp    801f6a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f4d:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801f50:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  801f54:	eb 14                	jmp    801f6a <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f56:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801f59:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801f60:	eb 08                	jmp    801f6a <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  801f62:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  801f65:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f6a:	0f b6 06             	movzbl (%esi),%eax
  801f6d:	8d 56 01             	lea    0x1(%esi),%edx
  801f70:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801f73:	8a 16                	mov    (%esi),%dl
  801f75:	83 ea 23             	sub    $0x23,%edx
  801f78:	80 fa 55             	cmp    $0x55,%dl
  801f7b:	0f 87 01 03 00 00    	ja     802282 <vprintfmt+0x388>
  801f81:	0f b6 d2             	movzbl %dl,%edx
  801f84:	ff 24 95 c0 42 80 00 	jmp    *0x8042c0(,%edx,4)
  801f8b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801f8e:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801f93:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  801f96:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  801f9a:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  801f9d:	8d 50 d0             	lea    -0x30(%eax),%edx
  801fa0:	83 fa 09             	cmp    $0x9,%edx
  801fa3:	77 2a                	ja     801fcf <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801fa5:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801fa6:	eb eb                	jmp    801f93 <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801fa8:	8b 45 14             	mov    0x14(%ebp),%eax
  801fab:	8d 50 04             	lea    0x4(%eax),%edx
  801fae:	89 55 14             	mov    %edx,0x14(%ebp)
  801fb1:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fb3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801fb6:	eb 17                	jmp    801fcf <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  801fb8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801fbc:	78 98                	js     801f56 <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fbe:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801fc1:	eb a7                	jmp    801f6a <vprintfmt+0x70>
  801fc3:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801fc6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  801fcd:	eb 9b                	jmp    801f6a <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  801fcf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801fd3:	79 95                	jns    801f6a <vprintfmt+0x70>
  801fd5:	eb 8b                	jmp    801f62 <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801fd7:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801fd8:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801fdb:	eb 8d                	jmp    801f6a <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801fdd:	8b 45 14             	mov    0x14(%ebp),%eax
  801fe0:	8d 50 04             	lea    0x4(%eax),%edx
  801fe3:	89 55 14             	mov    %edx,0x14(%ebp)
  801fe6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801fea:	8b 00                	mov    (%eax),%eax
  801fec:	89 04 24             	mov    %eax,(%esp)
  801fef:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ff2:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801ff5:	e9 23 ff ff ff       	jmp    801f1d <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ffa:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffd:	8d 50 04             	lea    0x4(%eax),%edx
  802000:	89 55 14             	mov    %edx,0x14(%ebp)
  802003:	8b 00                	mov    (%eax),%eax
  802005:	85 c0                	test   %eax,%eax
  802007:	79 02                	jns    80200b <vprintfmt+0x111>
  802009:	f7 d8                	neg    %eax
  80200b:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80200d:	83 f8 0f             	cmp    $0xf,%eax
  802010:	7f 0b                	jg     80201d <vprintfmt+0x123>
  802012:	8b 04 85 20 44 80 00 	mov    0x804420(,%eax,4),%eax
  802019:	85 c0                	test   %eax,%eax
  80201b:	75 23                	jne    802040 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  80201d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802021:	c7 44 24 08 8b 41 80 	movl   $0x80418b,0x8(%esp)
  802028:	00 
  802029:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80202d:	8b 45 08             	mov    0x8(%ebp),%eax
  802030:	89 04 24             	mov    %eax,(%esp)
  802033:	e8 9a fe ff ff       	call   801ed2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802038:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80203b:	e9 dd fe ff ff       	jmp    801f1d <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  802040:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802044:	c7 44 24 08 0f 3c 80 	movl   $0x803c0f,0x8(%esp)
  80204b:	00 
  80204c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802050:	8b 55 08             	mov    0x8(%ebp),%edx
  802053:	89 14 24             	mov    %edx,(%esp)
  802056:	e8 77 fe ff ff       	call   801ed2 <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80205b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80205e:	e9 ba fe ff ff       	jmp    801f1d <vprintfmt+0x23>
  802063:	89 f9                	mov    %edi,%ecx
  802065:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802068:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80206b:	8b 45 14             	mov    0x14(%ebp),%eax
  80206e:	8d 50 04             	lea    0x4(%eax),%edx
  802071:	89 55 14             	mov    %edx,0x14(%ebp)
  802074:	8b 30                	mov    (%eax),%esi
  802076:	85 f6                	test   %esi,%esi
  802078:	75 05                	jne    80207f <vprintfmt+0x185>
				p = "(null)";
  80207a:	be 84 41 80 00       	mov    $0x804184,%esi
			if (width > 0 && padc != '-')
  80207f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  802083:	0f 8e 84 00 00 00    	jle    80210d <vprintfmt+0x213>
  802089:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  80208d:	74 7e                	je     80210d <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  80208f:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802093:	89 34 24             	mov    %esi,(%esp)
  802096:	e8 ab 02 00 00       	call   802346 <strnlen>
  80209b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80209e:	29 c2                	sub    %eax,%edx
  8020a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8020a3:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8020a7:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8020aa:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8020ad:	89 de                	mov    %ebx,%esi
  8020af:	89 d3                	mov    %edx,%ebx
  8020b1:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8020b3:	eb 0b                	jmp    8020c0 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8020b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8020b9:	89 3c 24             	mov    %edi,(%esp)
  8020bc:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8020bf:	4b                   	dec    %ebx
  8020c0:	85 db                	test   %ebx,%ebx
  8020c2:	7f f1                	jg     8020b5 <vprintfmt+0x1bb>
  8020c4:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8020c7:	89 f3                	mov    %esi,%ebx
  8020c9:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8020cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	79 05                	jns    8020d8 <vprintfmt+0x1de>
  8020d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8020db:	29 c2                	sub    %eax,%edx
  8020dd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8020e0:	eb 2b                	jmp    80210d <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8020e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8020e6:	74 18                	je     802100 <vprintfmt+0x206>
  8020e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8020eb:	83 fa 5e             	cmp    $0x5e,%edx
  8020ee:	76 10                	jbe    802100 <vprintfmt+0x206>
					putch('?', putdat);
  8020f0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8020f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8020fb:	ff 55 08             	call   *0x8(%ebp)
  8020fe:	eb 0a                	jmp    80210a <vprintfmt+0x210>
				else
					putch(ch, putdat);
  802100:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802104:	89 04 24             	mov    %eax,(%esp)
  802107:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80210a:	ff 4d e4             	decl   -0x1c(%ebp)
  80210d:	0f be 06             	movsbl (%esi),%eax
  802110:	46                   	inc    %esi
  802111:	85 c0                	test   %eax,%eax
  802113:	74 21                	je     802136 <vprintfmt+0x23c>
  802115:	85 ff                	test   %edi,%edi
  802117:	78 c9                	js     8020e2 <vprintfmt+0x1e8>
  802119:	4f                   	dec    %edi
  80211a:	79 c6                	jns    8020e2 <vprintfmt+0x1e8>
  80211c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80211f:	89 de                	mov    %ebx,%esi
  802121:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  802124:	eb 18                	jmp    80213e <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  802126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80212a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  802131:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  802133:	4b                   	dec    %ebx
  802134:	eb 08                	jmp    80213e <vprintfmt+0x244>
  802136:	8b 7d 08             	mov    0x8(%ebp),%edi
  802139:	89 de                	mov    %ebx,%esi
  80213b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80213e:	85 db                	test   %ebx,%ebx
  802140:	7f e4                	jg     802126 <vprintfmt+0x22c>
  802142:	89 7d 08             	mov    %edi,0x8(%ebp)
  802145:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  802147:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80214a:	e9 ce fd ff ff       	jmp    801f1d <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80214f:	83 f9 01             	cmp    $0x1,%ecx
  802152:	7e 10                	jle    802164 <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  802154:	8b 45 14             	mov    0x14(%ebp),%eax
  802157:	8d 50 08             	lea    0x8(%eax),%edx
  80215a:	89 55 14             	mov    %edx,0x14(%ebp)
  80215d:	8b 30                	mov    (%eax),%esi
  80215f:	8b 78 04             	mov    0x4(%eax),%edi
  802162:	eb 26                	jmp    80218a <vprintfmt+0x290>
	else if (lflag)
  802164:	85 c9                	test   %ecx,%ecx
  802166:	74 12                	je     80217a <vprintfmt+0x280>
		return va_arg(*ap, long);
  802168:	8b 45 14             	mov    0x14(%ebp),%eax
  80216b:	8d 50 04             	lea    0x4(%eax),%edx
  80216e:	89 55 14             	mov    %edx,0x14(%ebp)
  802171:	8b 30                	mov    (%eax),%esi
  802173:	89 f7                	mov    %esi,%edi
  802175:	c1 ff 1f             	sar    $0x1f,%edi
  802178:	eb 10                	jmp    80218a <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  80217a:	8b 45 14             	mov    0x14(%ebp),%eax
  80217d:	8d 50 04             	lea    0x4(%eax),%edx
  802180:	89 55 14             	mov    %edx,0x14(%ebp)
  802183:	8b 30                	mov    (%eax),%esi
  802185:	89 f7                	mov    %esi,%edi
  802187:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80218a:	85 ff                	test   %edi,%edi
  80218c:	78 0a                	js     802198 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80218e:	b8 0a 00 00 00       	mov    $0xa,%eax
  802193:	e9 ac 00 00 00       	jmp    802244 <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  802198:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80219c:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8021a3:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  8021a6:	f7 de                	neg    %esi
  8021a8:	83 d7 00             	adc    $0x0,%edi
  8021ab:	f7 df                	neg    %edi
			}
			base = 10;
  8021ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8021b2:	e9 8d 00 00 00       	jmp    802244 <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8021b7:	89 ca                	mov    %ecx,%edx
  8021b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8021bc:	e8 bd fc ff ff       	call   801e7e <getuint>
  8021c1:	89 c6                	mov    %eax,%esi
  8021c3:	89 d7                	mov    %edx,%edi
			base = 10;
  8021c5:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  8021ca:	eb 78                	jmp    802244 <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8021cc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021d0:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8021d7:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8021da:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021de:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8021e5:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  8021e8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8021ec:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8021f3:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8021f6:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8021f9:	e9 1f fd ff ff       	jmp    801f1d <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  8021fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802202:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  802209:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  80220c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802210:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  802217:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80221a:	8b 45 14             	mov    0x14(%ebp),%eax
  80221d:	8d 50 04             	lea    0x4(%eax),%edx
  802220:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  802223:	8b 30                	mov    (%eax),%esi
  802225:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80222a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80222f:	eb 13                	jmp    802244 <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  802231:	89 ca                	mov    %ecx,%edx
  802233:	8d 45 14             	lea    0x14(%ebp),%eax
  802236:	e8 43 fc ff ff       	call   801e7e <getuint>
  80223b:	89 c6                	mov    %eax,%esi
  80223d:	89 d7                	mov    %edx,%edi
			base = 16;
  80223f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  802244:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  802248:	89 54 24 10          	mov    %edx,0x10(%esp)
  80224c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80224f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802253:	89 44 24 08          	mov    %eax,0x8(%esp)
  802257:	89 34 24             	mov    %esi,(%esp)
  80225a:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80225e:	89 da                	mov    %ebx,%edx
  802260:	8b 45 08             	mov    0x8(%ebp),%eax
  802263:	e8 4c fb ff ff       	call   801db4 <printnum>
			break;
  802268:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80226b:	e9 ad fc ff ff       	jmp    801f1d <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  802270:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802274:	89 04 24             	mov    %eax,(%esp)
  802277:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80227a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80227d:	e9 9b fc ff ff       	jmp    801f1d <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  802282:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802286:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  80228d:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  802290:	eb 01                	jmp    802293 <vprintfmt+0x399>
  802292:	4e                   	dec    %esi
  802293:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  802297:	75 f9                	jne    802292 <vprintfmt+0x398>
  802299:	e9 7f fc ff ff       	jmp    801f1d <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  80229e:	83 c4 4c             	add    $0x4c,%esp
  8022a1:	5b                   	pop    %ebx
  8022a2:	5e                   	pop    %esi
  8022a3:	5f                   	pop    %edi
  8022a4:	5d                   	pop    %ebp
  8022a5:	c3                   	ret    

008022a6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8022a6:	55                   	push   %ebp
  8022a7:	89 e5                	mov    %esp,%ebp
  8022a9:	83 ec 28             	sub    $0x28,%esp
  8022ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8022af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8022b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8022b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8022b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8022bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8022c3:	85 c0                	test   %eax,%eax
  8022c5:	74 30                	je     8022f7 <vsnprintf+0x51>
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	7e 33                	jle    8022fe <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8022cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8022ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8022d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8022d5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8022dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8022e0:	c7 04 24 b8 1e 80 00 	movl   $0x801eb8,(%esp)
  8022e7:	e8 0e fc ff ff       	call   801efa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8022ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8022ef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8022f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022f5:	eb 0c                	jmp    802303 <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8022f7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8022fc:	eb 05                	jmp    802303 <vsnprintf+0x5d>
  8022fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802303:	c9                   	leave  
  802304:	c3                   	ret    

00802305 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80230b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80230e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802312:	8b 45 10             	mov    0x10(%ebp),%eax
  802315:	89 44 24 08          	mov    %eax,0x8(%esp)
  802319:	8b 45 0c             	mov    0xc(%ebp),%eax
  80231c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802320:	8b 45 08             	mov    0x8(%ebp),%eax
  802323:	89 04 24             	mov    %eax,(%esp)
  802326:	e8 7b ff ff ff       	call   8022a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80232b:	c9                   	leave  
  80232c:	c3                   	ret    
  80232d:	00 00                	add    %al,(%eax)
	...

00802330 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802330:	55                   	push   %ebp
  802331:	89 e5                	mov    %esp,%ebp
  802333:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802336:	b8 00 00 00 00       	mov    $0x0,%eax
  80233b:	eb 01                	jmp    80233e <strlen+0xe>
		n++;
  80233d:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80233e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802342:	75 f9                	jne    80233d <strlen+0xd>
		n++;
	return n;
}
  802344:	5d                   	pop    %ebp
  802345:	c3                   	ret    

00802346 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802346:	55                   	push   %ebp
  802347:	89 e5                	mov    %esp,%ebp
  802349:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  80234c:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80234f:	b8 00 00 00 00       	mov    $0x0,%eax
  802354:	eb 01                	jmp    802357 <strnlen+0x11>
		n++;
  802356:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802357:	39 d0                	cmp    %edx,%eax
  802359:	74 06                	je     802361 <strnlen+0x1b>
  80235b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80235f:	75 f5                	jne    802356 <strnlen+0x10>
		n++;
	return n;
}
  802361:	5d                   	pop    %ebp
  802362:	c3                   	ret    

00802363 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802363:	55                   	push   %ebp
  802364:	89 e5                	mov    %esp,%ebp
  802366:	53                   	push   %ebx
  802367:	8b 45 08             	mov    0x8(%ebp),%eax
  80236a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80236d:	ba 00 00 00 00       	mov    $0x0,%edx
  802372:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  802375:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  802378:	42                   	inc    %edx
  802379:	84 c9                	test   %cl,%cl
  80237b:	75 f5                	jne    802372 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80237d:	5b                   	pop    %ebx
  80237e:	5d                   	pop    %ebp
  80237f:	c3                   	ret    

00802380 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	53                   	push   %ebx
  802384:	83 ec 08             	sub    $0x8,%esp
  802387:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80238a:	89 1c 24             	mov    %ebx,(%esp)
  80238d:	e8 9e ff ff ff       	call   802330 <strlen>
	strcpy(dst + len, src);
  802392:	8b 55 0c             	mov    0xc(%ebp),%edx
  802395:	89 54 24 04          	mov    %edx,0x4(%esp)
  802399:	01 d8                	add    %ebx,%eax
  80239b:	89 04 24             	mov    %eax,(%esp)
  80239e:	e8 c0 ff ff ff       	call   802363 <strcpy>
	return dst;
}
  8023a3:	89 d8                	mov    %ebx,%eax
  8023a5:	83 c4 08             	add    $0x8,%esp
  8023a8:	5b                   	pop    %ebx
  8023a9:	5d                   	pop    %ebp
  8023aa:	c3                   	ret    

008023ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8023ab:	55                   	push   %ebp
  8023ac:	89 e5                	mov    %esp,%ebp
  8023ae:	56                   	push   %esi
  8023af:	53                   	push   %ebx
  8023b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8023b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023b6:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8023b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8023be:	eb 0c                	jmp    8023cc <strncpy+0x21>
		*dst++ = *src;
  8023c0:	8a 1a                	mov    (%edx),%bl
  8023c2:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8023c5:	80 3a 01             	cmpb   $0x1,(%edx)
  8023c8:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8023cb:	41                   	inc    %ecx
  8023cc:	39 f1                	cmp    %esi,%ecx
  8023ce:	75 f0                	jne    8023c0 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5d                   	pop    %ebp
  8023d3:	c3                   	ret    

008023d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8023d4:	55                   	push   %ebp
  8023d5:	89 e5                	mov    %esp,%ebp
  8023d7:	56                   	push   %esi
  8023d8:	53                   	push   %ebx
  8023d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8023dc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023df:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8023e2:	85 d2                	test   %edx,%edx
  8023e4:	75 0a                	jne    8023f0 <strlcpy+0x1c>
  8023e6:	89 f0                	mov    %esi,%eax
  8023e8:	eb 1a                	jmp    802404 <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8023ea:	88 18                	mov    %bl,(%eax)
  8023ec:	40                   	inc    %eax
  8023ed:	41                   	inc    %ecx
  8023ee:	eb 02                	jmp    8023f2 <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8023f0:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  8023f2:	4a                   	dec    %edx
  8023f3:	74 0a                	je     8023ff <strlcpy+0x2b>
  8023f5:	8a 19                	mov    (%ecx),%bl
  8023f7:	84 db                	test   %bl,%bl
  8023f9:	75 ef                	jne    8023ea <strlcpy+0x16>
  8023fb:	89 c2                	mov    %eax,%edx
  8023fd:	eb 02                	jmp    802401 <strlcpy+0x2d>
  8023ff:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  802401:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  802404:	29 f0                	sub    %esi,%eax
}
  802406:	5b                   	pop    %ebx
  802407:	5e                   	pop    %esi
  802408:	5d                   	pop    %ebp
  802409:	c3                   	ret    

0080240a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80240a:	55                   	push   %ebp
  80240b:	89 e5                	mov    %esp,%ebp
  80240d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802410:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  802413:	eb 02                	jmp    802417 <strcmp+0xd>
		p++, q++;
  802415:	41                   	inc    %ecx
  802416:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802417:	8a 01                	mov    (%ecx),%al
  802419:	84 c0                	test   %al,%al
  80241b:	74 04                	je     802421 <strcmp+0x17>
  80241d:	3a 02                	cmp    (%edx),%al
  80241f:	74 f4                	je     802415 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  802421:	0f b6 c0             	movzbl %al,%eax
  802424:	0f b6 12             	movzbl (%edx),%edx
  802427:	29 d0                	sub    %edx,%eax
}
  802429:	5d                   	pop    %ebp
  80242a:	c3                   	ret    

0080242b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80242b:	55                   	push   %ebp
  80242c:	89 e5                	mov    %esp,%ebp
  80242e:	53                   	push   %ebx
  80242f:	8b 45 08             	mov    0x8(%ebp),%eax
  802432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802435:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  802438:	eb 03                	jmp    80243d <strncmp+0x12>
		n--, p++, q++;
  80243a:	4a                   	dec    %edx
  80243b:	40                   	inc    %eax
  80243c:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80243d:	85 d2                	test   %edx,%edx
  80243f:	74 14                	je     802455 <strncmp+0x2a>
  802441:	8a 18                	mov    (%eax),%bl
  802443:	84 db                	test   %bl,%bl
  802445:	74 04                	je     80244b <strncmp+0x20>
  802447:	3a 19                	cmp    (%ecx),%bl
  802449:	74 ef                	je     80243a <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80244b:	0f b6 00             	movzbl (%eax),%eax
  80244e:	0f b6 11             	movzbl (%ecx),%edx
  802451:	29 d0                	sub    %edx,%eax
  802453:	eb 05                	jmp    80245a <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802455:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80245a:	5b                   	pop    %ebx
  80245b:	5d                   	pop    %ebp
  80245c:	c3                   	ret    

0080245d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80245d:	55                   	push   %ebp
  80245e:	89 e5                	mov    %esp,%ebp
  802460:	8b 45 08             	mov    0x8(%ebp),%eax
  802463:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  802466:	eb 05                	jmp    80246d <strchr+0x10>
		if (*s == c)
  802468:	38 ca                	cmp    %cl,%dl
  80246a:	74 0c                	je     802478 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80246c:	40                   	inc    %eax
  80246d:	8a 10                	mov    (%eax),%dl
  80246f:	84 d2                	test   %dl,%dl
  802471:	75 f5                	jne    802468 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  802473:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802478:	5d                   	pop    %ebp
  802479:	c3                   	ret    

0080247a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	8b 45 08             	mov    0x8(%ebp),%eax
  802480:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  802483:	eb 05                	jmp    80248a <strfind+0x10>
		if (*s == c)
  802485:	38 ca                	cmp    %cl,%dl
  802487:	74 07                	je     802490 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  802489:	40                   	inc    %eax
  80248a:	8a 10                	mov    (%eax),%dl
  80248c:	84 d2                	test   %dl,%dl
  80248e:	75 f5                	jne    802485 <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  802490:	5d                   	pop    %ebp
  802491:	c3                   	ret    

00802492 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802492:	55                   	push   %ebp
  802493:	89 e5                	mov    %esp,%ebp
  802495:	57                   	push   %edi
  802496:	56                   	push   %esi
  802497:	53                   	push   %ebx
  802498:	8b 7d 08             	mov    0x8(%ebp),%edi
  80249b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80249e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8024a1:	85 c9                	test   %ecx,%ecx
  8024a3:	74 30                	je     8024d5 <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8024a5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8024ab:	75 25                	jne    8024d2 <memset+0x40>
  8024ad:	f6 c1 03             	test   $0x3,%cl
  8024b0:	75 20                	jne    8024d2 <memset+0x40>
		c &= 0xFF;
  8024b2:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8024b5:	89 d3                	mov    %edx,%ebx
  8024b7:	c1 e3 08             	shl    $0x8,%ebx
  8024ba:	89 d6                	mov    %edx,%esi
  8024bc:	c1 e6 18             	shl    $0x18,%esi
  8024bf:	89 d0                	mov    %edx,%eax
  8024c1:	c1 e0 10             	shl    $0x10,%eax
  8024c4:	09 f0                	or     %esi,%eax
  8024c6:	09 d0                	or     %edx,%eax
  8024c8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8024ca:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8024cd:	fc                   	cld    
  8024ce:	f3 ab                	rep stos %eax,%es:(%edi)
  8024d0:	eb 03                	jmp    8024d5 <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8024d2:	fc                   	cld    
  8024d3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8024d5:	89 f8                	mov    %edi,%eax
  8024d7:	5b                   	pop    %ebx
  8024d8:	5e                   	pop    %esi
  8024d9:	5f                   	pop    %edi
  8024da:	5d                   	pop    %ebp
  8024db:	c3                   	ret    

008024dc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8024dc:	55                   	push   %ebp
  8024dd:	89 e5                	mov    %esp,%ebp
  8024df:	57                   	push   %edi
  8024e0:	56                   	push   %esi
  8024e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8024e7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8024ea:	39 c6                	cmp    %eax,%esi
  8024ec:	73 34                	jae    802522 <memmove+0x46>
  8024ee:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8024f1:	39 d0                	cmp    %edx,%eax
  8024f3:	73 2d                	jae    802522 <memmove+0x46>
		s += n;
		d += n;
  8024f5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8024f8:	f6 c2 03             	test   $0x3,%dl
  8024fb:	75 1b                	jne    802518 <memmove+0x3c>
  8024fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  802503:	75 13                	jne    802518 <memmove+0x3c>
  802505:	f6 c1 03             	test   $0x3,%cl
  802508:	75 0e                	jne    802518 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80250a:	83 ef 04             	sub    $0x4,%edi
  80250d:	8d 72 fc             	lea    -0x4(%edx),%esi
  802510:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  802513:	fd                   	std    
  802514:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802516:	eb 07                	jmp    80251f <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  802518:	4f                   	dec    %edi
  802519:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80251c:	fd                   	std    
  80251d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80251f:	fc                   	cld    
  802520:	eb 20                	jmp    802542 <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802522:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802528:	75 13                	jne    80253d <memmove+0x61>
  80252a:	a8 03                	test   $0x3,%al
  80252c:	75 0f                	jne    80253d <memmove+0x61>
  80252e:	f6 c1 03             	test   $0x3,%cl
  802531:	75 0a                	jne    80253d <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  802533:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  802536:	89 c7                	mov    %eax,%edi
  802538:	fc                   	cld    
  802539:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80253b:	eb 05                	jmp    802542 <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80253d:	89 c7                	mov    %eax,%edi
  80253f:	fc                   	cld    
  802540:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  802542:	5e                   	pop    %esi
  802543:	5f                   	pop    %edi
  802544:	5d                   	pop    %ebp
  802545:	c3                   	ret    

00802546 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802546:	55                   	push   %ebp
  802547:	89 e5                	mov    %esp,%ebp
  802549:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80254c:	8b 45 10             	mov    0x10(%ebp),%eax
  80254f:	89 44 24 08          	mov    %eax,0x8(%esp)
  802553:	8b 45 0c             	mov    0xc(%ebp),%eax
  802556:	89 44 24 04          	mov    %eax,0x4(%esp)
  80255a:	8b 45 08             	mov    0x8(%ebp),%eax
  80255d:	89 04 24             	mov    %eax,(%esp)
  802560:	e8 77 ff ff ff       	call   8024dc <memmove>
}
  802565:	c9                   	leave  
  802566:	c3                   	ret    

00802567 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802567:	55                   	push   %ebp
  802568:	89 e5                	mov    %esp,%ebp
  80256a:	57                   	push   %edi
  80256b:	56                   	push   %esi
  80256c:	53                   	push   %ebx
  80256d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802570:	8b 75 0c             	mov    0xc(%ebp),%esi
  802573:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802576:	ba 00 00 00 00       	mov    $0x0,%edx
  80257b:	eb 16                	jmp    802593 <memcmp+0x2c>
		if (*s1 != *s2)
  80257d:	8a 04 17             	mov    (%edi,%edx,1),%al
  802580:	42                   	inc    %edx
  802581:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  802585:	38 c8                	cmp    %cl,%al
  802587:	74 0a                	je     802593 <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  802589:	0f b6 c0             	movzbl %al,%eax
  80258c:	0f b6 c9             	movzbl %cl,%ecx
  80258f:	29 c8                	sub    %ecx,%eax
  802591:	eb 09                	jmp    80259c <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802593:	39 da                	cmp    %ebx,%edx
  802595:	75 e6                	jne    80257d <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802597:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80259c:	5b                   	pop    %ebx
  80259d:	5e                   	pop    %esi
  80259e:	5f                   	pop    %edi
  80259f:	5d                   	pop    %ebp
  8025a0:	c3                   	ret    

008025a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8025a1:	55                   	push   %ebp
  8025a2:	89 e5                	mov    %esp,%ebp
  8025a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8025a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8025aa:	89 c2                	mov    %eax,%edx
  8025ac:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8025af:	eb 05                	jmp    8025b6 <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  8025b1:	38 08                	cmp    %cl,(%eax)
  8025b3:	74 05                	je     8025ba <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8025b5:	40                   	inc    %eax
  8025b6:	39 d0                	cmp    %edx,%eax
  8025b8:	72 f7                	jb     8025b1 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    

008025bc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8025bc:	55                   	push   %ebp
  8025bd:	89 e5                	mov    %esp,%ebp
  8025bf:	57                   	push   %edi
  8025c0:	56                   	push   %esi
  8025c1:	53                   	push   %ebx
  8025c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8025c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8025c8:	eb 01                	jmp    8025cb <strtol+0xf>
		s++;
  8025ca:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8025cb:	8a 02                	mov    (%edx),%al
  8025cd:	3c 20                	cmp    $0x20,%al
  8025cf:	74 f9                	je     8025ca <strtol+0xe>
  8025d1:	3c 09                	cmp    $0x9,%al
  8025d3:	74 f5                	je     8025ca <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8025d5:	3c 2b                	cmp    $0x2b,%al
  8025d7:	75 08                	jne    8025e1 <strtol+0x25>
		s++;
  8025d9:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8025da:	bf 00 00 00 00       	mov    $0x0,%edi
  8025df:	eb 13                	jmp    8025f4 <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8025e1:	3c 2d                	cmp    $0x2d,%al
  8025e3:	75 0a                	jne    8025ef <strtol+0x33>
		s++, neg = 1;
  8025e5:	8d 52 01             	lea    0x1(%edx),%edx
  8025e8:	bf 01 00 00 00       	mov    $0x1,%edi
  8025ed:	eb 05                	jmp    8025f4 <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8025ef:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8025f4:	85 db                	test   %ebx,%ebx
  8025f6:	74 05                	je     8025fd <strtol+0x41>
  8025f8:	83 fb 10             	cmp    $0x10,%ebx
  8025fb:	75 28                	jne    802625 <strtol+0x69>
  8025fd:	8a 02                	mov    (%edx),%al
  8025ff:	3c 30                	cmp    $0x30,%al
  802601:	75 10                	jne    802613 <strtol+0x57>
  802603:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  802607:	75 0a                	jne    802613 <strtol+0x57>
		s += 2, base = 16;
  802609:	83 c2 02             	add    $0x2,%edx
  80260c:	bb 10 00 00 00       	mov    $0x10,%ebx
  802611:	eb 12                	jmp    802625 <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  802613:	85 db                	test   %ebx,%ebx
  802615:	75 0e                	jne    802625 <strtol+0x69>
  802617:	3c 30                	cmp    $0x30,%al
  802619:	75 05                	jne    802620 <strtol+0x64>
		s++, base = 8;
  80261b:	42                   	inc    %edx
  80261c:	b3 08                	mov    $0x8,%bl
  80261e:	eb 05                	jmp    802625 <strtol+0x69>
	else if (base == 0)
		base = 10;
  802620:	bb 0a 00 00 00       	mov    $0xa,%ebx
  802625:	b8 00 00 00 00       	mov    $0x0,%eax
  80262a:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80262c:	8a 0a                	mov    (%edx),%cl
  80262e:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  802631:	80 fb 09             	cmp    $0x9,%bl
  802634:	77 08                	ja     80263e <strtol+0x82>
			dig = *s - '0';
  802636:	0f be c9             	movsbl %cl,%ecx
  802639:	83 e9 30             	sub    $0x30,%ecx
  80263c:	eb 1e                	jmp    80265c <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  80263e:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  802641:	80 fb 19             	cmp    $0x19,%bl
  802644:	77 08                	ja     80264e <strtol+0x92>
			dig = *s - 'a' + 10;
  802646:	0f be c9             	movsbl %cl,%ecx
  802649:	83 e9 57             	sub    $0x57,%ecx
  80264c:	eb 0e                	jmp    80265c <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  80264e:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  802651:	80 fb 19             	cmp    $0x19,%bl
  802654:	77 12                	ja     802668 <strtol+0xac>
			dig = *s - 'A' + 10;
  802656:	0f be c9             	movsbl %cl,%ecx
  802659:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80265c:	39 f1                	cmp    %esi,%ecx
  80265e:	7d 0c                	jge    80266c <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  802660:	42                   	inc    %edx
  802661:	0f af c6             	imul   %esi,%eax
  802664:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  802666:	eb c4                	jmp    80262c <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  802668:	89 c1                	mov    %eax,%ecx
  80266a:	eb 02                	jmp    80266e <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80266c:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  80266e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802672:	74 05                	je     802679 <strtol+0xbd>
		*endptr = (char *) s;
  802674:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802677:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  802679:	85 ff                	test   %edi,%edi
  80267b:	74 04                	je     802681 <strtol+0xc5>
  80267d:	89 c8                	mov    %ecx,%eax
  80267f:	f7 d8                	neg    %eax
}
  802681:	5b                   	pop    %ebx
  802682:	5e                   	pop    %esi
  802683:	5f                   	pop    %edi
  802684:	5d                   	pop    %ebp
  802685:	c3                   	ret    
	...

00802688 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802688:	55                   	push   %ebp
  802689:	89 e5                	mov    %esp,%ebp
  80268b:	57                   	push   %edi
  80268c:	56                   	push   %esi
  80268d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80268e:	b8 00 00 00 00       	mov    $0x0,%eax
  802693:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802696:	8b 55 08             	mov    0x8(%ebp),%edx
  802699:	89 c3                	mov    %eax,%ebx
  80269b:	89 c7                	mov    %eax,%edi
  80269d:	89 c6                	mov    %eax,%esi
  80269f:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8026a1:	5b                   	pop    %ebx
  8026a2:	5e                   	pop    %esi
  8026a3:	5f                   	pop    %edi
  8026a4:	5d                   	pop    %ebp
  8026a5:	c3                   	ret    

008026a6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8026a6:	55                   	push   %ebp
  8026a7:	89 e5                	mov    %esp,%ebp
  8026a9:	57                   	push   %edi
  8026aa:	56                   	push   %esi
  8026ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8026b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026b6:	89 d1                	mov    %edx,%ecx
  8026b8:	89 d3                	mov    %edx,%ebx
  8026ba:	89 d7                	mov    %edx,%edi
  8026bc:	89 d6                	mov    %edx,%esi
  8026be:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8026c0:	5b                   	pop    %ebx
  8026c1:	5e                   	pop    %esi
  8026c2:	5f                   	pop    %edi
  8026c3:	5d                   	pop    %ebp
  8026c4:	c3                   	ret    

008026c5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8026c5:	55                   	push   %ebp
  8026c6:	89 e5                	mov    %esp,%ebp
  8026c8:	57                   	push   %edi
  8026c9:	56                   	push   %esi
  8026ca:	53                   	push   %ebx
  8026cb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8026ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8026d3:	b8 03 00 00 00       	mov    $0x3,%eax
  8026d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8026db:	89 cb                	mov    %ecx,%ebx
  8026dd:	89 cf                	mov    %ecx,%edi
  8026df:	89 ce                	mov    %ecx,%esi
  8026e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8026e3:	85 c0                	test   %eax,%eax
  8026e5:	7e 28                	jle    80270f <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8026e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8026eb:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8026f2:	00 
  8026f3:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  8026fa:	00 
  8026fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802702:	00 
  802703:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  80270a:	e8 91 f5 ff ff       	call   801ca0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80270f:	83 c4 2c             	add    $0x2c,%esp
  802712:	5b                   	pop    %ebx
  802713:	5e                   	pop    %esi
  802714:	5f                   	pop    %edi
  802715:	5d                   	pop    %ebp
  802716:	c3                   	ret    

00802717 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  802717:	55                   	push   %ebp
  802718:	89 e5                	mov    %esp,%ebp
  80271a:	57                   	push   %edi
  80271b:	56                   	push   %esi
  80271c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80271d:	ba 00 00 00 00       	mov    $0x0,%edx
  802722:	b8 02 00 00 00       	mov    $0x2,%eax
  802727:	89 d1                	mov    %edx,%ecx
  802729:	89 d3                	mov    %edx,%ebx
  80272b:	89 d7                	mov    %edx,%edi
  80272d:	89 d6                	mov    %edx,%esi
  80272f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802731:	5b                   	pop    %ebx
  802732:	5e                   	pop    %esi
  802733:	5f                   	pop    %edi
  802734:	5d                   	pop    %ebp
  802735:	c3                   	ret    

00802736 <sys_yield>:

void
sys_yield(void)
{
  802736:	55                   	push   %ebp
  802737:	89 e5                	mov    %esp,%ebp
  802739:	57                   	push   %edi
  80273a:	56                   	push   %esi
  80273b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80273c:	ba 00 00 00 00       	mov    $0x0,%edx
  802741:	b8 0b 00 00 00       	mov    $0xb,%eax
  802746:	89 d1                	mov    %edx,%ecx
  802748:	89 d3                	mov    %edx,%ebx
  80274a:	89 d7                	mov    %edx,%edi
  80274c:	89 d6                	mov    %edx,%esi
  80274e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802750:	5b                   	pop    %ebx
  802751:	5e                   	pop    %esi
  802752:	5f                   	pop    %edi
  802753:	5d                   	pop    %ebp
  802754:	c3                   	ret    

00802755 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  802755:	55                   	push   %ebp
  802756:	89 e5                	mov    %esp,%ebp
  802758:	57                   	push   %edi
  802759:	56                   	push   %esi
  80275a:	53                   	push   %ebx
  80275b:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80275e:	be 00 00 00 00       	mov    $0x0,%esi
  802763:	b8 04 00 00 00       	mov    $0x4,%eax
  802768:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80276b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80276e:	8b 55 08             	mov    0x8(%ebp),%edx
  802771:	89 f7                	mov    %esi,%edi
  802773:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802775:	85 c0                	test   %eax,%eax
  802777:	7e 28                	jle    8027a1 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  802779:	89 44 24 10          	mov    %eax,0x10(%esp)
  80277d:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  802784:	00 
  802785:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  80278c:	00 
  80278d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802794:	00 
  802795:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  80279c:	e8 ff f4 ff ff       	call   801ca0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8027a1:	83 c4 2c             	add    $0x2c,%esp
  8027a4:	5b                   	pop    %ebx
  8027a5:	5e                   	pop    %esi
  8027a6:	5f                   	pop    %edi
  8027a7:	5d                   	pop    %ebp
  8027a8:	c3                   	ret    

008027a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8027a9:	55                   	push   %ebp
  8027aa:	89 e5                	mov    %esp,%ebp
  8027ac:	57                   	push   %edi
  8027ad:	56                   	push   %esi
  8027ae:	53                   	push   %ebx
  8027af:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8027b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8027b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8027ba:	8b 7d 14             	mov    0x14(%ebp),%edi
  8027bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8027c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8027c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8027c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8027c8:	85 c0                	test   %eax,%eax
  8027ca:	7e 28                	jle    8027f4 <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8027cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8027d0:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8027d7:	00 
  8027d8:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  8027df:	00 
  8027e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8027e7:	00 
  8027e8:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  8027ef:	e8 ac f4 ff ff       	call   801ca0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8027f4:	83 c4 2c             	add    $0x2c,%esp
  8027f7:	5b                   	pop    %ebx
  8027f8:	5e                   	pop    %esi
  8027f9:	5f                   	pop    %edi
  8027fa:	5d                   	pop    %ebp
  8027fb:	c3                   	ret    

008027fc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8027fc:	55                   	push   %ebp
  8027fd:	89 e5                	mov    %esp,%ebp
  8027ff:	57                   	push   %edi
  802800:	56                   	push   %esi
  802801:	53                   	push   %ebx
  802802:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802805:	bb 00 00 00 00       	mov    $0x0,%ebx
  80280a:	b8 06 00 00 00       	mov    $0x6,%eax
  80280f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802812:	8b 55 08             	mov    0x8(%ebp),%edx
  802815:	89 df                	mov    %ebx,%edi
  802817:	89 de                	mov    %ebx,%esi
  802819:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80281b:	85 c0                	test   %eax,%eax
  80281d:	7e 28                	jle    802847 <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80281f:	89 44 24 10          	mov    %eax,0x10(%esp)
  802823:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  80282a:	00 
  80282b:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  802832:	00 
  802833:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80283a:	00 
  80283b:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  802842:	e8 59 f4 ff ff       	call   801ca0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  802847:	83 c4 2c             	add    $0x2c,%esp
  80284a:	5b                   	pop    %ebx
  80284b:	5e                   	pop    %esi
  80284c:	5f                   	pop    %edi
  80284d:	5d                   	pop    %ebp
  80284e:	c3                   	ret    

0080284f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80284f:	55                   	push   %ebp
  802850:	89 e5                	mov    %esp,%ebp
  802852:	57                   	push   %edi
  802853:	56                   	push   %esi
  802854:	53                   	push   %ebx
  802855:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802858:	bb 00 00 00 00       	mov    $0x0,%ebx
  80285d:	b8 08 00 00 00       	mov    $0x8,%eax
  802862:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802865:	8b 55 08             	mov    0x8(%ebp),%edx
  802868:	89 df                	mov    %ebx,%edi
  80286a:	89 de                	mov    %ebx,%esi
  80286c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80286e:	85 c0                	test   %eax,%eax
  802870:	7e 28                	jle    80289a <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802872:	89 44 24 10          	mov    %eax,0x10(%esp)
  802876:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80287d:	00 
  80287e:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  802885:	00 
  802886:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80288d:	00 
  80288e:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  802895:	e8 06 f4 ff ff       	call   801ca0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80289a:	83 c4 2c             	add    $0x2c,%esp
  80289d:	5b                   	pop    %ebx
  80289e:	5e                   	pop    %esi
  80289f:	5f                   	pop    %edi
  8028a0:	5d                   	pop    %ebp
  8028a1:	c3                   	ret    

008028a2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8028a2:	55                   	push   %ebp
  8028a3:	89 e5                	mov    %esp,%ebp
  8028a5:	57                   	push   %edi
  8028a6:	56                   	push   %esi
  8028a7:	53                   	push   %ebx
  8028a8:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028ab:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028b0:	b8 09 00 00 00       	mov    $0x9,%eax
  8028b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8028bb:	89 df                	mov    %ebx,%edi
  8028bd:	89 de                	mov    %ebx,%esi
  8028bf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8028c1:	85 c0                	test   %eax,%eax
  8028c3:	7e 28                	jle    8028ed <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8028c5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8028c9:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8028d0:	00 
  8028d1:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  8028d8:	00 
  8028d9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8028e0:	00 
  8028e1:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  8028e8:	e8 b3 f3 ff ff       	call   801ca0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8028ed:	83 c4 2c             	add    $0x2c,%esp
  8028f0:	5b                   	pop    %ebx
  8028f1:	5e                   	pop    %esi
  8028f2:	5f                   	pop    %edi
  8028f3:	5d                   	pop    %ebp
  8028f4:	c3                   	ret    

008028f5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8028f5:	55                   	push   %ebp
  8028f6:	89 e5                	mov    %esp,%ebp
  8028f8:	57                   	push   %edi
  8028f9:	56                   	push   %esi
  8028fa:	53                   	push   %ebx
  8028fb:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8028fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  802903:	b8 0a 00 00 00       	mov    $0xa,%eax
  802908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80290b:	8b 55 08             	mov    0x8(%ebp),%edx
  80290e:	89 df                	mov    %ebx,%edi
  802910:	89 de                	mov    %ebx,%esi
  802912:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802914:	85 c0                	test   %eax,%eax
  802916:	7e 28                	jle    802940 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802918:	89 44 24 10          	mov    %eax,0x10(%esp)
  80291c:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  802923:	00 
  802924:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  80292b:	00 
  80292c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802933:	00 
  802934:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  80293b:	e8 60 f3 ff ff       	call   801ca0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802940:	83 c4 2c             	add    $0x2c,%esp
  802943:	5b                   	pop    %ebx
  802944:	5e                   	pop    %esi
  802945:	5f                   	pop    %edi
  802946:	5d                   	pop    %ebp
  802947:	c3                   	ret    

00802948 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802948:	55                   	push   %ebp
  802949:	89 e5                	mov    %esp,%ebp
  80294b:	57                   	push   %edi
  80294c:	56                   	push   %esi
  80294d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80294e:	be 00 00 00 00       	mov    $0x0,%esi
  802953:	b8 0c 00 00 00       	mov    $0xc,%eax
  802958:	8b 7d 14             	mov    0x14(%ebp),%edi
  80295b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80295e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802961:	8b 55 08             	mov    0x8(%ebp),%edx
  802964:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802966:	5b                   	pop    %ebx
  802967:	5e                   	pop    %esi
  802968:	5f                   	pop    %edi
  802969:	5d                   	pop    %ebp
  80296a:	c3                   	ret    

0080296b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80296b:	55                   	push   %ebp
  80296c:	89 e5                	mov    %esp,%ebp
  80296e:	57                   	push   %edi
  80296f:	56                   	push   %esi
  802970:	53                   	push   %ebx
  802971:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802974:	b9 00 00 00 00       	mov    $0x0,%ecx
  802979:	b8 0d 00 00 00       	mov    $0xd,%eax
  80297e:	8b 55 08             	mov    0x8(%ebp),%edx
  802981:	89 cb                	mov    %ecx,%ebx
  802983:	89 cf                	mov    %ecx,%edi
  802985:	89 ce                	mov    %ecx,%esi
  802987:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802989:	85 c0                	test   %eax,%eax
  80298b:	7e 28                	jle    8029b5 <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80298d:	89 44 24 10          	mov    %eax,0x10(%esp)
  802991:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  802998:	00 
  802999:	c7 44 24 08 7f 44 80 	movl   $0x80447f,0x8(%esp)
  8029a0:	00 
  8029a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8029a8:	00 
  8029a9:	c7 04 24 9c 44 80 00 	movl   $0x80449c,(%esp)
  8029b0:	e8 eb f2 ff ff       	call   801ca0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8029b5:	83 c4 2c             	add    $0x2c,%esp
  8029b8:	5b                   	pop    %ebx
  8029b9:	5e                   	pop    %esi
  8029ba:	5f                   	pop    %edi
  8029bb:	5d                   	pop    %ebp
  8029bc:	c3                   	ret    
  8029bd:	00 00                	add    %al,(%eax)
	...

008029c0 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8029c0:	55                   	push   %ebp
  8029c1:	89 e5                	mov    %esp,%ebp
  8029c3:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8029c6:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  8029cd:	0f 85 80 00 00 00    	jne    802a53 <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8029d3:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8029d8:	8b 40 48             	mov    0x48(%eax),%eax
  8029db:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8029e2:	00 
  8029e3:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8029ea:	ee 
  8029eb:	89 04 24             	mov    %eax,(%esp)
  8029ee:	e8 62 fd ff ff       	call   802755 <sys_page_alloc>
  8029f3:	85 c0                	test   %eax,%eax
  8029f5:	79 20                	jns    802a17 <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  8029f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8029fb:	c7 44 24 08 ac 44 80 	movl   $0x8044ac,0x8(%esp)
  802a02:	00 
  802a03:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802a0a:	00 
  802a0b:	c7 04 24 08 45 80 00 	movl   $0x804508,(%esp)
  802a12:	e8 89 f2 ff ff       	call   801ca0 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  802a17:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802a1c:	8b 40 48             	mov    0x48(%eax),%eax
  802a1f:	c7 44 24 04 60 2a 80 	movl   $0x802a60,0x4(%esp)
  802a26:	00 
  802a27:	89 04 24             	mov    %eax,(%esp)
  802a2a:	e8 c6 fe ff ff       	call   8028f5 <sys_env_set_pgfault_upcall>
  802a2f:	85 c0                	test   %eax,%eax
  802a31:	79 20                	jns    802a53 <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  802a33:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802a37:	c7 44 24 08 d8 44 80 	movl   $0x8044d8,0x8(%esp)
  802a3e:	00 
  802a3f:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  802a46:	00 
  802a47:	c7 04 24 08 45 80 00 	movl   $0x804508,(%esp)
  802a4e:	e8 4d f2 ff ff       	call   801ca0 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802a53:	8b 45 08             	mov    0x8(%ebp),%eax
  802a56:	a3 10 a0 80 00       	mov    %eax,0x80a010
}
  802a5b:	c9                   	leave  
  802a5c:	c3                   	ret    
  802a5d:	00 00                	add    %al,(%eax)
	...

00802a60 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802a60:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802a61:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802a66:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802a68:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  802a6b:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  802a6f:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802a71:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  802a74:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  802a75:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802a78:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  802a7a:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  802a7d:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  802a7e:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802a81:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802a82:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802a83:	c3                   	ret    

00802a84 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802a84:	55                   	push   %ebp
  802a85:	89 e5                	mov    %esp,%ebp
  802a87:	56                   	push   %esi
  802a88:	53                   	push   %ebx
  802a89:	83 ec 10             	sub    $0x10,%esp
  802a8c:	8b 75 08             	mov    0x8(%ebp),%esi
  802a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  802a95:	85 c0                	test   %eax,%eax
  802a97:	75 05                	jne    802a9e <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  802a99:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  802a9e:	89 04 24             	mov    %eax,(%esp)
  802aa1:	e8 c5 fe ff ff       	call   80296b <sys_ipc_recv>
	if (!err) {
  802aa6:	85 c0                	test   %eax,%eax
  802aa8:	75 26                	jne    802ad0 <ipc_recv+0x4c>
		if (from_env_store) {
  802aaa:	85 f6                	test   %esi,%esi
  802aac:	74 0a                	je     802ab8 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  802aae:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ab3:	8b 40 74             	mov    0x74(%eax),%eax
  802ab6:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  802ab8:	85 db                	test   %ebx,%ebx
  802aba:	74 0a                	je     802ac6 <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  802abc:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ac1:	8b 40 78             	mov    0x78(%eax),%eax
  802ac4:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  802ac6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802acb:	8b 40 70             	mov    0x70(%eax),%eax
  802ace:	eb 14                	jmp    802ae4 <ipc_recv+0x60>
	}
	if (from_env_store) {
  802ad0:	85 f6                	test   %esi,%esi
  802ad2:	74 06                	je     802ada <ipc_recv+0x56>
		*from_env_store = 0;
  802ad4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  802ada:	85 db                	test   %ebx,%ebx
  802adc:	74 06                	je     802ae4 <ipc_recv+0x60>
		*perm_store = 0;
  802ade:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  802ae4:	83 c4 10             	add    $0x10,%esp
  802ae7:	5b                   	pop    %ebx
  802ae8:	5e                   	pop    %esi
  802ae9:	5d                   	pop    %ebp
  802aea:	c3                   	ret    

00802aeb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802aeb:	55                   	push   %ebp
  802aec:	89 e5                	mov    %esp,%ebp
  802aee:	57                   	push   %edi
  802aef:	56                   	push   %esi
  802af0:	53                   	push   %ebx
  802af1:	83 ec 1c             	sub    $0x1c,%esp
  802af4:	8b 75 10             	mov    0x10(%ebp),%esi
  802af7:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  802afa:	85 f6                	test   %esi,%esi
  802afc:	75 05                	jne    802b03 <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  802afe:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  802b03:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802b07:	89 74 24 08          	mov    %esi,0x8(%esp)
  802b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802b12:	8b 45 08             	mov    0x8(%ebp),%eax
  802b15:	89 04 24             	mov    %eax,(%esp)
  802b18:	e8 2b fe ff ff       	call   802948 <sys_ipc_try_send>
  802b1d:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802b1f:	e8 12 fc ff ff       	call   802736 <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  802b24:	83 fb f9             	cmp    $0xfffffff9,%ebx
  802b27:	74 da                	je     802b03 <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802b29:	85 db                	test   %ebx,%ebx
  802b2b:	74 20                	je     802b4d <ipc_send+0x62>
		panic("send fail: %e", err);
  802b2d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802b31:	c7 44 24 08 16 45 80 	movl   $0x804516,0x8(%esp)
  802b38:	00 
  802b39:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802b40:	00 
  802b41:	c7 04 24 24 45 80 00 	movl   $0x804524,(%esp)
  802b48:	e8 53 f1 ff ff       	call   801ca0 <_panic>
	}
	return;
}
  802b4d:	83 c4 1c             	add    $0x1c,%esp
  802b50:	5b                   	pop    %ebx
  802b51:	5e                   	pop    %esi
  802b52:	5f                   	pop    %edi
  802b53:	5d                   	pop    %ebp
  802b54:	c3                   	ret    

00802b55 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802b55:	55                   	push   %ebp
  802b56:	89 e5                	mov    %esp,%ebp
  802b58:	53                   	push   %ebx
  802b59:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802b5c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802b61:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802b68:	89 c2                	mov    %eax,%edx
  802b6a:	c1 e2 07             	shl    $0x7,%edx
  802b6d:	29 ca                	sub    %ecx,%edx
  802b6f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802b75:	8b 52 50             	mov    0x50(%edx),%edx
  802b78:	39 da                	cmp    %ebx,%edx
  802b7a:	75 0f                	jne    802b8b <ipc_find_env+0x36>
			return envs[i].env_id;
  802b7c:	c1 e0 07             	shl    $0x7,%eax
  802b7f:	29 c8                	sub    %ecx,%eax
  802b81:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  802b86:	8b 40 40             	mov    0x40(%eax),%eax
  802b89:	eb 0c                	jmp    802b97 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802b8b:	40                   	inc    %eax
  802b8c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802b91:	75 ce                	jne    802b61 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802b93:	66 b8 00 00          	mov    $0x0,%ax
}
  802b97:	5b                   	pop    %ebx
  802b98:	5d                   	pop    %ebp
  802b99:	c3                   	ret    
	...

00802b9c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  802b9c:	55                   	push   %ebp
  802b9d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  802b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  802ba2:	05 00 00 00 30       	add    $0x30000000,%eax
  802ba7:	c1 e8 0c             	shr    $0xc,%eax
}
  802baa:	5d                   	pop    %ebp
  802bab:	c3                   	ret    

00802bac <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802bac:	55                   	push   %ebp
  802bad:	89 e5                	mov    %esp,%ebp
  802baf:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  802bb2:	8b 45 08             	mov    0x8(%ebp),%eax
  802bb5:	89 04 24             	mov    %eax,(%esp)
  802bb8:	e8 df ff ff ff       	call   802b9c <fd2num>
  802bbd:	05 20 00 0d 00       	add    $0xd0020,%eax
  802bc2:	c1 e0 0c             	shl    $0xc,%eax
}
  802bc5:	c9                   	leave  
  802bc6:	c3                   	ret    

00802bc7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  802bc7:	55                   	push   %ebp
  802bc8:	89 e5                	mov    %esp,%ebp
  802bca:	53                   	push   %ebx
  802bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  802bce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  802bd3:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802bd5:	89 c2                	mov    %eax,%edx
  802bd7:	c1 ea 16             	shr    $0x16,%edx
  802bda:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802be1:	f6 c2 01             	test   $0x1,%dl
  802be4:	74 11                	je     802bf7 <fd_alloc+0x30>
  802be6:	89 c2                	mov    %eax,%edx
  802be8:	c1 ea 0c             	shr    $0xc,%edx
  802beb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802bf2:	f6 c2 01             	test   $0x1,%dl
  802bf5:	75 09                	jne    802c00 <fd_alloc+0x39>
			*fd_store = fd;
  802bf7:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  802bf9:	b8 00 00 00 00       	mov    $0x0,%eax
  802bfe:	eb 17                	jmp    802c17 <fd_alloc+0x50>
  802c00:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802c05:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802c0a:	75 c7                	jne    802bd3 <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802c0c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  802c12:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802c17:	5b                   	pop    %ebx
  802c18:	5d                   	pop    %ebp
  802c19:	c3                   	ret    

00802c1a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802c1a:	55                   	push   %ebp
  802c1b:	89 e5                	mov    %esp,%ebp
  802c1d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802c20:	83 f8 1f             	cmp    $0x1f,%eax
  802c23:	77 36                	ja     802c5b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802c25:	05 00 00 0d 00       	add    $0xd0000,%eax
  802c2a:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802c2d:	89 c2                	mov    %eax,%edx
  802c2f:	c1 ea 16             	shr    $0x16,%edx
  802c32:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802c39:	f6 c2 01             	test   $0x1,%dl
  802c3c:	74 24                	je     802c62 <fd_lookup+0x48>
  802c3e:	89 c2                	mov    %eax,%edx
  802c40:	c1 ea 0c             	shr    $0xc,%edx
  802c43:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802c4a:	f6 c2 01             	test   $0x1,%dl
  802c4d:	74 1a                	je     802c69 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802c4f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c52:	89 02                	mov    %eax,(%edx)
	return 0;
  802c54:	b8 00 00 00 00       	mov    $0x0,%eax
  802c59:	eb 13                	jmp    802c6e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802c5b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c60:	eb 0c                	jmp    802c6e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802c62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802c67:	eb 05                	jmp    802c6e <fd_lookup+0x54>
  802c69:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802c6e:	5d                   	pop    %ebp
  802c6f:	c3                   	ret    

00802c70 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802c70:	55                   	push   %ebp
  802c71:	89 e5                	mov    %esp,%ebp
  802c73:	53                   	push   %ebx
  802c74:	83 ec 14             	sub    $0x14,%esp
  802c77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802c7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  802c7d:	ba 00 00 00 00       	mov    $0x0,%edx
  802c82:	eb 0e                	jmp    802c92 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  802c84:	39 08                	cmp    %ecx,(%eax)
  802c86:	75 09                	jne    802c91 <dev_lookup+0x21>
			*dev = devtab[i];
  802c88:	89 03                	mov    %eax,(%ebx)
			return 0;
  802c8a:	b8 00 00 00 00       	mov    $0x0,%eax
  802c8f:	eb 33                	jmp    802cc4 <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802c91:	42                   	inc    %edx
  802c92:	8b 04 95 b0 45 80 00 	mov    0x8045b0(,%edx,4),%eax
  802c99:	85 c0                	test   %eax,%eax
  802c9b:	75 e7                	jne    802c84 <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802c9d:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802ca2:	8b 40 48             	mov    0x48(%eax),%eax
  802ca5:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802ca9:	89 44 24 04          	mov    %eax,0x4(%esp)
  802cad:	c7 04 24 30 45 80 00 	movl   $0x804530,(%esp)
  802cb4:	e8 df f0 ff ff       	call   801d98 <cprintf>
	*dev = 0;
  802cb9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  802cbf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802cc4:	83 c4 14             	add    $0x14,%esp
  802cc7:	5b                   	pop    %ebx
  802cc8:	5d                   	pop    %ebp
  802cc9:	c3                   	ret    

00802cca <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802cca:	55                   	push   %ebp
  802ccb:	89 e5                	mov    %esp,%ebp
  802ccd:	56                   	push   %esi
  802cce:	53                   	push   %ebx
  802ccf:	83 ec 30             	sub    $0x30,%esp
  802cd2:	8b 75 08             	mov    0x8(%ebp),%esi
  802cd5:	8a 45 0c             	mov    0xc(%ebp),%al
  802cd8:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802cdb:	89 34 24             	mov    %esi,(%esp)
  802cde:	e8 b9 fe ff ff       	call   802b9c <fd2num>
  802ce3:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802ce6:	89 54 24 04          	mov    %edx,0x4(%esp)
  802cea:	89 04 24             	mov    %eax,(%esp)
  802ced:	e8 28 ff ff ff       	call   802c1a <fd_lookup>
  802cf2:	89 c3                	mov    %eax,%ebx
  802cf4:	85 c0                	test   %eax,%eax
  802cf6:	78 05                	js     802cfd <fd_close+0x33>
	    || fd != fd2)
  802cf8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802cfb:	74 0d                	je     802d0a <fd_close+0x40>
		return (must_exist ? r : 0);
  802cfd:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802d01:	75 46                	jne    802d49 <fd_close+0x7f>
  802d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  802d08:	eb 3f                	jmp    802d49 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802d0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802d0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d11:	8b 06                	mov    (%esi),%eax
  802d13:	89 04 24             	mov    %eax,(%esp)
  802d16:	e8 55 ff ff ff       	call   802c70 <dev_lookup>
  802d1b:	89 c3                	mov    %eax,%ebx
  802d1d:	85 c0                	test   %eax,%eax
  802d1f:	78 18                	js     802d39 <fd_close+0x6f>
		if (dev->dev_close)
  802d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d24:	8b 40 10             	mov    0x10(%eax),%eax
  802d27:	85 c0                	test   %eax,%eax
  802d29:	74 09                	je     802d34 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802d2b:	89 34 24             	mov    %esi,(%esp)
  802d2e:	ff d0                	call   *%eax
  802d30:	89 c3                	mov    %eax,%ebx
  802d32:	eb 05                	jmp    802d39 <fd_close+0x6f>
		else
			r = 0;
  802d34:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802d39:	89 74 24 04          	mov    %esi,0x4(%esp)
  802d3d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802d44:	e8 b3 fa ff ff       	call   8027fc <sys_page_unmap>
	return r;
}
  802d49:	89 d8                	mov    %ebx,%eax
  802d4b:	83 c4 30             	add    $0x30,%esp
  802d4e:	5b                   	pop    %ebx
  802d4f:	5e                   	pop    %esi
  802d50:	5d                   	pop    %ebp
  802d51:	c3                   	ret    

00802d52 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802d52:	55                   	push   %ebp
  802d53:	89 e5                	mov    %esp,%ebp
  802d55:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802d58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  802d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  802d62:	89 04 24             	mov    %eax,(%esp)
  802d65:	e8 b0 fe ff ff       	call   802c1a <fd_lookup>
  802d6a:	85 c0                	test   %eax,%eax
  802d6c:	78 13                	js     802d81 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802d6e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  802d75:	00 
  802d76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d79:	89 04 24             	mov    %eax,(%esp)
  802d7c:	e8 49 ff ff ff       	call   802cca <fd_close>
}
  802d81:	c9                   	leave  
  802d82:	c3                   	ret    

00802d83 <close_all>:

void
close_all(void)
{
  802d83:	55                   	push   %ebp
  802d84:	89 e5                	mov    %esp,%ebp
  802d86:	53                   	push   %ebx
  802d87:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802d8a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802d8f:	89 1c 24             	mov    %ebx,(%esp)
  802d92:	e8 bb ff ff ff       	call   802d52 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802d97:	43                   	inc    %ebx
  802d98:	83 fb 20             	cmp    $0x20,%ebx
  802d9b:	75 f2                	jne    802d8f <close_all+0xc>
		close(i);
}
  802d9d:	83 c4 14             	add    $0x14,%esp
  802da0:	5b                   	pop    %ebx
  802da1:	5d                   	pop    %ebp
  802da2:	c3                   	ret    

00802da3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802da3:	55                   	push   %ebp
  802da4:	89 e5                	mov    %esp,%ebp
  802da6:	57                   	push   %edi
  802da7:	56                   	push   %esi
  802da8:	53                   	push   %ebx
  802da9:	83 ec 4c             	sub    $0x4c,%esp
  802dac:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802daf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802db2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802db6:	8b 45 08             	mov    0x8(%ebp),%eax
  802db9:	89 04 24             	mov    %eax,(%esp)
  802dbc:	e8 59 fe ff ff       	call   802c1a <fd_lookup>
  802dc1:	89 c3                	mov    %eax,%ebx
  802dc3:	85 c0                	test   %eax,%eax
  802dc5:	0f 88 e1 00 00 00    	js     802eac <dup+0x109>
		return r;
	close(newfdnum);
  802dcb:	89 3c 24             	mov    %edi,(%esp)
  802dce:	e8 7f ff ff ff       	call   802d52 <close>

	newfd = INDEX2FD(newfdnum);
  802dd3:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  802dd9:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  802ddc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802ddf:	89 04 24             	mov    %eax,(%esp)
  802de2:	e8 c5 fd ff ff       	call   802bac <fd2data>
  802de7:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802de9:	89 34 24             	mov    %esi,(%esp)
  802dec:	e8 bb fd ff ff       	call   802bac <fd2data>
  802df1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802df4:	89 d8                	mov    %ebx,%eax
  802df6:	c1 e8 16             	shr    $0x16,%eax
  802df9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802e00:	a8 01                	test   $0x1,%al
  802e02:	74 46                	je     802e4a <dup+0xa7>
  802e04:	89 d8                	mov    %ebx,%eax
  802e06:	c1 e8 0c             	shr    $0xc,%eax
  802e09:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802e10:	f6 c2 01             	test   $0x1,%dl
  802e13:	74 35                	je     802e4a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802e15:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802e1c:	25 07 0e 00 00       	and    $0xe07,%eax
  802e21:	89 44 24 10          	mov    %eax,0x10(%esp)
  802e25:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802e28:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802e2c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802e33:	00 
  802e34:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802e38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e3f:	e8 65 f9 ff ff       	call   8027a9 <sys_page_map>
  802e44:	89 c3                	mov    %eax,%ebx
  802e46:	85 c0                	test   %eax,%eax
  802e48:	78 3b                	js     802e85 <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e4d:	89 c2                	mov    %eax,%edx
  802e4f:	c1 ea 0c             	shr    $0xc,%edx
  802e52:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802e59:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802e5f:	89 54 24 10          	mov    %edx,0x10(%esp)
  802e63:	89 74 24 0c          	mov    %esi,0xc(%esp)
  802e67:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802e6e:	00 
  802e6f:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e7a:	e8 2a f9 ff ff       	call   8027a9 <sys_page_map>
  802e7f:	89 c3                	mov    %eax,%ebx
  802e81:	85 c0                	test   %eax,%eax
  802e83:	79 25                	jns    802eaa <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802e85:	89 74 24 04          	mov    %esi,0x4(%esp)
  802e89:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802e90:	e8 67 f9 ff ff       	call   8027fc <sys_page_unmap>
	sys_page_unmap(0, nva);
  802e95:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802e98:	89 44 24 04          	mov    %eax,0x4(%esp)
  802e9c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802ea3:	e8 54 f9 ff ff       	call   8027fc <sys_page_unmap>
	return r;
  802ea8:	eb 02                	jmp    802eac <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  802eaa:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  802eac:	89 d8                	mov    %ebx,%eax
  802eae:	83 c4 4c             	add    $0x4c,%esp
  802eb1:	5b                   	pop    %ebx
  802eb2:	5e                   	pop    %esi
  802eb3:	5f                   	pop    %edi
  802eb4:	5d                   	pop    %ebp
  802eb5:	c3                   	ret    

00802eb6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802eb6:	55                   	push   %ebp
  802eb7:	89 e5                	mov    %esp,%ebp
  802eb9:	53                   	push   %ebx
  802eba:	83 ec 24             	sub    $0x24,%esp
  802ebd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ec0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ec3:	89 44 24 04          	mov    %eax,0x4(%esp)
  802ec7:	89 1c 24             	mov    %ebx,(%esp)
  802eca:	e8 4b fd ff ff       	call   802c1a <fd_lookup>
  802ecf:	85 c0                	test   %eax,%eax
  802ed1:	78 6d                	js     802f40 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802ed3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  802eda:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802edd:	8b 00                	mov    (%eax),%eax
  802edf:	89 04 24             	mov    %eax,(%esp)
  802ee2:	e8 89 fd ff ff       	call   802c70 <dev_lookup>
  802ee7:	85 c0                	test   %eax,%eax
  802ee9:	78 55                	js     802f40 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802eeb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802eee:	8b 50 08             	mov    0x8(%eax),%edx
  802ef1:	83 e2 03             	and    $0x3,%edx
  802ef4:	83 fa 01             	cmp    $0x1,%edx
  802ef7:	75 23                	jne    802f1c <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ef9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802efe:	8b 40 48             	mov    0x48(%eax),%eax
  802f01:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802f05:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f09:	c7 04 24 74 45 80 00 	movl   $0x804574,(%esp)
  802f10:	e8 83 ee ff ff       	call   801d98 <cprintf>
		return -E_INVAL;
  802f15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802f1a:	eb 24                	jmp    802f40 <read+0x8a>
	}
	if (!dev->dev_read)
  802f1c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f1f:	8b 52 08             	mov    0x8(%edx),%edx
  802f22:	85 d2                	test   %edx,%edx
  802f24:	74 15                	je     802f3b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802f26:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802f29:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f30:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802f34:	89 04 24             	mov    %eax,(%esp)
  802f37:	ff d2                	call   *%edx
  802f39:	eb 05                	jmp    802f40 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802f3b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802f40:	83 c4 24             	add    $0x24,%esp
  802f43:	5b                   	pop    %ebx
  802f44:	5d                   	pop    %ebp
  802f45:	c3                   	ret    

00802f46 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802f46:	55                   	push   %ebp
  802f47:	89 e5                	mov    %esp,%ebp
  802f49:	57                   	push   %edi
  802f4a:	56                   	push   %esi
  802f4b:	53                   	push   %ebx
  802f4c:	83 ec 1c             	sub    $0x1c,%esp
  802f4f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f52:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  802f5a:	eb 23                	jmp    802f7f <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802f5c:	89 f0                	mov    %esi,%eax
  802f5e:	29 d8                	sub    %ebx,%eax
  802f60:	89 44 24 08          	mov    %eax,0x8(%esp)
  802f64:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f67:	01 d8                	add    %ebx,%eax
  802f69:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f6d:	89 3c 24             	mov    %edi,(%esp)
  802f70:	e8 41 ff ff ff       	call   802eb6 <read>
		if (m < 0)
  802f75:	85 c0                	test   %eax,%eax
  802f77:	78 10                	js     802f89 <readn+0x43>
			return m;
		if (m == 0)
  802f79:	85 c0                	test   %eax,%eax
  802f7b:	74 0a                	je     802f87 <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802f7d:	01 c3                	add    %eax,%ebx
  802f7f:	39 f3                	cmp    %esi,%ebx
  802f81:	72 d9                	jb     802f5c <readn+0x16>
  802f83:	89 d8                	mov    %ebx,%eax
  802f85:	eb 02                	jmp    802f89 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  802f87:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  802f89:	83 c4 1c             	add    $0x1c,%esp
  802f8c:	5b                   	pop    %ebx
  802f8d:	5e                   	pop    %esi
  802f8e:	5f                   	pop    %edi
  802f8f:	5d                   	pop    %ebp
  802f90:	c3                   	ret    

00802f91 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802f91:	55                   	push   %ebp
  802f92:	89 e5                	mov    %esp,%ebp
  802f94:	53                   	push   %ebx
  802f95:	83 ec 24             	sub    $0x24,%esp
  802f98:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802f9b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802f9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fa2:	89 1c 24             	mov    %ebx,(%esp)
  802fa5:	e8 70 fc ff ff       	call   802c1a <fd_lookup>
  802faa:	85 c0                	test   %eax,%eax
  802fac:	78 68                	js     803016 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802fb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fb8:	8b 00                	mov    (%eax),%eax
  802fba:	89 04 24             	mov    %eax,(%esp)
  802fbd:	e8 ae fc ff ff       	call   802c70 <dev_lookup>
  802fc2:	85 c0                	test   %eax,%eax
  802fc4:	78 50                	js     803016 <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802fc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802fc9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802fcd:	75 23                	jne    802ff2 <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802fcf:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802fd4:	8b 40 48             	mov    0x48(%eax),%eax
  802fd7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802fdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fdf:	c7 04 24 90 45 80 00 	movl   $0x804590,(%esp)
  802fe6:	e8 ad ed ff ff       	call   801d98 <cprintf>
		return -E_INVAL;
  802feb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802ff0:	eb 24                	jmp    803016 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802ff2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802ff5:	8b 52 0c             	mov    0xc(%edx),%edx
  802ff8:	85 d2                	test   %edx,%edx
  802ffa:	74 15                	je     803011 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802ffc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802fff:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803003:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803006:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80300a:	89 04 24             	mov    %eax,(%esp)
  80300d:	ff d2                	call   *%edx
  80300f:	eb 05                	jmp    803016 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  803011:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  803016:	83 c4 24             	add    $0x24,%esp
  803019:	5b                   	pop    %ebx
  80301a:	5d                   	pop    %ebp
  80301b:	c3                   	ret    

0080301c <seek>:

int
seek(int fdnum, off_t offset)
{
  80301c:	55                   	push   %ebp
  80301d:	89 e5                	mov    %esp,%ebp
  80301f:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803022:	8d 45 fc             	lea    -0x4(%ebp),%eax
  803025:	89 44 24 04          	mov    %eax,0x4(%esp)
  803029:	8b 45 08             	mov    0x8(%ebp),%eax
  80302c:	89 04 24             	mov    %eax,(%esp)
  80302f:	e8 e6 fb ff ff       	call   802c1a <fd_lookup>
  803034:	85 c0                	test   %eax,%eax
  803036:	78 0e                	js     803046 <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  803038:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80303b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80303e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  803041:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803046:	c9                   	leave  
  803047:	c3                   	ret    

00803048 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  803048:	55                   	push   %ebp
  803049:	89 e5                	mov    %esp,%ebp
  80304b:	53                   	push   %ebx
  80304c:	83 ec 24             	sub    $0x24,%esp
  80304f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  803052:	8d 45 f0             	lea    -0x10(%ebp),%eax
  803055:	89 44 24 04          	mov    %eax,0x4(%esp)
  803059:	89 1c 24             	mov    %ebx,(%esp)
  80305c:	e8 b9 fb ff ff       	call   802c1a <fd_lookup>
  803061:	85 c0                	test   %eax,%eax
  803063:	78 61                	js     8030c6 <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  803065:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80306c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80306f:	8b 00                	mov    (%eax),%eax
  803071:	89 04 24             	mov    %eax,(%esp)
  803074:	e8 f7 fb ff ff       	call   802c70 <dev_lookup>
  803079:	85 c0                	test   %eax,%eax
  80307b:	78 49                	js     8030c6 <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80307d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803080:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  803084:	75 23                	jne    8030a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  803086:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80308b:	8b 40 48             	mov    0x48(%eax),%eax
  80308e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803092:	89 44 24 04          	mov    %eax,0x4(%esp)
  803096:	c7 04 24 50 45 80 00 	movl   $0x804550,(%esp)
  80309d:	e8 f6 ec ff ff       	call   801d98 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8030a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8030a7:	eb 1d                	jmp    8030c6 <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8030a9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8030ac:	8b 52 18             	mov    0x18(%edx),%edx
  8030af:	85 d2                	test   %edx,%edx
  8030b1:	74 0e                	je     8030c1 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8030b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8030b6:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8030ba:	89 04 24             	mov    %eax,(%esp)
  8030bd:	ff d2                	call   *%edx
  8030bf:	eb 05                	jmp    8030c6 <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8030c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8030c6:	83 c4 24             	add    $0x24,%esp
  8030c9:	5b                   	pop    %ebx
  8030ca:	5d                   	pop    %ebp
  8030cb:	c3                   	ret    

008030cc <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8030cc:	55                   	push   %ebp
  8030cd:	89 e5                	mov    %esp,%ebp
  8030cf:	53                   	push   %ebx
  8030d0:	83 ec 24             	sub    $0x24,%esp
  8030d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8030d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8030d9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8030e0:	89 04 24             	mov    %eax,(%esp)
  8030e3:	e8 32 fb ff ff       	call   802c1a <fd_lookup>
  8030e8:	85 c0                	test   %eax,%eax
  8030ea:	78 52                	js     80313e <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8030ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8030f6:	8b 00                	mov    (%eax),%eax
  8030f8:	89 04 24             	mov    %eax,(%esp)
  8030fb:	e8 70 fb ff ff       	call   802c70 <dev_lookup>
  803100:	85 c0                	test   %eax,%eax
  803102:	78 3a                	js     80313e <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  803104:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803107:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80310b:	74 2c                	je     803139 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80310d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  803110:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  803117:	00 00 00 
	stat->st_isdir = 0;
  80311a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803121:	00 00 00 
	stat->st_dev = dev;
  803124:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80312a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80312e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  803131:	89 14 24             	mov    %edx,(%esp)
  803134:	ff 50 14             	call   *0x14(%eax)
  803137:	eb 05                	jmp    80313e <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  803139:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80313e:	83 c4 24             	add    $0x24,%esp
  803141:	5b                   	pop    %ebx
  803142:	5d                   	pop    %ebp
  803143:	c3                   	ret    

00803144 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  803144:	55                   	push   %ebp
  803145:	89 e5                	mov    %esp,%ebp
  803147:	56                   	push   %esi
  803148:	53                   	push   %ebx
  803149:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80314c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  803153:	00 
  803154:	8b 45 08             	mov    0x8(%ebp),%eax
  803157:	89 04 24             	mov    %eax,(%esp)
  80315a:	e8 fe 01 00 00       	call   80335d <open>
  80315f:	89 c3                	mov    %eax,%ebx
  803161:	85 c0                	test   %eax,%eax
  803163:	78 1b                	js     803180 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  803165:	8b 45 0c             	mov    0xc(%ebp),%eax
  803168:	89 44 24 04          	mov    %eax,0x4(%esp)
  80316c:	89 1c 24             	mov    %ebx,(%esp)
  80316f:	e8 58 ff ff ff       	call   8030cc <fstat>
  803174:	89 c6                	mov    %eax,%esi
	close(fd);
  803176:	89 1c 24             	mov    %ebx,(%esp)
  803179:	e8 d4 fb ff ff       	call   802d52 <close>
	return r;
  80317e:	89 f3                	mov    %esi,%ebx
}
  803180:	89 d8                	mov    %ebx,%eax
  803182:	83 c4 10             	add    $0x10,%esp
  803185:	5b                   	pop    %ebx
  803186:	5e                   	pop    %esi
  803187:	5d                   	pop    %ebp
  803188:	c3                   	ret    
  803189:	00 00                	add    %al,(%eax)
	...

0080318c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80318c:	55                   	push   %ebp
  80318d:	89 e5                	mov    %esp,%ebp
  80318f:	56                   	push   %esi
  803190:	53                   	push   %ebx
  803191:	83 ec 10             	sub    $0x10,%esp
  803194:	89 c3                	mov    %eax,%ebx
  803196:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  803198:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  80319f:	75 11                	jne    8031b2 <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8031a1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8031a8:	e8 a8 f9 ff ff       	call   802b55 <ipc_find_env>
  8031ad:	a3 00 a0 80 00       	mov    %eax,0x80a000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8031b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8031b9:	00 
  8031ba:	c7 44 24 08 00 b0 80 	movl   $0x80b000,0x8(%esp)
  8031c1:	00 
  8031c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8031c6:	a1 00 a0 80 00       	mov    0x80a000,%eax
  8031cb:	89 04 24             	mov    %eax,(%esp)
  8031ce:	e8 18 f9 ff ff       	call   802aeb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8031d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8031da:	00 
  8031db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8031df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031e6:	e8 99 f8 ff ff       	call   802a84 <ipc_recv>
}
  8031eb:	83 c4 10             	add    $0x10,%esp
  8031ee:	5b                   	pop    %ebx
  8031ef:	5e                   	pop    %esi
  8031f0:	5d                   	pop    %ebp
  8031f1:	c3                   	ret    

008031f2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8031f2:	55                   	push   %ebp
  8031f3:	89 e5                	mov    %esp,%ebp
  8031f5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8031f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8031fb:	8b 40 0c             	mov    0xc(%eax),%eax
  8031fe:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  803203:	8b 45 0c             	mov    0xc(%ebp),%eax
  803206:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80320b:	ba 00 00 00 00       	mov    $0x0,%edx
  803210:	b8 02 00 00 00       	mov    $0x2,%eax
  803215:	e8 72 ff ff ff       	call   80318c <fsipc>
}
  80321a:	c9                   	leave  
  80321b:	c3                   	ret    

0080321c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80321c:	55                   	push   %ebp
  80321d:	89 e5                	mov    %esp,%ebp
  80321f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  803222:	8b 45 08             	mov    0x8(%ebp),%eax
  803225:	8b 40 0c             	mov    0xc(%eax),%eax
  803228:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  80322d:	ba 00 00 00 00       	mov    $0x0,%edx
  803232:	b8 06 00 00 00       	mov    $0x6,%eax
  803237:	e8 50 ff ff ff       	call   80318c <fsipc>
}
  80323c:	c9                   	leave  
  80323d:	c3                   	ret    

0080323e <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80323e:	55                   	push   %ebp
  80323f:	89 e5                	mov    %esp,%ebp
  803241:	53                   	push   %ebx
  803242:	83 ec 14             	sub    $0x14,%esp
  803245:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  803248:	8b 45 08             	mov    0x8(%ebp),%eax
  80324b:	8b 40 0c             	mov    0xc(%eax),%eax
  80324e:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  803253:	ba 00 00 00 00       	mov    $0x0,%edx
  803258:	b8 05 00 00 00       	mov    $0x5,%eax
  80325d:	e8 2a ff ff ff       	call   80318c <fsipc>
  803262:	85 c0                	test   %eax,%eax
  803264:	78 2b                	js     803291 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  803266:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  80326d:	00 
  80326e:	89 1c 24             	mov    %ebx,(%esp)
  803271:	e8 ed f0 ff ff       	call   802363 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  803276:	a1 80 b0 80 00       	mov    0x80b080,%eax
  80327b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  803281:	a1 84 b0 80 00       	mov    0x80b084,%eax
  803286:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80328c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  803291:	83 c4 14             	add    $0x14,%esp
  803294:	5b                   	pop    %ebx
  803295:	5d                   	pop    %ebp
  803296:	c3                   	ret    

00803297 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  803297:	55                   	push   %ebp
  803298:	89 e5                	mov    %esp,%ebp
  80329a:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  80329d:	c7 44 24 08 c0 45 80 	movl   $0x8045c0,0x8(%esp)
  8032a4:	00 
  8032a5:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  8032ac:	00 
  8032ad:	c7 04 24 de 45 80 00 	movl   $0x8045de,(%esp)
  8032b4:	e8 e7 e9 ff ff       	call   801ca0 <_panic>

008032b9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8032b9:	55                   	push   %ebp
  8032ba:	89 e5                	mov    %esp,%ebp
  8032bc:	56                   	push   %esi
  8032bd:	53                   	push   %ebx
  8032be:	83 ec 10             	sub    $0x10,%esp
  8032c1:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8032c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8032c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8032ca:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  8032cf:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8032d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8032da:	b8 03 00 00 00       	mov    $0x3,%eax
  8032df:	e8 a8 fe ff ff       	call   80318c <fsipc>
  8032e4:	89 c3                	mov    %eax,%ebx
  8032e6:	85 c0                	test   %eax,%eax
  8032e8:	78 6a                	js     803354 <devfile_read+0x9b>
		return r;
	assert(r <= n);
  8032ea:	39 c6                	cmp    %eax,%esi
  8032ec:	73 24                	jae    803312 <devfile_read+0x59>
  8032ee:	c7 44 24 0c e9 45 80 	movl   $0x8045e9,0xc(%esp)
  8032f5:	00 
  8032f6:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  8032fd:	00 
  8032fe:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  803305:	00 
  803306:	c7 04 24 de 45 80 00 	movl   $0x8045de,(%esp)
  80330d:	e8 8e e9 ff ff       	call   801ca0 <_panic>
	assert(r <= PGSIZE);
  803312:	3d 00 10 00 00       	cmp    $0x1000,%eax
  803317:	7e 24                	jle    80333d <devfile_read+0x84>
  803319:	c7 44 24 0c f0 45 80 	movl   $0x8045f0,0xc(%esp)
  803320:	00 
  803321:	c7 44 24 08 fd 3b 80 	movl   $0x803bfd,0x8(%esp)
  803328:	00 
  803329:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  803330:	00 
  803331:	c7 04 24 de 45 80 00 	movl   $0x8045de,(%esp)
  803338:	e8 63 e9 ff ff       	call   801ca0 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80333d:	89 44 24 08          	mov    %eax,0x8(%esp)
  803341:	c7 44 24 04 00 b0 80 	movl   $0x80b000,0x4(%esp)
  803348:	00 
  803349:	8b 45 0c             	mov    0xc(%ebp),%eax
  80334c:	89 04 24             	mov    %eax,(%esp)
  80334f:	e8 88 f1 ff ff       	call   8024dc <memmove>
	return r;
}
  803354:	89 d8                	mov    %ebx,%eax
  803356:	83 c4 10             	add    $0x10,%esp
  803359:	5b                   	pop    %ebx
  80335a:	5e                   	pop    %esi
  80335b:	5d                   	pop    %ebp
  80335c:	c3                   	ret    

0080335d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80335d:	55                   	push   %ebp
  80335e:	89 e5                	mov    %esp,%ebp
  803360:	56                   	push   %esi
  803361:	53                   	push   %ebx
  803362:	83 ec 20             	sub    $0x20,%esp
  803365:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  803368:	89 34 24             	mov    %esi,(%esp)
  80336b:	e8 c0 ef ff ff       	call   802330 <strlen>
  803370:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  803375:	7f 60                	jg     8033d7 <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  803377:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80337a:	89 04 24             	mov    %eax,(%esp)
  80337d:	e8 45 f8 ff ff       	call   802bc7 <fd_alloc>
  803382:	89 c3                	mov    %eax,%ebx
  803384:	85 c0                	test   %eax,%eax
  803386:	78 54                	js     8033dc <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  803388:	89 74 24 04          	mov    %esi,0x4(%esp)
  80338c:	c7 04 24 00 b0 80 00 	movl   $0x80b000,(%esp)
  803393:	e8 cb ef ff ff       	call   802363 <strcpy>
	fsipcbuf.open.req_omode = mode;
  803398:	8b 45 0c             	mov    0xc(%ebp),%eax
  80339b:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8033a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8033a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8033a8:	e8 df fd ff ff       	call   80318c <fsipc>
  8033ad:	89 c3                	mov    %eax,%ebx
  8033af:	85 c0                	test   %eax,%eax
  8033b1:	79 15                	jns    8033c8 <open+0x6b>
		fd_close(fd, 0);
  8033b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8033ba:	00 
  8033bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033be:	89 04 24             	mov    %eax,(%esp)
  8033c1:	e8 04 f9 ff ff       	call   802cca <fd_close>
		return r;
  8033c6:	eb 14                	jmp    8033dc <open+0x7f>
	}

	return fd2num(fd);
  8033c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8033cb:	89 04 24             	mov    %eax,(%esp)
  8033ce:	e8 c9 f7 ff ff       	call   802b9c <fd2num>
  8033d3:	89 c3                	mov    %eax,%ebx
  8033d5:	eb 05                	jmp    8033dc <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8033d7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8033dc:	89 d8                	mov    %ebx,%eax
  8033de:	83 c4 20             	add    $0x20,%esp
  8033e1:	5b                   	pop    %ebx
  8033e2:	5e                   	pop    %esi
  8033e3:	5d                   	pop    %ebp
  8033e4:	c3                   	ret    

008033e5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8033e5:	55                   	push   %ebp
  8033e6:	89 e5                	mov    %esp,%ebp
  8033e8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8033eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8033f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8033f5:	e8 92 fd ff ff       	call   80318c <fsipc>
}
  8033fa:	c9                   	leave  
  8033fb:	c3                   	ret    

008033fc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8033fc:	55                   	push   %ebp
  8033fd:	89 e5                	mov    %esp,%ebp
  8033ff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  803402:	89 c2                	mov    %eax,%edx
  803404:	c1 ea 16             	shr    $0x16,%edx
  803407:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80340e:	f6 c2 01             	test   $0x1,%dl
  803411:	74 1e                	je     803431 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  803413:	c1 e8 0c             	shr    $0xc,%eax
  803416:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80341d:	a8 01                	test   $0x1,%al
  80341f:	74 17                	je     803438 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803421:	c1 e8 0c             	shr    $0xc,%eax
  803424:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  80342b:	ef 
  80342c:	0f b7 c0             	movzwl %ax,%eax
  80342f:	eb 0c                	jmp    80343d <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  803431:	b8 00 00 00 00       	mov    $0x0,%eax
  803436:	eb 05                	jmp    80343d <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  803438:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  80343d:	5d                   	pop    %ebp
  80343e:	c3                   	ret    
	...

00803440 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803440:	55                   	push   %ebp
  803441:	89 e5                	mov    %esp,%ebp
  803443:	56                   	push   %esi
  803444:	53                   	push   %ebx
  803445:	83 ec 10             	sub    $0x10,%esp
  803448:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80344b:	8b 45 08             	mov    0x8(%ebp),%eax
  80344e:	89 04 24             	mov    %eax,(%esp)
  803451:	e8 56 f7 ff ff       	call   802bac <fd2data>
  803456:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  803458:	c7 44 24 04 fc 45 80 	movl   $0x8045fc,0x4(%esp)
  80345f:	00 
  803460:	89 34 24             	mov    %esi,(%esp)
  803463:	e8 fb ee ff ff       	call   802363 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803468:	8b 43 04             	mov    0x4(%ebx),%eax
  80346b:	2b 03                	sub    (%ebx),%eax
  80346d:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  803473:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  80347a:	00 00 00 
	stat->st_dev = &devpipe;
  80347d:	c7 86 88 00 00 00 80 	movl   $0x809080,0x88(%esi)
  803484:	90 80 00 
	return 0;
}
  803487:	b8 00 00 00 00       	mov    $0x0,%eax
  80348c:	83 c4 10             	add    $0x10,%esp
  80348f:	5b                   	pop    %ebx
  803490:	5e                   	pop    %esi
  803491:	5d                   	pop    %ebp
  803492:	c3                   	ret    

00803493 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803493:	55                   	push   %ebp
  803494:	89 e5                	mov    %esp,%ebp
  803496:	53                   	push   %ebx
  803497:	83 ec 14             	sub    $0x14,%esp
  80349a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80349d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8034a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034a8:	e8 4f f3 ff ff       	call   8027fc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8034ad:	89 1c 24             	mov    %ebx,(%esp)
  8034b0:	e8 f7 f6 ff ff       	call   802bac <fd2data>
  8034b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8034b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8034c0:	e8 37 f3 ff ff       	call   8027fc <sys_page_unmap>
}
  8034c5:	83 c4 14             	add    $0x14,%esp
  8034c8:	5b                   	pop    %ebx
  8034c9:	5d                   	pop    %ebp
  8034ca:	c3                   	ret    

008034cb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8034cb:	55                   	push   %ebp
  8034cc:	89 e5                	mov    %esp,%ebp
  8034ce:	57                   	push   %edi
  8034cf:	56                   	push   %esi
  8034d0:	53                   	push   %ebx
  8034d1:	83 ec 2c             	sub    $0x2c,%esp
  8034d4:	89 c7                	mov    %eax,%edi
  8034d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8034d9:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8034de:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8034e1:	89 3c 24             	mov    %edi,(%esp)
  8034e4:	e8 13 ff ff ff       	call   8033fc <pageref>
  8034e9:	89 c6                	mov    %eax,%esi
  8034eb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8034ee:	89 04 24             	mov    %eax,(%esp)
  8034f1:	e8 06 ff ff ff       	call   8033fc <pageref>
  8034f6:	39 c6                	cmp    %eax,%esi
  8034f8:	0f 94 c0             	sete   %al
  8034fb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8034fe:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  803504:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  803507:	39 cb                	cmp    %ecx,%ebx
  803509:	75 08                	jne    803513 <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  80350b:	83 c4 2c             	add    $0x2c,%esp
  80350e:	5b                   	pop    %ebx
  80350f:	5e                   	pop    %esi
  803510:	5f                   	pop    %edi
  803511:	5d                   	pop    %ebp
  803512:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  803513:	83 f8 01             	cmp    $0x1,%eax
  803516:	75 c1                	jne    8034d9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803518:	8b 42 58             	mov    0x58(%edx),%eax
  80351b:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  803522:	00 
  803523:	89 44 24 08          	mov    %eax,0x8(%esp)
  803527:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80352b:	c7 04 24 03 46 80 00 	movl   $0x804603,(%esp)
  803532:	e8 61 e8 ff ff       	call   801d98 <cprintf>
  803537:	eb a0                	jmp    8034d9 <_pipeisclosed+0xe>

00803539 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803539:	55                   	push   %ebp
  80353a:	89 e5                	mov    %esp,%ebp
  80353c:	57                   	push   %edi
  80353d:	56                   	push   %esi
  80353e:	53                   	push   %ebx
  80353f:	83 ec 1c             	sub    $0x1c,%esp
  803542:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803545:	89 34 24             	mov    %esi,(%esp)
  803548:	e8 5f f6 ff ff       	call   802bac <fd2data>
  80354d:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80354f:	bf 00 00 00 00       	mov    $0x0,%edi
  803554:	eb 3c                	jmp    803592 <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803556:	89 da                	mov    %ebx,%edx
  803558:	89 f0                	mov    %esi,%eax
  80355a:	e8 6c ff ff ff       	call   8034cb <_pipeisclosed>
  80355f:	85 c0                	test   %eax,%eax
  803561:	75 38                	jne    80359b <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803563:	e8 ce f1 ff ff       	call   802736 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803568:	8b 43 04             	mov    0x4(%ebx),%eax
  80356b:	8b 13                	mov    (%ebx),%edx
  80356d:	83 c2 20             	add    $0x20,%edx
  803570:	39 d0                	cmp    %edx,%eax
  803572:	73 e2                	jae    803556 <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803574:	8b 55 0c             	mov    0xc(%ebp),%edx
  803577:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  80357a:	89 c2                	mov    %eax,%edx
  80357c:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  803582:	79 05                	jns    803589 <devpipe_write+0x50>
  803584:	4a                   	dec    %edx
  803585:	83 ca e0             	or     $0xffffffe0,%edx
  803588:	42                   	inc    %edx
  803589:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80358d:	40                   	inc    %eax
  80358e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  803591:	47                   	inc    %edi
  803592:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803595:	75 d1                	jne    803568 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803597:	89 f8                	mov    %edi,%eax
  803599:	eb 05                	jmp    8035a0 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80359b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8035a0:	83 c4 1c             	add    $0x1c,%esp
  8035a3:	5b                   	pop    %ebx
  8035a4:	5e                   	pop    %esi
  8035a5:	5f                   	pop    %edi
  8035a6:	5d                   	pop    %ebp
  8035a7:	c3                   	ret    

008035a8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8035a8:	55                   	push   %ebp
  8035a9:	89 e5                	mov    %esp,%ebp
  8035ab:	57                   	push   %edi
  8035ac:	56                   	push   %esi
  8035ad:	53                   	push   %ebx
  8035ae:	83 ec 1c             	sub    $0x1c,%esp
  8035b1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8035b4:	89 3c 24             	mov    %edi,(%esp)
  8035b7:	e8 f0 f5 ff ff       	call   802bac <fd2data>
  8035bc:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035be:	be 00 00 00 00       	mov    $0x0,%esi
  8035c3:	eb 3a                	jmp    8035ff <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8035c5:	85 f6                	test   %esi,%esi
  8035c7:	74 04                	je     8035cd <devpipe_read+0x25>
				return i;
  8035c9:	89 f0                	mov    %esi,%eax
  8035cb:	eb 40                	jmp    80360d <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8035cd:	89 da                	mov    %ebx,%edx
  8035cf:	89 f8                	mov    %edi,%eax
  8035d1:	e8 f5 fe ff ff       	call   8034cb <_pipeisclosed>
  8035d6:	85 c0                	test   %eax,%eax
  8035d8:	75 2e                	jne    803608 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8035da:	e8 57 f1 ff ff       	call   802736 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8035df:	8b 03                	mov    (%ebx),%eax
  8035e1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8035e4:	74 df                	je     8035c5 <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8035e6:	25 1f 00 00 80       	and    $0x8000001f,%eax
  8035eb:	79 05                	jns    8035f2 <devpipe_read+0x4a>
  8035ed:	48                   	dec    %eax
  8035ee:	83 c8 e0             	or     $0xffffffe0,%eax
  8035f1:	40                   	inc    %eax
  8035f2:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  8035f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8035f9:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  8035fc:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8035fe:	46                   	inc    %esi
  8035ff:	3b 75 10             	cmp    0x10(%ebp),%esi
  803602:	75 db                	jne    8035df <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803604:	89 f0                	mov    %esi,%eax
  803606:	eb 05                	jmp    80360d <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803608:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80360d:	83 c4 1c             	add    $0x1c,%esp
  803610:	5b                   	pop    %ebx
  803611:	5e                   	pop    %esi
  803612:	5f                   	pop    %edi
  803613:	5d                   	pop    %ebp
  803614:	c3                   	ret    

00803615 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803615:	55                   	push   %ebp
  803616:	89 e5                	mov    %esp,%ebp
  803618:	57                   	push   %edi
  803619:	56                   	push   %esi
  80361a:	53                   	push   %ebx
  80361b:	83 ec 3c             	sub    $0x3c,%esp
  80361e:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803621:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  803624:	89 04 24             	mov    %eax,(%esp)
  803627:	e8 9b f5 ff ff       	call   802bc7 <fd_alloc>
  80362c:	89 c3                	mov    %eax,%ebx
  80362e:	85 c0                	test   %eax,%eax
  803630:	0f 88 45 01 00 00    	js     80377b <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803636:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  80363d:	00 
  80363e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803641:	89 44 24 04          	mov    %eax,0x4(%esp)
  803645:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80364c:	e8 04 f1 ff ff       	call   802755 <sys_page_alloc>
  803651:	89 c3                	mov    %eax,%ebx
  803653:	85 c0                	test   %eax,%eax
  803655:	0f 88 20 01 00 00    	js     80377b <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80365b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80365e:	89 04 24             	mov    %eax,(%esp)
  803661:	e8 61 f5 ff ff       	call   802bc7 <fd_alloc>
  803666:	89 c3                	mov    %eax,%ebx
  803668:	85 c0                	test   %eax,%eax
  80366a:	0f 88 f8 00 00 00    	js     803768 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803670:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803677:	00 
  803678:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80367b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80367f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803686:	e8 ca f0 ff ff       	call   802755 <sys_page_alloc>
  80368b:	89 c3                	mov    %eax,%ebx
  80368d:	85 c0                	test   %eax,%eax
  80368f:	0f 88 d3 00 00 00    	js     803768 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  803695:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803698:	89 04 24             	mov    %eax,(%esp)
  80369b:	e8 0c f5 ff ff       	call   802bac <fd2data>
  8036a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036a2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  8036a9:	00 
  8036aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8036ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036b5:	e8 9b f0 ff ff       	call   802755 <sys_page_alloc>
  8036ba:	89 c3                	mov    %eax,%ebx
  8036bc:	85 c0                	test   %eax,%eax
  8036be:	0f 88 91 00 00 00    	js     803755 <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8036c4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8036c7:	89 04 24             	mov    %eax,(%esp)
  8036ca:	e8 dd f4 ff ff       	call   802bac <fd2data>
  8036cf:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  8036d6:	00 
  8036d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8036db:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8036e2:	00 
  8036e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8036e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8036ee:	e8 b6 f0 ff ff       	call   8027a9 <sys_page_map>
  8036f3:	89 c3                	mov    %eax,%ebx
  8036f5:	85 c0                	test   %eax,%eax
  8036f7:	78 4c                	js     803745 <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8036f9:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8036ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803702:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803704:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803707:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80370e:	8b 15 80 90 80 00    	mov    0x809080,%edx
  803714:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803717:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803719:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80371c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803723:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803726:	89 04 24             	mov    %eax,(%esp)
  803729:	e8 6e f4 ff ff       	call   802b9c <fd2num>
  80372e:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803730:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803733:	89 04 24             	mov    %eax,(%esp)
  803736:	e8 61 f4 ff ff       	call   802b9c <fd2num>
  80373b:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  80373e:	bb 00 00 00 00       	mov    $0x0,%ebx
  803743:	eb 36                	jmp    80377b <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  803745:	89 74 24 04          	mov    %esi,0x4(%esp)
  803749:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803750:	e8 a7 f0 ff ff       	call   8027fc <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  803755:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803758:	89 44 24 04          	mov    %eax,0x4(%esp)
  80375c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803763:	e8 94 f0 ff ff       	call   8027fc <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803768:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80376b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80376f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803776:	e8 81 f0 ff ff       	call   8027fc <sys_page_unmap>
    err:
	return r;
}
  80377b:	89 d8                	mov    %ebx,%eax
  80377d:	83 c4 3c             	add    $0x3c,%esp
  803780:	5b                   	pop    %ebx
  803781:	5e                   	pop    %esi
  803782:	5f                   	pop    %edi
  803783:	5d                   	pop    %ebp
  803784:	c3                   	ret    

00803785 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  803785:	55                   	push   %ebp
  803786:	89 e5                	mov    %esp,%ebp
  803788:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80378b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80378e:	89 44 24 04          	mov    %eax,0x4(%esp)
  803792:	8b 45 08             	mov    0x8(%ebp),%eax
  803795:	89 04 24             	mov    %eax,(%esp)
  803798:	e8 7d f4 ff ff       	call   802c1a <fd_lookup>
  80379d:	85 c0                	test   %eax,%eax
  80379f:	78 15                	js     8037b6 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8037a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037a4:	89 04 24             	mov    %eax,(%esp)
  8037a7:	e8 00 f4 ff ff       	call   802bac <fd2data>
	return _pipeisclosed(fd, p);
  8037ac:	89 c2                	mov    %eax,%edx
  8037ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8037b1:	e8 15 fd ff ff       	call   8034cb <_pipeisclosed>
}
  8037b6:	c9                   	leave  
  8037b7:	c3                   	ret    

008037b8 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8037b8:	55                   	push   %ebp
  8037b9:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8037bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8037c0:	5d                   	pop    %ebp
  8037c1:	c3                   	ret    

008037c2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8037c2:	55                   	push   %ebp
  8037c3:	89 e5                	mov    %esp,%ebp
  8037c5:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8037c8:	c7 44 24 04 1b 46 80 	movl   $0x80461b,0x4(%esp)
  8037cf:	00 
  8037d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8037d3:	89 04 24             	mov    %eax,(%esp)
  8037d6:	e8 88 eb ff ff       	call   802363 <strcpy>
	return 0;
}
  8037db:	b8 00 00 00 00       	mov    $0x0,%eax
  8037e0:	c9                   	leave  
  8037e1:	c3                   	ret    

008037e2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8037e2:	55                   	push   %ebp
  8037e3:	89 e5                	mov    %esp,%ebp
  8037e5:	57                   	push   %edi
  8037e6:	56                   	push   %esi
  8037e7:	53                   	push   %ebx
  8037e8:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037ee:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8037f3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8037f9:	eb 30                	jmp    80382b <devcons_write+0x49>
		m = n - tot;
  8037fb:	8b 75 10             	mov    0x10(%ebp),%esi
  8037fe:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803800:	83 fe 7f             	cmp    $0x7f,%esi
  803803:	76 05                	jbe    80380a <devcons_write+0x28>
			m = sizeof(buf) - 1;
  803805:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80380a:	89 74 24 08          	mov    %esi,0x8(%esp)
  80380e:	03 45 0c             	add    0xc(%ebp),%eax
  803811:	89 44 24 04          	mov    %eax,0x4(%esp)
  803815:	89 3c 24             	mov    %edi,(%esp)
  803818:	e8 bf ec ff ff       	call   8024dc <memmove>
		sys_cputs(buf, m);
  80381d:	89 74 24 04          	mov    %esi,0x4(%esp)
  803821:	89 3c 24             	mov    %edi,(%esp)
  803824:	e8 5f ee ff ff       	call   802688 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803829:	01 f3                	add    %esi,%ebx
  80382b:	89 d8                	mov    %ebx,%eax
  80382d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803830:	72 c9                	jb     8037fb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  803832:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803838:	5b                   	pop    %ebx
  803839:	5e                   	pop    %esi
  80383a:	5f                   	pop    %edi
  80383b:	5d                   	pop    %ebp
  80383c:	c3                   	ret    

0080383d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80383d:	55                   	push   %ebp
  80383e:	89 e5                	mov    %esp,%ebp
  803840:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  803843:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803847:	75 07                	jne    803850 <devcons_read+0x13>
  803849:	eb 25                	jmp    803870 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80384b:	e8 e6 ee ff ff       	call   802736 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803850:	e8 51 ee ff ff       	call   8026a6 <sys_cgetc>
  803855:	85 c0                	test   %eax,%eax
  803857:	74 f2                	je     80384b <devcons_read+0xe>
  803859:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  80385b:	85 c0                	test   %eax,%eax
  80385d:	78 1d                	js     80387c <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80385f:	83 f8 04             	cmp    $0x4,%eax
  803862:	74 13                	je     803877 <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  803864:	8b 45 0c             	mov    0xc(%ebp),%eax
  803867:	88 10                	mov    %dl,(%eax)
	return 1;
  803869:	b8 01 00 00 00       	mov    $0x1,%eax
  80386e:	eb 0c                	jmp    80387c <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  803870:	b8 00 00 00 00       	mov    $0x0,%eax
  803875:	eb 05                	jmp    80387c <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  803877:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80387c:	c9                   	leave  
  80387d:	c3                   	ret    

0080387e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80387e:	55                   	push   %ebp
  80387f:	89 e5                	mov    %esp,%ebp
  803881:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  803884:	8b 45 08             	mov    0x8(%ebp),%eax
  803887:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80388a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  803891:	00 
  803892:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803895:	89 04 24             	mov    %eax,(%esp)
  803898:	e8 eb ed ff ff       	call   802688 <sys_cputs>
}
  80389d:	c9                   	leave  
  80389e:	c3                   	ret    

0080389f <getchar>:

int
getchar(void)
{
  80389f:	55                   	push   %ebp
  8038a0:	89 e5                	mov    %esp,%ebp
  8038a2:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8038a5:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8038ac:	00 
  8038ad:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8038b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8038bb:	e8 f6 f5 ff ff       	call   802eb6 <read>
	if (r < 0)
  8038c0:	85 c0                	test   %eax,%eax
  8038c2:	78 0f                	js     8038d3 <getchar+0x34>
		return r;
	if (r < 1)
  8038c4:	85 c0                	test   %eax,%eax
  8038c6:	7e 06                	jle    8038ce <getchar+0x2f>
		return -E_EOF;
	return c;
  8038c8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8038cc:	eb 05                	jmp    8038d3 <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8038ce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8038d3:	c9                   	leave  
  8038d4:	c3                   	ret    

008038d5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8038d5:	55                   	push   %ebp
  8038d6:	89 e5                	mov    %esp,%ebp
  8038d8:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8038db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8038de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8038e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8038e5:	89 04 24             	mov    %eax,(%esp)
  8038e8:	e8 2d f3 ff ff       	call   802c1a <fd_lookup>
  8038ed:	85 c0                	test   %eax,%eax
  8038ef:	78 11                	js     803902 <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8038f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8038f4:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8038fa:	39 10                	cmp    %edx,(%eax)
  8038fc:	0f 94 c0             	sete   %al
  8038ff:	0f b6 c0             	movzbl %al,%eax
}
  803902:	c9                   	leave  
  803903:	c3                   	ret    

00803904 <opencons>:

int
opencons(void)
{
  803904:	55                   	push   %ebp
  803905:	89 e5                	mov    %esp,%ebp
  803907:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80390a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80390d:	89 04 24             	mov    %eax,(%esp)
  803910:	e8 b2 f2 ff ff       	call   802bc7 <fd_alloc>
  803915:	85 c0                	test   %eax,%eax
  803917:	78 3c                	js     803955 <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803919:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803920:	00 
  803921:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803924:	89 44 24 04          	mov    %eax,0x4(%esp)
  803928:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80392f:	e8 21 ee ff ff       	call   802755 <sys_page_alloc>
  803934:	85 c0                	test   %eax,%eax
  803936:	78 1d                	js     803955 <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803938:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  80393e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803941:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803943:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803946:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80394d:	89 04 24             	mov    %eax,(%esp)
  803950:	e8 47 f2 ff ff       	call   802b9c <fd2num>
}
  803955:	c9                   	leave  
  803956:	c3                   	ret    
	...

00803958 <__udivdi3>:
  803958:	55                   	push   %ebp
  803959:	57                   	push   %edi
  80395a:	56                   	push   %esi
  80395b:	83 ec 10             	sub    $0x10,%esp
  80395e:	8b 74 24 20          	mov    0x20(%esp),%esi
  803962:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  803966:	89 74 24 04          	mov    %esi,0x4(%esp)
  80396a:	8b 7c 24 24          	mov    0x24(%esp),%edi
  80396e:	89 cd                	mov    %ecx,%ebp
  803970:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  803974:	85 c0                	test   %eax,%eax
  803976:	75 2c                	jne    8039a4 <__udivdi3+0x4c>
  803978:	39 f9                	cmp    %edi,%ecx
  80397a:	77 68                	ja     8039e4 <__udivdi3+0x8c>
  80397c:	85 c9                	test   %ecx,%ecx
  80397e:	75 0b                	jne    80398b <__udivdi3+0x33>
  803980:	b8 01 00 00 00       	mov    $0x1,%eax
  803985:	31 d2                	xor    %edx,%edx
  803987:	f7 f1                	div    %ecx
  803989:	89 c1                	mov    %eax,%ecx
  80398b:	31 d2                	xor    %edx,%edx
  80398d:	89 f8                	mov    %edi,%eax
  80398f:	f7 f1                	div    %ecx
  803991:	89 c7                	mov    %eax,%edi
  803993:	89 f0                	mov    %esi,%eax
  803995:	f7 f1                	div    %ecx
  803997:	89 c6                	mov    %eax,%esi
  803999:	89 f0                	mov    %esi,%eax
  80399b:	89 fa                	mov    %edi,%edx
  80399d:	83 c4 10             	add    $0x10,%esp
  8039a0:	5e                   	pop    %esi
  8039a1:	5f                   	pop    %edi
  8039a2:	5d                   	pop    %ebp
  8039a3:	c3                   	ret    
  8039a4:	39 f8                	cmp    %edi,%eax
  8039a6:	77 2c                	ja     8039d4 <__udivdi3+0x7c>
  8039a8:	0f bd f0             	bsr    %eax,%esi
  8039ab:	83 f6 1f             	xor    $0x1f,%esi
  8039ae:	75 4c                	jne    8039fc <__udivdi3+0xa4>
  8039b0:	39 f8                	cmp    %edi,%eax
  8039b2:	bf 00 00 00 00       	mov    $0x0,%edi
  8039b7:	72 0a                	jb     8039c3 <__udivdi3+0x6b>
  8039b9:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8039bd:	0f 87 ad 00 00 00    	ja     803a70 <__udivdi3+0x118>
  8039c3:	be 01 00 00 00       	mov    $0x1,%esi
  8039c8:	89 f0                	mov    %esi,%eax
  8039ca:	89 fa                	mov    %edi,%edx
  8039cc:	83 c4 10             	add    $0x10,%esp
  8039cf:	5e                   	pop    %esi
  8039d0:	5f                   	pop    %edi
  8039d1:	5d                   	pop    %ebp
  8039d2:	c3                   	ret    
  8039d3:	90                   	nop
  8039d4:	31 ff                	xor    %edi,%edi
  8039d6:	31 f6                	xor    %esi,%esi
  8039d8:	89 f0                	mov    %esi,%eax
  8039da:	89 fa                	mov    %edi,%edx
  8039dc:	83 c4 10             	add    $0x10,%esp
  8039df:	5e                   	pop    %esi
  8039e0:	5f                   	pop    %edi
  8039e1:	5d                   	pop    %ebp
  8039e2:	c3                   	ret    
  8039e3:	90                   	nop
  8039e4:	89 fa                	mov    %edi,%edx
  8039e6:	89 f0                	mov    %esi,%eax
  8039e8:	f7 f1                	div    %ecx
  8039ea:	89 c6                	mov    %eax,%esi
  8039ec:	31 ff                	xor    %edi,%edi
  8039ee:	89 f0                	mov    %esi,%eax
  8039f0:	89 fa                	mov    %edi,%edx
  8039f2:	83 c4 10             	add    $0x10,%esp
  8039f5:	5e                   	pop    %esi
  8039f6:	5f                   	pop    %edi
  8039f7:	5d                   	pop    %ebp
  8039f8:	c3                   	ret    
  8039f9:	8d 76 00             	lea    0x0(%esi),%esi
  8039fc:	89 f1                	mov    %esi,%ecx
  8039fe:	d3 e0                	shl    %cl,%eax
  803a00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803a04:	b8 20 00 00 00       	mov    $0x20,%eax
  803a09:	29 f0                	sub    %esi,%eax
  803a0b:	89 ea                	mov    %ebp,%edx
  803a0d:	88 c1                	mov    %al,%cl
  803a0f:	d3 ea                	shr    %cl,%edx
  803a11:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  803a15:	09 ca                	or     %ecx,%edx
  803a17:	89 54 24 08          	mov    %edx,0x8(%esp)
  803a1b:	89 f1                	mov    %esi,%ecx
  803a1d:	d3 e5                	shl    %cl,%ebp
  803a1f:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  803a23:	89 fd                	mov    %edi,%ebp
  803a25:	88 c1                	mov    %al,%cl
  803a27:	d3 ed                	shr    %cl,%ebp
  803a29:	89 fa                	mov    %edi,%edx
  803a2b:	89 f1                	mov    %esi,%ecx
  803a2d:	d3 e2                	shl    %cl,%edx
  803a2f:	8b 7c 24 04          	mov    0x4(%esp),%edi
  803a33:	88 c1                	mov    %al,%cl
  803a35:	d3 ef                	shr    %cl,%edi
  803a37:	09 d7                	or     %edx,%edi
  803a39:	89 f8                	mov    %edi,%eax
  803a3b:	89 ea                	mov    %ebp,%edx
  803a3d:	f7 74 24 08          	divl   0x8(%esp)
  803a41:	89 d1                	mov    %edx,%ecx
  803a43:	89 c7                	mov    %eax,%edi
  803a45:	f7 64 24 0c          	mull   0xc(%esp)
  803a49:	39 d1                	cmp    %edx,%ecx
  803a4b:	72 17                	jb     803a64 <__udivdi3+0x10c>
  803a4d:	74 09                	je     803a58 <__udivdi3+0x100>
  803a4f:	89 fe                	mov    %edi,%esi
  803a51:	31 ff                	xor    %edi,%edi
  803a53:	e9 41 ff ff ff       	jmp    803999 <__udivdi3+0x41>
  803a58:	8b 54 24 04          	mov    0x4(%esp),%edx
  803a5c:	89 f1                	mov    %esi,%ecx
  803a5e:	d3 e2                	shl    %cl,%edx
  803a60:	39 c2                	cmp    %eax,%edx
  803a62:	73 eb                	jae    803a4f <__udivdi3+0xf7>
  803a64:	8d 77 ff             	lea    -0x1(%edi),%esi
  803a67:	31 ff                	xor    %edi,%edi
  803a69:	e9 2b ff ff ff       	jmp    803999 <__udivdi3+0x41>
  803a6e:	66 90                	xchg   %ax,%ax
  803a70:	31 f6                	xor    %esi,%esi
  803a72:	e9 22 ff ff ff       	jmp    803999 <__udivdi3+0x41>
	...

00803a78 <__umoddi3>:
  803a78:	55                   	push   %ebp
  803a79:	57                   	push   %edi
  803a7a:	56                   	push   %esi
  803a7b:	83 ec 20             	sub    $0x20,%esp
  803a7e:	8b 44 24 30          	mov    0x30(%esp),%eax
  803a82:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  803a86:	89 44 24 14          	mov    %eax,0x14(%esp)
  803a8a:	8b 74 24 34          	mov    0x34(%esp),%esi
  803a8e:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  803a92:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  803a96:	89 c7                	mov    %eax,%edi
  803a98:	89 f2                	mov    %esi,%edx
  803a9a:	85 ed                	test   %ebp,%ebp
  803a9c:	75 16                	jne    803ab4 <__umoddi3+0x3c>
  803a9e:	39 f1                	cmp    %esi,%ecx
  803aa0:	0f 86 a6 00 00 00    	jbe    803b4c <__umoddi3+0xd4>
  803aa6:	f7 f1                	div    %ecx
  803aa8:	89 d0                	mov    %edx,%eax
  803aaa:	31 d2                	xor    %edx,%edx
  803aac:	83 c4 20             	add    $0x20,%esp
  803aaf:	5e                   	pop    %esi
  803ab0:	5f                   	pop    %edi
  803ab1:	5d                   	pop    %ebp
  803ab2:	c3                   	ret    
  803ab3:	90                   	nop
  803ab4:	39 f5                	cmp    %esi,%ebp
  803ab6:	0f 87 ac 00 00 00    	ja     803b68 <__umoddi3+0xf0>
  803abc:	0f bd c5             	bsr    %ebp,%eax
  803abf:	83 f0 1f             	xor    $0x1f,%eax
  803ac2:	89 44 24 10          	mov    %eax,0x10(%esp)
  803ac6:	0f 84 a8 00 00 00    	je     803b74 <__umoddi3+0xfc>
  803acc:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803ad0:	d3 e5                	shl    %cl,%ebp
  803ad2:	bf 20 00 00 00       	mov    $0x20,%edi
  803ad7:	2b 7c 24 10          	sub    0x10(%esp),%edi
  803adb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803adf:	89 f9                	mov    %edi,%ecx
  803ae1:	d3 e8                	shr    %cl,%eax
  803ae3:	09 e8                	or     %ebp,%eax
  803ae5:	89 44 24 18          	mov    %eax,0x18(%esp)
  803ae9:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803aed:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803af1:	d3 e0                	shl    %cl,%eax
  803af3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803af7:	89 f2                	mov    %esi,%edx
  803af9:	d3 e2                	shl    %cl,%edx
  803afb:	8b 44 24 14          	mov    0x14(%esp),%eax
  803aff:	d3 e0                	shl    %cl,%eax
  803b01:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  803b05:	8b 44 24 14          	mov    0x14(%esp),%eax
  803b09:	89 f9                	mov    %edi,%ecx
  803b0b:	d3 e8                	shr    %cl,%eax
  803b0d:	09 d0                	or     %edx,%eax
  803b0f:	d3 ee                	shr    %cl,%esi
  803b11:	89 f2                	mov    %esi,%edx
  803b13:	f7 74 24 18          	divl   0x18(%esp)
  803b17:	89 d6                	mov    %edx,%esi
  803b19:	f7 64 24 0c          	mull   0xc(%esp)
  803b1d:	89 c5                	mov    %eax,%ebp
  803b1f:	89 d1                	mov    %edx,%ecx
  803b21:	39 d6                	cmp    %edx,%esi
  803b23:	72 67                	jb     803b8c <__umoddi3+0x114>
  803b25:	74 75                	je     803b9c <__umoddi3+0x124>
  803b27:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803b2b:	29 e8                	sub    %ebp,%eax
  803b2d:	19 ce                	sbb    %ecx,%esi
  803b2f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803b33:	d3 e8                	shr    %cl,%eax
  803b35:	89 f2                	mov    %esi,%edx
  803b37:	89 f9                	mov    %edi,%ecx
  803b39:	d3 e2                	shl    %cl,%edx
  803b3b:	09 d0                	or     %edx,%eax
  803b3d:	89 f2                	mov    %esi,%edx
  803b3f:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803b43:	d3 ea                	shr    %cl,%edx
  803b45:	83 c4 20             	add    $0x20,%esp
  803b48:	5e                   	pop    %esi
  803b49:	5f                   	pop    %edi
  803b4a:	5d                   	pop    %ebp
  803b4b:	c3                   	ret    
  803b4c:	85 c9                	test   %ecx,%ecx
  803b4e:	75 0b                	jne    803b5b <__umoddi3+0xe3>
  803b50:	b8 01 00 00 00       	mov    $0x1,%eax
  803b55:	31 d2                	xor    %edx,%edx
  803b57:	f7 f1                	div    %ecx
  803b59:	89 c1                	mov    %eax,%ecx
  803b5b:	89 f0                	mov    %esi,%eax
  803b5d:	31 d2                	xor    %edx,%edx
  803b5f:	f7 f1                	div    %ecx
  803b61:	89 f8                	mov    %edi,%eax
  803b63:	e9 3e ff ff ff       	jmp    803aa6 <__umoddi3+0x2e>
  803b68:	89 f2                	mov    %esi,%edx
  803b6a:	83 c4 20             	add    $0x20,%esp
  803b6d:	5e                   	pop    %esi
  803b6e:	5f                   	pop    %edi
  803b6f:	5d                   	pop    %ebp
  803b70:	c3                   	ret    
  803b71:	8d 76 00             	lea    0x0(%esi),%esi
  803b74:	39 f5                	cmp    %esi,%ebp
  803b76:	72 04                	jb     803b7c <__umoddi3+0x104>
  803b78:	39 f9                	cmp    %edi,%ecx
  803b7a:	77 06                	ja     803b82 <__umoddi3+0x10a>
  803b7c:	89 f2                	mov    %esi,%edx
  803b7e:	29 cf                	sub    %ecx,%edi
  803b80:	19 ea                	sbb    %ebp,%edx
  803b82:	89 f8                	mov    %edi,%eax
  803b84:	83 c4 20             	add    $0x20,%esp
  803b87:	5e                   	pop    %esi
  803b88:	5f                   	pop    %edi
  803b89:	5d                   	pop    %ebp
  803b8a:	c3                   	ret    
  803b8b:	90                   	nop
  803b8c:	89 d1                	mov    %edx,%ecx
  803b8e:	89 c5                	mov    %eax,%ebp
  803b90:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  803b94:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  803b98:	eb 8d                	jmp    803b27 <__umoddi3+0xaf>
  803b9a:	66 90                	xchg   %ax,%ax
  803b9c:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  803ba0:	72 ea                	jb     803b8c <__umoddi3+0x114>
  803ba2:	89 f1                	mov    %esi,%ecx
  803ba4:	eb 81                	jmp    803b27 <__umoddi3+0xaf>
