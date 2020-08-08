
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
  80002c:	e8 17 15 00 00       	call   801548 <libmain>
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
  8000b0:	c7 04 24 c0 34 80 00 	movl   $0x8034c0,(%esp)
  8000b7:	e8 f4 15 00 00       	call   8016b0 <cprintf>
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
  8000d9:	c7 44 24 08 d7 34 80 	movl   $0x8034d7,0x8(%esp)
  8000e0:	00 
  8000e1:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  8000e8:	00 
  8000e9:	c7 04 24 e7 34 80 00 	movl   $0x8034e7,(%esp)
  8000f0:	e8 c3 14 00 00       	call   8015b8 <_panic>
	diskno = d;
  8000f5:	a3 00 40 80 00       	mov    %eax,0x804000
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
  800116:	c7 44 24 0c f0 34 80 	movl   $0x8034f0,0xc(%esp)
  80011d:	00 
  80011e:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  800125:	00 
  800126:	c7 44 24 04 44 00 00 	movl   $0x44,0x4(%esp)
  80012d:	00 
  80012e:	c7 04 24 e7 34 80 00 	movl   $0x8034e7,(%esp)
  800135:	e8 7e 14 00 00       	call   8015b8 <_panic>

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
  800161:	a1 00 40 80 00       	mov    0x804000,%eax
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
  8001d0:	c7 44 24 0c f0 34 80 	movl   $0x8034f0,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 e7 34 80 00 	movl   $0x8034e7,(%esp)
  8001ef:	e8 c4 13 00 00       	call   8015b8 <_panic>

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
  80021b:	a1 00 40 80 00       	mov    0x804000,%eax
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
  800273:	53                   	push   %ebx
  800274:	83 ec 24             	sub    $0x24,%esp
  800277:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80027a:	8b 02                	mov    (%edx),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80027c:	8d 88 00 00 00 f0    	lea    -0x10000000(%eax),%ecx
  800282:	81 f9 ff ff ff bf    	cmp    $0xbfffffff,%ecx
  800288:	76 2e                	jbe    8002b8 <bc_pgfault+0x48>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  80028a:	8b 4a 04             	mov    0x4(%edx),%ecx
  80028d:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  800291:	89 44 24 10          	mov    %eax,0x10(%esp)
  800295:	8b 42 28             	mov    0x28(%edx),%eax
  800298:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80029c:	c7 44 24 08 14 35 80 	movl   $0x803514,0x8(%esp)
  8002a3:	00 
  8002a4:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  8002ab:	00 
  8002ac:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  8002b3:	e8 00 13 00 00       	call   8015b8 <_panic>
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
	void *addr = (void *) utf->utf_fault_va;
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  8002b8:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
  8002be:	c1 eb 0c             	shr    $0xc,%ebx
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("page fault in FS: eip %08x, va %08x, err %04x",
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002c1:	8b 15 08 90 80 00    	mov    0x809008,%edx
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 25                	je     8002f0 <bc_pgfault+0x80>
  8002cb:	3b 5a 04             	cmp    0x4(%edx),%ebx
  8002ce:	72 20                	jb     8002f0 <bc_pgfault+0x80>
		panic("reading non-existent block %08x\n", blockno);
  8002d0:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002d4:	c7 44 24 08 44 35 80 	movl   $0x803544,0x8(%esp)
  8002db:	00 
  8002dc:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  8002e3:	00 
  8002e4:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  8002eb:	e8 c8 12 00 00       	call   8015b8 <_panic>
	//
	// LAB 5: you code here:

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  8002f0:	89 c2                	mov    %eax,%edx
  8002f2:	c1 ea 0c             	shr    $0xc,%edx
  8002f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8002fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800302:	89 54 24 10          	mov    %edx,0x10(%esp)
  800306:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80030a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800311:	00 
  800312:	89 44 24 04          	mov    %eax,0x4(%esp)
  800316:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80031d:	e8 9f 1d 00 00       	call   8020c1 <sys_page_map>
  800322:	85 c0                	test   %eax,%eax
  800324:	79 20                	jns    800346 <bc_pgfault+0xd6>
		panic("in bc_pgfault, sys_page_map: %e", r);
  800326:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80032a:	c7 44 24 08 68 35 80 	movl   $0x803568,0x8(%esp)
  800331:	00 
  800332:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800339:	00 
  80033a:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  800341:	e8 72 12 00 00       	call   8015b8 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  800346:	83 3d 04 90 80 00 00 	cmpl   $0x0,0x809004
  80034d:	74 2c                	je     80037b <bc_pgfault+0x10b>
  80034f:	89 1c 24             	mov    %ebx,(%esp)
  800352:	e8 0e 02 00 00       	call   800565 <block_is_free>
  800357:	84 c0                	test   %al,%al
  800359:	74 20                	je     80037b <bc_pgfault+0x10b>
		panic("reading free block %08x\n", blockno);
  80035b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80035f:	c7 44 24 08 b2 35 80 	movl   $0x8035b2,0x8(%esp)
  800366:	00 
  800367:	c7 44 24 04 3d 00 00 	movl   $0x3d,0x4(%esp)
  80036e:	00 
  80036f:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  800376:	e8 3d 12 00 00       	call   8015b8 <_panic>
}
  80037b:	83 c4 24             	add    $0x24,%esp
  80037e:	5b                   	pop    %ebx
  80037f:	5d                   	pop    %ebp
  800380:	c3                   	ret    

00800381 <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  800381:	55                   	push   %ebp
  800382:	89 e5                	mov    %esp,%ebp
  800384:	83 ec 18             	sub    $0x18,%esp
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  80038a:	85 c0                	test   %eax,%eax
  80038c:	74 0f                	je     80039d <diskaddr+0x1c>
  80038e:	8b 15 08 90 80 00    	mov    0x809008,%edx
  800394:	85 d2                	test   %edx,%edx
  800396:	74 25                	je     8003bd <diskaddr+0x3c>
  800398:	3b 42 04             	cmp    0x4(%edx),%eax
  80039b:	72 20                	jb     8003bd <diskaddr+0x3c>
		panic("bad block number %08x in diskaddr", blockno);
  80039d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8003a1:	c7 44 24 08 88 35 80 	movl   $0x803588,0x8(%esp)
  8003a8:	00 
  8003a9:	c7 44 24 04 09 00 00 	movl   $0x9,0x4(%esp)
  8003b0:	00 
  8003b1:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  8003b8:	e8 fb 11 00 00       	call   8015b8 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bd:	05 00 00 01 00       	add    $0x10000,%eax
  8003c2:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c5:	c9                   	leave  
  8003c6:	c3                   	ret    

008003c7 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cd:	89 c2                	mov    %eax,%edx
  8003cf:	c1 ea 16             	shr    $0x16,%edx
  8003d2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d9:	f6 c2 01             	test   $0x1,%dl
  8003dc:	74 0f                	je     8003ed <va_is_mapped+0x26>
  8003de:	c1 e8 0c             	shr    $0xc,%eax
  8003e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003e8:	83 e0 01             	and    $0x1,%eax
  8003eb:	eb 05                	jmp    8003f2 <va_is_mapped+0x2b>
  8003ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	a8 40                	test   $0x40,%al
  800406:	0f 95 c0             	setne  %al
}
  800409:	5d                   	pop    %ebp
  80040a:	c3                   	ret    

0080040b <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040b:	55                   	push   %ebp
  80040c:	89 e5                	mov    %esp,%ebp
  80040e:	83 ec 18             	sub    $0x18,%esp
  800411:	8b 45 08             	mov    0x8(%ebp),%eax
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 90 00 00 00 f0    	lea    -0x10000000(%eax),%edx
  80041a:	81 fa ff ff ff bf    	cmp    $0xbfffffff,%edx
  800420:	76 20                	jbe    800442 <flush_block+0x37>
		panic("flush_block of bad va %08x", addr);
  800422:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800426:	c7 44 24 08 cb 35 80 	movl   $0x8035cb,0x8(%esp)
  80042d:	00 
  80042e:	c7 44 24 04 4d 00 00 	movl   $0x4d,0x4(%esp)
  800435:	00 
  800436:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  80043d:	e8 76 11 00 00       	call   8015b8 <_panic>

	// LAB 5: Your code here.
	panic("flush_block not implemented");
  800442:	c7 44 24 08 e6 35 80 	movl   $0x8035e6,0x8(%esp)
  800449:	00 
  80044a:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800451:	00 
  800452:	c7 04 24 aa 35 80 00 	movl   $0x8035aa,(%esp)
  800459:	e8 5a 11 00 00       	call   8015b8 <_panic>

0080045e <check_bc>:

// Test that the block cache works, by smashing the superblock and
// reading it back.
static void
check_bc(void)
{
  80045e:	55                   	push   %ebp
  80045f:	89 e5                	mov    %esp,%ebp
  800461:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  800467:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80046e:	e8 0e ff ff ff       	call   800381 <diskaddr>
  800473:	c7 44 24 08 08 01 00 	movl   $0x108,0x8(%esp)
  80047a:	00 
  80047b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80047f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800485:	89 04 24             	mov    %eax,(%esp)
  800488:	e8 67 19 00 00       	call   801df4 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  80048d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800494:	e8 e8 fe ff ff       	call   800381 <diskaddr>
  800499:	c7 44 24 04 02 36 80 	movl   $0x803602,0x4(%esp)
  8004a0:	00 
  8004a1:	89 04 24             	mov    %eax,(%esp)
  8004a4:	e8 d2 17 00 00       	call   801c7b <strcpy>
	flush_block(diskaddr(1));
  8004a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004b0:	e8 cc fe ff ff       	call   800381 <diskaddr>
  8004b5:	89 04 24             	mov    %eax,(%esp)
  8004b8:	e8 4e ff ff ff       	call   80040b <flush_block>

008004bd <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	83 ec 18             	sub    $0x18,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004c3:	c7 04 24 70 02 80 00 	movl   $0x800270,(%esp)
  8004ca:	e8 09 1e 00 00       	call   8022d8 <set_pgfault_handler>
	check_bc();
  8004cf:	e8 8a ff ff ff       	call   80045e <check_bc>

008004d4 <skip_slash>:
}

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
	while (*p == '/')
  8004d7:	eb 01                	jmp    8004da <skip_slash+0x6>
		p++;
  8004d9:	40                   	inc    %eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8004da:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004dd:	74 fa                	je     8004d9 <skip_slash+0x5>
		p++;
	return p;
}
  8004df:	5d                   	pop    %ebp
  8004e0:	c3                   	ret    

008004e1 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	83 ec 18             	sub    $0x18,%esp
       // LAB 5: Your code here.
       panic("file_block_walk not implemented");
  8004e7:	c7 44 24 08 0c 36 80 	movl   $0x80360c,0x8(%esp)
  8004ee:	00 
  8004ef:	c7 44 24 04 8a 00 00 	movl   $0x8a,0x4(%esp)
  8004f6:	00 
  8004f7:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  8004fe:	e8 b5 10 00 00       	call   8015b8 <_panic>

00800503 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800503:	55                   	push   %ebp
  800504:	89 e5                	mov    %esp,%ebp
  800506:	83 ec 18             	sub    $0x18,%esp
	if (super->s_magic != FS_MAGIC)
  800509:	a1 08 90 80 00       	mov    0x809008,%eax
  80050e:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800514:	74 1c                	je     800532 <check_super+0x2f>
		panic("bad file system magic number");
  800516:	c7 44 24 08 53 36 80 	movl   $0x803653,0x8(%esp)
  80051d:	00 
  80051e:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  800525:	00 
  800526:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  80052d:	e8 86 10 00 00       	call   8015b8 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  800532:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800539:	76 1c                	jbe    800557 <check_super+0x54>
		panic("file system is too large");
  80053b:	c7 44 24 08 70 36 80 	movl   $0x803670,0x8(%esp)
  800542:	00 
  800543:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  80054a:	00 
  80054b:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  800552:	e8 61 10 00 00       	call   8015b8 <_panic>

	cprintf("superblock is good\n");
  800557:	c7 04 24 89 36 80 00 	movl   $0x803689,(%esp)
  80055e:	e8 4d 11 00 00       	call   8016b0 <cprintf>
}
  800563:	c9                   	leave  
  800564:	c3                   	ret    

00800565 <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  80056b:	a1 08 90 80 00       	mov    0x809008,%eax
  800570:	85 c0                	test   %eax,%eax
  800572:	74 1d                	je     800591 <block_is_free+0x2c>
  800574:	39 48 04             	cmp    %ecx,0x4(%eax)
  800577:	76 1c                	jbe    800595 <block_is_free+0x30>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  800579:	b8 01 00 00 00       	mov    $0x1,%eax
  80057e:	d3 e0                	shl    %cl,%eax
  800580:	c1 e9 05             	shr    $0x5,%ecx
// --------------------------------------------------------------

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
  800583:	8b 15 04 90 80 00    	mov    0x809004,%edx
  800589:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  80058c:	0f 95 c0             	setne  %al
  80058f:	eb 06                	jmp    800597 <block_is_free+0x32>
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800591:	b0 00                	mov    $0x0,%al
  800593:	eb 02                	jmp    800597 <block_is_free+0x32>
  800595:	b0 00                	mov    $0x0,%al
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800597:	5d                   	pop    %ebp
  800598:	c3                   	ret    

00800599 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  800599:	55                   	push   %ebp
  80059a:	89 e5                	mov    %esp,%ebp
  80059c:	83 ec 18             	sub    $0x18,%esp
  80059f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  8005a2:	85 c9                	test   %ecx,%ecx
  8005a4:	75 1c                	jne    8005c2 <free_block+0x29>
		panic("attempt to free zero block");
  8005a6:	c7 44 24 08 9d 36 80 	movl   $0x80369d,0x8(%esp)
  8005ad:	00 
  8005ae:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8005b5:	00 
  8005b6:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  8005bd:	e8 f6 0f 00 00       	call   8015b8 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  8005c2:	89 c8                	mov    %ecx,%eax
  8005c4:	c1 e8 05             	shr    $0x5,%eax
  8005c7:	c1 e0 02             	shl    $0x2,%eax
  8005ca:	03 05 04 90 80 00    	add    0x809004,%eax
  8005d0:	ba 01 00 00 00       	mov    $0x1,%edx
  8005d5:	d3 e2                	shl    %cl,%edx
  8005d7:	09 10                	or     %edx,(%eax)
}
  8005d9:	c9                   	leave  
  8005da:	c3                   	ret    

008005db <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  8005db:	55                   	push   %ebp
  8005dc:	89 e5                	mov    %esp,%ebp
  8005de:	83 ec 18             	sub    $0x18,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.

	// LAB 5: Your code here.
	panic("alloc_block not implemented");
  8005e1:	c7 44 24 08 b8 36 80 	movl   $0x8036b8,0x8(%esp)
  8005e8:	00 
  8005e9:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8005f0:	00 
  8005f1:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  8005f8:	e8 bb 0f 00 00       	call   8015b8 <_panic>

008005fd <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  8005fd:	55                   	push   %ebp
  8005fe:	89 e5                	mov    %esp,%ebp
  800600:	53                   	push   %ebx
  800601:	83 ec 14             	sub    $0x14,%esp
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800604:	bb 00 00 00 00       	mov    $0x0,%ebx
  800609:	eb 34                	jmp    80063f <check_bitmap+0x42>
		assert(!block_is_free(2+i));
  80060b:	8d 43 02             	lea    0x2(%ebx),%eax
  80060e:	89 04 24             	mov    %eax,(%esp)
  800611:	e8 4f ff ff ff       	call   800565 <block_is_free>
  800616:	84 c0                	test   %al,%al
  800618:	74 24                	je     80063e <check_bitmap+0x41>
  80061a:	c7 44 24 0c d4 36 80 	movl   $0x8036d4,0xc(%esp)
  800621:	00 
  800622:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  800629:	00 
  80062a:	c7 44 24 04 50 00 00 	movl   $0x50,0x4(%esp)
  800631:	00 
  800632:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  800639:	e8 7a 0f 00 00       	call   8015b8 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80063e:	43                   	inc    %ebx
  80063f:	89 da                	mov    %ebx,%edx
  800641:	c1 e2 0f             	shl    $0xf,%edx
  800644:	a1 08 90 80 00       	mov    0x809008,%eax
  800649:	3b 50 04             	cmp    0x4(%eax),%edx
  80064c:	72 bd                	jb     80060b <check_bitmap+0xe>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80064e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800655:	e8 0b ff ff ff       	call   800565 <block_is_free>
  80065a:	84 c0                	test   %al,%al
  80065c:	74 24                	je     800682 <check_bitmap+0x85>
  80065e:	c7 44 24 0c e8 36 80 	movl   $0x8036e8,0xc(%esp)
  800665:	00 
  800666:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  80066d:	00 
  80066e:	c7 44 24 04 53 00 00 	movl   $0x53,0x4(%esp)
  800675:	00 
  800676:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  80067d:	e8 36 0f 00 00       	call   8015b8 <_panic>
	assert(!block_is_free(1));
  800682:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800689:	e8 d7 fe ff ff       	call   800565 <block_is_free>
  80068e:	84 c0                	test   %al,%al
  800690:	74 24                	je     8006b6 <check_bitmap+0xb9>
  800692:	c7 44 24 0c fa 36 80 	movl   $0x8036fa,0xc(%esp)
  800699:	00 
  80069a:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  8006a1:	00 
  8006a2:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8006a9:	00 
  8006aa:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  8006b1:	e8 02 0f 00 00       	call   8015b8 <_panic>

	cprintf("bitmap is good\n");
  8006b6:	c7 04 24 0c 37 80 00 	movl   $0x80370c,(%esp)
  8006bd:	e8 ee 0f 00 00       	call   8016b0 <cprintf>
}
  8006c2:	83 c4 14             	add    $0x14,%esp
  8006c5:	5b                   	pop    %ebx
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  8006ce:	e8 95 f9 ff ff       	call   800068 <ide_probe_disk1>
  8006d3:	84 c0                	test   %al,%al
  8006d5:	74 0e                	je     8006e5 <fs_init+0x1d>
		ide_set_disk(1);
  8006d7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006de:	e8 e8 f9 ff ff       	call   8000cb <ide_set_disk>
  8006e3:	eb 0c                	jmp    8006f1 <fs_init+0x29>
	else
		ide_set_disk(0);
  8006e5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8006ec:	e8 da f9 ff ff       	call   8000cb <ide_set_disk>
	bc_init();
  8006f1:	e8 c7 fd ff ff       	call   8004bd <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  8006f6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8006fd:	e8 7f fc ff ff       	call   800381 <diskaddr>
  800702:	a3 08 90 80 00       	mov    %eax,0x809008
	check_super();
  800707:	e8 f7 fd ff ff       	call   800503 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80070c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800713:	e8 69 fc ff ff       	call   800381 <diskaddr>
  800718:	a3 04 90 80 00       	mov    %eax,0x809004
	check_bitmap();
  80071d:	e8 db fe ff ff       	call   8005fd <check_bitmap>
	
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 18             	sub    $0x18,%esp
       // LAB 5: Your code here.
       panic("file_get_block not implemented");
  80072a:	c7 44 24 08 2c 36 80 	movl   $0x80362c,0x8(%esp)
  800731:	00 
  800732:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  800739:	00 
  80073a:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  800741:	e8 72 0e 00 00       	call   8015b8 <_panic>

00800746 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	57                   	push   %edi
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx
  80074c:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  800752:	89 95 54 ff ff ff    	mov    %edx,-0xac(%ebp)
  800758:	89 8d 50 ff ff ff    	mov    %ecx,-0xb0(%ebp)
	struct File *dir, *f;
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
  80075e:	e8 71 fd ff ff       	call   8004d4 <skip_slash>
	f = &super->s_root;
  800763:	8b 3d 08 90 80 00    	mov    0x809008,%edi
  800769:	8d 57 08             	lea    0x8(%edi),%edx
  80076c:	89 95 4c ff ff ff    	mov    %edx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  800772:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  800779:	83 bd 54 ff ff ff 00 	cmpl   $0x0,-0xac(%ebp)
  800780:	74 0c                	je     80078e <walk_path+0x48>
		*pdir = 0;
  800782:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  800788:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = 0;
  80078e:	8b 95 50 ff ff ff    	mov    -0xb0(%ebp),%edx
  800794:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	while (*path != '\0') {
  80079a:	80 38 00             	cmpb   $0x0,(%eax)
  80079d:	75 08                	jne    8007a7 <walk_path+0x61>
  80079f:	e9 fc 00 00 00       	jmp    8008a0 <walk_path+0x15a>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  8007a4:	43                   	inc    %ebx
  8007a5:	eb 02                	jmp    8007a9 <walk_path+0x63>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  8007a7:	89 c3                	mov    %eax,%ebx
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  8007a9:	8a 13                	mov    (%ebx),%dl
  8007ab:	80 fa 2f             	cmp    $0x2f,%dl
  8007ae:	74 04                	je     8007b4 <walk_path+0x6e>
  8007b0:	84 d2                	test   %dl,%dl
  8007b2:	75 f0                	jne    8007a4 <walk_path+0x5e>
			path++;
		if (path - p >= MAXNAMELEN)
  8007b4:	89 de                	mov    %ebx,%esi
  8007b6:	29 c6                	sub    %eax,%esi
  8007b8:	83 fe 7f             	cmp    $0x7f,%esi
  8007bb:	0f 8f 09 01 00 00    	jg     8008ca <walk_path+0x184>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  8007c1:	89 74 24 08          	mov    %esi,0x8(%esp)
  8007c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c9:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	e8 1d 16 00 00       	call   801df4 <memmove>
		name[path - p] = '\0';
  8007d7:	c6 84 35 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%esi,1)
  8007de:	00 
		path = skip_slash(path);
  8007df:	89 d8                	mov    %ebx,%eax
  8007e1:	e8 ee fc ff ff       	call   8004d4 <skip_slash>

		if (dir->f_type != FTYPE_DIR)
  8007e6:	83 bf 8c 00 00 00 01 	cmpl   $0x1,0x8c(%edi)
  8007ed:	0f 85 de 00 00 00    	jne    8008d1 <walk_path+0x18b>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  8007f3:	8b 97 88 00 00 00    	mov    0x88(%edi),%edx
  8007f9:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
  8007ff:	74 24                	je     800825 <walk_path+0xdf>
  800801:	c7 44 24 0c 1c 37 80 	movl   $0x80371c,0xc(%esp)
  800808:	00 
  800809:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  800810:	00 
  800811:	c7 44 24 04 ab 00 00 	movl   $0xab,0x4(%esp)
  800818:	00 
  800819:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  800820:	e8 93 0d 00 00       	call   8015b8 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800825:	89 d1                	mov    %edx,%ecx
  800827:	85 d2                	test   %edx,%edx
  800829:	79 06                	jns    800831 <walk_path+0xeb>
  80082b:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
	for (i = 0; i < nblock; i++) {
  800831:	c1 e9 0c             	shr    $0xc,%ecx
  800834:	74 20                	je     800856 <walk_path+0x110>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800836:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  80083c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800840:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800847:	00 
  800848:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	e8 ce fe ff ff       	call   800724 <file_get_block>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800856:	80 38 00             	cmpb   $0x0,(%eax)
  800859:	75 7d                	jne    8008d8 <walk_path+0x192>
				if (pdir)
  80085b:	83 bd 54 ff ff ff 00 	cmpl   $0x0,-0xac(%ebp)
  800862:	74 0e                	je     800872 <walk_path+0x12c>
					*pdir = dir;
  800864:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  80086a:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  800870:	89 02                	mov    %eax,(%edx)
				if (lastelem)
  800872:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800876:	74 15                	je     80088d <walk_path+0x147>
					strcpy(lastelem, name);
  800878:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  80087e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800882:	8b 55 08             	mov    0x8(%ebp),%edx
  800885:	89 14 24             	mov    %edx,(%esp)
  800888:	e8 ee 13 00 00       	call   801c7b <strcpy>
				*pf = 0;
  80088d:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  800893:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800899:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80089e:	eb 3d                	jmp    8008dd <walk_path+0x197>
		}
	}

	if (pdir)
  8008a0:	83 bd 54 ff ff ff 00 	cmpl   $0x0,-0xac(%ebp)
  8008a7:	74 0c                	je     8008b5 <walk_path+0x16f>
		*pdir = dir;
  8008a9:	8b 95 54 ff ff ff    	mov    -0xac(%ebp),%edx
  8008af:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	*pf = f;
  8008b5:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
  8008bb:	8b 85 50 ff ff ff    	mov    -0xb0(%ebp),%eax
  8008c1:	89 10                	mov    %edx,(%eax)
	return 0;
  8008c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c8:	eb 13                	jmp    8008dd <walk_path+0x197>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  8008ca:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8008cf:	eb 0c                	jmp    8008dd <walk_path+0x197>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  8008d1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  8008d6:	eb 05                	jmp    8008dd <walk_path+0x197>
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  8008d8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  8008dd:	81 c4 bc 00 00 00    	add    $0xbc,%esp
  8008e3:	5b                   	pop    %ebx
  8008e4:	5e                   	pop    %esi
  8008e5:	5f                   	pop    %edi
  8008e6:	5d                   	pop    %ebp
  8008e7:	c3                   	ret    

008008e8 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	56                   	push   %esi
  8008ec:	53                   	push   %ebx
  8008ed:	81 ec a0 00 00 00    	sub    $0xa0,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  8008f3:	8d 85 78 ff ff ff    	lea    -0x88(%ebp),%eax
  8008f9:	89 04 24             	mov    %eax,(%esp)
  8008fc:	8d 8d 70 ff ff ff    	lea    -0x90(%ebp),%ecx
  800902:	8d 95 74 ff ff ff    	lea    -0x8c(%ebp),%edx
  800908:	8b 45 08             	mov    0x8(%ebp),%eax
  80090b:	e8 36 fe ff ff       	call   800746 <walk_path>
  800910:	85 c0                	test   %eax,%eax
  800912:	0f 84 97 00 00 00    	je     8009af <file_create+0xc7>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800918:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80091b:	0f 85 93 00 00 00    	jne    8009b4 <file_create+0xcc>
  800921:	8b 8d 74 ff ff ff    	mov    -0x8c(%ebp),%ecx
  800927:	85 c9                	test   %ecx,%ecx
  800929:	0f 84 85 00 00 00    	je     8009b4 <file_create+0xcc>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  80092f:	8b 99 80 00 00 00    	mov    0x80(%ecx),%ebx
  800935:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
  80093b:	74 24                	je     800961 <file_create+0x79>
  80093d:	c7 44 24 0c 1c 37 80 	movl   $0x80371c,0xc(%esp)
  800944:	00 
  800945:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  80094c:	00 
  80094d:	c7 44 24 04 c4 00 00 	movl   $0xc4,0x4(%esp)
  800954:	00 
  800955:	c7 04 24 4b 36 80 00 	movl   $0x80364b,(%esp)
  80095c:	e8 57 0c 00 00       	call   8015b8 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800961:	be 00 10 00 00       	mov    $0x1000,%esi
  800966:	89 d8                	mov    %ebx,%eax
  800968:	99                   	cltd   
  800969:	f7 fe                	idiv   %esi
	for (i = 0; i < nblock; i++) {
  80096b:	85 c0                	test   %eax,%eax
  80096d:	74 1a                	je     800989 <file_create+0xa1>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  80096f:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  800975:	89 44 24 08          	mov    %eax,0x8(%esp)
  800979:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800980:	00 
  800981:	89 0c 24             	mov    %ecx,(%esp)
  800984:	e8 9b fd ff ff       	call   800724 <file_get_block>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800989:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80098f:	89 99 80 00 00 00    	mov    %ebx,0x80(%ecx)
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800995:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  80099b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80099f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8009a6:	00 
  8009a7:	89 0c 24             	mov    %ecx,(%esp)
  8009aa:	e8 75 fd ff ff       	call   800724 <file_get_block>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  8009af:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax

	strcpy(f->f_name, name);
	*pf = f;
	file_flush(dir);
	return 0;
}
  8009b4:	81 c4 a0 00 00 00    	add    $0xa0,%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 18             	sub    $0x18,%esp
	return walk_path(path, 0, pf, 0);
  8009c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8009cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	e8 6b fd ff ff       	call   800746 <walk_path>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	56                   	push   %esi
  8009e1:	53                   	push   %ebx
  8009e2:	83 ec 20             	sub    $0x20,%esp
  8009e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e8:	8b 75 10             	mov    0x10(%ebp),%esi
  8009eb:	8b 55 14             	mov    0x14(%ebp),%edx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  8009ee:	8b 81 80 00 00 00    	mov    0x80(%ecx),%eax
  8009f4:	39 d0                	cmp    %edx,%eax
  8009f6:	7e 32                	jle    800a2a <file_read+0x4d>
		return 0;

	count = MIN(count, f->f_size - offset);
  8009f8:	29 d0                	sub    %edx,%eax
  8009fa:	89 c3                	mov    %eax,%ebx
  8009fc:	39 f0                	cmp    %esi,%eax
  8009fe:	76 02                	jbe    800a02 <file_read+0x25>
  800a00:	89 f3                	mov    %esi,%ebx

	for (pos = offset; pos < offset + count; ) {
  800a02:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800a05:	39 c2                	cmp    %eax,%edx
  800a07:	73 1d                	jae    800a26 <file_read+0x49>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800a09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a10:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800a15:	89 d0                	mov    %edx,%eax
  800a17:	99                   	cltd   
  800a18:	f7 fb                	idiv   %ebx
  800a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1e:	89 0c 24             	mov    %ecx,(%esp)
  800a21:	e8 fe fc ff ff       	call   800724 <file_get_block>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800a26:	89 d8                	mov    %ebx,%eax
  800a28:	eb 05                	jmp    800a2f <file_read+0x52>
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
		return 0;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
		pos += bn;
		buf += bn;
	}

	return count;
}
  800a2f:	83 c4 20             	add    $0x20,%esp
  800a32:	5b                   	pop    %ebx
  800a33:	5e                   	pop    %esi
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	56                   	push   %esi
  800a3a:	53                   	push   %ebx
  800a3b:	83 ec 20             	sub    $0x20,%esp
  800a3e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a41:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (f->f_size > newsize)
  800a44:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800a4a:	39 f0                	cmp    %esi,%eax
  800a4c:	7e 5f                	jle    800aad <file_set_size+0x77>
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800a4e:	8d 8e ff 0f 00 00    	lea    0xfff(%esi),%ecx
  800a54:	89 ca                	mov    %ecx,%edx
  800a56:	85 c9                	test   %ecx,%ecx
  800a58:	79 06                	jns    800a60 <file_set_size+0x2a>
  800a5a:	8d 96 fe 1f 00 00    	lea    0x1ffe(%esi),%edx
  800a60:	c1 fa 0c             	sar    $0xc,%edx
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800a63:	05 ff 0f 00 00       	add    $0xfff,%eax
  800a68:	89 c1                	mov    %eax,%ecx
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	79 06                	jns    800a74 <file_set_size+0x3e>
  800a6e:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
  800a74:	c1 f9 0c             	sar    $0xc,%ecx
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800a77:	39 d1                	cmp    %edx,%ecx
  800a79:	76 11                	jbe    800a8c <file_set_size+0x56>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800a7b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800a82:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800a85:	89 d8                	mov    %ebx,%eax
  800a87:	e8 55 fa ff ff       	call   8004e1 <file_block_walk>
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800a8c:	83 fa 0a             	cmp    $0xa,%edx
  800a8f:	77 1c                	ja     800aad <file_set_size+0x77>
  800a91:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800a97:	85 c0                	test   %eax,%eax
  800a99:	74 12                	je     800aad <file_set_size+0x77>
		free_block(f->f_indirect);
  800a9b:	89 04 24             	mov    %eax,(%esp)
  800a9e:	e8 f6 fa ff ff       	call   800599 <free_block>
		f->f_indirect = 0;
  800aa3:	c7 83 b0 00 00 00 00 	movl   $0x0,0xb0(%ebx)
  800aaa:	00 00 00 
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800aad:	89 b3 80 00 00 00    	mov    %esi,0x80(%ebx)
	flush_block(f);
  800ab3:	89 1c 24             	mov    %ebx,(%esp)
  800ab6:	e8 50 f9 ff ff       	call   80040b <flush_block>
	return 0;
}
  800abb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac0:	83 c4 20             	add    $0x20,%esp
  800ac3:	5b                   	pop    %ebx
  800ac4:	5e                   	pop    %esi
  800ac5:	5d                   	pop    %ebp
  800ac6:	c3                   	ret    

00800ac7 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	57                   	push   %edi
  800acb:	56                   	push   %esi
  800acc:	53                   	push   %ebx
  800acd:	83 ec 2c             	sub    $0x2c,%esp
  800ad0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ad3:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800ad6:	8d 1c 3e             	lea    (%esi,%edi,1),%ebx
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	3b 98 80 00 00 00    	cmp    0x80(%eax),%ebx
  800ae2:	76 10                	jbe    800af4 <file_write+0x2d>
		if ((r = file_set_size(f, offset + count)) < 0)
  800ae4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	e8 46 ff ff ff       	call   800a36 <file_set_size>
  800af0:	85 c0                	test   %eax,%eax
  800af2:	78 26                	js     800b1a <file_write+0x53>
			return r;

	for (pos = offset; pos < offset + count; ) {
  800af4:	39 de                	cmp    %ebx,%esi
  800af6:	73 20                	jae    800b18 <file_write+0x51>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800af8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800afb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aff:	b9 00 10 00 00       	mov    $0x1000,%ecx
  800b04:	89 f0                	mov    %esi,%eax
  800b06:	99                   	cltd   
  800b07:	f7 f9                	idiv   %ecx
  800b09:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	89 04 24             	mov    %eax,(%esp)
  800b13:	e8 0c fc ff ff       	call   800724 <file_get_block>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800b18:	89 f8                	mov    %edi,%eax
}
  800b1a:	83 c4 2c             	add    $0x2c,%esp
  800b1d:	5b                   	pop    %ebx
  800b1e:	5e                   	pop    %esi
  800b1f:	5f                   	pop    %edi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    

00800b22 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	53                   	push   %ebx
  800b26:	83 ec 24             	sub    $0x24,%esp
  800b29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800b2c:	8b 83 80 00 00 00    	mov    0x80(%ebx),%eax
  800b32:	05 ff 0f 00 00       	add    $0xfff,%eax
  800b37:	3d ff 0f 00 00       	cmp    $0xfff,%eax
  800b3c:	7e 16                	jle    800b54 <file_flush+0x32>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800b3e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800b45:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800b48:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4d:	89 d8                	mov    %ebx,%eax
  800b4f:	e8 8d f9 ff ff       	call   8004e1 <file_block_walk>
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800b54:	89 1c 24             	mov    %ebx,(%esp)
  800b57:	e8 af f8 ff ff       	call   80040b <flush_block>
	if (f->f_indirect)
  800b5c:	8b 83 b0 00 00 00    	mov    0xb0(%ebx),%eax
  800b62:	85 c0                	test   %eax,%eax
  800b64:	74 10                	je     800b76 <file_flush+0x54>
		flush_block(diskaddr(f->f_indirect));
  800b66:	89 04 24             	mov    %eax,(%esp)
  800b69:	e8 13 f8 ff ff       	call   800381 <diskaddr>
  800b6e:	89 04 24             	mov    %eax,(%esp)
  800b71:	e8 95 f8 ff ff       	call   80040b <flush_block>
}
  800b76:	83 c4 24             	add    $0x24,%esp
  800b79:	5b                   	pop    %ebx
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800b83:	bb 01 00 00 00       	mov    $0x1,%ebx
  800b88:	eb 11                	jmp    800b9b <fs_sync+0x1f>
		flush_block(diskaddr(i));
  800b8a:	89 1c 24             	mov    %ebx,(%esp)
  800b8d:	e8 ef f7 ff ff       	call   800381 <diskaddr>
  800b92:	89 04 24             	mov    %eax,(%esp)
  800b95:	e8 71 f8 ff ff       	call   80040b <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  800b9a:	43                   	inc    %ebx
  800b9b:	a1 08 90 80 00       	mov    0x809008,%eax
  800ba0:	3b 58 04             	cmp    0x4(%eax),%ebx
  800ba3:	72 e5                	jb     800b8a <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  800ba5:	83 c4 14             	add    $0x14,%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    
	...

00800bac <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// Lab 5: Your code here:
	return 0;
}
  800baf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb4:	5d                   	pop    %ebp
  800bb5:	c3                   	ret    

00800bb6 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  800bbc:	e8 bb ff ff ff       	call   800b7c <fs_sync>
	return 0;
}
  800bc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc6:	c9                   	leave  
  800bc7:	c3                   	ret    

00800bc8 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 18             	sub    $0x18,%esp
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);

	// LAB 5: Your code here.
	panic("serve_write not implemented");
  800bce:	c7 44 24 08 39 37 80 	movl   $0x803739,0x8(%esp)
  800bd5:	00 
  800bd6:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  800bdd:	00 
  800bde:	c7 04 24 55 37 80 00 	movl   $0x803755,(%esp)
  800be5:	e8 ce 09 00 00       	call   8015b8 <_panic>

00800bea <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800bed:	ba 60 40 80 00       	mov    $0x804060,%edx

void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
  800bf2:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  800bf7:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  800bfc:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  800bfe:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  800c01:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  800c07:	40                   	inc    %eax
  800c08:	83 c2 10             	add    $0x10,%edx
  800c0b:	3d 00 04 00 00       	cmp    $0x400,%eax
  800c10:	75 ea                	jne    800bfc <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    

00800c14 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	56                   	push   %esi
  800c18:	53                   	push   %ebx
  800c19:	83 ec 10             	sub    $0x10,%esp
  800c1c:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800c1f:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
}

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
  800c24:	89 d8                	mov    %ebx,%eax
  800c26:	c1 e0 04             	shl    $0x4,%eax
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
		switch (pageref(opentab[i].o_fd)) {
  800c29:	8b 80 6c 40 80 00    	mov    0x80406c(%eax),%eax
  800c2f:	89 04 24             	mov    %eax,(%esp)
  800c32:	e8 dd 20 00 00       	call   802d14 <pageref>
  800c37:	85 c0                	test   %eax,%eax
  800c39:	74 07                	je     800c42 <openfile_alloc+0x2e>
  800c3b:	83 f8 01             	cmp    $0x1,%eax
  800c3e:	75 62                	jne    800ca2 <openfile_alloc+0x8e>
  800c40:	eb 27                	jmp    800c69 <openfile_alloc+0x55>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  800c42:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800c49:	00 
  800c4a:	89 d8                	mov    %ebx,%eax
  800c4c:	c1 e0 04             	shl    $0x4,%eax
  800c4f:	8b 80 6c 40 80 00    	mov    0x80406c(%eax),%eax
  800c55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c59:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800c60:	e8 08 14 00 00       	call   80206d <sys_page_alloc>
  800c65:	85 c0                	test   %eax,%eax
  800c67:	78 4b                	js     800cb4 <openfile_alloc+0xa0>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  800c69:	c1 e3 04             	shl    $0x4,%ebx
  800c6c:	8d 83 60 40 80 00    	lea    0x804060(%ebx),%eax
  800c72:	81 83 60 40 80 00 00 	addl   $0x400,0x804060(%ebx)
  800c79:	04 00 00 
			*o = &opentab[i];
  800c7c:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  800c7e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  800c85:	00 
  800c86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800c8d:	00 
  800c8e:	8b 83 6c 40 80 00    	mov    0x80406c(%ebx),%eax
  800c94:	89 04 24             	mov    %eax,(%esp)
  800c97:	e8 0e 11 00 00       	call   801daa <memset>
			return (*o)->o_fileid;
  800c9c:	8b 06                	mov    (%esi),%eax
  800c9e:	8b 00                	mov    (%eax),%eax
  800ca0:	eb 12                	jmp    800cb4 <openfile_alloc+0xa0>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  800ca2:	43                   	inc    %ebx
  800ca3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800ca9:	0f 85 75 ff ff ff    	jne    800c24 <openfile_alloc+0x10>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  800caf:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800cb4:	83 c4 10             	add    $0x10,%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 1c             	sub    $0x1c,%esp
  800cc4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  800cc7:	89 fe                	mov    %edi,%esi
  800cc9:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800ccf:	c1 e6 04             	shl    $0x4,%esi
  800cd2:	8d 9e 60 40 80 00    	lea    0x804060(%esi),%ebx
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  800cd8:	8b 86 6c 40 80 00    	mov    0x80406c(%esi),%eax
  800cde:	89 04 24             	mov    %eax,(%esp)
  800ce1:	e8 2e 20 00 00       	call   802d14 <pageref>
  800ce6:	83 f8 01             	cmp    $0x1,%eax
  800ce9:	7e 14                	jle    800cff <openfile_lookup+0x44>
  800ceb:	39 be 60 40 80 00    	cmp    %edi,0x804060(%esi)
  800cf1:	75 13                	jne    800d06 <openfile_lookup+0x4b>
		return -E_INVAL;
	*po = o;
  800cf3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf6:	89 18                	mov    %ebx,(%eax)
	return 0;
  800cf8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cfd:	eb 0c                	jmp    800d0b <openfile_lookup+0x50>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  800cff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d04:	eb 05                	jmp    800d0b <openfile_lookup+0x50>
  800d06:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  800d0b:	83 c4 1c             	add    $0x1c,%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <serve_flush>:
}

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800d19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d23:	8b 00                	mov    (%eax),%eax
  800d25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d29:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2c:	89 04 24             	mov    %eax,(%esp)
  800d2f:	e8 87 ff ff ff       	call   800cbb <openfile_lookup>
  800d34:	85 c0                	test   %eax,%eax
  800d36:	78 13                	js     800d4b <serve_flush+0x38>
		return r;
	file_flush(o->o_file);
  800d38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d3b:	8b 40 04             	mov    0x4(%eax),%eax
  800d3e:	89 04 24             	mov    %eax,(%esp)
  800d41:	e8 dc fd ff ff       	call   800b22 <file_flush>
	return 0;
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	53                   	push   %ebx
  800d51:	83 ec 24             	sub    $0x24,%esp
  800d54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800d57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d5e:	8b 03                	mov    (%ebx),%eax
  800d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	89 04 24             	mov    %eax,(%esp)
  800d6a:	e8 4c ff ff ff       	call   800cbb <openfile_lookup>
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	78 3f                	js     800db2 <serve_stat+0x65>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  800d73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d76:	8b 40 04             	mov    0x4(%eax),%eax
  800d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d7d:	89 1c 24             	mov    %ebx,(%esp)
  800d80:	e8 f6 0e 00 00       	call   801c7b <strcpy>
	ret->ret_size = o->o_file->f_size;
  800d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d88:	8b 50 04             	mov    0x4(%eax),%edx
  800d8b:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  800d91:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  800d97:	8b 40 04             	mov    0x4(%eax),%eax
  800d9a:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800da1:	0f 94 c0             	sete   %al
  800da4:	0f b6 c0             	movzbl %al,%eax
  800da7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800dad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800db2:	83 c4 24             	add    $0x24,%esp
  800db5:	5b                   	pop    %ebx
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    

00800db8 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  800db8:	55                   	push   %ebp
  800db9:	89 e5                	mov    %esp,%ebp
  800dbb:	53                   	push   %ebx
  800dbc:	83 ec 24             	sub    $0x24,%esp
  800dbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  800dc2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800dc5:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc9:	8b 03                	mov    (%ebx),%eax
  800dcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd2:	89 04 24             	mov    %eax,(%esp)
  800dd5:	e8 e1 fe ff ff       	call   800cbb <openfile_lookup>
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	78 15                	js     800df3 <serve_set_size+0x3b>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  800dde:	8b 43 04             	mov    0x4(%ebx),%eax
  800de1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800de5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800de8:	8b 40 04             	mov    0x4(%eax),%eax
  800deb:	89 04 24             	mov    %eax,(%esp)
  800dee:	e8 43 fc ff ff       	call   800a36 <file_set_size>
}
  800df3:	83 c4 24             	add    $0x24,%esp
  800df6:	5b                   	pop    %ebx
  800df7:	5d                   	pop    %ebp
  800df8:	c3                   	ret    

00800df9 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	53                   	push   %ebx
  800dfd:	81 ec 24 04 00 00    	sub    $0x424,%esp
  800e03:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  800e06:	c7 44 24 08 00 04 00 	movl   $0x400,0x8(%esp)
  800e0d:	00 
  800e0e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800e12:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800e18:	89 04 24             	mov    %eax,(%esp)
  800e1b:	e8 d4 0f 00 00       	call   801df4 <memmove>
	path[MAXPATHLEN-1] = 0;
  800e20:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  800e24:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  800e2a:	89 04 24             	mov    %eax,(%esp)
  800e2d:	e8 e2 fd ff ff       	call   800c14 <openfile_alloc>
  800e32:	85 c0                	test   %eax,%eax
  800e34:	0f 88 f0 00 00 00    	js     800f2a <serve_open+0x131>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  800e3a:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  800e41:	74 32                	je     800e75 <serve_open+0x7c>
		if ((r = file_create(path, &f)) < 0) {
  800e43:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800e49:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e4d:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800e53:	89 04 24             	mov    %eax,(%esp)
  800e56:	e8 8d fa ff ff       	call   8008e8 <file_create>
  800e5b:	85 c0                	test   %eax,%eax
  800e5d:	79 36                	jns    800e95 <serve_open+0x9c>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  800e5f:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  800e66:	0f 85 be 00 00 00    	jne    800f2a <serve_open+0x131>
  800e6c:	83 f8 f3             	cmp    $0xfffffff3,%eax
  800e6f:	0f 85 b5 00 00 00    	jne    800f2a <serve_open+0x131>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  800e75:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800e7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e7f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800e85:	89 04 24             	mov    %eax,(%esp)
  800e88:	e8 31 fb ff ff       	call   8009be <file_open>
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	0f 88 95 00 00 00    	js     800f2a <serve_open+0x131>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  800e95:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  800e9c:	74 1a                	je     800eb8 <serve_open+0xbf>
		if ((r = file_set_size(f, 0)) < 0) {
  800e9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea5:	00 
  800ea6:	8b 85 f4 fb ff ff    	mov    -0x40c(%ebp),%eax
  800eac:	89 04 24             	mov    %eax,(%esp)
  800eaf:	e8 82 fb ff ff       	call   800a36 <file_set_size>
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	78 72                	js     800f2a <serve_open+0x131>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  800eb8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  800ebe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec2:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  800ec8:	89 04 24             	mov    %eax,(%esp)
  800ecb:	e8 ee fa ff ff       	call   8009be <file_open>
  800ed0:	85 c0                	test   %eax,%eax
  800ed2:	78 56                	js     800f2a <serve_open+0x131>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  800ed4:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800eda:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  800ee0:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  800ee3:	8b 50 0c             	mov    0xc(%eax),%edx
  800ee6:	8b 08                	mov    (%eax),%ecx
  800ee8:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  800eeb:	8b 50 0c             	mov    0xc(%eax),%edx
  800eee:	8b 8b 00 04 00 00    	mov    0x400(%ebx),%ecx
  800ef4:	83 e1 03             	and    $0x3,%ecx
  800ef7:	89 4a 08             	mov    %ecx,0x8(%edx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  800efa:	8b 40 0c             	mov    0xc(%eax),%eax
  800efd:	8b 15 64 80 80 00    	mov    0x808064,%edx
  800f03:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  800f05:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  800f0b:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  800f11:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  800f14:	8b 50 0c             	mov    0xc(%eax),%edx
  800f17:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1a:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  800f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1f:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  800f25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f2a:	81 c4 24 04 00 00    	add    $0x424,%esp
  800f30:	5b                   	pop    %ebx
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	56                   	push   %esi
  800f37:	53                   	push   %ebx
  800f38:	83 ec 20             	sub    $0x20,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800f3b:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  800f3e:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  800f41:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  800f48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f4c:	a1 44 40 80 00       	mov    0x804044,%eax
  800f51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f55:	89 34 24             	mov    %esi,(%esp)
  800f58:	e8 3f 14 00 00       	call   80239c <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  800f5d:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  800f61:	75 15                	jne    800f78 <serve+0x45>
			cprintf("Invalid request from %08x: no argument page\n",
  800f63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f66:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f6a:	c7 04 24 80 37 80 00 	movl   $0x803780,(%esp)
  800f71:	e8 3a 07 00 00       	call   8016b0 <cprintf>
				whom);
			continue; // just leave it hanging...
  800f76:	eb c9                	jmp    800f41 <serve+0xe>
		}

		pg = NULL;
  800f78:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  800f7f:	83 f8 01             	cmp    $0x1,%eax
  800f82:	75 21                	jne    800fa5 <serve+0x72>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  800f84:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f88:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800f8b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f8f:	a1 44 40 80 00       	mov    0x804044,%eax
  800f94:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9b:	89 04 24             	mov    %eax,(%esp)
  800f9e:	e8 56 fe ff ff       	call   800df9 <serve_open>
  800fa3:	eb 3f                	jmp    800fe4 <serve+0xb1>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  800fa5:	83 f8 08             	cmp    $0x8,%eax
  800fa8:	77 1e                	ja     800fc8 <serve+0x95>
  800faa:	8b 14 85 20 40 80 00 	mov    0x804020(,%eax,4),%edx
  800fb1:	85 d2                	test   %edx,%edx
  800fb3:	74 13                	je     800fc8 <serve+0x95>
			r = handlers[req](whom, fsreq);
  800fb5:	a1 44 40 80 00       	mov    0x804044,%eax
  800fba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc1:	89 04 24             	mov    %eax,(%esp)
  800fc4:	ff d2                	call   *%edx
  800fc6:	eb 1c                	jmp    800fe4 <serve+0xb1>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  800fc8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800fcb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fd3:	c7 04 24 b0 37 80 00 	movl   $0x8037b0,(%esp)
  800fda:	e8 d1 06 00 00       	call   8016b0 <cprintf>
			r = -E_INVAL;
  800fdf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  800fe4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fe7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800feb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  800fee:	89 54 24 08          	mov    %edx,0x8(%esp)
  800ff2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff9:	89 04 24             	mov    %eax,(%esp)
  800ffc:	e8 02 14 00 00       	call   802403 <ipc_send>
		sys_page_unmap(0, fsreq);
  801001:	a1 44 40 80 00       	mov    0x804044,%eax
  801006:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801011:	e8 fe 10 00 00       	call   802114 <sys_page_unmap>
  801016:	e9 26 ff ff ff       	jmp    800f41 <serve+0xe>

0080101b <umain>:
	}
}

void
umain(int argc, char **argv)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 18             	sub    $0x18,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801021:	c7 05 60 80 80 00 5f 	movl   $0x80375f,0x808060
  801028:	37 80 00 
	cprintf("FS is running\n");
  80102b:	c7 04 24 62 37 80 00 	movl   $0x803762,(%esp)
  801032:	e8 79 06 00 00       	call   8016b0 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801037:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  80103c:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801041:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801043:	c7 04 24 71 37 80 00 	movl   $0x803771,(%esp)
  80104a:	e8 61 06 00 00       	call   8016b0 <cprintf>

	serve_init();
  80104f:	e8 96 fb ff ff       	call   800bea <serve_init>
	fs_init();
  801054:	e8 6f f6 ff ff       	call   8006c8 <fs_init>
        fs_test();
  801059:	e8 06 00 00 00       	call   801064 <fs_test>
	serve();
  80105e:	e8 d0 fe ff ff       	call   800f33 <serve>
	...

00801064 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	53                   	push   %ebx
  801068:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  80106b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801072:	00 
  801073:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  80107a:	00 
  80107b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801082:	e8 e6 0f 00 00       	call   80206d <sys_page_alloc>
  801087:	85 c0                	test   %eax,%eax
  801089:	79 20                	jns    8010ab <fs_test+0x47>
		panic("sys_page_alloc: %e", r);
  80108b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80108f:	c7 44 24 08 d3 37 80 	movl   $0x8037d3,0x8(%esp)
  801096:	00 
  801097:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  80109e:	00 
  80109f:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8010a6:	e8 0d 05 00 00       	call   8015b8 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8010ab:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8010b2:	00 
  8010b3:	a1 04 90 80 00       	mov    0x809004,%eax
  8010b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010bc:	c7 04 24 00 10 00 00 	movl   $0x1000,(%esp)
  8010c3:	e8 2c 0d 00 00       	call   801df4 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8010c8:	e8 0e f5 ff ff       	call   8005db <alloc_block>
  8010cd:	85 c0                	test   %eax,%eax
  8010cf:	79 20                	jns    8010f1 <fs_test+0x8d>
		panic("alloc_block: %e", r);
  8010d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d5:	c7 44 24 08 f0 37 80 	movl   $0x8037f0,0x8(%esp)
  8010dc:	00 
  8010dd:	c7 44 24 04 17 00 00 	movl   $0x17,0x4(%esp)
  8010e4:	00 
  8010e5:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8010ec:	e8 c7 04 00 00       	call   8015b8 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8010f1:	89 c2                	mov    %eax,%edx
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	79 03                	jns    8010fa <fs_test+0x96>
  8010f7:	8d 50 1f             	lea    0x1f(%eax),%edx
  8010fa:	c1 fa 05             	sar    $0x5,%edx
  8010fd:	c1 e2 02             	shl    $0x2,%edx
  801100:	25 1f 00 00 80       	and    $0x8000001f,%eax
  801105:	79 05                	jns    80110c <fs_test+0xa8>
  801107:	48                   	dec    %eax
  801108:	83 c8 e0             	or     $0xffffffe0,%eax
  80110b:	40                   	inc    %eax
  80110c:	bb 01 00 00 00       	mov    $0x1,%ebx
  801111:	88 c1                	mov    %al,%cl
  801113:	d3 e3                	shl    %cl,%ebx
  801115:	85 9a 00 10 00 00    	test   %ebx,0x1000(%edx)
  80111b:	75 24                	jne    801141 <fs_test+0xdd>
  80111d:	c7 44 24 0c 00 38 80 	movl   $0x803800,0xc(%esp)
  801124:	00 
  801125:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  80112c:	00 
  80112d:	c7 44 24 04 19 00 00 	movl   $0x19,0x4(%esp)
  801134:	00 
  801135:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  80113c:	e8 77 04 00 00       	call   8015b8 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801141:	8b 0d 04 90 80 00    	mov    0x809004,%ecx
  801147:	85 1c 11             	test   %ebx,(%ecx,%edx,1)
  80114a:	74 24                	je     801170 <fs_test+0x10c>
  80114c:	c7 44 24 0c 78 39 80 	movl   $0x803978,0xc(%esp)
  801153:	00 
  801154:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  80115b:	00 
  80115c:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
  801163:	00 
  801164:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  80116b:	e8 48 04 00 00       	call   8015b8 <_panic>
	cprintf("alloc_block is good\n");
  801170:	c7 04 24 1b 38 80 00 	movl   $0x80381b,(%esp)
  801177:	e8 34 05 00 00       	call   8016b0 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80117c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801183:	c7 04 24 30 38 80 00 	movl   $0x803830,(%esp)
  80118a:	e8 2f f8 ff ff       	call   8009be <file_open>
  80118f:	85 c0                	test   %eax,%eax
  801191:	79 25                	jns    8011b8 <fs_test+0x154>
  801193:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801196:	74 40                	je     8011d8 <fs_test+0x174>
		panic("file_open /not-found: %e", r);
  801198:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80119c:	c7 44 24 08 3b 38 80 	movl   $0x80383b,0x8(%esp)
  8011a3:	00 
  8011a4:	c7 44 24 04 1f 00 00 	movl   $0x1f,0x4(%esp)
  8011ab:	00 
  8011ac:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8011b3:	e8 00 04 00 00       	call   8015b8 <_panic>
	else if (r == 0)
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	75 1c                	jne    8011d8 <fs_test+0x174>
		panic("file_open /not-found succeeded!");
  8011bc:	c7 44 24 08 98 39 80 	movl   $0x803998,0x8(%esp)
  8011c3:	00 
  8011c4:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8011cb:	00 
  8011cc:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8011d3:	e8 e0 03 00 00       	call   8015b8 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  8011d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011df:	c7 04 24 54 38 80 00 	movl   $0x803854,(%esp)
  8011e6:	e8 d3 f7 ff ff       	call   8009be <file_open>
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	79 20                	jns    80120f <fs_test+0x1ab>
		panic("file_open /newmotd: %e", r);
  8011ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f3:	c7 44 24 08 5d 38 80 	movl   $0x80385d,0x8(%esp)
  8011fa:	00 
  8011fb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801202:	00 
  801203:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  80120a:	e8 a9 03 00 00       	call   8015b8 <_panic>
	cprintf("file_open is good\n");
  80120f:	c7 04 24 74 38 80 00 	movl   $0x803874,(%esp)
  801216:	e8 95 04 00 00       	call   8016b0 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80121b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121e:	89 44 24 08          	mov    %eax,0x8(%esp)
  801222:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801229:	00 
  80122a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122d:	89 04 24             	mov    %eax,(%esp)
  801230:	e8 ef f4 ff ff       	call   800724 <file_get_block>
  801235:	85 c0                	test   %eax,%eax
  801237:	79 20                	jns    801259 <fs_test+0x1f5>
		panic("file_get_block: %e", r);
  801239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123d:	c7 44 24 08 87 38 80 	movl   $0x803887,0x8(%esp)
  801244:	00 
  801245:	c7 44 24 04 27 00 00 	movl   $0x27,0x4(%esp)
  80124c:	00 
  80124d:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  801254:	e8 5f 03 00 00       	call   8015b8 <_panic>
	if (strcmp(blk, msg) != 0)
  801259:	c7 44 24 04 b8 39 80 	movl   $0x8039b8,0x4(%esp)
  801260:	00 
  801261:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801264:	89 04 24             	mov    %eax,(%esp)
  801267:	e8 b6 0a 00 00       	call   801d22 <strcmp>
  80126c:	85 c0                	test   %eax,%eax
  80126e:	74 1c                	je     80128c <fs_test+0x228>
		panic("file_get_block returned wrong data");
  801270:	c7 44 24 08 e0 39 80 	movl   $0x8039e0,0x8(%esp)
  801277:	00 
  801278:	c7 44 24 04 29 00 00 	movl   $0x29,0x4(%esp)
  80127f:	00 
  801280:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  801287:	e8 2c 03 00 00       	call   8015b8 <_panic>
	cprintf("file_get_block is good\n");
  80128c:	c7 04 24 9a 38 80 00 	movl   $0x80389a,(%esp)
  801293:	e8 18 04 00 00       	call   8016b0 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801298:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80129b:	8a 10                	mov    (%eax),%dl
  80129d:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	c1 e8 0c             	shr    $0xc,%eax
  8012a5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ac:	a8 40                	test   $0x40,%al
  8012ae:	75 24                	jne    8012d4 <fs_test+0x270>
  8012b0:	c7 44 24 0c b3 38 80 	movl   $0x8038b3,0xc(%esp)
  8012b7:	00 
  8012b8:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  8012bf:	00 
  8012c0:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  8012c7:	00 
  8012c8:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8012cf:	e8 e4 02 00 00       	call   8015b8 <_panic>
	file_flush(f);
  8012d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d7:	89 04 24             	mov    %eax,(%esp)
  8012da:	e8 43 f8 ff ff       	call   800b22 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8012df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e2:	c1 e8 0c             	shr    $0xc,%eax
  8012e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012ec:	a8 40                	test   $0x40,%al
  8012ee:	74 24                	je     801314 <fs_test+0x2b0>
  8012f0:	c7 44 24 0c b2 38 80 	movl   $0x8038b2,0xc(%esp)
  8012f7:	00 
  8012f8:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  8012ff:	00 
  801300:	c7 44 24 04 2f 00 00 	movl   $0x2f,0x4(%esp)
  801307:	00 
  801308:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  80130f:	e8 a4 02 00 00       	call   8015b8 <_panic>
	cprintf("file_flush is good\n");
  801314:	c7 04 24 ce 38 80 00 	movl   $0x8038ce,(%esp)
  80131b:	e8 90 03 00 00       	call   8016b0 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801320:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801327:	00 
  801328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132b:	89 04 24             	mov    %eax,(%esp)
  80132e:	e8 03 f7 ff ff       	call   800a36 <file_set_size>
  801333:	85 c0                	test   %eax,%eax
  801335:	79 20                	jns    801357 <fs_test+0x2f3>
		panic("file_set_size: %e", r);
  801337:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80133b:	c7 44 24 08 e2 38 80 	movl   $0x8038e2,0x8(%esp)
  801342:	00 
  801343:	c7 44 24 04 33 00 00 	movl   $0x33,0x4(%esp)
  80134a:	00 
  80134b:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  801352:	e8 61 02 00 00       	call   8015b8 <_panic>
	assert(f->f_direct[0] == 0);
  801357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135a:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  801361:	74 24                	je     801387 <fs_test+0x323>
  801363:	c7 44 24 0c f4 38 80 	movl   $0x8038f4,0xc(%esp)
  80136a:	00 
  80136b:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  801372:	00 
  801373:	c7 44 24 04 34 00 00 	movl   $0x34,0x4(%esp)
  80137a:	00 
  80137b:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  801382:	e8 31 02 00 00       	call   8015b8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801387:	c1 e8 0c             	shr    $0xc,%eax
  80138a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801391:	a8 40                	test   $0x40,%al
  801393:	74 24                	je     8013b9 <fs_test+0x355>
  801395:	c7 44 24 0c 08 39 80 	movl   $0x803908,0xc(%esp)
  80139c:	00 
  80139d:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  8013a4:	00 
  8013a5:	c7 44 24 04 35 00 00 	movl   $0x35,0x4(%esp)
  8013ac:	00 
  8013ad:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8013b4:	e8 ff 01 00 00       	call   8015b8 <_panic>
	cprintf("file_truncate is good\n");
  8013b9:	c7 04 24 22 39 80 00 	movl   $0x803922,(%esp)
  8013c0:	e8 eb 02 00 00       	call   8016b0 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8013c5:	c7 04 24 b8 39 80 00 	movl   $0x8039b8,(%esp)
  8013cc:	e8 77 08 00 00       	call   801c48 <strlen>
  8013d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d8:	89 04 24             	mov    %eax,(%esp)
  8013db:	e8 56 f6 ff ff       	call   800a36 <file_set_size>
  8013e0:	85 c0                	test   %eax,%eax
  8013e2:	79 20                	jns    801404 <fs_test+0x3a0>
		panic("file_set_size 2: %e", r);
  8013e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013e8:	c7 44 24 08 39 39 80 	movl   $0x803939,0x8(%esp)
  8013ef:	00 
  8013f0:	c7 44 24 04 39 00 00 	movl   $0x39,0x4(%esp)
  8013f7:	00 
  8013f8:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8013ff:	e8 b4 01 00 00       	call   8015b8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  801404:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801407:	89 c2                	mov    %eax,%edx
  801409:	c1 ea 0c             	shr    $0xc,%edx
  80140c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801413:	f6 c2 40             	test   $0x40,%dl
  801416:	74 24                	je     80143c <fs_test+0x3d8>
  801418:	c7 44 24 0c 08 39 80 	movl   $0x803908,0xc(%esp)
  80141f:	00 
  801420:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  801427:	00 
  801428:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  80142f:	00 
  801430:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  801437:	e8 7c 01 00 00       	call   8015b8 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  80143c:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80143f:	89 54 24 08          	mov    %edx,0x8(%esp)
  801443:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80144a:	00 
  80144b:	89 04 24             	mov    %eax,(%esp)
  80144e:	e8 d1 f2 ff ff       	call   800724 <file_get_block>
  801453:	85 c0                	test   %eax,%eax
  801455:	79 20                	jns    801477 <fs_test+0x413>
		panic("file_get_block 2: %e", r);
  801457:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80145b:	c7 44 24 08 4d 39 80 	movl   $0x80394d,0x8(%esp)
  801462:	00 
  801463:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
  80146a:	00 
  80146b:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  801472:	e8 41 01 00 00       	call   8015b8 <_panic>
	strcpy(blk, msg);
  801477:	c7 44 24 04 b8 39 80 	movl   $0x8039b8,0x4(%esp)
  80147e:	00 
  80147f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801482:	89 04 24             	mov    %eax,(%esp)
  801485:	e8 f1 07 00 00       	call   801c7b <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	c1 e8 0c             	shr    $0xc,%eax
  801490:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801497:	a8 40                	test   $0x40,%al
  801499:	75 24                	jne    8014bf <fs_test+0x45b>
  80149b:	c7 44 24 0c b3 38 80 	movl   $0x8038b3,0xc(%esp)
  8014a2:	00 
  8014a3:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  8014aa:	00 
  8014ab:	c7 44 24 04 3e 00 00 	movl   $0x3e,0x4(%esp)
  8014b2:	00 
  8014b3:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8014ba:	e8 f9 00 00 00       	call   8015b8 <_panic>
	file_flush(f);
  8014bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c2:	89 04 24             	mov    %eax,(%esp)
  8014c5:	e8 58 f6 ff ff       	call   800b22 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8014ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014cd:	c1 e8 0c             	shr    $0xc,%eax
  8014d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d7:	a8 40                	test   $0x40,%al
  8014d9:	74 24                	je     8014ff <fs_test+0x49b>
  8014db:	c7 44 24 0c b2 38 80 	movl   $0x8038b2,0xc(%esp)
  8014e2:	00 
  8014e3:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  8014ea:	00 
  8014eb:	c7 44 24 04 40 00 00 	movl   $0x40,0x4(%esp)
  8014f2:	00 
  8014f3:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  8014fa:	e8 b9 00 00 00       	call   8015b8 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8014ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801502:	c1 e8 0c             	shr    $0xc,%eax
  801505:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80150c:	a8 40                	test   $0x40,%al
  80150e:	74 24                	je     801534 <fs_test+0x4d0>
  801510:	c7 44 24 0c 08 39 80 	movl   $0x803908,0xc(%esp)
  801517:	00 
  801518:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  80151f:	00 
  801520:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801527:	00 
  801528:	c7 04 24 e6 37 80 00 	movl   $0x8037e6,(%esp)
  80152f:	e8 84 00 00 00       	call   8015b8 <_panic>
	cprintf("file rewrite is good\n");
  801534:	c7 04 24 62 39 80 00 	movl   $0x803962,(%esp)
  80153b:	e8 70 01 00 00       	call   8016b0 <cprintf>
}
  801540:	83 c4 24             	add    $0x24,%esp
  801543:	5b                   	pop    %ebx
  801544:	5d                   	pop    %ebp
  801545:	c3                   	ret    
	...

00801548 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	56                   	push   %esi
  80154c:	53                   	push   %ebx
  80154d:	83 ec 10             	sub    $0x10,%esp
  801550:	8b 75 08             	mov    0x8(%ebp),%esi
  801553:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  801556:	e8 d4 0a 00 00       	call   80202f <sys_getenvid>
	thisenv = &envs[ENVX(envid)];
  80155b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801560:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801567:	c1 e0 07             	shl    $0x7,%eax
  80156a:	29 d0                	sub    %edx,%eax
  80156c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801571:	a3 0c 90 80 00       	mov    %eax,0x80900c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801576:	85 f6                	test   %esi,%esi
  801578:	7e 07                	jle    801581 <libmain+0x39>
		binaryname = argv[0];
  80157a:	8b 03                	mov    (%ebx),%eax
  80157c:	a3 60 80 80 00       	mov    %eax,0x808060

	// call user main routine
	umain(argc, argv);
  801581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801585:	89 34 24             	mov    %esi,(%esp)
  801588:	e8 8e fa ff ff       	call   80101b <umain>

	// exit gracefully
	exit();
  80158d:	e8 0a 00 00 00       	call   80159c <exit>
}
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	5b                   	pop    %ebx
  801596:	5e                   	pop    %esi
  801597:	5d                   	pop    %ebp
  801598:	c3                   	ret    
  801599:	00 00                	add    %al,(%eax)
	...

0080159c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8015a2:	e8 f4 10 00 00       	call   80269b <close_all>
	sys_env_destroy(0);
  8015a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ae:	e8 2a 0a 00 00       	call   801fdd <sys_env_destroy>
}
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    
  8015b5:	00 00                	add    %al,(%eax)
	...

008015b8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	56                   	push   %esi
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 20             	sub    $0x20,%esp
	va_list ap;

	va_start(ap, fmt);
  8015c0:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8015c3:	8b 1d 60 80 80 00    	mov    0x808060,%ebx
  8015c9:	e8 61 0a 00 00       	call   80202f <sys_getenvid>
  8015ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8015d8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8015dc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8015e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e4:	c7 04 24 10 3a 80 00 	movl   $0x803a10,(%esp)
  8015eb:	e8 c0 00 00 00       	call   8016b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8015f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f7:	89 04 24             	mov    %eax,(%esp)
  8015fa:	e8 50 00 00 00       	call   80164f <vcprintf>
	cprintf("\n");
  8015ff:	c7 04 24 07 36 80 00 	movl   $0x803607,(%esp)
  801606:	e8 a5 00 00 00       	call   8016b0 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80160b:	cc                   	int3   
  80160c:	eb fd                	jmp    80160b <_panic+0x53>
	...

00801610 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	53                   	push   %ebx
  801614:	83 ec 14             	sub    $0x14,%esp
  801617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80161a:	8b 03                	mov    (%ebx),%eax
  80161c:	8b 55 08             	mov    0x8(%ebp),%edx
  80161f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  801623:	40                   	inc    %eax
  801624:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  801626:	3d ff 00 00 00       	cmp    $0xff,%eax
  80162b:	75 19                	jne    801646 <putch+0x36>
		sys_cputs(b->buf, b->idx);
  80162d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  801634:	00 
  801635:	8d 43 08             	lea    0x8(%ebx),%eax
  801638:	89 04 24             	mov    %eax,(%esp)
  80163b:	e8 60 09 00 00       	call   801fa0 <sys_cputs>
		b->idx = 0;
  801640:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  801646:	ff 43 04             	incl   0x4(%ebx)
}
  801649:	83 c4 14             	add    $0x14,%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  801658:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80165f:	00 00 00 
	b.cnt = 0;
  801662:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801669:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80166c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	89 44 24 08          	mov    %eax,0x8(%esp)
  80167a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801680:	89 44 24 04          	mov    %eax,0x4(%esp)
  801684:	c7 04 24 10 16 80 00 	movl   $0x801610,(%esp)
  80168b:	e8 82 01 00 00       	call   801812 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801690:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80169a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8016a0:	89 04 24             	mov    %eax,(%esp)
  8016a3:	e8 f8 08 00 00       	call   801fa0 <sys_cputs>

	return b.cnt;
}
  8016a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8016b9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c0:	89 04 24             	mov    %eax,(%esp)
  8016c3:	e8 87 ff ff ff       	call   80164f <vcprintf>
	va_end(ap);

	return cnt;
}
  8016c8:	c9                   	leave  
  8016c9:	c3                   	ret    
	...

008016cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	57                   	push   %edi
  8016d0:	56                   	push   %esi
  8016d1:	53                   	push   %ebx
  8016d2:	83 ec 3c             	sub    $0x3c,%esp
  8016d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016d8:	89 d7                	mov    %edx,%edi
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8016e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8016e6:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8016e9:	8b 75 18             	mov    0x18(%ebp),%esi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	75 08                	jne    8016f8 <printnum+0x2c>
  8016f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8016f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8016f6:	77 57                	ja     80174f <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8016f8:	89 74 24 10          	mov    %esi,0x10(%esp)
  8016fc:	4b                   	dec    %ebx
  8016fd:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801701:	8b 45 10             	mov    0x10(%ebp),%eax
  801704:	89 44 24 08          	mov    %eax,0x8(%esp)
  801708:	8b 5c 24 08          	mov    0x8(%esp),%ebx
  80170c:	8b 74 24 0c          	mov    0xc(%esp),%esi
  801710:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801717:	00 
  801718:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80171b:	89 04 24             	mov    %eax,(%esp)
  80171e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801721:	89 44 24 04          	mov    %eax,0x4(%esp)
  801725:	e8 46 1b 00 00       	call   803270 <__udivdi3>
  80172a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80172e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801732:	89 04 24             	mov    %eax,(%esp)
  801735:	89 54 24 04          	mov    %edx,0x4(%esp)
  801739:	89 fa                	mov    %edi,%edx
  80173b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80173e:	e8 89 ff ff ff       	call   8016cc <printnum>
  801743:	eb 0f                	jmp    801754 <printnum+0x88>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801745:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801749:	89 34 24             	mov    %esi,(%esp)
  80174c:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80174f:	4b                   	dec    %ebx
  801750:	85 db                	test   %ebx,%ebx
  801752:	7f f1                	jg     801745 <printnum+0x79>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801754:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801758:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80175c:	8b 45 10             	mov    0x10(%ebp),%eax
  80175f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801763:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80176a:	00 
  80176b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80176e:	89 04 24             	mov    %eax,(%esp)
  801771:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801774:	89 44 24 04          	mov    %eax,0x4(%esp)
  801778:	e8 13 1c 00 00       	call   803390 <__umoddi3>
  80177d:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801781:	0f be 80 33 3a 80 00 	movsbl 0x803a33(%eax),%eax
  801788:	89 04 24             	mov    %eax,(%esp)
  80178b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80178e:	83 c4 3c             	add    $0x3c,%esp
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5f                   	pop    %edi
  801794:	5d                   	pop    %ebp
  801795:	c3                   	ret    

00801796 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801799:	83 fa 01             	cmp    $0x1,%edx
  80179c:	7e 0e                	jle    8017ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80179e:	8b 10                	mov    (%eax),%edx
  8017a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8017a3:	89 08                	mov    %ecx,(%eax)
  8017a5:	8b 02                	mov    (%edx),%eax
  8017a7:	8b 52 04             	mov    0x4(%edx),%edx
  8017aa:	eb 22                	jmp    8017ce <getuint+0x38>
	else if (lflag)
  8017ac:	85 d2                	test   %edx,%edx
  8017ae:	74 10                	je     8017c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8017b0:	8b 10                	mov    (%eax),%edx
  8017b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017b5:	89 08                	mov    %ecx,(%eax)
  8017b7:	8b 02                	mov    (%edx),%eax
  8017b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017be:	eb 0e                	jmp    8017ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8017c0:	8b 10                	mov    (%eax),%edx
  8017c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8017c5:	89 08                	mov    %ecx,(%eax)
  8017c7:	8b 02                	mov    (%edx),%eax
  8017c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8017d6:	ff 40 08             	incl   0x8(%eax)
	if (b->buf < b->ebuf)
  8017d9:	8b 10                	mov    (%eax),%edx
  8017db:	3b 50 04             	cmp    0x4(%eax),%edx
  8017de:	73 08                	jae    8017e8 <sprintputch+0x18>
		*b->buf++ = ch;
  8017e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e3:	88 0a                	mov    %cl,(%edx)
  8017e5:	42                   	inc    %edx
  8017e6:	89 10                	mov    %edx,(%eax)
}
  8017e8:	5d                   	pop    %ebp
  8017e9:	c3                   	ret    

008017ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8017ea:	55                   	push   %ebp
  8017eb:	89 e5                	mov    %esp,%ebp
  8017ed:	83 ec 18             	sub    $0x18,%esp
	va_list ap;

	va_start(ap, fmt);
  8017f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8017f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017f7:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801801:	89 44 24 04          	mov    %eax,0x4(%esp)
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	89 04 24             	mov    %eax,(%esp)
  80180b:	e8 02 00 00 00       	call   801812 <vprintfmt>
	va_end(ap);
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	57                   	push   %edi
  801816:	56                   	push   %esi
  801817:	53                   	push   %ebx
  801818:	83 ec 4c             	sub    $0x4c,%esp
  80181b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80181e:	8b 75 10             	mov    0x10(%ebp),%esi
  801821:	eb 12                	jmp    801835 <vprintfmt+0x23>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801823:	85 c0                	test   %eax,%eax
  801825:	0f 84 8b 03 00 00    	je     801bb6 <vprintfmt+0x3a4>
				return;
			putch(ch, putdat);
  80182b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80182f:	89 04 24             	mov    %eax,(%esp)
  801832:	ff 55 08             	call   *0x8(%ebp)
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801835:	0f b6 06             	movzbl (%esi),%eax
  801838:	46                   	inc    %esi
  801839:	83 f8 25             	cmp    $0x25,%eax
  80183c:	75 e5                	jne    801823 <vprintfmt+0x11>
  80183e:	c6 45 d8 20          	movb   $0x20,-0x28(%ebp)
  801842:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  801849:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  80184e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  801855:	b9 00 00 00 00       	mov    $0x0,%ecx
  80185a:	eb 26                	jmp    801882 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185c:	8b 75 e0             	mov    -0x20(%ebp),%esi

		// flag to pad on the right
		case '-':
			padc = '-';
  80185f:	c6 45 d8 2d          	movb   $0x2d,-0x28(%ebp)
  801863:	eb 1d                	jmp    801882 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801865:	8b 75 e0             	mov    -0x20(%ebp),%esi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801868:	c6 45 d8 30          	movb   $0x30,-0x28(%ebp)
  80186c:	eb 14                	jmp    801882 <vprintfmt+0x70>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80186e:	8b 75 e0             	mov    -0x20(%ebp),%esi
			precision = va_arg(ap, int);
			goto process_precision;

		case '.':
			if (width < 0)
				width = 0;
  801871:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801878:	eb 08                	jmp    801882 <vprintfmt+0x70>
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
				width = precision, precision = -1;
  80187a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  80187d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801882:	0f b6 06             	movzbl (%esi),%eax
  801885:	8d 56 01             	lea    0x1(%esi),%edx
  801888:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80188b:	8a 16                	mov    (%esi),%dl
  80188d:	83 ea 23             	sub    $0x23,%edx
  801890:	80 fa 55             	cmp    $0x55,%dl
  801893:	0f 87 01 03 00 00    	ja     801b9a <vprintfmt+0x388>
  801899:	0f b6 d2             	movzbl %dl,%edx
  80189c:	ff 24 95 80 3b 80 00 	jmp    *0x803b80(,%edx,4)
  8018a3:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8018a6:	bf 00 00 00 00       	mov    $0x0,%edi
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8018ab:	8d 14 bf             	lea    (%edi,%edi,4),%edx
  8018ae:	8d 7c 50 d0          	lea    -0x30(%eax,%edx,2),%edi
				ch = *fmt;
  8018b2:	0f be 06             	movsbl (%esi),%eax
				if (ch < '0' || ch > '9')
  8018b5:	8d 50 d0             	lea    -0x30(%eax),%edx
  8018b8:	83 fa 09             	cmp    $0x9,%edx
  8018bb:	77 2a                	ja     8018e7 <vprintfmt+0xd5>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8018bd:	46                   	inc    %esi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8018be:	eb eb                	jmp    8018ab <vprintfmt+0x99>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8018c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8018c3:	8d 50 04             	lea    0x4(%eax),%edx
  8018c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8018c9:	8b 38                	mov    (%eax),%edi
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018cb:	8b 75 e0             	mov    -0x20(%ebp),%esi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8018ce:	eb 17                	jmp    8018e7 <vprintfmt+0xd5>

		case '.':
			if (width < 0)
  8018d0:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018d4:	78 98                	js     80186e <vprintfmt+0x5c>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018d6:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8018d9:	eb a7                	jmp    801882 <vprintfmt+0x70>
  8018db:	8b 75 e0             	mov    -0x20(%ebp),%esi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8018de:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8018e5:	eb 9b                	jmp    801882 <vprintfmt+0x70>

		process_precision:
			if (width < 0)
  8018e7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8018eb:	79 95                	jns    801882 <vprintfmt+0x70>
  8018ed:	eb 8b                	jmp    80187a <vprintfmt+0x68>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8018ef:	41                   	inc    %ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8018f0:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8018f3:	eb 8d                	jmp    801882 <vprintfmt+0x70>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8018f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f8:	8d 50 04             	lea    0x4(%eax),%edx
  8018fb:	89 55 14             	mov    %edx,0x14(%ebp)
  8018fe:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801902:	8b 00                	mov    (%eax),%eax
  801904:	89 04 24             	mov    %eax,(%esp)
  801907:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80190a:	8b 75 e0             	mov    -0x20(%ebp),%esi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80190d:	e9 23 ff ff ff       	jmp    801835 <vprintfmt+0x23>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801912:	8b 45 14             	mov    0x14(%ebp),%eax
  801915:	8d 50 04             	lea    0x4(%eax),%edx
  801918:	89 55 14             	mov    %edx,0x14(%ebp)
  80191b:	8b 00                	mov    (%eax),%eax
  80191d:	85 c0                	test   %eax,%eax
  80191f:	79 02                	jns    801923 <vprintfmt+0x111>
  801921:	f7 d8                	neg    %eax
  801923:	89 c2                	mov    %eax,%edx
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801925:	83 f8 0f             	cmp    $0xf,%eax
  801928:	7f 0b                	jg     801935 <vprintfmt+0x123>
  80192a:	8b 04 85 e0 3c 80 00 	mov    0x803ce0(,%eax,4),%eax
  801931:	85 c0                	test   %eax,%eax
  801933:	75 23                	jne    801958 <vprintfmt+0x146>
				printfmt(putch, putdat, "error %d", err);
  801935:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801939:	c7 44 24 08 4b 3a 80 	movl   $0x803a4b,0x8(%esp)
  801940:	00 
  801941:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801945:	8b 45 08             	mov    0x8(%ebp),%eax
  801948:	89 04 24             	mov    %eax,(%esp)
  80194b:	e8 9a fe ff ff       	call   8017ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801950:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801953:	e9 dd fe ff ff       	jmp    801835 <vprintfmt+0x23>
			else
				printfmt(putch, putdat, "%s", p);
  801958:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80195c:	c7 44 24 08 0f 35 80 	movl   $0x80350f,0x8(%esp)
  801963:	00 
  801964:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801968:	8b 55 08             	mov    0x8(%ebp),%edx
  80196b:	89 14 24             	mov    %edx,(%esp)
  80196e:	e8 77 fe ff ff       	call   8017ea <printfmt>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801973:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801976:	e9 ba fe ff ff       	jmp    801835 <vprintfmt+0x23>
  80197b:	89 f9                	mov    %edi,%ecx
  80197d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801980:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801983:	8b 45 14             	mov    0x14(%ebp),%eax
  801986:	8d 50 04             	lea    0x4(%eax),%edx
  801989:	89 55 14             	mov    %edx,0x14(%ebp)
  80198c:	8b 30                	mov    (%eax),%esi
  80198e:	85 f6                	test   %esi,%esi
  801990:	75 05                	jne    801997 <vprintfmt+0x185>
				p = "(null)";
  801992:	be 44 3a 80 00       	mov    $0x803a44,%esi
			if (width > 0 && padc != '-')
  801997:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80199b:	0f 8e 84 00 00 00    	jle    801a25 <vprintfmt+0x213>
  8019a1:	80 7d d8 2d          	cmpb   $0x2d,-0x28(%ebp)
  8019a5:	74 7e                	je     801a25 <vprintfmt+0x213>
				for (width -= strnlen(p, precision); width > 0; width--)
  8019a7:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8019ab:	89 34 24             	mov    %esi,(%esp)
  8019ae:	e8 ab 02 00 00       	call   801c5e <strnlen>
  8019b3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8019b6:	29 c2                	sub    %eax,%edx
  8019b8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
					putch(padc, putdat);
  8019bb:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  8019bf:	89 75 d0             	mov    %esi,-0x30(%ebp)
  8019c2:	89 7d cc             	mov    %edi,-0x34(%ebp)
  8019c5:	89 de                	mov    %ebx,%esi
  8019c7:	89 d3                	mov    %edx,%ebx
  8019c9:	89 c7                	mov    %eax,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019cb:	eb 0b                	jmp    8019d8 <vprintfmt+0x1c6>
					putch(padc, putdat);
  8019cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019d1:	89 3c 24             	mov    %edi,(%esp)
  8019d4:	ff 55 08             	call   *0x8(%ebp)
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8019d7:	4b                   	dec    %ebx
  8019d8:	85 db                	test   %ebx,%ebx
  8019da:	7f f1                	jg     8019cd <vprintfmt+0x1bb>
  8019dc:	8b 7d cc             	mov    -0x34(%ebp),%edi
  8019df:	89 f3                	mov    %esi,%ebx
  8019e1:	8b 75 d0             	mov    -0x30(%ebp),%esi

// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
  8019e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	79 05                	jns    8019f0 <vprintfmt+0x1de>
  8019eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019f3:	29 c2                	sub    %eax,%edx
  8019f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8019f8:	eb 2b                	jmp    801a25 <vprintfmt+0x213>
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8019fa:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019fe:	74 18                	je     801a18 <vprintfmt+0x206>
  801a00:	8d 50 e0             	lea    -0x20(%eax),%edx
  801a03:	83 fa 5e             	cmp    $0x5e,%edx
  801a06:	76 10                	jbe    801a18 <vprintfmt+0x206>
					putch('?', putdat);
  801a08:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a0c:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  801a13:	ff 55 08             	call   *0x8(%ebp)
  801a16:	eb 0a                	jmp    801a22 <vprintfmt+0x210>
				else
					putch(ch, putdat);
  801a18:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a1c:	89 04 24             	mov    %eax,(%esp)
  801a1f:	ff 55 08             	call   *0x8(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801a22:	ff 4d e4             	decl   -0x1c(%ebp)
  801a25:	0f be 06             	movsbl (%esi),%eax
  801a28:	46                   	inc    %esi
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	74 21                	je     801a4e <vprintfmt+0x23c>
  801a2d:	85 ff                	test   %edi,%edi
  801a2f:	78 c9                	js     8019fa <vprintfmt+0x1e8>
  801a31:	4f                   	dec    %edi
  801a32:	79 c6                	jns    8019fa <vprintfmt+0x1e8>
  801a34:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a37:	89 de                	mov    %ebx,%esi
  801a39:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801a3c:	eb 18                	jmp    801a56 <vprintfmt+0x244>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801a3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a42:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  801a49:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801a4b:	4b                   	dec    %ebx
  801a4c:	eb 08                	jmp    801a56 <vprintfmt+0x244>
  801a4e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a51:	89 de                	mov    %ebx,%esi
  801a53:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  801a56:	85 db                	test   %ebx,%ebx
  801a58:	7f e4                	jg     801a3e <vprintfmt+0x22c>
  801a5a:	89 7d 08             	mov    %edi,0x8(%ebp)
  801a5d:	89 f3                	mov    %esi,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a5f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801a62:	e9 ce fd ff ff       	jmp    801835 <vprintfmt+0x23>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a67:	83 f9 01             	cmp    $0x1,%ecx
  801a6a:	7e 10                	jle    801a7c <vprintfmt+0x26a>
		return va_arg(*ap, long long);
  801a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6f:	8d 50 08             	lea    0x8(%eax),%edx
  801a72:	89 55 14             	mov    %edx,0x14(%ebp)
  801a75:	8b 30                	mov    (%eax),%esi
  801a77:	8b 78 04             	mov    0x4(%eax),%edi
  801a7a:	eb 26                	jmp    801aa2 <vprintfmt+0x290>
	else if (lflag)
  801a7c:	85 c9                	test   %ecx,%ecx
  801a7e:	74 12                	je     801a92 <vprintfmt+0x280>
		return va_arg(*ap, long);
  801a80:	8b 45 14             	mov    0x14(%ebp),%eax
  801a83:	8d 50 04             	lea    0x4(%eax),%edx
  801a86:	89 55 14             	mov    %edx,0x14(%ebp)
  801a89:	8b 30                	mov    (%eax),%esi
  801a8b:	89 f7                	mov    %esi,%edi
  801a8d:	c1 ff 1f             	sar    $0x1f,%edi
  801a90:	eb 10                	jmp    801aa2 <vprintfmt+0x290>
	else
		return va_arg(*ap, int);
  801a92:	8b 45 14             	mov    0x14(%ebp),%eax
  801a95:	8d 50 04             	lea    0x4(%eax),%edx
  801a98:	89 55 14             	mov    %edx,0x14(%ebp)
  801a9b:	8b 30                	mov    (%eax),%esi
  801a9d:	89 f7                	mov    %esi,%edi
  801a9f:	c1 ff 1f             	sar    $0x1f,%edi
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801aa2:	85 ff                	test   %edi,%edi
  801aa4:	78 0a                	js     801ab0 <vprintfmt+0x29e>
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801aa6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aab:	e9 ac 00 00 00       	jmp    801b5c <vprintfmt+0x34a>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
				putch('-', putdat);
  801ab0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab4:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  801abb:	ff 55 08             	call   *0x8(%ebp)
				num = -(long long) num;
  801abe:	f7 de                	neg    %esi
  801ac0:	83 d7 00             	adc    $0x0,%edi
  801ac3:	f7 df                	neg    %edi
			}
			base = 10;
  801ac5:	b8 0a 00 00 00       	mov    $0xa,%eax
  801aca:	e9 8d 00 00 00       	jmp    801b5c <vprintfmt+0x34a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801acf:	89 ca                	mov    %ecx,%edx
  801ad1:	8d 45 14             	lea    0x14(%ebp),%eax
  801ad4:	e8 bd fc ff ff       	call   801796 <getuint>
  801ad9:	89 c6                	mov    %eax,%esi
  801adb:	89 d7                	mov    %edx,%edi
			base = 10;
  801add:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801ae2:	eb 78                	jmp    801b5c <vprintfmt+0x34a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801ae4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ae8:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801aef:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  801af2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801af6:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801afd:	ff 55 08             	call   *0x8(%ebp)
			putch('X', putdat);
  801b00:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b04:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  801b0b:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b0e:	8b 75 e0             	mov    -0x20(%ebp),%esi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801b11:	e9 1f fd ff ff       	jmp    801835 <vprintfmt+0x23>

		// pointer
		case 'p':
			putch('0', putdat);
  801b16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b1a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  801b21:	ff 55 08             	call   *0x8(%ebp)
			putch('x', putdat);
  801b24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b28:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  801b2f:	ff 55 08             	call   *0x8(%ebp)
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801b32:	8b 45 14             	mov    0x14(%ebp),%eax
  801b35:	8d 50 04             	lea    0x4(%eax),%edx
  801b38:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801b3b:	8b 30                	mov    (%eax),%esi
  801b3d:	bf 00 00 00 00       	mov    $0x0,%edi
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801b42:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801b47:	eb 13                	jmp    801b5c <vprintfmt+0x34a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801b49:	89 ca                	mov    %ecx,%edx
  801b4b:	8d 45 14             	lea    0x14(%ebp),%eax
  801b4e:	e8 43 fc ff ff       	call   801796 <getuint>
  801b53:	89 c6                	mov    %eax,%esi
  801b55:	89 d7                	mov    %edx,%edi
			base = 16;
  801b57:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801b5c:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  801b60:	89 54 24 10          	mov    %edx,0x10(%esp)
  801b64:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801b67:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801b6b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b6f:	89 34 24             	mov    %esi,(%esp)
  801b72:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b76:	89 da                	mov    %ebx,%edx
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	e8 4c fb ff ff       	call   8016cc <printnum>
			break;
  801b80:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801b83:	e9 ad fc ff ff       	jmp    801835 <vprintfmt+0x23>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b88:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b8c:	89 04 24             	mov    %eax,(%esp)
  801b8f:	ff 55 08             	call   *0x8(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b92:	8b 75 e0             	mov    -0x20(%ebp),%esi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b95:	e9 9b fc ff ff       	jmp    801835 <vprintfmt+0x23>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b9e:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  801ba5:	ff 55 08             	call   *0x8(%ebp)
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ba8:	eb 01                	jmp    801bab <vprintfmt+0x399>
  801baa:	4e                   	dec    %esi
  801bab:	80 7e ff 25          	cmpb   $0x25,-0x1(%esi)
  801baf:	75 f9                	jne    801baa <vprintfmt+0x398>
  801bb1:	e9 7f fc ff ff       	jmp    801835 <vprintfmt+0x23>
				/* do nothing */;
			break;
		}
	}
}
  801bb6:	83 c4 4c             	add    $0x4c,%esp
  801bb9:	5b                   	pop    %ebx
  801bba:	5e                   	pop    %esi
  801bbb:	5f                   	pop    %edi
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	83 ec 28             	sub    $0x28,%esp
  801bc4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801bca:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801bcd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801bd1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bd4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801bdb:	85 c0                	test   %eax,%eax
  801bdd:	74 30                	je     801c0f <vsnprintf+0x51>
  801bdf:	85 d2                	test   %edx,%edx
  801be1:	7e 33                	jle    801c16 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801be3:	8b 45 14             	mov    0x14(%ebp),%eax
  801be6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bea:	8b 45 10             	mov    0x10(%ebp),%eax
  801bed:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bf1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bf8:	c7 04 24 d0 17 80 00 	movl   $0x8017d0,(%esp)
  801bff:	e8 0e fc ff ff       	call   801812 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801c04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801c07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801c0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0d:	eb 0c                	jmp    801c1b <vsnprintf+0x5d>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801c0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c14:	eb 05                	jmp    801c1b <vsnprintf+0x5d>
  801c16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	83 ec 18             	sub    $0x18,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801c23:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801c26:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c31:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c34:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3b:	89 04 24             	mov    %eax,(%esp)
  801c3e:	e8 7b ff ff ff       	call   801bbe <vsnprintf>
	va_end(ap);

	return rc;
}
  801c43:	c9                   	leave  
  801c44:	c3                   	ret    
  801c45:	00 00                	add    %al,(%eax)
	...

00801c48 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c53:	eb 01                	jmp    801c56 <strlen+0xe>
		n++;
  801c55:	40                   	inc    %eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801c56:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801c5a:	75 f9                	jne    801c55 <strlen+0xd>
		n++;
	return n;
}
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    

00801c5e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
		n++;
	return n;
}

int
strnlen(const char *s, size_t size)
  801c64:	8b 55 0c             	mov    0xc(%ebp),%edx
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c67:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6c:	eb 01                	jmp    801c6f <strnlen+0x11>
		n++;
  801c6e:	40                   	inc    %eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801c6f:	39 d0                	cmp    %edx,%eax
  801c71:	74 06                	je     801c79 <strnlen+0x1b>
  801c73:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801c77:	75 f5                	jne    801c6e <strnlen+0x10>
		n++;
	return n;
}
  801c79:	5d                   	pop    %ebp
  801c7a:	c3                   	ret    

00801c7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801c7b:	55                   	push   %ebp
  801c7c:	89 e5                	mov    %esp,%ebp
  801c7e:	53                   	push   %ebx
  801c7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801c85:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8a:	8a 0c 13             	mov    (%ebx,%edx,1),%cl
  801c8d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  801c90:	42                   	inc    %edx
  801c91:	84 c9                	test   %cl,%cl
  801c93:	75 f5                	jne    801c8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801c95:	5b                   	pop    %ebx
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	53                   	push   %ebx
  801c9c:	83 ec 08             	sub    $0x8,%esp
  801c9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ca2:	89 1c 24             	mov    %ebx,(%esp)
  801ca5:	e8 9e ff ff ff       	call   801c48 <strlen>
	strcpy(dst + len, src);
  801caa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cad:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cb1:	01 d8                	add    %ebx,%eax
  801cb3:	89 04 24             	mov    %eax,(%esp)
  801cb6:	e8 c0 ff ff ff       	call   801c7b <strcpy>
	return dst;
}
  801cbb:	89 d8                	mov    %ebx,%eax
  801cbd:	83 c4 08             	add    $0x8,%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5d                   	pop    %ebp
  801cc2:	c3                   	ret    

00801cc3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801cc3:	55                   	push   %ebp
  801cc4:	89 e5                	mov    %esp,%ebp
  801cc6:	56                   	push   %esi
  801cc7:	53                   	push   %ebx
  801cc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cce:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801cd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  801cd6:	eb 0c                	jmp    801ce4 <strncpy+0x21>
		*dst++ = *src;
  801cd8:	8a 1a                	mov    (%edx),%bl
  801cda:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801cdd:	80 3a 01             	cmpb   $0x1,(%edx)
  801ce0:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801ce3:	41                   	inc    %ecx
  801ce4:	39 f1                	cmp    %esi,%ecx
  801ce6:	75 f0                	jne    801cd8 <strncpy+0x15>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801ce8:	5b                   	pop    %ebx
  801ce9:	5e                   	pop    %esi
  801cea:	5d                   	pop    %ebp
  801ceb:	c3                   	ret    

00801cec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801cec:	55                   	push   %ebp
  801ced:	89 e5                	mov    %esp,%ebp
  801cef:	56                   	push   %esi
  801cf0:	53                   	push   %ebx
  801cf1:	8b 75 08             	mov    0x8(%ebp),%esi
  801cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cf7:	8b 55 10             	mov    0x10(%ebp),%edx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801cfa:	85 d2                	test   %edx,%edx
  801cfc:	75 0a                	jne    801d08 <strlcpy+0x1c>
  801cfe:	89 f0                	mov    %esi,%eax
  801d00:	eb 1a                	jmp    801d1c <strlcpy+0x30>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801d02:	88 18                	mov    %bl,(%eax)
  801d04:	40                   	inc    %eax
  801d05:	41                   	inc    %ecx
  801d06:	eb 02                	jmp    801d0a <strlcpy+0x1e>
strlcpy(char *dst, const char *src, size_t size)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801d08:	89 f0                	mov    %esi,%eax
		while (--size > 0 && *src != '\0')
  801d0a:	4a                   	dec    %edx
  801d0b:	74 0a                	je     801d17 <strlcpy+0x2b>
  801d0d:	8a 19                	mov    (%ecx),%bl
  801d0f:	84 db                	test   %bl,%bl
  801d11:	75 ef                	jne    801d02 <strlcpy+0x16>
  801d13:	89 c2                	mov    %eax,%edx
  801d15:	eb 02                	jmp    801d19 <strlcpy+0x2d>
  801d17:	89 c2                	mov    %eax,%edx
			*dst++ = *src++;
		*dst = '\0';
  801d19:	c6 02 00             	movb   $0x0,(%edx)
	}
	return dst - dst_in;
  801d1c:	29 f0                	sub    %esi,%eax
}
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d28:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801d2b:	eb 02                	jmp    801d2f <strcmp+0xd>
		p++, q++;
  801d2d:	41                   	inc    %ecx
  801d2e:	42                   	inc    %edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801d2f:	8a 01                	mov    (%ecx),%al
  801d31:	84 c0                	test   %al,%al
  801d33:	74 04                	je     801d39 <strcmp+0x17>
  801d35:	3a 02                	cmp    (%edx),%al
  801d37:	74 f4                	je     801d2d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801d39:	0f b6 c0             	movzbl %al,%eax
  801d3c:	0f b6 12             	movzbl (%edx),%edx
  801d3f:	29 d0                	sub    %edx,%eax
}
  801d41:	5d                   	pop    %ebp
  801d42:	c3                   	ret    

00801d43 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801d43:	55                   	push   %ebp
  801d44:	89 e5                	mov    %esp,%ebp
  801d46:	53                   	push   %ebx
  801d47:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d4d:	8b 55 10             	mov    0x10(%ebp),%edx
	while (n > 0 && *p && *p == *q)
  801d50:	eb 03                	jmp    801d55 <strncmp+0x12>
		n--, p++, q++;
  801d52:	4a                   	dec    %edx
  801d53:	40                   	inc    %eax
  801d54:	41                   	inc    %ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801d55:	85 d2                	test   %edx,%edx
  801d57:	74 14                	je     801d6d <strncmp+0x2a>
  801d59:	8a 18                	mov    (%eax),%bl
  801d5b:	84 db                	test   %bl,%bl
  801d5d:	74 04                	je     801d63 <strncmp+0x20>
  801d5f:	3a 19                	cmp    (%ecx),%bl
  801d61:	74 ef                	je     801d52 <strncmp+0xf>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801d63:	0f b6 00             	movzbl (%eax),%eax
  801d66:	0f b6 11             	movzbl (%ecx),%edx
  801d69:	29 d0                	sub    %edx,%eax
  801d6b:	eb 05                	jmp    801d72 <strncmp+0x2f>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801d6d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801d72:	5b                   	pop    %ebx
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7b:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801d7e:	eb 05                	jmp    801d85 <strchr+0x10>
		if (*s == c)
  801d80:	38 ca                	cmp    %cl,%dl
  801d82:	74 0c                	je     801d90 <strchr+0x1b>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d84:	40                   	inc    %eax
  801d85:	8a 10                	mov    (%eax),%dl
  801d87:	84 d2                	test   %dl,%dl
  801d89:	75 f5                	jne    801d80 <strchr+0xb>
		if (*s == c)
			return (char *) s;
	return 0;
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d90:	5d                   	pop    %ebp
  801d91:	c3                   	ret    

00801d92 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	8b 45 08             	mov    0x8(%ebp),%eax
  801d98:	8a 4d 0c             	mov    0xc(%ebp),%cl
	for (; *s; s++)
  801d9b:	eb 05                	jmp    801da2 <strfind+0x10>
		if (*s == c)
  801d9d:	38 ca                	cmp    %cl,%dl
  801d9f:	74 07                	je     801da8 <strfind+0x16>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  801da1:	40                   	inc    %eax
  801da2:	8a 10                	mov    (%eax),%dl
  801da4:	84 d2                	test   %dl,%dl
  801da6:	75 f5                	jne    801d9d <strfind+0xb>
		if (*s == c)
			break;
	return (char *) s;
}
  801da8:	5d                   	pop    %ebp
  801da9:	c3                   	ret    

00801daa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	57                   	push   %edi
  801dae:	56                   	push   %esi
  801daf:	53                   	push   %ebx
  801db0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801db3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801db6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801db9:	85 c9                	test   %ecx,%ecx
  801dbb:	74 30                	je     801ded <memset+0x43>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801dbd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801dc3:	75 25                	jne    801dea <memset+0x40>
  801dc5:	f6 c1 03             	test   $0x3,%cl
  801dc8:	75 20                	jne    801dea <memset+0x40>
		c &= 0xFF;
  801dca:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	c1 e3 08             	shl    $0x8,%ebx
  801dd2:	89 d6                	mov    %edx,%esi
  801dd4:	c1 e6 18             	shl    $0x18,%esi
  801dd7:	89 d0                	mov    %edx,%eax
  801dd9:	c1 e0 10             	shl    $0x10,%eax
  801ddc:	09 f0                	or     %esi,%eax
  801dde:	09 d0                	or     %edx,%eax
  801de0:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801de2:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801de5:	fc                   	cld    
  801de6:	f3 ab                	rep stos %eax,%es:(%edi)
  801de8:	eb 03                	jmp    801ded <memset+0x43>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801dea:	fc                   	cld    
  801deb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801ded:	89 f8                	mov    %edi,%eax
  801def:	5b                   	pop    %ebx
  801df0:	5e                   	pop    %esi
  801df1:	5f                   	pop    %edi
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	57                   	push   %edi
  801df8:	56                   	push   %esi
  801df9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfc:	8b 75 0c             	mov    0xc(%ebp),%esi
  801dff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801e02:	39 c6                	cmp    %eax,%esi
  801e04:	73 34                	jae    801e3a <memmove+0x46>
  801e06:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801e09:	39 d0                	cmp    %edx,%eax
  801e0b:	73 2d                	jae    801e3a <memmove+0x46>
		s += n;
		d += n;
  801e0d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e10:	f6 c2 03             	test   $0x3,%dl
  801e13:	75 1b                	jne    801e30 <memmove+0x3c>
  801e15:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801e1b:	75 13                	jne    801e30 <memmove+0x3c>
  801e1d:	f6 c1 03             	test   $0x3,%cl
  801e20:	75 0e                	jne    801e30 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801e22:	83 ef 04             	sub    $0x4,%edi
  801e25:	8d 72 fc             	lea    -0x4(%edx),%esi
  801e28:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801e2b:	fd                   	std    
  801e2c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e2e:	eb 07                	jmp    801e37 <memmove+0x43>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801e30:	4f                   	dec    %edi
  801e31:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801e34:	fd                   	std    
  801e35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801e37:	fc                   	cld    
  801e38:	eb 20                	jmp    801e5a <memmove+0x66>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801e3a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801e40:	75 13                	jne    801e55 <memmove+0x61>
  801e42:	a8 03                	test   $0x3,%al
  801e44:	75 0f                	jne    801e55 <memmove+0x61>
  801e46:	f6 c1 03             	test   $0x3,%cl
  801e49:	75 0a                	jne    801e55 <memmove+0x61>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801e4b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801e4e:	89 c7                	mov    %eax,%edi
  801e50:	fc                   	cld    
  801e51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801e53:	eb 05                	jmp    801e5a <memmove+0x66>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801e55:	89 c7                	mov    %eax,%edi
  801e57:	fc                   	cld    
  801e58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801e5a:	5e                   	pop    %esi
  801e5b:	5f                   	pop    %edi
  801e5c:	5d                   	pop    %ebp
  801e5d:	c3                   	ret    

00801e5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801e5e:	55                   	push   %ebp
  801e5f:	89 e5                	mov    %esp,%ebp
  801e61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801e64:	8b 45 10             	mov    0x10(%ebp),%eax
  801e67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e72:	8b 45 08             	mov    0x8(%ebp),%eax
  801e75:	89 04 24             	mov    %eax,(%esp)
  801e78:	e8 77 ff ff ff       	call   801df4 <memmove>
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    

00801e7f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	57                   	push   %edi
  801e83:	56                   	push   %esi
  801e84:	53                   	push   %ebx
  801e85:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e88:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801e93:	eb 16                	jmp    801eab <memcmp+0x2c>
		if (*s1 != *s2)
  801e95:	8a 04 17             	mov    (%edi,%edx,1),%al
  801e98:	42                   	inc    %edx
  801e99:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
  801e9d:	38 c8                	cmp    %cl,%al
  801e9f:	74 0a                	je     801eab <memcmp+0x2c>
			return (int) *s1 - (int) *s2;
  801ea1:	0f b6 c0             	movzbl %al,%eax
  801ea4:	0f b6 c9             	movzbl %cl,%ecx
  801ea7:	29 c8                	sub    %ecx,%eax
  801ea9:	eb 09                	jmp    801eb4 <memcmp+0x35>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801eab:	39 da                	cmp    %ebx,%edx
  801ead:	75 e6                	jne    801e95 <memcmp+0x16>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801eaf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb4:	5b                   	pop    %ebx
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801ec2:	89 c2                	mov    %eax,%edx
  801ec4:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801ec7:	eb 05                	jmp    801ece <memfind+0x15>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ec9:	38 08                	cmp    %cl,(%eax)
  801ecb:	74 05                	je     801ed2 <memfind+0x19>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801ecd:	40                   	inc    %eax
  801ece:	39 d0                	cmp    %edx,%eax
  801ed0:	72 f7                	jb     801ec9 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	8b 55 08             	mov    0x8(%ebp),%edx
  801edd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ee0:	eb 01                	jmp    801ee3 <strtol+0xf>
		s++;
  801ee2:	42                   	inc    %edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801ee3:	8a 02                	mov    (%edx),%al
  801ee5:	3c 20                	cmp    $0x20,%al
  801ee7:	74 f9                	je     801ee2 <strtol+0xe>
  801ee9:	3c 09                	cmp    $0x9,%al
  801eeb:	74 f5                	je     801ee2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801eed:	3c 2b                	cmp    $0x2b,%al
  801eef:	75 08                	jne    801ef9 <strtol+0x25>
		s++;
  801ef1:	42                   	inc    %edx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801ef2:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef7:	eb 13                	jmp    801f0c <strtol+0x38>
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801ef9:	3c 2d                	cmp    $0x2d,%al
  801efb:	75 0a                	jne    801f07 <strtol+0x33>
		s++, neg = 1;
  801efd:	8d 52 01             	lea    0x1(%edx),%edx
  801f00:	bf 01 00 00 00       	mov    $0x1,%edi
  801f05:	eb 05                	jmp    801f0c <strtol+0x38>
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801f07:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801f0c:	85 db                	test   %ebx,%ebx
  801f0e:	74 05                	je     801f15 <strtol+0x41>
  801f10:	83 fb 10             	cmp    $0x10,%ebx
  801f13:	75 28                	jne    801f3d <strtol+0x69>
  801f15:	8a 02                	mov    (%edx),%al
  801f17:	3c 30                	cmp    $0x30,%al
  801f19:	75 10                	jne    801f2b <strtol+0x57>
  801f1b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801f1f:	75 0a                	jne    801f2b <strtol+0x57>
		s += 2, base = 16;
  801f21:	83 c2 02             	add    $0x2,%edx
  801f24:	bb 10 00 00 00       	mov    $0x10,%ebx
  801f29:	eb 12                	jmp    801f3d <strtol+0x69>
	else if (base == 0 && s[0] == '0')
  801f2b:	85 db                	test   %ebx,%ebx
  801f2d:	75 0e                	jne    801f3d <strtol+0x69>
  801f2f:	3c 30                	cmp    $0x30,%al
  801f31:	75 05                	jne    801f38 <strtol+0x64>
		s++, base = 8;
  801f33:	42                   	inc    %edx
  801f34:	b3 08                	mov    $0x8,%bl
  801f36:	eb 05                	jmp    801f3d <strtol+0x69>
	else if (base == 0)
		base = 10;
  801f38:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801f3d:	b8 00 00 00 00       	mov    $0x0,%eax
  801f42:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801f44:	8a 0a                	mov    (%edx),%cl
  801f46:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801f49:	80 fb 09             	cmp    $0x9,%bl
  801f4c:	77 08                	ja     801f56 <strtol+0x82>
			dig = *s - '0';
  801f4e:	0f be c9             	movsbl %cl,%ecx
  801f51:	83 e9 30             	sub    $0x30,%ecx
  801f54:	eb 1e                	jmp    801f74 <strtol+0xa0>
		else if (*s >= 'a' && *s <= 'z')
  801f56:	8d 59 9f             	lea    -0x61(%ecx),%ebx
  801f59:	80 fb 19             	cmp    $0x19,%bl
  801f5c:	77 08                	ja     801f66 <strtol+0x92>
			dig = *s - 'a' + 10;
  801f5e:	0f be c9             	movsbl %cl,%ecx
  801f61:	83 e9 57             	sub    $0x57,%ecx
  801f64:	eb 0e                	jmp    801f74 <strtol+0xa0>
		else if (*s >= 'A' && *s <= 'Z')
  801f66:	8d 59 bf             	lea    -0x41(%ecx),%ebx
  801f69:	80 fb 19             	cmp    $0x19,%bl
  801f6c:	77 12                	ja     801f80 <strtol+0xac>
			dig = *s - 'A' + 10;
  801f6e:	0f be c9             	movsbl %cl,%ecx
  801f71:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  801f74:	39 f1                	cmp    %esi,%ecx
  801f76:	7d 0c                	jge    801f84 <strtol+0xb0>
			break;
		s++, val = (val * base) + dig;
  801f78:	42                   	inc    %edx
  801f79:	0f af c6             	imul   %esi,%eax
  801f7c:	01 c8                	add    %ecx,%eax
		// we don't properly detect overflow!
	}
  801f7e:	eb c4                	jmp    801f44 <strtol+0x70>

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
  801f80:	89 c1                	mov    %eax,%ecx
  801f82:	eb 02                	jmp    801f86 <strtol+0xb2>
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801f84:	89 c1                	mov    %eax,%ecx
			break;
		s++, val = (val * base) + dig;
		// we don't properly detect overflow!
	}

	if (endptr)
  801f86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f8a:	74 05                	je     801f91 <strtol+0xbd>
		*endptr = (char *) s;
  801f8c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801f8f:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801f91:	85 ff                	test   %edi,%edi
  801f93:	74 04                	je     801f99 <strtol+0xc5>
  801f95:	89 c8                	mov    %ecx,%eax
  801f97:	f7 d8                	neg    %eax
}
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5f                   	pop    %edi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    
	...

00801fa0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801fa0:	55                   	push   %ebp
  801fa1:	89 e5                	mov    %esp,%ebp
  801fa3:	57                   	push   %edi
  801fa4:	56                   	push   %esi
  801fa5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801fa6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fae:	8b 55 08             	mov    0x8(%ebp),%edx
  801fb1:	89 c3                	mov    %eax,%ebx
  801fb3:	89 c7                	mov    %eax,%edi
  801fb5:	89 c6                	mov    %eax,%esi
  801fb7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801fb9:	5b                   	pop    %ebx
  801fba:	5e                   	pop    %esi
  801fbb:	5f                   	pop    %edi
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <sys_cgetc>:

int
sys_cgetc(void)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801fc4:	ba 00 00 00 00       	mov    $0x0,%edx
  801fc9:	b8 01 00 00 00       	mov    $0x1,%eax
  801fce:	89 d1                	mov    %edx,%ecx
  801fd0:	89 d3                	mov    %edx,%ebx
  801fd2:	89 d7                	mov    %edx,%edi
  801fd4:	89 d6                	mov    %edx,%esi
  801fd6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801fd8:	5b                   	pop    %ebx
  801fd9:	5e                   	pop    %esi
  801fda:	5f                   	pop    %edi
  801fdb:	5d                   	pop    %ebp
  801fdc:	c3                   	ret    

00801fdd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	57                   	push   %edi
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
  801feb:	b8 03 00 00 00       	mov    $0x3,%eax
  801ff0:	8b 55 08             	mov    0x8(%ebp),%edx
  801ff3:	89 cb                	mov    %ecx,%ebx
  801ff5:	89 cf                	mov    %ecx,%edi
  801ff7:	89 ce                	mov    %ecx,%esi
  801ff9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	7e 28                	jle    802027 <sys_env_destroy+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801fff:	89 44 24 10          	mov    %eax,0x10(%esp)
  802003:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80200a:	00 
  80200b:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  802012:	00 
  802013:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80201a:	00 
  80201b:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  802022:	e8 91 f5 ff ff       	call   8015b8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802027:	83 c4 2c             	add    $0x2c,%esp
  80202a:	5b                   	pop    %ebx
  80202b:	5e                   	pop    %esi
  80202c:	5f                   	pop    %edi
  80202d:	5d                   	pop    %ebp
  80202e:	c3                   	ret    

0080202f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80202f:	55                   	push   %ebp
  802030:	89 e5                	mov    %esp,%ebp
  802032:	57                   	push   %edi
  802033:	56                   	push   %esi
  802034:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802035:	ba 00 00 00 00       	mov    $0x0,%edx
  80203a:	b8 02 00 00 00       	mov    $0x2,%eax
  80203f:	89 d1                	mov    %edx,%ecx
  802041:	89 d3                	mov    %edx,%ebx
  802043:	89 d7                	mov    %edx,%edi
  802045:	89 d6                	mov    %edx,%esi
  802047:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802049:	5b                   	pop    %ebx
  80204a:	5e                   	pop    %esi
  80204b:	5f                   	pop    %edi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <sys_yield>:

void
sys_yield(void)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802054:	ba 00 00 00 00       	mov    $0x0,%edx
  802059:	b8 0b 00 00 00       	mov    $0xb,%eax
  80205e:	89 d1                	mov    %edx,%ecx
  802060:	89 d3                	mov    %edx,%ebx
  802062:	89 d7                	mov    %edx,%edi
  802064:	89 d6                	mov    %edx,%esi
  802066:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802068:	5b                   	pop    %ebx
  802069:	5e                   	pop    %esi
  80206a:	5f                   	pop    %edi
  80206b:	5d                   	pop    %ebp
  80206c:	c3                   	ret    

0080206d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80206d:	55                   	push   %ebp
  80206e:	89 e5                	mov    %esp,%ebp
  802070:	57                   	push   %edi
  802071:	56                   	push   %esi
  802072:	53                   	push   %ebx
  802073:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802076:	be 00 00 00 00       	mov    $0x0,%esi
  80207b:	b8 04 00 00 00       	mov    $0x4,%eax
  802080:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802083:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802086:	8b 55 08             	mov    0x8(%ebp),%edx
  802089:	89 f7                	mov    %esi,%edi
  80208b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80208d:	85 c0                	test   %eax,%eax
  80208f:	7e 28                	jle    8020b9 <sys_page_alloc+0x4c>
		panic("syscall %d returned %d (> 0)", num, ret);
  802091:	89 44 24 10          	mov    %eax,0x10(%esp)
  802095:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80209c:	00 
  80209d:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  8020a4:	00 
  8020a5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8020ac:	00 
  8020ad:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  8020b4:	e8 ff f4 ff ff       	call   8015b8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8020b9:	83 c4 2c             	add    $0x2c,%esp
  8020bc:	5b                   	pop    %ebx
  8020bd:	5e                   	pop    %esi
  8020be:	5f                   	pop    %edi
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    

008020c1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8020c1:	55                   	push   %ebp
  8020c2:	89 e5                	mov    %esp,%ebp
  8020c4:	57                   	push   %edi
  8020c5:	56                   	push   %esi
  8020c6:	53                   	push   %ebx
  8020c7:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8020ca:	b8 05 00 00 00       	mov    $0x5,%eax
  8020cf:	8b 75 18             	mov    0x18(%ebp),%esi
  8020d2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8020d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020db:	8b 55 08             	mov    0x8(%ebp),%edx
  8020de:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8020e0:	85 c0                	test   %eax,%eax
  8020e2:	7e 28                	jle    80210c <sys_page_map+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8020e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8020e8:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8020ef:	00 
  8020f0:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  8020f7:	00 
  8020f8:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8020ff:	00 
  802100:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  802107:	e8 ac f4 ff ff       	call   8015b8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80210c:	83 c4 2c             	add    $0x2c,%esp
  80210f:	5b                   	pop    %ebx
  802110:	5e                   	pop    %esi
  802111:	5f                   	pop    %edi
  802112:	5d                   	pop    %ebp
  802113:	c3                   	ret    

00802114 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	57                   	push   %edi
  802118:	56                   	push   %esi
  802119:	53                   	push   %ebx
  80211a:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80211d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802122:	b8 06 00 00 00       	mov    $0x6,%eax
  802127:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212a:	8b 55 08             	mov    0x8(%ebp),%edx
  80212d:	89 df                	mov    %ebx,%edi
  80212f:	89 de                	mov    %ebx,%esi
  802131:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802133:	85 c0                	test   %eax,%eax
  802135:	7e 28                	jle    80215f <sys_page_unmap+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802137:	89 44 24 10          	mov    %eax,0x10(%esp)
  80213b:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  802142:	00 
  802143:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  80214a:	00 
  80214b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  802152:	00 
  802153:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  80215a:	e8 59 f4 ff ff       	call   8015b8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80215f:	83 c4 2c             	add    $0x2c,%esp
  802162:	5b                   	pop    %ebx
  802163:	5e                   	pop    %esi
  802164:	5f                   	pop    %edi
  802165:	5d                   	pop    %ebp
  802166:	c3                   	ret    

00802167 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802167:	55                   	push   %ebp
  802168:	89 e5                	mov    %esp,%ebp
  80216a:	57                   	push   %edi
  80216b:	56                   	push   %esi
  80216c:	53                   	push   %ebx
  80216d:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802170:	bb 00 00 00 00       	mov    $0x0,%ebx
  802175:	b8 08 00 00 00       	mov    $0x8,%eax
  80217a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80217d:	8b 55 08             	mov    0x8(%ebp),%edx
  802180:	89 df                	mov    %ebx,%edi
  802182:	89 de                	mov    %ebx,%esi
  802184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802186:	85 c0                	test   %eax,%eax
  802188:	7e 28                	jle    8021b2 <sys_env_set_status+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80218a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80218e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  802195:	00 
  802196:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  80219d:	00 
  80219e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8021a5:	00 
  8021a6:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  8021ad:	e8 06 f4 ff ff       	call   8015b8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8021b2:	83 c4 2c             	add    $0x2c,%esp
  8021b5:	5b                   	pop    %ebx
  8021b6:	5e                   	pop    %esi
  8021b7:	5f                   	pop    %edi
  8021b8:	5d                   	pop    %ebp
  8021b9:	c3                   	ret    

008021ba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8021ba:	55                   	push   %ebp
  8021bb:	89 e5                	mov    %esp,%ebp
  8021bd:	57                   	push   %edi
  8021be:	56                   	push   %esi
  8021bf:	53                   	push   %ebx
  8021c0:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8021c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021c8:	b8 09 00 00 00       	mov    $0x9,%eax
  8021cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8021d3:	89 df                	mov    %ebx,%edi
  8021d5:	89 de                	mov    %ebx,%esi
  8021d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8021d9:	85 c0                	test   %eax,%eax
  8021db:	7e 28                	jle    802205 <sys_env_set_trapframe+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8021dd:	89 44 24 10          	mov    %eax,0x10(%esp)
  8021e1:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8021e8:	00 
  8021e9:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  8021f0:	00 
  8021f1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8021f8:	00 
  8021f9:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  802200:	e8 b3 f3 ff ff       	call   8015b8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802205:	83 c4 2c             	add    $0x2c,%esp
  802208:	5b                   	pop    %ebx
  802209:	5e                   	pop    %esi
  80220a:	5f                   	pop    %edi
  80220b:	5d                   	pop    %ebp
  80220c:	c3                   	ret    

0080220d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80220d:	55                   	push   %ebp
  80220e:	89 e5                	mov    %esp,%ebp
  802210:	57                   	push   %edi
  802211:	56                   	push   %esi
  802212:	53                   	push   %ebx
  802213:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802216:	bb 00 00 00 00       	mov    $0x0,%ebx
  80221b:	b8 0a 00 00 00       	mov    $0xa,%eax
  802220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802223:	8b 55 08             	mov    0x8(%ebp),%edx
  802226:	89 df                	mov    %ebx,%edi
  802228:	89 de                	mov    %ebx,%esi
  80222a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80222c:	85 c0                	test   %eax,%eax
  80222e:	7e 28                	jle    802258 <sys_env_set_pgfault_upcall+0x4b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802230:	89 44 24 10          	mov    %eax,0x10(%esp)
  802234:	c7 44 24 0c 0a 00 00 	movl   $0xa,0xc(%esp)
  80223b:	00 
  80223c:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  802243:	00 
  802244:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80224b:	00 
  80224c:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  802253:	e8 60 f3 ff ff       	call   8015b8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802258:	83 c4 2c             	add    $0x2c,%esp
  80225b:	5b                   	pop    %ebx
  80225c:	5e                   	pop    %esi
  80225d:	5f                   	pop    %edi
  80225e:	5d                   	pop    %ebp
  80225f:	c3                   	ret    

00802260 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	57                   	push   %edi
  802264:	56                   	push   %esi
  802265:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802266:	be 00 00 00 00       	mov    $0x0,%esi
  80226b:	b8 0c 00 00 00       	mov    $0xc,%eax
  802270:	8b 7d 14             	mov    0x14(%ebp),%edi
  802273:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802279:	8b 55 08             	mov    0x8(%ebp),%edx
  80227c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80227e:	5b                   	pop    %ebx
  80227f:	5e                   	pop    %esi
  802280:	5f                   	pop    %edi
  802281:	5d                   	pop    %ebp
  802282:	c3                   	ret    

00802283 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  802283:	55                   	push   %ebp
  802284:	89 e5                	mov    %esp,%ebp
  802286:	57                   	push   %edi
  802287:	56                   	push   %esi
  802288:	53                   	push   %ebx
  802289:	83 ec 2c             	sub    $0x2c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80228c:	b9 00 00 00 00       	mov    $0x0,%ecx
  802291:	b8 0d 00 00 00       	mov    $0xd,%eax
  802296:	8b 55 08             	mov    0x8(%ebp),%edx
  802299:	89 cb                	mov    %ecx,%ebx
  80229b:	89 cf                	mov    %ecx,%edi
  80229d:	89 ce                	mov    %ecx,%esi
  80229f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	7e 28                	jle    8022cd <sys_ipc_recv+0x4a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8022a5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8022a9:	c7 44 24 0c 0d 00 00 	movl   $0xd,0xc(%esp)
  8022b0:	00 
  8022b1:	c7 44 24 08 3f 3d 80 	movl   $0x803d3f,0x8(%esp)
  8022b8:	00 
  8022b9:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8022c0:	00 
  8022c1:	c7 04 24 5c 3d 80 00 	movl   $0x803d5c,(%esp)
  8022c8:	e8 eb f2 ff ff       	call   8015b8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8022cd:	83 c4 2c             	add    $0x2c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	00 00                	add    %al,(%eax)
	...

008022d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022d8:	55                   	push   %ebp
  8022d9:	89 e5                	mov    %esp,%ebp
  8022db:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  8022de:	83 3d 10 90 80 00 00 	cmpl   $0x0,0x809010
  8022e5:	0f 85 80 00 00 00    	jne    80236b <set_pgfault_handler+0x93>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P)) < 0) {
  8022eb:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8022f0:	8b 40 48             	mov    0x48(%eax),%eax
  8022f3:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8022fa:	00 
  8022fb:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  802302:	ee 
  802303:	89 04 24             	mov    %eax,(%esp)
  802306:	e8 62 fd ff ff       	call   80206d <sys_page_alloc>
  80230b:	85 c0                	test   %eax,%eax
  80230d:	79 20                	jns    80232f <set_pgfault_handler+0x57>
			panic("Set pgfault handler: %e when allocate page", r);
  80230f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802313:	c7 44 24 08 6c 3d 80 	movl   $0x803d6c,0x8(%esp)
  80231a:	00 
  80231b:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  802322:	00 
  802323:	c7 04 24 c8 3d 80 00 	movl   $0x803dc8,(%esp)
  80232a:	e8 89 f2 ff ff       	call   8015b8 <_panic>
		}
		if ((r = sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall)) < 0) {
  80232f:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802334:	8b 40 48             	mov    0x48(%eax),%eax
  802337:	c7 44 24 04 78 23 80 	movl   $0x802378,0x4(%esp)
  80233e:	00 
  80233f:	89 04 24             	mov    %eax,(%esp)
  802342:	e8 c6 fe ff ff       	call   80220d <sys_env_set_pgfault_upcall>
  802347:	85 c0                	test   %eax,%eax
  802349:	79 20                	jns    80236b <set_pgfault_handler+0x93>
			panic("Set pgfault handler: %e when set upcall handler", r);
  80234b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80234f:	c7 44 24 08 98 3d 80 	movl   $0x803d98,0x8(%esp)
  802356:	00 
  802357:	c7 44 24 04 24 00 00 	movl   $0x24,0x4(%esp)
  80235e:	00 
  80235f:	c7 04 24 c8 3d 80 00 	movl   $0x803dc8,(%esp)
  802366:	e8 4d f2 ff ff       	call   8015b8 <_panic>
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80236b:	8b 45 08             	mov    0x8(%ebp),%eax
  80236e:	a3 10 90 80 00       	mov    %eax,0x809010
}
  802373:	c9                   	leave  
  802374:	c3                   	ret    
  802375:	00 00                	add    %al,(%eax)
	...

00802378 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802378:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802379:	a1 10 90 80 00       	mov    0x809010,%eax
	call *%eax
  80237e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802380:	83 c4 04             	add    $0x4,%esp
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	// First, find the location of trap-time eip and store it to a register
	movl 0x28(%esp), %ebx
  802383:	8b 5c 24 28          	mov    0x28(%esp),%ebx

	// Second, store the current stack pointer
	movl %esp, %ecx
  802387:	89 e1                	mov    %esp,%ecx

	// Third, go back to the loaction where the original stack pointer pointed to.
	// Notice: the original stack pointer is located at 0x30(%esp)
	movl 0x30(%ecx), %esp
  802389:	8b 61 30             	mov    0x30(%ecx),%esp

	// Fourth, store eip at that location
	pushl %ebx
  80238c:	53                   	push   %ebx

	// Fifth, replace the original trap-time %esp with the new one, because we can no
	// longer use arithmetic operations later
	movl %esp, 0x30(%ecx)
  80238d:	89 61 30             	mov    %esp,0x30(%ecx)

	// Sixth, restore the top of stack
	movl %ecx, %esp
  802390:	89 cc                	mov    %ecx,%esp
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	// First, remove the last two numbers, which are fault_va and error code
	addl $8, %esp
  802392:	83 c4 08             	add    $0x8,%esp

	// Second, restore all registers
	popal
  802395:	61                   	popa   
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	// First, ignore the eip
	addl $4, %esp
  802396:	83 c4 04             	add    $0x4,%esp

	// Second, restore eflags
	popfl
  802399:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80239a:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80239b:	c3                   	ret    

0080239c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80239c:	55                   	push   %ebp
  80239d:	89 e5                	mov    %esp,%ebp
  80239f:	56                   	push   %esi
  8023a0:	53                   	push   %ebx
  8023a1:	83 ec 10             	sub    $0x10,%esp
  8023a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int err;
	// Map the page at address pg when pg is not null, 
	// otherwise, we can just pass a value greater than
	// UTOP.
	if (!pg) {
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	75 05                	jne    8023b6 <ipc_recv+0x1a>
		pg = (void *)(UTOP + 1);
  8023b1:	b8 01 00 c0 ee       	mov    $0xeec00001,%eax
	}
	err = sys_ipc_recv(pg);
  8023b6:	89 04 24             	mov    %eax,(%esp)
  8023b9:	e8 c5 fe ff ff       	call   802283 <sys_ipc_recv>
	if (!err) {
  8023be:	85 c0                	test   %eax,%eax
  8023c0:	75 26                	jne    8023e8 <ipc_recv+0x4c>
		if (from_env_store) {
  8023c2:	85 f6                	test   %esi,%esi
  8023c4:	74 0a                	je     8023d0 <ipc_recv+0x34>
			*from_env_store = thisenv->env_ipc_from;
  8023c6:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8023cb:	8b 40 74             	mov    0x74(%eax),%eax
  8023ce:	89 06                	mov    %eax,(%esi)
		}
		if (perm_store) {
  8023d0:	85 db                	test   %ebx,%ebx
  8023d2:	74 0a                	je     8023de <ipc_recv+0x42>
			*perm_store = thisenv->env_ipc_perm;
  8023d4:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8023d9:	8b 40 78             	mov    0x78(%eax),%eax
  8023dc:	89 03                	mov    %eax,(%ebx)
		}
		return thisenv->env_ipc_value;
  8023de:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8023e3:	8b 40 70             	mov    0x70(%eax),%eax
  8023e6:	eb 14                	jmp    8023fc <ipc_recv+0x60>
	}
	if (from_env_store) {
  8023e8:	85 f6                	test   %esi,%esi
  8023ea:	74 06                	je     8023f2 <ipc_recv+0x56>
		*from_env_store = 0;
  8023ec:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	}
	if (perm_store) {
  8023f2:	85 db                	test   %ebx,%ebx
  8023f4:	74 06                	je     8023fc <ipc_recv+0x60>
		*perm_store = 0;
  8023f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	return err;
}
  8023fc:	83 c4 10             	add    $0x10,%esp
  8023ff:	5b                   	pop    %ebx
  802400:	5e                   	pop    %esi
  802401:	5d                   	pop    %ebp
  802402:	c3                   	ret    

00802403 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802403:	55                   	push   %ebp
  802404:	89 e5                	mov    %esp,%ebp
  802406:	57                   	push   %edi
  802407:	56                   	push   %esi
  802408:	53                   	push   %ebx
  802409:	83 ec 1c             	sub    $0x1c,%esp
  80240c:	8b 75 10             	mov    0x10(%ebp),%esi
  80240f:	8b 7d 14             	mov    0x14(%ebp),%edi
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
  802412:	85 f6                	test   %esi,%esi
  802414:	75 05                	jne    80241b <ipc_send+0x18>
		pg = (void *)(UTOP + 1);
  802416:	be 01 00 c0 ee       	mov    $0xeec00001,%esi
	}
	while (err == -E_IPC_NOT_RECV)
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
  80241b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80241f:	89 74 24 08          	mov    %esi,0x8(%esp)
  802423:	8b 45 0c             	mov    0xc(%ebp),%eax
  802426:	89 44 24 04          	mov    %eax,0x4(%esp)
  80242a:	8b 45 08             	mov    0x8(%ebp),%eax
  80242d:	89 04 24             	mov    %eax,(%esp)
  802430:	e8 2b fe ff ff       	call   802260 <sys_ipc_try_send>
  802435:	89 c3                	mov    %eax,%ebx
		sys_yield();
  802437:	e8 12 fc ff ff       	call   80204e <sys_yield>
	// LAB 4: Your code here.
	int err = -E_IPC_NOT_RECV;
	if (!pg) {
		pg = (void *)(UTOP + 1);
	}
	while (err == -E_IPC_NOT_RECV)
  80243c:	83 fb f9             	cmp    $0xfffffff9,%ebx
  80243f:	74 da                	je     80241b <ipc_send+0x18>
	{
		err = sys_ipc_try_send(to_env, val, pg, perm);
		sys_yield();
	}
	// On success
	if (err) {
  802441:	85 db                	test   %ebx,%ebx
  802443:	74 20                	je     802465 <ipc_send+0x62>
		panic("send fail: %e", err);
  802445:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802449:	c7 44 24 08 d6 3d 80 	movl   $0x803dd6,0x8(%esp)
  802450:	00 
  802451:	c7 44 24 04 4b 00 00 	movl   $0x4b,0x4(%esp)
  802458:	00 
  802459:	c7 04 24 e4 3d 80 00 	movl   $0x803de4,(%esp)
  802460:	e8 53 f1 ff ff       	call   8015b8 <_panic>
	}
	return;
}
  802465:	83 c4 1c             	add    $0x1c,%esp
  802468:	5b                   	pop    %ebx
  802469:	5e                   	pop    %esi
  80246a:	5f                   	pop    %edi
  80246b:	5d                   	pop    %ebp
  80246c:	c3                   	ret    

0080246d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80246d:	55                   	push   %ebp
  80246e:	89 e5                	mov    %esp,%ebp
  802470:	53                   	push   %ebx
  802471:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i;
	for (i = 0; i < NENV; i++)
  802474:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802479:	8d 0c 85 00 00 00 00 	lea    0x0(,%eax,4),%ecx
  802480:	89 c2                	mov    %eax,%edx
  802482:	c1 e2 07             	shl    $0x7,%edx
  802485:	29 ca                	sub    %ecx,%edx
  802487:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80248d:	8b 52 50             	mov    0x50(%edx),%edx
  802490:	39 da                	cmp    %ebx,%edx
  802492:	75 0f                	jne    8024a3 <ipc_find_env+0x36>
			return envs[i].env_id;
  802494:	c1 e0 07             	shl    $0x7,%eax
  802497:	29 c8                	sub    %ecx,%eax
  802499:	05 08 00 c0 ee       	add    $0xeec00008,%eax
  80249e:	8b 40 40             	mov    0x40(%eax),%eax
  8024a1:	eb 0c                	jmp    8024af <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8024a3:	40                   	inc    %eax
  8024a4:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024a9:	75 ce                	jne    802479 <ipc_find_env+0xc>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8024ab:	66 b8 00 00          	mov    $0x0,%ax
}
  8024af:	5b                   	pop    %ebx
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
	...

008024b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8024b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8024ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8024bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8024c2:	5d                   	pop    %ebp
  8024c3:	c3                   	ret    

008024c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8024c4:	55                   	push   %ebp
  8024c5:	89 e5                	mov    %esp,%ebp
  8024c7:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8024ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8024cd:	89 04 24             	mov    %eax,(%esp)
  8024d0:	e8 df ff ff ff       	call   8024b4 <fd2num>
  8024d5:	05 20 00 0d 00       	add    $0xd0020,%eax
  8024da:	c1 e0 0c             	shl    $0xc,%eax
}
  8024dd:	c9                   	leave  
  8024de:	c3                   	ret    

008024df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	53                   	push   %ebx
  8024e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8024e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
  8024eb:	89 c1                	mov    %eax,%ecx
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8024ed:	89 c2                	mov    %eax,%edx
  8024ef:	c1 ea 16             	shr    $0x16,%edx
  8024f2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8024f9:	f6 c2 01             	test   $0x1,%dl
  8024fc:	74 11                	je     80250f <fd_alloc+0x30>
  8024fe:	89 c2                	mov    %eax,%edx
  802500:	c1 ea 0c             	shr    $0xc,%edx
  802503:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80250a:	f6 c2 01             	test   $0x1,%dl
  80250d:	75 09                	jne    802518 <fd_alloc+0x39>
			*fd_store = fd;
  80250f:	89 0b                	mov    %ecx,(%ebx)
			return 0;
  802511:	b8 00 00 00 00       	mov    $0x0,%eax
  802516:	eb 17                	jmp    80252f <fd_alloc+0x50>
  802518:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80251d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  802522:	75 c7                	jne    8024eb <fd_alloc+0xc>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  802524:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_MAX_OPEN;
  80252a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80252f:	5b                   	pop    %ebx
  802530:	5d                   	pop    %ebp
  802531:	c3                   	ret    

00802532 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  802532:	55                   	push   %ebp
  802533:	89 e5                	mov    %esp,%ebp
  802535:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802538:	83 f8 1f             	cmp    $0x1f,%eax
  80253b:	77 36                	ja     802573 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80253d:	05 00 00 0d 00       	add    $0xd0000,%eax
  802542:	c1 e0 0c             	shl    $0xc,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  802545:	89 c2                	mov    %eax,%edx
  802547:	c1 ea 16             	shr    $0x16,%edx
  80254a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802551:	f6 c2 01             	test   $0x1,%dl
  802554:	74 24                	je     80257a <fd_lookup+0x48>
  802556:	89 c2                	mov    %eax,%edx
  802558:	c1 ea 0c             	shr    $0xc,%edx
  80255b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802562:	f6 c2 01             	test   $0x1,%dl
  802565:	74 1a                	je     802581 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  802567:	8b 55 0c             	mov    0xc(%ebp),%edx
  80256a:	89 02                	mov    %eax,(%edx)
	return 0;
  80256c:	b8 00 00 00 00       	mov    $0x0,%eax
  802571:	eb 13                	jmp    802586 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802573:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802578:	eb 0c                	jmp    802586 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80257a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80257f:	eb 05                	jmp    802586 <fd_lookup+0x54>
  802581:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  802586:	5d                   	pop    %ebp
  802587:	c3                   	ret    

00802588 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802588:	55                   	push   %ebp
  802589:	89 e5                	mov    %esp,%ebp
  80258b:	53                   	push   %ebx
  80258c:	83 ec 14             	sub    $0x14,%esp
  80258f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802592:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
  802595:	ba 00 00 00 00       	mov    $0x0,%edx
  80259a:	eb 0e                	jmp    8025aa <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
  80259c:	39 08                	cmp    %ecx,(%eax)
  80259e:	75 09                	jne    8025a9 <dev_lookup+0x21>
			*dev = devtab[i];
  8025a0:	89 03                	mov    %eax,(%ebx)
			return 0;
  8025a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8025a7:	eb 33                	jmp    8025dc <dev_lookup+0x54>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8025a9:	42                   	inc    %edx
  8025aa:	8b 04 95 70 3e 80 00 	mov    0x803e70(,%edx,4),%eax
  8025b1:	85 c0                	test   %eax,%eax
  8025b3:	75 e7                	jne    80259c <dev_lookup+0x14>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8025b5:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8025ba:	8b 40 48             	mov    0x48(%eax),%eax
  8025bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8025c5:	c7 04 24 f0 3d 80 00 	movl   $0x803df0,(%esp)
  8025cc:	e8 df f0 ff ff       	call   8016b0 <cprintf>
	*dev = 0;
  8025d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	return -E_INVAL;
  8025d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8025dc:	83 c4 14             	add    $0x14,%esp
  8025df:	5b                   	pop    %ebx
  8025e0:	5d                   	pop    %ebp
  8025e1:	c3                   	ret    

008025e2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8025e2:	55                   	push   %ebp
  8025e3:	89 e5                	mov    %esp,%ebp
  8025e5:	56                   	push   %esi
  8025e6:	53                   	push   %ebx
  8025e7:	83 ec 30             	sub    $0x30,%esp
  8025ea:	8b 75 08             	mov    0x8(%ebp),%esi
  8025ed:	8a 45 0c             	mov    0xc(%ebp),%al
  8025f0:	88 45 e7             	mov    %al,-0x19(%ebp)
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8025f3:	89 34 24             	mov    %esi,(%esp)
  8025f6:	e8 b9 fe ff ff       	call   8024b4 <fd2num>
  8025fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8025fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  802602:	89 04 24             	mov    %eax,(%esp)
  802605:	e8 28 ff ff ff       	call   802532 <fd_lookup>
  80260a:	89 c3                	mov    %eax,%ebx
  80260c:	85 c0                	test   %eax,%eax
  80260e:	78 05                	js     802615 <fd_close+0x33>
	    || fd != fd2)
  802610:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802613:	74 0d                	je     802622 <fd_close+0x40>
		return (must_exist ? r : 0);
  802615:	80 7d e7 00          	cmpb   $0x0,-0x19(%ebp)
  802619:	75 46                	jne    802661 <fd_close+0x7f>
  80261b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802620:	eb 3f                	jmp    802661 <fd_close+0x7f>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  802622:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802625:	89 44 24 04          	mov    %eax,0x4(%esp)
  802629:	8b 06                	mov    (%esi),%eax
  80262b:	89 04 24             	mov    %eax,(%esp)
  80262e:	e8 55 ff ff ff       	call   802588 <dev_lookup>
  802633:	89 c3                	mov    %eax,%ebx
  802635:	85 c0                	test   %eax,%eax
  802637:	78 18                	js     802651 <fd_close+0x6f>
		if (dev->dev_close)
  802639:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80263c:	8b 40 10             	mov    0x10(%eax),%eax
  80263f:	85 c0                	test   %eax,%eax
  802641:	74 09                	je     80264c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802643:	89 34 24             	mov    %esi,(%esp)
  802646:	ff d0                	call   *%eax
  802648:	89 c3                	mov    %eax,%ebx
  80264a:	eb 05                	jmp    802651 <fd_close+0x6f>
		else
			r = 0;
  80264c:	bb 00 00 00 00       	mov    $0x0,%ebx
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  802651:	89 74 24 04          	mov    %esi,0x4(%esp)
  802655:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80265c:	e8 b3 fa ff ff       	call   802114 <sys_page_unmap>
	return r;
}
  802661:	89 d8                	mov    %ebx,%eax
  802663:	83 c4 30             	add    $0x30,%esp
  802666:	5b                   	pop    %ebx
  802667:	5e                   	pop    %esi
  802668:	5d                   	pop    %ebp
  802669:	c3                   	ret    

0080266a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80266a:	55                   	push   %ebp
  80266b:	89 e5                	mov    %esp,%ebp
  80266d:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802670:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802673:	89 44 24 04          	mov    %eax,0x4(%esp)
  802677:	8b 45 08             	mov    0x8(%ebp),%eax
  80267a:	89 04 24             	mov    %eax,(%esp)
  80267d:	e8 b0 fe ff ff       	call   802532 <fd_lookup>
  802682:	85 c0                	test   %eax,%eax
  802684:	78 13                	js     802699 <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  802686:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80268d:	00 
  80268e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802691:	89 04 24             	mov    %eax,(%esp)
  802694:	e8 49 ff ff ff       	call   8025e2 <fd_close>
}
  802699:	c9                   	leave  
  80269a:	c3                   	ret    

0080269b <close_all>:

void
close_all(void)
{
  80269b:	55                   	push   %ebp
  80269c:	89 e5                	mov    %esp,%ebp
  80269e:	53                   	push   %ebx
  80269f:	83 ec 14             	sub    $0x14,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8026a2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8026a7:	89 1c 24             	mov    %ebx,(%esp)
  8026aa:	e8 bb ff ff ff       	call   80266a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8026af:	43                   	inc    %ebx
  8026b0:	83 fb 20             	cmp    $0x20,%ebx
  8026b3:	75 f2                	jne    8026a7 <close_all+0xc>
		close(i);
}
  8026b5:	83 c4 14             	add    $0x14,%esp
  8026b8:	5b                   	pop    %ebx
  8026b9:	5d                   	pop    %ebp
  8026ba:	c3                   	ret    

008026bb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8026bb:	55                   	push   %ebp
  8026bc:	89 e5                	mov    %esp,%ebp
  8026be:	57                   	push   %edi
  8026bf:	56                   	push   %esi
  8026c0:	53                   	push   %ebx
  8026c1:	83 ec 4c             	sub    $0x4c,%esp
  8026c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8026c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8026ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8026ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8026d1:	89 04 24             	mov    %eax,(%esp)
  8026d4:	e8 59 fe ff ff       	call   802532 <fd_lookup>
  8026d9:	89 c3                	mov    %eax,%ebx
  8026db:	85 c0                	test   %eax,%eax
  8026dd:	0f 88 e1 00 00 00    	js     8027c4 <dup+0x109>
		return r;
	close(newfdnum);
  8026e3:	89 3c 24             	mov    %edi,(%esp)
  8026e6:	e8 7f ff ff ff       	call   80266a <close>

	newfd = INDEX2FD(newfdnum);
  8026eb:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8026f1:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8026f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8026f7:	89 04 24             	mov    %eax,(%esp)
  8026fa:	e8 c5 fd ff ff       	call   8024c4 <fd2data>
  8026ff:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802701:	89 34 24             	mov    %esi,(%esp)
  802704:	e8 bb fd ff ff       	call   8024c4 <fd2data>
  802709:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80270c:	89 d8                	mov    %ebx,%eax
  80270e:	c1 e8 16             	shr    $0x16,%eax
  802711:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802718:	a8 01                	test   $0x1,%al
  80271a:	74 46                	je     802762 <dup+0xa7>
  80271c:	89 d8                	mov    %ebx,%eax
  80271e:	c1 e8 0c             	shr    $0xc,%eax
  802721:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802728:	f6 c2 01             	test   $0x1,%dl
  80272b:	74 35                	je     802762 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80272d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802734:	25 07 0e 00 00       	and    $0xe07,%eax
  802739:	89 44 24 10          	mov    %eax,0x10(%esp)
  80273d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  802740:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802744:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80274b:	00 
  80274c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802750:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802757:	e8 65 f9 ff ff       	call   8020c1 <sys_page_map>
  80275c:	89 c3                	mov    %eax,%ebx
  80275e:	85 c0                	test   %eax,%eax
  802760:	78 3b                	js     80279d <dup+0xe2>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802765:	89 c2                	mov    %eax,%edx
  802767:	c1 ea 0c             	shr    $0xc,%edx
  80276a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802771:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  802777:	89 54 24 10          	mov    %edx,0x10(%esp)
  80277b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80277f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802786:	00 
  802787:	89 44 24 04          	mov    %eax,0x4(%esp)
  80278b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802792:	e8 2a f9 ff ff       	call   8020c1 <sys_page_map>
  802797:	89 c3                	mov    %eax,%ebx
  802799:	85 c0                	test   %eax,%eax
  80279b:	79 25                	jns    8027c2 <dup+0x107>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80279d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027a8:	e8 67 f9 ff ff       	call   802114 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8027ad:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8027b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8027bb:	e8 54 f9 ff ff       	call   802114 <sys_page_unmap>
	return r;
  8027c0:	eb 02                	jmp    8027c4 <dup+0x109>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
		goto err;

	return newfdnum;
  8027c2:	89 fb                	mov    %edi,%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8027c4:	89 d8                	mov    %ebx,%eax
  8027c6:	83 c4 4c             	add    $0x4c,%esp
  8027c9:	5b                   	pop    %ebx
  8027ca:	5e                   	pop    %esi
  8027cb:	5f                   	pop    %edi
  8027cc:	5d                   	pop    %ebp
  8027cd:	c3                   	ret    

008027ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8027ce:	55                   	push   %ebp
  8027cf:	89 e5                	mov    %esp,%ebp
  8027d1:	53                   	push   %ebx
  8027d2:	83 ec 24             	sub    $0x24,%esp
  8027d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8027d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8027db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027df:	89 1c 24             	mov    %ebx,(%esp)
  8027e2:	e8 4b fd ff ff       	call   802532 <fd_lookup>
  8027e7:	85 c0                	test   %eax,%eax
  8027e9:	78 6d                	js     802858 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8027eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8027ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8027f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8027f5:	8b 00                	mov    (%eax),%eax
  8027f7:	89 04 24             	mov    %eax,(%esp)
  8027fa:	e8 89 fd ff ff       	call   802588 <dev_lookup>
  8027ff:	85 c0                	test   %eax,%eax
  802801:	78 55                	js     802858 <read+0x8a>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802803:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802806:	8b 50 08             	mov    0x8(%eax),%edx
  802809:	83 e2 03             	and    $0x3,%edx
  80280c:	83 fa 01             	cmp    $0x1,%edx
  80280f:	75 23                	jne    802834 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802811:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802816:	8b 40 48             	mov    0x48(%eax),%eax
  802819:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80281d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802821:	c7 04 24 34 3e 80 00 	movl   $0x803e34,(%esp)
  802828:	e8 83 ee ff ff       	call   8016b0 <cprintf>
		return -E_INVAL;
  80282d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802832:	eb 24                	jmp    802858 <read+0x8a>
	}
	if (!dev->dev_read)
  802834:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802837:	8b 52 08             	mov    0x8(%edx),%edx
  80283a:	85 d2                	test   %edx,%edx
  80283c:	74 15                	je     802853 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80283e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802841:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802845:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802848:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80284c:	89 04 24             	mov    %eax,(%esp)
  80284f:	ff d2                	call   *%edx
  802851:	eb 05                	jmp    802858 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802853:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_read)(fd, buf, n);
}
  802858:	83 c4 24             	add    $0x24,%esp
  80285b:	5b                   	pop    %ebx
  80285c:	5d                   	pop    %ebp
  80285d:	c3                   	ret    

0080285e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80285e:	55                   	push   %ebp
  80285f:	89 e5                	mov    %esp,%ebp
  802861:	57                   	push   %edi
  802862:	56                   	push   %esi
  802863:	53                   	push   %ebx
  802864:	83 ec 1c             	sub    $0x1c,%esp
  802867:	8b 7d 08             	mov    0x8(%ebp),%edi
  80286a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80286d:	bb 00 00 00 00       	mov    $0x0,%ebx
  802872:	eb 23                	jmp    802897 <readn+0x39>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802874:	89 f0                	mov    %esi,%eax
  802876:	29 d8                	sub    %ebx,%eax
  802878:	89 44 24 08          	mov    %eax,0x8(%esp)
  80287c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80287f:	01 d8                	add    %ebx,%eax
  802881:	89 44 24 04          	mov    %eax,0x4(%esp)
  802885:	89 3c 24             	mov    %edi,(%esp)
  802888:	e8 41 ff ff ff       	call   8027ce <read>
		if (m < 0)
  80288d:	85 c0                	test   %eax,%eax
  80288f:	78 10                	js     8028a1 <readn+0x43>
			return m;
		if (m == 0)
  802891:	85 c0                	test   %eax,%eax
  802893:	74 0a                	je     80289f <readn+0x41>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802895:	01 c3                	add    %eax,%ebx
  802897:	39 f3                	cmp    %esi,%ebx
  802899:	72 d9                	jb     802874 <readn+0x16>
  80289b:	89 d8                	mov    %ebx,%eax
  80289d:	eb 02                	jmp    8028a1 <readn+0x43>
		m = read(fdnum, (char*)buf + tot, n - tot);
		if (m < 0)
			return m;
		if (m == 0)
  80289f:	89 d8                	mov    %ebx,%eax
			break;
	}
	return tot;
}
  8028a1:	83 c4 1c             	add    $0x1c,%esp
  8028a4:	5b                   	pop    %ebx
  8028a5:	5e                   	pop    %esi
  8028a6:	5f                   	pop    %edi
  8028a7:	5d                   	pop    %ebp
  8028a8:	c3                   	ret    

008028a9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8028a9:	55                   	push   %ebp
  8028aa:	89 e5                	mov    %esp,%ebp
  8028ac:	53                   	push   %ebx
  8028ad:	83 ec 24             	sub    $0x24,%esp
  8028b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8028b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8028b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028ba:	89 1c 24             	mov    %ebx,(%esp)
  8028bd:	e8 70 fc ff ff       	call   802532 <fd_lookup>
  8028c2:	85 c0                	test   %eax,%eax
  8028c4:	78 68                	js     80292e <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8028c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028d0:	8b 00                	mov    (%eax),%eax
  8028d2:	89 04 24             	mov    %eax,(%esp)
  8028d5:	e8 ae fc ff ff       	call   802588 <dev_lookup>
  8028da:	85 c0                	test   %eax,%eax
  8028dc:	78 50                	js     80292e <write+0x85>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8028de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8028e1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8028e5:	75 23                	jne    80290a <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8028e7:	a1 0c 90 80 00       	mov    0x80900c,%eax
  8028ec:	8b 40 48             	mov    0x48(%eax),%eax
  8028ef:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8028f7:	c7 04 24 50 3e 80 00 	movl   $0x803e50,(%esp)
  8028fe:	e8 ad ed ff ff       	call   8016b0 <cprintf>
		return -E_INVAL;
  802903:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802908:	eb 24                	jmp    80292e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80290a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80290d:	8b 52 0c             	mov    0xc(%edx),%edx
  802910:	85 d2                	test   %edx,%edx
  802912:	74 15                	je     802929 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802914:	8b 4d 10             	mov    0x10(%ebp),%ecx
  802917:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80291b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80291e:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802922:	89 04 24             	mov    %eax,(%esp)
  802925:	ff d2                	call   *%edx
  802927:	eb 05                	jmp    80292e <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802929:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_write)(fd, buf, n);
}
  80292e:	83 c4 24             	add    $0x24,%esp
  802931:	5b                   	pop    %ebx
  802932:	5d                   	pop    %ebp
  802933:	c3                   	ret    

00802934 <seek>:

int
seek(int fdnum, off_t offset)
{
  802934:	55                   	push   %ebp
  802935:	89 e5                	mov    %esp,%ebp
  802937:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80293a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80293d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802941:	8b 45 08             	mov    0x8(%ebp),%eax
  802944:	89 04 24             	mov    %eax,(%esp)
  802947:	e8 e6 fb ff ff       	call   802532 <fd_lookup>
  80294c:	85 c0                	test   %eax,%eax
  80294e:	78 0e                	js     80295e <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  802950:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802953:	8b 55 0c             	mov    0xc(%ebp),%edx
  802956:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802959:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80295e:	c9                   	leave  
  80295f:	c3                   	ret    

00802960 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802960:	55                   	push   %ebp
  802961:	89 e5                	mov    %esp,%ebp
  802963:	53                   	push   %ebx
  802964:	83 ec 24             	sub    $0x24,%esp
  802967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80296a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80296d:	89 44 24 04          	mov    %eax,0x4(%esp)
  802971:	89 1c 24             	mov    %ebx,(%esp)
  802974:	e8 b9 fb ff ff       	call   802532 <fd_lookup>
  802979:	85 c0                	test   %eax,%eax
  80297b:	78 61                	js     8029de <ftruncate+0x7e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80297d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802980:	89 44 24 04          	mov    %eax,0x4(%esp)
  802984:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802987:	8b 00                	mov    (%eax),%eax
  802989:	89 04 24             	mov    %eax,(%esp)
  80298c:	e8 f7 fb ff ff       	call   802588 <dev_lookup>
  802991:	85 c0                	test   %eax,%eax
  802993:	78 49                	js     8029de <ftruncate+0x7e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802995:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802998:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80299c:	75 23                	jne    8029c1 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80299e:	a1 0c 90 80 00       	mov    0x80900c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8029a3:	8b 40 48             	mov    0x48(%eax),%eax
  8029a6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8029aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029ae:	c7 04 24 10 3e 80 00 	movl   $0x803e10,(%esp)
  8029b5:	e8 f6 ec ff ff       	call   8016b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8029ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8029bf:	eb 1d                	jmp    8029de <ftruncate+0x7e>
	}
	if (!dev->dev_trunc)
  8029c1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8029c4:	8b 52 18             	mov    0x18(%edx),%edx
  8029c7:	85 d2                	test   %edx,%edx
  8029c9:	74 0e                	je     8029d9 <ftruncate+0x79>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8029cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8029ce:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8029d2:	89 04 24             	mov    %eax,(%esp)
  8029d5:	ff d2                	call   *%edx
  8029d7:	eb 05                	jmp    8029de <ftruncate+0x7e>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8029d9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return (*dev->dev_trunc)(fd, newsize);
}
  8029de:	83 c4 24             	add    $0x24,%esp
  8029e1:	5b                   	pop    %ebx
  8029e2:	5d                   	pop    %ebp
  8029e3:	c3                   	ret    

008029e4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8029e4:	55                   	push   %ebp
  8029e5:	89 e5                	mov    %esp,%ebp
  8029e7:	53                   	push   %ebx
  8029e8:	83 ec 24             	sub    $0x24,%esp
  8029eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8029ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8029f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8029f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8029f8:	89 04 24             	mov    %eax,(%esp)
  8029fb:	e8 32 fb ff ff       	call   802532 <fd_lookup>
  802a00:	85 c0                	test   %eax,%eax
  802a02:	78 52                	js     802a56 <fstat+0x72>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802a04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802a07:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802a0e:	8b 00                	mov    (%eax),%eax
  802a10:	89 04 24             	mov    %eax,(%esp)
  802a13:	e8 70 fb ff ff       	call   802588 <dev_lookup>
  802a18:	85 c0                	test   %eax,%eax
  802a1a:	78 3a                	js     802a56 <fstat+0x72>
		return r;
	if (!dev->dev_stat)
  802a1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802a1f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802a23:	74 2c                	je     802a51 <fstat+0x6d>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802a25:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802a28:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802a2f:	00 00 00 
	stat->st_isdir = 0;
  802a32:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802a39:	00 00 00 
	stat->st_dev = dev;
  802a3c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802a42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802a46:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802a49:	89 14 24             	mov    %edx,(%esp)
  802a4c:	ff 50 14             	call   *0x14(%eax)
  802a4f:	eb 05                	jmp    802a56 <fstat+0x72>

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802a51:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802a56:	83 c4 24             	add    $0x24,%esp
  802a59:	5b                   	pop    %ebx
  802a5a:	5d                   	pop    %ebp
  802a5b:	c3                   	ret    

00802a5c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802a5c:	55                   	push   %ebp
  802a5d:	89 e5                	mov    %esp,%ebp
  802a5f:	56                   	push   %esi
  802a60:	53                   	push   %ebx
  802a61:	83 ec 10             	sub    $0x10,%esp
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802a64:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802a6b:	00 
  802a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  802a6f:	89 04 24             	mov    %eax,(%esp)
  802a72:	e8 fe 01 00 00       	call   802c75 <open>
  802a77:	89 c3                	mov    %eax,%ebx
  802a79:	85 c0                	test   %eax,%eax
  802a7b:	78 1b                	js     802a98 <stat+0x3c>
		return fd;
	r = fstat(fd, stat);
  802a7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802a80:	89 44 24 04          	mov    %eax,0x4(%esp)
  802a84:	89 1c 24             	mov    %ebx,(%esp)
  802a87:	e8 58 ff ff ff       	call   8029e4 <fstat>
  802a8c:	89 c6                	mov    %eax,%esi
	close(fd);
  802a8e:	89 1c 24             	mov    %ebx,(%esp)
  802a91:	e8 d4 fb ff ff       	call   80266a <close>
	return r;
  802a96:	89 f3                	mov    %esi,%ebx
}
  802a98:	89 d8                	mov    %ebx,%eax
  802a9a:	83 c4 10             	add    $0x10,%esp
  802a9d:	5b                   	pop    %ebx
  802a9e:	5e                   	pop    %esi
  802a9f:	5d                   	pop    %ebp
  802aa0:	c3                   	ret    
  802aa1:	00 00                	add    %al,(%eax)
	...

00802aa4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802aa4:	55                   	push   %ebp
  802aa5:	89 e5                	mov    %esp,%ebp
  802aa7:	56                   	push   %esi
  802aa8:	53                   	push   %ebx
  802aa9:	83 ec 10             	sub    $0x10,%esp
  802aac:	89 c3                	mov    %eax,%ebx
  802aae:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  802ab0:	83 3d 00 90 80 00 00 	cmpl   $0x0,0x809000
  802ab7:	75 11                	jne    802aca <fsipc+0x26>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802ab9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  802ac0:	e8 a8 f9 ff ff       	call   80246d <ipc_find_env>
  802ac5:	a3 00 90 80 00       	mov    %eax,0x809000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802aca:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  802ad1:	00 
  802ad2:	c7 44 24 08 00 a0 80 	movl   $0x80a000,0x8(%esp)
  802ad9:	00 
  802ada:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802ade:	a1 00 90 80 00       	mov    0x809000,%eax
  802ae3:	89 04 24             	mov    %eax,(%esp)
  802ae6:	e8 18 f9 ff ff       	call   802403 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802aeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802af2:	00 
  802af3:	89 74 24 04          	mov    %esi,0x4(%esp)
  802af7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802afe:	e8 99 f8 ff ff       	call   80239c <ipc_recv>
}
  802b03:	83 c4 10             	add    $0x10,%esp
  802b06:	5b                   	pop    %ebx
  802b07:	5e                   	pop    %esi
  802b08:	5d                   	pop    %ebp
  802b09:	c3                   	ret    

00802b0a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802b0a:	55                   	push   %ebp
  802b0b:	89 e5                	mov    %esp,%ebp
  802b0d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802b10:	8b 45 08             	mov    0x8(%ebp),%eax
  802b13:	8b 40 0c             	mov    0xc(%eax),%eax
  802b16:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.set_size.req_size = newsize;
  802b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802b1e:	a3 04 a0 80 00       	mov    %eax,0x80a004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802b23:	ba 00 00 00 00       	mov    $0x0,%edx
  802b28:	b8 02 00 00 00       	mov    $0x2,%eax
  802b2d:	e8 72 ff ff ff       	call   802aa4 <fsipc>
}
  802b32:	c9                   	leave  
  802b33:	c3                   	ret    

00802b34 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802b34:	55                   	push   %ebp
  802b35:	89 e5                	mov    %esp,%ebp
  802b37:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  802b3d:	8b 40 0c             	mov    0xc(%eax),%eax
  802b40:	a3 00 a0 80 00       	mov    %eax,0x80a000
	return fsipc(FSREQ_FLUSH, NULL);
  802b45:	ba 00 00 00 00       	mov    $0x0,%edx
  802b4a:	b8 06 00 00 00       	mov    $0x6,%eax
  802b4f:	e8 50 ff ff ff       	call   802aa4 <fsipc>
}
  802b54:	c9                   	leave  
  802b55:	c3                   	ret    

00802b56 <devfile_stat>:
	panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802b56:	55                   	push   %ebp
  802b57:	89 e5                	mov    %esp,%ebp
  802b59:	53                   	push   %ebx
  802b5a:	83 ec 14             	sub    $0x14,%esp
  802b5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802b60:	8b 45 08             	mov    0x8(%ebp),%eax
  802b63:	8b 40 0c             	mov    0xc(%eax),%eax
  802b66:	a3 00 a0 80 00       	mov    %eax,0x80a000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  802b70:	b8 05 00 00 00       	mov    $0x5,%eax
  802b75:	e8 2a ff ff ff       	call   802aa4 <fsipc>
  802b7a:	85 c0                	test   %eax,%eax
  802b7c:	78 2b                	js     802ba9 <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802b7e:	c7 44 24 04 00 a0 80 	movl   $0x80a000,0x4(%esp)
  802b85:	00 
  802b86:	89 1c 24             	mov    %ebx,(%esp)
  802b89:	e8 ed f0 ff ff       	call   801c7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802b8e:	a1 80 a0 80 00       	mov    0x80a080,%eax
  802b93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802b99:	a1 84 a0 80 00       	mov    0x80a084,%eax
  802b9e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802ba4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802ba9:	83 c4 14             	add    $0x14,%esp
  802bac:	5b                   	pop    %ebx
  802bad:	5d                   	pop    %ebp
  802bae:	c3                   	ret    

00802baf <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802baf:	55                   	push   %ebp
  802bb0:	89 e5                	mov    %esp,%ebp
  802bb2:	83 ec 18             	sub    $0x18,%esp
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	panic("devfile_write not implemented");
  802bb5:	c7 44 24 08 80 3e 80 	movl   $0x803e80,0x8(%esp)
  802bbc:	00 
  802bbd:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
  802bc4:	00 
  802bc5:	c7 04 24 9e 3e 80 00 	movl   $0x803e9e,(%esp)
  802bcc:	e8 e7 e9 ff ff       	call   8015b8 <_panic>

00802bd1 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802bd1:	55                   	push   %ebp
  802bd2:	89 e5                	mov    %esp,%ebp
  802bd4:	56                   	push   %esi
  802bd5:	53                   	push   %ebx
  802bd6:	83 ec 10             	sub    $0x10,%esp
  802bd9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  802bdf:	8b 40 0c             	mov    0xc(%eax),%eax
  802be2:	a3 00 a0 80 00       	mov    %eax,0x80a000
	fsipcbuf.read.req_n = n;
  802be7:	89 35 04 a0 80 00    	mov    %esi,0x80a004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802bed:	ba 00 00 00 00       	mov    $0x0,%edx
  802bf2:	b8 03 00 00 00       	mov    $0x3,%eax
  802bf7:	e8 a8 fe ff ff       	call   802aa4 <fsipc>
  802bfc:	89 c3                	mov    %eax,%ebx
  802bfe:	85 c0                	test   %eax,%eax
  802c00:	78 6a                	js     802c6c <devfile_read+0x9b>
		return r;
	assert(r <= n);
  802c02:	39 c6                	cmp    %eax,%esi
  802c04:	73 24                	jae    802c2a <devfile_read+0x59>
  802c06:	c7 44 24 0c a9 3e 80 	movl   $0x803ea9,0xc(%esp)
  802c0d:	00 
  802c0e:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  802c15:	00 
  802c16:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  802c1d:	00 
  802c1e:	c7 04 24 9e 3e 80 00 	movl   $0x803e9e,(%esp)
  802c25:	e8 8e e9 ff ff       	call   8015b8 <_panic>
	assert(r <= PGSIZE);
  802c2a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802c2f:	7e 24                	jle    802c55 <devfile_read+0x84>
  802c31:	c7 44 24 0c b0 3e 80 	movl   $0x803eb0,0xc(%esp)
  802c38:	00 
  802c39:	c7 44 24 08 fd 34 80 	movl   $0x8034fd,0x8(%esp)
  802c40:	00 
  802c41:	c7 44 24 04 7d 00 00 	movl   $0x7d,0x4(%esp)
  802c48:	00 
  802c49:	c7 04 24 9e 3e 80 00 	movl   $0x803e9e,(%esp)
  802c50:	e8 63 e9 ff ff       	call   8015b8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802c55:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c59:	c7 44 24 04 00 a0 80 	movl   $0x80a000,0x4(%esp)
  802c60:	00 
  802c61:	8b 45 0c             	mov    0xc(%ebp),%eax
  802c64:	89 04 24             	mov    %eax,(%esp)
  802c67:	e8 88 f1 ff ff       	call   801df4 <memmove>
	return r;
}
  802c6c:	89 d8                	mov    %ebx,%eax
  802c6e:	83 c4 10             	add    $0x10,%esp
  802c71:	5b                   	pop    %ebx
  802c72:	5e                   	pop    %esi
  802c73:	5d                   	pop    %ebp
  802c74:	c3                   	ret    

00802c75 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802c75:	55                   	push   %ebp
  802c76:	89 e5                	mov    %esp,%ebp
  802c78:	56                   	push   %esi
  802c79:	53                   	push   %ebx
  802c7a:	83 ec 20             	sub    $0x20,%esp
  802c7d:	8b 75 08             	mov    0x8(%ebp),%esi
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802c80:	89 34 24             	mov    %esi,(%esp)
  802c83:	e8 c0 ef ff ff       	call   801c48 <strlen>
  802c88:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802c8d:	7f 60                	jg     802cef <open+0x7a>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c92:	89 04 24             	mov    %eax,(%esp)
  802c95:	e8 45 f8 ff ff       	call   8024df <fd_alloc>
  802c9a:	89 c3                	mov    %eax,%ebx
  802c9c:	85 c0                	test   %eax,%eax
  802c9e:	78 54                	js     802cf4 <open+0x7f>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802ca0:	89 74 24 04          	mov    %esi,0x4(%esp)
  802ca4:	c7 04 24 00 a0 80 00 	movl   $0x80a000,(%esp)
  802cab:	e8 cb ef ff ff       	call   801c7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  802cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802cb3:	a3 00 a4 80 00       	mov    %eax,0x80a400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802cb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802cbb:	b8 01 00 00 00       	mov    $0x1,%eax
  802cc0:	e8 df fd ff ff       	call   802aa4 <fsipc>
  802cc5:	89 c3                	mov    %eax,%ebx
  802cc7:	85 c0                	test   %eax,%eax
  802cc9:	79 15                	jns    802ce0 <open+0x6b>
		fd_close(fd, 0);
  802ccb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802cd2:	00 
  802cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cd6:	89 04 24             	mov    %eax,(%esp)
  802cd9:	e8 04 f9 ff ff       	call   8025e2 <fd_close>
		return r;
  802cde:	eb 14                	jmp    802cf4 <open+0x7f>
	}

	return fd2num(fd);
  802ce0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ce3:	89 04 24             	mov    %eax,(%esp)
  802ce6:	e8 c9 f7 ff ff       	call   8024b4 <fd2num>
  802ceb:	89 c3                	mov    %eax,%ebx
  802ced:	eb 05                	jmp    802cf4 <open+0x7f>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802cef:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802cf4:	89 d8                	mov    %ebx,%eax
  802cf6:	83 c4 20             	add    $0x20,%esp
  802cf9:	5b                   	pop    %ebx
  802cfa:	5e                   	pop    %esi
  802cfb:	5d                   	pop    %ebp
  802cfc:	c3                   	ret    

00802cfd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802cfd:	55                   	push   %ebp
  802cfe:	89 e5                	mov    %esp,%ebp
  802d00:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802d03:	ba 00 00 00 00       	mov    $0x0,%edx
  802d08:	b8 08 00 00 00       	mov    $0x8,%eax
  802d0d:	e8 92 fd ff ff       	call   802aa4 <fsipc>
}
  802d12:	c9                   	leave  
  802d13:	c3                   	ret    

00802d14 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802d14:	55                   	push   %ebp
  802d15:	89 e5                	mov    %esp,%ebp
  802d17:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802d1a:	89 c2                	mov    %eax,%edx
  802d1c:	c1 ea 16             	shr    $0x16,%edx
  802d1f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802d26:	f6 c2 01             	test   $0x1,%dl
  802d29:	74 1e                	je     802d49 <pageref+0x35>
		return 0;
	pte = uvpt[PGNUM(v)];
  802d2b:	c1 e8 0c             	shr    $0xc,%eax
  802d2e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802d35:	a8 01                	test   $0x1,%al
  802d37:	74 17                	je     802d50 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802d39:	c1 e8 0c             	shr    $0xc,%eax
  802d3c:	66 8b 04 c5 04 00 00 	mov    -0x10fffffc(,%eax,8),%ax
  802d43:	ef 
  802d44:	0f b7 c0             	movzwl %ax,%eax
  802d47:	eb 0c                	jmp    802d55 <pageref+0x41>
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
		return 0;
  802d49:	b8 00 00 00 00       	mov    $0x0,%eax
  802d4e:	eb 05                	jmp    802d55 <pageref+0x41>
	pte = uvpt[PGNUM(v)];
	if (!(pte & PTE_P))
		return 0;
  802d50:	b8 00 00 00 00       	mov    $0x0,%eax
	return pages[PGNUM(pte)].pp_ref;
}
  802d55:	5d                   	pop    %ebp
  802d56:	c3                   	ret    
	...

00802d58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802d58:	55                   	push   %ebp
  802d59:	89 e5                	mov    %esp,%ebp
  802d5b:	56                   	push   %esi
  802d5c:	53                   	push   %ebx
  802d5d:	83 ec 10             	sub    $0x10,%esp
  802d60:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802d63:	8b 45 08             	mov    0x8(%ebp),%eax
  802d66:	89 04 24             	mov    %eax,(%esp)
  802d69:	e8 56 f7 ff ff       	call   8024c4 <fd2data>
  802d6e:	89 c3                	mov    %eax,%ebx
	strcpy(stat->st_name, "<pipe>");
  802d70:	c7 44 24 04 bc 3e 80 	movl   $0x803ebc,0x4(%esp)
  802d77:	00 
  802d78:	89 34 24             	mov    %esi,(%esp)
  802d7b:	e8 fb ee ff ff       	call   801c7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802d80:	8b 43 04             	mov    0x4(%ebx),%eax
  802d83:	2b 03                	sub    (%ebx),%eax
  802d85:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	stat->st_isdir = 0;
  802d8b:	c7 86 84 00 00 00 00 	movl   $0x0,0x84(%esi)
  802d92:	00 00 00 
	stat->st_dev = &devpipe;
  802d95:	c7 86 88 00 00 00 80 	movl   $0x808080,0x88(%esi)
  802d9c:	80 80 00 
	return 0;
}
  802d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  802da4:	83 c4 10             	add    $0x10,%esp
  802da7:	5b                   	pop    %ebx
  802da8:	5e                   	pop    %esi
  802da9:	5d                   	pop    %ebp
  802daa:	c3                   	ret    

00802dab <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802dab:	55                   	push   %ebp
  802dac:	89 e5                	mov    %esp,%ebp
  802dae:	53                   	push   %ebx
  802daf:	83 ec 14             	sub    $0x14,%esp
  802db2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802db5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802db9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dc0:	e8 4f f3 ff ff       	call   802114 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802dc5:	89 1c 24             	mov    %ebx,(%esp)
  802dc8:	e8 f7 f6 ff ff       	call   8024c4 <fd2data>
  802dcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  802dd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802dd8:	e8 37 f3 ff ff       	call   802114 <sys_page_unmap>
}
  802ddd:	83 c4 14             	add    $0x14,%esp
  802de0:	5b                   	pop    %ebx
  802de1:	5d                   	pop    %ebp
  802de2:	c3                   	ret    

00802de3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802de3:	55                   	push   %ebp
  802de4:	89 e5                	mov    %esp,%ebp
  802de6:	57                   	push   %edi
  802de7:	56                   	push   %esi
  802de8:	53                   	push   %ebx
  802de9:	83 ec 2c             	sub    $0x2c,%esp
  802dec:	89 c7                	mov    %eax,%edi
  802dee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802df1:	a1 0c 90 80 00       	mov    0x80900c,%eax
  802df6:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802df9:	89 3c 24             	mov    %edi,(%esp)
  802dfc:	e8 13 ff ff ff       	call   802d14 <pageref>
  802e01:	89 c6                	mov    %eax,%esi
  802e03:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802e06:	89 04 24             	mov    %eax,(%esp)
  802e09:	e8 06 ff ff ff       	call   802d14 <pageref>
  802e0e:	39 c6                	cmp    %eax,%esi
  802e10:	0f 94 c0             	sete   %al
  802e13:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802e16:	8b 15 0c 90 80 00    	mov    0x80900c,%edx
  802e1c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802e1f:	39 cb                	cmp    %ecx,%ebx
  802e21:	75 08                	jne    802e2b <_pipeisclosed+0x48>
			return ret;
		if (n != nn && ret == 1)
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
	}
}
  802e23:	83 c4 2c             	add    $0x2c,%esp
  802e26:	5b                   	pop    %ebx
  802e27:	5e                   	pop    %esi
  802e28:	5f                   	pop    %edi
  802e29:	5d                   	pop    %ebp
  802e2a:	c3                   	ret    
		n = thisenv->env_runs;
		ret = pageref(fd) == pageref(p);
		nn = thisenv->env_runs;
		if (n == nn)
			return ret;
		if (n != nn && ret == 1)
  802e2b:	83 f8 01             	cmp    $0x1,%eax
  802e2e:	75 c1                	jne    802df1 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e30:	8b 42 58             	mov    0x58(%edx),%eax
  802e33:	c7 44 24 0c 01 00 00 	movl   $0x1,0xc(%esp)
  802e3a:	00 
  802e3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  802e3f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802e43:	c7 04 24 c3 3e 80 00 	movl   $0x803ec3,(%esp)
  802e4a:	e8 61 e8 ff ff       	call   8016b0 <cprintf>
  802e4f:	eb a0                	jmp    802df1 <_pipeisclosed+0xe>

00802e51 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802e51:	55                   	push   %ebp
  802e52:	89 e5                	mov    %esp,%ebp
  802e54:	57                   	push   %edi
  802e55:	56                   	push   %esi
  802e56:	53                   	push   %ebx
  802e57:	83 ec 1c             	sub    $0x1c,%esp
  802e5a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802e5d:	89 34 24             	mov    %esi,(%esp)
  802e60:	e8 5f f6 ff ff       	call   8024c4 <fd2data>
  802e65:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802e67:	bf 00 00 00 00       	mov    $0x0,%edi
  802e6c:	eb 3c                	jmp    802eaa <devpipe_write+0x59>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802e6e:	89 da                	mov    %ebx,%edx
  802e70:	89 f0                	mov    %esi,%eax
  802e72:	e8 6c ff ff ff       	call   802de3 <_pipeisclosed>
  802e77:	85 c0                	test   %eax,%eax
  802e79:	75 38                	jne    802eb3 <devpipe_write+0x62>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802e7b:	e8 ce f1 ff ff       	call   80204e <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802e80:	8b 43 04             	mov    0x4(%ebx),%eax
  802e83:	8b 13                	mov    (%ebx),%edx
  802e85:	83 c2 20             	add    $0x20,%edx
  802e88:	39 d0                	cmp    %edx,%eax
  802e8a:	73 e2                	jae    802e6e <devpipe_write+0x1d>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802e8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  802e8f:	8a 0c 3a             	mov    (%edx,%edi,1),%cl
  802e92:	89 c2                	mov    %eax,%edx
  802e94:	81 e2 1f 00 00 80    	and    $0x8000001f,%edx
  802e9a:	79 05                	jns    802ea1 <devpipe_write+0x50>
  802e9c:	4a                   	dec    %edx
  802e9d:	83 ca e0             	or     $0xffffffe0,%edx
  802ea0:	42                   	inc    %edx
  802ea1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802ea5:	40                   	inc    %eax
  802ea6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ea9:	47                   	inc    %edi
  802eaa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802ead:	75 d1                	jne    802e80 <devpipe_write+0x2f>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802eaf:	89 f8                	mov    %edi,%eax
  802eb1:	eb 05                	jmp    802eb8 <devpipe_write+0x67>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802eb3:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802eb8:	83 c4 1c             	add    $0x1c,%esp
  802ebb:	5b                   	pop    %ebx
  802ebc:	5e                   	pop    %esi
  802ebd:	5f                   	pop    %edi
  802ebe:	5d                   	pop    %ebp
  802ebf:	c3                   	ret    

00802ec0 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802ec0:	55                   	push   %ebp
  802ec1:	89 e5                	mov    %esp,%ebp
  802ec3:	57                   	push   %edi
  802ec4:	56                   	push   %esi
  802ec5:	53                   	push   %ebx
  802ec6:	83 ec 1c             	sub    $0x1c,%esp
  802ec9:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802ecc:	89 3c 24             	mov    %edi,(%esp)
  802ecf:	e8 f0 f5 ff ff       	call   8024c4 <fd2data>
  802ed4:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802ed6:	be 00 00 00 00       	mov    $0x0,%esi
  802edb:	eb 3a                	jmp    802f17 <devpipe_read+0x57>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802edd:	85 f6                	test   %esi,%esi
  802edf:	74 04                	je     802ee5 <devpipe_read+0x25>
				return i;
  802ee1:	89 f0                	mov    %esi,%eax
  802ee3:	eb 40                	jmp    802f25 <devpipe_read+0x65>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802ee5:	89 da                	mov    %ebx,%edx
  802ee7:	89 f8                	mov    %edi,%eax
  802ee9:	e8 f5 fe ff ff       	call   802de3 <_pipeisclosed>
  802eee:	85 c0                	test   %eax,%eax
  802ef0:	75 2e                	jne    802f20 <devpipe_read+0x60>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802ef2:	e8 57 f1 ff ff       	call   80204e <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802ef7:	8b 03                	mov    (%ebx),%eax
  802ef9:	3b 43 04             	cmp    0x4(%ebx),%eax
  802efc:	74 df                	je     802edd <devpipe_read+0x1d>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802efe:	25 1f 00 00 80       	and    $0x8000001f,%eax
  802f03:	79 05                	jns    802f0a <devpipe_read+0x4a>
  802f05:	48                   	dec    %eax
  802f06:	83 c8 e0             	or     $0xffffffe0,%eax
  802f09:	40                   	inc    %eax
  802f0a:	8a 44 03 08          	mov    0x8(%ebx,%eax,1),%al
  802f0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802f11:	88 04 32             	mov    %al,(%edx,%esi,1)
		p->p_rpos++;
  802f14:	ff 03                	incl   (%ebx)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802f16:	46                   	inc    %esi
  802f17:	3b 75 10             	cmp    0x10(%ebp),%esi
  802f1a:	75 db                	jne    802ef7 <devpipe_read+0x37>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802f1c:	89 f0                	mov    %esi,%eax
  802f1e:	eb 05                	jmp    802f25 <devpipe_read+0x65>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802f20:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802f25:	83 c4 1c             	add    $0x1c,%esp
  802f28:	5b                   	pop    %ebx
  802f29:	5e                   	pop    %esi
  802f2a:	5f                   	pop    %edi
  802f2b:	5d                   	pop    %ebp
  802f2c:	c3                   	ret    

00802f2d <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802f2d:	55                   	push   %ebp
  802f2e:	89 e5                	mov    %esp,%ebp
  802f30:	57                   	push   %edi
  802f31:	56                   	push   %esi
  802f32:	53                   	push   %ebx
  802f33:	83 ec 3c             	sub    $0x3c,%esp
  802f36:	8b 7d 08             	mov    0x8(%ebp),%edi
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802f39:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  802f3c:	89 04 24             	mov    %eax,(%esp)
  802f3f:	e8 9b f5 ff ff       	call   8024df <fd_alloc>
  802f44:	89 c3                	mov    %eax,%ebx
  802f46:	85 c0                	test   %eax,%eax
  802f48:	0f 88 45 01 00 00    	js     803093 <pipe+0x166>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f4e:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802f55:	00 
  802f56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802f59:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f64:	e8 04 f1 ff ff       	call   80206d <sys_page_alloc>
  802f69:	89 c3                	mov    %eax,%ebx
  802f6b:	85 c0                	test   %eax,%eax
  802f6d:	0f 88 20 01 00 00    	js     803093 <pipe+0x166>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802f73:	8d 45 e0             	lea    -0x20(%ebp),%eax
  802f76:	89 04 24             	mov    %eax,(%esp)
  802f79:	e8 61 f5 ff ff       	call   8024df <fd_alloc>
  802f7e:	89 c3                	mov    %eax,%ebx
  802f80:	85 c0                	test   %eax,%eax
  802f82:	0f 88 f8 00 00 00    	js     803080 <pipe+0x153>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802f88:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802f8f:	00 
  802f90:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  802f97:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802f9e:	e8 ca f0 ff ff       	call   80206d <sys_page_alloc>
  802fa3:	89 c3                	mov    %eax,%ebx
  802fa5:	85 c0                	test   %eax,%eax
  802fa7:	0f 88 d3 00 00 00    	js     803080 <pipe+0x153>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802fad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802fb0:	89 04 24             	mov    %eax,(%esp)
  802fb3:	e8 0c f5 ff ff       	call   8024c4 <fd2data>
  802fb8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fba:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802fc1:	00 
  802fc2:	89 44 24 04          	mov    %eax,0x4(%esp)
  802fc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802fcd:	e8 9b f0 ff ff       	call   80206d <sys_page_alloc>
  802fd2:	89 c3                	mov    %eax,%ebx
  802fd4:	85 c0                	test   %eax,%eax
  802fd6:	0f 88 91 00 00 00    	js     80306d <pipe+0x140>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fdc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  802fdf:	89 04 24             	mov    %eax,(%esp)
  802fe2:	e8 dd f4 ff ff       	call   8024c4 <fd2data>
  802fe7:	c7 44 24 10 07 04 00 	movl   $0x407,0x10(%esp)
  802fee:	00 
  802fef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802ff3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  802ffa:	00 
  802ffb:	89 74 24 04          	mov    %esi,0x4(%esp)
  802fff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803006:	e8 b6 f0 ff ff       	call   8020c1 <sys_page_map>
  80300b:	89 c3                	mov    %eax,%ebx
  80300d:	85 c0                	test   %eax,%eax
  80300f:	78 4c                	js     80305d <pipe+0x130>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  803011:	8b 15 80 80 80 00    	mov    0x808080,%edx
  803017:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80301a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80301c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80301f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803026:	8b 15 80 80 80 00    	mov    0x808080,%edx
  80302c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80302f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  803031:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803034:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80303b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80303e:	89 04 24             	mov    %eax,(%esp)
  803041:	e8 6e f4 ff ff       	call   8024b4 <fd2num>
  803046:	89 07                	mov    %eax,(%edi)
	pfd[1] = fd2num(fd1);
  803048:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80304b:	89 04 24             	mov    %eax,(%esp)
  80304e:	e8 61 f4 ff ff       	call   8024b4 <fd2num>
  803053:	89 47 04             	mov    %eax,0x4(%edi)
	return 0;
  803056:	bb 00 00 00 00       	mov    $0x0,%ebx
  80305b:	eb 36                	jmp    803093 <pipe+0x166>

    err3:
	sys_page_unmap(0, va);
  80305d:	89 74 24 04          	mov    %esi,0x4(%esp)
  803061:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803068:	e8 a7 f0 ff ff       	call   802114 <sys_page_unmap>
    err2:
	sys_page_unmap(0, fd1);
  80306d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  803070:	89 44 24 04          	mov    %eax,0x4(%esp)
  803074:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80307b:	e8 94 f0 ff ff       	call   802114 <sys_page_unmap>
    err1:
	sys_page_unmap(0, fd0);
  803080:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  803083:	89 44 24 04          	mov    %eax,0x4(%esp)
  803087:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80308e:	e8 81 f0 ff ff       	call   802114 <sys_page_unmap>
    err:
	return r;
}
  803093:	89 d8                	mov    %ebx,%eax
  803095:	83 c4 3c             	add    $0x3c,%esp
  803098:	5b                   	pop    %ebx
  803099:	5e                   	pop    %esi
  80309a:	5f                   	pop    %edi
  80309b:	5d                   	pop    %ebp
  80309c:	c3                   	ret    

0080309d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80309d:	55                   	push   %ebp
  80309e:	89 e5                	mov    %esp,%ebp
  8030a0:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8030aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8030ad:	89 04 24             	mov    %eax,(%esp)
  8030b0:	e8 7d f4 ff ff       	call   802532 <fd_lookup>
  8030b5:	85 c0                	test   %eax,%eax
  8030b7:	78 15                	js     8030ce <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8030b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030bc:	89 04 24             	mov    %eax,(%esp)
  8030bf:	e8 00 f4 ff ff       	call   8024c4 <fd2data>
	return _pipeisclosed(fd, p);
  8030c4:	89 c2                	mov    %eax,%edx
  8030c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8030c9:	e8 15 fd ff ff       	call   802de3 <_pipeisclosed>
}
  8030ce:	c9                   	leave  
  8030cf:	c3                   	ret    

008030d0 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8030d0:	55                   	push   %ebp
  8030d1:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8030d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8030d8:	5d                   	pop    %ebp
  8030d9:	c3                   	ret    

008030da <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8030da:	55                   	push   %ebp
  8030db:	89 e5                	mov    %esp,%ebp
  8030dd:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<cons>");
  8030e0:	c7 44 24 04 db 3e 80 	movl   $0x803edb,0x4(%esp)
  8030e7:	00 
  8030e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8030eb:	89 04 24             	mov    %eax,(%esp)
  8030ee:	e8 88 eb ff ff       	call   801c7b <strcpy>
	return 0;
}
  8030f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8030f8:	c9                   	leave  
  8030f9:	c3                   	ret    

008030fa <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8030fa:	55                   	push   %ebp
  8030fb:	89 e5                	mov    %esp,%ebp
  8030fd:	57                   	push   %edi
  8030fe:	56                   	push   %esi
  8030ff:	53                   	push   %ebx
  803100:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803106:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80310b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803111:	eb 30                	jmp    803143 <devcons_write+0x49>
		m = n - tot;
  803113:	8b 75 10             	mov    0x10(%ebp),%esi
  803116:	29 de                	sub    %ebx,%esi
		if (m > sizeof(buf) - 1)
  803118:	83 fe 7f             	cmp    $0x7f,%esi
  80311b:	76 05                	jbe    803122 <devcons_write+0x28>
			m = sizeof(buf) - 1;
  80311d:	be 7f 00 00 00       	mov    $0x7f,%esi
		memmove(buf, (char*)vbuf + tot, m);
  803122:	89 74 24 08          	mov    %esi,0x8(%esp)
  803126:	03 45 0c             	add    0xc(%ebp),%eax
  803129:	89 44 24 04          	mov    %eax,0x4(%esp)
  80312d:	89 3c 24             	mov    %edi,(%esp)
  803130:	e8 bf ec ff ff       	call   801df4 <memmove>
		sys_cputs(buf, m);
  803135:	89 74 24 04          	mov    %esi,0x4(%esp)
  803139:	89 3c 24             	mov    %edi,(%esp)
  80313c:	e8 5f ee ff ff       	call   801fa0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803141:	01 f3                	add    %esi,%ebx
  803143:	89 d8                	mov    %ebx,%eax
  803145:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803148:	72 c9                	jb     803113 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80314a:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  803150:	5b                   	pop    %ebx
  803151:	5e                   	pop    %esi
  803152:	5f                   	pop    %edi
  803153:	5d                   	pop    %ebp
  803154:	c3                   	ret    

00803155 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803155:	55                   	push   %ebp
  803156:	89 e5                	mov    %esp,%ebp
  803158:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
  80315b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80315f:	75 07                	jne    803168 <devcons_read+0x13>
  803161:	eb 25                	jmp    803188 <devcons_read+0x33>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  803163:	e8 e6 ee ff ff       	call   80204e <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  803168:	e8 51 ee ff ff       	call   801fbe <sys_cgetc>
  80316d:	85 c0                	test   %eax,%eax
  80316f:	74 f2                	je     803163 <devcons_read+0xe>
  803171:	89 c2                	mov    %eax,%edx
		sys_yield();
	if (c < 0)
  803173:	85 c0                	test   %eax,%eax
  803175:	78 1d                	js     803194 <devcons_read+0x3f>
		return c;
	if (c == 0x04)	// ctl-d is eof
  803177:	83 f8 04             	cmp    $0x4,%eax
  80317a:	74 13                	je     80318f <devcons_read+0x3a>
		return 0;
	*(char*)vbuf = c;
  80317c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80317f:	88 10                	mov    %dl,(%eax)
	return 1;
  803181:	b8 01 00 00 00       	mov    $0x1,%eax
  803186:	eb 0c                	jmp    803194 <devcons_read+0x3f>
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
		return 0;
  803188:	b8 00 00 00 00       	mov    $0x0,%eax
  80318d:	eb 05                	jmp    803194 <devcons_read+0x3f>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80318f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803194:	c9                   	leave  
  803195:	c3                   	ret    

00803196 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803196:	55                   	push   %ebp
  803197:	89 e5                	mov    %esp,%ebp
  803199:	83 ec 28             	sub    $0x28,%esp
	char c = ch;
  80319c:	8b 45 08             	mov    0x8(%ebp),%eax
  80319f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8031a2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8031a9:	00 
  8031aa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8031ad:	89 04 24             	mov    %eax,(%esp)
  8031b0:	e8 eb ed ff ff       	call   801fa0 <sys_cputs>
}
  8031b5:	c9                   	leave  
  8031b6:	c3                   	ret    

008031b7 <getchar>:

int
getchar(void)
{
  8031b7:	55                   	push   %ebp
  8031b8:	89 e5                	mov    %esp,%ebp
  8031ba:	83 ec 28             	sub    $0x28,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8031bd:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  8031c4:	00 
  8031c5:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8031c8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031cc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8031d3:	e8 f6 f5 ff ff       	call   8027ce <read>
	if (r < 0)
  8031d8:	85 c0                	test   %eax,%eax
  8031da:	78 0f                	js     8031eb <getchar+0x34>
		return r;
	if (r < 1)
  8031dc:	85 c0                	test   %eax,%eax
  8031de:	7e 06                	jle    8031e6 <getchar+0x2f>
		return -E_EOF;
	return c;
  8031e0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8031e4:	eb 05                	jmp    8031eb <getchar+0x34>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8031e6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8031eb:	c9                   	leave  
  8031ec:	c3                   	ret    

008031ed <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8031ed:	55                   	push   %ebp
  8031ee:	89 e5                	mov    %esp,%ebp
  8031f0:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8031f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8031fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8031fd:	89 04 24             	mov    %eax,(%esp)
  803200:	e8 2d f3 ff ff       	call   802532 <fd_lookup>
  803205:	85 c0                	test   %eax,%eax
  803207:	78 11                	js     80321a <iscons+0x2d>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803209:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80320c:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  803212:	39 10                	cmp    %edx,(%eax)
  803214:	0f 94 c0             	sete   %al
  803217:	0f b6 c0             	movzbl %al,%eax
}
  80321a:	c9                   	leave  
  80321b:	c3                   	ret    

0080321c <opencons>:

int
opencons(void)
{
  80321c:	55                   	push   %ebp
  80321d:	89 e5                	mov    %esp,%ebp
  80321f:	83 ec 28             	sub    $0x28,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803225:	89 04 24             	mov    %eax,(%esp)
  803228:	e8 b2 f2 ff ff       	call   8024df <fd_alloc>
  80322d:	85 c0                	test   %eax,%eax
  80322f:	78 3c                	js     80326d <opencons+0x51>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803231:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  803238:	00 
  803239:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80323c:	89 44 24 04          	mov    %eax,0x4(%esp)
  803240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  803247:	e8 21 ee ff ff       	call   80206d <sys_page_alloc>
  80324c:	85 c0                	test   %eax,%eax
  80324e:	78 1d                	js     80326d <opencons+0x51>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  803250:	8b 15 9c 80 80 00    	mov    0x80809c,%edx
  803256:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803259:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80325b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80325e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  803265:	89 04 24             	mov    %eax,(%esp)
  803268:	e8 47 f2 ff ff       	call   8024b4 <fd2num>
}
  80326d:	c9                   	leave  
  80326e:	c3                   	ret    
	...

00803270 <__udivdi3>:
  803270:	55                   	push   %ebp
  803271:	57                   	push   %edi
  803272:	56                   	push   %esi
  803273:	83 ec 10             	sub    $0x10,%esp
  803276:	8b 74 24 20          	mov    0x20(%esp),%esi
  80327a:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  80327e:	89 74 24 04          	mov    %esi,0x4(%esp)
  803282:	8b 7c 24 24          	mov    0x24(%esp),%edi
  803286:	89 cd                	mov    %ecx,%ebp
  803288:	8b 44 24 2c          	mov    0x2c(%esp),%eax
  80328c:	85 c0                	test   %eax,%eax
  80328e:	75 2c                	jne    8032bc <__udivdi3+0x4c>
  803290:	39 f9                	cmp    %edi,%ecx
  803292:	77 68                	ja     8032fc <__udivdi3+0x8c>
  803294:	85 c9                	test   %ecx,%ecx
  803296:	75 0b                	jne    8032a3 <__udivdi3+0x33>
  803298:	b8 01 00 00 00       	mov    $0x1,%eax
  80329d:	31 d2                	xor    %edx,%edx
  80329f:	f7 f1                	div    %ecx
  8032a1:	89 c1                	mov    %eax,%ecx
  8032a3:	31 d2                	xor    %edx,%edx
  8032a5:	89 f8                	mov    %edi,%eax
  8032a7:	f7 f1                	div    %ecx
  8032a9:	89 c7                	mov    %eax,%edi
  8032ab:	89 f0                	mov    %esi,%eax
  8032ad:	f7 f1                	div    %ecx
  8032af:	89 c6                	mov    %eax,%esi
  8032b1:	89 f0                	mov    %esi,%eax
  8032b3:	89 fa                	mov    %edi,%edx
  8032b5:	83 c4 10             	add    $0x10,%esp
  8032b8:	5e                   	pop    %esi
  8032b9:	5f                   	pop    %edi
  8032ba:	5d                   	pop    %ebp
  8032bb:	c3                   	ret    
  8032bc:	39 f8                	cmp    %edi,%eax
  8032be:	77 2c                	ja     8032ec <__udivdi3+0x7c>
  8032c0:	0f bd f0             	bsr    %eax,%esi
  8032c3:	83 f6 1f             	xor    $0x1f,%esi
  8032c6:	75 4c                	jne    803314 <__udivdi3+0xa4>
  8032c8:	39 f8                	cmp    %edi,%eax
  8032ca:	bf 00 00 00 00       	mov    $0x0,%edi
  8032cf:	72 0a                	jb     8032db <__udivdi3+0x6b>
  8032d1:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8032d5:	0f 87 ad 00 00 00    	ja     803388 <__udivdi3+0x118>
  8032db:	be 01 00 00 00       	mov    $0x1,%esi
  8032e0:	89 f0                	mov    %esi,%eax
  8032e2:	89 fa                	mov    %edi,%edx
  8032e4:	83 c4 10             	add    $0x10,%esp
  8032e7:	5e                   	pop    %esi
  8032e8:	5f                   	pop    %edi
  8032e9:	5d                   	pop    %ebp
  8032ea:	c3                   	ret    
  8032eb:	90                   	nop
  8032ec:	31 ff                	xor    %edi,%edi
  8032ee:	31 f6                	xor    %esi,%esi
  8032f0:	89 f0                	mov    %esi,%eax
  8032f2:	89 fa                	mov    %edi,%edx
  8032f4:	83 c4 10             	add    $0x10,%esp
  8032f7:	5e                   	pop    %esi
  8032f8:	5f                   	pop    %edi
  8032f9:	5d                   	pop    %ebp
  8032fa:	c3                   	ret    
  8032fb:	90                   	nop
  8032fc:	89 fa                	mov    %edi,%edx
  8032fe:	89 f0                	mov    %esi,%eax
  803300:	f7 f1                	div    %ecx
  803302:	89 c6                	mov    %eax,%esi
  803304:	31 ff                	xor    %edi,%edi
  803306:	89 f0                	mov    %esi,%eax
  803308:	89 fa                	mov    %edi,%edx
  80330a:	83 c4 10             	add    $0x10,%esp
  80330d:	5e                   	pop    %esi
  80330e:	5f                   	pop    %edi
  80330f:	5d                   	pop    %ebp
  803310:	c3                   	ret    
  803311:	8d 76 00             	lea    0x0(%esi),%esi
  803314:	89 f1                	mov    %esi,%ecx
  803316:	d3 e0                	shl    %cl,%eax
  803318:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80331c:	b8 20 00 00 00       	mov    $0x20,%eax
  803321:	29 f0                	sub    %esi,%eax
  803323:	89 ea                	mov    %ebp,%edx
  803325:	88 c1                	mov    %al,%cl
  803327:	d3 ea                	shr    %cl,%edx
  803329:	8b 4c 24 0c          	mov    0xc(%esp),%ecx
  80332d:	09 ca                	or     %ecx,%edx
  80332f:	89 54 24 08          	mov    %edx,0x8(%esp)
  803333:	89 f1                	mov    %esi,%ecx
  803335:	d3 e5                	shl    %cl,%ebp
  803337:	89 6c 24 0c          	mov    %ebp,0xc(%esp)
  80333b:	89 fd                	mov    %edi,%ebp
  80333d:	88 c1                	mov    %al,%cl
  80333f:	d3 ed                	shr    %cl,%ebp
  803341:	89 fa                	mov    %edi,%edx
  803343:	89 f1                	mov    %esi,%ecx
  803345:	d3 e2                	shl    %cl,%edx
  803347:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80334b:	88 c1                	mov    %al,%cl
  80334d:	d3 ef                	shr    %cl,%edi
  80334f:	09 d7                	or     %edx,%edi
  803351:	89 f8                	mov    %edi,%eax
  803353:	89 ea                	mov    %ebp,%edx
  803355:	f7 74 24 08          	divl   0x8(%esp)
  803359:	89 d1                	mov    %edx,%ecx
  80335b:	89 c7                	mov    %eax,%edi
  80335d:	f7 64 24 0c          	mull   0xc(%esp)
  803361:	39 d1                	cmp    %edx,%ecx
  803363:	72 17                	jb     80337c <__udivdi3+0x10c>
  803365:	74 09                	je     803370 <__udivdi3+0x100>
  803367:	89 fe                	mov    %edi,%esi
  803369:	31 ff                	xor    %edi,%edi
  80336b:	e9 41 ff ff ff       	jmp    8032b1 <__udivdi3+0x41>
  803370:	8b 54 24 04          	mov    0x4(%esp),%edx
  803374:	89 f1                	mov    %esi,%ecx
  803376:	d3 e2                	shl    %cl,%edx
  803378:	39 c2                	cmp    %eax,%edx
  80337a:	73 eb                	jae    803367 <__udivdi3+0xf7>
  80337c:	8d 77 ff             	lea    -0x1(%edi),%esi
  80337f:	31 ff                	xor    %edi,%edi
  803381:	e9 2b ff ff ff       	jmp    8032b1 <__udivdi3+0x41>
  803386:	66 90                	xchg   %ax,%ax
  803388:	31 f6                	xor    %esi,%esi
  80338a:	e9 22 ff ff ff       	jmp    8032b1 <__udivdi3+0x41>
	...

00803390 <__umoddi3>:
  803390:	55                   	push   %ebp
  803391:	57                   	push   %edi
  803392:	56                   	push   %esi
  803393:	83 ec 20             	sub    $0x20,%esp
  803396:	8b 44 24 30          	mov    0x30(%esp),%eax
  80339a:	8b 4c 24 38          	mov    0x38(%esp),%ecx
  80339e:	89 44 24 14          	mov    %eax,0x14(%esp)
  8033a2:	8b 74 24 34          	mov    0x34(%esp),%esi
  8033a6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8033aa:	8b 6c 24 3c          	mov    0x3c(%esp),%ebp
  8033ae:	89 c7                	mov    %eax,%edi
  8033b0:	89 f2                	mov    %esi,%edx
  8033b2:	85 ed                	test   %ebp,%ebp
  8033b4:	75 16                	jne    8033cc <__umoddi3+0x3c>
  8033b6:	39 f1                	cmp    %esi,%ecx
  8033b8:	0f 86 a6 00 00 00    	jbe    803464 <__umoddi3+0xd4>
  8033be:	f7 f1                	div    %ecx
  8033c0:	89 d0                	mov    %edx,%eax
  8033c2:	31 d2                	xor    %edx,%edx
  8033c4:	83 c4 20             	add    $0x20,%esp
  8033c7:	5e                   	pop    %esi
  8033c8:	5f                   	pop    %edi
  8033c9:	5d                   	pop    %ebp
  8033ca:	c3                   	ret    
  8033cb:	90                   	nop
  8033cc:	39 f5                	cmp    %esi,%ebp
  8033ce:	0f 87 ac 00 00 00    	ja     803480 <__umoddi3+0xf0>
  8033d4:	0f bd c5             	bsr    %ebp,%eax
  8033d7:	83 f0 1f             	xor    $0x1f,%eax
  8033da:	89 44 24 10          	mov    %eax,0x10(%esp)
  8033de:	0f 84 a8 00 00 00    	je     80348c <__umoddi3+0xfc>
  8033e4:	8a 4c 24 10          	mov    0x10(%esp),%cl
  8033e8:	d3 e5                	shl    %cl,%ebp
  8033ea:	bf 20 00 00 00       	mov    $0x20,%edi
  8033ef:	2b 7c 24 10          	sub    0x10(%esp),%edi
  8033f3:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8033f7:	89 f9                	mov    %edi,%ecx
  8033f9:	d3 e8                	shr    %cl,%eax
  8033fb:	09 e8                	or     %ebp,%eax
  8033fd:	89 44 24 18          	mov    %eax,0x18(%esp)
  803401:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803405:	8a 4c 24 10          	mov    0x10(%esp),%cl
  803409:	d3 e0                	shl    %cl,%eax
  80340b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80340f:	89 f2                	mov    %esi,%edx
  803411:	d3 e2                	shl    %cl,%edx
  803413:	8b 44 24 14          	mov    0x14(%esp),%eax
  803417:	d3 e0                	shl    %cl,%eax
  803419:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  80341d:	8b 44 24 14          	mov    0x14(%esp),%eax
  803421:	89 f9                	mov    %edi,%ecx
  803423:	d3 e8                	shr    %cl,%eax
  803425:	09 d0                	or     %edx,%eax
  803427:	d3 ee                	shr    %cl,%esi
  803429:	89 f2                	mov    %esi,%edx
  80342b:	f7 74 24 18          	divl   0x18(%esp)
  80342f:	89 d6                	mov    %edx,%esi
  803431:	f7 64 24 0c          	mull   0xc(%esp)
  803435:	89 c5                	mov    %eax,%ebp
  803437:	89 d1                	mov    %edx,%ecx
  803439:	39 d6                	cmp    %edx,%esi
  80343b:	72 67                	jb     8034a4 <__umoddi3+0x114>
  80343d:	74 75                	je     8034b4 <__umoddi3+0x124>
  80343f:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  803443:	29 e8                	sub    %ebp,%eax
  803445:	19 ce                	sbb    %ecx,%esi
  803447:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80344b:	d3 e8                	shr    %cl,%eax
  80344d:	89 f2                	mov    %esi,%edx
  80344f:	89 f9                	mov    %edi,%ecx
  803451:	d3 e2                	shl    %cl,%edx
  803453:	09 d0                	or     %edx,%eax
  803455:	89 f2                	mov    %esi,%edx
  803457:	8a 4c 24 10          	mov    0x10(%esp),%cl
  80345b:	d3 ea                	shr    %cl,%edx
  80345d:	83 c4 20             	add    $0x20,%esp
  803460:	5e                   	pop    %esi
  803461:	5f                   	pop    %edi
  803462:	5d                   	pop    %ebp
  803463:	c3                   	ret    
  803464:	85 c9                	test   %ecx,%ecx
  803466:	75 0b                	jne    803473 <__umoddi3+0xe3>
  803468:	b8 01 00 00 00       	mov    $0x1,%eax
  80346d:	31 d2                	xor    %edx,%edx
  80346f:	f7 f1                	div    %ecx
  803471:	89 c1                	mov    %eax,%ecx
  803473:	89 f0                	mov    %esi,%eax
  803475:	31 d2                	xor    %edx,%edx
  803477:	f7 f1                	div    %ecx
  803479:	89 f8                	mov    %edi,%eax
  80347b:	e9 3e ff ff ff       	jmp    8033be <__umoddi3+0x2e>
  803480:	89 f2                	mov    %esi,%edx
  803482:	83 c4 20             	add    $0x20,%esp
  803485:	5e                   	pop    %esi
  803486:	5f                   	pop    %edi
  803487:	5d                   	pop    %ebp
  803488:	c3                   	ret    
  803489:	8d 76 00             	lea    0x0(%esi),%esi
  80348c:	39 f5                	cmp    %esi,%ebp
  80348e:	72 04                	jb     803494 <__umoddi3+0x104>
  803490:	39 f9                	cmp    %edi,%ecx
  803492:	77 06                	ja     80349a <__umoddi3+0x10a>
  803494:	89 f2                	mov    %esi,%edx
  803496:	29 cf                	sub    %ecx,%edi
  803498:	19 ea                	sbb    %ebp,%edx
  80349a:	89 f8                	mov    %edi,%eax
  80349c:	83 c4 20             	add    $0x20,%esp
  80349f:	5e                   	pop    %esi
  8034a0:	5f                   	pop    %edi
  8034a1:	5d                   	pop    %ebp
  8034a2:	c3                   	ret    
  8034a3:	90                   	nop
  8034a4:	89 d1                	mov    %edx,%ecx
  8034a6:	89 c5                	mov    %eax,%ebp
  8034a8:	2b 6c 24 0c          	sub    0xc(%esp),%ebp
  8034ac:	1b 4c 24 18          	sbb    0x18(%esp),%ecx
  8034b0:	eb 8d                	jmp    80343f <__umoddi3+0xaf>
  8034b2:	66 90                	xchg   %ax,%ax
  8034b4:	39 44 24 1c          	cmp    %eax,0x1c(%esp)
  8034b8:	72 ea                	jb     8034a4 <__umoddi3+0x114>
  8034ba:	89 f1                	mov    %esi,%ecx
  8034bc:	eb 81                	jmp    80343f <__umoddi3+0xaf>
