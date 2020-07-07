
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 80 10 00       	mov    $0x108000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc b0 a5 10 80       	mov    $0x8010a5b0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 7c 2a 10 80       	mov    $0x80102a7c,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	53                   	push   %ebx
80100038:	83 ec 14             	sub    $0x14,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003b:	c7 44 24 04 e0 64 10 	movl   $0x801064e0,0x4(%esp)
80100042:	80 
80100043:	c7 04 24 c0 a5 10 80 	movl   $0x8010a5c0,(%esp)
8010004a:	e8 75 3b 00 00       	call   80103bc4 <initlock>

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 0c ed 10 80 bc 	movl   $0x8010ecbc,0x8010ed0c
80100056:	ec 10 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 10 ed 10 80 bc 	movl   $0x8010ecbc,0x8010ed10
80100060:	ec 10 80 
80100063:	ba bc ec 10 80       	mov    $0x8010ecbc,%edx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100068:	bb f4 a5 10 80       	mov    $0x8010a5f4,%ebx
8010006d:	eb 05                	jmp    80100074 <binit+0x40>
8010006f:	90                   	nop
80100070:	89 da                	mov    %ebx,%edx
80100072:	89 c3                	mov    %eax,%ebx
    b->next = bcache.head.next;
80100074:	89 53 54             	mov    %edx,0x54(%ebx)
    b->prev = &bcache.head;
80100077:	c7 43 50 bc ec 10 80 	movl   $0x8010ecbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
8010007e:	c7 44 24 04 e7 64 10 	movl   $0x801064e7,0x4(%esp)
80100085:	80 
80100086:	8d 43 0c             	lea    0xc(%ebx),%eax
80100089:	89 04 24             	mov    %eax,(%esp)
8010008c:	e8 27 3a 00 00       	call   80103ab8 <initsleeplock>
    bcache.head.next->prev = b;
80100091:	a1 10 ed 10 80       	mov    0x8010ed10,%eax
80100096:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100099:	89 1d 10 ed 10 80    	mov    %ebx,0x8010ed10

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	8d 83 5c 02 00 00    	lea    0x25c(%ebx),%eax
801000a5:	3d bc ec 10 80       	cmp    $0x8010ecbc,%eax
801000aa:	72 c4                	jb     80100070 <binit+0x3c>
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000ac:	83 c4 14             	add    $0x14,%esp
801000af:	5b                   	pop    %ebx
801000b0:	5d                   	pop    %ebp
801000b1:	c3                   	ret    
801000b2:	66 90                	xchg   %ax,%ax

801000b4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000b4:	55                   	push   %ebp
801000b5:	89 e5                	mov    %esp,%ebp
801000b7:	57                   	push   %edi
801000b8:	56                   	push   %esi
801000b9:	53                   	push   %ebx
801000ba:	83 ec 1c             	sub    $0x1c,%esp
801000bd:	8b 75 08             	mov    0x8(%ebp),%esi
801000c0:	8b 7d 0c             	mov    0xc(%ebp),%edi
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  acquire(&bcache.lock);
801000c3:	c7 04 24 c0 a5 10 80 	movl   $0x8010a5c0,(%esp)
801000ca:	e8 31 3c 00 00       	call   80103d00 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000cf:	8b 1d 10 ed 10 80    	mov    0x8010ed10,%ebx
801000d5:	81 fb bc ec 10 80    	cmp    $0x8010ecbc,%ebx
801000db:	75 0e                	jne    801000eb <bread+0x37>
801000dd:	eb 1d                	jmp    801000fc <bread+0x48>
801000df:	90                   	nop
801000e0:	8b 5b 54             	mov    0x54(%ebx),%ebx
801000e3:	81 fb bc ec 10 80    	cmp    $0x8010ecbc,%ebx
801000e9:	74 11                	je     801000fc <bread+0x48>
    if(b->dev == dev && b->blockno == blockno){
801000eb:	3b 73 04             	cmp    0x4(%ebx),%esi
801000ee:	75 f0                	jne    801000e0 <bread+0x2c>
801000f0:	3b 7b 08             	cmp    0x8(%ebx),%edi
801000f3:	75 eb                	jne    801000e0 <bread+0x2c>
      b->refcnt++;
801000f5:	ff 43 4c             	incl   0x4c(%ebx)
801000f8:	eb 3c                	jmp    80100136 <bread+0x82>
801000fa:	66 90                	xchg   %ax,%ax
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801000fc:	8b 1d 0c ed 10 80    	mov    0x8010ed0c,%ebx
80100102:	81 fb bc ec 10 80    	cmp    $0x8010ecbc,%ebx
80100108:	75 0d                	jne    80100117 <bread+0x63>
8010010a:	eb 58                	jmp    80100164 <bread+0xb0>
8010010c:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010010f:	81 fb bc ec 10 80    	cmp    $0x8010ecbc,%ebx
80100115:	74 4d                	je     80100164 <bread+0xb0>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
80100117:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010011a:	85 c0                	test   %eax,%eax
8010011c:	75 ee                	jne    8010010c <bread+0x58>
8010011e:	f6 03 04             	testb  $0x4,(%ebx)
80100121:	75 e9                	jne    8010010c <bread+0x58>
      b->dev = dev;
80100123:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
80100126:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
80100129:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
8010012f:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100136:	c7 04 24 c0 a5 10 80 	movl   $0x8010a5c0,(%esp)
8010013d:	e8 22 3c 00 00       	call   80103d64 <release>
      acquiresleep(&b->lock);
80100142:	8d 43 0c             	lea    0xc(%ebx),%eax
80100145:	89 04 24             	mov    %eax,(%esp)
80100148:	e8 a3 39 00 00       	call   80103af0 <acquiresleep>
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
8010014d:	f6 03 02             	testb  $0x2,(%ebx)
80100150:	75 08                	jne    8010015a <bread+0xa6>
    iderw(b);
80100152:	89 1c 24             	mov    %ebx,(%esp)
80100155:	e8 9a 1d 00 00       	call   80101ef4 <iderw>
  }
  return b;
}
8010015a:	89 d8                	mov    %ebx,%eax
8010015c:	83 c4 1c             	add    $0x1c,%esp
8010015f:	5b                   	pop    %ebx
80100160:	5e                   	pop    %esi
80100161:	5f                   	pop    %edi
80100162:	5d                   	pop    %ebp
80100163:	c3                   	ret    
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  panic("bget: no buffers");
80100164:	c7 04 24 ee 64 10 80 	movl   $0x801064ee,(%esp)
8010016b:	e8 ac 01 00 00       	call   8010031c <panic>

80100170 <bwrite>:
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
80100170:	55                   	push   %ebp
80100171:	89 e5                	mov    %esp,%ebp
80100173:	53                   	push   %ebx
80100174:	83 ec 14             	sub    $0x14,%esp
80100177:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
8010017a:	8d 43 0c             	lea    0xc(%ebx),%eax
8010017d:	89 04 24             	mov    %eax,(%esp)
80100180:	e8 f7 39 00 00       	call   80103b7c <holdingsleep>
80100185:	85 c0                	test   %eax,%eax
80100187:	74 10                	je     80100199 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
80100189:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
8010018c:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010018f:	83 c4 14             	add    $0x14,%esp
80100192:	5b                   	pop    %ebx
80100193:	5d                   	pop    %ebp
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  b->flags |= B_DIRTY;
  iderw(b);
80100194:	e9 5b 1d 00 00       	jmp    80101ef4 <iderw>
// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
80100199:	c7 04 24 ff 64 10 80 	movl   $0x801064ff,(%esp)
801001a0:	e8 77 01 00 00       	call   8010031c <panic>
801001a5:	8d 76 00             	lea    0x0(%esi),%esi

801001a8 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001a8:	55                   	push   %ebp
801001a9:	89 e5                	mov    %esp,%ebp
801001ab:	56                   	push   %esi
801001ac:	53                   	push   %ebx
801001ad:	83 ec 10             	sub    $0x10,%esp
801001b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001b3:	8d 73 0c             	lea    0xc(%ebx),%esi
801001b6:	89 34 24             	mov    %esi,(%esp)
801001b9:	e8 be 39 00 00       	call   80103b7c <holdingsleep>
801001be:	85 c0                	test   %eax,%eax
801001c0:	74 60                	je     80100222 <brelse+0x7a>
    panic("brelse");

  releasesleep(&b->lock);
801001c2:	89 34 24             	mov    %esi,(%esp)
801001c5:	e8 76 39 00 00       	call   80103b40 <releasesleep>

  acquire(&bcache.lock);
801001ca:	c7 04 24 c0 a5 10 80 	movl   $0x8010a5c0,(%esp)
801001d1:	e8 2a 3b 00 00       	call   80103d00 <acquire>
  b->refcnt--;
801001d6:	8b 43 4c             	mov    0x4c(%ebx),%eax
801001d9:	48                   	dec    %eax
801001da:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
801001dd:	85 c0                	test   %eax,%eax
801001df:	75 2f                	jne    80100210 <brelse+0x68>
    // no one is waiting for it.
    b->next->prev = b->prev;
801001e1:	8b 43 54             	mov    0x54(%ebx),%eax
801001e4:	8b 53 50             	mov    0x50(%ebx),%edx
801001e7:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801001ea:	8b 43 50             	mov    0x50(%ebx),%eax
801001ed:	8b 53 54             	mov    0x54(%ebx),%edx
801001f0:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
801001f3:	a1 10 ed 10 80       	mov    0x8010ed10,%eax
801001f8:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
801001fb:	c7 43 50 bc ec 10 80 	movl   $0x8010ecbc,0x50(%ebx)
    bcache.head.next->prev = b;
80100202:	a1 10 ed 10 80       	mov    0x8010ed10,%eax
80100207:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010020a:	89 1d 10 ed 10 80    	mov    %ebx,0x8010ed10
  }
  
  release(&bcache.lock);
80100210:	c7 45 08 c0 a5 10 80 	movl   $0x8010a5c0,0x8(%ebp)
}
80100217:	83 c4 10             	add    $0x10,%esp
8010021a:	5b                   	pop    %ebx
8010021b:	5e                   	pop    %esi
8010021c:	5d                   	pop    %ebp
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
  
  release(&bcache.lock);
8010021d:	e9 42 3b 00 00       	jmp    80103d64 <release>
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");
80100222:	c7 04 24 06 65 10 80 	movl   $0x80106506,(%esp)
80100229:	e8 ee 00 00 00       	call   8010031c <panic>
	...

80100230 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100230:	55                   	push   %ebp
80100231:	89 e5                	mov    %esp,%ebp
80100233:	57                   	push   %edi
80100234:	56                   	push   %esi
80100235:	53                   	push   %ebx
80100236:	83 ec 2c             	sub    $0x2c,%esp
80100239:	8b 75 08             	mov    0x8(%ebp),%esi
8010023c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010023f:	89 34 24             	mov    %esi,(%esp)
80100242:	e8 71 13 00 00       	call   801015b8 <iunlock>
  target = n;
80100247:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
8010024a:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
80100251:	e8 aa 3a 00 00       	call   80103d00 <acquire>
  while(n > 0){
80100256:	85 db                	test   %ebx,%ebx
80100258:	7f 26                	jg     80100280 <consoleread+0x50>
8010025a:	e9 b7 00 00 00       	jmp    80100316 <consoleread+0xe6>
8010025f:	90                   	nop
    while(input.r == input.w){
      if(myproc()->killed){
80100260:	e8 4b 30 00 00       	call   801032b0 <myproc>
80100265:	8b 40 24             	mov    0x24(%eax),%eax
80100268:	85 c0                	test   %eax,%eax
8010026a:	75 58                	jne    801002c4 <consoleread+0x94>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
8010026c:	c7 44 24 04 20 95 10 	movl   $0x80109520,0x4(%esp)
80100273:	80 
80100274:	c7 04 24 a0 ef 10 80 	movl   $0x8010efa0,(%esp)
8010027b:	e8 34 35 00 00       	call   801037b4 <sleep>

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
    while(input.r == input.w){
80100280:	a1 a0 ef 10 80       	mov    0x8010efa0,%eax
80100285:	3b 05 a4 ef 10 80    	cmp    0x8010efa4,%eax
8010028b:	74 d3                	je     80100260 <consoleread+0x30>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
8010028d:	89 c2                	mov    %eax,%edx
8010028f:	83 e2 7f             	and    $0x7f,%edx
80100292:	8a 8a 20 ef 10 80    	mov    -0x7fef10e0(%edx),%cl
80100298:	0f be d1             	movsbl %cl,%edx
8010029b:	8d 78 01             	lea    0x1(%eax),%edi
8010029e:	89 3d a0 ef 10 80    	mov    %edi,0x8010efa0
    if(c == C('D')){  // EOF
801002a4:	83 fa 04             	cmp    $0x4,%edx
801002a7:	74 3c                	je     801002e5 <consoleread+0xb5>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
801002a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801002ac:	88 08                	mov    %cl,(%eax)
801002ae:	40                   	inc    %eax
801002af:	89 45 0c             	mov    %eax,0xc(%ebp)
    --n;
801002b2:	4b                   	dec    %ebx
    if(c == '\n')
801002b3:	83 fa 0a             	cmp    $0xa,%edx
801002b6:	74 37                	je     801002ef <consoleread+0xbf>
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
801002b8:	85 db                	test   %ebx,%ebx
801002ba:	75 c4                	jne    80100280 <consoleread+0x50>
801002bc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801002bf:	eb 33                	jmp    801002f4 <consoleread+0xc4>
801002c1:	8d 76 00             	lea    0x0(%esi),%esi
    while(input.r == input.w){
      if(myproc()->killed){
        release(&cons.lock);
801002c4:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801002cb:	e8 94 3a 00 00       	call   80103d64 <release>
        ilock(ip);
801002d0:	89 34 24             	mov    %esi,(%esp)
801002d3:	e8 10 12 00 00       	call   801014e8 <ilock>
        return -1;
801002d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002dd:	83 c4 2c             	add    $0x2c,%esp
801002e0:	5b                   	pop    %ebx
801002e1:	5e                   	pop    %esi
801002e2:	5f                   	pop    %edi
801002e3:	5d                   	pop    %ebp
801002e4:	c3                   	ret    
      }
      sleep(&input.r, &cons.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
    if(c == C('D')){  // EOF
      if(n < target){
801002e5:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
801002e8:	76 05                	jbe    801002ef <consoleread+0xbf>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
801002ea:	a3 a0 ef 10 80       	mov    %eax,0x8010efa0
801002ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801002f2:	29 d8                	sub    %ebx,%eax
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
  }
  release(&cons.lock);
801002f4:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801002fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
801002fe:	e8 61 3a 00 00       	call   80103d64 <release>
  ilock(ip);
80100303:	89 34 24             	mov    %esi,(%esp)
80100306:	e8 dd 11 00 00       	call   801014e8 <ilock>
8010030b:	8b 45 e0             	mov    -0x20(%ebp),%eax

  return target - n;
}
8010030e:	83 c4 2c             	add    $0x2c,%esp
80100311:	5b                   	pop    %ebx
80100312:	5e                   	pop    %esi
80100313:	5f                   	pop    %edi
80100314:	5d                   	pop    %ebp
80100315:	c3                   	ret    
  int c;

  iunlock(ip);
  target = n;
  acquire(&cons.lock);
  while(n > 0){
80100316:	31 c0                	xor    %eax,%eax
80100318:	eb da                	jmp    801002f4 <consoleread+0xc4>
8010031a:	66 90                	xchg   %ax,%ax

8010031c <panic>:
    release(&cons.lock);
}

void
panic(char *s)
{
8010031c:	55                   	push   %ebp
8010031d:	89 e5                	mov    %esp,%ebp
8010031f:	56                   	push   %esi
80100320:	53                   	push   %ebx
80100321:	83 ec 40             	sub    $0x40,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100324:	fa                   	cli    
  int i;
  uint pcs[10];

  cli();
  cons.locking = 0;
80100325:	c7 05 54 95 10 80 00 	movl   $0x0,0x80109554
8010032c:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
8010032f:	e8 b0 20 00 00       	call   801023e4 <lapicid>
80100334:	89 44 24 04          	mov    %eax,0x4(%esp)
80100338:	c7 04 24 0d 65 10 80 	movl   $0x8010650d,(%esp)
8010033f:	e8 78 02 00 00       	call   801005bc <cprintf>
  cprintf(s);
80100344:	8b 45 08             	mov    0x8(%ebp),%eax
80100347:	89 04 24             	mov    %eax,(%esp)
8010034a:	e8 6d 02 00 00       	call   801005bc <cprintf>
  cprintf("\n");
8010034f:	c7 04 24 37 6e 10 80 	movl   $0x80106e37,(%esp)
80100356:	e8 61 02 00 00       	call   801005bc <cprintf>
  getcallerpcs(&s, pcs);
8010035b:	8d 5d d0             	lea    -0x30(%ebp),%ebx
8010035e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100362:	8d 45 08             	lea    0x8(%ebp),%eax
80100365:	89 04 24             	mov    %eax,(%esp)
80100368:	e8 73 38 00 00       	call   80103be0 <getcallerpcs>
  if(locking)
    release(&cons.lock);
}

void
panic(char *s)
8010036d:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
    cprintf(" %p", pcs[i]);
80100370:	8b 03                	mov    (%ebx),%eax
80100372:	89 44 24 04          	mov    %eax,0x4(%esp)
80100376:	c7 04 24 21 65 10 80 	movl   $0x80106521,(%esp)
8010037d:	e8 3a 02 00 00       	call   801005bc <cprintf>
80100382:	83 c3 04             	add    $0x4,%ebx
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
80100385:	39 f3                	cmp    %esi,%ebx
80100387:	75 e7                	jne    80100370 <panic+0x54>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
80100389:	c7 05 58 95 10 80 01 	movl   $0x1,0x80109558
80100390:	00 00 00 
80100393:	eb fe                	jmp    80100393 <panic+0x77>
80100395:	8d 76 00             	lea    0x0(%esi),%esi

80100398 <consputc>:
  crt[pos] = ' ' | 0x0700;
}

void
consputc(int c)
{
80100398:	55                   	push   %ebp
80100399:	89 e5                	mov    %esp,%ebp
8010039b:	57                   	push   %edi
8010039c:	56                   	push   %esi
8010039d:	53                   	push   %ebx
8010039e:	83 ec 1c             	sub    $0x1c,%esp
801003a1:	89 c7                	mov    %eax,%edi
  if(panicked){
801003a3:	8b 15 58 95 10 80    	mov    0x80109558,%edx
801003a9:	85 d2                	test   %edx,%edx
801003ab:	74 03                	je     801003b0 <consputc+0x18>
801003ad:	fa                   	cli    
801003ae:	eb fe                	jmp    801003ae <consputc+0x16>
    cli();
    for(;;)
      ;
  }

  if(c == BACKSPACE){
801003b0:	3d 00 01 00 00       	cmp    $0x100,%eax
801003b5:	0f 84 a0 00 00 00    	je     8010045b <consputc+0xc3>
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
801003bb:	89 04 24             	mov    %eax,(%esp)
801003be:	e8 15 4d 00 00       	call   801050d8 <uartputc>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003c3:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003c8:	b0 0e                	mov    $0xe,%al
801003ca:	89 ca                	mov    %ecx,%edx
801003cc:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003cd:	be d5 03 00 00       	mov    $0x3d5,%esi
801003d2:	89 f2                	mov    %esi,%edx
801003d4:	ec                   	in     (%dx),%al
{
  int pos;

  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
  pos = inb(CRTPORT+1) << 8;
801003d5:	0f b6 d8             	movzbl %al,%ebx
801003d8:	c1 e3 08             	shl    $0x8,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003db:	b0 0f                	mov    $0xf,%al
801003dd:	89 ca                	mov    %ecx,%edx
801003df:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003e0:	89 f2                	mov    %esi,%edx
801003e2:	ec                   	in     (%dx),%al
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);
801003e3:	0f b6 c0             	movzbl %al,%eax
801003e6:	09 c3                	or     %eax,%ebx

  if(c == '\n')
801003e8:	83 ff 0a             	cmp    $0xa,%edi
801003eb:	0f 84 f7 00 00 00    	je     801004e8 <consputc+0x150>
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
801003f1:	81 ff 00 01 00 00    	cmp    $0x100,%edi
801003f7:	0f 84 dd 00 00 00    	je     801004da <consputc+0x142>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
801003fd:	81 e7 ff 00 00 00    	and    $0xff,%edi
80100403:	81 cf 00 07 00 00    	or     $0x700,%edi
80100409:	66 89 bc 1b 00 80 0b 	mov    %di,-0x7ff48000(%ebx,%ebx,1)
80100410:	80 
80100411:	43                   	inc    %ebx

  if(pos < 0 || pos > 25*80)
80100412:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100418:	0f 87 b0 00 00 00    	ja     801004ce <consputc+0x136>
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
8010041e:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100424:	7f 5e                	jg     80100484 <consputc+0xec>
80100426:	8d bc 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010042d:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
80100432:	b0 0e                	mov    $0xe,%al
80100434:	89 ca                	mov    %ecx,%edx
80100436:	ee                   	out    %al,(%dx)
    pos -= 80;
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
  }

  outb(CRTPORT, 14);
  outb(CRTPORT+1, pos>>8);
80100437:	89 d8                	mov    %ebx,%eax
80100439:	c1 f8 08             	sar    $0x8,%eax
8010043c:	be d5 03 00 00       	mov    $0x3d5,%esi
80100441:	89 f2                	mov    %esi,%edx
80100443:	ee                   	out    %al,(%dx)
80100444:	b0 0f                	mov    $0xf,%al
80100446:	89 ca                	mov    %ecx,%edx
80100448:	ee                   	out    %al,(%dx)
80100449:	88 d8                	mov    %bl,%al
8010044b:	89 f2                	mov    %esi,%edx
8010044d:	ee                   	out    %al,(%dx)
  outb(CRTPORT, 15);
  outb(CRTPORT+1, pos);
  crt[pos] = ' ' | 0x0700;
8010044e:	66 c7 07 20 07       	movw   $0x720,(%edi)
  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
  } else
    uartputc(c);
  cgaputc(c);
}
80100453:	83 c4 1c             	add    $0x1c,%esp
80100456:	5b                   	pop    %ebx
80100457:	5e                   	pop    %esi
80100458:	5f                   	pop    %edi
80100459:	5d                   	pop    %ebp
8010045a:	c3                   	ret    
    for(;;)
      ;
  }

  if(c == BACKSPACE){
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010045b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100462:	e8 71 4c 00 00       	call   801050d8 <uartputc>
80100467:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010046e:	e8 65 4c 00 00       	call   801050d8 <uartputc>
80100473:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010047a:	e8 59 4c 00 00       	call   801050d8 <uartputc>
8010047f:	e9 3f ff ff ff       	jmp    801003c3 <consputc+0x2b>

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100484:	c7 44 24 08 60 0e 00 	movl   $0xe60,0x8(%esp)
8010048b:	00 
8010048c:	c7 44 24 04 a0 80 0b 	movl   $0x800b80a0,0x4(%esp)
80100493:	80 
80100494:	c7 04 24 00 80 0b 80 	movl   $0x800b8000,(%esp)
8010049b:	e8 9c 39 00 00       	call   80103e3c <memmove>
    pos -= 80;
801004a0:	8d 73 b0             	lea    -0x50(%ebx),%esi
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004a3:	8d bc 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%edi
801004aa:	b8 d0 07 00 00       	mov    $0x7d0,%eax
801004af:	29 d8                	sub    %ebx,%eax
801004b1:	d1 e0                	shl    %eax
801004b3:	89 44 24 08          	mov    %eax,0x8(%esp)
801004b7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801004be:	00 
801004bf:	89 3c 24             	mov    %edi,(%esp)
801004c2:	e8 e5 38 00 00       	call   80103dac <memset>
  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");

  if((pos/80) >= 24){  // Scroll up.
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
    pos -= 80;
801004c7:	89 f3                	mov    %esi,%ebx
801004c9:	e9 5f ff ff ff       	jmp    8010042d <consputc+0x95>
    if(pos > 0) --pos;
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white

  if(pos < 0 || pos > 25*80)
    panic("pos under/overflow");
801004ce:	c7 04 24 25 65 10 80 	movl   $0x80106525,(%esp)
801004d5:	e8 42 fe ff ff       	call   8010031c <panic>
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
  else if(c == BACKSPACE){
    if(pos > 0) --pos;
801004da:	85 db                	test   %ebx,%ebx
801004dc:	0f 8e 30 ff ff ff    	jle    80100412 <consputc+0x7a>
801004e2:	4b                   	dec    %ebx
801004e3:	e9 2a ff ff ff       	jmp    80100412 <consputc+0x7a>
  pos = inb(CRTPORT+1) << 8;
  outb(CRTPORT, 15);
  pos |= inb(CRTPORT+1);

  if(c == '\n')
    pos += 80 - pos%80;
801004e8:	b9 50 00 00 00       	mov    $0x50,%ecx
801004ed:	89 d8                	mov    %ebx,%eax
801004ef:	99                   	cltd   
801004f0:	f7 f9                	idiv   %ecx
801004f2:	29 d1                	sub    %edx,%ecx
801004f4:	01 cb                	add    %ecx,%ebx
801004f6:	e9 17 ff ff ff       	jmp    80100412 <consputc+0x7a>
801004fb:	90                   	nop

801004fc <consolewrite>:
  return target - n;
}

int
consolewrite(struct inode *ip, char *buf, int n)
{
801004fc:	55                   	push   %ebp
801004fd:	89 e5                	mov    %esp,%ebp
801004ff:	57                   	push   %edi
80100500:	56                   	push   %esi
80100501:	53                   	push   %ebx
80100502:	83 ec 1c             	sub    $0x1c,%esp
80100505:	8b 7d 0c             	mov    0xc(%ebp),%edi
80100508:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
8010050b:	8b 45 08             	mov    0x8(%ebp),%eax
8010050e:	89 04 24             	mov    %eax,(%esp)
80100511:	e8 a2 10 00 00       	call   801015b8 <iunlock>
  acquire(&cons.lock);
80100516:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
8010051d:	e8 de 37 00 00       	call   80103d00 <acquire>
  for(i = 0; i < n; i++)
80100522:	85 f6                	test   %esi,%esi
80100524:	7e 10                	jle    80100536 <consolewrite+0x3a>
80100526:	31 db                	xor    %ebx,%ebx
    consputc(buf[i] & 0xff);
80100528:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
8010052c:	e8 67 fe ff ff       	call   80100398 <consputc>
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100531:	43                   	inc    %ebx
80100532:	39 f3                	cmp    %esi,%ebx
80100534:	75 f2                	jne    80100528 <consolewrite+0x2c>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100536:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
8010053d:	e8 22 38 00 00       	call   80103d64 <release>
  ilock(ip);
80100542:	8b 45 08             	mov    0x8(%ebp),%eax
80100545:	89 04 24             	mov    %eax,(%esp)
80100548:	e8 9b 0f 00 00       	call   801014e8 <ilock>

  return n;
}
8010054d:	89 f0                	mov    %esi,%eax
8010054f:	83 c4 1c             	add    $0x1c,%esp
80100552:	5b                   	pop    %ebx
80100553:	5e                   	pop    %esi
80100554:	5f                   	pop    %edi
80100555:	5d                   	pop    %ebp
80100556:	c3                   	ret    
80100557:	90                   	nop

80100558 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100558:	55                   	push   %ebp
80100559:	89 e5                	mov    %esp,%ebp
8010055b:	56                   	push   %esi
8010055c:	53                   	push   %ebx
8010055d:	83 ec 10             	sub    $0x10,%esp
80100560:	89 d3                	mov    %edx,%ebx
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
80100562:	85 c9                	test   %ecx,%ecx
80100564:	74 52                	je     801005b8 <printint+0x60>
80100566:	85 c0                	test   %eax,%eax
80100568:	79 4e                	jns    801005b8 <printint+0x60>
    x = -xx;
8010056a:	f7 d8                	neg    %eax
8010056c:	be 01 00 00 00       	mov    $0x1,%esi
  else
    x = xx;

  i = 0;
80100571:	31 c9                	xor    %ecx,%ecx
80100573:	eb 05                	jmp    8010057a <printint+0x22>
80100575:	8d 76 00             	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
80100578:	89 d1                	mov    %edx,%ecx
8010057a:	31 d2                	xor    %edx,%edx
8010057c:	f7 f3                	div    %ebx
8010057e:	8a 92 50 65 10 80    	mov    -0x7fef9ab0(%edx),%dl
80100584:	88 54 0d e8          	mov    %dl,-0x18(%ebp,%ecx,1)
80100588:	8d 51 01             	lea    0x1(%ecx),%edx
  }while((x /= base) != 0);
8010058b:	85 c0                	test   %eax,%eax
8010058d:	75 e9                	jne    80100578 <printint+0x20>

  if(sign)
8010058f:	85 f6                	test   %esi,%esi
80100591:	74 08                	je     8010059b <printint+0x43>
    buf[i++] = '-';
80100593:	c6 44 15 e8 2d       	movb   $0x2d,-0x18(%ebp,%edx,1)
80100598:	8d 51 02             	lea    0x2(%ecx),%edx

  while(--i >= 0)
8010059b:	8d 5a ff             	lea    -0x1(%edx),%ebx
8010059e:	66 90                	xchg   %ax,%ax
    consputc(buf[i]);
801005a0:	0f be 44 1d e8       	movsbl -0x18(%ebp,%ebx,1),%eax
801005a5:	e8 ee fd ff ff       	call   80100398 <consputc>
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801005aa:	4b                   	dec    %ebx
801005ab:	83 fb ff             	cmp    $0xffffffff,%ebx
801005ae:	75 f0                	jne    801005a0 <printint+0x48>
    consputc(buf[i]);
}
801005b0:	83 c4 10             	add    $0x10,%esp
801005b3:	5b                   	pop    %ebx
801005b4:	5e                   	pop    %esi
801005b5:	5d                   	pop    %ebp
801005b6:	c3                   	ret    
801005b7:	90                   	nop
  uint x;

  if(sign && (sign = xx < 0))
    x = -xx;
  else
    x = xx;
801005b8:	31 f6                	xor    %esi,%esi
801005ba:	eb b5                	jmp    80100571 <printint+0x19>

801005bc <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801005bc:	55                   	push   %ebp
801005bd:	89 e5                	mov    %esp,%ebp
801005bf:	57                   	push   %edi
801005c0:	56                   	push   %esi
801005c1:	53                   	push   %ebx
801005c2:	83 ec 2c             	sub    $0x2c,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801005c5:	8b 3d 54 95 10 80    	mov    0x80109554,%edi
  if(locking)
801005cb:	85 ff                	test   %edi,%edi
801005cd:	0f 85 01 01 00 00    	jne    801006d4 <cprintf+0x118>
    acquire(&cons.lock);

  if (fmt == 0)
801005d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801005d6:	85 c9                	test   %ecx,%ecx
801005d8:	0f 84 11 01 00 00    	je     801006ef <cprintf+0x133>
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801005de:	0f b6 01             	movzbl (%ecx),%eax
801005e1:	85 c0                	test   %eax,%eax
801005e3:	74 77                	je     8010065c <cprintf+0xa0>
801005e5:	8d 75 0c             	lea    0xc(%ebp),%esi
801005e8:	31 db                	xor    %ebx,%ebx
801005ea:	eb 31                	jmp    8010061d <cprintf+0x61>
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
801005ec:	83 fa 25             	cmp    $0x25,%edx
801005ef:	0f 84 9b 00 00 00    	je     80100690 <cprintf+0xd4>
801005f5:	83 fa 64             	cmp    $0x64,%edx
801005f8:	74 7a                	je     80100674 <cprintf+0xb8>
    case '%':
      consputc('%');
      break;
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
801005fa:	b8 25 00 00 00       	mov    $0x25,%eax
801005ff:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80100602:	e8 91 fd ff ff       	call   80100398 <consputc>
      consputc(c);
80100607:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010060a:	89 d0                	mov    %edx,%eax
8010060c:	e8 87 fd ff ff       	call   80100398 <consputc>
80100611:	8b 4d 08             	mov    0x8(%ebp),%ecx

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100614:	43                   	inc    %ebx
80100615:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
80100619:	85 c0                	test   %eax,%eax
8010061b:	74 3f                	je     8010065c <cprintf+0xa0>
    if(c != '%'){
8010061d:	83 f8 25             	cmp    $0x25,%eax
80100620:	75 ea                	jne    8010060c <cprintf+0x50>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
80100622:	43                   	inc    %ebx
80100623:	0f b6 14 19          	movzbl (%ecx,%ebx,1),%edx
    if(c == 0)
80100627:	85 d2                	test   %edx,%edx
80100629:	74 31                	je     8010065c <cprintf+0xa0>
      break;
    switch(c){
8010062b:	83 fa 70             	cmp    $0x70,%edx
8010062e:	74 0c                	je     8010063c <cprintf+0x80>
80100630:	7e ba                	jle    801005ec <cprintf+0x30>
80100632:	83 fa 73             	cmp    $0x73,%edx
80100635:	74 6d                	je     801006a4 <cprintf+0xe8>
80100637:	83 fa 78             	cmp    $0x78,%edx
8010063a:	75 be                	jne    801005fa <cprintf+0x3e>
    case 'd':
      printint(*argp++, 10, 1);
      break;
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010063c:	8b 06                	mov    (%esi),%eax
8010063e:	83 c6 04             	add    $0x4,%esi
80100641:	31 c9                	xor    %ecx,%ecx
80100643:	ba 10 00 00 00       	mov    $0x10,%edx
80100648:	e8 0b ff ff ff       	call   80100558 <printint>
8010064d:	8b 4d 08             	mov    0x8(%ebp),%ecx

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100650:	43                   	inc    %ebx
80100651:	0f b6 04 19          	movzbl (%ecx,%ebx,1),%eax
80100655:	85 c0                	test   %eax,%eax
80100657:	75 c4                	jne    8010061d <cprintf+0x61>
80100659:	8d 76 00             	lea    0x0(%esi),%esi
      consputc(c);
      break;
    }
  }

  if(locking)
8010065c:	85 ff                	test   %edi,%edi
8010065e:	74 0c                	je     8010066c <cprintf+0xb0>
    release(&cons.lock);
80100660:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
80100667:	e8 f8 36 00 00       	call   80103d64 <release>
}
8010066c:	83 c4 2c             	add    $0x2c,%esp
8010066f:	5b                   	pop    %ebx
80100670:	5e                   	pop    %esi
80100671:	5f                   	pop    %edi
80100672:	5d                   	pop    %ebp
80100673:	c3                   	ret    
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
    switch(c){
    case 'd':
      printint(*argp++, 10, 1);
80100674:	8b 06                	mov    (%esi),%eax
80100676:	83 c6 04             	add    $0x4,%esi
80100679:	b9 01 00 00 00       	mov    $0x1,%ecx
8010067e:	ba 0a 00 00 00       	mov    $0xa,%edx
80100683:	e8 d0 fe ff ff       	call   80100558 <printint>
80100688:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
8010068b:	eb 87                	jmp    80100614 <cprintf+0x58>
8010068d:	8d 76 00             	lea    0x0(%esi),%esi
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
      break;
    case '%':
      consputc('%');
80100690:	b8 25 00 00 00       	mov    $0x25,%eax
80100695:	e8 fe fc ff ff       	call   80100398 <consputc>
8010069a:	8b 4d 08             	mov    0x8(%ebp),%ecx
      break;
8010069d:	e9 72 ff ff ff       	jmp    80100614 <cprintf+0x58>
801006a2:	66 90                	xchg   %ax,%ax
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
801006a4:	8b 16                	mov    (%esi),%edx
801006a6:	83 c6 04             	add    $0x4,%esi
801006a9:	85 d2                	test   %edx,%edx
801006ab:	74 3b                	je     801006e8 <cprintf+0x12c>
        s = "(null)";
      for(; *s; s++)
801006ad:	8a 02                	mov    (%edx),%al
801006af:	84 c0                	test   %al,%al
801006b1:	0f 84 5d ff ff ff    	je     80100614 <cprintf+0x58>
801006b7:	90                   	nop
        consputc(*s);
801006b8:	0f be c0             	movsbl %al,%eax
801006bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
801006be:	e8 d5 fc ff ff       	call   80100398 <consputc>
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801006c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801006c6:	42                   	inc    %edx
801006c7:	8a 02                	mov    (%edx),%al
801006c9:	84 c0                	test   %al,%al
801006cb:	75 eb                	jne    801006b8 <cprintf+0xfc>
801006cd:	e9 3f ff ff ff       	jmp    80100611 <cprintf+0x55>
801006d2:	66 90                	xchg   %ax,%ax
  uint *argp;
  char *s;

  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);
801006d4:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801006db:	e8 20 36 00 00       	call   80103d00 <acquire>
801006e0:	e9 ee fe ff ff       	jmp    801005d3 <cprintf+0x17>
801006e5:	8d 76 00             	lea    0x0(%esi),%esi
    case 'p':
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
801006e8:	ba 38 65 10 80       	mov    $0x80106538,%edx
801006ed:	eb be                	jmp    801006ad <cprintf+0xf1>
  locking = cons.locking;
  if(locking)
    acquire(&cons.lock);

  if (fmt == 0)
    panic("null fmt");
801006ef:	c7 04 24 3f 65 10 80 	movl   $0x8010653f,(%esp)
801006f6:	e8 21 fc ff ff       	call   8010031c <panic>
801006fb:	90                   	nop

801006fc <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801006fc:	55                   	push   %ebp
801006fd:	89 e5                	mov    %esp,%ebp
801006ff:	57                   	push   %edi
80100700:	56                   	push   %esi
80100701:	53                   	push   %ebx
80100702:	83 ec 1c             	sub    $0x1c,%esp
80100705:	8b 75 08             	mov    0x8(%ebp),%esi
  int c, doprocdump = 0;

  acquire(&cons.lock);
80100708:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
8010070f:	e8 ec 35 00 00       	call   80103d00 <acquire>
#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;
80100714:	31 ff                	xor    %edi,%edi
80100716:	66 90                	xchg   %ax,%ax

  acquire(&cons.lock);
  while((c = getc()) >= 0){
80100718:	ff d6                	call   *%esi
8010071a:	89 c3                	mov    %eax,%ebx
8010071c:	85 c0                	test   %eax,%eax
8010071e:	0f 88 8c 00 00 00    	js     801007b0 <consoleintr+0xb4>
    switch(c){
80100724:	83 fb 10             	cmp    $0x10,%ebx
80100727:	0f 84 d3 00 00 00    	je     80100800 <consoleintr+0x104>
8010072d:	0f 8f 99 00 00 00    	jg     801007cc <consoleintr+0xd0>
80100733:	83 fb 08             	cmp    $0x8,%ebx
80100736:	0f 84 9e 00 00 00    	je     801007da <consoleintr+0xde>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010073c:	85 db                	test   %ebx,%ebx
8010073e:	74 d8                	je     80100718 <consoleintr+0x1c>
80100740:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
80100745:	89 c2                	mov    %eax,%edx
80100747:	2b 15 a0 ef 10 80    	sub    0x8010efa0,%edx
8010074d:	83 fa 7f             	cmp    $0x7f,%edx
80100750:	77 c6                	ja     80100718 <consoleintr+0x1c>
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
80100752:	89 c2                	mov    %eax,%edx
80100754:	83 e2 7f             	and    $0x7f,%edx
        consputc(BACKSPACE);
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
80100757:	83 fb 0d             	cmp    $0xd,%ebx
8010075a:	0f 84 00 01 00 00    	je     80100860 <consoleintr+0x164>
        input.buf[input.e++ % INPUT_BUF] = c;
80100760:	88 9a 20 ef 10 80    	mov    %bl,-0x7fef10e0(%edx)
80100766:	40                   	inc    %eax
80100767:	a3 a8 ef 10 80       	mov    %eax,0x8010efa8
        consputc(c);
8010076c:	89 d8                	mov    %ebx,%eax
8010076e:	e8 25 fc ff ff       	call   80100398 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100773:	83 fb 0a             	cmp    $0xa,%ebx
80100776:	0f 84 fb 00 00 00    	je     80100877 <consoleintr+0x17b>
8010077c:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
80100781:	83 fb 04             	cmp    $0x4,%ebx
80100784:	74 0d                	je     80100793 <consoleintr+0x97>
80100786:	8b 15 a0 ef 10 80    	mov    0x8010efa0,%edx
8010078c:	83 ea 80             	sub    $0xffffff80,%edx
8010078f:	39 d0                	cmp    %edx,%eax
80100791:	75 85                	jne    80100718 <consoleintr+0x1c>
          input.w = input.e;
80100793:	a3 a4 ef 10 80       	mov    %eax,0x8010efa4
          wakeup(&input.r);
80100798:	c7 04 24 a0 ef 10 80 	movl   $0x8010efa0,(%esp)
8010079f:	e8 8c 31 00 00       	call   80103930 <wakeup>
consoleintr(int (*getc)(void))
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
801007a4:	ff d6                	call   *%esi
801007a6:	89 c3                	mov    %eax,%ebx
801007a8:	85 c0                	test   %eax,%eax
801007aa:	0f 89 74 ff ff ff    	jns    80100724 <consoleintr+0x28>
        }
      }
      break;
    }
  }
  release(&cons.lock);
801007b0:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801007b7:	e8 a8 35 00 00       	call   80103d64 <release>
  if(doprocdump) {
801007bc:	85 ff                	test   %edi,%edi
801007be:	0f 85 90 00 00 00    	jne    80100854 <consoleintr+0x158>
    procdump();  // now call procdump() wo. cons.lock held
  }
}
801007c4:	83 c4 1c             	add    $0x1c,%esp
801007c7:	5b                   	pop    %ebx
801007c8:	5e                   	pop    %esi
801007c9:	5f                   	pop    %edi
801007ca:	5d                   	pop    %ebp
801007cb:	c3                   	ret    
{
  int c, doprocdump = 0;

  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
801007cc:	83 fb 15             	cmp    $0x15,%ebx
801007cf:	74 3b                	je     8010080c <consoleintr+0x110>
801007d1:	83 fb 7f             	cmp    $0x7f,%ebx
801007d4:	0f 85 62 ff ff ff    	jne    8010073c <consoleintr+0x40>
        input.e--;
        consputc(BACKSPACE);
      }
      break;
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
801007da:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
801007df:	3b 05 a4 ef 10 80    	cmp    0x8010efa4,%eax
801007e5:	0f 84 2d ff ff ff    	je     80100718 <consoleintr+0x1c>
        input.e--;
801007eb:	48                   	dec    %eax
801007ec:	a3 a8 ef 10 80       	mov    %eax,0x8010efa8
        consputc(BACKSPACE);
801007f1:	b8 00 01 00 00       	mov    $0x100,%eax
801007f6:	e8 9d fb ff ff       	call   80100398 <consputc>
801007fb:	e9 18 ff ff ff       	jmp    80100718 <consoleintr+0x1c>
  acquire(&cons.lock);
  while((c = getc()) >= 0){
    switch(c){
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
80100800:	bf 01 00 00 00       	mov    $0x1,%edi
80100805:	e9 0e ff ff ff       	jmp    80100718 <consoleintr+0x1c>
8010080a:	66 90                	xchg   %ax,%ax
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010080c:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
80100811:	3b 05 a4 ef 10 80    	cmp    0x8010efa4,%eax
80100817:	75 27                	jne    80100840 <consoleintr+0x144>
80100819:	e9 fa fe ff ff       	jmp    80100718 <consoleintr+0x1c>
8010081e:	66 90                	xchg   %ax,%ax
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100820:	a3 a8 ef 10 80       	mov    %eax,0x8010efa8
        consputc(BACKSPACE);
80100825:	b8 00 01 00 00       	mov    $0x100,%eax
8010082a:	e8 69 fb ff ff       	call   80100398 <consputc>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010082f:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
80100834:	3b 05 a4 ef 10 80    	cmp    0x8010efa4,%eax
8010083a:	0f 84 d8 fe ff ff    	je     80100718 <consoleintr+0x1c>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100840:	48                   	dec    %eax
80100841:	89 c2                	mov    %eax,%edx
80100843:	83 e2 7f             	and    $0x7f,%edx
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100846:	80 ba 20 ef 10 80 0a 	cmpb   $0xa,-0x7fef10e0(%edx)
8010084d:	75 d1                	jne    80100820 <consoleintr+0x124>
8010084f:	e9 c4 fe ff ff       	jmp    80100718 <consoleintr+0x1c>
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
  }
}
80100854:	83 c4 1c             	add    $0x1c,%esp
80100857:	5b                   	pop    %ebx
80100858:	5e                   	pop    %esi
80100859:	5f                   	pop    %edi
8010085a:	5d                   	pop    %ebp
      break;
    }
  }
  release(&cons.lock);
  if(doprocdump) {
    procdump();  // now call procdump() wo. cons.lock held
8010085b:	e9 a4 31 00 00       	jmp    80103a04 <procdump>
      }
      break;
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
        c = (c == '\r') ? '\n' : c;
        input.buf[input.e++ % INPUT_BUF] = c;
80100860:	c6 82 20 ef 10 80 0a 	movb   $0xa,-0x7fef10e0(%edx)
80100867:	40                   	inc    %eax
80100868:	a3 a8 ef 10 80       	mov    %eax,0x8010efa8
        consputc(c);
8010086d:	b8 0a 00 00 00       	mov    $0xa,%eax
80100872:	e8 21 fb ff ff       	call   80100398 <consputc>
80100877:	a1 a8 ef 10 80       	mov    0x8010efa8,%eax
8010087c:	e9 12 ff ff ff       	jmp    80100793 <consoleintr+0x97>
80100881:	8d 76 00             	lea    0x0(%esi),%esi

80100884 <consoleinit>:
  return n;
}

void
consoleinit(void)
{
80100884:	55                   	push   %ebp
80100885:	89 e5                	mov    %esp,%ebp
80100887:	83 ec 18             	sub    $0x18,%esp
  initlock(&cons.lock, "console");
8010088a:	c7 44 24 04 48 65 10 	movl   $0x80106548,0x4(%esp)
80100891:	80 
80100892:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
80100899:	e8 26 33 00 00       	call   80103bc4 <initlock>

  devsw[CONSOLE].write = consolewrite;
8010089e:	c7 05 6c f9 10 80 fc 	movl   $0x801004fc,0x8010f96c
801008a5:	04 10 80 
  devsw[CONSOLE].read = consoleread;
801008a8:	c7 05 68 f9 10 80 30 	movl   $0x80100230,0x8010f968
801008af:	02 10 80 
  cons.locking = 1;
801008b2:	c7 05 54 95 10 80 01 	movl   $0x1,0x80109554
801008b9:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008bc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801008c3:	00 
801008c4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801008cb:	e8 94 17 00 00       	call   80102064 <ioapicenable>
}
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    
	...

801008d4 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d4:	55                   	push   %ebp
801008d5:	89 e5                	mov    %esp,%ebp
801008d7:	57                   	push   %edi
801008d8:	56                   	push   %esi
801008d9:	53                   	push   %ebx
801008da:	81 ec 3c 01 00 00    	sub    $0x13c,%esp
801008e0:	8b 75 08             	mov    0x8(%ebp),%esi
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008e3:	e8 c8 29 00 00       	call   801032b0 <myproc>
801008e8:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008ee:	e8 ed 1e 00 00       	call   801027e0 <begin_op>

  if((ip = namei(path)) == 0){
801008f3:	89 34 24             	mov    %esi,(%esp)
801008f6:	e8 1d 14 00 00       	call   80101d18 <namei>
801008fb:	89 c3                	mov    %eax,%ebx
801008fd:	85 c0                	test   %eax,%eax
801008ff:	0f 84 3c 02 00 00    	je     80100b41 <exec+0x26d>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100905:	89 04 24             	mov    %eax,(%esp)
80100908:	e8 db 0b 00 00       	call   801014e8 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090d:	c7 44 24 0c 34 00 00 	movl   $0x34,0xc(%esp)
80100914:	00 
80100915:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
8010091c:	00 
8010091d:	8d 45 94             	lea    -0x6c(%ebp),%eax
80100920:	89 44 24 04          	mov    %eax,0x4(%esp)
80100924:	89 1c 24             	mov    %ebx,(%esp)
80100927:	e8 58 0e 00 00       	call   80101784 <readi>
8010092c:	83 f8 34             	cmp    $0x34,%eax
8010092f:	74 1f                	je     80100950 <exec+0x7c>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100931:	89 1c 24             	mov    %ebx,(%esp)
80100934:	e8 ff 0d 00 00       	call   80101738 <iunlockput>
    end_op();
80100939:	e8 02 1f 00 00       	call   80102840 <end_op>
  }
  return -1;
8010093e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100943:	81 c4 3c 01 00 00    	add    $0x13c,%esp
80100949:	5b                   	pop    %ebx
8010094a:	5e                   	pop    %esi
8010094b:	5f                   	pop    %edi
8010094c:	5d                   	pop    %ebp
8010094d:	c3                   	ret    
8010094e:	66 90                	xchg   %ax,%ax
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100950:	81 7d 94 7f 45 4c 46 	cmpl   $0x464c457f,-0x6c(%ebp)
80100957:	75 d8                	jne    80100931 <exec+0x5d>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100959:	e8 32 59 00 00       	call   80106290 <setupkvm>
8010095e:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
80100964:	85 c0                	test   %eax,%eax
80100966:	74 c9                	je     80100931 <exec+0x5d>
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100968:	8b 7d b0             	mov    -0x50(%ebp),%edi
8010096b:	66 83 7d c0 00       	cmpw   $0x0,-0x40(%ebp)

  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
80100970:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100977:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
8010097a:	0f 84 cd 00 00 00    	je     80100a4d <exec+0x179>
80100980:	31 d2                	xor    %edx,%edx
80100982:	89 b5 e8 fe ff ff    	mov    %esi,-0x118(%ebp)
80100988:	89 d6                	mov    %edx,%esi
8010098a:	eb 10                	jmp    8010099c <exec+0xc8>
8010098c:	46                   	inc    %esi
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
8010098d:	83 c7 20             	add    $0x20,%edi
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80100994:	39 f0                	cmp    %esi,%eax
80100996:	0f 8e ab 00 00 00    	jle    80100a47 <exec+0x173>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
8010099c:	c7 44 24 0c 20 00 00 	movl   $0x20,0xc(%esp)
801009a3:	00 
801009a4:	89 7c 24 08          	mov    %edi,0x8(%esp)
801009a8:	8d 45 c8             	lea    -0x38(%ebp),%eax
801009ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801009af:	89 1c 24             	mov    %ebx,(%esp)
801009b2:	e8 cd 0d 00 00       	call   80101784 <readi>
801009b7:	83 f8 20             	cmp    $0x20,%eax
801009ba:	75 70                	jne    80100a2c <exec+0x158>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
801009bc:	83 7d c8 01          	cmpl   $0x1,-0x38(%ebp)
801009c0:	75 ca                	jne    8010098c <exec+0xb8>
      continue;
    if(ph.memsz < ph.filesz)
801009c2:	8b 45 dc             	mov    -0x24(%ebp),%eax
801009c5:	3b 45 d8             	cmp    -0x28(%ebp),%eax
801009c8:	72 62                	jb     80100a2c <exec+0x158>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ca:	03 45 d0             	add    -0x30(%ebp),%eax
801009cd:	72 5d                	jb     80100a2c <exec+0x158>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009cf:	89 44 24 08          	mov    %eax,0x8(%esp)
801009d3:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009d9:	89 44 24 04          	mov    %eax,0x4(%esp)
801009dd:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
801009e3:	89 04 24             	mov    %eax,(%esp)
801009e6:	e8 1d 57 00 00       	call   80106108 <allocuvm>
801009eb:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009f1:	85 c0                	test   %eax,%eax
801009f3:	74 37                	je     80100a2c <exec+0x158>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
801009f5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801009f8:	a9 ff 0f 00 00       	test   $0xfff,%eax
801009fd:	75 2d                	jne    80100a2c <exec+0x158>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
801009ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
80100a02:	89 54 24 10          	mov    %edx,0x10(%esp)
80100a06:	8b 55 cc             	mov    -0x34(%ebp),%edx
80100a09:	89 54 24 0c          	mov    %edx,0xc(%esp)
80100a0d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80100a11:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a15:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a1b:	89 04 24             	mov    %eax,(%esp)
80100a1e:	e8 79 55 00 00       	call   80105f9c <loaduvm>
80100a23:	85 c0                	test   %eax,%eax
80100a25:	0f 89 61 ff ff ff    	jns    8010098c <exec+0xb8>
80100a2b:	90                   	nop
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
80100a2c:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a32:	89 04 24             	mov    %eax,(%esp)
80100a35:	e8 e2 57 00 00       	call   8010621c <freevm>
  if(ip){
80100a3a:	85 db                	test   %ebx,%ebx
80100a3c:	0f 85 ef fe ff ff    	jne    80100931 <exec+0x5d>
80100a42:	e9 f7 fe ff ff       	jmp    8010093e <exec+0x6a>
80100a47:	8b b5 e8 fe ff ff    	mov    -0x118(%ebp),%esi
    if(ph.vaddr % PGSIZE != 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100a4d:	89 1c 24             	mov    %ebx,(%esp)
80100a50:	e8 e3 0c 00 00       	call   80101738 <iunlockput>
  end_op();
80100a55:	e8 e6 1d 00 00       	call   80102840 <end_op>
  ip = 0;

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100a5a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100a60:	05 ff 0f 00 00       	add    $0xfff,%eax
80100a65:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a6a:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a70:	89 54 24 08          	mov    %edx,0x8(%esp)
80100a74:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a78:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a7e:	89 04 24             	mov    %eax,(%esp)
80100a81:	e8 82 56 00 00       	call   80106108 <allocuvm>
80100a86:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a8c:	85 c0                	test   %eax,%eax
80100a8e:	75 04                	jne    80100a94 <exec+0x1c0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;
80100a90:	31 db                	xor    %ebx,%ebx
80100a92:	eb 98                	jmp    80100a2c <exec+0x158>
  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100a94:	2d 00 20 00 00       	sub    $0x2000,%eax
80100a99:	89 44 24 04          	mov    %eax,0x4(%esp)
80100a9d:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100aa3:	89 04 24             	mov    %eax,(%esp)
80100aa6:	e8 79 58 00 00       	call   80106324 <clearpteu>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100aab:	8b 55 0c             	mov    0xc(%ebp),%edx
80100aae:	8b 02                	mov    (%edx),%eax
80100ab0:	85 c0                	test   %eax,%eax
80100ab2:	0f 84 80 01 00 00    	je     80100c38 <exec+0x364>
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
80100ab8:	83 c2 04             	add    $0x4,%edx
80100abb:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	31 ff                	xor    %edi,%edi
80100ac3:	89 b5 e8 fe ff ff    	mov    %esi,-0x118(%ebp)
80100ac9:	89 d6                	mov    %edx,%esi
80100acb:	8b 55 0c             	mov    0xc(%ebp),%edx
80100ace:	eb 1e                	jmp    80100aee <exec+0x21a>
    if(argc >= MAXARG)
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
80100ad0:	8d 8d 04 ff ff ff    	lea    -0xfc(%ebp),%ecx
80100ad6:	89 9c bd 10 ff ff ff 	mov    %ebx,-0xf0(%ebp,%edi,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100add:	47                   	inc    %edi
80100ade:	89 f2                	mov    %esi,%edx
80100ae0:	8b 06                	mov    (%esi),%eax
80100ae2:	85 c0                	test   %eax,%eax
80100ae4:	74 76                	je     80100b5c <exec+0x288>
80100ae6:	83 c6 04             	add    $0x4,%esi
    if(argc >= MAXARG)
80100ae9:	83 ff 20             	cmp    $0x20,%edi
80100aec:	74 a2                	je     80100a90 <exec+0x1bc>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100aee:	89 04 24             	mov    %eax,(%esp)
80100af1:	89 95 e4 fe ff ff    	mov    %edx,-0x11c(%ebp)
80100af7:	e8 68 34 00 00       	call   80103f64 <strlen>
80100afc:	f7 d0                	not    %eax
80100afe:	01 c3                	add    %eax,%ebx
80100b00:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100b03:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100b09:	8b 02                	mov    (%edx),%eax
80100b0b:	89 04 24             	mov    %eax,(%esp)
80100b0e:	e8 51 34 00 00       	call   80103f64 <strlen>
80100b13:	40                   	inc    %eax
80100b14:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100b18:	8b 95 e4 fe ff ff    	mov    -0x11c(%ebp),%edx
80100b1e:	8b 02                	mov    (%edx),%eax
80100b20:	89 44 24 08          	mov    %eax,0x8(%esp)
80100b24:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100b28:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100b2e:	89 04 24             	mov    %eax,(%esp)
80100b31:	e8 1e 59 00 00       	call   80106454 <copyout>
80100b36:	85 c0                	test   %eax,%eax
80100b38:	79 96                	jns    80100ad0 <exec+0x1fc>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
  end_op();
  ip = 0;
80100b3a:	31 db                	xor    %ebx,%ebx
80100b3c:	e9 eb fe ff ff       	jmp    80100a2c <exec+0x158>
  struct proc *curproc = myproc();

  begin_op();

  if((ip = namei(path)) == 0){
    end_op();
80100b41:	e8 fa 1c 00 00       	call   80102840 <end_op>
    cprintf("exec: fail\n");
80100b46:	c7 04 24 61 65 10 80 	movl   $0x80106561,(%esp)
80100b4d:	e8 6a fa ff ff       	call   801005bc <cprintf>
    return -1;
80100b52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b57:	e9 e7 fd ff ff       	jmp    80100943 <exec+0x6f>
80100b5c:	8b b5 e8 fe ff ff    	mov    -0x118(%ebp),%esi
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100b62:	c7 84 bd 10 ff ff ff 	movl   $0x0,-0xf0(%ebp,%edi,4)
80100b69:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100b6d:	c7 85 04 ff ff ff ff 	movl   $0xffffffff,-0xfc(%ebp)
80100b74:	ff ff ff 
  ustack[1] = argc;
80100b77:	89 bd 08 ff ff ff    	mov    %edi,-0xf8(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b7d:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100b84:	89 da                	mov    %ebx,%edx
80100b86:	29 c2                	sub    %eax,%edx
80100b88:	89 95 0c ff ff ff    	mov    %edx,-0xf4(%ebp)

  sp -= (3+argc+1) * 4;
80100b8e:	8d 04 bd 10 00 00 00 	lea    0x10(,%edi,4),%eax
80100b95:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b97:	89 44 24 0c          	mov    %eax,0xc(%esp)
80100b9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80100b9f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80100ba3:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100ba9:	89 04 24             	mov    %eax,(%esp)
80100bac:	e8 a3 58 00 00       	call   80106454 <copyout>
80100bb1:	85 c0                	test   %eax,%eax
80100bb3:	0f 88 d7 fe ff ff    	js     80100a90 <exec+0x1bc>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100bb9:	8a 16                	mov    (%esi),%dl
80100bbb:	84 d2                	test   %dl,%dl
80100bbd:	74 16                	je     80100bd5 <exec+0x301>
#include "defs.h"
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
80100bbf:	8d 46 01             	lea    0x1(%esi),%eax
80100bc2:	eb 08                	jmp    80100bcc <exec+0x2f8>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
    if(*s == '/')
      last = s+1;
80100bc4:	40                   	inc    %eax
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100bc5:	8a 50 ff             	mov    -0x1(%eax),%dl
80100bc8:	84 d2                	test   %dl,%dl
80100bca:	74 09                	je     80100bd5 <exec+0x301>
    if(*s == '/')
80100bcc:	80 fa 2f             	cmp    $0x2f,%dl
80100bcf:	75 f3                	jne    80100bc4 <exec+0x2f0>
      last = s+1;
80100bd1:	89 c6                	mov    %eax,%esi
80100bd3:	eb ef                	jmp    80100bc4 <exec+0x2f0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100bd5:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80100bdc:	00 
80100bdd:	89 74 24 04          	mov    %esi,0x4(%esp)
80100be1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100be7:	83 c0 6c             	add    $0x6c,%eax
80100bea:	89 04 24             	mov    %eax,(%esp)
80100bed:	e8 46 33 00 00       	call   80103f38 <safestrcpy>

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100bf2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
80100bf8:	8b 70 04             	mov    0x4(%eax),%esi
  curproc->pgdir = pgdir;
80100bfb:	8b 95 ec fe ff ff    	mov    -0x114(%ebp),%edx
80100c01:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100c04:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c0a:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100c0c:	8b 40 18             	mov    0x18(%eax),%eax
80100c0f:	8b 55 ac             	mov    -0x54(%ebp),%edx
80100c12:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100c15:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c1b:	8b 42 18             	mov    0x18(%edx),%eax
80100c1e:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100c21:	89 14 24             	mov    %edx,(%esp)
80100c24:	e8 f7 51 00 00       	call   80105e20 <switchuvm>
  freevm(oldpgdir);
80100c29:	89 34 24             	mov    %esi,(%esp)
80100c2c:	e8 eb 55 00 00       	call   8010621c <freevm>
  return 0;
80100c31:	31 c0                	xor    %eax,%eax
80100c33:	e9 0b fd ff ff       	jmp    80100943 <exec+0x6f>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100c38:	8b 9d f0 fe ff ff    	mov    -0x110(%ebp),%ebx
80100c3e:	31 ff                	xor    %edi,%edi
80100c40:	8d 8d 04 ff ff ff    	lea    -0xfc(%ebp),%ecx
80100c46:	e9 17 ff ff ff       	jmp    80100b62 <exec+0x28e>
	...

80100c4c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c4c:	55                   	push   %ebp
80100c4d:	89 e5                	mov    %esp,%ebp
80100c4f:	83 ec 18             	sub    $0x18,%esp
  initlock(&ftable.lock, "ftable");
80100c52:	c7 44 24 04 6d 65 10 	movl   $0x8010656d,0x4(%esp)
80100c59:	80 
80100c5a:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100c61:	e8 5e 2f 00 00       	call   80103bc4 <initlock>
}
80100c66:	c9                   	leave  
80100c67:	c3                   	ret    

80100c68 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c68:	55                   	push   %ebp
80100c69:	89 e5                	mov    %esp,%ebp
80100c6b:	53                   	push   %ebx
80100c6c:	83 ec 14             	sub    $0x14,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c6f:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100c76:	e8 85 30 00 00       	call   80103d00 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c7b:	bb f4 ef 10 80       	mov    $0x8010eff4,%ebx
    if(f->ref == 0){
80100c80:	8b 15 f8 ef 10 80    	mov    0x8010eff8,%edx
80100c86:	85 d2                	test   %edx,%edx
80100c88:	74 14                	je     80100c9e <filealloc+0x36>
80100c8a:	66 90                	xchg   %ax,%ax
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c8c:	83 c3 18             	add    $0x18,%ebx
80100c8f:	81 fb 54 f9 10 80    	cmp    $0x8010f954,%ebx
80100c95:	73 25                	jae    80100cbc <filealloc+0x54>
    if(f->ref == 0){
80100c97:	8b 43 04             	mov    0x4(%ebx),%eax
80100c9a:	85 c0                	test   %eax,%eax
80100c9c:	75 ee                	jne    80100c8c <filealloc+0x24>
      f->ref = 1;
80100c9e:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100ca5:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100cac:	e8 b3 30 00 00       	call   80103d64 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100cb1:	89 d8                	mov    %ebx,%eax
80100cb3:	83 c4 14             	add    $0x14,%esp
80100cb6:	5b                   	pop    %ebx
80100cb7:	5d                   	pop    %ebp
80100cb8:	c3                   	ret    
80100cb9:	8d 76 00             	lea    0x0(%esi),%esi
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100cbc:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100cc3:	e8 9c 30 00 00       	call   80103d64 <release>
  return 0;
80100cc8:	31 db                	xor    %ebx,%ebx
}
80100cca:	89 d8                	mov    %ebx,%eax
80100ccc:	83 c4 14             	add    $0x14,%esp
80100ccf:	5b                   	pop    %ebx
80100cd0:	5d                   	pop    %ebp
80100cd1:	c3                   	ret    
80100cd2:	66 90                	xchg   %ax,%ax

80100cd4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100cd4:	55                   	push   %ebp
80100cd5:	89 e5                	mov    %esp,%ebp
80100cd7:	53                   	push   %ebx
80100cd8:	83 ec 14             	sub    $0x14,%esp
80100cdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100cde:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100ce5:	e8 16 30 00 00       	call   80103d00 <acquire>
  if(f->ref < 1)
80100cea:	8b 43 04             	mov    0x4(%ebx),%eax
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 18                	jle    80100d09 <filedup+0x35>
    panic("filedup");
  f->ref++;
80100cf1:	40                   	inc    %eax
80100cf2:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cf5:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100cfc:	e8 63 30 00 00       	call   80103d64 <release>
  return f;
}
80100d01:	89 d8                	mov    %ebx,%eax
80100d03:	83 c4 14             	add    $0x14,%esp
80100d06:	5b                   	pop    %ebx
80100d07:	5d                   	pop    %ebp
80100d08:	c3                   	ret    
struct file*
filedup(struct file *f)
{
  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("filedup");
80100d09:	c7 04 24 74 65 10 80 	movl   $0x80106574,(%esp)
80100d10:	e8 07 f6 ff ff       	call   8010031c <panic>
80100d15:	8d 76 00             	lea    0x0(%esi),%esi

80100d18 <fileclose>:
}

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100d18:	55                   	push   %ebp
80100d19:	89 e5                	mov    %esp,%ebp
80100d1b:	57                   	push   %edi
80100d1c:	56                   	push   %esi
80100d1d:	53                   	push   %ebx
80100d1e:	83 ec 2c             	sub    $0x2c,%esp
80100d21:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100d24:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100d2b:	e8 d0 2f 00 00       	call   80103d00 <acquire>
  if(f->ref < 1)
80100d30:	8b 43 04             	mov    0x4(%ebx),%eax
80100d33:	85 c0                	test   %eax,%eax
80100d35:	0f 8e 86 00 00 00    	jle    80100dc1 <fileclose+0xa9>
    panic("fileclose");
  if(--f->ref > 0){
80100d3b:	48                   	dec    %eax
80100d3c:	89 43 04             	mov    %eax,0x4(%ebx)
80100d3f:	85 c0                	test   %eax,%eax
80100d41:	74 15                	je     80100d58 <fileclose+0x40>
    release(&ftable.lock);
80100d43:	c7 45 08 c0 ef 10 80 	movl   $0x8010efc0,0x8(%ebp)
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d4a:	83 c4 2c             	add    $0x2c,%esp
80100d4d:	5b                   	pop    %ebx
80100d4e:	5e                   	pop    %esi
80100d4f:	5f                   	pop    %edi
80100d50:	5d                   	pop    %ebp

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
  if(--f->ref > 0){
    release(&ftable.lock);
80100d51:	e9 0e 30 00 00       	jmp    80103d64 <release>
80100d56:	66 90                	xchg   %ax,%ax
    return;
  }
  ff = *f;
80100d58:	8b 33                	mov    (%ebx),%esi
80100d5a:	8a 43 09             	mov    0x9(%ebx),%al
80100d5d:	88 45 e7             	mov    %al,-0x19(%ebp)
80100d60:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d63:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d66:	8b 7b 10             	mov    0x10(%ebx),%edi
  f->ref = 0;
  f->type = FD_NONE;
80100d69:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d6f:	c7 04 24 c0 ef 10 80 	movl   $0x8010efc0,(%esp)
80100d76:	e8 e9 2f 00 00       	call   80103d64 <release>

  if(ff.type == FD_PIPE)
80100d7b:	83 fe 01             	cmp    $0x1,%esi
80100d7e:	74 2c                	je     80100dac <fileclose+0x94>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100d80:	83 fe 02             	cmp    $0x2,%esi
80100d83:	74 0b                	je     80100d90 <fileclose+0x78>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d85:	83 c4 2c             	add    $0x2c,%esp
80100d88:	5b                   	pop    %ebx
80100d89:	5e                   	pop    %esi
80100d8a:	5f                   	pop    %edi
80100d8b:	5d                   	pop    %ebp
80100d8c:	c3                   	ret    
80100d8d:	8d 76 00             	lea    0x0(%esi),%esi
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
80100d90:	e8 4b 1a 00 00       	call   801027e0 <begin_op>
    iput(ff.ip);
80100d95:	89 3c 24             	mov    %edi,(%esp)
80100d98:	e8 5b 08 00 00       	call   801015f8 <iput>
    end_op();
  }
}
80100d9d:	83 c4 2c             	add    $0x2c,%esp
80100da0:	5b                   	pop    %ebx
80100da1:	5e                   	pop    %esi
80100da2:	5f                   	pop    %edi
80100da3:	5d                   	pop    %ebp
  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
80100da4:	e9 97 1a 00 00       	jmp    80102840 <end_op>
80100da9:	8d 76 00             	lea    0x0(%esi),%esi
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);

  if(ff.type == FD_PIPE)
    pipeclose(ff.pipe, ff.writable);
80100dac:	0f be 45 e7          	movsbl -0x19(%ebp),%eax
80100db0:	89 44 24 04          	mov    %eax,0x4(%esp)
80100db4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100db7:	89 04 24             	mov    %eax,(%esp)
80100dba:	e8 d5 20 00 00       	call   80102e94 <pipeclose>
80100dbf:	eb c4                	jmp    80100d85 <fileclose+0x6d>
{
  struct file ff;

  acquire(&ftable.lock);
  if(f->ref < 1)
    panic("fileclose");
80100dc1:	c7 04 24 7c 65 10 80 	movl   $0x8010657c,(%esp)
80100dc8:	e8 4f f5 ff ff       	call   8010031c <panic>
80100dcd:	8d 76 00             	lea    0x0(%esi),%esi

80100dd0 <filestat>:
}

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100dd0:	55                   	push   %ebp
80100dd1:	89 e5                	mov    %esp,%ebp
80100dd3:	53                   	push   %ebx
80100dd4:	83 ec 14             	sub    $0x14,%esp
80100dd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100dda:	83 3b 02             	cmpl   $0x2,(%ebx)
80100ddd:	75 31                	jne    80100e10 <filestat+0x40>
    ilock(f->ip);
80100ddf:	8b 43 10             	mov    0x10(%ebx),%eax
80100de2:	89 04 24             	mov    %eax,(%esp)
80100de5:	e8 fe 06 00 00       	call   801014e8 <ilock>
    stati(f->ip, st);
80100dea:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ded:	89 44 24 04          	mov    %eax,0x4(%esp)
80100df1:	8b 43 10             	mov    0x10(%ebx),%eax
80100df4:	89 04 24             	mov    %eax,(%esp)
80100df7:	e8 5c 09 00 00       	call   80101758 <stati>
    iunlock(f->ip);
80100dfc:	8b 43 10             	mov    0x10(%ebx),%eax
80100dff:	89 04 24             	mov    %eax,(%esp)
80100e02:	e8 b1 07 00 00       	call   801015b8 <iunlock>
    return 0;
80100e07:	31 c0                	xor    %eax,%eax
  }
  return -1;
}
80100e09:	83 c4 14             	add    $0x14,%esp
80100e0c:	5b                   	pop    %ebx
80100e0d:	5d                   	pop    %ebp
80100e0e:	c3                   	ret    
80100e0f:	90                   	nop
    ilock(f->ip);
    stati(f->ip, st);
    iunlock(f->ip);
    return 0;
  }
  return -1;
80100e10:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100e15:	83 c4 14             	add    $0x14,%esp
80100e18:	5b                   	pop    %ebx
80100e19:	5d                   	pop    %ebp
80100e1a:	c3                   	ret    
80100e1b:	90                   	nop

80100e1c <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100e1c:	55                   	push   %ebp
80100e1d:	89 e5                	mov    %esp,%ebp
80100e1f:	57                   	push   %edi
80100e20:	56                   	push   %esi
80100e21:	53                   	push   %ebx
80100e22:	83 ec 2c             	sub    $0x2c,%esp
80100e25:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100e28:	8b 75 0c             	mov    0xc(%ebp),%esi
80100e2b:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80100e2e:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100e32:	74 68                	je     80100e9c <fileread+0x80>
    return -1;
  if(f->type == FD_PIPE)
80100e34:	8b 03                	mov    (%ebx),%eax
80100e36:	83 f8 01             	cmp    $0x1,%eax
80100e39:	74 4d                	je     80100e88 <fileread+0x6c>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e3b:	83 f8 02             	cmp    $0x2,%eax
80100e3e:	75 63                	jne    80100ea3 <fileread+0x87>
    ilock(f->ip);
80100e40:	8b 43 10             	mov    0x10(%ebx),%eax
80100e43:	89 04 24             	mov    %eax,(%esp)
80100e46:	e8 9d 06 00 00       	call   801014e8 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100e4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80100e4f:	8b 43 14             	mov    0x14(%ebx),%eax
80100e52:	89 44 24 08          	mov    %eax,0x8(%esp)
80100e56:	89 74 24 04          	mov    %esi,0x4(%esp)
80100e5a:	8b 43 10             	mov    0x10(%ebx),%eax
80100e5d:	89 04 24             	mov    %eax,(%esp)
80100e60:	e8 1f 09 00 00       	call   80101784 <readi>
80100e65:	85 c0                	test   %eax,%eax
80100e67:	7e 03                	jle    80100e6c <fileread+0x50>
      f->off += r;
80100e69:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e6c:	8b 53 10             	mov    0x10(%ebx),%edx
80100e6f:	89 14 24             	mov    %edx,(%esp)
80100e72:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100e75:	e8 3e 07 00 00       	call   801015b8 <iunlock>
    return r;
80100e7a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  }
  panic("fileread");
}
80100e7d:	83 c4 2c             	add    $0x2c,%esp
80100e80:	5b                   	pop    %ebx
80100e81:	5e                   	pop    %esi
80100e82:	5f                   	pop    %edi
80100e83:	5d                   	pop    %ebp
80100e84:	c3                   	ret    
80100e85:	8d 76 00             	lea    0x0(%esi),%esi
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100e88:	8b 43 0c             	mov    0xc(%ebx),%eax
80100e8b:	89 45 08             	mov    %eax,0x8(%ebp)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
}
80100e8e:	83 c4 2c             	add    $0x2c,%esp
80100e91:	5b                   	pop    %ebx
80100e92:	5e                   	pop    %esi
80100e93:	5f                   	pop    %edi
80100e94:	5d                   	pop    %ebp
  int r;

  if(f->readable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return piperead(f->pipe, addr, n);
80100e95:	e9 62 21 00 00       	jmp    80102ffc <piperead>
80100e9a:	66 90                	xchg   %ax,%ax
fileread(struct file *f, char *addr, int n)
{
  int r;

  if(f->readable == 0)
    return -1;
80100e9c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ea1:	eb da                	jmp    80100e7d <fileread+0x61>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
    return r;
  }
  panic("fileread");
80100ea3:	c7 04 24 86 65 10 80 	movl   $0x80106586,(%esp)
80100eaa:	e8 6d f4 ff ff       	call   8010031c <panic>
80100eaf:	90                   	nop

80100eb0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100eb0:	55                   	push   %ebp
80100eb1:	89 e5                	mov    %esp,%ebp
80100eb3:	57                   	push   %edi
80100eb4:	56                   	push   %esi
80100eb5:	53                   	push   %ebx
80100eb6:	83 ec 2c             	sub    $0x2c,%esp
80100eb9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80100ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ebf:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ec2:	8b 45 10             	mov    0x10(%ebp),%eax
80100ec5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  int r;

  if(f->writable == 0)
80100ec8:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100ecc:	0f 84 a9 00 00 00    	je     80100f7b <filewrite+0xcb>
    return -1;
  if(f->type == FD_PIPE)
80100ed2:	8b 03                	mov    (%ebx),%eax
80100ed4:	83 f8 01             	cmp    $0x1,%eax
80100ed7:	0f 84 ba 00 00 00    	je     80100f97 <filewrite+0xe7>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100edd:	83 f8 02             	cmp    $0x2,%eax
80100ee0:	0f 85 cf 00 00 00    	jne    80100fb5 <filewrite+0x105>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100ee6:	31 f6                	xor    %esi,%esi
80100ee8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80100eeb:	85 c9                	test   %ecx,%ecx
80100eed:	7f 2d                	jg     80100f1c <filewrite+0x6c>
80100eef:	e9 94 00 00 00       	jmp    80100f88 <filewrite+0xd8>
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80100ef4:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ef7:	8b 53 10             	mov    0x10(%ebx),%edx
80100efa:	89 14 24             	mov    %edx,(%esp)
80100efd:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100f00:	e8 b3 06 00 00       	call   801015b8 <iunlock>
      end_op();
80100f05:	e8 36 19 00 00       	call   80102840 <end_op>
80100f0a:	8b 45 dc             	mov    -0x24(%ebp),%eax

      if(r < 0)
        break;
      if(r != n1)
80100f0d:	39 f8                	cmp    %edi,%eax
80100f0f:	0f 85 94 00 00 00    	jne    80100fa9 <filewrite+0xf9>
        panic("short filewrite");
      i += r;
80100f15:	01 c6                	add    %eax,%esi
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80100f17:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100f1a:	7e 6c                	jle    80100f88 <filewrite+0xd8>
      int n1 = n - i;
80100f1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80100f1f:	29 f7                	sub    %esi,%edi
80100f21:	81 ff 00 06 00 00    	cmp    $0x600,%edi
80100f27:	7e 05                	jle    80100f2e <filewrite+0x7e>
80100f29:	bf 00 06 00 00       	mov    $0x600,%edi
      if(n1 > max)
        n1 = max;

      begin_op();
80100f2e:	e8 ad 18 00 00       	call   801027e0 <begin_op>
      ilock(f->ip);
80100f33:	8b 43 10             	mov    0x10(%ebx),%eax
80100f36:	89 04 24             	mov    %eax,(%esp)
80100f39:	e8 aa 05 00 00       	call   801014e8 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100f3e:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80100f42:	8b 43 14             	mov    0x14(%ebx),%eax
80100f45:	89 44 24 08          	mov    %eax,0x8(%esp)
80100f49:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100f4c:	01 f0                	add    %esi,%eax
80100f4e:	89 44 24 04          	mov    %eax,0x4(%esp)
80100f52:	8b 43 10             	mov    0x10(%ebx),%eax
80100f55:	89 04 24             	mov    %eax,(%esp)
80100f58:	e8 53 09 00 00       	call   801018b0 <writei>
80100f5d:	85 c0                	test   %eax,%eax
80100f5f:	7f 93                	jg     80100ef4 <filewrite+0x44>
        f->off += r;
      iunlock(f->ip);
80100f61:	8b 53 10             	mov    0x10(%ebx),%edx
80100f64:	89 14 24             	mov    %edx,(%esp)
80100f67:	89 45 dc             	mov    %eax,-0x24(%ebp)
80100f6a:	e8 49 06 00 00       	call   801015b8 <iunlock>
      end_op();
80100f6f:	e8 cc 18 00 00       	call   80102840 <end_op>

      if(r < 0)
80100f74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100f77:	85 c0                	test   %eax,%eax
80100f79:	74 92                	je     80100f0d <filewrite+0x5d>
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80100f7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
80100f80:	83 c4 2c             	add    $0x2c,%esp
80100f83:	5b                   	pop    %ebx
80100f84:	5e                   	pop    %esi
80100f85:	5f                   	pop    %edi
80100f86:	5d                   	pop    %ebp
80100f87:	c3                   	ret    
        break;
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80100f88:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
80100f8b:	75 ee                	jne    80100f7b <filewrite+0xcb>
80100f8d:	89 f0                	mov    %esi,%eax
  }
  panic("filewrite");
}
80100f8f:	83 c4 2c             	add    $0x2c,%esp
80100f92:	5b                   	pop    %ebx
80100f93:	5e                   	pop    %esi
80100f94:	5f                   	pop    %edi
80100f95:	5d                   	pop    %ebp
80100f96:	c3                   	ret    
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100f97:	8b 43 0c             	mov    0xc(%ebx),%eax
80100f9a:	89 45 08             	mov    %eax,0x8(%ebp)
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
}
80100f9d:	83 c4 2c             	add    $0x2c,%esp
80100fa0:	5b                   	pop    %ebx
80100fa1:	5e                   	pop    %esi
80100fa2:	5f                   	pop    %edi
80100fa3:	5d                   	pop    %ebp
  int r;

  if(f->writable == 0)
    return -1;
  if(f->type == FD_PIPE)
    return pipewrite(f->pipe, addr, n);
80100fa4:	e9 73 1f 00 00       	jmp    80102f1c <pipewrite>
      end_op();

      if(r < 0)
        break;
      if(r != n1)
        panic("short filewrite");
80100fa9:	c7 04 24 8f 65 10 80 	movl   $0x8010658f,(%esp)
80100fb0:	e8 67 f3 ff ff       	call   8010031c <panic>
      i += r;
    }
    return i == n ? n : -1;
  }
  panic("filewrite");
80100fb5:	c7 04 24 95 65 10 80 	movl   $0x80106595,(%esp)
80100fbc:	e8 5b f3 ff ff       	call   8010031c <panic>
80100fc1:	00 00                	add    %al,(%eax)
	...

80100fc4 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	57                   	push   %edi
80100fc8:	56                   	push   %esi
80100fc9:	53                   	push   %ebx
80100fca:	83 ec 2c             	sub    $0x2c,%esp
80100fcd:	89 c3                	mov    %eax,%ebx
80100fcf:	89 d7                	mov    %edx,%edi
  struct inode *ip, *empty;

  acquire(&icache.lock);
80100fd1:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
80100fd8:	e8 23 2d 00 00       	call   80103d00 <acquire>

  // Is the inode already cached?
  empty = 0;
80100fdd:	31 f6                	xor    %esi,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100fdf:	b8 14 fa 10 80       	mov    $0x8010fa14,%eax
80100fe4:	eb 12                	jmp    80100ff8 <iget+0x34>
80100fe6:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80100fe8:	85 f6                	test   %esi,%esi
80100fea:	74 3c                	je     80101028 <iget+0x64>

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80100fec:	05 90 00 00 00       	add    $0x90,%eax
80100ff1:	3d 34 16 11 80       	cmp    $0x80111634,%eax
80100ff6:	73 44                	jae    8010103c <iget+0x78>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80100ff8:	8b 48 08             	mov    0x8(%eax),%ecx
80100ffb:	85 c9                	test   %ecx,%ecx
80100ffd:	7e e9                	jle    80100fe8 <iget+0x24>
80100fff:	39 18                	cmp    %ebx,(%eax)
80101001:	75 e5                	jne    80100fe8 <iget+0x24>
80101003:	39 78 04             	cmp    %edi,0x4(%eax)
80101006:	75 e0                	jne    80100fe8 <iget+0x24>
      ip->ref++;
80101008:	41                   	inc    %ecx
80101009:	89 48 08             	mov    %ecx,0x8(%eax)
      release(&icache.lock);
8010100c:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
80101013:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101016:	e8 49 2d 00 00       	call   80103d64 <release>
      return ip;
8010101b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);

  return ip;
}
8010101e:	83 c4 2c             	add    $0x2c,%esp
80101021:	5b                   	pop    %ebx
80101022:	5e                   	pop    %esi
80101023:	5f                   	pop    %edi
80101024:	5d                   	pop    %ebp
80101025:	c3                   	ret    
80101026:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101028:	85 c9                	test   %ecx,%ecx
8010102a:	75 c0                	jne    80100fec <iget+0x28>
8010102c:	89 c6                	mov    %eax,%esi

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010102e:	05 90 00 00 00       	add    $0x90,%eax
80101033:	3d 34 16 11 80       	cmp    $0x80111634,%eax
80101038:	72 be                	jb     80100ff8 <iget+0x34>
8010103a:	66 90                	xchg   %ax,%ax
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010103c:	85 f6                	test   %esi,%esi
8010103e:	74 29                	je     80101069 <iget+0xa5>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
80101040:	89 1e                	mov    %ebx,(%esi)
  ip->inum = inum;
80101042:	89 7e 04             	mov    %edi,0x4(%esi)
  ip->ref = 1;
80101045:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
8010104c:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
80101053:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
8010105a:	e8 05 2d 00 00       	call   80103d64 <release>

  return ip;
8010105f:	89 f0                	mov    %esi,%eax
}
80101061:	83 c4 2c             	add    $0x2c,%esp
80101064:	5b                   	pop    %ebx
80101065:	5e                   	pop    %esi
80101066:	5f                   	pop    %edi
80101067:	5d                   	pop    %ebp
80101068:	c3                   	ret    
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
    panic("iget: no inodes");
80101069:	c7 04 24 9f 65 10 80 	movl   $0x8010659f,(%esp)
80101070:	e8 a7 f2 ff ff       	call   8010031c <panic>
80101075:	8d 76 00             	lea    0x0(%esi),%esi

80101078 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
80101078:	55                   	push   %ebp
80101079:	89 e5                	mov    %esp,%ebp
8010107b:	57                   	push   %edi
8010107c:	56                   	push   %esi
8010107d:	53                   	push   %ebx
8010107e:	83 ec 1c             	sub    $0x1c,%esp
80101081:	89 d6                	mov    %edx,%esi
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
80101083:	c1 ea 0c             	shr    $0xc,%edx
80101086:	03 15 d8 f9 10 80    	add    0x8010f9d8,%edx
8010108c:	89 54 24 04          	mov    %edx,0x4(%esp)
80101090:	89 04 24             	mov    %eax,(%esp)
80101093:	e8 1c f0 ff ff       	call   801000b4 <bread>
80101098:	89 c7                	mov    %eax,%edi
  bi = b % BPB;
8010109a:	89 f3                	mov    %esi,%ebx
8010109c:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
  m = 1 << (bi % 8);
801010a2:	89 f1                	mov    %esi,%ecx
801010a4:	83 e1 07             	and    $0x7,%ecx
801010a7:	be 01 00 00 00       	mov    $0x1,%esi
801010ac:	d3 e6                	shl    %cl,%esi
  if((bp->data[bi/8] & m) == 0)
801010ae:	c1 fb 03             	sar    $0x3,%ebx
801010b1:	8a 54 18 5c          	mov    0x5c(%eax,%ebx,1),%dl
801010b5:	0f b6 c2             	movzbl %dl,%eax
801010b8:	85 f0                	test   %esi,%eax
801010ba:	74 22                	je     801010de <bfree+0x66>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
801010bc:	89 f0                	mov    %esi,%eax
801010be:	f7 d0                	not    %eax
801010c0:	21 d0                	and    %edx,%eax
801010c2:	88 44 1f 5c          	mov    %al,0x5c(%edi,%ebx,1)
  log_write(bp);
801010c6:	89 3c 24             	mov    %edi,(%esp)
801010c9:	e8 9a 18 00 00       	call   80102968 <log_write>
  brelse(bp);
801010ce:	89 3c 24             	mov    %edi,(%esp)
801010d1:	e8 d2 f0 ff ff       	call   801001a8 <brelse>
}
801010d6:	83 c4 1c             	add    $0x1c,%esp
801010d9:	5b                   	pop    %ebx
801010da:	5e                   	pop    %esi
801010db:	5f                   	pop    %edi
801010dc:	5d                   	pop    %ebp
801010dd:	c3                   	ret    

  bp = bread(dev, BBLOCK(b, sb));
  bi = b % BPB;
  m = 1 << (bi % 8);
  if((bp->data[bi/8] & m) == 0)
    panic("freeing free block");
801010de:	c7 04 24 af 65 10 80 	movl   $0x801065af,(%esp)
801010e5:	e8 32 f2 ff ff       	call   8010031c <panic>
801010ea:	66 90                	xchg   %ax,%ax

801010ec <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801010ec:	55                   	push   %ebp
801010ed:	89 e5                	mov    %esp,%ebp
801010ef:	57                   	push   %edi
801010f0:	56                   	push   %esi
801010f1:	53                   	push   %ebx
801010f2:	83 ec 3c             	sub    $0x3c,%esp
801010f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
801010f8:	a1 c0 f9 10 80       	mov    0x8010f9c0,%eax
801010fd:	85 c0                	test   %eax,%eax
801010ff:	0f 84 82 00 00 00    	je     80101187 <balloc+0x9b>
80101105:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
8010110c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010110f:	c1 f8 0c             	sar    $0xc,%eax
80101112:	03 05 d8 f9 10 80    	add    0x8010f9d8,%eax
80101118:	89 44 24 04          	mov    %eax,0x4(%esp)
8010111c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010111f:	89 04 24             	mov    %eax,(%esp)
80101122:	e8 8d ef ff ff       	call   801000b4 <bread>
80101127:	8b 15 c0 f9 10 80    	mov    0x8010f9c0,%edx
8010112d:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101130:	8b 5d dc             	mov    -0x24(%ebp),%ebx
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101133:	31 d2                	xor    %edx,%edx
80101135:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101138:	eb 2b                	jmp    80101165 <balloc+0x79>
8010113a:	66 90                	xchg   %ax,%ax
      m = 1 << (bi % 8);
8010113c:	89 d1                	mov    %edx,%ecx
8010113e:	83 e1 07             	and    $0x7,%ecx
80101141:	bf 01 00 00 00       	mov    $0x1,%edi
80101146:	d3 e7                	shl    %cl,%edi
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101148:	89 d1                	mov    %edx,%ecx
8010114a:	c1 f9 03             	sar    $0x3,%ecx
8010114d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80101150:	8a 44 0e 5c          	mov    0x5c(%esi,%ecx,1),%al
80101154:	0f b6 f0             	movzbl %al,%esi
80101157:	85 fe                	test   %edi,%esi
80101159:	74 39                	je     80101194 <balloc+0xa8>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010115b:	42                   	inc    %edx
8010115c:	43                   	inc    %ebx
8010115d:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
80101163:	74 05                	je     8010116a <balloc+0x7e>
80101165:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
80101168:	72 d2                	jb     8010113c <balloc+0x50>
8010116a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010116d:	89 04 24             	mov    %eax,(%esp)
80101170:	e8 33 f0 ff ff       	call   801001a8 <brelse>
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101175:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
8010117c:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010117f:	3b 15 c0 f9 10 80    	cmp    0x8010f9c0,%edx
80101185:	72 85                	jb     8010110c <balloc+0x20>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
80101187:	c7 04 24 c2 65 10 80 	movl   $0x801065c2,(%esp)
8010118e:	e8 89 f1 ff ff       	call   8010031c <panic>
80101193:	90                   	nop
80101194:	88 c2                	mov    %al,%dl
80101196:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
      m = 1 << (bi % 8);
      if((bp->data[bi/8] & m) == 0){  // Is block free?
        bp->data[bi/8] |= m;  // Mark block in use.
80101199:	09 fa                	or     %edi,%edx
8010119b:	88 54 08 5c          	mov    %dl,0x5c(%eax,%ecx,1)
        log_write(bp);
8010119f:	89 04 24             	mov    %eax,(%esp)
801011a2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801011a5:	e8 be 17 00 00       	call   80102968 <log_write>
        brelse(bp);
801011aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801011ad:	89 04 24             	mov    %eax,(%esp)
801011b0:	e8 f3 ef ff ff       	call   801001a8 <brelse>
static void
bzero(int dev, int bno)
{
  struct buf *bp;

  bp = bread(dev, bno);
801011b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801011b9:	8b 45 d8             	mov    -0x28(%ebp),%eax
801011bc:	89 04 24             	mov    %eax,(%esp)
801011bf:	e8 f0 ee ff ff       	call   801000b4 <bread>
801011c4:	89 c6                	mov    %eax,%esi
  memset(bp->data, 0, BSIZE);
801011c6:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801011cd:	00 
801011ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801011d5:	00 
801011d6:	8d 40 5c             	lea    0x5c(%eax),%eax
801011d9:	89 04 24             	mov    %eax,(%esp)
801011dc:	e8 cb 2b 00 00       	call   80103dac <memset>
  log_write(bp);
801011e1:	89 34 24             	mov    %esi,(%esp)
801011e4:	e8 7f 17 00 00       	call   80102968 <log_write>
  brelse(bp);
801011e9:	89 34 24             	mov    %esi,(%esp)
801011ec:	e8 b7 ef ff ff       	call   801001a8 <brelse>
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
}
801011f1:	89 d8                	mov    %ebx,%eax
801011f3:	83 c4 3c             	add    $0x3c,%esp
801011f6:	5b                   	pop    %ebx
801011f7:	5e                   	pop    %esi
801011f8:	5f                   	pop    %edi
801011f9:	5d                   	pop    %ebp
801011fa:	c3                   	ret    
801011fb:	90                   	nop

801011fc <bmap.part.0>:
// listed in block ip->addrs[NDIRECT].

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
801011fc:	55                   	push   %ebp
801011fd:	89 e5                	mov    %esp,%ebp
801011ff:	57                   	push   %edi
80101200:	56                   	push   %esi
80101201:	53                   	push   %ebx
80101202:	83 ec 2c             	sub    $0x2c,%esp
80101205:	89 c3                	mov    %eax,%ebx
  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101207:	8d 7a f4             	lea    -0xc(%edx),%edi

  if(bn < NINDIRECT){
8010120a:	83 ff 7f             	cmp    $0x7f,%edi
8010120d:	77 60                	ja     8010126f <bmap.part.0+0x73>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
8010120f:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101215:	85 c0                	test   %eax,%eax
80101217:	74 47                	je     80101260 <bmap.part.0+0x64>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
80101219:	89 44 24 04          	mov    %eax,0x4(%esp)
8010121d:	8b 03                	mov    (%ebx),%eax
8010121f:	89 04 24             	mov    %eax,(%esp)
80101222:	e8 8d ee ff ff       	call   801000b4 <bread>
80101227:	89 c6                	mov    %eax,%esi
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101229:	8d 7c b8 5c          	lea    0x5c(%eax,%edi,4),%edi
8010122d:	8b 07                	mov    (%edi),%eax
8010122f:	85 c0                	test   %eax,%eax
80101231:	75 17                	jne    8010124a <bmap.part.0+0x4e>
      a[bn] = addr = balloc(ip->dev);
80101233:	8b 03                	mov    (%ebx),%eax
80101235:	e8 b2 fe ff ff       	call   801010ec <balloc>
8010123a:	89 07                	mov    %eax,(%edi)
      log_write(bp);
8010123c:	89 34 24             	mov    %esi,(%esp)
8010123f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101242:	e8 21 17 00 00       	call   80102968 <log_write>
80101247:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
8010124a:	89 34 24             	mov    %esi,(%esp)
8010124d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101250:	e8 53 ef ff ff       	call   801001a8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
80101255:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101258:	83 c4 2c             	add    $0x2c,%esp
8010125b:	5b                   	pop    %ebx
8010125c:	5e                   	pop    %esi
8010125d:	5f                   	pop    %edi
8010125e:	5d                   	pop    %ebp
8010125f:	c3                   	ret    
  bn -= NDIRECT;

  if(bn < NINDIRECT){
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101260:	8b 03                	mov    (%ebx),%eax
80101262:	e8 85 fe ff ff       	call   801010ec <balloc>
80101267:	89 83 8c 00 00 00    	mov    %eax,0x8c(%ebx)
8010126d:	eb aa                	jmp    80101219 <bmap.part.0+0x1d>
    }
    brelse(bp);
    return addr;
  }

  panic("bmap: out of range");
8010126f:	c7 04 24 d8 65 10 80 	movl   $0x801065d8,(%esp)
80101276:	e8 a1 f0 ff ff       	call   8010031c <panic>
8010127b:	90                   	nop

8010127c <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
8010127c:	55                   	push   %ebp
8010127d:	89 e5                	mov    %esp,%ebp
8010127f:	56                   	push   %esi
80101280:	53                   	push   %ebx
80101281:	83 ec 10             	sub    $0x10,%esp
80101284:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct buf *bp;

  bp = bread(dev, 1);
80101287:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
8010128e:	00 
8010128f:	8b 45 08             	mov    0x8(%ebp),%eax
80101292:	89 04 24             	mov    %eax,(%esp)
80101295:	e8 1a ee ff ff       	call   801000b4 <bread>
8010129a:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010129c:	c7 44 24 08 1c 00 00 	movl   $0x1c,0x8(%esp)
801012a3:	00 
801012a4:	8d 40 5c             	lea    0x5c(%eax),%eax
801012a7:	89 44 24 04          	mov    %eax,0x4(%esp)
801012ab:	89 34 24             	mov    %esi,(%esp)
801012ae:	e8 89 2b 00 00       	call   80103e3c <memmove>
  brelse(bp);
801012b3:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801012b6:	83 c4 10             	add    $0x10,%esp
801012b9:	5b                   	pop    %ebx
801012ba:	5e                   	pop    %esi
801012bb:	5d                   	pop    %ebp
{
  struct buf *bp;

  bp = bread(dev, 1);
  memmove(sb, bp->data, sizeof(*sb));
  brelse(bp);
801012bc:	e9 e7 ee ff ff       	jmp    801001a8 <brelse>
801012c1:	8d 76 00             	lea    0x0(%esi),%esi

801012c4 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
801012c4:	55                   	push   %ebp
801012c5:	89 e5                	mov    %esp,%ebp
801012c7:	53                   	push   %ebx
801012c8:	83 ec 24             	sub    $0x24,%esp
  int i = 0;
  
  initlock(&icache.lock, "icache");
801012cb:	c7 44 24 04 eb 65 10 	movl   $0x801065eb,0x4(%esp)
801012d2:	80 
801012d3:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
801012da:	e8 e5 28 00 00       	call   80103bc4 <initlock>
  for(i = 0; i < NINODE; i++) {
801012df:	31 db                	xor    %ebx,%ebx
801012e1:	8d 76 00             	lea    0x0(%esi),%esi
    initsleeplock(&icache.inode[i].lock, "inode");
801012e4:	c7 44 24 04 f2 65 10 	movl   $0x801065f2,0x4(%esp)
801012eb:	80 
801012ec:	8d 04 db             	lea    (%ebx,%ebx,8),%eax
801012ef:	c1 e0 04             	shl    $0x4,%eax
801012f2:	05 20 fa 10 80       	add    $0x8010fa20,%eax
801012f7:	89 04 24             	mov    %eax,(%esp)
801012fa:	e8 b9 27 00 00       	call   80103ab8 <initsleeplock>
iinit(int dev)
{
  int i = 0;
  
  initlock(&icache.lock, "icache");
  for(i = 0; i < NINODE; i++) {
801012ff:	43                   	inc    %ebx
80101300:	83 fb 32             	cmp    $0x32,%ebx
80101303:	75 df                	jne    801012e4 <iinit+0x20>
    initsleeplock(&icache.inode[i].lock, "inode");
  }

  readsb(dev, &sb);
80101305:	c7 44 24 04 c0 f9 10 	movl   $0x8010f9c0,0x4(%esp)
8010130c:	80 
8010130d:	8b 45 08             	mov    0x8(%ebp),%eax
80101310:	89 04 24             	mov    %eax,(%esp)
80101313:	e8 64 ff ff ff       	call   8010127c <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101318:	a1 d8 f9 10 80       	mov    0x8010f9d8,%eax
8010131d:	89 44 24 1c          	mov    %eax,0x1c(%esp)
80101321:	a1 d4 f9 10 80       	mov    0x8010f9d4,%eax
80101326:	89 44 24 18          	mov    %eax,0x18(%esp)
8010132a:	a1 d0 f9 10 80       	mov    0x8010f9d0,%eax
8010132f:	89 44 24 14          	mov    %eax,0x14(%esp)
80101333:	a1 cc f9 10 80       	mov    0x8010f9cc,%eax
80101338:	89 44 24 10          	mov    %eax,0x10(%esp)
8010133c:	a1 c8 f9 10 80       	mov    0x8010f9c8,%eax
80101341:	89 44 24 0c          	mov    %eax,0xc(%esp)
80101345:	a1 c4 f9 10 80       	mov    0x8010f9c4,%eax
8010134a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010134e:	a1 c0 f9 10 80       	mov    0x8010f9c0,%eax
80101353:	89 44 24 04          	mov    %eax,0x4(%esp)
80101357:	c7 04 24 58 66 10 80 	movl   $0x80106658,(%esp)
8010135e:	e8 59 f2 ff ff       	call   801005bc <cprintf>
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101363:	83 c4 24             	add    $0x24,%esp
80101366:	5b                   	pop    %ebx
80101367:	5d                   	pop    %ebp
80101368:	c3                   	ret    
80101369:	8d 76 00             	lea    0x0(%esi),%esi

8010136c <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010136c:	55                   	push   %ebp
8010136d:	89 e5                	mov    %esp,%ebp
8010136f:	57                   	push   %edi
80101370:	56                   	push   %esi
80101371:	53                   	push   %ebx
80101372:	83 ec 2c             	sub    $0x2c,%esp
80101375:	8b 45 08             	mov    0x8(%ebp),%eax
80101378:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010137b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010137e:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101382:	83 3d c8 f9 10 80 01 	cmpl   $0x1,0x8010f9c8
80101389:	0f 86 94 00 00 00    	jbe    80101423 <ialloc+0xb7>
8010138f:	be 01 00 00 00       	mov    $0x1,%esi
80101394:	bb 01 00 00 00       	mov    $0x1,%ebx
80101399:	eb 14                	jmp    801013af <ialloc+0x43>
8010139b:	90                   	nop
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
8010139c:	89 3c 24             	mov    %edi,(%esp)
8010139f:	e8 04 ee ff ff       	call   801001a8 <brelse>
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801013a4:	43                   	inc    %ebx
801013a5:	89 de                	mov    %ebx,%esi
801013a7:	3b 1d c8 f9 10 80    	cmp    0x8010f9c8,%ebx
801013ad:	73 74                	jae    80101423 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801013af:	89 f0                	mov    %esi,%eax
801013b1:	c1 e8 03             	shr    $0x3,%eax
801013b4:	03 05 d4 f9 10 80    	add    0x8010f9d4,%eax
801013ba:	89 44 24 04          	mov    %eax,0x4(%esp)
801013be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801013c1:	89 04 24             	mov    %eax,(%esp)
801013c4:	e8 eb ec ff ff       	call   801000b4 <bread>
801013c9:	89 c7                	mov    %eax,%edi
    dip = (struct dinode*)bp->data + inum%IPB;
801013cb:	89 f0                	mov    %esi,%eax
801013cd:	83 e0 07             	and    $0x7,%eax
801013d0:	c1 e0 06             	shl    $0x6,%eax
801013d3:	8d 54 07 5c          	lea    0x5c(%edi,%eax,1),%edx
    if(dip->type == 0){  // a free inode
801013d7:	66 83 3a 00          	cmpw   $0x0,(%edx)
801013db:	75 bf                	jne    8010139c <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
801013dd:	c7 44 24 08 40 00 00 	movl   $0x40,0x8(%esp)
801013e4:	00 
801013e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801013ec:	00 
801013ed:	89 14 24             	mov    %edx,(%esp)
801013f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
801013f3:	e8 b4 29 00 00       	call   80103dac <memset>
      dip->type = type;
801013f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
801013fb:	66 8b 45 e2          	mov    -0x1e(%ebp),%ax
801013ff:	66 89 02             	mov    %ax,(%edx)
      log_write(bp);   // mark it allocated on the disk
80101402:	89 3c 24             	mov    %edi,(%esp)
80101405:	e8 5e 15 00 00       	call   80102968 <log_write>
      brelse(bp);
8010140a:	89 3c 24             	mov    %edi,(%esp)
8010140d:	e8 96 ed ff ff       	call   801001a8 <brelse>
      return iget(dev, inum);
80101412:	89 f2                	mov    %esi,%edx
80101414:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
}
80101417:	83 c4 2c             	add    $0x2c,%esp
8010141a:	5b                   	pop    %ebx
8010141b:	5e                   	pop    %esi
8010141c:	5f                   	pop    %edi
8010141d:	5d                   	pop    %ebp
    if(dip->type == 0){  // a free inode
      memset(dip, 0, sizeof(*dip));
      dip->type = type;
      log_write(bp);   // mark it allocated on the disk
      brelse(bp);
      return iget(dev, inum);
8010141e:	e9 a1 fb ff ff       	jmp    80100fc4 <iget>
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101423:	c7 04 24 f8 65 10 80 	movl   $0x801065f8,(%esp)
8010142a:	e8 ed ee ff ff       	call   8010031c <panic>
8010142f:	90                   	nop

80101430 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101430:	55                   	push   %ebp
80101431:	89 e5                	mov    %esp,%ebp
80101433:	56                   	push   %esi
80101434:	53                   	push   %ebx
80101435:	83 ec 10             	sub    $0x10,%esp
80101438:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010143b:	8b 43 04             	mov    0x4(%ebx),%eax
8010143e:	c1 e8 03             	shr    $0x3,%eax
80101441:	03 05 d4 f9 10 80    	add    0x8010f9d4,%eax
80101447:	89 44 24 04          	mov    %eax,0x4(%esp)
8010144b:	8b 03                	mov    (%ebx),%eax
8010144d:	89 04 24             	mov    %eax,(%esp)
80101450:	e8 5f ec ff ff       	call   801000b4 <bread>
80101455:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101457:	8b 43 04             	mov    0x4(%ebx),%eax
8010145a:	83 e0 07             	and    $0x7,%eax
8010145d:	c1 e0 06             	shl    $0x6,%eax
80101460:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101464:	8b 53 50             	mov    0x50(%ebx),%edx
80101467:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010146a:	66 8b 53 52          	mov    0x52(%ebx),%dx
8010146e:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101472:	8b 53 54             	mov    0x54(%ebx),%edx
80101475:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101479:	66 8b 53 56          	mov    0x56(%ebx),%dx
8010147d:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101481:	8b 53 58             	mov    0x58(%ebx),%edx
80101484:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101487:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
8010148e:	00 
8010148f:	83 c3 5c             	add    $0x5c,%ebx
80101492:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101496:	83 c0 0c             	add    $0xc,%eax
80101499:	89 04 24             	mov    %eax,(%esp)
8010149c:	e8 9b 29 00 00       	call   80103e3c <memmove>
  log_write(bp);
801014a1:	89 34 24             	mov    %esi,(%esp)
801014a4:	e8 bf 14 00 00       	call   80102968 <log_write>
  brelse(bp);
801014a9:	89 75 08             	mov    %esi,0x8(%ebp)
}
801014ac:	83 c4 10             	add    $0x10,%esp
801014af:	5b                   	pop    %ebx
801014b0:	5e                   	pop    %esi
801014b1:	5d                   	pop    %ebp
  dip->minor = ip->minor;
  dip->nlink = ip->nlink;
  dip->size = ip->size;
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
  log_write(bp);
  brelse(bp);
801014b2:	e9 f1 ec ff ff       	jmp    801001a8 <brelse>
801014b7:	90                   	nop

801014b8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801014b8:	55                   	push   %ebp
801014b9:	89 e5                	mov    %esp,%ebp
801014bb:	53                   	push   %ebx
801014bc:	83 ec 14             	sub    $0x14,%esp
801014bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
801014c2:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
801014c9:	e8 32 28 00 00       	call   80103d00 <acquire>
  ip->ref++;
801014ce:	ff 43 08             	incl   0x8(%ebx)
  release(&icache.lock);
801014d1:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
801014d8:	e8 87 28 00 00       	call   80103d64 <release>
  return ip;
}
801014dd:	89 d8                	mov    %ebx,%eax
801014df:	83 c4 14             	add    $0x14,%esp
801014e2:	5b                   	pop    %ebx
801014e3:	5d                   	pop    %ebp
801014e4:	c3                   	ret    
801014e5:	8d 76 00             	lea    0x0(%esi),%esi

801014e8 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801014e8:	55                   	push   %ebp
801014e9:	89 e5                	mov    %esp,%ebp
801014eb:	56                   	push   %esi
801014ec:	53                   	push   %ebx
801014ed:	83 ec 10             	sub    $0x10,%esp
801014f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801014f3:	85 db                	test   %ebx,%ebx
801014f5:	0f 84 b1 00 00 00    	je     801015ac <ilock+0xc4>
801014fb:	8b 4b 08             	mov    0x8(%ebx),%ecx
801014fe:	85 c9                	test   %ecx,%ecx
80101500:	0f 8e a6 00 00 00    	jle    801015ac <ilock+0xc4>
    panic("ilock");

  acquiresleep(&ip->lock);
80101506:	8d 43 0c             	lea    0xc(%ebx),%eax
80101509:	89 04 24             	mov    %eax,(%esp)
8010150c:	e8 df 25 00 00       	call   80103af0 <acquiresleep>

  if(ip->valid == 0){
80101511:	8b 53 4c             	mov    0x4c(%ebx),%edx
80101514:	85 d2                	test   %edx,%edx
80101516:	74 08                	je     80101520 <ilock+0x38>
    brelse(bp);
    ip->valid = 1;
    if(ip->type == 0)
      panic("ilock: no type");
  }
}
80101518:	83 c4 10             	add    $0x10,%esp
8010151b:	5b                   	pop    %ebx
8010151c:	5e                   	pop    %esi
8010151d:	5d                   	pop    %ebp
8010151e:	c3                   	ret    
8010151f:	90                   	nop
    panic("ilock");

  acquiresleep(&ip->lock);

  if(ip->valid == 0){
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101520:	8b 43 04             	mov    0x4(%ebx),%eax
80101523:	c1 e8 03             	shr    $0x3,%eax
80101526:	03 05 d4 f9 10 80    	add    0x8010f9d4,%eax
8010152c:	89 44 24 04          	mov    %eax,0x4(%esp)
80101530:	8b 03                	mov    (%ebx),%eax
80101532:	89 04 24             	mov    %eax,(%esp)
80101535:	e8 7a eb ff ff       	call   801000b4 <bread>
8010153a:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
8010153c:	8b 43 04             	mov    0x4(%ebx),%eax
8010153f:	83 e0 07             	and    $0x7,%eax
80101542:	c1 e0 06             	shl    $0x6,%eax
80101545:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
80101549:	8b 10                	mov    (%eax),%edx
8010154b:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
8010154f:	66 8b 50 02          	mov    0x2(%eax),%dx
80101553:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
80101557:	8b 50 04             	mov    0x4(%eax),%edx
8010155a:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
8010155e:	66 8b 50 06          	mov    0x6(%eax),%dx
80101562:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101566:	8b 50 08             	mov    0x8(%eax),%edx
80101569:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
8010156c:	c7 44 24 08 34 00 00 	movl   $0x34,0x8(%esp)
80101573:	00 
80101574:	83 c0 0c             	add    $0xc,%eax
80101577:	89 44 24 04          	mov    %eax,0x4(%esp)
8010157b:	8d 43 5c             	lea    0x5c(%ebx),%eax
8010157e:	89 04 24             	mov    %eax,(%esp)
80101581:	e8 b6 28 00 00       	call   80103e3c <memmove>
    brelse(bp);
80101586:	89 34 24             	mov    %esi,(%esp)
80101589:	e8 1a ec ff ff       	call   801001a8 <brelse>
    ip->valid = 1;
8010158e:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101595:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
8010159a:	0f 85 78 ff ff ff    	jne    80101518 <ilock+0x30>
      panic("ilock: no type");
801015a0:	c7 04 24 10 66 10 80 	movl   $0x80106610,(%esp)
801015a7:	e8 70 ed ff ff       	call   8010031c <panic>
{
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
    panic("ilock");
801015ac:	c7 04 24 0a 66 10 80 	movl   $0x8010660a,(%esp)
801015b3:	e8 64 ed ff ff       	call   8010031c <panic>

801015b8 <iunlock>:
}

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
801015b8:	55                   	push   %ebp
801015b9:	89 e5                	mov    %esp,%ebp
801015bb:	56                   	push   %esi
801015bc:	53                   	push   %ebx
801015bd:	83 ec 10             	sub    $0x10,%esp
801015c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
801015c3:	85 db                	test   %ebx,%ebx
801015c5:	74 24                	je     801015eb <iunlock+0x33>
801015c7:	8d 73 0c             	lea    0xc(%ebx),%esi
801015ca:	89 34 24             	mov    %esi,(%esp)
801015cd:	e8 aa 25 00 00       	call   80103b7c <holdingsleep>
801015d2:	85 c0                	test   %eax,%eax
801015d4:	74 15                	je     801015eb <iunlock+0x33>
801015d6:	8b 5b 08             	mov    0x8(%ebx),%ebx
801015d9:	85 db                	test   %ebx,%ebx
801015db:	7e 0e                	jle    801015eb <iunlock+0x33>
    panic("iunlock");

  releasesleep(&ip->lock);
801015dd:	89 75 08             	mov    %esi,0x8(%ebp)
}
801015e0:	83 c4 10             	add    $0x10,%esp
801015e3:	5b                   	pop    %ebx
801015e4:	5e                   	pop    %esi
801015e5:	5d                   	pop    %ebp
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");

  releasesleep(&ip->lock);
801015e6:	e9 55 25 00 00       	jmp    80103b40 <releasesleep>
// Unlock the given inode.
void
iunlock(struct inode *ip)
{
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    panic("iunlock");
801015eb:	c7 04 24 1f 66 10 80 	movl   $0x8010661f,(%esp)
801015f2:	e8 25 ed ff ff       	call   8010031c <panic>
801015f7:	90                   	nop

801015f8 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
801015f8:	55                   	push   %ebp
801015f9:	89 e5                	mov    %esp,%ebp
801015fb:	57                   	push   %edi
801015fc:	56                   	push   %esi
801015fd:	53                   	push   %ebx
801015fe:	83 ec 2c             	sub    $0x2c,%esp
80101601:	8b 75 08             	mov    0x8(%ebp),%esi
  acquiresleep(&ip->lock);
80101604:	8d 7e 0c             	lea    0xc(%esi),%edi
80101607:	89 3c 24             	mov    %edi,(%esp)
8010160a:	e8 e1 24 00 00       	call   80103af0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010160f:	8b 46 4c             	mov    0x4c(%esi),%eax
80101612:	85 c0                	test   %eax,%eax
80101614:	74 07                	je     8010161d <iput+0x25>
80101616:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
8010161b:	74 2b                	je     80101648 <iput+0x50>
      ip->type = 0;
      iupdate(ip);
      ip->valid = 0;
    }
  }
  releasesleep(&ip->lock);
8010161d:	89 3c 24             	mov    %edi,(%esp)
80101620:	e8 1b 25 00 00       	call   80103b40 <releasesleep>

  acquire(&icache.lock);
80101625:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
8010162c:	e8 cf 26 00 00       	call   80103d00 <acquire>
  ip->ref--;
80101631:	ff 4e 08             	decl   0x8(%esi)
  release(&icache.lock);
80101634:	c7 45 08 e0 f9 10 80 	movl   $0x8010f9e0,0x8(%ebp)
}
8010163b:	83 c4 2c             	add    $0x2c,%esp
8010163e:	5b                   	pop    %ebx
8010163f:	5e                   	pop    %esi
80101640:	5f                   	pop    %edi
80101641:	5d                   	pop    %ebp
  }
  releasesleep(&ip->lock);

  acquire(&icache.lock);
  ip->ref--;
  release(&icache.lock);
80101642:	e9 1d 27 00 00       	jmp    80103d64 <release>
80101647:	90                   	nop
void
iput(struct inode *ip)
{
  acquiresleep(&ip->lock);
  if(ip->valid && ip->nlink == 0){
    acquire(&icache.lock);
80101648:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
8010164f:	e8 ac 26 00 00       	call   80103d00 <acquire>
    int r = ip->ref;
80101654:	8b 5e 08             	mov    0x8(%esi),%ebx
    release(&icache.lock);
80101657:	c7 04 24 e0 f9 10 80 	movl   $0x8010f9e0,(%esp)
8010165e:	e8 01 27 00 00       	call   80103d64 <release>
    if(r == 1){
80101663:	4b                   	dec    %ebx
80101664:	75 b7                	jne    8010161d <iput+0x25>
80101666:	89 f3                	mov    %esi,%ebx
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
80101668:	8d 4e 30             	lea    0x30(%esi),%ecx
8010166b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010166e:	89 cf                	mov    %ecx,%edi
80101670:	eb 09                	jmp    8010167b <iput+0x83>
80101672:	66 90                	xchg   %ax,%ax
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
80101674:	83 c3 04             	add    $0x4,%ebx
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101677:	39 fb                	cmp    %edi,%ebx
80101679:	74 19                	je     80101694 <iput+0x9c>
    if(ip->addrs[i]){
8010167b:	8b 53 5c             	mov    0x5c(%ebx),%edx
8010167e:	85 d2                	test   %edx,%edx
80101680:	74 f2                	je     80101674 <iput+0x7c>
      bfree(ip->dev, ip->addrs[i]);
80101682:	8b 06                	mov    (%esi),%eax
80101684:	e8 ef f9 ff ff       	call   80101078 <bfree>
      ip->addrs[i] = 0;
80101689:	c7 43 5c 00 00 00 00 	movl   $0x0,0x5c(%ebx)
80101690:	eb e2                	jmp    80101674 <iput+0x7c>
80101692:	66 90                	xchg   %ax,%ax
80101694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
    }
  }

  if(ip->addrs[NDIRECT]){
80101697:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
8010169d:	85 c0                	test   %eax,%eax
8010169f:	75 2b                	jne    801016cc <iput+0xd4>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
801016a1:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801016a8:	89 34 24             	mov    %esi,(%esp)
801016ab:	e8 80 fd ff ff       	call   80101430 <iupdate>
    int r = ip->ref;
    release(&icache.lock);
    if(r == 1){
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
      ip->type = 0;
801016b0:	66 c7 46 50 00 00    	movw   $0x0,0x50(%esi)
      iupdate(ip);
801016b6:	89 34 24             	mov    %esi,(%esp)
801016b9:	e8 72 fd ff ff       	call   80101430 <iupdate>
      ip->valid = 0;
801016be:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
801016c5:	e9 53 ff ff ff       	jmp    8010161d <iput+0x25>
801016ca:	66 90                	xchg   %ax,%ax
      ip->addrs[i] = 0;
    }
  }

  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801016cc:	89 44 24 04          	mov    %eax,0x4(%esp)
801016d0:	8b 06                	mov    (%esi),%eax
801016d2:	89 04 24             	mov    %eax,(%esp)
801016d5:	e8 da e9 ff ff       	call   801000b4 <bread>
801016da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
801016dd:	89 c1                	mov    %eax,%ecx
801016df:	83 c1 5c             	add    $0x5c,%ecx
    for(j = 0; j < NINDIRECT; j++){
801016e2:	31 c0                	xor    %eax,%eax
801016e4:	31 db                	xor    %ebx,%ebx
801016e6:	89 7d e0             	mov    %edi,-0x20(%ebp)
801016e9:	89 f7                	mov    %esi,%edi
801016eb:	89 ce                	mov    %ecx,%esi
801016ed:	eb 0c                	jmp    801016fb <iput+0x103>
801016ef:	90                   	nop
801016f0:	43                   	inc    %ebx
801016f1:	89 d8                	mov    %ebx,%eax
801016f3:	81 fb 80 00 00 00    	cmp    $0x80,%ebx
801016f9:	74 10                	je     8010170b <iput+0x113>
      if(a[j])
801016fb:	8b 14 86             	mov    (%esi,%eax,4),%edx
801016fe:	85 d2                	test   %edx,%edx
80101700:	74 ee                	je     801016f0 <iput+0xf8>
        bfree(ip->dev, a[j]);
80101702:	8b 07                	mov    (%edi),%eax
80101704:	e8 6f f9 ff ff       	call   80101078 <bfree>
80101709:	eb e5                	jmp    801016f0 <iput+0xf8>
8010170b:	89 fe                	mov    %edi,%esi
8010170d:	8b 7d e0             	mov    -0x20(%ebp),%edi
    }
    brelse(bp);
80101710:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101713:	89 04 24             	mov    %eax,(%esp)
80101716:	e8 8d ea ff ff       	call   801001a8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
8010171b:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
80101721:	8b 06                	mov    (%esi),%eax
80101723:	e8 50 f9 ff ff       	call   80101078 <bfree>
    ip->addrs[NDIRECT] = 0;
80101728:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
8010172f:	00 00 00 
80101732:	e9 6a ff ff ff       	jmp    801016a1 <iput+0xa9>
80101737:	90                   	nop

80101738 <iunlockput>:
}

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101738:	55                   	push   %ebp
80101739:	89 e5                	mov    %esp,%ebp
8010173b:	53                   	push   %ebx
8010173c:	83 ec 14             	sub    $0x14,%esp
8010173f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101742:	89 1c 24             	mov    %ebx,(%esp)
80101745:	e8 6e fe ff ff       	call   801015b8 <iunlock>
  iput(ip);
8010174a:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010174d:	83 c4 14             	add    $0x14,%esp
80101750:	5b                   	pop    %ebx
80101751:	5d                   	pop    %ebp
// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
  iunlock(ip);
  iput(ip);
80101752:	e9 a1 fe ff ff       	jmp    801015f8 <iput>
80101757:	90                   	nop

80101758 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101758:	55                   	push   %ebp
80101759:	89 e5                	mov    %esp,%ebp
8010175b:	8b 55 08             	mov    0x8(%ebp),%edx
8010175e:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101761:	8b 0a                	mov    (%edx),%ecx
80101763:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101766:	8b 4a 04             	mov    0x4(%edx),%ecx
80101769:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010176c:	8b 4a 50             	mov    0x50(%edx),%ecx
8010176f:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101772:	66 8b 4a 56          	mov    0x56(%edx),%cx
80101776:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010177a:	8b 52 58             	mov    0x58(%edx),%edx
8010177d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101780:	5d                   	pop    %ebp
80101781:	c3                   	ret    
80101782:	66 90                	xchg   %ax,%ax

80101784 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101784:	55                   	push   %ebp
80101785:	89 e5                	mov    %esp,%ebp
80101787:	57                   	push   %edi
80101788:	56                   	push   %esi
80101789:	53                   	push   %ebx
8010178a:	83 ec 2c             	sub    $0x2c,%esp
8010178d:	8b 75 08             	mov    0x8(%ebp),%esi
80101790:	8b 45 0c             	mov    0xc(%ebp),%eax
80101793:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101796:	8b 5d 10             	mov    0x10(%ebp),%ebx
80101799:	8b 55 14             	mov    0x14(%ebp),%edx
8010179c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010179f:	66 83 7e 50 03       	cmpw   $0x3,0x50(%esi)
801017a4:	0f 84 da 00 00 00    	je     80101884 <readi+0x100>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
801017aa:	8b 46 58             	mov    0x58(%esi),%eax
801017ad:	39 d8                	cmp    %ebx,%eax
801017af:	0f 82 f3 00 00 00    	jb     801018a8 <readi+0x124>
801017b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
801017b8:	01 da                	add    %ebx,%edx
801017ba:	0f 82 e8 00 00 00    	jb     801018a8 <readi+0x124>
    return -1;
  if(off + n > ip->size)
801017c0:	39 d0                	cmp    %edx,%eax
801017c2:	0f 82 b0 00 00 00    	jb     80101878 <readi+0xf4>
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017c8:	8b 45 dc             	mov    -0x24(%ebp),%eax
801017cb:	85 c0                	test   %eax,%eax
801017cd:	0f 84 99 00 00 00    	je     8010186c <readi+0xe8>
801017d3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801017da:	eb 6a                	jmp    80101846 <readi+0xc2>
{
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
801017dc:	8d 7a 14             	lea    0x14(%edx),%edi
801017df:	8b 44 be 0c          	mov    0xc(%esi,%edi,4),%eax
801017e3:	85 c0                	test   %eax,%eax
801017e5:	74 75                	je     8010185c <readi+0xd8>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801017eb:	8b 06                	mov    (%esi),%eax
801017ed:	89 04 24             	mov    %eax,(%esp)
801017f0:	e8 bf e8 ff ff       	call   801000b4 <bread>
801017f5:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
801017f7:	89 d8                	mov    %ebx,%eax
801017f9:	25 ff 01 00 00       	and    $0x1ff,%eax
801017fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80101801:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
80101804:	bf 00 02 00 00       	mov    $0x200,%edi
80101809:	29 c7                	sub    %eax,%edi
8010180b:	39 cf                	cmp    %ecx,%edi
8010180d:	76 02                	jbe    80101811 <readi+0x8d>
8010180f:	89 cf                	mov    %ecx,%edi
    memmove(dst, bp->data + off%BSIZE, m);
80101811:	89 7c 24 08          	mov    %edi,0x8(%esp)
80101815:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
80101819:	89 44 24 04          	mov    %eax,0x4(%esp)
8010181d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101820:	89 04 24             	mov    %eax,(%esp)
80101823:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101826:	e8 11 26 00 00       	call   80103e3c <memmove>
    brelse(bp);
8010182b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010182e:	89 14 24             	mov    %edx,(%esp)
80101831:	e8 72 e9 ff ff       	call   801001a8 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101836:	01 7d e4             	add    %edi,-0x1c(%ebp)
80101839:	01 fb                	add    %edi,%ebx
8010183b:	01 7d e0             	add    %edi,-0x20(%ebp)
8010183e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101841:	39 55 dc             	cmp    %edx,-0x24(%ebp)
80101844:	76 26                	jbe    8010186c <readi+0xe8>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101846:	89 da                	mov    %ebx,%edx
80101848:	c1 ea 09             	shr    $0x9,%edx
bmap(struct inode *ip, uint bn)
{
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010184b:	83 fa 0b             	cmp    $0xb,%edx
8010184e:	76 8c                	jbe    801017dc <readi+0x58>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
80101850:	89 f0                	mov    %esi,%eax
80101852:	e8 a5 f9 ff ff       	call   801011fc <bmap.part.0>
80101857:	eb 8e                	jmp    801017e7 <readi+0x63>
80101859:	8d 76 00             	lea    0x0(%esi),%esi
8010185c:	8b 06                	mov    (%esi),%eax
8010185e:	e8 89 f8 ff ff       	call   801010ec <balloc>
80101863:	89 44 be 0c          	mov    %eax,0xc(%esi,%edi,4)
80101867:	e9 7b ff ff ff       	jmp    801017e7 <readi+0x63>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010186c:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
8010186f:	83 c4 2c             	add    $0x2c,%esp
80101872:	5b                   	pop    %ebx
80101873:	5e                   	pop    %esi
80101874:	5f                   	pop    %edi
80101875:	5d                   	pop    %ebp
80101876:	c3                   	ret    
80101877:	90                   	nop
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101878:	29 d8                	sub    %ebx,%eax
8010187a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010187d:	e9 46 ff ff ff       	jmp    801017c8 <readi+0x44>
80101882:	66 90                	xchg   %ax,%ax
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101884:	66 8b 46 52          	mov    0x52(%esi),%ax
80101888:	66 83 f8 09          	cmp    $0x9,%ax
8010188c:	77 1a                	ja     801018a8 <readi+0x124>
8010188e:	98                   	cwtl   
8010188f:	8b 04 c5 60 f9 10 80 	mov    -0x7fef06a0(,%eax,8),%eax
80101896:	85 c0                	test   %eax,%eax
80101898:	74 0e                	je     801018a8 <readi+0x124>
      return -1;
    return devsw[ip->major].read(ip, dst, n);
8010189a:	89 55 10             	mov    %edx,0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
}
8010189d:	83 c4 2c             	add    $0x2c,%esp
801018a0:	5b                   	pop    %ebx
801018a1:	5e                   	pop    %esi
801018a2:	5f                   	pop    %edi
801018a3:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
801018a4:	ff e0                	jmp    *%eax
801018a6:	66 90                	xchg   %ax,%ax
  }

  if(off > ip->size || off + n < off)
    return -1;
801018a8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801018ad:	eb c0                	jmp    8010186f <readi+0xeb>
801018af:	90                   	nop

801018b0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
801018b0:	55                   	push   %ebp
801018b1:	89 e5                	mov    %esp,%ebp
801018b3:	57                   	push   %edi
801018b4:	56                   	push   %esi
801018b5:	53                   	push   %ebx
801018b6:	83 ec 2c             	sub    $0x2c,%esp
801018b9:	8b 75 08             	mov    0x8(%ebp),%esi
801018bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801018bf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
801018c2:	8b 5d 10             	mov    0x10(%ebp),%ebx
801018c5:	8b 4d 14             	mov    0x14(%ebp),%ecx
801018c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
801018cb:	66 83 7e 50 03       	cmpw   $0x3,0x50(%esi)
801018d0:	0f 84 ea 00 00 00    	je     801019c0 <writei+0x110>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
801018d6:	39 5e 58             	cmp    %ebx,0x58(%esi)
801018d9:	0f 82 05 01 00 00    	jb     801019e4 <writei+0x134>
801018df:	8b 45 dc             	mov    -0x24(%ebp),%eax
801018e2:	01 d8                	add    %ebx,%eax
801018e4:	0f 82 fa 00 00 00    	jb     801019e4 <writei+0x134>
    return -1;
  if(off + n > MAXFILE*BSIZE)
801018ea:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018ef:	0f 87 ef 00 00 00    	ja     801019e4 <writei+0x134>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018f5:	8b 45 dc             	mov    -0x24(%ebp),%eax
801018f8:	85 c0                	test   %eax,%eax
801018fa:	0f 84 b4 00 00 00    	je     801019b4 <writei+0x104>
80101900:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101907:	eb 78                	jmp    80101981 <writei+0xd1>
80101909:	8d 76 00             	lea    0x0(%esi),%esi
{
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    if((addr = ip->addrs[bn]) == 0)
8010190c:	8d 7a 14             	lea    0x14(%edx),%edi
8010190f:	8b 44 be 0c          	mov    0xc(%esi,%edi,4),%eax
80101913:	85 c0                	test   %eax,%eax
80101915:	74 7d                	je     80101994 <writei+0xe4>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101917:	89 44 24 04          	mov    %eax,0x4(%esp)
8010191b:	8b 06                	mov    (%esi),%eax
8010191d:	89 04 24             	mov    %eax,(%esp)
80101920:	e8 8f e7 ff ff       	call   801000b4 <bread>
80101925:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101927:	89 d8                	mov    %ebx,%eax
80101929:	25 ff 01 00 00       	and    $0x1ff,%eax
8010192e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80101931:	2b 4d e4             	sub    -0x1c(%ebp),%ecx
80101934:	bf 00 02 00 00       	mov    $0x200,%edi
80101939:	29 c7                	sub    %eax,%edi
8010193b:	39 cf                	cmp    %ecx,%edi
8010193d:	76 02                	jbe    80101941 <writei+0x91>
8010193f:	89 cf                	mov    %ecx,%edi
    memmove(bp->data + off%BSIZE, src, m);
80101941:	89 7c 24 08          	mov    %edi,0x8(%esp)
80101945:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80101948:	89 4c 24 04          	mov    %ecx,0x4(%esp)
8010194c:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
80101950:	89 04 24             	mov    %eax,(%esp)
80101953:	89 55 d8             	mov    %edx,-0x28(%ebp)
80101956:	e8 e1 24 00 00       	call   80103e3c <memmove>
    log_write(bp);
8010195b:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010195e:	89 14 24             	mov    %edx,(%esp)
80101961:	e8 02 10 00 00       	call   80102968 <log_write>
    brelse(bp);
80101966:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101969:	89 14 24             	mov    %edx,(%esp)
8010196c:	e8 37 e8 ff ff       	call   801001a8 <brelse>
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101971:	01 7d e4             	add    %edi,-0x1c(%ebp)
80101974:	01 fb                	add    %edi,%ebx
80101976:	01 7d e0             	add    %edi,-0x20(%ebp)
80101979:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010197c:	39 4d dc             	cmp    %ecx,-0x24(%ebp)
8010197f:	76 23                	jbe    801019a4 <writei+0xf4>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101981:	89 da                	mov    %ebx,%edx
80101983:	c1 ea 09             	shr    $0x9,%edx
bmap(struct inode *ip, uint bn)
{
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101986:	83 fa 0b             	cmp    $0xb,%edx
80101989:	76 81                	jbe    8010190c <writei+0x5c>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
8010198b:	89 f0                	mov    %esi,%eax
8010198d:	e8 6a f8 ff ff       	call   801011fc <bmap.part.0>
80101992:	eb 83                	jmp    80101917 <writei+0x67>
80101994:	8b 06                	mov    (%esi),%eax
80101996:	e8 51 f7 ff ff       	call   801010ec <balloc>
8010199b:	89 44 be 0c          	mov    %eax,0xc(%esi,%edi,4)
8010199f:	e9 73 ff ff ff       	jmp    80101917 <writei+0x67>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
801019a4:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019a7:	73 0b                	jae    801019b4 <writei+0x104>
    ip->size = off;
801019a9:	89 5e 58             	mov    %ebx,0x58(%esi)
    iupdate(ip);
801019ac:	89 34 24             	mov    %esi,(%esp)
801019af:	e8 7c fa ff ff       	call   80101430 <iupdate>
  }
  return n;
801019b4:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801019b7:	83 c4 2c             	add    $0x2c,%esp
801019ba:	5b                   	pop    %ebx
801019bb:	5e                   	pop    %esi
801019bc:	5f                   	pop    %edi
801019bd:	5d                   	pop    %ebp
801019be:	c3                   	ret    
801019bf:	90                   	nop
{
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801019c0:	66 8b 46 52          	mov    0x52(%esi),%ax
801019c4:	66 83 f8 09          	cmp    $0x9,%ax
801019c8:	77 1a                	ja     801019e4 <writei+0x134>
801019ca:	98                   	cwtl   
801019cb:	8b 04 c5 64 f9 10 80 	mov    -0x7fef069c(,%eax,8),%eax
801019d2:	85 c0                	test   %eax,%eax
801019d4:	74 0e                	je     801019e4 <writei+0x134>
      return -1;
    return devsw[ip->major].write(ip, src, n);
801019d6:	89 4d 10             	mov    %ecx,0x10(%ebp)
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
801019d9:	83 c4 2c             	add    $0x2c,%esp
801019dc:	5b                   	pop    %ebx
801019dd:	5e                   	pop    %esi
801019de:	5f                   	pop    %edi
801019df:	5d                   	pop    %ebp
  struct buf *bp;

  if(ip->type == T_DEV){
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
801019e0:	ff e0                	jmp    *%eax
801019e2:	66 90                	xchg   %ax,%ax
  }

  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;
801019e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(n > 0 && off > ip->size){
    ip->size = off;
    iupdate(ip);
  }
  return n;
}
801019e9:	83 c4 2c             	add    $0x2c,%esp
801019ec:	5b                   	pop    %ebx
801019ed:	5e                   	pop    %esi
801019ee:	5f                   	pop    %edi
801019ef:	5d                   	pop    %ebp
801019f0:	c3                   	ret    
801019f1:	8d 76 00             	lea    0x0(%esi),%esi

801019f4 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801019f4:	55                   	push   %ebp
801019f5:	89 e5                	mov    %esp,%ebp
801019f7:	83 ec 18             	sub    $0x18,%esp
  return strncmp(s, t, DIRSIZ);
801019fa:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101a01:	00 
80101a02:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a05:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a09:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0c:	89 04 24             	mov    %eax,(%esp)
80101a0f:	e8 88 24 00 00       	call   80103e9c <strncmp>
}
80101a14:	c9                   	leave  
80101a15:	c3                   	ret    
80101a16:	66 90                	xchg   %ax,%ax

80101a18 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101a18:	55                   	push   %ebp
80101a19:	89 e5                	mov    %esp,%ebp
80101a1b:	57                   	push   %edi
80101a1c:	56                   	push   %esi
80101a1d:	53                   	push   %ebx
80101a1e:	83 ec 2c             	sub    $0x2c,%esp
80101a21:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101a24:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101a29:	0f 85 8b 00 00 00    	jne    80101aba <dirlookup+0xa2>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101a2f:	8b 43 58             	mov    0x58(%ebx),%eax
80101a32:	85 c0                	test   %eax,%eax
80101a34:	74 6e                	je     80101aa4 <dirlookup+0x8c>
80101a36:	31 f6                	xor    %esi,%esi
80101a38:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101a3b:	eb 0b                	jmp    80101a48 <dirlookup+0x30>
80101a3d:	8d 76 00             	lea    0x0(%esi),%esi
80101a40:	83 c6 10             	add    $0x10,%esi
80101a43:	39 73 58             	cmp    %esi,0x58(%ebx)
80101a46:	76 5c                	jbe    80101aa4 <dirlookup+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101a48:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101a4f:	00 
80101a50:	89 74 24 08          	mov    %esi,0x8(%esp)
80101a54:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101a58:	89 1c 24             	mov    %ebx,(%esp)
80101a5b:	e8 24 fd ff ff       	call   80101784 <readi>
80101a60:	83 f8 10             	cmp    $0x10,%eax
80101a63:	75 49                	jne    80101aae <dirlookup+0x96>
      panic("dirlookup read");
    if(de.inum == 0)
80101a65:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a6a:	74 d4                	je     80101a40 <dirlookup+0x28>
      continue;
    if(namecmp(name, de.name) == 0){
80101a6c:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a6f:	89 44 24 04          	mov    %eax,0x4(%esp)
80101a73:	8b 45 0c             	mov    0xc(%ebp),%eax
80101a76:	89 04 24             	mov    %eax,(%esp)
80101a79:	e8 76 ff ff ff       	call   801019f4 <namecmp>
80101a7e:	85 c0                	test   %eax,%eax
80101a80:	75 be                	jne    80101a40 <dirlookup+0x28>
      // entry matches path element
      if(poff)
80101a82:	8b 45 10             	mov    0x10(%ebp),%eax
80101a85:	85 c0                	test   %eax,%eax
80101a87:	74 05                	je     80101a8e <dirlookup+0x76>
        *poff = off;
80101a89:	8b 45 10             	mov    0x10(%ebp),%eax
80101a8c:	89 30                	mov    %esi,(%eax)
      inum = de.inum;
80101a8e:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a92:	8b 03                	mov    (%ebx),%eax
80101a94:	e8 2b f5 ff ff       	call   80100fc4 <iget>
    }
  }

  return 0;
}
80101a99:	83 c4 2c             	add    $0x2c,%esp
80101a9c:	5b                   	pop    %ebx
80101a9d:	5e                   	pop    %esi
80101a9e:	5f                   	pop    %edi
80101a9f:	5d                   	pop    %ebp
80101aa0:	c3                   	ret    
80101aa1:	8d 76 00             	lea    0x0(%esi),%esi
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80101aa4:	31 c0                	xor    %eax,%eax
}
80101aa6:	83 c4 2c             	add    $0x2c,%esp
80101aa9:	5b                   	pop    %ebx
80101aaa:	5e                   	pop    %esi
80101aab:	5f                   	pop    %edi
80101aac:	5d                   	pop    %ebp
80101aad:	c3                   	ret    
  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlookup read");
80101aae:	c7 04 24 39 66 10 80 	movl   $0x80106639,(%esp)
80101ab5:	e8 62 e8 ff ff       	call   8010031c <panic>
{
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");
80101aba:	c7 04 24 27 66 10 80 	movl   $0x80106627,(%esp)
80101ac1:	e8 56 e8 ff ff       	call   8010031c <panic>
80101ac6:	66 90                	xchg   %ax,%ax

80101ac8 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101ac8:	55                   	push   %ebp
80101ac9:	89 e5                	mov    %esp,%ebp
80101acb:	57                   	push   %edi
80101acc:	56                   	push   %esi
80101acd:	53                   	push   %ebx
80101ace:	83 ec 2c             	sub    $0x2c,%esp
80101ad1:	89 c3                	mov    %eax,%ebx
80101ad3:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ad6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101ad9:	80 38 2f             	cmpb   $0x2f,(%eax)
80101adc:	0f 84 01 01 00 00    	je     80101be3 <namex+0x11b>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101ae2:	e8 c9 17 00 00       	call   801032b0 <myproc>
80101ae7:	8b 40 68             	mov    0x68(%eax),%eax
80101aea:	89 04 24             	mov    %eax,(%esp)
80101aed:	e8 c6 f9 ff ff       	call   801014b8 <idup>
80101af2:	89 c7                	mov    %eax,%edi
80101af4:	eb 03                	jmp    80101af9 <namex+0x31>
80101af6:	66 90                	xchg   %ax,%ax
{
  char *s;
  int len;

  while(*path == '/')
    path++;
80101af8:	43                   	inc    %ebx
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80101af9:	8a 03                	mov    (%ebx),%al
80101afb:	3c 2f                	cmp    $0x2f,%al
80101afd:	74 f9                	je     80101af8 <namex+0x30>
    path++;
  if(*path == 0)
80101aff:	84 c0                	test   %al,%al
80101b01:	75 15                	jne    80101b18 <namex+0x50>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101b03:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101b06:	85 c0                	test   %eax,%eax
80101b08:	0f 85 22 01 00 00    	jne    80101c30 <namex+0x168>
    iput(ip);
    return 0;
  }
  return ip;
}
80101b0e:	89 f8                	mov    %edi,%eax
80101b10:	83 c4 2c             	add    $0x2c,%esp
80101b13:	5b                   	pop    %ebx
80101b14:	5e                   	pop    %esi
80101b15:	5f                   	pop    %edi
80101b16:	5d                   	pop    %ebp
80101b17:	c3                   	ret    
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101b18:	8a 03                	mov    (%ebx),%al
80101b1a:	89 de                	mov    %ebx,%esi
80101b1c:	3c 2f                	cmp    $0x2f,%al
80101b1e:	0f 84 95 00 00 00    	je     80101bb9 <namex+0xf1>
80101b24:	84 c0                	test   %al,%al
80101b26:	75 0c                	jne    80101b34 <namex+0x6c>
80101b28:	e9 8c 00 00 00       	jmp    80101bb9 <namex+0xf1>
80101b2d:	8d 76 00             	lea    0x0(%esi),%esi
80101b30:	84 c0                	test   %al,%al
80101b32:	74 07                	je     80101b3b <namex+0x73>
    path++;
80101b34:	46                   	inc    %esi
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101b35:	8a 06                	mov    (%esi),%al
80101b37:	3c 2f                	cmp    $0x2f,%al
80101b39:	75 f5                	jne    80101b30 <namex+0x68>
80101b3b:	89 f2                	mov    %esi,%edx
80101b3d:	29 da                	sub    %ebx,%edx
    path++;
  len = path - s;
  if(len >= DIRSIZ)
80101b3f:	83 fa 0d             	cmp    $0xd,%edx
80101b42:	7e 78                	jle    80101bbc <namex+0xf4>
    memmove(name, s, DIRSIZ);
80101b44:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101b4b:	00 
80101b4c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101b50:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101b53:	89 04 24             	mov    %eax,(%esp)
80101b56:	e8 e1 22 00 00       	call   80103e3c <memmove>
80101b5b:	89 f3                	mov    %esi,%ebx
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101b5d:	80 3e 2f             	cmpb   $0x2f,(%esi)
80101b60:	75 08                	jne    80101b6a <namex+0xa2>
80101b62:	66 90                	xchg   %ax,%ax
    path++;
80101b64:	43                   	inc    %ebx
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80101b65:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101b68:	74 fa                	je     80101b64 <namex+0x9c>
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
80101b6a:	85 db                	test   %ebx,%ebx
80101b6c:	74 95                	je     80101b03 <namex+0x3b>
    ilock(ip);
80101b6e:	89 3c 24             	mov    %edi,(%esp)
80101b71:	e8 72 f9 ff ff       	call   801014e8 <ilock>
    if(ip->type != T_DIR){
80101b76:	66 83 7f 50 01       	cmpw   $0x1,0x50(%edi)
80101b7b:	75 7c                	jne    80101bf9 <namex+0x131>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101b7d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101b80:	85 d2                	test   %edx,%edx
80101b82:	74 09                	je     80101b8d <namex+0xc5>
80101b84:	80 3b 00             	cmpb   $0x0,(%ebx)
80101b87:	0f 84 91 00 00 00    	je     80101c1e <namex+0x156>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101b8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101b94:	00 
80101b95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101b98:	89 44 24 04          	mov    %eax,0x4(%esp)
80101b9c:	89 3c 24             	mov    %edi,(%esp)
80101b9f:	e8 74 fe ff ff       	call   80101a18 <dirlookup>
80101ba4:	89 c6                	mov    %eax,%esi
      iunlockput(ip);
80101ba6:	89 3c 24             	mov    %edi,(%esp)
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101ba9:	85 c0                	test   %eax,%eax
80101bab:	74 60                	je     80101c0d <namex+0x145>
      iunlockput(ip);
      return 0;
    }
    iunlockput(ip);
80101bad:	e8 86 fb ff ff       	call   80101738 <iunlockput>
    ip = next;
80101bb2:	89 f7                	mov    %esi,%edi
80101bb4:	e9 40 ff ff ff       	jmp    80101af9 <namex+0x31>
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80101bb9:	31 d2                	xor    %edx,%edx
80101bbb:	90                   	nop
    path++;
  len = path - s;
  if(len >= DIRSIZ)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
80101bbc:	89 54 24 08          	mov    %edx,0x8(%esp)
80101bc0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80101bc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101bc7:	89 04 24             	mov    %eax,(%esp)
80101bca:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101bcd:	e8 6a 22 00 00       	call   80103e3c <memmove>
    name[len] = 0;
80101bd2:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101bd5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101bd8:	c6 04 10 00          	movb   $0x0,(%eax,%edx,1)
80101bdc:	89 f3                	mov    %esi,%ebx
80101bde:	e9 7a ff ff ff       	jmp    80101b5d <namex+0x95>
namex(char *path, int nameiparent, char *name)
{
  struct inode *ip, *next;

  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
80101be3:	ba 01 00 00 00       	mov    $0x1,%edx
80101be8:	b8 01 00 00 00       	mov    $0x1,%eax
80101bed:	e8 d2 f3 ff ff       	call   80100fc4 <iget>
80101bf2:	89 c7                	mov    %eax,%edi
80101bf4:	e9 00 ff ff ff       	jmp    80101af9 <namex+0x31>
    ip = idup(myproc()->cwd);

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101bf9:	89 3c 24             	mov    %edi,(%esp)
80101bfc:	e8 37 fb ff ff       	call   80101738 <iunlockput>
      return 0;
80101c01:	31 ff                	xor    %edi,%edi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101c03:	89 f8                	mov    %edi,%eax
80101c05:	83 c4 2c             	add    $0x2c,%esp
80101c08:	5b                   	pop    %ebx
80101c09:	5e                   	pop    %esi
80101c0a:	5f                   	pop    %edi
80101c0b:	5d                   	pop    %ebp
80101c0c:	c3                   	ret    
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
      iunlockput(ip);
80101c0d:	e8 26 fb ff ff       	call   80101738 <iunlockput>
      return 0;
80101c12:	31 ff                	xor    %edi,%edi
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101c14:	89 f8                	mov    %edi,%eax
80101c16:	83 c4 2c             	add    $0x2c,%esp
80101c19:	5b                   	pop    %ebx
80101c1a:	5e                   	pop    %esi
80101c1b:	5f                   	pop    %edi
80101c1c:	5d                   	pop    %ebp
80101c1d:	c3                   	ret    
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
      // Stop one level early.
      iunlock(ip);
80101c1e:	89 3c 24             	mov    %edi,(%esp)
80101c21:	e8 92 f9 ff ff       	call   801015b8 <iunlock>
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101c26:	89 f8                	mov    %edi,%eax
80101c28:	83 c4 2c             	add    $0x2c,%esp
80101c2b:	5b                   	pop    %ebx
80101c2c:	5e                   	pop    %esi
80101c2d:	5f                   	pop    %edi
80101c2e:	5d                   	pop    %ebp
80101c2f:	c3                   	ret    
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
    iput(ip);
80101c30:	89 3c 24             	mov    %edi,(%esp)
80101c33:	e8 c0 f9 ff ff       	call   801015f8 <iput>
    return 0;
80101c38:	31 ff                	xor    %edi,%edi
80101c3a:	e9 cf fe ff ff       	jmp    80101b0e <namex+0x46>
80101c3f:	90                   	nop

80101c40 <dirlink>:
}

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80101c40:	55                   	push   %ebp
80101c41:	89 e5                	mov    %esp,%ebp
80101c43:	57                   	push   %edi
80101c44:	56                   	push   %esi
80101c45:	53                   	push   %ebx
80101c46:	83 ec 2c             	sub    $0x2c,%esp
80101c49:	8b 75 08             	mov    0x8(%ebp),%esi
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80101c4c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80101c53:	00 
80101c54:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c57:	89 44 24 04          	mov    %eax,0x4(%esp)
80101c5b:	89 34 24             	mov    %esi,(%esp)
80101c5e:	e8 b5 fd ff ff       	call   80101a18 <dirlookup>
80101c63:	85 c0                	test   %eax,%eax
80101c65:	0f 85 85 00 00 00    	jne    80101cf0 <dirlink+0xb0>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80101c6b:	31 db                	xor    %ebx,%ebx
80101c6d:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101c70:	8b 4e 58             	mov    0x58(%esi),%ecx
80101c73:	85 c9                	test   %ecx,%ecx
80101c75:	75 0d                	jne    80101c84 <dirlink+0x44>
80101c77:	eb 2f                	jmp    80101ca8 <dirlink+0x68>
80101c79:	8d 76 00             	lea    0x0(%esi),%esi
80101c7c:	83 c3 10             	add    $0x10,%ebx
80101c7f:	39 5e 58             	cmp    %ebx,0x58(%esi)
80101c82:	76 24                	jbe    80101ca8 <dirlink+0x68>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101c84:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101c8b:	00 
80101c8c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101c90:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101c94:	89 34 24             	mov    %esi,(%esp)
80101c97:	e8 e8 fa ff ff       	call   80101784 <readi>
80101c9c:	83 f8 10             	cmp    $0x10,%eax
80101c9f:	75 5e                	jne    80101cff <dirlink+0xbf>
      panic("dirlink read");
    if(de.inum == 0)
80101ca1:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101ca6:	75 d4                	jne    80101c7c <dirlink+0x3c>
      break;
  }

  strncpy(de.name, name, DIRSIZ);
80101ca8:	c7 44 24 08 0e 00 00 	movl   $0xe,0x8(%esp)
80101caf:	00 
80101cb0:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cb3:	89 44 24 04          	mov    %eax,0x4(%esp)
80101cb7:	8d 45 da             	lea    -0x26(%ebp),%eax
80101cba:	89 04 24             	mov    %eax,(%esp)
80101cbd:	e8 3a 22 00 00       	call   80103efc <strncpy>
  de.inum = inum;
80101cc2:	8b 45 10             	mov    0x10(%ebp),%eax
80101cc5:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101cc9:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80101cd0:	00 
80101cd1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80101cd5:	89 7c 24 04          	mov    %edi,0x4(%esp)
80101cd9:	89 34 24             	mov    %esi,(%esp)
80101cdc:	e8 cf fb ff ff       	call   801018b0 <writei>
80101ce1:	83 f8 10             	cmp    $0x10,%eax
80101ce4:	75 25                	jne    80101d0b <dirlink+0xcb>
    panic("dirlink");

  return 0;
80101ce6:	31 c0                	xor    %eax,%eax
}
80101ce8:	83 c4 2c             	add    $0x2c,%esp
80101ceb:	5b                   	pop    %ebx
80101cec:	5e                   	pop    %esi
80101ced:	5f                   	pop    %edi
80101cee:	5d                   	pop    %ebp
80101cef:	c3                   	ret    
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
    iput(ip);
80101cf0:	89 04 24             	mov    %eax,(%esp)
80101cf3:	e8 00 f9 ff ff       	call   801015f8 <iput>
    return -1;
80101cf8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cfd:	eb e9                	jmp    80101ce8 <dirlink+0xa8>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
80101cff:	c7 04 24 48 66 10 80 	movl   $0x80106648,(%esp)
80101d06:	e8 11 e6 ff ff       	call   8010031c <panic>
  }

  strncpy(de.name, name, DIRSIZ);
  de.inum = inum;
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("dirlink");
80101d0b:	c7 04 24 1e 6c 10 80 	movl   $0x80106c1e,(%esp)
80101d12:	e8 05 e6 ff ff       	call   8010031c <panic>
80101d17:	90                   	nop

80101d18 <namei>:
  return ip;
}

struct inode*
namei(char *path)
{
80101d18:	55                   	push   %ebp
80101d19:	89 e5                	mov    %esp,%ebp
80101d1b:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101d1e:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101d21:	31 d2                	xor    %edx,%edx
80101d23:	8b 45 08             	mov    0x8(%ebp),%eax
80101d26:	e8 9d fd ff ff       	call   80101ac8 <namex>
}
80101d2b:	c9                   	leave  
80101d2c:	c3                   	ret    
80101d2d:	8d 76 00             	lea    0x0(%esi),%esi

80101d30 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101d30:	55                   	push   %ebp
80101d31:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
80101d33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101d36:	ba 01 00 00 00       	mov    $0x1,%edx
80101d3b:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101d3e:	5d                   	pop    %ebp
}

struct inode*
nameiparent(char *path, char *name)
{
  return namex(path, 1, name);
80101d3f:	e9 84 fd ff ff       	jmp    80101ac8 <namex>

80101d44 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101d44:	55                   	push   %ebp
80101d45:	89 e5                	mov    %esp,%ebp
80101d47:	56                   	push   %esi
80101d48:	53                   	push   %ebx
80101d49:	83 ec 10             	sub    $0x10,%esp
80101d4c:	89 c6                	mov    %eax,%esi
  if(b == 0)
80101d4e:	85 c0                	test   %eax,%eax
80101d50:	0f 84 8e 00 00 00    	je     80101de4 <idestart+0xa0>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101d56:	8b 48 08             	mov    0x8(%eax),%ecx
80101d59:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d5f:	77 77                	ja     80101dd8 <idestart+0x94>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d61:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d66:	66 90                	xchg   %ax,%ax
80101d68:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101d69:	25 c0 00 00 00       	and    $0xc0,%eax
80101d6e:	83 f8 40             	cmp    $0x40,%eax
80101d71:	75 f5                	jne    80101d68 <idestart+0x24>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d73:	31 db                	xor    %ebx,%ebx
80101d75:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101d7a:	88 d8                	mov    %bl,%al
80101d7c:	ee                   	out    %al,(%dx)
80101d7d:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101d82:	b0 01                	mov    $0x1,%al
80101d84:	ee                   	out    %al,(%dx)
80101d85:	b2 f3                	mov    $0xf3,%dl
80101d87:	88 c8                	mov    %cl,%al
80101d89:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101d8a:	89 c8                	mov    %ecx,%eax
80101d8c:	c1 f8 08             	sar    $0x8,%eax
80101d8f:	b2 f4                	mov    $0xf4,%dl
80101d91:	ee                   	out    %al,(%dx)
80101d92:	b2 f5                	mov    $0xf5,%dl
80101d94:	88 d8                	mov    %bl,%al
80101d96:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101d97:	8b 46 04             	mov    0x4(%esi),%eax
80101d9a:	83 e0 01             	and    $0x1,%eax
80101d9d:	c1 e0 04             	shl    $0x4,%eax
80101da0:	83 c8 e0             	or     $0xffffffe0,%eax
80101da3:	b2 f6                	mov    $0xf6,%dl
80101da5:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101da6:	f6 06 04             	testb  $0x4,(%esi)
80101da9:	75 11                	jne    80101dbc <idestart+0x78>
80101dab:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101db0:	b0 20                	mov    $0x20,%al
80101db2:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101db3:	83 c4 10             	add    $0x10,%esp
80101db6:	5b                   	pop    %ebx
80101db7:	5e                   	pop    %esi
80101db8:	5d                   	pop    %ebp
80101db9:	c3                   	ret    
80101dba:	66 90                	xchg   %ax,%ax
80101dbc:	b2 f7                	mov    $0xf7,%dl
80101dbe:	b0 30                	mov    $0x30,%al
80101dc0:	ee                   	out    %al,(%dx)
  outb(0x1f4, (sector >> 8) & 0xff);
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
80101dc1:	83 c6 5c             	add    $0x5c,%esi
}

static inline void
outsl(int port, const void *addr, int cnt)
{
  asm volatile("cld; rep outsl" :
80101dc4:	b9 80 00 00 00       	mov    $0x80,%ecx
80101dc9:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101dce:	fc                   	cld    
80101dcf:	f3 6f                	rep outsl %ds:(%esi),(%dx)
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101dd1:	83 c4 10             	add    $0x10,%esp
80101dd4:	5b                   	pop    %ebx
80101dd5:	5e                   	pop    %esi
80101dd6:	5d                   	pop    %ebp
80101dd7:	c3                   	ret    
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
  if(b->blockno >= FSSIZE)
    panic("incorrect blockno");
80101dd8:	c7 04 24 b4 66 10 80 	movl   $0x801066b4,(%esp)
80101ddf:	e8 38 e5 ff ff       	call   8010031c <panic>
// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
  if(b == 0)
    panic("idestart");
80101de4:	c7 04 24 ab 66 10 80 	movl   $0x801066ab,(%esp)
80101deb:	e8 2c e5 ff ff       	call   8010031c <panic>

80101df0 <ideinit>:
  return 0;
}

void
ideinit(void)
{
80101df0:	55                   	push   %ebp
80101df1:	89 e5                	mov    %esp,%ebp
80101df3:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
80101df6:	c7 44 24 04 c6 66 10 	movl   $0x801066c6,0x4(%esp)
80101dfd:	80 
80101dfe:	c7 04 24 60 95 10 80 	movl   $0x80109560,(%esp)
80101e05:	e8 ba 1d 00 00       	call   80103bc4 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101e0a:	a1 00 1d 11 80       	mov    0x80111d00,%eax
80101e0f:	48                   	dec    %eax
80101e10:	89 44 24 04          	mov    %eax,0x4(%esp)
80101e14:	c7 04 24 0e 00 00 00 	movl   $0xe,(%esp)
80101e1b:	e8 44 02 00 00       	call   80102064 <ioapicenable>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e20:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101e25:	8d 76 00             	lea    0x0(%esi),%esi
80101e28:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101e29:	25 c0 00 00 00       	and    $0xc0,%eax
80101e2e:	83 f8 40             	cmp    $0x40,%eax
80101e31:	75 f5                	jne    80101e28 <ideinit+0x38>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e33:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101e38:	b0 f0                	mov    $0xf0,%al
80101e3a:	ee                   	out    %al,(%dx)
80101e3b:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101e40:	b2 f7                	mov    $0xf7,%dl
80101e42:	eb 03                	jmp    80101e47 <ideinit+0x57>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);

  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80101e44:	49                   	dec    %ecx
80101e45:	74 0f                	je     80101e56 <ideinit+0x66>
80101e47:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101e48:	84 c0                	test   %al,%al
80101e4a:	74 f8                	je     80101e44 <ideinit+0x54>
      havedisk1 = 1;
80101e4c:	c7 05 94 95 10 80 01 	movl   $0x1,0x80109594
80101e53:	00 00 00 
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101e56:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101e5b:	b0 e0                	mov    $0xe0,%al
80101e5d:	ee                   	out    %al,(%dx)
    }
  }

  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
}
80101e5e:	c9                   	leave  
80101e5f:	c3                   	ret    

80101e60 <ideintr>:
}

// Interrupt handler.
void
ideintr(void)
{
80101e60:	55                   	push   %ebp
80101e61:	89 e5                	mov    %esp,%ebp
80101e63:	57                   	push   %edi
80101e64:	53                   	push   %ebx
80101e65:	83 ec 10             	sub    $0x10,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101e68:	c7 04 24 60 95 10 80 	movl   $0x80109560,(%esp)
80101e6f:	e8 8c 1e 00 00       	call   80103d00 <acquire>

  if((b = idequeue) == 0){
80101e74:	8b 1d 98 95 10 80    	mov    0x80109598,%ebx
80101e7a:	85 db                	test   %ebx,%ebx
80101e7c:	74 2d                	je     80101eab <ideintr+0x4b>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101e7e:	8b 43 58             	mov    0x58(%ebx),%eax
80101e81:	a3 98 95 10 80       	mov    %eax,0x80109598

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101e86:	8b 0b                	mov    (%ebx),%ecx
80101e88:	f6 c1 04             	test   $0x4,%cl
80101e8b:	74 33                	je     80101ec0 <ideintr+0x60>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101e8d:	83 c9 02             	or     $0x2,%ecx
  b->flags &= ~B_DIRTY;
80101e90:	83 e1 fb             	and    $0xfffffffb,%ecx
80101e93:	89 0b                	mov    %ecx,(%ebx)
  wakeup(b);
80101e95:	89 1c 24             	mov    %ebx,(%esp)
80101e98:	e8 93 1a 00 00       	call   80103930 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101e9d:	a1 98 95 10 80       	mov    0x80109598,%eax
80101ea2:	85 c0                	test   %eax,%eax
80101ea4:	74 05                	je     80101eab <ideintr+0x4b>
    idestart(idequeue);
80101ea6:	e8 99 fe ff ff       	call   80101d44 <idestart>

  release(&idelock);
80101eab:	c7 04 24 60 95 10 80 	movl   $0x80109560,(%esp)
80101eb2:	e8 ad 1e 00 00       	call   80103d64 <release>
}
80101eb7:	83 c4 10             	add    $0x10,%esp
80101eba:	5b                   	pop    %ebx
80101ebb:	5f                   	pop    %edi
80101ebc:	5d                   	pop    %ebp
80101ebd:	c3                   	ret    
80101ebe:	66 90                	xchg   %ax,%ax
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101ec0:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ec5:	8d 76 00             	lea    0x0(%esi),%esi
80101ec8:	ec                   	in     (%dx),%al
static int
idewait(int checkerr)
{
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101ec9:	0f b6 c0             	movzbl %al,%eax
80101ecc:	89 c7                	mov    %eax,%edi
80101ece:	81 e7 c0 00 00 00    	and    $0xc0,%edi
80101ed4:	83 ff 40             	cmp    $0x40,%edi
80101ed7:	75 ef                	jne    80101ec8 <ideintr+0x68>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101ed9:	a8 21                	test   $0x21,%al
80101edb:	75 b0                	jne    80101e8d <ideintr+0x2d>
  }
  idequeue = b->qnext;

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
    insl(0x1f0, b->data, BSIZE/4);
80101edd:	8d 7b 5c             	lea    0x5c(%ebx),%edi
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
80101ee0:	b9 80 00 00 00       	mov    $0x80,%ecx
80101ee5:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101eea:	fc                   	cld    
80101eeb:	f3 6d                	rep insl (%dx),%es:(%edi)
80101eed:	8b 0b                	mov    (%ebx),%ecx
80101eef:	eb 9c                	jmp    80101e8d <ideintr+0x2d>
80101ef1:	8d 76 00             	lea    0x0(%esi),%esi

80101ef4 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101ef4:	55                   	push   %ebp
80101ef5:	89 e5                	mov    %esp,%ebp
80101ef7:	53                   	push   %ebx
80101ef8:	83 ec 14             	sub    $0x14,%esp
80101efb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101efe:	8d 43 0c             	lea    0xc(%ebx),%eax
80101f01:	89 04 24             	mov    %eax,(%esp)
80101f04:	e8 73 1c 00 00       	call   80103b7c <holdingsleep>
80101f09:	85 c0                	test   %eax,%eax
80101f0b:	0f 84 8e 00 00 00    	je     80101f9f <iderw+0xab>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101f11:	8b 03                	mov    (%ebx),%eax
80101f13:	83 e0 06             	and    $0x6,%eax
80101f16:	83 f8 02             	cmp    $0x2,%eax
80101f19:	0f 84 98 00 00 00    	je     80101fb7 <iderw+0xc3>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101f1f:	8b 53 04             	mov    0x4(%ebx),%edx
80101f22:	85 d2                	test   %edx,%edx
80101f24:	74 09                	je     80101f2f <iderw+0x3b>
80101f26:	a1 94 95 10 80       	mov    0x80109594,%eax
80101f2b:	85 c0                	test   %eax,%eax
80101f2d:	74 7c                	je     80101fab <iderw+0xb7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101f2f:	c7 04 24 60 95 10 80 	movl   $0x80109560,(%esp)
80101f36:	e8 c5 1d 00 00       	call   80103d00 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101f3b:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101f42:	a1 98 95 10 80       	mov    0x80109598,%eax
80101f47:	85 c0                	test   %eax,%eax
80101f49:	74 44                	je     80101f8f <iderw+0x9b>
80101f4b:	90                   	nop
80101f4c:	8d 50 58             	lea    0x58(%eax),%edx
80101f4f:	8b 40 58             	mov    0x58(%eax),%eax
80101f52:	85 c0                	test   %eax,%eax
80101f54:	75 f6                	jne    80101f4c <iderw+0x58>
    ;
  *pp = b;
80101f56:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101f58:	39 1d 98 95 10 80    	cmp    %ebx,0x80109598
80101f5e:	75 14                	jne    80101f74 <iderw+0x80>
80101f60:	eb 34                	jmp    80101f96 <iderw+0xa2>
80101f62:	66 90                	xchg   %ax,%ax
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101f64:	c7 44 24 04 60 95 10 	movl   $0x80109560,0x4(%esp)
80101f6b:	80 
80101f6c:	89 1c 24             	mov    %ebx,(%esp)
80101f6f:	e8 40 18 00 00       	call   801037b4 <sleep>
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101f74:	8b 03                	mov    (%ebx),%eax
80101f76:	83 e0 06             	and    $0x6,%eax
80101f79:	83 f8 02             	cmp    $0x2,%eax
80101f7c:	75 e6                	jne    80101f64 <iderw+0x70>
    sleep(b, &idelock);
  }


  release(&idelock);
80101f7e:	c7 45 08 60 95 10 80 	movl   $0x80109560,0x8(%ebp)
}
80101f85:	83 c4 14             	add    $0x14,%esp
80101f88:	5b                   	pop    %ebx
80101f89:	5d                   	pop    %ebp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
  }


  release(&idelock);
80101f8a:	e9 d5 1d 00 00       	jmp    80103d64 <release>

  acquire(&idelock);  //DOC:acquire-lock

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101f8f:	ba 98 95 10 80       	mov    $0x80109598,%edx
80101f94:	eb c0                	jmp    80101f56 <iderw+0x62>
    ;
  *pp = b;

  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
80101f96:	89 d8                	mov    %ebx,%eax
80101f98:	e8 a7 fd ff ff       	call   80101d44 <idestart>
80101f9d:	eb d5                	jmp    80101f74 <iderw+0x80>
iderw(struct buf *b)
{
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
80101f9f:	c7 04 24 ca 66 10 80 	movl   $0x801066ca,(%esp)
80101fa6:	e8 71 e3 ff ff       	call   8010031c <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
    panic("iderw: ide disk 1 not present");
80101fab:	c7 04 24 f5 66 10 80 	movl   $0x801066f5,(%esp)
80101fb2:	e8 65 e3 ff ff       	call   8010031c <panic>
  struct buf **pp;

  if(!holdingsleep(&b->lock))
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
    panic("iderw: nothing to do");
80101fb7:	c7 04 24 e0 66 10 80 	movl   $0x801066e0,(%esp)
80101fbe:	e8 59 e3 ff ff       	call   8010031c <panic>
	...

80101fc4 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80101fc4:	55                   	push   %ebp
80101fc5:	89 e5                	mov    %esp,%ebp
80101fc7:	56                   	push   %esi
80101fc8:	53                   	push   %ebx
80101fc9:	83 ec 10             	sub    $0x10,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101fcc:	c7 05 34 16 11 80 00 	movl   $0xfec00000,0x80111634
80101fd3:	00 c0 fe 
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101fd6:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
80101fdd:	00 00 00 
  return ioapic->data;
80101fe0:	8b 35 10 00 c0 fe    	mov    0xfec00010,%esi
ioapicinit(void)
{
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101fe6:	c1 ee 10             	shr    $0x10,%esi
80101fe9:	81 e6 ff 00 00 00    	and    $0xff,%esi
};

static uint
ioapicread(int reg)
{
  ioapic->reg = reg;
80101fef:	c7 05 00 00 c0 fe 00 	movl   $0x0,0xfec00000
80101ff6:	00 00 00 
  return ioapic->data;
80101ff9:	bb 00 00 c0 fe       	mov    $0xfec00000,%ebx
80101ffe:	a1 10 00 c0 fe       	mov    0xfec00010,%eax
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
80102003:	0f b6 15 60 17 11 80 	movzbl 0x80111760,%edx
{
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
8010200a:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
8010200d:	39 c2                	cmp    %eax,%edx
8010200f:	74 12                	je     80102023 <ioapicinit+0x5f>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102011:	c7 04 24 14 67 10 80 	movl   $0x80106714,(%esp)
80102018:	e8 9f e5 ff ff       	call   801005bc <cprintf>
8010201d:	8b 1d 34 16 11 80    	mov    0x80111634,%ebx
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102023:	ba 10 00 00 00       	mov    $0x10,%edx
80102028:	31 c0                	xor    %eax,%eax
8010202a:	66 90                	xchg   %ax,%ax
  ioapic->reg = reg;
  ioapic->data = data;
}

void
ioapicinit(void)
8010202c:	8d 48 20             	lea    0x20(%eax),%ecx
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010202f:	81 c9 00 00 01 00    	or     $0x10000,%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102035:	89 13                	mov    %edx,(%ebx)
  ioapic->data = data;
80102037:	8b 1d 34 16 11 80    	mov    0x80111634,%ebx
8010203d:	89 4b 10             	mov    %ecx,0x10(%ebx)
}

void
ioapicinit(void)
80102040:	8d 4a 01             	lea    0x1(%edx),%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102043:	89 0b                	mov    %ecx,(%ebx)
  ioapic->data = data;
80102045:	8b 1d 34 16 11 80    	mov    0x80111634,%ebx
8010204b:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102052:	40                   	inc    %eax
80102053:	83 c2 02             	add    $0x2,%edx
80102056:	39 c6                	cmp    %eax,%esi
80102058:	7d d2                	jge    8010202c <ioapicinit+0x68>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010205a:	83 c4 10             	add    $0x10,%esp
8010205d:	5b                   	pop    %ebx
8010205e:	5e                   	pop    %esi
8010205f:	5d                   	pop    %ebp
80102060:	c3                   	ret    
80102061:	8d 76 00             	lea    0x0(%esi),%esi

80102064 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102064:	55                   	push   %ebp
80102065:	89 e5                	mov    %esp,%ebp
80102067:	53                   	push   %ebx
80102068:	8b 55 08             	mov    0x8(%ebp),%edx
8010206b:	8b 45 0c             	mov    0xc(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010206e:	8d 5a 20             	lea    0x20(%edx),%ebx
80102071:	8d 4c 12 10          	lea    0x10(%edx,%edx,1),%ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
80102075:	8b 15 34 16 11 80    	mov    0x80111634,%edx
8010207b:	89 0a                	mov    %ecx,(%edx)
  ioapic->data = data;
8010207d:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80102083:	89 5a 10             	mov    %ebx,0x10(%edx)
{
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102086:	c1 e0 18             	shl    $0x18,%eax
80102089:	41                   	inc    %ecx
}

static void
ioapicwrite(int reg, uint data)
{
  ioapic->reg = reg;
8010208a:	89 0a                	mov    %ecx,(%edx)
  ioapic->data = data;
8010208c:	8b 15 34 16 11 80    	mov    0x80111634,%edx
80102092:	89 42 10             	mov    %eax,0x10(%edx)
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102095:	5b                   	pop    %ebx
80102096:	5d                   	pop    %ebp
80102097:	c3                   	ret    

80102098 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102098:	55                   	push   %ebp
80102099:	89 e5                	mov    %esp,%ebp
8010209b:	53                   	push   %ebx
8010209c:	83 ec 14             	sub    $0x14,%esp
8010209f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801020a2:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801020a8:	75 78                	jne    80102122 <kfree+0x8a>
801020aa:	81 fb a8 44 11 80    	cmp    $0x801144a8,%ebx
801020b0:	72 70                	jb     80102122 <kfree+0x8a>
801020b2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801020b8:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801020bd:	77 63                	ja     80102122 <kfree+0x8a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801020bf:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801020c6:	00 
801020c7:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
801020ce:	00 
801020cf:	89 1c 24             	mov    %ebx,(%esp)
801020d2:	e8 d5 1c 00 00       	call   80103dac <memset>

  if(kmem.use_lock)
801020d7:	8b 15 74 16 11 80    	mov    0x80111674,%edx
801020dd:	85 d2                	test   %edx,%edx
801020df:	75 33                	jne    80102114 <kfree+0x7c>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
801020e1:	a1 78 16 11 80       	mov    0x80111678,%eax
801020e6:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
801020e8:	89 1d 78 16 11 80    	mov    %ebx,0x80111678
  if(kmem.use_lock)
801020ee:	a1 74 16 11 80       	mov    0x80111674,%eax
801020f3:	85 c0                	test   %eax,%eax
801020f5:	75 09                	jne    80102100 <kfree+0x68>
    release(&kmem.lock);
}
801020f7:	83 c4 14             	add    $0x14,%esp
801020fa:	5b                   	pop    %ebx
801020fb:	5d                   	pop    %ebp
801020fc:	c3                   	ret    
801020fd:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if(kmem.use_lock)
    release(&kmem.lock);
80102100:	c7 45 08 40 16 11 80 	movl   $0x80111640,0x8(%ebp)
}
80102107:	83 c4 14             	add    $0x14,%esp
8010210a:	5b                   	pop    %ebx
8010210b:	5d                   	pop    %ebp
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if(kmem.use_lock)
    release(&kmem.lock);
8010210c:	e9 53 1c 00 00       	jmp    80103d64 <release>
80102111:	8d 76 00             	lea    0x0(%esi),%esi

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);

  if(kmem.use_lock)
    acquire(&kmem.lock);
80102114:	c7 04 24 40 16 11 80 	movl   $0x80111640,(%esp)
8010211b:	e8 e0 1b 00 00       	call   80103d00 <acquire>
80102120:	eb bf                	jmp    801020e1 <kfree+0x49>
kfree(char *v)
{
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");
80102122:	c7 04 24 46 67 10 80 	movl   $0x80106746,(%esp)
80102129:	e8 ee e1 ff ff       	call   8010031c <panic>
8010212e:	66 90                	xchg   %ax,%ax

80102130 <freerange>:
  kmem.use_lock = 1;
}

void
freerange(void *vstart, void *vend)
{
80102130:	55                   	push   %ebp
80102131:	89 e5                	mov    %esp,%ebp
80102133:	56                   	push   %esi
80102134:	53                   	push   %ebx
80102135:	83 ec 10             	sub    $0x10,%esp
80102138:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
8010213b:	8b 55 08             	mov    0x8(%ebp),%edx
8010213e:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
80102144:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010214a:	8d 9a 00 10 00 00    	lea    0x1000(%edx),%ebx
80102150:	39 de                	cmp    %ebx,%esi
80102152:	73 08                	jae    8010215c <freerange+0x2c>
80102154:	eb 18                	jmp    8010216e <freerange+0x3e>
80102156:	66 90                	xchg   %ax,%ax
80102158:	89 da                	mov    %ebx,%edx
8010215a:	89 c3                	mov    %eax,%ebx
    kfree(p);
8010215c:	89 14 24             	mov    %edx,(%esp)
8010215f:	e8 34 ff ff ff       	call   80102098 <kfree>
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102164:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
8010216a:	39 f0                	cmp    %esi,%eax
8010216c:	76 ea                	jbe    80102158 <freerange+0x28>
    kfree(p);
}
8010216e:	83 c4 10             	add    $0x10,%esp
80102171:	5b                   	pop    %ebx
80102172:	5e                   	pop    %esi
80102173:	5d                   	pop    %ebp
80102174:	c3                   	ret    
80102175:	8d 76 00             	lea    0x0(%esi),%esi

80102178 <kinit2>:
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
80102178:	55                   	push   %ebp
80102179:	89 e5                	mov    %esp,%ebp
8010217b:	83 ec 18             	sub    $0x18,%esp
  freerange(vstart, vend);
8010217e:	8b 45 0c             	mov    0xc(%ebp),%eax
80102181:	89 44 24 04          	mov    %eax,0x4(%esp)
80102185:	8b 45 08             	mov    0x8(%ebp),%eax
80102188:	89 04 24             	mov    %eax,(%esp)
8010218b:	e8 a0 ff ff ff       	call   80102130 <freerange>
  kmem.use_lock = 1;
80102190:	c7 05 74 16 11 80 01 	movl   $0x1,0x80111674
80102197:	00 00 00 
}
8010219a:	c9                   	leave  
8010219b:	c3                   	ret    

8010219c <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
8010219c:	55                   	push   %ebp
8010219d:	89 e5                	mov    %esp,%ebp
8010219f:	56                   	push   %esi
801021a0:	53                   	push   %ebx
801021a1:	83 ec 10             	sub    $0x10,%esp
801021a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
801021a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
801021aa:	c7 44 24 04 4c 67 10 	movl   $0x8010674c,0x4(%esp)
801021b1:	80 
801021b2:	c7 04 24 40 16 11 80 	movl   $0x80111640,(%esp)
801021b9:	e8 06 1a 00 00       	call   80103bc4 <initlock>
  kmem.use_lock = 0;
801021be:	c7 05 74 16 11 80 00 	movl   $0x0,0x80111674
801021c5:	00 00 00 
  freerange(vstart, vend);
801021c8:	89 75 0c             	mov    %esi,0xc(%ebp)
801021cb:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801021ce:	83 c4 10             	add    $0x10,%esp
801021d1:	5b                   	pop    %ebx
801021d2:	5e                   	pop    %esi
801021d3:	5d                   	pop    %ebp
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
801021d4:	e9 57 ff ff ff       	jmp    80102130 <freerange>
801021d9:	8d 76 00             	lea    0x0(%esi),%esi

801021dc <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801021dc:	55                   	push   %ebp
801021dd:	89 e5                	mov    %esp,%ebp
801021df:	83 ec 28             	sub    $0x28,%esp
  struct run *r;

  if(kmem.use_lock)
801021e2:	8b 0d 74 16 11 80    	mov    0x80111674,%ecx
801021e8:	85 c9                	test   %ecx,%ecx
801021ea:	75 30                	jne    8010221c <kalloc+0x40>
801021ec:	31 d2                	xor    %edx,%edx
    acquire(&kmem.lock);
  r = kmem.freelist;
801021ee:	a1 78 16 11 80       	mov    0x80111678,%eax
  if(r)
801021f3:	85 c0                	test   %eax,%eax
801021f5:	74 08                	je     801021ff <kalloc+0x23>
    kmem.freelist = r->next;
801021f7:	8b 08                	mov    (%eax),%ecx
801021f9:	89 0d 78 16 11 80    	mov    %ecx,0x80111678
  if(kmem.use_lock)
801021ff:	85 d2                	test   %edx,%edx
80102201:	75 05                	jne    80102208 <kalloc+0x2c>
    release(&kmem.lock);
  return (char*)r;
}
80102203:	c9                   	leave  
80102204:	c3                   	ret    
80102205:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  if(kmem.use_lock)
    release(&kmem.lock);
80102208:	c7 04 24 40 16 11 80 	movl   $0x80111640,(%esp)
8010220f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102212:	e8 4d 1b 00 00       	call   80103d64 <release>
80102217:	8b 45 f4             	mov    -0xc(%ebp),%eax
  return (char*)r;
}
8010221a:	c9                   	leave  
8010221b:	c3                   	ret    
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
8010221c:	c7 04 24 40 16 11 80 	movl   $0x80111640,(%esp)
80102223:	e8 d8 1a 00 00       	call   80103d00 <acquire>
80102228:	8b 15 74 16 11 80    	mov    0x80111674,%edx
8010222e:	eb be                	jmp    801021ee <kalloc+0x12>

80102230 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102230:	55                   	push   %ebp
80102231:	89 e5                	mov    %esp,%ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102233:	ba 64 00 00 00       	mov    $0x64,%edx
80102238:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102239:	a8 01                	test   $0x1,%al
8010223b:	0f 84 a3 00 00 00    	je     801022e4 <kbdgetc+0xb4>
80102241:	b2 60                	mov    $0x60,%dl
80102243:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102244:	0f b6 c0             	movzbl %al,%eax

  if(data == 0xE0){
80102247:	3d e0 00 00 00       	cmp    $0xe0,%eax
8010224c:	74 7a                	je     801022c8 <kbdgetc+0x98>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
8010224e:	a8 80                	test   $0x80,%al
80102250:	74 2a                	je     8010227c <kbdgetc+0x4c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102252:	8b 15 9c 95 10 80    	mov    0x8010959c,%edx
80102258:	f6 c2 40             	test   $0x40,%dl
8010225b:	75 03                	jne    80102260 <kbdgetc+0x30>
8010225d:	83 e0 7f             	and    $0x7f,%eax
    shift &= ~(shiftcode[data] | E0ESC);
80102260:	8a 80 60 67 10 80    	mov    -0x7fef98a0(%eax),%al
80102266:	83 c8 40             	or     $0x40,%eax
80102269:	0f b6 c0             	movzbl %al,%eax
8010226c:	f7 d0                	not    %eax
8010226e:	21 d0                	and    %edx,%eax
80102270:	a3 9c 95 10 80       	mov    %eax,0x8010959c
    return 0;
80102275:	31 c0                	xor    %eax,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102277:	5d                   	pop    %ebp
80102278:	c3                   	ret    
80102279:	8d 76 00             	lea    0x0(%esi),%esi
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010227c:	8b 0d 9c 95 10 80    	mov    0x8010959c,%ecx
80102282:	f6 c1 40             	test   $0x40,%cl
80102285:	74 05                	je     8010228c <kbdgetc+0x5c>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102287:	0c 80                	or     $0x80,%al
    shift &= ~E0ESC;
80102289:	83 e1 bf             	and    $0xffffffbf,%ecx
  }

  shift |= shiftcode[data];
8010228c:	0f b6 90 60 67 10 80 	movzbl -0x7fef98a0(%eax),%edx
80102293:	09 ca                	or     %ecx,%edx
  shift ^= togglecode[data];
80102295:	0f b6 88 60 68 10 80 	movzbl -0x7fef97a0(%eax),%ecx
8010229c:	31 ca                	xor    %ecx,%edx
8010229e:	89 15 9c 95 10 80    	mov    %edx,0x8010959c
  c = charcode[shift & (CTL | SHIFT)][data];
801022a4:	89 d1                	mov    %edx,%ecx
801022a6:	83 e1 03             	and    $0x3,%ecx
801022a9:	8b 0c 8d 60 69 10 80 	mov    -0x7fef96a0(,%ecx,4),%ecx
801022b0:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
  if(shift & CAPSLOCK){
801022b4:	83 e2 08             	and    $0x8,%edx
801022b7:	74 be                	je     80102277 <kbdgetc+0x47>
    if('a' <= c && c <= 'z')
801022b9:	8d 50 9f             	lea    -0x61(%eax),%edx
801022bc:	83 fa 19             	cmp    $0x19,%edx
801022bf:	77 13                	ja     801022d4 <kbdgetc+0xa4>
      c += 'A' - 'a';
801022c1:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801022c4:	5d                   	pop    %ebp
801022c5:	c3                   	ret    
801022c6:	66 90                	xchg   %ax,%ax
  if((st & KBS_DIB) == 0)
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
801022c8:	83 0d 9c 95 10 80 40 	orl    $0x40,0x8010959c
    return 0;
801022cf:	30 c0                	xor    %al,%al
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801022d1:	5d                   	pop    %ebp
801022d2:	c3                   	ret    
801022d3:	90                   	nop
  shift ^= togglecode[data];
  c = charcode[shift & (CTL | SHIFT)][data];
  if(shift & CAPSLOCK){
    if('a' <= c && c <= 'z')
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
801022d4:	8d 50 bf             	lea    -0x41(%eax),%edx
801022d7:	83 fa 19             	cmp    $0x19,%edx
801022da:	77 9b                	ja     80102277 <kbdgetc+0x47>
      c += 'a' - 'A';
801022dc:	83 c0 20             	add    $0x20,%eax
  }
  return c;
}
801022df:	5d                   	pop    %ebp
801022e0:	c3                   	ret    
801022e1:	8d 76 00             	lea    0x0(%esi),%esi
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
    return -1;
801022e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      c += 'A' - 'a';
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801022e9:	5d                   	pop    %ebp
801022ea:	c3                   	ret    
801022eb:	90                   	nop

801022ec <kbdintr>:

void
kbdintr(void)
{
801022ec:	55                   	push   %ebp
801022ed:	89 e5                	mov    %esp,%ebp
801022ef:	83 ec 18             	sub    $0x18,%esp
  consoleintr(kbdgetc);
801022f2:	c7 04 24 30 22 10 80 	movl   $0x80102230,(%esp)
801022f9:	e8 fe e3 ff ff       	call   801006fc <consoleintr>
}
801022fe:	c9                   	leave  
801022ff:	c3                   	ret    

80102300 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(void)
{
80102300:	55                   	push   %ebp
80102301:	89 e5                	mov    %esp,%ebp
  if(!lapic)
80102303:	a1 7c 16 11 80       	mov    0x8011167c,%eax
80102308:	85 c0                	test   %eax,%eax
8010230a:	0f 84 c0 00 00 00    	je     801023d0 <lapicinit+0xd0>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102310:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102317:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010231a:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010231d:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102324:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102327:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010232a:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
80102331:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102334:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102337:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010233e:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
80102341:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102344:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
8010234b:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010234e:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102351:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102358:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010235b:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010235e:	8b 50 30             	mov    0x30(%eax),%edx
80102361:	c1 ea 10             	shr    $0x10,%edx
80102364:	80 fa 03             	cmp    $0x3,%dl
80102367:	77 6b                	ja     801023d4 <lapicinit+0xd4>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102369:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102370:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102373:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102376:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010237d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102380:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102383:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010238a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010238d:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102390:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102397:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010239a:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010239d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801023a4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801023a7:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023aa:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801023b1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801023b4:	8b 50 20             	mov    0x20(%eax),%edx
801023b7:	90                   	nop
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801023b8:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801023be:	80 e6 10             	and    $0x10,%dh
801023c1:	75 f5                	jne    801023b8 <lapicinit+0xb8>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023c3:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801023ca:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801023cd:	8b 40 20             	mov    0x20(%eax),%eax
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801023d0:	5d                   	pop    %ebp
801023d1:	c3                   	ret    
801023d2:	66 90                	xchg   %ax,%ax

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
801023d4:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801023db:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801023de:	8b 50 20             	mov    0x20(%eax),%edx
801023e1:	eb 86                	jmp    80102369 <lapicinit+0x69>
801023e3:	90                   	nop

801023e4 <lapicid>:
  lapicw(TPR, 0);
}

int
lapicid(void)
{
801023e4:	55                   	push   %ebp
801023e5:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801023e7:	a1 7c 16 11 80       	mov    0x8011167c,%eax
801023ec:	85 c0                	test   %eax,%eax
801023ee:	74 08                	je     801023f8 <lapicid+0x14>
    return 0;
  return lapic[ID] >> 24;
801023f0:	8b 40 20             	mov    0x20(%eax),%eax
801023f3:	c1 e8 18             	shr    $0x18,%eax
}
801023f6:	5d                   	pop    %ebp
801023f7:	c3                   	ret    

int
lapicid(void)
{
  if (!lapic)
    return 0;
801023f8:	31 c0                	xor    %eax,%eax
  return lapic[ID] >> 24;
}
801023fa:	5d                   	pop    %ebp
801023fb:	c3                   	ret    

801023fc <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
801023fc:	55                   	push   %ebp
801023fd:	89 e5                	mov    %esp,%ebp
  if(lapic)
801023ff:	a1 7c 16 11 80       	mov    0x8011167c,%eax
80102404:	85 c0                	test   %eax,%eax
80102406:	74 0d                	je     80102415 <lapiceoi+0x19>

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102408:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
8010240f:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102412:	8b 40 20             	mov    0x20(%eax),%eax
void
lapiceoi(void)
{
  if(lapic)
    lapicw(EOI, 0);
}
80102415:	5d                   	pop    %ebp
80102416:	c3                   	ret    
80102417:	90                   	nop

80102418 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102418:	55                   	push   %ebp
80102419:	89 e5                	mov    %esp,%ebp
}
8010241b:	5d                   	pop    %ebp
8010241c:	c3                   	ret    
8010241d:	8d 76 00             	lea    0x0(%esi),%esi

80102420 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102420:	55                   	push   %ebp
80102421:	89 e5                	mov    %esp,%ebp
80102423:	53                   	push   %ebx
80102424:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102427:	8a 5d 08             	mov    0x8(%ebp),%bl
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010242a:	ba 70 00 00 00       	mov    $0x70,%edx
8010242f:	b0 0f                	mov    $0xf,%al
80102431:	ee                   	out    %al,(%dx)
80102432:	b2 71                	mov    $0x71,%dl
80102434:	b0 0a                	mov    $0xa,%al
80102436:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102437:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010243e:	00 00 
  wrv[1] = addr >> 4;
80102440:	89 c8                	mov    %ecx,%eax
80102442:	c1 e8 04             	shr    $0x4,%eax
80102445:	66 a3 69 04 00 80    	mov    %ax,0x80000469

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010244b:	a1 7c 16 11 80       	mov    0x8011167c,%eax
  wrv[0] = 0;
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102450:	c1 e3 18             	shl    $0x18,%ebx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102453:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102459:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010245c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102463:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102466:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102469:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102470:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102473:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102476:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010247c:	8b 50 20             	mov    0x20(%eax),%edx
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010247f:	c1 e9 0c             	shr    $0xc,%ecx
80102482:	80 cd 06             	or     $0x6,%ch

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102485:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010248b:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
8010248e:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102494:	8b 50 20             	mov    0x20(%eax),%edx

//PAGEBREAK!
static void
lapicw(int index, int value)
{
  lapic[index] = value;
80102497:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010249d:	8b 40 20             	mov    0x20(%eax),%eax
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
801024a0:	5b                   	pop    %ebx
801024a1:	5d                   	pop    %ebp
801024a2:	c3                   	ret    
801024a3:	90                   	nop

801024a4 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801024a4:	55                   	push   %ebp
801024a5:	89 e5                	mov    %esp,%ebp
801024a7:	57                   	push   %edi
801024a8:	56                   	push   %esi
801024a9:	53                   	push   %ebx
801024aa:	83 ec 6c             	sub    $0x6c,%esp
801024ad:	ba 70 00 00 00       	mov    $0x70,%edx
801024b2:	b0 0b                	mov    $0xb,%al
801024b4:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024b5:	b2 71                	mov    $0x71,%dl
801024b7:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
801024b8:	89 c2                	mov    %eax,%edx
801024ba:	83 e2 04             	and    $0x4,%edx
801024bd:	89 55 a0             	mov    %edx,-0x60(%ebp)
801024c0:	8d 45 b8             	lea    -0x48(%ebp),%eax
801024c3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024c6:	be 70 00 00 00       	mov    $0x70,%esi
801024cb:	90                   	nop
801024cc:	31 c0                	xor    %eax,%eax
801024ce:	89 f2                	mov    %esi,%edx
801024d0:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024d1:	b9 71 00 00 00       	mov    $0x71,%ecx
801024d6:	89 ca                	mov    %ecx,%edx
801024d8:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801024d9:	0f b6 d8             	movzbl %al,%ebx
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024dc:	b0 02                	mov    $0x2,%al
801024de:	89 f2                	mov    %esi,%edx
801024e0:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024e1:	89 ca                	mov    %ecx,%edx
801024e3:	ec                   	in     (%dx),%al
801024e4:	0f b6 c0             	movzbl %al,%eax
801024e7:	89 45 b0             	mov    %eax,-0x50(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024ea:	b0 04                	mov    $0x4,%al
801024ec:	89 f2                	mov    %esi,%edx
801024ee:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024ef:	89 ca                	mov    %ecx,%edx
801024f1:	ec                   	in     (%dx),%al
801024f2:	0f b6 c0             	movzbl %al,%eax
801024f5:	89 45 ac             	mov    %eax,-0x54(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801024f8:	b0 07                	mov    $0x7,%al
801024fa:	89 f2                	mov    %esi,%edx
801024fc:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801024fd:	89 ca                	mov    %ecx,%edx
801024ff:	ec                   	in     (%dx),%al
80102500:	0f b6 c0             	movzbl %al,%eax
80102503:	89 45 a8             	mov    %eax,-0x58(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102506:	b0 08                	mov    $0x8,%al
80102508:	89 f2                	mov    %esi,%edx
8010250a:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010250b:	89 ca                	mov    %ecx,%edx
8010250d:	ec                   	in     (%dx),%al
8010250e:	0f b6 c0             	movzbl %al,%eax
80102511:	89 45 a4             	mov    %eax,-0x5c(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102514:	b0 09                	mov    $0x9,%al
80102516:	89 f2                	mov    %esi,%edx
80102518:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102519:	89 ca                	mov    %ecx,%edx
8010251b:	ec                   	in     (%dx),%al
8010251c:	0f b6 f8             	movzbl %al,%edi
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010251f:	b0 0a                	mov    $0xa,%al
80102521:	89 f2                	mov    %esi,%edx
80102523:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102524:	89 ca                	mov    %ecx,%edx
80102526:	ec                   	in     (%dx),%al
  bcd = (sb & (1 << 2)) == 0;

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102527:	a8 80                	test   $0x80,%al
80102529:	75 a1                	jne    801024cc <cmostime+0x28>
8010252b:	89 5d b8             	mov    %ebx,-0x48(%ebp)
8010252e:	8b 45 b0             	mov    -0x50(%ebp),%eax
80102531:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102534:	8b 55 ac             	mov    -0x54(%ebp),%edx
80102537:	89 55 c0             	mov    %edx,-0x40(%ebp)
8010253a:	8b 45 a8             	mov    -0x58(%ebp),%eax
8010253d:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102540:	8b 55 a4             	mov    -0x5c(%ebp),%edx
80102543:	89 55 c8             	mov    %edx,-0x38(%ebp)
80102546:	89 7d cc             	mov    %edi,-0x34(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102549:	31 c0                	xor    %eax,%eax
8010254b:	89 f2                	mov    %esi,%edx
8010254d:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010254e:	89 ca                	mov    %ecx,%edx
80102550:	ec                   	in     (%dx),%al
cmos_read(uint reg)
{
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102551:	0f b6 c0             	movzbl %al,%eax
80102554:	89 45 d0             	mov    %eax,-0x30(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102557:	b0 02                	mov    $0x2,%al
80102559:	89 f2                	mov    %esi,%edx
8010255b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010255c:	89 ca                	mov    %ecx,%edx
8010255e:	ec                   	in     (%dx),%al
8010255f:	0f b6 c0             	movzbl %al,%eax
80102562:	89 45 d4             	mov    %eax,-0x2c(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102565:	b0 04                	mov    $0x4,%al
80102567:	89 f2                	mov    %esi,%edx
80102569:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010256a:	89 ca                	mov    %ecx,%edx
8010256c:	ec                   	in     (%dx),%al
8010256d:	0f b6 c0             	movzbl %al,%eax
80102570:	89 45 d8             	mov    %eax,-0x28(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102573:	b0 07                	mov    $0x7,%al
80102575:	89 f2                	mov    %esi,%edx
80102577:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102578:	89 ca                	mov    %ecx,%edx
8010257a:	ec                   	in     (%dx),%al
8010257b:	0f b6 c0             	movzbl %al,%eax
8010257e:	89 45 dc             	mov    %eax,-0x24(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102581:	b0 08                	mov    $0x8,%al
80102583:	89 f2                	mov    %esi,%edx
80102585:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102586:	89 ca                	mov    %ecx,%edx
80102588:	ec                   	in     (%dx),%al
80102589:	0f b6 c0             	movzbl %al,%eax
8010258c:	89 45 e0             	mov    %eax,-0x20(%ebp)
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010258f:	b0 09                	mov    $0x9,%al
80102591:	89 f2                	mov    %esi,%edx
80102593:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102594:	89 ca                	mov    %ecx,%edx
80102596:	ec                   	in     (%dx),%al
80102597:	0f b6 c8             	movzbl %al,%ecx
8010259a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
8010259d:	c7 44 24 08 18 00 00 	movl   $0x18,0x8(%esp)
801025a4:	00 
801025a5:	8d 45 d0             	lea    -0x30(%ebp),%eax
801025a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801025ac:	8d 55 b8             	lea    -0x48(%ebp),%edx
801025af:	89 14 24             	mov    %edx,(%esp)
801025b2:	e8 3d 18 00 00       	call   80103df4 <memcmp>
801025b7:	85 c0                	test   %eax,%eax
801025b9:	0f 85 0d ff ff ff    	jne    801024cc <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
801025bf:	8b 45 a0             	mov    -0x60(%ebp),%eax
801025c2:	85 c0                	test   %eax,%eax
801025c4:	75 78                	jne    8010263e <cmostime+0x19a>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801025c6:	8b 45 b8             	mov    -0x48(%ebp),%eax
801025c9:	89 c2                	mov    %eax,%edx
801025cb:	c1 ea 04             	shr    $0x4,%edx
801025ce:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025d1:	83 e0 0f             	and    $0xf,%eax
801025d4:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025d7:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
801025da:	8b 45 bc             	mov    -0x44(%ebp),%eax
801025dd:	89 c2                	mov    %eax,%edx
801025df:	c1 ea 04             	shr    $0x4,%edx
801025e2:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025e5:	83 e0 0f             	and    $0xf,%eax
801025e8:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025eb:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
801025ee:	8b 45 c0             	mov    -0x40(%ebp),%eax
801025f1:	89 c2                	mov    %eax,%edx
801025f3:	c1 ea 04             	shr    $0x4,%edx
801025f6:	8d 14 92             	lea    (%edx,%edx,4),%edx
801025f9:	83 e0 0f             	and    $0xf,%eax
801025fc:	8d 04 50             	lea    (%eax,%edx,2),%eax
801025ff:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102602:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102605:	89 c2                	mov    %eax,%edx
80102607:	c1 ea 04             	shr    $0x4,%edx
8010260a:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010260d:	83 e0 0f             	and    $0xf,%eax
80102610:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102613:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102616:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102619:	89 c2                	mov    %eax,%edx
8010261b:	c1 ea 04             	shr    $0x4,%edx
8010261e:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102621:	83 e0 0f             	and    $0xf,%eax
80102624:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102627:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
8010262a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010262d:	89 c2                	mov    %eax,%edx
8010262f:	c1 ea 04             	shr    $0x4,%edx
80102632:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102635:	83 e0 0f             	and    $0xf,%eax
80102638:	8d 04 50             	lea    (%eax,%edx,2),%eax
8010263b:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
8010263e:	b9 06 00 00 00       	mov    $0x6,%ecx
80102643:	8b 7d 08             	mov    0x8(%ebp),%edi
80102646:	8b 75 b4             	mov    -0x4c(%ebp),%esi
80102649:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  r->year += 2000;
8010264b:	8b 45 08             	mov    0x8(%ebp),%eax
8010264e:	81 40 14 d0 07 00 00 	addl   $0x7d0,0x14(%eax)
}
80102655:	83 c4 6c             	add    $0x6c,%esp
80102658:	5b                   	pop    %ebx
80102659:	5e                   	pop    %esi
8010265a:	5f                   	pop    %edi
8010265b:	5d                   	pop    %ebp
8010265c:	c3                   	ret    
8010265d:	00 00                	add    %al,(%eax)
	...

80102660 <install_trans>:
}

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102660:	55                   	push   %ebp
80102661:	89 e5                	mov    %esp,%ebp
80102663:	57                   	push   %edi
80102664:	56                   	push   %esi
80102665:	53                   	push   %ebx
80102666:	83 ec 1c             	sub    $0x1c,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102669:	a1 c8 16 11 80       	mov    0x801116c8,%eax
8010266e:	85 c0                	test   %eax,%eax
80102670:	7e 72                	jle    801026e4 <install_trans+0x84>
80102672:	31 db                	xor    %ebx,%ebx
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102674:	a1 b4 16 11 80       	mov    0x801116b4,%eax
80102679:	01 d8                	add    %ebx,%eax
8010267b:	40                   	inc    %eax
8010267c:	89 44 24 04          	mov    %eax,0x4(%esp)
80102680:	a1 c4 16 11 80       	mov    0x801116c4,%eax
80102685:	89 04 24             	mov    %eax,(%esp)
80102688:	e8 27 da ff ff       	call   801000b4 <bread>
8010268d:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010268f:	8b 04 9d cc 16 11 80 	mov    -0x7feee934(,%ebx,4),%eax
80102696:	89 44 24 04          	mov    %eax,0x4(%esp)
8010269a:	a1 c4 16 11 80       	mov    0x801116c4,%eax
8010269f:	89 04 24             	mov    %eax,(%esp)
801026a2:	e8 0d da ff ff       	call   801000b4 <bread>
801026a7:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801026a9:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801026b0:	00 
801026b1:	8d 47 5c             	lea    0x5c(%edi),%eax
801026b4:	89 44 24 04          	mov    %eax,0x4(%esp)
801026b8:	8d 46 5c             	lea    0x5c(%esi),%eax
801026bb:	89 04 24             	mov    %eax,(%esp)
801026be:	e8 79 17 00 00       	call   80103e3c <memmove>
    bwrite(dbuf);  // write dst to disk
801026c3:	89 34 24             	mov    %esi,(%esp)
801026c6:	e8 a5 da ff ff       	call   80100170 <bwrite>
    brelse(lbuf);
801026cb:	89 3c 24             	mov    %edi,(%esp)
801026ce:	e8 d5 da ff ff       	call   801001a8 <brelse>
    brelse(dbuf);
801026d3:	89 34 24             	mov    %esi,(%esp)
801026d6:	e8 cd da ff ff       	call   801001a8 <brelse>
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026db:	43                   	inc    %ebx
801026dc:	39 1d c8 16 11 80    	cmp    %ebx,0x801116c8
801026e2:	7f 90                	jg     80102674 <install_trans+0x14>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf);
    brelse(dbuf);
  }
}
801026e4:	83 c4 1c             	add    $0x1c,%esp
801026e7:	5b                   	pop    %ebx
801026e8:	5e                   	pop    %esi
801026e9:	5f                   	pop    %edi
801026ea:	5d                   	pop    %ebp
801026eb:	c3                   	ret    

801026ec <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801026ec:	55                   	push   %ebp
801026ed:	89 e5                	mov    %esp,%ebp
801026ef:	57                   	push   %edi
801026f0:	56                   	push   %esi
801026f1:	53                   	push   %ebx
801026f2:	83 ec 1c             	sub    $0x1c,%esp
  struct buf *buf = bread(log.dev, log.start);
801026f5:	a1 b4 16 11 80       	mov    0x801116b4,%eax
801026fa:	89 44 24 04          	mov    %eax,0x4(%esp)
801026fe:	a1 c4 16 11 80       	mov    0x801116c4,%eax
80102703:	89 04 24             	mov    %eax,(%esp)
80102706:	e8 a9 d9 ff ff       	call   801000b4 <bread>
8010270b:	89 c7                	mov    %eax,%edi
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
8010270d:	8b 1d c8 16 11 80    	mov    0x801116c8,%ebx
80102713:	89 58 5c             	mov    %ebx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102716:	85 db                	test   %ebx,%ebx
80102718:	7e 16                	jle    80102730 <write_head+0x44>
8010271a:	31 d2                	xor    %edx,%edx
8010271c:	8d 70 5c             	lea    0x5c(%eax),%esi
8010271f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102720:	8b 0c 95 cc 16 11 80 	mov    -0x7feee934(,%edx,4),%ecx
80102727:	89 4c 96 04          	mov    %ecx,0x4(%esi,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
8010272b:	42                   	inc    %edx
8010272c:	39 da                	cmp    %ebx,%edx
8010272e:	75 f0                	jne    80102720 <write_head+0x34>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
80102730:	89 3c 24             	mov    %edi,(%esp)
80102733:	e8 38 da ff ff       	call   80100170 <bwrite>
  brelse(buf);
80102738:	89 3c 24             	mov    %edi,(%esp)
8010273b:	e8 68 da ff ff       	call   801001a8 <brelse>
}
80102740:	83 c4 1c             	add    $0x1c,%esp
80102743:	5b                   	pop    %ebx
80102744:	5e                   	pop    %esi
80102745:	5f                   	pop    %edi
80102746:	5d                   	pop    %ebp
80102747:	c3                   	ret    

80102748 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102748:	55                   	push   %ebp
80102749:	89 e5                	mov    %esp,%ebp
8010274b:	56                   	push   %esi
8010274c:	53                   	push   %ebx
8010274d:	83 ec 30             	sub    $0x30,%esp
80102750:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102753:	c7 44 24 04 70 69 10 	movl   $0x80106970,0x4(%esp)
8010275a:	80 
8010275b:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
80102762:	e8 5d 14 00 00       	call   80103bc4 <initlock>
  readsb(dev, &sb);
80102767:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010276a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010276e:	89 1c 24             	mov    %ebx,(%esp)
80102771:	e8 06 eb ff ff       	call   8010127c <readsb>
  log.start = sb.logstart;
80102776:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102779:	a3 b4 16 11 80       	mov    %eax,0x801116b4
  log.size = sb.nlog;
8010277e:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102781:	89 15 b8 16 11 80    	mov    %edx,0x801116b8
  log.dev = dev;
80102787:	89 1d c4 16 11 80    	mov    %ebx,0x801116c4

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
  struct buf *buf = bread(log.dev, log.start);
8010278d:	89 44 24 04          	mov    %eax,0x4(%esp)
80102791:	89 1c 24             	mov    %ebx,(%esp)
80102794:	e8 1b d9 ff ff       	call   801000b4 <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102799:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010279c:	89 1d c8 16 11 80    	mov    %ebx,0x801116c8
  for (i = 0; i < log.lh.n; i++) {
801027a2:	85 db                	test   %ebx,%ebx
801027a4:	7e 16                	jle    801027bc <initlog+0x74>
801027a6:	31 d2                	xor    %edx,%edx
801027a8:	8d 70 5c             	lea    0x5c(%eax),%esi
801027ab:	90                   	nop
    log.lh.block[i] = lh->block[i];
801027ac:	8b 4c 96 04          	mov    0x4(%esi,%edx,4),%ecx
801027b0:	89 0c 95 cc 16 11 80 	mov    %ecx,-0x7feee934(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801027b7:	42                   	inc    %edx
801027b8:	39 da                	cmp    %ebx,%edx
801027ba:	75 f0                	jne    801027ac <initlog+0x64>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
801027bc:	89 04 24             	mov    %eax,(%esp)
801027bf:	e8 e4 d9 ff ff       	call   801001a8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
801027c4:	e8 97 fe ff ff       	call   80102660 <install_trans>
  log.lh.n = 0;
801027c9:	c7 05 c8 16 11 80 00 	movl   $0x0,0x801116c8
801027d0:	00 00 00 
  write_head(); // clear the log
801027d3:	e8 14 ff ff ff       	call   801026ec <write_head>
  readsb(dev, &sb);
  log.start = sb.logstart;
  log.size = sb.nlog;
  log.dev = dev;
  recover_from_log();
}
801027d8:	83 c4 30             	add    $0x30,%esp
801027db:	5b                   	pop    %ebx
801027dc:	5e                   	pop    %esi
801027dd:	5d                   	pop    %ebp
801027de:	c3                   	ret    
801027df:	90                   	nop

801027e0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
801027e0:	55                   	push   %ebp
801027e1:	89 e5                	mov    %esp,%ebp
801027e3:	83 ec 18             	sub    $0x18,%esp
  acquire(&log.lock);
801027e6:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
801027ed:	e8 0e 15 00 00       	call   80103d00 <acquire>
801027f2:	eb 14                	jmp    80102808 <begin_op+0x28>
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
801027f4:	c7 44 24 04 80 16 11 	movl   $0x80111680,0x4(%esp)
801027fb:	80 
801027fc:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
80102803:	e8 ac 0f 00 00       	call   801037b4 <sleep>
void
begin_op(void)
{
  acquire(&log.lock);
  while(1){
    if(log.committing){
80102808:	a1 c0 16 11 80       	mov    0x801116c0,%eax
8010280d:	85 c0                	test   %eax,%eax
8010280f:	75 e3                	jne    801027f4 <begin_op+0x14>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102811:	8b 15 bc 16 11 80    	mov    0x801116bc,%edx
80102817:	42                   	inc    %edx
80102818:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010281b:	8b 0d c8 16 11 80    	mov    0x801116c8,%ecx
80102821:	8d 04 41             	lea    (%ecx,%eax,2),%eax
80102824:	83 f8 1e             	cmp    $0x1e,%eax
80102827:	7f cb                	jg     801027f4 <begin_op+0x14>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
80102829:	89 15 bc 16 11 80    	mov    %edx,0x801116bc
      release(&log.lock);
8010282f:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
80102836:	e8 29 15 00 00       	call   80103d64 <release>
      break;
    }
  }
}
8010283b:	c9                   	leave  
8010283c:	c3                   	ret    
8010283d:	8d 76 00             	lea    0x0(%esi),%esi

80102840 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102840:	55                   	push   %ebp
80102841:	89 e5                	mov    %esp,%ebp
80102843:	57                   	push   %edi
80102844:	56                   	push   %esi
80102845:	53                   	push   %ebx
80102846:	83 ec 1c             	sub    $0x1c,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102849:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
80102850:	e8 ab 14 00 00       	call   80103d00 <acquire>
  log.outstanding -= 1;
80102855:	a1 bc 16 11 80       	mov    0x801116bc,%eax
8010285a:	48                   	dec    %eax
8010285b:	a3 bc 16 11 80       	mov    %eax,0x801116bc
  if(log.committing)
80102860:	8b 15 c0 16 11 80    	mov    0x801116c0,%edx
80102866:	85 d2                	test   %edx,%edx
80102868:	0f 85 ed 00 00 00    	jne    8010295b <end_op+0x11b>
    panic("log.committing");
  if(log.outstanding == 0){
8010286e:	85 c0                	test   %eax,%eax
80102870:	0f 85 c5 00 00 00    	jne    8010293b <end_op+0xfb>
    do_commit = 1;
    log.committing = 1;
80102876:	c7 05 c0 16 11 80 01 	movl   $0x1,0x801116c0
8010287d:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102880:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
80102887:	e8 d8 14 00 00       	call   80103d64 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
8010288c:	a1 c8 16 11 80       	mov    0x801116c8,%eax
80102891:	85 c0                	test   %eax,%eax
80102893:	0f 8e 8c 00 00 00    	jle    80102925 <end_op+0xe5>
80102899:	31 db                	xor    %ebx,%ebx
8010289b:	90                   	nop
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010289c:	a1 b4 16 11 80       	mov    0x801116b4,%eax
801028a1:	01 d8                	add    %ebx,%eax
801028a3:	40                   	inc    %eax
801028a4:	89 44 24 04          	mov    %eax,0x4(%esp)
801028a8:	a1 c4 16 11 80       	mov    0x801116c4,%eax
801028ad:	89 04 24             	mov    %eax,(%esp)
801028b0:	e8 ff d7 ff ff       	call   801000b4 <bread>
801028b5:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801028b7:	8b 04 9d cc 16 11 80 	mov    -0x7feee934(,%ebx,4),%eax
801028be:	89 44 24 04          	mov    %eax,0x4(%esp)
801028c2:	a1 c4 16 11 80       	mov    0x801116c4,%eax
801028c7:	89 04 24             	mov    %eax,(%esp)
801028ca:	e8 e5 d7 ff ff       	call   801000b4 <bread>
801028cf:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801028d1:	c7 44 24 08 00 02 00 	movl   $0x200,0x8(%esp)
801028d8:	00 
801028d9:	8d 40 5c             	lea    0x5c(%eax),%eax
801028dc:	89 44 24 04          	mov    %eax,0x4(%esp)
801028e0:	8d 46 5c             	lea    0x5c(%esi),%eax
801028e3:	89 04 24             	mov    %eax,(%esp)
801028e6:	e8 51 15 00 00       	call   80103e3c <memmove>
    bwrite(to);  // write the log
801028eb:	89 34 24             	mov    %esi,(%esp)
801028ee:	e8 7d d8 ff ff       	call   80100170 <bwrite>
    brelse(from);
801028f3:	89 3c 24             	mov    %edi,(%esp)
801028f6:	e8 ad d8 ff ff       	call   801001a8 <brelse>
    brelse(to);
801028fb:	89 34 24             	mov    %esi,(%esp)
801028fe:	e8 a5 d8 ff ff       	call   801001a8 <brelse>
static void
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102903:	43                   	inc    %ebx
80102904:	3b 1d c8 16 11 80    	cmp    0x801116c8,%ebx
8010290a:	7c 90                	jl     8010289c <end_op+0x5c>
static void
commit()
{
  if (log.lh.n > 0) {
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
8010290c:	e8 db fd ff ff       	call   801026ec <write_head>
    install_trans(); // Now install writes to home locations
80102911:	e8 4a fd ff ff       	call   80102660 <install_trans>
    log.lh.n = 0;
80102916:	c7 05 c8 16 11 80 00 	movl   $0x0,0x801116c8
8010291d:	00 00 00 
    write_head();    // Erase the transaction from the log
80102920:	e8 c7 fd ff ff       	call   801026ec <write_head>

  if(do_commit){
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
    acquire(&log.lock);
80102925:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
8010292c:	e8 cf 13 00 00       	call   80103d00 <acquire>
    log.committing = 0;
80102931:	c7 05 c0 16 11 80 00 	movl   $0x0,0x801116c0
80102938:	00 00 00 
    wakeup(&log);
8010293b:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
80102942:	e8 e9 0f 00 00       	call   80103930 <wakeup>
    release(&log.lock);
80102947:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
8010294e:	e8 11 14 00 00       	call   80103d64 <release>
  }
}
80102953:	83 c4 1c             	add    $0x1c,%esp
80102956:	5b                   	pop    %ebx
80102957:	5e                   	pop    %esi
80102958:	5f                   	pop    %edi
80102959:	5d                   	pop    %ebp
8010295a:	c3                   	ret    
  int do_commit = 0;

  acquire(&log.lock);
  log.outstanding -= 1;
  if(log.committing)
    panic("log.committing");
8010295b:	c7 04 24 74 69 10 80 	movl   $0x80106974,(%esp)
80102962:	e8 b5 d9 ff ff       	call   8010031c <panic>
80102967:	90                   	nop

80102968 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102968:	55                   	push   %ebp
80102969:	89 e5                	mov    %esp,%ebp
8010296b:	53                   	push   %ebx
8010296c:	83 ec 14             	sub    $0x14,%esp
8010296f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102972:	a1 c8 16 11 80       	mov    0x801116c8,%eax
80102977:	83 f8 1d             	cmp    $0x1d,%eax
8010297a:	0f 8f 84 00 00 00    	jg     80102a04 <log_write+0x9c>
80102980:	8b 15 b8 16 11 80    	mov    0x801116b8,%edx
80102986:	4a                   	dec    %edx
80102987:	39 d0                	cmp    %edx,%eax
80102989:	7d 79                	jge    80102a04 <log_write+0x9c>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010298b:	8b 0d bc 16 11 80    	mov    0x801116bc,%ecx
80102991:	85 c9                	test   %ecx,%ecx
80102993:	7e 7b                	jle    80102a10 <log_write+0xa8>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102995:	c7 04 24 80 16 11 80 	movl   $0x80111680,(%esp)
8010299c:	e8 5f 13 00 00       	call   80103d00 <acquire>
  for (i = 0; i < log.lh.n; i++) {
801029a1:	8b 15 c8 16 11 80    	mov    0x801116c8,%edx
801029a7:	83 fa 00             	cmp    $0x0,%edx
801029aa:	7e 49                	jle    801029f5 <log_write+0x8d>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801029ac:	8b 4b 08             	mov    0x8(%ebx),%ecx
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801029af:	31 c0                	xor    %eax,%eax
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801029b1:	39 0d cc 16 11 80    	cmp    %ecx,0x801116cc
801029b7:	75 0c                	jne    801029c5 <log_write+0x5d>
801029b9:	eb 31                	jmp    801029ec <log_write+0x84>
801029bb:	90                   	nop
801029bc:	39 0c 85 cc 16 11 80 	cmp    %ecx,-0x7feee934(,%eax,4)
801029c3:	74 27                	je     801029ec <log_write+0x84>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801029c5:	40                   	inc    %eax
801029c6:	39 d0                	cmp    %edx,%eax
801029c8:	75 f2                	jne    801029bc <log_write+0x54>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801029ca:	89 0c 95 cc 16 11 80 	mov    %ecx,-0x7feee934(,%edx,4)
  if (i == log.lh.n)
    log.lh.n++;
801029d1:	42                   	inc    %edx
801029d2:	89 15 c8 16 11 80    	mov    %edx,0x801116c8
  b->flags |= B_DIRTY; // prevent eviction
801029d8:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
801029db:	c7 45 08 80 16 11 80 	movl   $0x80111680,0x8(%ebp)
}
801029e2:	83 c4 14             	add    $0x14,%esp
801029e5:	5b                   	pop    %ebx
801029e6:	5d                   	pop    %ebp
  }
  log.lh.block[i] = b->blockno;
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
  release(&log.lock);
801029e7:	e9 78 13 00 00       	jmp    80103d64 <release>
  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
  }
  log.lh.block[i] = b->blockno;
801029ec:	89 0c 85 cc 16 11 80 	mov    %ecx,-0x7feee934(,%eax,4)
801029f3:	eb e3                	jmp    801029d8 <log_write+0x70>
801029f5:	8b 43 08             	mov    0x8(%ebx),%eax
801029f8:	a3 cc 16 11 80       	mov    %eax,0x801116cc
  if (i == log.lh.n)
801029fd:	75 d9                	jne    801029d8 <log_write+0x70>
801029ff:	eb d0                	jmp    801029d1 <log_write+0x69>
80102a01:	8d 76 00             	lea    0x0(%esi),%esi
log_write(struct buf *b)
{
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    panic("too big a transaction");
80102a04:	c7 04 24 83 69 10 80 	movl   $0x80106983,(%esp)
80102a0b:	e8 0c d9 ff ff       	call   8010031c <panic>
  if (log.outstanding < 1)
    panic("log_write outside of trans");
80102a10:	c7 04 24 99 69 10 80 	movl   $0x80106999,(%esp)
80102a17:	e8 00 d9 ff ff       	call   8010031c <panic>

80102a1c <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80102a1c:	55                   	push   %ebp
80102a1d:	89 e5                	mov    %esp,%ebp
80102a1f:	53                   	push   %ebx
80102a20:	83 ec 14             	sub    $0x14,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a23:	e8 54 08 00 00       	call   8010327c <cpuid>
80102a28:	89 c3                	mov    %eax,%ebx
80102a2a:	e8 4d 08 00 00       	call   8010327c <cpuid>
80102a2f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80102a33:	89 44 24 04          	mov    %eax,0x4(%esp)
80102a37:	c7 04 24 b4 69 10 80 	movl   $0x801069b4,(%esp)
80102a3e:	e8 79 db ff ff       	call   801005bc <cprintf>
  idtinit();       // load idt register
80102a43:	e8 f8 23 00 00       	call   80104e40 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a48:	e8 bb 07 00 00       	call   80103208 <mycpu>
80102a4d:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a4f:	b8 01 00 00 00       	mov    $0x1,%eax
80102a54:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a5b:	e8 e4 0a 00 00       	call   80103544 <scheduler>

80102a60 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80102a60:	55                   	push   %ebp
80102a61:	89 e5                	mov    %esp,%ebp
80102a63:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a66:	e8 a1 33 00 00       	call   80105e0c <switchkvm>
  seginit();
80102a6b:	e8 c0 32 00 00       	call   80105d30 <seginit>
  lapicinit();
80102a70:	e8 8b f8 ff ff       	call   80102300 <lapicinit>
  mpmain();
80102a75:	e8 a2 ff ff ff       	call   80102a1c <mpmain>
	...

80102a7c <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80102a7c:	55                   	push   %ebp
80102a7d:	89 e5                	mov    %esp,%ebp
80102a7f:	53                   	push   %ebx
80102a80:	83 e4 f0             	and    $0xfffffff0,%esp
80102a83:	83 ec 10             	sub    $0x10,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102a86:	c7 44 24 04 00 00 40 	movl   $0x80400000,0x4(%esp)
80102a8d:	80 
80102a8e:	c7 04 24 a8 44 11 80 	movl   $0x801144a8,(%esp)
80102a95:	e8 02 f7 ff ff       	call   8010219c <kinit1>
  kvmalloc();      // kernel page table
80102a9a:	e8 69 38 00 00       	call   80106308 <kvmalloc>
  mpinit();        // detect other processors
80102a9f:	e8 58 01 00 00       	call   80102bfc <mpinit>
  lapicinit();     // interrupt controller
80102aa4:	e8 57 f8 ff ff       	call   80102300 <lapicinit>
  seginit();       // segment descriptors
80102aa9:	e8 82 32 00 00       	call   80105d30 <seginit>
  picinit();       // disable pic
80102aae:	e8 e1 02 00 00       	call   80102d94 <picinit>
  ioapicinit();    // another interrupt controller
80102ab3:	e8 0c f5 ff ff       	call   80101fc4 <ioapicinit>
  consoleinit();   // console hardware
80102ab8:	e8 c7 dd ff ff       	call   80100884 <consoleinit>
  uartinit();      // serial port
80102abd:	e8 5e 26 00 00       	call   80105120 <uartinit>
  pinit();         // process table
80102ac2:	e8 25 07 00 00       	call   801031ec <pinit>
  tvinit();        // trap vectors
80102ac7:	e8 f0 22 00 00       	call   80104dbc <tvinit>
  binit();         // buffer cache
80102acc:	e8 63 d5 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80102ad1:	e8 76 e1 ff ff       	call   80100c4c <fileinit>
  ideinit();       // disk 
80102ad6:	e8 15 f3 ff ff       	call   80101df0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102adb:	c7 44 24 08 8a 00 00 	movl   $0x8a,0x8(%esp)
80102ae2:	00 
80102ae3:	c7 44 24 04 8c 94 10 	movl   $0x8010948c,0x4(%esp)
80102aea:	80 
80102aeb:	c7 04 24 00 70 00 80 	movl   $0x80007000,(%esp)
80102af2:	e8 45 13 00 00       	call   80103e3c <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102af7:	a1 00 1d 11 80       	mov    0x80111d00,%eax
80102afc:	8d 14 80             	lea    (%eax,%eax,4),%edx
80102aff:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b02:	c1 e0 04             	shl    $0x4,%eax
80102b05:	05 80 17 11 80       	add    $0x80111780,%eax
80102b0a:	3d 80 17 11 80       	cmp    $0x80111780,%eax
80102b0f:	76 6e                	jbe    80102b7f <main+0x103>
80102b11:	bb 80 17 11 80       	mov    $0x80111780,%ebx
80102b16:	66 90                	xchg   %ax,%ax
    if(c == mycpu())  // We've started already.
80102b18:	e8 eb 06 00 00       	call   80103208 <mycpu>
80102b1d:	39 d8                	cmp    %ebx,%eax
80102b1f:	74 41                	je     80102b62 <main+0xe6>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102b21:	e8 b6 f6 ff ff       	call   801021dc <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b26:	05 00 10 00 00       	add    $0x1000,%eax
80102b2b:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102b30:	c7 05 f8 6f 00 80 60 	movl   $0x80102a60,0x80006ff8
80102b37:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102b3a:	c7 05 f4 6f 00 80 00 	movl   $0x108000,0x80006ff4
80102b41:	80 10 00 

    lapicstartap(c->apicid, V2P(code));
80102b44:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
80102b4b:	00 
80102b4c:	0f b6 03             	movzbl (%ebx),%eax
80102b4f:	89 04 24             	mov    %eax,(%esp)
80102b52:	e8 c9 f8 ff ff       	call   80102420 <lapicstartap>
80102b57:	90                   	nop

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102b58:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b5e:	85 c0                	test   %eax,%eax
80102b60:	74 f6                	je     80102b58 <main+0xdc>
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80102b62:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b68:	a1 00 1d 11 80       	mov    0x80111d00,%eax
80102b6d:	8d 14 80             	lea    (%eax,%eax,4),%edx
80102b70:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b73:	c1 e0 04             	shl    $0x4,%eax
80102b76:	05 80 17 11 80       	add    $0x80111780,%eax
80102b7b:	39 c3                	cmp    %eax,%ebx
80102b7d:	72 99                	jb     80102b18 <main+0x9c>
  tvinit();        // trap vectors
  binit();         // buffer cache
  fileinit();      // file table
  ideinit();       // disk 
  startothers();   // start other processors
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102b7f:	c7 44 24 04 00 00 00 	movl   $0x8e000000,0x4(%esp)
80102b86:	8e 
80102b87:	c7 04 24 00 00 40 80 	movl   $0x80400000,(%esp)
80102b8e:	e8 e5 f5 ff ff       	call   80102178 <kinit2>
  userinit();      // first user process
80102b93:	e8 38 07 00 00       	call   801032d0 <userinit>
  mpmain();        // finish this processor's setup
80102b98:	e8 7f fe ff ff       	call   80102a1c <mpmain>
80102b9d:	00 00                	add    %al,(%eax)
	...

80102ba0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102ba0:	55                   	push   %ebp
80102ba1:	89 e5                	mov    %esp,%ebp
80102ba3:	56                   	push   %esi
80102ba4:	53                   	push   %ebx
80102ba5:	83 ec 10             	sub    $0x10,%esp
  uchar *e, *p, *addr;

  addr = P2V(a);
80102ba8:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
  e = addr+len;
80102bae:	8d 34 13             	lea    (%ebx,%edx,1),%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102bb1:	39 f3                	cmp    %esi,%ebx
80102bb3:	73 3a                	jae    80102bef <mpsearch1+0x4f>
80102bb5:	8d 76 00             	lea    0x0(%esi),%esi
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102bb8:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80102bbf:	00 
80102bc0:	c7 44 24 04 c8 69 10 	movl   $0x801069c8,0x4(%esp)
80102bc7:	80 
80102bc8:	89 1c 24             	mov    %ebx,(%esp)
80102bcb:	e8 24 12 00 00       	call   80103df4 <memcmp>
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	75 14                	jne    80102be8 <mpsearch1+0x48>
80102bd4:	31 d2                	xor    %edx,%edx
80102bd6:	66 90                	xchg   %ax,%ax
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
    sum += addr[i];
80102bd8:	0f b6 0c 03          	movzbl (%ebx,%eax,1),%ecx
80102bdc:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80102bde:	40                   	inc    %eax
80102bdf:	83 f8 10             	cmp    $0x10,%eax
80102be2:	75 f4                	jne    80102bd8 <mpsearch1+0x38>
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102be4:	84 d2                	test   %dl,%dl
80102be6:	74 09                	je     80102bf1 <mpsearch1+0x51>
{
  uchar *e, *p, *addr;

  addr = P2V(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80102be8:	83 c3 10             	add    $0x10,%ebx
80102beb:	39 de                	cmp    %ebx,%esi
80102bed:	77 c9                	ja     80102bb8 <mpsearch1+0x18>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80102bef:	31 db                	xor    %ebx,%ebx
}
80102bf1:	89 d8                	mov    %ebx,%eax
80102bf3:	83 c4 10             	add    $0x10,%esp
80102bf6:	5b                   	pop    %ebx
80102bf7:	5e                   	pop    %esi
80102bf8:	5d                   	pop    %ebp
80102bf9:	c3                   	ret    
80102bfa:	66 90                	xchg   %ax,%ax

80102bfc <mpinit>:
  return conf;
}

void
mpinit(void)
{
80102bfc:	55                   	push   %ebp
80102bfd:	89 e5                	mov    %esp,%ebp
80102bff:	57                   	push   %edi
80102c00:	56                   	push   %esi
80102c01:	53                   	push   %ebx
80102c02:	83 ec 2c             	sub    $0x2c,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102c05:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102c0c:	c1 e0 08             	shl    $0x8,%eax
80102c0f:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102c16:	09 d0                	or     %edx,%eax
80102c18:	c1 e0 04             	shl    $0x4,%eax
80102c1b:	75 1b                	jne    80102c38 <mpinit+0x3c>
    if((mp = mpsearch1(p, 1024)))
      return mp;
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102c1d:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102c24:	c1 e0 08             	shl    $0x8,%eax
80102c27:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102c2e:	09 d0                	or     %edx,%eax
80102c30:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102c33:	2d 00 04 00 00       	sub    $0x400,%eax
80102c38:	ba 00 04 00 00       	mov    $0x400,%edx
80102c3d:	e8 5e ff ff ff       	call   80102ba0 <mpsearch1>
80102c42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80102c45:	85 c0                	test   %eax,%eax
80102c47:	0f 84 15 01 00 00    	je     80102d62 <mpinit+0x166>
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c4d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c50:	8b 58 04             	mov    0x4(%eax),%ebx
80102c53:	85 db                	test   %ebx,%ebx
80102c55:	0f 84 21 01 00 00    	je     80102d7c <mpinit+0x180>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102c5b:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102c61:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
80102c68:	00 
80102c69:	c7 44 24 04 cd 69 10 	movl   $0x801069cd,0x4(%esp)
80102c70:	80 
80102c71:	89 34 24             	mov    %esi,(%esp)
80102c74:	e8 7b 11 00 00       	call   80103df4 <memcmp>
80102c79:	85 c0                	test   %eax,%eax
80102c7b:	0f 85 fb 00 00 00    	jne    80102d7c <mpinit+0x180>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102c81:	8a 83 06 00 00 80    	mov    -0x7ffffffa(%ebx),%al
80102c87:	3c 01                	cmp    $0x1,%al
80102c89:	74 08                	je     80102c93 <mpinit+0x97>
80102c8b:	3c 04                	cmp    $0x4,%al
80102c8d:	0f 85 e9 00 00 00    	jne    80102d7c <mpinit+0x180>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c93:	0f b7 bb 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edi
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80102c9a:	85 ff                	test   %edi,%edi
80102c9c:	74 1d                	je     80102cbb <mpinit+0xbf>
80102c9e:	31 d2                	xor    %edx,%edx
80102ca0:	31 c0                	xor    %eax,%eax
80102ca2:	66 90                	xchg   %ax,%ax
    sum += addr[i];
80102ca4:	0f b6 8c 03 00 00 00 	movzbl -0x80000000(%ebx,%eax,1),%ecx
80102cab:	80 
80102cac:	01 ca                	add    %ecx,%edx
sum(uchar *addr, int len)
{
  int i, sum;

  sum = 0;
  for(i=0; i<len; i++)
80102cae:	40                   	inc    %eax
80102caf:	39 c7                	cmp    %eax,%edi
80102cb1:	7f f1                	jg     80102ca4 <mpinit+0xa8>
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
  if(memcmp(conf, "PCMP", 4) != 0)
    return 0;
  if(conf->version != 1 && conf->version != 4)
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102cb3:	84 d2                	test   %dl,%dl
80102cb5:	0f 85 c1 00 00 00    	jne    80102d7c <mpinit+0x180>
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102cbb:	85 f6                	test   %esi,%esi
80102cbd:	0f 84 b9 00 00 00    	je     80102d7c <mpinit+0x180>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102cc3:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
80102cc9:	a3 7c 16 11 80       	mov    %eax,0x8011167c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cce:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
80102cd4:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102cdb:	01 d6                	add    %edx,%esi
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
80102cdd:	b9 01 00 00 00       	mov    $0x1,%ecx
80102ce2:	66 90                	xchg   %ax,%ax
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ce4:	39 f0                	cmp    %esi,%eax
80102ce6:	73 1f                	jae    80102d07 <mpinit+0x10b>
80102ce8:	8a 10                	mov    (%eax),%dl
    switch(*p){
80102cea:	80 fa 04             	cmp    $0x4,%dl
80102ced:	76 07                	jbe    80102cf6 <mpinit+0xfa>
    case MPIOINTR:
    case MPLINTR:
      p += 8;
      continue;
    default:
      ismp = 0;
80102cef:	31 c9                	xor    %ecx,%ecx
  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
80102cf1:	80 fa 04             	cmp    $0x4,%dl
80102cf4:	77 f9                	ja     80102cef <mpinit+0xf3>
80102cf6:	0f b6 d2             	movzbl %dl,%edx
80102cf9:	ff 24 95 0c 6a 10 80 	jmp    *-0x7fef95f4(,%edx,4)
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102d00:	83 c0 08             	add    $0x8,%eax

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102d03:	39 f0                	cmp    %esi,%eax
80102d05:	72 e1                	jb     80102ce8 <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80102d07:	85 c9                	test   %ecx,%ecx
80102d09:	74 7d                	je     80102d88 <mpinit+0x18c>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d0b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d0e:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d12:	74 0f                	je     80102d23 <mpinit+0x127>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d14:	ba 22 00 00 00       	mov    $0x22,%edx
80102d19:	b0 70                	mov    $0x70,%al
80102d1b:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d1c:	b2 23                	mov    $0x23,%dl
80102d1e:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d1f:	83 c8 01             	or     $0x1,%eax
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d22:	ee                   	out    %al,(%dx)
  }
}
80102d23:	83 c4 2c             	add    $0x2c,%esp
80102d26:	5b                   	pop    %ebx
80102d27:	5e                   	pop    %esi
80102d28:	5f                   	pop    %edi
80102d29:	5d                   	pop    %ebp
80102d2a:	c3                   	ret    
80102d2b:	90                   	nop
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102d2c:	8b 15 00 1d 11 80    	mov    0x80111d00,%edx
80102d32:	83 fa 07             	cmp    $0x7,%edx
80102d35:	7f 18                	jg     80102d4f <mpinit+0x153>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102d37:	8a 58 01             	mov    0x1(%eax),%bl
80102d3a:	8d 3c 92             	lea    (%edx,%edx,4),%edi
80102d3d:	8d 14 7a             	lea    (%edx,%edi,2),%edx
80102d40:	c1 e2 04             	shl    $0x4,%edx
80102d43:	88 9a 80 17 11 80    	mov    %bl,-0x7feee880(%edx)
        ncpu++;
80102d49:	ff 05 00 1d 11 80    	incl   0x80111d00
      }
      p += sizeof(struct mpproc);
80102d4f:	83 c0 14             	add    $0x14,%eax
      continue;
80102d52:	eb 90                	jmp    80102ce4 <mpinit+0xe8>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102d54:	8a 50 01             	mov    0x1(%eax),%dl
80102d57:	88 15 60 17 11 80    	mov    %dl,0x80111760
      p += sizeof(struct mpioapic);
80102d5d:	83 c0 08             	add    $0x8,%eax
      continue;
80102d60:	eb 82                	jmp    80102ce4 <mpinit+0xe8>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102d62:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d67:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d6c:	e8 2f fe ff ff       	call   80102ba0 <mpsearch1>
80102d71:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d74:	85 c0                	test   %eax,%eax
80102d76:	0f 85 d1 fe ff ff    	jne    80102c4d <mpinit+0x51>
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
80102d7c:	c7 04 24 d2 69 10 80 	movl   $0x801069d2,(%esp)
80102d83:	e8 94 d5 ff ff       	call   8010031c <panic>
      ismp = 0;
      break;
    }
  }
  if(!ismp)
    panic("Didn't find a suitable machine");
80102d88:	c7 04 24 ec 69 10 80 	movl   $0x801069ec,(%esp)
80102d8f:	e8 88 d5 ff ff       	call   8010031c <panic>

80102d94 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d94:	55                   	push   %ebp
80102d95:	89 e5                	mov    %esp,%ebp
80102d97:	ba 21 00 00 00       	mov    $0x21,%edx
80102d9c:	b0 ff                	mov    $0xff,%al
80102d9e:	ee                   	out    %al,(%dx)
80102d9f:	b2 a1                	mov    $0xa1,%dl
80102da1:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102da2:	5d                   	pop    %ebp
80102da3:	c3                   	ret    

80102da4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102da4:	55                   	push   %ebp
80102da5:	89 e5                	mov    %esp,%ebp
80102da7:	56                   	push   %esi
80102da8:	53                   	push   %ebx
80102da9:	83 ec 20             	sub    $0x20,%esp
80102dac:	8b 75 08             	mov    0x8(%ebp),%esi
80102daf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102db2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
80102db8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102dbe:	e8 a5 de ff ff       	call   80100c68 <filealloc>
80102dc3:	89 06                	mov    %eax,(%esi)
80102dc5:	85 c0                	test   %eax,%eax
80102dc7:	0f 84 a1 00 00 00    	je     80102e6e <pipealloc+0xca>
80102dcd:	e8 96 de ff ff       	call   80100c68 <filealloc>
80102dd2:	89 03                	mov    %eax,(%ebx)
80102dd4:	85 c0                	test   %eax,%eax
80102dd6:	0f 84 84 00 00 00    	je     80102e60 <pipealloc+0xbc>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102ddc:	e8 fb f3 ff ff       	call   801021dc <kalloc>
80102de1:	85 c0                	test   %eax,%eax
80102de3:	74 7b                	je     80102e60 <pipealloc+0xbc>
    goto bad;
  p->readopen = 1;
80102de5:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102dec:	00 00 00 
  p->writeopen = 1;
80102def:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102df6:	00 00 00 
  p->nwrite = 0;
80102df9:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e00:	00 00 00 
  p->nread = 0;
80102e03:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102e0a:	00 00 00 
  initlock(&p->lock, "pipe");
80102e0d:	c7 44 24 04 20 6a 10 	movl   $0x80106a20,0x4(%esp)
80102e14:	80 
80102e15:	89 04 24             	mov    %eax,(%esp)
80102e18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102e1b:	e8 a4 0d 00 00       	call   80103bc4 <initlock>
  (*f0)->type = FD_PIPE;
80102e20:	8b 16                	mov    (%esi),%edx
80102e22:	c7 02 01 00 00 00    	movl   $0x1,(%edx)
  (*f0)->readable = 1;
80102e28:	8b 16                	mov    (%esi),%edx
80102e2a:	c6 42 08 01          	movb   $0x1,0x8(%edx)
  (*f0)->writable = 0;
80102e2e:	8b 16                	mov    (%esi),%edx
80102e30:	c6 42 09 00          	movb   $0x0,0x9(%edx)
  (*f0)->pipe = p;
80102e34:	8b 16                	mov    (%esi),%edx
80102e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e39:	89 42 0c             	mov    %eax,0xc(%edx)
  (*f1)->type = FD_PIPE;
80102e3c:	8b 13                	mov    (%ebx),%edx
80102e3e:	c7 02 01 00 00 00    	movl   $0x1,(%edx)
  (*f1)->readable = 0;
80102e44:	8b 13                	mov    (%ebx),%edx
80102e46:	c6 42 08 00          	movb   $0x0,0x8(%edx)
  (*f1)->writable = 1;
80102e4a:	8b 13                	mov    (%ebx),%edx
80102e4c:	c6 42 09 01          	movb   $0x1,0x9(%edx)
  (*f1)->pipe = p;
80102e50:	8b 13                	mov    (%ebx),%edx
80102e52:	89 42 0c             	mov    %eax,0xc(%edx)
  return 0;
80102e55:	31 c0                	xor    %eax,%eax
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
80102e57:	83 c4 20             	add    $0x20,%esp
80102e5a:	5b                   	pop    %ebx
80102e5b:	5e                   	pop    %esi
80102e5c:	5d                   	pop    %ebp
80102e5d:	c3                   	ret    
80102e5e:	66 90                	xchg   %ax,%ax

//PAGEBREAK: 20
 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102e60:	8b 06                	mov    (%esi),%eax
80102e62:	85 c0                	test   %eax,%eax
80102e64:	74 08                	je     80102e6e <pipealloc+0xca>
    fileclose(*f0);
80102e66:	89 04 24             	mov    %eax,(%esp)
80102e69:	e8 aa de ff ff       	call   80100d18 <fileclose>
  if(*f1)
80102e6e:	8b 03                	mov    (%ebx),%eax
80102e70:	85 c0                	test   %eax,%eax
80102e72:	74 14                	je     80102e88 <pipealloc+0xe4>
    fileclose(*f1);
80102e74:	89 04 24             	mov    %eax,(%esp)
80102e77:	e8 9c de ff ff       	call   80100d18 <fileclose>
  return -1;
80102e7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e81:	83 c4 20             	add    $0x20,%esp
80102e84:	5b                   	pop    %ebx
80102e85:	5e                   	pop    %esi
80102e86:	5d                   	pop    %ebp
80102e87:	c3                   	ret    
    kfree((char*)p);
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
80102e88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102e8d:	83 c4 20             	add    $0x20,%esp
80102e90:	5b                   	pop    %ebx
80102e91:	5e                   	pop    %esi
80102e92:	5d                   	pop    %ebp
80102e93:	c3                   	ret    

80102e94 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e94:	55                   	push   %ebp
80102e95:	89 e5                	mov    %esp,%ebp
80102e97:	56                   	push   %esi
80102e98:	53                   	push   %ebx
80102e99:	83 ec 10             	sub    $0x10,%esp
80102e9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e9f:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
80102ea2:	89 1c 24             	mov    %ebx,(%esp)
80102ea5:	e8 56 0e 00 00       	call   80103d00 <acquire>
  if(writable){
80102eaa:	85 f6                	test   %esi,%esi
80102eac:	74 3a                	je     80102ee8 <pipeclose+0x54>
    p->writeopen = 0;
80102eae:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102eb5:	00 00 00 
    wakeup(&p->nread);
80102eb8:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ebe:	89 04 24             	mov    %eax,(%esp)
80102ec1:	e8 6a 0a 00 00       	call   80103930 <wakeup>
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102ec6:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
80102ecc:	85 d2                	test   %edx,%edx
80102ece:	75 0a                	jne    80102eda <pipeclose+0x46>
80102ed0:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80102ed6:	85 c0                	test   %eax,%eax
80102ed8:	74 2a                	je     80102f04 <pipeclose+0x70>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102eda:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80102edd:	83 c4 10             	add    $0x10,%esp
80102ee0:	5b                   	pop    %ebx
80102ee1:	5e                   	pop    %esi
80102ee2:	5d                   	pop    %ebp
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102ee3:	e9 7c 0e 00 00       	jmp    80103d64 <release>
  acquire(&p->lock);
  if(writable){
    p->writeopen = 0;
    wakeup(&p->nread);
  } else {
    p->readopen = 0;
80102ee8:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102eef:	00 00 00 
    wakeup(&p->nwrite);
80102ef2:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102ef8:	89 04 24             	mov    %eax,(%esp)
80102efb:	e8 30 0a 00 00       	call   80103930 <wakeup>
80102f00:	eb c4                	jmp    80102ec6 <pipeclose+0x32>
80102f02:	66 90                	xchg   %ax,%ax
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
80102f04:	89 1c 24             	mov    %ebx,(%esp)
80102f07:	e8 58 0e 00 00       	call   80103d64 <release>
    kfree((char*)p);
80102f0c:	89 5d 08             	mov    %ebx,0x8(%ebp)
  } else
    release(&p->lock);
}
80102f0f:	83 c4 10             	add    $0x10,%esp
80102f12:	5b                   	pop    %ebx
80102f13:	5e                   	pop    %esi
80102f14:	5d                   	pop    %ebp
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
    release(&p->lock);
    kfree((char*)p);
80102f15:	e9 7e f1 ff ff       	jmp    80102098 <kfree>
80102f1a:	66 90                	xchg   %ax,%ax

80102f1c <pipewrite>:
}

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80102f1c:	55                   	push   %ebp
80102f1d:	89 e5                	mov    %esp,%ebp
80102f1f:	57                   	push   %edi
80102f20:	56                   	push   %esi
80102f21:	53                   	push   %ebx
80102f22:	83 ec 2c             	sub    $0x2c,%esp
80102f25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102f28:	89 1c 24             	mov    %ebx,(%esp)
80102f2b:	e8 d0 0d 00 00       	call   80103d00 <acquire>
  for(i = 0; i < n; i++){
80102f30:	8b 45 10             	mov    0x10(%ebp),%eax
80102f33:	85 c0                	test   %eax,%eax
80102f35:	0f 8e 8a 00 00 00    	jle    80102fc5 <pipewrite+0xa9>
80102f3b:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102f41:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102f48:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f4e:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
80102f54:	eb 32                	jmp    80102f88 <pipewrite+0x6c>
80102f56:	66 90                	xchg   %ax,%ax
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
80102f58:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80102f5e:	85 c0                	test   %eax,%eax
80102f60:	74 7e                	je     80102fe0 <pipewrite+0xc4>
80102f62:	e8 49 03 00 00       	call   801032b0 <myproc>
80102f67:	8b 48 24             	mov    0x24(%eax),%ecx
80102f6a:	85 c9                	test   %ecx,%ecx
80102f6c:	75 72                	jne    80102fe0 <pipewrite+0xc4>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102f6e:	89 3c 24             	mov    %edi,(%esp)
80102f71:	e8 ba 09 00 00       	call   80103930 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f76:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80102f7a:	89 34 24             	mov    %esi,(%esp)
80102f7d:	e8 32 08 00 00       	call   801037b4 <sleep>
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102f82:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102f88:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
80102f8e:	81 c2 00 02 00 00    	add    $0x200,%edx
80102f94:	39 d0                	cmp    %edx,%eax
80102f96:	74 c0                	je     80102f58 <pipewrite+0x3c>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102f9b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102f9e:	8a 14 11             	mov    (%ecx,%edx,1),%dl
80102fa1:	88 55 e3             	mov    %dl,-0x1d(%ebp)
80102fa4:	89 c2                	mov    %eax,%edx
80102fa6:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102fac:	8a 4d e3             	mov    -0x1d(%ebp),%cl
80102faf:	88 4c 13 34          	mov    %cl,0x34(%ebx,%edx,1)
80102fb3:	40                   	inc    %eax
80102fb4:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80102fba:	ff 45 e4             	incl   -0x1c(%ebp)
80102fbd:	8b 55 10             	mov    0x10(%ebp),%edx
80102fc0:	39 55 e4             	cmp    %edx,-0x1c(%ebp)
80102fc3:	75 c3                	jne    80102f88 <pipewrite+0x6c>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102fc5:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fcb:	89 04 24             	mov    %eax,(%esp)
80102fce:	e8 5d 09 00 00       	call   80103930 <wakeup>
  release(&p->lock);
80102fd3:	89 1c 24             	mov    %ebx,(%esp)
80102fd6:	e8 89 0d 00 00       	call   80103d64 <release>
  return n;
80102fdb:	eb 12                	jmp    80102fef <pipewrite+0xd3>
80102fdd:	8d 76 00             	lea    0x0(%esi),%esi

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
80102fe0:	89 1c 24             	mov    %ebx,(%esp)
80102fe3:	e8 7c 0d 00 00       	call   80103d64 <release>
        return -1;
80102fe8:	c7 45 10 ff ff ff ff 	movl   $0xffffffff,0x10(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102fef:	8b 45 10             	mov    0x10(%ebp),%eax
80102ff2:	83 c4 2c             	add    $0x2c,%esp
80102ff5:	5b                   	pop    %ebx
80102ff6:	5e                   	pop    %esi
80102ff7:	5f                   	pop    %edi
80102ff8:	5d                   	pop    %ebp
80102ff9:	c3                   	ret    
80102ffa:	66 90                	xchg   %ax,%ax

80102ffc <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102ffc:	55                   	push   %ebp
80102ffd:	89 e5                	mov    %esp,%ebp
80102fff:	57                   	push   %edi
80103000:	56                   	push   %esi
80103001:	53                   	push   %ebx
80103002:	83 ec 2c             	sub    $0x2c,%esp
80103005:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103008:	8b 7d 10             	mov    0x10(%ebp),%edi
  int i;

  acquire(&p->lock);
8010300b:	89 1c 24             	mov    %ebx,(%esp)
8010300e:	e8 ed 0c 00 00       	call   80103d00 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103013:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
80103019:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
8010301f:	75 5b                	jne    8010307c <piperead+0x80>
80103021:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103027:	85 c0                	test   %eax,%eax
80103029:	74 51                	je     8010307c <piperead+0x80>
    if(myproc()->killed){
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010302b:	8d b3 34 02 00 00    	lea    0x234(%ebx),%esi
80103031:	eb 25                	jmp    80103058 <piperead+0x5c>
80103033:	90                   	nop
80103034:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80103038:	89 34 24             	mov    %esi,(%esp)
8010303b:	e8 74 07 00 00       	call   801037b4 <sleep>
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103040:	8b 93 34 02 00 00    	mov    0x234(%ebx),%edx
80103046:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
8010304c:	75 2e                	jne    8010307c <piperead+0x80>
8010304e:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103054:	85 c0                	test   %eax,%eax
80103056:	74 24                	je     8010307c <piperead+0x80>
    if(myproc()->killed){
80103058:	e8 53 02 00 00       	call   801032b0 <myproc>
8010305d:	8b 40 24             	mov    0x24(%eax),%eax
80103060:	85 c0                	test   %eax,%eax
80103062:	74 d0                	je     80103034 <piperead+0x38>
      release(&p->lock);
80103064:	89 1c 24             	mov    %ebx,(%esp)
80103067:	e8 f8 0c 00 00       	call   80103d64 <release>
      return -1;
8010306c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
  release(&p->lock);
  return i;
}
80103071:	83 c4 2c             	add    $0x2c,%esp
80103074:	5b                   	pop    %ebx
80103075:	5e                   	pop    %esi
80103076:	5f                   	pop    %edi
80103077:	5d                   	pop    %ebp
80103078:	c3                   	ret    
80103079:	8d 76 00             	lea    0x0(%esi),%esi
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
8010307c:	31 c0                	xor    %eax,%eax
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010307e:	85 ff                	test   %edi,%edi
80103080:	7e 35                	jle    801030b7 <piperead+0xbb>
    if(p->nread == p->nwrite)
80103082:	3b 93 38 02 00 00    	cmp    0x238(%ebx),%edx
80103088:	74 2d                	je     801030b7 <piperead+0xbb>
  release(&p->lock);
  return n;
}

int
piperead(struct pipe *p, char *addr, int n)
8010308a:	8b 75 0c             	mov    0xc(%ebp),%esi
8010308d:	29 d6                	sub    %edx,%esi
8010308f:	eb 0b                	jmp    8010309c <piperead+0xa0>
80103091:	8d 76 00             	lea    0x0(%esi),%esi
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(p->nread == p->nwrite)
80103094:	39 93 38 02 00 00    	cmp    %edx,0x238(%ebx)
8010309a:	74 1b                	je     801030b7 <piperead+0xbb>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010309c:	89 d1                	mov    %edx,%ecx
8010309e:	81 e1 ff 01 00 00    	and    $0x1ff,%ecx
801030a4:	8a 4c 0b 34          	mov    0x34(%ebx,%ecx,1),%cl
801030a8:	88 0c 16             	mov    %cl,(%esi,%edx,1)
801030ab:	42                   	inc    %edx
801030ac:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801030b2:	40                   	inc    %eax
801030b3:	39 f8                	cmp    %edi,%eax
801030b5:	75 dd                	jne    80103094 <piperead+0x98>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801030b7:	8d 93 38 02 00 00    	lea    0x238(%ebx),%edx
801030bd:	89 14 24             	mov    %edx,(%esp)
801030c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801030c3:	e8 68 08 00 00       	call   80103930 <wakeup>
  release(&p->lock);
801030c8:	89 1c 24             	mov    %ebx,(%esp)
801030cb:	e8 94 0c 00 00       	call   80103d64 <release>
801030d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  return i;
}
801030d3:	83 c4 2c             	add    $0x2c,%esp
801030d6:	5b                   	pop    %ebx
801030d7:	5e                   	pop    %esi
801030d8:	5f                   	pop    %edi
801030d9:	5d                   	pop    %ebp
801030da:	c3                   	ret    
	...

801030dc <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801030dc:	55                   	push   %ebp
801030dd:	89 e5                	mov    %esp,%ebp
801030df:	53                   	push   %ebx
801030e0:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801030e3:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801030ea:	e8 11 0c 00 00       	call   80103d00 <acquire>

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030ef:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
    if(p->state == UNUSED)
801030f4:	8b 15 60 1d 11 80    	mov    0x80111d60,%edx
801030fa:	85 d2                	test   %edx,%edx
801030fc:	74 14                	je     80103112 <allocproc+0x36>
801030fe:	66 90                	xchg   %ax,%ax
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103100:	83 c3 7c             	add    $0x7c,%ebx
80103103:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103109:	73 79                	jae    80103184 <allocproc+0xa8>
    if(p->state == UNUSED)
8010310b:	8b 43 0c             	mov    0xc(%ebx),%eax
8010310e:	85 c0                	test   %eax,%eax
80103110:	75 ee                	jne    80103100 <allocproc+0x24>

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80103112:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103119:	a1 00 90 10 80       	mov    0x80109000,%eax
8010311e:	89 43 10             	mov    %eax,0x10(%ebx)
80103121:	40                   	inc    %eax
80103122:	a3 00 90 10 80       	mov    %eax,0x80109000

  release(&ptable.lock);
80103127:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010312e:	e8 31 0c 00 00       	call   80103d64 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103133:	e8 a4 f0 ff ff       	call   801021dc <kalloc>
80103138:	89 43 08             	mov    %eax,0x8(%ebx)
8010313b:	85 c0                	test   %eax,%eax
8010313d:	74 5b                	je     8010319a <allocproc+0xbe>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010313f:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
80103145:	89 53 18             	mov    %edx,0x18(%ebx)
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;
80103148:	c7 80 b0 0f 00 00 b0 	movl   $0x80104db0,0xfb0(%eax)
8010314f:	4d 10 80 

  sp -= sizeof *p->context;
80103152:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103157:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010315a:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
80103161:	00 
80103162:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103169:	00 
8010316a:	89 04 24             	mov    %eax,(%esp)
8010316d:	e8 3a 0c 00 00       	call   80103dac <memset>
  p->context->eip = (uint)forkret;
80103172:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103175:	c7 40 10 a8 31 10 80 	movl   $0x801031a8,0x10(%eax)

  return p;
}
8010317c:	89 d8                	mov    %ebx,%eax
8010317e:	83 c4 14             	add    $0x14,%esp
80103181:	5b                   	pop    %ebx
80103182:	5d                   	pop    %ebp
80103183:	c3                   	ret    

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
80103184:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010318b:	e8 d4 0b 00 00       	call   80103d64 <release>
  return 0;
80103190:	31 db                	xor    %ebx,%ebx
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}
80103192:	89 d8                	mov    %ebx,%eax
80103194:	83 c4 14             	add    $0x14,%esp
80103197:	5b                   	pop    %ebx
80103198:	5d                   	pop    %ebp
80103199:	c3                   	ret    

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
8010319a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801031a1:	31 db                	xor    %ebx,%ebx
801031a3:	eb d7                	jmp    8010317c <allocproc+0xa0>
801031a5:	8d 76 00             	lea    0x0(%esi),%esi

801031a8 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801031a8:	55                   	push   %ebp
801031a9:	89 e5                	mov    %esp,%ebp
801031ab:	83 ec 18             	sub    $0x18,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801031ae:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801031b5:	e8 aa 0b 00 00       	call   80103d64 <release>

  if (first) {
801031ba:	8b 0d 04 90 10 80    	mov    0x80109004,%ecx
801031c0:	85 c9                	test   %ecx,%ecx
801031c2:	75 04                	jne    801031c8 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801031c4:	c9                   	leave  
801031c5:	c3                   	ret    
801031c6:	66 90                	xchg   %ax,%ax

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801031c8:	c7 05 04 90 10 80 00 	movl   $0x0,0x80109004
801031cf:	00 00 00 
    iinit(ROOTDEV);
801031d2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031d9:	e8 e6 e0 ff ff       	call   801012c4 <iinit>
    initlog(ROOTDEV);
801031de:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801031e5:	e8 5e f5 ff ff       	call   80102748 <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
801031ea:	c9                   	leave  
801031eb:	c3                   	ret    

801031ec <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801031ec:	55                   	push   %ebp
801031ed:	89 e5                	mov    %esp,%ebp
801031ef:	83 ec 18             	sub    $0x18,%esp
  initlock(&ptable.lock, "ptable");
801031f2:	c7 44 24 04 25 6a 10 	movl   $0x80106a25,0x4(%esp)
801031f9:	80 
801031fa:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103201:	e8 be 09 00 00       	call   80103bc4 <initlock>
}
80103206:	c9                   	leave  
80103207:	c3                   	ret    

80103208 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
80103208:	55                   	push   %ebp
80103209:	89 e5                	mov    %esp,%ebp
8010320b:	56                   	push   %esi
8010320c:	53                   	push   %ebx
8010320d:	83 ec 10             	sub    $0x10,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103210:	9c                   	pushf  
80103211:	58                   	pop    %eax
  int apicid, i;
  
  if(readeflags()&FL_IF)
80103212:	f6 c4 02             	test   $0x2,%ah
80103215:	75 58                	jne    8010326f <mycpu+0x67>
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
80103217:	e8 c8 f1 ff ff       	call   801023e4 <lapicid>
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
8010321c:	8b 35 00 1d 11 80    	mov    0x80111d00,%esi
80103222:	85 f6                	test   %esi,%esi
80103224:	7e 3d                	jle    80103263 <mycpu+0x5b>
    if (cpus[i].apicid == apicid)
80103226:	0f b6 15 80 17 11 80 	movzbl 0x80111780,%edx
8010322d:	39 c2                	cmp    %eax,%edx
8010322f:	74 2e                	je     8010325f <mycpu+0x57>
      return &cpus[i];
80103231:	b9 30 18 11 80       	mov    $0x80111830,%ecx
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
80103236:	31 d2                	xor    %edx,%edx
80103238:	42                   	inc    %edx
80103239:	39 f2                	cmp    %esi,%edx
8010323b:	74 26                	je     80103263 <mycpu+0x5b>
    if (cpus[i].apicid == apicid)
8010323d:	0f b6 19             	movzbl (%ecx),%ebx
80103240:	81 c1 b0 00 00 00    	add    $0xb0,%ecx
80103246:	39 c3                	cmp    %eax,%ebx
80103248:	75 ee                	jne    80103238 <mycpu+0x30>
      return &cpus[i];
8010324a:	8d 04 92             	lea    (%edx,%edx,4),%eax
8010324d:	8d 04 42             	lea    (%edx,%eax,2),%eax
80103250:	c1 e0 04             	shl    $0x4,%eax
80103253:	05 80 17 11 80       	add    $0x80111780,%eax
  }
  panic("unknown apicid\n");
}
80103258:	83 c4 10             	add    $0x10,%esp
8010325b:	5b                   	pop    %ebx
8010325c:	5e                   	pop    %esi
8010325d:	5d                   	pop    %ebp
8010325e:	c3                   	ret    
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
8010325f:	31 d2                	xor    %edx,%edx
80103261:	eb e7                	jmp    8010324a <mycpu+0x42>
      return &cpus[i];
  }
  panic("unknown apicid\n");
80103263:	c7 04 24 2c 6a 10 80 	movl   $0x80106a2c,(%esp)
8010326a:	e8 ad d0 ff ff       	call   8010031c <panic>
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
8010326f:	c7 04 24 08 6b 10 80 	movl   $0x80106b08,(%esp)
80103276:	e8 a1 d0 ff ff       	call   8010031c <panic>
8010327b:	90                   	nop

8010327c <cpuid>:
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
8010327c:	55                   	push   %ebp
8010327d:	89 e5                	mov    %esp,%ebp
8010327f:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103282:	e8 81 ff ff ff       	call   80103208 <mycpu>
80103287:	2d 80 17 11 80       	sub    $0x80111780,%eax
8010328c:	c1 f8 04             	sar    $0x4,%eax
8010328f:	8d 0c c0             	lea    (%eax,%eax,8),%ecx
80103292:	89 ca                	mov    %ecx,%edx
80103294:	c1 e2 05             	shl    $0x5,%edx
80103297:	29 ca                	sub    %ecx,%edx
80103299:	8d 14 90             	lea    (%eax,%edx,4),%edx
8010329c:	8d 0c d0             	lea    (%eax,%edx,8),%ecx
8010329f:	89 ca                	mov    %ecx,%edx
801032a1:	c1 e2 0f             	shl    $0xf,%edx
801032a4:	29 ca                	sub    %ecx,%edx
801032a6:	8d 04 90             	lea    (%eax,%edx,4),%eax
801032a9:	f7 d8                	neg    %eax
}
801032ab:	c9                   	leave  
801032ac:	c3                   	ret    
801032ad:	8d 76 00             	lea    0x0(%esi),%esi

801032b0 <myproc>:
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
801032b0:	55                   	push   %ebp
801032b1:	89 e5                	mov    %esp,%ebp
801032b3:	53                   	push   %ebx
801032b4:	53                   	push   %ebx
  struct cpu *c;
  struct proc *p;
  pushcli();
801032b5:	e8 72 09 00 00       	call   80103c2c <pushcli>
  c = mycpu();
801032ba:	e8 49 ff ff ff       	call   80103208 <mycpu>
  p = c->proc;
801032bf:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801032c5:	e8 9a 09 00 00       	call   80103c64 <popcli>
  return p;
}
801032ca:	89 d8                	mov    %ebx,%eax
801032cc:	5a                   	pop    %edx
801032cd:	5b                   	pop    %ebx
801032ce:	5d                   	pop    %ebp
801032cf:	c3                   	ret    

801032d0 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
801032d0:	55                   	push   %ebp
801032d1:	89 e5                	mov    %esp,%ebp
801032d3:	53                   	push   %ebx
801032d4:	83 ec 14             	sub    $0x14,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801032d7:	e8 00 fe ff ff       	call   801030dc <allocproc>
801032dc:	89 c3                	mov    %eax,%ebx
  
  initproc = p;
801032de:	a3 a0 95 10 80       	mov    %eax,0x801095a0
  if((p->pgdir = setupkvm()) == 0)
801032e3:	e8 a8 2f 00 00       	call   80106290 <setupkvm>
801032e8:	89 43 04             	mov    %eax,0x4(%ebx)
801032eb:	85 c0                	test   %eax,%eax
801032ed:	0f 84 cc 00 00 00    	je     801033bf <userinit+0xef>
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801032f3:	c7 44 24 08 2c 00 00 	movl   $0x2c,0x8(%esp)
801032fa:	00 
801032fb:	c7 44 24 04 60 94 10 	movl   $0x80109460,0x4(%esp)
80103302:	80 
80103303:	89 04 24             	mov    %eax,(%esp)
80103306:	e8 11 2c 00 00       	call   80105f1c <inituvm>
  p->sz = PGSIZE;
8010330b:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103311:	c7 44 24 08 4c 00 00 	movl   $0x4c,0x8(%esp)
80103318:	00 
80103319:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80103320:	00 
80103321:	8b 43 18             	mov    0x18(%ebx),%eax
80103324:	89 04 24             	mov    %eax,(%esp)
80103327:	e8 80 0a 00 00       	call   80103dac <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010332c:	8b 43 18             	mov    0x18(%ebx),%eax
8010332f:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103335:	8b 43 18             	mov    0x18(%ebx),%eax
80103338:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010333e:	8b 43 18             	mov    0x18(%ebx),%eax
80103341:	8b 50 2c             	mov    0x2c(%eax),%edx
80103344:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103348:	8b 43 18             	mov    0x18(%ebx),%eax
8010334b:	8b 50 2c             	mov    0x2c(%eax),%edx
8010334e:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103352:	8b 43 18             	mov    0x18(%ebx),%eax
80103355:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010335c:	8b 43 18             	mov    0x18(%ebx),%eax
8010335f:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103366:	8b 43 18             	mov    0x18(%ebx),%eax
80103369:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103370:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
80103377:	00 
80103378:	c7 44 24 04 55 6a 10 	movl   $0x80106a55,0x4(%esp)
8010337f:	80 
80103380:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103383:	89 04 24             	mov    %eax,(%esp)
80103386:	e8 ad 0b 00 00       	call   80103f38 <safestrcpy>
  p->cwd = namei("/");
8010338b:	c7 04 24 5e 6a 10 80 	movl   $0x80106a5e,(%esp)
80103392:	e8 81 e9 ff ff       	call   80101d18 <namei>
80103397:	89 43 68             	mov    %eax,0x68(%ebx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
8010339a:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801033a1:	e8 5a 09 00 00       	call   80103d00 <acquire>

  p->state = RUNNABLE;
801033a6:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)

  release(&ptable.lock);
801033ad:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801033b4:	e8 ab 09 00 00       	call   80103d64 <release>
}
801033b9:	83 c4 14             	add    $0x14,%esp
801033bc:	5b                   	pop    %ebx
801033bd:	5d                   	pop    %ebp
801033be:	c3                   	ret    

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
801033bf:	c7 04 24 3c 6a 10 80 	movl   $0x80106a3c,(%esp)
801033c6:	e8 51 cf ff ff       	call   8010031c <panic>
801033cb:	90                   	nop

801033cc <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801033cc:	55                   	push   %ebp
801033cd:	89 e5                	mov    %esp,%ebp
801033cf:	56                   	push   %esi
801033d0:	53                   	push   %ebx
801033d1:	83 ec 10             	sub    $0x10,%esp
801033d4:	8b 75 08             	mov    0x8(%ebp),%esi
  uint sz;
  struct proc *curproc = myproc();
801033d7:	e8 d4 fe ff ff       	call   801032b0 <myproc>
801033dc:	89 c3                	mov    %eax,%ebx

  sz = curproc->sz;
801033de:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801033e0:	83 fe 00             	cmp    $0x0,%esi
801033e3:	7e 2f                	jle    80103414 <growproc+0x48>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801033e5:	01 c6                	add    %eax,%esi
801033e7:	89 74 24 08          	mov    %esi,0x8(%esp)
801033eb:	89 44 24 04          	mov    %eax,0x4(%esp)
801033ef:	8b 43 04             	mov    0x4(%ebx),%eax
801033f2:	89 04 24             	mov    %eax,(%esp)
801033f5:	e8 0e 2d 00 00       	call   80106108 <allocuvm>
801033fa:	85 c0                	test   %eax,%eax
801033fc:	74 32                	je     80103430 <growproc+0x64>
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
801033fe:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103400:	89 1c 24             	mov    %ebx,(%esp)
80103403:	e8 18 2a 00 00       	call   80105e20 <switchuvm>
  return 0;
80103408:	31 c0                	xor    %eax,%eax
}
8010340a:	83 c4 10             	add    $0x10,%esp
8010340d:	5b                   	pop    %ebx
8010340e:	5e                   	pop    %esi
8010340f:	5d                   	pop    %ebp
80103410:	c3                   	ret    
80103411:	8d 76 00             	lea    0x0(%esi),%esi

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
80103414:	74 e8                	je     801033fe <growproc+0x32>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103416:	01 c6                	add    %eax,%esi
80103418:	89 74 24 08          	mov    %esi,0x8(%esp)
8010341c:	89 44 24 04          	mov    %eax,0x4(%esp)
80103420:	8b 43 04             	mov    0x4(%ebx),%eax
80103423:	89 04 24             	mov    %eax,(%esp)
80103426:	e8 35 2c 00 00       	call   80106060 <deallocuvm>
8010342b:	85 c0                	test   %eax,%eax
8010342d:	75 cf                	jne    801033fe <growproc+0x32>
8010342f:	90                   	nop
      return -1;
80103430:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103435:	eb d3                	jmp    8010340a <growproc+0x3e>
80103437:	90                   	nop

80103438 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103438:	55                   	push   %ebp
80103439:	89 e5                	mov    %esp,%ebp
8010343b:	57                   	push   %edi
8010343c:	56                   	push   %esi
8010343d:	53                   	push   %ebx
8010343e:	83 ec 2c             	sub    $0x2c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103441:	e8 6a fe ff ff       	call   801032b0 <myproc>
80103446:	89 c3                	mov    %eax,%ebx

  // Allocate process.
  if((np = allocproc()) == 0){
80103448:	e8 8f fc ff ff       	call   801030dc <allocproc>
8010344d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103450:	85 c0                	test   %eax,%eax
80103452:	0f 84 c0 00 00 00    	je     80103518 <fork+0xe0>
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103458:	8b 03                	mov    (%ebx),%eax
8010345a:	89 44 24 04          	mov    %eax,0x4(%esp)
8010345e:	8b 43 04             	mov    0x4(%ebx),%eax
80103461:	89 04 24             	mov    %eax,(%esp)
80103464:	e8 e3 2e 00 00       	call   8010634c <copyuvm>
80103469:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010346c:	89 42 04             	mov    %eax,0x4(%edx)
8010346f:	85 c0                	test   %eax,%eax
80103471:	0f 84 a8 00 00 00    	je     8010351f <fork+0xe7>
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
80103477:	8b 03                	mov    (%ebx),%eax
80103479:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010347c:	89 02                	mov    %eax,(%edx)
  np->parent = curproc;
8010347e:	89 5a 14             	mov    %ebx,0x14(%edx)
  *np->tf = *curproc->tf;
80103481:	8b 42 18             	mov    0x18(%edx),%eax
80103484:	8b 73 18             	mov    0x18(%ebx),%esi
80103487:	b9 13 00 00 00       	mov    $0x13,%ecx
8010348c:	89 c7                	mov    %eax,%edi
8010348e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103490:	8b 42 18             	mov    0x18(%edx),%eax
80103493:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010349a:	31 f6                	xor    %esi,%esi
    if(curproc->ofile[i])
8010349c:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801034a0:	85 c0                	test   %eax,%eax
801034a2:	74 0f                	je     801034b3 <fork+0x7b>
      np->ofile[i] = filedup(curproc->ofile[i]);
801034a4:	89 04 24             	mov    %eax,(%esp)
801034a7:	e8 28 d8 ff ff       	call   80100cd4 <filedup>
801034ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034af:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801034b3:	46                   	inc    %esi
801034b4:	83 fe 10             	cmp    $0x10,%esi
801034b7:	75 e3                	jne    8010349c <fork+0x64>
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
801034b9:	8b 43 68             	mov    0x68(%ebx),%eax
801034bc:	89 04 24             	mov    %eax,(%esp)
801034bf:	e8 f4 df ff ff       	call   801014b8 <idup>
801034c4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801034c7:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801034ca:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801034d1:	00 
801034d2:	83 c3 6c             	add    $0x6c,%ebx
801034d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801034d9:	89 d0                	mov    %edx,%eax
801034db:	83 c0 6c             	add    $0x6c,%eax
801034de:	89 04 24             	mov    %eax,(%esp)
801034e1:	e8 52 0a 00 00       	call   80103f38 <safestrcpy>

  pid = np->pid;
801034e6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034e9:	8b 58 10             	mov    0x10(%eax),%ebx

  acquire(&ptable.lock);
801034ec:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801034f3:	e8 08 08 00 00       	call   80103d00 <acquire>

  np->state = RUNNABLE;
801034f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801034fb:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103502:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103509:	e8 56 08 00 00       	call   80103d64 <release>

  return pid;
}
8010350e:	89 d8                	mov    %ebx,%eax
80103510:	83 c4 2c             	add    $0x2c,%esp
80103513:	5b                   	pop    %ebx
80103514:	5e                   	pop    %esi
80103515:	5f                   	pop    %edi
80103516:	5d                   	pop    %ebp
80103517:	c3                   	ret    
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
80103518:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010351d:	eb ef                	jmp    8010350e <fork+0xd6>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
8010351f:	8b 42 08             	mov    0x8(%edx),%eax
80103522:	89 04 24             	mov    %eax,(%esp)
80103525:	e8 6e eb ff ff       	call   80102098 <kfree>
    np->kstack = 0;
8010352a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010352d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103534:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
8010353b:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103540:	eb cc                	jmp    8010350e <fork+0xd6>
80103542:	66 90                	xchg   %ax,%ax

80103544 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80103544:	55                   	push   %ebp
80103545:	89 e5                	mov    %esp,%ebp
80103547:	57                   	push   %edi
80103548:	56                   	push   %esi
80103549:	53                   	push   %ebx
8010354a:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *p;
  struct cpu *c = mycpu();
8010354d:	e8 b6 fc ff ff       	call   80103208 <mycpu>
80103552:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103554:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010355b:	00 00 00 
8010355e:	8d 78 04             	lea    0x4(%eax),%edi
80103561:	8d 76 00             	lea    0x0(%esi),%esi
}

static inline void
sti(void)
{
  asm volatile("sti");
80103564:	fb                   	sti    
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80103565:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010356c:	e8 8f 07 00 00       	call   80103d00 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103571:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
80103576:	eb 0b                	jmp    80103583 <scheduler+0x3f>
80103578:	83 c3 7c             	add    $0x7c,%ebx
8010357b:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103581:	73 45                	jae    801035c8 <scheduler+0x84>
      if(p->state != RUNNABLE)
80103583:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103587:	75 ef                	jne    80103578 <scheduler+0x34>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80103589:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010358f:	89 1c 24             	mov    %ebx,(%esp)
80103592:	e8 89 28 00 00       	call   80105e20 <switchuvm>
      p->state = RUNNING;
80103597:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)

      swtch(&(c->scheduler), p->context);
8010359e:	8b 43 1c             	mov    0x1c(%ebx),%eax
801035a1:	89 44 24 04          	mov    %eax,0x4(%esp)
801035a5:	89 3c 24             	mov    %edi,(%esp)
801035a8:	e8 d3 09 00 00       	call   80103f80 <swtch>
      switchkvm();
801035ad:	e8 5a 28 00 00       	call   80105e0c <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
801035b2:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
801035b9:	00 00 00 
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035bc:	83 c3 7c             	add    $0x7c,%ebx
801035bf:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801035c5:	72 bc                	jb     80103583 <scheduler+0x3f>
801035c7:	90                   	nop

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);
801035c8:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801035cf:	e8 90 07 00 00       	call   80103d64 <release>

  }
801035d4:	eb 8e                	jmp    80103564 <scheduler+0x20>
801035d6:	66 90                	xchg   %ax,%ax

801035d8 <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801035d8:	55                   	push   %ebp
801035d9:	89 e5                	mov    %esp,%ebp
801035db:	56                   	push   %esi
801035dc:	53                   	push   %ebx
801035dd:	83 ec 10             	sub    $0x10,%esp
  int intena;
  struct proc *p = myproc();
801035e0:	e8 cb fc ff ff       	call   801032b0 <myproc>
801035e5:	89 c3                	mov    %eax,%ebx

  if(!holding(&ptable.lock))
801035e7:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801035ee:	e8 d1 06 00 00       	call   80103cc4 <holding>
801035f3:	85 c0                	test   %eax,%eax
801035f5:	74 4f                	je     80103646 <sched+0x6e>
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
801035f7:	e8 0c fc ff ff       	call   80103208 <mycpu>
801035fc:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103603:	75 65                	jne    8010366a <sched+0x92>
    panic("sched locks");
  if(p->state == RUNNING)
80103605:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103609:	74 53                	je     8010365e <sched+0x86>

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010360b:	9c                   	pushf  
8010360c:	58                   	pop    %eax
    panic("sched running");
  if(readeflags()&FL_IF)
8010360d:	f6 c4 02             	test   $0x2,%ah
80103610:	75 40                	jne    80103652 <sched+0x7a>
    panic("sched interruptible");
  intena = mycpu()->intena;
80103612:	e8 f1 fb ff ff       	call   80103208 <mycpu>
80103617:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010361d:	e8 e6 fb ff ff       	call   80103208 <mycpu>
80103622:	8b 40 04             	mov    0x4(%eax),%eax
80103625:	89 44 24 04          	mov    %eax,0x4(%esp)
80103629:	83 c3 1c             	add    $0x1c,%ebx
8010362c:	89 1c 24             	mov    %ebx,(%esp)
8010362f:	e8 4c 09 00 00       	call   80103f80 <swtch>
  mycpu()->intena = intena;
80103634:	e8 cf fb ff ff       	call   80103208 <mycpu>
80103639:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010363f:	83 c4 10             	add    $0x10,%esp
80103642:	5b                   	pop    %ebx
80103643:	5e                   	pop    %esi
80103644:	5d                   	pop    %ebp
80103645:	c3                   	ret    
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
80103646:	c7 04 24 60 6a 10 80 	movl   $0x80106a60,(%esp)
8010364d:	e8 ca cc ff ff       	call   8010031c <panic>
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
80103652:	c7 04 24 8c 6a 10 80 	movl   $0x80106a8c,(%esp)
80103659:	e8 be cc ff ff       	call   8010031c <panic>
  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
8010365e:	c7 04 24 7e 6a 10 80 	movl   $0x80106a7e,(%esp)
80103665:	e8 b2 cc ff ff       	call   8010031c <panic>
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
8010366a:	c7 04 24 72 6a 10 80 	movl   $0x80106a72,(%esp)
80103671:	e8 a6 cc ff ff       	call   8010031c <panic>
80103676:	66 90                	xchg   %ax,%ax

80103678 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103678:	55                   	push   %ebp
80103679:	89 e5                	mov    %esp,%ebp
8010367b:	56                   	push   %esi
8010367c:	53                   	push   %ebx
8010367d:	83 ec 10             	sub    $0x10,%esp
  struct proc *curproc = myproc();
80103680:	e8 2b fc ff ff       	call   801032b0 <myproc>
80103685:	89 c3                	mov    %eax,%ebx
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103687:	3b 05 a0 95 10 80    	cmp    0x801095a0,%eax
8010368d:	0f 84 e0 00 00 00    	je     80103773 <exit+0xfb>
80103693:	31 f6                	xor    %esi,%esi
80103695:	8d 76 00             	lea    0x0(%esi),%esi
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
80103698:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010369c:	85 c0                	test   %eax,%eax
8010369e:	74 10                	je     801036b0 <exit+0x38>
      fileclose(curproc->ofile[fd]);
801036a0:	89 04 24             	mov    %eax,(%esp)
801036a3:	e8 70 d6 ff ff       	call   80100d18 <fileclose>
      curproc->ofile[fd] = 0;
801036a8:	c7 44 b3 28 00 00 00 	movl   $0x0,0x28(%ebx,%esi,4)
801036af:	00 

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801036b0:	46                   	inc    %esi
801036b1:	83 fe 10             	cmp    $0x10,%esi
801036b4:	75 e2                	jne    80103698 <exit+0x20>
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
801036b6:	e8 25 f1 ff ff       	call   801027e0 <begin_op>
  iput(curproc->cwd);
801036bb:	8b 43 68             	mov    0x68(%ebx),%eax
801036be:	89 04 24             	mov    %eax,(%esp)
801036c1:	e8 32 df ff ff       	call   801015f8 <iput>
  end_op();
801036c6:	e8 75 f1 ff ff       	call   80102840 <end_op>
  curproc->cwd = 0;
801036cb:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)

  acquire(&ptable.lock);
801036d2:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801036d9:	e8 22 06 00 00       	call   80103d00 <acquire>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
801036de:	8b 43 14             	mov    0x14(%ebx),%eax
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801036e1:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
801036e6:	eb 0b                	jmp    801036f3 <exit+0x7b>
801036e8:	83 c2 7c             	add    $0x7c,%edx
801036eb:	81 fa 54 3c 11 80    	cmp    $0x80113c54,%edx
801036f1:	73 1d                	jae    80103710 <exit+0x98>
    if(p->state == SLEEPING && p->chan == chan)
801036f3:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801036f7:	75 ef                	jne    801036e8 <exit+0x70>
801036f9:	3b 42 20             	cmp    0x20(%edx),%eax
801036fc:	75 ea                	jne    801036e8 <exit+0x70>
      p->state = RUNNABLE;
801036fe:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103705:	83 c2 7c             	add    $0x7c,%edx
80103708:	81 fa 54 3c 11 80    	cmp    $0x80113c54,%edx
8010370e:	72 e3                	jb     801036f3 <exit+0x7b>
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
80103710:	a1 a0 95 10 80       	mov    0x801095a0,%eax
80103715:	b9 54 1d 11 80       	mov    $0x80111d54,%ecx
8010371a:	eb 0b                	jmp    80103727 <exit+0xaf>

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010371c:	83 c1 7c             	add    $0x7c,%ecx
8010371f:	81 f9 54 3c 11 80    	cmp    $0x80113c54,%ecx
80103725:	73 34                	jae    8010375b <exit+0xe3>
    if(p->parent == curproc){
80103727:	39 59 14             	cmp    %ebx,0x14(%ecx)
8010372a:	75 f0                	jne    8010371c <exit+0xa4>
      p->parent = initproc;
8010372c:	89 41 14             	mov    %eax,0x14(%ecx)
      if(p->state == ZOMBIE)
8010372f:	83 79 0c 05          	cmpl   $0x5,0xc(%ecx)
80103733:	75 e7                	jne    8010371c <exit+0xa4>
80103735:	ba 54 1d 11 80       	mov    $0x80111d54,%edx
8010373a:	eb 0b                	jmp    80103747 <exit+0xcf>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010373c:	83 c2 7c             	add    $0x7c,%edx
8010373f:	81 fa 54 3c 11 80    	cmp    $0x80113c54,%edx
80103745:	73 d5                	jae    8010371c <exit+0xa4>
    if(p->state == SLEEPING && p->chan == chan)
80103747:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
8010374b:	75 ef                	jne    8010373c <exit+0xc4>
8010374d:	3b 42 20             	cmp    0x20(%edx),%eax
80103750:	75 ea                	jne    8010373c <exit+0xc4>
      p->state = RUNNABLE;
80103752:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103759:	eb e1                	jmp    8010373c <exit+0xc4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
8010375b:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
80103762:	e8 71 fe ff ff       	call   801035d8 <sched>
  panic("zombie exit");
80103767:	c7 04 24 ad 6a 10 80 	movl   $0x80106aad,(%esp)
8010376e:	e8 a9 cb ff ff       	call   8010031c <panic>
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");
80103773:	c7 04 24 a0 6a 10 80 	movl   $0x80106aa0,(%esp)
8010377a:	e8 9d cb ff ff       	call   8010031c <panic>
8010377f:	90                   	nop

80103780 <yield>:
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
80103780:	55                   	push   %ebp
80103781:	89 e5                	mov    %esp,%ebp
80103783:	83 ec 18             	sub    $0x18,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103786:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010378d:	e8 6e 05 00 00       	call   80103d00 <acquire>
  myproc()->state = RUNNABLE;
80103792:	e8 19 fb ff ff       	call   801032b0 <myproc>
80103797:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010379e:	e8 35 fe ff ff       	call   801035d8 <sched>
  release(&ptable.lock);
801037a3:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801037aa:	e8 b5 05 00 00       	call   80103d64 <release>
}
801037af:	c9                   	leave  
801037b0:	c3                   	ret    
801037b1:	8d 76 00             	lea    0x0(%esi),%esi

801037b4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801037b4:	55                   	push   %ebp
801037b5:	89 e5                	mov    %esp,%ebp
801037b7:	57                   	push   %edi
801037b8:	56                   	push   %esi
801037b9:	53                   	push   %ebx
801037ba:	83 ec 1c             	sub    $0x1c,%esp
801037bd:	8b 75 08             	mov    0x8(%ebp),%esi
801037c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801037c3:	e8 e8 fa ff ff       	call   801032b0 <myproc>
801037c8:	89 c7                	mov    %eax,%edi
  
  if(p == 0)
801037ca:	85 c0                	test   %eax,%eax
801037cc:	74 7c                	je     8010384a <sleep+0x96>
    panic("sleep");

  if(lk == 0)
801037ce:	85 db                	test   %ebx,%ebx
801037d0:	74 6c                	je     8010383e <sleep+0x8a>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
801037d2:	81 fb 20 1d 11 80    	cmp    $0x80111d20,%ebx
801037d8:	74 46                	je     80103820 <sleep+0x6c>
    acquire(&ptable.lock);  //DOC: sleeplock1
801037da:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801037e1:	e8 1a 05 00 00       	call   80103d00 <acquire>
    release(lk);
801037e6:	89 1c 24             	mov    %ebx,(%esp)
801037e9:	e8 76 05 00 00       	call   80103d64 <release>
  }
  // Go to sleep.
  p->chan = chan;
801037ee:	89 77 20             	mov    %esi,0x20(%edi)
  p->state = SLEEPING;
801037f1:	c7 47 0c 02 00 00 00 	movl   $0x2,0xc(%edi)

  sched();
801037f8:	e8 db fd ff ff       	call   801035d8 <sched>

  // Tidy up.
  p->chan = 0;
801037fd:	c7 47 20 00 00 00 00 	movl   $0x0,0x20(%edi)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
80103804:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010380b:	e8 54 05 00 00       	call   80103d64 <release>
    acquire(lk);
80103810:	89 5d 08             	mov    %ebx,0x8(%ebp)
  }
}
80103813:	83 c4 1c             	add    $0x1c,%esp
80103816:	5b                   	pop    %ebx
80103817:	5e                   	pop    %esi
80103818:	5f                   	pop    %edi
80103819:	5d                   	pop    %ebp
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
8010381a:	e9 e1 04 00 00       	jmp    80103d00 <acquire>
8010381f:	90                   	nop
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
80103820:	89 70 20             	mov    %esi,0x20(%eax)
  p->state = SLEEPING;
80103823:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
8010382a:	e8 a9 fd ff ff       	call   801035d8 <sched>

  // Tidy up.
  p->chan = 0;
8010382f:	c7 47 20 00 00 00 00 	movl   $0x0,0x20(%edi)
  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}
80103836:	83 c4 1c             	add    $0x1c,%esp
80103839:	5b                   	pop    %ebx
8010383a:	5e                   	pop    %esi
8010383b:	5f                   	pop    %edi
8010383c:	5d                   	pop    %ebp
8010383d:	c3                   	ret    
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");
8010383e:	c7 04 24 bf 6a 10 80 	movl   $0x80106abf,(%esp)
80103845:	e8 d2 ca ff ff       	call   8010031c <panic>
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");
8010384a:	c7 04 24 b9 6a 10 80 	movl   $0x80106ab9,(%esp)
80103851:	e8 c6 ca ff ff       	call   8010031c <panic>
80103856:	66 90                	xchg   %ax,%ax

80103858 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103858:	55                   	push   %ebp
80103859:	89 e5                	mov    %esp,%ebp
8010385b:	56                   	push   %esi
8010385c:	53                   	push   %ebx
8010385d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103860:	e8 4b fa ff ff       	call   801032b0 <myproc>
80103865:	89 c6                	mov    %eax,%esi
  
  acquire(&ptable.lock);
80103867:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010386e:	e8 8d 04 00 00       	call   80103d00 <acquire>
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103873:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103875:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
8010387a:	eb 0b                	jmp    80103887 <wait+0x2f>
8010387c:	83 c3 7c             	add    $0x7c,%ebx
8010387f:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103885:	73 1d                	jae    801038a4 <wait+0x4c>
      if(p->parent != curproc)
80103887:	39 73 14             	cmp    %esi,0x14(%ebx)
8010388a:	75 f0                	jne    8010387c <wait+0x24>
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
8010388c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103890:	74 2f                	je     801038c1 <wait+0x69>
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
80103892:	b8 01 00 00 00       	mov    $0x1,%eax
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103897:	83 c3 7c             	add    $0x7c,%ebx
8010389a:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
801038a0:	72 e5                	jb     80103887 <wait+0x2f>
801038a2:	66 90                	xchg   %ax,%ax
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801038a4:	85 c0                	test   %eax,%eax
801038a6:	74 6e                	je     80103916 <wait+0xbe>
801038a8:	8b 4e 24             	mov    0x24(%esi),%ecx
801038ab:	85 c9                	test   %ecx,%ecx
801038ad:	75 67                	jne    80103916 <wait+0xbe>
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801038af:	c7 44 24 04 20 1d 11 	movl   $0x80111d20,0x4(%esp)
801038b6:	80 
801038b7:	89 34 24             	mov    %esi,(%esp)
801038ba:	e8 f5 fe ff ff       	call   801037b4 <sleep>
  }
801038bf:	eb b2                	jmp    80103873 <wait+0x1b>
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
801038c1:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801038c4:	8b 43 08             	mov    0x8(%ebx),%eax
801038c7:	89 04 24             	mov    %eax,(%esp)
801038ca:	e8 c9 e7 ff ff       	call   80102098 <kfree>
        p->kstack = 0;
801038cf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801038d6:	8b 43 04             	mov    0x4(%ebx),%eax
801038d9:	89 04 24             	mov    %eax,(%esp)
801038dc:	e8 3b 29 00 00       	call   8010621c <freevm>
        p->pid = 0;
801038e1:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801038e8:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801038ef:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801038f3:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801038fa:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103901:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103908:	e8 57 04 00 00       	call   80103d64 <release>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
8010390d:	89 f0                	mov    %esi,%eax
8010390f:	83 c4 10             	add    $0x10,%esp
80103912:	5b                   	pop    %ebx
80103913:	5e                   	pop    %esi
80103914:	5d                   	pop    %ebp
80103915:	c3                   	ret    
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
80103916:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010391d:	e8 42 04 00 00       	call   80103d64 <release>
      return -1;
80103922:	be ff ff ff ff       	mov    $0xffffffff,%esi
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}
80103927:	89 f0                	mov    %esi,%eax
80103929:	83 c4 10             	add    $0x10,%esp
8010392c:	5b                   	pop    %ebx
8010392d:	5e                   	pop    %esi
8010392e:	5d                   	pop    %ebp
8010392f:	c3                   	ret    

80103930 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103930:	55                   	push   %ebp
80103931:	89 e5                	mov    %esp,%ebp
80103933:	53                   	push   %ebx
80103934:	83 ec 14             	sub    $0x14,%esp
80103937:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010393a:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
80103941:	e8 ba 03 00 00       	call   80103d00 <acquire>
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103946:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
8010394b:	eb 0d                	jmp    8010395a <wakeup+0x2a>
8010394d:	8d 76 00             	lea    0x0(%esi),%esi
80103950:	83 c0 7c             	add    $0x7c,%eax
80103953:	3d 54 3c 11 80       	cmp    $0x80113c54,%eax
80103958:	73 1e                	jae    80103978 <wakeup+0x48>
    if(p->state == SLEEPING && p->chan == chan)
8010395a:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
8010395e:	75 f0                	jne    80103950 <wakeup+0x20>
80103960:	3b 58 20             	cmp    0x20(%eax),%ebx
80103963:	75 eb                	jne    80103950 <wakeup+0x20>
      p->state = RUNNABLE;
80103965:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010396c:	83 c0 7c             	add    $0x7c,%eax
8010396f:	3d 54 3c 11 80       	cmp    $0x80113c54,%eax
80103974:	72 e4                	jb     8010395a <wakeup+0x2a>
80103976:	66 90                	xchg   %ax,%ax
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80103978:	c7 45 08 20 1d 11 80 	movl   $0x80111d20,0x8(%ebp)
}
8010397f:	83 c4 14             	add    $0x14,%esp
80103982:	5b                   	pop    %ebx
80103983:	5d                   	pop    %ebp
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
80103984:	e9 db 03 00 00       	jmp    80103d64 <release>
80103989:	8d 76 00             	lea    0x0(%esi),%esi

8010398c <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010398c:	55                   	push   %ebp
8010398d:	89 e5                	mov    %esp,%ebp
8010398f:	53                   	push   %ebx
80103990:	83 ec 14             	sub    $0x14,%esp
80103993:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103996:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
8010399d:	e8 5e 03 00 00       	call   80103d00 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039a2:	b8 54 1d 11 80       	mov    $0x80111d54,%eax
    if(p->pid == pid){
801039a7:	39 1d 64 1d 11 80    	cmp    %ebx,0x80111d64
801039ad:	74 10                	je     801039bf <kill+0x33>
801039af:	90                   	nop
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039b0:	83 c0 7c             	add    $0x7c,%eax
801039b3:	3d 54 3c 11 80       	cmp    $0x80113c54,%eax
801039b8:	73 32                	jae    801039ec <kill+0x60>
    if(p->pid == pid){
801039ba:	39 58 10             	cmp    %ebx,0x10(%eax)
801039bd:	75 f1                	jne    801039b0 <kill+0x24>
      p->killed = 1;
801039bf:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801039c6:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801039ca:	74 14                	je     801039e0 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
801039cc:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801039d3:	e8 8c 03 00 00       	call   80103d64 <release>
      return 0;
801039d8:	31 c0                	xor    %eax,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801039da:	83 c4 14             	add    $0x14,%esp
801039dd:	5b                   	pop    %ebx
801039de:	5d                   	pop    %ebp
801039df:	c3                   	ret    
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
801039e0:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801039e7:	eb e3                	jmp    801039cc <kill+0x40>
801039e9:	8d 76 00             	lea    0x0(%esi),%esi
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
801039ec:	c7 04 24 20 1d 11 80 	movl   $0x80111d20,(%esp)
801039f3:	e8 6c 03 00 00       	call   80103d64 <release>
  return -1;
801039f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801039fd:	83 c4 14             	add    $0x14,%esp
80103a00:	5b                   	pop    %ebx
80103a01:	5d                   	pop    %ebp
80103a02:	c3                   	ret    
80103a03:	90                   	nop

80103a04 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103a04:	55                   	push   %ebp
80103a05:	89 e5                	mov    %esp,%ebp
80103a07:	57                   	push   %edi
80103a08:	56                   	push   %esi
80103a09:	53                   	push   %ebx
80103a0a:	83 ec 4c             	sub    $0x4c,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a0d:	bb 54 1d 11 80       	mov    $0x80111d54,%ebx
//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
80103a12:	8d 7d e8             	lea    -0x18(%ebp),%edi
80103a15:	eb 47                	jmp    80103a5e <procdump+0x5a>
80103a17:	90                   	nop
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a18:	8b 04 85 30 6b 10 80 	mov    -0x7fef94d0(,%eax,4),%eax
80103a1f:	85 c0                	test   %eax,%eax
80103a21:	74 47                	je     80103a6a <procdump+0x66>
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
80103a23:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a26:	89 54 24 0c          	mov    %edx,0xc(%esp)
80103a2a:	89 44 24 08          	mov    %eax,0x8(%esp)
80103a2e:	8b 43 10             	mov    0x10(%ebx),%eax
80103a31:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a35:	c7 04 24 d4 6a 10 80 	movl   $0x80106ad4,(%esp)
80103a3c:	e8 7b cb ff ff       	call   801005bc <cprintf>
    if(p->state == SLEEPING){
80103a41:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a45:	74 2d                	je     80103a74 <procdump+0x70>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a47:	c7 04 24 37 6e 10 80 	movl   $0x80106e37,(%esp)
80103a4e:	e8 69 cb ff ff       	call   801005bc <cprintf>
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a53:	83 c3 7c             	add    $0x7c,%ebx
80103a56:	81 fb 54 3c 11 80    	cmp    $0x80113c54,%ebx
80103a5c:	73 52                	jae    80103ab0 <procdump+0xac>
    if(p->state == UNUSED)
80103a5e:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a61:	85 c0                	test   %eax,%eax
80103a63:	74 ee                	je     80103a53 <procdump+0x4f>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a65:	83 f8 05             	cmp    $0x5,%eax
80103a68:	76 ae                	jbe    80103a18 <procdump+0x14>
      state = states[p->state];
    else
      state = "???";
80103a6a:	b8 d0 6a 10 80       	mov    $0x80106ad0,%eax
80103a6f:	eb b2                	jmp    80103a23 <procdump+0x1f>
80103a71:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a74:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103a77:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a7b:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a7e:	8b 40 0c             	mov    0xc(%eax),%eax
80103a81:	83 c0 08             	add    $0x8,%eax
80103a84:	89 04 24             	mov    %eax,(%esp)
80103a87:	e8 54 01 00 00       	call   80103be0 <getcallerpcs>
80103a8c:	8d 75 c0             	lea    -0x40(%ebp),%esi
80103a8f:	90                   	nop
      for(i=0; i<10 && pc[i] != 0; i++)
80103a90:	8b 06                	mov    (%esi),%eax
80103a92:	85 c0                	test   %eax,%eax
80103a94:	74 b1                	je     80103a47 <procdump+0x43>
        cprintf(" %p", pc[i]);
80103a96:	89 44 24 04          	mov    %eax,0x4(%esp)
80103a9a:	c7 04 24 21 65 10 80 	movl   $0x80106521,(%esp)
80103aa1:	e8 16 cb ff ff       	call   801005bc <cprintf>
80103aa6:	83 c6 04             	add    $0x4,%esi
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
80103aa9:	39 fe                	cmp    %edi,%esi
80103aab:	75 e3                	jne    80103a90 <procdump+0x8c>
80103aad:	eb 98                	jmp    80103a47 <procdump+0x43>
80103aaf:	90                   	nop
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
80103ab0:	83 c4 4c             	add    $0x4c,%esp
80103ab3:	5b                   	pop    %ebx
80103ab4:	5e                   	pop    %esi
80103ab5:	5f                   	pop    %edi
80103ab6:	5d                   	pop    %ebp
80103ab7:	c3                   	ret    

80103ab8 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103ab8:	55                   	push   %ebp
80103ab9:	89 e5                	mov    %esp,%ebp
80103abb:	53                   	push   %ebx
80103abc:	83 ec 14             	sub    $0x14,%esp
80103abf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103ac2:	c7 44 24 04 48 6b 10 	movl   $0x80106b48,0x4(%esp)
80103ac9:	80 
80103aca:	8d 43 04             	lea    0x4(%ebx),%eax
80103acd:	89 04 24             	mov    %eax,(%esp)
80103ad0:	e8 ef 00 00 00       	call   80103bc4 <initlock>
  lk->name = name;
80103ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ad8:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103adb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ae1:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103ae8:	83 c4 14             	add    $0x14,%esp
80103aeb:	5b                   	pop    %ebx
80103aec:	5d                   	pop    %ebp
80103aed:	c3                   	ret    
80103aee:	66 90                	xchg   %ax,%ax

80103af0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103af0:	55                   	push   %ebp
80103af1:	89 e5                	mov    %esp,%ebp
80103af3:	56                   	push   %esi
80103af4:	53                   	push   %ebx
80103af5:	83 ec 10             	sub    $0x10,%esp
80103af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103afb:	8d 73 04             	lea    0x4(%ebx),%esi
80103afe:	89 34 24             	mov    %esi,(%esp)
80103b01:	e8 fa 01 00 00       	call   80103d00 <acquire>
  while (lk->locked) {
80103b06:	8b 13                	mov    (%ebx),%edx
80103b08:	85 d2                	test   %edx,%edx
80103b0a:	74 12                	je     80103b1e <acquiresleep+0x2e>
    sleep(lk, &lk->lk);
80103b0c:	89 74 24 04          	mov    %esi,0x4(%esp)
80103b10:	89 1c 24             	mov    %ebx,(%esp)
80103b13:	e8 9c fc ff ff       	call   801037b4 <sleep>

void
acquiresleep(struct sleeplock *lk)
{
  acquire(&lk->lk);
  while (lk->locked) {
80103b18:	8b 03                	mov    (%ebx),%eax
80103b1a:	85 c0                	test   %eax,%eax
80103b1c:	75 ee                	jne    80103b0c <acquiresleep+0x1c>
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
80103b1e:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b24:	e8 87 f7 ff ff       	call   801032b0 <myproc>
80103b29:	8b 40 10             	mov    0x10(%eax),%eax
80103b2c:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b2f:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103b32:	83 c4 10             	add    $0x10,%esp
80103b35:	5b                   	pop    %ebx
80103b36:	5e                   	pop    %esi
80103b37:	5d                   	pop    %ebp
  while (lk->locked) {
    sleep(lk, &lk->lk);
  }
  lk->locked = 1;
  lk->pid = myproc()->pid;
  release(&lk->lk);
80103b38:	e9 27 02 00 00       	jmp    80103d64 <release>
80103b3d:	8d 76 00             	lea    0x0(%esi),%esi

80103b40 <releasesleep>:
}

void
releasesleep(struct sleeplock *lk)
{
80103b40:	55                   	push   %ebp
80103b41:	89 e5                	mov    %esp,%ebp
80103b43:	56                   	push   %esi
80103b44:	53                   	push   %ebx
80103b45:	83 ec 10             	sub    $0x10,%esp
80103b48:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b4b:	8d 73 04             	lea    0x4(%ebx),%esi
80103b4e:	89 34 24             	mov    %esi,(%esp)
80103b51:	e8 aa 01 00 00       	call   80103d00 <acquire>
  lk->locked = 0;
80103b56:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b5c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103b63:	89 1c 24             	mov    %ebx,(%esp)
80103b66:	e8 c5 fd ff ff       	call   80103930 <wakeup>
  release(&lk->lk);
80103b6b:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103b6e:	83 c4 10             	add    $0x10,%esp
80103b71:	5b                   	pop    %ebx
80103b72:	5e                   	pop    %esi
80103b73:	5d                   	pop    %ebp
{
  acquire(&lk->lk);
  lk->locked = 0;
  lk->pid = 0;
  wakeup(lk);
  release(&lk->lk);
80103b74:	e9 eb 01 00 00       	jmp    80103d64 <release>
80103b79:	8d 76 00             	lea    0x0(%esi),%esi

80103b7c <holdingsleep>:
}

int
holdingsleep(struct sleeplock *lk)
{
80103b7c:	55                   	push   %ebp
80103b7d:	89 e5                	mov    %esp,%ebp
80103b7f:	56                   	push   %esi
80103b80:	53                   	push   %ebx
80103b81:	83 ec 10             	sub    $0x10,%esp
80103b84:	8b 75 08             	mov    0x8(%ebp),%esi
  int r;
  
  acquire(&lk->lk);
80103b87:	8d 5e 04             	lea    0x4(%esi),%ebx
80103b8a:	89 1c 24             	mov    %ebx,(%esp)
80103b8d:	e8 6e 01 00 00       	call   80103d00 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103b92:	8b 0e                	mov    (%esi),%ecx
80103b94:	85 c9                	test   %ecx,%ecx
80103b96:	75 14                	jne    80103bac <holdingsleep+0x30>
80103b98:	31 f6                	xor    %esi,%esi
  release(&lk->lk);
80103b9a:	89 1c 24             	mov    %ebx,(%esp)
80103b9d:	e8 c2 01 00 00       	call   80103d64 <release>
  return r;
}
80103ba2:	89 f0                	mov    %esi,%eax
80103ba4:	83 c4 10             	add    $0x10,%esp
80103ba7:	5b                   	pop    %ebx
80103ba8:	5e                   	pop    %esi
80103ba9:	5d                   	pop    %ebp
80103baa:	c3                   	ret    
80103bab:	90                   	nop
holdingsleep(struct sleeplock *lk)
{
  int r;
  
  acquire(&lk->lk);
  r = lk->locked && (lk->pid == myproc()->pid);
80103bac:	8b 76 3c             	mov    0x3c(%esi),%esi
80103baf:	e8 fc f6 ff ff       	call   801032b0 <myproc>
80103bb4:	3b 70 10             	cmp    0x10(%eax),%esi
80103bb7:	0f 94 c0             	sete   %al
80103bba:	0f b6 c0             	movzbl %al,%eax
80103bbd:	89 c6                	mov    %eax,%esi
80103bbf:	eb d9                	jmp    80103b9a <holdingsleep+0x1e>
80103bc1:	00 00                	add    %al,(%eax)
	...

80103bc4 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103bc4:	55                   	push   %ebp
80103bc5:	89 e5                	mov    %esp,%ebp
80103bc7:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103bca:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bcd:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103bd0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103bd6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103bdd:	5d                   	pop    %ebp
80103bde:	c3                   	ret    
80103bdf:	90                   	nop

80103be0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103be0:	55                   	push   %ebp
80103be1:	89 e5                	mov    %esp,%ebp
80103be3:	53                   	push   %ebx
80103be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103be7:	8b 55 08             	mov    0x8(%ebp),%edx
80103bea:	83 ea 08             	sub    $0x8,%edx
  for(i = 0; i < 10; i++){
80103bed:	31 c0                	xor    %eax,%eax
80103bef:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103bf0:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103bf6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103bfc:	77 12                	ja     80103c10 <getcallerpcs+0x30>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103bfe:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c01:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c04:	8b 12                	mov    (%edx),%edx
{
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80103c06:	40                   	inc    %eax
80103c07:	83 f8 0a             	cmp    $0xa,%eax
80103c0a:	75 e4                	jne    80103bf0 <getcallerpcs+0x10>
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
80103c0c:	5b                   	pop    %ebx
80103c0d:	5d                   	pop    %ebp
80103c0e:	c3                   	ret    
80103c0f:	90                   	nop
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c10:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80103c17:	40                   	inc    %eax
80103c18:	83 f8 0a             	cmp    $0xa,%eax
80103c1b:	74 ef                	je     80103c0c <getcallerpcs+0x2c>
    pcs[i] = 0;
80103c1d:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
80103c24:	40                   	inc    %eax
80103c25:	83 f8 0a             	cmp    $0xa,%eax
80103c28:	75 e6                	jne    80103c10 <getcallerpcs+0x30>
80103c2a:	eb e0                	jmp    80103c0c <getcallerpcs+0x2c>

80103c2c <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c2c:	55                   	push   %ebp
80103c2d:	89 e5                	mov    %esp,%ebp
80103c2f:	53                   	push   %ebx
80103c30:	52                   	push   %edx
80103c31:	9c                   	pushf  
80103c32:	5b                   	pop    %ebx
}

static inline void
cli(void)
{
  asm volatile("cli");
80103c33:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c34:	e8 cf f5 ff ff       	call   80103208 <mycpu>
80103c39:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103c3f:	85 c9                	test   %ecx,%ecx
80103c41:	75 11                	jne    80103c54 <pushcli+0x28>
    mycpu()->intena = eflags & FL_IF;
80103c43:	e8 c0 f5 ff ff       	call   80103208 <mycpu>
80103c48:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103c4e:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
  mycpu()->ncli += 1;
80103c54:	e8 af f5 ff ff       	call   80103208 <mycpu>
80103c59:	ff 80 a4 00 00 00    	incl   0xa4(%eax)
}
80103c5f:	58                   	pop    %eax
80103c60:	5b                   	pop    %ebx
80103c61:	5d                   	pop    %ebp
80103c62:	c3                   	ret    
80103c63:	90                   	nop

80103c64 <popcli>:

void
popcli(void)
{
80103c64:	55                   	push   %ebp
80103c65:	89 e5                	mov    %esp,%ebp
80103c67:	83 ec 18             	sub    $0x18,%esp

static inline uint
readeflags(void)
{
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c6a:	9c                   	pushf  
80103c6b:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103c6c:	f6 c4 02             	test   $0x2,%ah
80103c6f:	75 45                	jne    80103cb6 <popcli+0x52>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103c71:	e8 92 f5 ff ff       	call   80103208 <mycpu>
80103c76:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80103c7c:	4a                   	dec    %edx
80103c7d:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103c83:	85 d2                	test   %edx,%edx
80103c85:	78 23                	js     80103caa <popcli+0x46>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c87:	e8 7c f5 ff ff       	call   80103208 <mycpu>
80103c8c:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80103c92:	85 c0                	test   %eax,%eax
80103c94:	74 02                	je     80103c98 <popcli+0x34>
    sti();
}
80103c96:	c9                   	leave  
80103c97:	c3                   	ret    
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c98:	e8 6b f5 ff ff       	call   80103208 <mycpu>
80103c9d:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103ca3:	85 c0                	test   %eax,%eax
80103ca5:	74 ef                	je     80103c96 <popcli+0x32>
}

static inline void
sti(void)
{
  asm volatile("sti");
80103ca7:	fb                   	sti    
    sti();
}
80103ca8:	c9                   	leave  
80103ca9:	c3                   	ret    
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
    panic("popcli");
80103caa:	c7 04 24 6a 6b 10 80 	movl   $0x80106b6a,(%esp)
80103cb1:	e8 66 c6 ff ff       	call   8010031c <panic>

void
popcli(void)
{
  if(readeflags()&FL_IF)
    panic("popcli - interruptible");
80103cb6:	c7 04 24 53 6b 10 80 	movl   $0x80106b53,(%esp)
80103cbd:	e8 5a c6 ff ff       	call   8010031c <panic>
80103cc2:	66 90                	xchg   %ax,%ax

80103cc4 <holding>:
}

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80103cc4:	55                   	push   %ebp
80103cc5:	89 e5                	mov    %esp,%ebp
80103cc7:	53                   	push   %ebx
80103cc8:	51                   	push   %ecx
80103cc9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  pushcli();
80103ccc:	e8 5b ff ff ff       	call   80103c2c <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103cd1:	8b 03                	mov    (%ebx),%eax
80103cd3:	85 c0                	test   %eax,%eax
80103cd5:	75 0d                	jne    80103ce4 <holding+0x20>
80103cd7:	31 db                	xor    %ebx,%ebx
  popcli();
80103cd9:	e8 86 ff ff ff       	call   80103c64 <popcli>
  return r;
}
80103cde:	89 d8                	mov    %ebx,%eax
80103ce0:	5a                   	pop    %edx
80103ce1:	5b                   	pop    %ebx
80103ce2:	5d                   	pop    %ebp
80103ce3:	c3                   	ret    
int
holding(struct spinlock *lock)
{
  int r;
  pushcli();
  r = lock->locked && lock->cpu == mycpu();
80103ce4:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103ce7:	e8 1c f5 ff ff       	call   80103208 <mycpu>
80103cec:	39 c3                	cmp    %eax,%ebx
80103cee:	0f 94 c3             	sete   %bl
80103cf1:	0f b6 db             	movzbl %bl,%ebx
  popcli();
80103cf4:	e8 6b ff ff ff       	call   80103c64 <popcli>
  return r;
}
80103cf9:	89 d8                	mov    %ebx,%eax
80103cfb:	5a                   	pop    %edx
80103cfc:	5b                   	pop    %ebx
80103cfd:	5d                   	pop    %ebp
80103cfe:	c3                   	ret    
80103cff:	90                   	nop

80103d00 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80103d00:	55                   	push   %ebp
80103d01:	89 e5                	mov    %esp,%ebp
80103d03:	53                   	push   %ebx
80103d04:	83 ec 14             	sub    $0x14,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d07:	e8 20 ff ff ff       	call   80103c2c <pushcli>
  if(holding(lk))
80103d0c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d0f:	89 04 24             	mov    %eax,(%esp)
80103d12:	e8 ad ff ff ff       	call   80103cc4 <holding>
80103d17:	85 c0                	test   %eax,%eax
80103d19:	75 3c                	jne    80103d57 <acquire+0x57>
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103d1b:	b9 01 00 00 00       	mov    $0x1,%ecx
    panic("acquire");

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80103d20:	8b 55 08             	mov    0x8(%ebp),%edx
80103d23:	89 c8                	mov    %ecx,%eax
80103d25:	f0 87 02             	lock xchg %eax,(%edx)
80103d28:	85 c0                	test   %eax,%eax
80103d2a:	75 f4                	jne    80103d20 <acquire+0x20>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80103d2c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
80103d31:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d34:	e8 cf f4 ff ff       	call   80103208 <mycpu>
80103d39:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d3f:	83 c0 0c             	add    $0xc,%eax
80103d42:	89 44 24 04          	mov    %eax,0x4(%esp)
80103d46:	8d 45 08             	lea    0x8(%ebp),%eax
80103d49:	89 04 24             	mov    %eax,(%esp)
80103d4c:	e8 8f fe ff ff       	call   80103be0 <getcallerpcs>
}
80103d51:	83 c4 14             	add    $0x14,%esp
80103d54:	5b                   	pop    %ebx
80103d55:	5d                   	pop    %ebp
80103d56:	c3                   	ret    
void
acquire(struct spinlock *lk)
{
  pushcli(); // disable interrupts to avoid deadlock.
  if(holding(lk))
    panic("acquire");
80103d57:	c7 04 24 71 6b 10 80 	movl   $0x80106b71,(%esp)
80103d5e:	e8 b9 c5 ff ff       	call   8010031c <panic>
80103d63:	90                   	nop

80103d64 <release>:
}

// Release the lock.
void
release(struct spinlock *lk)
{
80103d64:	55                   	push   %ebp
80103d65:	89 e5                	mov    %esp,%ebp
80103d67:	53                   	push   %ebx
80103d68:	83 ec 14             	sub    $0x14,%esp
80103d6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103d6e:	89 1c 24             	mov    %ebx,(%esp)
80103d71:	e8 4e ff ff ff       	call   80103cc4 <holding>
80103d76:	85 c0                	test   %eax,%eax
80103d78:	74 23                	je     80103d9d <release+0x39>
    panic("release");

  lk->pcs[0] = 0;
80103d7a:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103d81:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
80103d88:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103d8d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

  popcli();
}
80103d93:	83 c4 14             	add    $0x14,%esp
80103d96:	5b                   	pop    %ebx
80103d97:	5d                   	pop    %ebp
  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );

  popcli();
80103d98:	e9 c7 fe ff ff       	jmp    80103c64 <popcli>
// Release the lock.
void
release(struct spinlock *lk)
{
  if(!holding(lk))
    panic("release");
80103d9d:	c7 04 24 79 6b 10 80 	movl   $0x80106b79,(%esp)
80103da4:	e8 73 c5 ff ff       	call   8010031c <panic>
80103da9:	00 00                	add    %al,(%eax)
	...

80103dac <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103dac:	55                   	push   %ebp
80103dad:	89 e5                	mov    %esp,%ebp
80103daf:	57                   	push   %edi
80103db0:	53                   	push   %ebx
80103db1:	8b 55 08             	mov    0x8(%ebp),%edx
80103db4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db7:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103dba:	f6 c2 03             	test   $0x3,%dl
80103dbd:	75 05                	jne    80103dc4 <memset+0x18>
80103dbf:	f6 c1 03             	test   $0x3,%cl
80103dc2:	74 0c                	je     80103dd0 <memset+0x24>
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
80103dc4:	89 d7                	mov    %edx,%edi
80103dc6:	fc                   	cld    
80103dc7:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103dc9:	89 d0                	mov    %edx,%eax
80103dcb:	5b                   	pop    %ebx
80103dcc:	5f                   	pop    %edi
80103dcd:	5d                   	pop    %ebp
80103dce:	c3                   	ret    
80103dcf:	90                   	nop

void*
memset(void *dst, int c, uint n)
{
  if ((int)dst%4 == 0 && n%4 == 0){
    c &= 0xFF;
80103dd0:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103dd3:	c1 e9 02             	shr    $0x2,%ecx
80103dd6:	89 f8                	mov    %edi,%eax
80103dd8:	c1 e0 18             	shl    $0x18,%eax
80103ddb:	89 fb                	mov    %edi,%ebx
80103ddd:	c1 e3 10             	shl    $0x10,%ebx
80103de0:	09 d8                	or     %ebx,%eax
80103de2:	09 f8                	or     %edi,%eax
80103de4:	c1 e7 08             	shl    $0x8,%edi
80103de7:	09 f8                	or     %edi,%eax
}

static inline void
stosl(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosl" :
80103de9:	89 d7                	mov    %edx,%edi
80103deb:	fc                   	cld    
80103dec:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80103dee:	89 d0                	mov    %edx,%eax
80103df0:	5b                   	pop    %ebx
80103df1:	5f                   	pop    %edi
80103df2:	5d                   	pop    %ebp
80103df3:	c3                   	ret    

80103df4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103df4:	55                   	push   %ebp
80103df5:	89 e5                	mov    %esp,%ebp
80103df7:	57                   	push   %edi
80103df8:	56                   	push   %esi
80103df9:	53                   	push   %ebx
80103dfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103dfd:	8b 75 0c             	mov    0xc(%ebp),%esi
80103e00:	8b 7d 10             	mov    0x10(%ebp),%edi
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e03:	85 ff                	test   %edi,%edi
80103e05:	74 1d                	je     80103e24 <memcmp+0x30>
    if(*s1 != *s2)
80103e07:	8a 03                	mov    (%ebx),%al
80103e09:	8a 0e                	mov    (%esi),%cl
80103e0b:	38 c8                	cmp    %cl,%al
80103e0d:	75 1d                	jne    80103e2c <memcmp+0x38>
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e0f:	4f                   	dec    %edi
80103e10:	31 d2                	xor    %edx,%edx
80103e12:	eb 0c                	jmp    80103e20 <memcmp+0x2c>
    if(*s1 != *s2)
80103e14:	8a 44 13 01          	mov    0x1(%ebx,%edx,1),%al
80103e18:	42                   	inc    %edx
80103e19:	8a 0c 16             	mov    (%esi,%edx,1),%cl
80103e1c:	38 c8                	cmp    %cl,%al
80103e1e:	75 0c                	jne    80103e2c <memcmp+0x38>
{
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e20:	39 d7                	cmp    %edx,%edi
80103e22:	75 f0                	jne    80103e14 <memcmp+0x20>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80103e24:	31 c0                	xor    %eax,%eax
}
80103e26:	5b                   	pop    %ebx
80103e27:	5e                   	pop    %esi
80103e28:	5f                   	pop    %edi
80103e29:	5d                   	pop    %ebp
80103e2a:	c3                   	ret    
80103e2b:	90                   	nop

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    if(*s1 != *s2)
      return *s1 - *s2;
80103e2c:	0f b6 c0             	movzbl %al,%eax
80103e2f:	0f b6 c9             	movzbl %cl,%ecx
80103e32:	29 c8                	sub    %ecx,%eax
    s1++, s2++;
  }

  return 0;
}
80103e34:	5b                   	pop    %ebx
80103e35:	5e                   	pop    %esi
80103e36:	5f                   	pop    %edi
80103e37:	5d                   	pop    %ebp
80103e38:	c3                   	ret    
80103e39:	8d 76 00             	lea    0x0(%esi),%esi

80103e3c <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e3c:	55                   	push   %ebp
80103e3d:	89 e5                	mov    %esp,%ebp
80103e3f:	57                   	push   %edi
80103e40:	56                   	push   %esi
80103e41:	53                   	push   %ebx
80103e42:	8b 45 08             	mov    0x8(%ebp),%eax
80103e45:	8b 75 0c             	mov    0xc(%ebp),%esi
80103e48:	8b 5d 10             	mov    0x10(%ebp),%ebx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e4b:	39 c6                	cmp    %eax,%esi
80103e4d:	73 29                	jae    80103e78 <memmove+0x3c>
80103e4f:	8d 0c 1e             	lea    (%esi,%ebx,1),%ecx
80103e52:	39 c8                	cmp    %ecx,%eax
80103e54:	73 22                	jae    80103e78 <memmove+0x3c>
    s += n;
    d += n;
    while(n-- > 0)
80103e56:	85 db                	test   %ebx,%ebx
80103e58:	74 19                	je     80103e73 <memmove+0x37>

  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
80103e5a:	8d 3c 18             	lea    (%eax,%ebx,1),%edi
80103e5d:	89 da                	mov    %ebx,%edx

  return 0;
}

void*
memmove(void *dst, const void *src, uint n)
80103e5f:	f7 db                	neg    %ebx
80103e61:	8d 34 19             	lea    (%ecx,%ebx,1),%esi
80103e64:	01 fb                	add    %edi,%ebx
80103e66:	66 90                	xchg   %ax,%ax
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
80103e68:	8a 4c 16 ff          	mov    -0x1(%esi,%edx,1),%cl
80103e6c:	88 4c 13 ff          	mov    %cl,-0x1(%ebx,%edx,1)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80103e70:	4a                   	dec    %edx
80103e71:	75 f5                	jne    80103e68 <memmove+0x2c>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80103e73:	5b                   	pop    %ebx
80103e74:	5e                   	pop    %esi
80103e75:	5f                   	pop    %edi
80103e76:	5d                   	pop    %ebp
80103e77:	c3                   	ret    
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80103e78:	85 db                	test   %ebx,%ebx
80103e7a:	74 f7                	je     80103e73 <memmove+0x37>
80103e7c:	31 d2                	xor    %edx,%edx
80103e7e:	66 90                	xchg   %ax,%ax
      *d++ = *s++;
80103e80:	8a 0c 16             	mov    (%esi,%edx,1),%cl
80103e83:	88 0c 10             	mov    %cl,(%eax,%edx,1)
80103e86:	42                   	inc    %edx
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80103e87:	39 d3                	cmp    %edx,%ebx
80103e89:	75 f5                	jne    80103e80 <memmove+0x44>
      *d++ = *s++;

  return dst;
}
80103e8b:	5b                   	pop    %ebx
80103e8c:	5e                   	pop    %esi
80103e8d:	5f                   	pop    %edi
80103e8e:	5d                   	pop    %ebp
80103e8f:	c3                   	ret    

80103e90 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103e90:	55                   	push   %ebp
80103e91:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
}
80103e93:	5d                   	pop    %ebp

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80103e94:	e9 a3 ff ff ff       	jmp    80103e3c <memmove>
80103e99:	8d 76 00             	lea    0x0(%esi),%esi

80103e9c <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
80103e9f:	57                   	push   %edi
80103ea0:	56                   	push   %esi
80103ea1:	53                   	push   %ebx
80103ea2:	51                   	push   %ecx
80103ea3:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103ea6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103ea9:	8b 7d 10             	mov    0x10(%ebp),%edi
  while(n > 0 && *p && *p == *q)
80103eac:	85 ff                	test   %edi,%edi
80103eae:	74 2d                	je     80103edd <strncmp+0x41>
80103eb0:	8a 01                	mov    (%ecx),%al
80103eb2:	84 c0                	test   %al,%al
80103eb4:	74 2f                	je     80103ee5 <strncmp+0x49>
80103eb6:	8a 13                	mov    (%ebx),%dl
80103eb8:	88 55 f3             	mov    %dl,-0xd(%ebp)
80103ebb:	38 d0                	cmp    %dl,%al
80103ebd:	74 1b                	je     80103eda <strncmp+0x3e>
80103ebf:	eb 2b                	jmp    80103eec <strncmp+0x50>
80103ec1:	8d 76 00             	lea    0x0(%esi),%esi
    n--, p++, q++;
80103ec4:	41                   	inc    %ecx
80103ec5:	8d 73 01             	lea    0x1(%ebx),%esi
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80103ec8:	8a 01                	mov    (%ecx),%al
80103eca:	8a 5b 01             	mov    0x1(%ebx),%bl
80103ecd:	88 5d f3             	mov    %bl,-0xd(%ebp)
80103ed0:	84 c0                	test   %al,%al
80103ed2:	74 18                	je     80103eec <strncmp+0x50>
80103ed4:	38 d8                	cmp    %bl,%al
80103ed6:	75 14                	jne    80103eec <strncmp+0x50>
    n--, p++, q++;
80103ed8:	89 f3                	mov    %esi,%ebx
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80103eda:	4f                   	dec    %edi
80103edb:	75 e7                	jne    80103ec4 <strncmp+0x28>
    n--, p++, q++;
  if(n == 0)
    return 0;
80103edd:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
}
80103edf:	5a                   	pop    %edx
80103ee0:	5b                   	pop    %ebx
80103ee1:	5e                   	pop    %esi
80103ee2:	5f                   	pop    %edi
80103ee3:	5d                   	pop    %ebp
80103ee4:	c3                   	ret    
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80103ee5:	8a 1b                	mov    (%ebx),%bl
80103ee7:	88 5d f3             	mov    %bl,-0xd(%ebp)
80103eea:	66 90                	xchg   %ax,%ax
    n--, p++, q++;
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80103eec:	0f b6 c0             	movzbl %al,%eax
80103eef:	0f b6 55 f3          	movzbl -0xd(%ebp),%edx
80103ef3:	29 d0                	sub    %edx,%eax
}
80103ef5:	5a                   	pop    %edx
80103ef6:	5b                   	pop    %ebx
80103ef7:	5e                   	pop    %esi
80103ef8:	5f                   	pop    %edi
80103ef9:	5d                   	pop    %ebp
80103efa:	c3                   	ret    
80103efb:	90                   	nop

80103efc <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103efc:	55                   	push   %ebp
80103efd:	89 e5                	mov    %esp,%ebp
80103eff:	57                   	push   %edi
80103f00:	56                   	push   %esi
80103f01:	53                   	push   %ebx
80103f02:	8b 7d 08             	mov    0x8(%ebp),%edi
80103f05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f08:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f0b:	89 fa                	mov    %edi,%edx
80103f0d:	eb 0b                	jmp    80103f1a <strncpy+0x1e>
80103f0f:	90                   	nop
80103f10:	8a 03                	mov    (%ebx),%al
80103f12:	88 02                	mov    %al,(%edx)
80103f14:	42                   	inc    %edx
80103f15:	43                   	inc    %ebx
80103f16:	84 c0                	test   %al,%al
80103f18:	74 08                	je     80103f22 <strncpy+0x26>
80103f1a:	49                   	dec    %ecx
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
80103f1b:	8d 71 01             	lea    0x1(%ecx),%esi
{
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f1e:	85 f6                	test   %esi,%esi
80103f20:	7f ee                	jg     80103f10 <strncpy+0x14>
    ;
  while(n-- > 0)
80103f22:	85 c9                	test   %ecx,%ecx
80103f24:	7e 0a                	jle    80103f30 <strncpy+0x34>
    return 0;
  return (uchar)*p - (uchar)*q;
}

char*
strncpy(char *s, const char *t, int n)
80103f26:	01 d1                	add    %edx,%ecx

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
    *s++ = 0;
80103f28:	c6 02 00             	movb   $0x0,(%edx)
80103f2b:	42                   	inc    %edx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80103f2c:	39 ca                	cmp    %ecx,%edx
80103f2e:	75 f8                	jne    80103f28 <strncpy+0x2c>
    *s++ = 0;
  return os;
}
80103f30:	89 f8                	mov    %edi,%eax
80103f32:	5b                   	pop    %ebx
80103f33:	5e                   	pop    %esi
80103f34:	5f                   	pop    %edi
80103f35:	5d                   	pop    %ebp
80103f36:	c3                   	ret    
80103f37:	90                   	nop

80103f38 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f38:	55                   	push   %ebp
80103f39:	89 e5                	mov    %esp,%ebp
80103f3b:	56                   	push   %esi
80103f3c:	53                   	push   %ebx
80103f3d:	8b 75 08             	mov    0x8(%ebp),%esi
80103f40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f43:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f46:	85 d2                	test   %edx,%edx
80103f48:	7e 12                	jle    80103f5c <safestrcpy+0x24>
80103f4a:	89 f1                	mov    %esi,%ecx
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f4c:	4a                   	dec    %edx
80103f4d:	74 0a                	je     80103f59 <safestrcpy+0x21>
80103f4f:	8a 03                	mov    (%ebx),%al
80103f51:	88 01                	mov    %al,(%ecx)
80103f53:	41                   	inc    %ecx
80103f54:	43                   	inc    %ebx
80103f55:	84 c0                	test   %al,%al
80103f57:	75 f3                	jne    80103f4c <safestrcpy+0x14>
    ;
  *s = 0;
80103f59:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f5c:	89 f0                	mov    %esi,%eax
80103f5e:	5b                   	pop    %ebx
80103f5f:	5e                   	pop    %esi
80103f60:	5d                   	pop    %ebp
80103f61:	c3                   	ret    
80103f62:	66 90                	xchg   %ax,%ax

80103f64 <strlen>:

int
strlen(const char *s)
{
80103f64:	55                   	push   %ebp
80103f65:	89 e5                	mov    %esp,%ebp
80103f67:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103f6a:	31 c0                	xor    %eax,%eax
80103f6c:	80 3a 00             	cmpb   $0x0,(%edx)
80103f6f:	74 0a                	je     80103f7b <strlen+0x17>
80103f71:	8d 76 00             	lea    0x0(%esi),%esi
80103f74:	40                   	inc    %eax
80103f75:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103f79:	75 f9                	jne    80103f74 <strlen+0x10>
    ;
  return n;
}
80103f7b:	5d                   	pop    %ebp
80103f7c:	c3                   	ret    
80103f7d:	00 00                	add    %al,(%eax)
	...

80103f80 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103f80:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103f84:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103f88:	55                   	push   %ebp
  pushl %ebx
80103f89:	53                   	push   %ebx
  pushl %esi
80103f8a:	56                   	push   %esi
  pushl %edi
80103f8b:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103f8c:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103f8e:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103f90:	5f                   	pop    %edi
  popl %esi
80103f91:	5e                   	pop    %esi
  popl %ebx
80103f92:	5b                   	pop    %ebx
  popl %ebp
80103f93:	5d                   	pop    %ebp
  ret
80103f94:	c3                   	ret    
80103f95:	00 00                	add    %al,(%eax)
	...

80103f98 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103f98:	55                   	push   %ebp
80103f99:	89 e5                	mov    %esp,%ebp
80103f9b:	53                   	push   %ebx
80103f9c:	51                   	push   %ecx
80103f9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103fa0:	e8 0b f3 ff ff       	call   801032b0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103fa5:	8b 00                	mov    (%eax),%eax
80103fa7:	39 d8                	cmp    %ebx,%eax
80103fa9:	76 15                	jbe    80103fc0 <fetchint+0x28>
80103fab:	8d 53 04             	lea    0x4(%ebx),%edx
80103fae:	39 d0                	cmp    %edx,%eax
80103fb0:	72 0e                	jb     80103fc0 <fetchint+0x28>
    return -1;
  *ip = *(int*)(addr);
80103fb2:	8b 13                	mov    (%ebx),%edx
80103fb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fb7:	89 10                	mov    %edx,(%eax)
  return 0;
80103fb9:	31 c0                	xor    %eax,%eax
}
80103fbb:	5a                   	pop    %edx
80103fbc:	5b                   	pop    %ebx
80103fbd:	5d                   	pop    %ebp
80103fbe:	c3                   	ret    
80103fbf:	90                   	nop
fetchint(uint addr, int *ip)
{
  struct proc *curproc = myproc();

  if(addr >= curproc->sz || addr+4 > curproc->sz)
    return -1;
80103fc0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fc5:	eb f4                	jmp    80103fbb <fetchint+0x23>
80103fc7:	90                   	nop

80103fc8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103fc8:	55                   	push   %ebp
80103fc9:	89 e5                	mov    %esp,%ebp
80103fcb:	53                   	push   %ebx
80103fcc:	50                   	push   %eax
80103fcd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103fd0:	e8 db f2 ff ff       	call   801032b0 <myproc>

  if(addr >= curproc->sz)
80103fd5:	39 18                	cmp    %ebx,(%eax)
80103fd7:	76 21                	jbe    80103ffa <fetchstr+0x32>
    return -1;
  *pp = (char*)addr;
80103fd9:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fdc:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103fde:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103fe0:	39 d3                	cmp    %edx,%ebx
80103fe2:	73 16                	jae    80103ffa <fetchstr+0x32>
    if(*s == 0)
80103fe4:	80 3b 00             	cmpb   $0x0,(%ebx)
80103fe7:	74 21                	je     8010400a <fetchstr+0x42>
80103fe9:	89 d8                	mov    %ebx,%eax
80103feb:	eb 08                	jmp    80103ff5 <fetchstr+0x2d>
80103fed:	8d 76 00             	lea    0x0(%esi),%esi
80103ff0:	80 38 00             	cmpb   $0x0,(%eax)
80103ff3:	74 0f                	je     80104004 <fetchstr+0x3c>

  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
80103ff5:	40                   	inc    %eax
80103ff6:	39 c2                	cmp    %eax,%edx
80103ff8:	77 f6                	ja     80103ff0 <fetchstr+0x28>
    if(*s == 0)
      return s - *pp;
  }
  return -1;
80103ffa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fff:	5b                   	pop    %ebx
80104000:	5b                   	pop    %ebx
80104001:	5d                   	pop    %ebp
80104002:	c3                   	ret    
80104003:	90                   	nop
  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
    if(*s == 0)
80104004:	29 d8                	sub    %ebx,%eax
      return s - *pp;
  }
  return -1;
}
80104006:	5b                   	pop    %ebx
80104007:	5b                   	pop    %ebx
80104008:	5d                   	pop    %ebp
80104009:	c3                   	ret    
  if(addr >= curproc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)curproc->sz;
  for(s = *pp; s < ep; s++){
    if(*s == 0)
8010400a:	31 c0                	xor    %eax,%eax
      return s - *pp;
8010400c:	eb f1                	jmp    80103fff <fetchstr+0x37>
8010400e:	66 90                	xchg   %ax,%ax

80104010 <argint>:
}

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104010:	55                   	push   %ebp
80104011:	89 e5                	mov    %esp,%ebp
80104013:	56                   	push   %esi
80104014:	53                   	push   %ebx
80104015:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104018:	8b 75 0c             	mov    0xc(%ebp),%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010401b:	e8 90 f2 ff ff       	call   801032b0 <myproc>
80104020:	89 75 0c             	mov    %esi,0xc(%ebp)
80104023:	8b 40 18             	mov    0x18(%eax),%eax
80104026:	8b 40 44             	mov    0x44(%eax),%eax
80104029:	8d 44 98 04          	lea    0x4(%eax,%ebx,4),%eax
8010402d:	89 45 08             	mov    %eax,0x8(%ebp)
}
80104030:	5b                   	pop    %ebx
80104031:	5e                   	pop    %esi
80104032:	5d                   	pop    %ebp

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104033:	e9 60 ff ff ff       	jmp    80103f98 <fetchint>

80104038 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104038:	55                   	push   %ebp
80104039:	89 e5                	mov    %esp,%ebp
8010403b:	56                   	push   %esi
8010403c:	53                   	push   %ebx
8010403d:	83 ec 20             	sub    $0x20,%esp
80104040:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104043:	e8 68 f2 ff ff       	call   801032b0 <myproc>
80104048:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
8010404a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010404d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104051:	8b 45 08             	mov    0x8(%ebp),%eax
80104054:	89 04 24             	mov    %eax,(%esp)
80104057:	e8 b4 ff ff ff       	call   80104010 <argint>
8010405c:	85 c0                	test   %eax,%eax
8010405e:	78 24                	js     80104084 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104060:	85 db                	test   %ebx,%ebx
80104062:	78 20                	js     80104084 <argptr+0x4c>
80104064:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104067:	8b 16                	mov    (%esi),%edx
80104069:	39 d0                	cmp    %edx,%eax
8010406b:	73 17                	jae    80104084 <argptr+0x4c>
8010406d:	01 c3                	add    %eax,%ebx
8010406f:	39 da                	cmp    %ebx,%edx
80104071:	72 11                	jb     80104084 <argptr+0x4c>
    return -1;
  *pp = (char*)i;
80104073:	8b 55 0c             	mov    0xc(%ebp),%edx
80104076:	89 02                	mov    %eax,(%edx)
  return 0;
80104078:	31 c0                	xor    %eax,%eax
}
8010407a:	83 c4 20             	add    $0x20,%esp
8010407d:	5b                   	pop    %ebx
8010407e:	5e                   	pop    %esi
8010407f:	5d                   	pop    %ebp
80104080:	c3                   	ret    
80104081:	8d 76 00             	lea    0x0(%esi),%esi
  struct proc *curproc = myproc();
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
    return -1;
80104084:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  *pp = (char*)i;
  return 0;
}
80104089:	83 c4 20             	add    $0x20,%esp
8010408c:	5b                   	pop    %ebx
8010408d:	5e                   	pop    %esi
8010408e:	5d                   	pop    %ebp
8010408f:	c3                   	ret    

80104090 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104090:	55                   	push   %ebp
80104091:	89 e5                	mov    %esp,%ebp
80104093:	83 ec 28             	sub    $0x28,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104096:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104099:	89 44 24 04          	mov    %eax,0x4(%esp)
8010409d:	8b 45 08             	mov    0x8(%ebp),%eax
801040a0:	89 04 24             	mov    %eax,(%esp)
801040a3:	e8 68 ff ff ff       	call   80104010 <argint>
801040a8:	85 c0                	test   %eax,%eax
801040aa:	78 14                	js     801040c0 <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
801040ac:	8b 45 0c             	mov    0xc(%ebp),%eax
801040af:	89 44 24 04          	mov    %eax,0x4(%esp)
801040b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b6:	89 04 24             	mov    %eax,(%esp)
801040b9:	e8 0a ff ff ff       	call   80103fc8 <fetchstr>
}
801040be:	c9                   	leave  
801040bf:	c3                   	ret    
int
argstr(int n, char **pp)
{
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
801040c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchstr(addr, pp);
}
801040c5:	c9                   	leave  
801040c6:	c3                   	ret    
801040c7:	90                   	nop

801040c8 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
801040c8:	55                   	push   %ebp
801040c9:	89 e5                	mov    %esp,%ebp
801040cb:	53                   	push   %ebx
801040cc:	83 ec 24             	sub    $0x24,%esp
  int num;
  struct proc *curproc = myproc();
801040cf:	e8 dc f1 ff ff       	call   801032b0 <myproc>

  num = curproc->tf->eax;
801040d4:	8b 58 18             	mov    0x18(%eax),%ebx
801040d7:	8b 53 1c             	mov    0x1c(%ebx),%edx
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801040da:	8d 4a ff             	lea    -0x1(%edx),%ecx
801040dd:	83 f9 14             	cmp    $0x14,%ecx
801040e0:	77 16                	ja     801040f8 <syscall+0x30>
801040e2:	8b 0c 95 a0 6b 10 80 	mov    -0x7fef9460(,%edx,4),%ecx
801040e9:	85 c9                	test   %ecx,%ecx
801040eb:	74 0b                	je     801040f8 <syscall+0x30>
    curproc->tf->eax = syscalls[num]();
801040ed:	ff d1                	call   *%ecx
801040ef:	89 43 1c             	mov    %eax,0x1c(%ebx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
801040f2:	83 c4 24             	add    $0x24,%esp
801040f5:	5b                   	pop    %ebx
801040f6:	5d                   	pop    %ebp
801040f7:	c3                   	ret    

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
801040f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
            curproc->pid, curproc->name, num);
801040fc:	8d 50 6c             	lea    0x6c(%eax),%edx
801040ff:	89 54 24 08          	mov    %edx,0x8(%esp)

  num = curproc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    curproc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80104103:	8b 50 10             	mov    0x10(%eax),%edx
80104106:	89 54 24 04          	mov    %edx,0x4(%esp)
8010410a:	c7 04 24 81 6b 10 80 	movl   $0x80106b81,(%esp)
80104111:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104114:	e8 a3 c4 ff ff       	call   801005bc <cprintf>
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
80104119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010411c:	8b 40 18             	mov    0x18(%eax),%eax
8010411f:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104126:	83 c4 24             	add    $0x24,%esp
80104129:	5b                   	pop    %ebx
8010412a:	5d                   	pop    %ebp
8010412b:	c3                   	ret    

8010412c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010412c:	55                   	push   %ebp
8010412d:	89 e5                	mov    %esp,%ebp
8010412f:	53                   	push   %ebx
80104130:	53                   	push   %ebx
80104131:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104133:	e8 78 f1 ff ff       	call   801032b0 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104138:	31 d2                	xor    %edx,%edx
8010413a:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
8010413c:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
80104140:	85 c9                	test   %ecx,%ecx
80104142:	74 14                	je     80104158 <fdalloc+0x2c>
fdalloc(struct file *f)
{
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
80104144:	42                   	inc    %edx
80104145:	83 fa 10             	cmp    $0x10,%edx
80104148:	75 f2                	jne    8010413c <fdalloc+0x10>
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
8010414a:	ba ff ff ff ff       	mov    $0xffffffff,%edx
}
8010414f:	89 d0                	mov    %edx,%eax
80104151:	5a                   	pop    %edx
80104152:	5b                   	pop    %ebx
80104153:	5d                   	pop    %ebp
80104154:	c3                   	ret    
80104155:	8d 76 00             	lea    0x0(%esi),%esi
  int fd;
  struct proc *curproc = myproc();

  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd] == 0){
      curproc->ofile[fd] = f;
80104158:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
8010415c:	89 d0                	mov    %edx,%eax
8010415e:	5a                   	pop    %edx
8010415f:	5b                   	pop    %ebx
80104160:	5d                   	pop    %ebp
80104161:	c3                   	ret    
80104162:	66 90                	xchg   %ax,%ax

80104164 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104164:	55                   	push   %ebp
80104165:	89 e5                	mov    %esp,%ebp
80104167:	57                   	push   %edi
80104168:	56                   	push   %esi
80104169:	53                   	push   %ebx
8010416a:	83 ec 3c             	sub    $0x3c,%esp
8010416d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
80104170:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104173:	89 4d d0             	mov    %ecx,-0x30(%ebp)
80104176:	89 d7                	mov    %edx,%edi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104178:	8d 75 da             	lea    -0x26(%ebp),%esi
8010417b:	89 74 24 04          	mov    %esi,0x4(%esp)
8010417f:	89 04 24             	mov    %eax,(%esp)
80104182:	e8 a9 db ff ff       	call   80101d30 <nameiparent>
80104187:	85 c0                	test   %eax,%eax
80104189:	0f 84 e9 00 00 00    	je     80104278 <create+0x114>
    return 0;
  ilock(dp);
8010418f:	89 04 24             	mov    %eax,(%esp)
80104192:	89 45 cc             	mov    %eax,-0x34(%ebp)
80104195:	e8 4e d3 ff ff       	call   801014e8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
8010419a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
801041a1:	00 
801041a2:	89 74 24 04          	mov    %esi,0x4(%esp)
801041a6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801041a9:	89 14 24             	mov    %edx,(%esp)
801041ac:	e8 67 d8 ff ff       	call   80101a18 <dirlookup>
801041b1:	89 c3                	mov    %eax,%ebx
801041b3:	85 c0                	test   %eax,%eax
801041b5:	8b 55 cc             	mov    -0x34(%ebp),%edx
801041b8:	74 3e                	je     801041f8 <create+0x94>
    iunlockput(dp);
801041ba:	89 14 24             	mov    %edx,(%esp)
801041bd:	e8 76 d5 ff ff       	call   80101738 <iunlockput>
    ilock(ip);
801041c2:	89 1c 24             	mov    %ebx,(%esp)
801041c5:	e8 1e d3 ff ff       	call   801014e8 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801041ca:	66 83 ff 02          	cmp    $0x2,%di
801041ce:	75 14                	jne    801041e4 <create+0x80>
801041d0:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801041d5:	75 0d                	jne    801041e4 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801041d7:	89 d8                	mov    %ebx,%eax
801041d9:	83 c4 3c             	add    $0x3c,%esp
801041dc:	5b                   	pop    %ebx
801041dd:	5e                   	pop    %esi
801041de:	5f                   	pop    %edi
801041df:	5d                   	pop    %ebp
801041e0:	c3                   	ret    
801041e1:	8d 76 00             	lea    0x0(%esi),%esi
  if((ip = dirlookup(dp, name, 0)) != 0){
    iunlockput(dp);
    ilock(ip);
    if(type == T_FILE && ip->type == T_FILE)
      return ip;
    iunlockput(ip);
801041e4:	89 1c 24             	mov    %ebx,(%esp)
801041e7:	e8 4c d5 ff ff       	call   80101738 <iunlockput>
    return 0;
801041ec:	31 db                	xor    %ebx,%ebx
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801041ee:	89 d8                	mov    %ebx,%eax
801041f0:	83 c4 3c             	add    $0x3c,%esp
801041f3:	5b                   	pop    %ebx
801041f4:	5e                   	pop    %esi
801041f5:	5f                   	pop    %edi
801041f6:	5d                   	pop    %ebp
801041f7:	c3                   	ret    
      return ip;
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
801041f8:	0f bf c7             	movswl %di,%eax
801041fb:	89 44 24 04          	mov    %eax,0x4(%esp)
801041ff:	8b 02                	mov    (%edx),%eax
80104201:	89 04 24             	mov    %eax,(%esp)
80104204:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104207:	e8 60 d1 ff ff       	call   8010136c <ialloc>
8010420c:	89 c3                	mov    %eax,%ebx
8010420e:	85 c0                	test   %eax,%eax
80104210:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104213:	0f 84 ce 00 00 00    	je     801042e7 <create+0x183>
    panic("create: ialloc");

  ilock(ip);
80104219:	89 04 24             	mov    %eax,(%esp)
8010421c:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010421f:	e8 c4 d2 ff ff       	call   801014e8 <ilock>
  ip->major = major;
80104224:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80104227:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010422b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010422e:	66 89 4b 54          	mov    %cx,0x54(%ebx)
  ip->nlink = 1;
80104232:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104238:	89 1c 24             	mov    %ebx,(%esp)
8010423b:	e8 f0 d1 ff ff       	call   80101430 <iupdate>

  if(type == T_DIR){  // Create . and .. entries.
80104240:	66 4f                	dec    %di
80104242:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104245:	74 39                	je     80104280 <create+0x11c>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
      panic("create dots");
  }

  if(dirlink(dp, name, ip->inum) < 0)
80104247:	8b 43 04             	mov    0x4(%ebx),%eax
8010424a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010424e:	89 74 24 04          	mov    %esi,0x4(%esp)
80104252:	89 14 24             	mov    %edx,(%esp)
80104255:	89 55 cc             	mov    %edx,-0x34(%ebp)
80104258:	e8 e3 d9 ff ff       	call   80101c40 <dirlink>
8010425d:	85 c0                	test   %eax,%eax
8010425f:	8b 55 cc             	mov    -0x34(%ebp),%edx
80104262:	78 77                	js     801042db <create+0x177>
    panic("create: dirlink");

  iunlockput(dp);
80104264:	89 14 24             	mov    %edx,(%esp)
80104267:	e8 cc d4 ff ff       	call   80101738 <iunlockput>

  return ip;
}
8010426c:	89 d8                	mov    %ebx,%eax
8010426e:	83 c4 3c             	add    $0x3c,%esp
80104271:	5b                   	pop    %ebx
80104272:	5e                   	pop    %esi
80104273:	5f                   	pop    %edi
80104274:	5d                   	pop    %ebp
80104275:	c3                   	ret    
80104276:	66 90                	xchg   %ax,%ax
{
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    return 0;
80104278:	31 db                	xor    %ebx,%ebx
8010427a:	e9 58 ff ff ff       	jmp    801041d7 <create+0x73>
8010427f:	90                   	nop
  ip->minor = minor;
  ip->nlink = 1;
  iupdate(ip);

  if(type == T_DIR){  // Create . and .. entries.
    dp->nlink++;  // for ".."
80104280:	66 ff 42 56          	incw   0x56(%edx)
    iupdate(dp);
80104284:	89 14 24             	mov    %edx,(%esp)
80104287:	89 55 cc             	mov    %edx,-0x34(%ebp)
8010428a:	e8 a1 d1 ff ff       	call   80101430 <iupdate>
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010428f:	8b 43 04             	mov    0x4(%ebx),%eax
80104292:	89 44 24 08          	mov    %eax,0x8(%esp)
80104296:	c7 44 24 04 08 6c 10 	movl   $0x80106c08,0x4(%esp)
8010429d:	80 
8010429e:	89 1c 24             	mov    %ebx,(%esp)
801042a1:	e8 9a d9 ff ff       	call   80101c40 <dirlink>
801042a6:	85 c0                	test   %eax,%eax
801042a8:	8b 55 cc             	mov    -0x34(%ebp),%edx
801042ab:	78 22                	js     801042cf <create+0x16b>
801042ad:	8b 42 04             	mov    0x4(%edx),%eax
801042b0:	89 44 24 08          	mov    %eax,0x8(%esp)
801042b4:	c7 44 24 04 07 6c 10 	movl   $0x80106c07,0x4(%esp)
801042bb:	80 
801042bc:	89 1c 24             	mov    %ebx,(%esp)
801042bf:	e8 7c d9 ff ff       	call   80101c40 <dirlink>
801042c4:	85 c0                	test   %eax,%eax
801042c6:	8b 55 cc             	mov    -0x34(%ebp),%edx
801042c9:	0f 89 78 ff ff ff    	jns    80104247 <create+0xe3>
      panic("create dots");
801042cf:	c7 04 24 0a 6c 10 80 	movl   $0x80106c0a,(%esp)
801042d6:	e8 41 c0 ff ff       	call   8010031c <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
    panic("create: dirlink");
801042db:	c7 04 24 16 6c 10 80 	movl   $0x80106c16,(%esp)
801042e2:	e8 35 c0 ff ff       	call   8010031c <panic>
    iunlockput(ip);
    return 0;
  }

  if((ip = ialloc(dp->dev, type)) == 0)
    panic("create: ialloc");
801042e7:	c7 04 24 f8 6b 10 80 	movl   $0x80106bf8,(%esp)
801042ee:	e8 29 c0 ff ff       	call   8010031c <panic>
801042f3:	90                   	nop

801042f4 <argfd.constprop.0>:
#include "fcntl.h"

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
801042f4:	55                   	push   %ebp
801042f5:	89 e5                	mov    %esp,%ebp
801042f7:	56                   	push   %esi
801042f8:	53                   	push   %ebx
801042f9:	83 ec 20             	sub    $0x20,%esp
801042fc:	89 c3                	mov    %eax,%ebx
801042fe:	89 d6                	mov    %edx,%esi
{
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104300:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104303:	89 44 24 04          	mov    %eax,0x4(%esp)
80104307:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010430e:	e8 fd fc ff ff       	call   80104010 <argint>
80104313:	85 c0                	test   %eax,%eax
80104315:	78 2d                	js     80104344 <argfd.constprop.0+0x50>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104317:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010431b:	77 27                	ja     80104344 <argfd.constprop.0+0x50>
8010431d:	e8 8e ef ff ff       	call   801032b0 <myproc>
80104322:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104325:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104329:	85 c0                	test   %eax,%eax
8010432b:	74 17                	je     80104344 <argfd.constprop.0+0x50>
    return -1;
  if(pfd)
8010432d:	85 db                	test   %ebx,%ebx
8010432f:	74 02                	je     80104333 <argfd.constprop.0+0x3f>
    *pfd = fd;
80104331:	89 13                	mov    %edx,(%ebx)
  if(pf)
80104333:	85 f6                	test   %esi,%esi
80104335:	74 19                	je     80104350 <argfd.constprop.0+0x5c>
    *pf = f;
80104337:	89 06                	mov    %eax,(%esi)
  return 0;
80104339:	31 c0                	xor    %eax,%eax
}
8010433b:	83 c4 20             	add    $0x20,%esp
8010433e:	5b                   	pop    %ebx
8010433f:	5e                   	pop    %esi
80104340:	5d                   	pop    %ebp
80104341:	c3                   	ret    
80104342:	66 90                	xchg   %ax,%ax
  struct file *f;

  if(argint(n, &fd) < 0)
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    return -1;
80104344:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
}
80104349:	83 c4 20             	add    $0x20,%esp
8010434c:	5b                   	pop    %ebx
8010434d:	5e                   	pop    %esi
8010434e:	5d                   	pop    %ebp
8010434f:	c3                   	ret    
    return -1;
  if(pfd)
    *pfd = fd;
  if(pf)
    *pf = f;
  return 0;
80104350:	31 c0                	xor    %eax,%eax
80104352:	eb e7                	jmp    8010433b <argfd.constprop.0+0x47>

80104354 <sys_dup>:
  return -1;
}

int
sys_dup(void)
{
80104354:	55                   	push   %ebp
80104355:	89 e5                	mov    %esp,%ebp
80104357:	53                   	push   %ebx
80104358:	83 ec 24             	sub    $0x24,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
8010435b:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010435e:	31 c0                	xor    %eax,%eax
80104360:	e8 8f ff ff ff       	call   801042f4 <argfd.constprop.0>
80104365:	85 c0                	test   %eax,%eax
80104367:	78 23                	js     8010438c <sys_dup+0x38>
    return -1;
  if((fd=fdalloc(f)) < 0)
80104369:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010436c:	e8 bb fd ff ff       	call   8010412c <fdalloc>
80104371:	89 c3                	mov    %eax,%ebx
80104373:	85 c0                	test   %eax,%eax
80104375:	78 15                	js     8010438c <sys_dup+0x38>
    return -1;
  filedup(f);
80104377:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437a:	89 04 24             	mov    %eax,(%esp)
8010437d:	e8 52 c9 ff ff       	call   80100cd4 <filedup>
  return fd;
}
80104382:	89 d8                	mov    %ebx,%eax
80104384:	83 c4 24             	add    $0x24,%esp
80104387:	5b                   	pop    %ebx
80104388:	5d                   	pop    %ebp
80104389:	c3                   	ret    
8010438a:	66 90                	xchg   %ax,%ax
  int fd;

  if(argfd(0, 0, &f) < 0)
    return -1;
  if((fd=fdalloc(f)) < 0)
    return -1;
8010438c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104391:	eb ef                	jmp    80104382 <sys_dup+0x2e>
80104393:	90                   	nop

80104394 <sys_read>:
  return fd;
}

int
sys_read(void)
{
80104394:	55                   	push   %ebp
80104395:	89 e5                	mov    %esp,%ebp
80104397:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010439a:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010439d:	31 c0                	xor    %eax,%eax
8010439f:	e8 50 ff ff ff       	call   801042f4 <argfd.constprop.0>
801043a4:	85 c0                	test   %eax,%eax
801043a6:	78 50                	js     801043f8 <sys_read+0x64>
801043a8:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043ab:	89 44 24 04          	mov    %eax,0x4(%esp)
801043af:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801043b6:	e8 55 fc ff ff       	call   80104010 <argint>
801043bb:	85 c0                	test   %eax,%eax
801043bd:	78 39                	js     801043f8 <sys_read+0x64>
801043bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043c2:	89 44 24 08          	mov    %eax,0x8(%esp)
801043c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
801043c9:	89 44 24 04          	mov    %eax,0x4(%esp)
801043cd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801043d4:	e8 5f fc ff ff       	call   80104038 <argptr>
801043d9:	85 c0                	test   %eax,%eax
801043db:	78 1b                	js     801043f8 <sys_read+0x64>
    return -1;
  return fileread(f, p, n);
801043dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801043e0:	89 44 24 08          	mov    %eax,0x8(%esp)
801043e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043e7:	89 44 24 04          	mov    %eax,0x4(%esp)
801043eb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801043ee:	89 04 24             	mov    %eax,(%esp)
801043f1:	e8 26 ca ff ff       	call   80100e1c <fileread>
}
801043f6:	c9                   	leave  
801043f7:	c3                   	ret    
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
801043f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fileread(f, p, n);
}
801043fd:	c9                   	leave  
801043fe:	c3                   	ret    
801043ff:	90                   	nop

80104400 <sys_write>:

int
sys_write(void)
{
80104400:	55                   	push   %ebp
80104401:	89 e5                	mov    %esp,%ebp
80104403:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104406:	8d 55 ec             	lea    -0x14(%ebp),%edx
80104409:	31 c0                	xor    %eax,%eax
8010440b:	e8 e4 fe ff ff       	call   801042f4 <argfd.constprop.0>
80104410:	85 c0                	test   %eax,%eax
80104412:	78 50                	js     80104464 <sys_write+0x64>
80104414:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104417:	89 44 24 04          	mov    %eax,0x4(%esp)
8010441b:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
80104422:	e8 e9 fb ff ff       	call   80104010 <argint>
80104427:	85 c0                	test   %eax,%eax
80104429:	78 39                	js     80104464 <sys_write+0x64>
8010442b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010442e:	89 44 24 08          	mov    %eax,0x8(%esp)
80104432:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104435:	89 44 24 04          	mov    %eax,0x4(%esp)
80104439:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104440:	e8 f3 fb ff ff       	call   80104038 <argptr>
80104445:	85 c0                	test   %eax,%eax
80104447:	78 1b                	js     80104464 <sys_write+0x64>
    return -1;
  return filewrite(f, p, n);
80104449:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010444c:	89 44 24 08          	mov    %eax,0x8(%esp)
80104450:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104453:	89 44 24 04          	mov    %eax,0x4(%esp)
80104457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010445a:	89 04 24             	mov    %eax,(%esp)
8010445d:	e8 4e ca ff ff       	call   80100eb0 <filewrite>
}
80104462:	c9                   	leave  
80104463:	c3                   	ret    
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
    return -1;
80104464:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return filewrite(f, p, n);
}
80104469:	c9                   	leave  
8010446a:	c3                   	ret    
8010446b:	90                   	nop

8010446c <sys_close>:

int
sys_close(void)
{
8010446c:	55                   	push   %ebp
8010446d:	89 e5                	mov    %esp,%ebp
8010446f:	83 ec 28             	sub    $0x28,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80104472:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104475:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104478:	e8 77 fe ff ff       	call   801042f4 <argfd.constprop.0>
8010447d:	85 c0                	test   %eax,%eax
8010447f:	78 1f                	js     801044a0 <sys_close+0x34>
    return -1;
  myproc()->ofile[fd] = 0;
80104481:	e8 2a ee ff ff       	call   801032b0 <myproc>
80104486:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104489:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
80104490:	00 
  fileclose(f);
80104491:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104494:	89 04 24             	mov    %eax,(%esp)
80104497:	e8 7c c8 ff ff       	call   80100d18 <fileclose>
  return 0;
8010449c:	31 c0                	xor    %eax,%eax
}
8010449e:	c9                   	leave  
8010449f:	c3                   	ret    
{
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
    return -1;
801044a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  myproc()->ofile[fd] = 0;
  fileclose(f);
  return 0;
}
801044a5:	c9                   	leave  
801044a6:	c3                   	ret    
801044a7:	90                   	nop

801044a8 <sys_fstat>:

int
sys_fstat(void)
{
801044a8:	55                   	push   %ebp
801044a9:	89 e5                	mov    %esp,%ebp
801044ab:	83 ec 28             	sub    $0x28,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801044ae:	8d 55 f0             	lea    -0x10(%ebp),%edx
801044b1:	31 c0                	xor    %eax,%eax
801044b3:	e8 3c fe ff ff       	call   801042f4 <argfd.constprop.0>
801044b8:	85 c0                	test   %eax,%eax
801044ba:	78 34                	js     801044f0 <sys_fstat+0x48>
801044bc:	c7 44 24 08 14 00 00 	movl   $0x14,0x8(%esp)
801044c3:	00 
801044c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
801044c7:	89 44 24 04          	mov    %eax,0x4(%esp)
801044cb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801044d2:	e8 61 fb ff ff       	call   80104038 <argptr>
801044d7:	85 c0                	test   %eax,%eax
801044d9:	78 15                	js     801044f0 <sys_fstat+0x48>
    return -1;
  return filestat(f, st);
801044db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044de:	89 44 24 04          	mov    %eax,0x4(%esp)
801044e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e5:	89 04 24             	mov    %eax,(%esp)
801044e8:	e8 e3 c8 ff ff       	call   80100dd0 <filestat>
}
801044ed:	c9                   	leave  
801044ee:	c3                   	ret    
801044ef:	90                   	nop
{
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
    return -1;
801044f0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return filestat(f, st);
}
801044f5:	c9                   	leave  
801044f6:	c3                   	ret    
801044f7:	90                   	nop

801044f8 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801044f8:	55                   	push   %ebp
801044f9:	89 e5                	mov    %esp,%ebp
801044fb:	57                   	push   %edi
801044fc:	56                   	push   %esi
801044fd:	53                   	push   %ebx
801044fe:	83 ec 3c             	sub    $0x3c,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104501:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104504:	89 44 24 04          	mov    %eax,0x4(%esp)
80104508:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010450f:	e8 7c fb ff ff       	call   80104090 <argstr>
80104514:	85 c0                	test   %eax,%eax
80104516:	0f 88 f0 00 00 00    	js     8010460c <sys_link+0x114>
8010451c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010451f:	89 44 24 04          	mov    %eax,0x4(%esp)
80104523:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010452a:	e8 61 fb ff ff       	call   80104090 <argstr>
8010452f:	85 c0                	test   %eax,%eax
80104531:	0f 88 d5 00 00 00    	js     8010460c <sys_link+0x114>
    return -1;

  begin_op();
80104537:	e8 a4 e2 ff ff       	call   801027e0 <begin_op>
  if((ip = namei(old)) == 0){
8010453c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010453f:	89 04 24             	mov    %eax,(%esp)
80104542:	e8 d1 d7 ff ff       	call   80101d18 <namei>
80104547:	89 c3                	mov    %eax,%ebx
80104549:	85 c0                	test   %eax,%eax
8010454b:	0f 84 a7 00 00 00    	je     801045f8 <sys_link+0x100>
    end_op();
    return -1;
  }

  ilock(ip);
80104551:	89 04 24             	mov    %eax,(%esp)
80104554:	e8 8f cf ff ff       	call   801014e8 <ilock>
  if(ip->type == T_DIR){
80104559:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010455e:	0f 84 b0 00 00 00    	je     80104614 <sys_link+0x11c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  ip->nlink++;
80104564:	66 ff 43 56          	incw   0x56(%ebx)
  iupdate(ip);
80104568:	89 1c 24             	mov    %ebx,(%esp)
8010456b:	e8 c0 ce ff ff       	call   80101430 <iupdate>
  iunlock(ip);
80104570:	89 1c 24             	mov    %ebx,(%esp)
80104573:	e8 40 d0 ff ff       	call   801015b8 <iunlock>

  if((dp = nameiparent(new, name)) == 0)
80104578:	8d 7d d2             	lea    -0x2e(%ebp),%edi
8010457b:	89 7c 24 04          	mov    %edi,0x4(%esp)
8010457f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104582:	89 04 24             	mov    %eax,(%esp)
80104585:	e8 a6 d7 ff ff       	call   80101d30 <nameiparent>
8010458a:	89 c6                	mov    %eax,%esi
8010458c:	85 c0                	test   %eax,%eax
8010458e:	74 4c                	je     801045dc <sys_link+0xe4>
    goto bad;
  ilock(dp);
80104590:	89 04 24             	mov    %eax,(%esp)
80104593:	e8 50 cf ff ff       	call   801014e8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104598:	8b 03                	mov    (%ebx),%eax
8010459a:	39 06                	cmp    %eax,(%esi)
8010459c:	75 36                	jne    801045d4 <sys_link+0xdc>
8010459e:	8b 43 04             	mov    0x4(%ebx),%eax
801045a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801045a5:	89 7c 24 04          	mov    %edi,0x4(%esp)
801045a9:	89 34 24             	mov    %esi,(%esp)
801045ac:	e8 8f d6 ff ff       	call   80101c40 <dirlink>
801045b1:	85 c0                	test   %eax,%eax
801045b3:	78 1f                	js     801045d4 <sys_link+0xdc>
    iunlockput(dp);
    goto bad;
  }
  iunlockput(dp);
801045b5:	89 34 24             	mov    %esi,(%esp)
801045b8:	e8 7b d1 ff ff       	call   80101738 <iunlockput>
  iput(ip);
801045bd:	89 1c 24             	mov    %ebx,(%esp)
801045c0:	e8 33 d0 ff ff       	call   801015f8 <iput>

  end_op();
801045c5:	e8 76 e2 ff ff       	call   80102840 <end_op>

  return 0;
801045ca:	31 c0                	xor    %eax,%eax
  ip->nlink--;
  iupdate(ip);
  iunlockput(ip);
  end_op();
  return -1;
}
801045cc:	83 c4 3c             	add    $0x3c,%esp
801045cf:	5b                   	pop    %ebx
801045d0:	5e                   	pop    %esi
801045d1:	5f                   	pop    %edi
801045d2:	5d                   	pop    %ebp
801045d3:	c3                   	ret    

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
  ilock(dp);
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    iunlockput(dp);
801045d4:	89 34 24             	mov    %esi,(%esp)
801045d7:	e8 5c d1 ff ff       	call   80101738 <iunlockput>
  end_op();

  return 0;

bad:
  ilock(ip);
801045dc:	89 1c 24             	mov    %ebx,(%esp)
801045df:	e8 04 cf ff ff       	call   801014e8 <ilock>
  ip->nlink--;
801045e4:	66 ff 4b 56          	decw   0x56(%ebx)
  iupdate(ip);
801045e8:	89 1c 24             	mov    %ebx,(%esp)
801045eb:	e8 40 ce ff ff       	call   80101430 <iupdate>
  iunlockput(ip);
801045f0:	89 1c 24             	mov    %ebx,(%esp)
801045f3:	e8 40 d1 ff ff       	call   80101738 <iunlockput>
  end_op();
801045f8:	e8 43 e2 ff ff       	call   80102840 <end_op>
  return -1;
801045fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104602:	83 c4 3c             	add    $0x3c,%esp
80104605:	5b                   	pop    %ebx
80104606:	5e                   	pop    %esi
80104607:	5f                   	pop    %edi
80104608:	5d                   	pop    %ebp
80104609:	c3                   	ret    
8010460a:	66 90                	xchg   %ax,%ax
{
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
    return -1;
8010460c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104611:	eb b9                	jmp    801045cc <sys_link+0xd4>
80104613:	90                   	nop
    return -1;
  }

  ilock(ip);
  if(ip->type == T_DIR){
    iunlockput(ip);
80104614:	89 1c 24             	mov    %ebx,(%esp)
80104617:	e8 1c d1 ff ff       	call   80101738 <iunlockput>
    end_op();
8010461c:	e8 1f e2 ff ff       	call   80102840 <end_op>
    return -1;
80104621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104626:	eb a4                	jmp    801045cc <sys_link+0xd4>

80104628 <sys_unlink>:
}

//PAGEBREAK!
int
sys_unlink(void)
{
80104628:	55                   	push   %ebp
80104629:	89 e5                	mov    %esp,%ebp
8010462b:	57                   	push   %edi
8010462c:	56                   	push   %esi
8010462d:	53                   	push   %ebx
8010462e:	83 ec 6c             	sub    $0x6c,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80104631:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104634:	89 44 24 04          	mov    %eax,0x4(%esp)
80104638:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
8010463f:	e8 4c fa ff ff       	call   80104090 <argstr>
80104644:	85 c0                	test   %eax,%eax
80104646:	0f 88 94 01 00 00    	js     801047e0 <sys_unlink+0x1b8>
    return -1;

  begin_op();
8010464c:	e8 8f e1 ff ff       	call   801027e0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104651:	8d 5d d2             	lea    -0x2e(%ebp),%ebx
80104654:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80104658:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010465b:	89 04 24             	mov    %eax,(%esp)
8010465e:	e8 cd d6 ff ff       	call   80101d30 <nameiparent>
80104663:	89 45 a4             	mov    %eax,-0x5c(%ebp)
80104666:	85 c0                	test   %eax,%eax
80104668:	0f 84 49 01 00 00    	je     801047b7 <sys_unlink+0x18f>
    end_op();
    return -1;
  }

  ilock(dp);
8010466e:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80104671:	89 04 24             	mov    %eax,(%esp)
80104674:	e8 6f ce ff ff       	call   801014e8 <ilock>

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104679:	c7 44 24 04 08 6c 10 	movl   $0x80106c08,0x4(%esp)
80104680:	80 
80104681:	89 1c 24             	mov    %ebx,(%esp)
80104684:	e8 6b d3 ff ff       	call   801019f4 <namecmp>
80104689:	85 c0                	test   %eax,%eax
8010468b:	0f 84 1b 01 00 00    	je     801047ac <sys_unlink+0x184>
80104691:	c7 44 24 04 07 6c 10 	movl   $0x80106c07,0x4(%esp)
80104698:	80 
80104699:	89 1c 24             	mov    %ebx,(%esp)
8010469c:	e8 53 d3 ff ff       	call   801019f4 <namecmp>
801046a1:	85 c0                	test   %eax,%eax
801046a3:	0f 84 03 01 00 00    	je     801047ac <sys_unlink+0x184>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
801046a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801046ac:	89 44 24 08          	mov    %eax,0x8(%esp)
801046b0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
801046b4:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801046b7:	89 04 24             	mov    %eax,(%esp)
801046ba:	e8 59 d3 ff ff       	call   80101a18 <dirlookup>
801046bf:	89 c6                	mov    %eax,%esi
801046c1:	85 c0                	test   %eax,%eax
801046c3:	0f 84 e3 00 00 00    	je     801047ac <sys_unlink+0x184>
    goto bad;
  ilock(ip);
801046c9:	89 04 24             	mov    %eax,(%esp)
801046cc:	e8 17 ce ff ff       	call   801014e8 <ilock>

  if(ip->nlink < 1)
801046d1:	66 83 7e 56 00       	cmpw   $0x0,0x56(%esi)
801046d6:	0f 8e 1a 01 00 00    	jle    801047f6 <sys_unlink+0x1ce>
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
801046dc:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801046e1:	74 7d                	je     80104760 <sys_unlink+0x138>
    iunlockput(ip);
    goto bad;
  }

  memset(&de, 0, sizeof(de));
801046e3:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
801046ea:	00 
801046eb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801046f2:	00 
801046f3:	8d 5d b2             	lea    -0x4e(%ebp),%ebx
801046f6:	89 1c 24             	mov    %ebx,(%esp)
801046f9:	e8 ae f6 ff ff       	call   80103dac <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801046fe:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80104705:	00 
80104706:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104709:	89 44 24 08          	mov    %eax,0x8(%esp)
8010470d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
80104711:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80104714:	89 04 24             	mov    %eax,(%esp)
80104717:	e8 94 d1 ff ff       	call   801018b0 <writei>
8010471c:	83 f8 10             	cmp    $0x10,%eax
8010471f:	0f 85 dd 00 00 00    	jne    80104802 <sys_unlink+0x1da>
    panic("unlink: writei");
  if(ip->type == T_DIR){
80104725:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010472a:	0f 84 9c 00 00 00    	je     801047cc <sys_unlink+0x1a4>
    dp->nlink--;
    iupdate(dp);
  }
  iunlockput(dp);
80104730:	8b 45 a4             	mov    -0x5c(%ebp),%eax
80104733:	89 04 24             	mov    %eax,(%esp)
80104736:	e8 fd cf ff ff       	call   80101738 <iunlockput>

  ip->nlink--;
8010473b:	66 ff 4e 56          	decw   0x56(%esi)
  iupdate(ip);
8010473f:	89 34 24             	mov    %esi,(%esp)
80104742:	e8 e9 cc ff ff       	call   80101430 <iupdate>
  iunlockput(ip);
80104747:	89 34 24             	mov    %esi,(%esp)
8010474a:	e8 e9 cf ff ff       	call   80101738 <iunlockput>

  end_op();
8010474f:	e8 ec e0 ff ff       	call   80102840 <end_op>

  return 0;
80104754:	31 c0                	xor    %eax,%eax

bad:
  iunlockput(dp);
  end_op();
  return -1;
}
80104756:	83 c4 6c             	add    $0x6c,%esp
80104759:	5b                   	pop    %ebx
8010475a:	5e                   	pop    %esi
8010475b:	5f                   	pop    %edi
8010475c:	5d                   	pop    %ebp
8010475d:	c3                   	ret    
8010475e:	66 90                	xchg   %ax,%ax
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104760:	83 7e 58 20          	cmpl   $0x20,0x58(%esi)
80104764:	0f 86 79 ff ff ff    	jbe    801046e3 <sys_unlink+0xbb>
8010476a:	bb 20 00 00 00       	mov    $0x20,%ebx
8010476f:	8d 7d c2             	lea    -0x3e(%ebp),%edi
80104772:	eb 0c                	jmp    80104780 <sys_unlink+0x158>
80104774:	83 c3 10             	add    $0x10,%ebx
80104777:	3b 5e 58             	cmp    0x58(%esi),%ebx
8010477a:	0f 83 63 ff ff ff    	jae    801046e3 <sys_unlink+0xbb>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104780:	c7 44 24 0c 10 00 00 	movl   $0x10,0xc(%esp)
80104787:	00 
80104788:	89 5c 24 08          	mov    %ebx,0x8(%esp)
8010478c:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104790:	89 34 24             	mov    %esi,(%esp)
80104793:	e8 ec cf ff ff       	call   80101784 <readi>
80104798:	83 f8 10             	cmp    $0x10,%eax
8010479b:	75 4d                	jne    801047ea <sys_unlink+0x1c2>
      panic("isdirempty: readi");
    if(de.inum != 0)
8010479d:	66 83 7d c2 00       	cmpw   $0x0,-0x3e(%ebp)
801047a2:	74 d0                	je     80104774 <sys_unlink+0x14c>
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
  if(ip->type == T_DIR && !isdirempty(ip)){
    iunlockput(ip);
801047a4:	89 34 24             	mov    %esi,(%esp)
801047a7:	e8 8c cf ff ff       	call   80101738 <iunlockput>
  end_op();

  return 0;

bad:
  iunlockput(dp);
801047ac:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801047af:	89 04 24             	mov    %eax,(%esp)
801047b2:	e8 81 cf ff ff       	call   80101738 <iunlockput>
  end_op();
801047b7:	e8 84 e0 ff ff       	call   80102840 <end_op>
  return -1;
801047bc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801047c1:	83 c4 6c             	add    $0x6c,%esp
801047c4:	5b                   	pop    %ebx
801047c5:	5e                   	pop    %esi
801047c6:	5f                   	pop    %edi
801047c7:	5d                   	pop    %ebp
801047c8:	c3                   	ret    
801047c9:	8d 76 00             	lea    0x0(%esi),%esi

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
  if(ip->type == T_DIR){
    dp->nlink--;
801047cc:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801047cf:	66 ff 48 56          	decw   0x56(%eax)
    iupdate(dp);
801047d3:	89 04 24             	mov    %eax,(%esp)
801047d6:	e8 55 cc ff ff       	call   80101430 <iupdate>
801047db:	e9 50 ff ff ff       	jmp    80104730 <sys_unlink+0x108>
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
    return -1;
801047e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047e5:	e9 6c ff ff ff       	jmp    80104756 <sys_unlink+0x12e>
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
801047ea:	c7 04 24 38 6c 10 80 	movl   $0x80106c38,(%esp)
801047f1:	e8 26 bb ff ff       	call   8010031c <panic>
  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
  ilock(ip);

  if(ip->nlink < 1)
    panic("unlink: nlink < 1");
801047f6:	c7 04 24 26 6c 10 80 	movl   $0x80106c26,(%esp)
801047fd:	e8 1a bb ff ff       	call   8010031c <panic>
    goto bad;
  }

  memset(&de, 0, sizeof(de));
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
    panic("unlink: writei");
80104802:	c7 04 24 4a 6c 10 80 	movl   $0x80106c4a,(%esp)
80104809:	e8 0e bb ff ff       	call   8010031c <panic>
8010480e:	66 90                	xchg   %ax,%ax

80104810 <sys_open>:
  return ip;
}

int
sys_open(void)
{
80104810:	55                   	push   %ebp
80104811:	89 e5                	mov    %esp,%ebp
80104813:	56                   	push   %esi
80104814:	53                   	push   %ebx
80104815:	83 ec 30             	sub    $0x30,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104818:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010481b:	89 44 24 04          	mov    %eax,0x4(%esp)
8010481f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104826:	e8 65 f8 ff ff       	call   80104090 <argstr>
8010482b:	85 c0                	test   %eax,%eax
8010482d:	0f 88 e9 00 00 00    	js     8010491c <sys_open+0x10c>
80104833:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104836:	89 44 24 04          	mov    %eax,0x4(%esp)
8010483a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104841:	e8 ca f7 ff ff       	call   80104010 <argint>
80104846:	85 c0                	test   %eax,%eax
80104848:	0f 88 ce 00 00 00    	js     8010491c <sys_open+0x10c>
    return -1;

  begin_op();
8010484e:	e8 8d df ff ff       	call   801027e0 <begin_op>

  if(omode & O_CREATE){
80104853:	f6 45 f5 02          	testb  $0x2,-0xb(%ebp)
80104857:	75 7b                	jne    801048d4 <sys_open+0xc4>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80104859:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010485c:	89 04 24             	mov    %eax,(%esp)
8010485f:	e8 b4 d4 ff ff       	call   80101d18 <namei>
80104864:	89 c6                	mov    %eax,%esi
80104866:	85 c0                	test   %eax,%eax
80104868:	0f 84 82 00 00 00    	je     801048f0 <sys_open+0xe0>
      end_op();
      return -1;
    }
    ilock(ip);
8010486e:	89 04 24             	mov    %eax,(%esp)
80104871:	e8 72 cc ff ff       	call   801014e8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104876:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010487b:	74 7f                	je     801048fc <sys_open+0xec>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010487d:	e8 e6 c3 ff ff       	call   80100c68 <filealloc>
80104882:	89 c3                	mov    %eax,%ebx
80104884:	85 c0                	test   %eax,%eax
80104886:	0f 84 a0 00 00 00    	je     8010492c <sys_open+0x11c>
8010488c:	e8 9b f8 ff ff       	call   8010412c <fdalloc>
80104891:	85 c0                	test   %eax,%eax
80104893:	0f 88 8b 00 00 00    	js     80104924 <sys_open+0x114>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104899:	89 34 24             	mov    %esi,(%esp)
8010489c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010489f:	e8 14 cd ff ff       	call   801015b8 <iunlock>
  end_op();
801048a4:	e8 97 df ff ff       	call   80102840 <end_op>

  f->type = FD_INODE;
801048a9:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801048af:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801048b2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801048b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048bc:	f6 c2 01             	test   $0x1,%dl
801048bf:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801048c3:	83 e2 03             	and    $0x3,%edx
801048c6:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
801048ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
801048cd:	83 c4 30             	add    $0x30,%esp
801048d0:	5b                   	pop    %ebx
801048d1:	5e                   	pop    %esi
801048d2:	5d                   	pop    %ebp
801048d3:	c3                   	ret    
    return -1;

  begin_op();

  if(omode & O_CREATE){
    ip = create(path, T_FILE, 0, 0);
801048d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801048db:	31 c9                	xor    %ecx,%ecx
801048dd:	ba 02 00 00 00       	mov    $0x2,%edx
801048e2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801048e5:	e8 7a f8 ff ff       	call   80104164 <create>
801048ea:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801048ec:	85 c0                	test   %eax,%eax
801048ee:	75 8d                	jne    8010487d <sys_open+0x6d>

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
    iunlockput(ip);
    end_op();
801048f0:	e8 4b df ff ff       	call   80102840 <end_op>
    return -1;
801048f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048fa:	eb d1                	jmp    801048cd <sys_open+0xbd>
    if((ip = namei(path)) == 0){
      end_op();
      return -1;
    }
    ilock(ip);
    if(ip->type == T_DIR && omode != O_RDONLY){
801048fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048ff:	85 c0                	test   %eax,%eax
80104901:	0f 84 76 ff ff ff    	je     8010487d <sys_open+0x6d>
      iunlockput(ip);
80104907:	89 34 24             	mov    %esi,(%esp)
8010490a:	e8 29 ce ff ff       	call   80101738 <iunlockput>
      end_op();
8010490f:	e8 2c df ff ff       	call   80102840 <end_op>
      return -1;
80104914:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104919:	eb b2                	jmp    801048cd <sys_open+0xbd>
8010491b:	90                   	nop
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
    return -1;
8010491c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104921:	eb aa                	jmp    801048cd <sys_open+0xbd>
80104923:	90                   	nop
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    if(f)
      fileclose(f);
80104924:	89 1c 24             	mov    %ebx,(%esp)
80104927:	e8 ec c3 ff ff       	call   80100d18 <fileclose>
    iunlockput(ip);
8010492c:	89 34 24             	mov    %esi,(%esp)
8010492f:	e8 04 ce ff ff       	call   80101738 <iunlockput>
80104934:	eb ba                	jmp    801048f0 <sys_open+0xe0>
80104936:	66 90                	xchg   %ax,%ax

80104938 <sys_mkdir>:
  return fd;
}

int
sys_mkdir(void)
{
80104938:	55                   	push   %ebp
80104939:	89 e5                	mov    %esp,%ebp
8010493b:	83 ec 28             	sub    $0x28,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010493e:	e8 9d de ff ff       	call   801027e0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104943:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104946:	89 44 24 04          	mov    %eax,0x4(%esp)
8010494a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104951:	e8 3a f7 ff ff       	call   80104090 <argstr>
80104956:	85 c0                	test   %eax,%eax
80104958:	78 2e                	js     80104988 <sys_mkdir+0x50>
8010495a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104961:	31 c9                	xor    %ecx,%ecx
80104963:	ba 01 00 00 00       	mov    $0x1,%edx
80104968:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010496b:	e8 f4 f7 ff ff       	call   80104164 <create>
80104970:	85 c0                	test   %eax,%eax
80104972:	74 14                	je     80104988 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104974:	89 04 24             	mov    %eax,(%esp)
80104977:	e8 bc cd ff ff       	call   80101738 <iunlockput>
  end_op();
8010497c:	e8 bf de ff ff       	call   80102840 <end_op>
  return 0;
80104981:	31 c0                	xor    %eax,%eax
}
80104983:	c9                   	leave  
80104984:	c3                   	ret    
80104985:	8d 76 00             	lea    0x0(%esi),%esi
  char *path;
  struct inode *ip;

  begin_op();
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    end_op();
80104988:	e8 b3 de ff ff       	call   80102840 <end_op>
    return -1;
8010498d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  iunlockput(ip);
  end_op();
  return 0;
}
80104992:	c9                   	leave  
80104993:	c3                   	ret    

80104994 <sys_mknod>:

int
sys_mknod(void)
{
80104994:	55                   	push   %ebp
80104995:	89 e5                	mov    %esp,%ebp
80104997:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010499a:	e8 41 de ff ff       	call   801027e0 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010499f:	8d 45 ec             	lea    -0x14(%ebp),%eax
801049a2:	89 44 24 04          	mov    %eax,0x4(%esp)
801049a6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
801049ad:	e8 de f6 ff ff       	call   80104090 <argstr>
801049b2:	85 c0                	test   %eax,%eax
801049b4:	78 5e                	js     80104a14 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
801049b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
801049b9:	89 44 24 04          	mov    %eax,0x4(%esp)
801049bd:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801049c4:	e8 47 f6 ff ff       	call   80104010 <argint>
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
801049c9:	85 c0                	test   %eax,%eax
801049cb:	78 47                	js     80104a14 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801049cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049d0:	89 44 24 04          	mov    %eax,0x4(%esp)
801049d4:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
801049db:	e8 30 f6 ff ff       	call   80104010 <argint>
  char *path;
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801049e0:	85 c0                	test   %eax,%eax
801049e2:	78 30                	js     80104a14 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801049e4:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
801049e8:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801049ec:	89 04 24             	mov    %eax,(%esp)
  int major, minor;

  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801049ef:	ba 03 00 00 00       	mov    $0x3,%edx
801049f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801049f7:	e8 68 f7 ff ff       	call   80104164 <create>
801049fc:	85 c0                	test   %eax,%eax
801049fe:	74 14                	je     80104a14 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a00:	89 04 24             	mov    %eax,(%esp)
80104a03:	e8 30 cd ff ff       	call   80101738 <iunlockput>
  end_op();
80104a08:	e8 33 de ff ff       	call   80102840 <end_op>
  return 0;
80104a0d:	31 c0                	xor    %eax,%eax
}
80104a0f:	c9                   	leave  
80104a10:	c3                   	ret    
80104a11:	8d 76 00             	lea    0x0(%esi),%esi
  begin_op();
  if((argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80104a14:	e8 27 de ff ff       	call   80102840 <end_op>
    return -1;
80104a19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  iunlockput(ip);
  end_op();
  return 0;
}
80104a1e:	c9                   	leave  
80104a1f:	c3                   	ret    

80104a20 <sys_chdir>:

int
sys_chdir(void)
{
80104a20:	55                   	push   %ebp
80104a21:	89 e5                	mov    %esp,%ebp
80104a23:	56                   	push   %esi
80104a24:	53                   	push   %ebx
80104a25:	83 ec 20             	sub    $0x20,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104a28:	e8 83 e8 ff ff       	call   801032b0 <myproc>
80104a2d:	89 c3                	mov    %eax,%ebx
  
  begin_op();
80104a2f:	e8 ac dd ff ff       	call   801027e0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104a34:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a37:	89 44 24 04          	mov    %eax,0x4(%esp)
80104a3b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104a42:	e8 49 f6 ff ff       	call   80104090 <argstr>
80104a47:	85 c0                	test   %eax,%eax
80104a49:	78 4a                	js     80104a95 <sys_chdir+0x75>
80104a4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a4e:	89 04 24             	mov    %eax,(%esp)
80104a51:	e8 c2 d2 ff ff       	call   80101d18 <namei>
80104a56:	89 c6                	mov    %eax,%esi
80104a58:	85 c0                	test   %eax,%eax
80104a5a:	74 39                	je     80104a95 <sys_chdir+0x75>
    end_op();
    return -1;
  }
  ilock(ip);
80104a5c:	89 04 24             	mov    %eax,(%esp)
80104a5f:	e8 84 ca ff ff       	call   801014e8 <ilock>
  if(ip->type != T_DIR){
80104a64:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
    iunlockput(ip);
80104a69:	89 34 24             	mov    %esi,(%esp)
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
    end_op();
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
80104a6c:	75 22                	jne    80104a90 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104a6e:	e8 45 cb ff ff       	call   801015b8 <iunlock>
  iput(curproc->cwd);
80104a73:	8b 43 68             	mov    0x68(%ebx),%eax
80104a76:	89 04 24             	mov    %eax,(%esp)
80104a79:	e8 7a cb ff ff       	call   801015f8 <iput>
  end_op();
80104a7e:	e8 bd dd ff ff       	call   80102840 <end_op>
  curproc->cwd = ip;
80104a83:	89 73 68             	mov    %esi,0x68(%ebx)
  return 0;
80104a86:	31 c0                	xor    %eax,%eax
}
80104a88:	83 c4 20             	add    $0x20,%esp
80104a8b:	5b                   	pop    %ebx
80104a8c:	5e                   	pop    %esi
80104a8d:	5d                   	pop    %ebp
80104a8e:	c3                   	ret    
80104a8f:	90                   	nop
    end_op();
    return -1;
  }
  ilock(ip);
  if(ip->type != T_DIR){
    iunlockput(ip);
80104a90:	e8 a3 cc ff ff       	call   80101738 <iunlockput>
    end_op();
80104a95:	e8 a6 dd ff ff       	call   80102840 <end_op>
    return -1;
80104a9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  iunlock(ip);
  iput(curproc->cwd);
  end_op();
  curproc->cwd = ip;
  return 0;
}
80104a9f:	83 c4 20             	add    $0x20,%esp
80104aa2:	5b                   	pop    %ebx
80104aa3:	5e                   	pop    %esi
80104aa4:	5d                   	pop    %ebp
80104aa5:	c3                   	ret    
80104aa6:	66 90                	xchg   %ax,%ax

80104aa8 <sys_exec>:

int
sys_exec(void)
{
80104aa8:	55                   	push   %ebp
80104aa9:	89 e5                	mov    %esp,%ebp
80104aab:	57                   	push   %edi
80104aac:	56                   	push   %esi
80104aad:	53                   	push   %ebx
80104aae:	81 ec ac 00 00 00    	sub    $0xac,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104ab4:	8d 45 dc             	lea    -0x24(%ebp),%eax
80104ab7:	89 44 24 04          	mov    %eax,0x4(%esp)
80104abb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104ac2:	e8 c9 f5 ff ff       	call   80104090 <argstr>
80104ac7:	85 c0                	test   %eax,%eax
80104ac9:	78 78                	js     80104b43 <sys_exec+0x9b>
80104acb:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104ace:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ad2:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80104ad9:	e8 32 f5 ff ff       	call   80104010 <argint>
80104ade:	85 c0                	test   %eax,%eax
80104ae0:	78 61                	js     80104b43 <sys_exec+0x9b>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104ae2:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
80104ae9:	00 
80104aea:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80104af1:	00 
80104af2:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
80104af8:	89 3c 24             	mov    %edi,(%esp)
80104afb:	e8 ac f2 ff ff       	call   80103dac <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv))
80104b00:	31 f6                	xor    %esi,%esi

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80104b02:	31 db                	xor    %ebx,%ebx
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b04:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104b07:	89 44 24 04          	mov    %eax,0x4(%esp)
  curproc->cwd = ip;
  return 0;
}

int
sys_exec(void)
80104b0b:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b12:	03 45 e0             	add    -0x20(%ebp),%eax
80104b15:	89 04 24             	mov    %eax,(%esp)
80104b18:	e8 7b f4 ff ff       	call   80103f98 <fetchint>
80104b1d:	85 c0                	test   %eax,%eax
80104b1f:	78 22                	js     80104b43 <sys_exec+0x9b>
      return -1;
    if(uarg == 0){
80104b21:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104b24:	85 c0                	test   %eax,%eax
80104b26:	74 2c                	je     80104b54 <sys_exec+0xac>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104b28:	8d 14 b7             	lea    (%edi,%esi,4),%edx
80104b2b:	89 54 24 04          	mov    %edx,0x4(%esp)
80104b2f:	89 04 24             	mov    %eax,(%esp)
80104b32:	e8 91 f4 ff ff       	call   80103fc8 <fetchstr>
80104b37:	85 c0                	test   %eax,%eax
80104b39:	78 08                	js     80104b43 <sys_exec+0x9b>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80104b3b:	43                   	inc    %ebx
    if(i >= NELEM(argv))
80104b3c:	89 de                	mov    %ebx,%esi
80104b3e:	83 fb 20             	cmp    $0x20,%ebx
80104b41:	75 c1                	jne    80104b04 <sys_exec+0x5c>
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
80104b43:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return exec(path, argv);
}
80104b48:	81 c4 ac 00 00 00    	add    $0xac,%esp
80104b4e:	5b                   	pop    %ebx
80104b4f:	5e                   	pop    %esi
80104b50:	5f                   	pop    %edi
80104b51:	5d                   	pop    %ebp
80104b52:	c3                   	ret    
80104b53:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
      return -1;
    if(uarg == 0){
      argv[i] = 0;
80104b54:	c7 84 9d 5c ff ff ff 	movl   $0x0,-0xa4(%ebp,%ebx,4)
80104b5b:	00 00 00 00 
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80104b5f:	89 7c 24 04          	mov    %edi,0x4(%esp)
80104b63:	8b 45 dc             	mov    -0x24(%ebp),%eax
80104b66:	89 04 24             	mov    %eax,(%esp)
80104b69:	e8 66 bd ff ff       	call   801008d4 <exec>
}
80104b6e:	81 c4 ac 00 00 00    	add    $0xac,%esp
80104b74:	5b                   	pop    %ebx
80104b75:	5e                   	pop    %esi
80104b76:	5f                   	pop    %edi
80104b77:	5d                   	pop    %ebp
80104b78:	c3                   	ret    
80104b79:	8d 76 00             	lea    0x0(%esi),%esi

80104b7c <sys_pipe>:

int
sys_pipe(void)
{
80104b7c:	55                   	push   %ebp
80104b7d:	89 e5                	mov    %esp,%ebp
80104b7f:	53                   	push   %ebx
80104b80:	83 ec 24             	sub    $0x24,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b83:	c7 44 24 08 08 00 00 	movl   $0x8,0x8(%esp)
80104b8a:	00 
80104b8b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b8e:	89 44 24 04          	mov    %eax,0x4(%esp)
80104b92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104b99:	e8 9a f4 ff ff       	call   80104038 <argptr>
80104b9e:	85 c0                	test   %eax,%eax
80104ba0:	78 46                	js     80104be8 <sys_pipe+0x6c>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104ba2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ba9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104bac:	89 04 24             	mov    %eax,(%esp)
80104baf:	e8 f0 e1 ff ff       	call   80102da4 <pipealloc>
80104bb4:	85 c0                	test   %eax,%eax
80104bb6:	78 30                	js     80104be8 <sys_pipe+0x6c>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104bb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104bbb:	e8 6c f5 ff ff       	call   8010412c <fdalloc>
80104bc0:	89 c3                	mov    %eax,%ebx
80104bc2:	85 c0                	test   %eax,%eax
80104bc4:	78 37                	js     80104bfd <sys_pipe+0x81>
80104bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc9:	e8 5e f5 ff ff       	call   8010412c <fdalloc>
80104bce:	85 c0                	test   %eax,%eax
80104bd0:	78 1e                	js     80104bf0 <sys_pipe+0x74>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104bd2:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104bd5:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104bd7:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104bda:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104bdd:	31 c0                	xor    %eax,%eax
}
80104bdf:	83 c4 24             	add    $0x24,%esp
80104be2:	5b                   	pop    %ebx
80104be3:	5d                   	pop    %ebp
80104be4:	c3                   	ret    
80104be5:	8d 76 00             	lea    0x0(%esi),%esi
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
    return -1;
  if(pipealloc(&rf, &wf) < 0)
    return -1;
80104be8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bed:	eb f0                	jmp    80104bdf <sys_pipe+0x63>
80104bef:	90                   	nop
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
80104bf0:	e8 bb e6 ff ff       	call   801032b0 <myproc>
80104bf5:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104bfc:	00 
    fileclose(rf);
80104bfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c00:	89 04 24             	mov    %eax,(%esp)
80104c03:	e8 10 c1 ff ff       	call   80100d18 <fileclose>
    fileclose(wf);
80104c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c0b:	89 04 24             	mov    %eax,(%esp)
80104c0e:	e8 05 c1 ff ff       	call   80100d18 <fileclose>
    return -1;
80104c13:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c18:	eb c5                	jmp    80104bdf <sys_pipe+0x63>
	...

80104c1c <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104c1c:	55                   	push   %ebp
80104c1d:	89 e5                	mov    %esp,%ebp
  return fork();
}
80104c1f:	5d                   	pop    %ebp
#include "proc.h"

int
sys_fork(void)
{
  return fork();
80104c20:	e9 13 e8 ff ff       	jmp    80103438 <fork>
80104c25:	8d 76 00             	lea    0x0(%esi),%esi

80104c28 <sys_exit>:
}

int
sys_exit(void)
{
80104c28:	55                   	push   %ebp
80104c29:	89 e5                	mov    %esp,%ebp
80104c2b:	83 ec 08             	sub    $0x8,%esp
  exit();
80104c2e:	e8 45 ea ff ff       	call   80103678 <exit>
  return 0;  // not reached
}
80104c33:	31 c0                	xor    %eax,%eax
80104c35:	c9                   	leave  
80104c36:	c3                   	ret    
80104c37:	90                   	nop

80104c38 <sys_wait>:

int
sys_wait(void)
{
80104c38:	55                   	push   %ebp
80104c39:	89 e5                	mov    %esp,%ebp
  return wait();
}
80104c3b:	5d                   	pop    %ebp
}

int
sys_wait(void)
{
  return wait();
80104c3c:	e9 17 ec ff ff       	jmp    80103858 <wait>
80104c41:	8d 76 00             	lea    0x0(%esi),%esi

80104c44 <sys_kill>:
}

int
sys_kill(void)
{
80104c44:	55                   	push   %ebp
80104c45:	89 e5                	mov    %esp,%ebp
80104c47:	83 ec 28             	sub    $0x28,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104c4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c4d:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c51:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104c58:	e8 b3 f3 ff ff       	call   80104010 <argint>
80104c5d:	85 c0                	test   %eax,%eax
80104c5f:	78 0f                	js     80104c70 <sys_kill+0x2c>
    return -1;
  return kill(pid);
80104c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c64:	89 04 24             	mov    %eax,(%esp)
80104c67:	e8 20 ed ff ff       	call   8010398c <kill>
}
80104c6c:	c9                   	leave  
80104c6d:	c3                   	ret    
80104c6e:	66 90                	xchg   %ax,%ax
sys_kill(void)
{
  int pid;

  if(argint(0, &pid) < 0)
    return -1;
80104c70:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return kill(pid);
}
80104c75:	c9                   	leave  
80104c76:	c3                   	ret    
80104c77:	90                   	nop

80104c78 <sys_getpid>:

int
sys_getpid(void)
{
80104c78:	55                   	push   %ebp
80104c79:	89 e5                	mov    %esp,%ebp
80104c7b:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c7e:	e8 2d e6 ff ff       	call   801032b0 <myproc>
80104c83:	8b 40 10             	mov    0x10(%eax),%eax
}
80104c86:	c9                   	leave  
80104c87:	c3                   	ret    

80104c88 <sys_sbrk>:

int
sys_sbrk(void)
{
80104c88:	55                   	push   %ebp
80104c89:	89 e5                	mov    %esp,%ebp
80104c8b:	53                   	push   %ebx
80104c8c:	83 ec 24             	sub    $0x24,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c92:	89 44 24 04          	mov    %eax,0x4(%esp)
80104c96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104c9d:	e8 6e f3 ff ff       	call   80104010 <argint>
80104ca2:	85 c0                	test   %eax,%eax
80104ca4:	78 1e                	js     80104cc4 <sys_sbrk+0x3c>
    return -1;
  addr = myproc()->sz;
80104ca6:	e8 05 e6 ff ff       	call   801032b0 <myproc>
80104cab:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cb0:	89 04 24             	mov    %eax,(%esp)
80104cb3:	e8 14 e7 ff ff       	call   801033cc <growproc>
80104cb8:	85 c0                	test   %eax,%eax
80104cba:	78 08                	js     80104cc4 <sys_sbrk+0x3c>
  int addr;
  int n;

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
80104cbc:	89 d8                	mov    %ebx,%eax
  if(growproc(n) < 0)
    return -1;
  return addr;
}
80104cbe:	83 c4 24             	add    $0x24,%esp
80104cc1:	5b                   	pop    %ebx
80104cc2:	5d                   	pop    %ebp
80104cc3:	c3                   	ret    

  if(argint(0, &n) < 0)
    return -1;
  addr = myproc()->sz;
  if(growproc(n) < 0)
    return -1;
80104cc4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cc9:	eb f3                	jmp    80104cbe <sys_sbrk+0x36>
80104ccb:	90                   	nop

80104ccc <sys_sleep>:
  return addr;
}

int
sys_sleep(void)
{
80104ccc:	55                   	push   %ebp
80104ccd:	89 e5                	mov    %esp,%ebp
80104ccf:	53                   	push   %ebx
80104cd0:	83 ec 24             	sub    $0x24,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104cd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cd6:	89 44 24 04          	mov    %eax,0x4(%esp)
80104cda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
80104ce1:	e8 2a f3 ff ff       	call   80104010 <argint>
80104ce6:	85 c0                	test   %eax,%eax
80104ce8:	78 76                	js     80104d60 <sys_sleep+0x94>
    return -1;
  acquire(&tickslock);
80104cea:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104cf1:	e8 0a f0 ff ff       	call   80103d00 <acquire>
  ticks0 = ticks;
80104cf6:	8b 1d a0 44 11 80    	mov    0x801144a0,%ebx
  while(ticks - ticks0 < n){
80104cfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cff:	85 d2                	test   %edx,%edx
80104d01:	75 25                	jne    80104d28 <sys_sleep+0x5c>
80104d03:	eb 47                	jmp    80104d4c <sys_sleep+0x80>
80104d05:	8d 76 00             	lea    0x0(%esi),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104d08:	c7 44 24 04 60 3c 11 	movl   $0x80113c60,0x4(%esp)
80104d0f:	80 
80104d10:	c7 04 24 a0 44 11 80 	movl   $0x801144a0,(%esp)
80104d17:	e8 98 ea ff ff       	call   801037b4 <sleep>

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80104d1c:	a1 a0 44 11 80       	mov    0x801144a0,%eax
80104d21:	29 d8                	sub    %ebx,%eax
80104d23:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104d26:	73 24                	jae    80104d4c <sys_sleep+0x80>
    if(myproc()->killed){
80104d28:	e8 83 e5 ff ff       	call   801032b0 <myproc>
80104d2d:	8b 40 24             	mov    0x24(%eax),%eax
80104d30:	85 c0                	test   %eax,%eax
80104d32:	74 d4                	je     80104d08 <sys_sleep+0x3c>
      release(&tickslock);
80104d34:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104d3b:	e8 24 f0 ff ff       	call   80103d64 <release>
      return -1;
80104d40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
  return 0;
}
80104d45:	83 c4 24             	add    $0x24,%esp
80104d48:	5b                   	pop    %ebx
80104d49:	5d                   	pop    %ebp
80104d4a:	c3                   	ret    
80104d4b:	90                   	nop
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80104d4c:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104d53:	e8 0c f0 ff ff       	call   80103d64 <release>
  return 0;
80104d58:	31 c0                	xor    %eax,%eax
}
80104d5a:	83 c4 24             	add    $0x24,%esp
80104d5d:	5b                   	pop    %ebx
80104d5e:	5d                   	pop    %ebp
80104d5f:	c3                   	ret    
{
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    return -1;
80104d60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d65:	eb de                	jmp    80104d45 <sys_sleep+0x79>
80104d67:	90                   	nop

80104d68 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104d68:	55                   	push   %ebp
80104d69:	89 e5                	mov    %esp,%ebp
80104d6b:	53                   	push   %ebx
80104d6c:	83 ec 14             	sub    $0x14,%esp
  uint xticks;

  acquire(&tickslock);
80104d6f:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104d76:	e8 85 ef ff ff       	call   80103d00 <acquire>
  xticks = ticks;
80104d7b:	8b 1d a0 44 11 80    	mov    0x801144a0,%ebx
  release(&tickslock);
80104d81:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104d88:	e8 d7 ef ff ff       	call   80103d64 <release>
  return xticks;
}
80104d8d:	89 d8                	mov    %ebx,%eax
80104d8f:	83 c4 14             	add    $0x14,%esp
80104d92:	5b                   	pop    %ebx
80104d93:	5d                   	pop    %ebp
80104d94:	c3                   	ret    
80104d95:	00 00                	add    %al,(%eax)
	...

80104d98 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104d98:	1e                   	push   %ds
  pushl %es
80104d99:	06                   	push   %es
  pushl %fs
80104d9a:	0f a0                	push   %fs
  pushl %gs
80104d9c:	0f a8                	push   %gs
  pushal
80104d9e:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104d9f:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104da3:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104da5:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104da7:	54                   	push   %esp
  call trap
80104da8:	e8 b7 00 00 00       	call   80104e64 <trap>
  addl $4, %esp
80104dad:	83 c4 04             	add    $0x4,%esp

80104db0 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104db0:	61                   	popa   
  popl %gs
80104db1:	0f a9                	pop    %gs
  popl %fs
80104db3:	0f a1                	pop    %fs
  popl %es
80104db5:	07                   	pop    %es
  popl %ds
80104db6:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104db7:	83 c4 08             	add    $0x8,%esp
  iret
80104dba:	cf                   	iret   
	...

80104dbc <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104dbc:	55                   	push   %ebp
80104dbd:	89 e5                	mov    %esp,%ebp
80104dbf:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80104dc2:	31 c0                	xor    %eax,%eax
80104dc4:	ba a0 3c 11 80       	mov    $0x80113ca0,%edx
80104dc9:	8d 76 00             	lea    0x0(%esi),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104dcc:	8b 0c 85 08 90 10 80 	mov    -0x7fef6ff8(,%eax,4),%ecx
80104dd3:	66 89 0c c5 a0 3c 11 	mov    %cx,-0x7feec360(,%eax,8)
80104dda:	80 
80104ddb:	66 c7 44 c2 02 08 00 	movw   $0x8,0x2(%edx,%eax,8)
80104de2:	c6 44 c2 04 00       	movb   $0x0,0x4(%edx,%eax,8)
80104de7:	c6 44 c2 05 8e       	movb   $0x8e,0x5(%edx,%eax,8)
80104dec:	c1 e9 10             	shr    $0x10,%ecx
80104def:	66 89 4c c2 06       	mov    %cx,0x6(%edx,%eax,8)
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80104df4:	40                   	inc    %eax
80104df5:	3d 00 01 00 00       	cmp    $0x100,%eax
80104dfa:	75 d0                	jne    80104dcc <tvinit+0x10>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104dfc:	a1 08 91 10 80       	mov    0x80109108,%eax
80104e01:	66 a3 a0 3e 11 80    	mov    %ax,0x80113ea0
80104e07:	66 c7 05 a2 3e 11 80 	movw   $0x8,0x80113ea2
80104e0e:	08 00 
80104e10:	c6 05 a4 3e 11 80 00 	movb   $0x0,0x80113ea4
80104e17:	c6 05 a5 3e 11 80 ef 	movb   $0xef,0x80113ea5
80104e1e:	c1 e8 10             	shr    $0x10,%eax
80104e21:	66 a3 a6 3e 11 80    	mov    %ax,0x80113ea6

  initlock(&tickslock, "time");
80104e27:	c7 44 24 04 59 6c 10 	movl   $0x80106c59,0x4(%esp)
80104e2e:	80 
80104e2f:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104e36:	e8 89 ed ff ff       	call   80103bc4 <initlock>
}
80104e3b:	c9                   	leave  
80104e3c:	c3                   	ret    
80104e3d:	8d 76 00             	lea    0x0(%esi),%esi

80104e40 <idtinit>:

void
idtinit(void)
{
80104e40:	55                   	push   %ebp
80104e41:	89 e5                	mov    %esp,%ebp
80104e43:	83 ec 10             	sub    $0x10,%esp
static inline void
lidt(struct gatedesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
80104e46:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e4c:	b8 a0 3c 11 80       	mov    $0x80113ca0,%eax
80104e51:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e55:	c1 e8 10             	shr    $0x10,%eax
80104e58:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80104e5c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e5f:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104e62:	c9                   	leave  
80104e63:	c3                   	ret    

80104e64 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80104e64:	55                   	push   %ebp
80104e65:	89 e5                	mov    %esp,%ebp
80104e67:	57                   	push   %edi
80104e68:	56                   	push   %esi
80104e69:	53                   	push   %ebx
80104e6a:	83 ec 3c             	sub    $0x3c,%esp
80104e6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104e70:	8b 43 30             	mov    0x30(%ebx),%eax
80104e73:	83 f8 40             	cmp    $0x40,%eax
80104e76:	0f 84 b0 01 00 00    	je     8010502c <trap+0x1c8>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104e7c:	83 e8 20             	sub    $0x20,%eax
80104e7f:	83 f8 1f             	cmp    $0x1f,%eax
80104e82:	0f 86 f4 00 00 00    	jbe    80104f7c <trap+0x118>
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80104e88:	e8 23 e4 ff ff       	call   801032b0 <myproc>
80104e8d:	85 c0                	test   %eax,%eax
80104e8f:	0f 84 e2 01 00 00    	je     80105077 <trap+0x213>
80104e95:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80104e99:	0f 84 d8 01 00 00    	je     80105077 <trap+0x213>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80104e9f:	0f 20 d2             	mov    %cr2,%edx
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80104ea2:	8b 7b 38             	mov    0x38(%ebx),%edi
80104ea5:	89 55 dc             	mov    %edx,-0x24(%ebp)
80104ea8:	e8 cf e3 ff ff       	call   8010327c <cpuid>
80104ead:	89 c6                	mov    %eax,%esi
80104eaf:	8b 4b 34             	mov    0x34(%ebx),%ecx
80104eb2:	8b 43 30             	mov    0x30(%ebx),%eax
80104eb5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80104eb8:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80104ebb:	e8 f0 e3 ff ff       	call   801032b0 <myproc>
80104ec0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104ec3:	e8 e8 e3 ff ff       	call   801032b0 <myproc>
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80104ec8:	8b 55 dc             	mov    -0x24(%ebp),%edx
80104ecb:	89 54 24 1c          	mov    %edx,0x1c(%esp)
80104ecf:	89 7c 24 18          	mov    %edi,0x18(%esp)
80104ed3:	89 74 24 14          	mov    %esi,0x14(%esp)
80104ed7:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80104eda:	89 4c 24 10          	mov    %ecx,0x10(%esp)
80104ede:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104ee1:	89 54 24 0c          	mov    %edx,0xc(%esp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80104ee5:	8b 55 e0             	mov    -0x20(%ebp),%edx
80104ee8:	83 c2 6c             	add    $0x6c,%edx
80104eeb:	89 54 24 08          	mov    %edx,0x8(%esp)
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80104eef:	8b 40 10             	mov    0x10(%eax),%eax
80104ef2:	89 44 24 04          	mov    %eax,0x4(%esp)
80104ef6:	c7 04 24 bc 6c 10 80 	movl   $0x80106cbc,(%esp)
80104efd:	e8 ba b6 ff ff       	call   801005bc <cprintf>
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80104f02:	e8 a9 e3 ff ff       	call   801032b0 <myproc>
80104f07:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80104f0e:	66 90                	xchg   %ax,%ax
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f10:	e8 9b e3 ff ff       	call   801032b0 <myproc>
80104f15:	85 c0                	test   %eax,%eax
80104f17:	74 1c                	je     80104f35 <trap+0xd1>
80104f19:	e8 92 e3 ff ff       	call   801032b0 <myproc>
80104f1e:	8b 50 24             	mov    0x24(%eax),%edx
80104f21:	85 d2                	test   %edx,%edx
80104f23:	74 10                	je     80104f35 <trap+0xd1>
80104f25:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f29:	83 e0 03             	and    $0x3,%eax
80104f2c:	83 f8 03             	cmp    $0x3,%eax
80104f2f:	0f 84 2f 01 00 00    	je     80105064 <trap+0x200>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f35:	e8 76 e3 ff ff       	call   801032b0 <myproc>
80104f3a:	85 c0                	test   %eax,%eax
80104f3c:	74 0f                	je     80104f4d <trap+0xe9>
80104f3e:	e8 6d e3 ff ff       	call   801032b0 <myproc>
80104f43:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104f47:	0f 84 cb 00 00 00    	je     80105018 <trap+0x1b4>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f4d:	e8 5e e3 ff ff       	call   801032b0 <myproc>
80104f52:	85 c0                	test   %eax,%eax
80104f54:	74 1c                	je     80104f72 <trap+0x10e>
80104f56:	e8 55 e3 ff ff       	call   801032b0 <myproc>
80104f5b:	8b 40 24             	mov    0x24(%eax),%eax
80104f5e:	85 c0                	test   %eax,%eax
80104f60:	74 10                	je     80104f72 <trap+0x10e>
80104f62:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f66:	83 e0 03             	and    $0x3,%eax
80104f69:	83 f8 03             	cmp    $0x3,%eax
80104f6c:	0f 84 e3 00 00 00    	je     80105055 <trap+0x1f1>
    exit();
}
80104f72:	83 c4 3c             	add    $0x3c,%esp
80104f75:	5b                   	pop    %ebx
80104f76:	5e                   	pop    %esi
80104f77:	5f                   	pop    %edi
80104f78:	5d                   	pop    %ebp
80104f79:	c3                   	ret    
80104f7a:	66 90                	xchg   %ax,%ax
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104f7c:	ff 24 85 00 6d 10 80 	jmp    *-0x7fef9300(,%eax,4)
80104f83:	90                   	nop
      release(&tickslock);
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80104f84:	e8 d7 ce ff ff       	call   80101e60 <ideintr>
    lapiceoi();
80104f89:	e8 6e d4 ff ff       	call   801023fc <lapiceoi>
    break;
80104f8e:	eb 80                	jmp    80104f10 <trap+0xac>
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104f90:	8b 7b 38             	mov    0x38(%ebx),%edi
80104f93:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80104f97:	e8 e0 e2 ff ff       	call   8010327c <cpuid>
80104f9c:	89 7c 24 0c          	mov    %edi,0xc(%esp)
80104fa0:	89 74 24 08          	mov    %esi,0x8(%esp)
80104fa4:	89 44 24 04          	mov    %eax,0x4(%esp)
80104fa8:	c7 04 24 64 6c 10 80 	movl   $0x80106c64,(%esp)
80104faf:	e8 08 b6 ff ff       	call   801005bc <cprintf>
            cpuid(), tf->cs, tf->eip);
    lapiceoi();
80104fb4:	e8 43 d4 ff ff       	call   801023fc <lapiceoi>
    break;
80104fb9:	e9 52 ff ff ff       	jmp    80104f10 <trap+0xac>
80104fbe:	66 90                	xchg   %ax,%ax
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80104fc0:	e8 eb 01 00 00       	call   801051b0 <uartintr>
    lapiceoi();
80104fc5:	e8 32 d4 ff ff       	call   801023fc <lapiceoi>
    break;
80104fca:	e9 41 ff ff ff       	jmp    80104f10 <trap+0xac>
80104fcf:	90                   	nop
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80104fd0:	e8 17 d3 ff ff       	call   801022ec <kbdintr>
    lapiceoi();
80104fd5:	e8 22 d4 ff ff       	call   801023fc <lapiceoi>
    break;
80104fda:	e9 31 ff ff ff       	jmp    80104f10 <trap+0xac>
80104fdf:	90                   	nop
    return;
  }

  switch(tf->trapno){
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104fe0:	e8 97 e2 ff ff       	call   8010327c <cpuid>
80104fe5:	85 c0                	test   %eax,%eax
80104fe7:	75 a0                	jne    80104f89 <trap+0x125>
      acquire(&tickslock);
80104fe9:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
80104ff0:	e8 0b ed ff ff       	call   80103d00 <acquire>
      ticks++;
80104ff5:	ff 05 a0 44 11 80    	incl   0x801144a0
      wakeup(&ticks);
80104ffb:	c7 04 24 a0 44 11 80 	movl   $0x801144a0,(%esp)
80105002:	e8 29 e9 ff ff       	call   80103930 <wakeup>
      release(&tickslock);
80105007:	c7 04 24 60 3c 11 80 	movl   $0x80113c60,(%esp)
8010500e:	e8 51 ed ff ff       	call   80103d64 <release>
80105013:	e9 71 ff ff ff       	jmp    80104f89 <trap+0x125>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105018:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010501c:	0f 85 2b ff ff ff    	jne    80104f4d <trap+0xe9>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();
80105022:	e8 59 e7 ff ff       	call   80103780 <yield>
80105027:	e9 21 ff ff ff       	jmp    80104f4d <trap+0xe9>
//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
8010502c:	e8 7f e2 ff ff       	call   801032b0 <myproc>
80105031:	8b 70 24             	mov    0x24(%eax),%esi
80105034:	85 f6                	test   %esi,%esi
80105036:	75 38                	jne    80105070 <trap+0x20c>
      exit();
    myproc()->tf = tf;
80105038:	e8 73 e2 ff ff       	call   801032b0 <myproc>
8010503d:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105040:	e8 83 f0 ff ff       	call   801040c8 <syscall>
    if(myproc()->killed)
80105045:	e8 66 e2 ff ff       	call   801032b0 <myproc>
8010504a:	8b 48 24             	mov    0x24(%eax),%ecx
8010504d:	85 c9                	test   %ecx,%ecx
8010504f:	0f 84 1d ff ff ff    	je     80104f72 <trap+0x10e>
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80105055:	83 c4 3c             	add    $0x3c,%esp
80105058:	5b                   	pop    %ebx
80105059:	5e                   	pop    %esi
8010505a:	5f                   	pop    %edi
8010505b:	5d                   	pop    %ebp
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
8010505c:	e9 17 e6 ff ff       	jmp    80103678 <exit>
80105061:	8d 76 00             	lea    0x0(%esi),%esi

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
    exit();
80105064:	e8 0f e6 ff ff       	call   80103678 <exit>
80105069:	e9 c7 fe ff ff       	jmp    80104f35 <trap+0xd1>
8010506e:	66 90                	xchg   %ax,%ax
void
trap(struct trapframe *tf)
{
  if(tf->trapno == T_SYSCALL){
    if(myproc()->killed)
      exit();
80105070:	e8 03 e6 ff ff       	call   80103678 <exit>
80105075:	eb c1                	jmp    80105038 <trap+0x1d4>
80105077:	0f 20 d7             	mov    %cr2,%edi

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010507a:	8b 73 38             	mov    0x38(%ebx),%esi
8010507d:	e8 fa e1 ff ff       	call   8010327c <cpuid>
80105082:	89 7c 24 10          	mov    %edi,0x10(%esp)
80105086:	89 74 24 0c          	mov    %esi,0xc(%esp)
8010508a:	89 44 24 08          	mov    %eax,0x8(%esp)
8010508e:	8b 43 30             	mov    0x30(%ebx),%eax
80105091:	89 44 24 04          	mov    %eax,0x4(%esp)
80105095:	c7 04 24 88 6c 10 80 	movl   $0x80106c88,(%esp)
8010509c:	e8 1b b5 ff ff       	call   801005bc <cprintf>
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801050a1:	c7 04 24 5e 6c 10 80 	movl   $0x80106c5e,(%esp)
801050a8:	e8 6f b2 ff ff       	call   8010031c <panic>
801050ad:	00 00                	add    %al,(%eax)
	...

801050b0 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801050b0:	55                   	push   %ebp
801050b1:	89 e5                	mov    %esp,%ebp
  if(!uart)
801050b3:	a1 a4 95 10 80       	mov    0x801095a4,%eax
801050b8:	85 c0                	test   %eax,%eax
801050ba:	74 14                	je     801050d0 <uartgetc+0x20>
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801050bc:	ba fd 03 00 00       	mov    $0x3fd,%edx
801050c1:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801050c2:	a8 01                	test   $0x1,%al
801050c4:	74 0a                	je     801050d0 <uartgetc+0x20>
801050c6:	b2 f8                	mov    $0xf8,%dl
801050c8:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801050c9:	0f b6 c0             	movzbl %al,%eax
}
801050cc:	5d                   	pop    %ebp
801050cd:	c3                   	ret    
801050ce:	66 90                	xchg   %ax,%ax
uartgetc(void)
{
  if(!uart)
    return -1;
  if(!(inb(COM1+5) & 0x01))
    return -1;
801050d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return inb(COM1+0);
}
801050d5:	5d                   	pop    %ebp
801050d6:	c3                   	ret    
801050d7:	90                   	nop

801050d8 <uartputc>:
    uartputc(*p);
}

void
uartputc(int c)
{
801050d8:	55                   	push   %ebp
801050d9:	89 e5                	mov    %esp,%ebp
801050db:	56                   	push   %esi
801050dc:	53                   	push   %ebx
801050dd:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(!uart)
801050e0:	8b 15 a4 95 10 80    	mov    0x801095a4,%edx
801050e6:	85 d2                	test   %edx,%edx
801050e8:	74 2d                	je     80105117 <uartputc+0x3f>
801050ea:	bb 80 00 00 00       	mov    $0x80,%ebx
801050ef:	be fd 03 00 00       	mov    $0x3fd,%esi
801050f4:	eb 11                	jmp    80105107 <uartputc+0x2f>
801050f6:	66 90                	xchg   %ax,%ax
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
801050f8:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
801050ff:	e8 14 d3 ff ff       	call   80102418 <microdelay>
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105104:	4b                   	dec    %ebx
80105105:	74 07                	je     8010510e <uartputc+0x36>
80105107:	89 f2                	mov    %esi,%edx
80105109:	ec                   	in     (%dx),%al
8010510a:	a8 20                	test   $0x20,%al
8010510c:	74 ea                	je     801050f8 <uartputc+0x20>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010510e:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105113:	8b 45 08             	mov    0x8(%ebp),%eax
80105116:	ee                   	out    %al,(%dx)
    microdelay(10);
  outb(COM1+0, c);
}
80105117:	83 c4 10             	add    $0x10,%esp
8010511a:	5b                   	pop    %ebx
8010511b:	5e                   	pop    %esi
8010511c:	5d                   	pop    %ebp
8010511d:	c3                   	ret    
8010511e:	66 90                	xchg   %ax,%ax

80105120 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80105120:	55                   	push   %ebp
80105121:	89 e5                	mov    %esp,%ebp
80105123:	57                   	push   %edi
80105124:	56                   	push   %esi
80105125:	53                   	push   %ebx
80105126:	83 ec 1c             	sub    $0x1c,%esp
80105129:	be fa 03 00 00       	mov    $0x3fa,%esi
8010512e:	31 c0                	xor    %eax,%eax
80105130:	89 f2                	mov    %esi,%edx
80105132:	ee                   	out    %al,(%dx)
80105133:	bb fb 03 00 00       	mov    $0x3fb,%ebx
80105138:	b0 80                	mov    $0x80,%al
8010513a:	89 da                	mov    %ebx,%edx
8010513c:	ee                   	out    %al,(%dx)
8010513d:	bf f8 03 00 00       	mov    $0x3f8,%edi
80105142:	b0 0c                	mov    $0xc,%al
80105144:	89 fa                	mov    %edi,%edx
80105146:	ee                   	out    %al,(%dx)
80105147:	b9 f9 03 00 00       	mov    $0x3f9,%ecx
8010514c:	31 c0                	xor    %eax,%eax
8010514e:	89 ca                	mov    %ecx,%edx
80105150:	ee                   	out    %al,(%dx)
80105151:	b0 03                	mov    $0x3,%al
80105153:	89 da                	mov    %ebx,%edx
80105155:	ee                   	out    %al,(%dx)
80105156:	b2 fc                	mov    $0xfc,%dl
80105158:	31 c0                	xor    %eax,%eax
8010515a:	ee                   	out    %al,(%dx)
8010515b:	b0 01                	mov    $0x1,%al
8010515d:	89 ca                	mov    %ecx,%edx
8010515f:	ee                   	out    %al,(%dx)
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105160:	b2 fd                	mov    $0xfd,%dl
80105162:	ec                   	in     (%dx),%al
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80105163:	fe c0                	inc    %al
80105165:	74 3f                	je     801051a6 <uartinit+0x86>
    return;
  uart = 1;
80105167:	c7 05 a4 95 10 80 01 	movl   $0x1,0x801095a4
8010516e:	00 00 00 
80105171:	89 f2                	mov    %esi,%edx
80105173:	ec                   	in     (%dx),%al
80105174:	89 fa                	mov    %edi,%edx
80105176:	ec                   	in     (%dx),%al

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);
80105177:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010517e:	00 
8010517f:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
80105186:	e8 d9 ce ff ff       	call   80102064 <ioapicenable>

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010518b:	b0 78                	mov    $0x78,%al
8010518d:	bb 80 6d 10 80       	mov    $0x80106d80,%ebx
80105192:	66 90                	xchg   %ax,%ax
    uartputc(*p);
80105194:	0f be c0             	movsbl %al,%eax
80105197:	89 04 24             	mov    %eax,(%esp)
8010519a:	e8 39 ff ff ff       	call   801050d8 <uartputc>
  inb(COM1+2);
  inb(COM1+0);
  ioapicenable(IRQ_COM1, 0);

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
8010519f:	43                   	inc    %ebx
801051a0:	8a 03                	mov    (%ebx),%al
801051a2:	84 c0                	test   %al,%al
801051a4:	75 ee                	jne    80105194 <uartinit+0x74>
    uartputc(*p);
}
801051a6:	83 c4 1c             	add    $0x1c,%esp
801051a9:	5b                   	pop    %ebx
801051aa:	5e                   	pop    %esi
801051ab:	5f                   	pop    %edi
801051ac:	5d                   	pop    %ebp
801051ad:	c3                   	ret    
801051ae:	66 90                	xchg   %ax,%ax

801051b0 <uartintr>:
  return inb(COM1+0);
}

void
uartintr(void)
{
801051b0:	55                   	push   %ebp
801051b1:	89 e5                	mov    %esp,%ebp
801051b3:	83 ec 18             	sub    $0x18,%esp
  consoleintr(uartgetc);
801051b6:	c7 04 24 b0 50 10 80 	movl   $0x801050b0,(%esp)
801051bd:	e8 3a b5 ff ff       	call   801006fc <consoleintr>
}
801051c2:	c9                   	leave  
801051c3:	c3                   	ret    

801051c4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801051c4:	6a 00                	push   $0x0
  pushl $0
801051c6:	6a 00                	push   $0x0
  jmp alltraps
801051c8:	e9 cb fb ff ff       	jmp    80104d98 <alltraps>

801051cd <vector1>:
.globl vector1
vector1:
  pushl $0
801051cd:	6a 00                	push   $0x0
  pushl $1
801051cf:	6a 01                	push   $0x1
  jmp alltraps
801051d1:	e9 c2 fb ff ff       	jmp    80104d98 <alltraps>

801051d6 <vector2>:
.globl vector2
vector2:
  pushl $0
801051d6:	6a 00                	push   $0x0
  pushl $2
801051d8:	6a 02                	push   $0x2
  jmp alltraps
801051da:	e9 b9 fb ff ff       	jmp    80104d98 <alltraps>

801051df <vector3>:
.globl vector3
vector3:
  pushl $0
801051df:	6a 00                	push   $0x0
  pushl $3
801051e1:	6a 03                	push   $0x3
  jmp alltraps
801051e3:	e9 b0 fb ff ff       	jmp    80104d98 <alltraps>

801051e8 <vector4>:
.globl vector4
vector4:
  pushl $0
801051e8:	6a 00                	push   $0x0
  pushl $4
801051ea:	6a 04                	push   $0x4
  jmp alltraps
801051ec:	e9 a7 fb ff ff       	jmp    80104d98 <alltraps>

801051f1 <vector5>:
.globl vector5
vector5:
  pushl $0
801051f1:	6a 00                	push   $0x0
  pushl $5
801051f3:	6a 05                	push   $0x5
  jmp alltraps
801051f5:	e9 9e fb ff ff       	jmp    80104d98 <alltraps>

801051fa <vector6>:
.globl vector6
vector6:
  pushl $0
801051fa:	6a 00                	push   $0x0
  pushl $6
801051fc:	6a 06                	push   $0x6
  jmp alltraps
801051fe:	e9 95 fb ff ff       	jmp    80104d98 <alltraps>

80105203 <vector7>:
.globl vector7
vector7:
  pushl $0
80105203:	6a 00                	push   $0x0
  pushl $7
80105205:	6a 07                	push   $0x7
  jmp alltraps
80105207:	e9 8c fb ff ff       	jmp    80104d98 <alltraps>

8010520c <vector8>:
.globl vector8
vector8:
  pushl $8
8010520c:	6a 08                	push   $0x8
  jmp alltraps
8010520e:	e9 85 fb ff ff       	jmp    80104d98 <alltraps>

80105213 <vector9>:
.globl vector9
vector9:
  pushl $0
80105213:	6a 00                	push   $0x0
  pushl $9
80105215:	6a 09                	push   $0x9
  jmp alltraps
80105217:	e9 7c fb ff ff       	jmp    80104d98 <alltraps>

8010521c <vector10>:
.globl vector10
vector10:
  pushl $10
8010521c:	6a 0a                	push   $0xa
  jmp alltraps
8010521e:	e9 75 fb ff ff       	jmp    80104d98 <alltraps>

80105223 <vector11>:
.globl vector11
vector11:
  pushl $11
80105223:	6a 0b                	push   $0xb
  jmp alltraps
80105225:	e9 6e fb ff ff       	jmp    80104d98 <alltraps>

8010522a <vector12>:
.globl vector12
vector12:
  pushl $12
8010522a:	6a 0c                	push   $0xc
  jmp alltraps
8010522c:	e9 67 fb ff ff       	jmp    80104d98 <alltraps>

80105231 <vector13>:
.globl vector13
vector13:
  pushl $13
80105231:	6a 0d                	push   $0xd
  jmp alltraps
80105233:	e9 60 fb ff ff       	jmp    80104d98 <alltraps>

80105238 <vector14>:
.globl vector14
vector14:
  pushl $14
80105238:	6a 0e                	push   $0xe
  jmp alltraps
8010523a:	e9 59 fb ff ff       	jmp    80104d98 <alltraps>

8010523f <vector15>:
.globl vector15
vector15:
  pushl $0
8010523f:	6a 00                	push   $0x0
  pushl $15
80105241:	6a 0f                	push   $0xf
  jmp alltraps
80105243:	e9 50 fb ff ff       	jmp    80104d98 <alltraps>

80105248 <vector16>:
.globl vector16
vector16:
  pushl $0
80105248:	6a 00                	push   $0x0
  pushl $16
8010524a:	6a 10                	push   $0x10
  jmp alltraps
8010524c:	e9 47 fb ff ff       	jmp    80104d98 <alltraps>

80105251 <vector17>:
.globl vector17
vector17:
  pushl $17
80105251:	6a 11                	push   $0x11
  jmp alltraps
80105253:	e9 40 fb ff ff       	jmp    80104d98 <alltraps>

80105258 <vector18>:
.globl vector18
vector18:
  pushl $0
80105258:	6a 00                	push   $0x0
  pushl $18
8010525a:	6a 12                	push   $0x12
  jmp alltraps
8010525c:	e9 37 fb ff ff       	jmp    80104d98 <alltraps>

80105261 <vector19>:
.globl vector19
vector19:
  pushl $0
80105261:	6a 00                	push   $0x0
  pushl $19
80105263:	6a 13                	push   $0x13
  jmp alltraps
80105265:	e9 2e fb ff ff       	jmp    80104d98 <alltraps>

8010526a <vector20>:
.globl vector20
vector20:
  pushl $0
8010526a:	6a 00                	push   $0x0
  pushl $20
8010526c:	6a 14                	push   $0x14
  jmp alltraps
8010526e:	e9 25 fb ff ff       	jmp    80104d98 <alltraps>

80105273 <vector21>:
.globl vector21
vector21:
  pushl $0
80105273:	6a 00                	push   $0x0
  pushl $21
80105275:	6a 15                	push   $0x15
  jmp alltraps
80105277:	e9 1c fb ff ff       	jmp    80104d98 <alltraps>

8010527c <vector22>:
.globl vector22
vector22:
  pushl $0
8010527c:	6a 00                	push   $0x0
  pushl $22
8010527e:	6a 16                	push   $0x16
  jmp alltraps
80105280:	e9 13 fb ff ff       	jmp    80104d98 <alltraps>

80105285 <vector23>:
.globl vector23
vector23:
  pushl $0
80105285:	6a 00                	push   $0x0
  pushl $23
80105287:	6a 17                	push   $0x17
  jmp alltraps
80105289:	e9 0a fb ff ff       	jmp    80104d98 <alltraps>

8010528e <vector24>:
.globl vector24
vector24:
  pushl $0
8010528e:	6a 00                	push   $0x0
  pushl $24
80105290:	6a 18                	push   $0x18
  jmp alltraps
80105292:	e9 01 fb ff ff       	jmp    80104d98 <alltraps>

80105297 <vector25>:
.globl vector25
vector25:
  pushl $0
80105297:	6a 00                	push   $0x0
  pushl $25
80105299:	6a 19                	push   $0x19
  jmp alltraps
8010529b:	e9 f8 fa ff ff       	jmp    80104d98 <alltraps>

801052a0 <vector26>:
.globl vector26
vector26:
  pushl $0
801052a0:	6a 00                	push   $0x0
  pushl $26
801052a2:	6a 1a                	push   $0x1a
  jmp alltraps
801052a4:	e9 ef fa ff ff       	jmp    80104d98 <alltraps>

801052a9 <vector27>:
.globl vector27
vector27:
  pushl $0
801052a9:	6a 00                	push   $0x0
  pushl $27
801052ab:	6a 1b                	push   $0x1b
  jmp alltraps
801052ad:	e9 e6 fa ff ff       	jmp    80104d98 <alltraps>

801052b2 <vector28>:
.globl vector28
vector28:
  pushl $0
801052b2:	6a 00                	push   $0x0
  pushl $28
801052b4:	6a 1c                	push   $0x1c
  jmp alltraps
801052b6:	e9 dd fa ff ff       	jmp    80104d98 <alltraps>

801052bb <vector29>:
.globl vector29
vector29:
  pushl $0
801052bb:	6a 00                	push   $0x0
  pushl $29
801052bd:	6a 1d                	push   $0x1d
  jmp alltraps
801052bf:	e9 d4 fa ff ff       	jmp    80104d98 <alltraps>

801052c4 <vector30>:
.globl vector30
vector30:
  pushl $0
801052c4:	6a 00                	push   $0x0
  pushl $30
801052c6:	6a 1e                	push   $0x1e
  jmp alltraps
801052c8:	e9 cb fa ff ff       	jmp    80104d98 <alltraps>

801052cd <vector31>:
.globl vector31
vector31:
  pushl $0
801052cd:	6a 00                	push   $0x0
  pushl $31
801052cf:	6a 1f                	push   $0x1f
  jmp alltraps
801052d1:	e9 c2 fa ff ff       	jmp    80104d98 <alltraps>

801052d6 <vector32>:
.globl vector32
vector32:
  pushl $0
801052d6:	6a 00                	push   $0x0
  pushl $32
801052d8:	6a 20                	push   $0x20
  jmp alltraps
801052da:	e9 b9 fa ff ff       	jmp    80104d98 <alltraps>

801052df <vector33>:
.globl vector33
vector33:
  pushl $0
801052df:	6a 00                	push   $0x0
  pushl $33
801052e1:	6a 21                	push   $0x21
  jmp alltraps
801052e3:	e9 b0 fa ff ff       	jmp    80104d98 <alltraps>

801052e8 <vector34>:
.globl vector34
vector34:
  pushl $0
801052e8:	6a 00                	push   $0x0
  pushl $34
801052ea:	6a 22                	push   $0x22
  jmp alltraps
801052ec:	e9 a7 fa ff ff       	jmp    80104d98 <alltraps>

801052f1 <vector35>:
.globl vector35
vector35:
  pushl $0
801052f1:	6a 00                	push   $0x0
  pushl $35
801052f3:	6a 23                	push   $0x23
  jmp alltraps
801052f5:	e9 9e fa ff ff       	jmp    80104d98 <alltraps>

801052fa <vector36>:
.globl vector36
vector36:
  pushl $0
801052fa:	6a 00                	push   $0x0
  pushl $36
801052fc:	6a 24                	push   $0x24
  jmp alltraps
801052fe:	e9 95 fa ff ff       	jmp    80104d98 <alltraps>

80105303 <vector37>:
.globl vector37
vector37:
  pushl $0
80105303:	6a 00                	push   $0x0
  pushl $37
80105305:	6a 25                	push   $0x25
  jmp alltraps
80105307:	e9 8c fa ff ff       	jmp    80104d98 <alltraps>

8010530c <vector38>:
.globl vector38
vector38:
  pushl $0
8010530c:	6a 00                	push   $0x0
  pushl $38
8010530e:	6a 26                	push   $0x26
  jmp alltraps
80105310:	e9 83 fa ff ff       	jmp    80104d98 <alltraps>

80105315 <vector39>:
.globl vector39
vector39:
  pushl $0
80105315:	6a 00                	push   $0x0
  pushl $39
80105317:	6a 27                	push   $0x27
  jmp alltraps
80105319:	e9 7a fa ff ff       	jmp    80104d98 <alltraps>

8010531e <vector40>:
.globl vector40
vector40:
  pushl $0
8010531e:	6a 00                	push   $0x0
  pushl $40
80105320:	6a 28                	push   $0x28
  jmp alltraps
80105322:	e9 71 fa ff ff       	jmp    80104d98 <alltraps>

80105327 <vector41>:
.globl vector41
vector41:
  pushl $0
80105327:	6a 00                	push   $0x0
  pushl $41
80105329:	6a 29                	push   $0x29
  jmp alltraps
8010532b:	e9 68 fa ff ff       	jmp    80104d98 <alltraps>

80105330 <vector42>:
.globl vector42
vector42:
  pushl $0
80105330:	6a 00                	push   $0x0
  pushl $42
80105332:	6a 2a                	push   $0x2a
  jmp alltraps
80105334:	e9 5f fa ff ff       	jmp    80104d98 <alltraps>

80105339 <vector43>:
.globl vector43
vector43:
  pushl $0
80105339:	6a 00                	push   $0x0
  pushl $43
8010533b:	6a 2b                	push   $0x2b
  jmp alltraps
8010533d:	e9 56 fa ff ff       	jmp    80104d98 <alltraps>

80105342 <vector44>:
.globl vector44
vector44:
  pushl $0
80105342:	6a 00                	push   $0x0
  pushl $44
80105344:	6a 2c                	push   $0x2c
  jmp alltraps
80105346:	e9 4d fa ff ff       	jmp    80104d98 <alltraps>

8010534b <vector45>:
.globl vector45
vector45:
  pushl $0
8010534b:	6a 00                	push   $0x0
  pushl $45
8010534d:	6a 2d                	push   $0x2d
  jmp alltraps
8010534f:	e9 44 fa ff ff       	jmp    80104d98 <alltraps>

80105354 <vector46>:
.globl vector46
vector46:
  pushl $0
80105354:	6a 00                	push   $0x0
  pushl $46
80105356:	6a 2e                	push   $0x2e
  jmp alltraps
80105358:	e9 3b fa ff ff       	jmp    80104d98 <alltraps>

8010535d <vector47>:
.globl vector47
vector47:
  pushl $0
8010535d:	6a 00                	push   $0x0
  pushl $47
8010535f:	6a 2f                	push   $0x2f
  jmp alltraps
80105361:	e9 32 fa ff ff       	jmp    80104d98 <alltraps>

80105366 <vector48>:
.globl vector48
vector48:
  pushl $0
80105366:	6a 00                	push   $0x0
  pushl $48
80105368:	6a 30                	push   $0x30
  jmp alltraps
8010536a:	e9 29 fa ff ff       	jmp    80104d98 <alltraps>

8010536f <vector49>:
.globl vector49
vector49:
  pushl $0
8010536f:	6a 00                	push   $0x0
  pushl $49
80105371:	6a 31                	push   $0x31
  jmp alltraps
80105373:	e9 20 fa ff ff       	jmp    80104d98 <alltraps>

80105378 <vector50>:
.globl vector50
vector50:
  pushl $0
80105378:	6a 00                	push   $0x0
  pushl $50
8010537a:	6a 32                	push   $0x32
  jmp alltraps
8010537c:	e9 17 fa ff ff       	jmp    80104d98 <alltraps>

80105381 <vector51>:
.globl vector51
vector51:
  pushl $0
80105381:	6a 00                	push   $0x0
  pushl $51
80105383:	6a 33                	push   $0x33
  jmp alltraps
80105385:	e9 0e fa ff ff       	jmp    80104d98 <alltraps>

8010538a <vector52>:
.globl vector52
vector52:
  pushl $0
8010538a:	6a 00                	push   $0x0
  pushl $52
8010538c:	6a 34                	push   $0x34
  jmp alltraps
8010538e:	e9 05 fa ff ff       	jmp    80104d98 <alltraps>

80105393 <vector53>:
.globl vector53
vector53:
  pushl $0
80105393:	6a 00                	push   $0x0
  pushl $53
80105395:	6a 35                	push   $0x35
  jmp alltraps
80105397:	e9 fc f9 ff ff       	jmp    80104d98 <alltraps>

8010539c <vector54>:
.globl vector54
vector54:
  pushl $0
8010539c:	6a 00                	push   $0x0
  pushl $54
8010539e:	6a 36                	push   $0x36
  jmp alltraps
801053a0:	e9 f3 f9 ff ff       	jmp    80104d98 <alltraps>

801053a5 <vector55>:
.globl vector55
vector55:
  pushl $0
801053a5:	6a 00                	push   $0x0
  pushl $55
801053a7:	6a 37                	push   $0x37
  jmp alltraps
801053a9:	e9 ea f9 ff ff       	jmp    80104d98 <alltraps>

801053ae <vector56>:
.globl vector56
vector56:
  pushl $0
801053ae:	6a 00                	push   $0x0
  pushl $56
801053b0:	6a 38                	push   $0x38
  jmp alltraps
801053b2:	e9 e1 f9 ff ff       	jmp    80104d98 <alltraps>

801053b7 <vector57>:
.globl vector57
vector57:
  pushl $0
801053b7:	6a 00                	push   $0x0
  pushl $57
801053b9:	6a 39                	push   $0x39
  jmp alltraps
801053bb:	e9 d8 f9 ff ff       	jmp    80104d98 <alltraps>

801053c0 <vector58>:
.globl vector58
vector58:
  pushl $0
801053c0:	6a 00                	push   $0x0
  pushl $58
801053c2:	6a 3a                	push   $0x3a
  jmp alltraps
801053c4:	e9 cf f9 ff ff       	jmp    80104d98 <alltraps>

801053c9 <vector59>:
.globl vector59
vector59:
  pushl $0
801053c9:	6a 00                	push   $0x0
  pushl $59
801053cb:	6a 3b                	push   $0x3b
  jmp alltraps
801053cd:	e9 c6 f9 ff ff       	jmp    80104d98 <alltraps>

801053d2 <vector60>:
.globl vector60
vector60:
  pushl $0
801053d2:	6a 00                	push   $0x0
  pushl $60
801053d4:	6a 3c                	push   $0x3c
  jmp alltraps
801053d6:	e9 bd f9 ff ff       	jmp    80104d98 <alltraps>

801053db <vector61>:
.globl vector61
vector61:
  pushl $0
801053db:	6a 00                	push   $0x0
  pushl $61
801053dd:	6a 3d                	push   $0x3d
  jmp alltraps
801053df:	e9 b4 f9 ff ff       	jmp    80104d98 <alltraps>

801053e4 <vector62>:
.globl vector62
vector62:
  pushl $0
801053e4:	6a 00                	push   $0x0
  pushl $62
801053e6:	6a 3e                	push   $0x3e
  jmp alltraps
801053e8:	e9 ab f9 ff ff       	jmp    80104d98 <alltraps>

801053ed <vector63>:
.globl vector63
vector63:
  pushl $0
801053ed:	6a 00                	push   $0x0
  pushl $63
801053ef:	6a 3f                	push   $0x3f
  jmp alltraps
801053f1:	e9 a2 f9 ff ff       	jmp    80104d98 <alltraps>

801053f6 <vector64>:
.globl vector64
vector64:
  pushl $0
801053f6:	6a 00                	push   $0x0
  pushl $64
801053f8:	6a 40                	push   $0x40
  jmp alltraps
801053fa:	e9 99 f9 ff ff       	jmp    80104d98 <alltraps>

801053ff <vector65>:
.globl vector65
vector65:
  pushl $0
801053ff:	6a 00                	push   $0x0
  pushl $65
80105401:	6a 41                	push   $0x41
  jmp alltraps
80105403:	e9 90 f9 ff ff       	jmp    80104d98 <alltraps>

80105408 <vector66>:
.globl vector66
vector66:
  pushl $0
80105408:	6a 00                	push   $0x0
  pushl $66
8010540a:	6a 42                	push   $0x42
  jmp alltraps
8010540c:	e9 87 f9 ff ff       	jmp    80104d98 <alltraps>

80105411 <vector67>:
.globl vector67
vector67:
  pushl $0
80105411:	6a 00                	push   $0x0
  pushl $67
80105413:	6a 43                	push   $0x43
  jmp alltraps
80105415:	e9 7e f9 ff ff       	jmp    80104d98 <alltraps>

8010541a <vector68>:
.globl vector68
vector68:
  pushl $0
8010541a:	6a 00                	push   $0x0
  pushl $68
8010541c:	6a 44                	push   $0x44
  jmp alltraps
8010541e:	e9 75 f9 ff ff       	jmp    80104d98 <alltraps>

80105423 <vector69>:
.globl vector69
vector69:
  pushl $0
80105423:	6a 00                	push   $0x0
  pushl $69
80105425:	6a 45                	push   $0x45
  jmp alltraps
80105427:	e9 6c f9 ff ff       	jmp    80104d98 <alltraps>

8010542c <vector70>:
.globl vector70
vector70:
  pushl $0
8010542c:	6a 00                	push   $0x0
  pushl $70
8010542e:	6a 46                	push   $0x46
  jmp alltraps
80105430:	e9 63 f9 ff ff       	jmp    80104d98 <alltraps>

80105435 <vector71>:
.globl vector71
vector71:
  pushl $0
80105435:	6a 00                	push   $0x0
  pushl $71
80105437:	6a 47                	push   $0x47
  jmp alltraps
80105439:	e9 5a f9 ff ff       	jmp    80104d98 <alltraps>

8010543e <vector72>:
.globl vector72
vector72:
  pushl $0
8010543e:	6a 00                	push   $0x0
  pushl $72
80105440:	6a 48                	push   $0x48
  jmp alltraps
80105442:	e9 51 f9 ff ff       	jmp    80104d98 <alltraps>

80105447 <vector73>:
.globl vector73
vector73:
  pushl $0
80105447:	6a 00                	push   $0x0
  pushl $73
80105449:	6a 49                	push   $0x49
  jmp alltraps
8010544b:	e9 48 f9 ff ff       	jmp    80104d98 <alltraps>

80105450 <vector74>:
.globl vector74
vector74:
  pushl $0
80105450:	6a 00                	push   $0x0
  pushl $74
80105452:	6a 4a                	push   $0x4a
  jmp alltraps
80105454:	e9 3f f9 ff ff       	jmp    80104d98 <alltraps>

80105459 <vector75>:
.globl vector75
vector75:
  pushl $0
80105459:	6a 00                	push   $0x0
  pushl $75
8010545b:	6a 4b                	push   $0x4b
  jmp alltraps
8010545d:	e9 36 f9 ff ff       	jmp    80104d98 <alltraps>

80105462 <vector76>:
.globl vector76
vector76:
  pushl $0
80105462:	6a 00                	push   $0x0
  pushl $76
80105464:	6a 4c                	push   $0x4c
  jmp alltraps
80105466:	e9 2d f9 ff ff       	jmp    80104d98 <alltraps>

8010546b <vector77>:
.globl vector77
vector77:
  pushl $0
8010546b:	6a 00                	push   $0x0
  pushl $77
8010546d:	6a 4d                	push   $0x4d
  jmp alltraps
8010546f:	e9 24 f9 ff ff       	jmp    80104d98 <alltraps>

80105474 <vector78>:
.globl vector78
vector78:
  pushl $0
80105474:	6a 00                	push   $0x0
  pushl $78
80105476:	6a 4e                	push   $0x4e
  jmp alltraps
80105478:	e9 1b f9 ff ff       	jmp    80104d98 <alltraps>

8010547d <vector79>:
.globl vector79
vector79:
  pushl $0
8010547d:	6a 00                	push   $0x0
  pushl $79
8010547f:	6a 4f                	push   $0x4f
  jmp alltraps
80105481:	e9 12 f9 ff ff       	jmp    80104d98 <alltraps>

80105486 <vector80>:
.globl vector80
vector80:
  pushl $0
80105486:	6a 00                	push   $0x0
  pushl $80
80105488:	6a 50                	push   $0x50
  jmp alltraps
8010548a:	e9 09 f9 ff ff       	jmp    80104d98 <alltraps>

8010548f <vector81>:
.globl vector81
vector81:
  pushl $0
8010548f:	6a 00                	push   $0x0
  pushl $81
80105491:	6a 51                	push   $0x51
  jmp alltraps
80105493:	e9 00 f9 ff ff       	jmp    80104d98 <alltraps>

80105498 <vector82>:
.globl vector82
vector82:
  pushl $0
80105498:	6a 00                	push   $0x0
  pushl $82
8010549a:	6a 52                	push   $0x52
  jmp alltraps
8010549c:	e9 f7 f8 ff ff       	jmp    80104d98 <alltraps>

801054a1 <vector83>:
.globl vector83
vector83:
  pushl $0
801054a1:	6a 00                	push   $0x0
  pushl $83
801054a3:	6a 53                	push   $0x53
  jmp alltraps
801054a5:	e9 ee f8 ff ff       	jmp    80104d98 <alltraps>

801054aa <vector84>:
.globl vector84
vector84:
  pushl $0
801054aa:	6a 00                	push   $0x0
  pushl $84
801054ac:	6a 54                	push   $0x54
  jmp alltraps
801054ae:	e9 e5 f8 ff ff       	jmp    80104d98 <alltraps>

801054b3 <vector85>:
.globl vector85
vector85:
  pushl $0
801054b3:	6a 00                	push   $0x0
  pushl $85
801054b5:	6a 55                	push   $0x55
  jmp alltraps
801054b7:	e9 dc f8 ff ff       	jmp    80104d98 <alltraps>

801054bc <vector86>:
.globl vector86
vector86:
  pushl $0
801054bc:	6a 00                	push   $0x0
  pushl $86
801054be:	6a 56                	push   $0x56
  jmp alltraps
801054c0:	e9 d3 f8 ff ff       	jmp    80104d98 <alltraps>

801054c5 <vector87>:
.globl vector87
vector87:
  pushl $0
801054c5:	6a 00                	push   $0x0
  pushl $87
801054c7:	6a 57                	push   $0x57
  jmp alltraps
801054c9:	e9 ca f8 ff ff       	jmp    80104d98 <alltraps>

801054ce <vector88>:
.globl vector88
vector88:
  pushl $0
801054ce:	6a 00                	push   $0x0
  pushl $88
801054d0:	6a 58                	push   $0x58
  jmp alltraps
801054d2:	e9 c1 f8 ff ff       	jmp    80104d98 <alltraps>

801054d7 <vector89>:
.globl vector89
vector89:
  pushl $0
801054d7:	6a 00                	push   $0x0
  pushl $89
801054d9:	6a 59                	push   $0x59
  jmp alltraps
801054db:	e9 b8 f8 ff ff       	jmp    80104d98 <alltraps>

801054e0 <vector90>:
.globl vector90
vector90:
  pushl $0
801054e0:	6a 00                	push   $0x0
  pushl $90
801054e2:	6a 5a                	push   $0x5a
  jmp alltraps
801054e4:	e9 af f8 ff ff       	jmp    80104d98 <alltraps>

801054e9 <vector91>:
.globl vector91
vector91:
  pushl $0
801054e9:	6a 00                	push   $0x0
  pushl $91
801054eb:	6a 5b                	push   $0x5b
  jmp alltraps
801054ed:	e9 a6 f8 ff ff       	jmp    80104d98 <alltraps>

801054f2 <vector92>:
.globl vector92
vector92:
  pushl $0
801054f2:	6a 00                	push   $0x0
  pushl $92
801054f4:	6a 5c                	push   $0x5c
  jmp alltraps
801054f6:	e9 9d f8 ff ff       	jmp    80104d98 <alltraps>

801054fb <vector93>:
.globl vector93
vector93:
  pushl $0
801054fb:	6a 00                	push   $0x0
  pushl $93
801054fd:	6a 5d                	push   $0x5d
  jmp alltraps
801054ff:	e9 94 f8 ff ff       	jmp    80104d98 <alltraps>

80105504 <vector94>:
.globl vector94
vector94:
  pushl $0
80105504:	6a 00                	push   $0x0
  pushl $94
80105506:	6a 5e                	push   $0x5e
  jmp alltraps
80105508:	e9 8b f8 ff ff       	jmp    80104d98 <alltraps>

8010550d <vector95>:
.globl vector95
vector95:
  pushl $0
8010550d:	6a 00                	push   $0x0
  pushl $95
8010550f:	6a 5f                	push   $0x5f
  jmp alltraps
80105511:	e9 82 f8 ff ff       	jmp    80104d98 <alltraps>

80105516 <vector96>:
.globl vector96
vector96:
  pushl $0
80105516:	6a 00                	push   $0x0
  pushl $96
80105518:	6a 60                	push   $0x60
  jmp alltraps
8010551a:	e9 79 f8 ff ff       	jmp    80104d98 <alltraps>

8010551f <vector97>:
.globl vector97
vector97:
  pushl $0
8010551f:	6a 00                	push   $0x0
  pushl $97
80105521:	6a 61                	push   $0x61
  jmp alltraps
80105523:	e9 70 f8 ff ff       	jmp    80104d98 <alltraps>

80105528 <vector98>:
.globl vector98
vector98:
  pushl $0
80105528:	6a 00                	push   $0x0
  pushl $98
8010552a:	6a 62                	push   $0x62
  jmp alltraps
8010552c:	e9 67 f8 ff ff       	jmp    80104d98 <alltraps>

80105531 <vector99>:
.globl vector99
vector99:
  pushl $0
80105531:	6a 00                	push   $0x0
  pushl $99
80105533:	6a 63                	push   $0x63
  jmp alltraps
80105535:	e9 5e f8 ff ff       	jmp    80104d98 <alltraps>

8010553a <vector100>:
.globl vector100
vector100:
  pushl $0
8010553a:	6a 00                	push   $0x0
  pushl $100
8010553c:	6a 64                	push   $0x64
  jmp alltraps
8010553e:	e9 55 f8 ff ff       	jmp    80104d98 <alltraps>

80105543 <vector101>:
.globl vector101
vector101:
  pushl $0
80105543:	6a 00                	push   $0x0
  pushl $101
80105545:	6a 65                	push   $0x65
  jmp alltraps
80105547:	e9 4c f8 ff ff       	jmp    80104d98 <alltraps>

8010554c <vector102>:
.globl vector102
vector102:
  pushl $0
8010554c:	6a 00                	push   $0x0
  pushl $102
8010554e:	6a 66                	push   $0x66
  jmp alltraps
80105550:	e9 43 f8 ff ff       	jmp    80104d98 <alltraps>

80105555 <vector103>:
.globl vector103
vector103:
  pushl $0
80105555:	6a 00                	push   $0x0
  pushl $103
80105557:	6a 67                	push   $0x67
  jmp alltraps
80105559:	e9 3a f8 ff ff       	jmp    80104d98 <alltraps>

8010555e <vector104>:
.globl vector104
vector104:
  pushl $0
8010555e:	6a 00                	push   $0x0
  pushl $104
80105560:	6a 68                	push   $0x68
  jmp alltraps
80105562:	e9 31 f8 ff ff       	jmp    80104d98 <alltraps>

80105567 <vector105>:
.globl vector105
vector105:
  pushl $0
80105567:	6a 00                	push   $0x0
  pushl $105
80105569:	6a 69                	push   $0x69
  jmp alltraps
8010556b:	e9 28 f8 ff ff       	jmp    80104d98 <alltraps>

80105570 <vector106>:
.globl vector106
vector106:
  pushl $0
80105570:	6a 00                	push   $0x0
  pushl $106
80105572:	6a 6a                	push   $0x6a
  jmp alltraps
80105574:	e9 1f f8 ff ff       	jmp    80104d98 <alltraps>

80105579 <vector107>:
.globl vector107
vector107:
  pushl $0
80105579:	6a 00                	push   $0x0
  pushl $107
8010557b:	6a 6b                	push   $0x6b
  jmp alltraps
8010557d:	e9 16 f8 ff ff       	jmp    80104d98 <alltraps>

80105582 <vector108>:
.globl vector108
vector108:
  pushl $0
80105582:	6a 00                	push   $0x0
  pushl $108
80105584:	6a 6c                	push   $0x6c
  jmp alltraps
80105586:	e9 0d f8 ff ff       	jmp    80104d98 <alltraps>

8010558b <vector109>:
.globl vector109
vector109:
  pushl $0
8010558b:	6a 00                	push   $0x0
  pushl $109
8010558d:	6a 6d                	push   $0x6d
  jmp alltraps
8010558f:	e9 04 f8 ff ff       	jmp    80104d98 <alltraps>

80105594 <vector110>:
.globl vector110
vector110:
  pushl $0
80105594:	6a 00                	push   $0x0
  pushl $110
80105596:	6a 6e                	push   $0x6e
  jmp alltraps
80105598:	e9 fb f7 ff ff       	jmp    80104d98 <alltraps>

8010559d <vector111>:
.globl vector111
vector111:
  pushl $0
8010559d:	6a 00                	push   $0x0
  pushl $111
8010559f:	6a 6f                	push   $0x6f
  jmp alltraps
801055a1:	e9 f2 f7 ff ff       	jmp    80104d98 <alltraps>

801055a6 <vector112>:
.globl vector112
vector112:
  pushl $0
801055a6:	6a 00                	push   $0x0
  pushl $112
801055a8:	6a 70                	push   $0x70
  jmp alltraps
801055aa:	e9 e9 f7 ff ff       	jmp    80104d98 <alltraps>

801055af <vector113>:
.globl vector113
vector113:
  pushl $0
801055af:	6a 00                	push   $0x0
  pushl $113
801055b1:	6a 71                	push   $0x71
  jmp alltraps
801055b3:	e9 e0 f7 ff ff       	jmp    80104d98 <alltraps>

801055b8 <vector114>:
.globl vector114
vector114:
  pushl $0
801055b8:	6a 00                	push   $0x0
  pushl $114
801055ba:	6a 72                	push   $0x72
  jmp alltraps
801055bc:	e9 d7 f7 ff ff       	jmp    80104d98 <alltraps>

801055c1 <vector115>:
.globl vector115
vector115:
  pushl $0
801055c1:	6a 00                	push   $0x0
  pushl $115
801055c3:	6a 73                	push   $0x73
  jmp alltraps
801055c5:	e9 ce f7 ff ff       	jmp    80104d98 <alltraps>

801055ca <vector116>:
.globl vector116
vector116:
  pushl $0
801055ca:	6a 00                	push   $0x0
  pushl $116
801055cc:	6a 74                	push   $0x74
  jmp alltraps
801055ce:	e9 c5 f7 ff ff       	jmp    80104d98 <alltraps>

801055d3 <vector117>:
.globl vector117
vector117:
  pushl $0
801055d3:	6a 00                	push   $0x0
  pushl $117
801055d5:	6a 75                	push   $0x75
  jmp alltraps
801055d7:	e9 bc f7 ff ff       	jmp    80104d98 <alltraps>

801055dc <vector118>:
.globl vector118
vector118:
  pushl $0
801055dc:	6a 00                	push   $0x0
  pushl $118
801055de:	6a 76                	push   $0x76
  jmp alltraps
801055e0:	e9 b3 f7 ff ff       	jmp    80104d98 <alltraps>

801055e5 <vector119>:
.globl vector119
vector119:
  pushl $0
801055e5:	6a 00                	push   $0x0
  pushl $119
801055e7:	6a 77                	push   $0x77
  jmp alltraps
801055e9:	e9 aa f7 ff ff       	jmp    80104d98 <alltraps>

801055ee <vector120>:
.globl vector120
vector120:
  pushl $0
801055ee:	6a 00                	push   $0x0
  pushl $120
801055f0:	6a 78                	push   $0x78
  jmp alltraps
801055f2:	e9 a1 f7 ff ff       	jmp    80104d98 <alltraps>

801055f7 <vector121>:
.globl vector121
vector121:
  pushl $0
801055f7:	6a 00                	push   $0x0
  pushl $121
801055f9:	6a 79                	push   $0x79
  jmp alltraps
801055fb:	e9 98 f7 ff ff       	jmp    80104d98 <alltraps>

80105600 <vector122>:
.globl vector122
vector122:
  pushl $0
80105600:	6a 00                	push   $0x0
  pushl $122
80105602:	6a 7a                	push   $0x7a
  jmp alltraps
80105604:	e9 8f f7 ff ff       	jmp    80104d98 <alltraps>

80105609 <vector123>:
.globl vector123
vector123:
  pushl $0
80105609:	6a 00                	push   $0x0
  pushl $123
8010560b:	6a 7b                	push   $0x7b
  jmp alltraps
8010560d:	e9 86 f7 ff ff       	jmp    80104d98 <alltraps>

80105612 <vector124>:
.globl vector124
vector124:
  pushl $0
80105612:	6a 00                	push   $0x0
  pushl $124
80105614:	6a 7c                	push   $0x7c
  jmp alltraps
80105616:	e9 7d f7 ff ff       	jmp    80104d98 <alltraps>

8010561b <vector125>:
.globl vector125
vector125:
  pushl $0
8010561b:	6a 00                	push   $0x0
  pushl $125
8010561d:	6a 7d                	push   $0x7d
  jmp alltraps
8010561f:	e9 74 f7 ff ff       	jmp    80104d98 <alltraps>

80105624 <vector126>:
.globl vector126
vector126:
  pushl $0
80105624:	6a 00                	push   $0x0
  pushl $126
80105626:	6a 7e                	push   $0x7e
  jmp alltraps
80105628:	e9 6b f7 ff ff       	jmp    80104d98 <alltraps>

8010562d <vector127>:
.globl vector127
vector127:
  pushl $0
8010562d:	6a 00                	push   $0x0
  pushl $127
8010562f:	6a 7f                	push   $0x7f
  jmp alltraps
80105631:	e9 62 f7 ff ff       	jmp    80104d98 <alltraps>

80105636 <vector128>:
.globl vector128
vector128:
  pushl $0
80105636:	6a 00                	push   $0x0
  pushl $128
80105638:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010563d:	e9 56 f7 ff ff       	jmp    80104d98 <alltraps>

80105642 <vector129>:
.globl vector129
vector129:
  pushl $0
80105642:	6a 00                	push   $0x0
  pushl $129
80105644:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105649:	e9 4a f7 ff ff       	jmp    80104d98 <alltraps>

8010564e <vector130>:
.globl vector130
vector130:
  pushl $0
8010564e:	6a 00                	push   $0x0
  pushl $130
80105650:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105655:	e9 3e f7 ff ff       	jmp    80104d98 <alltraps>

8010565a <vector131>:
.globl vector131
vector131:
  pushl $0
8010565a:	6a 00                	push   $0x0
  pushl $131
8010565c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105661:	e9 32 f7 ff ff       	jmp    80104d98 <alltraps>

80105666 <vector132>:
.globl vector132
vector132:
  pushl $0
80105666:	6a 00                	push   $0x0
  pushl $132
80105668:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010566d:	e9 26 f7 ff ff       	jmp    80104d98 <alltraps>

80105672 <vector133>:
.globl vector133
vector133:
  pushl $0
80105672:	6a 00                	push   $0x0
  pushl $133
80105674:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105679:	e9 1a f7 ff ff       	jmp    80104d98 <alltraps>

8010567e <vector134>:
.globl vector134
vector134:
  pushl $0
8010567e:	6a 00                	push   $0x0
  pushl $134
80105680:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105685:	e9 0e f7 ff ff       	jmp    80104d98 <alltraps>

8010568a <vector135>:
.globl vector135
vector135:
  pushl $0
8010568a:	6a 00                	push   $0x0
  pushl $135
8010568c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80105691:	e9 02 f7 ff ff       	jmp    80104d98 <alltraps>

80105696 <vector136>:
.globl vector136
vector136:
  pushl $0
80105696:	6a 00                	push   $0x0
  pushl $136
80105698:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010569d:	e9 f6 f6 ff ff       	jmp    80104d98 <alltraps>

801056a2 <vector137>:
.globl vector137
vector137:
  pushl $0
801056a2:	6a 00                	push   $0x0
  pushl $137
801056a4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801056a9:	e9 ea f6 ff ff       	jmp    80104d98 <alltraps>

801056ae <vector138>:
.globl vector138
vector138:
  pushl $0
801056ae:	6a 00                	push   $0x0
  pushl $138
801056b0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801056b5:	e9 de f6 ff ff       	jmp    80104d98 <alltraps>

801056ba <vector139>:
.globl vector139
vector139:
  pushl $0
801056ba:	6a 00                	push   $0x0
  pushl $139
801056bc:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801056c1:	e9 d2 f6 ff ff       	jmp    80104d98 <alltraps>

801056c6 <vector140>:
.globl vector140
vector140:
  pushl $0
801056c6:	6a 00                	push   $0x0
  pushl $140
801056c8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801056cd:	e9 c6 f6 ff ff       	jmp    80104d98 <alltraps>

801056d2 <vector141>:
.globl vector141
vector141:
  pushl $0
801056d2:	6a 00                	push   $0x0
  pushl $141
801056d4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801056d9:	e9 ba f6 ff ff       	jmp    80104d98 <alltraps>

801056de <vector142>:
.globl vector142
vector142:
  pushl $0
801056de:	6a 00                	push   $0x0
  pushl $142
801056e0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801056e5:	e9 ae f6 ff ff       	jmp    80104d98 <alltraps>

801056ea <vector143>:
.globl vector143
vector143:
  pushl $0
801056ea:	6a 00                	push   $0x0
  pushl $143
801056ec:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801056f1:	e9 a2 f6 ff ff       	jmp    80104d98 <alltraps>

801056f6 <vector144>:
.globl vector144
vector144:
  pushl $0
801056f6:	6a 00                	push   $0x0
  pushl $144
801056f8:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801056fd:	e9 96 f6 ff ff       	jmp    80104d98 <alltraps>

80105702 <vector145>:
.globl vector145
vector145:
  pushl $0
80105702:	6a 00                	push   $0x0
  pushl $145
80105704:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105709:	e9 8a f6 ff ff       	jmp    80104d98 <alltraps>

8010570e <vector146>:
.globl vector146
vector146:
  pushl $0
8010570e:	6a 00                	push   $0x0
  pushl $146
80105710:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105715:	e9 7e f6 ff ff       	jmp    80104d98 <alltraps>

8010571a <vector147>:
.globl vector147
vector147:
  pushl $0
8010571a:	6a 00                	push   $0x0
  pushl $147
8010571c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105721:	e9 72 f6 ff ff       	jmp    80104d98 <alltraps>

80105726 <vector148>:
.globl vector148
vector148:
  pushl $0
80105726:	6a 00                	push   $0x0
  pushl $148
80105728:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010572d:	e9 66 f6 ff ff       	jmp    80104d98 <alltraps>

80105732 <vector149>:
.globl vector149
vector149:
  pushl $0
80105732:	6a 00                	push   $0x0
  pushl $149
80105734:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105739:	e9 5a f6 ff ff       	jmp    80104d98 <alltraps>

8010573e <vector150>:
.globl vector150
vector150:
  pushl $0
8010573e:	6a 00                	push   $0x0
  pushl $150
80105740:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105745:	e9 4e f6 ff ff       	jmp    80104d98 <alltraps>

8010574a <vector151>:
.globl vector151
vector151:
  pushl $0
8010574a:	6a 00                	push   $0x0
  pushl $151
8010574c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105751:	e9 42 f6 ff ff       	jmp    80104d98 <alltraps>

80105756 <vector152>:
.globl vector152
vector152:
  pushl $0
80105756:	6a 00                	push   $0x0
  pushl $152
80105758:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010575d:	e9 36 f6 ff ff       	jmp    80104d98 <alltraps>

80105762 <vector153>:
.globl vector153
vector153:
  pushl $0
80105762:	6a 00                	push   $0x0
  pushl $153
80105764:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105769:	e9 2a f6 ff ff       	jmp    80104d98 <alltraps>

8010576e <vector154>:
.globl vector154
vector154:
  pushl $0
8010576e:	6a 00                	push   $0x0
  pushl $154
80105770:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105775:	e9 1e f6 ff ff       	jmp    80104d98 <alltraps>

8010577a <vector155>:
.globl vector155
vector155:
  pushl $0
8010577a:	6a 00                	push   $0x0
  pushl $155
8010577c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105781:	e9 12 f6 ff ff       	jmp    80104d98 <alltraps>

80105786 <vector156>:
.globl vector156
vector156:
  pushl $0
80105786:	6a 00                	push   $0x0
  pushl $156
80105788:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010578d:	e9 06 f6 ff ff       	jmp    80104d98 <alltraps>

80105792 <vector157>:
.globl vector157
vector157:
  pushl $0
80105792:	6a 00                	push   $0x0
  pushl $157
80105794:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105799:	e9 fa f5 ff ff       	jmp    80104d98 <alltraps>

8010579e <vector158>:
.globl vector158
vector158:
  pushl $0
8010579e:	6a 00                	push   $0x0
  pushl $158
801057a0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801057a5:	e9 ee f5 ff ff       	jmp    80104d98 <alltraps>

801057aa <vector159>:
.globl vector159
vector159:
  pushl $0
801057aa:	6a 00                	push   $0x0
  pushl $159
801057ac:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801057b1:	e9 e2 f5 ff ff       	jmp    80104d98 <alltraps>

801057b6 <vector160>:
.globl vector160
vector160:
  pushl $0
801057b6:	6a 00                	push   $0x0
  pushl $160
801057b8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801057bd:	e9 d6 f5 ff ff       	jmp    80104d98 <alltraps>

801057c2 <vector161>:
.globl vector161
vector161:
  pushl $0
801057c2:	6a 00                	push   $0x0
  pushl $161
801057c4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801057c9:	e9 ca f5 ff ff       	jmp    80104d98 <alltraps>

801057ce <vector162>:
.globl vector162
vector162:
  pushl $0
801057ce:	6a 00                	push   $0x0
  pushl $162
801057d0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801057d5:	e9 be f5 ff ff       	jmp    80104d98 <alltraps>

801057da <vector163>:
.globl vector163
vector163:
  pushl $0
801057da:	6a 00                	push   $0x0
  pushl $163
801057dc:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801057e1:	e9 b2 f5 ff ff       	jmp    80104d98 <alltraps>

801057e6 <vector164>:
.globl vector164
vector164:
  pushl $0
801057e6:	6a 00                	push   $0x0
  pushl $164
801057e8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801057ed:	e9 a6 f5 ff ff       	jmp    80104d98 <alltraps>

801057f2 <vector165>:
.globl vector165
vector165:
  pushl $0
801057f2:	6a 00                	push   $0x0
  pushl $165
801057f4:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801057f9:	e9 9a f5 ff ff       	jmp    80104d98 <alltraps>

801057fe <vector166>:
.globl vector166
vector166:
  pushl $0
801057fe:	6a 00                	push   $0x0
  pushl $166
80105800:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105805:	e9 8e f5 ff ff       	jmp    80104d98 <alltraps>

8010580a <vector167>:
.globl vector167
vector167:
  pushl $0
8010580a:	6a 00                	push   $0x0
  pushl $167
8010580c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105811:	e9 82 f5 ff ff       	jmp    80104d98 <alltraps>

80105816 <vector168>:
.globl vector168
vector168:
  pushl $0
80105816:	6a 00                	push   $0x0
  pushl $168
80105818:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010581d:	e9 76 f5 ff ff       	jmp    80104d98 <alltraps>

80105822 <vector169>:
.globl vector169
vector169:
  pushl $0
80105822:	6a 00                	push   $0x0
  pushl $169
80105824:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105829:	e9 6a f5 ff ff       	jmp    80104d98 <alltraps>

8010582e <vector170>:
.globl vector170
vector170:
  pushl $0
8010582e:	6a 00                	push   $0x0
  pushl $170
80105830:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105835:	e9 5e f5 ff ff       	jmp    80104d98 <alltraps>

8010583a <vector171>:
.globl vector171
vector171:
  pushl $0
8010583a:	6a 00                	push   $0x0
  pushl $171
8010583c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105841:	e9 52 f5 ff ff       	jmp    80104d98 <alltraps>

80105846 <vector172>:
.globl vector172
vector172:
  pushl $0
80105846:	6a 00                	push   $0x0
  pushl $172
80105848:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010584d:	e9 46 f5 ff ff       	jmp    80104d98 <alltraps>

80105852 <vector173>:
.globl vector173
vector173:
  pushl $0
80105852:	6a 00                	push   $0x0
  pushl $173
80105854:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105859:	e9 3a f5 ff ff       	jmp    80104d98 <alltraps>

8010585e <vector174>:
.globl vector174
vector174:
  pushl $0
8010585e:	6a 00                	push   $0x0
  pushl $174
80105860:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105865:	e9 2e f5 ff ff       	jmp    80104d98 <alltraps>

8010586a <vector175>:
.globl vector175
vector175:
  pushl $0
8010586a:	6a 00                	push   $0x0
  pushl $175
8010586c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105871:	e9 22 f5 ff ff       	jmp    80104d98 <alltraps>

80105876 <vector176>:
.globl vector176
vector176:
  pushl $0
80105876:	6a 00                	push   $0x0
  pushl $176
80105878:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010587d:	e9 16 f5 ff ff       	jmp    80104d98 <alltraps>

80105882 <vector177>:
.globl vector177
vector177:
  pushl $0
80105882:	6a 00                	push   $0x0
  pushl $177
80105884:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105889:	e9 0a f5 ff ff       	jmp    80104d98 <alltraps>

8010588e <vector178>:
.globl vector178
vector178:
  pushl $0
8010588e:	6a 00                	push   $0x0
  pushl $178
80105890:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105895:	e9 fe f4 ff ff       	jmp    80104d98 <alltraps>

8010589a <vector179>:
.globl vector179
vector179:
  pushl $0
8010589a:	6a 00                	push   $0x0
  pushl $179
8010589c:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058a1:	e9 f2 f4 ff ff       	jmp    80104d98 <alltraps>

801058a6 <vector180>:
.globl vector180
vector180:
  pushl $0
801058a6:	6a 00                	push   $0x0
  pushl $180
801058a8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801058ad:	e9 e6 f4 ff ff       	jmp    80104d98 <alltraps>

801058b2 <vector181>:
.globl vector181
vector181:
  pushl $0
801058b2:	6a 00                	push   $0x0
  pushl $181
801058b4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801058b9:	e9 da f4 ff ff       	jmp    80104d98 <alltraps>

801058be <vector182>:
.globl vector182
vector182:
  pushl $0
801058be:	6a 00                	push   $0x0
  pushl $182
801058c0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801058c5:	e9 ce f4 ff ff       	jmp    80104d98 <alltraps>

801058ca <vector183>:
.globl vector183
vector183:
  pushl $0
801058ca:	6a 00                	push   $0x0
  pushl $183
801058cc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801058d1:	e9 c2 f4 ff ff       	jmp    80104d98 <alltraps>

801058d6 <vector184>:
.globl vector184
vector184:
  pushl $0
801058d6:	6a 00                	push   $0x0
  pushl $184
801058d8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801058dd:	e9 b6 f4 ff ff       	jmp    80104d98 <alltraps>

801058e2 <vector185>:
.globl vector185
vector185:
  pushl $0
801058e2:	6a 00                	push   $0x0
  pushl $185
801058e4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801058e9:	e9 aa f4 ff ff       	jmp    80104d98 <alltraps>

801058ee <vector186>:
.globl vector186
vector186:
  pushl $0
801058ee:	6a 00                	push   $0x0
  pushl $186
801058f0:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801058f5:	e9 9e f4 ff ff       	jmp    80104d98 <alltraps>

801058fa <vector187>:
.globl vector187
vector187:
  pushl $0
801058fa:	6a 00                	push   $0x0
  pushl $187
801058fc:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105901:	e9 92 f4 ff ff       	jmp    80104d98 <alltraps>

80105906 <vector188>:
.globl vector188
vector188:
  pushl $0
80105906:	6a 00                	push   $0x0
  pushl $188
80105908:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010590d:	e9 86 f4 ff ff       	jmp    80104d98 <alltraps>

80105912 <vector189>:
.globl vector189
vector189:
  pushl $0
80105912:	6a 00                	push   $0x0
  pushl $189
80105914:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105919:	e9 7a f4 ff ff       	jmp    80104d98 <alltraps>

8010591e <vector190>:
.globl vector190
vector190:
  pushl $0
8010591e:	6a 00                	push   $0x0
  pushl $190
80105920:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105925:	e9 6e f4 ff ff       	jmp    80104d98 <alltraps>

8010592a <vector191>:
.globl vector191
vector191:
  pushl $0
8010592a:	6a 00                	push   $0x0
  pushl $191
8010592c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105931:	e9 62 f4 ff ff       	jmp    80104d98 <alltraps>

80105936 <vector192>:
.globl vector192
vector192:
  pushl $0
80105936:	6a 00                	push   $0x0
  pushl $192
80105938:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010593d:	e9 56 f4 ff ff       	jmp    80104d98 <alltraps>

80105942 <vector193>:
.globl vector193
vector193:
  pushl $0
80105942:	6a 00                	push   $0x0
  pushl $193
80105944:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105949:	e9 4a f4 ff ff       	jmp    80104d98 <alltraps>

8010594e <vector194>:
.globl vector194
vector194:
  pushl $0
8010594e:	6a 00                	push   $0x0
  pushl $194
80105950:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105955:	e9 3e f4 ff ff       	jmp    80104d98 <alltraps>

8010595a <vector195>:
.globl vector195
vector195:
  pushl $0
8010595a:	6a 00                	push   $0x0
  pushl $195
8010595c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105961:	e9 32 f4 ff ff       	jmp    80104d98 <alltraps>

80105966 <vector196>:
.globl vector196
vector196:
  pushl $0
80105966:	6a 00                	push   $0x0
  pushl $196
80105968:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010596d:	e9 26 f4 ff ff       	jmp    80104d98 <alltraps>

80105972 <vector197>:
.globl vector197
vector197:
  pushl $0
80105972:	6a 00                	push   $0x0
  pushl $197
80105974:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105979:	e9 1a f4 ff ff       	jmp    80104d98 <alltraps>

8010597e <vector198>:
.globl vector198
vector198:
  pushl $0
8010597e:	6a 00                	push   $0x0
  pushl $198
80105980:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105985:	e9 0e f4 ff ff       	jmp    80104d98 <alltraps>

8010598a <vector199>:
.globl vector199
vector199:
  pushl $0
8010598a:	6a 00                	push   $0x0
  pushl $199
8010598c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105991:	e9 02 f4 ff ff       	jmp    80104d98 <alltraps>

80105996 <vector200>:
.globl vector200
vector200:
  pushl $0
80105996:	6a 00                	push   $0x0
  pushl $200
80105998:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010599d:	e9 f6 f3 ff ff       	jmp    80104d98 <alltraps>

801059a2 <vector201>:
.globl vector201
vector201:
  pushl $0
801059a2:	6a 00                	push   $0x0
  pushl $201
801059a4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801059a9:	e9 ea f3 ff ff       	jmp    80104d98 <alltraps>

801059ae <vector202>:
.globl vector202
vector202:
  pushl $0
801059ae:	6a 00                	push   $0x0
  pushl $202
801059b0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801059b5:	e9 de f3 ff ff       	jmp    80104d98 <alltraps>

801059ba <vector203>:
.globl vector203
vector203:
  pushl $0
801059ba:	6a 00                	push   $0x0
  pushl $203
801059bc:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801059c1:	e9 d2 f3 ff ff       	jmp    80104d98 <alltraps>

801059c6 <vector204>:
.globl vector204
vector204:
  pushl $0
801059c6:	6a 00                	push   $0x0
  pushl $204
801059c8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801059cd:	e9 c6 f3 ff ff       	jmp    80104d98 <alltraps>

801059d2 <vector205>:
.globl vector205
vector205:
  pushl $0
801059d2:	6a 00                	push   $0x0
  pushl $205
801059d4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801059d9:	e9 ba f3 ff ff       	jmp    80104d98 <alltraps>

801059de <vector206>:
.globl vector206
vector206:
  pushl $0
801059de:	6a 00                	push   $0x0
  pushl $206
801059e0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801059e5:	e9 ae f3 ff ff       	jmp    80104d98 <alltraps>

801059ea <vector207>:
.globl vector207
vector207:
  pushl $0
801059ea:	6a 00                	push   $0x0
  pushl $207
801059ec:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801059f1:	e9 a2 f3 ff ff       	jmp    80104d98 <alltraps>

801059f6 <vector208>:
.globl vector208
vector208:
  pushl $0
801059f6:	6a 00                	push   $0x0
  pushl $208
801059f8:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801059fd:	e9 96 f3 ff ff       	jmp    80104d98 <alltraps>

80105a02 <vector209>:
.globl vector209
vector209:
  pushl $0
80105a02:	6a 00                	push   $0x0
  pushl $209
80105a04:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a09:	e9 8a f3 ff ff       	jmp    80104d98 <alltraps>

80105a0e <vector210>:
.globl vector210
vector210:
  pushl $0
80105a0e:	6a 00                	push   $0x0
  pushl $210
80105a10:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a15:	e9 7e f3 ff ff       	jmp    80104d98 <alltraps>

80105a1a <vector211>:
.globl vector211
vector211:
  pushl $0
80105a1a:	6a 00                	push   $0x0
  pushl $211
80105a1c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a21:	e9 72 f3 ff ff       	jmp    80104d98 <alltraps>

80105a26 <vector212>:
.globl vector212
vector212:
  pushl $0
80105a26:	6a 00                	push   $0x0
  pushl $212
80105a28:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a2d:	e9 66 f3 ff ff       	jmp    80104d98 <alltraps>

80105a32 <vector213>:
.globl vector213
vector213:
  pushl $0
80105a32:	6a 00                	push   $0x0
  pushl $213
80105a34:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a39:	e9 5a f3 ff ff       	jmp    80104d98 <alltraps>

80105a3e <vector214>:
.globl vector214
vector214:
  pushl $0
80105a3e:	6a 00                	push   $0x0
  pushl $214
80105a40:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105a45:	e9 4e f3 ff ff       	jmp    80104d98 <alltraps>

80105a4a <vector215>:
.globl vector215
vector215:
  pushl $0
80105a4a:	6a 00                	push   $0x0
  pushl $215
80105a4c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105a51:	e9 42 f3 ff ff       	jmp    80104d98 <alltraps>

80105a56 <vector216>:
.globl vector216
vector216:
  pushl $0
80105a56:	6a 00                	push   $0x0
  pushl $216
80105a58:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105a5d:	e9 36 f3 ff ff       	jmp    80104d98 <alltraps>

80105a62 <vector217>:
.globl vector217
vector217:
  pushl $0
80105a62:	6a 00                	push   $0x0
  pushl $217
80105a64:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105a69:	e9 2a f3 ff ff       	jmp    80104d98 <alltraps>

80105a6e <vector218>:
.globl vector218
vector218:
  pushl $0
80105a6e:	6a 00                	push   $0x0
  pushl $218
80105a70:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105a75:	e9 1e f3 ff ff       	jmp    80104d98 <alltraps>

80105a7a <vector219>:
.globl vector219
vector219:
  pushl $0
80105a7a:	6a 00                	push   $0x0
  pushl $219
80105a7c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105a81:	e9 12 f3 ff ff       	jmp    80104d98 <alltraps>

80105a86 <vector220>:
.globl vector220
vector220:
  pushl $0
80105a86:	6a 00                	push   $0x0
  pushl $220
80105a88:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105a8d:	e9 06 f3 ff ff       	jmp    80104d98 <alltraps>

80105a92 <vector221>:
.globl vector221
vector221:
  pushl $0
80105a92:	6a 00                	push   $0x0
  pushl $221
80105a94:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105a99:	e9 fa f2 ff ff       	jmp    80104d98 <alltraps>

80105a9e <vector222>:
.globl vector222
vector222:
  pushl $0
80105a9e:	6a 00                	push   $0x0
  pushl $222
80105aa0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105aa5:	e9 ee f2 ff ff       	jmp    80104d98 <alltraps>

80105aaa <vector223>:
.globl vector223
vector223:
  pushl $0
80105aaa:	6a 00                	push   $0x0
  pushl $223
80105aac:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105ab1:	e9 e2 f2 ff ff       	jmp    80104d98 <alltraps>

80105ab6 <vector224>:
.globl vector224
vector224:
  pushl $0
80105ab6:	6a 00                	push   $0x0
  pushl $224
80105ab8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105abd:	e9 d6 f2 ff ff       	jmp    80104d98 <alltraps>

80105ac2 <vector225>:
.globl vector225
vector225:
  pushl $0
80105ac2:	6a 00                	push   $0x0
  pushl $225
80105ac4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105ac9:	e9 ca f2 ff ff       	jmp    80104d98 <alltraps>

80105ace <vector226>:
.globl vector226
vector226:
  pushl $0
80105ace:	6a 00                	push   $0x0
  pushl $226
80105ad0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105ad5:	e9 be f2 ff ff       	jmp    80104d98 <alltraps>

80105ada <vector227>:
.globl vector227
vector227:
  pushl $0
80105ada:	6a 00                	push   $0x0
  pushl $227
80105adc:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105ae1:	e9 b2 f2 ff ff       	jmp    80104d98 <alltraps>

80105ae6 <vector228>:
.globl vector228
vector228:
  pushl $0
80105ae6:	6a 00                	push   $0x0
  pushl $228
80105ae8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105aed:	e9 a6 f2 ff ff       	jmp    80104d98 <alltraps>

80105af2 <vector229>:
.globl vector229
vector229:
  pushl $0
80105af2:	6a 00                	push   $0x0
  pushl $229
80105af4:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105af9:	e9 9a f2 ff ff       	jmp    80104d98 <alltraps>

80105afe <vector230>:
.globl vector230
vector230:
  pushl $0
80105afe:	6a 00                	push   $0x0
  pushl $230
80105b00:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b05:	e9 8e f2 ff ff       	jmp    80104d98 <alltraps>

80105b0a <vector231>:
.globl vector231
vector231:
  pushl $0
80105b0a:	6a 00                	push   $0x0
  pushl $231
80105b0c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b11:	e9 82 f2 ff ff       	jmp    80104d98 <alltraps>

80105b16 <vector232>:
.globl vector232
vector232:
  pushl $0
80105b16:	6a 00                	push   $0x0
  pushl $232
80105b18:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b1d:	e9 76 f2 ff ff       	jmp    80104d98 <alltraps>

80105b22 <vector233>:
.globl vector233
vector233:
  pushl $0
80105b22:	6a 00                	push   $0x0
  pushl $233
80105b24:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b29:	e9 6a f2 ff ff       	jmp    80104d98 <alltraps>

80105b2e <vector234>:
.globl vector234
vector234:
  pushl $0
80105b2e:	6a 00                	push   $0x0
  pushl $234
80105b30:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b35:	e9 5e f2 ff ff       	jmp    80104d98 <alltraps>

80105b3a <vector235>:
.globl vector235
vector235:
  pushl $0
80105b3a:	6a 00                	push   $0x0
  pushl $235
80105b3c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b41:	e9 52 f2 ff ff       	jmp    80104d98 <alltraps>

80105b46 <vector236>:
.globl vector236
vector236:
  pushl $0
80105b46:	6a 00                	push   $0x0
  pushl $236
80105b48:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105b4d:	e9 46 f2 ff ff       	jmp    80104d98 <alltraps>

80105b52 <vector237>:
.globl vector237
vector237:
  pushl $0
80105b52:	6a 00                	push   $0x0
  pushl $237
80105b54:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105b59:	e9 3a f2 ff ff       	jmp    80104d98 <alltraps>

80105b5e <vector238>:
.globl vector238
vector238:
  pushl $0
80105b5e:	6a 00                	push   $0x0
  pushl $238
80105b60:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105b65:	e9 2e f2 ff ff       	jmp    80104d98 <alltraps>

80105b6a <vector239>:
.globl vector239
vector239:
  pushl $0
80105b6a:	6a 00                	push   $0x0
  pushl $239
80105b6c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105b71:	e9 22 f2 ff ff       	jmp    80104d98 <alltraps>

80105b76 <vector240>:
.globl vector240
vector240:
  pushl $0
80105b76:	6a 00                	push   $0x0
  pushl $240
80105b78:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105b7d:	e9 16 f2 ff ff       	jmp    80104d98 <alltraps>

80105b82 <vector241>:
.globl vector241
vector241:
  pushl $0
80105b82:	6a 00                	push   $0x0
  pushl $241
80105b84:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105b89:	e9 0a f2 ff ff       	jmp    80104d98 <alltraps>

80105b8e <vector242>:
.globl vector242
vector242:
  pushl $0
80105b8e:	6a 00                	push   $0x0
  pushl $242
80105b90:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105b95:	e9 fe f1 ff ff       	jmp    80104d98 <alltraps>

80105b9a <vector243>:
.globl vector243
vector243:
  pushl $0
80105b9a:	6a 00                	push   $0x0
  pushl $243
80105b9c:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105ba1:	e9 f2 f1 ff ff       	jmp    80104d98 <alltraps>

80105ba6 <vector244>:
.globl vector244
vector244:
  pushl $0
80105ba6:	6a 00                	push   $0x0
  pushl $244
80105ba8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105bad:	e9 e6 f1 ff ff       	jmp    80104d98 <alltraps>

80105bb2 <vector245>:
.globl vector245
vector245:
  pushl $0
80105bb2:	6a 00                	push   $0x0
  pushl $245
80105bb4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105bb9:	e9 da f1 ff ff       	jmp    80104d98 <alltraps>

80105bbe <vector246>:
.globl vector246
vector246:
  pushl $0
80105bbe:	6a 00                	push   $0x0
  pushl $246
80105bc0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105bc5:	e9 ce f1 ff ff       	jmp    80104d98 <alltraps>

80105bca <vector247>:
.globl vector247
vector247:
  pushl $0
80105bca:	6a 00                	push   $0x0
  pushl $247
80105bcc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105bd1:	e9 c2 f1 ff ff       	jmp    80104d98 <alltraps>

80105bd6 <vector248>:
.globl vector248
vector248:
  pushl $0
80105bd6:	6a 00                	push   $0x0
  pushl $248
80105bd8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105bdd:	e9 b6 f1 ff ff       	jmp    80104d98 <alltraps>

80105be2 <vector249>:
.globl vector249
vector249:
  pushl $0
80105be2:	6a 00                	push   $0x0
  pushl $249
80105be4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105be9:	e9 aa f1 ff ff       	jmp    80104d98 <alltraps>

80105bee <vector250>:
.globl vector250
vector250:
  pushl $0
80105bee:	6a 00                	push   $0x0
  pushl $250
80105bf0:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105bf5:	e9 9e f1 ff ff       	jmp    80104d98 <alltraps>

80105bfa <vector251>:
.globl vector251
vector251:
  pushl $0
80105bfa:	6a 00                	push   $0x0
  pushl $251
80105bfc:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c01:	e9 92 f1 ff ff       	jmp    80104d98 <alltraps>

80105c06 <vector252>:
.globl vector252
vector252:
  pushl $0
80105c06:	6a 00                	push   $0x0
  pushl $252
80105c08:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c0d:	e9 86 f1 ff ff       	jmp    80104d98 <alltraps>

80105c12 <vector253>:
.globl vector253
vector253:
  pushl $0
80105c12:	6a 00                	push   $0x0
  pushl $253
80105c14:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c19:	e9 7a f1 ff ff       	jmp    80104d98 <alltraps>

80105c1e <vector254>:
.globl vector254
vector254:
  pushl $0
80105c1e:	6a 00                	push   $0x0
  pushl $254
80105c20:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c25:	e9 6e f1 ff ff       	jmp    80104d98 <alltraps>

80105c2a <vector255>:
.globl vector255
vector255:
  pushl $0
80105c2a:	6a 00                	push   $0x0
  pushl $255
80105c2c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c31:	e9 62 f1 ff ff       	jmp    80104d98 <alltraps>
	...

80105c38 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c38:	55                   	push   %ebp
80105c39:	89 e5                	mov    %esp,%ebp
80105c3b:	57                   	push   %edi
80105c3c:	56                   	push   %esi
80105c3d:	53                   	push   %ebx
80105c3e:	83 ec 1c             	sub    $0x1c,%esp
80105c41:	89 d3                	mov    %edx,%ebx
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105c43:	c1 ea 16             	shr    $0x16,%edx
80105c46:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105c49:	8b 37                	mov    (%edi),%esi
80105c4b:	f7 c6 01 00 00 00    	test   $0x1,%esi
80105c51:	74 21                	je     80105c74 <walkpgdir+0x3c>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105c53:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
80105c59:	81 c6 00 00 00 80    	add    $0x80000000,%esi
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105c5f:	c1 eb 0a             	shr    $0xa,%ebx
80105c62:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
80105c68:	8d 04 1e             	lea    (%esi,%ebx,1),%eax
}
80105c6b:	83 c4 1c             	add    $0x1c,%esp
80105c6e:	5b                   	pop    %ebx
80105c6f:	5e                   	pop    %esi
80105c70:	5f                   	pop    %edi
80105c71:	5d                   	pop    %ebp
80105c72:	c3                   	ret    
80105c73:	90                   	nop

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105c74:	85 c9                	test   %ecx,%ecx
80105c76:	74 30                	je     80105ca8 <walkpgdir+0x70>
80105c78:	e8 5f c5 ff ff       	call   801021dc <kalloc>
80105c7d:	89 c6                	mov    %eax,%esi
80105c7f:	85 c0                	test   %eax,%eax
80105c81:	74 25                	je     80105ca8 <walkpgdir+0x70>
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80105c83:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105c8a:	00 
80105c8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105c92:	00 
80105c93:	89 04 24             	mov    %eax,(%esp)
80105c96:	e8 11 e1 ff ff       	call   80103dac <memset>
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105c9b:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80105ca1:	83 c8 07             	or     $0x7,%eax
80105ca4:	89 07                	mov    %eax,(%edi)
80105ca6:	eb b7                	jmp    80105c5f <walkpgdir+0x27>
  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
80105ca8:	31 c0                	xor    %eax,%eax
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}
80105caa:	83 c4 1c             	add    $0x1c,%esp
80105cad:	5b                   	pop    %ebx
80105cae:	5e                   	pop    %esi
80105caf:	5f                   	pop    %edi
80105cb0:	5d                   	pop    %ebp
80105cb1:	c3                   	ret    
80105cb2:	66 90                	xchg   %ax,%ax

80105cb4 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105cb4:	55                   	push   %ebp
80105cb5:	89 e5                	mov    %esp,%ebp
80105cb7:	57                   	push   %edi
80105cb8:	56                   	push   %esi
80105cb9:	53                   	push   %ebx
80105cba:	83 ec 2c             	sub    $0x2c,%esp
80105cbd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105cc0:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105cc3:	89 d3                	mov    %edx,%ebx
80105cc5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105ccb:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105ccf:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
80105cd5:	83 4d 0c 01          	orl    $0x1,0xc(%ebp)
80105cd9:	eb 1d                	jmp    80105cf8 <mappages+0x44>
80105cdb:	90                   	nop
  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
80105cdc:	f6 00 01             	testb  $0x1,(%eax)
80105cdf:	75 41                	jne    80105d22 <mappages+0x6e>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105ce1:	8b 55 0c             	mov    0xc(%ebp),%edx
80105ce4:	09 f2                	or     %esi,%edx
80105ce6:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105ce8:	39 fb                	cmp    %edi,%ebx
80105cea:	74 2c                	je     80105d18 <mappages+0x64>
      break;
    a += PGSIZE;
80105cec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105cf2:	81 c6 00 10 00 00    	add    $0x1000,%esi
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105cf8:	b9 01 00 00 00       	mov    $0x1,%ecx
80105cfd:	89 da                	mov    %ebx,%edx
80105cff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105d02:	e8 31 ff ff ff       	call   80105c38 <walkpgdir>
80105d07:	85 c0                	test   %eax,%eax
80105d09:	75 d1                	jne    80105cdc <mappages+0x28>
      return -1;
80105d0b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
}
80105d10:	83 c4 2c             	add    $0x2c,%esp
80105d13:	5b                   	pop    %ebx
80105d14:	5e                   	pop    %esi
80105d15:	5f                   	pop    %edi
80105d16:	5d                   	pop    %ebp
80105d17:	c3                   	ret    
    if(a == last)
      break;
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80105d18:	31 c0                	xor    %eax,%eax
}
80105d1a:	83 c4 2c             	add    $0x2c,%esp
80105d1d:	5b                   	pop    %ebx
80105d1e:	5e                   	pop    %esi
80105d1f:	5f                   	pop    %edi
80105d20:	5d                   	pop    %ebp
80105d21:	c3                   	ret    
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
      panic("remap");
80105d22:	c7 04 24 88 6d 10 80 	movl   $0x80106d88,(%esp)
80105d29:	e8 ee a5 ff ff       	call   8010031c <panic>
80105d2e:	66 90                	xchg   %ax,%ax

80105d30 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80105d30:	55                   	push   %ebp
80105d31:	89 e5                	mov    %esp,%ebp
80105d33:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80105d36:	e8 41 d5 ff ff       	call   8010327c <cpuid>
80105d3b:	8d 14 80             	lea    (%eax,%eax,4),%edx
80105d3e:	8d 04 50             	lea    (%eax,%edx,2),%eax
80105d41:	c1 e0 04             	shl    $0x4,%eax
80105d44:	05 80 17 11 80       	add    $0x80111780,%eax
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d49:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80105d4f:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80105d55:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80105d59:	c6 40 7d 9a          	movb   $0x9a,0x7d(%eax)
80105d5d:	c6 40 7e cf          	movb   $0xcf,0x7e(%eax)
80105d61:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105d65:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80105d6c:	ff ff 
80105d6e:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80105d75:	00 00 
80105d77:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80105d7e:	c6 80 85 00 00 00 92 	movb   $0x92,0x85(%eax)
80105d85:	c6 80 86 00 00 00 cf 	movb   $0xcf,0x86(%eax)
80105d8c:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105d93:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
80105d9a:	ff ff 
80105d9c:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80105da3:	00 00 
80105da5:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80105dac:	c6 80 8d 00 00 00 fa 	movb   $0xfa,0x8d(%eax)
80105db3:	c6 80 8e 00 00 00 cf 	movb   $0xcf,0x8e(%eax)
80105dba:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105dc1:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80105dc8:	ff ff 
80105dca:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80105dd1:	00 00 
80105dd3:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80105dda:	c6 80 95 00 00 00 f2 	movb   $0xf2,0x95(%eax)
80105de1:	c6 80 96 00 00 00 cf 	movb   $0xcf,0x96(%eax)
80105de8:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105def:	83 c0 70             	add    $0x70,%eax
static inline void
lgdt(struct segdesc *p, int size)
{
  volatile ushort pd[3];

  pd[0] = size-1;
80105df2:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105df8:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105dfc:	c1 e8 10             	shr    $0x10,%eax
80105dff:	66 89 45 f6          	mov    %ax,-0xa(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80105e03:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105e06:	0f 01 10             	lgdtl  (%eax)
}
80105e09:	c9                   	leave  
80105e0a:	c3                   	ret    
80105e0b:	90                   	nop

80105e0c <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105e0c:	55                   	push   %ebp
80105e0d:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105e0f:	a1 a4 44 11 80       	mov    0x801144a4,%eax
80105e14:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105e19:	0f 22 d8             	mov    %eax,%cr3
}
80105e1c:	5d                   	pop    %ebp
80105e1d:	c3                   	ret    
80105e1e:	66 90                	xchg   %ax,%ax

80105e20 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105e20:	55                   	push   %ebp
80105e21:	89 e5                	mov    %esp,%ebp
80105e23:	57                   	push   %edi
80105e24:	56                   	push   %esi
80105e25:	53                   	push   %ebx
80105e26:	83 ec 2c             	sub    $0x2c,%esp
80105e29:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105e2c:	85 f6                	test   %esi,%esi
80105e2e:	0f 84 c4 00 00 00    	je     80105ef8 <switchuvm+0xd8>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105e34:	8b 56 08             	mov    0x8(%esi),%edx
80105e37:	85 d2                	test   %edx,%edx
80105e39:	0f 84 d1 00 00 00    	je     80105f10 <switchuvm+0xf0>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105e3f:	8b 46 04             	mov    0x4(%esi),%eax
80105e42:	85 c0                	test   %eax,%eax
80105e44:	0f 84 ba 00 00 00    	je     80105f04 <switchuvm+0xe4>
    panic("switchuvm: no pgdir");

  pushcli();
80105e4a:	e8 dd dd ff ff       	call   80103c2c <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105e4f:	e8 b4 d3 ff ff       	call   80103208 <mycpu>
80105e54:	89 c3                	mov    %eax,%ebx
80105e56:	e8 ad d3 ff ff       	call   80103208 <mycpu>
80105e5b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105e5e:	e8 a5 d3 ff ff       	call   80103208 <mycpu>
80105e63:	89 c7                	mov    %eax,%edi
80105e65:	e8 9e d3 ff ff       	call   80103208 <mycpu>
80105e6a:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105e71:	67 00 
80105e73:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105e76:	83 c2 08             	add    $0x8,%edx
80105e79:	66 89 93 9a 00 00 00 	mov    %dx,0x9a(%ebx)
80105e80:	8d 57 08             	lea    0x8(%edi),%edx
80105e83:	c1 ea 10             	shr    $0x10,%edx
80105e86:	88 93 9c 00 00 00    	mov    %dl,0x9c(%ebx)
80105e8c:	c6 83 9d 00 00 00 99 	movb   $0x99,0x9d(%ebx)
80105e93:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105e9a:	83 c0 08             	add    $0x8,%eax
80105e9d:	c1 e8 18             	shr    $0x18,%eax
80105ea0:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105ea6:	e8 5d d3 ff ff       	call   80103208 <mycpu>
80105eab:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105eb2:	e8 51 d3 ff ff       	call   80103208 <mycpu>
80105eb7:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105ebd:	e8 46 d3 ff ff       	call   80103208 <mycpu>
80105ec2:	8b 56 08             	mov    0x8(%esi),%edx
80105ec5:	81 c2 00 10 00 00    	add    $0x1000,%edx
80105ecb:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105ece:	e8 35 d3 ff ff       	call   80103208 <mycpu>
80105ed3:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
}

static inline void
ltr(ushort sel)
{
  asm volatile("ltr %0" : : "r" (sel));
80105ed9:	b8 28 00 00 00       	mov    $0x28,%eax
80105ede:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105ee1:	8b 46 04             	mov    0x4(%esi),%eax
80105ee4:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105ee9:	0f 22 d8             	mov    %eax,%cr3
  popcli();
}
80105eec:	83 c4 2c             	add    $0x2c,%esp
80105eef:	5b                   	pop    %ebx
80105ef0:	5e                   	pop    %esi
80105ef1:	5f                   	pop    %edi
80105ef2:	5d                   	pop    %ebp
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
  popcli();
80105ef3:	e9 6c dd ff ff       	jmp    80103c64 <popcli>
// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
80105ef8:	c7 04 24 8e 6d 10 80 	movl   $0x80106d8e,(%esp)
80105eff:	e8 18 a4 ff ff       	call   8010031c <panic>
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
    panic("switchuvm: no pgdir");
80105f04:	c7 04 24 b9 6d 10 80 	movl   $0x80106db9,(%esp)
80105f0b:	e8 0c a4 ff ff       	call   8010031c <panic>
switchuvm(struct proc *p)
{
  if(p == 0)
    panic("switchuvm: no process");
  if(p->kstack == 0)
    panic("switchuvm: no kstack");
80105f10:	c7 04 24 a4 6d 10 80 	movl   $0x80106da4,(%esp)
80105f17:	e8 00 a4 ff ff       	call   8010031c <panic>

80105f1c <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80105f1c:	55                   	push   %ebp
80105f1d:	89 e5                	mov    %esp,%ebp
80105f1f:	57                   	push   %edi
80105f20:	56                   	push   %esi
80105f21:	53                   	push   %ebx
80105f22:	83 ec 2c             	sub    $0x2c,%esp
80105f25:	8b 45 08             	mov    0x8(%ebp),%eax
80105f28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105f2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
80105f2e:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80105f31:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80105f37:	77 54                	ja     80105f8d <inituvm+0x71>
    panic("inituvm: more than a page");
  mem = kalloc();
80105f39:	e8 9e c2 ff ff       	call   801021dc <kalloc>
80105f3e:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80105f40:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80105f47:	00 
80105f48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
80105f4f:	00 
80105f50:	89 04 24             	mov    %eax,(%esp)
80105f53:	e8 54 de ff ff       	call   80103dac <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80105f58:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
80105f5f:	00 
80105f60:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105f66:	89 04 24             	mov    %eax,(%esp)
80105f69:	b9 00 10 00 00       	mov    $0x1000,%ecx
80105f6e:	31 d2                	xor    %edx,%edx
80105f70:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f73:	e8 3c fd ff ff       	call   80105cb4 <mappages>
  memmove(mem, init, sz);
80105f78:	89 75 10             	mov    %esi,0x10(%ebp)
80105f7b:	89 7d 0c             	mov    %edi,0xc(%ebp)
80105f7e:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80105f81:	83 c4 2c             	add    $0x2c,%esp
80105f84:	5b                   	pop    %ebx
80105f85:	5e                   	pop    %esi
80105f86:	5f                   	pop    %edi
80105f87:	5d                   	pop    %ebp
  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
  mem = kalloc();
  memset(mem, 0, PGSIZE);
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
  memmove(mem, init, sz);
80105f88:	e9 af de ff ff       	jmp    80103e3c <memmove>
inituvm(pde_t *pgdir, char *init, uint sz)
{
  char *mem;

  if(sz >= PGSIZE)
    panic("inituvm: more than a page");
80105f8d:	c7 04 24 cd 6d 10 80 	movl   $0x80106dcd,(%esp)
80105f94:	e8 83 a3 ff ff       	call   8010031c <panic>
80105f99:	8d 76 00             	lea    0x0(%esi),%esi

80105f9c <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80105f9c:	55                   	push   %ebp
80105f9d:	89 e5                	mov    %esp,%ebp
80105f9f:	57                   	push   %edi
80105fa0:	56                   	push   %esi
80105fa1:	53                   	push   %ebx
80105fa2:	83 ec 2c             	sub    $0x2c,%esp
80105fa5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80105fa8:	f7 c7 ff 0f 00 00    	test   $0xfff,%edi
80105fae:	0f 85 9d 00 00 00    	jne    80106051 <loaduvm+0xb5>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80105fb4:	8b 4d 18             	mov    0x18(%ebp),%ecx
80105fb7:	85 c9                	test   %ecx,%ecx
80105fb9:	74 71                	je     8010602c <loaduvm+0x90>
80105fbb:	8b 75 18             	mov    0x18(%ebp),%esi
80105fbe:	31 db                	xor    %ebx,%ebx
80105fc0:	eb 40                	jmp    80106002 <loaduvm+0x66>
80105fc2:	66 90                	xchg   %ax,%ax
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
80105fc4:	89 f2                	mov    %esi,%edx
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80105fc6:	89 54 24 0c          	mov    %edx,0xc(%esp)
80105fca:	8b 4d 14             	mov    0x14(%ebp),%ecx
80105fcd:	01 d9                	add    %ebx,%ecx
80105fcf:	89 4c 24 08          	mov    %ecx,0x8(%esp)
80105fd3:	05 00 00 00 80       	add    $0x80000000,%eax
80105fd8:	89 44 24 04          	mov    %eax,0x4(%esp)
80105fdc:	8b 45 10             	mov    0x10(%ebp),%eax
80105fdf:	89 04 24             	mov    %eax,(%esp)
80105fe2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80105fe5:	e8 9a b7 ff ff       	call   80101784 <readi>
80105fea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80105fed:	39 d0                	cmp    %edx,%eax
80105fef:	75 47                	jne    80106038 <loaduvm+0x9c>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80105ff1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105ff7:	81 ee 00 10 00 00    	sub    $0x1000,%esi
80105ffd:	39 5d 18             	cmp    %ebx,0x18(%ebp)
80106000:	76 2a                	jbe    8010602c <loaduvm+0x90>
}

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
80106002:	8d 14 1f             	lea    (%edi,%ebx,1),%edx
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106005:	31 c9                	xor    %ecx,%ecx
80106007:	8b 45 08             	mov    0x8(%ebp),%eax
8010600a:	e8 29 fc ff ff       	call   80105c38 <walkpgdir>
8010600f:	85 c0                	test   %eax,%eax
80106011:	74 32                	je     80106045 <loaduvm+0xa9>
      panic("loaduvm: address should exist");
    pa = PTE_ADDR(*pte);
80106013:	8b 00                	mov    (%eax),%eax
80106015:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010601a:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106020:	76 a2                	jbe    80105fc4 <loaduvm+0x28>
      n = sz - i;
    else
      n = PGSIZE;
80106022:	ba 00 10 00 00       	mov    $0x1000,%edx
80106027:	eb 9d                	jmp    80105fc6 <loaduvm+0x2a>
80106029:	8d 76 00             	lea    0x0(%esi),%esi
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
8010602c:	31 c0                	xor    %eax,%eax
}
8010602e:	83 c4 2c             	add    $0x2c,%esp
80106031:	5b                   	pop    %ebx
80106032:	5e                   	pop    %esi
80106033:	5f                   	pop    %edi
80106034:	5d                   	pop    %ebp
80106035:	c3                   	ret    
80106036:	66 90                	xchg   %ax,%ax
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
      return -1;
80106038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
8010603d:	83 c4 2c             	add    $0x2c,%esp
80106040:	5b                   	pop    %ebx
80106041:	5e                   	pop    %esi
80106042:	5f                   	pop    %edi
80106043:	5d                   	pop    %ebp
80106044:	c3                   	ret    

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106045:	c7 04 24 e7 6d 10 80 	movl   $0x80106de7,(%esp)
8010604c:	e8 cb a2 ff ff       	call   8010031c <panic>
{
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
80106051:	c7 04 24 88 6e 10 80 	movl   $0x80106e88,(%esp)
80106058:	e8 bf a2 ff ff       	call   8010031c <panic>
8010605d:	8d 76 00             	lea    0x0(%esi),%esi

80106060 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106060:	55                   	push   %ebp
80106061:	89 e5                	mov    %esp,%ebp
80106063:	57                   	push   %edi
80106064:	56                   	push   %esi
80106065:	53                   	push   %ebx
80106066:	83 ec 2c             	sub    $0x2c,%esp
80106069:	8b 7d 08             	mov    0x8(%ebp),%edi
8010606c:	8b 75 0c             	mov    0xc(%ebp),%esi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
8010606f:	39 75 10             	cmp    %esi,0x10(%ebp)
80106072:	73 7c                	jae    801060f0 <deallocuvm+0x90>
    return oldsz;

  a = PGROUNDUP(newsz);
80106074:	8b 5d 10             	mov    0x10(%ebp),%ebx
80106077:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
8010607d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106083:	39 de                	cmp    %ebx,%esi
80106085:	77 38                	ja     801060bf <deallocuvm+0x5f>
80106087:	eb 5b                	jmp    801060e4 <deallocuvm+0x84>
80106089:	8d 76 00             	lea    0x0(%esi),%esi
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
8010608c:	8b 10                	mov    (%eax),%edx
8010608e:	f6 c2 01             	test   $0x1,%dl
80106091:	74 22                	je     801060b5 <deallocuvm+0x55>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106093:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
80106099:	74 5f                	je     801060fa <deallocuvm+0x9a>
        panic("kfree");
      char *v = P2V(pa);
8010609b:	81 c2 00 00 00 80    	add    $0x80000000,%edx
      kfree(v);
801060a1:	89 14 24             	mov    %edx,(%esp)
801060a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801060a7:	e8 ec bf ff ff       	call   80102098 <kfree>
      *pte = 0;
801060ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801060b5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060bb:	39 de                	cmp    %ebx,%esi
801060bd:	76 25                	jbe    801060e4 <deallocuvm+0x84>
    pte = walkpgdir(pgdir, (char*)a, 0);
801060bf:	31 c9                	xor    %ecx,%ecx
801060c1:	89 da                	mov    %ebx,%edx
801060c3:	89 f8                	mov    %edi,%eax
801060c5:	e8 6e fb ff ff       	call   80105c38 <walkpgdir>
    if(!pte)
801060ca:	85 c0                	test   %eax,%eax
801060cc:	75 be                	jne    8010608c <deallocuvm+0x2c>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801060ce:	81 e3 00 00 c0 ff    	and    $0xffc00000,%ebx
801060d4:	81 c3 00 f0 3f 00    	add    $0x3ff000,%ebx

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
801060da:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060e0:	39 de                	cmp    %ebx,%esi
801060e2:	77 db                	ja     801060bf <deallocuvm+0x5f>
      char *v = P2V(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
801060e4:	8b 45 10             	mov    0x10(%ebp),%eax
}
801060e7:	83 c4 2c             	add    $0x2c,%esp
801060ea:	5b                   	pop    %ebx
801060eb:	5e                   	pop    %esi
801060ec:	5f                   	pop    %edi
801060ed:	5d                   	pop    %ebp
801060ee:	c3                   	ret    
801060ef:	90                   	nop
{
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;
801060f0:	89 f0                	mov    %esi,%eax
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
801060f2:	83 c4 2c             	add    $0x2c,%esp
801060f5:	5b                   	pop    %ebx
801060f6:	5e                   	pop    %esi
801060f7:	5f                   	pop    %edi
801060f8:	5d                   	pop    %ebp
801060f9:	c3                   	ret    
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
      pa = PTE_ADDR(*pte);
      if(pa == 0)
        panic("kfree");
801060fa:	c7 04 24 46 67 10 80 	movl   $0x80106746,(%esp)
80106101:	e8 16 a2 ff ff       	call   8010031c <panic>
80106106:	66 90                	xchg   %ax,%ax

80106108 <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106108:	55                   	push   %ebp
80106109:	89 e5                	mov    %esp,%ebp
8010610b:	57                   	push   %edi
8010610c:	56                   	push   %esi
8010610d:	53                   	push   %ebx
8010610e:	83 ec 1c             	sub    $0x1c,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80106111:	8b 7d 10             	mov    0x10(%ebp),%edi
80106114:	85 ff                	test   %edi,%edi
80106116:	0f 88 b8 00 00 00    	js     801061d4 <allocuvm+0xcc>
    return 0;
  if(newsz < oldsz)
8010611c:	3b 7d 0c             	cmp    0xc(%ebp),%edi
8010611f:	0f 82 9f 00 00 00    	jb     801061c4 <allocuvm+0xbc>
    return oldsz;

  a = PGROUNDUP(oldsz);
80106125:	8b 75 0c             	mov    0xc(%ebp),%esi
80106128:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
8010612e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80106134:	39 75 10             	cmp    %esi,0x10(%ebp)
80106137:	77 4e                	ja     80106187 <allocuvm+0x7f>
80106139:	e9 89 00 00 00       	jmp    801061c7 <allocuvm+0xbf>
8010613e:	66 90                	xchg   %ax,%ax
    if(mem == 0){
      cprintf("allocuvm out of memory\n");
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
80106140:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
80106147:	00 
80106148:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
8010614f:	00 
80106150:	89 04 24             	mov    %eax,(%esp)
80106153:	e8 54 dc ff ff       	call   80103dac <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106158:	c7 44 24 04 06 00 00 	movl   $0x6,0x4(%esp)
8010615f:	00 
80106160:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106166:	89 04 24             	mov    %eax,(%esp)
80106169:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010616e:	89 f2                	mov    %esi,%edx
80106170:	8b 45 08             	mov    0x8(%ebp),%eax
80106173:	e8 3c fb ff ff       	call   80105cb4 <mappages>
80106178:	85 c0                	test   %eax,%eax
8010617a:	78 64                	js     801061e0 <allocuvm+0xd8>
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
8010617c:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106182:	39 75 10             	cmp    %esi,0x10(%ebp)
80106185:	76 40                	jbe    801061c7 <allocuvm+0xbf>
    mem = kalloc();
80106187:	e8 50 c0 ff ff       	call   801021dc <kalloc>
8010618c:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
8010618e:	85 c0                	test   %eax,%eax
80106190:	75 ae                	jne    80106140 <allocuvm+0x38>
      cprintf("allocuvm out of memory\n");
80106192:	c7 04 24 05 6e 10 80 	movl   $0x80106e05,(%esp)
80106199:	e8 1e a4 ff ff       	call   801005bc <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010619e:	8b 45 0c             	mov    0xc(%ebp),%eax
801061a1:	89 44 24 08          	mov    %eax,0x8(%esp)
801061a5:	8b 45 10             	mov    0x10(%ebp),%eax
801061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
801061ac:	8b 45 08             	mov    0x8(%ebp),%eax
801061af:	89 04 24             	mov    %eax,(%esp)
801061b2:	e8 a9 fe ff ff       	call   80106060 <deallocuvm>
      return 0;
801061b7:	31 ff                	xor    %edi,%edi
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
801061b9:	89 f8                	mov    %edi,%eax
801061bb:	83 c4 1c             	add    $0x1c,%esp
801061be:	5b                   	pop    %ebx
801061bf:	5e                   	pop    %esi
801061c0:	5f                   	pop    %edi
801061c1:	5d                   	pop    %ebp
801061c2:	c3                   	ret    
801061c3:	90                   	nop
  uint a;

  if(newsz >= KERNBASE)
    return 0;
  if(newsz < oldsz)
    return oldsz;
801061c4:	8b 7d 0c             	mov    0xc(%ebp),%edi
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
801061c7:	89 f8                	mov    %edi,%eax
801061c9:	83 c4 1c             	add    $0x1c,%esp
801061cc:	5b                   	pop    %ebx
801061cd:	5e                   	pop    %esi
801061ce:	5f                   	pop    %edi
801061cf:	5d                   	pop    %ebp
801061d0:	c3                   	ret    
801061d1:	8d 76 00             	lea    0x0(%esi),%esi
{
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
    return 0;
801061d4:	31 ff                	xor    %edi,%edi
      kfree(mem);
      return 0;
    }
  }
  return newsz;
}
801061d6:	89 f8                	mov    %edi,%eax
801061d8:	83 c4 1c             	add    $0x1c,%esp
801061db:	5b                   	pop    %ebx
801061dc:	5e                   	pop    %esi
801061dd:	5f                   	pop    %edi
801061de:	5d                   	pop    %ebp
801061df:	c3                   	ret    
      deallocuvm(pgdir, newsz, oldsz);
      return 0;
    }
    memset(mem, 0, PGSIZE);
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
      cprintf("allocuvm out of memory (2)\n");
801061e0:	c7 04 24 1d 6e 10 80 	movl   $0x80106e1d,(%esp)
801061e7:	e8 d0 a3 ff ff       	call   801005bc <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801061ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801061ef:	89 44 24 08          	mov    %eax,0x8(%esp)
801061f3:	8b 45 10             	mov    0x10(%ebp),%eax
801061f6:	89 44 24 04          	mov    %eax,0x4(%esp)
801061fa:	8b 45 08             	mov    0x8(%ebp),%eax
801061fd:	89 04 24             	mov    %eax,(%esp)
80106200:	e8 5b fe ff ff       	call   80106060 <deallocuvm>
      kfree(mem);
80106205:	89 1c 24             	mov    %ebx,(%esp)
80106208:	e8 8b be ff ff       	call   80102098 <kfree>
      return 0;
8010620d:	31 ff                	xor    %edi,%edi
    }
  }
  return newsz;
}
8010620f:	89 f8                	mov    %edi,%eax
80106211:	83 c4 1c             	add    $0x1c,%esp
80106214:	5b                   	pop    %ebx
80106215:	5e                   	pop    %esi
80106216:	5f                   	pop    %edi
80106217:	5d                   	pop    %ebp
80106218:	c3                   	ret    
80106219:	8d 76 00             	lea    0x0(%esi),%esi

8010621c <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010621c:	55                   	push   %ebp
8010621d:	89 e5                	mov    %esp,%ebp
8010621f:	56                   	push   %esi
80106220:	53                   	push   %ebx
80106221:	83 ec 10             	sub    $0x10,%esp
80106224:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint i;

  if(pgdir == 0)
80106227:	85 db                	test   %ebx,%ebx
80106229:	74 56                	je     80106281 <freevm+0x65>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010622b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
80106232:	00 
80106233:	c7 44 24 04 00 00 00 	movl   $0x80000000,0x4(%esp)
8010623a:	80 
8010623b:	89 1c 24             	mov    %ebx,(%esp)
8010623e:	e8 1d fe ff ff       	call   80106060 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106243:	31 f6                	xor    %esi,%esi
80106245:	eb 0a                	jmp    80106251 <freevm+0x35>
80106247:	90                   	nop
80106248:	46                   	inc    %esi
80106249:	81 fe 00 04 00 00    	cmp    $0x400,%esi
8010624f:	74 22                	je     80106273 <freevm+0x57>
    if(pgdir[i] & PTE_P){
80106251:	8b 04 b3             	mov    (%ebx,%esi,4),%eax
80106254:	a8 01                	test   $0x1,%al
80106256:	74 f0                	je     80106248 <freevm+0x2c>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106258:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010625d:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106262:	89 04 24             	mov    %eax,(%esp)
80106265:	e8 2e be ff ff       	call   80102098 <kfree>
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
8010626a:	46                   	inc    %esi
8010626b:	81 fe 00 04 00 00    	cmp    $0x400,%esi
80106271:	75 de                	jne    80106251 <freevm+0x35>
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80106273:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80106276:	83 c4 10             	add    $0x10,%esp
80106279:	5b                   	pop    %ebx
8010627a:	5e                   	pop    %esi
8010627b:	5d                   	pop    %ebp
    if(pgdir[i] & PTE_P){
      char * v = P2V(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
8010627c:	e9 17 be ff ff       	jmp    80102098 <kfree>
freevm(pde_t *pgdir)
{
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
80106281:	c7 04 24 39 6e 10 80 	movl   $0x80106e39,(%esp)
80106288:	e8 8f a0 ff ff       	call   8010031c <panic>
8010628d:	8d 76 00             	lea    0x0(%esi),%esi

80106290 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80106290:	55                   	push   %ebp
80106291:	89 e5                	mov    %esp,%ebp
80106293:	56                   	push   %esi
80106294:	53                   	push   %ebx
80106295:	83 ec 10             	sub    $0x10,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80106298:	e8 3f bf ff ff       	call   801021dc <kalloc>
8010629d:	89 c6                	mov    %eax,%esi
8010629f:	85 c0                	test   %eax,%eax
801062a1:	74 47                	je     801062ea <setupkvm+0x5a>
    return 0;
  memset(pgdir, 0, PGSIZE);
801062a3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
801062aa:	00 
801062ab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
801062b2:	00 
801062b3:	89 04 24             	mov    %eax,(%esp)
801062b6:	e8 f1 da ff ff       	call   80103dac <memset>
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062bb:	bb 20 94 10 80       	mov    $0x80109420,%ebx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801062c0:	8b 43 04             	mov    0x4(%ebx),%eax
801062c3:	8b 4b 08             	mov    0x8(%ebx),%ecx
801062c6:	29 c1                	sub    %eax,%ecx
801062c8:	8b 53 0c             	mov    0xc(%ebx),%edx
801062cb:	89 54 24 04          	mov    %edx,0x4(%esp)
801062cf:	89 04 24             	mov    %eax,(%esp)
801062d2:	8b 13                	mov    (%ebx),%edx
801062d4:	89 f0                	mov    %esi,%eax
801062d6:	e8 d9 f9 ff ff       	call   80105cb4 <mappages>
801062db:	85 c0                	test   %eax,%eax
801062dd:	78 15                	js     801062f4 <setupkvm+0x64>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062df:	83 c3 10             	add    $0x10,%ebx
801062e2:	81 fb 60 94 10 80    	cmp    $0x80109460,%ebx
801062e8:	72 d6                	jb     801062c0 <setupkvm+0x30>
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
      return 0;
    }
  return pgdir;
}
801062ea:	89 f0                	mov    %esi,%eax
801062ec:	83 c4 10             	add    $0x10,%esp
801062ef:	5b                   	pop    %ebx
801062f0:	5e                   	pop    %esi
801062f1:	5d                   	pop    %ebp
801062f2:	c3                   	ret    
801062f3:	90                   	nop
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
                (uint)k->phys_start, k->perm) < 0) {
      freevm(pgdir);
801062f4:	89 34 24             	mov    %esi,(%esp)
801062f7:	e8 20 ff ff ff       	call   8010621c <freevm>
      return 0;
801062fc:	31 f6                	xor    %esi,%esi
    }
  return pgdir;
}
801062fe:	89 f0                	mov    %esi,%eax
80106300:	83 c4 10             	add    $0x10,%esp
80106303:	5b                   	pop    %ebx
80106304:	5e                   	pop    %esi
80106305:	5d                   	pop    %ebp
80106306:	c3                   	ret    
80106307:	90                   	nop

80106308 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80106308:	55                   	push   %ebp
80106309:	89 e5                	mov    %esp,%ebp
8010630b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010630e:	e8 7d ff ff ff       	call   80106290 <setupkvm>
80106313:	a3 a4 44 11 80       	mov    %eax,0x801144a4
// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80106318:	05 00 00 00 80       	add    $0x80000000,%eax
8010631d:	0f 22 d8             	mov    %eax,%cr3
void
kvmalloc(void)
{
  kpgdir = setupkvm();
  switchkvm();
}
80106320:	c9                   	leave  
80106321:	c3                   	ret    
80106322:	66 90                	xchg   %ax,%ax

80106324 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106324:	55                   	push   %ebp
80106325:	89 e5                	mov    %esp,%ebp
80106327:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010632a:	31 c9                	xor    %ecx,%ecx
8010632c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010632f:	8b 45 08             	mov    0x8(%ebp),%eax
80106332:	e8 01 f9 ff ff       	call   80105c38 <walkpgdir>
  if(pte == 0)
80106337:	85 c0                	test   %eax,%eax
80106339:	74 05                	je     80106340 <clearpteu+0x1c>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010633b:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010633e:	c9                   	leave  
8010633f:	c3                   	ret    
{
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
80106340:	c7 04 24 4a 6e 10 80 	movl   $0x80106e4a,(%esp)
80106347:	e8 d0 9f ff ff       	call   8010031c <panic>

8010634c <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
8010634c:	55                   	push   %ebp
8010634d:	89 e5                	mov    %esp,%ebp
8010634f:	57                   	push   %edi
80106350:	56                   	push   %esi
80106351:	53                   	push   %ebx
80106352:	83 ec 2c             	sub    $0x2c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106355:	e8 36 ff ff ff       	call   80106290 <setupkvm>
8010635a:	89 c7                	mov    %eax,%edi
8010635c:	85 c0                	test   %eax,%eax
8010635e:	0f 84 91 00 00 00    	je     801063f5 <copyuvm+0xa9>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106364:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80106367:	85 db                	test   %ebx,%ebx
80106369:	0f 84 86 00 00 00    	je     801063f5 <copyuvm+0xa9>
8010636f:	31 f6                	xor    %esi,%esi
80106371:	eb 54                	jmp    801063c7 <copyuvm+0x7b>
80106373:	90                   	nop
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106374:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
8010637b:	00 
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010637c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010637f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106384:	05 00 00 00 80       	add    $0x80000000,%eax
80106389:	89 44 24 04          	mov    %eax,0x4(%esp)
8010638d:	89 1c 24             	mov    %ebx,(%esp)
80106390:	e8 a7 da ff ff       	call   80103e3c <memmove>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
80106395:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106398:	25 ff 0f 00 00       	and    $0xfff,%eax
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010639d:	89 44 24 04          	mov    %eax,0x4(%esp)
801063a1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801063a7:	89 04 24             	mov    %eax,(%esp)
801063aa:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063af:	89 f2                	mov    %esi,%edx
801063b1:	89 f8                	mov    %edi,%eax
801063b3:	e8 fc f8 ff ff       	call   80105cb4 <mappages>
801063b8:	85 c0                	test   %eax,%eax
801063ba:	78 44                	js     80106400 <copyuvm+0xb4>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801063bc:	81 c6 00 10 00 00    	add    $0x1000,%esi
801063c2:	39 75 0c             	cmp    %esi,0xc(%ebp)
801063c5:	76 2e                	jbe    801063f5 <copyuvm+0xa9>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801063c7:	31 c9                	xor    %ecx,%ecx
801063c9:	89 f2                	mov    %esi,%edx
801063cb:	8b 45 08             	mov    0x8(%ebp),%eax
801063ce:	e8 65 f8 ff ff       	call   80105c38 <walkpgdir>
801063d3:	85 c0                	test   %eax,%eax
801063d5:	74 3f                	je     80106416 <copyuvm+0xca>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801063d7:	8b 00                	mov    (%eax),%eax
801063d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801063dc:	a8 01                	test   $0x1,%al
801063de:	74 2a                	je     8010640a <copyuvm+0xbe>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
801063e0:	e8 f7 bd ff ff       	call   801021dc <kalloc>
801063e5:	89 c3                	mov    %eax,%ebx
801063e7:	85 c0                	test   %eax,%eax
801063e9:	75 89                	jne    80106374 <copyuvm+0x28>
    }
  }
  return d;

bad:
  freevm(d);
801063eb:	89 3c 24             	mov    %edi,(%esp)
801063ee:	e8 29 fe ff ff       	call   8010621c <freevm>
  return 0;
801063f3:	31 ff                	xor    %edi,%edi
}
801063f5:	89 f8                	mov    %edi,%eax
801063f7:	83 c4 2c             	add    $0x2c,%esp
801063fa:	5b                   	pop    %ebx
801063fb:	5e                   	pop    %esi
801063fc:	5f                   	pop    %edi
801063fd:	5d                   	pop    %ebp
801063fe:	c3                   	ret    
801063ff:	90                   	nop
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
      kfree(mem);
80106400:	89 1c 24             	mov    %ebx,(%esp)
80106403:	e8 90 bc ff ff       	call   80102098 <kfree>
      goto bad;
80106408:	eb e1                	jmp    801063eb <copyuvm+0x9f>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
8010640a:	c7 04 24 6e 6e 10 80 	movl   $0x80106e6e,(%esp)
80106411:	e8 06 9f ff ff       	call   8010031c <panic>

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
      panic("copyuvm: pte should exist");
80106416:	c7 04 24 54 6e 10 80 	movl   $0x80106e54,(%esp)
8010641d:	e8 fa 9e ff ff       	call   8010031c <panic>
80106422:	66 90                	xchg   %ax,%ax

80106424 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106424:	55                   	push   %ebp
80106425:	89 e5                	mov    %esp,%ebp
80106427:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010642a:	31 c9                	xor    %ecx,%ecx
8010642c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010642f:	8b 45 08             	mov    0x8(%ebp),%eax
80106432:	e8 01 f8 ff ff       	call   80105c38 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106437:	8b 00                	mov    (%eax),%eax
80106439:	a8 01                	test   $0x1,%al
8010643b:	74 13                	je     80106450 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010643d:	a8 04                	test   $0x4,%al
8010643f:	74 0f                	je     80106450 <uva2ka+0x2c>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106441:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106446:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010644b:	c9                   	leave  
8010644c:	c3                   	ret    
8010644d:	8d 76 00             	lea    0x0(%esi),%esi

  pte = walkpgdir(pgdir, uva, 0);
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
80106450:	31 c0                	xor    %eax,%eax
  return (char*)P2V(PTE_ADDR(*pte));
}
80106452:	c9                   	leave  
80106453:	c3                   	ret    

80106454 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106454:	55                   	push   %ebp
80106455:	89 e5                	mov    %esp,%ebp
80106457:	57                   	push   %edi
80106458:	56                   	push   %esi
80106459:	53                   	push   %ebx
8010645a:	83 ec 2c             	sub    $0x2c,%esp
8010645d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106460:	8b 75 14             	mov    0x14(%ebp),%esi
80106463:	85 f6                	test   %esi,%esi
80106465:	74 69                	je     801064d0 <copyout+0x7c>
80106467:	8b 55 10             	mov    0x10(%ebp),%edx
8010646a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010646d:	eb 38                	jmp    801064a7 <copyout+0x53>
8010646f:	90                   	nop
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
80106470:	89 f3                	mov    %esi,%ebx
80106472:	29 fb                	sub    %edi,%ebx
80106474:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010647a:	3b 5d 14             	cmp    0x14(%ebp),%ebx
8010647d:	76 03                	jbe    80106482 <copyout+0x2e>
8010647f:	8b 5d 14             	mov    0x14(%ebp),%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106482:	89 5c 24 08          	mov    %ebx,0x8(%esp)
80106486:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106489:	89 54 24 04          	mov    %edx,0x4(%esp)
8010648d:	29 f7                	sub    %esi,%edi
8010648f:	01 c7                	add    %eax,%edi
80106491:	89 3c 24             	mov    %edi,(%esp)
80106494:	e8 a3 d9 ff ff       	call   80103e3c <memmove>
    len -= n;
    buf += n;
80106499:	01 5d e4             	add    %ebx,-0x1c(%ebp)
    va = va0 + PGSIZE;
8010649c:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801064a2:	29 5d 14             	sub    %ebx,0x14(%ebp)
801064a5:	74 29                	je     801064d0 <copyout+0x7c>
    va0 = (uint)PGROUNDDOWN(va);
801064a7:	89 fe                	mov    %edi,%esi
801064a9:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801064af:	89 74 24 04          	mov    %esi,0x4(%esp)
801064b3:	8b 55 08             	mov    0x8(%ebp),%edx
801064b6:	89 14 24             	mov    %edx,(%esp)
801064b9:	e8 66 ff ff ff       	call   80106424 <uva2ka>
    if(pa0 == 0)
801064be:	85 c0                	test   %eax,%eax
801064c0:	75 ae                	jne    80106470 <copyout+0x1c>
      return -1;
801064c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
}
801064c7:	83 c4 2c             	add    $0x2c,%esp
801064ca:	5b                   	pop    %ebx
801064cb:	5e                   	pop    %esi
801064cc:	5f                   	pop    %edi
801064cd:	5d                   	pop    %ebp
801064ce:	c3                   	ret    
801064cf:	90                   	nop
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
801064d0:	31 c0                	xor    %eax,%eax
}
801064d2:	83 c4 2c             	add    $0x2c,%esp
801064d5:	5b                   	pop    %ebx
801064d6:	5e                   	pop    %esi
801064d7:	5f                   	pop    %edi
801064d8:	5d                   	pop    %ebp
801064d9:	c3                   	ret    
