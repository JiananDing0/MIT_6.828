
bootblock.o:     file format elf32-i386


Disassembly of section .text:

00007c00 <start>:
# with %cs=0 %ip=7c00.

.code16                       # Assemble for 16-bit mode
.globl start
start:
  cli                         # BIOS enabled interrupts; disable
    7c00:	fa                   	cli    

  # Zero data segment registers DS, ES, and SS.
  xorw    %ax,%ax             # Set %ax to zero
    7c01:	31 c0                	xor    %eax,%eax
  movw    %ax,%ds             # -> Data Segment
    7c03:	8e d8                	mov    %eax,%ds
  movw    %ax,%es             # -> Extra Segment
    7c05:	8e c0                	mov    %eax,%es
  movw    %ax,%ss             # -> Stack Segment
    7c07:	8e d0                	mov    %eax,%ss

00007c09 <seta20.1>:

  # Physical address line A20 is tied to zero so that the first PCs 
  # with 2 MB would run software that assumed 1 MB.  Undo that.
seta20.1:
  inb     $0x64,%al               # Wait for not busy
    7c09:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c0b:	a8 02                	test   $0x2,%al
  jnz     seta20.1
    7c0d:	75 fa                	jne    7c09 <seta20.1>

  movb    $0xd1,%al               # 0xd1 -> port 0x64
    7c0f:	b0 d1                	mov    $0xd1,%al
  outb    %al,$0x64
    7c11:	e6 64                	out    %al,$0x64

00007c13 <seta20.2>:

seta20.2:
  inb     $0x64,%al               # Wait for not busy
    7c13:	e4 64                	in     $0x64,%al
  testb   $0x2,%al
    7c15:	a8 02                	test   $0x2,%al
  jnz     seta20.2
    7c17:	75 fa                	jne    7c13 <seta20.2>

  movb    $0xdf,%al               # 0xdf -> port 0x60
    7c19:	b0 df                	mov    $0xdf,%al
  outb    %al,$0x60
    7c1b:	e6 60                	out    %al,$0x60

  # Switch from real to protected mode.  Use a bootstrap GDT that makes
  # virtual addresses map directly to physical addresses so that the
  # effective memory map doesn't change during the transition.
  lgdt    gdtdesc
    7c1d:	0f 01 16             	lgdtl  (%esi)
    7c20:	78 7c                	js     7c9e <readsect+0x9>
  movl    %cr0, %eax
    7c22:	0f 20 c0             	mov    %cr0,%eax
  orl     $CR0_PE, %eax
    7c25:	66 83 c8 01          	or     $0x1,%ax
  movl    %eax, %cr0
    7c29:	0f 22 c0             	mov    %eax,%cr0

//PAGEBREAK!
  # Complete the transition to 32-bit protected mode by using a long jmp
  # to reload %cs and %eip.  The segment descriptors are set up with no
  # translation, so that the mapping is still the identity mapping.
  ljmp    $(SEG_KCODE<<3), $start32
    7c2c:	ea 31 7c 08 00 66 b8 	ljmp   $0xb866,$0x87c31

00007c31 <start32>:

.code32  # Tell assembler to generate 32-bit code now.
start32:
  # Set up the protected-mode data segment registers
  movw    $(SEG_KDATA<<3), %ax    # Our data segment selector
    7c31:	66 b8 10 00          	mov    $0x10,%ax
  movw    %ax, %ds                # -> DS: Data Segment
    7c35:	8e d8                	mov    %eax,%ds
  movw    %ax, %es                # -> ES: Extra Segment
    7c37:	8e c0                	mov    %eax,%es
  movw    %ax, %ss                # -> SS: Stack Segment
    7c39:	8e d0                	mov    %eax,%ss
  movw    $0, %ax                 # Zero segments not ready for use
    7c3b:	66 b8 00 00          	mov    $0x0,%ax
  movw    %ax, %fs                # -> FS
    7c3f:	8e e0                	mov    %eax,%fs
  movw    %ax, %gs                # -> GS
    7c41:	8e e8                	mov    %eax,%gs

  # Set up the stack pointer and call into C.
  movl    $start, %esp
    7c43:	bc 00 7c 00 00       	mov    $0x7c00,%esp
  call    bootmain
    7c48:	e8 dd 00 00 00       	call   7d2a <bootmain>

  # If bootmain returns (it shouldn't), trigger a Bochs
  # breakpoint if running under Bochs, then loop.
  movw    $0x8a00, %ax            # 0x8a00 -> port 0x8a00
    7c4d:	66 b8 00 8a          	mov    $0x8a00,%ax
  movw    %ax, %dx
    7c51:	66 89 c2             	mov    %ax,%dx
  outw    %ax, %dx
    7c54:	66 ef                	out    %ax,(%dx)
  movw    $0x8ae0, %ax            # 0x8ae0 -> port 0x8a00
    7c56:	66 b8 e0 8a          	mov    $0x8ae0,%ax
  outw    %ax, %dx
    7c5a:	66 ef                	out    %ax,(%dx)

00007c5c <spin>:
spin:
  jmp     spin
    7c5c:	eb fe                	jmp    7c5c <spin>
    7c5e:	66 90                	xchg   %ax,%ax

00007c60 <gdt>:
	...
    7c68:	ff                   	(bad)  
    7c69:	ff 00                	incl   (%eax)
    7c6b:	00 00                	add    %al,(%eax)
    7c6d:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
    7c74:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

00007c78 <gdtdesc>:
    7c78:	17                   	pop    %ss
    7c79:	00 60 7c             	add    %ah,0x7c(%eax)
    7c7c:	00 00                	add    %al,(%eax)
    7c7e:	90                   	nop
    7c7f:	90                   	nop

00007c80 <waitdisk>:
  entry();
}

void
waitdisk(void)
{
    7c80:	55                   	push   %ebp
    7c81:	89 e5                	mov    %esp,%ebp
static inline uchar
inb(ushort port)
{
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
    7c83:	ba f7 01 00 00       	mov    $0x1f7,%edx
    7c88:	ec                   	in     (%dx),%al
  // Wait for disk ready.
  while((inb(0x1F7) & 0xC0) != 0x40)
    7c89:	25 c0 00 00 00       	and    $0xc0,%eax
    7c8e:	83 f8 40             	cmp    $0x40,%eax
    7c91:	75 f5                	jne    7c88 <waitdisk+0x8>
    ;
}
    7c93:	5d                   	pop    %ebp
    7c94:	c3                   	ret    

00007c95 <readsect>:

// Read a single sector at offset into dst.
void
readsect(void *dst, uint offset)
{
    7c95:	55                   	push   %ebp
    7c96:	89 e5                	mov    %esp,%ebp
    7c98:	57                   	push   %edi
    7c99:	8b 7d 0c             	mov    0xc(%ebp),%edi
  // Issue command.
  waitdisk();
    7c9c:	e8 df ff ff ff       	call   7c80 <waitdisk>
}

static inline void
outb(ushort port, uchar data)
{
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
    7ca1:	ba f2 01 00 00       	mov    $0x1f2,%edx
    7ca6:	b0 01                	mov    $0x1,%al
    7ca8:	ee                   	out    %al,(%dx)
    7ca9:	b2 f3                	mov    $0xf3,%dl
    7cab:	89 f8                	mov    %edi,%eax
    7cad:	ee                   	out    %al,(%dx)
  outb(0x1F2, 1);   // count = 1
  outb(0x1F3, offset);
  outb(0x1F4, offset >> 8);
    7cae:	89 f8                	mov    %edi,%eax
    7cb0:	c1 e8 08             	shr    $0x8,%eax
    7cb3:	b2 f4                	mov    $0xf4,%dl
    7cb5:	ee                   	out    %al,(%dx)
  outb(0x1F5, offset >> 16);
    7cb6:	89 f8                	mov    %edi,%eax
    7cb8:	c1 e8 10             	shr    $0x10,%eax
    7cbb:	b2 f5                	mov    $0xf5,%dl
    7cbd:	ee                   	out    %al,(%dx)
  outb(0x1F6, (offset >> 24) | 0xE0);
    7cbe:	c1 ef 18             	shr    $0x18,%edi
    7cc1:	89 f8                	mov    %edi,%eax
    7cc3:	83 c8 e0             	or     $0xffffffe0,%eax
    7cc6:	b2 f6                	mov    $0xf6,%dl
    7cc8:	ee                   	out    %al,(%dx)
    7cc9:	b2 f7                	mov    $0xf7,%dl
    7ccb:	b0 20                	mov    $0x20,%al
    7ccd:	ee                   	out    %al,(%dx)
  outb(0x1F7, 0x20);  // cmd 0x20 - read sectors

  // Read data.
  waitdisk();
    7cce:	e8 ad ff ff ff       	call   7c80 <waitdisk>
}

static inline void
insl(int port, void *addr, int cnt)
{
  asm volatile("cld; rep insl" :
    7cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
    7cd6:	b9 80 00 00 00       	mov    $0x80,%ecx
    7cdb:	ba f0 01 00 00       	mov    $0x1f0,%edx
    7ce0:	fc                   	cld    
    7ce1:	f3 6d                	rep insl (%dx),%es:(%edi)
  insl(0x1F0, dst, SECTSIZE/4);
}
    7ce3:	5f                   	pop    %edi
    7ce4:	5d                   	pop    %ebp
    7ce5:	c3                   	ret    

00007ce6 <readseg>:

// Read 'count' bytes at 'offset' from kernel into physical address 'pa'.
// Might copy more than asked.
void
readseg(uchar* pa, uint count, uint offset)
{
    7ce6:	55                   	push   %ebp
    7ce7:	89 e5                	mov    %esp,%ebp
    7ce9:	57                   	push   %edi
    7cea:	56                   	push   %esi
    7ceb:	53                   	push   %ebx
    7cec:	83 ec 08             	sub    $0x8,%esp
    7cef:	8b 5d 08             	mov    0x8(%ebp),%ebx
    7cf2:	8b 75 10             	mov    0x10(%ebp),%esi
  uchar* epa;

  epa = pa + count;
    7cf5:	89 df                	mov    %ebx,%edi
    7cf7:	03 7d 0c             	add    0xc(%ebp),%edi

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;
    7cfa:	89 f0                	mov    %esi,%eax
    7cfc:	25 ff 01 00 00       	and    $0x1ff,%eax
    7d01:	29 c3                	sub    %eax,%ebx
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d03:	39 df                	cmp    %ebx,%edi
    7d05:	76 1b                	jbe    7d22 <readseg+0x3c>

  // Round down to sector boundary.
  pa -= offset % SECTSIZE;

  // Translate from bytes to sectors; kernel starts at sector 1.
  offset = (offset / SECTSIZE) + 1;
    7d07:	c1 ee 09             	shr    $0x9,%esi
    7d0a:	46                   	inc    %esi

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    readsect(pa, offset);
    7d0b:	89 74 24 04          	mov    %esi,0x4(%esp)
    7d0f:	89 1c 24             	mov    %ebx,(%esp)
    7d12:	e8 7e ff ff ff       	call   7c95 <readsect>
  offset = (offset / SECTSIZE) + 1;

  // If this is too slow, we could read lots of sectors at a time.
  // We'd write more to memory than asked, but it doesn't matter --
  // we load in increasing order.
  for(; pa < epa; pa += SECTSIZE, offset++)
    7d17:	81 c3 00 02 00 00    	add    $0x200,%ebx
    7d1d:	46                   	inc    %esi
    7d1e:	39 df                	cmp    %ebx,%edi
    7d20:	77 e9                	ja     7d0b <readseg+0x25>
    readsect(pa, offset);
}
    7d22:	83 c4 08             	add    $0x8,%esp
    7d25:	5b                   	pop    %ebx
    7d26:	5e                   	pop    %esi
    7d27:	5f                   	pop    %edi
    7d28:	5d                   	pop    %ebp
    7d29:	c3                   	ret    

00007d2a <bootmain>:

void readseg(uchar*, uint, uint);

void
bootmain(void)
{
    7d2a:	55                   	push   %ebp
    7d2b:	89 e5                	mov    %esp,%ebp
    7d2d:	57                   	push   %edi
    7d2e:	56                   	push   %esi
    7d2f:	53                   	push   %ebx
    7d30:	83 ec 2c             	sub    $0x2c,%esp
  uchar* pa;

  elf = (struct elfhdr*)0x10000;  // scratch space

  // Read 1st page off disk
  readseg((uchar*)elf, 4096, 0);
    7d33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
    7d3a:	00 
    7d3b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
    7d42:	00 
    7d43:	c7 04 24 00 00 01 00 	movl   $0x10000,(%esp)
    7d4a:	e8 97 ff ff ff       	call   7ce6 <readseg>

  // Is this an ELF executable?
  if(elf->magic != ELF_MAGIC)
    7d4f:	81 3d 00 00 01 00 7f 	cmpl   $0x464c457f,0x10000
    7d56:	45 4c 46 
    7d59:	75 5d                	jne    7db8 <bootmain+0x8e>
    return;  // let bootasm.S handle error

  // Load each program segment (ignores ph flags).
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
    7d5b:	8b 1d 1c 00 01 00    	mov    0x1001c,%ebx
    7d61:	81 c3 00 00 01 00    	add    $0x10000,%ebx
  eph = ph + elf->phnum;
    7d67:	0f b7 05 2c 00 01 00 	movzwl 0x1002c,%eax
    7d6e:	c1 e0 05             	shl    $0x5,%eax
    7d71:	01 d8                	add    %ebx,%eax
    7d73:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(; ph < eph; ph++){
    7d76:	39 c3                	cmp    %eax,%ebx
    7d78:	73 38                	jae    7db2 <bootmain+0x88>
    pa = (uchar*)ph->paddr;
    7d7a:	8b 73 0c             	mov    0xc(%ebx),%esi
    readseg(pa, ph->filesz, ph->off);
    7d7d:	8b 43 04             	mov    0x4(%ebx),%eax
    7d80:	89 44 24 08          	mov    %eax,0x8(%esp)
    7d84:	8b 43 10             	mov    0x10(%ebx),%eax
    7d87:	89 44 24 04          	mov    %eax,0x4(%esp)
    7d8b:	89 34 24             	mov    %esi,(%esp)
    7d8e:	e8 53 ff ff ff       	call   7ce6 <readseg>
    if(ph->memsz > ph->filesz)
    7d93:	8b 4b 14             	mov    0x14(%ebx),%ecx
    7d96:	8b 43 10             	mov    0x10(%ebx),%eax
    7d99:	39 c1                	cmp    %eax,%ecx
    7d9b:	76 0d                	jbe    7daa <bootmain+0x80>
      stosb(pa + ph->filesz, 0, ph->memsz - ph->filesz);
    7d9d:	8d 3c 06             	lea    (%esi,%eax,1),%edi
    7da0:	29 c1                	sub    %eax,%ecx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
    7da2:	b8 00 00 00 00       	mov    $0x0,%eax
    7da7:	fc                   	cld    
    7da8:	f3 aa                	rep stos %al,%es:(%edi)
    return;  // let bootasm.S handle error

  // Load each program segment (ignores ph flags).
  ph = (struct proghdr*)((uchar*)elf + elf->phoff);
  eph = ph + elf->phnum;
  for(; ph < eph; ph++){
    7daa:	83 c3 20             	add    $0x20,%ebx
    7dad:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
    7db0:	77 c8                	ja     7d7a <bootmain+0x50>
  }

  // Call the entry point from the ELF header.
  // Does not return!
  entry = (void(*)(void))(elf->entry);
  entry();
    7db2:	ff 15 18 00 01 00    	call   *0x10018
}
    7db8:	83 c4 2c             	add    $0x2c,%esp
    7dbb:	5b                   	pop    %ebx
    7dbc:	5e                   	pop    %esi
    7dbd:	5f                   	pop    %edi
    7dbe:	5d                   	pop    %ebp
    7dbf:	c3                   	ret    
